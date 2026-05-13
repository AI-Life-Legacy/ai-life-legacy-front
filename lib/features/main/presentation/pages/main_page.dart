import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ai_life_legacy/app/core/theme/app_theme.dart';
import 'package:ai_life_legacy/app/core/theme/app_text_styles.dart';
import 'package:ai_life_legacy/app/core/theme/widgets/app_buttons.dart';
import 'package:ai_life_legacy/app/core/routes/app_routes.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: Column(
          children: [
            // Status bar spacer or custom status bar can be added here
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Life Legacy',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.text,
                      letterSpacing: -0.2,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Get.toNamed(Routes.login),
                    child: const Text(
                      '로그인',
                      style: TextStyle(fontSize: 14, color: AppTheme.textSec),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppTheme.bgAlt,
                        border: Border.all(color: AppTheme.border),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.book_outlined, size: 28, color: AppTheme.text),
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      '당신의 이야기,\n영원히 간직하세요.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.display,
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'AI와 대화하며 당신의 삶을\n한 권의 책으로 남겨보세요.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: AppTheme.textSec,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              child: Column(
                children: [
                  PrimaryButton(
                    text: '내 자서전 쓰기 시작하기',
                    onPressed: () => Get.toNamed(Routes.signup),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        '이미 계정이 있으신가요? ',
                        style: TextStyle(fontSize: 13, color: AppTheme.textPh),
                      ),
                      GestureDetector(
                        onTap: () => Get.toNamed(Routes.login),
                        child: const Text(
                          '로그인',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.text,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(color: AppTheme.border, height: 1),
                  const SizedBox(height: 20),
                  const Text(
                    '이야기를 공유받으셨나요?',
                    style: TextStyle(fontSize: 13, color: AppTheme.textSec),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () => Get.toNamed(Routes.viewerEntry),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: AppTheme.bgAlt,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: const Center(
                        child: Text(
                          '뷰어 코드로 입장',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.text,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
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
