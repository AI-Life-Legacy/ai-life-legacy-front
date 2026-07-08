import 'package:ai_life_legacy/app/core/config/env.dart';
import 'package:ai_life_legacy/app/core/network/dio_client.dart';
import 'package:ai_life_legacy/app/core/routes/app_routes.dart';
import 'package:ai_life_legacy/app/core/theme/app_theme.dart';
import 'package:ai_life_legacy/app/core/theme/widgets/mascot_flow_widgets.dart';
import 'package:ai_life_legacy/app/core/utils/safe_navigation.dart';
import 'package:ai_life_legacy/features/autobiography/presentation/controllers/autobiography_controller.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EbookReaderPage extends StatefulWidget {
  const EbookReaderPage({super.key});

  @override
  State<EbookReaderPage> createState() => _EbookReaderPageState();
}

class _EbookReaderPageState extends State<EbookReaderPage> {
  final PageController _pageController = PageController();
  List<_ReaderPageData> _pages = const [];

  int _currentPage = 0;
  double _fontSize = 18;
  bool _darkMode = false;
  bool _isLoading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loadPages();
  }

  Future<void> _loadPages() async {
    final args = Get.arguments as Map<String, dynamic>?;
    var markdown = args?['markdown']?.toString() ?? _findControllerMarkdown();
    var markdownUrl =
        args?['markdownUrl']?.toString() ?? _findControllerMarkdownUrl();
    final pdfUrl = args?['pdfUrl']?.toString() ?? _findControllerPdfUrl();

    try {
      if (_isBlank(markdown)) {
        final candidates = await _candidateMarkdownUrls(markdownUrl, pdfUrl);
        Object? lastError;

        for (final candidate in candidates) {
          try {
            markdown = await _fetchMarkdown(candidate);
            markdownUrl = candidate;
            break;
          } catch (e) {
            lastError = e;
          }
        }

        if (_isBlank(markdown) && lastError != null) {
          throw lastError;
        }
      }

      if (!mounted) return;
      setState(() {
        _pages = _buildReaderPages(
          markdown ?? '',
          assetBaseUrl: _assetBaseUrl(markdownUrl, pdfUrl),
        );
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _pages = _buildReaderPages('');
        _loadError = '원고를 불러오지 못했어요. 잠시 후 다시 시도해주세요.';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String? _findControllerMarkdown() {
    if (!Get.isRegistered<AutobiographyController>()) return null;
    return Get.find<AutobiographyController>().markdown.value;
  }

  String? _findControllerMarkdownUrl() {
    if (!Get.isRegistered<AutobiographyController>()) return null;
    return Get.find<AutobiographyController>().markdownUrl.value;
  }

  String? _findControllerPdfUrl() {
    if (!Get.isRegistered<AutobiographyController>()) return null;
    return Get.find<AutobiographyController>().pdfUrl.value;
  }

  Future<List<String>> _candidateMarkdownUrls(
    String? currentUrl,
    String? pdfUrl,
  ) async {
    final urls = <String>[];

    void add(String? value) {
      if (_isBlank(value)) return;
      final normalized = value!.trim();
      if (!urls.contains(normalized)) {
        urls.add(normalized);
      }
    }

    add(currentUrl);
    add(await _fetchStatusMarkdownUrl());
    add(_inferMarkdownUrlFromPdfUrl(pdfUrl));

    return urls;
  }

  Future<String?> _fetchStatusMarkdownUrl() async {
    try {
      final response = await DioClient.instance.get('/api/autobiography/status');
      final data = response.data;
      if (data is! Map<String, dynamic>) return null;
      final result = data['result'];
      final target = result is Map<String, dynamic> ? result : data;
      return (target['markdownUrl'] ?? target['markdown_url'])?.toString();
    } catch (_) {
      return null;
    }
  }

  String? _inferMarkdownUrlFromPdfUrl(String? pdfUrl) {
    if (_isBlank(pdfUrl)) return null;
    final uri = Uri.tryParse(pdfUrl!);
    if (uri == null || !uri.path.endsWith('.pdf')) return null;
    final markdownPath = uri.path
        .replaceFirst('/generated-pdfs/', '/storage/data/')
        .replaceFirst(RegExp(r'\.pdf$'), '.md');
    return uri.replace(path: markdownPath).toString();
  }

  Future<String> _fetchMarkdown(String markdownUrl) async {
    final response = await Dio().get<String>(
      _normalizeLocalhostUrl(markdownUrl),
      options: Options(responseType: ResponseType.plain),
    );
    return response.data ?? '';
  }

  String _normalizeLocalhostUrl(String url) {
    final uri = Uri.tryParse(url);
    final apiBaseUri = Uri.tryParse(Env.apiBase);
    if (uri == null || apiBaseUri == null) return url;
    final shouldUseApiHost =
        (uri.host == 'localhost' || uri.host == '127.0.0.1') &&
            apiBaseUri.host == '10.0.2.2';
    if (!shouldUseApiHost) return url;
    return uri.replace(host: apiBaseUri.host).toString();
  }

  bool _isBlank(String? value) => value == null || value.trim().isEmpty;

  String? _assetBaseUrl(String? markdownUrl, String? pdfUrl) {
    final sourceUrl = !_isBlank(markdownUrl) ? markdownUrl : pdfUrl;
    if (_isBlank(sourceUrl)) return null;
    final uri = Uri.tryParse(_normalizeLocalhostUrl(sourceUrl!));
    if (uri == null) return null;
    return uri.replace(path: '/storage/assets/', query: '').toString();
  }

  @override
  Widget build(BuildContext context) {
    final bg = _darkMode ? const Color(0xFF111820) : const Color(0xFFF7F1E8);
    final paper =
        _darkMode ? const Color(0xFF18242E) : const Color(0xFFFFFBF4);
    final text = _darkMode ? Colors.white : const Color(0xFF2B2118);
    final muted = _darkMode ? const Color(0xFF93A6B5) : const Color(0xFF8B7764);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        leading: IconButton(
          onPressed: () => SafeNavigation.back(context, fallbackRoute: Routes.generated),
          icon: Icon(Icons.arrow_back_ios_new, color: text),
        ),
        title: Text(
          '내 자서전',
          style: TextStyle(
            color: text,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: [
          IconButton(
            tooltip: '글자 작게',
            onPressed: () {
              setState(() {
                _fontSize = (_fontSize - 1).clamp(15, 23);
              });
            },
            icon: Icon(Icons.text_decrease, color: text),
          ),
          IconButton(
            tooltip: '글자 크게',
            onPressed: () {
              setState(() {
                _fontSize = (_fontSize + 1).clamp(15, 23);
              });
            },
            icon: Icon(Icons.text_increase, color: text),
          ),
          IconButton(
            tooltip: '읽기 모드',
            onPressed: () {
              setState(() {
                _darkMode = !_darkMode;
              });
            },
            icon: Icon(
              _darkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              color: text,
            ),
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: _darkMode ? Colors.white : AppTheme.cta,
              ),
            )
          : Column(
        children: [
          if (_loadError != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 4, 18, 0),
              child: Text(
                _loadError!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: muted,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _pages.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                final page = _pages[index];
                if (page.isCover) {
                  return _ChapterCoverPage(
                    page: page,
                    textColor: text,
                    mutedColor: muted,
                    darkMode: _darkMode,
                  );
                }
                return Padding(
                  padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: paper,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _darkMode
                            ? const Color(0xFF2B3D4A)
                            : const Color(0xFFE3D4C1),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.14),
                          blurRadius: 24,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 26, 24, 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            page.chapter,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: muted,
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Expanded(
                            child: SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              child: Text(
                                page.body,
                                style: TextStyle(
                                  color: text,
                                  fontSize: _fontSize,
                                  height: 1.78,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: LinearProgressIndicator(
                                  minHeight: 6,
                                  borderRadius: BorderRadius.circular(99),
                                  value: (_currentPage + 1) / _pages.length,
                                  backgroundColor: _darkMode
                                      ? const Color(0xFF2B3D4A)
                                      : const Color(0xFFE9DDCE),
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                    AppTheme.cta,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '${index + 1} / ${_pages.length}',
                                style: TextStyle(
                                  color: muted,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
              child: Row(
                children: [
                  _NavButton(
                    icon: Icons.chevron_left,
                    enabled: _currentPage > 0,
                    onTap: () => _moveTo(_currentPage - 1),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '옆으로 넘기며 읽을 수 있어요',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: muted,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  _NavButton(
                    icon: Icons.chevron_right,
                    enabled: _currentPage < _pages.length - 1,
                    onTap: () => _moveTo(_currentPage + 1),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _moveTo(int page) {
    _pageController.animateToPage(
      page.clamp(0, _pages.length - 1).toInt(),
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _NavButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: ElevatedButton(
        onPressed: enabled ? onTap : null,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          backgroundColor: MascotFlowTheme.surface,
          disabledBackgroundColor: MascotFlowTheme.border,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: Icon(icon),
      ),
    );
  }
}

class _ChapterCoverPage extends StatelessWidget {
  final _ReaderPageData page;
  final Color textColor;
  final Color mutedColor;
  final bool darkMode;

  const _ChapterCoverPage({
    required this.page,
    required this.textColor,
    required this.mutedColor,
    required this.darkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (page.imageUrl != null)
              Image.network(
                page.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _FallbackCover(mood: page.mood),
              )
            else
              _FallbackCover(mood: page.mood),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: darkMode ? 0.28 : 0.06),
                    Colors.black.withValues(alpha: darkMode ? 0.70 : 0.42),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(26),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Chapter',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.82),
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    page.chapter,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      height: 1.18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  if (page.quote != null && page.quote!.trim().isNotEmpty) ...[
                    const SizedBox(height: 18),
                    Text(
                      page.quote!,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.88),
                        fontSize: 14,
                        height: 1.45,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FallbackCover extends StatelessWidget {
  final String? mood;

  const _FallbackCover({this.mood});

  @override
  Widget build(BuildContext context) {
    final colors = _coverColors(mood);
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            left: -90,
            top: -70,
            child: _CoverShape(size: 250, color: Colors.white24),
          ),
          Positioned(
            right: -120,
            bottom: -100,
            child: _CoverShape(size: 330, color: Colors.black12),
          ),
        ],
      ),
    );
  }

  List<Color> _coverColors(String? mood) {
    switch (mood) {
      case 'childhood':
        return const [Color(0xFFF8D7A4), Color(0xFF6B8F71)];
      case 'youth':
        return const [Color(0xFFB7D9F7), Color(0xFF456990)];
      case 'career':
        return const [Color(0xFFD9E2EC), Color(0xFF334E68)];
      case 'marriage':
        return const [Color(0xFFFFD6DC), Color(0xFF9F5F80)];
      case 'crisis':
        return const [Color(0xFFCBD5E1), Color(0xFF475569)];
      case 'hobby':
        return const [Color(0xFFC8E6C9), Color(0xFF3D7A45)];
      case 'future':
        return const [Color(0xFFD8CCFF), Color(0xFF5B4B8A)];
      case 'family':
      default:
        return const [Color(0xFFF7C59F), Color(0xFF7F5539)];
    }
  }
}

class _CoverShape extends StatelessWidget {
  final double size;
  final Color color;

  const _CoverShape({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}

class _ReaderPageData {
  final String chapter;
  final String body;
  final bool isCover;
  final String? mood;
  final String? imageUrl;
  final String? quote;

  const _ReaderPageData({
    required this.chapter,
    required this.body,
    this.isCover = false,
    this.mood,
    this.imageUrl,
    this.quote,
  });
}

List<_ReaderPageData> _buildReaderPages(
  String markdown, {
  String? assetBaseUrl,
}) {
  final normalized = _cleanMarkdown(markdown);
  if (normalized.trim().isEmpty) {
    return const [
      _ReaderPageData(
        chapter: '원고가 아직 준비되지 않았어요',
        body: '자서전을 새로 생성하면 앱 안에서 책처럼 넘겨 읽을 수 있습니다.',
      ),
    ];
  }

  final chapters = <_ReaderPageData>[];
  var currentTitle = '프롤로그';
  var currentMood = 'family';
  String? currentImageUrl;
  String? currentQuote;
  var hasSeenHeading = false;
  final buffer = StringBuffer();

  void flush() {
    final rawBody = buffer.toString().trim();
    if (rawBody.isEmpty) return;
    final metadata = _extractChapterMetadata(rawBody);
    final mood = metadata.mood ?? currentMood;
    final imageUrl = metadata.imageUrl ?? currentImageUrl ?? _moodImageUrl(assetBaseUrl, mood);
    final quote = metadata.quote ?? currentQuote;
    final body = metadata.body.trim();
    if (body.isEmpty) return;
    chapters.add(
      _ReaderPageData(
        chapter: currentTitle,
        body: '',
        isCover: true,
        mood: mood,
        imageUrl: imageUrl,
        quote: quote,
      ),
    );
    chapters.addAll(_splitChapter(currentTitle, body));
    buffer.clear();
    currentMood = 'family';
    currentImageUrl = null;
    currentQuote = null;
  }

  for (final rawLine in normalized.split('\n')) {
    final line = rawLine.trimRight();
    if (line.startsWith('#')) {
      flush();
      hasSeenHeading = true;
      currentTitle = line.replaceFirst(RegExp(r'^#+\s*'), '').trim();
      if (currentTitle.isEmpty) currentTitle = '나의 이야기';
    } else if (!hasSeenHeading && _isGeneratedTitleLine(line)) {
      continue;
    } else if (line.trimLeft().startsWith('<!--')) {
      final metadata = _extractChapterMetadata(line);
      currentMood = _normalizeMood(metadata.mood) ?? currentMood;
      currentImageUrl = metadata.imageUrl ?? currentImageUrl;
      currentQuote = metadata.quote ?? currentQuote;
    } else {
      buffer.writeln(line);
    }
  }
  flush();

  return chapters.isEmpty
      ? [_ReaderPageData(chapter: '나의 이야기', body: normalized)]
      : chapters;
}

class _ChapterMetadata {
  final String body;
  final String? mood;
  final String? imageUrl;
  final String? quote;

  const _ChapterMetadata({
    required this.body,
    this.mood,
    this.imageUrl,
    this.quote,
  });
}

_ChapterMetadata _extractChapterMetadata(String text) {
  String? readTag(String tag) {
    final match = RegExp(
      '<!--\\s*$tag:\\s*([\\s\\S]*?)\\s*-->',
      caseSensitive: false,
    ).firstMatch(text);
    return match?.group(1)?.trim();
  }

  final body = text
      .replaceAll(
        RegExp(r'<!--\s*(MOOD|QUOTE|IMAGE):[\s\S]*?-->', caseSensitive: false),
        '',
      )
      .trim();

  return _ChapterMetadata(
    body: body,
    mood: _normalizeMood(readTag('MOOD')),
    imageUrl: readTag('IMAGE'),
    quote: readTag('QUOTE'),
  );
}

String? _moodImageUrl(String? assetBaseUrl, String? mood) {
  if (assetBaseUrl == null || assetBaseUrl.trim().isEmpty) return null;
  final safeMood = _normalizeMood(mood) ?? 'family';
  return Uri.parse(assetBaseUrl).resolve('$safeMood.png').toString();
}

String? _normalizeMood(String? mood) {
  final value = mood?.trim().toLowerCase();
  switch (value) {
    case 'childhood':
    case 'career':
    case 'marriage':
    case 'crisis':
    case 'family':
    case 'hobby':
    case 'future':
      return value;
    case 'school':
    case 'youth':
      return 'youth';
    default:
      return value == null || value.isEmpty ? null : 'family';
  }
}

bool _isGeneratedTitleLine(String line) {
  final trimmed = line.trim();
  if (trimmed.isEmpty) return true;
  if (trimmed.startsWith('제목:') || trimmed.startsWith('Title:')) return true;
  if (trimmed.startsWith('?') && trimmed.contains(':') && trimmed.length < 80) {
    return true;
  }
  return false;
}

List<_ReaderPageData> _splitChapter(String title, String body) {
  const targetLength = 950;
  final paragraphs = body
      .split(RegExp(r'\n\s*\n'))
      .map((p) => p.trim())
      .where((p) => p.isNotEmpty)
      .toList();
  final pages = <_ReaderPageData>[];
  final buffer = StringBuffer();

  void flush() {
    final text = buffer.toString().trim();
    if (text.isEmpty) return;
    pages.add(_ReaderPageData(chapter: title, body: text));
    buffer.clear();
  }

  for (final paragraph in paragraphs) {
    if (buffer.length + paragraph.length > targetLength && buffer.isNotEmpty) {
      flush();
    }
    if (buffer.isNotEmpty) buffer.writeln('\n');
    buffer.write(paragraph);
  }
  flush();
  return pages;
}

String _cleanMarkdown(String markdown) {
  return markdown
      .replaceAll(r'\r\n', '\n')
      .replaceAll(r'\n', '\n')
      .replaceAll(RegExp(r'!\[[^\]]*\]\([^)]+\)'), '')
      .replaceAll(RegExp(r'\*\*(.*?)\*\*'), r'$1')
      .replaceAll(RegExp(r'__(.*?)__'), r'$1')
      .replaceAll(RegExp(r'`([^`]*)`'), r'$1')
      .replaceAll(RegExp(r'^\s*[-*]\s+', multiLine: true), '')
      .replaceAll(RegExp(r'\n{3,}'), '\n\n')
      .trim();
}
