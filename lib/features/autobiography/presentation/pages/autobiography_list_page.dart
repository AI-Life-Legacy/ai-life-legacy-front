import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ai_life_legacy/app/core/theme/app_theme.dart';
import 'package:ai_life_legacy/app/core/theme/widgets/app_buttons.dart';
import 'package:ai_life_legacy/app/core/theme/widgets/app_indicators.dart';
import 'package:ai_life_legacy/features/autobiography/presentation/controllers/autobiography_list_controller.dart';
import 'package:ai_life_legacy/features/autobiography/presentation/controllers/autobiography_controller.dart';
import 'package:ai_life_legacy/app/core/routes/app_routes.dart';

class AutobiographyListPage extends GetView<AutobiographyListController> {
  const AutobiographyListPage({super.key});

  void _onCreateAutobiographyPressed() {
    final canGenerate = controller.totalQuestions.value > 0 &&
        controller.answeredQuestions.value >= controller.totalQuestions.value;

    if (!canGenerate) {
      Get.snackbar(
        '안내',
        '${controller.remainingQuestions.value}개 질문에 아직 답변이 필요해요. 모든 질문에 답변한 뒤 자서전을 만들 수 있어요.',
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
    final count = autoController.pageCount.value ?? 0;
    
    if (url == null || url.isEmpty) {
      Get.snackbar(
        '안내',
        'PDF URL이 없습니다. 다시 제작해주세요.',
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
          '자서전을 다시 제작할까요?',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.text),
        ),
        content: const Text(
          '기존에 만들어진 자서전은 현재 답변을 기준으로 다시 만들어집니다. 제작에는 몇 분 정도 걸릴 수 있어요.',
          style: TextStyle(fontSize: 13, color: AppTheme.textSec, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('취소', style: TextStyle(color: AppTheme.textSec)),
          ),
          TextButton(
            onPressed: () {
              Get.back(); // 닫기
              Get.toNamed(Routes.generating, arguments: {'force': true});
            },
            child: const Text('다시 제작하기', style: TextStyle(color: AppTheme.cta, fontWeight: FontWeight.bold)),
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
        title: const Text('나의 자서전', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.info_outline, color: AppTheme.textSec),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.chapters.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.bgAlt,
                border: Border.all(color: AppTheme.border),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${controller.totalChapters.value}개 챕터 중 ${controller.completedChapters.value}개 완료',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.text),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '질문을 탭하면 답변을 수정할 수 있어요.',
                    style: TextStyle(fontSize: 12, color: AppTheme.textPh),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '전체 질문 ${controller.answeredQuestions.value} / ${controller.totalQuestions.value}개 답변 완료',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.textSec),
                      ),
                      Text(
                        '${(controller.totalProgress.value * 100).toInt()}%',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.cta),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  AppProgressBar(
                    value: controller.totalProgress.value,
                    height: 8,
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: controller.chapters.length,
                itemBuilder: (context, index) {
                  final ch = controller.chapters[index];
                  return _ChapterCard(ch: ch);
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: AppTheme.border)),
              ),
              child: Obx(() {
                final autoController = Get.find<AutobiographyController>();
                final bool isGenerated = autoController.autobiographyGenerated.value;
                final bool isAnsweringCompleted = controller.totalQuestions.value > 0 &&
                    controller.answeredQuestions.value >= controller.totalQuestions.value;

                if (isGenerated) {
                  return Column(
                    children: [
                      const Text(
                        '자서전이 완성되어 있어요',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.success),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '답변을 수정했다면 자서전을 다시 제작할 수 있어요.',
                        style: TextStyle(fontSize: 11, color: AppTheme.textPh),
                      ),
                      if (autoController.pageCount.value != null || autoController.pdfUrl.value != null) ...[
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (autoController.pageCount.value != null) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppTheme.bgAlt,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '총 ${autoController.pageCount.value}쪽',
                                  style: const TextStyle(fontSize: 11, color: AppTheme.textSec, fontWeight: FontWeight.w500),
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: autoController.pdfUrl.value != null ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                autoController.pdfUrl.value != null ? 'PDF 사용 가능' : 'PDF 없음',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: autoController.pdfUrl.value != null ? Colors.green.shade800 : Colors.red.shade800,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: SecondaryButton(
                              text: '다시 제작하기',
                              onPressed: _onRecreateAutobiographyPressed,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 2,
                            child: PrimaryButton(
                              text: '내 자서전 보기',
                              onPressed: () => _onViewAutobiographyPressed(autoController),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                } else if (isAnsweringCompleted) {
                  return Column(
                    children: [
                      const Text(
                        '답변을 모아 한 권의 자서전을 만들 수 있어요',
                        style: TextStyle(fontSize: 12, color: AppTheme.success),
                      ),
                      const SizedBox(height: 10),
                      PrimaryButton(
                        text: '내 자서전 만들기',
                        onPressed: _onCreateAutobiographyPressed,
                      ),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      const Text(
                        '모든 질문에 답하면 자서전을 만들 수 있어요',
                        style: TextStyle(fontSize: 12, color: AppTheme.warning),
                      ),
                      const SizedBox(height: 10),
                      PrimaryButton(
                        text: '자서전 만들기',
                        onPressed: _onCreateAutobiographyPressed,
                        disabled: true,
                      ),
                    ],
                  );
                }
              }),
            ),
          ],
        );
      }),
    );
  }
}

class _ChapterCard extends GetView<AutobiographyListController> {
  final Map<String, dynamic> ch;
  const _ChapterCard({required this.ch});

  @override
  Widget build(BuildContext context) {
    final tocId = ch['tocId'] ?? ch['id'] ?? ch['n'];
    final title = ch['title'] ?? ch['tocTitle'] ?? ch['name'] ?? '제목 없음';
    final done = (ch['done'] as num?)?.toInt() ?? 0;
    final total = (ch['total'] as num?)?.toInt() ?? 0;
    final percent = (ch['percent'] as num?)?.toInt() ?? 0;
    
    String statusStr = ch['status']?.toString().toLowerCase() ?? '';

    final bool isCompleted = statusStr == 'completed' ||
        statusStr == 'complete' ||
        (total > 0 && done >= total) ||
        percent >= 100;

    final bool isInProgress = done > 0 && !isCompleted;

    if (statusStr.isEmpty || statusStr == 'null') {
      if (isCompleted) {
        statusStr = 'complete';
      } else if (isInProgress) {
        statusStr = 'in-progress';
      } else {
        statusStr = 'not-started';
      }
    }

    final Color progressColor = isCompleted
        ? Colors.green
        : isInProgress
            ? Colors.black87
            : Colors.grey.shade300;

    final double progress = total > 0 ? done / total : 0.0;

    return Obx(() {
      final isExpanded = controller.expandedTocId.value == tocId;
      final questions = controller.tocQuestions[tocId] ?? [];
      final isLoadingQuestions = controller.loadingQuestionTocIds.contains(tocId);

      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppTheme.border),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            InkWell(
              onTap: () => controller.toggleChapter(tocId),
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppTheme.bgAlt,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Ch.$tocId',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppTheme.textSec),
                          ),
                        ),
                        Row(
                          children: [
                            StatusBadge(status: statusStr),
                            const SizedBox(width: 8),
                            Icon(
                              isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                              color: AppTheme.textPh,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      title,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.text),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$done / $total 질문 답변 완료',
                          style: const TextStyle(fontSize: 12, color: AppTheme.textSec),
                        ),
                        Text(
                          '${(progress * 100).toInt()}%',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.cta),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    AppProgressBar(value: progress, height: 6, fill: progressColor),
                  ],
                ),
              ),
            ),
            if (isExpanded)
              Container(
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: AppTheme.border)),
                  color: AppTheme.bg,
                ),
                padding: const EdgeInsets.all(12),
                child: isLoadingQuestions
                    ? const Center(
                        child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      ))
                    : questions.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text('질문 목록이 없습니다.', style: TextStyle(color: AppTheme.textSec)),
                          )
                        : Column(
                            children: questions.map((q) {
                              final qIndex = questions.indexOf(q) + 1;
                              final qText = q['questionText'] ?? q['question'] ?? q['text'] ?? '제목 없음';
                              final isQDone = q['isAnswered'] == true ||
                                  q['status'] == 'completed' ||
                                  q['done'] == true ||
                                  q['answerId'] != null ||
                                  qIndex <= done;
                              
                              return InkWell(
                                onTap: () => controller.onQuestionTap(tocId, q),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('$qIndex. ', style: const TextStyle(fontSize: 13, color: AppTheme.text)),
                                      Expanded(
                                        child: Text(
                                          qText,
                                          style: const TextStyle(fontSize: 13, color: AppTheme.text),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        isQDone ? '완료' : '미완료',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isQDone ? AppTheme.cta : AppTheme.textPh,
                                          fontWeight: isQDone ? FontWeight.w600 : FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
              ),
          ],
        ),
      );
    });
  }
}
