import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ai_life_legacy/features/onboarding/data/onboarding_api.dart';
import 'package:ai_life_legacy/app/core/routes/app_routes.dart';

class OnboardingController extends GetxController {
  final OnboardingApi _onboardingApi;

  OnboardingController(this._onboardingApi);

  final currentStep = 1.obs;
  final totalSteps = 3.obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  // 4개의 질문에 대한 컨트롤러
  final q1Controller = TextEditingController(); // 이름과 나이
  final q2Controller = TextEditingController(); // 태어난 곳과 성장 배경
  final q3Controller = TextEditingController(); // 주요 경험
  final q4Controller = TextEditingController(); // 자서전에 남기고 싶은 이야기

  @override
  void onClose() {
    q1Controller.dispose();
    q2Controller.dispose();
    q3Controller.dispose();
    q4Controller.dispose();
    super.onClose();
  }

  /// 4개 답변을 하나로 합침
  String _combineAnswers() {
    final a1 = q1Controller.text.trim();
    final a2 = q2Controller.text.trim();
    final a3 = q3Controller.text.trim();
    final a4 = q4Controller.text.trim();

    return '''이름과 나이:
$a1

태어난 곳과 성장 배경:
$a2

학교/직장/결혼/가족 등 주요 경험:
$a3

자서전에 남기고 싶은 이야기:
$a4''';
  }

  /// 자기소개 저장 및 다음 단계 진행
  Future<void> submitIntro() async {
    final a1 = q1Controller.text.trim();
    final a2 = q2Controller.text.trim();
    final a3 = q3Controller.text.trim();
    final a4 = q4Controller.text.trim();

    // 검증: 최소 1개 이상 입력
    if (a1.isEmpty && a2.isEmpty && a3.isEmpty && a4.isEmpty) {
      Get.snackbar('알림', '간단한 자기소개를 입력해주세요.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.black87,
          colorText: Colors.white);
      return;
    }

    errorMessage.value = '';
    isLoading.value = true;

    try {
      final combinedText = _combineAnswers();

      // 1. 자기소개 저장 API 호출
      debugPrint('[OnboardingController] Saving intro...');
      final introResponse = await _onboardingApi.saveIntro(combinedText);
      
      if (introResponse.statusCode != 200 && introResponse.statusCode != 201) {
        throw Exception('Failed to save intro');
      }

      // 2. 케이스 생성 API 호출
      debugPrint('[OnboardingController] Generating case...');
      final caseResponse = await _onboardingApi.generateCase(combinedText);
      
      if (caseResponse.statusCode != 200 && caseResponse.statusCode != 201) {
        throw Exception('Failed to generate case');
      }

      // 3. 목차 생성 페이지로 이동
      Get.offNamed(Routes.chapterGenerating);
    } catch (e) {
      debugPrint('[OnboardingController] Error: $e');
      errorMessage.value = '자기소개 저장에 실패했습니다. 다시 시도해주세요.';
      Get.snackbar('오류', errorMessage.value,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }
}

