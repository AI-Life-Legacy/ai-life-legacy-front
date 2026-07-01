import 'package:ai_life_legacy/app/core/routes/app_routes.dart';
import 'package:ai_life_legacy/app/core/theme/widgets/animated_mascot.dart';
import 'package:ai_life_legacy/app/core/theme/widgets/mascot_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CompletionPage extends StatelessWidget {
  const CompletionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MascotScaffold(
      child: Column(
        children: [
          const Spacer(),
          const AnimatedMascot(size: 160),
          const SizedBox(height: 24),
          const Text(
            '모든 기억을\n채웠어요!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: MascotFlowTheme.text,
              fontSize: 30,
              height: 1.15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            '이제 답변을 한 권의 이야기로 묶을 수 있어요.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: MascotFlowTheme.textMuted,
              fontSize: 15,
              height: 1.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 28),
          FlowOptionCard(
            icon: Icons.auto_stories_outlined,
            title: '내 인생책 만들기',
            subtitle: '완성된 답변을 바탕으로 자서전을 생성합니다.',
            selected: true,
            onTap: () => Get.toNamed(Routes.generating),
          ),
          FlowOptionCard(
            icon: Icons.home_rounded,
            title: '홈으로 돌아가기',
            subtitle: '조금 더 보고 나중에 생성할 수 있어요.',
            onTap: () => Get.offAllNamed(Routes.home),
          ),
          const Spacer(),
          FlowPrimaryButton(
            text: '책 만들기',
            onPressed: () => Get.toNamed(Routes.generating),
          ),
        ],
      ),
    );
  }
}
