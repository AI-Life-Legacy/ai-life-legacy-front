/// 자서전(In-Depth Questions) 데이터 관리 Repository
/// AutobiographyApi를 통해 질문 목록을 가져오고 답변을 저장합니다.

import 'package:ai_life_legacy/features/autobiography/data/autobiography_api.dart';
import 'package:ai_life_legacy/app/core/models/response.dart';

import 'package:ai_life_legacy/features/user/data/models/user.dto.dart';

abstract class AutobiographyRepository {
  Future<SuccessResponse<List<TocQuestionDto>>> getQuestions(int tocId);
  Future<SuccessResponse<void>> saveAnswer(
      int tocId, int questionId, AnswerSaveDto dto);
}

class AutobiographyRepositoryImpl implements AutobiographyRepository {
  final AutobiographyApi api;
  AutobiographyRepositoryImpl(this.api);

  @override
  Future<SuccessResponse<List<TocQuestionDto>>> getQuestions(int tocId) async {
    final response = await api.getQuestions(tocId);
    return SuccessResponse.fromJson(
      response.data,
      (json) => (json as List).map((e) => TocQuestionDto.fromJson(e)).toList(),
    );
  }

  @override
  Future<SuccessResponse<void>> saveAnswer(
    int tocId,
    int questionId,
    AnswerSaveDto dto,
  ) async {
    final response = await api.saveAnswer(tocId, questionId, dto);
    return SuccessResponse.fromJson(
      response.data,
      (json) => null,
    );
  }
}
