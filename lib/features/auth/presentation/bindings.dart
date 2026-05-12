import 'package:get/get.dart';
import 'package:ai_life_legacy/features/auth/data/auth_api.dart';
import 'package:ai_life_legacy/features/auth/presentation/controllers/auth_controller.dart';
import 'package:ai_life_legacy/app/core/network/api_provider.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AuthApi>()) {
      Get.lazyPut<AuthApi>(() => AuthApi(Get.find<ApiProvider>()));
    }

    if (!Get.isRegistered<AuthController>()) {
      Get.lazyPut<AuthController>(
        () => AuthController(Get.find<AuthApi>()),
        fenix: true,
      );
    }
  }
}
