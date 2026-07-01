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
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        backgroundColor: AppTheme.bg,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.border, width: 2),
                  boxShadow: const [
                    BoxShadow(
                        color: AppTheme.shadow,
                        blurRadius: 0,
                        offset: Offset(0, 5)),
                  ],
                ),
                child: const Row(
                  children: [
                    Icon(Icons.auto_stories, color: AppTheme.cta, size: 42),
                    SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('다시 오신 것을 환영합니다', style: AppTextStyles.h1),
                          SizedBox(height: 4),
                          Text('오늘의 기억 레슨을 이어가세요',
                              style: AppTextStyles.bodySec),
                        ],
                      ),
                    ),
                  ],
                ),
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
                child: Obx(() => AppInput(
                      placeholder: '8자 이상 입력',
                      isPassword: !controller.showPassword.value,
                      onChanged: (v) => controller.passwordController.value = v,
                      right: IconButton(
                        icon: Icon(
                          controller.showPassword.value
                              ? Icons.visibility
                              : Icons.visibility_off,
                          size: 18,
                          color: AppTheme.textSec,
                        ),
                        onPressed: controller.toggleShowPassword,
                      ),
                    )),
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
                        fontWeight: FontWeight.w700),
                  ),
                );
              }),
              Obx(() => PrimaryButton(
                    text: controller.isLoading.value ? '로그인 중...' : '로그인',
                    onPressed:
                        controller.isLoading.value ? null : controller.login,
                  )),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('계정이 없으신가요? ', style: AppTextStyles.bodySec),
                  GestureDetector(
                    onTap: () => Get.toNamed(Routes.signup),
                    child: const Text(
                      '가입하기',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.ctaDark,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Row(
                children: [
                  Expanded(child: Divider(color: AppTheme.border)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text('또는',
                        style: TextStyle(fontSize: 12, color: AppTheme.textPh)),
                  ),
                  Expanded(child: Divider(color: AppTheme.border)),
                ],
              ),
              const SizedBox(height: 24),
              SecondaryButton(
                text: 'Google로 계속하기',
                icon: Image.asset('assets/images/google_logo.png',
                    width: 18, height: 18),
                onPressed: () {},
              ),
              const SizedBox(height: 10),
              SecondaryButton(
                text: '카카오로 계속하기',
                icon: Container(
                    width: 18,
                    height: 18,
                    color: Colors.yellow), // Simplified Kakao icon
                onPressed: () {},
              ),
              const SizedBox(height: 32),
              const SizedBox(height: 10),
              InkWell(
                onTap: () => Get.toNamed(Routes.viewerEntry),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.border, width: 2),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.qr_code_2, color: AppTheme.skyDark),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '공유받은 뷰어 코드로 입장',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.text,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Icon(Icons.chevron_right, color: AppTheme.textPh),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
