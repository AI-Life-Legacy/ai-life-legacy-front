import 'package:ai_life_legacy/app/core/routes/app_routes.dart';
import 'package:ai_life_legacy/app/core/theme/app_theme.dart';
import 'package:ai_life_legacy/app/core/theme/widgets/animated_mascot.dart';
import 'package:ai_life_legacy/app/core/theme/widgets/app_buttons.dart';
import 'package:ai_life_legacy/app/core/theme/widgets/app_inputs.dart';
import 'package:ai_life_legacy/app/core/utils/safe_navigation.dart';
import 'package:ai_life_legacy/features/viewer/presentation/controllers/viewer_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ViewerEntryPage extends GetView<ViewerController> {
  const ViewerEntryPage({super.key});

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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 28),
              const _ViewerHeader(),
              const SizedBox(height: 32),
              AppInput(
                placeholder: '예: A3F7K2',
                autofocus: true,
                onChanged: (v) {
                  controller.viewerCode.value = v;
                },
              ),
              const SizedBox(height: 16),
              Obx(() {
                if (controller.errorMessage.value.isEmpty) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    controller.errorMessage.value,
                    style: const TextStyle(color: AppTheme.error, fontSize: 13),
                  ),
                );
              }),
              const SizedBox(height: 8),
              Obx(() {
                final code = controller.viewerCode.value.trim();
                final isButtonEnabled =
                    code.length == 6 && !controller.isLoading.value;
                return PrimaryButton(
                  text: controller.isLoading.value ? '입장 중...' : '입장하기',
                  onPressed: isButtonEnabled
                      ? () => controller.verifyCode(code)
                      : null,
                );
              }),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '코드가 없나요? ',
                    style: TextStyle(fontSize: 13, color: AppTheme.textPh),
                  ),
                  GestureDetector(
                    onTap: () => Get.offAllNamed(Routes.signup),
                    child: const Text(
                      '내 기록 시작하기',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.text,
                        fontWeight: FontWeight.w800,
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

class _ViewerHeader extends StatelessWidget {
  const _ViewerHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.text,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const AnimatedMascot(size: 92, mood: MascotMood.sad),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  '공유 코드로\n기록에 입장하세요',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    height: 1.12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(width: 46, height: 14, color: AppTheme.sky),
              const SizedBox(width: 8),
              Container(width: 20, height: 20, color: AppTheme.lavender),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            '전달받은 6자리 코드를 입력하면 읽기와 대화 화면으로 이동합니다.',
            style: TextStyle(
              color: Colors.white70,
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
