/// GetX 라우트 설정 클래스. 경로와 페이지, 바인딩(Dependency Injection)을 매핑합니다.

import 'package:get/get.dart';
import 'package:ai_life_legacy/features/main/presentation/pages/main_page.dart';
import 'package:ai_life_legacy/features/auth/presentation/pages/login_page.dart';
import 'package:ai_life_legacy/features/auth/presentation/pages/signup_page.dart';

import 'package:ai_life_legacy/features/home/presentation/pages/home_page.dart';
import 'package:ai_life_legacy/features/onboarding/presentation/pages/self_intro_page.dart';
import 'package:ai_life_legacy/features/autobiography/presentation/pages/autobiography_list_page.dart';
import 'package:ai_life_legacy/app/core/routes/app_routes.dart';
import 'package:ai_life_legacy/features/home/presentation/bindings/home_binding.dart';
import 'package:ai_life_legacy/features/onboarding/presentation/bindings/onboarding_binding.dart';
import 'package:ai_life_legacy/features/profile/presentation/pages/my_page.dart';
import 'package:ai_life_legacy/features/profile/presentation/bindings/my_page_binding.dart';
import 'package:ai_life_legacy/features/home/presentation/pages/search_page.dart';

class AppPages {
  /// GetMaterialApp에 등록할 페이지 리스트
  static final pages = <GetPage>[
    // 1. 시작 화면 (/)
    GetPage(name: Routes.main, page: () => const MainPage()),

    // 2. 로그인 화면 (/login)
    GetPage(
      name: Routes.login,
      page: () => const LoginPage(),
    ),

    // 2.5. 회원가입 화면 (/signup)
    GetPage(
      name: Routes.signup,
      page: () => const SignUpPage(),
    ),

    // 3. 홈 화면 (/home)
    GetPage(
      name: Routes.home,
      page: () => const HomePage(),
      bindings: [
        HomeBinding(),
      ],
    ),

    // 4. 자기소개 작성 화면 (/self_intro)
    GetPage(
      name: Routes.selfIntro,
      page: () => const SelfIntroPage(),
      bindings: [
        OnboardingBinding(),
      ],
    ),

    // 5. 자서전 목록 화면 (/autobiography)
    GetPage(
      name: Routes.autobiography,
      page: () => const AutobiographyListPage(),
      bindings: [
        HomeBinding(),
      ],
    ),

    // 5.5. 검색 화면 (/search)
    GetPage(
      name: Routes.search,
      page: () => const SearchPage(),
      binding: HomeBinding(),
    ),
    // 6. 마이페이지 화면 (/mypage)
    GetPage(
      name: Routes.myPage,
      page: () => const MyPage(),
      binding: MyPageBinding(),
    ),
  ];
}
