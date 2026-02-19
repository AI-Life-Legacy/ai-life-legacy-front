// lib/features/post/presentation/screens/autobiography_list_screen.dart

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:ai_life_legacy/features/autobiography/presentation/pages/autobiography_write_page.dart';
import 'package:ai_life_legacy/features/user/data/models/user.dto.dart';
import 'package:ai_life_legacy/features/user/data/user_repository.dart';
import 'package:ai_life_legacy/app/core/utils/toast_utils.dart';
import 'package:ai_life_legacy/app/core/routes/app_routes.dart'; // import added

class AutobiographyListPage extends StatefulWidget {
  const AutobiographyListPage({super.key});

  @override
  State<AutobiographyListPage> createState() => _AutobiographyListPageState();
}

class _AutobiographyListPageState extends State<AutobiographyListPage> {
  final UserRepository _userRepository = Get.find<UserRepository>();

  int? _expandedIndex;
  bool _isLoading = false;
  String? _errorMessage;
  List<UserTocQuestionDto> _sections = [];

  @override
  void initState() {
    super.initState();
    _loadSections();
  }

  Future<void> _loadSections() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 1. 목차 및 질문 목록 조회
      // UserRepo를 통해 맞춤형 질문 리스트를 한 번에 가져옵니다.
      final result = await _userRepository.getUserTocQuestions();
      // tocId 기준으로 중복 제거 (Backend 데이터 정합성 보장 차원)
      final uniqueIds = <int>{};
      final loadedSections = result.data.where((section) {
        return uniqueIds.add(section.tocId);
      }).toList();

      if (!mounted) return;
      setState(() {
        _sections = loadedSections;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _sections = [];
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 배경색 흰색으로 변경
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
      body: RefreshIndicator(
        onRefresh: _loadSections,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _sections.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null && _sections.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ErrorState(
            message: _errorMessage!,
            onRetry: _loadSections,
          ),
        ],
      );
    }

    if (_sections.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(32),
        children: const [
          Center(
            child: Text(
              '표시할 자서전 질문이 없습니다.',
              style: TextStyle(fontSize: 16, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _sections.length,
      itemBuilder: (context, index) {
        final section = _sections[index];
        final isExpanded = _expandedIndex == index;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Column(
            children: [
              ListTile(
                title: Text(
                  section.tocTitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  '총 ${section.questions.length}개의 질문',
                  style: const TextStyle(fontSize: 13),
                ),
                trailing: Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                ),
                onTap: () {
                  setState(() {
                    _expandedIndex = isExpanded ? null : index;
                  });
                },
              ),
              if (isExpanded)
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: section.questions.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            '아직 등록된 질문이 없습니다.',
                            style:
                                TextStyle(fontSize: 14, color: Colors.black54),
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Divider(),
                            ...section.questions.asMap().entries.map(
                              (entry) {
                                final questionIndex = entry.key;
                                final question = entry.value;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: InkWell(
                                    onTap: () async {
                                      // 1. 기존 답변 존재 여부 확인 (답변이 있으면 수정 화면으로 이동하기 위함)
                                      try {
                                        await _userRepository.getUserAnswers(
                                          questionId: question.id,
                                          tocId: section.tocId,
                                        );

                                        // 2. 답변이 존재하면 조회된 데이터와 함께 이동 (작성 페이지 재활용)
                                        final result = await Get.to(
                                          () => AutobiographyWritePage(
                                            tocId: section.tocId,
                                            tocTitle: section.tocTitle,
                                            questionId: question.id,
                                            question: question.questionText,
                                          ),
                                        );
                                        if (result == true) {
                                          _loadSections();
                                        }
                                      } on DioException catch (e) {
                                        if (e.response?.statusCode == 404) {
                                          ToastUtils.showInfoToast(
                                              '아직 작성된 내용이 없습니다. 먼저 자서전을 작성해주세요.');
                                        } else {
                                          Get.snackbar(
                                            '오류',
                                            '확인 중 오류가 발생했습니다: ${e.message}',
                                          );
                                        }
                                      } catch (e) {
                                        Get.snackbar(
                                            '오류', '알 수 없는 오류가 발생했습니다.');
                                      }
                                    },
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${questionIndex + 1}. ',
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                        Expanded(
                                          child: Text(
                                            question.questionText,
                                            style:
                                                const TextStyle(fontSize: 14),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          message,
          style: const TextStyle(fontSize: 14, color: Colors.redAccent),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: onRetry,
          child: const Text('다시 시도'),
        ),
      ],
    );
  }
}
