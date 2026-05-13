import 'package:flutter/material.dart';
import '../app_theme.dart';

class AppChatInput extends StatefulWidget {
  final String placeholder;
  final String value;
  final ValueChanged<String>? onSend;
  final bool recording;
  final VoidCallback? onMicTap;
  final bool enabled;

  const AppChatInput({
    super.key,
    this.placeholder = '답변을 입력하세요...',
    this.value = '',
    this.onSend,
    this.recording = false,
    this.onMicTap,
    this.enabled = true,
  });

  @override
  State<AppChatInput> createState() => _AppChatInputState();
}

class _AppChatInputState extends State<AppChatInput> {
  late TextEditingController _textController;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.value);
    _hasText = _textController.text.trim().isNotEmpty;
    _textController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _textController.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
  }

  void _handleSend() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    widget.onSend?.call(text);
    _textController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppTheme.border)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: 48,
                maxHeight: 140,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.border),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextField(
                  enabled: widget.enabled,
                  controller: _textController,
                  minLines: 1,
                  maxLines: 5,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                  scrollPhysics: const BouncingScrollPhysics(),
                  decoration: InputDecoration(
                    hintText: widget.placeholder,
                    hintStyle: TextStyle(
                      fontSize: 15,
                      color: widget.enabled ? AppTheme.textPh : AppTheme.textPh.withValues(alpha: 0.5),
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  style: TextStyle(
                    fontSize: 15,
                    color: widget.enabled ? AppTheme.text : AppTheme.textPh,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: widget.enabled ? widget.onMicTap : null,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: widget.recording 
                    ? AppTheme.error 
                    : (widget.enabled ? AppTheme.bgAlt : AppTheme.bgAlt.withValues(alpha: 0.5)),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.mic,
                size: 20,
                color: widget.recording 
                    ? Colors.white 
                    : (widget.enabled ? AppTheme.textSec : AppTheme.textPh.withValues(alpha: 0.5)),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: (widget.enabled && _hasText) ? _handleSend : null,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: (widget.enabled && _hasText) ? AppTheme.cta : AppTheme.bgAlt,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.send,
                size: 18,
                color: (widget.enabled && _hasText) ? Colors.white : AppTheme.textPh,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
