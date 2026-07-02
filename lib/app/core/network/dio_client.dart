library;

import 'package:flutter/foundation.dart';

/// 전역 Dio 클라이언트 인스턴스를 관리합니다.
/// 공통 헤더, 타임아웃, 인터셉터 설정을 중앙화합니다.
import 'package:dio/dio.dart';
import 'package:ai_life_legacy/app/core/config/env.dart';
import 'package:ai_life_legacy/app/core/utils/token_storage.dart';
import 'package:ai_life_legacy/app/core/network/api_endpoints.dart';

class DioClient {
  /// 실제 HTTP 요청을 수행하는 Dio 객체
  static late Dio _dio;

  /// 외부에서 읽기 전용으로 접근할 getter.
  /// 외부에서 접근 가능한 읽기 전용 Dio 인스턴스 (Singleton 패턴)
  static Dio get instance => _dio;

  /// 전역 Dio 초기화. 반환값 없음.
  /// Dio 인스턴스 초기화. BaseOptions를 통해 API 기본 설정(URL, Timeout, Header)을 적용합니다.
  static void init() {
    _dio = Dio(
      BaseOptions(
        baseUrl: Env.apiBase,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    // 인터셉터 추가: 로깅 및 인증 토큰 관리
    _dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestBody: true,
        responseHeader: false,
        responseBody: true,
        error: true,
      ),
    );

    // 토큰 없이 접근 가능한 공개 API 경로 목록
    final publicPaths = [
      '/auth/login',
      '/auth/signup',
      '/auth/refresh-token',
      '/auth/viewer-login',
    ];

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final path = options.path;
          final isPublic = publicPaths.any((p) => path.contains(p));

          debugPrint('[DioClient] Request: ${options.method} $path');

          if (!isPublic) {
            final isViewer = TokenStorage.isViewerMode();
            if (isViewer) {
              final viewerToken = TokenStorage.getViewerAccessToken();
              debugPrint(
                  '[DioClient] ViewerMode is True. ViewerToken exists: ${viewerToken != null && viewerToken.isNotEmpty}');
              if (viewerToken != null && viewerToken.isNotEmpty) {
                options.headers['Authorization'] = 'Bearer $viewerToken';
                debugPrint('[DioClient] Viewer Authorization header attached');
              } else {
                debugPrint(
                    '[DioClient] WARNING: No viewer access token available for request');
              }
            } else {
              // 공개 API가 아닌 경우에만 Access Token 주입
              final accessToken = TokenStorage.getAccessToken();
              debugPrint(
                  '[DioClient] AccessToken exists: ${accessToken != null && accessToken.isNotEmpty}');
              if (accessToken != null && accessToken.isNotEmpty) {
                options.headers['Authorization'] = 'Bearer $accessToken';
                debugPrint('[DioClient] Authorization header attached');
              } else {
                debugPrint(
                    '[DioClient] WARNING: No access token available for request');
              }
            }
          } else {
            debugPrint('[DioClient] Public path — skipping Authorization');
          }

          options.headers['Content-Type'] = 'application/json';
          return handler.next(options);
        },
        onError: (error, handler) async {
          // 401 Unauthorized 에러 발생 시 토큰 갱신 로직 수행
          // 단, 로그인 요청 실패(비밀번호 오류 등)인 경우는 제외
          final isLoginRequest =
              error.requestOptions.path.contains(ApiEndpoints.login);

          if (error.response?.statusCode == 401 && !isLoginRequest) {
            try {
              await _refreshTokenAndRetry(error.requestOptions, handler);
            } catch (e) {
              // 토큰 갱신 실패 시 로그아웃 처리 및 에러 전파
              debugPrint('[DioClient] Token refresh failed: $e');
              await TokenStorage.clearTokens();
              return handler.reject(error);
            }
          } else {
            return handler.next(error);
          }
        },
      ),
    );
  }

  /// Refresh Token을 사용하여 Access Token을 갱신하고, 이전 요청을 재시도합니다.
  static Future<void> _refreshTokenAndRetry(
    RequestOptions requestOptions,
    ErrorInterceptorHandler handler,
  ) async {
    final refreshToken = TokenStorage.getRefreshToken();
    if (refreshToken == null) {
      throw Exception('Refresh token not found');
    }

    try {
      // 토큰 갱신 API 호출 (DioClient 내부 인스턴스가 아닌 별도 호출로 순환 참조 방지)
      final response = await _dio.post(
        ApiEndpoints.refreshToken,
        data: {'refreshToken': refreshToken},
      );

      final result = response.data as Map<String, dynamic>;
      // API 응답 구조에 따라 'result' 혹은 'data' 필드에서 토큰 정보 추출
      final tokenData =
          (result['result'] ?? result['data']) as Map<String, dynamic>;

      final newAccessToken = tokenData['accessToken'] as String;
      final newRefreshToken = tokenData['refreshToken'] as String;

      // 새 토큰 저장
      await TokenStorage.saveTokens(
        accessToken: newAccessToken,
        refreshToken: newRefreshToken,
      );

      // 원래 요청 재시도
      requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
      final retryResponse = await _dio.fetch(requestOptions);
      return handler.resolve(retryResponse);
    } catch (e) {
      return handler.reject(
        DioException(
          requestOptions: requestOptions,
          error: e,
        ),
      );
    }
  }
}
