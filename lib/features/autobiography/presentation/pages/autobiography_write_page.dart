import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ai_life_legacy/app/core/theme/app_theme.dart';
import 'package:ai_life_legacy/features/autobiography/presentation/controllers/autobiography_write_controller.dart';

class AutobiographyWritePage extends StatefulWidget {
  const AutobiographyWritePage({super.key});

  @override
  State<AutobiographyWritePage> createState() => _AutobiographyWritePageState();
}

class _AutobiographyWritePageState extends State<AutobiographyWritePage> {
  final _textController = TextEditingController();
  final _controller = Get.find<AutobiographyWriteController>();
  Worker? _worker;

  @override
  void initState() {
    super.initState();
    
    _worker = ever(_controller.answerText, (String text) {
      if (_textController.text != text) {
        _textController.text = text;
      }
    });
    
    _textController.addListener(() {
      _controller.answerText.value = _textController.text;
    });
  }

  @override
  void dispose() {
    _worker?.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppTheme.border)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      '취소',
                      style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 14, color: AppTheme.textSec),
                    ),
                  ),
                  const Text(
                    '기억 수정 · 기록하기',
                    style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.text),
                  ),
                  Obx(() {
                    return TextButton(
                      onPressed: _controller.isSaving.value ? null : () => _controller.save(),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        _controller.isSaving.value ? '저장 중...' : '저장',
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 14,
                          color: _controller.isSaving.value ? AppTheme.textPh : AppTheme.success,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),

            // Question
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('질문', style: AppTheme.sectionLabel),
                  const SizedBox(height: 6),
                  Obx(() {
                    return Text(
                      _controller.questionText.value,
                      style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 15, fontWeight: FontWeight.w500, color: AppTheme.text, height: 1.5),
                    );
                  }),
                ],
              ),
            ),

            // Text Area
            Expanded(
              child: Obx(() {
                if (_controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (_controller.errorMessage.value.isNotEmpty) {
                  return Center(
                    child: Text(
                      _controller.errorMessage.value,
                      style: const TextStyle(color: AppTheme.error),
                    ),
                  );
                }

                final text = _controller.answerText.value;
                final bool hasQuestionMarker = text.contains('추가 질문:');
                final bool hasAnswerMarker = text.contains('추가 답변:');
                
                Widget? helperWidget;
                if (hasQuestionMarker && hasAnswerMarker) {
                  helperWidget = Container(
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F4FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline, size: 16, color: Color(0xFF3B82F6)),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '아래 내용에는 AI 추가 질문과 추가 답변이 함께 포함되어 있어요.',
                            style: TextStyle(fontSize: 12, color: Color(0xFF3B82F6)),
                          ),
                        ),
                      ],
                    ),
                  );
                } else if (hasAnswerMarker && !hasQuestionMarker) {
                  helperWidget = Container(
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7ED),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.warning_amber_rounded, size: 16, color: Color(0xFFF97316)),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '추가 질문 정보가 저장되지 않은 답변입니다.',
                            style: TextStyle(fontSize: 12, color: Color(0xFFF97316)),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: [
                    if (helperWidget != null) helperWidget,
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: TextField(
                          controller: _textController,
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
                          style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 16, color: AppTheme.text, height: 1.7),
                          decoration: const InputDecoration(
                            hintText: '답변을 여기에 적어보세요...',
                            hintStyle: TextStyle(color: AppTheme.textPh),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ),

            // Footer info
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: AppTheme.border)),
              ),
              child: Obx(() {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_controller.answerText.value.length}자',
                      style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: AppTheme.textPh),
                    ),
                    const Icon(Icons.chevron_left, color: AppTheme.textSec, size: 24),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
