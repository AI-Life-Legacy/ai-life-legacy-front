import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ai_life_legacy/app/core/theme/app_theme.dart';
import 'package:ai_life_legacy/app/core/theme/app_text_styles.dart';
import 'package:ai_life_legacy/app/core/theme/widgets/app_buttons.dart';
import 'package:ai_life_legacy/app/core/theme/widgets/app_inputs.dart';
import 'package:ai_life_legacy/features/viewer/presentation/controllers/viewer_controller.dart';
import 'package:ai_life_legacy/app/core/routes/app_routes.dart';

class ViewerEntryPage extends GetView<ViewerController> {
  const ViewerEntryPage({super.key});

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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              const Text('뷰어 코드를 입력해주세요', style: AppTextStyles.h1),
              const SizedBox(height: 8),
              const Text(
                '이야기를 공유해주신 분께 받은\n6자리 코드를 입력하세요.',
                style: AppTextStyles.bodySec,
              ),
              const SizedBox(height: 40),
              AppInput(
                placeholder: '예: A3F7K2',
                autofocus: true,
                onChanged: (v) {
                  controller.viewerCode.value = v;
                },
              ),
              const SizedBox(height: 16),
              // 에러 메시지 노출
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
              const SizedBox(height: 8),
              Obx(() {
                final code = controller.viewerCode.value.trim();
                final isButtonEnabled = code.length == 6 && !controller.isLoading.value;
                return PrimaryButton(
                  text: controller.isLoading.value ? '입장 중...' : '입장하기',
                  onPressed: isButtonEnabled ? () => controller.verifyCode(code) : null,
                );
              }),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '코드가 없으신가요? ',
                    style: TextStyle(fontSize: 13, color: AppTheme.textPh),
                  ),
                  GestureDetector(
                    onTap: () => Get.offAllNamed(Routes.signup),
                    child: const Text(
                      '내 이야기 쓰기',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.text,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
