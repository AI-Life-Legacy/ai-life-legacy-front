import 'package:ai_life_legacy/app/core/theme/app_theme.dart';
import 'package:ai_life_legacy/app/core/theme/widgets/animated_mascot.dart';
import 'package:ai_life_legacy/app/core/theme/widgets/app_chat_input.dart';
import 'package:ai_life_legacy/app/core/theme/widgets/chat_widgets.dart';
import 'package:ai_life_legacy/app/core/theme/widgets/mascot_flow_widgets.dart';
import 'package:ai_life_legacy/app/core/utils/token_storage.dart';
import 'package:ai_life_legacy/features/avatar_chat/presentation/controllers/avatar_chat_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AvatarChatPage extends GetView<AvatarChatController> {
  const AvatarChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      switch (controller.step.value) {
        case AvatarChatStep.roleSelect:
          return _buildRoleSelect(context);
        case AvatarChatStep.intro:
          return _buildIntro(context);
        case AvatarChatStep.chat:
          return _buildChat(context);
      }
    });
  }

  Widget _buildRoleSelect(BuildContext context) {
    final basicRoles = controller.roles.where((r) => r.group == '기본').toList();
    final familyRoles = controller.roles.where((r) => r.group == '가족').toList();

    return _AvatarShell(
      title: '대화 상대 선택',
      onBack: controller.handleBack,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
              children: [
                _HeroPanel(
                  eyebrow: Obx(
                      () => Text('${controller.authorName.value}님의 기억과 대화')),
                  title: '어떤 목소리로\n이야기를 들어볼까요?',
                  body: '선택한 관계에 따라 말투와 질문 방식이 달라져요. 언제든 다시 바꿀 수 있습니다.',
                  mood: MascotMood.thinking,
                ),
                const SizedBox(height: 22),
                _SectionLabel('추천'),
                const SizedBox(height: 10),
                ...basicRoles.map((role) => Obx(() {
                      return _RoleCard(
                        role: role,
                        selected: controller.selectedRoleId.value == role.id,
                        onTap: () => controller.selectRole(role.id),
                      );
                    })),
                const SizedBox(height: 18),
                _SectionLabel('가족과 가까운 관계'),
                const SizedBox(height: 10),
                ...familyRoles.map((role) => Obx(() {
                      return _RoleCard(
                        role: role,
                        selected: controller.selectedRoleId.value == role.id,
                        onTap: () => controller.selectRole(role.id),
                      );
                    })),
              ],
            ),
          ),
          _BottomAction(
            child: Obx(() {
              final role = controller.selectedRole;
              return ElevatedButton.icon(
                onPressed: controller.goToIntro,
                icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                label: Text('${role.name} 목소리로 만나기'),
                style: _primaryButtonStyle(),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildIntro(BuildContext context) {
    final role = controller.selectedRole;

    return _AvatarShell(
      title: '대화 준비',
      onBack: controller.handleBack,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
            child: ConstrainedBox(
              constraints:
                  BoxConstraints(minHeight: constraints.maxHeight - 42),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MascotCoachBubble(
                    message: '좋아요. ${role.name}의 말투로 먼저 인사를 건넬게요.',
                    mood: MascotMood.listening,
                    mascotSize: 148,
                    maxBubbleWidth: 300,
                  ),
                  const SizedBox(height: 18),
                  _AvatarProfileCard(role: role),
                  const SizedBox(height: 18),
                  _MemoryStatsCard(controller: controller),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: controller.startChat,
                      icon: const Icon(Icons.chat_bubble_outline_rounded,
                          size: 19),
                      label: Text('${role.name}와 대화 시작하기'),
                      style: _primaryButtonStyle(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: controller.goToRoleSelect,
                    child: const Text(
                      '다른 목소리 고르기',
                      style: TextStyle(
                        color: AppTheme.textSec,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildChat(BuildContext context) {
    final role = controller.selectedRole;

    return _AvatarShell(
      title: controller.authorName.value,
      subtitle: '${role.emoji} ${role.name}와 대화 중',
      onBack: controller.handleBack,
      action: TokenStorage.isViewerMode()
          ? null
          : IconButton(
              tooltip: '공유 코드 만들기',
              onPressed: controller.generateViewerCode,
              icon:
                  const Icon(Icons.ios_share_rounded, color: AppTheme.textSec),
            ),
      child: Column(
        children: [
          _ChatContextBar(
            role: role,
            onChangeRole: controller.goToRoleSelect,
          ),
          Expanded(
            child: Obx(() {
              if (controller.messages.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: MascotCoachBubble(
                      message: '첫 질문을 건네면 ${role.name}가 기억을 함께 짚어줄 거예요.',
                      mood: MascotMood.listening,
                    ),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                itemCount: controller.messages.length +
                    (controller.isLoading.value ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == controller.messages.length) {
                    return AvatarAIBubble(
                      text: '${role.name}가 답을 고르고 있어요...',
                      label: role.name,
                      emoji: role.emoji,
                      muted: true,
                    );
                  }

                  final message = controller.messages[index];
                  final isAi = message['role'] == 'ai';
                  final text = message['text'] ?? '';

                  if (isAi) {
                    return AvatarAIBubble(
                      text: text,
                      label: role.name,
                      emoji: role.emoji,
                    );
                  }

                  return UserBubble(text: text);
                },
              );
            }),
          ),
          Obx(() {
            final error = controller.errorMessage.value;
            if (error.isEmpty) return const SizedBox.shrink();

            return _InlineNotice(
              icon: Icons.error_outline_rounded,
              text: error,
              color: AppTheme.error,
              backgroundColor: AppTheme.errorBg,
            );
          }),
          Obx(() {
            final viewerCode = controller.viewerCode.value;
            if (viewerCode.isEmpty) return const SizedBox.shrink();

            return _InlineNotice(
              icon: Icons.key_rounded,
              text: '공유 코드: $viewerCode',
              color: AppTheme.ctaDark,
              backgroundColor: AppTheme.successBg,
            );
          }),
          Obx(() {
            return AppChatInput(
              placeholder: '${role.name}에게 묻고 싶은 이야기를 적어보세요.',
              enabled: !controller.isLoading.value,
              onSend: controller.sendMessage,
            );
          }),
        ],
      ),
    );
  }

  ButtonStyle _primaryButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: AppTheme.cta,
      foregroundColor: Colors.white,
      disabledBackgroundColor: AppTheme.border,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      textStyle: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _AvatarShell extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback onBack;
  final Widget child;
  final Widget? action;

  const _AvatarShell({
    required this.title,
    this.subtitle,
    required this.onBack,
    required this.child,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: onBack,
        ),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(
                subtitle!,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.textSec,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
        centerTitle: true,
        backgroundColor: AppTheme.surface,
        elevation: 0,
        actions: [if (action != null) action!],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppTheme.border),
        ),
      ),
      body: SafeArea(child: child),
    );
  }
}

class _HeroPanel extends StatelessWidget {
  final Widget eyebrow;
  final String title;
  final String body;
  final MascotMood mood;

  const _HeroPanel({
    required this.eyebrow,
    required this.title,
    required this.body,
    required this.mood,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border.all(color: AppTheme.border, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AnimatedMascot(size: 92, mood: mood),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DefaultTextStyle(
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPh,
                  ),
                  child: eyebrow,
                ),
                const SizedBox(height: 7),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 23,
                    height: 1.22,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.text,
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  body,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.55,
                    color: AppTheme.textSec,
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

class _RoleCard extends StatelessWidget {
  final AvatarRole role;
  final bool selected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.role,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: selected ? AppTheme.cta : AppTheme.surface,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: selected ? AppTheme.ctaDark : AppTheme.border,
                width: selected ? 2.4 : 2,
              ),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: AppTheme.cta.withValues(alpha: 0.18),
                        blurRadius: 14,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _RoleAvatar(role: role, selected: selected),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              role.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: selected ? Colors.white : AppTheme.text,
                              ),
                            ),
                          ),
                          Text(
                            role.sub,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: selected
                                  ? Colors.white.withValues(alpha: 0.78)
                                  : AppTheme.textPh,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        role.desc,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.45,
                          color: selected
                              ? Colors.white.withValues(alpha: 0.88)
                              : AppTheme.textSec,
                        ),
                      ),
                      if (selected) ...[
                        const SizedBox(height: 12),
                        SpeechBubble(
                          text: role.greet,
                          tail: SpeechBubbleTail.none,
                          backgroundColor: Colors.white.withValues(alpha: 0.14),
                          borderColor: Colors.white.withValues(alpha: 0.25),
                          textColor: Colors.white,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Icon(
                  selected
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: selected ? Colors.white : AppTheme.border,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleAvatar extends StatelessWidget {
  final AvatarRole role;
  final bool selected;

  const _RoleAvatar({
    required this.role,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: selected ? Colors.white.withValues(alpha: 0.16) : AppTheme.bgAlt,
        shape: BoxShape.circle,
        border: Border.all(
          color:
              selected ? Colors.white.withValues(alpha: 0.34) : AppTheme.border,
          width: 2,
        ),
      ),
      alignment: Alignment.center,
      child: Text(role.emoji, style: const TextStyle(fontSize: 20)),
    );
  }
}

class _AvatarProfileCard extends StatelessWidget {
  final AvatarRole role;

  const _AvatarProfileCard({required this.role});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.border, width: 2),
      ),
      child: Column(
        children: [
          _RoleAvatar(role: role, selected: false),
          const SizedBox(height: 10),
          Text(
            role.name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppTheme.text,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            role.sub,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textPh,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          SpeechBubble(
            text: role.greet,
            tail: SpeechBubbleTail.none,
            backgroundColor: AppTheme.bg,
            borderColor: AppTheme.border,
          ),
        ],
      ),
    );
  }
}

class _MemoryStatsCard extends StatelessWidget {
  final AvatarChatController controller;

  const _MemoryStatsCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.border, width: 2),
      ),
      child: Obx(() {
        return Row(
          children: [
            _StatItem(
              value: controller.totalChapters.value?.toString() ?? '-',
              label: '챕터',
            ),
            const _StatDivider(),
            _StatItem(
              value: controller.pageCount.value?.toString() ?? '-',
              label: '페이지',
            ),
            const _StatDivider(),
            _StatItem(
              value: DateTime.now().year.toString(),
              label: '작성 연도',
            ),
          ],
        );
      }),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;

  const _StatItem({
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppTheme.text,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppTheme.textPh,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 34,
      color: AppTheme.border,
    );
  }
}

class _ChatContextBar extends StatelessWidget {
  final AvatarRole role;
  final VoidCallback onChangeRole;

  const _ChatContextBar({
    required this.role,
    required this.onChangeRole,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        border: Border(bottom: BorderSide(color: AppTheme.border)),
      ),
      child: Row(
        children: [
          _RoleAvatar(role: role, selected: false),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${role.name}의 관점으로 답변합니다',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.text,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  role.desc,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textSec,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onChangeRole,
            child: const Text(
              '변경',
              style: TextStyle(
                color: AppTheme.ctaDark,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineNotice extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  final Color backgroundColor;

  const _InlineNotice({
    required this.icon,
    required this.text,
    required this.color,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 17),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomAction extends StatelessWidget {
  final Widget child;

  const _BottomAction({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        border: Border(top: BorderSide(color: AppTheme.border)),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: child,
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w900,
        color: AppTheme.textPh,
      ),
    );
  }
}
