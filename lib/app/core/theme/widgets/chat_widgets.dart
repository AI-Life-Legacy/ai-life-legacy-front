import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../app_text_styles.dart';

class AIQuestionCard extends StatelessWidget {
  final String text;
  final String label;
  final bool showListen;
  final VoidCallback? onListen;

  const AIQuestionCard({
    super.key,
    required this.text,
    this.label = 'AI 질문',
    this.showListen = true,
    this.onListen,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.bgAlt,
        border: Border.all(color: AppTheme.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: AppTheme.textPh,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textPh,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 130),
            child: SingleChildScrollView(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.text,
                  height: 1.5,
                ),
              ),
            ),
          ),
          if (showListen) ...[
            const SizedBox(height: 10),
            GestureDetector(
              onTap: onListen,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Icon(Icons.volume_up, size: 14, color: AppTheme.textPh),
                  const SizedBox(width: 4),
                  Text(
                    '다시 듣기',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class AIBubble extends StatelessWidget {
  final String text;
  final String? time;

  const AIBubble({
    super.key,
    required this.text,
    this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Flexible(
          child: Container(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
            margin: const EdgeInsets.only(bottom: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppTheme.bgAlt,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    text,
                    softWrap: true,
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppTheme.text,
                      height: 1.5,
                    ),
                  ),
                ),
                if (time != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4, left: 4),
                    child: Text(time!, style: AppTextStyles.caption),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class UserBubble extends StatelessWidget {
  final String text;
  final String? time;

  const UserBubble({
    super.key,
    required this.text,
    this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Flexible(
          child: Container(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
            margin: const EdgeInsets.only(bottom: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppTheme.cta,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    text,
                    softWrap: true,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.white,
                      height: 1.5,
                    ),
                  ),
                ),
                if (time != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4, right: 4),
                    child: Text(
                      time!,
                      style: AppTextStyles.caption,
                      textAlign: TextAlign.right,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
