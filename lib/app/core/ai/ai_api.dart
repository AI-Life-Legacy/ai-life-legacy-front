/// AI 관련 API 호출 클래스
library;

import 'package:dio/dio.dart';
import 'package:ai_life_legacy/app/core/network/dio_client.dart';
import 'package:ai_life_legacy/app/core/network/api_endpoints.dart';
import 'package:ai_life_legacy/app/core/models/response.dart';
import 'package:ai_life_legacy/app/core/ai/models/ai.dto.dart';

class AiApi {
  final Dio _dio = DioClient.instance;

  /// 1. 온보딩 케이스 분류
  Future<SuccessResponse<AiCaseResponseDto>> getCase(
      AiCaseRequestDto dto) async {
    final response = await _dio.post(
      ApiEndpoints.aiCase,
      data: dto.toJson(),
    );

    return SuccessResponse<AiCaseResponseDto>.fromJson(
      response.data,
      (json) => AiCaseResponseDto.fromJson(json as Map<String, dynamic>),
    );
  }

  /// 2. 기억 동기화 (RAG 학습)
  Future<Success204Response> sync(AiSyncRequestDto dto) async {
    final response = await _dio.post(
      ApiEndpoints.aiSync,
      data: dto.toJson(),
    );

    return Success204Response.fromJson(response.data);
  }

  /// 3. 맞춤형 꼬리 질문 생성
  Future<SuccessResponse<AiQuestionResponseDto>> getQuestion(
    AiQuestionRequestDto dto,
  ) async {
    final response = await _dio.post(
      ApiEndpoints.aiQuestion,
      data: dto.toJson(),
    );

    return SuccessResponse<AiQuestionResponseDto>.fromJson(
      response.data,
      (json) => AiQuestionResponseDto.fromJson(json as Map<String, dynamic>),
    );
  }

  /// 4. 자서전 및 PDF 생성
  Future<SuccessResponse<AiAutobiographyResponseDto>>
      generateAutobiography() async {
    final response = await _dio.post(
      ApiEndpoints.aiAutobiography,
      options: Options(
        receiveTimeout:
            const Duration(minutes: 5), // LLM 처리에 시간이 오래 걸리므로 5분으로 연장
        sendTimeout: const Duration(minutes: 5),
      ),
    );

    return SuccessResponse<AiAutobiographyResponseDto>.fromJson(
      response.data,
      (json) =>
          AiAutobiographyResponseDto.fromJson(json as Map<String, dynamic>),
    );
  }

  /// 5. 아바타 채팅
  Future<SuccessResponse<AiChatResponseDto>> sendMessage(
    AiChatRequestDto dto,
  ) async {
    final response = await _dio.post(
      ApiEndpoints.aiChat,
      data: dto.toJson(),
    );

    return SuccessResponse<AiChatResponseDto>.fromJson(
      response.data,
      (json) => AiChatResponseDto.fromJson(json as Map<String, dynamic>),
    );
  }

  /// 6. 기록 검색
  Future<SuccessResponse<AiSearchResponseDto>> search(
    AiSearchRequestDto dto,
  ) async {
    final response = await _dio.post(
      ApiEndpoints.aiSearch,
      data: dto.toJson(),
    );

    return SuccessResponse<AiSearchResponseDto>.fromJson(
      response.data,
      (json) => AiSearchResponseDto.fromJson(json as Map<String, dynamic>),
    );
  }
}
