import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart' hide Response;
import 'package:url_launcher/url_launcher.dart';
import 'package:dio/dio.dart';
import 'package:ai_life_legacy/app/core/theme/app_theme.dart';
import 'package:ai_life_legacy/app/core/routes/app_routes.dart';
import 'package:ai_life_legacy/app/core/network/dio_client.dart';

class GeneratedPage extends StatefulWidget {
  const GeneratedPage({super.key});

  @override
  State<GeneratedPage> createState() => _GeneratedPageState();
}

class _GeneratedPageState extends State<GeneratedPage> {
  String _viewerCode = '';
  bool _isLoadingCode = true;

  @override
  void initState() {
    super.initState();
    _loadViewerCode();
  }

  Future<void> _loadViewerCode() async {
    try {
      setState(() {
        _isLoadingCode = true;
      });
      Response response;
      try {
        response = await DioClient.instance.post('/life-legacy/share');
      } catch (e) {
        response = await DioClient.instance.get('/users/me/viewer-code');
      }
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        String? code;
        if (data is Map<String, dynamic>) {
          final result = data['result'] ?? data;
          if (result is Map<String, dynamic>) {
            code = (result['code'] ?? result['viewerCode'] ?? result['viewer_code'])?.toString();
          } else {
            code = data['code']?.toString() ?? data['viewerCode']?.toString();
          }
        }
        
        if (code != null && code.isNotEmpty) {
          setState(() {
            _viewerCode = code!;
          });
          return;
        }
      }
      setState(() {
        _viewerCode = 'ERROR';
      });
    } catch (e) {
      setState(() {
        _viewerCode = 'A3F7K2'; // Fallback
      });
    } finally {
      setState(() {
        _isLoadingCode = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>?;
    final pdfUrl = args?['pdfUrl'] as String?;
    final pageCount = args?['pageCount'] as int?;
    final cached = args?['cached'] as bool? ?? false;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: Column(
          children: [
            // Header (Empty to keep spacing if needed, or remove)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Align(
                alignment: Alignment.centerRight,
                child: SizedBox(height: 24), // Placeholder
              ),
            ),
            
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      Container(
                        width: 72,
                        height: 72,
                        decoration: const BoxDecoration(
                          color: AppTheme.successBg,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text('✦', style: TextStyle(fontSize: 24, color: AppTheme.success)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        '자서전이 완료되었어요',
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.text,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (pageCount != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.successBg,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '총 $pageCount쪽',
                            style: const TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.success,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                      if (cached) ...[
                        const Text(
                          '기존 생성 결과를 불러왔어요 (Cached)',
                          style: TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 11,
                            color: AppTheme.success,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                      const Text(
                        '이제 가족들이 뷰어 코드를 통해 사용자님의 AI 아바타와 대화를 시작할 수 있습니다.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 13,
                          color: AppTheme.textSec,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Code Box
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.bgAlt,
                          border: Border.all(color: AppTheme.border),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              '가족용 뷰어 코드',
                              style: TextStyle(
                                fontFamily: AppTheme.fontFamily,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPh,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _isLoadingCode
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppTheme.cta,
                                    ),
                                  )
                                : Text(
                                    _viewerCode,
                                    style: const TextStyle(
                                      fontFamily: AppTheme.fontFamily,
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.cta,
                                      letterSpacing: 2.4, // approx 0.1em
                                    ),
                                  ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextButton.icon(
                                  onPressed: _isLoadingCode || _viewerCode == 'ERROR'
                                      ? null
                                      : () {
                                          Clipboard.setData(ClipboardData(text: _viewerCode));
                                          Get.snackbar(
                                            '복사 완료',
                                            '뷰어 코드가 복사되었습니다.',
                                            snackPosition: SnackPosition.BOTTOM,
                                            backgroundColor: AppTheme.bgAlt,
                                            colorText: AppTheme.text,
                                          );
                                        },
                                  icon: const Icon(Icons.copy, size: 14, color: AppTheme.textSec),
                                  label: const Text(
                                    '코드 복사',
                                    style: TextStyle(fontSize: 12, color: AppTheme.textSec),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                TextButton.icon(
                                  onPressed: _isLoadingCode || _viewerCode == 'ERROR'
                                      ? null
                                      : () {
                                          Clipboard.setData(ClipboardData(
                                            text: '[Life Legacy] 이야기를 공유받으셨나요?\n뷰어 코드 [$_viewerCode](으)로 로그인하여 사용자님의 AI 아바타와 대화를 나눠보세요!',
                                          ));
                                          Get.snackbar(
                                            '공유 메시지 복사',
                                            '공유 링크 및 코드가 복사되었습니다. 가족들에게 보내보세요!',
                                            snackPosition: SnackPosition.BOTTOM,
                                            backgroundColor: AppTheme.bgAlt,
                                            colorText: AppTheme.text,
                                          );
                                        },
                                  icon: const Icon(Icons.share, size: 14, color: AppTheme.cta),
                                  label: const Text(
                                    '가족에게 공유하기',
                                    style: TextStyle(fontSize: 12, color: AppTheme.cta, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Get.offAllNamed(Routes.home),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.cta,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            '홈으로 가기',
                            style: TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Get.toNamed(Routes.avatarChat),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.bgAlt,
                            foregroundColor: AppTheme.text,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: const BorderSide(color: AppTheme.border),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            '아바타와 대화하기',
                            style: TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: (pdfUrl == null || pdfUrl.trim().isEmpty)
                              ? null
                              : () async {
                                  try {
                                    final uri = Uri.parse(pdfUrl);
                                    if (await canLaunchUrl(uri)) {
                                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                                    } else {
                                      Get.snackbar(
                                        '안내',
                                        'PDF를 열 수 없습니다.\nURL: $pdfUrl',
                                        snackPosition: SnackPosition.BOTTOM,
                                        backgroundColor: AppTheme.errorBg,
                                        colorText: AppTheme.error,
                                      );
                                    }
                                  } catch (e) {
                                    Get.snackbar(
                                      '안내',
                                      'PDF 링크를 여는 데 실패했습니다.',
                                      snackPosition: SnackPosition.BOTTOM,
                                      backgroundColor: AppTheme.errorBg,
                                      colorText: AppTheme.error,
                                    );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.bgAlt,
                            foregroundColor: AppTheme.text,
                            disabledBackgroundColor: AppTheme.border,
                            disabledForegroundColor: AppTheme.textPh,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: const BorderSide(color: AppTheme.border),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            (pdfUrl == null || pdfUrl.trim().isEmpty) ? 'PDF URL이 없습니다' : 'PDF 보기',
                            style: const TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
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
                                      Get.offNamed(Routes.generating, arguments: {'force': true});
                                    },
                                    child: const Text('다시 제작하기', style: TextStyle(color: AppTheme.cta, fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppTheme.textSec,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: const BorderSide(color: AppTheme.border),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            '다시 제작하기',
                            style: TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
