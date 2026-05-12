import 'package:get/get.dart';
import 'package:ai_life_legacy/features/auth/presentation/controllers/auth_controller.dart';
import 'package:ai_life_legacy/features/user/data/user_repository.dart';
import 'package:ai_life_legacy/features/user/data/models/user.dto.dart';
import 'package:ai_life_legacy/app/core/utils/toast_utils.dart';

class MyPageController extends GetxController {
  final UserRepository _userRepo;
  final AuthController _authController = Get.find<AuthController>();

  MyPageController(this._userRepo);

  final RxBool isLoading = false.obs;

  /// 로그아웃 처리
  /// AuthController의 로그아웃 로직을 호출하여 로그인 화면으로 이동합니다.
  Future<void> logout() async {
    await _authController.logout();
    // AuthController.logout handles navigation to Login
  }

  /// 회원 탈퇴 처리
  /// - API 호출 및 로컬 데이터 정리(로그아웃)
  /// - 완료 시 안내 메시지 표시
  Future<void> withdrawAccount() async {
    isLoading.value = true;
    try {
      // 1. API 호출 (회원 탈퇴 요청)
      final dto = UserWithdrawalDto(
        withdrawalReason: "USER_REQUEST",
        withdrawalText: "사용자 요청에 의한 탈퇴",
      );
      await _userRepo.deleteUser(dto);

      // 2. 로그아웃 처리 (토큰 삭제 및 상태 초기화)
      await _authController.logout();

      // 3. 메시지 표시
      ToastUtils.showInfoToast('회원 탈퇴가 완료되었습니다.');
    } catch (e) {
      ToastUtils.showErrorToast('회원 탈퇴 중 오류가 발생했습니다.');
      print('[MyPageController] withdrawAccount error: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
