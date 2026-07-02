/// 사용자(User) 데이터 관리 Repository 인터페이스
/// API 호출을 추상화하여 비즈니스 로직에 제공합니다.
library;

import 'package:ai_life_legacy/features/user/data/user_api.dart';
import 'package:ai_life_legacy/features/user/data/models/user.dto.dart';
import 'package:ai_life_legacy/app/core/models/response.dart';

abstract class UserRepository {
  Future<SuccessResponse<void>> saveSelfIntro(UserIntroDto dto);
  Future<SuccessResponse<List<UserTocDto>>> getUserToc();
  Future<SuccessResponse<List<UserTocQuestionDto>>> getUserTocQuestions();
  Future<SuccessResponse<UserAnswerDto>> getUserAnswers(
      {int? questionId, int? tocId});
  Future<SuccessResponse<void>> updateAnswer(int answerId, AnswerUpdateDto dto);
  Future<SuccessResponse<void>> deleteUser(UserWithdrawalDto dto);
}

class UserRepositoryImpl implements UserRepository {
  final UserApi api;
  UserRepositoryImpl(this.api);

  @override
  Future<SuccessResponse<void>> saveSelfIntro(UserIntroDto dto) =>
      api.saveSelfIntro(dto);

  @override
  Future<SuccessResponse<List<UserTocDto>>> getUserToc() => api.getUserToc();

  @override
  Future<SuccessResponse<List<UserTocQuestionDto>>> getUserTocQuestions() =>
      api.getUserTocQuestions();

  @override
  Future<SuccessResponse<UserAnswerDto>> getUserAnswers({
    int? questionId,
    int? tocId,
  }) =>
      api.getUserAnswers(questionId: questionId, tocId: tocId);

  @override
  Future<SuccessResponse<void>> updateAnswer(
    int answerId,
    AnswerUpdateDto dto,
  ) =>
      api.updateAnswer(answerId, dto);

  @override
  Future<SuccessResponse<void>> deleteUser(UserWithdrawalDto dto) =>
      api.deleteUser(dto);
}
