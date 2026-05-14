import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ai_life_legacy/app/core/theme/app_theme.dart';
import 'package:ai_life_legacy/features/home/presentation/controllers/home_controller.dart';
import 'package:ai_life_legacy/app/core/routes/app_routes.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: Column(
          children: [
            // Greeting
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '안녕하세요, ${controller.displayName}${controller.displayName == '사용자' || controller.displayName == '작성자' ? '님' : ' 님'}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.text),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Get.toNamed(Routes.search),
                        icon: const Icon(Icons.search, color: AppTheme.textSec),
                      ),
                      IconButton(
                        onPressed: () => Get.toNamed(Routes.myPage),
                        icon: const Icon(Icons.settings_outlined, color: AppTheme.textSec),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Expanded(
              child: Obx(() {
                if (controller.isLoading.value && controller.chapters.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                return RefreshIndicator(
                  onRefresh: controller.fetchToc,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      // Premium Progress card
                      Container(
                        margin: const EdgeInsets.only(bottom: 24),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${controller.totalChapters.value}개 챕터 중 ${controller.completedChapters.value}개 완료',
                              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppTheme.text),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              '잘 하고 계세요. 계속 이어가봐요.',
                              style: TextStyle(fontSize: 13, color: AppTheme.textSec),
                            ),
                            const SizedBox(height: 20),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: controller.totalProgress.value,
                                minHeight: 8,
                                backgroundColor: const Color(0xFFF0F0F0),
                                valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.cta),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                '${controller.progressPercent.value}%',
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.cta),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Padding(
                        padding: EdgeInsets.only(left: 4, bottom: 12),
                        child: Text(
                          '나의 챕터',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPh),
                        ),
                      ),

                      ...controller.chapters.map((ch) => _ChapterCard(ch: ch)),
                      const SizedBox(height: 20),
                    ],
                  ),
                );
              }),
            ),

            // Bottom Nav
            _BottomNav(),
          ],
        ),
      ),
    );
  }
}

class _ChapterCard extends StatelessWidget {
  final Map<String, dynamic> ch;

  const _ChapterCard({required this.ch});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    final status = ch['status']?.toString().toLowerCase() ?? 'not-started';
    final done = (ch['done'] as num?)?.toInt() ?? 0;
    final total = (ch['total'] as num?)?.toInt() ?? 0;
    final percent = (ch['percent'] as num?)?.toInt() ?? 0;

    final bool isCompleted = status == 'completed' ||
        status == 'complete' ||
        (total > 0 && done >= total) ||
        percent >= 100;

    final bool isInProgress = done > 0 && !isCompleted;

    final Color progressColor = isCompleted
        ? Colors.green
        : isInProgress
            ? Colors.black87
            : Colors.grey.shade300;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFEEEEEE),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () => controller.onChapterTap(ch),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Ch.${ch['tocId'] ?? ch['id']}',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.textSec),
                    ),
                  ),
                  _StatusBadge(status: status),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                ch['title'] ?? '제목 없음',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.text),
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (ch['percent'] ?? 0) / 100.0,
                  minHeight: 4,
                  backgroundColor: const Color(0xFFF5F5F5),
                  valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${ch['done'] ?? 0} / ${ch['total'] ?? 0} 질문 답변 완료',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.textPh),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    String text;
    Color bgColor;
    Color textColor;

    if (status == 'complete' || status == 'completed') {
      text = '완료 ✓';
      bgColor = const Color(0xFFE8F5E9);
      textColor = const Color(0xFF2E7D32);
    } else if (status == 'in-progress') {
      text = '진행 중';
      bgColor = const Color(0xFFFFF8E1);
      textColor = const Color(0xFFF57F17);
    } else {
      text = '시작 전';
      bgColor = const Color(0xFFF5F5F5);
      textColor = AppTheme.textPh;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: textColor),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppTheme.border)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(Icons.home, '홈', true, () {}),
          Obx(() {
            final isViewer = controller.isViewerMode;
            final isUnlocked = controller.isAvatarUnlocked;
            
            // 뷰어 모드면 항상 잠금 해제 상태로 보임
            final showLocked = !isViewer && !isUnlocked;
            
            return _navItem(
              showLocked ? Icons.lock_outline : Icons.person_outline, 
              '아바타', 
              false, 
              () {
                if (isViewer) {
                  Get.toNamed(Routes.viewerChat);
                } else if (isUnlocked) {
                  Get.toNamed(Routes.avatarChat);
                } else {
                  Get.toNamed(Routes.locked);
                }
              }
            );
          }),
          _navItem(Icons.book_outlined, '자서전', false, () => Get.toNamed(Routes.autobiography)),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isActive ? AppTheme.text : AppTheme.textSec),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
              color: isActive ? AppTheme.text : AppTheme.textSec,
            ),
          ),
        ],
      ),
    );
  }
}
