/// JWT 토큰 파싱 및 유효성 검사 유틸리티
library;

import 'dart:convert';

class JwtUtils {
  /// JWT 토큰에서 UUID 추출
  static String? extractUuidFromToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      final payload = parts[1];
      // Base64Url 형식을 Base64 표준으로 변환 (Padding 보정)
      String normalizedPayload =
          payload.replaceAll('-', '+').replaceAll('_', '/');
      switch (normalizedPayload.length % 4) {
        case 1:
          normalizedPayload += '===';
          break;
        case 2:
          normalizedPayload += '==';
          break;
        case 3:
          normalizedPayload += '=';
          break;
      }

      final decoded = base64Decode(normalizedPayload);
      final json = jsonDecode(utf8.decode(decoded)) as Map<String, dynamic>;

      // JWT payload에서 uuid 또는 sub 등의 필드 확인
      return json['uuid'] as String? ??
          json['sub'] as String? ??
          json['userId'] as String?;
    } catch (e) {
      return null;
    }
  }

  /// JWT 토큰에서 모든 클레임 추출
  static Map<String, dynamic>? getClaims(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      final payload = parts[1];
      String normalizedPayload =
          payload.replaceAll('-', '+').replaceAll('_', '/');
      switch (normalizedPayload.length % 4) {
        case 1:
          normalizedPayload += '===';
          break;
        case 2:
          normalizedPayload += '==';
          break;
        case 3:
          normalizedPayload += '=';
          break;
      }

      final decoded = base64Decode(normalizedPayload);
      return jsonDecode(utf8.decode(decoded)) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  /// 토큰 만료 시간 확인 (exp 클레임)
  static DateTime? getExpirationDate(String token) {
    final claims = getClaims(token);
    if (claims == null) return null;

    final exp = claims['exp'];
    if (exp == null) return null;

    // JWT의 exp claim은 Unix Timestamp(초 단위)를 사용합니다.
    return DateTime.fromMillisecondsSinceEpoch(exp * 1000);
  }

  /// 토큰이 만료되었는지 확인
  static bool isTokenExpired(String token) {
    final expDate = getExpirationDate(token);
    if (expDate == null) return true;
    return DateTime.now().isAfter(expDate);
  }
}
