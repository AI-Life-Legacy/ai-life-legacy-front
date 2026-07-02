import 'package:ai_life_legacy/app/core/theme/widgets/mascot_flow_widgets.dart';
import 'package:ai_life_legacy/features/onboarding/presentation/controllers/onboarding_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SelfIntroPage extends GetView<OnboardingController> {
  const SelfIntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MascotScaffold(
      padding: EdgeInsets.zero,
      bottom: _BottomActions(controller: controller),
      child: Obx(
        () => Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: _IntroTopBar(controller: controller),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 420),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) {
                  final curved = CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                    reverseCurve: Curves.easeInCubic,
                  );
                  return FadeTransition(
                    opacity: curved,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.08),
                        end: Offset.zero,
                      ).animate(curved),
                      child: ScaleTransition(
                        scale:
                            Tween<double>(begin: 0.985, end: 1).animate(curved),
                        child: child,
                      ),
                    ),
                  );
                },
                child: _QuestionStep(
                  key: ValueKey(controller.currentStep.value),
                  controller: controller,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IntroTopBar extends StatelessWidget {
  final OnboardingController controller;

  const _IntroTopBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            _BackButton(controller: controller),
            const SizedBox(width: 12),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  value: controller.progress,
                  minHeight: 10,
                  backgroundColor: MascotFlowTheme.surface,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    MascotFlowTheme.active,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '${controller.currentStep.value}/${controller.totalSteps.value}',
              style: const TextStyle(
                color: MascotFlowTheme.textMuted,
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Obx(
          () => MascotHeader(
            message: controller.headerMessage,
            mascotSize: 72,
          ),
        ),
      ],
    );
  }
}

class _BackButton extends StatelessWidget {
  final OnboardingController controller;

  const _BackButton({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: controller.isFirstStep ? 0.35 : 1,
      duration: const Duration(milliseconds: 180),
      child: Material(
        color: MascotFlowTheme.surface,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: controller.isFirstStep ? null : controller.goToPreviousStep,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: MascotFlowTheme.border, width: 2),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: MascotFlowTheme.text,
              size: 18,
            ),
          ),
        ),
      ),
    );
  }
}

class _QuestionStep extends StatelessWidget {
  final OnboardingController controller;

  const _QuestionStep({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 26, 20, 24),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: MascotFlowTheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: MascotFlowTheme.border, width: 2),
            boxShadow: const [
              BoxShadow(
                color: Color(0x3302080B),
                blurRadius: 26,
                offset: Offset(0, 16),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF0B171C),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: MascotFlowTheme.active, width: 2),
                ),
                child: Icon(
                  controller.currentIcon,
                  color: MascotFlowTheme.active,
                ),
              ),
              const SizedBox(height: 22),
              Text(
                controller.currentTitle,
                style: const TextStyle(
                  color: MascotFlowTheme.text,
                  fontSize: 25,
                  height: 1.22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                controller.currentDescription,
                style: const TextStyle(
                  color: MascotFlowTheme.textMuted,
                  fontSize: 14,
                  height: 1.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 22),
              if (controller.isProfileStep)
                _ProfileFields(controller: controller)
              else if (controller.isPurposeStep)
                _PurposePicker(controller: controller)
              else if (controller.isStyleStep)
                _StylePicker(controller: controller)
              else
                _WritingFields(controller: controller),
            ],
          ),
        ),
        Obx(() {
          if (controller.errorMessage.value.isEmpty) {
            return const SizedBox.shrink();
          }

          return Padding(
            padding: const EdgeInsets.only(top: 14),
            child: FlowOptionCard(
              icon: Icons.error_outline,
              title: controller.errorMessage.value,
              subtitle: '잠시 후 다시 시도해주세요.',
              selected: true,
              onTap: () {},
            ),
          );
        }),
      ],
    );
  }
}

class _ProfileFields extends StatelessWidget {
  final OnboardingController controller;

  const _ProfileFields({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ProfileTextField(
          controller: controller.nameController,
          label: '이름',
          hintText: '예: 김하늘',
          icon: Icons.person_outline,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 18),
        _AgePicker(controller: controller),
        const SizedBox(height: 18),
        const Text(
          '성별',
          style: TextStyle(
            color: MascotFlowTheme.text,
            fontSize: 15,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 10),
        Obx(
          () => Column(
            children: controller.genderOptions.map((option) {
              return FlowOptionCard(
                icon: option.icon,
                title: option.label,
                subtitle: option.subtitle,
                selected: controller.selectedGender.value == option.label,
                onTap: () => controller.selectGender(option.label),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          '현재 상태',
          style: TextStyle(
            color: MascotFlowTheme.text,
            fontSize: 15,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 10),
        Obx(
          () => Column(
            children: controller.lifeStageOptions.map((option) {
              return FlowOptionCard(
                icon: option.icon,
                title: option.label,
                subtitle: option.subtitle,
                selected: controller.selectedLifeStage.value == option.label,
                onTap: () => controller.selectLifeStage(option.label),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _AgePicker extends StatelessWidget {
  final OnboardingController controller;

  const _AgePicker({required this.controller});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller.ageController,
      builder: (context, value, _) {
        final age = int.tryParse(value.text.trim());

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: MascotFlowTheme.bg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: MascotFlowTheme.border, width: 2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.cake_outlined,
                    color: MascotFlowTheme.active,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    '나이',
                    style: TextStyle(
                      color: MascotFlowTheme.text,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _AgeButton(
                    icon: Icons.remove_rounded,
                    onTap: () => controller.adjustAge(-1),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        age == null ? '선택' : '$age세',
                        style: const TextStyle(
                          color: MascotFlowTheme.text,
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  _AgeButton(
                    icon: Icons.add_rounded,
                    onTap: () => controller.adjustAge(1),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _AgeQuickChip(
                    label: '10대',
                    selected: age != null && age >= 10 && age < 20,
                    onTap: () => controller.setAge(18),
                  ),
                  _AgeQuickChip(
                    label: '20대',
                    selected: age != null && age >= 20 && age < 30,
                    onTap: () => controller.setAge(25),
                  ),
                  _AgeQuickChip(
                    label: '30대',
                    selected: age != null && age >= 30 && age < 40,
                    onTap: () => controller.setAge(35),
                  ),
                  _AgeQuickChip(
                    label: '40대',
                    selected: age != null && age >= 40 && age < 50,
                    onTap: () => controller.setAge(45),
                  ),
                  _AgeQuickChip(
                    label: '50대',
                    selected: age != null && age >= 50 && age < 60,
                    onTap: () => controller.setAge(55),
                  ),
                  _AgeQuickChip(
                    label: '60대+',
                    selected: age != null && age >= 60,
                    onTap: () => controller.setAge(65),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AgeButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _AgeButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF0B171C),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          width: 52,
          height: 52,
          child: Icon(icon, color: MascotFlowTheme.active, size: 28),
        ),
      ),
    );
  }
}

class _AgeQuickChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _AgeQuickChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? MascotFlowTheme.active : MascotFlowTheme.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? const Color(0xFF0B171C) : MascotFlowTheme.border,
              width: 2,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : MascotFlowTheme.text,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}

class _PurposePicker extends StatelessWidget {
  final OnboardingController controller;

  const _PurposePicker({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        children: controller.purposeOptions.map((option) {
          return FlowOptionCard(
            icon: option.icon,
            title: option.label,
            subtitle: option.subtitle,
            selected: controller.selectedPurposeIds.contains(option.id),
            onTap: () => controller.togglePurpose(option.id),
          );
        }).toList(),
      ),
    );
  }
}

class _StylePicker extends StatelessWidget {
  final OnboardingController controller;

  const _StylePicker({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...controller.styleOptions.map((option) {
            return FlowOptionCard(
              icon: option.icon,
              title: option.label,
              subtitle: option.subtitle,
              selected: controller.selectedStyleId.value == option.id,
              onTap: () => controller.selectStyle(option.id),
            );
          }),
          const SizedBox(height: 8),
          _TocPreview(controller: controller),
        ],
      ),
    );
  }
}

class _TocPreview extends StatelessWidget {
  final OnboardingController controller;

  const _TocPreview({required this.controller});

  @override
  Widget build(BuildContext context) {
    final chapters = controller.personalizedTocPlan;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0B171C),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: MascotFlowTheme.border, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.account_tree_outlined,
                color: MascotFlowTheme.active,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                '예상 목차 미리보기',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            '아래 번호는 질문 번호가 아니라 완성될 자서전의 장 순서예요.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              height: 1.45,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          ...chapters.asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: MascotFlowTheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: MascotFlowTheme.border,
                        width: 1.4,
                      ),
                    ),
                    child: Text(
                      '${entry.key + 1}',
                      style: const TextStyle(
                        color: MascotFlowTheme.active,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      entry.value,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        height: 1.35,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _WritingFields extends StatelessWidget {
  final OnboardingController controller;

  const _WritingFields({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SpeechInputBar(controller: controller),
        const SizedBox(height: 12),
        TextField(
          controller: controller.currentTextController,
          minLines: 7,
          maxLines: 10,
          textInputAction: TextInputAction.newline,
          style: const TextStyle(
            color: MascotFlowTheme.text,
            fontSize: 16,
            height: 1.5,
            fontWeight: FontWeight.w700,
          ),
          decoration: _inputDecoration(controller.currentPlaceholder),
        ),
      ],
    );
  }
}

class _ProfileTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hintText;
  final IconData icon;
  final TextInputAction? textInputAction;

  const _ProfileTextField({
    required this.controller,
    required this.label,
    required this.hintText,
    required this.icon,
    this.textInputAction,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textInputAction: textInputAction,
      style: const TextStyle(
        color: MascotFlowTheme.text,
        fontSize: 16,
        fontWeight: FontWeight.w800,
      ),
      decoration: _inputDecoration(hintText).copyWith(
        labelText: label,
        labelStyle: const TextStyle(
          color: MascotFlowTheme.textMuted,
          fontWeight: FontWeight.w800,
        ),
        prefixIcon: Icon(icon, color: MascotFlowTheme.active),
      ),
    );
  }
}

InputDecoration _inputDecoration(String hintText) {
  return InputDecoration(
    hintText: hintText,
    hintStyle: const TextStyle(
      color: MascotFlowTheme.textMuted,
      fontSize: 14,
      height: 1.45,
    ),
    filled: true,
    fillColor: MascotFlowTheme.bg,
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
        width: 2.4,
      ),
    ),
  );
}

class _SpeechInputBar extends StatelessWidget {
  final OnboardingController controller;

  const _SpeechInputBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        final active = controller.isListening.value;
        final starting = controller.isSpeechStarting.value;
        final highlighted = active || starting;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: highlighted
                ? const Color(0xFF173319)
                : const Color(0xFF0B171C),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color:
                  highlighted ? const Color(0xFF58CC02) : MascotFlowTheme.border,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  controller.speechStatusMessage.value,
                  style: TextStyle(
                    color: highlighted
                        ? const Color(0xFFBDF2A0)
                        : MascotFlowTheme.textMuted,
                    fontSize: 13,
                    height: 1.35,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Material(
                color: highlighted
                    ? const Color(0xFF58CC02)
                    : MascotFlowTheme.surface,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: starting ? null : controller.toggleListening,
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 44,
                    height: 44,
                    child: starting
                        ? const Center(
                            child: SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                color: Colors.white,
                              ),
                            ),
                          )
                        : Icon(
                            active
                                ? Icons.stop_rounded
                                : Icons.mic_none_rounded,
                            color: active ? Colors.white : MascotFlowTheme.text,
                          ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BottomActions extends StatelessWidget {
  final OnboardingController controller;

  const _BottomActions({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        decoration: const BoxDecoration(
          color: MascotFlowTheme.bg,
          border: Border(
            top: BorderSide(color: Color(0x2235505A), width: 1),
          ),
        ),
        child: Obx(
          () => FlowPrimaryButton(
            text: controller.primaryButtonText,
            loading: controller.isLoading.value,
            onPressed: controller.continueFromCurrentStep,
          ),
        ),
      ),
    );
  }
}
