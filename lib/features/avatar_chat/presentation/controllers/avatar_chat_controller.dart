import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ai_life_legacy/features/avatar_chat/data/avatar_chat_api.dart';
import 'package:ai_life_legacy/app/core/utils/token_storage.dart';
import 'package:ai_life_legacy/app/core/routes/app_routes.dart';
import 'package:ai_life_legacy/features/autobiography/presentation/controllers/autobiography_controller.dart';

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
      sub: 'Life Legacy 기본',
      desc: '3인칭 존댓말. 작성자 님의 이야기를 정리해 차분하게 안내합니다.',
      greet: '안녕하세요. 저는 작성자 님의 이야기를 안내하는 큐레이터예요. 어떤 이야기가 궁금하신가요?',
      sample: '작성자 님께서는 아름다운 마을에서 자라셨어요. 어릴 적 가장 선명한 기억은 소중한 추억이라고 말씀하셨답니다.',
      emoji: '✦',
    ),
    AvatarRole(
      id: 'father',
      name: '아버지',
      group: '가족',
      sub: '아빠로 부르는 관계',
      desc: '1인칭 반말. "아빠가 있지," 같은 다정하고 담백한 말투.',
      greet: '왔구나. 아빠다. 뭐가 궁금해서 왔어?',
      sample: '아빠가 네 나이쯤엔 말이야, 열심히 일하면서 살았지. 별거 아닌 것 같아도 그게 다 지금 생각하면 그립더라.',
      emoji: '◐',
    ),
    AvatarRole(
      id: 'mother',
      name: '어머니',
      group: '가족',
      sub: '엄마로 부르는 관계',
      desc: '1인칭 반말. "엄마가 있잖니," 다정하고 포근한 말투.',
      greet: '왔어? 엄마야. 오늘은 무슨 얘기 하고 싶어서 왔니?',
      sample: '엄마는 네 살쯤, 뒷마당 나무 아래서 놀던 오후가 제일 선명해. 그 냄새, 단내. 엄마가 제일 좋아하는 기억이야.',
      emoji: '◑',
    ),
    AvatarRole(
      id: 'self',
      name: '나',
      group: '가족',
      sub: '스스로를 돌아보는 나',
      desc: '1인칭 존댓말. "저는 ~였어요." 회고하듯 담담한 말투.',
      greet: '안녕. 나야. 내 안의 어느 시간이 궁금한 거야?',
      sample: '나는 그때, 교실 창밖으로 해 지는 걸 가만히 보곤 했어. 아이들 떠든 소리가 사라진 그 짧은 정적이 참 좋았어.',
      emoji: '◉',
    ),
    AvatarRole(
      id: 'sister',
      name: '누나 · 언니',
      group: '가족',
      sub: '손위 자매로 부르는 관계',
      desc: '1인칭 반말. "있잖아," 조금 장난스럽고 편안한 말투.',
      greet: '어, 왔어? 누나야. 뭐 물어보게?',
      sample: '있잖아, 내가 어릴 적 여름에 말이야, 나무 밑에서 책 읽다가 잠들었었거든. 일어나 보니 엄마가 옆에 앉아계셨어. 그 장면이 왜 이렇게 오래 남지.',
      emoji: '◒',
    ),
    AvatarRole(
      id: 'brother',
      name: '형 · 오빠',
      group: '가족',
      sub: '손위 형제로 부르는 관계',
      desc: '1인칭 반말. "야, 그게 말이지," 덤덤하지만 따뜻한 말투.',
      greet: '야, 왔냐. 형이야. 궁금한 거 있어?',
      sample: '야, 그거 말이지. 내가 일곱 살인가 여덟 살인가, 마당 나무 밑에서 동생이랑 둘이 낮잠 잔 적 있거든. 그 냄새가 아직도 안 잊혀진다.',
      emoji: '◓',
    ),
  ];

  final step = AvatarChatStep.roleSelect.obs;
  final selectedRoleId = 'curator'.obs;
  final sessionId = ''.obs;
  
  final messages = <Map<String, String>>[].obs;
  final isLoading = false.obs;
  final viewerCode = ''.obs;
  final errorMessage = ''.obs;

  // Real biography statistics loaded from DB/SharedPreferences
  final pageCount = RxnInt();
  final totalChapters = RxnInt();

  final authorName = '사용자'.obs;
  final authorIntro = ''.obs;

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
        debugPrint('[AvatarChatController] Access denied to viewer_chat for writer. Redirecting to home.');
        Future.microtask(() => Get.offAllNamed(Routes.home));
        return;
      }
    } else if (currentRoute == Routes.avatarChat) {
      if (isViewer) {
        debugPrint('[AvatarChatController] Access denied to avatar_chat for viewer. Redirecting to viewer_chat.');
        Future.microtask(() => Get.offAllNamed(Routes.viewerChat));
        return;
      }
      
      // For writers, check if unlocked (server status check already done in HomeController/AutobiographyController)
      final autoBioController = Get.find<AutobiographyController>();
      if (!autoBioController.isUnlocked.value) {
        debugPrint('[AvatarChatController] Autobiography not completed. Redirecting to locked page.');
        Future.microtask(() => Get.offNamed(Routes.locked));
        return;
      }
    }
  }

  void _loadAuthorInfo() {
    if (TokenStorage.isViewerMode()) {
      authorName.value = TokenStorage.getViewerAuthorName() ?? '작성자';
      authorIntro.value = TokenStorage.getViewerAuthorIntro() ?? '';
    } else {
      authorName.value = '사용자'; // Default author name for writer mode
      authorIntro.value = '';
    }
  }

  Future<void> _loadSelectedRole() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedRoleId = prefs.getString('last_selected_role_id');
      if (savedRoleId != null && roles.any((r) => r.id == savedRoleId)) {
        selectedRoleId.value = savedRoleId;
      }
    } catch (e) {
      // SharedPreferences 불러오기 실패 시 기본값 유지
    }
    // 최초 진입 시 step은 roleSelect로 지정
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
      if (response.statusCode == 200) {
        final raw = response.data;
        final result = raw is Map<String, dynamic> && raw.containsKey('result')
            ? raw['result']
            : raw;
        if (result is Map<String, dynamic>) {
          final tc = result['totalChapters'];
          if (tc is int) {
            totalChapters.value = tc;
          } else if (tc != null) {
            totalChapters.value = int.tryParse(tc.toString());
          }

          final pc = result['pageCount'] ?? result['page_count'];
          if (pc is int) {
            pageCount.value = pc;
            await prefs.setInt('pageCount', pc);
          } else if (pc != null) {
            final parsed = int.tryParse(pc.toString());
            if (parsed != null) {
              pageCount.value = parsed;
              await prefs.setInt('pageCount', parsed);
            }
          }
        }
      }
    } catch (e) {
      // 무시
    }
  }

  Future<void> selectRole(String roleId) async {
    if (selectedRoleId.value == roleId) return;
    
    selectedRoleId.value = roleId;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_selected_role_id', roleId);
    } catch (e) {
      // SharedPreferences 저장 실패 시 무시
    }
  }

  AvatarRole get selectedRole => roles.firstWhere((r) => r.id == selectedRoleId.value, orElse: () => roles[0]);

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
      } else if (step.value == AvatarChatStep.chat) {
        step.value = AvatarChatStep.intro;
      }
    } else {
      if (step.value == AvatarChatStep.roleSelect) {
        Get.back();
      } else if (step.value == AvatarChatStep.intro) {
        step.value = AvatarChatStep.roleSelect;
      } else if (step.value == AvatarChatStep.chat) {
        step.value = AvatarChatStep.intro;
      }
    }
  }

  void startChat() {
    resetSession();
    step.value = AvatarChatStep.chat;
  }

  void resetSession() {
    sessionId.value = 'avatar_${DateTime.now().millisecondsSinceEpoch}';
    errorMessage.value = '';
    _initChatWithGreet();
  }

  void _initChatWithGreet() {
    final role = selectedRole;
    messages.assignAll([
      {'role': 'ai', 'text': role.greet}
    ]);
  }

  Future<void> sendMessage(String text) async {
    if (text.isEmpty) return;

    messages.add({'role': 'user', 'text': text});

    try {
      errorMessage.value = '';
      isLoading.value = true;
      final response = await _api.chat(
        text,
        role: selectedRoleId.value,
        roleId: selectedRoleId.value,
        sessionId: sessionId.value,
      );

      final httpStatus = response.statusCode ?? 0;
      final isHttpStatusSuccess = httpStatus >= 200 && httpStatus < 300;

      bool isResponseStatusSuccess = false;
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final statusValue = data['status'];
        final result = data['result'];
        if ((statusValue == 200 || statusValue == '200') &&
            result is Map<String, dynamic> &&
            result['answer'] != null) {
          isResponseStatusSuccess = true;
        }
      } else if (data is String) {
        try {
          final decoded = jsonDecode(data);
          if (decoded is Map<String, dynamic>) {
            final statusValue = decoded['status'];
            final result = decoded['result'];
            if ((statusValue == 200 || statusValue == '200') &&
                result is Map<String, dynamic> &&
                result['answer'] != null) {
              isResponseStatusSuccess = true;
            }
          }
        } catch (_) {}
      }

      if (isHttpStatusSuccess || isResponseStatusSuccess) {
        String? answer;
        String? parsedSessionId;
        bool? parsedContextUsed;

        if (data is Map<String, dynamic>) {
          final result = data['result'];

          // 파싱 우선순위:
          // 1. response.data['result']['answer']
          // 2. response.data['answer']
          // 3. response.data['result']['message']
          // response.data['message']는 "Success"일 수 있으므로 AI 답변으로 쓰지 않음
          if (result is Map<String, dynamic> && result['answer'] != null) {
            answer = result['answer'].toString();
          } else if (data['answer'] != null) {
            answer = data['answer'].toString();
          } else if (result is Map<String, dynamic> && result['message'] != null) {
            answer = result['message'].toString();
          } else if (data['aiReply'] != null) {
            answer = data['aiReply'].toString();
          }

          // sessionId 파싱 (Shape A, B, C)
          if (result is Map<String, dynamic>) {
            final sid = result['sessionId'] ?? result['session_id'];
            if (sid != null) {
              parsedSessionId = sid.toString();
            }
          }
          if (parsedSessionId == null && data['sessionId'] != null) {
            parsedSessionId = data['sessionId'].toString();
          }
          if (parsedSessionId == null && data['session_id'] != null) {
            parsedSessionId = data['session_id'].toString();
          }

          // contextUsed 파싱 (Shape A, B, C)
          if (result is Map<String, dynamic>) {
            final cu = result['contextUsed'] ?? result['context_used'];
            if (cu is bool) {
              parsedContextUsed = cu;
            } else if (cu != null) {
              parsedContextUsed = cu.toString().toLowerCase() == 'true';
            }
          }
          if (parsedContextUsed == null) {
            final cu = data['contextUsed'] ?? data['context_used'];
            if (cu is bool) {
              parsedContextUsed = cu;
            } else if (cu != null) {
              parsedContextUsed = cu.toString().toLowerCase() == 'true';
            }
          }
        } else if (data is String) {
          try {
            final decoded = jsonDecode(data);
            if (decoded is Map<String, dynamic>) {
              final result = decoded['result'];
              if (result is Map<String, dynamic> && result['answer'] != null) {
                answer = result['answer'].toString();
              } else if (decoded['answer'] != null) {
                answer = decoded['answer'].toString();
              } else if (result is Map<String, dynamic> && result['message'] != null) {
                answer = result['message'].toString();
              } else if (decoded['aiReply'] != null) {
                answer = decoded['aiReply'].toString();
              }

              if (result is Map<String, dynamic>) {
                final sid = result['sessionId'] ?? result['session_id'];
                if (sid != null) parsedSessionId = sid.toString();
              }
              if (parsedSessionId == null && decoded['sessionId'] != null) {
                parsedSessionId = decoded['sessionId'].toString();
              }
              if (parsedSessionId == null && decoded['session_id'] != null) {
                parsedSessionId = decoded['session_id'].toString();
              }

              if (result is Map<String, dynamic>) {
                final cu = result['contextUsed'] ?? result['context_used'];
                if (cu is bool) {
                  parsedContextUsed = cu;
                } else if (cu != null) {
                  parsedContextUsed = cu.toString().toLowerCase() == 'true';
                }
              }
              if (parsedContextUsed == null) {
                final cu = decoded['contextUsed'] ?? decoded['context_used'];
                if (cu is bool) {
                  parsedContextUsed = cu;
                } else if (cu != null) {
                  parsedContextUsed = cu.toString().toLowerCase() == 'true';
                }
              }
            }
          } catch (_) {}
        }

        // 디버깅 로그 추가
        debugPrint('[AvatarChat] RAW response.data: $data');
        debugPrint('[AvatarChat] Parsed answer: $answer');
        debugPrint('[AvatarChat] Parsed sessionId: $parsedSessionId');
        debugPrint('[AvatarChat] Parsed contextUsed: $parsedContextUsed');

        // answer.trim().isNotEmpty 이면 성공 처리
        if (answer != null && answer.trim().isNotEmpty) {
          // 성공했으므로 기존 에러 메시지(배너) 클리어
          errorMessage.value = '';
          // 기존에 혹시 목록에 추가되어 있던 실패 메시지(말풍선)들도 제거
          messages.removeWhere((m) =>
              m['role'] == 'ai' &&
              m['text'] == '아바타 응답을 불러오지 못했습니다. 다시 시도해주세요.');

          if (parsedSessionId != null && parsedSessionId.isNotEmpty) {
            sessionId.value = parsedSessionId;
          }

          messages.add({
            'role': 'ai',
            'text': answer,
          });
        } else {
          debugPrint('[AvatarChat] Success response but parsed answer is empty/null');
          errorMessage.value = '아바타 응답을 불러오지 못했습니다. 다시 시도해주세요.';
          messages.add({
            'role': 'ai',
            'text': '아바타 응답을 불러오지 못했습니다. 다시 시도해주세요.',
          });
        }
      } else {
        debugPrint('[AvatarChat] Response code is not successful: ${response.statusCode}');
        errorMessage.value = '아바타 응답을 불러오지 못했습니다. 다시 시도해주세요.';
        messages.add({
          'role': 'ai',
          'text': '아바타 응답을 불러오지 못했습니다. 다시 시도해주세요.',
        });
      }
    } catch (e, stack) {
      debugPrint('[AvatarChat] Exception in sendMessage: $e');
      debugPrint(stack.toString());
      errorMessage.value = '아바타 응답을 불러오지 못했습니다. 다시 시도해주세요.';
      messages.add({
        'role': 'ai',
        'text': '아바타 응답을 불러오지 못했습니다. 다시 시도해주세요.',
      });
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
