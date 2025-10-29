import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:get/get.dart';
import 'package:ai_life_legacy/features/auth/presentation/controllers/auth_controller.dart';
import 'package:ai_life_legacy/features/auth/data/auth_repository.dart';

@GenerateMocks([AuthRepository])
import 'auth_controller_test.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AuthController', () {
    late MockAuthRepository mockRepository;
    late AuthController controller;

    setUp(() {
      mockRepository = MockAuthRepository();
      controller = AuthController(mockRepository);
    });

    tearDown(() {
      Get.reset();
    });

    test('should extend GetxController', () {
      expect(controller, isA<GetxController>());
    });

    test('should initialize with isLoggedIn as false', () {
      expect(controller.isLoggedIn.value, isFalse);
    });

    test('should initialize with loading as false', () {
      expect(controller.loading.value, isFalse);
    });

    group('onInit', () {
      test('should call _refreshSession when initialized', () async {
        when(mockRepository.checkSession()).thenAnswer((_) async => true);
        
        controller.onInit();
        
        // Wait for async operation
        await Future.delayed(const Duration(milliseconds: 100));
        
        verify(mockRepository.checkSession()).called(1);
      });

      test('should set isLoggedIn based on repository response', () async {
        when(mockRepository.checkSession()).thenAnswer((_) async => true);
        
        controller.onInit();
        await Future.delayed(const Duration(milliseconds: 100));
        
        expect(controller.isLoggedIn.value, isTrue);
      });

      test('should set loading to false after session check completes', () async {
        when(mockRepository.checkSession()).thenAnswer((_) async => false);
        
        controller.onInit();
        await Future.delayed(const Duration(milliseconds: 100));
        
        expect(controller.loading.value, isFalse);
      });

      test('should handle repository errors gracefully', () async {
        when(mockRepository.checkSession()).thenThrow(Exception('Network error'));
        
        controller.onInit();
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Loading should be set to false even on error
        expect(controller.loading.value, isFalse);
      });
    });

    group('demoLogin', () {
      test('should set isLoggedIn to true', () {
        controller.demoLogin();
        expect(controller.isLoggedIn.value, isTrue);
      });

      test('should update reactive state', () {
        var updateCount = 0;
        controller.isLoggedIn.listen((_) => updateCount++);
        
        controller.demoLogin();
        
        expect(updateCount, greaterThan(0));
      });

      test('should work multiple times', () {
        controller.isLoggedIn.value = false;
        controller.demoLogin();
        expect(controller.isLoggedIn.value, isTrue);
        
        controller.isLoggedIn.value = false;
        controller.demoLogin();
        expect(controller.isLoggedIn.value, isTrue);
      });
    });

    group('demoLogout', () {
      test('should set isLoggedIn to false', () {
        controller.isLoggedIn.value = true;
        controller.demoLogout();
        expect(controller.isLoggedIn.value, isFalse);
      });

      test('should update reactive state', () {
        var updateCount = 0;
        controller.isLoggedIn.listen((_) => updateCount++);
        
        controller.demoLogout();
        
        expect(updateCount, greaterThan(0));
      });

      test('should work after demoLogin', () {
        controller.demoLogin();
        expect(controller.isLoggedIn.value, isTrue);
        
        controller.demoLogout();
        expect(controller.isLoggedIn.value, isFalse);
      });
    });

    group('reactive state', () {
      test('isLoggedIn should be RxBool', () {
        expect(controller.isLoggedIn, isA<RxBool>());
      });

      test('loading should be RxBool', () {
        expect(controller.loading, isA<RxBool>());
      });

      test('isLoggedIn changes should be observable', () {
        final values = <bool>[];
        controller.isLoggedIn.listen((value) => values.add(value));
        
        controller.isLoggedIn.value = true;
        controller.isLoggedIn.value = false;
        controller.isLoggedIn.value = true;
        
        expect(values, contains(true));
        expect(values, contains(false));
      });

      test('loading changes should be observable', () {
        final values = <bool>[];
        controller.loading.listen((value) => values.add(value));
        
        controller.loading.value = true;
        controller.loading.value = false;
        
        expect(values, contains(true));
        expect(values, contains(false));
      });
    });

    group('dependency injection', () {
      test('should accept repository through constructor', () {
        final repo = MockAuthRepository();
        final ctrl = AuthController(repo);
        
        expect(ctrl, isA<AuthController>());
      });

      test('should use injected repository', () async {
        when(mockRepository.checkSession()).thenAnswer((_) async => true);
        
        controller.onInit();
        await Future.delayed(const Duration(milliseconds: 100));
        
        verify(mockRepository.checkSession()).called(1);
      });
    });

    group('loading state management', () {
      test('should set loading to true during session check', () async {
        when(mockRepository.checkSession()).thenAnswer(
          (_) => Future.delayed(const Duration(milliseconds: 50), () => true),
        );
        
        controller.onInit();
        // Immediately check loading state
        expect(controller.loading.value, isTrue);
      });

      test('should set loading to false after successful session check', () async {
        when(mockRepository.checkSession()).thenAnswer((_) async => true);
        
        controller.onInit();
        await Future.delayed(const Duration(milliseconds: 100));
        
        expect(controller.loading.value, isFalse);
      });

      test('should set loading to false after failed session check', () async {
        when(mockRepository.checkSession()).thenThrow(Exception('Error'));
        
        controller.onInit();
        await Future.delayed(const Duration(milliseconds: 100));
        
        expect(controller.loading.value, isFalse);
      });
    });
  });
}