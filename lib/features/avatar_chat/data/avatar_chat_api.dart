import 'package:dio/dio.dart';
import 'package:ai_life_legacy/app/core/network/api_provider.dart';
import 'package:ai_life_legacy/app/core/network/api_endpoints.dart';

class AvatarChatApi {
  final ApiProvider _apiProvider;

  AvatarChatApi(this._apiProvider);

  /// 아바타 채팅
  /// Request: { message, role }
  Future<Response> chat(String message, {String? role}) async {
    return await _apiProvider.post(
      ApiEndpoints.aiChat,
      data: {
        'message': message,
        if (role != null) 'role': role,
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
}
