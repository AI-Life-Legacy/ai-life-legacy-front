import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ai_life_legacy/app/core/theme/app_theme.dart';
import 'package:ai_life_legacy/app/core/routes/app_routes.dart';

class ChapterCompletePage extends StatelessWidget {
  const ChapterCompletePage({super.key});

  Map<String, dynamic>? findNextChapter(List<Map<String, dynamic>> chapters, int currentTocId) {
    final normalized = chapters.map((e) => Map<String, dynamic>.from(e)).toList();

    final afterCurrent = normalized.where((ch) {
      final id = (ch['tocId'] as num?)?.toInt() ?? 0;
      final done = (ch['done'] as num?)?.toInt() ?? 0;
      final total = (ch['total'] as num?)?.toInt() ?? 0;
      final status = ch['status']?.toString();
      final isCompleted = status == 'completed' || status == 'complete' || done >= total;
      return id > currentTocId && !isCompleted;
    }).toList();

    if (afterCurrent.isNotEmpty) return afterCurrent.first;

    final anyIncomplete = normalized.where((ch) {
      final done = (ch['done'] as num?)?.toInt() ?? 0;
      final total = (ch['total'] as num?)?.toInt() ?? 0;
      final status = ch['status']?.toString();
      final isCompleted = status == 'completed' || status == 'complete' || done >= total;
      return !isCompleted;
    }).toList();

    return anyIncomplete.isNotEmpty ? anyIncomplete.first : null;
  }

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    final tocId = args['tocId'] as int? ?? 0;
    final title = args['title']?.toString() ?? '';
    final chapterNumber = args['chapterNumber'] as int? ?? tocId;
    final questionCount = args['questionCount'] as int? ?? 0;
    final answeredCount = args['answeredCount'] as int? ?? questionCount;
    final completedChapters = args['completedChapters'] as int? ?? 0;
    final chaptersList = args['chapters'] as List? ?? [];
    
    final chapters = chaptersList.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    final nextChapter = findNextChapter(chapters, tocId);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppTheme.cta.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        size: 40,
                        color: AppTheme.cta,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      '챕터 완료',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Ch.$chapterNumber — $title\n성공적으로 저장되었어요.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppTheme.textPh,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 48),
                    Row(
                      children: [
                        _buildStatCard('질문 수', '$questionCount'),
                        const SizedBox(width: 12),
                        _buildStatCard('답변 완료', '$answeredCount'),
                        const SizedBox(width: 12),
                        _buildStatCard('완료 챕터', '$completedChapters'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        if (nextChapter == null) {
                          Get.offNamed(Routes.autobiography);
                          return;
                        }

                        Get.offNamed(
                          Routes.chapterChat,
                          arguments: {
                            'tocId': nextChapter['tocId'],
                            'title': nextChapter['title'],
                            'chapterNumber': nextChapter['tocId'],
                            'done': nextChapter['done'],
                            'total': nextChapter['total'],
                            'status': nextChapter['status'],
                            'percent': nextChapter['percent'],
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.cta,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        nextChapter == null ? '나의 자서전 보러가기' : '다음 챕터 시작하기',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: TextButton(
                      onPressed: () {
                        Get.offAllNamed(Routes.home);
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.textPh,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        '홈으로 돌아가기',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppTheme.bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textPh,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
