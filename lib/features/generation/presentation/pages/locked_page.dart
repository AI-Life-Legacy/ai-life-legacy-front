import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ai_life_legacy/app/core/theme/app_theme.dart';
import 'package:ai_life_legacy/app/core/routes/app_routes.dart';

class LockedPage extends StatelessWidget {
  const LockedPage({super.key});

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
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () => Get.back(),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    '닫기',
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

            // Top Profile Info
            Padding(
              padding: const EdgeInsets.only(top: 48),
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                      color: AppTheme.bgAlt,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        'U',
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.text,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '사용자',
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.text,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: AppTheme.textPh,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        '잠김',
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 12,
                          color: AppTheme.textPh,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: Container(
                width: double.infinity,
                color: Colors.white,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.lock_outline,
                        size: 48, color: AppTheme.border),
                    const SizedBox(height: 24),
                    const Text(
                      '자서전을 완성하면\n아바타 대화가 열려요.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.text,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '먼저 자서전을 만들어주세요.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 14,
                        color: AppTheme.textSec,
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: 220,
                      child: ElevatedButton(
                        onPressed: () => Get.offNamed(Routes.autobiography),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.cta,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          '자서전 작성하러 가기',
                          style: TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
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
