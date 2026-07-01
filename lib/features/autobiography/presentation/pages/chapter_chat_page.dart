import 'package:ai_life_legacy/app/core/routes/app_routes.dart';
import 'package:ai_life_legacy/app/core/theme/app_theme.dart';
import 'package:ai_life_legacy/app/core/theme/widgets/mascot_flow_widgets.dart';
import 'package:ai_life_legacy/features/autobiography/presentation/controllers/autobiography_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChapterChatPage extends StatefulWidget {
  const ChapterChatPage({super.key});

  @override
  State<ChapterChatPage> createState() => _ChapterChatPageState();
}

class _ChapterChatPageState extends State<ChapterChatPage> {
  final _answerController = TextEditingController();
  final AutobiographyController controller =
      Get.find<AutobiographyController>();

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    if (args is Map) {
      final tocId = _toInt(args['tocId'] ?? args['id']);
      if (tocId != null && controller.currentTocId.value != tocId) {
        controller.fetchQuestions(tocId);
      }
    }
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

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
      return const _MissingChapterPage(message: '챕터 정보를 불러오지 못했습니다.');
    }

    final ch = Map<String, dynamic>.from(args);
    final tocId = _toInt(ch['tocId'] ?? ch['id']);
    if (tocId == null) {
      return const _MissingChapterPage(message: '챕터 ID가 없습니다.');
    }

    final title = ch['title']?.toString() ?? '기억 레슨';
    final chapterNumber =
        _toInt(ch['chapterNumber'] ?? ch['tocId'] ?? ch['id']) ?? 0;

    return MascotScaffold(
      padding: EdgeInsets.zero,
      bottom: _AnswerComposer(
        textController: _answerController,
        controller: controller,
      ),
      child: Obx(() {
        final questionCount = controller.questions.length;
        final current =
            questionCount == 0 ? 0 : controller.currentQuestionIndex.value + 1;
        final progress = questionCount == 0 ? 0.0 : current / questionCount;
        final question = controller.currentQuestionText;

        return Column(
          children: [
            _LessonTopBar(
              title: 'Ch.$chapterNumber $title',
              progress: progress,
              onBack: () {
                if (controller.isSavingAnswer.value) return;
                if (Get.key.currentState?.canPop() == true) {
                  Get.back();
                } else {
                  Get.offAllNamed(Routes.home);
                }
              },
            ),
            Expanded(
              child: ListView(
                controller: controller.scrollController,
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
                children: [
                  if (controller.isLoading.value &&
                      controller.questions.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 80),
                      child: Center(
                        child: CircularProgressIndicator(color: AppTheme.cta),
                      ),
                    )
                  else if (question.isEmpty)
                    const _EmptyLesson()
                  else ...[
                    MascotHeader(
                      message: question,
                      mascotSize: 72,
                    ),
                    const SizedBox(height: 24),
                    _QuestionProgress(
                      current: current,
                      total: questionCount,
                    ),
                    const SizedBox(height: 18),
                    ...controller.messages.map(_LessonMessage.new),
                  ],
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _LessonTopBar extends StatelessWidget {
  final String title;
  final double progress;
  final VoidCallback onBack;

  const _LessonTopBar({
    required this.title,
    required this.progress,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 18, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.close, color: MascotFlowTheme.textMuted),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(
                value: progress.clamp(0, 1),
                minHeight: 12,
                backgroundColor: MascotFlowTheme.surface,
                valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.cta),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: MascotFlowTheme.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestionProgress extends StatelessWidget {
  final int current;
  final int total;

  const _QuestionProgress({
    required this.current,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: MascotFlowTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: MascotFlowTheme.border, width: 2),
      ),
      child: Row(
        children: [
          const Icon(Icons.bolt, color: AppTheme.cta),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '$current / $total 질문',
              style: const TextStyle(
                color: MascotFlowTheme.text,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const Text(
            '짧게 써도 좋아요',
            style: TextStyle(
              color: MascotFlowTheme.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _LessonMessage extends StatelessWidget {
  final Map<String, dynamic> message;

  const _LessonMessage(this.message);

  @override
  Widget build(BuildContext context) {
    final role = message['role']?.toString();
    final type = message['type']?.toString();
    final text = message['text']?.toString() ?? '';

    if (type == 'fixedQuestion') return const SizedBox.shrink();
    if (type == 'followUpChoice') {
      return _FollowUpChoice(
        text: text,
        controller: Get.find<AutobiographyController>(),
      );
    }

    final isUser = role == 'user';
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 310),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        decoration: BoxDecoration(
          color: isUser ? AppTheme.cta : MascotFlowTheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isUser ? AppTheme.ctaDark : MascotFlowTheme.border,
            width: 2,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isUser ? Colors.white : MascotFlowTheme.text,
            fontSize: 14,
            height: 1.45,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _FollowUpChoice extends StatelessWidget {
  final String text;
  final AutobiographyController controller;

  const _FollowUpChoice({
    required this.text,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: MascotFlowTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: MascotFlowTheme.border, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text,
            style: const TextStyle(
              color: MascotFlowTheme.text,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FlowPrimaryButton(
                  text: '더 물어보기',
                  loading: controller.isGeneratingFollowUp.value,
                  onPressed: controller.generateFollowUpQuestion,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: controller.skipFollowUpAndMoveNext,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: MascotFlowTheme.text,
                    side: const BorderSide(
                        color: MascotFlowTheme.border, width: 2),
                    minimumSize: const Size.fromHeight(56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    '다음 질문',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AnswerComposer extends StatelessWidget {
  final TextEditingController textController;
  final AutobiographyController controller;

  const _AnswerComposer({
    required this.textController,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final canType =
          controller.chatStep.value == ChatStep.answeringFixedQuestion ||
              controller.chatStep.value == ChatStep.answeringFollowUp;
      final isBusy =
          controller.chatStep.value == ChatStep.waitingFollowUpChoice ||
              controller.chatStep.value == ChatStep.generatingFollowUp ||
              controller.isSavingAnswer.value ||
              controller.isLoading.value;

      return Container(
        padding: EdgeInsets.fromLTRB(
          16,
          12,
          16,
          12 + MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: const BoxDecoration(
          color: MascotFlowTheme.surface,
          border: Border(top: BorderSide(color: MascotFlowTheme.border)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: textController,
                enabled: canType && !isBusy,
                minLines: 1,
                maxLines: 4,
                style: const TextStyle(
                  color: MascotFlowTheme.text,
                  fontSize: 15,
                  height: 1.45,
                ),
                decoration: InputDecoration(
                  hintText: canType ? '기억을 적어보세요...' : '선택을 기다리고 있어요',
                  hintStyle: const TextStyle(color: MascotFlowTheme.textMuted),
                  filled: true,
                  fillColor: MascotFlowTheme.bg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: MascotFlowTheme.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: MascotFlowTheme.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: MascotFlowTheme.active),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 52,
              height: 52,
              child: ElevatedButton(
                onPressed: canType && !isBusy
                    ? () {
                        final text = textController.text;
                        textController.clear();
                        controller.sendMessage(text);
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.cta,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: MascotFlowTheme.border,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: controller.isSavingAnswer.value
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.arrow_upward_rounded),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _EmptyLesson extends StatelessWidget {
  const _EmptyLesson();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 80),
      child: Center(
        child: Text(
          '진행할 질문이 없습니다.',
          style: TextStyle(color: MascotFlowTheme.textMuted),
        ),
      ),
    );
  }
}

class _MissingChapterPage extends StatelessWidget {
  final String message;

  const _MissingChapterPage({required this.message});

  @override
  Widget build(BuildContext context) {
    return MascotScaffold(
      child: Center(
        child: MascotHeader(message: message),
      ),
    );
  }
}
