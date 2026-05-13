/// 아바타 채팅 관련 요청/응답 DTO 정의
library;

/// 아바타 채팅 요청 DTO
class AvatarChatRequestDto {
  final String message;

  AvatarChatRequestDto({
    required this.message,
  });

  factory AvatarChatRequestDto.fromJson(Map<String, dynamic> json) {
    return AvatarChatRequestDto(
      message: json['message'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
    };
  }
}

/// 아바타 채팅 응답 DTO
/// 서버 응답 구조: result 안에 message로 받음
class AvatarChatResponseDto {
  final String message;

  AvatarChatResponseDto({
    required this.message,
  });

  factory AvatarChatResponseDto.fromJson(Map<String, dynamic> json) {
    return AvatarChatResponseDto(
      message: json['message'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
    };
  }
}
