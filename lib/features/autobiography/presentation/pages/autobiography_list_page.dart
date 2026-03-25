// lib/features/post/presentation/screens/autobiography_list_screen.dart

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:ai_life_legacy/features/autobiography/presentation/pages/autobiography_write_page.dart';
import 'package:ai_life_legacy/features/user/data/models/user.dto.dart';
import 'package:ai_life_legacy/features/user/data/user_repository.dart';
import 'package:ai_life_legacy/app/core/utils/toast_utils.dart';
import 'package:ai_life_legacy/app/core/routes/app_routes.dart';
import 'package:ai_life_legacy/app/core/ai/ai_repository.dart';

class AutobiographyListPage extends StatefulWidget {
  const AutobiographyListPage({super.key});

  @override
  State<AutobiographyListPage> createState() => _AutobiographyListPageState();
}

class _AutobiographyListPageState extends State<AutobiographyListPage> {
  final UserRepository _userRepository = Get.find<UserRepository>();
  final AiRepository _aiRepository = Get.find<AiRepository>();

  int? _expandedIndex;
  bool _isLoading = false;
  bool _isGenerating = false;
  int _generationStep = 0;
  String? _generatedPdfPath; // 생성된 PDF 경로 저장
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
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () => Get.toNamed(Routes.search), // 새 경로 추가 예정
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.black),
            onPressed: () => Get.toNamed(Routes.myPage),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isGenerating
          ? _buildBody()
          : RefreshIndicator(
              onRefresh: _loadSections,
              child: _buildBody(),
            ),
      floatingActionButton: _isGenerating
          ? null
          : FloatingActionButton.extended(
              onPressed: _generateAutobiography,
              backgroundColor: Colors.black,
              icon: const Icon(Icons.auto_stories, color: Colors.white),
              label: const Text(
                '나만의 자서전 만들기',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
    );
  }

  Future<void> _generateAutobiography() async {
    // 생성 확인 다이얼로그
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('자서전 생성'),
        content: const Text('그동안 작성하신 모든 기억을 모아 자서전을 생성하시겠습니까? (시간이 조금 걸릴 수 있습니다)'),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('취소')),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: Colors.blue),
            child: const Text('생성 시작'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // 기존의 단순 로딩 다이얼로그 제거 (이제 _buildBody에서 자체 대기 화면을 보여줌)

    try {
      if (!mounted) return;
      setState(() {
        _isGenerating = true;
        _generationStep = 0;
        _generatedPdfPath = null;
      });

      // 진행 단계 시뮬레이션
      final stepTimer = Stream.periodic(const Duration(seconds: 15), (i) => i + 1)
          .listen((step) {
            if (mounted && step < 4) {
              setState(() => _generationStep = step);
            }
          });

      final response = await _aiRepository.generateAutobiography();
      
      stepTimer.cancel();
      if (!mounted) return;
      setState(() {
        _isGenerating = false;
        _generatedPdfPath = response.data.pdfPath;
      });
      
      // 성공 알림
      ToastUtils.showInfoToast('자서전 작성이 완료되었습니다! 아래에서 다운로드할 수 있습니다.');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isGenerating = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('생성 실패: 자서전 생성 중 오류가 발생했습니다.\n$e')),
      );
    }
  }

  Widget _buildBody() {
    if (_isGenerating) {
      final steps = [
        '기록된 추억들을 불러오는 중입니다...',
        '소중한 순간들을 엮어 이야기를 만들고 있습니다...',
        '자서전의 내용을 다듬고 교정하는 중입니다...',
        '마지막으로 PDF 파일을 생성하고 있습니다...',
      ];

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.auto_stories, size: 80, color: Color(0xFF5B9FED)),
            const SizedBox(height: 40),
            Text(
              steps[_generationStep],
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 24),
            const LinearProgressIndicator(
              backgroundColor: Color(0xFFE0E0E0),
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF5B9FED)),
              minHeight: 8,
            ),
            const SizedBox(height: 32),
            const Text(
              '자서전 생성이 진행 중입니다.\n최대 3분 정도 소요될 수 있으니 잠시만 기다려 주세요.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black45, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 16),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black26),
                ),
                SizedBox(width: 12),
                Text('서버와 연결 확인 중...', style: TextStyle(color: Colors.black26, fontSize: 12)),
              ],
            ),
          ],
        ),
      );
    }

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

    if (_sections.isEmpty && _generatedPdfPath == null) {
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
      itemCount: _sections.length + (_generatedPdfPath != null ? 1 : 0),
      itemBuilder: (context, index) {
        if (_generatedPdfPath != null && index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildDownloadCard(),
          );
        }

        final sectionIndex = _generatedPdfPath != null ? index - 1 : index;
        final section = _sections[sectionIndex];
        final isExpanded = _expandedIndex == sectionIndex;

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
                                                if (context.mounted) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(content: Text('오류: 확인 중 오류가 발생했습니다: ${e.message}')),
                                                  );
                                                }
                                              }
                                            } catch (e) {
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(content: Text('오류: 알 수 없는 오류가 발생했습니다.')),
                                                );
                                              }
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

  Widget _buildDownloadCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F7FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD0E3FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text(
                '자서전 제작 완료!',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF003D99),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            '소중한 추억이 담긴 나만의 자서전이 완성되었습니다.\n지금 바로 확인해보세요.',
            style: TextStyle(fontSize: 13, color: Colors.black87, height: 1.5),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                if (_generatedPdfPath != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('다운로드: PDF 파일(${_generatedPdfPath})을 다운로드합니다.')),
                  );
                }
              },
              icon: const Icon(Icons.download),
              label: const Text('자서전 PDF 다운로드'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5B9FED),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
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
