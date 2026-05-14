import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ai_life_legacy/app/core/theme/app_theme.dart';
import 'package:ai_life_legacy/features/onboarding/presentation/controllers/onboarding_controller.dart';

class SelfIntroPage extends GetView<OnboardingController> {
  const SelfIntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: const Text('알아가기',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Obx(() => Text(
                    '${controller.currentStep.value}/${controller.totalSteps.value}',
                    style: const TextStyle(fontSize: 13, color: AppTheme.textPh),
                  )),
            ),
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppTheme.border),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '자서전 작성을 위한\n기본 정보를 입력해주세요.',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '입력하신 내용은 자서전의 기초 자료로 활용됩니다.',
                      style: TextStyle(fontSize: 14, color: AppTheme.textPh),
                    ),
                    const SizedBox(height: 32),
                    _buildQuestionField(
                      '1. 이름과 나이',
                      '예: 저는 이근준이고, 25살입니다.',
                      controller.q1Controller,
                    ),
                    const SizedBox(height: 24),
                    _buildQuestionField(
                      '2. 태어난 곳과 성장 배경',
                      '예: 저는 대전에서 태어나 초등학교까지 그곳에서 살았습니다.',
                      controller.q2Controller,
                    ),
                    const SizedBox(height: 24),
                    _buildQuestionField(
                      '3. 학교, 직장, 결혼, 가족 등 주요 경험',
                      '예: 대학에서는 컴퓨터공학을 전공했고, 이후 개발자로 일했습니다. 결혼과 가족 이야기도 남기고 싶습니다.',
                      controller.q3Controller,
                    ),
                    const SizedBox(height: 24),
                    _buildQuestionField(
                      '4. 자서전에 꼭 남기고 싶은 이야기',
                      '예: 가족과 함께 보낸 시간, 힘들었지만 성장했던 경험을 남기고 싶습니다.',
                      controller.q4Controller,
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Obx(() => SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: controller.isLoading.value
                          ? null
                          : () => controller.submitIntro(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.cta,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: controller.isLoading.value
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              '저장하고 계속하기',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionField(
      String label, String placeholder, TextEditingController textController) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppTheme.text,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: textController,
          maxLines: 3,
          minLines: 1,
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: const TextStyle(fontSize: 14, color: AppTheme.textPh),
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.cta, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}


