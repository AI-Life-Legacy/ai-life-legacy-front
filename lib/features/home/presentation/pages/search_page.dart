import 'package:ai_life_legacy/app/core/routes/app_routes.dart';
import 'package:ai_life_legacy/app/core/theme/app_theme.dart';
import 'package:ai_life_legacy/app/core/theme/widgets/animated_mascot.dart';
import 'package:ai_life_legacy/app/core/theme/widgets/mascot_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final queryController = TextEditingController();
  late List<_SearchResult> filteredResults;

  static const results = <_SearchResult>[];

  @override
  void initState() {
    super.initState();
    filteredResults = results;
    queryController.addListener(_filterResults);
  }

  @override
  void dispose() {
    queryController
      ..removeListener(_filterResults)
      ..dispose();
    super.dispose();
  }

  void _filterResults() {
    final query = queryController.text.trim().toLowerCase();
    setState(() {
      filteredResults = query.isEmpty
          ? results
          : results.where((result) => result.matches(query)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final query = queryController.text.trim();
    final hasQuery = query.isNotEmpty;

    return MascotScaffold(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _SearchHeader(
            controller: queryController,
            onClear: queryController.clear,
          ),
          Expanded(
            child: ListView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
              children: [
                MascotHeader(
                  message: hasQuery
                      ? '"$query"와 연결된 기억을 찾아볼게요.'
                      : '검색 화면은 준비됐어요. 실제 기억 데이터가 연결되면 여기에서 찾아볼 수 있어요.',
                  mood: hasQuery ? MascotMood.thinking : MascotMood.listening,
                  trailing: IconButton(
                    tooltip: '닫기',
                    onPressed: Get.back,
                    icon: const Icon(
                      Icons.close_rounded,
                      color: MascotFlowTheme.textMuted,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _SearchSummary(
                  query: query,
                  count: filteredResults.length,
                  hasQuery: hasQuery,
                ),
                const SizedBox(height: 18),
                _SectionTitle('검색 결과'),
                const SizedBox(height: 10),
                if (filteredResults.isEmpty)
                  _EmptyState(query: query)
                else
                  ...filteredResults.map(
                    (result) => _ResultCard(result: result, query: query),
                  ),
                const SizedBox(height: 18),
                _ExploreCard(
                  onTap: () => Get.toNamed(Routes.autobiography),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchHeader extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onClear;

  const _SearchHeader({
    required this.controller,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      decoration: const BoxDecoration(
        color: MascotFlowTheme.surface,
        border: Border(bottom: BorderSide(color: MascotFlowTheme.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 46,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: MascotFlowTheme.bg,
                border: Border.all(color: MascotFlowTheme.border, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.search_rounded,
                    size: 20,
                    color: MascotFlowTheme.active,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      textInputAction: TextInputAction.search,
                      style: const TextStyle(
                        fontSize: 15,
                        color: MascotFlowTheme.text,
                        fontWeight: FontWeight.w700,
                      ),
                      cursorColor: MascotFlowTheme.active,
                      decoration: const InputDecoration(
                        hintText: '기억을 검색해보세요',
                        hintStyle: TextStyle(color: MascotFlowTheme.textMuted),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: controller,
                    builder: (context, value, child) {
                      if (value.text.isEmpty) return const SizedBox.shrink();
                      return IconButton(
                        tooltip: '검색어 지우기',
                        onPressed: onClear,
                        icon: const Icon(
                          Icons.cancel_rounded,
                          size: 18,
                          color: MascotFlowTheme.textMuted,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          TextButton(
            onPressed: Get.back,
            child: const Text(
              '취소',
              style: TextStyle(
                color: MascotFlowTheme.textMuted,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchSummary extends StatelessWidget {
  final String query;
  final int count;
  final bool hasQuery;

  const _SearchSummary({
    required this.query,
    required this.count,
    required this.hasQuery,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MascotFlowTheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: MascotFlowTheme.border, width: 2),
      ),
      child: Row(
        children: [
          const AnimatedMascot(
            size: 54,
            mood: MascotMood.listening,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasQuery ? '"$query" 검색 결과' : '기억 탐색',
                  style: const TextStyle(
                    color: MascotFlowTheme.text,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  hasQuery ? '$count개의 관련 기억을 찾았어요.' : '아직 연결된 검색 데이터가 없어요.',
                  style: const TextStyle(
                    color: MascotFlowTheme.textMuted,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final _SearchResult result;
  final String query;

  const _ResultCard({
    required this.result,
    required this.query,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: MascotFlowTheme.surface,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: () => Get.toNamed(Routes.chapterChat),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: MascotFlowTheme.border, width: 2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.warnBg,
                        borderRadius: BorderRadius.circular(99),
                        border: Border.all(color: AppTheme.warnBorder),
                      ),
                      child: Text(
                        'Ch.${result.chapter}',
                        style: const TextStyle(
                          color: AppTheme.warning,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        result.label,
                        style: const TextStyle(
                          color: MascotFlowTheme.textMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: MascotFlowTheme.textMuted,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _HighlightedText(
                  text: result.question,
                  query: query,
                  style: const TextStyle(
                    color: MascotFlowTheme.text,
                    fontSize: 15,
                    height: 1.38,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                _HighlightedText(
                  text: result.answer,
                  query: query,
                  maxLines: 3,
                  style: const TextStyle(
                    color: MascotFlowTheme.textMuted,
                    fontSize: 13,
                    height: 1.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HighlightedText extends StatelessWidget {
  final String text;
  final String query;
  final TextStyle style;
  final int? maxLines;

  const _HighlightedText({
    required this.text,
    required this.query,
    required this.style,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    final normalizedQuery = query.trim().toLowerCase();
    final matchIndex = normalizedQuery.isEmpty
        ? -1
        : text.toLowerCase().indexOf(normalizedQuery);

    if (matchIndex < 0) {
      return Text(
        text,
        maxLines: maxLines,
        overflow: maxLines == null ? null : TextOverflow.ellipsis,
        style: style,
      );
    }

    final matchEnd = matchIndex + normalizedQuery.length;
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: text.substring(0, matchIndex)),
          TextSpan(
            text: text.substring(matchIndex, matchEnd),
            style: style.copyWith(
              color: AppTheme.sun,
              fontWeight: FontWeight.w900,
            ),
          ),
          TextSpan(text: text.substring(matchEnd)),
        ],
      ),
      maxLines: maxLines,
      overflow: maxLines == null ? TextOverflow.clip : TextOverflow.ellipsis,
      style: style,
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String query;

  const _EmptyState({required this.query});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: MascotFlowTheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: MascotFlowTheme.border, width: 2),
      ),
      child: Row(
        children: [
          const AnimatedMascot(
            size: 62,
            mood: MascotMood.sad,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '아직 표시할 기억이 없어요',
                  style: TextStyle(
                    color: MascotFlowTheme.text,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  query.isEmpty
                      ? '실제 자서전 데이터가 연결되면 검색 결과가 여기에 표시돼요.'
                      : '"$query"에 대한 검색 결과가 아직 없어요.',
                  style: const TextStyle(
                    color: MascotFlowTheme.textMuted,
                    fontSize: 13,
                    height: 1.4,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ExploreCard extends StatelessWidget {
  final VoidCallback onTap;

  const _ExploreCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return FlowOptionCard(
      icon: Icons.auto_stories_outlined,
      title: '전체 자서전에서 둘러보기',
      subtitle: '챕터 목록으로 이동해 작성된 기억을 한 번에 확인할 수 있어요.',
      selected: true,
      onTap: onTap,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: MascotFlowTheme.text,
        fontSize: 18,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _SearchResult {
  final int chapter;
  final String label;
  final String question;
  final String answer;
  final List<String> keywords;

  const _SearchResult({
    required this.chapter,
    required this.label,
    required this.question,
    required this.answer,
    required this.keywords,
  });

  bool matches(String query) {
    final haystack = [
      label,
      question,
      answer,
      ...keywords,
    ].join(' ').toLowerCase();
    return haystack.contains(query);
  }
}
