import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ai_life_legacy/app/core/ai/ai_repository.dart';
import 'package:ai_life_legacy/app/core/ai/models/ai.dto.dart';

/// 채팅 메시지 모델
class ChatMessage {
  final String text;
  final bool isUser;
  
  ChatMessage(this.text, {this.isUser = true});
}

class AvatarChatController extends GetxController {
  final TextEditingController textController = TextEditingController();
  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  final ScrollController scrollController = ScrollController();
  
  final RxBool isLoading = false.obs;
  final RxBool isVoiceRecorderVisible = false.obs;
  final RxBool isRecording = false.obs;
  final RxInt recordingSeconds = 0.obs;
  Timer? _recordingTimer;
  
  final AiRepository aiRepo;
  
  AvatarChatController(this.aiRepo);

  @override
  void onInit() {
    super.onInit();
    messages.add(ChatMessage("안녕하세요! 저는 당신의 AI 아바타입니다.", isUser: false));
    messages.add(ChatMessage("무엇을 도와드릴까요?", isUser: false));
  }

  /// 메시지 전송 (API 호출)
  /// 응답이 올 때까지 사용자는 다시 채팅을 보낼 수 없도록 isLoading으로 제어됩니다.
  Future<void> sendMessage() async {
    final text = textController.text.trim();
    if (text.isEmpty || isLoading.value) return;

    // 사용자 메시지 추가
    messages.add(ChatMessage(text, isUser: true));
    textController.clear();
    _scrollToBottom();
    
    // 로딩 시작 (입력 비활성화)
    isLoading.value = true;
    
    try {
      // API 호출
      final response = await aiRepo.sendMessage(
        AiChatRequestDto(
          message: text,
          role: "아버지", // 기본 페르소나 설정
        ),
      );
      
      // AI 응답 메시지 추가
      final aiResponse = response.data.message;
      messages.add(ChatMessage(aiResponse, isUser: false));
      _scrollToBottom();
    } catch (e) {
      // 에러 발생 시 에러 메시지 표시
      print('Avatar Chat Error: $e');
      messages.add(
        ChatMessage(
          "죄송합니다. 메시지를 처리하는 중 오류가 발생했습니다. 다시 시도해주세요.",
          isUser: false,
        ),
      );
      _scrollToBottom();
    } finally {
      // 로딩 종료 (입력 활성화)
      isLoading.value = false;
    }
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
