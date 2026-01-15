import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AvatarChatController extends GetxController {
  final TextEditingController textController = TextEditingController();
  final RxList<String> messages = <String>[].obs;
  final ScrollController scrollController = ScrollController();
  
  final RxBool isLoading = false.obs;
  final RxBool isVoiceRecorderVisible = false.obs;
  final RxBool isRecording = false.obs;
  final RxInt recordingSeconds = 0.obs;
  Timer? _recordingTimer;

  @override
  void onInit() {
    super.onInit();
    messages.add("안녕하세요! 저는 당신의 AI 아바타입니다.");
    messages.add("무엇을 도와드릴까요?");
  }

  void sendMessage() {
    final text = textController.text.trim();
    if (text.isEmpty) return;

    messages.add(text);
    textController.clear();
    _scrollToBottom();
    
    isLoading.value = true;
    Future.delayed(const Duration(seconds: 1), () {
      messages.add("죄송합니다. 아직 학습 중이라 대답할 수 없어요.");
      isLoading.value = false;
      _scrollToBottom();
    });
  }

  void toggleVoiceRecorderVisible() {
    isVoiceRecorderVisible.toggle();
    if (!isVoiceRecorderVisible.value) {
      if (isRecording.value) stopRecording();
    }
  }

  void toggleRecording() {
    if (isRecording.value) {
      stopRecording();
    } else {
      startRecording();
    }
  }

  void startRecording() {
    isRecording.value = true;
    recordingSeconds.value = 0;
    _recordingTimer?.cancel();
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      recordingSeconds.value++;
    });
  }

  void stopRecording() {
    isRecording.value = false;
    _recordingTimer?.cancel();
  }

  String getFormattedTime() {
    int minutes = recordingSeconds.value ~/ 60;
    int seconds = recordingSeconds.value % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void onClose() {
    textController.dispose();
    scrollController.dispose();
    _recordingTimer?.cancel();
    super.onClose();
  }
}
