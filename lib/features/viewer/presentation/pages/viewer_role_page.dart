import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ai_life_legacy/app/core/theme/app_theme.dart';
import 'package:ai_life_legacy/app/core/utils/token_storage.dart';

class ViewerRolePage extends StatefulWidget {
  const ViewerRolePage({super.key});

  @override
  State<ViewerRolePage> createState() => _ViewerRolePageState();
}

class _ViewerRolePageState extends State<ViewerRolePage> {
  String _selectedRole = '';
  final List<String> _roles = ['아들', '딸', '배우자', '손주', '친구', '기타'];

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
                child: IconButton(
                  icon: const Icon(Icons.arrow_back,
                      color: AppTheme.text, size: 20),
                  onPressed: () => Get.back(),
                ),
              ),
            ),

            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '환영합니다',
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.text,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '원활한 대화를 위해 ${TokenStorage.getViewerAuthorName() ?? '작성자'} 님과의 관계를 선택해주세요. 아바타가 당신을 맞춤형으로 부르고 대화할 수 있습니다.',
                      style: const TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 13,
                        color: AppTheme.textSec,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 32),
                    Expanded(
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 2.5,
                        ),
                        itemCount: _roles.length,
                        itemBuilder: (context, index) {
                          final r = _roles[index];
                          final isSelected = _selectedRole == r;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedRole = r),
                            child: Container(
                              decoration: BoxDecoration(
                                color:
                                    isSelected ? AppTheme.bgAlt : AppTheme.bg,
                                border: Border.all(
                                    color: isSelected
                                        ? AppTheme.cta
                                        : AppTheme.border),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                r,
                                style: TextStyle(
                                  fontFamily: AppTheme.fontFamily,
                                  fontSize: 15,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? AppTheme.text
                                      : AppTheme.textSec,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // Bottom CTA
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _selectedRole.isEmpty
                            ? null
                            : () => Get.toNamed('/viewer_chat'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _selectedRole.isEmpty
                              ? AppTheme.border
                              : AppTheme.cta,
                          foregroundColor: _selectedRole.isEmpty
                              ? AppTheme.textPh
                              : Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          '대화 시작하기',
                          style: TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
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
