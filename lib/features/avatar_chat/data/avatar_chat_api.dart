import 'package:dio/dio.dart';
import 'package:ai_life_legacy/app/core/network/api_provider.dart';
import 'package:ai_life_legacy/app/core/network/api_endpoints.dart';

class AvatarChatApi {
  final ApiProvider _apiProvider;

  AvatarChatApi(this._apiProvider);

  /// 아바타 채팅
  /// Request: { message, role, role_id, session_id }
  Future<Response> chat(
    String message, {
    String? role,
    String? roleId,
    String? sessionId,
  }) async {
    return await _apiProvider.post(
      ApiEndpoints.aiChat,
      data: {
        'message': message,
        if (role != null) 'role': role,
        if (roleId != null) 'role_id': roleId,
        if (sessionId != null) 'session_id': sessionId,
      },
    );
  }

  /// 원문 검색
  /// Request: { query }
  Future<Response> search(String query) async {
    return await _apiProvider.post(
      ApiEndpoints.aiSearch,
      data: {
        'query': query,
      },
    );
  }

  /// 뷰어 코드 가져오기
  Future<Response> getViewerCode() async {
    return await _apiProvider.get(ApiEndpoints.viewerCode);
  }

  /// TOC 가져오기 (총 챕터수 등 확인용)
  Future<Response> getToc() async {
    return await _apiProvider.get(ApiEndpoints.userToc);
  }
}
