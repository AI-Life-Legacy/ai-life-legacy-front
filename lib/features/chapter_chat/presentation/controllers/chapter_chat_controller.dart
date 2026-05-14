import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'package:ai_life_legacy/app/core/ai/ai_repository.dart';
import 'package:ai_life_legacy/app/core/ai/models/ai.dto.dart';
import 'package:ai_life_legacy/features/autobiography/data/autobiography_repository.dart';
import 'package:ai_life_legacy/features/user/data/models/user.dto.dart';
import 'package:ai_life_legacy/features/user/data/user_repository.dart';
import 'package:ai_life_legacy/features/home/presentation/controllers/home_controller.dart';

enum AnswerPhase { primary, followUp }

class ChapterChatController extends GetxController {
  final UserRepository userRepo;
  final AutobiographyRepository postRepo;
  final AiRepository aiRepo;

  ChapterChatController(this.userRepo, this.postRepo, this.aiRepo);

  final textController = TextEditingController();
  final RxBool isRecording = false.obs;
  final RxInt recordingSeconds = 0.obs;
  Timer? recordingTimer;
  final RxBool isVoiceRecorderVisible = false.obs;

  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  final ScrollController scrollController = ScrollController();

  int? currentTocId;
  final RxList<QuestionDto> questions = <QuestionDto>[].obs;
  final RxInt currentQuestionIndex = 0.obs;
  final Rx<AnswerPhase> answerPhase = AnswerPhase.primary.obs;
  final RxBool loading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool canThinkDeeper = false.obs;
  String? _pendingPrimaryAnswer;

  /// 이전 화면(홈)으로 돌아갑니다.
  void backToHome() {
    Get.find<HomeController>().changeTab(0);
  }

  /// 특정 챕터(TOC)의 질문을 로드합니다.
  Future<void> loadQuestions(int tocId) async {
    currentTocId = tocId;
    loading.value = true;
    errorMessage.value = '';
    messages.clear();
    _resetPendingState();
    answerPhase.value = AnswerPhase.primary;
    currentQuestionIndex.value = 0;

    try {
      debugPrint('[ChapterChat] Loading questions for TOC ID: $tocId');
      final result = await postRepo.getQuestions(tocId);
      questions.assignAll(result.data
          .map((e) => QuestionDto(id: e.id, questionText: e.question)));
      
      if (questions.isNotEmpty) {
        addMessage(questions.first.questionText, isUser: false);
      } else {
        addMessage('질문을 불러올 수 없습니다.', isUser: false);
      }
    } catch (e) {
      errorMessage.value = e.toString();
      addMessage('오류 발생: $e', isUser: false);
    } finally {
      loading.value = false;
    }
  }

  Future<void> submitAnswer() async {
    final text = textController.text.trim();
    if (text.isEmpty) return;
    addMessage(text);
    clearText();
    await _handleUserAnswer(text);
  }

  Future<void> _handleUserAnswer(String answer) async {
    if (questions.isEmpty) return;
    if (currentQuestionIndex.value >= questions.length) {
      addMessage('모든 질문에 답변하셨습니다!', isUser: false);
      return;
    }

    loading.value = true;
    final currentQuestion = questions[currentQuestionIndex.value];

    try {
      if (answerPhase.value == AnswerPhase.primary) {
        await _handlePrimaryAnswer(currentQuestion, answer);
      } else {
        await _handleFollowUpAnswer(currentQuestion, answer);
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      loading.value = false;
    }
  }

  Future<void> _handlePrimaryAnswer(QuestionDto question, String answer) async {
    _pendingPrimaryAnswer = answer;
    try {
      // 1. 답변 동기화 (실패해도 조용히 진행)
      await aiRepo.sync(AiSyncRequestDto(content: answer));
    } catch (e) {
      debugPrint('[ChapterChat] AI Sync failed: $e');
    }

    // 2. 무조건 수동 트리거 버튼 노출 (사용자가 더 깊게 생각할지, 다음으로 넘길지 선택)
    canThinkDeeper.value = true;
    _scrollToBottom();
  }

  /// AI 꼬리질문 생성 (수동 트리거)
  Future<void> generateFollowUpQuestion() async {
    if (questions.isEmpty || currentQuestionIndex.value >= questions.length) {
      return;
    }
    final question = questions[currentQuestionIndex.value];
    final answer = _pendingPrimaryAnswer;
    if (answer == null) return;

    loading.value = true;
    canThinkDeeper.value = false;

    try {
      final aiResponse = await aiRepo.getQuestion(
        AiQuestionRequestDto(
          question: question.questionText,
          data: answer,
        ),
      );
      final followUp = aiResponse.data.message.trim();
      if (followUp.isEmpty) {
        await _persistAnswer(question, answer);
        _moveToNextQuestion();
        return;
      }
      answerPhase.value = AnswerPhase.followUp;
      addMessage(followUp, isUser: false);
    } catch (e) {
      errorMessage.value = e.toString();
      await _persistAnswer(question, answer);
      _moveToNextQuestion();
    } finally {
      loading.value = false;
    }
  }

  /// 꼬리질문 없이 다음으로 이동
  Future<void> skipFollowUp() async {
    final question = questions[currentQuestionIndex.value];
    final answer = _pendingPrimaryAnswer;
    if (answer != null) {
      await _persistAnswer(question, answer);
    }
    canThinkDeeper.value = false;
    _moveToNextQuestion();
  }

  Future<void> _handleFollowUpAnswer(QuestionDto question, String answer) async {
    final primary = _pendingPrimaryAnswer;
    if (primary == null) {
      await _persistAnswer(question, answer);
      _resetPendingState();
      answerPhase.value = AnswerPhase.primary;
      _moveToNextQuestion();
      return;
    }

    try {
      // 2차 답변도 동기화
      await aiRepo.sync(AiSyncRequestDto(content: answer));
    } catch (e) {
      // sync 실패해도 진행
    }

    final combinedAnswer = "$primary\n추가 답변: $answer";
    await _persistAnswer(question, combinedAnswer);
    addMessage(combinedAnswer, isUser: false);
    _resetPendingState();
    answerPhase.value = AnswerPhase.primary;
    _moveToNextQuestion();
  }

  Future<void> _persistAnswer(QuestionDto question, String answer) async {
    if (currentTocId != null) {
      await postRepo.saveAnswer(
        currentTocId!,
        question.id,
        AnswerSaveDto(answer: answer),
      );
    }
  }

  void _moveToNextQuestion() {
    if (questions.isEmpty) return;
    canThinkDeeper.value = false;
    _resetPendingState();
    if (currentQuestionIndex.value < questions.length - 1) {
      currentQuestionIndex.value++;
      addMessage(questions[currentQuestionIndex.value].questionText, isUser: false);
    } else {
      currentQuestionIndex.value = questions.length;
      addMessage('모든 질문에 답변하셨습니다!', isUser: false);
      debugPrint('[ChapterChatController] 모든 답변이 저장되었습니다.');
      // 여기서 챕터 완료 처리를 하거나 홈으로 돌아갈 수 있음
    }
  }

  void _resetPendingState() {
    _pendingPrimaryAnswer = null;
  }

  String get currentQuestionText {
    if (questions.isEmpty) return '질문을 불러오는 중...';
    if (currentQuestionIndex.value >= questions.length) return '완료되었습니다.';
    return questions[currentQuestionIndex.value].questionText;
  }

  void replayCurrentQuestion() {
    addMessage(currentQuestionText, isUser: false);
  }

  void addMessage(String text, {bool isUser = true}) {
    messages.add(ChatMessage(text, isUser: isUser));
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void toggleVoiceRecorderVisible() => isVoiceRecorderVisible.toggle();

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
    recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      recordingSeconds.value++;
    });
  }

  void stopRecording() {
    isRecording.value = false;
    recordingTimer?.cancel();
  }

  String getFormattedTime() {
    int minutes = recordingSeconds.value ~/ 60;
    int seconds = recordingSeconds.value % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void clearText() => textController.clear();

  @override
  void onClose() {
    textController.dispose();
    scrollController.dispose();
    recordingTimer?.cancel();
    super.onClose();
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  ChatMessage(this.text, {this.isUser = true});
}
