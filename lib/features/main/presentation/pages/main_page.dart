import 'package:ai_life_legacy/app/core/routes/app_routes.dart';
import 'package:ai_life_legacy/app/core/theme/widgets/animated_mascot.dart';
import 'package:ai_life_legacy/app/core/theme/widgets/mascot_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MascotScaffold(
      bottom: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FlowPrimaryButton(
              text: '오늘의 기억 시작하기',
              onPressed: () => Get.toNamed(Routes.signup),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () => Get.toNamed(Routes.login),
                  child: const Text(
                    '로그인',
                    style: TextStyle(
                      color: MascotFlowTheme.textMuted,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Container(
                  width: 1,
                  height: 14,
                  color: MascotFlowTheme.border,
                ),
                TextButton(
                  onPressed: () => Get.toNamed(Routes.viewerEntry),
                  child: const Text(
                    '뷰어 코드 입력',
                    style: TextStyle(
                      color: MascotFlowTheme.textMuted,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 10),
          Row(
            children: [
              const Text(
                'Life Legacy',
                style: TextStyle(
                  color: MascotFlowTheme.text,
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Get.toNamed(Routes.login),
                icon: const Icon(
                  Icons.person_outline,
                  color: MascotFlowTheme.textMuted,
                ),
              ),
            ],
          ),
          const Spacer(),
          const Center(child: AnimatedMascot(size: 188)),
          const SizedBox(height: 30),
          const Text(
            '질문 하나씩,\n내 인생책이 열려요',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: MascotFlowTheme.text,
              fontSize: 30,
              height: 1.18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            '길게 쓰지 않아도 괜찮아요.\n오늘의 기억만 짧게 남기면 됩니다.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: MascotFlowTheme.textMuted,
              fontSize: 15,
              height: 1.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 34),
          FlowOptionCard(
            icon: Icons.chat_bubble_outline,
            title: '마스코트가 질문을 던져요',
            subtitle: '대답하면 다음 기억으로 자연스럽게 이어집니다.',
            selected: true,
            onTap: () => Get.toNamed(Routes.signup),
          ),
          FlowOptionCard(
            icon: Icons.auto_stories_outlined,
            title: '챕터가 하나씩 완성돼요',
            subtitle: '진행 경로를 따라 내 이야기가 책처럼 쌓입니다.',
            onTap: () => Get.toNamed(Routes.signup),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
