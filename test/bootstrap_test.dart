import 'package:flutter_test/flutter_test.dart';
import 'package:ai_life_legacy/bootstrap.dart';
import 'package:ai_life_legacy/app/core/config/env.dart';
import 'package:ai_life_legacy/app/core/network/dio_client.dart';
import 'package:dio/dio.dart';

void main() {
  group('bootstrap', () {
    test('should complete without errors', () async {
      await expectLater(bootstrap(), completes);
    });

    test('should load environment variables', () async {
      await bootstrap();
      
      expect(Env.apiBase, isNotNull);
      expect(Env.apiBase, isNotEmpty);
    });

    test('should initialize DioClient', () async {
      await bootstrap();
      
      expect(DioClient.instance, isA<Dio>());
    });

    test('should set up DioClient with correct baseUrl', () async {
      await bootstrap();
      
      expect(DioClient.instance.options.baseUrl, equals(Env.apiBase));
    });

    test('should be idempotent - can be called multiple times', () async {
      await bootstrap();
      final firstBaseUrl = Env.apiBase;
      
      await bootstrap();
      final secondBaseUrl = Env.apiBase;
      
      expect(firstBaseUrl, equals(secondBaseUrl));
    });

    test('should initialize in correct order - Env before DioClient', () async {
      await bootstrap();
      
      // If this passes, it means Env was loaded before DioClient
      // because DioClient.init() depends on Env.apiBase
      expect(DioClient.instance.options.baseUrl, equals(Env.apiBase));
    });

    test('should set up all required configurations', () async {
      await bootstrap();
      
      // Verify Env configuration
      expect(Env.apiBase, isNotEmpty);
      expect(Uri.tryParse(Env.apiBase), isNotNull);
      
      // Verify DioClient configuration
      expect(DioClient.instance.options.connectTimeout, isNotNull);
      expect(DioClient.instance.options.receiveTimeout, isNotNull);
      expect(DioClient.instance.options.headers, isNotEmpty);
    });

    test('should return Future<void>', () {
      final result = bootstrap();
      expect(result, isA<Future<void>>());
    });
  });
}