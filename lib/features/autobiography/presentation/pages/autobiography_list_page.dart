import 'package:ai_life_legacy/app/core/routes/app_routes.dart';
import 'package:ai_life_legacy/app/core/theme/app_theme.dart';
import 'package:ai_life_legacy/app/core/theme/widgets/app_buttons.dart';
import 'package:ai_life_legacy/app/core/theme/widgets/app_indicators.dart';
import 'package:ai_life_legacy/features/autobiography/presentation/controllers/autobiography_controller.dart';
import 'package:ai_life_legacy/features/autobiography/presentation/controllers/autobiography_list_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AutobiographyListPage extends GetView<AutobiographyListController> {
  const AutobiographyListPage({super.key});

  void _onCreateAutobiographyPressed() {
    final canGenerate = controller.totalQuestions.value > 0 &&
        controller.answeredQuestions.value >= controller.totalQuestions.value;

    if (!canGenerate) {
      Get.snackbar(
        '아직 준비 중이에요',
        '남은 질문 ${controller.remainingQuestions.value}개를 채우면 자서전을 만들 수 있어요.',
        backgroundColor: AppTheme.error,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    Get.toNamed(Routes.genConfirm, arguments: {'canGenerate': canGenerate});
  }

  void _onViewAutobiographyPressed(AutobiographyController autoController) {
    final url = autoController.pdfUrl.value;
    final markdownUrl = autoController.markdownUrl.value;
    final count = autoController.pageCount.value ?? 0;

    if (url == null || url.isEmpty) {
      Get.snackbar(
        'PDF를 찾을 수 없어요',
        '잠시 후 다시 시도해 주세요.',
        backgroundColor: AppTheme.error,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    Get.toNamed(
      Routes.generated,
      arguments: {
        'pdfUrl': url,
        'markdownUrl': markdownUrl,
        'pageCount': count,
        'cached': true,
      },
    );
  }

  void _onRecreateAutobiographyPressed() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text(
          '자서전을 다시 만들까요?',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: AppTheme.text,
          ),
        ),
        content: const Text(
          '현재 답변을 기준으로 자서전을 다시 생성합니다. 기존 PDF는 새 결과로 대체될 수 있어요.',
          style: TextStyle(fontSize: 13, color: AppTheme.textSec, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: const Text('취소', style: TextStyle(color: AppTheme.textSec)),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              Get.toNamed(Routes.generating, arguments: {'force': true});
            },
            child: const Text(
              '다시 만들기',
              style: TextStyle(
                color: AppTheme.cta,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: const Text(
          '나의 자서전',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
        ),
        backgroundColor: AppTheme.bg,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: '새로고침',
            onPressed: () async {
              await controller.fetchToc();
              await controller.fetchTocQuestions();
              await controller.syncAutobiographyStatus();
            },
            icon: const Icon(Icons.refresh_rounded, color: AppTheme.textSec),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.chapters.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.cta),
          );
        }

        final autoController = Get.find<AutobiographyController>();
        final isGenerated = autoController.autobiographyGenerated.value;
        final canGenerate = controller.totalQuestions.value > 0 &&
            controller.answeredQuestions.value >=
                controller.totalQuestions.value;

        return Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                color: AppTheme.cta,
                backgroundColor: AppTheme.surface,
                onRefresh: () async {
                  await controller.fetchToc();
                  await controller.fetchTocQuestions();
                  await controller.syncAutobiographyStatus();
                },
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  children: [
                    _BookStatusPanel(
                      isGenerated: isGenerated,
                      canGenerate: canGenerate,
                      totalChapters: controller.totalChapters.value,
                      completedChapters: controller.completedChapters.value,
                      answeredQuestions: controller.answeredQuestions.value,
                      totalQuestions: controller.totalQuestions.value,
                      remainingQuestions: controller.remainingQuestions.value,
                      progress: controller.totalProgress.value,
                      pageCount: autoController.pageCount.value,
                      hasPdf: (autoController.pdfUrl.value ?? '').isNotEmpty,
                      onView: () => _onViewAutobiographyPressed(autoController),
                    ),
                    const SizedBox(height: 20),
                    const _SectionHeader(
                      title: '목차와 질문',
                      subtitle: '오늘 떠오르는 시기부터 자유롭게 채워도 괜찮아요.',
                    ),
                    const SizedBox(height: 12),
                    if (controller.errorMessage.value.isNotEmpty)
                      _InfoPanel(
                        icon: Icons.wifi_off_rounded,
                        title: controller.errorMessage.value,
                        subtitle: '아래로 당겨 다시 불러올 수 있어요.',
                      )
                    else if (controller.chapters.isEmpty)
                      const _InfoPanel(
                        icon: Icons.auto_stories_outlined,
                        title: '아직 목차가 없어요',
                        subtitle: '첫 질문을 시작하면 자서전 목차가 만들어집니다.',
                      )
                    else
                      ...controller.chapters.map((chapter) {
                        return _ChapterCard(chapter: chapter);
                      }),
                  ],
                ),
              ),
            ),
            _BottomComposer(
              isGenerated: isGenerated,
              canGenerate: canGenerate,
              remainingQuestions: controller.remainingQuestions.value,
              pageCount: autoController.pageCount.value,
              hasPdf: (autoController.pdfUrl.value ?? '').isNotEmpty,
              onCreate: _onCreateAutobiographyPressed,
              onView: () => _onViewAutobiographyPressed(autoController),
              onRecreate: _onRecreateAutobiographyPressed,
            ),
          ],
        );
      }),
    );
  }
}

class _BookStatusPanel extends StatelessWidget {
  final bool isGenerated;
  final bool canGenerate;
  final int totalChapters;
  final int completedChapters;
  final int answeredQuestions;
  final int totalQuestions;
  final int remainingQuestions;
  final double progress;
  final int? pageCount;
  final bool hasPdf;
  final VoidCallback onView;

  const _BookStatusPanel({
    required this.isGenerated,
    required this.canGenerate,
    required this.totalChapters,
    required this.completedChapters,
    required this.answeredQuestions,
    required this.totalQuestions,
    required this.remainingQuestions,
    required this.progress,
    required this.pageCount,
    required this.hasPdf,
    required this.onView,
  });

  @override
  Widget build(BuildContext context) {
    final percent = (progress * 100).clamp(0, 100).round();
    final headline = isGenerated
        ? '자서전이 준비됐어요'
        : canGenerate
            ? '책으로 묶을 준비가 됐어요'
            : '기억을 차곡차곡 모으는 중';
    final subtitle = isGenerated
        ? '새 답변을 더한 뒤 다시 만들 수도 있어요.'
        : canGenerate
            ? '지금까지의 답변으로 첫 자서전을 만들 수 있어요.'
            : '남은 질문 $remainingQuestions개를 원하는 순서로 채워보세요.';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isGenerated || canGenerate ? AppTheme.cta : AppTheme.border,
          width: 2,
        ),
        boxShadow: const [
          BoxShadow(
            color: AppTheme.shadow,
            blurRadius: 0,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: isGenerated ? AppTheme.successBg : AppTheme.bgAlt,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isGenerated ? AppTheme.cta : AppTheme.border,
                    width: 2,
                  ),
                ),
                child: Icon(
                  isGenerated
                      ? Icons.menu_book_rounded
                      : Icons.edit_note_rounded,
                  color: isGenerated ? AppTheme.cta : AppTheme.sky,
                  size: 30,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      headline,
                      style: const TextStyle(
                        color: AppTheme.text,
                        fontSize: 20,
                        height: 1.25,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppTheme.textSec,
                        fontSize: 13,
                        height: 1.45,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _MetricTile(
                  label: '챕터',
                  value: '$completedChapters/$totalChapters',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MetricTile(
                  label: '질문',
                  value: '$answeredQuestions/$totalQuestions',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MetricTile(
                  label: '진행률',
                  value: '$percent%',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AppProgressBar(
            value: progress,
            height: 10,
            fill: canGenerate || isGenerated ? AppTheme.cta : AppTheme.sky,
          ),
          if (isGenerated) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                _Pill(
                  icon: Icons.picture_as_pdf_rounded,
                  text: hasPdf ? 'PDF 사용 가능' : 'PDF 확인 필요',
                  color: hasPdf ? AppTheme.cta : AppTheme.warning,
                ),
                if (pageCount != null) ...[
                  const SizedBox(width: 8),
                  _Pill(
                    icon: Icons.layers_rounded,
                    text: '$pageCount쪽',
                    color: AppTheme.sky,
                  ),
                ],
                const Spacer(),
                TextButton.icon(
                  onPressed: onView,
                  icon: const Icon(Icons.open_in_new_rounded, size: 18),
                  label: const Text('보기'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;

  const _MetricTile({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: AppTheme.bgAlt,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textPh,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.text,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppTheme.text,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppTheme.textSec,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ChapterCard extends GetView<AutobiographyListController> {
  final Map<String, dynamic> chapter;

  const _ChapterCard({required this.chapter});

  @override
  Widget build(BuildContext context) {
    final tocId = _toInt(chapter['tocId'] ?? chapter['id'] ?? chapter['n']);
    final title =
        chapter['title'] ?? chapter['tocTitle'] ?? chapter['name'] ?? '제목 없음';
    final done = (chapter['done'] as num?)?.toInt() ?? 0;
    final total = (chapter['total'] as num?)?.toInt() ?? 0;
    final percent = (chapter['percent'] as num?)?.toInt() ?? 0;
    final status = chapter['status']?.toString().toLowerCase() ?? '';
    final isCompleted = status == 'completed' ||
        status == 'complete' ||
        (total > 0 && done >= total) ||
        percent >= 100;
    final isInProgress = done > 0 && !isCompleted;
    final progress = total > 0 ? done / total : percent / 100;
    final accent = isCompleted
        ? AppTheme.cta
        : isInProgress
            ? AppTheme.sky
            : AppTheme.lavender;

    return Obx(() {
      final isExpanded =
          tocId != null && controller.expandedTocId.value == tocId;
      final questions =
          tocId == null ? [] : controller.tocQuestions[tocId] ?? [];
      final isLoadingQuestions =
          tocId != null && controller.loadingQuestionTocIds.contains(tocId);

      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isExpanded ? accent : AppTheme.border,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            InkWell(
              onTap:
                  tocId == null ? null : () => controller.toggleChapter(tocId),
              borderRadius: BorderRadius.circular(14),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: accent, width: 2),
                          ),
                          child: Icon(
                            isCompleted
                                ? Icons.check_rounded
                                : isInProgress
                                    ? Icons.edit_rounded
                                    : Icons.auto_stories_outlined,
                            color: accent,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tocId == null ? 'Chapter' : 'Chapter $tocId',
                                style: TextStyle(
                                  color: accent,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                title.toString(),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppTheme.text,
                                  fontSize: 16,
                                  height: 1.25,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _ChapterStatusPill(
                          isCompleted: isCompleted,
                          isInProgress: isInProgress,
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          isExpanded
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          color: AppTheme.textPh,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: AppProgressBar(
                            value: progress,
                            height: 8,
                            fill: accent,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '$done / $total',
                          style: const TextStyle(
                            color: AppTheme.textSec,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (isExpanded)
              _QuestionList(
                tocId: tocId,
                done: done,
                questions: questions.cast<Map<String, dynamic>>(),
                isLoading: isLoadingQuestions,
              ),
          ],
        ),
      );
    });
  }

  int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}

class _QuestionList extends GetView<AutobiographyListController> {
  final int? tocId;
  final int done;
  final List<Map<String, dynamic>> questions;
  final bool isLoading;

  const _QuestionList({
    required this.tocId,
    required this.done,
    required this.questions,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.bgAlt,
        border: Border(top: BorderSide(color: AppTheme.border)),
      ),
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
      child: isLoading
          ? const Padding(
              padding: EdgeInsets.all(18),
              child: Center(
                child: CircularProgressIndicator(color: AppTheme.cta),
              ),
            )
          : questions.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(14),
                  child: Text(
                    '질문 목록이 아직 없어요.',
                    style: TextStyle(color: AppTheme.textSec),
                  ),
                )
              : Column(
                  children: questions.asMap().entries.map((entry) {
                    final index = entry.key + 1;
                    final question = entry.value;
                    final text = question['questionText'] ??
                        question['question'] ??
                        question['text'] ??
                        '질문 내용 없음';
                    final isDone = question['isAnswered'] == true ||
                        question['status'] == 'completed' ||
                        question['done'] == true ||
                        question['answerId'] != null ||
                        index <= done;

                    return _QuestionRow(
                      index: index,
                      text: text.toString(),
                      isDone: isDone,
                      onTap: tocId == null
                          ? null
                          : () => controller.onQuestionTap(tocId!, question),
                    );
                  }).toList(),
                ),
    );
  }
}

class _QuestionRow extends StatelessWidget {
  final int index;
  final String text;
  final bool isDone;
  final VoidCallback? onTap;

  const _QuestionRow({
    required this.index,
    required this.text,
    required this.isDone,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isDone ? AppTheme.successBg : AppTheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDone ? AppTheme.cta : AppTheme.border,
                ),
              ),
              child: Text(
                '$index',
                style: TextStyle(
                  color: isDone ? AppTheme.cta : AppTheme.textSec,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  color: AppTheme.text,
                  fontSize: 13,
                  height: 1.4,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              isDone ? Icons.check_circle_rounded : Icons.chevron_right_rounded,
              color: isDone ? AppTheme.cta : AppTheme.textPh,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _ChapterStatusPill extends StatelessWidget {
  final bool isCompleted;
  final bool isInProgress;

  const _ChapterStatusPill({
    required this.isCompleted,
    required this.isInProgress,
  });

  @override
  Widget build(BuildContext context) {
    final text = isCompleted
        ? '완료'
        : isInProgress
            ? '작성 중'
            : '선택 가능';
    final color = isCompleted
        ? AppTheme.cta
        : isInProgress
            ? AppTheme.sky
            : AppTheme.lavender;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _BottomComposer extends StatelessWidget {
  final bool isGenerated;
  final bool canGenerate;
  final int remainingQuestions;
  final int? pageCount;
  final bool hasPdf;
  final VoidCallback onCreate;
  final VoidCallback onView;
  final VoidCallback onRecreate;

  const _BottomComposer({
    required this.isGenerated,
    required this.canGenerate,
    required this.remainingQuestions,
    required this.pageCount,
    required this.hasPdf,
    required this.onCreate,
    required this.onView,
    required this.onRecreate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        border: Border(top: BorderSide(color: AppTheme.border)),
      ),
      child: SafeArea(
        top: false,
        child: isGenerated
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      _Pill(
                        icon: Icons.menu_book_rounded,
                        text: hasPdf ? '완성본 있음' : '완성 상태 확인 필요',
                        color: hasPdf ? AppTheme.cta : AppTheme.warning,
                      ),
                      if (pageCount != null) ...[
                        const SizedBox(width: 8),
                        _Pill(
                          icon: Icons.layers_rounded,
                          text: '$pageCount쪽',
                          color: AppTheme.sky,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: SecondaryButton(
                          text: '다시 만들기',
                          icon: const Icon(
                            Icons.refresh_rounded,
                            color: AppTheme.text,
                            size: 18,
                          ),
                          onPressed: onRecreate,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: PrimaryButton(
                          text: '자서전 보기',
                          icon: const Icon(
                            Icons.open_in_new_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                          onPressed: onView,
                        ),
                      ),
                    ],
                  ),
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    canGenerate
                        ? '답변이 모두 모였어요. 이제 책으로 엮을 수 있습니다.'
                        : '남은 질문 $remainingQuestions개를 채우면 자서전을 만들 수 있어요.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: canGenerate ? AppTheme.ctaDark : AppTheme.warning,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  PrimaryButton(
                    text: '자서전 만들기',
                    icon: const Icon(
                      Icons.auto_stories_outlined,
                      color: Colors.white,
                      size: 18,
                    ),
                    onPressed: onCreate,
                    disabled: !canGenerate,
                  ),
                ],
              ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _Pill({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoPanel extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _InfoPanel({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border, width: 2),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.sky, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppTheme.text,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppTheme.textSec,
                    fontSize: 12,
                    height: 1.4,
                    fontWeight: FontWeight.w700,
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
