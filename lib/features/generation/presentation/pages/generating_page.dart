import 'dart:async';
import 'package:ai_life_legacy/app/core/theme/widgets/animated_mascot.dart';
import 'package:ai_life_legacy/app/core/theme/widgets/mascot_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ai_life_legacy/app/core/theme/app_theme.dart';
import 'package:ai_life_legacy/app/core/routes/app_routes.dart';
import 'package:ai_life_legacy/app/core/utils/safe_navigation.dart';
import 'package:ai_life_legacy/features/autobiography/presentation/controllers/autobiography_controller.dart';

class GeneratingPage extends StatefulWidget {
  const GeneratingPage({super.key});

  @override
  State<GeneratingPage> createState() => _GeneratingPageState();
}

class _GeneratingPageState extends State<GeneratingPage> {
  final AutobiographyController _controller =
      Get.find<AutobiographyController>();

  Timer? _progressTimer;
  double _progress = 0.0;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _startGeneration();
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    super.dispose();
  }

  void _startGeneration() {
    setState(() {
      _progress = 0.0;
      _hasError = false;
      _errorMessage = '';
    });

    // 시작 5분 (300초) 기준, 0.1초마다 0.0316% 증가 -> 300초에 95% 도달
    // (95 / 300) / 10 = 0.03166...
    _progressTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (_progress < 95.0) {
        setState(() {
          _progress += (95.0 / 3000.0);
          if (_progress > 95.0) _progress = 95.0;
        });
      }
    });

    _executeApi();
  }

  Future<void> _executeApi() async {
    final bool force = Get.arguments?['force'] == true;
    final templateId = Get.arguments?['templateId']?.toString() ?? 'classic';
    final result = await _controller.generateFullBook(
      force: force,
      templateId: templateId,
    );
    _progressTimer?.cancel();

    if (!mounted) return;

    if (result != null) {
      setState(() {
        _progress = 100.0;
      });

      // 성공 후 100% 보여주고 이동
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          Get.offNamed(Routes.generated, arguments: result);
        }
      });
    } else {
      setState(() {
        _hasError = true;
        final errorMsg = _controller.lastGenerationError.value;
        if (force) {
          _errorMessage = '다시 제작에 실패했습니다. 기존 자서전은 계속 볼 수 있어요.';
        } else {
          _errorMessage = errorMsg.isNotEmpty
              ? errorMsg
              : '자서전 생성에 실패했습니다.\n잠시 후 다시 시도해주세요.';
        }
      });
    }
  }

  String get _currentTitle {
    if (_progress < 25) return '기억을 모으는 중...';
    if (_progress < 50) return '이야기를 엮는 중...';
    if (_progress < 75) return '문장을 다듬는 중...';
    return 'PDF를 만드는 중...';
  }

  String get _currentDescription {
    if (_progress < 25) return '당신의 이야기들을 찾고 있어요';
    if (_progress < 50) return '흩어진 이야기들을 하나의 흐름으로 연결하고 있어요';
    if (_progress < 75) return '당신의 목소리를 담아 정성스럽게 다듬고 있어요';
    return '한 권의 책으로 엮어내고 있어요';
  }

  int get _currentStep {
    if (_progress < 25) return 1;
    if (_progress < 50) return 2;
    if (_progress < 75) return 3;
    return 4;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MascotFlowTheme.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_hasError) ...[
                const AnimatedMascot(size: 132),
                const SizedBox(height: 22),
                const Text(
                  '잠깐 멈췄어요',
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: MascotFlowTheme.text,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _errorMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 14,
                    color: MascotFlowTheme.textMuted,
                    height: 1.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 32),
                FlowPrimaryButton(
                  text: '다시 시도',
                  onPressed: _startGeneration,
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => SafeNavigation.back(context, fallbackRoute: Routes.autobiography),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MascotFlowTheme.surface,
                      foregroundColor: MascotFlowTheme.text,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: const BorderSide(color: MascotFlowTheme.border),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      '취소',
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ] else ...[
                const AnimatedMascot(size: 142),
                const SizedBox(height: 20),
                Text(
                  _currentTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: MascotFlowTheme.text,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _currentDescription,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 14,
                    color: MascotFlowTheme.textMuted,
                    height: 1.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 34),
                FlowProgressPill(
                  value: _progress / 100.0,
                  label: '단계 $_currentStep / 4',
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
