import 'package:dio/dio.dart';
import 'package:ai_life_legacy/app/core/network/api_provider.dart';

class ViewerApi {
  final ApiProvider _apiProvider;

  ViewerApi(this._apiProvider);

  /// 뷰어 코드 검증
  /// Request: { code: 'A3F7K2' }
  /// Response: { valid: true, writerName: 'Margaret' }
  Future<Response> verifyCode(String code) async {
    return await _apiProvider.post('/viewer/verify', data: {'code': code});
  }

  /// 관계 설정
  /// Request: { code, role: '딸' }
  /// Response: { success: true }
  Future<Response> setRole(String code, String role) async {
    return await _apiProvider.post('/viewer/role', data: {'code': code, 'role': role});
  }

  /// 아바타 채팅 전송 (뷰어용)
  /// Request: { code, message }
  /// Response: { aiReply, audioUrl }
  Future<Response> chat({
    required String code,
    required String message,
  }) async {
    return await _apiProvider.post(
      '/viewer/chat',
      data: {
        'code': code,
        'message': message,
      },
    );
  }

  /// 아바타 음성 스트림 조회
  /// Response: (Audio Stream or URL)
  Future<Response> getAudio(String messageId) async {
    return await _apiProvider.get('/viewer/audio', queryParameters: {'messageId': messageId});
  }
}
