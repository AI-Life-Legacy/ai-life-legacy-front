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
        MascotHeader(
          message: '한 번에 하나씩만 답해볼게요. 편하게 떠오르는 만큼만 적어주세요.',
          mascotSize: 72,
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
                decoration: InputDecoration(
                  hintText: controller.currentPlaceholder,
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
                ),
              ),
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
            text: controller.isLoading.value
                ? '기억을 정리하는 중...'
                : controller.isLastStep
                    ? '저장하고 계속하기'
                    : '다음 질문',
            loading: controller.isLoading.value,
            onPressed: controller.continueFromCurrentStep,
          ),
        ),
      ),
    );
  }
}
