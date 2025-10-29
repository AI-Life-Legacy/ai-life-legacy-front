import 'package:flutter_test/flutter_test.dart';
import 'package:ai_life_legacy/app/core/network/api_endpoints.dart';

void main() {
  group('ApiEndpoints', () {
    test('authSession should be defined as expected constant', () {
      expect(ApiEndpoints.authSession, equals('/auth/session'));
    });

    test('authSession should start with forward slash', () {
      expect(ApiEndpoints.authSession, startsWith('/'));
    });

    test('authSession should not be empty', () {
      expect(ApiEndpoints.authSession, isNotEmpty);
    });

    test('authSession should not have trailing slash', () {
      expect(ApiEndpoints.authSession.endsWith('/'), isFalse);
    });

    test('authSession should be a valid URL path segment', () {
      expect(ApiEndpoints.authSession.contains(' '), isFalse);
      expect(ApiEndpoints.authSession.contains('\n'), isFalse);
      expect(ApiEndpoints.authSession.contains('\t'), isFalse);
    });

    test('all endpoints should be const strings', () {
      // This ensures compile-time constants
      expect(ApiEndpoints.authSession, isA<String>());
      const testConst = ApiEndpoints.authSession;
      expect(testConst, equals('/auth/session'));
    });

    test('endpoint paths should follow RESTful conventions', () {
      expect(ApiEndpoints.authSession.split('/').length, greaterThan(1));
      expect(ApiEndpoints.authSession, contains('auth'));
      expect(ApiEndpoints.authSession, contains('session'));
    });
  });
}