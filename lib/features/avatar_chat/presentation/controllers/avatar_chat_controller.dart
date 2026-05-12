import 'package:get/get.dart';
import 'package:ai_life_legacy/features/avatar_chat/data/avatar_chat_api.dart';

class AvatarChatController extends GetxController {
  final AvatarChatApi _api;

  AvatarChatController(this._api);

  final messages = RxList<Map<String, String>>([]).obs;
  final isLoading = false.obs;
  final viewerCode = ''.obs;
  final errorMessage = ''.obs;

  Future<void> sendMessage(String text) async {
    if (text.isEmpty) return;

    messages.value.add({'role': 'user', 'text': text});
    messages.refresh();

    try {
      errorMessage.value = '';
      isLoading.value = true;
      final response = await _api.chat(text);
      if (response.statusCode == 200) {
        messages.value.add({
          'role': 'ai',
          'text': response.data['aiReply'] ?? '아바타가 아직 준비 중입니다.',
        });
        messages.refresh();
      }
    } catch (e) {
      errorMessage.value = '메시지 전송에 실패했습니다.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> generateViewerCode() async {
    try {
      final response = await _api.getViewerCode();
      if (response.statusCode == 200) {
        viewerCode.value = response.data['code'];
      }
    } catch (e) {
      errorMessage.value = '공유 코드를 생성하지 못했습니다.';
    }
  }
}
