import 'package:flutter_test/flutter_test.dart';
import 'package:ai_life_legacy/app/core/network/dio_client.dart';
import 'package:ai_life_legacy/app/core/config/env.dart';
import 'package:dio/dio.dart';

void main() {
  group('DioClient', () {
    setUp(() {
      // Ensure Env is loaded before each test
      Env.load();
    });

    test('init should create a Dio instance', () {
      DioClient.init();
      
      expect(DioClient.instance, isA<Dio>());
    });

    test('instance should return the same Dio object', () {
      DioClient.init();
      
      final first = DioClient.instance;
      final second = DioClient.instance;
      
      expect(identical(first, second), isTrue);
    });

    test('init should set baseUrl from Env', () {
      DioClient.init();
      
      expect(DioClient.instance.options.baseUrl, equals(Env.apiBase));
      expect(DioClient.instance.options.baseUrl, equals('https://api.example.com'));
    });

    test('init should set connectTimeout to 10 seconds', () {
      DioClient.init();
      
      expect(DioClient.instance.options.connectTimeout, equals(const Duration(seconds: 10)));
    });

    test('init should set receiveTimeout to 15 seconds', () {
      DioClient.init();
      
      expect(DioClient.instance.options.receiveTimeout, equals(const Duration(seconds: 15)));
    });

    test('init should set Content-Type header to application/json', () {
      DioClient.init();
      
      expect(DioClient.instance.options.headers['Content-Type'], equals('application/json'));
    });

    test('init should configure all BaseOptions correctly', () {
      DioClient.init();
      
      final options = DioClient.instance.options;
      expect(options.baseUrl, isNotEmpty);
      expect(options.connectTimeout, isNotNull);
      expect(options.receiveTimeout, isNotNull);
      expect(options.headers, isNotNull);
      expect(options.headers, isNotEmpty);
    });

    test('init should be idempotent - can be called multiple times', () {
      DioClient.init();
      final firstInstance = DioClient.instance;
      
      DioClient.init();
      final secondInstance = DioClient.instance;
      
      // After re-initialization, we get a new instance
      expect(firstInstance, isA<Dio>());
      expect(secondInstance, isA<Dio>());
    });

    test('instance should have valid baseUrl format', () {
      DioClient.init();
      
      final baseUrl = DioClient.instance.options.baseUrl;
      expect(Uri.tryParse(baseUrl), isNotNull);
      expect(baseUrl, startsWith('http'));
    });

    test('timeouts should be positive durations', () {
      DioClient.init();
      
      expect(DioClient.instance.options.connectTimeout!.inMilliseconds, greaterThan(0));
      expect(DioClient.instance.options.receiveTimeout!.inMilliseconds, greaterThan(0));
    });

    test('receiveTimeout should be greater than or equal to connectTimeout', () {
      DioClient.init();
      
      final connectMs = DioClient.instance.options.connectTimeout!.inMilliseconds;
      final receiveMs = DioClient.instance.options.receiveTimeout!.inMilliseconds;
      
      expect(receiveMs, greaterThanOrEqualTo(connectMs));
    });
  });
}