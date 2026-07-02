/// 인증 관련 요청/응답 DTO 정의
library;

/// 회원가입/로그인 요청 DTO
class AuthCredentialsDto {
  final String email;
  final String password;

  AuthCredentialsDto({
    required this.email,
    required this.password,
  });

  factory AuthCredentialsDto.fromJson(Map<String, dynamic> json) {
    return AuthCredentialsDto(
      email: json['email'] as String,
      password: json['password'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}

/// JWT 토큰 응답 DTO
class JwtTokenResponseDto {
  final String accessToken;
  final String refreshToken;

  JwtTokenResponseDto({
    required this.accessToken,
    required this.refreshToken,
  });

  factory JwtTokenResponseDto.fromJson(Map<String, dynamic> json) {
    return JwtTokenResponseDto(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
    };
  }
}

/// 토큰 갱신 요청 DTO
class RefreshTokenDto {
  final String refreshToken;

  RefreshTokenDto({
    required this.refreshToken,
  });

  factory RefreshTokenDto.fromJson(Map<String, dynamic> json) {
    return RefreshTokenDto(
      refreshToken: json['refreshToken'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'refreshToken': refreshToken,
    };
  }
}
