import 'package:get/get.dart';
import 'package:ai_life_legacy/features/avatar_chat/data/avatar_chat_api.dart';
import 'package:ai_life_legacy/features/avatar_chat/presentation/controllers/avatar_chat_controller.dart';
import 'package:ai_life_legacy/app/core/network/api_provider.dart';

class AvatarChatBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AvatarChatApi(Get.find<ApiProvider>()));
    Get.lazyPut(() => AvatarChatController(Get.find<AvatarChatApi>()));
  }
}
