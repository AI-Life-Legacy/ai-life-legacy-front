import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ai_life_legacy/app/core/theme/app_theme.dart';
import 'package:ai_life_legacy/app/core/routes/app_routes.dart';

class GeneratedPage extends StatelessWidget {
  const GeneratedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Get.offAllNamed(Routes.home),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    '완료',
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 14,
                      color: AppTheme.textSec,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
            
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
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
                      '생성이 완료되었습니다',
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.text,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '이제 가족들이 뷰어 코드를 통해 Margaret 님의 AI 아바타와 대화를 시작할 수 있습니다.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 13,
                        color: AppTheme.textSec,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Code Box
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.bgAlt,
                        border: Border.all(color: AppTheme.border),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Column(
                        children: [
                          Text(
                            '가족용 뷰어 코드',
                            style: TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPh,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'A3F7K2',
                            style: TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.cta,
                              letterSpacing: 2.4, // approx 0.1em
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Get.toNamed(Routes.viewerChat),
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
                          '대화 테스트하기',
                          style: TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
