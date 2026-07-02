import 'package:ai_life_legacy/app/core/theme/app_theme.dart';
import 'package:ai_life_legacy/app/core/theme/widgets/app_chat_input.dart';
import 'package:ai_life_legacy/app/core/theme/widgets/chat_widgets.dart';
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
      title: '대화 모드',
      onBack: controller.handleBack,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
              children: [
                _HeroPanel(
                  eyebrow:
                      Obx(() => Text('${controller.authorName.value}님의 기록')),
                  title: '어떤 말투로\n기억을 열어볼까요?',
                  body: '역할은 말투와 질문의 속도만 바꿉니다. 언제든 다시 선택할 수 있습니다.',
                ),
                const SizedBox(height: 22),
                const _SectionLabel('추천'),
                const SizedBox(height: 10),
                ...basicRoles.map((role) => Obx(() {
                      return _RoleCard(
                        role: role,
                        selected: controller.selectedRoleId.value == role.id,
                        onTap: () => controller.selectRole(role.id),
                      );
                    })),
                const SizedBox(height: 18),
                const _SectionLabel('가족 톤'),
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
                label: Text('${role.name}으로 계속'),
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
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        child: Column(
          children: [
            _PreviewPanel(role: role),
            const SizedBox(height: 14),
            _MemoryStatsCard(controller: controller),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: controller.startChat,
                icon: const Icon(Icons.forum_outlined, size: 19),
                label: Text('${role.name} 시작'),
                style: _primaryButtonStyle(),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: controller.goToRoleSelect,
              child: const Text('다른 톤 선택'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChat(BuildContext context) {
    final role = controller.selectedRole;

    return _AvatarShell(
      title: controller.authorName.value,
      subtitle: '${role.name} 대화 중',
      onBack: controller.handleBack,
      action: TokenStorage.isViewerMode()
          ? null
          : IconButton(
              tooltip: '공유 코드 만들기',
              onPressed: controller.generateViewerCode,
              icon: const Icon(Icons.ios_share_rounded),
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
                    child: _EmptyChat(role: role),
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
                      text: '${role.name}이 답변을 정리하고 있습니다.',
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
              placeholder: '${role.name}에게 묻거나 기억을 적어보세요',
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
      backgroundColor: AppTheme.text,
      foregroundColor: Colors.white,
      disabledBackgroundColor: AppTheme.border,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
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
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ],
        ),
        centerTitle: true,
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

  const _HeroPanel({
    required this.eyebrow,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.text,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 48, height: 14, color: AppTheme.sun),
              const SizedBox(width: 8),
              Container(width: 20, height: 20, color: AppTheme.sky),
            ],
          ),
          const SizedBox(height: 18),
          DefaultTextStyle(
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Colors.white70,
            ),
            child: eyebrow,
          ),
          const SizedBox(height: 7),
          Text(
            title,
            style: const TextStyle(
              fontSize: 28,
              height: 1.12,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 9),
          Text(
            body,
            style: const TextStyle(
              fontSize: 13,
              height: 1.55,
              color: Colors.white70,
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
        color: selected ? AppTheme.surfaceElevated : AppTheme.surface,
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
                color: selected ? AppTheme.text : AppTheme.border,
                width: selected ? 1.5 : 1,
              ),
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
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: AppTheme.text,
                              ),
                            ),
                          ),
                          Text(
                            role.sub,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPh,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        role.desc,
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.45,
                          color: AppTheme.textSec,
                        ),
                      ),
                      if (selected) ...[
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.surface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppTheme.border),
                          ),
                          child: Text(
                            role.greet,
                            style: const TextStyle(
                              color: AppTheme.text,
                              height: 1.45,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
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
                  color: selected ? AppTheme.ctaDark : AppTheme.border,
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
        color: selected ? AppTheme.sun : AppTheme.bgAlt,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: selected ? AppTheme.text : AppTheme.border),
      ),
      alignment: Alignment.center,
      child: Text(
        role.emoji,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w900,
          color: AppTheme.text,
        ),
      ),
    );
  }
}

class _PreviewPanel extends StatelessWidget {
  final AvatarRole role;

  const _PreviewPanel({required this.role});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.text),
      ),
      child: Column(
        children: [
          _RoleAvatar(role: role, selected: true),
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
          Text(
            role.greet,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppTheme.text,
              height: 1.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyChat extends StatelessWidget {
  final AvatarRole role;

  const _EmptyChat({required this.role});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _RoleAvatar(role: role, selected: true),
          const SizedBox(height: 12),
          Text(
            role.sample,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppTheme.text,
              fontSize: 15,
              height: 1.45,
              fontWeight: FontWeight.w800,
            ),
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
        border: Border.all(color: AppTheme.border),
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
              label: '연도',
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
    return Container(width: 1, height: 34, color: AppTheme.border);
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
                  '${role.name}으로 듣고 있습니다',
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
                  style: const TextStyle(fontSize: 11, color: AppTheme.textSec),
                ),
              ],
            ),
          ),
          TextButton(onPressed: onChangeRole, child: const Text('변경')),
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
      child: SizedBox(width: double.infinity, height: 54, child: child),
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
