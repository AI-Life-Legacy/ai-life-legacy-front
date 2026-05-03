import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ai_life_legacy/app/core/theme/app_theme.dart';

class AutobiographyWritePage extends StatefulWidget {
  const AutobiographyWritePage({super.key});

  @override
  State<AutobiographyWritePage> createState() => _AutobiographyWritePageState();
}

class _AutobiographyWritePageState extends State<AutobiographyWritePage> {
  final _controller = TextEditingController(text: 'Mrs. Harlow 선생님의 영문학 수업. 학생 하나하나를 진심으로 봐주셨고, "네 안에 이야기가 있어"라고 자주 말씀하셨죠. 선생님의 말씀을 통해 내면의 목소리를 처음 들을 수 있었어요.');
  int _charCount = 0;

  @override
  void initState() {
    super.initState();
    _charCount = _controller.text.length;
    _controller.addListener(() {
      setState(() {
        _charCount = _controller.text.length;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
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
                  TextButton(
                    onPressed: () => Get.back(),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      '저장',
                      style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 14, color: AppTheme.success),
                    ),
                  ),
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
                  const Text(
                    '당신의 가장 어릴 적 기억은 무엇인가요?',
                    style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 15, fontWeight: FontWeight.w500, color: AppTheme.text, height: 1.5),
                  ),
                ],
              ),
            ),

            // Text Area
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _controller,
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

            // Footer info
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: AppTheme.border)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$_charCount자',
                    style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: AppTheme.textPh),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: const Icon(Icons.chevron_left, color: AppTheme.textSec, size: 24),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
