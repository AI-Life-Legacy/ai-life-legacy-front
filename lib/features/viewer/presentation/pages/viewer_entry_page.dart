import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ai_life_legacy/app/core/theme/app_theme.dart';
import 'package:ai_life_legacy/app/core/theme/app_text_styles.dart';
import 'package:ai_life_legacy/app/core/theme/widgets/app_buttons.dart';
import 'package:ai_life_legacy/app/core/theme/widgets/app_inputs.dart';
import 'package:ai_life_legacy/features/viewer/presentation/controllers/viewer_controller.dart';

class ViewerEntryPage extends GetView<ViewerController> {
  const ViewerEntryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController codeController = TextEditingController();

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
              const Text('뷰어 코드를 입력하세요', style: AppTextStyles.h1),
              const SizedBox(height: 8),
              const Text('가족이나 지인으로부터 공유받은\n6자리 코드를 입력해주세요.', style: AppTextStyles.bodySec),
              const SizedBox(height: 40),
              AppInput(
                placeholder: '예: A3F7K2',
                autofocus: true,
                onChanged: (v) => codeController.text = v,
              ),
              const SizedBox(height: 24),
              Obx(() => PrimaryButton(
                    text: controller.isLoading.value ? '검증 중...' : '입장하기',
                    onPressed: controller.isLoading.value ? null : () => controller.verifyCode(codeController.text),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
