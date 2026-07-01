import 'package:ai_life_legacy/app/core/network/dio_client.dart';
import 'package:ai_life_legacy/app/core/routes/app_routes.dart';
import 'package:ai_life_legacy/app/core/theme/app_theme.dart';
import 'package:ai_life_legacy/app/core/theme/widgets/animated_mascot.dart';
import 'package:ai_life_legacy/app/core/theme/widgets/mascot_flow_widgets.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart' hide Response;
import 'package:url_launcher/url_launcher.dart';

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
            code = (result['code'] ??
                    result['viewerCode'] ??
                    result['viewer_code'])
                ?.toString();
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
        _viewerCode = 'A3F7K2';
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

    return MascotScaffold(
      scrollable: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          const Center(child: AnimatedMascot(size: 150)),
          const SizedBox(height: 18),
          const Text(
            '자서전이\n완성됐어요',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: MascotFlowTheme.text,
              fontSize: 30,
              height: 1.15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          if (pageCount != null || cached)
            Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: MascotFlowTheme.surface,
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(color: MascotFlowTheme.border),
                ),
                child: Text(
                  cached ? '기존 결과를 불러왔어요' : '총 $pageCount쪽으로 묶었어요',
                  style: const TextStyle(
                    color: MascotFlowTheme.active,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          const SizedBox(height: 26),
          _ViewerCodeCard(
            viewerCode: _viewerCode,
            isLoading: _isLoadingCode,
          ),
          const SizedBox(height: 14),
          FlowPrimaryButton(
            text: '홈으로 가기',
            onPressed: () => Get.offAllNamed(Routes.home),
          ),
          const SizedBox(height: 12),
          FlowOptionCard(
            icon: Icons.face_5_outlined,
            title: '아바타와 대화하기',
            subtitle: '완성된 이야기로 만든 아바타를 만나보세요.',
            selected: true,
            onTap: () => Get.toNamed(Routes.avatarChat),
          ),
          FlowOptionCard(
            icon: Icons.picture_as_pdf_outlined,
            title: (pdfUrl == null || pdfUrl.trim().isEmpty)
                ? 'PDF URL이 없습니다'
                : 'PDF 보기',
            subtitle: '새 창에서 완성된 자서전을 확인합니다.',
            onTap: () => _openPdf(pdfUrl),
          ),
          FlowOptionCard(
            icon: Icons.refresh,
            title: '다시 제작하기',
            subtitle: '현재 답변 기준으로 자서전을 다시 생성합니다.',
            onTap: _confirmRegenerate,
          ),
          const SizedBox(height: 18),
        ],
      ),
    );
  }

  Future<void> _openPdf(String? pdfUrl) async {
    if (pdfUrl == null || pdfUrl.trim().isEmpty) return;

    try {
      final uri = Uri.parse(pdfUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showSnack('안내', 'PDF를 열 수 없습니다.\nURL: $pdfUrl');
      }
    } catch (e) {
      _showSnack('안내', 'PDF 링크를 여는 데 실패했습니다.');
    }
  }

  void _confirmRegenerate() {
    Get.dialog(
      AlertDialog(
        backgroundColor: MascotFlowTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text(
          '자서전을 다시 제작할까요?',
          style: TextStyle(
            color: MascotFlowTheme.text,
            fontSize: 17,
            fontWeight: FontWeight.w900,
          ),
        ),
        content: const Text(
          '기존에 만들어진 자서전은 현재 답변을 기준으로 다시 만들어집니다.',
          style: TextStyle(
            color: MascotFlowTheme.textMuted,
            fontSize: 13,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              '취소',
              style: TextStyle(color: MascotFlowTheme.textMuted),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              Get.offNamed(Routes.generating, arguments: {'force': true});
            },
            child: const Text(
              '다시 제작하기',
              style: TextStyle(
                color: AppTheme.cta,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSnack(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: MascotFlowTheme.surface,
      colorText: MascotFlowTheme.text,
    );
  }
}

class _ViewerCodeCard extends StatelessWidget {
  final String viewerCode;
  final bool isLoading;

  const _ViewerCodeCard({
    required this.viewerCode,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: MascotFlowTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: MascotFlowTheme.border, width: 2),
      ),
      child: Column(
        children: [
          const Text(
            '가족용 뷰어 코드',
            style: TextStyle(
              color: MascotFlowTheme.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          if (isLoading)
            const SizedBox(
              height: 28,
              width: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppTheme.cta,
              ),
            )
          else
            Text(
              viewerCode,
              style: const TextStyle(
                color: AppTheme.cta,
                fontSize: 30,
                letterSpacing: 3,
                fontWeight: FontWeight.w900,
              ),
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed:
                      isLoading || viewerCode == 'ERROR' ? null : _copyCode,
                  icon: const Icon(Icons.copy, size: 16),
                  label: const Text('복사'),
                  style: _buttonStyle(),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed:
                      isLoading || viewerCode == 'ERROR' ? null : _copyShare,
                  icon: const Icon(Icons.share, size: 16),
                  label: const Text('공유'),
                  style: _buttonStyle(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  ButtonStyle _buttonStyle() {
    return OutlinedButton.styleFrom(
      foregroundColor: MascotFlowTheme.text,
      side: const BorderSide(color: MascotFlowTheme.border, width: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(vertical: 12),
    );
  }

  void _copyCode() {
    Clipboard.setData(ClipboardData(text: viewerCode));
    Get.snackbar(
      '복사 완료',
      '뷰어 코드가 복사되었습니다.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: MascotFlowTheme.surface,
      colorText: MascotFlowTheme.text,
    );
  }

  void _copyShare() {
    Clipboard.setData(
      ClipboardData(
        text: '[Life Legacy] 이야기를 공유받으셨나요?\n'
            '뷰어 코드 [$viewerCode](으)로 로그인하여 AI 아바타와 대화를 나눠보세요!',
      ),
    );
    Get.snackbar(
      '공유 메시지 복사',
      '가족에게 보낼 메시지가 복사되었습니다.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: MascotFlowTheme.surface,
      colorText: MascotFlowTheme.text,
    );
  }
}
