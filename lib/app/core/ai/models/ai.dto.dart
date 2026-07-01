/// AI 관련 요청/응답 DTO 정의
library;

/// 유저 케이스 분류 요청 DTO
class AiCaseRequestDto {
  final String data;

  AiCaseRequestDto({required this.data});

  factory AiCaseRequestDto.fromJson(Map<String, dynamic> json) =>
      AiCaseRequestDto(data: json['data'] as String);

  Map<String, dynamic> toJson() => {'data': data};
}

/// 유저 케이스 분류 응답 DTO
class AiCaseResponseDto {
  final String caseName;

  AiCaseResponseDto({required this.caseName});

  factory AiCaseResponseDto.fromJson(dynamic json) {
    if (json is String) return AiCaseResponseDto(caseName: json);
    if (json is Map<String, dynamic>) {
      final c = json['case'] ?? json['result'] ?? json['data'] ?? 'case1';
      return AiCaseResponseDto(caseName: c.toString());
    }
    return AiCaseResponseDto(caseName: 'case1');
  }

  Map<String, dynamic> toJson() => {'case': caseName};
}

/// 기억 동기화 요청 DTO
class AiSyncRequestDto {
  final String content;

  AiSyncRequestDto({required this.content});

  factory AiSyncRequestDto.fromJson(Map<String, dynamic> json) =>
      AiSyncRequestDto(content: json['content'] as String);

  Map<String, dynamic> toJson() => {'content': content};
}

/// 꼬리 질문 생성 요청 DTO
class AiQuestionRequestDto {
  final String question;
  final String data;

  AiQuestionRequestDto({required this.question, required this.data});

  factory AiQuestionRequestDto.fromJson(Map<String, dynamic> json) =>
      AiQuestionRequestDto(
        question: json['question'] as String,
        data: json['data'] as String,
      );

  Map<String, dynamic> toJson() => {'question': question, 'data': data};
}

/// 꼬리 질문 생성 응답 DTO
class AiQuestionResponseDto {
  final String message;

  AiQuestionResponseDto({required this.message});

  factory AiQuestionResponseDto.fromJson(Map<String, dynamic> json) =>
      AiQuestionResponseDto(message: json['message'] as String);

  Map<String, dynamic> toJson() => {'message': message};
}

/// 자서전 생성 응답 DTO
class AiAutobiographyResponseDto {
  final String markdown;
  final String pdfPath;

  AiAutobiographyResponseDto({required this.markdown, required this.pdfPath});

  factory AiAutobiographyResponseDto.fromJson(Map<String, dynamic> json) =>
      AiAutobiographyResponseDto(
        markdown: (json['markdown'] ?? '') as String,
        pdfPath: (json['pdfPath'] ?? '') as String,
      );

  Map<String, dynamic> toJson() => {'markdown': markdown, 'pdfPath': pdfPath};
}

/// 아바타 채팅 요청 DTO
class AiChatRequestDto {
  final String message;
  final String role;

  AiChatRequestDto({required this.message, required this.role});

  factory AiChatRequestDto.fromJson(Map<String, dynamic> json) =>
      AiChatRequestDto(
        message: json['message'] as String,
        role: json['role'] as String,
      );

  Map<String, dynamic> toJson() => {'message': message, 'role': role};
}

/// 아바타 채팅 응답 DTO
class AiChatResponseDto {
  final String message;

  AiChatResponseDto({required this.message});

  factory AiChatResponseDto.fromJson(Map<String, dynamic> json) =>
      AiChatResponseDto(message: json['message'] as String);

  Map<String, dynamic> toJson() => {'message': message};
}

/// 기록 검색 요청 DTO
class AiSearchRequestDto {
  final String query;

  AiSearchRequestDto({required this.query});

  factory AiSearchRequestDto.fromJson(Map<String, dynamic> json) =>
      AiSearchRequestDto(query: json['query'] as String);

  Map<String, dynamic> toJson() => {'query': query};
}

/// 기록 검색 결과 항목 DTO
class AiSearchResultItem {
  final String content;

  AiSearchResultItem({required this.content});

  factory AiSearchResultItem.fromJson(Map<String, dynamic> json) =>
      AiSearchResultItem(content: json['content'] as String);

  Map<String, dynamic> toJson() => {'content': content};
}

/// 기록 검색 응답 DTO
class AiSearchResponseDto {
  final List<AiSearchResultItem> results;

  AiSearchResponseDto({required this.results});

  factory AiSearchResponseDto.fromJson(Map<String, dynamic> json) =>
      AiSearchResponseDto(
        results: (json['results'] as List)
            .map((e) => AiSearchResultItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() =>
      {'results': results.map((e) => e.toJson()).toList()};
}

/// (Legacy/Internal) AI 응답 DTO - content 필드 하나만 있을 때 사용
class AiResponseDto {
  final String content;

  AiResponseDto({required this.content});

  factory AiResponseDto.fromJson(Map<String, dynamic> json) {
    return AiResponseDto(
      content:
          (json['content'] ?? json['message'] ?? json['case'] ?? '') as String,
    );
  }

  Map<String, dynamic> toJson() => {'content': content};
}
