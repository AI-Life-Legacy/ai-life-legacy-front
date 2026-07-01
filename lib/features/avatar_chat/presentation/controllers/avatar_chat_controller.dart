import 'dart:convert';

import 'package:ai_life_legacy/app/core/routes/app_routes.dart';
import 'package:ai_life_legacy/app/core/utils/token_storage.dart';
import 'package:ai_life_legacy/features/autobiography/presentation/controllers/autobiography_controller.dart';
import 'package:ai_life_legacy/features/avatar_chat/data/avatar_chat_api.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AvatarChatStep { roleSelect, intro, chat }

class AvatarRole {
  final String id;
  final String name;
  final String group;
  final String sub;
  final String desc;
  final String greet;
  final String sample;
  final String emoji;

  AvatarRole({
    required this.id,
    required this.name,
    required this.group,
    required this.sub,
    required this.desc,
    required this.greet,
    required this.sample,
    required this.emoji,
  });
}

class AvatarChatController extends GetxController {
  final AvatarChatApi _api;

  AvatarChatController(this._api);

  final List<AvatarRole> roles = [
    AvatarRole(
      id: 'curator',
      name: '큐레이터',
      group: '기본',
      sub: '차분한 안내자',
      desc: '기억의 흐름을 정리하고, 다음 질문을 부드럽게 이어주는 기본 대화 상대입니다.',
      greet: '안녕하세요. 당신의 이야기를 함께 정리하는 큐레이터예요. 오늘은 어떤 기억이 궁금하신가요?',
      sample: '그 장면은 이야기의 시작점처럼 느껴져요. 그때 가장 선명하게 남아 있는 소리나 표정이 있었나요?',
      emoji: '📝',
    ),
    AvatarRole(
      id: 'father',
      name: '아버지',
      group: '가족',
      sub: '든든한 말투',
      desc: '짧고 다정한 반말로, 오래 알고 지낸 사람처럼 편안하게 물어봅니다.',
      greet: '그래, 궁금한 거 있으면 물어봐. 기억나는 만큼 천천히 얘기해줄게.',
      sample: '그때는 말이야, 별거 아닌 일 같아도 마음에는 오래 남는 법이더라.',
      emoji: '👨',
    ),
    AvatarRole(
      id: 'mother',
      name: '어머니',
      group: '가족',
      sub: '따뜻한 말투',
      desc: '세심하고 포근한 말투로 감정과 분위기를 먼저 살펴주는 대화 상대입니다.',
      greet: '왔구나. 오늘은 어떤 이야기가 듣고 싶니? 천천히 말해도 괜찮아.',
      sample: '그때 네 표정이 아직도 생각나. 힘들었지만 참 잘 버텼던 시간이었지.',
      emoji: '👩',
    ),
    AvatarRole(
      id: 'self',
      name: '나 자신',
      group: '가족',
      sub: '내면의 목소리',
      desc: '현재의 내가 과거의 나에게 묻듯, 조용하고 성찰적인 톤으로 답합니다.',
      greet: '안녕. 나에게 묻고 싶은 시간이 있다면 같이 돌아가 보자.',
      sample: '나는 그때 조용한 척했지만, 사실은 누군가 알아봐 주길 바랐던 것 같아.',
      emoji: '🌿',
    ),
    AvatarRole(
      id: 'sister',
      name: '누나 · 언니',
      group: '가족',
      sub: '가까운 장난기',
      desc: '친근하고 살짝 장난스러운 말투로, 기억의 디테일을 자연스럽게 끌어냅니다.',
      greet: '왔어? 뭐가 궁금해서 찾아왔어? 내가 기억나는 만큼 말해볼게.',
      sample: '너 그때 진짜 진지했잖아. 다들 웃었는데 너만 끝까지 몰입했던 거 기억나.',
      emoji: '👧',
    ),
    AvatarRole(
      id: 'brother',
      name: '형 · 오빠',
      group: '가족',
      sub: '담백한 말투',
      desc: '무심한 듯 다정하게, 핵심을 짚으며 기억을 다시 꺼내주는 대화 상대입니다.',
      greet: '그래, 물어봐. 기억나는 건 최대한 솔직하게 얘기해줄게.',
      sample: '그건 아직도 기억나. 별말 안 했지만, 그날 분위기는 꽤 오래 남았거든.',
      emoji: '👦',
    ),
  ];

  final step = AvatarChatStep.roleSelect.obs;
  final selectedRoleId = 'curator'.obs;
  final sessionId = ''.obs;

  final messages = <Map<String, String>>[].obs;
  final isLoading = false.obs;
  final viewerCode = ''.obs;
  final errorMessage = ''.obs;

  final pageCount = RxnInt();
  final totalChapters = RxnInt();

  final authorName = '사용자'.obs;
  final authorIntro = ''.obs;

  AvatarRole get selectedRole {
    return roles.firstWhere(
      (role) => role.id == selectedRoleId.value,
      orElse: () => roles.first,
    );
  }

  @override
  void onInit() {
    super.onInit();
    _loadSelectedRole();
    _loadAuthorInfo();
    _checkPermissions();
  }

  void _checkPermissions() {
    final currentRoute = Get.currentRoute;
    final isViewer = TokenStorage.isViewerMode();

    if (currentRoute == Routes.viewerChat) {
      if (!isViewer) {
        debugPrint(
          '[AvatarChatController] Access denied to viewer_chat for writer.',
        );
        Future.microtask(() => Get.offAllNamed(Routes.home));
      }
      return;
    }

    if (currentRoute == Routes.avatarChat && isViewer) {
      debugPrint(
        '[AvatarChatController] Access denied to avatar_chat for viewer.',
      );
      Future.microtask(() => Get.offAllNamed(Routes.viewerChat));
      return;
    }

    if (currentRoute == Routes.avatarChat &&
        Get.isRegistered<AutobiographyController>()) {
      final autoBioController = Get.find<AutobiographyController>();
      if (!autoBioController.isUnlocked.value) {
        debugPrint('[AvatarChatController] Autobiography is locked.');
        Future.microtask(() => Get.offNamed(Routes.locked));
      }
    }
  }

  void _loadAuthorInfo() {
    if (TokenStorage.isViewerMode()) {
      authorName.value = TokenStorage.getViewerAuthorName() ?? '작성자';
      authorIntro.value = TokenStorage.getViewerAuthorIntro() ?? '';
      return;
    }

    authorName.value = '사용자';
    authorIntro.value = '';
  }

  Future<void> _loadSelectedRole() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedRoleId = prefs.getString('last_selected_role_id');
      if (savedRoleId != null && roles.any((role) => role.id == savedRoleId)) {
        selectedRoleId.value = savedRoleId;
      }
    } catch (_) {
      // Keep the default role if local storage is unavailable.
    }

    step.value = AvatarChatStep.roleSelect;
    loadBiographyStats();
  }

  Future<void> loadBiographyStats() async {
    if (TokenStorage.isViewerMode()) {
      totalChapters.value = 5;
      pageCount.value = 120;
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedPageCount = prefs.getInt('pageCount');
      if (savedPageCount != null) {
        pageCount.value = savedPageCount;
      }

      final response = await _api.getToc();
      if (response.statusCode != 200) return;

      final raw = response.data;
      final result = raw is Map<String, dynamic> && raw.containsKey('result')
          ? raw['result']
          : raw;
      if (result is! Map<String, dynamic>) return;

      final chapters = result['totalChapters'];
      if (chapters is int) {
        totalChapters.value = chapters;
      } else if (chapters != null) {
        totalChapters.value = int.tryParse(chapters.toString());
      }

      final pages = result['pageCount'] ?? result['page_count'];
      if (pages is int) {
        pageCount.value = pages;
        await prefs.setInt('pageCount', pages);
      } else if (pages != null) {
        final parsed = int.tryParse(pages.toString());
        if (parsed != null) {
          pageCount.value = parsed;
          await prefs.setInt('pageCount', parsed);
        }
      }
    } catch (_) {
      // Stats are decorative, so the chat can continue without them.
    }
  }

  Future<void> selectRole(String roleId) async {
    if (selectedRoleId.value == roleId) return;

    selectedRoleId.value = roleId;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_selected_role_id', roleId);
    } catch (_) {
      // Ignore persistence failures.
    }
  }

  void goToIntro() {
    step.value = AvatarChatStep.intro;
  }

  void goToRoleSelect() {
    step.value = AvatarChatStep.roleSelect;
  }

  void handleBack() {
    if (TokenStorage.isViewerMode()) {
      if (step.value == AvatarChatStep.roleSelect) {
        Get.offAllNamed(Routes.main);
      } else if (step.value == AvatarChatStep.intro) {
        step.value = AvatarChatStep.roleSelect;
      } else {
        step.value = AvatarChatStep.intro;
      }
      return;
    }

    if (step.value == AvatarChatStep.roleSelect) {
      Get.back();
    } else if (step.value == AvatarChatStep.intro) {
      step.value = AvatarChatStep.roleSelect;
    } else {
      step.value = AvatarChatStep.intro;
    }
  }

  void startChat() {
    resetSession();
    step.value = AvatarChatStep.chat;
  }

  void resetSession() {
    sessionId.value = 'avatar_${DateTime.now().millisecondsSinceEpoch}';
    errorMessage.value = '';
    viewerCode.value = '';
    _initChatWithGreet();
  }

  void _initChatWithGreet() {
    messages.assignAll([
      {'role': 'ai', 'text': selectedRole.greet},
    ]);
  }

  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || isLoading.value) return;

    messages.add({'role': 'user', 'text': trimmed});

    try {
      errorMessage.value = '';
      isLoading.value = true;

      final response = await _api.chat(
        trimmed,
        role: selectedRoleId.value,
        roleId: selectedRoleId.value,
        sessionId: sessionId.value,
      );

      final httpStatus = response.statusCode ?? 0;
      final data = response.data;
      final success = (httpStatus >= 200 && httpStatus < 300) ||
          _hasSuccessfulEnvelope(data);

      if (!success) {
        _appendFallbackError();
        return;
      }

      final parsed = _parseChatResponse(data);
      final answer = parsed.answer?.trim();

      if (answer == null || answer.isEmpty) {
        debugPrint('[AvatarChat] Success response but answer is empty: $data');
        _appendFallbackError();
        return;
      }

      if (parsed.sessionId != null && parsed.sessionId!.isNotEmpty) {
        sessionId.value = parsed.sessionId!;
      }

      messages.removeWhere(
        (message) =>
            message['role'] == 'ai' && message['text'] == _fallbackErrorMessage,
      );
      messages.add({'role': 'ai', 'text': answer});
    } catch (error, stack) {
      debugPrint('[AvatarChat] Exception in sendMessage: $error');
      debugPrint(stack.toString());
      _appendFallbackError();
    } finally {
      isLoading.value = false;
    }
  }

  bool _hasSuccessfulEnvelope(dynamic data) {
    final map = _asMap(data);
    if (map == null) return false;

    final status = map['status'];
    final result = map['result'];
    return (status == 200 || status == '200') &&
        result is Map<String, dynamic> &&
        result['answer'] != null;
  }

  _ParsedChatResponse _parseChatResponse(dynamic data) {
    final map = _asMap(data);
    if (map == null) return const _ParsedChatResponse();

    final result = map['result'];
    String? answer;
    String? parsedSessionId;

    if (result is Map<String, dynamic>) {
      answer = _stringValue(result['answer'] ?? result['message']);
      parsedSessionId =
          _stringValue(result['sessionId'] ?? result['session_id']);
    }

    answer ??= _stringValue(map['answer'] ?? map['aiReply']);
    parsedSessionId ??= _stringValue(map['sessionId'] ?? map['session_id']);

    return _ParsedChatResponse(
      answer: answer,
      sessionId: parsedSessionId,
    );
  }

  Map<String, dynamic>? _asMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is String) {
      try {
        final decoded = jsonDecode(data);
        if (decoded is Map<String, dynamic>) return decoded;
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  String? _stringValue(dynamic value) {
    if (value == null) return null;
    return value.toString();
  }

  void _appendFallbackError() {
    errorMessage.value = _fallbackErrorMessage;
    messages.add({'role': 'ai', 'text': _fallbackErrorMessage});
  }

  Future<void> generateViewerCode() async {
    try {
      final response = await _api.getViewerCode();
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          viewerCode.value =
              (data['code'] ?? data['result']?['code'] ?? '').toString();
        }
      }
    } catch (_) {
      errorMessage.value = '공유 코드를 생성하지 못했습니다. 잠시 후 다시 시도해주세요.';
    }
  }
}

class _ParsedChatResponse {
  final String? answer;
  final String? sessionId;

  const _ParsedChatResponse({
    this.answer,
    this.sessionId,
  });
}

const _fallbackErrorMessage = '아바타 응답을 불러오지 못했습니다. 잠시 후 다시 시도해주세요.';
