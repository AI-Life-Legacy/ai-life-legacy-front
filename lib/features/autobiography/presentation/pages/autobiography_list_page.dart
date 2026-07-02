import 'package:ai_life_legacy/app/core/routes/app_routes.dart';
import 'package:ai_life_legacy/app/core/theme/app_theme.dart';
import 'package:ai_life_legacy/app/core/theme/widgets/animated_mascot.dart';
import 'package:ai_life_legacy/app/core/theme/widgets/app_buttons.dart';
import 'package:ai_life_legacy/app/core/theme/widgets/app_indicators.dart';
import 'package:ai_life_legacy/app/core/utils/safe_navigation.dart';
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
        '아직 준비 중입니다',
        '남은 질문 ${controller.remainingQuestions.value}개를 채우면 제작할 수 있어요.',
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
        '결과물을 찾을 수 없습니다',
        '잠시 후 다시 시도해주세요.',
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

  void _onRecreateAutobiographyPressed(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('다시 제작할까요?'),
        content: const Text(
          '현재 답변을 기준으로 결과물을 다시 생성합니다. 기존 결과는 새 결과로 대체될 수 있습니다.',
        ),
        actions: [
          TextButton(
            onPressed: () => SafeNavigation.closeDialog(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              SafeNavigation.closeDialog(context);
              Get.toNamed(
                Routes.genConfirm,
                arguments: {'canGenerate': true, 'force': true},
              );
            },
            child: const Text('다시 만들기'),
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
        title: const Text('제작 스튜디오'),
        actions: [
          IconButton(
            tooltip: '새로고침',
            onPressed: () async {
              await controller.fetchToc();
              await controller.fetchTocQuestions();
              await controller.syncAutobiographyStatus();
            },
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.chapters.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.text),
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
                color: AppTheme.text,
                backgroundColor: AppTheme.surface,
                onRefresh: () async {
                  await controller.fetchToc();
                  await controller.fetchTocQuestions();
                  await controller.syncAutobiographyStatus();
                },
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  children: [
                    _StudioPanel(
                      isGenerated: isGenerated,
                      canGenerate: canGenerate,
                      answeredQuestions: controller.answeredQuestions.value,
                      totalQuestions: controller.totalQuestions.value,
                      remainingQuestions: controller.remainingQuestions.value,
                      progress: controller.totalProgress.value,
                      pageCount: autoController.pageCount.value,
                      hasPdf: (autoController.pdfUrl.value ?? '').isNotEmpty,
                      onView: () => _onViewAutobiographyPressed(autoController),
                    ),
                    const SizedBox(height: 22),
                    _ChapterRail(controller: controller),
                    const SizedBox(height: 22),
                    _QuestionBoard(controller: controller),
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
              onRecreate: () => _onRecreateAutobiographyPressed(context),
            ),
          ],
        );
      }),
    );
  }
}

class _StudioPanel extends StatelessWidget {
  final bool isGenerated;
  final bool canGenerate;
  final int answeredQuestions;
  final int totalQuestions;
  final int remainingQuestions;
  final double progress;
  final int? pageCount;
  final bool hasPdf;
  final VoidCallback onView;

  const _StudioPanel({
    required this.isGenerated,
    required this.canGenerate,
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
    final title = isGenerated
        ? '완성본이 준비됐어요'
        : canGenerate
            ? '이제 제작할 수 있어요'
            : '질문을 모으는 중이에요';
    final subtitle = isGenerated
        ? '바로 열어보거나 현재 답변으로 다시 제작할 수 있습니다.'
        : canGenerate
            ? '답변을 하나의 읽기 좋은 결과물로 묶어볼까요?'
            : '남은 질문 $remainingQuestions개를 채우면 제작 버튼이 열립니다.';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.text,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: AnimatedMascot(
                  size: 108,
                  mood: MascotMood.success,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.sun,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '$percent%',
                  style: const TextStyle(
                    color: AppTheme.text,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 27,
              height: 1.12,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.45,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 18),
          AppProgressBar(
            value: progress,
            height: 10,
            fill: AppTheme.cta,
            bg: Colors.white24,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _DarkMetric(label: '답변', value: '$answeredQuestions/$totalQuestions'),
              const SizedBox(width: 8),
              _DarkMetric(label: '남음', value: '$remainingQuestions'),
              if (isGenerated) ...[
                const Spacer(),
                TextButton.icon(
                  onPressed: onView,
                  icon: const Icon(Icons.open_in_new_rounded, color: Colors.white),
                  label: const Text(
                    '열기',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (isGenerated) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _Pill(
                  icon: Icons.picture_as_pdf_rounded,
                  text: hasPdf ? 'PDF 연결됨' : 'PDF 확인 필요',
                  color: hasPdf ? AppTheme.cta : AppTheme.warning,
                ),
                if (pageCount != null)
                  _Pill(
                    icon: Icons.layers_rounded,
                    text: '$pageCount쪽',
                    color: AppTheme.sky,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _DarkMetric extends StatelessWidget {
  final String label;
  final String value;

  const _DarkMetric({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChapterRail extends StatelessWidget {
  final AutobiographyListController controller;

  const _ChapterRail({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.errorMessage.value.isNotEmpty) {
        return _InfoPanel(
          icon: Icons.wifi_off_rounded,
          title: controller.errorMessage.value,
          subtitle: '아래로 당겨 다시 불러올 수 있습니다.',
        );
      }

      if (controller.chapters.isEmpty) {
        return const _InfoPanel(
          icon: Icons.add_rounded,
          title: '아직 목차가 없습니다',
          subtitle: '첫 자기소개를 작성하면 목차가 생성됩니다.',
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(
            title: '목차 레일',
            subtitle: '챕터를 누르면 아래 질문 보드가 바뀝니다.',
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 168,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(2, 12, 2, 6),
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                final chapter = controller.chapters[index];
                return _ChapterTile(
                  index: index,
                  chapter: chapter,
                  onTap: () {
                    final tocId = _toInt(
                      chapter['tocId'] ?? chapter['id'] ?? chapter['n'],
                    );
                    if (tocId != null) controller.toggleChapter(tocId);
                  },
                );
              },
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemCount: controller.chapters.length,
            ),
          ),
        ],
      );
    });
  }
}

class _ChapterTile extends GetView<AutobiographyListController> {
  final int index;
  final Map<String, dynamic> chapter;
  final VoidCallback onTap;

  const _ChapterTile({
    required this.index,
    required this.chapter,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tocId = _toInt(chapter['tocId'] ?? chapter['id'] ?? chapter['n']);
    final title = chapter['title'] ??
        chapter['tocTitle'] ??
        chapter['name'] ??
        '제목 없는 챕터';
    final done = (chapter['done'] as num?)?.toInt() ?? 0;
    final total = (chapter['total'] as num?)?.toInt() ?? 0;
    final progress = total > 0 ? done / total : 0.0;
    final color = _palette[index % _palette.length];

    return Obx(() {
      final selected = tocId != null && controller.expandedTocId.value == tocId;

      return AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0, selected ? -10 : 0, 0),
        child: Stack(
          children: [
            Material(
              color: selected ? AppTheme.text : color,
              elevation: selected ? 9 : 0,
              shadowColor: const Color(0x66000000),
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(8),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  width: selected ? 166 : 154,
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: selected ? Colors.white : AppTheme.text,
                      width: selected ? 2.6 : 1.2,
                    ),
                    boxShadow: selected
                        ? const [
                            BoxShadow(
                              color: Color(0x55000000),
                              blurRadius: 0,
                              offset: Offset(5, 6),
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              '${index + 1}'.padLeft(2, '0'),
                              style: TextStyle(
                                color: selected ? Colors.white : AppTheme.text,
                                fontSize: selected ? 24 : 22,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          if (selected)
                            const Icon(
                              Icons.touch_app_rounded,
                              color: AppTheme.sun,
                              size: 22,
                            ),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        title.toString(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: selected ? Colors.white : AppTheme.text,
                          fontSize: selected ? 15 : 14,
                          height: 1.25,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      AppProgressBar(
                        value: progress,
                        height: selected ? 8 : 7,
                        fill: selected ? AppTheme.cta : AppTheme.text,
                        bg: selected ? Colors.white24 : Colors.black12,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _QuestionBoard extends StatelessWidget {
  final AutobiographyListController controller;

  const _QuestionBoard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selectedTocId = controller.expandedTocId.value ??
          (controller.chapters.isEmpty
              ? null
              : _toInt(
                  controller.chapters.first['tocId'] ??
                      controller.chapters.first['id'] ??
                      controller.chapters.first['n'],
                ));

      if (selectedTocId == null) {
        return const SizedBox.shrink();
      }

      final loading = controller.loadingQuestionTocIds.contains(selectedTocId);
      final questions = controller.tocQuestions[selectedTocId] ?? [];

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(
            title: '질문 보드',
            subtitle: '각 질문은 독립된 블록입니다. 바로 눌러 작성하세요.',
          ),
          const SizedBox(height: 12),
          if (loading)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator(color: AppTheme.text)),
            )
          else if (questions.isEmpty)
            _InfoPanel(
              icon: Icons.touch_app_rounded,
              title: '질문을 불러오는 중이거나 아직 없습니다',
              subtitle: '목차를 다시 누르거나 새로고침을 시도해보세요.',
              onTap: () => controller.fetchQuestionsForToc(selectedTocId),
            )
          else
            ...questions.asMap().entries.map((entry) {
              return _QuestionTile(
                tocId: selectedTocId,
                index: entry.key,
                question: Map<String, dynamic>.from(entry.value),
              );
            }),
        ],
      );
    });
  }
}

class _QuestionTile extends GetView<AutobiographyListController> {
  final int tocId;
  final int index;
  final Map<String, dynamic> question;

  const _QuestionTile({
    required this.tocId,
    required this.index,
    required this.question,
  });

  @override
  Widget build(BuildContext context) {
    final text = question['questionText'] ??
        question['question'] ??
        question['text'] ??
        '질문 내용 없음';
    final done = question['isAnswered'] == true ||
        question['status'] == 'completed' ||
        question['done'] == true ||
        question['answerId'] != null;
    final color = _palette[index % _palette.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: done ? AppTheme.surfaceElevated : AppTheme.surface,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: () => controller.onQuestionTap(tocId, question),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.text, width: 1.1),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: done ? AppTheme.cta : color,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: AppTheme.text,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        done ? '작성 완료' : '작성 대기',
                        style: TextStyle(
                          color: done ? AppTheme.ctaDark : AppTheme.textPh,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        text.toString(),
                        style: const TextStyle(
                          color: AppTheme.text,
                          fontSize: 14,
                          height: 1.42,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Icon(
                  done ? Icons.check_circle_rounded : Icons.arrow_forward_rounded,
                  color: done ? AppTheme.ctaDark : AppTheme.text,
                ),
              ],
            ),
          ),
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
        color: AppTheme.sun,
        border: Border(top: BorderSide(color: AppTheme.text)),
      ),
      child: SafeArea(
        top: false,
        child: isGenerated
            ? Row(
                children: [
                  Expanded(
                    child: SecondaryButton(
                      text: '다시 제작',
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      onPressed: onRecreate,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: PrimaryButton(
                      text: '결과 보기',
                      icon: const Icon(
                        Icons.open_in_new_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                      onPressed: onView,
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    canGenerate
                        ? '모든 질문이 채워졌습니다. 바로 제작할 수 있어요.'
                        : '남은 질문 $remainingQuestions개를 채우면 제작할 수 있어요.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppTheme.text,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  PrimaryButton(
                    text: '결과물 제작',
                    icon: const Icon(
                      Icons.auto_awesome_rounded,
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

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppTheme.text,
            fontSize: 19,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            color: AppTheme.textSec,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
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
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color),
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
  final VoidCallback? onTap;

  const _InfoPanel({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.surfaceElevated,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.text, width: 1.1),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppTheme.text, size: 28),
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
        ),
      ),
    );
  }
}

int? _toInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

const _palette = [
  AppTheme.sky,
  AppTheme.coral,
  AppTheme.cta,
  AppTheme.lavender,
  AppTheme.sun,
];
