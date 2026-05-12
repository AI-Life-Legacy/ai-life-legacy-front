import 'package:get/get.dart';
import 'package:ai_life_legacy/features/onboarding/data/onboarding_api.dart';
import 'package:ai_life_legacy/app/core/routes/app_routes.dart';

class OnboardingController extends GetxController {
  final OnboardingApi _onboardingApi;

  OnboardingController(this._onboardingApi);

  final name = ''.obs;
  final currentStep = 1.obs;
  final totalSteps = 3.obs;

  final isLoading = false.obs;

  /// 채팅 메시지 목록 (role: 'ai' | 'user', text: String)
  final messages = <Map<String, String>>[].obs;

  @override
  void onInit() {
    super.onInit();
    // 초기 AI 질문 메시지 추가
    messages.add({
      'role': 'ai',
      'text': '당신의 삶에서 자서전에 꼭 담고 싶은 주제는 무엇인가요?',
    });
  }

  /// 자기소개 전송 → saveIntro → generateCase → generating 페이지로 이동
  Future<void> submitIntro(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    // 유저 메시지를 채팅에 추가
    messages.add({
      'role': 'user',
      'text': trimmed,
    });

    try {
      isLoading.value = true;

      // 1. 자기소개 저장 API 호출
      print('[OnboardingController] Saving intro...');
      final introResponse = await _onboardingApi.saveIntro(trimmed);
      print('[OnboardingController] saveIntro status: ${introResponse.statusCode}');

      // 2. 케이스 생성 API 호출
      print('[OnboardingController] Generating case...');
      final caseResponse = await _onboardingApi.generateCase(trimmed);
      print('[OnboardingController] generateCase status: ${caseResponse.statusCode}');

      // 3. 목차 생성 페이지로 이동
      Get.offNamed(Routes.chapterGenerating);
    } catch (e) {
      print('[OnboardingController] Error: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
