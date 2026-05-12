import 'package:ai_life_legacy/app/core/network/api_provider.dart';
import 'package:ai_life_legacy/features/user/data/user_api.dart';
import 'package:ai_life_legacy/features/autobiography/data/autobiography_api.dart';
import 'package:ai_life_legacy/app/core/ai/ai_api.dart';
import 'package:get/get.dart';
import 'package:ai_life_legacy/features/onboarding/presentation/controllers/self_intro_controller.dart';
import 'package:ai_life_legacy/features/onboarding/presentation/controllers/onboarding_controller.dart';
import 'package:ai_life_legacy/features/onboarding/data/onboarding_api.dart';
import 'package:ai_life_legacy/features/user/data/user_repository.dart';
import 'package:ai_life_legacy/features/autobiography/data/autobiography_repository.dart';
import 'package:ai_life_legacy/app/core/ai/ai_repository.dart';

class OnboardingBinding extends Bindings {
  @override
  void dependencies() {
    // Data Sources: API Provider 의존성 주입
    Get.lazyPut(() => UserApi(), fenix: true);
    Get.lazyPut(() => AutobiographyApi(Get.find<ApiProvider>()), fenix: true);
    Get.lazyPut(() => AiApi(), fenix: true);
    Get.lazyPut(() => OnboardingApi(Get.find<ApiProvider>()), fenix: true);

    // Repositories: 데이터 계층 의존성 주입
    Get.lazyPut<UserRepository>(() => UserRepositoryImpl(Get.find<UserApi>()),
        fenix: true);
    Get.lazyPut<AutobiographyRepository>(
        () => AutobiographyRepositoryImpl(Get.find<AutobiographyApi>()),
        fenix: true);
    Get.lazyPut<AiRepository>(() => AiRepositoryImpl(Get.find<AiApi>()),
        fenix: true);

    // Controllers: 비즈니스 로직 제어 컨트롤러 주입
    Get.lazyPut<SelfIntroController>(
      () => SelfIntroController(
        Get.find<UserRepository>(),
        Get.find<AutobiographyRepository>(),
        Get.find<AiRepository>(),
      ),
    );

    Get.lazyPut<OnboardingController>(
      () => OnboardingController(Get.find<OnboardingApi>()),
    );
  }
}
