import 'package:ai_life_legacy/features/auth/data/models/auth.dto.dart';
import 'package:ai_life_legacy/app/core/network/api_provider.dart';
import 'package:ai_life_legacy/app/core/network/api_endpoints.dart';
import 'package:dio/dio.dart';

class AuthApi {
  final ApiProvider _apiProvider;

  AuthApi(this._apiProvider);

  /// 회원가입
  Future<Response> signUp(AuthCredentialsDto credentials) async {
    return await _apiProvider.post(
      ApiEndpoints.signUp,
      data: credentials.toJson(),
    );
  }

  /// 로그인
  Future<Response> login(AuthCredentialsDto credentials) async {
    return await _apiProvider.post(
      ApiEndpoints.login,
      data: credentials.toJson(),
    );
  }

  /// 토큰 갱신
  Future<Response> refreshToken(RefreshTokenDto refreshTokenDto) async {
    return await _apiProvider.post(
      ApiEndpoints.refreshToken,
      data: refreshTokenDto.toJson(),
    );
  }

  /// 세션 확인 (프로필 조회로 확인)
  Future<bool> checkSession() async {
    try {
      final response = await _apiProvider.get(ApiEndpoints.profile);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
