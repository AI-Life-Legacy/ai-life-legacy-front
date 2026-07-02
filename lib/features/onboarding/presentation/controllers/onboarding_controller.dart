import 'dart:async';

import 'package:ai_life_legacy/app/core/routes/app_routes.dart';
import 'package:ai_life_legacy/features/onboarding/data/onboarding_api.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class OnboardingController extends GetxController {
  final OnboardingApi _onboardingApi;

  OnboardingController(this._onboardingApi);

  final currentStep = 1.obs;
  final totalSteps = 7.obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final isSpeechAvailable = false.obs;
  final isSpeechStarting = false.obs;
  final isListening = false.obs;
  final speechStatusMessage = '마이크로 말하면 답변칸에 바로 적어드릴게요.'.obs;

  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final q1Controller = TextEditingController();
  final q2Controller = TextEditingController();
  final q3Controller = TextEditingController();
  final q4Controller = TextEditingController();
  final selectedGender = ''.obs;
  final selectedLifeStage = '학생'.obs;
  final selectedPurposeIds = <String>[].obs;
  final selectedStyleId = 'detailed'.obs;
  final SpeechToText _speechToText = SpeechToText();

  String _speechBaseText = '';

  bool get isFirstStep => currentStep.value == 1;
  bool get isLastStep => currentStep.value == totalSteps.value;
  bool get isProfileStep => currentStep.value == 1;
  bool get isPurposeStep => currentStep.value == 2;
  bool get isStyleStep => currentStep.value == 3;
  bool get isWritingStep => currentStep.value >= 4;
  double get progress => currentStep.value / totalSteps.value;

  List<OnboardingChoice> get lifeStageOptions => const [
        OnboardingChoice(
          id: 'student',
          label: '학생',
          subtitle: '학교생활, 진로 고민, 성장 과정을 더 자연스럽게 다뤄요.',
          icon: Icons.school_outlined,
        ),
        OnboardingChoice(
          id: 'worker',
          label: '직장인',
          subtitle: '일, 선택, 관계, 성취와 전환점을 중심으로 묶어요.',
          icon: Icons.work_outline,
        ),
        OnboardingChoice(
          id: 'retired',
          label: '은퇴/시니어',
          subtitle: '가족사, 시대 배경, 후손에게 남길 말을 더 살려요.',
          icon: Icons.volunteer_activism_outlined,
        ),
        OnboardingChoice(
          id: 'other',
          label: '기타',
          subtitle: '현재 상황을 특정하지 않고 폭넓은 질문으로 시작해요.',
          icon: Icons.person_outline,
        ),
      ];

  List<OnboardingChoice> get genderOptions => const [
        OnboardingChoice(
          id: 'male',
          label: '남성',
          subtitle: '아바타 호칭을 형, 누나처럼 자연스럽게 맞춰요.',
          icon: Icons.male_rounded,
        ),
        OnboardingChoice(
          id: 'female',
          label: '여성',
          subtitle: '아바타 호칭을 오빠, 언니처럼 자연스럽게 맞춰요.',
          icon: Icons.female_rounded,
        ),
        OnboardingChoice(
          id: 'unspecified',
          label: '선택 안 함',
          subtitle: '성별 호칭이 들어간 아바타 톤은 숨겨둘게요.',
          icon: Icons.person_outline_rounded,
        ),
      ];

  List<OnboardingChoice> get purposeOptions => const [
        OnboardingChoice(
          id: 'self_reflection',
          label: '나를 돌아보기',
          subtitle: '내 삶을 정리하고 스스로 이해하는 방향',
          icon: Icons.psychology_alt_outlined,
        ),
        OnboardingChoice(
          id: 'family',
          label: '가족에게 남기기',
          subtitle: '가족, 추억, 고마움, 전하고 싶은 말을 강조',
          icon: Icons.family_restroom,
        ),
        OnboardingChoice(
          id: 'descendants',
          label: '자녀/후손에게 전하기',
          subtitle: '삶의 교훈과 시대 이야기를 남기는 방향',
          icon: Icons.diversity_1_outlined,
        ),
        OnboardingChoice(
          id: 'career',
          label: '진로/포트폴리오',
          subtitle: '경험, 성장, 강점, 앞으로의 목표를 중심으로 구성',
          icon: Icons.badge_outlined,
        ),
        OnboardingChoice(
          id: 'special_event',
          label: '특별한 사건 기록',
          subtitle: '중요한 사건과 그 전후 변화를 깊게 다뤄요.',
          icon: Icons.bookmark_border,
        ),
        OnboardingChoice(
          id: 'simple_record',
          label: '간단한 기록',
          subtitle: '부담 없이 짧고 읽기 쉬운 자서전을 만들어요.',
          icon: Icons.notes_outlined,
        ),
      ];

  List<OnboardingChoice> get styleOptions => const [
        OnboardingChoice(
          id: 'simple',
          label: '짧고 간단하게',
          subtitle: '핵심 사건과 감정을 부담 없이 읽히게 정리해요.',
          icon: Icons.short_text_rounded,
        ),
        OnboardingChoice(
          id: 'detailed',
          label: '자세하고 풍부하게',
          subtitle: '장면, 배경, 감정을 충분히 풀어 책다운 분량으로 만들어요.',
          icon: Icons.menu_book_outlined,
        ),
        OnboardingChoice(
          id: 'warm',
          label: '따뜻하고 감성적으로',
          subtitle: '가족, 추억, 고마움을 부드러운 문체로 살려요.',
          icon: Icons.favorite_border,
        ),
        OnboardingChoice(
          id: 'calm',
          label: '담담하고 객관적으로',
          subtitle: '과장 없이 사건과 선택을 차분하게 기록해요.',
          icon: Icons.fact_check_outlined,
        ),
        OnboardingChoice(
          id: 'literary',
          label: '책처럼 문학적으로',
          subtitle: '제목, 장면 전환, 문장 리듬을 더 신경 써서 구성해요.',
          icon: Icons.auto_stories_outlined,
        ),
      ];

  String get currentTitle {
    switch (currentStep.value) {
      case 1:
        return '자서전 기본 정보를 알려주세요';
      case 2:
        return '어떤 자서전으로 만들까요?';
      case 3:
        return '결과물은 어떤 느낌이면 좋을까요?';
      case 4:
        return '당신을 어떻게 부르면 좋을까요?';
      case 5:
        return '어디에서 어떤 시간을 보내며 자라왔나요?';
      case 6:
        return '삶에서 오래 남아 있는 장면이 있나요?';
      case 7:
        return '꼭 남기고 싶은 이야기가 있다면요?';
      default:
        return '';
    }
  }

  String get currentDescription {
    switch (currentStep.value) {
      case 1:
        return '이름, 나이, 성별, 현재 상태를 받아서 목차와 아바타 호칭을 더 자연스럽게 맞출게요.';
      case 2:
        return '직접 쓰지 않아도 괜찮아요. 원하는 목적을 버튼으로 골라주세요. 여러 개 선택할 수 있어요.';
      case 3:
        return '완성된 PDF의 분량과 문체를 정하는 기준이에요. 하나만 선택해주세요.';
      case 4:
        return '이름, 성격, 지금의 나를 짧게 적어주세요.';
      case 5:
        return '태어난 곳, 살았던 동네, 학교나 일터처럼 나를 만든 배경을 들려주세요.';
      case 6:
        return '학창 시절, 가족, 일, 사랑, 도전처럼 기억에 남는 경험이면 충분해요.';
      case 7:
        return '아직 정리되지 않은 마음이어도 괜찮아요. 떠오르는 만큼만 남겨주세요.';
      default:
        return '';
    }
  }

  String get currentPlaceholder {
    switch (currentStep.value) {
      case 4:
        return '예: 저는 김하늘이고, 25살입니다. 조용하지만 좋아하는 일에는 오래 몰입하는 편이에요.';
      case 5:
        return '예: 부산에서 태어나 바닷가 근처에서 자랐고, 어린 시절 대부분을 할머니 집에서 보냈어요.';
      case 6:
        return '예: 대학 때 처음 혼자 서울에 올라왔던 순간이 아직도 선명해요.';
      case 7:
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
        return Icons.tune_outlined;
      case 3:
        return Icons.palette_outlined;
      case 4:
        return Icons.face_outlined;
      case 5:
        return Icons.place_outlined;
      case 6:
        return Icons.timeline;
      case 7:
        return Icons.favorite_border;
      default:
        return Icons.auto_stories_outlined;
    }
  }

  TextEditingController get currentTextController {
    switch (currentStep.value) {
      case 4:
        return q1Controller;
      case 5:
        return q2Controller;
      case 6:
        return q3Controller;
      case 7:
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

    if (!_validateCurrentStep()) {
      return;
    }

    if (!isLastStep) {
      currentStep.value++;
      return;
    }

    await submitIntro();
  }

  @override
  void onClose() {
    _speechToText.cancel();
    nameController.dispose();
    ageController.dispose();
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
    if (isLoading.value || !isWritingStep) return;

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
    final name = nameController.text.trim();
    final age = ageController.text.trim();
    final gender = selectedGender.value;
    final purposes = selectedPurposeLabels.join(', ');
    final style = selectedStyleLabel;
    final tocPlan = personalizedTocPlan
        .asMap()
        .entries
        .map((entry) => '${entry.key + 1}. ${entry.value}')
        .join('\n');
    final a1 = q1Controller.text.trim();
    final a2 = q2Controller.text.trim();
    final a3 = q3Controller.text.trim();
    final a4 = q4Controller.text.trim();

    return '''기본 정보:
이름: $name
나이: $age
성별: $gender
현재 상태: ${selectedLifeStage.value}
자서전 제작 목적: $purposes
원하는 결과물 스타일: $style

추천 목차 설계:
$tocPlan

이름과 현재의 나:
$a1

태어난 곳과 성장 배경:
$a2

학창 시절, 일, 가족 같은 주요 경험:
$a3

자서전에 꼭 남기고 싶은 이야기:
$a4''';
  }

  Future<void> submitIntro() async {
    final name = nameController.text.trim();
    final age = ageController.text.trim();
    final a1 = q1Controller.text.trim();
    final a2 = q2Controller.text.trim();
    final a3 = q3Controller.text.trim();
    final a4 = q4Controller.text.trim();

    if (name.isEmpty ||
        age.isEmpty ||
        selectedGender.value.isEmpty ||
        selectedPurposeIds.isEmpty ||
        selectedStyleId.value.isEmpty) {
      Get.snackbar(
        '알림',
        '이름, 나이, 성별, 제작 목적을 먼저 선택해주세요.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.black87,
        colorText: Colors.white,
      );
      return;
    }

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
      await _saveProfileSelections();

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

  List<String> get selectedPurposeLabels {
    return purposeOptions
        .where((option) => selectedPurposeIds.contains(option.id))
        .map((option) => option.label)
        .toList();
  }

  String get selectedStyleLabel {
    return styleOptions
        .firstWhere(
          (option) => option.id == selectedStyleId.value,
          orElse: () => styleOptions[1],
        )
        .label;
  }

  List<String> get personalizedTocPlan {
    final age = int.tryParse(ageController.text.trim());
    final isSenior =
        selectedLifeStage.value == '은퇴/시니어' || (age != null && age >= 60);
    final isYoung = selectedLifeStage.value == '학생' || (age != null && age < 30);
    final isCareer = selectedPurposeIds.contains('career');
    final isFamily = selectedPurposeIds.contains('family') ||
        selectedPurposeIds.contains('descendants');
    final isEvent = selectedPurposeIds.contains('special_event');
    final isSimple = selectedStyleId.value == 'simple';

    final chapters = <String>[];

    if (isYoung) {
      chapters.addAll(['나를 소개하는 첫 장', '어린 시절과 성장 배경', '학교생활과 관계']);
      chapters.add(isCareer ? '진로 고민과 나의 강점' : '나를 바꾼 경험들');
      chapters.add('앞으로 만들고 싶은 삶');
    } else if (isSenior) {
      chapters.addAll(['내 삶의 시작과 시대 배경', '가족과 함께한 시간', '일과 생업의 기록']);
      chapters.add(isFamily ? '후손에게 남기고 싶은 말' : '인생의 전환점');
      chapters.add('돌아보며 배운 것');
    } else {
      chapters.addAll(['지금의 나를 만든 배경', '일과 삶의 균형', '가족과 관계']);
      chapters.add(isCareer ? '성취와 실패에서 배운 것' : '중요한 선택과 전환점');
      chapters.add('앞으로의 방향');
    }

    if (isEvent) {
      chapters.insert(chapters.length > 2 ? 3 : chapters.length, '특별한 사건과 그 이후의 변화');
    }

    if (selectedStyleId.value == 'warm' && !chapters.contains('고마운 사람들과 마음의 기록')) {
      chapters.add('고마운 사람들과 마음의 기록');
    }

    if (selectedStyleId.value == 'literary') {
      chapters.add('내 이야기에 붙이고 싶은 제목과 장면');
    }

    final unique = <String>[];
    for (final chapter in chapters) {
      if (!unique.contains(chapter)) {
        unique.add(chapter);
      }
    }

    return isSimple ? unique.take(4).toList() : unique.take(7).toList();
  }

  String get primaryButtonText {
    if (isLoading.value) {
      return '기억을 정리하는 중...';
    }
    if (isLastStep) {
      return '저장하고 계속하기';
    }
    if (isProfileStep || isPurposeStep || isStyleStep) {
      return '다음 단계';
    }
    return '다음 질문';
  }

  String get headerMessage {
    if (isProfileStep) {
      return '먼저 기본 정보를 터치로 고르면 목차와 아바타 톤을 더 알맞게 준비할 수 있어요.';
    }
    if (isPurposeStep) {
      return '자서전 목적은 직접 쓰지 말고 버튼으로 골라주세요.';
    }
    if (isStyleStep) {
      return '원하는 스타일을 고르면 분량, 문체, 목차 방향을 맞출 수 있어요.';
    }
    return '한 번에 하나씩만 답해볼게요. 편하게 떠오르는 만큼만 적어주세요.';
  }

  void selectLifeStage(String label) {
    selectedLifeStage.value = label;
  }

  void selectGender(String label) {
    selectedGender.value = label;
  }

  void setAge(int age) {
    final safeAge = age.clamp(1, 120);
    ageController.text = safeAge.toString();
    ageController.selection = TextSelection.collapsed(
      offset: ageController.text.length,
    );
  }

  void adjustAge(int delta) {
    final current = int.tryParse(ageController.text.trim()) ?? 30;
    setAge(current + delta);
  }

  Future<void> _saveProfileSelections() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('author_gender', selectedGender.value);
      await prefs.setString('author_age', ageController.text.trim());
      await prefs.setString('author_name', nameController.text.trim());
      await prefs.setString('author_life_stage', selectedLifeStage.value);
    } catch (_) {
      // Profile hints are only used for local personalization.
    }
  }

  void togglePurpose(String id) {
    if (selectedPurposeIds.contains(id)) {
      selectedPurposeIds.remove(id);
    } else {
      selectedPurposeIds.add(id);
    }
  }

  void selectStyle(String id) {
    selectedStyleId.value = id;
  }

  bool _validateCurrentStep() {
    if (isProfileStep) {
      final name = nameController.text.trim();
      final age = ageController.text.trim();
      if (name.isEmpty || age.isEmpty || selectedGender.value.isEmpty) {
        Get.snackbar(
          '알림',
          '이름, 나이, 성별을 선택해주세요.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.black87,
          colorText: Colors.white,
        );
        return false;
      }
    }

    if (isPurposeStep && selectedPurposeIds.isEmpty) {
      Get.snackbar(
        '알림',
        '자서전 제작 목적을 하나 이상 선택해주세요.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.black87,
        colorText: Colors.white,
      );
      return false;
    }

    if (isStyleStep && selectedStyleId.value.isEmpty) {
      Get.snackbar(
        '알림',
        '결과물 스타일을 선택해주세요.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.black87,
        colorText: Colors.white,
      );
      return false;
    }

    return true;
  }
}

class OnboardingChoice {
  final String id;
  final String label;
  final String subtitle;
  final IconData icon;

  const OnboardingChoice({
    required this.id,
    required this.label,
    required this.subtitle,
    required this.icon,
  });
}
