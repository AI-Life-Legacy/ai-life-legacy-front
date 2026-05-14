import 'package:get/get.dart';
import 'package:ai_life_legacy/features/onboarding/data/onboarding_api.dart';
import 'package:ai_life_legacy/features/onboarding/presentation/controllers/onboarding_controller.dart';
import 'package:ai_life_legacy/app/core/network/api_provider.dart';

class OnboardingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => OnboardingApi(Get.find<ApiProvider>()));
    Get.lazyPut(() => OnboardingController(Get.find<OnboardingApi>()));
  }
}
