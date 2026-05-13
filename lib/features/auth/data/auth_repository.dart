/// Repository: Data Source(API, DB)와 Domain/Presentation 계층 사이의 중개자 역할
/// 데이터를 상위 계층이 사용하기 쉬운 형태로 변환하여 제공합니다.
library;
import 'package:ai_life_legacy/features/auth/data/auth_api.dart';
import 'package:ai_life_legacy/features/auth/data/models/auth.dto.dart';
import 'package:ai_life_legacy/app/core/models/response.dart';

/// 도메인 계층이 의존하는 추상 인터페이스
/// 구현체 교체 및 테스트 용이성을 확보합니다.
abstract class AuthRepository {
  Future<Success201Response<JwtTokenResponseDto>> signUp(
    AuthCredentialsDto credentials,
  );
  Future<SuccessResponse<JwtTokenResponseDto>> login(
    AuthCredentialsDto credentials,
  );
  Future<SuccessResponse<JwtTokenResponseDto>> refreshToken(
    RefreshTokenDto refreshTokenDto,
  );
  Future<bool> checkSession();
}

/// AuthRepository의 실제 구현체
/// AuthApi를 호출하고 결과를 반환합니다.
class AuthRepositoryImpl implements AuthRepository {
  final AuthApi api;
  AuthRepositoryImpl(this.api);

  @override
  Future<Success201Response<JwtTokenResponseDto>> signUp(
    AuthCredentialsDto credentials,
  ) async {
    final response = await api.signUp(credentials);
    return Success201Response.fromJson(
      response.data,
      (json) => JwtTokenResponseDto.fromJson(json),
    );
  }

  @override
  Future<SuccessResponse<JwtTokenResponseDto>> login(
    AuthCredentialsDto credentials,
  ) async {
    final response = await api.login(credentials);
    return SuccessResponse.fromJson(
      response.data,
      (json) => JwtTokenResponseDto.fromJson(json),
    );
  }

  @override
  Future<SuccessResponse<JwtTokenResponseDto>> refreshToken(
    RefreshTokenDto refreshTokenDto,
  ) async {
    final response = await api.refreshToken(refreshTokenDto);
    return SuccessResponse.fromJson(
      response.data,
      (json) => JwtTokenResponseDto.fromJson(json),
    );
  }

  @override
  Future<bool> checkSession() => api.checkSession();
}
