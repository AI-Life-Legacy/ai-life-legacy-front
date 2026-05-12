import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ai_life_legacy/app/core/theme/app_theme.dart';
import 'package:ai_life_legacy/app/core/theme/widgets/chat_widgets.dart';
import 'package:ai_life_legacy/app/core/theme/widgets/app_chat_input.dart';
import 'package:ai_life_legacy/features/avatar_chat/presentation/controllers/avatar_chat_controller.dart';

class AvatarChatPage extends GetView<AvatarChatController> {
  const AvatarChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: const Text('Margaret의 아바타', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => controller.generateViewerCode(),
            icon: const Icon(Icons.share_outlined, color: AppTheme.textSec),
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppTheme.border),
        ),
      ),
      body: Column(
        children: [
          // Avatar visual representation (Simplified)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: CircleAvatar(
              radius: 40,
              backgroundColor: AppTheme.bgAlt,
              child: const Icon(Icons.face, size: 40, color: AppTheme.text),
            ),
          ),
          Expanded(
            child: Obx(() => ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: controller.messages.value.length,
                  itemBuilder: (context, index) {
                    final msg = controller.messages.value[index];
                    return msg['role'] == 'ai' ? AIBubble(text: msg['text']!) : UserBubble(text: msg['text']!);
                  },
                )),
          ),
          AppChatInput(
            placeholder: '아바타에게 말을 걸어보세요...',
            onSend: (v) => controller.sendMessage(v),
          ),
        ],
      ),
    );
  }
}
