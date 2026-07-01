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
        color: AppTheme.surface,
        border: Border.all(color: AppTheme.border, width: 2),
        borderRadius: BorderRadius.circular(8),
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
                  color: AppTheme.cta,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.cta,
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
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.78),
            margin: const EdgeInsets.only(bottom: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppTheme.bgAlt,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                      bottomLeft: Radius.circular(2),
                    ),
                    border: Border.all(color: AppTheme.border, width: 1.5),
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
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.78),
            margin: const EdgeInsets.only(bottom: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppTheme.cta,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                      bottomLeft: Radius.circular(8),
                      bottomRight: Radius.circular(2),
                    ),
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

class AvatarAIBubble extends StatelessWidget {
  final String text;
  final String label;
  final String emoji;
  final bool muted;
  final String? time;

  const AvatarAIBubble({
    super.key,
    required this.text,
    required this.label,
    required this.emoji,
    this.muted = false,
    this.time,
  });

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.of(context).size.width * 0.76;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              color: AppTheme.bgAlt,
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.border, width: 1.5),
            ),
            alignment: Alignment.center,
            child: Text(emoji, style: const TextStyle(fontSize: 16)),
          ),
          const SizedBox(width: 9),
          Flexible(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 2, bottom: 5),
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPh,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 13,
                      vertical: 11,
                    ),
                    decoration: BoxDecoration(
                      color: muted ? AppTheme.bgAlt : AppTheme.surface,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(3),
                        topRight: Radius.circular(14),
                        bottomLeft: Radius.circular(14),
                        bottomRight: Radius.circular(14),
                      ),
                      border: Border.all(color: AppTheme.border, width: 1.5),
                    ),
                    child: muted
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppTheme.cta,
                                ),
                              ),
                              const SizedBox(width: 9),
                              Flexible(
                                child: Text(
                                  text,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppTheme.textSec,
                                    height: 1.45,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Text(
                            text,
                            softWrap: true,
                            style: const TextStyle(
                              fontSize: 15,
                              color: AppTheme.text,
                              height: 1.52,
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
      ),
    );
  }
}
