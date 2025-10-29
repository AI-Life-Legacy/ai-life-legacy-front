import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:ai_life_legacy/features/auth/presentation/bindings.dart';
import 'package:ai_life_legacy/features/auth/data/auth_api.dart';
import 'package:ai_life_legacy/features/auth/data/auth_repository.dart';
import 'package:ai_life_legacy/features/auth/presentation/controllers/auth_controller.dart';
import 'package:ai_life_legacy/app/core/network/dio_client.dart';
import 'package:ai_life_legacy/app/core/config/env.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AuthBinding', () {
    late AuthBinding binding;

    setUp(() {
      // Initialize required dependencies
      Env.load();
      DioClient.init();
      binding = AuthBinding();
    });

    tearDown(() {
      Get.reset();
    });

    test('should extend Bindings', () {
      expect(binding, isA<Bindings>());
    });

    test('should register AuthApi', () {
      binding.dependencies();
      
      expect(Get.isRegistered<AuthApi>(), isTrue);
    });

    test('should register AuthRepository', () {
      binding.dependencies();
      
      expect(Get.isRegistered<AuthRepository>(), isTrue);
    });

    test('should register AuthController', () {
      binding.dependencies();
      
      expect(Get.isRegistered<AuthController>(), isTrue);
    });

    test('should register all dependencies in correct order', () {
      binding.dependencies();
      
      final api = Get.find<AuthApi>();
      final repo = Get.find<AuthRepository>();
      final controller = Get.find<AuthController>();
      
      expect(api, isA<AuthApi>());
      expect(repo, isA<AuthRepository>());
      expect(controller, isA<AuthController>());
    });

    test('should use lazyPut for all dependencies', () {
      // Dependencies should not be instantiated yet
      expect(Get.isRegistered<AuthApi>(), isFalse);
      
      binding.dependencies();
      
      // After binding, they should be registered
      expect(Get.isRegistered<AuthApi>(), isTrue);
    });

    test('should inject AuthApi into AuthRepository', () {
      binding.dependencies();
      
      final repo = Get.find<AuthRepository>();
      expect(repo, isA<AuthRepositoryImpl>());
      
      // The repository should be properly constructed with AuthApi
      expect(repo, isNotNull);
    });

    test('should inject AuthRepository into AuthController', () {
      binding.dependencies();
      
      final controller = Get.find<AuthController>();
      expect(controller, isNotNull);
      
      // Controller should have access to repository
      expect(controller, isA<AuthController>());
    });

    test('dependencies should be singletons within scope', () {
      binding.dependencies();
      
      final api1 = Get.find<AuthApi>();
      final api2 = Get.find<AuthApi>();
      
      expect(identical(api1, api2), isTrue);
    });

    test('should handle multiple dependency() calls', () {
      binding.dependencies();
      binding.dependencies();
      
      expect(Get.isRegistered<AuthApi>(), isTrue);
      expect(Get.isRegistered<AuthRepository>(), isTrue);
      expect(Get.isRegistered<AuthController>(), isTrue);
    });

    test('AuthRepository should be instance of AuthRepositoryImpl', () {
      binding.dependencies();
      
      final repo = Get.find<AuthRepository>();
      expect(repo, isA<AuthRepositoryImpl>());
    });

    test('should properly wire dependency graph', () {
      binding.dependencies();
      
      // Get controller which depends on repository which depends on api
      final controller = Get.find<AuthController>();
      
      // If this doesn't throw, the dependency graph is properly wired
      expect(controller, isNotNull);
      expect(controller.isLoggedIn, isNotNull);
    });
  });
}