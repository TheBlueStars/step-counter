import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../generated/colors.gen.dart';
import '../../../../generated/text_styles.gen.dart';
import '../../../data/models/enums/onboarding_step.dart';
import '../../../widgets/default/button_default.dart';
import '../../../widgets/default/done_lottie_overlay.dart';
import '../../../widgets/default/page_default.dart';
import '../../../widgets/page_switcher.dart';
import '../../../widgets/profiles/age_picker.dart';
import '../../../widgets/profiles/gender_selection.dart';
import '../../../widgets/profiles/measurement_picker.dart';
import '../../../widgets/progress_indicator_widget.dart';
import '../onboarding_controller/onboarding_controller.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return PageDefault(
      canBack: controller.canBack,
      body: SafeArea(child: Obx(_buildBody)),
      bottomNavigationBar: Obx(_buildBottom),
    );
  }

  Widget _buildBody() {
    final step = controller.selectedStep.value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProgressIndicatorWidget(
          showNavigator: !step.isDone,
          onTrailingIconTap: controller.onPreviousStep,
          onSkip: () => controller.onNextStep(isSkip: true),
          totalSteps: controller.steps.length,
          currentStep: step.index,
          inactiveColor: ColorName.borderBackground,
          horizontalPadding: 0,
        ),
        const SizedBox(height: 16),
        Text(
          step.field?.question ?? "",
          style: TextStyles.h5.medium.copyWith(color: ColorName.neutralBlack),
        ),
        const SizedBox(height: 4),
        Text(
          step.field?.note ?? "",
          style: TextStyles.body.copyWith(color: ColorName.neutralGray),
        ),
        const SizedBox(height: 32),
        Expanded(
          child: SingleChildScrollView(
            child: PageSwitcher(
              horizontalPadding: 0,
              child: _buildStep(step),
            ),
          ),
        ),
      ],
    ).paddingSymmetric(horizontal: 16);
  }

  Widget _buildStep(OnboardingStep step) {
    return switch (step) {
      OnboardingStep.gender => GenderSelection(
        key: const ValueKey(OnboardingStep.gender),
        selectedGender: controller.gender.value,
        onGenderSelected: controller.onGenderSelected,
      ),
      OnboardingStep.age => AgePicker(
        key: const ValueKey(OnboardingStep.age),
        selectedAge: controller.age.value,
        onChanged: controller.onAgeChanged,
      ),
      OnboardingStep.height => MeasurementPicker.height(
        key: const ValueKey(OnboardingStep.height),
        initialCm: controller.heightCm.value,
        onChanged: controller.onHeightChanged,
      ),
      OnboardingStep.weight => MeasurementPicker.weight(
        key: const ValueKey(OnboardingStep.weight),
        initialKg: controller.weightKg.value,
        onChanged: controller.onWeightChanged,
      ),
      OnboardingStep.done => Padding(
        key: const ValueKey(OnboardingStep.done),
        padding: const EdgeInsets.only(top: 60),
        child: DoneLottieOverlay(
          title: "You're all set!",
          message: "We'll use this to personalize your step insights.",
          onCompleted: controller.onNextStep,
        ),
      ),
    };
  }

  Widget _buildBottom() {
    if (controller.selectedStep.value.isDone) {
      return const SizedBox.shrink();
    }

    return SafeArea(
      top: false,
      child: ButtonDefault(
        text: "Continue",
        onTap: controller.onNextStep,
      ),
    );
  }
}
