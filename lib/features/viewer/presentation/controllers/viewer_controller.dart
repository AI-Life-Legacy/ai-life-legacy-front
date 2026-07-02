import 'package:get/get.dart';
import 'package:ai_life_legacy/features/viewer/data/viewer_api.dart';
import 'package:ai_life_legacy/app/core/routes/app_routes.dart';
import 'package:ai_life_legacy/app/core/utils/token_storage.dart';

class ViewerController extends GetxController {
  final ViewerApi _api;

  ViewerController(this._api);

  final viewerCode = ''.obs;
  final writerName = ''.obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  Future<void> verifyCode(String code) async {
    if (code.trim().length != 6) {
      errorMessage.value = '6자리 코드를 정확히 입력해주세요.';
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _api.viewerLogin(code.trim());

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        Map<String, dynamic>? resultData;

        if (data is Map<String, dynamic>) {
          if (data.containsKey('result')) {
            resultData = data['result'] as Map<String, dynamic>?;
          } else {
            resultData = data;
          }
        }

        if (resultData != null && resultData.containsKey('accessToken')) {
          final token = resultData['accessToken'] as String;
          final authorInfo = resultData['authorInfo'] as Map<String, dynamic>?;
          final authorName = authorInfo?['name'] as String? ?? '작성자';
          final authorIntro = authorInfo?['intro'] as String? ?? '';

          // 기존 작성자 토큰 클리어 후 뷰어 모드로 저장
          await TokenStorage.clearTokens();
          await TokenStorage.saveViewerAccessToken(token);
          await TokenStorage.saveViewerAuthorName(authorName);
          await TokenStorage.saveViewerAuthorIntro(authorIntro);
          await TokenStorage.saveIsViewerMode(true);

          viewerCode.value = code.trim();
          writerName.value = authorName;

          // 곧바로 뷰어 아바타 채팅(AvatarChatPage) 라우트로 이동!
          Get.offNamed(Routes.viewerChat);
        } else {
          errorMessage.value = '로그인 응답 형식이 올바르지 않습니다.';
        }
      } else {
        errorMessage.value = '유효하지 않은 코드입니다.';
      }
    } catch (e) {
      errorMessage.value = '잘못된 코드이거나 로그인에 실패했습니다.';
    } finally {
      isLoading.value = false;
    }
  }
}
