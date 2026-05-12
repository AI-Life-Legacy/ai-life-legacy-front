import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ai_life_legacy/app/core/routes/app_routes.dart';
import 'package:ai_life_legacy/app/core/theme/app_theme.dart';

class ChapterGeneratingPage extends StatefulWidget {
  const ChapterGeneratingPage({super.key});

  @override
  State<ChapterGeneratingPage> createState() => _ChapterGeneratingPageState();
}

class _ChapterGeneratingPageState extends State<ChapterGeneratingPage> {
  @override
  void initState() {
    super.initState();

    // 2~3초 정도 로딩 후 홈으로 이동
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Get.offAllNamed(Routes.home);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 56,
                height: 56,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: const BoxDecoration(
                  color: AppTheme.successBg,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: AppTheme.success,
                      strokeWidth: 3,
                    ),
                  ),
                ),
              ),
              const Text(
                '챕터를 만들고 있어요...',
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.text,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                '들려주신 이야기를 바탕으로\n당신의 삶을 챕터로 정리하고 있어요.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 15,
                  color: AppTheme.textSec,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
