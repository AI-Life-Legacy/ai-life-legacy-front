import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ai_life_legacy/features/home/presentation/controllers/home_controller.dart';
import 'package:ai_life_legacy/app/core/routes/app_routes.dart';
import 'package:ai_life_legacy/app/core/theme/app_theme.dart';

class HomeTabView extends GetView<HomeController> {
  const HomeTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.bg,
        scrolledUnderElevation: 0, // 스크롤 시 색상 변경 방지
        elevation: 0,
        title: const Text(
          '나의 자서전',
          style: TextStyle(
            color: AppTheme.text,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: AppTheme.textSec),
            onPressed: () => Get.toNamed(Routes.myPage),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Obx(() {
          if (controller.isLoading.value && controller.chapters.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.chapters.isEmpty) {
            return _buildEmptyState();
          }

          if (controller.errorMessage.value.isNotEmpty) {
            Get.rawSnackbar(
              message: controller.errorMessage.value,
              backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
              snackPosition: SnackPosition.BOTTOM,
            );
          }

          return ListView.builder(
            itemCount: controller.chapters.length,
            itemBuilder: (context, index) {
              final chapter = controller.chapters[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: _buildChapterCard(chapter),
              );
            },
          );
        }),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.successBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.cta, width: 2),
            ),
            child:
                const Icon(Icons.edit_note, size: 42, color: AppTheme.ctaDark),
          ),
          const SizedBox(height: 16),
          const Text(
            '아직 자기소개가 작성되지 않아\n목차가 보이지 않습니다.',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: AppTheme.text,
                fontSize: 16,
                height: 1.5,
                fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => Get.find<HomeController>().changeTab(1), // 자기소개 탭으로 이동
            child: const Text(
              '이어서 작성하러 가시겠습니까?',
              style: TextStyle(
                color: AppTheme.ctaDark,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChapterCard(dynamic chapter) {
    final tocId = chapter['tocId'] ?? chapter['id'] ?? chapter['n'] ?? 0;
    final chapterNumber = chapter['n'] ?? chapter['chapterNumber'] ?? tocId;
    final title =
        chapter['title'] ?? chapter['tocTitle'] ?? chapter['name'] ?? '제목 없음';
    final subtitle = chapter['subtitle'] ?? chapter['description'] ?? '';

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.border, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadow,
            blurRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => controller.onChapterTap(chapter),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Chapter $chapterNumber',
                  style: const TextStyle(
                    color: AppTheme.skyDark,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(
                    color: AppTheme.text,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: AppTheme.textSec,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                _buildProgressBar(chapter),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar(dynamic chapter) {
    double toDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is int) return value.toDouble();
      if (value is double) return value;
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    final done = chapter['done'] ??
        chapter['answeredCount'] ??
        chapter['completedQuestionCount'] ??
        chapter['completedQuestions'] ??
        0;
    final total = chapter['total'] ??
        chapter['totalCount'] ??
        chapter['questionCount'] ??
        chapter['totalQuestions'] ??
        0;
    final status = chapter['status']?.toString().toLowerCase() ?? '';

    double progress = 0.0;
    if (chapter['percent'] != null) {
      final p = toDouble(chapter['percent']);
      progress = p <= 1 ? p : p / 100;
    } else if (toDouble(total) > 0) {
      progress = toDouble(done) / toDouble(total);
    } else if (status == 'complete' || status == 'completed') {
      progress = 1.0;
    }

    final clamped = progress.clamp(0.0, 1.0);
    final widthFactor = clamped.isNaN ? 0.0 : clamped.toDouble();
    final progressPercent = (widthFactor * 100).round();

    final questionLabel = toDouble(total) == 0 ? '질문 준비 중' : '답변 $done/$total개';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  color: AppTheme.bgAlt,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: widthFactor,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          AppTheme.cta,
                          AppTheme.sky,
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$progressPercent% 완료',
              style: const TextStyle(
                color: AppTheme.ctaDark,
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              questionLabel,
              style: TextStyle(
                color: AppTheme.textSec,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
