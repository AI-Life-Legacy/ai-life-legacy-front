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
  final RxBool canThinkDeeper = false.obs;
  String? _pendingPrimaryAnswer;
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
      // 1. 답변을 AI 서버에 동기화 (실패해도 조용히 진행)
      await aiRepo.sync(AiSyncRequestDto(content: answer));
    } catch (e) {
      print('[SelfIntro] AI Sync failed: $e');
    }

    // 2. 무조건 수동 트리거 버튼 노출 (사용자가 더 깊게 생각할지, 다음으로 넘길지 선택)
    canThinkDeeper.value = true;
    _scrollToBottom();
  }

  /// AI 꼬리질문 생성 (수동 트리거)
  Future<void> generateFollowUpQuestion() async {
    if (questions.isEmpty || currentQuestionIndex.value >= questions.length)
      return;
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

  Future<void> _handleFollowUpAnswer(
    QuestionDto question,
    String answer,
  ) async {
    final primary = _pendingPrimaryAnswer;
    if (primary == null) {
      await _persistAnswer(question, answer);
      _resetPendingState();
      answerPhase.value = AnswerPhase.primary;
      _moveToNextQuestion();
      return;
    }

    try {
      // 2차 답변도 AI 서버에 동기화
      await aiRepo.sync(AiSyncRequestDto(content: answer));
    } catch (e) {
      errorMessage.value = e.toString();
    }

    // 기존 로컬 저장용으로 답변 병합 (백엔드 combine 대신 프론트에서 단순 결합하여 저장)
    final combinedAnswer = "$primary\n추가 답변: $answer";
    await _persistAnswer(question, combinedAnswer);
    addMessage(combinedAnswer, isUser: false);
    _resetPendingState();
    answerPhase.value = AnswerPhase.primary;
    _moveToNextQuestion();
  }

  void _moveToNextQuestion() {
    if (questions.isEmpty) return;
    canThinkDeeper.value = false;
    _resetPendingState();

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
      print('[SelfIntroController] 작성이 완료되었습니다.');
      Get.back(); // Return to Home
      return;
    }

    // Onboarding finish
    loading.value = true;
    try {
      final fullText = _accumulatedAnswers.toString().trim();
      print(
          '[SelfIntro] Finalizing... User Answers Length: ${fullText.length}');
      // 1. 답변을 분석하여 유저 케이스를 생성
      addMessage('답변을 분석하여 유저 케이스를 생성 중입니다...', isUser: false);
      final caseResponse = await aiRepo.getCase(AiCaseRequestDto(data: fullText));
      final userCase = caseResponse.data.caseName;
      print('[SelfIntro] Determined User Case: $userCase');

      // 2. 백엔드에 자기소개 및 케이스 저장
      await userRepo.saveSelfIntro(UserIntroDto(
        userIntroText: fullText,
      ));

      // 3. 홈으로 이동
      print('[SelfIntro] Redirecting to Home...');
      Get.offAllNamed(Routes.home, arguments: {'userCase': userCase});
    } catch (e) {
      print('[SelfIntro] Error during finalization: $e');
      errorMessage.value = e.toString();
      addMessage('마무리 중 오류가 발생했습니다: $e', isUser: false);
    } finally {
      loading.value = false;
    }
  }

  void _resetPendingState() {
    _pendingPrimaryAnswer = null;
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
