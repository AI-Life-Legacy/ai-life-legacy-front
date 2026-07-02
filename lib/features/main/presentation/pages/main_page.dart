import 'package:ai_life_legacy/app/core/routes/app_routes.dart';
import 'package:ai_life_legacy/app/core/theme/app_theme.dart';
import 'package:ai_life_legacy/app/core/theme/widgets/animated_mascot.dart';
import 'package:ai_life_legacy/app/core/theme/widgets/mascot_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MascotScaffold(
      padding: EdgeInsets.zero,
      bottom: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FlowPrimaryButton(
              text: '내 기록 시작하기',
              onPressed: () => Get.toNamed(Routes.signup),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.toNamed(Routes.login),
                    child: const Text('로그인'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.toNamed(Routes.viewerEntry),
                    child: const Text('공유 코드 입력'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        children: [
          Row(
            children: [
              Container(width: 32, height: 10, color: AppTheme.coral),
              const SizedBox(width: 8),
              Container(width: 18, height: 18, color: AppTheme.sun),
              const Spacer(),
              IconButton(
                tooltip: '로그인',
                onPressed: () => Get.toNamed(Routes.login),
                icon: const Icon(Icons.person_outline_rounded),
              ),
            ],
          ),
          const SizedBox(height: 36),
          const Text(
            'Life Legacy',
            style: TextStyle(
              color: AppTheme.text,
              fontSize: 48,
              height: 0.95,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '질문을 따라가며 기억을 정리하고, 완성된 기록은 책처럼 보관합니다.',
            style: TextStyle(
              color: AppTheme.textSec,
              fontSize: 16,
              height: 1.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 30),
          Container(
            height: 240,
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.text, width: 1.4),
            ),
            child: Stack(
              children: const [
                Positioned(
                  left: 18,
                  top: 18,
                  child: _ColorTile(color: AppTheme.sky, width: 88, height: 88),
                ),
                Positioned(
                  left: 118,
                  top: 18,
                  child: _ColorTile(color: AppTheme.cta, width: 128, height: 54),
                ),
                Positioned(
                  right: 18,
                  top: 18,
                  child:
                      _ColorTile(color: AppTheme.coral, width: 68, height: 130),
                ),
                Positioned(
                  left: 30,
                  bottom: 22,
                  child: _ColorTile(color: AppTheme.sun, width: 150, height: 74),
                ),
                Positioned(
                  right: 92,
                  bottom: 22,
                  child:
                      _ColorTile(color: AppTheme.lavender, width: 74, height: 74),
                ),
                Positioned(
                  right: 20,
                  bottom: 20,
                  child: AnimatedMascot(size: 92, mood: MascotMood.thinking),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          FlowOptionCard(
            icon: Icons.route_rounded,
            title: '짧은 자기소개로 구조 만들기',
            subtitle: '앱이 목차를 만들고, 이후 질문 화면으로 자연스럽게 이어집니다.',
            selected: true,
            onTap: () => Get.toNamed(Routes.signup),
          ),
          FlowOptionCard(
            icon: Icons.forum_outlined,
            title: '질문 단위로 기록하기',
            subtitle: '한 번에 긴 글을 쓰지 않고 장면별 답변을 쌓습니다.',
            onTap: () => Get.toNamed(Routes.signup),
          ),
          FlowOptionCard(
            icon: Icons.ios_share_rounded,
            title: '가족에게 공유하기',
            subtitle: '완성 후 공유 코드로 읽기와 대화를 이어갈 수 있습니다.',
            onTap: () => Get.toNamed(Routes.viewerEntry),
          ),
        ],
      ),
    );
  }
}

class _ColorTile extends StatelessWidget {
  final Color color;
  final double width;
  final double height;

  const _ColorTile({
    required this.color,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
