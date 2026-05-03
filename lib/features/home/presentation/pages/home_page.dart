import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ai_life_legacy/app/core/routes/app_routes.dart';
import 'package:ai_life_legacy/app/core/theme/app_theme.dart';
import 'package:ai_life_legacy/features/home/presentation/controllers/home_controller.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // We can use controller.chapters, but for now we mix mock data
    final chapters = [
      {'n': 1, 'title': '유년기: 고향의 기억', 'done': true},
      {'n': 2, 'title': '청소년기: 학창 시절', 'done': true},
      {'n': 3, 'title': '첫 직장과 경험', 'done': true},
      {'n': 4, 'title': '가족의 형성', 'done': false},
      {'n': 5, 'title': '교직 생활의 보람', 'done': false},
      {'n': 6, 'title': '황혼의 지혜', 'done': false},
      {'n': 7, 'title': '남기고 싶은 이야기', 'done': false},
    ];
    final total = chapters.length;
    final totalDone = chapters.where((c) => c['done'] == true).length;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Get.toNamed(Routes.dashboard);
      },
      child: Scaffold(
        backgroundColor: AppTheme.bg,
        body: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Life Legacy',
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.text,
                      ),
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Get.toNamed('/search'),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppTheme.bg,
                              border: Border.all(color: AppTheme.border),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.search, size: 16, color: AppTheme.text),
                          ),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () => Get.toNamed('/mypage'),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppTheme.bg,
                              border: Border.all(color: AppTheme.border),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.settings, size: 18, color: AppTheme.text),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Content
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    // Profile Section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: AppTheme.bgAlt,
                        border: Border(bottom: BorderSide(color: AppTheme.border)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppTheme.border),
                            ),
                            child: const Center(
                              child: Text(
                                'MT',
                                style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 18, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Margaret Thompson',
                                style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.text),
                              ),
                              SizedBox(height: 2),
                              Text(
                                '72세 • 은퇴한 교육자',
                                style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: AppTheme.textSec),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Progress summary
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.bgAlt,
                        border: Border.all(color: AppTheme.border),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '7개 챕터 중 3개 완료',
                            style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 15, fontWeight: FontWeight.w500, color: AppTheme.text),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            '잘 하고 계세요. 계속 이어가봐요.',
                            style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, color: AppTheme.textSec),
                          ),
                          const SizedBox(height: 14),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(3),
                            child: LinearProgressIndicator(
                              value: totalDone / total,
                              minHeight: 6,
                              backgroundColor: AppTheme.border,
                              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.cta),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              '${((totalDone / total) * 100).toInt()}%',
                              style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, color: AppTheme.textPh),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Chapters
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('나의 챕터', style: AppTheme.sectionLabel),
                          const SizedBox(height: 12),
                          ...chapters.map((ch) {
                            final isDone = ch['done'] as bool;
                            final num = ch['n'];
                            return GestureDetector(
                              onTap: () => Get.toNamed('/chapter-chat', arguments: {'chapter': ch}),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                decoration: BoxDecoration(
                                  color: AppTheme.bg,
                                  border: Border.all(color: AppTheme.border),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 24,
                                          height: 24,
                                          decoration: BoxDecoration(
                                            color: isDone ? AppTheme.successBg : AppTheme.bgAlt,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: Text(
                                              isDone ? '✓' : '$num',
                                              style: TextStyle(
                                                fontFamily: AppTheme.fontFamily,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: isDone ? AppTheme.success : AppTheme.textPh,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          ch['title'] as String,
                                          style: TextStyle(
                                            fontFamily: AppTheme.fontFamily,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: isDone ? AppTheme.text : AppTheme.textSec,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      isDone ? '보기' : '진행중',
                                      style: TextStyle(
                                        fontFamily: AppTheme.fontFamily,
                                        fontSize: 11,
                                        color: isDone ? AppTheme.textPh : AppTheme.warning,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Footer CTA
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: AppTheme.border)),
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Get.toNamed('/gen_confirm'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.successBg,
                      foregroundColor: AppTheme.success,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: AppTheme.success),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      '아바타 생성하기',
                      style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 15, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
