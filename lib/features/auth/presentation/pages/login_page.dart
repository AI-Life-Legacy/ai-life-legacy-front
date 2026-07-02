import 'package:ai_life_legacy/app/core/network/api_provider.dart';
import 'package:ai_life_legacy/app/core/routes/app_routes.dart';
import 'package:ai_life_legacy/app/core/theme/app_theme.dart';
import 'package:ai_life_legacy/app/core/theme/widgets/animated_mascot.dart';
import 'package:ai_life_legacy/app/core/theme/widgets/app_buttons.dart';
import 'package:ai_life_legacy/app/core/theme/widgets/app_inputs.dart';
import 'package:ai_life_legacy/app/core/utils/safe_navigation.dart';
import 'package:ai_life_legacy/features/auth/data/auth_api.dart';
import 'package:ai_life_legacy/features/auth/presentation/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginPage extends GetView<AuthController> {
  const LoginPage({super.key});

  @override
  AuthController get controller {
    if (Get.isRegistered<AuthController>()) {
      return Get.find<AuthController>();
    }

    final api = Get.isRegistered<AuthApi>()
        ? Get.find<AuthApi>()
        : Get.put(AuthApi(Get.find<ApiProvider>()));

    return Get.put(AuthController(api));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => SafeNavigation.back(context, fallbackRoute: Routes.main),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _AuthHeader(
                title: '다시 이어서 기록하기',
                subtitle: '계정에 로그인하고 남겨둔 질문으로 돌아가세요.',
                color: AppTheme.sky,
              ),
              const SizedBox(height: 30),
              InputField(
                label: '이메일',
                child: AppInput(
                  placeholder: 'you@email.com',
                  type: TextInputType.emailAddress,
                  onChanged: (v) => controller.emailController.value = v,
                ),
              ),
              const SizedBox(height: 16),
              InputField(
                label: '비밀번호',
                child: Obx(
                  () => AppInput(
                    placeholder: '8자 이상 입력',
                    isPassword: !controller.showPassword.value,
                    onChanged: (v) => controller.passwordController.value = v,
                    right: IconButton(
                      icon: Icon(
                        controller.showPassword.value
                            ? Icons.visibility_rounded
                            : Icons.visibility_off_rounded,
                        size: 18,
                        color: AppTheme.textSec,
                      ),
                      onPressed: controller.toggleShowPassword,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Obx(() {
                if (controller.errorMessage.value.isEmpty) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    controller.errorMessage.value,
                    style: const TextStyle(
                      color: AppTheme.error,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                );
              }),
              Obx(
                () => PrimaryButton(
                  text: controller.isLoading.value ? '로그인 중...' : '로그인',
                  onPressed:
                      controller.isLoading.value ? null : controller.login,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '계정이 없나요? ',
                    style: TextStyle(
                      color: AppTheme.textSec,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Get.toNamed(Routes.signup),
                    child: const Text(
                      '가입하기',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.ctaDark,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              _ViewerEntryLink(onTap: () => Get.toNamed(Routes.viewerEntry)),
            ],
          ),
        ),
      ),
    );
  }
}

class _AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;

  const _AuthHeader({
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.text),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const AnimatedMascot(size: 82, mood: MascotMood.listening),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AppTheme.text,
                    fontSize: 24,
                    height: 1.15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(width: 46, height: 14, color: color),
              const SizedBox(width: 8),
              Container(width: 20, height: 20, color: AppTheme.sun),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
              color: AppTheme.textSec,
              fontSize: 14,
              height: 1.45,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ViewerEntryLink extends StatelessWidget {
  final VoidCallback onTap;

  const _ViewerEntryLink({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.border),
        ),
        child: const Row(
          children: [
            Icon(Icons.qr_code_2_rounded, color: AppTheme.skyDark),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                '공유받은 코드로 입장',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.text,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: AppTheme.textPh),
          ],
        ),
      ),
    );
  }
}
