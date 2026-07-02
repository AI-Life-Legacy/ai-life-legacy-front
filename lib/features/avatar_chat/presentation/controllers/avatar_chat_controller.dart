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

AvatarRole _sisterRole(String name) {
  return AvatarRole(
    id: 'sister',
    name: name,
    group: '가족',
    sub: '가까운 장난기',
    desc: '친근하고 가벼운 리듬으로 자연스럽게 기억의 디테일을 꺼냅니다.',
    greet: '궁금해서 찾아왔어. 그때 이야기, 조금 더 들려줘.',
    sample: '그때 분위기 진짜 선명했을 것 같은데, 뭐가 제일 기억나?',
    emoji: 'SI',
  );
}

AvatarRole _brotherRole(String name) {
  return AvatarRole(
    id: 'brother',
    name: name,
    group: '가족',
    sub: '담백한 말투',
    desc: '과하게 감상적이지 않게, 핵심 장면을 다시 떠올리도록 돕습니다.',
    greet: '편하게 말해줘. 기억나는 것부터 하나씩 들어볼게.',
    sample: '그날의 공기나 사람들 표정은 아직 남아 있어?',
    emoji: 'BR',
  );
}

class AvatarChatController extends GetxController {
  final AvatarChatApi _api;

  AvatarChatController(this._api);

  List<AvatarRole> get roles {
    final gender = authorGender.value;
    final siblingRoles = <AvatarRole>[];

    if (gender == '남성') {
      siblingRoles.addAll([
        _sisterRole('누나 톤'),
        _brotherRole('형 톤'),
      ]);
    } else if (gender == '여성') {
      siblingRoles.addAll([
        _sisterRole('언니 톤'),
        _brotherRole('오빠 톤'),
      ]);
    }

    return [
      AvatarRole(
        id: 'curator',
        name: '기록 큐레이터',
        group: '기본',
        sub: '차분한 안내',
        desc: '기억의 흐름을 정리하고 다음 질문을 부드럽게 이어주는 기본 대화 모드입니다.',
        greet: '안녕하세요. 오늘은 어떤 장면부터 꺼내볼까요? 천천히 말해도 괜찮아요.',
        sample: '그 장면에서 가장 먼저 떠오르는 소리나 색이 있었나요?',
        emoji: 'CU',
      ),
      AvatarRole(
        id: 'father',
        name: '아버지 톤',
        group: '가족',
        sub: '든든한 말투',
        desc: '짧고 담백한 질문으로 오래 묻어둔 기억을 편안하게 열어줍니다.',
        greet: '그래, 궁금한 걸 물어볼게. 기억나는 만큼만 솔직하게 말해줘.',
        sample: '그때는 별일 아닌 것 같았어도 마음에는 오래 남았던 것 같아.',
        emoji: 'FA',
      ),
      AvatarRole(
        id: 'mother',
        name: '어머니 톤',
        group: '가족',
        sub: '따뜻한 말투',
        desc: '감정과 분위기를 먼저 살피며 이야기의 온도를 맞춰주는 대화 모드입니다.',
        greet: '오늘은 어떤 이야기를 남기고 싶니? 편한 것부터 말해줘.',
        sample: '그때 마음은 아직도 선명하게 남아 있을 것 같아.',
        emoji: 'MO',
      ),
      AvatarRole(
        id: 'self',
        name: '나 자신',
        group: '가족',
        sub: '내면의 목소리',
        desc: '현재의 내가 과거의 나에게 묻듯 조용하고 성찰적인 톤으로 대화합니다.',
        greet: '잠깐 멈춰서 그 시절의 나를 다시 만나볼까요?',
        sample: '그때의 나는 무엇을 가장 지키고 싶었을까?',
        emoji: 'ME',
      ),
      ...siblingRoles,
    ];
  }

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
  final authorGender = ''.obs;

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
        debugPrint('[AvatarChatController] Access denied to viewer_chat.');
        Future.microtask(() => Get.offAllNamed(Routes.home));
      }
      return;
    }

    if (currentRoute == Routes.avatarChat && isViewer) {
      debugPrint('[AvatarChatController] Redirect viewer to viewer_chat.');
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

  Future<void> _loadAuthorInfo() async {
    if (TokenStorage.isViewerMode()) {
      authorName.value = TokenStorage.getViewerAuthorName() ?? '작성자';
      authorIntro.value = TokenStorage.getViewerAuthorIntro() ?? '';
      authorGender.value = '';
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      authorName.value = prefs.getString('author_name') ?? '사용자';
      authorGender.value = prefs.getString('author_gender') ?? '';
    } catch (_) {
      authorName.value = '사용자';
      authorGender.value = '';
    }
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
      if (savedPageCount != null) pageCount.value = savedPageCount;

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
      final navigator = Get.key.currentState;
      if (navigator?.canPop() == true) {
        navigator!.pop();
      } else {
        Get.offAllNamed(Routes.home);
      }
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

    return _ParsedChatResponse(answer: answer, sessionId: parsedSessionId);
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
      errorMessage.value = '공유 코드를 만들지 못했습니다. 잠시 후 다시 시도해주세요.';
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

const _fallbackErrorMessage = '응답을 불러오지 못했습니다. 잠시 후 다시 시도해주세요.';
