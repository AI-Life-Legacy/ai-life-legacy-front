import 'package:ai_life_legacy/app/core/network/api_provider.dart';
import 'package:ai_life_legacy/app/core/network/api_endpoints.dart';
import 'package:dio/dio.dart';

class HomeApi {
  final ApiProvider _apiProvider;

  HomeApi(this._apiProvider);

  /// 목차 및 진행도 조회
  /// Endpoint: GET /users/me/toc
  Future<Response> getToc() async {
    return await _apiProvider.get(ApiEndpoints.userToc);
  }

  /// 목차 및 질문 조회
  /// Endpoint: GET /users/me/toc-questions
  Future<Response> getTocQuestions() async {
    return await _apiProvider.get('/users/me/toc-questions');
  }
}
