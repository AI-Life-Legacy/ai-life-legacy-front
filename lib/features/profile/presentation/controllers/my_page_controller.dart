import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:ai_life_legacy/features/user/data/user_repository.dart';
import 'package:ai_life_legacy/features/user/data/models/user.dto.dart';
import 'package:ai_life_legacy/app/core/utils/token_storage.dart';
import 'package:ai_life_legacy/app/core/routes/app_routes.dart';

class MyPageController extends GetxController {
  final UserRepository _userRepository;

  MyPageController(this._userRepository);

  final RxBool isLoading = false.obs;
  
  // Profile state
  final RxString userName = '사용자님'.obs;
  final RxString userEmail = ''.obs;
  final RxInt chapterCount = 0.obs;
  final RxBool isCompleted = false.obs;

  // Notification state (local UI only)
  final RxBool isReminderEnabled = true.obs;
  final RxString reminderTime = '오전 9:00'.obs;
  final RxString errorMessage = ''.obs;

  bool get isViewerMode => TokenStorage.isViewerMode();

  @override
  void onInit() {
    super.onInit();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    if (isViewerMode) {
      userName.value = TokenStorage.getViewerAuthorName() ?? '작성자';
      return;
    }

    try {
      // Get chapter count from TOC
      final response = await _userRepository.getUserToc();
      chapterCount.value = response.data.length;
    } catch (e) {
      debugPrint('[MyPageController] _loadUserProfile error: $e');
    }
  }

  /// 로그아웃 처리
  Future<void> logout() async {
    try {
      // 모든 토큰 및 세션 정보 삭제 (accessToken, refreshToken, viewer 세션 등 포함)
      await TokenStorage.clearTokens();
      
      // 모든 라우트 스택 제거 후 로그인 페이지로 이동
      Get.offAllNamed(Routes.login);
    } catch (e) {
      debugPrint('[MyPageController] logout error: $e');
      // 에러가 나더라도 일단 로그인 페이지로 강제 이동
      Get.offAllNamed(Routes.login);
    }
  }

  /// 회원 탈퇴 처리
  Future<void> withdrawAccount() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      // 백엔드 명세 기준 요청 데이터 구성
      final dto = UserWithdrawalDto(
        withdrawalReason: "USER_REQUEST",
        withdrawalText: "사용자 요청으로 탈퇴",
      );

      // 실제 백엔드 DELETE /users/me 호출
      await _userRepository.deleteUser(dto);
      
      // 탈퇴 API 성공 응답을 받은 경우에만 세션 정리 및 이동
      await TokenStorage.clearTokens();
      
      // 화면 이동
      Get.offAllNamed(Routes.login);
    } catch (e) {
      debugPrint('[MyPageController] withdrawAccount error: $e');
      // 실패 시에는 토큰 삭제나 화면 이동 없이 에러 메시지 저장
      errorMessage.value = '회원 탈퇴에 실패했습니다. 다시 시도해주세요.';
    } finally {
      isLoading.value = false;
    }
  }

  void toggleReminder(bool value) {
    isReminderEnabled.value = value;
  }
}


