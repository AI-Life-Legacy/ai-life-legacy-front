import 'package:get/get.dart';

import 'package:ai_life_legacy/app/core/routes/app_routes.dart';

import 'package:ai_life_legacy/features/main/presentation/pages/main_page.dart';
import 'package:ai_life_legacy/features/auth/presentation/pages/login_page.dart';
import 'package:ai_life_legacy/features/auth/presentation/pages/signup_page.dart';
import 'package:ai_life_legacy/features/home/presentation/pages/home_page.dart';
import 'package:ai_life_legacy/features/home/presentation/pages/dashboard_page.dart';
import 'package:ai_life_legacy/features/home/presentation/pages/search_page.dart';
import 'package:ai_life_legacy/features/onboarding/presentation/pages/self_intro_page.dart';
import 'package:ai_life_legacy/features/onboarding/presentation/pages/chapter_generating_page.dart';
import 'package:ai_life_legacy/features/onboarding/presentation/pages/complete_page.dart';
import 'package:ai_life_legacy/features/autobiography/presentation/pages/autobiography_list_page.dart';
import 'package:ai_life_legacy/features/autobiography/presentation/pages/autobiography_write_page.dart';
import 'package:ai_life_legacy/features/autobiography/presentation/pages/completion_page.dart';
import 'package:ai_life_legacy/features/autobiography/presentation/pages/chapter_chat_page.dart';
import 'package:ai_life_legacy/features/autobiography/presentation/pages/chapter_complete_page.dart';
import 'package:ai_life_legacy/features/generation/presentation/pages/gen_confirm_page.dart';
import 'package:ai_life_legacy/features/generation/presentation/pages/generating_page.dart';
import 'package:ai_life_legacy/features/generation/presentation/pages/generated_page.dart';
import 'package:ai_life_legacy/features/generation/presentation/pages/locked_page.dart';
import 'package:ai_life_legacy/features/viewer/presentation/pages/viewer_entry_page.dart';
import 'package:ai_life_legacy/features/viewer/presentation/pages/viewer_role_page.dart';
import 'package:ai_life_legacy/features/viewer/presentation/pages/viewer_audio_page.dart';
import 'package:ai_life_legacy/features/avatar_chat/presentation/pages/avatar_chat_page.dart';
import 'package:ai_life_legacy/features/profile/presentation/pages/my_page.dart';

import 'package:ai_life_legacy/features/home/presentation/bindings/home_binding.dart';
import 'package:ai_life_legacy/features/onboarding/presentation/bindings/onboarding_binding.dart';
import 'package:ai_life_legacy/features/autobiography/presentation/bindings/autobiography_binding.dart';
import 'package:ai_life_legacy/features/avatar_chat/presentation/bindings/avatar_chat_binding.dart';
import 'package:ai_life_legacy/features/profile/presentation/bindings/my_page_binding.dart';
import 'package:ai_life_legacy/features/auth/presentation/bindings.dart';
import 'package:ai_life_legacy/features/viewer/presentation/bindings/viewer_binding.dart';

class AppPages {
  static final pages = <GetPage>[
    GetPage(name: Routes.main, page: () => const MainPage()),
    GetPage(
        name: Routes.login,
        page: () => const LoginPage(),
        binding: AuthBinding()),
    GetPage(
        name: Routes.signup,
        page: () => const SignUpPage(),
        binding: AuthBinding()),
    GetPage(
        name: Routes.home,
        page: () => const HomePage(),
        binding: HomeBinding()),
    GetPage(name: Routes.dashboard, page: () => const DashboardPage()),
    GetPage(
        name: Routes.search,
        page: () => const SearchPage(),
        binding: HomeBinding()),
    GetPage(
        name: Routes.selfIntro,
        page: () => const SelfIntroPage(),
        binding: OnboardingBinding()),
    GetPage(name: Routes.complete, page: () => const CompletePage()),
    GetPage(
        name: Routes.autobiography,
        page: () => const AutobiographyListPage(),
        binding: AutobiographyBinding()),
    GetPage(
        name: Routes.write,
        page: () => const AutobiographyWritePage(),
        binding: AutobiographyBinding()),
    GetPage(name: Routes.completion, page: () => const CompletionPage()),
    GetPage(
        name: Routes.chapterComplete, page: () => const ChapterCompletePage()),
    GetPage(
        name: Routes.chapterChat,
        page: () => const ChapterChatPage(),
        binding: AutobiographyBinding()),
    GetPage(
        name: Routes.genConfirm,
        page: () => const GenConfirmPage(),
        binding: AutobiographyBinding()),
    GetPage(name: Routes.generating, page: () => const GeneratingPage()),
    GetPage(
        name: Routes.chapterGenerating,
        page: () => const ChapterGeneratingPage()),
    GetPage(name: Routes.generated, page: () => const GeneratedPage()),
    GetPage(name: Routes.locked, page: () => const LockedPage()),
    GetPage(
        name: Routes.viewerEntry,
        page: () => const ViewerEntryPage(),
        binding: ViewerBinding()),
    GetPage(name: Routes.viewerRole, page: () => const ViewerRolePage()),
    GetPage(
        name: Routes.avatarChat,
        page: () => const AvatarChatPage(),
        binding: AvatarChatBinding()),
    GetPage(
        name: Routes.viewerChat,
        page: () => const AvatarChatPage(),
        binding: AvatarChatBinding()),
    GetPage(name: Routes.viewerAudio, page: () => const ViewerAudioPage()),
    GetPage(
        name: Routes.myPage,
        page: () => const MyPage(),
        binding: MyPageBinding()),
  ];
}
