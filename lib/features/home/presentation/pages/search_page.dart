import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ai_life_legacy/app/core/theme/app_theme.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final queryController = TextEditingController(text: "학교");

  final results = [
    {
      'ch': 2,
      'q': '학창 시절 가장 좋아했던 과목은 무엇이었고, 그 이유는 무엇인가요?',
      'a': 'Mrs. Harlow 선생님의 영문학 수업. 학생 하나하나를 진심으로 봐주셨고, "네 안에 이야기가 있어"라고 자주 말씀하셨죠.'
    },
    {
      'ch': 5,
      'q': '선생님이 되고 처음 맡은 반은 어땠나요?',
      'a': '작은 학교의 3학년 반이었어요. 스무 명 남짓한 아이들과 함께한 첫 해가 지금도 가장 선명해요.'
    },
    {
      'ch': 2,
      'q': '학교에서 가장 기억에 남는 친구는 누구인가요?',
      'a': 'Ruthie라는 아이였어요. 우리는 매일 같은 학교 버스를 탔고, 여름방학이면 같이 복숭아를 땄어요.'
    },
  ];

  @override
  void dispose() {
    queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: Column(
          children: [
            // Header Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppTheme.border),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search, size: 18, color: AppTheme.textPh),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: queryController,
                              style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 14, color: AppTheme.text),
                              decoration: const InputDecoration(
                                hintText: '기억을 검색해보세요',
                                hintStyle: TextStyle(color: AppTheme.textPh),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  TextButton(
                    onPressed: () => Get.back(),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      '취소',
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 14,
                        color: AppTheme.textSec,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text('검색 결과', style: AppTheme.sectionLabel),
                  const SizedBox(height: 12),
                  ...results.map((r) => GestureDetector(
                    onTap: () => Get.toNamed('/chapter-chat'),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.bg,
                        border: Border.all(color: AppTheme.border),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ch.${r["ch"]} · 관련 기억',
                            style: const TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              fontSize: 11,
                              color: AppTheme.warning,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            r["q"].toString(),
                            style: const TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.text,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '"${r["a"]}"',
                            style: const TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              fontSize: 13,
                              color: AppTheme.textSec,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
