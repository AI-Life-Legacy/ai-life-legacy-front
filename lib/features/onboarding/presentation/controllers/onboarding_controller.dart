import 'dart:async';

import 'package:ai_life_legacy/app/core/routes/app_routes.dart';
import 'package:ai_life_legacy/features/onboarding/data/onboarding_api.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class OnboardingController extends GetxController {
  final OnboardingApi _onboardingApi;

  OnboardingController(this._onboardingApi);

  final currentStep = 1.obs;
  final totalSteps = 4.obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final isSpeechAvailable = false.obs;
  final isSpeechStarting = false.obs;
  final isListening = false.obs;
  final speechStatusMessage = '마이크로 말하면 답변칸에 바로 적어드릴게요.'.obs;

  final q1Controller = TextEditingController();
  final q2Controller = TextEditingController();
  final q3Controller = TextEditingController();
  final q4Controller = TextEditingController();
  final SpeechToText _speechToText = SpeechToText();

  String _speechBaseText = '';

  bool get isFirstStep => currentStep.value == 1;
  bool get isLastStep => currentStep.value == totalSteps.value;
  double get progress => currentStep.value / totalSteps.value;

  String get currentTitle {
    switch (currentStep.value) {
      case 1:
        return '당신을 어떻게 부르면 좋을까요?';
      case 2:
        return '어디에서 어떤 시간을 보내며 자라왔나요?';
      case 3:
        return '삶에서 오래 남아 있는 장면이 있나요?';
      case 4:
        return '꼭 남기고 싶은 이야기가 있다면요?';
      default:
        return '';
    }
  }

  String get currentDescription {
    switch (currentStep.value) {
      case 1:
        return '이름, 나이, 지금의 나를 짧게 적어주세요.';
      case 2:
        return '태어난 곳, 살았던 동네, 학교나 일터처럼 나를 만든 배경을 들려주세요.';
      case 3:
        return '학창 시절, 가족, 일, 사랑, 도전처럼 기억에 남는 경험이면 충분해요.';
      case 4:
        return '아직 정리되지 않은 마음이어도 괜찮아요. 떠오르는 만큼만 남겨주세요.';
      default:
        return '';
    }
  }

  String get currentPlaceholder {
    switch (currentStep.value) {
      case 1:
        return '예: 저는 김하늘이고, 25살입니다. 조용하지만 좋아하는 일에는 오래 몰입하는 편이에요.';
      case 2:
        return '예: 부산에서 태어나 바닷가 근처에서 자랐고, 어린 시절 대부분을 할머니 집에서 보냈어요.';
      case 3:
        return '예: 대학 때 처음 혼자 서울에 올라왔던 순간이 아직도 선명해요.';
      case 4:
        return '예: 가족에게 고맙다고 말하지 못했던 일, 다시 떠올리고 싶은 여행, 가장 힘들었지만 버텼던 시간.';
      default:
        return '';
    }
  }

  IconData get currentIcon {
    switch (currentStep.value) {
      case 1:
        return Icons.badge_outlined;
      case 2:
        return Icons.place_outlined;
      case 3:
        return Icons.timeline;
      case 4:
        return Icons.favorite_border;
      default:
        return Icons.auto_stories_outlined;
    }
  }

  TextEditingController get currentTextController {
    switch (currentStep.value) {
      case 1:
        return q1Controller;
      case 2:
        return q2Controller;
      case 3:
        return q3Controller;
      case 4:
        return q4Controller;
      default:
        return q1Controller;
    }
  }

  void goToPreviousStep() {
    if (isLoading.value || isFirstStep) return;
    stopListening();
    errorMessage.value = '';
    currentStep.value--;
  }

  Future<void> continueFromCurrentStep() async {
    if (isLoading.value) return;
    await stopListening();
    errorMessage.value = '';

    if (!isLastStep) {
      currentStep.value++;
      return;
    }

    await submitIntro();
  }

  @override
  void onClose() {
    _speechToText.cancel();
    q1Controller.dispose();
    q2Controller.dispose();
    q3Controller.dispose();
    q4Controller.dispose();
    super.onClose();
  }

  Future<void> toggleListening() async {
    if (isSpeechStarting.value) return;

    if (isListening.value) {
      await stopListening();
      return;
    }

    await startListening();
  }

  Future<void> startListening() async {
    if (isLoading.value) return;

    isSpeechStarting.value = true;
    speechStatusMessage.value = '마이크를 준비하는 중이에요...';

    try {
      final available = await _speechToText
          .initialize(
            onStatus: _handleSpeechStatus,
            onError: _handleSpeechError,
          )
          .timeout(const Duration(seconds: 8));

      isSpeechAvailable.value = available;
      if (!available) {
        speechStatusMessage.value = '이 기기에서 음성 인식을 사용할 수 없어요.';
        Get.snackbar(
          '음성 인식',
          '마이크 권한이나 기기의 음성 인식 설정을 확인해주세요.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.black87,
          colorText: Colors.white,
        );
        return;
      }

      _speechBaseText = currentTextController.text.trim();
      speechStatusMessage.value = '듣는 중이에요. 편하게 말씀해주세요.';
      isListening.value = true;

      await _speechToText.listen(
        onResult: _handleSpeechResult,
        listenOptions: SpeechListenOptions(
          localeId: 'ko_KR',
          listenMode: ListenMode.dictation,
        ),
      );
    } on TimeoutException {
      speechStatusMessage.value = '마이크 준비가 오래 걸려요. 앱을 다시 실행해보세요.';
      Get.snackbar(
        '음성 인식',
        '플러그인 추가 후에는 앱을 완전히 종료하고 다시 실행해야 할 수 있어요.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.black87,
        colorText: Colors.white,
      );
    } catch (e) {
      speechStatusMessage.value = '음성 인식을 시작하지 못했어요.';
      debugPrint('[OnboardingController] Speech init failed: $e');
    } finally {
      isSpeechStarting.value = false;
    }
  }

  Future<void> stopListening() async {
    if (!isListening.value && !isSpeechStarting.value) return;
    isSpeechStarting.value = false;
    await _speechToText.stop();
    isListening.value = false;
    speechStatusMessage.value = '마이크로 말하면 답변칸에 바로 적어드릴게요.';
  }

  void _handleSpeechResult(SpeechRecognitionResult result) {
    final recognizedText = result.recognizedWords.trim();
    if (recognizedText.isEmpty) return;

    final nextText = _speechBaseText.isEmpty
        ? recognizedText
        : '$_speechBaseText $recognizedText';

    currentTextController
      ..text = nextText
      ..selection = TextSelection.collapsed(offset: nextText.length);
  }

  void _handleSpeechStatus(String status) {
    if (status == 'done' || status == 'notListening') {
      isSpeechStarting.value = false;
      isListening.value = false;
      speechStatusMessage.value = '마이크로 말하면 답변칸에 바로 적어드릴게요.';
    }
  }

  void _handleSpeechError(SpeechRecognitionError error) {
    isSpeechStarting.value = false;
    isListening.value = false;
    speechStatusMessage.value = '음성 인식을 다시 시도해주세요.';
    debugPrint('[OnboardingController] Speech error: ${error.errorMsg}');
  }

  String _combineAnswers() {
    final a1 = q1Controller.text.trim();
    final a2 = q2Controller.text.trim();
    final a3 = q3Controller.text.trim();
    final a4 = q4Controller.text.trim();

    return '''이름과 현재의 나:
$a1

태어난 곳과 성장 배경:
$a2

학창 시절, 일, 가족 같은 주요 경험:
$a3

자서전에 꼭 남기고 싶은 이야기:
$a4''';
  }

  Future<void> submitIntro() async {
    final a1 = q1Controller.text.trim();
    final a2 = q2Controller.text.trim();
    final a3 = q3Controller.text.trim();
    final a4 = q4Controller.text.trim();

    if (a1.isEmpty && a2.isEmpty && a3.isEmpty && a4.isEmpty) {
      Get.snackbar(
        '알림',
        '간단한 자기소개를 하나 이상 입력해주세요.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.black87,
        colorText: Colors.white,
      );
      return;
    }

    errorMessage.value = '';
    isLoading.value = true;

    try {
      final combinedText = _combineAnswers();

      debugPrint('[OnboardingController] Saving intro...');
      final introResponse = await _onboardingApi.saveIntro(combinedText);

      if (introResponse.statusCode != 200 && introResponse.statusCode != 201) {
        throw Exception('Failed to save intro');
      }

      debugPrint('[OnboardingController] Generating case...');
      final caseResponse = await _onboardingApi.generateCase(combinedText);

      if (caseResponse.statusCode != 200 && caseResponse.statusCode != 201) {
        throw Exception('Failed to generate case');
      }

      Get.offNamed(Routes.chapterGenerating);
    } catch (e) {
      debugPrint('[OnboardingController] Error: $e');
      errorMessage.value = '자기소개 저장에 실패했습니다. 다시 시도해주세요.';
      Get.snackbar(
        '오류',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
