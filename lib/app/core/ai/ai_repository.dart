/// AI 관련 Repository 인터페이스 및 구현
library;

import 'package:ai_life_legacy/app/core/models/response.dart';
import 'package:ai_life_legacy/app/core/ai/ai_api.dart';
import 'package:ai_life_legacy/app/core/ai/models/ai.dto.dart';

abstract class AiRepository {
  /// 1. 온보딩 케이스 분류
  Future<SuccessResponse<AiCaseResponseDto>> getCase(AiCaseRequestDto dto);

  /// 2. 기억 동기화 (RAG 학습)
  Future<Success204Response> sync(AiSyncRequestDto dto);

  /// 3. 맞춤형 꼬리 질문 생성
  Future<SuccessResponse<AiQuestionResponseDto>> getQuestion(
      AiQuestionRequestDto dto);

  /// 4. 자서전 및 PDF 생성
  Future<SuccessResponse<AiAutobiographyResponseDto>> generateAutobiography();

  /// 5. 아바타 채팅
  Future<SuccessResponse<AiChatResponseDto>> sendMessage(AiChatRequestDto dto);

  /// 6. 기록 검색
  Future<SuccessResponse<AiSearchResponseDto>> search(AiSearchRequestDto dto);
}

class AiRepositoryImpl implements AiRepository {
  final AiApi api;
  AiRepositoryImpl(this.api);

  @override
  Future<SuccessResponse<AiCaseResponseDto>> getCase(AiCaseRequestDto dto) =>
      api.getCase(dto);

  @override
  Future<Success204Response> sync(AiSyncRequestDto dto) => api.sync(dto);

  @override
  Future<SuccessResponse<AiQuestionResponseDto>> getQuestion(
    AiQuestionRequestDto dto,
  ) =>
      api.getQuestion(dto);

  @override
  Future<SuccessResponse<AiAutobiographyResponseDto>> generateAutobiography() =>
      api.generateAutobiography();

  @override
  Future<SuccessResponse<AiChatResponseDto>> sendMessage(
    AiChatRequestDto dto,
  ) =>
      api.sendMessage(dto);

  @override
  Future<SuccessResponse<AiSearchResponseDto>> search(AiSearchRequestDto dto) =>
      api.search(dto);
}
