import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ai_life_legacy/app/core/theme/app_theme.dart';
import 'package:ai_life_legacy/app/core/theme/widgets/chat_widgets.dart';
import 'package:ai_life_legacy/app/core/theme/widgets/app_chat_input.dart';
import 'package:ai_life_legacy/app/core/routes/app_routes.dart';
import 'package:ai_life_legacy/features/autobiography/presentation/controllers/autobiography_controller.dart';

class ChapterChatPage extends GetView<AutobiographyController> {
  const ChapterChatPage({super.key});

  int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is double) return value.toInt();
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments;

    if (args == null || args is! Map) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('챕터'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Get.back(),
          ),
        ),
        body: const Center(child: Text('챕터 정보를 불러오지 못했습니다.')),
      );
    }

    final ch = Map<String, dynamic>.from(args);
    final int? tocId = _toInt(ch['tocId'] ?? ch['id']);
    final String title = ch['title']?.toString() ?? '제목 없음';
    final int chapterNumber = _toInt(ch['chapterNumber'] ?? ch['tocId'] ?? ch['id']) ?? 0;

    if (tocId == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('챕터'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Get.back(),
          ),
        ),
        body: const Center(child: Text('챕터 ID가 없습니다. 다시 시도해주세요.')),
      );
    }

    // Initial data load if needed
    if (controller.currentTocId.value != tocId) {
      controller.fetchQuestions(tocId);
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (controller.isSavingAnswer.value) return;

            if (Get.key.currentState?.canPop() == true) {
              Get.back();
            } else {
              Get.offAllNamed(Routes.home);
            }
          },
        ),
        title: Text('Ch.$chapterNumber — $title',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
        centerTitle: true,
        actions: [
          Obx(() => Center(
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Text(
                    '${controller.currentQuestionIndex.value + 1} / ${controller.questions.length}',
                    style: const TextStyle(fontSize: 13, color: AppTheme.textPh),
                  ),
                ),
              )),
        ],
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppTheme.border),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
          Obx(() {
            if (controller.isLoading.value && controller.questions.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(20),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            final question = controller.currentQuestionText;
            if (question.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(20),
                child: Text('진행할 질문이 없습니다.', style: TextStyle(color: AppTheme.textPh)),
              );
            }

            return AIQuestionCard(text: question);
          }),
          Expanded(
            child: Obx(() => ListView.builder(
                  controller: controller.scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: controller.messages.length,
                  itemBuilder: (context, index) {
                    final msg = controller.messages[index];
                    final role = msg['role'];
                    final text = msg['text'] ?? '';
                    final time = msg['time'];
                    final type = msg['type'];

                    if (type == 'followUpChoice') {
                      return FollowUpChoiceCard(
                        text: text,
                        onGenerate: controller.generateFollowUpQuestion,
                        onSkip: controller.skipFollowUpAndMoveNext,
                        isLoading: controller.isGeneratingFollowUp.value,
                      );
                    }

                    if (role == 'ai') {
                      return AIBubble(text: text, time: time);
                    } else if (role == 'user') {
                      return UserBubble(text: text, time: time);
                    } else {
                      // System or other types
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            text,
                            style: const TextStyle(fontSize: 12, color: AppTheme.textPh),
                          ),
                        ),
                      );
                    }
                  },
                )),
          ),
          Obx(() {
            final canType = controller.chatStep.value == ChatStep.answeringFixedQuestion ||
                controller.chatStep.value == ChatStep.answeringFollowUp;
            final isBusy = controller.chatStep.value == ChatStep.waitingFollowUpChoice ||
                          controller.chatStep.value == ChatStep.generatingFollowUp ||
                          controller.isSavingAnswer.value ||
                          controller.isLoading.value;

            return AppChatInput(
              placeholder: '답변을 입력하거나 말씀해보세요...',
              enabled: canType && !isBusy,
              onSend: (v) => controller.sendMessage(v),
            );
          }),
        ],
      )),
    );
  }
}

class FollowUpChoiceCard extends StatelessWidget {
  final String text;
  final VoidCallback onGenerate;
  final VoidCallback onSkip;
  final bool isLoading;

  const FollowUpChoiceCard({
    super.key,
    required this.text,
    required this.onGenerate,
    required this.onSkip,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AIBubble(text: text),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(left: 48), // AI 아이콘 공간만큼 띄움
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: isLoading ? null : onGenerate,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.cta,
                      side: const BorderSide(color: AppTheme.cta),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.cta),
                          )
                        : const Text('추가 질문하기', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isLoading ? null : onSkip,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.cta,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('다음 질문으로', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
