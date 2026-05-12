import 'package:get/get.dart';
import 'package:ai_life_legacy/features/viewer/data/viewer_api.dart';
import 'package:ai_life_legacy/features/viewer/presentation/controllers/viewer_controller.dart';
import 'package:ai_life_legacy/app/core/network/api_provider.dart';

class ViewerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ViewerApi(Get.find<ApiProvider>()));
    Get.lazyPut(() => ViewerController(Get.find<ViewerApi>()));
  }
}
