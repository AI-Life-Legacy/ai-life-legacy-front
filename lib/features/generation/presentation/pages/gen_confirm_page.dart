import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ai_life_legacy/app/core/theme/app_theme.dart';

class GenConfirmPage extends StatelessWidget {
  const GenConfirmPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: Stack(
        children: [
          // Background UI mock
          Opacity(
            opacity: 0.2,
            child: IgnorePointer(
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Container(height: 40, decoration: BoxDecoration(color: AppTheme.bgAlt, borderRadius: BorderRadius.circular(10)), margin: const EdgeInsets.only(bottom: 12)),
                      ...List.generate(5, (index) => Container(
                        height: 52,
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(border: Border.all(color: AppTheme.border), borderRadius: BorderRadius.circular(10)),
                      )),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // Dark overlay
          Container(color: Colors.black.withOpacity(0.3)),
          
          // Bottom Sheet
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 36, height: 4, decoration: BoxDecoration(color: AppTheme.border, borderRadius: BorderRadius.circular(2)), margin: const EdgeInsets.only(bottom: 16)),
                    const Icon(Icons.bookmark_added, size: 36, color: AppTheme.text),
                    const SizedBox(height: 12),
                    const Text(
                      '자서전을 완성하셨습니다',
                      style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.text),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'AI 아바타를 생성하면 가족들이 내 기억을 더 생생하게 만나볼 수 있습니다. 생성하시겠습니까?',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, color: AppTheme.textSec, height: 1.5),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Get.toNamed('/generating'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.cta,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 0,
                        ),
                        child: const Text('아바타 생성하기', style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 15, fontWeight: FontWeight.w500)),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Get.back(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.bgAlt,
                          foregroundColor: AppTheme.text,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: const BorderSide(color: AppTheme.border)),
                          elevation: 0,
                        ),
                        child: const Text('다음에 하기', style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 15, fontWeight: FontWeight.w500)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
