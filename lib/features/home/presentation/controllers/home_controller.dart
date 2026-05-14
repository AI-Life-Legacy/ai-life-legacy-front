import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:ai_life_legacy/features/home/data/home_api.dart';
import 'package:ai_life_legacy/app/core/routes/app_routes.dart';

import 'package:ai_life_legacy/app/core/utils/token_storage.dart';
import 'package:ai_life_legacy/features/autobiography/presentation/controllers/autobiography_controller.dart';

class HomeController extends GetxController {
  final HomeApi _homeApi;
  final _autoBioController = Get.find<AutobiographyController>();

  HomeController(this._homeApi);

  final chapters = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;
  final totalProgress = 0.0.obs;
  final totalChapters = 0.obs;
  final completedChapters = 0.obs;
  final progressPercent = 0.obs;
  
  final totalQuestions = 0.obs;
  final answeredQuestions = 0.obs;
  final remainingQuestions = 0.obs;
  
  final currentIndex = 0.obs;
  final errorMessage = ''.obs;

  bool get isViewerMode => TokenStorage.isViewerMode();
  bool get isAvatarUnlocked => _autoBioController.isUnlocked.value;

  String get displayName {
    if (isViewerMode) {
      return TokenStorage.getViewerAuthorName() ?? '작성자';
    }
    // TODO: If we have user name in storage, return it. For now, fallback to '사용자'.
    return '사용자';
  }

  // alias for backward compatibility or different naming in UI
  bool get loading => isLoading.value;

  @override
  void onInit() {
    super.onInit();
    if (!isViewerMode) {
      fetchToc();
      // Only sync if not already syncing or if needed
      _autoBioController.syncStatusWithServer();
    }
  }

  Future<void> fetchToc() async {
    if (isViewerMode) return;
    
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _homeApi.getToc();

      debugPrint('GET /users/me/toc status: ${response.statusCode}');
      debugPrint('GET /users/me/toc data: ${response.data}');

      if (response.statusCode == 200) {
        final raw = response.data;

        // Handle common response structure { success: true, result: ... }
        final result = raw is Map<String, dynamic> && raw.containsKey('result')
            ? raw['result']
            : raw;

        List<dynamic> rawChapters = [];

        if (result is List) {
          rawChapters = result;
        } else if (result is Map<String, dynamic>) {
          totalChapters.value = result['totalChapters'] ?? 0;
          completedChapters.value = result['completedChapters'] ?? 0;
          progressPercent.value = result['progressPercent'] ?? 0;
          totalProgress.value = (result['progressPercent'] ?? 0) / 100.0;

          rawChapters = result['chapters'] ??
              result['toc'] ??
              result['items'] ??
              result['data'] ??
              [];
        }

        chapters.assignAll(
          rawChapters
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList(),
        );

        final tq = chapters.fold<int>(
          0,
          (sum, ch) => sum + ((ch['total'] as num?)?.toInt() ?? 0),
        );

        final aq = chapters.fold<int>(
          0,
          (sum, ch) => sum + ((ch['done'] as num?)?.toInt() ?? 0),
        );

        totalQuestions.value = tq;
        answeredQuestions.value = aq;
        remainingQuestions.value = tq - aq;

        // If backend didn't provide total progress, calculate it locally
        if (totalProgress.value == 0.0 && chapters.isNotEmpty) {
          _calculateProgress();
        }
      }
    } catch (e) {
      debugPrint('HomeController.fetchToc error: $e');
      errorMessage.value = '목차를 불러오는 데 실패했습니다.';
    } finally {
      isLoading.value = false;
    }
  }

  void changeTab(int index) {
    currentIndex.value = index;
  }

  Future<void> onChapterTap(dynamic chapter) async {
    final tocId = chapter['tocId'] ?? chapter['id'] ?? chapter['n'];
    final chapterNumber = chapter['n'] ?? chapter['chapterNumber'] ?? tocId;
    final title = chapter['title'] ?? chapter['tocTitle'] ?? chapter['name'] ?? '제목 없음';

    final navigationFuture = Get.toNamed(Routes.chapterChat, arguments: {
      'tocId': tocId,
      'title': title,
      'chapterNumber': chapterNumber,
      'done': chapter['done'],
      'total': chapter['total'],
      'status': chapter['status'],
      'percent': chapter['percent'],
    });

    if (navigationFuture != null) {
      await navigationFuture;
    }
    
    await fetchToc();
  }

  void _calculateProgress() {
    if (chapters.isEmpty) {
      totalProgress.value = 0.0;
      return;
    }

    double sum = 0.0;

    for (final ch in chapters) {
      // 1. Try percent field
      if (ch['percent'] != null) {
        sum += _normalizePercent(ch['percent']);
        continue;
      }

      // 2. Try done/total or answeredCount/totalCount
      final done = ch['done'] ??
          ch['answeredCount'] ??
          ch['completedQuestionCount'] ??
          ch['completedQuestions'];

      final total = ch['total'] ??
          ch['totalCount'] ??
          ch['questionCount'] ??
          ch['totalQuestions'];

      if (done != null && total != null && _toDouble(total) > 0) {
        sum += _toDouble(done) / _toDouble(total);
        continue;
      }

      // 3. Fallback to status
      final status = ch['status']?.toString().toLowerCase();
      if (status == 'complete' || status == 'completed') {
        sum += 1.0;
      }
    }

    totalProgress.value = sum / chapters.length;
  }

  double _normalizePercent(dynamic value) {
    final n = _toDouble(value);
    // If it's 0~1, use as is. If 0~100, normalize.
    return n <= 1 ? n : n / 100;
  }

  double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
