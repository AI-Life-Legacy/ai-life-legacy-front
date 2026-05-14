import 'package:get/get.dart';
import 'package:ai_life_legacy/features/autobiography/data/autobiography_api.dart';
import 'package:ai_life_legacy/features/autobiography/presentation/controllers/autobiography_controller.dart';
import 'package:ai_life_legacy/features/autobiography/presentation/controllers/autobiography_list_controller.dart';
import 'package:ai_life_legacy/features/autobiography/presentation/controllers/autobiography_write_controller.dart';
import 'package:ai_life_legacy/app/core/network/api_provider.dart';

class AutobiographyBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AutobiographyApi(Get.find<ApiProvider>()));
    Get.lazyPut(() => AutobiographyController(Get.find<AutobiographyApi>()));
    Get.lazyPut(() => AutobiographyListController(Get.find<AutobiographyApi>()));
    Get.lazyPut(() => AutobiographyWriteController(Get.find<AutobiographyApi>()));
  }
}
