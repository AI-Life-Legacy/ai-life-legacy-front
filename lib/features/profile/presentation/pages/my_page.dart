import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ai_life_legacy/app/core/routes/app_routes.dart';
import 'package:ai_life_legacy/app/core/theme/app_theme.dart';
import 'package:ai_life_legacy/app/core/utils/safe_navigation.dart';
import 'package:ai_life_legacy/features/profile/presentation/controllers/my_page_controller.dart';

class MyPage extends GetView<MyPageController> {
  const MyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: const Text('마이페이지'),
        centerTitle: true,
        backgroundColor: AppTheme.bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              size: 20, color: AppTheme.text),
          onPressed: () => SafeNavigation.back(context, fallbackRoute: Routes.home),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        children: [
          _buildProfileCard(),
          const SizedBox(height: 32),
          _buildSectionTitle('알림'),
          _buildNotificationSection(),
          const SizedBox(height: 32),
          _buildSectionTitle('계정'),
          _buildAccountSection(context),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    return Obx(() {
      final name = controller.userName.value;
      final email = controller.userEmail.value;
      final initial = name.isNotEmpty ? name[0] : 'U';

      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.border, width: 2),
          boxShadow: const [
            BoxShadow(
              color: AppTheme.shadow,
              blurRadius: 0,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppTheme.cta,
                  child: Text(
                    initial,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.text,
                        ),
                      ),
                      if (email.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          email,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.textPh,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                if (controller.chapterCount.value > 0)
                  _buildBadge('${controller.chapterCount.value}개 챕터'),
                if (controller.chapterCount.value > 0 &&
                    controller.isCompleted.value)
                  const SizedBox(width: 8),
                if (controller.isCompleted.value)
                  _buildBadge('완료', isSuccess: true),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildBadge(String text, {bool isSuccess = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isSuccess ? AppTheme.successBg : const Color(0xFFE8F7FF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w900,
          color: isSuccess ? AppTheme.ctaDark : AppTheme.skyDark,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w900,
          color: AppTheme.text,
          letterSpacing: -0.2,
        ),
      ),
    );
  }

  Widget _buildNotificationSection() {
    return Column(
      children: [
        _buildMenuRow(
          label: '인터뷰 리마인더',
          showChevron: false,
          trailing: Obx(() => SizedBox(
                height: 24,
                child: Switch(
                  value: controller.isReminderEnabled.value,
                  onChanged: controller.toggleReminder,
                  activeTrackColor: AppTheme.cta,
                ),
              )),
        ),
        _buildMenuRow(
          label: '알림 시간',
          value: controller.reminderTime.value,
          onTap: () {
            // 단순 UI 상태 처리를 위해 현재는 기능 생략
          },
        ),
      ],
    );
  }

  Widget _buildAccountSection(BuildContext context) {
    return Column(
      children: [
        _buildMenuRow(
          label: '비밀번호 변경',
          onTap: () {
            Get.dialog(AlertDialog(
              backgroundColor: AppTheme.surface,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: const Text('비밀번호 변경',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              content: const Text('준비 중입니다.'),
              actions: [
                TextButton(
                    onPressed: () => SafeNavigation.closeDialog(context),
                    child:
                        const Text('확인', style: TextStyle(color: AppTheme.cta)))
              ],
            ));
          },
        ),
        _buildMenuRow(
          label: '로그아웃',
          showChevron: false,
          onTap: () => _showLogoutDialog(context),
        ),
        if (!controller.isViewerMode)
          _buildMenuRow(
            label: '계정 삭제',
            textColor: AppTheme.error,
            showChevron: false,
            onTap: () {
              controller.errorMessage.value = '';
              _showResignDialog(context);
            },
          ),
      ],
    );
  }

  Widget _buildMenuRow({
    required String label,
    String? value,
    Widget? trailing,
    Color textColor = AppTheme.text,
    bool showChevron = true,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.border, width: 2),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                ),
              ),
            ),
            if (value != null)
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSec,
                ),
              ),
            if (trailing != null) trailing,
            if (showChevron && trailing == null) ...[
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, size: 18, color: AppTheme.textPh),
            ],
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('로그아웃할까요?',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text('현재 계정에서 로그아웃됩니다.'),
        actions: [
          TextButton(
            onPressed: () => SafeNavigation.closeDialog(context),
            child: const Text('취소', style: TextStyle(color: AppTheme.textSec)),
          ),
          TextButton(
            onPressed: () {
              SafeNavigation.closeDialog(context);
              controller.logout();
            },
            child: const Text('로그아웃',
                style: TextStyle(
                    color: AppTheme.error, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void _showResignDialog(BuildContext context) {
    Get.dialog(
      Obx(() => AlertDialog(
            backgroundColor: AppTheme.surface,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('정말 탈퇴하시겠어요?',
                style: TextStyle(fontWeight: FontWeight.w700)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('탈퇴하면 계정과 작성 데이터가 삭제될 수 있습니다.'),
                if (controller.errorMessage.value.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    controller.errorMessage.value,
                    style: const TextStyle(
                      color: AppTheme.error,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: controller.isLoading.value
                    ? null
                    : () => SafeNavigation.closeDialog(context),
                child:
                    const Text('취소', style: TextStyle(color: AppTheme.textSec)),
              ),
              TextButton(
                onPressed: controller.isLoading.value
                    ? null
                    : () => controller.withdrawAccount(),
                child: controller.isLoading.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppTheme.error,
                        ),
                      )
                    : const Text('탈퇴하기',
                        style: TextStyle(
                            color: AppTheme.error,
                            fontWeight: FontWeight.w600)),
              ),
            ],
          )),
    );
  }
}
