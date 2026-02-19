/// 아바타 채팅 관련 원격 API 호출을 담당하는 Data Source 레이어입니다.

import 'package:dio/dio.dart';
import 'package:ai_life_legacy/app/core/network/dio_client.dart';
import 'package:ai_life_legacy/app/core/network/api_endpoints.dart';
import 'package:ai_life_legacy/app/core/models/response.dart';
import 'package:ai_life_legacy/features/avatar_chat/data/models/avatar_chat.dto.dart';

class AvatarChatApi {
  // 전역 Dio 인스턴스 사용 (인터셉터 및 토큰 설정 공유)
  final Dio _dio = DioClient.instance;

  /// 아바타 채팅 메시지 전송
  /// AccessToken은 DioClient 인터셉터에서 자동으로 추가됩니다.
  Future<SuccessResponse<AvatarChatResponseDto>> sendMessage(
    AvatarChatRequestDto request,
  ) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.aiChat,
        data: request.toJson(),
      );

      return SuccessResponse<AvatarChatResponseDto>.fromJson(
        response.data,
        (json) => AvatarChatResponseDto.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      if (e.response != null) {
        print('Avatar Chat Error Status: ${e.response?.statusCode}');
        print('Avatar Chat Error Data: ${e.response?.data}');
      }
      rethrow;
    }
  }
}
