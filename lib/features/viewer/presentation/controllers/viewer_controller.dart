import 'package:get/get.dart';
import 'package:ai_life_legacy/features/viewer/data/viewer_api.dart';
import 'package:ai_life_legacy/app/core/routes/app_routes.dart';

class ViewerController extends GetxController {
  final ViewerApi _api;

  ViewerController(this._api);

  final viewerCode = ''.obs;
  final writerName = ''.obs;
  final selectedRole = ''.obs;
  final messages = RxList<Map<String, String>>([]).obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  Future<void> verifyCode(String code) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final response = await _api.verifyCode(code);
      if (response.data['valid'] == true) {
        viewerCode.value = code;
        writerName.value = response.data['writerName'] ?? '작성자';
        Get.toNamed(Routes.viewerRole);
      } else {
        errorMessage.value = '유효하지 않은 코드입니다.';
      }
    } catch (e) {
      errorMessage.value = '코드 검증에 실패했습니다.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> setRole(String role) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final response = await _api.setRole(viewerCode.value, role);
      if (response.statusCode == 200) {
        selectedRole.value = role;
        Get.toNamed(Routes.viewerChat);
      }
    } catch (e) {
      errorMessage.value = '관계 설정에 실패했습니다.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendMessage(String text) async {
    if (text.isEmpty) return;

    messages.value.add({'role': 'user', 'text': text});
    messages.refresh();

    try {
      isLoading.value = true;
      errorMessage.value = '';
      final response = await _api.chat(
        code: viewerCode.value,
        message: text,
      );
      if (response.statusCode == 200) {
        messages.value.add({
          'role': 'ai',
          'text': response.data['aiReply'] ?? '아바타가 대답할 수 없는 상태입니다.',
        });
        messages.refresh();
      }
    } catch (e) {
      errorMessage.value = '메시지 전송에 실패했습니다.';
    } finally {
      isLoading.value = false;
    }
  }
}
