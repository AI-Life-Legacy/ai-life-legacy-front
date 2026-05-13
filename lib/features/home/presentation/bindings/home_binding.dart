import 'package:get/get.dart';
import 'package:ai_life_legacy/features/home/data/home_api.dart';
import 'package:ai_life_legacy/features/home/presentation/controllers/home_controller.dart';
import 'package:ai_life_legacy/app/core/network/api_provider.dart';
import 'package:ai_life_legacy/features/autobiography/data/autobiography_api.dart';
import 'package:ai_life_legacy/features/autobiography/presentation/controllers/autobiography_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => HomeApi(Get.find<ApiProvider>()));
    Get.lazyPut(() => AutobiographyApi(Get.find<ApiProvider>()));
    Get.lazyPut(() => HomeController(Get.find<HomeApi>()));
    Get.lazyPut(() => AutobiographyController(Get.find<AutobiographyApi>()));
  }
}
