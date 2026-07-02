import 'package:ai_life_legacy/app/core/theme/app_theme.dart';
import 'package:ai_life_legacy/app/core/theme/widgets/mascot_flow_widgets.dart';
import 'package:ai_life_legacy/app/core/utils/safe_navigation.dart';
import 'package:ai_life_legacy/features/autobiography/presentation/controllers/autobiography_write_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AutobiographyWritePage extends StatefulWidget {
  const AutobiographyWritePage({super.key});

  @override
  State<AutobiographyWritePage> createState() => _AutobiographyWritePageState();
}

class _AutobiographyWritePageState extends State<AutobiographyWritePage> {
  final _textController = TextEditingController();
  final _controller = Get.find<AutobiographyWriteController>();
  Worker? _worker;

  @override
  void initState() {
    super.initState();

    _worker = ever(_controller.answerText, (String text) {
      if (_textController.text != text) {
        _textController.text = text;
      }
    });

    _textController.addListener(() {
      _controller.answerText.value = _textController.text;
    });
  }

  @override
  void dispose() {
    _worker?.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MascotScaffold(
      padding: EdgeInsets.zero,
      bottom: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        child: Obx(
          () => FlowPrimaryButton(
            text: _controller.isSaving.value ? '저장 중...' : '저장하기',
            loading: _controller.isSaving.value,
            onPressed: _controller.save,
          ),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => SafeNavigation.back(context),
                  icon: const Icon(
                    Icons.close,
                    color: MascotFlowTheme.textMuted,
                  ),
                ),
                const Expanded(
                  child: Text(
                    '기억 다듬기',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: MascotFlowTheme.text,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Obx(
                  () => Text(
                    '${_controller.answerText.value.length}자',
                    style: const TextStyle(
                      color: MascotFlowTheme.textMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              if (_controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(color: AppTheme.cta),
                );
              }

              if (_controller.errorMessage.value.isNotEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: MascotHeader(
                      message: _controller.errorMessage.value,
                    ),
                  ),
                );
              }

              return ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                children: [
                  MascotHeader(
                    message: _controller.questionText.value.isEmpty
                        ? '이 기억을 조금 더 다듬어볼까요?'
                        : _controller.questionText.value,
                    mascotSize: 70,
                  ),
                  const SizedBox(height: 20),
                  _AnswerHint(text: _controller.answerText.value),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _textController,
                    maxLines: null,
                    minLines: 12,
                    keyboardType: TextInputType.multiline,
                    style: const TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 16,
                      color: MascotFlowTheme.text,
                      height: 1.7,
                      fontWeight: FontWeight.w700,
                    ),
                    decoration: InputDecoration(
                      hintText: '답변을 여기에 적어보세요...',
                      hintStyle: const TextStyle(
                        color: MascotFlowTheme.textMuted,
                        fontWeight: FontWeight.w700,
                      ),
                      filled: true,
                      fillColor: MascotFlowTheme.surface,
                      contentPadding: const EdgeInsets.all(16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: MascotFlowTheme.border,
                          width: 2,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: MascotFlowTheme.border,
                          width: 2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: MascotFlowTheme.active,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _AnswerHint extends StatelessWidget {
  final String text;

  const _AnswerHint({required this.text});

  @override
  Widget build(BuildContext context) {
    final hasFollowUp = text.contains('추가 질문:') && text.contains('추가 답변:');
    final brokenFollowUp = text.contains('추가 답변:') && !text.contains('추가 질문:');

    if (!hasFollowUp && !brokenFollowUp) {
      return const FlowOptionCard(
        icon: Icons.edit_note,
        title: '말하듯이 조금만 정리해도 충분해요',
        subtitle: '저장하면 기존 답변 수정 API로 반영됩니다.',
        selected: true,
        onTap: _noop,
      );
    }

    return FlowOptionCard(
      icon: hasFollowUp ? Icons.forum_outlined : Icons.warning_amber_rounded,
      title: hasFollowUp ? '추가 질문까지 포함된 답변이에요' : '추가 답변 형식이 불완전해요',
      subtitle: hasFollowUp
          ? '본문, 추가 질문, 추가 답변이 함께 저장되어 있습니다.'
          : '필요하면 문장을 자연스럽게 정리해 주세요.',
      selected: true,
      onTap: _noop,
    );
  }

  static void _noop() {}
}
