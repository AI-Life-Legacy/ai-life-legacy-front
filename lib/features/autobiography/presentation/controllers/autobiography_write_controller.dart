import 'package:get/get.dart';
import 'package:ai_life_legacy/features/autobiography/data/autobiography_api.dart';

class AutobiographyWriteController extends GetxController {
  final AutobiographyApi _api;

  AutobiographyWriteController(this._api);

  final tocId = 0.obs;
  final questionId = 0.obs;
  final questionText = ''.obs;
  final answerId = RxnInt();
  final answerText = ''.obs;
  final isLoading = false.obs;
  final isSaving = false.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    
    if (Get.arguments != null) {
      tocId.value = Get.arguments['tocId'] ?? 0;
      questionId.value = Get.arguments['questionId'] ?? 0;
      questionText.value = Get.arguments['questionText'] ?? '';
    }
    
    fetchAnswer();
  }

  Future<void> fetchAnswer() async {
    if (tocId.value == 0 || questionId.value == 0) return;

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _api.getAnswer(
        tocId: tocId.value,
        questionId: questionId.value,
      );

      final raw = response.data;
      print('[AutobiographyWriteController] getAnswer raw: $raw');

      final result = raw is Map<String, dynamic> ? raw['result'] ?? raw : raw;

      if (result is Map) {
        final resultMap = Map<String, dynamic>.from(result);
        answerId.value = (resultMap['answerId'] ?? resultMap['id']) as int?;
        answerText.value = (resultMap['answer'] ??
            resultMap['answerText'] ??
            resultMap['content'] ??
            '').toString();
      } else {
        answerText.value = '';
      }
    } catch (e) {
      print('[AutobiographyWriteController] fetchAnswer error: $e');
      errorMessage.value = '답변을 불러오지 못했어요.';
      answerText.value = '';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> save() async {
    if (answerId.value == null) {
      errorMessage.value = '수정할 답변 정보가 없습니다.';
      return;
    }

    try {
      isSaving.value = true;
      errorMessage.value = '';

      await _api.updateAnswer(
        answerId: answerId.value!,
        tocId: tocId.value,
        questionId: questionId.value,
        updateAnswer: answerText.value,
      );

      Get.back(result: true);
    } catch (e) {
      print('[AutobiographyWriteController] save error: $e');
      errorMessage.value = '답변 저장에 실패했어요.';
      isSaving.value = false;
    }
  }
}

class ParsedAnswer {
  final String mainAnswer;
  final String? followUpQuestion;
  final String? followUpAnswer;

  ParsedAnswer({
    required this.mainAnswer,
    this.followUpQuestion,
    this.followUpAnswer,
  });
}

ParsedAnswer parseAnswerText(String text) {
  const followQuestionMarker = '추가 질문:';
  const followAnswerMarker = '추가 답변:';

  if (!text.contains(followQuestionMarker) ||
      !text.contains(followAnswerMarker)) {
    return ParsedAnswer(mainAnswer: text);
  }

  final qIndex = text.indexOf(followQuestionMarker);
  final aIndex = text.indexOf(followAnswerMarker);

  final main = text.substring(0, qIndex).trim();
  final fq = text.substring(
    qIndex + followQuestionMarker.length,
    aIndex,
  ).trim();
  final fa = text.substring(
    aIndex + followAnswerMarker.length,
  ).trim();

  return ParsedAnswer(
    mainAnswer: main,
    followUpQuestion: fq,
    followUpAnswer: fa,
  );
}
