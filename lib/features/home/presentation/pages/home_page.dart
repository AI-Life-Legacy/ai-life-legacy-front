import 'package:ai_life_legacy/features/autobiography/presentation/pages/autobiography_list_page.dart';
import 'package:ai_life_legacy/features/home/presentation/pages/home_tab_view.dart';
import 'package:ai_life_legacy/features/onboarding/presentation/pages/self_intro_page.dart';
import 'package:ai_life_legacy/features/chapter_chat/presentation/pages/chapter_chat_page.dart';
import 'package:ai_life_legacy/features/avatar_chat/presentation/pages/avatar_chat_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ai_life_legacy/features/home/presentation/controllers/home_controller.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        final shouldClose = await controller.onBackPressed();
        if (shouldClose) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        body: Obx(() => IndexedStack(
              index: controller.selectedTabIndex.value,
              children: const [
                HomeTabView(),
                AvatarChatPage(),
                AutobiographyListPage(),
                ChapterChatPage(),
              ],
            )),
        bottomNavigationBar: _buildBottomNavigationBar(),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Obx(() {
      if (controller.selectedTabIndex.value == 3) {
        return const SizedBox.shrink();
      }
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: controller.selectedTabIndex.value,
          onTap: controller.changeTab,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF4A9EFF),
          unselectedItemColor: Colors.grey[600],
          selectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined, size: 24),
              activeIcon: Icon(Icons.home, size: 24),
              label: '홈',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.face_outlined, size: 24),
              activeIcon: Icon(Icons.face, size: 24),
              label: 'AI 아바타',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.folder_outlined, size: 24),
              activeIcon: Icon(Icons.folder, size: 24),
              label: '자서전 확인',
            ),
          ],
        ),
      );
    });
  }
}
