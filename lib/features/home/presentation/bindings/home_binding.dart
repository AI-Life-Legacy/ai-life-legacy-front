import 'package:get/get.dart';
import 'package:ai_life_legacy/features/home/presentation/controllers/home_controller.dart';
import 'package:ai_life_legacy/features/user/data/user_api.dart';
import 'package:ai_life_legacy/features/user/data/user_repository.dart';

import 'package:ai_life_legacy/features/autobiography/data/autobiography_api.dart';
import 'package:ai_life_legacy/features/autobiography/data/autobiography_repository.dart';
import 'package:ai_life_legacy/app/core/ai/ai_api.dart';
import 'package:ai_life_legacy/app/core/ai/ai_repository.dart';
import 'package:ai_life_legacy/features/onboarding/presentation/controllers/self_intro_controller.dart';
import 'package:ai_life_legacy/features/chapter_chat/presentation/controllers/chapter_chat_controller.dart';
import '../../../avatar_chat/presentation/controllers/avatar_chat_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // UserRepo: 사용자 정보 및 목차 조회 관련 의존성 주입
    Get.lazyPut(() => UserApi(), fenix: true);
    Get.lazyPut<UserRepository>(() => UserRepositoryImpl(Get.find<UserApi>()),
        fenix: true);
    Get.lazyPut(() => HomeController(Get.find<UserRepository>()), fenix: true);

    // AutobiographyRepo: 자서전 관련 데이터 관리 의존성 주입
    Get.lazyPut(() => AutobiographyApi(), fenix: true);
    Get.lazyPut<AutobiographyRepository>(
        () => AutobiographyRepositoryImpl(Get.find<AutobiographyApi>()),
        fenix: true);

    // SelfIntroController 의존성 주입 (탭 전환 시 사용)
    Get.lazyPut(() => AiApi(), fenix: true);
    Get.lazyPut<AiRepository>(() => AiRepositoryImpl(Get.find<AiApi>()),
        fenix: true);
    Get.lazyPut(() => SelfIntroController(Get.find<UserRepository>(),
        Get.find<AutobiographyRepository>(), Get.find<AiRepository>()), fenix: true);
    
    // ChapterChatController 의존성 주입
    Get.lazyPut(() => ChapterChatController(Get.find<UserRepository>(),
        Get.find<AutobiographyRepository>(), Get.find<AiRepository>()), fenix: true);
        
    // AvatarChatController 의존성 주입
    Get.lazyPut(() => AvatarChatController(), fenix: true);
  }
}
