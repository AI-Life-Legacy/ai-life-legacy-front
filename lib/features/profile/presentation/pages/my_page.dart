import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ai_life_legacy/app/core/theme/app_theme.dart';
import 'package:ai_life_legacy/app/core/routes/app_routes.dart';
import 'package:ai_life_legacy/features/profile/presentation/controllers/my_page_controller.dart';

class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  bool notify = true;

  Widget _buildRow({required String label, required Widget right, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: const BoxDecoration(
          color: AppTheme.bg,
          border: Border(bottom: BorderSide(color: AppTheme.border)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 15,
                color: AppTheme.text,
              ),
            ),
            right,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppTheme.border))),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: const Icon(Icons.arrow_back, size: 20, color: AppTheme.text),
                  ),
                  const Expanded(
                    child: Text(
                      '설정',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 15, fontWeight: FontWeight.w500, color: AppTheme.text),
                    ),
                  ),
                  const SizedBox(width: 20),
                ],
              ),
            ),

            // Content
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  // Profile Summary
                  Container(
                    decoration: const BoxDecoration(
                      color: AppTheme.bgAlt,
                      border: Border(bottom: BorderSide(color: AppTheme.border)),
                    ),
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                    child: Column(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: const BoxDecoration(
                            color: AppTheme.textPh,
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Text(
                              'MT',
                              style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Margaret Thompson',
                          style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.text),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'margaret.t@example.com',
                          style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: AppTheme.textSec),
                        ),
                      ],
                    ),
                  ),

                  // Progress
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                    child: Text('진행 상황', style: AppTheme.sectionLabel),
                  ),
                  Container(
                    decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppTheme.border))),
                    child: Column(
                      children: [
                        _buildRow(
                          label: '내 자서전 다운로드',
                          right: const Icon(Icons.download, size: 16, color: AppTheme.textSec),
                          onTap: () {},
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: const BoxDecoration(color: AppTheme.bg, border: Border(bottom: BorderSide(color: AppTheme.border))),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('데이터 공유 허용', style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 15, color: AppTheme.text)),
                              Text('완료 ✓', style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 14, color: AppTheme.textSec)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Notifications
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                    child: Text('알림', style: AppTheme.sectionLabel),
                  ),
                  Container(
                    decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppTheme.border))),
                    child: Column(
                      children: [
                        _buildRow(
                          label: '인터뷰 리마인더',
                          right: Switch(
                            value: notify,
                            onChanged: (val) => setState(() => notify = val),
                            activeColor: Colors.white,
                            activeTrackColor: AppTheme.success,
                          ),
                        ),
                        _buildRow(
                          label: '알림 시간',
                          right: const Row(
                            children: [
                              Text('오전 9:00', style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 14, color: AppTheme.textSec)),
                              SizedBox(width: 6),
                              Icon(Icons.chevron_right, size: 16, color: AppTheme.textPh),
                            ],
                          ),
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),

                  // Account
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                    child: Text('계정', style: AppTheme.sectionLabel),
                  ),
                  Container(
                    decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppTheme.border))),
                    child: Column(
                      children: [
                        _buildRow(
                          label: '비밀번호 변경',
                          right: const Icon(Icons.chevron_right, size: 16, color: AppTheme.textPh),
                          onTap: () {},
                        ),
                        _buildRow(
                          label: '로그아웃',
                          right: const SizedBox.shrink(),
                          onTap: () => Get.offAllNamed(Routes.main),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),
                  Center(
                    child: GestureDetector(
                      onTap: () {},
                      child: const Text(
                        '계정 삭제',
                        style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 15, color: AppTheme.error),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
