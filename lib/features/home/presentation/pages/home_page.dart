import 'package:ai_life_legacy/app/core/routes/app_routes.dart';
import 'package:ai_life_legacy/app/core/theme/app_theme.dart';
import 'package:ai_life_legacy/app/core/theme/widgets/animated_mascot.dart';
import 'package:ai_life_legacy/app/core/theme/widgets/app_indicators.dart';
import 'package:ai_life_legacy/app/core/theme/widgets/mascot_flow_widgets.dart';
import 'package:ai_life_legacy/features/home/presentation/controllers/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MascotScaffold(
      padding: EdgeInsets.zero,
      bottom: _BottomBar(controller: controller),
      child: RefreshIndicator(
        color: AppTheme.cta,
        backgroundColor: AppTheme.surface,
        onRefresh: controller.fetchToc,
        child: Obx(() {
          if (controller.isLoading.value && controller.chapters.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.cta),
            );
          }

          final suggestedChapter = _suggestedChapter(controller.chapters);
          final suggestedTitle = _chapterTitle(suggestedChapter);

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
            children: [
              _TopBar(onSettings: () => Get.toNamed(Routes.myPage)),
              const SizedBox(height: 20),
              _HeroSummary(
                name: controller.displayName,
                progress: controller.totalProgress.value,
                completed: controller.completedChapters.value,
                total: controller.totalChapters.value,
              ),
              const SizedBox(height: 16),
              _QuickActionGrid(
                remainingQuestions: controller.remainingQuestions.value,
                onWrite: suggestedChapter == null
                    ? () => Get.toNamed(
                          Routes.genConfirm,
                          arguments: {'canGenerate': true},
                        )
                    : () => controller.onChapterTap(suggestedChapter),
                onBook: () => Get.toNamed(Routes.autobiography),
                onSearch: () => Get.toNamed(Routes.search),
                onAvatar: () {
                  if (controller.isViewerMode) {
                    Get.toNamed(Routes.viewerChat);
                  } else if (controller.isAvatarUnlocked) {
                    Get.toNamed(Routes.avatarChat);
                  } else {
                    Get.toNamed(Routes.locked);
                  }
                },
              ),
              const SizedBox(height: 24),
              _SectionTitle(
                title: '오늘 이어갈 기록',
                actionText: '전체 보기',
                onAction: () => Get.toNamed(Routes.autobiography),
              ),
              const SizedBox(height: 10),
              _FocusCard(
                title: suggestedTitle,
                remainingQuestions: controller.remainingQuestions.value,
                onTap: suggestedChapter == null
                    ? () => Get.toNamed(
                          Routes.genConfirm,
                          arguments: {'canGenerate': true},
                        )
                    : () => controller.onChapterTap(suggestedChapter),
              ),
              const SizedBox(height: 24),
              const _SectionTitle(title: '챕터 보드'),
              const SizedBox(height: 10),
              if (controller.errorMessage.value.isNotEmpty)
                _InfoPanel(
                  icon: Icons.wifi_off_rounded,
                  title: controller.errorMessage.value,
                  subtitle: '아래로 당겨 다시 불러오세요.',
                )
              else if (controller.chapters.isEmpty)
                _InfoPanel(
                  icon: Icons.add_rounded,
                  title: '아직 목차가 없습니다',
                  subtitle: '자기소개를 작성하면 첫 목차가 생성됩니다.',
                  onTap: () => Get.toNamed(Routes.selfIntro),
                )
              else
                ...controller.chapters.asMap().entries.map(
                      (entry) => _ChapterCard(
                        index: entry.key,
                        chapter: entry.value,
                        onTap: () => controller.onChapterTap(entry.value),
                      ),
                    ),
            ],
          );
        }),
      ),
    );
  }

  Map<String, dynamic>? _suggestedChapter(List<Map<String, dynamic>> chapters) {
    if (chapters.isEmpty) return null;

    for (final chapter in chapters) {
      if (_isStarted(chapter) && !_isComplete(chapter)) return chapter;
    }
    for (final chapter in chapters) {
      if (!_isComplete(chapter)) return chapter;
    }
    return chapters.first;
  }

  String _chapterTitle(Map<String, dynamic>? chapter) {
    if (chapter == null) return '새 목차 생성을 준비하세요';
    return chapter['title']?.toString() ??
        chapter['tocTitle']?.toString() ??
        chapter['name']?.toString() ??
        '제목 없는 챕터';
  }

  bool _isStarted(Map<String, dynamic> chapter) {
    final done = (chapter['done'] as num?)?.toInt() ?? 0;
    return done > 0;
  }

  bool _isComplete(Map<String, dynamic> chapter) {
    final percent = (chapter['percent'] as num?)?.toInt() ?? 0;
    final done = (chapter['done'] as num?)?.toInt() ?? 0;
    final total = (chapter['total'] as num?)?.toInt() ?? 0;
    final status = chapter['status']?.toString().toLowerCase() ?? '';
    return status == 'complete' ||
        status == 'completed' ||
        percent >= 100 ||
        (total > 0 && done >= total);
  }
}

class _TopBar extends StatelessWidget {
  final VoidCallback onSettings;

  const _TopBar({required this.onSettings});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          'Life Legacy',
          style: TextStyle(
            color: AppTheme.text,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        const Spacer(),
        IconButton(
          tooltip: '설정',
          onPressed: onSettings,
          icon: const Icon(Icons.tune_rounded),
        ),
      ],
    );
  }
}

class _HeroSummary extends StatelessWidget {
  final String name;
  final double progress;
  final int completed;
  final int total;

  const _HeroSummary({
    required this.name,
    required this.progress,
    required this.completed,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final percent = (progress * 100).clamp(0, 100).round();

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
            children: [
              const AnimatedMascot(size: 96, mood: MascotMood.idle),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '$name님의 기록이\n$percent% 정리됐어요',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    height: 1.12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(width: 42, height: 12, color: AppTheme.sun),
              const SizedBox(width: 8),
              Container(width: 20, height: 20, color: AppTheme.sky),
            ],
          ),
          const SizedBox(height: 16),
          AppProgressBar(
            value: progress,
            height: 9,
            fill: AppTheme.cta,
            bg: Colors.white24,
          ),
          const SizedBox(height: 10),
          Text(
            '$completed/$total 챕터 완료',
            style: const TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionGrid extends StatelessWidget {
  final int remainingQuestions;
  final VoidCallback onWrite;
  final VoidCallback onBook;
  final VoidCallback onSearch;
  final VoidCallback onAvatar;

  const _QuickActionGrid({
    required this.remainingQuestions,
    required this.onWrite,
    required this.onBook,
    required this.onSearch,
    required this.onAvatar,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.28,
      children: [
        _ActionTile(
          color: AppTheme.sun,
          icon: Icons.edit_rounded,
          title: '질문 답하기',
          meta: remainingQuestions > 0 ? '$remainingQuestions개 남음' : '완료',
          onTap: onWrite,
        ),
        _ActionTile(
          color: AppTheme.sky,
          icon: Icons.view_agenda_outlined,
          title: '목차 보기',
          meta: '전체 구조',
          onTap: onBook,
        ),
        _ActionTile(
          color: AppTheme.lavender,
          icon: Icons.search_rounded,
          title: '검색',
          meta: '기억 찾기',
          onTap: onSearch,
        ),
        _ActionTile(
          color: AppTheme.cta,
          icon: Icons.graphic_eq_rounded,
          title: '대화 모드',
          meta: '완성 후 이용',
          onTap: onAvatar,
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String title;
  final String meta;
  final VoidCallback onTap;

  const _ActionTile({
    required this.color,
    required this.icon,
    required this.title,
    required this.meta,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: AppTheme.text),
              const Spacer(),
              Text(
                title,
                style: const TextStyle(
                  color: AppTheme.text,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                meta,
                style: const TextStyle(
                  color: AppTheme.textSec,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FocusCard extends StatelessWidget {
  final String title;
  final int remainingQuestions;
  final VoidCallback onTap;

  const _FocusCard({
    required this.title,
    required this.remainingQuestions,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.text),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '추천 진입점',
            style: TextStyle(
              color: AppTheme.ctaDark,
              fontWeight: FontWeight.w900,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 9),
          Text(
            title,
            style: const TextStyle(
              color: AppTheme.text,
              fontSize: 21,
              height: 1.22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            remainingQuestions > 0
                ? '남은 질문을 채우면 책 생성에 가까워집니다.'
                : '모든 질문이 채워졌습니다. 결과물을 확인해보세요.',
            style: const TextStyle(
              color: AppTheme.textSec,
              fontSize: 13,
              height: 1.4,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          FlowPrimaryButton(
            text: remainingQuestions > 0 ? '이어서 답하기' : '결과 만들기',
            onPressed: onTap,
          ),
        ],
      ),
    );
  }
}

class _ChapterCard extends StatelessWidget {
  final int index;
  final Map<String, dynamic> chapter;
  final VoidCallback onTap;

  const _ChapterCard({
    required this.index,
    required this.chapter,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final done = (chapter['done'] as num?)?.toInt() ?? 0;
    final total = (chapter['total'] as num?)?.toInt() ?? 0;
    final percent = (chapter['percent'] as num?)?.toInt() ?? 0;
    final progress = total > 0 ? done / total : percent / 100;
    final title = chapter['title']?.toString() ??
        chapter['tocTitle']?.toString() ??
        chapter['name']?.toString() ??
        '제목 없는 챕터';
    final complete = (total > 0 && done >= total) || percent >= 100;
    final color = complete
        ? AppTheme.cta
        : done > 0
            ? AppTheme.sky
            : AppTheme.sun;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: AppTheme.text,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppTheme.text,
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      AppProgressBar(value: progress, height: 6, fill: color),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '$done/$total',
                  style: const TextStyle(
                    color: AppTheme.textSec,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String? actionText;
  final VoidCallback? onAction;

  const _SectionTitle({
    required this.title,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppTheme.text,
            fontSize: 19,
            fontWeight: FontWeight.w900,
          ),
        ),
        const Spacer(),
        if (actionText != null)
          TextButton(onPressed: onAction, child: Text(actionText!)),
      ],
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
    return FlowOptionCard(
      icon: icon,
      title: title,
      subtitle: subtitle,
      selected: true,
      onTap: onTap ?? () {},
    );
  }
}

class _BottomBar extends StatelessWidget {
  final HomeController controller;

  const _BottomBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 14),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        border: Border(top: BorderSide(color: AppTheme.border)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            const _NavButton(icon: Icons.home_rounded, label: '홈', active: true),
            _NavButton(
              icon: Icons.search_rounded,
              label: '검색',
              onTap: () => Get.toNamed(Routes.search),
            ),
            _NavButton(
              icon: Icons.view_agenda_outlined,
              label: '목차',
              onTap: () => Get.toNamed(Routes.autobiography),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback? onTap;

  const _NavButton({
    required this.icon,
    required this.label,
    this.active = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: active ? AppTheme.text : AppTheme.textPh),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: active ? AppTheme.text : AppTheme.textPh,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
