import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UnifiedChatInputWidget extends StatelessWidget {
  final TextEditingController textController;
  final VoidCallback onSubmitted;
  final VoidCallback onToggleVoice;
  final VoidCallback onToggleRecording;
  final RxBool isVoiceRecorderVisible;
  final RxBool isRecording;
  final RxBool isLoading;
  final String formattedTime;

  const UnifiedChatInputWidget({
    super.key,
    required this.textController,
    required this.onSubmitted,
    required this.onToggleVoice,
    required this.onToggleRecording,
    required this.isVoiceRecorderVisible,
    required this.isRecording,
    required this.isLoading,
    required this.formattedTime,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(
              children: [
                Obx(() => IconButton(
                      icon: Icon(
                        isVoiceRecorderVisible.value ? Icons.close : Icons.add,
                        color: Colors.grey[600],
                        size: 28,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: onToggleVoice,
                    )),
                const SizedBox(width: 12),
                Expanded(
                  child: Obx(() => TextField(
                        controller: textController,
                        enabled: !isLoading.value,
                        decoration: InputDecoration(
                          hintText: '메시지를 입력하세요...',
                          hintStyle: TextStyle(color: Colors.grey[500], fontSize: 15),
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                        ),
                        style: const TextStyle(fontSize: 15),
                        maxLines: 1,
                        onSubmitted: (_) => onSubmitted(),
                      )),
                ),
                const SizedBox(width: 8),
                Obx(() {
                  final isProcessing = isLoading.value;
                  return IconButton(
                    icon: isProcessing
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Color(0xFF4A9EFF)),
                            ),
                          )
                        : const Icon(Icons.send, color: Color(0xFF4A9EFF), size: 28),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: isProcessing ? null : onSubmitted,
                  );
                }),
              ],
            ),
          ),
          Obx(() {
            if (!isVoiceRecorderVisible.value) {
              return const SizedBox.shrink();
            }
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                  const Text(
                    '음성인식',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        formattedTime,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(width: 24),
                      GestureDetector(
                        onTap: onToggleRecording,
                        child: Obx(() => Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF5252),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFF5252).withOpacity(0.3),
                                blurRadius: 12,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Icon(
                            isRecording.value ? Icons.stop : Icons.mic,
                            color: Colors.white,
                            size: 32,
                          ),
                        )),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
