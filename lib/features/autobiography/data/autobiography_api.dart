import 'package:ai_life_legacy/features/user/data/models/user.dto.dart';
import 'package:dio/dio.dart';
import 'package:ai_life_legacy/app/core/network/api_provider.dart';
import 'package:ai_life_legacy/app/core/network/api_endpoints.dart';

class AutobiographyApi {
  final ApiProvider _apiProvider;

  AutobiographyApi(this._apiProvider);

  /// 특정 목차(카테고리)에 해당하는 질문 목록을 가져옵니다.
  /// Endpoint: GET /life-legacy/toc/:tocId/questions
  Future<Response> getQuestions(int tocId) async {
    return await _apiProvider.get('/life-legacy/toc/$tocId/questions');
  }

  /// 전체 목차 및 진행률 조회
  /// Endpoint: GET /users/me/toc
  Future<Response> getToc() async {
    return await _apiProvider.get('/users/me/toc');
  }

  /// 목차 및 질문 전체 조회
  /// Endpoint: GET /users/me/toc-questions
  Future<Response> getTocQuestions() async {
    return await _apiProvider.get('/users/me/toc-questions');
  }

  /// 각 질문에 대한 최종 완성된 자서전 문구를 저장합니다.
  /// Endpoint: POST /life-legacy/toc/:tocId/questions/:questionId/answers
  /// Request Body: { "answer": "..." }
  Future<Response> saveAnswer(
      int tocId, int questionId, AnswerSaveDto dto) async {
    return await _apiProvider.post(
      '/life-legacy/toc/$tocId/questions/$questionId/answers',
      data: dto.toJson(),
    );
  }

  /// 꼬리 질문 생성
  /// Request: { "question": "1차 질문 내용", "data": "유저의 1차 답변" }
  Future<Response> generateQuestion({
    required String question,
    required String answer,
  }) async {
    return await _apiProvider.post(
      ApiEndpoints.aiQuestion,
      data: {
        'question': question,
        'data': answer,
      },
    );
  }

  /// 답변 합치기 (Combine)
  /// Request: { question1, data1, question2, data2 }
  Future<Response> combineAnswers({
    required String q1,
    required String a1,
    required String q2,
    required String a2,
  }) async {
    return await _apiProvider.post(
      '/api/combine',
      data: {
        'question1': q1,
        'data1': a1,
        'question2': q2,
        'data2': a2,
      },
    );
  }

  /// 자서전 생성 및 PDF 발행
  Future<Response> generateAutobiography({bool force = false}) async {
    return await _apiProvider.post(
      ApiEndpoints.aiAutobiography,
      queryParameters: force ? {'force': 'true'} : null,
      options: Options(receiveTimeout: const Duration(minutes: 6)),
    );
  }

  /// 자서전 최종 생성 상태 및 결과 조회
  Future<Response> getAutobiographyStatus() async {
    return await _apiProvider.get('/api/autobiography/status');
  }

  /// 답변 조회
  /// Query: ?questionId=...&tocId=...
  Future<Response> getAnswer(
      {required int questionId, required int tocId}) async {
    return await _apiProvider.get(
      '/users/me/answers',
      queryParameters: {
        'questionId': questionId,
        'tocId': tocId,
      },
    );
  }

  /// 답변 수정
  /// Endpoint: PATCH /users/me/answers/:answerId
  /// Request: { updateAnswer, tocId, questionId }
  Future<Response> updateAnswer({
    required int answerId,
    required int tocId,
    required int questionId,
    required String updateAnswer,
  }) async {
    return await _apiProvider.patch(
      '/users/me/answers/$answerId',
      data: {
        'updateAnswer': updateAnswer,
        'tocId': tocId,
        'questionId': questionId,
      },
    );
  }

  /// 가족 공유 코드 발급
  /// Endpoint: POST /life-legacy/share
  Future<Response> createShareCode() async {
    return await _apiProvider.post('/life-legacy/share');
  }
}
