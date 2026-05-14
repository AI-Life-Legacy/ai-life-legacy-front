import 'package:get/get.dart';
import 'package:ai_life_legacy/features/profile/presentation/controllers/my_page_controller.dart';
import 'package:ai_life_legacy/features/user/data/user_api.dart';
import 'package:ai_life_legacy/features/user/data/user_repository.dart';

class MyPageBinding extends Bindings {
  @override
  void dependencies() {
    // UserApi 및 UserRepository 등록
    if (!Get.isRegistered<UserApi>()) {
      Get.lazyPut(() => UserApi());
    }
    if (!Get.isRegistered<UserRepository>()) {
      Get.lazyPut<UserRepository>(() => UserRepositoryImpl(Get.find<UserApi>()));
    }

    // MyPageController 등록
    Get.lazyPut(() => MyPageController(
          Get.find<UserRepository>(),
        ));
  }
}

