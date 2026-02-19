import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'dart:async';
import 'package:ai_life_legacy/app/core/routes/app_routes.dart';
import 'package:ai_life_legacy/features/user/data/user_repository.dart';
import 'package:ai_life_legacy/app/core/utils/toast_utils.dart';
import 'package:ai_life_legacy/features/chapter_chat/presentation/controllers/chapter_chat_controller.dart';

/// Home Feature의 비즈니스 로직을 제어합니다.
/// 사용자 목차(TOC) 로드, 탭 네비게이션, 챕터 클릭 이벤트 등을 처리합니다.
class HomeController extends GetxController {
  final UserRepository userRepo;
  HomeController(this.userRepo);

  // Reactive State: UI 업데이트를 위한 상태 변수
  final RxList<ChapterModel> chapters = <ChapterModel>[].obs;
  final RxInt selectedTabIndex = 0.obs;
  final RxBool loading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserContents();
  }

  /// 사용자 목차(TOC) 목록을 서버로부터 불러옵니다.
  Future<void> loadUserContents() async {
    loading.value = true;
    errorMessage.value = '';
    try {
      final tocResult = await userRepo.getUserToc();
      final initialChapters = tocResult.data
          .map(
            (toc) => ChapterModel(
              id: toc.id,
              title: toc.title,
              subtitle: '진행률 ${(toc.percent).toStringAsFixed(1)}%',
              progress: toc.percent / 100.0,
            ),
          )
          .toList();

      final ids = <int>{};
      final uniqueChapters = <ChapterModel>[];
      for (var chapter in initialChapters) {
        if (ids.add(chapter.id)) {
          uniqueChapters.add(chapter);
        }
      }
      chapters.assignAll(uniqueChapters);
    } catch (e) {
      if (e is DioException) {
        final status = e.response?.statusCode;
        final data = e.response?.data;
        Get.log('GET /users/me/toc 실패 → status:$status body:$data');
        final serverMessage = _extractServerMessage(data);
        errorMessage.value = status != null
            ? '[$status] ${serverMessage ?? e.message ?? '요청에 실패했습니다.'}'
            : (serverMessage ?? e.message ?? '요청에 실패했습니다.');
      } else {
        errorMessage.value = e.toString();
      }
      chapters.value = [];
    } finally {
      loading.value = false;
    }
  }

  String? _extractServerMessage(dynamic data) {
    if (data == null) return null;
    if (data is String) return data;
    if (data is Map<String, dynamic>) {
      if (data['message'] is List && data['message'].isNotEmpty) {
        return data['message'].first.toString();
      }
      if (data['message'] != null) return data['message'].toString();
      if (data['error'] != null) return data['error'].toString();
    }
    return data.toString();
  }

  // _calculateProgress 관련 로직은 loadUserContents 내부에 통합됨

  /// 챕터 카드 클릭 시 이벤트 핸들러
  void onChapterTap(ChapterModel chapter) {
    print("챕터 ${chapter.id} 클릭됨: ${chapter.title}");
    
    // 챕터별 채팅 컨트롤러에 로드 요청
    try {
      final chatController = Get.find<ChapterChatController>();
      chatController.loadQuestions(chapter.id);
    } catch (e) {
      Get.log("ChapterChatController not found: $e");
    }

    // 챕터 채팅 탭(인덱스 3)으로 이동
    changeTab(3);
  }

  /// 하단 탭 바 선택 변경 핸들러
  void changeTab(int index) {
    if (index == 0) {
      loadUserContents();
    }
    selectedTabIndex.value = index;
  }

  DateTime? lastPressedAt;

  Future<bool> onBackPressed() async {
    // 1. 챕터 채팅 탭(3)에 있는 경우 홈으로 복귀
    if (selectedTabIndex.value == 3) {
      changeTab(0);
      return false; // 앱 종료 방지
    }

    // 2. 다른 탭(0, 1, 2)에 있는 경우 -> 더블 탭 종료 로직
    final now = DateTime.now();
    if (lastPressedAt == null || 
        now.difference(lastPressedAt!) > const Duration(seconds: 2)) {
      lastPressedAt = now;
      ToastUtils.showInfoToast("'뒤로' 버튼을 한 번 더 누르면 종료됩니다.");
      return false; // 앱 종료 방지
    }

    return true; // 앱 종료 허용
  }
}

class ChapterModel {
  final int id;
  final String title;
  final String subtitle;
  final double progress;
  final int answeredQuestions;
  final int totalQuestions;

  ChapterModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.progress,
    this.answeredQuestions = 0,
    this.totalQuestions = 0,
  });
}

class ChapterProgressInfo {
  final int totalQuestions;
  final int answeredQuestions;

  const ChapterProgressInfo({
    required this.totalQuestions,
    required this.answeredQuestions,
  });

  double get progress =>
      totalQuestions == 0 ? 0.0 : answeredQuestions / totalQuestions;

  factory ChapterProgressInfo.zero() =>
      const ChapterProgressInfo(totalQuestions: 0, answeredQuestions: 0);
}
