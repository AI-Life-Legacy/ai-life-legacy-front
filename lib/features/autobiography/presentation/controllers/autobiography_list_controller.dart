import 'package:get/get.dart';
import 'package:ai_life_legacy/features/autobiography/data/autobiography_api.dart';
import 'package:ai_life_legacy/app/core/routes/app_routes.dart';

class AutobiographyListController extends GetxController {
  final AutobiographyApi _api;

  AutobiographyListController(this._api);

  final isLoading = false.obs;
  final errorMessage = ''.obs;

  final totalChapters = 0.obs;
  final completedChapters = 0.obs;
  final progressPercent = 0.obs;
  final totalProgress = 0.0.obs;
  final chapters = <Map<String, dynamic>>[].obs;

  final expandedTocId = RxnInt();
  final tocQuestions = <int, List<Map<String, dynamic>>>{}.obs;
  final loadingQuestionTocIds = <int>{}.obs;

  final totalQuestions = 0.obs;
  final answeredQuestions = 0.obs;
  final remainingQuestions = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchToc();
    fetchTocQuestions();
  }

  Future<void> fetchToc() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _api.getToc();

      if (response.statusCode == 200) {
        final raw = response.data;
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
        
        if (totalProgress.value == 0.0 && chapters.isNotEmpty) {
           _calculateProgress();
        }
      }
    } catch (e) {
      errorMessage.value = '목차를 불러오는 데 실패했습니다.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchTocQuestions() async {
    try {
      final response = await _api.getTocQuestions();
      final raw = response.data;
      print('[AutobiographyListController] tocQuestions raw: $raw');

      final result = raw is Map<String, dynamic> ? raw['result'] : raw;
      
      final Map<int, List<Map<String, dynamic>>> grouped = {};

      if (result is Map && result['chapters'] is List) {
        for (final ch in result['chapters']) {
          final map = Map<String, dynamic>.from(ch as Map);
          final tocId = (map['tocId'] ?? map['id']) as int?;
          final questions = map['questions'];
          if (tocId != null && questions is List) {
            grouped[tocId] = questions
                .whereType<Map>()
                .map((q) => Map<String, dynamic>.from(q))
                .toList();
          }
        }
      } else if (result is List) {
        for (final item in result) {
          if (item is! Map) continue;
          final map = Map<String, dynamic>.from(item);

          if (map['questions'] is List) {
            final tocId = (map['tocId'] ?? map['id']) as int?;
            if (tocId != null) {
              grouped[tocId] = (map['questions'] as List)
                  .whereType<Map>()
                  .map((q) => Map<String, dynamic>.from(q))
                  .toList();
            }
          } else {
            final tocId = map['tocId'] as int?;
            if (tocId != null) {
              grouped.putIfAbsent(tocId, () => []);
              grouped[tocId]!.add(map);
            }
          }
        }
      }

      tocQuestions.assignAll(grouped);
      tocQuestions.refresh();
    } catch (e) {
      print('[AutobiographyListController] fetchTocQuestions error: $e');
    }
  }

  Future<void> toggleChapter(int tocId) async {
    if (expandedTocId.value == tocId) {
      expandedTocId.value = null;
      return;
    }
    
    expandedTocId.value = tocId;
    if (!tocQuestions.containsKey(tocId) || tocQuestions[tocId]!.isEmpty) {
      await fetchQuestionsForToc(tocId);
    }
  }

  Future<void> fetchQuestionsForToc(int tocId) async {
    try {
      loadingQuestionTocIds.add(tocId);
      final response = await _api.getQuestions(tocId);
      if (response.statusCode == 200) {
        final raw = response.data;
        final result = raw is Map<String, dynamic> && raw.containsKey('result')
            ? raw['result']
            : raw;
            
        if (result is List) {
          tocQuestions[tocId] = result
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
          tocQuestions.refresh();
        }
      }
    } catch (e) {
      print('Failed to load questions for tocId $tocId: $e');
    } finally {
      loadingQuestionTocIds.remove(tocId);
    }
  }

  void onQuestionTap(int tocId, Map<String, dynamic> q) async {
    final routeFuture = Get.toNamed(
      Routes.write,
      arguments: {
        'tocId': tocId,
        'questionId': q['id'] ?? q['questionId'],
        'questionText': q['questionText'] ?? q['text'] ?? q['question'],
      },
    );
    if (routeFuture != null) {
      final result = await routeFuture;
      if (result == true) {
        await fetchToc();
        await fetchTocQuestions();
      }
    }
  }
  
  void _calculateProgress() {
    if (chapters.isEmpty) {
      totalProgress.value = 0.0;
      return;
    }

    double sum = 0.0;
    for (final ch in chapters) {
      if (ch['percent'] != null) {
        final p = ch['percent'];
        final n = p is num ? p.toDouble() : (double.tryParse(p.toString()) ?? 0.0);
        sum += n <= 1 ? n : n / 100;
        continue;
      }
      final done = ch['done'] ?? 0;
      final total = ch['total'] ?? 0;
      if (total is num && total > 0 && done is num) {
        sum += done / total;
        continue;
      }
      final status = ch['status']?.toString().toLowerCase();
      if (status == 'complete' || status == 'completed') {
        sum += 1.0;
      }
    }
    totalProgress.value = sum / chapters.length;
  }
}
