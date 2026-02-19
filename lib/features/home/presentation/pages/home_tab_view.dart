
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ai_life_legacy/features/home/presentation/controllers/home_controller.dart';
import 'package:ai_life_legacy/app/core/routes/app_routes.dart';

class HomeTabView extends GetView<HomeController> {
  const HomeTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0, // 스크롤 시 색상 변경 방지
        elevation: 0,
        title: const Text(
          '나의 자서전',
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Obx(() {
          if (controller.loading.value && controller.chapters.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.chapters.isEmpty) {
            return _buildEmptyState();
          }

          if (controller.errorMessage.isNotEmpty) {
            Get.rawSnackbar(
              message: controller.errorMessage.value,
              backgroundColor: Colors.redAccent.withOpacity(0.9),
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
          const Icon(Icons.edit_note, size: 48, color: Colors.blueAccent),
          const SizedBox(height: 16),
          const Text(
            '아직 자기소개가 작성되지 않아\n목차가 보이지 않습니다.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black87, fontSize: 16, height: 1.5),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => Get.find<HomeController>().changeTab(1), // 자기소개 탭으로 이동
            child: const Text(
              '이어서 작성하러 가시겠습니까?',
              style: TextStyle(
                color: Colors.blue,
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

  Widget _buildChapterCard(ChapterModel chapter) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => controller.onChapterTap(chapter),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Chapter ${chapter.id}',
                  style: const TextStyle(
                    color: Color(0xFF4A9EFF),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  chapter.title,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  chapter.subtitle,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 16),
                _buildProgressBar(chapter),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar(ChapterModel chapter) {
    final clamped = chapter.progress.clamp(0.0, 1.0);
    final widthFactor = clamped.isNaN ? 0.0 : clamped.toDouble();
    final progressPercent = (widthFactor * 100).round();
    final questionLabel = chapter.totalQuestions == 0
        ? '질문 준비 중'
        : '답변 ${chapter.answeredQuestions}/${chapter.totalQuestions}개';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: widthFactor,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF4FC3F7),
                          Color(0xFF2196F3),
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
                color: Colors.black87,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              questionLabel,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
