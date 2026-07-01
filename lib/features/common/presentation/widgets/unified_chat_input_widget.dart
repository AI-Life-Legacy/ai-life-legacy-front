import 'package:ai_life_legacy/app/core/theme/app_theme.dart';
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
        color: AppTheme.surface,
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadow.withValues(alpha: 0.35),
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
                        color: AppTheme.textSec,
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
                          hintStyle: const TextStyle(
                              color: AppTheme.textPh, fontSize: 15),
                          filled: true,
                          fillColor: AppTheme.bgAlt,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                        ),
                        style:
                            const TextStyle(fontSize: 15, color: AppTheme.text),
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
                                  AlwaysStoppedAnimation<Color>(AppTheme.sky),
                            ),
                          )
                        : const Icon(Icons.send, color: AppTheme.sky, size: 28),
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
                      color: AppTheme.text,
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
                          color: AppTheme.textSec,
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
                                    color: const Color(0xFFFF5252)
                                        .withValues(alpha: 0.3),
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
