import 'package:ai_life_legacy/app/core/routes/app_routes.dart';
import 'package:ai_life_legacy/app/core/theme/app_theme.dart';
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
        backgroundColor: MascotFlowTheme.surface,
        onRefresh: controller.fetchToc,
        child: Obx(() {
          if (controller.isLoading.value && controller.chapters.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.cta),
            );
          }

          final suggestedChapter = _suggestedChapter(controller.chapters);
          final title =
              suggestedChapter?['title']?.toString() ?? '오늘 떠오르는 목차를 골라보세요';

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
            children: [
              MascotHeader(
                message: '${controller.displayName}님, 오늘은 어떤 기억이 떠오르나요?',
                trailing: IconButton(
                  onPressed: () => Get.toNamed(Routes.myPage),
                  icon: const Icon(
                    Icons.settings_outlined,
                    color: MascotFlowTheme.textMuted,
                  ),
                ),
              ),
              const SizedBox(height: 26),
              FlowProgressPill(
                value: controller.totalProgress.value,
                label:
                    '${controller.completedChapters.value}/${controller.totalChapters.value} 챕터 완료',
              ),
              const SizedBox(height: 18),
              _TodayQuestionCard(
                title: title,
                remainingQuestions: controller.remainingQuestions.value,
                onTap: suggestedChapter == null
                    ? () => Get.toNamed(Routes.generating)
                    : () => controller.onChapterTap(suggestedChapter),
              ),
              const SizedBox(height: 28),
              const Text(
                '기억 목차',
                style: TextStyle(
                  color: MascotFlowTheme.text,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 14),
              if (controller.errorMessage.value.isNotEmpty)
                _InfoPanel(
                  icon: Icons.wifi_off,
                  title: controller.errorMessage.value,
                  subtitle: '잠시 후 아래로 당겨 다시 불러와 주세요.',
                )
              else if (controller.chapters.isEmpty)
                _InfoPanel(
                  icon: Icons.auto_stories_outlined,
                  title: '아직 열린 챕터가 없어요',
                  subtitle: '첫 질문을 시작하면 기억 목차가 만들어집니다.',
                  onTap: () => Get.toNamed(Routes.selfIntro),
                )
              else
                ...controller.chapters.asMap().entries.map(
                      (entry) => _ChapterNode(
                        index: entry.key,
                        chapter: entry.value,
                        onTap: () => controller.onChapterTap(entry.value),
                      ),
                    ),
              const SizedBox(height: 18),
              FlowOptionCard(
                icon: controller.isAvatarUnlocked
                    ? Icons.face_5_outlined
                    : Icons.lock_outline,
                title: controller.isAvatarUnlocked ? '아바타와 대화하기' : '아바타 잠금',
                subtitle: controller.isAvatarUnlocked
                    ? '완성된 이야기로 만든 아바타를 만나보세요.'
                    : '모든 기억을 채우면 열립니다.',
                onTap: () {
                  if (controller.isViewerMode) {
                    Get.toNamed(Routes.viewerChat);
                  } else if (controller.isAvatarUnlocked) {
                    Get.toNamed(Routes.avatarChat);
                  } else {
                    Get.toNamed(Routes.locked);
                  }
                },
              ),
            ],
          );
        }),
      ),
    );
  }

  Map<String, dynamic>? _suggestedChapter(
    List<Map<String, dynamic>> chapters,
  ) {
    if (chapters.isEmpty) return null;

    for (final chapter in chapters) {
      if (_isStarted(chapter) && !_isComplete(chapter)) return chapter;
    }

    for (final chapter in chapters) {
      if (!_isComplete(chapter)) return chapter;
    }

    return chapters.first;
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

class _TodayQuestionCard extends StatelessWidget {
  final String title;
  final int remainingQuestions;
  final VoidCallback onTap;

  const _TodayQuestionCard({
    required this.title,
    required this.remainingQuestions,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: MascotFlowTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: MascotFlowTheme.active, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '오늘의 추천 목차',
            style: TextStyle(
              color: MascotFlowTheme.active,
              fontWeight: FontWeight.w900,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              color: MascotFlowTheme.text,
              fontSize: 22,
              height: 1.25,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            remainingQuestions > 0
                ? '남은 질문 $remainingQuestions개가 있어요. 다른 목차를 먼저 골라도 괜찮아요.'
                : '모든 질문을 채웠어요. 책으로 묶어볼까요?',
            style: const TextStyle(
              color: MascotFlowTheme.textMuted,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 18),
          FlowPrimaryButton(
            text: remainingQuestions > 0 ? '추천 목차 답하기' : '책 만들기',
            onPressed: onTap,
          ),
        ],
      ),
    );
  }
}

class _ChapterNode extends StatelessWidget {
  final int index;
  final Map<String, dynamic> chapter;
  final VoidCallback onTap;

  const _ChapterNode({
    required this.index,
    required this.chapter,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final done = (chapter['done'] as num?)?.toInt() ?? 0;
    final total = (chapter['total'] as num?)?.toInt() ?? 0;
    final percent = (chapter['percent'] as num?)?.toInt() ?? 0;
    final status = chapter['status']?.toString().toLowerCase() ?? '';
    final complete = status == 'complete' ||
        status == 'completed' ||
        percent >= 100 ||
        (total > 0 && done >= total);
    final started = done > 0 && !complete;
    final color = complete
        ? AppTheme.cta
        : started
            ? MascotFlowTheme.active
            : AppTheme.sky;
    final icon = complete
        ? Icons.check_rounded
        : started
            ? Icons.edit_rounded
            : Icons.auto_stories_outlined;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Column(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(color: color, width: 3),
                ),
                child: Icon(icon, color: Colors.white),
              ),
              Container(
                width: 3,
                height: 18,
                color: index == 0 ? Colors.transparent : MascotFlowTheme.border,
              ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: FlowOptionCard(
              icon: Icons.auto_stories_outlined,
              title: chapter['title']?.toString() ?? '제목 없음',
              subtitle: '$done / $total 질문 완료',
              selected: started || complete,
              onTap: onTap,
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
        color: MascotFlowTheme.surface,
        border: Border(top: BorderSide(color: MascotFlowTheme.border)),
      ),
      child: Row(
        children: [
          _NavButton(icon: Icons.home_rounded, label: '홈', active: true),
          _NavButton(
            icon: Icons.search,
            label: '찾기',
            onTap: () => Get.toNamed(Routes.search),
          ),
          _NavButton(
            icon: Icons.auto_stories_outlined,
            label: '책',
            onTap: () => Get.toNamed(Routes.autobiography),
          ),
        ],
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
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: active ? AppTheme.cta : MascotFlowTheme.textMuted,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: active ? AppTheme.cta : MascotFlowTheme.textMuted,
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
