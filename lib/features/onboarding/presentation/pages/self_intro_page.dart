import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ai_life_legacy/app/core/theme/app_theme.dart';
import 'package:ai_life_legacy/app/core/theme/widgets/chat_widgets.dart';
import 'package:ai_life_legacy/app/core/theme/widgets/app_chat_input.dart';
import 'package:ai_life_legacy/features/onboarding/presentation/controllers/onboarding_controller.dart';

class SelfIntroPage extends GetView<OnboardingController> {
  const SelfIntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: const Text('알아가기', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
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
            // 동적 채팅 메시지 목록
            Expanded(
              child: Obx(() => ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: controller.messages.length,
                    itemBuilder: (context, index) {
                      final msg = controller.messages[index];
                      final role = msg['role'] ?? 'ai';
                      final text = msg['text'] ?? '';

                      if (role == 'ai') {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: AIBubble(text: text),
                        );
                      } else {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: UserBubble(text: text),
                        );
                      }
                    },
                  )),
            ),
            // 로딩 인디케이터
            Obx(() => controller.isLoading.value
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 8),
                        Text(
                          '저장 중...',
                          style: TextStyle(fontSize: 13, color: AppTheme.textPh),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink()),
            // 입력 필드
            AppChatInput(
              placeholder: '답변을 입력하거나 말씀해보세요...',
              onSend: (v) => controller.submitIntro(v),
              onMicTap: () {}, // Recording logic would go here
            ),
          ],
        ),
      ),
    );
  }
}
