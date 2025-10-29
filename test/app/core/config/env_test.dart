import 'package:flutter_test/flutter_test.dart';
import 'package:ai_life_legacy/app/core/config/env.dart';

void main() {
  group('Env', () {
    test('should have late apiBase field that can be assigned', () {
      // This test verifies that apiBase can be set
      expect(() => Env.apiBase, throwsA(isA<Error>())); // Not initialized yet
      
      Env.load();
      
      expect(Env.apiBase, isNotNull);
      expect(Env.apiBase, isA<String>());
    });

    test('load should set apiBase to expected URL', () {
      Env.load();
      
      expect(Env.apiBase, equals('https://api.example.com'));
    });

    test('load should be idempotent', () {
      Env.load();
      final firstValue = Env.apiBase;
      
      Env.load();
      final secondValue = Env.apiBase;
      
      expect(firstValue, equals(secondValue));
    });

    test('apiBase should persist across multiple accesses', () {
      Env.load();
      
      final firstAccess = Env.apiBase;
      final secondAccess = Env.apiBase;
      final thirdAccess = Env.apiBase;
      
      expect(firstAccess, equals(secondAccess));
      expect(secondAccess, equals(thirdAccess));
    });

    test('load should set a valid HTTP/HTTPS URL', () {
      Env.load();
      
      expect(Env.apiBase, startsWith('http'));
      expect(Uri.tryParse(Env.apiBase), isNotNull);
    });

    test('apiBase should not be empty after load', () {
      Env.load();
      
      expect(Env.apiBase, isNotEmpty);
    });

    test('apiBase should not have trailing slash', () {
      Env.load();
      
      expect(Env.apiBase.endsWith('/'), isFalse);
    });
  });
}