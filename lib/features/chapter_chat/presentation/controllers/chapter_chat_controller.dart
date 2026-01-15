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
  String? _pendingPrimaryAnswer;
  String? _pendingFollowUpQuestion;

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
      print('[ChapterChat] Loading questions for TOC ID: $tocId');
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
      final aiResponse = await aiRepo.makeReQuestion(
        MakeReQuestionDto(
          question: question.questionText,
          data: answer,
        ),
      );
      final followUp = aiResponse.data.content.trim();
      if (followUp.isEmpty) {
        await _persistAnswer(question, answer);
        _resetPendingState();
        _moveToNextQuestion();
        return;
      }
      _pendingFollowUpQuestion = followUp;
      answerPhase.value = AnswerPhase.followUp;
      addMessage(followUp, isUser: false);
    } catch (e) {
      // 오류 시 1차 답변만 저장하고 진행
      await _persistAnswer(question, answer);
      _resetPendingState();
      _moveToNextQuestion();
    }
  }

  Future<void> _handleFollowUpAnswer(QuestionDto question, String answer) async {
    final primary = _pendingPrimaryAnswer;
    final followUp = _pendingFollowUpQuestion;
    
    if (primary == null || followUp == null) {
      await _persistAnswer(question, answer);
      _resetPendingState();
      answerPhase.value = AnswerPhase.primary;
      _moveToNextQuestion();
      return;
    }

    String finalAnswer = answer;
    try {
      final combineRes = await aiRepo.combine(
        CombineDto(
          question1: question.questionText,
          data1: primary,
          question2: followUp,
          data2: answer,
        ),
      );
      if (combineRes.data.content.trim().isNotEmpty) {
        finalAnswer = combineRes.data.content.trim();
      }
    } catch (e) {
      // combine 실패 시 사용자 답변 그대로 사용
    }

    await _persistAnswer(question, finalAnswer);
    addMessage(finalAnswer, isUser: false); // 합쳐진 답변이나 최종 답변을 보여줄지 여부는 기획에 따름. 여기선 일단 보여줌.
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
    if (currentQuestionIndex.value < questions.length - 1) {
      currentQuestionIndex.value++;
      addMessage(questions[currentQuestionIndex.value].questionText, isUser: false);
    } else {
      currentQuestionIndex.value = questions.length;
      addMessage('모든 질문에 답변하셨습니다!', isUser: false);
      Get.snackbar('완료', '모든 답변이 저장되었습니다.');
      // 여기서 챕터 완료 처리를 하거나 홈으로 돌아갈 수 있음
    }
  }

  void _resetPendingState() {
    _pendingPrimaryAnswer = null;
    _pendingFollowUpQuestion = null;
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
