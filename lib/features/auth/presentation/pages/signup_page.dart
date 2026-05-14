import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ai_life_legacy/app/core/theme/app_theme.dart';
import 'package:ai_life_legacy/app/core/theme/app_text_styles.dart';
import 'package:ai_life_legacy/app/core/theme/widgets/app_buttons.dart';
import 'package:ai_life_legacy/app/core/theme/widgets/app_inputs.dart';
import 'package:ai_life_legacy/app/core/network/api_provider.dart';
import 'package:ai_life_legacy/features/auth/data/auth_api.dart';
import 'package:ai_life_legacy/features/auth/presentation/controllers/auth_controller.dart';
import 'package:ai_life_legacy/app/core/routes/app_routes.dart';

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
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 28),
              const Text('계정을 만들어보세요', style: AppTextStyles.h1),
              const SizedBox(height: 6),
              const Text('1분이면 충분합니다.', style: AppTextStyles.bodySec),
              const SizedBox(height: 32),
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
              InputField(
                label: '비밀번호 확인',
                child: const AppInput(
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
                    style: const TextStyle(color: Colors.red, fontSize: 13),
                  ),
                );
              }),
              Obx(() => PrimaryButton(
                    text: controller.isLoading.value ? '가입 중...' : '계정 만들기',
                    onPressed: controller.isLoading.value ? null : controller.signUp,
                  )),
              const SizedBox(height: 12),
              const Text(
                '가입하면 이용약관과 개인정보처리방침에 동의하게 됩니다.',
                textAlign: TextAlign.center,
                style: AppTextStyles.caption,
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('이미 계정이 있나요? ', style: AppTextStyles.bodySec),
                  GestureDetector(
                    onTap: () => Get.toNamed(Routes.login),
                    child: const Text(
                      '로그인',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.text,
                        fontWeight: FontWeight.w500,
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
