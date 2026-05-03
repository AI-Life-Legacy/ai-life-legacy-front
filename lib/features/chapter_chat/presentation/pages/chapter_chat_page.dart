import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ai_life_legacy/app/core/theme/app_theme.dart';

class ChapterChatPage extends StatefulWidget {
  const ChapterChatPage({super.key});

  @override
  State<ChapterChatPage> createState() => _ChapterChatPageState();
}

class _ChapterChatPageState extends State<ChapterChatPage> {
  Widget _buildAIBubble(String text, String time) {
    return Container(
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.76),
      margin: const EdgeInsets.only(bottom: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.bgAlt,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              text,
              style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 15, color: AppTheme.text, height: 1.5),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4),
            child: Text(time, style: AppTheme.caption),
          ),
        ],
      ),
    );
  }

  Widget _buildUserBubble(String text, String time) {
    return Container(
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.76),
      margin: const EdgeInsets.only(bottom: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.cta,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              text,
              style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 15, color: Colors.white, height: 1.5),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4, right: 4),
            child: Text(time, style: AppTheme.caption),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppTheme.border)),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.arrow_back, color: AppTheme.text, size: 20),
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'Ch.2 — 청소년기',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 15, fontWeight: FontWeight.w500, color: AppTheme.text),
                    ),
                  ),
                  SizedBox(
                    width: 40,
                    child: Text(
                      '3/8',
                      textAlign: TextAlign.right,
                      style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, color: AppTheme.textPh),
                    ),
                  ),
                ],
              ),
            ),

            // AI Question Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.warnBg,
                border: Border.all(color: AppTheme.warnBorder),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI 질문',
                    style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, color: AppTheme.warning, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '학창 시절 가장 좋아했던 과목은 무엇이었고, 그 이유는 무엇인가요?',
                    style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 14, color: AppTheme.text, height: 1.4),
                  ),
                ],
              ),
            ),

            // Chat area
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: _buildAIBubble('학창 시절 기억 중에서 가장 남는 장면이나 과목을 들려주세요.', '오전 9:10'),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: _buildUserBubble('Mrs. Harlow 선생님의 영문학 수업이요. 책 속에 삶이 있다는 걸 처음 가르쳐 주신 분이었어요.', '오전 9:15'),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: _buildAIBubble('그 수업이 Margaret님의 삶에 어떤 영감을 주었나요?', '오전 9:16'),
                  ),
                ],
              ),
            ),

            // Bottom Input
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: AppTheme.border)),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.toNamed('/write'),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppTheme.bgAlt,
                        border: Border.all(color: AppTheme.border),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.edit, size: 16, color: AppTheme.text),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      height: 40,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppTheme.border),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const TextField(
                        decoration: InputDecoration(
                          hintText: 'Mrs. Harlow 선생님은...',
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                        ),
                        style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () => Get.toNamed('/autobiography'), // Or submit
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.cta,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      minimumSize: const Size(0, 40),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                    child: const Text(
                      '전송',
                      style: TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w500),
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
}
