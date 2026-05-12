import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ai_life_legacy/features/autobiography/data/autobiography_api.dart';
import 'package:ai_life_legacy/features/user/data/models/user.dto.dart';
import 'package:ai_life_legacy/app/core/routes/app_routes.dart';

String _formatTime(DateTime dt) {
  final hour = dt.hour;
  final minute = dt.minute.toString().padLeft(2, '0');
  final period = hour < 12 ? '오전' : '오후';
  final h12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
  return '$period $h12:$minute';
}

enum ChatStep {
  answeringFixedQuestion,
  waitingFollowUpChoice,
  generatingFollowUp,
  answeringFollowUp,
}

class AutobiographyController extends GetxController {
  final AutobiographyApi _api;

  AutobiographyController(this._api);

  final questions = RxList<Map<String, dynamic>>([]);
  final currentQuestionIndex = 0.obs;
  final messages = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;
  final isGenerating = false.obs;
  final isGeneratingFollowUp = false.obs;
  final isSavingAnswer = false.obs;
  
  final currentTocId = 0.obs;
  
  // New state variables
  final chatStep = ChatStep.answeringFixedQuestion.obs;
  final lastFixedAnswer = ''.obs;
  final lastFollowUpAnswer = ''.obs;
  final currentFollowUpQuestion = ''.obs;
  
  final scrollController = ScrollController();
  
  bool _closed = false;

  @override
  void onClose() {
    _closed = true;
    scrollController.dispose();
    super.onClose();
  }

  void scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // Getters for current question
  String get currentQuestionText {
    if (questions.isEmpty || currentQuestionIndex.value >= questions.length) return '';
    final q = questions[currentQuestionIndex.value];
    return q['questionText']?.toString() ?? '';
  }

  int? get currentQuestionId {
    if (questions.isEmpty || currentQuestionIndex.value >= questions.length) return null;
    final q = questions[currentQuestionIndex.value];
    final id = q['id'];
    if (id is int) return id;
    if (id is String) return int.tryParse(id);
    return null;
  }

  Future<void> fetchQuestions(int tocId) async {
    currentTocId.value = tocId;
    try {
      isLoading.value = true;
      final response = await _api.getQuestions(tocId);
      final raw = response.data;
      
      final result = raw is Map<String, dynamic> ? raw['result'] : raw;

      if (result is List) {
        questions.assignAll(
          result
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList(),
        );
        currentQuestionIndex.value = 0;
        _resetChatState();

        // Add initial question to messages if empty
        if (questions.isNotEmpty && messages.isEmpty) {
          messages.add({
            'role': 'ai',
            'text': currentQuestionText,
            'type': 'fixedQuestion',
            'time': _formatTime(DateTime.now()),
          });
          messages.refresh();
        }
      } else {
        questions.clear();
      }
    } catch (e) {
      print('[AutobiographyController] fetchQuestions error: $e');
      messages.add({
        'role': 'ai',
        'text': '질문을 불러오지 못했습니다. 다시 시도해주세요.',
        'time': _formatTime(DateTime.now()),
      });
    } finally {
      isLoading.value = false;
    }
  }

  void _resetChatState() {
    messages.clear();
    lastFixedAnswer.value = '';
    lastFollowUpAnswer.value = '';
    currentFollowUpQuestion.value = '';
    chatStep.value = ChatStep.answeringFixedQuestion;
    isGeneratingFollowUp.value = false;
    isSavingAnswer.value = false;
    messages.refresh();
  }

  void removeTemporaryMessages() {
    messages.removeWhere((msg) => 
      msg['type'] == 'followUpChoice' || 
      msg['type'] == 'loading'
    );
    messages.refresh();
  }

  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    if (chatStep.value == ChatStep.answeringFixedQuestion) {
      messages.add({
        'role': 'user',
        'text': trimmed,
        'type': 'fixedAnswer',
        'time': _formatTime(DateTime.now()),
      });
      lastFixedAnswer.value = trimmed;
      
      chatStep.value = ChatStep.waitingFollowUpChoice;
      
      removeTemporaryMessages();
      
      messages.add({
        'role': 'system',
        'text': '이 답변에 대해 추가 질문을 해볼까요?',
        'type': 'followUpChoice',
        'time': _formatTime(DateTime.now()),
      });
      
      messages.refresh();
      scrollToBottom();
      return;
    }

    if (chatStep.value == ChatStep.answeringFollowUp) {
      messages.add({
        'role': 'user',
        'text': trimmed,
        'type': 'followUpAnswer',
        'time': _formatTime(DateTime.now()),
      });
      lastFollowUpAnswer.value = trimmed;
      messages.refresh();
      scrollToBottom();

      await completeCurrentQuestionAndMoveNext();
      return;
    }
  }

  Future<void> generateFollowUpQuestion() async {
    if (chatStep.value != ChatStep.waitingFollowUpChoice) return;
    if (isGeneratingFollowUp.value) return;
    if (lastFixedAnswer.value.trim().isEmpty) return;

    try {
      isGeneratingFollowUp.value = true;
      chatStep.value = ChatStep.generatingFollowUp;

      removeTemporaryMessages();

      messages.add({
        'role': 'ai',
        'text': '추가 질문을 만들고 있어요...',
        'type': 'loading',
        'time': _formatTime(DateTime.now()),
      });
      messages.refresh();
      scrollToBottom();

      final response = await _api.generateQuestion(
        question: currentQuestionText,
        answer: lastFixedAnswer.value,
      );

      messages.removeWhere((msg) => msg['type'] == 'loading');

      final raw = response.data;
      final result = raw is Map<String, dynamic> ? raw['result'] : null;
      
      final followUpQuestion = result is Map<String, dynamic>
          ? result['question']?.toString()
          : null;

      if (_closed) return;

      if (followUpQuestion != null && followUpQuestion.trim().isNotEmpty) {
        currentFollowUpQuestion.value = followUpQuestion;
        
        messages.add({
          'role': 'ai',
          'text': followUpQuestion,
          'time': _formatTime(DateTime.now()),
          'type': 'followUp',
        });
        
        chatStep.value = ChatStep.answeringFollowUp;
        scrollToBottom();
      } else {
        messages.add({
          'role': 'ai',
          'text': '추가 질문을 생성하지 못했어요. 다음 질문으로 넘어갈게요.',
          'type': 'system',
          'time': _formatTime(DateTime.now()),
        });
        await completeCurrentQuestionAndMoveNext();
      }
      messages.refresh();
    } catch (e) {
      print('[AutobiographyController] generateFollowUpQuestion error: $e');
      if (!_closed) {
        messages.removeWhere((msg) => msg['type'] == 'loading');
        messages.add({
          'role': 'ai',
          'text': '추가 질문 생성 중 문제가 발생했어요. 다음 질문으로 넘어갈게요.',
          'type': 'system',
          'time': _formatTime(DateTime.now()),
        });
        messages.refresh();
        await completeCurrentQuestionAndMoveNext();
      }
    } finally {
      if (!_closed) {
        isGeneratingFollowUp.value = false;
      }
    }
  }

  Future<void> skipFollowUpAndMoveNext() async {
    if (chatStep.value != ChatStep.waitingFollowUpChoice) return;
    if (isSavingAnswer.value) return;

    removeTemporaryMessages();
    await completeCurrentQuestionAndMoveNext();
  }

  Future<void> completeCurrentQuestionAndMoveNext() async {
    if (isSavingAnswer.value) return;

    try {
      isSavingAnswer.value = true;

      removeTemporaryMessages();

      final questionId = currentQuestionId;
      final tocId = currentTocId.value;
      
      final hasFollowUp = currentFollowUpQuestion.value.trim().isNotEmpty &&
          lastFollowUpAnswer.value.trim().isNotEmpty;

      final answer = hasFollowUp
          ? '${lastFixedAnswer.value.trim()}\n\n'
            '추가 질문: ${currentFollowUpQuestion.value.trim()}\n\n'
            '추가 답변: ${lastFollowUpAnswer.value.trim()}'
          : lastFixedAnswer.value.trim();

      if (questionId != null && tocId != 0) {
        try {
          await _api.saveAnswer(tocId, questionId, AnswerSaveDto(answer: answer));
          
          messages.add({
            'role': 'ai',
            'text': '저장했어요. 다음 질문으로 넘어갈게요.',
            'type': 'saved',
            'time': _formatTime(DateTime.now()),
          });
        } catch (e) {
          print('[AutobiographyController] saveAnswer error: $e');
          messages.add({
            'role': 'ai',
            'text': '저장 중 문제가 발생했어요. 그래도 다음으로 진행할게요.',
            'type': 'system',
            'time': _formatTime(DateTime.now()),
          });
        }
      }

      final isLastQuestion = currentQuestionIndex.value >= questions.length - 1;

      if (!isLastQuestion) {
        currentQuestionIndex.value++;
        
        lastFixedAnswer.value = '';
        lastFollowUpAnswer.value = '';
        currentFollowUpQuestion.value = '';

        chatStep.value = ChatStep.answeringFixedQuestion;
        isGeneratingFollowUp.value = false;
        isSavingAnswer.value = false;

        messages.add({
          'role': 'ai',
          'text': currentQuestionText,
          'type': 'fixedQuestion',
          'time': _formatTime(DateTime.now()),
        });

        messages.refresh();
        scrollToBottom();
        return;
      }

      print('[AutobiographyController] Chapter completed. Moving to chapter complete page.');
      
      try {
        final tocResponse = await _api.getToc();
        final raw = tocResponse.data;
        final result = raw is Map<String, dynamic> ? raw['result'] : raw;
        
        String chapterTitle = '';
        final chaptersList = result?['chapters'];
        if (chaptersList is List) {
          for (var ch in chaptersList) {
            if (ch['tocId'] == tocId) {
              chapterTitle = ch['title']?.toString() ?? '';
              break;
            }
          }
        }

        Get.offNamed(
          Routes.chapterComplete,
          arguments: {
            'tocId': tocId,
            'title': chapterTitle,
            'chapterNumber': tocId,
            'questionCount': questions.length,
            'answeredCount': questions.length,
            'totalChapters': result?['totalChapters'],
            'completedChapters': result?['completedChapters'],
            'chapters': chaptersList,
          },
        );
      } catch (e) {
        print('[AutobiographyController] Failed to fetch TOC for complete page: $e');
        Get.offNamed(Routes.home);
      }
    } finally {
      isSavingAnswer.value = false;
    }
  }

  Future<void> generateFullBook() async {
    try {
      isGenerating.value = true;
      Get.toNamed(Routes.generating);
      
      final response = await _api.generateAutobiography();
      if (response.statusCode == 200 || response.statusCode == 201) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('avatarUnlocked', true);
        Get.offNamed(Routes.generated);
      } else {
        throw Exception('Server returned status: ${response.statusCode}');
      }
    } catch (e) {
      Get.back(); // Back from loading
      Get.snackbar(
        '생성 실패',
        '자서전 생성에 실패했습니다. 다시 시도해주세요.',
        snackPosition: SnackPosition.BOTTOM,
      );
      print('[AutobiographyController] generateFullBook error: $e');
    } finally {
      isGenerating.value = false;
    }
  }
}
