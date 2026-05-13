import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ai_life_legacy/app/core/theme/app_theme.dart';
import 'package:ai_life_legacy/app/core/theme/widgets/chat_widgets.dart';
import 'package:ai_life_legacy/app/core/theme/widgets/app_chat_input.dart';
import 'package:ai_life_legacy/features/avatar_chat/presentation/controllers/avatar_chat_controller.dart';
import 'package:ai_life_legacy/app/core/utils/token_storage.dart';

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

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => controller.handleBack(),
        ),
        title: const Text(
          '아바타 역할 선택',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.text),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppTheme.border),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              children: [
                Obx(() => Text(
                  '${controller.authorName.value} 님의 아바타',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPh,
                    letterSpacing: 0.1,
                  ),
                )),
                const SizedBox(height: 6),
                const Text(
                  '어떤 목소리로\n이야기를 만나시겠어요?',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.text,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  '선택하신 역할에 따라 아바타의 말투가 달라져요. 언제든 다시 바꿀 수 있어요.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSec,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  '추천',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPh,
                    letterSpacing: 0.08,
                  ),
                ),
                const SizedBox(height: 8),
                ...basicRoles.map((r) => _buildRoleCard(r)),
                const SizedBox(height: 20),
                const Text(
                  '가족 · 가까운 관계',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPh,
                    letterSpacing: 0.08,
                  ),
                ),
                const SizedBox(height: 8),
                ...familyRoles.map((r) => _buildRoleCard(r)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 12, bottom: 24),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppTheme.border, width: 1)),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => controller.goToIntro(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.cta,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  '${controller.selectedRole.name}(으)로 만나기',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleCard(AvatarRole role) {
    final isSelected = controller.selectedRoleId.value == role.id;
    return GestureDetector(
      onTap: () => controller.selectRole(role.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.cta : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.cta : AppTheme.border,
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.cta.withValues(alpha: 0.12),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  )
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.01),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  )
                ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isSelected ? Colors.white.withValues(alpha: 0.14) : AppTheme.bgAlt,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.white.withValues(alpha: 0.3) : AppTheme.border,
                  width: 1,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                role.emoji,
                style: TextStyle(
                  fontSize: 16,
                  color: isSelected ? Colors.white : AppTheme.textSec,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        role.name,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : AppTheme.text,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        role.sub,
                        style: TextStyle(
                          fontSize: 11,
                          color: isSelected ? Colors.white.withValues(alpha: 0.7) : AppTheme.textSec,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    role.desc,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.5,
                      color: isSelected ? Colors.white.withValues(alpha: 0.85) : AppTheme.textSec,
                    ),
                  ),
                  if (isSelected) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(6),
                        border: Border(
                          left: BorderSide(
                            color: Colors.white.withValues(alpha: 0.4),
                            width: 2,
                          ),
                        ),
                      ),
                      child: Text(
                        '"${role.greet}"',
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.55,
                          fontStyle: FontStyle.italic,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.white : AppTheme.border,
                  width: 1.5,
                ),
                color: isSelected ? Colors.white : Colors.transparent,
              ),
              alignment: Alignment.center,
              child: isSelected
                  ? Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.text,
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIntro(BuildContext context) {
    final role = controller.selectedRole;
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => controller.handleBack(),
        ),
        title: const Text(
          '역할 소개',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.text),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppTheme.border),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight - 48,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 12),
                  // Avatar Profile Circle
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppTheme.bgAlt,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.border, width: 1),
                    ),
                    alignment: Alignment.center,
                    child: Obx(() {
                      final name = controller.authorName.value;
                      final initial = name.isNotEmpty ? name.substring(0, name.length > 1 ? 2 : 1).toUpperCase() : 'U';
                      return Text(
                        initial,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.text,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '이분의 이야기를 만나보세요',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textPh,
                      letterSpacing: 0.1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Obx(() => Text(
                    controller.authorName.value,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.text,
                    ),
                  )),
                  const SizedBox(height: 10),
                  // Badge + Change Role Underlined text
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          role.emoji,
                          style: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${role.name} 목소리로 대화 중',
                          style: const TextStyle(fontSize: 11, color: AppTheme.textSec),
                        ),
                        const SizedBox(width: 6),
                        const SizedBox(
                          height: 10,
                          child: VerticalDivider(
                            width: 1,
                            thickness: 1,
                            color: AppTheme.border,
                          ),
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () => controller.goToRoleSelect(),
                          child: const Text(
                            '변경',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.text,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  // Inset card for Book Info + Quote
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '자서전에 대해',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textPh,
                            letterSpacing: 0.1,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // 3 column stats dynamically loaded from controller
                        Obx(() => Row(
                          children: [
                            if (controller.totalChapters.value != null) ...[
                              _buildStatItem('${controller.totalChapters.value}', '챕터'),
                              const SizedBox(
                                height: 24,
                                child: VerticalDivider(
                                  width: 1,
                                  thickness: 1,
                                  color: AppTheme.border,
                                ),
                              ),
                            ],
                            _buildStatItem(controller.pageCount.value != null ? '${controller.pageCount.value}' : '-', '쪽'),
                            const SizedBox(
                              height: 24,
                              child: VerticalDivider(
                                width: 1,
                                thickness: 1,
                                color: AppTheme.border,
                              ),
                            ),
                            _buildStatItem('${DateTime.now().year}', '작성 연도'),
                          ],
                        )),
                        const SizedBox(height: 12),
                        const Divider(height: 1, color: AppTheme.border),
                        const SizedBox(height: 12),
                        Text(
                          '"${role.greet}"',
                          style: const TextStyle(
                            fontSize: 15,
                            fontStyle: FontStyle.italic,
                            color: AppTheme.text,
                            height: 1.7,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  // CTA Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () => controller.startChat(),
                      icon: const Icon(Icons.chat_bubble_outline, size: 18),
                      label: Text(
                        '${role.name}와 대화 시작하기',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.cta,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Obx(() => Text(
                    '${controller.authorName.value}${controller.authorName.value == '사용자' || controller.authorName.value == '작성자' ? '님' : ' 님'}의 삶에 대해 무엇이든 물어보세요.',
                    style: const TextStyle(fontSize: 12, color: AppTheme.textPh),
                    textAlign: TextAlign.center,
                  )),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppTheme.text,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppTheme.textPh,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChat(BuildContext context) {
    final role = controller.selectedRole;
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => controller.handleBack(),
        ),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Obx(() => Text(
              controller.authorName.value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.text),
            )),
            const SizedBox(height: 2),
            Text(
              '현재 역할: ${role.name}',
              style: const TextStyle(fontSize: 11, color: AppTheme.textSec, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (!TokenStorage.isViewerMode())
            IconButton(
              onPressed: () => controller.generateViewerCode(),
              icon: const Icon(Icons.share_outlined, color: AppTheme.textSec),
            ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppTheme.border),
        ),
      ),
      body: Column(
        children: [
          // Dynamic minimal header bar showing current role and allowing change
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: AppTheme.bgAlt,
            child: Row(
              children: [
                Text(
                  '${role.emoji}  현재 ${role.name} 역할로 대화 중입니다.',
                  style: const TextStyle(fontSize: 11, color: AppTheme.textSec, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => controller.goToRoleSelect(),
                  child: const Text(
                    '역할 변경',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.success,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppTheme.border),

          // Chat Messages List
          Expanded(
            child: Obx(() {
              if (controller.messages.isEmpty) {
                return const Center(
                  child: Text(
                    '대화를 시작해보세요.',
                    style: TextStyle(color: AppTheme.textPh),
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: controller.messages.length,
                itemBuilder: (context, index) {
                  final msg = controller.messages[index];
                  final isAi = msg['role'] == 'ai';
                  final text = msg['text'] ?? '';
                  return isAi ? AIBubble(text: text) : UserBubble(text: text);
                },
              );
            }),
          ),

          // Error Message Display inside the chat page
          Obx(() {
            if (controller.errorMessage.value.isEmpty) {
              return const SizedBox.shrink();
            }
            return Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.errorBg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.error.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: AppTheme.error, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      controller.errorMessage.value,
                      style: const TextStyle(color: AppTheme.error, fontSize: 12),
                    ),
                  ),
                ],
              ),
            );
          }),

          // Chat Input bar
          AppChatInput(
            placeholder: '${role.name}에게 말을 걸어보세요...',
            onSend: (v) => controller.sendMessage(v),
          ),
        ],
      ),
    );
  }
}
