import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ai_life_legacy/features/avatar_chat/presentation/controllers/avatar_chat_controller.dart';
import 'package:ai_life_legacy/features/common/presentation/widgets/unified_chat_input_widget.dart';
import 'package:ai_life_legacy/app/core/routes/app_routes.dart';

class AvatarChatPage extends GetView<AvatarChatController> {
  const AvatarChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('AI 아바타'),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.black),
            onPressed: () => Get.toNamed(Routes.myPage),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(
              () => ListView.builder(
                controller: controller.scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: controller.messages.length,
                itemBuilder: (context, index) {
                  final msg = controller.messages[index];
                  // 간단한 더미 UI: 왼쪽(시스템), 오른쪽(유저)
                  // 메시지 내용에 따라 시스템 메시지 여부 판단 (더미 로직)
                  final isSystem = msg.contains("입니다") || msg.contains("도와") || msg.contains("죄송"); 
                  
                  return Align(
                    alignment: isSystem ? Alignment.centerLeft : Alignment.centerRight,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSystem ? Colors.grey[200] : const Color(0xFF4A9EFF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        msg,
                        style: TextStyle(
                          color: isSystem ? Colors.black : Colors.white,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          UnifiedChatInputWidget(
            textController: controller.textController,
            onSubmitted: controller.sendMessage,
            onToggleVoice: controller.toggleVoiceRecorderVisible,
            onToggleRecording: controller.toggleRecording,
            isVoiceRecorderVisible: controller.isVoiceRecorderVisible,
            isRecording: controller.isRecording,
            isLoading: controller.isLoading,
            formattedTime: controller.getFormattedTime(),
          ),
        ],
      ),
    );
  }
}
