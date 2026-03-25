import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ai_life_legacy/features/onboarding/presentation/controllers/self_intro_controller.dart';
import 'package:ai_life_legacy/app/core/routes/app_routes.dart';
import 'package:ai_life_legacy/features/common/presentation/widgets/unified_chat_input_widget.dart';

class SelfIntroPage extends GetView<SelfIntroController> {
  const SelfIntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        elevation: 0,
        title: const Text(
          '자기소개',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.black),
            onPressed: () => Get.toNamed(Routes.myPage),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // 메인 컨텐츠 영역
          Expanded(
            child: Obx(() {
              return ListView(
                controller: controller.scrollController,
                padding: const EdgeInsets.all(20),
                children: [
                  const SizedBox(height: 20),
                  // 질문 카드
                  Obx(() => Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          controller.currentQuestionText,
                          style: const TextStyle(
                            fontSize: 18,
                            height: 1.5,
                            color: Colors.black87,
                          ),
                        ),
                      )),
                  const SizedBox(height: 24),
                  // 다시 들려줘 버튼 (그대로)
                  OutlinedButton(
                    onPressed: controller.replayCurrentQuestion,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF5B9FED),
                      side:
                          const BorderSide(color: Color(0xFF5B9FED), width: 2),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24)),
                    ),
                    child: const Text('다시 들려줘',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 24),

                  // 채팅 메시지(말풍선) 리스트 렌더링
                  ...controller.messages
                      .map((m) => _Bubble(text: m.text, isUser: m.isUser)),

                  // 수동 꼬리질문 버튼 영역
                  Obx(() => controller.canThinkDeeper.value
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: controller.generateFollowUpQuestion,
                                  icon: const Icon(Icons.psychology_outlined),
                                  label: const Text('네, 더 깊게 생각할게요'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF5B9FED),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: controller.skipFollowUp,
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.black54,
                                    side: const BorderSide(color: Colors.black12),
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  child: const Text('아니오, 다음 질문 주세요'),
                                ),
                              ),
                            ],
                          ),
                        )
                      : const SizedBox.shrink()),

                  const SizedBox(height: 80), // 하단 입력 영역과 겹치지 않게 여유
                ],
              );
            }),
          ),

          // Unified Input Widget
          UnifiedChatInputWidget(
            textController: controller.textController,
            onSubmitted: controller.submitAnswer,
            onToggleVoice: controller.toggleVoiceRecorderVisible,
            onToggleRecording: controller.toggleRecording,
            isVoiceRecorderVisible: controller.isVoiceRecorderVisible,
            isRecording: controller.isRecording,
            isLoading: controller.loading,
            formattedTime: controller.getFormattedTime(),
          ),
        ],
      ),
    );
  }
}

// 말풍선 위젯
class _Bubble extends StatelessWidget {
  final String text;
  final bool isUser;
  const _Bubble({required this.text, required this.isUser});

  @override
  Widget build(BuildContext context) {
    final bg = isUser ? const Color(0xFF5B9FED) : const Color(0xFFEDEDED);
    final fg = isUser ? Colors.white : Colors.black87;
    final align = isUser ? Alignment.centerRight : Alignment.centerLeft;
    final margin = isUser
        ? const EdgeInsets.only(left: 60, bottom: 10)
        : const EdgeInsets.only(right: 60, bottom: 10);

    return Align(
      alignment: align,
      child: Container(
        margin: margin,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
        ),
        child:
            Text(text, style: TextStyle(color: fg, fontSize: 16, height: 1.4)),
      ),
    );
  }
}
