import 'package:ai_life_legacy/app/core/network/api_provider.dart';
import 'package:ai_life_legacy/app/core/routes/app_routes.dart';
import 'package:ai_life_legacy/app/core/theme/app_theme.dart';
import 'package:ai_life_legacy/app/core/theme/app_text_styles.dart';
import 'package:ai_life_legacy/app/core/theme/widgets/animated_mascot.dart';
import 'package:ai_life_legacy/app/core/theme/widgets/app_buttons.dart';
import 'package:ai_life_legacy/app/core/theme/widgets/app_inputs.dart';
import 'package:ai_life_legacy/app/core/utils/safe_navigation.dart';
import 'package:ai_life_legacy/features/auth/data/auth_api.dart';
import 'package:ai_life_legacy/features/auth/presentation/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignUpPage extends GetView<AuthController> {
  const SignUpPage({super.key});

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
              const _SignUpHeader(),
              const SizedBox(height: 28),
              InputField(
                label: '이메일',
                child: AppInput(
                  placeholder: 'you@email.com',
                  type: TextInputType.emailAddress,
                  onChanged: (v) => controller.emailController.value = v,
                ),
              ),
              const SizedBox(height: 14),
              InputField(
                label: '비밀번호',
                child: AppInput(
                  placeholder: '8자 이상',
                  isPassword: true,
                  onChanged: (v) => controller.passwordController.value = v,
                ),
              ),
              const SizedBox(height: 14),
              const InputField(
                label: '비밀번호 확인',
                child: AppInput(
                  placeholder: '다시 입력해주세요',
                  isPassword: true,
                ),
              ),
              const SizedBox(height: 28),
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
                  text: controller.isLoading.value ? '가입 중...' : '계정 만들기',
                  onPressed:
                      controller.isLoading.value ? null : controller.signUp,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                '가입하면 서비스 이용약관과 개인정보 처리방침에 동의하게 됩니다.',
                textAlign: TextAlign.center,
                style: AppTextStyles.caption,
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '이미 계정이 있나요? ',
                    style: TextStyle(
                      color: AppTheme.textSec,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Get.toNamed(Routes.login),
                    child: const Text(
                      '로그인',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.ctaDark,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SignUpHeader extends StatelessWidget {
  const _SignUpHeader();

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
              const AnimatedMascot(size: 82, mood: MascotMood.thinking),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  '첫 기록을 시작해볼까요?',
                  style: TextStyle(
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
              Container(width: 46, height: 14, color: AppTheme.coral),
              const SizedBox(width: 8),
              Container(width: 20, height: 20, color: AppTheme.cta),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            '계정을 만들고 바로 자기소개와 목차 생성으로 이어집니다.',
            style: TextStyle(
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
