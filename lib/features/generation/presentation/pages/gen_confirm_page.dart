import 'package:ai_life_legacy/app/core/routes/app_routes.dart';
import 'package:ai_life_legacy/app/core/theme/app_theme.dart';
import 'package:ai_life_legacy/app/core/utils/safe_navigation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GenConfirmPage extends StatefulWidget {
  const GenConfirmPage({super.key});

  @override
  State<GenConfirmPage> createState() => _GenConfirmPageState();
}

class _GenConfirmPageState extends State<GenConfirmPage> {
  String _selectedTemplateId = 'classic';

  static const List<_BookTemplateOption> _templates = [
    _BookTemplateOption(
      id: 'classic',
      title: '클래식 회고록',
      subtitle: '단정한 종이책 느낌',
      accent: Color(0xFF8B1A1A),
      background: Color(0xFFFBFAF7),
    ),
    _BookTemplateOption(
      id: 'warm',
      title: '따뜻한 가족 앨범',
      subtitle: '크림톤과 사진첩 분위기',
      accent: Color(0xFFC46A3A),
      background: Color(0xFFFFF8F1),
    ),
    _BookTemplateOption(
      id: 'modern',
      title: '모던 에세이',
      subtitle: '넓은 여백과 선명한 구성',
      accent: Color(0xFF0D9488),
      background: Color(0xFFF8FAFC),
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final canGenerate = Get.arguments?['canGenerate'] == true;
      if (!canGenerate) {
        SafeNavigation.back(context, fallbackRoute: Routes.autobiography);
        Get.snackbar(
          '안내',
          '아직 결과물을 생성할 수 없습니다.',
          backgroundColor: AppTheme.error,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final force = Get.arguments?['force'] == true;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: Stack(
        children: [
          Opacity(
            opacity: 0.4,
            child: IgnorePointer(
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Container(
                        height: 96,
                        decoration: BoxDecoration(
                          color: AppTheme.text,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(height: 14),
                      ...List.generate(
                        5,
                        (index) => Container(
                          height: 56,
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: AppTheme.surface,
                            border: Border.all(color: AppTheme.border),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Container(color: Colors.black.withValues(alpha: 0.24)),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppTheme.border,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    Row(
                      children: [
                        Container(width: 52, height: 16, color: AppTheme.cta),
                        const SizedBox(width: 8),
                        Container(width: 24, height: 24, color: AppTheme.sun),
                      ],
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      '결과물을 만들 준비가 됐습니다',
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 23,
                        height: 1.16,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.text,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '지금까지의 답변을 정리해 읽을 수 있는 결과물로 생성합니다.',
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 13,
                        color: AppTheme.textSec,
                        height: 1.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      '디자인 템플릿',
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.text,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 148,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _templates.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final template = _templates[index];
                          final selected = template.id == _selectedTemplateId;
                          return _TemplatePreviewCard(
                            template: template,
                            selected: selected,
                            onTap: () {
                              setState(() {
                                _selectedTemplateId = template.id;
                              });
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Get.offNamed(
                            Routes.generating,
                            arguments: {
                              'templateId': _selectedTemplateId,
                              if (force) 'force': true,
                            },
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.text,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          '생성 시작',
                          style: TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => SafeNavigation.back(context, fallbackRoute: Routes.autobiography),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.text,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          side: const BorderSide(color: AppTheme.border),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          '취소',
                          style: TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BookTemplateOption {
  const _BookTemplateOption({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.background,
  });

  final String id;
  final String title;
  final String subtitle;
  final Color accent;
  final Color background;
}

class _TemplatePreviewCard extends StatelessWidget {
  const _TemplatePreviewCard({
    required this.template,
    required this.selected,
    required this.onTap,
  });

  final _BookTemplateOption template;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 148,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: template.background,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected ? template.accent : AppTheme.border,
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 30,
                        height: 4,
                        decoration: BoxDecoration(
                          color: template.accent,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(height: 8, width: 58, color: AppTheme.text),
                      const SizedBox(height: 6),
                      Container(height: 6, width: 86, color: AppTheme.border),
                      const Spacer(),
                      Row(
                        children: [
                          Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              color: template.accent.withValues(alpha: 0.16),
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          const SizedBox(width: 7),
                          Expanded(
                            child: Column(
                              children: [
                                Container(height: 4, color: AppTheme.border),
                                const SizedBox(height: 4),
                                Container(height: 4, color: AppTheme.border),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                template.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.text,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                template.subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textSec,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
