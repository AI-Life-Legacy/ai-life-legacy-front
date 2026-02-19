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
                  final message = controller.messages[index];
                  final isUser = message.isUser;
                  
                  return Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: EdgeInsets.only(
                        left: isUser ? 60 : 0,
                        right: isUser ? 0 : 60,
                        bottom: 10,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: isUser ? const Color(0xFF4A9EFF) : Colors.grey[200],
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        message.text,
                        style: TextStyle(
                          color: isUser ? Colors.white : Colors.black87,
                          fontSize: 16,
                          height: 1.4,
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
