import 'package:ai_life_legacy/app/core/network/api_provider.dart';
import 'package:ai_life_legacy/app/core/network/api_endpoints.dart';
import 'package:dio/dio.dart';

class OnboardingApi {
  final ApiProvider _apiProvider;

  OnboardingApi(this._apiProvider);

  /// 자기소개 저장
  /// Request: { userIntroText }
  Future<Response> saveIntro(String text) async {
    return await _apiProvider.post(
      ApiEndpoints.userIntro,
      data: {
        'userIntroText': text,
      },
    );
  }

  /// 유저 케이스 분류
  /// Request: { data: "자기소개 텍스트" }
  Future<Response> generateCase(String text) async {
    return await _apiProvider.post(
      ApiEndpoints.aiCase,
      data: {
        'data': text,
      },
    );
  }

  /// 기억 동기화
  /// Request: { content: "텍스트 내용" }
  Future<Response> syncMemory(String content) async {
    return await _apiProvider.post(
      '/api/sync',
      data: {
        'content': content,
      },
    );
  }
}
