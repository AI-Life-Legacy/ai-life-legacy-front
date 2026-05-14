import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../app_text_styles.dart';

class InputField extends StatelessWidget {
  final String? label;
  final Widget child;
  final String? hint;

  const InputField({
    super.key,
    this.label,
    required this.child,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!, style: AppTextStyles.label),
          const SizedBox(height: 6),
        ],
        child,
        if (hint != null) ...[
          const SizedBox(height: 2),
          Text(hint!, style: AppTextStyles.caption),
        ],
      ],
    );
  }
}

class AppInput extends StatelessWidget {
  final String? value;
  final String? placeholder;
  final bool isPassword;
  final Widget? right;
  final TextInputType? type;
  final bool autofocus;
  final ValueChanged<String>? onChanged;

  const AppInput({
    super.key,
    this.value,
    this.placeholder,
    this.isPassword = false,
    this.right,
    this.type,
    this.autofocus = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppTheme.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: value != null ? TextEditingController(text: value) : null,
              obscureText: isPassword,
              keyboardType: type,
              autofocus: autofocus,
              onChanged: onChanged,
              style: const TextStyle(
                fontSize: 15,
                color: AppTheme.text,
              ),
              decoration: InputDecoration(
                hintText: placeholder,
                hintStyle: const TextStyle(color: AppTheme.textPh),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (right != null) right!,
        ],
      ),
    );
  }
}
