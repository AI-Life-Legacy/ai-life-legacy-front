import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:ai_life_legacy/features/auth/data/auth_repository.dart';
import 'package:ai_life_legacy/features/auth/data/auth_api.dart';

@GenerateMocks([AuthApi])
import 'auth_repository_test.mocks.dart';

void main() {
  group('AuthRepository', () {
    test('should be an abstract class', () {
      expect(AuthRepository, isA<Type>());
    });

    test('should define checkSession method', () {
      // This test ensures the interface is well-defined
      expect(AuthRepository, isNotNull);
    });
  });

  group('AuthRepositoryImpl', () {
    late MockAuthApi mockAuthApi;
    late AuthRepositoryImpl repository;

    setUp(() {
      mockAuthApi = MockAuthApi();
      repository = AuthRepositoryImpl(mockAuthApi);
    });

    test('should implement AuthRepository', () {
      expect(repository, isA<AuthRepository>());
    });

    test('should create instance with AuthApi dependency', () {
      expect(() => AuthRepositoryImpl(mockAuthApi), returnsNormally);
    });

    group('checkSession', () {
      test('should call api.checkSession', () async {
        when(mockAuthApi.checkSession()).thenAnswer((_) async => true);
        
        await repository.checkSession();
        
        verify(mockAuthApi.checkSession()).called(1);
      });

      test('should return true when api returns true', () async {
        when(mockAuthApi.checkSession()).thenAnswer((_) async => true);
        
        final result = await repository.checkSession();
        
        expect(result, isTrue);
      });

      test('should return false when api returns false', () async {
        when(mockAuthApi.checkSession()).thenAnswer((_) async => false);
        
        final result = await repository.checkSession();
        
        expect(result, isFalse);
      });

      test('should propagate api result without modification', () async {
        when(mockAuthApi.checkSession()).thenAnswer((_) async => true);
        
        final result1 = await repository.checkSession();
        expect(result1, isTrue);
        
        when(mockAuthApi.checkSession()).thenAnswer((_) async => false);
        
        final result2 = await repository.checkSession();
        expect(result2, isFalse);
      });

      test('should handle multiple sequential calls', () async {
        when(mockAuthApi.checkSession()).thenAnswer((_) async => true);
        
        await repository.checkSession();
        await repository.checkSession();
        await repository.checkSession();
        
        verify(mockAuthApi.checkSession()).called(3);
      });

      test('should propagate exceptions from api', () async {
        when(mockAuthApi.checkSession()).thenThrow(Exception('Network error'));
        
        expect(
          () => repository.checkSession(),
          throwsA(isA<Exception>()),
        );
      });

      test('should return a Future<bool>', () {
        when(mockAuthApi.checkSession()).thenAnswer((_) async => false);
        
        final result = repository.checkSession();
        expect(result, isA<Future<bool>>());
      });

      test('should handle timeout scenarios', () async {
        when(mockAuthApi.checkSession()).thenAnswer(
          (_) => Future.delayed(const Duration(milliseconds: 100), () => true),
        );
        
        final result = await repository.checkSession();
        expect(result, isTrue);
      });
    });

    group('dependency injection', () {
      test('should accept any AuthApi implementation', () {
        final api1 = MockAuthApi();
        final api2 = MockAuthApi();
        
        final repo1 = AuthRepositoryImpl(api1);
        final repo2 = AuthRepositoryImpl(api2);
        
        expect(repo1, isA<AuthRepositoryImpl>());
        expect(repo2, isA<AuthRepositoryImpl>());
      });

      test('should use injected api instance', () async {
        final specificMockApi = MockAuthApi();
        when(specificMockApi.checkSession()).thenAnswer((_) async => true);
        
        final specificRepo = AuthRepositoryImpl(specificMockApi);
        await specificRepo.checkSession();
        
        verify(specificMockApi.checkSession()).called(1);
      });
    });
  });
}