/// 사용자(User) 관련 API 호출을 담당하는 클래스
/// - 자기소개 저장, 목차 조회, 답변 조회/수정, 회원탈퇴 등

import 'package:dio/dio.dart';
import 'package:ai_life_legacy/app/core/network/dio_client.dart';
import 'package:ai_life_legacy/app/core/network/api_endpoints.dart';
import 'package:ai_life_legacy/app/core/models/response.dart';
import 'package:ai_life_legacy/features/user/data/models/user.dto.dart';

class UserApi {
  final Dio _dio = DioClient.instance;

  /// 유저 자기소개 저장 (User Case 생성을 위해 백엔드로 전송)
  Future<SuccessResponse<void>> saveSelfIntro(UserIntroDto dto) async {
    final response = await _dio.post(
      ApiEndpoints.userIntro,
      data: dto.toJson(),
    );
    return SuccessResponse<void>.fromJson(
      response.data,
      (_) {},
    );
  }

  /// 유저 맞춤형 목차(TOC) 목록 조회
  Future<SuccessResponse<List<UserTocDto>>> getUserToc() async {
    final response = await _dio.get(ApiEndpoints.userToc);
    return SuccessResponse<List<UserTocDto>>.fromJson(
      response.data,
      (json) => (json as List<dynamic>)
          .map((item) => UserTocDto.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  /// 유저 맞춤형 목차 및 하위 질문 전체 조회
  Future<SuccessResponse<List<UserTocQuestionDto>>>
      getUserTocQuestions() async {
    final response = await _dio.get(ApiEndpoints.userTocQuestions);
    return SuccessResponse<List<UserTocQuestionDto>>.fromJson(
      response.data,
      (json) => (json as List<dynamic>)
          .map((item) =>
              UserTocQuestionDto.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  /// 사용자가 작성한 답변 조회 (질문 ID 또는 목차 ID 기준)
  Future<SuccessResponse<UserAnswerDto>> getUserAnswers({
    int? questionId,
    int? tocId,
  }) async {
    final response = await _dio.get(
      ApiEndpoints.userAnswers,
      queryParameters: {
        if (questionId != null) 'questionId': questionId,
        if (tocId != null) 'tocId': tocId,
      },
    );
    return SuccessResponse<UserAnswerDto>.fromJson(
      response.data,
      (json) {
        if (json == null || json is String) {
          throw DioException(
            requestOptions: RequestOptions(path: ApiEndpoints.userAnswers),
            response: Response(
              requestOptions: RequestOptions(path: ApiEndpoints.userAnswers),
              statusCode: 404,
              statusMessage: 'Not Found',
            ),
            type: DioExceptionType.badResponse,
          );
        }
        return UserAnswerDto.fromJson(json as Map<String, dynamic>);
      },
    );
  }

  /// 기존 답변 수정 (자서전 업데이트)
  Future<SuccessResponse<void>> updateAnswer(
    int answerId,
    AnswerUpdateDto dto,
  ) async {
    print('[UserApi] updateAnswer payload: ${dto.toJson()}');
    final response = await _dio.patch(
      ApiEndpoints.userAnswerUpdate(answerId),
      data: dto.toJson(),
    );
    print('[UserApi] updateAnswer response: ${response.statusCode}');
    return SuccessResponse<void>.fromJson(
      response.data,
      (_) {},
    );
  }

  /// 회원 탈퇴 요청
  Future<SuccessResponse<void>> deleteUser(UserWithdrawalDto dto) async {
    final response = await _dio.delete(
      ApiEndpoints.deleteUser,
      data: dto.toJson(),
    );
    return SuccessResponse<void>.fromJson(
      response.data,
      (_) {},
    );
  }
}
