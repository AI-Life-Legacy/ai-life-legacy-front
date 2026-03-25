import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ai_life_legacy/app/core/ai/ai_repository.dart';
import 'package:ai_life_legacy/app/core/ai/models/ai.dto.dart';

class SearchController extends GetxController {
  final AiRepository aiRepo;
  SearchController(this.aiRepo);

  final TextEditingController textController = TextEditingController();
  final RxList<AiSearchResultItem> results = <AiSearchResultItem>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  Future<void> search() async {
    final query = textController.text.trim();
    if (query.isEmpty) return;

    isLoading.value = true;
    errorMessage.value = '';
    results.clear();

    try {
      final response = await aiRepo.search(AiSearchRequestDto(query: query));
      results.assignAll(response.data.results);
      if (results.isEmpty) {
        errorMessage.value = '검색 결과가 없습니다.';
      }
    } catch (e) {
      errorMessage.value = '검색 중 오류가 발생했습니다: $e';
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    textController.dispose();
    super.onClose();
  }
}
