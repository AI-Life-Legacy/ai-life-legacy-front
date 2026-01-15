import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'package:ai_life_legacy/app/core/ai/ai_repository.dart';
import 'package:ai_life_legacy/app/core/ai/models/ai.dto.dart';
import 'package:ai_life_legacy/features/autobiography/data/autobiography_repository.dart';
// import 'package:ai_life_legacy/features/post/data/models/post.dto.dart'; // Unused
import 'package:ai_life_legacy/features/user/data/models/user.dto.dart';
import 'package:ai_life_legacy/features/user/data/user_repository.dart';
import 'package:ai_life_legacy/app/core/routes/app_routes.dart';

/// 자기소개(Onboarding) 및 질문 답변(Life Legacy) 기능을 수행하는 Controller
/// - 질문 목록 로드: 서버(TOC) 또는 로컬 기본 질문
/// - 답변 처리: 1차 답변 -> AI 꼬리질문(2차) -> 최종 답변 병합(Combine) -> 저장
enum AnswerPhase { primary, followUp }

class SelfIntroController extends GetxController {
  final UserRepository userRepo;
  final AutobiographyRepository postRepo;
  final AiRepository aiRepo;

  SelfIntroController(this.userRepo, this.postRepo, this.aiRepo);

  final textController = TextEditingController();
  final RxBool isRecording = false.obs;
  final RxInt recordingSeconds = 0.obs;
  Timer? recordingTimer;
  final RxBool isVoiceRecorderVisible = false.obs; // UI State: Voice Recorder Toggle

  // UI State: 채팅 메시지 리스트 및 스크롤 제어
  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  final ScrollController scrollController = ScrollController();

  // 현재 목차와 질문 정보
  int? currentTocId;
  // QuestionDto 모델을 사용하여 질문 데이터를 통일되게 관리
  final RxList<QuestionDto> questions = <QuestionDto>[].obs;
  final RxInt currentQuestionIndex = 0.obs;
  final Rx<AnswerPhase> answerPhase = AnswerPhase.primary.obs;
  final RxBool loading = false.obs;
  final RxString errorMessage = ''.obs;
  String? _pendingPrimaryAnswer;
  String? _pendingFollowUpQuestion;
  final StringBuffer _accumulatedAnswers = StringBuffer();

  @override
  void onInit() {
    super.onInit();
    // 이전 화면(Home)에서 전달된 tocId 인자(arguments) 확인
    final arguments = Get.arguments;
    if (arguments != null && arguments['tocId'] != null) {
      currentTocId = arguments['tocId'] as int;
    }
    loadQuestions();
  }

  /// 질문 목록 불러오기
  Future<void> loadQuestions() async {
    loading.value = true;
    errorMessage.value = '';
    messages.clear();
    _resetPendingState();
    answerPhase.value = AnswerPhase.primary;
    currentQuestionIndex.value = 0;

    try {
      if (currentTocId != null) {
        print('[SelfIntro] Loading questions for TOC ID: $currentTocId');
        // Chapter Mode: 특정 목차(Chapter)에 대한 질문 목록을 서버에서 가져옵니다.
        final result = await postRepo.getQuestions(currentTocId!);
        print('[SelfIntro] Questions fetched: ${result.data.length} items');
        // Convert to QuestionDto for compatibility if needed, or update the list type
        questions.assignAll(result.data
            .map((e) => QuestionDto(id: e.id, questionText: e.question)));
        print('[SelfIntro] Questions assigned: ${questions.length} items');
      } else {
        print('[SelfIntro] Loading default question (Onboarding Mode)');
        // Onboarding Mode: 신규 사용자를 위한 기본 자기소개 질문을 로드합니다.
        questions.assignAll([
          QuestionDto(
              id: -1,
              questionText: '안녕하세요! 당신의 인생 이야기를 듣고 싶어요. 자기소개를 자유롭게 부탁드려요.')
        ]);
      }

      if (questions.isNotEmpty) {
        addMessage(questions.first.questionText, isUser: false);
      } else {
        print('[SelfIntro] Questions list is empty!');
        addMessage('질문을 불러올 수 없습니다.', isUser: false);
      }
    } catch (e, stack) {
      print('[SelfIntro] Error loading questions: $e');
      print(stack);
      errorMessage.value = e.toString();
      addMessage('오류 발생: $e', isUser: false);
    } finally {
      loading.value = false;
    }
  }

  // ... (middle parts unchanged)

  /// 사용자가 입력한 답변을 전송하고 처리합니다.
  Future<void> submitAnswer() async {
    final text = textController.text.trim();
    if (text.isEmpty) return;

    print('[SelfIntro] User submitting answer: $text');
    addMessage(text);
    clearText();
    await _handleUserAnswer(text);
  }

  Future<void> _handleUserAnswer(String answer) async {
    if (questions.isEmpty) return;
    if (currentQuestionIndex.value >= questions.length) {
      print(
          '[SelfIntro] All questions answered (index ${currentQuestionIndex.value} >= ${questions.length})');
      addMessage('모든 질문에 답변하셨습니다!', isUser: false);
      return;
    }

    loading.value = true;
    errorMessage.value = '';
    final currentQuestion = questions[currentQuestionIndex.value];
    print(
        '[SelfIntro] Handling answer for Q${currentQuestionIndex.value} (Phase: ${answerPhase.value})');

    try {
      if (answerPhase.value == AnswerPhase.primary) {
        await _handlePrimaryAnswer(currentQuestion, answer);
      } else {
        await _handleFollowUpAnswer(currentQuestion, answer);
      }
    } catch (e) {
      print('[SelfIntro] Error handling answer: $e');
      errorMessage.value = e.toString();
    } finally {
      loading.value = false;
    }
  }

  Future<void> _handlePrimaryAnswer(
    QuestionDto question,
    String answer,
  ) async {
    _pendingPrimaryAnswer = answer;
    try {
      // 1차 답변 후, AI를 통해 2차 질문(꼬리질문)을 생성합니다.
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
      errorMessage.value = e.toString();
      // 오류 시 그냥 답변 저장하고 다음으로
      await _persistAnswer(question, answer);
      _resetPendingState();
      _moveToNextQuestion();
    }
  }

  Future<void> _handleFollowUpAnswer(
    QuestionDto question,
    String answer,
  ) async {
    final primary = _pendingPrimaryAnswer;
    final followUpQuestion = _pendingFollowUpQuestion;

    if (primary == null || followUpQuestion == null) {
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
          question2: followUpQuestion,
          data2: answer,
        ),
      );
      final combined = combineRes.data.content.trim();
      if (combined.isNotEmpty) {
        finalAnswer = combined;
      }
    } catch (e) {
      errorMessage.value = e.toString();
    }

    await _persistAnswer(question, finalAnswer);
    addMessage(finalAnswer, isUser: false);
    _resetPendingState();
    answerPhase.value = AnswerPhase.primary;
    _moveToNextQuestion();
  }

  void _moveToNextQuestion() {
    if (questions.isEmpty) return;

    if (currentQuestionIndex.value < questions.length - 1) {
      currentQuestionIndex.value++;
      addMessage(questions[currentQuestionIndex.value].questionText,
          isUser: false);
    } else {
      currentQuestionIndex.value = questions.length;
      addMessage('모든 질문에 답변하셨습니다!', isUser: false);
      _finalizeSelfIntro();
    }
  }

  Future<void> _persistAnswer(
    QuestionDto question,
    String answer,
  ) async {
    if (currentTocId != null) {
      // Chapter Mode: 답변을 서버에 저장합니다.
      await postRepo.saveAnswer(
        currentTocId!,
        question.id,
        AnswerSaveDto(answer: answer),
      );
    } else {
      // Onboarding Mode: 최종 케이스 생성을 위해 답변을 로컬에 누적합니다.
      _accumulatedAnswers.writeln("Q: ${question.questionText}");
      _accumulatedAnswers.writeln("A: $answer");
    }
  }

  // ... (middle parts unchanged)

  /// 모든 질문에 대한 답변 완료 후, 최종 데이터를 처리합니다.
  /// (Onboarding Mode의 경우 유저 케이스 생성 요청 포함)
  Future<void> _finalizeSelfIntro() async {
    if (currentTocId != null) {
      // Chapter mode finish
      Get.snackbar('완료', '작성이 완료되었습니다.');
      Get.back(); // Return to Home
      return;
    }

    // Onboarding finish
    loading.value = true;
    try {
      final fullText = _accumulatedAnswers.toString().trim();
      print(
          '[SelfIntro] Finalizing... User Answers Length: ${fullText.length}');
      addMessage('답변을 분석하여 유저 케이스를 생성 중입니다...', isUser: false);

      // 백엔드에 자기소개 저장 및 케이스 생성 요청 (반환값 없음)
      print('[SelfIntro] Saving User Intro to Backend...');
      await userRepo.saveSelfIntro(UserIntroDto(userIntroText: fullText));
      print(
          '[SelfIntro] User Intro Saved. Backend will determine UserCase internally.');

      // 3. 홈으로 이동
      print('[SelfIntro] Redirecting to Home...');
      Get.offAllNamed(Routes.home);
    } catch (e) {
      print('[SelfIntro] Error during finalization: $e');
      if (e is Error) {
        print('[SelfIntro] StackTrace: ${e.stackTrace}');
      }
      errorMessage.value = e.toString();
      addMessage('마무리 중 오류가 발생했습니다: $e', isUser: false);
    } finally {
      loading.value = false;
    }
  }

  void _resetPendingState() {
    _pendingPrimaryAnswer = null;
    _pendingFollowUpQuestion = null;
  }

  String get currentQuestionText {
    if (questions.isEmpty) {
      return errorMessage.value.isEmpty
          ? '질문을 불러오는 중입니다...'
          : '질문을 불러올 수 없습니다.';
    }
    if (currentQuestionIndex.value >= questions.length) {
      return '모든 질문에 답변하셨습니다!';
    }
    return questions[currentQuestionIndex.value].questionText;
  }

  void replayCurrentQuestion() {
    final text = currentQuestionText.trim();
    if (text.isEmpty) return;
    addMessage(text, isUser: false);
  }

  // 메시지 추가(전송 시 호출)
  void addMessage(String text, {bool isUser = true}) {
    final t = text.trim();
    if (t.isEmpty) return;
    messages.add(ChatMessage(t, isUser: isUser));
    _scrollToBottom();
  }

  // 자동 스크롤 함수
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!scrollController.hasClients) return;
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void onClose() {
    // 뒤로가기 시 홈 탭으로 복귀 logic

    textController.dispose();
    recordingTimer?.cancel();
    scrollController.dispose();
    super.onClose();
  }

  void startRecording() {
    isRecording.value = true;
    recordingSeconds.value = 0;

    recordingTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      recordingSeconds.value++;
    });
  }

  void stopRecording() {
    isRecording.value = false;
    recordingTimer?.cancel();
    recordingSeconds.value = 0;
  }

  void toggleRecording() {
    if (isRecording.value) {
      stopRecording();
    } else {
      startRecording();
    }
  }

  String getFormattedTime() {
    int minutes = recordingSeconds.value ~/ 60;
    int seconds = recordingSeconds.value % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void clearText() {
    textController.clear();
  }

  void toggleVoiceRecorderVisible() {
    isVoiceRecorderVisible.value = !isVoiceRecorderVisible.value;
  }
}

// 메시지 모델(단순): 필요하면 role 구분용
class ChatMessage {
  final String text;
  final bool isUser;
  ChatMessage(this.text, {this.isUser = true});
}
