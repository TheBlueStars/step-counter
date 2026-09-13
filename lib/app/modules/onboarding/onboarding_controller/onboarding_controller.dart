import 'package:get/get.dart';

import '../../../data/models/enums/gender.dart';
import '../../../data/models/enums/onboarding_step.dart';
import '../../../routes/app_pages.dart';
import '../../../services/step_counter_channel.dart';
import '../../../services/step_record_service.dart';

class OnboardingController extends GetxController {
  OnboardingController({StepCounterChannel? channel})
    : _channel = channel ?? StepCounterChannel();

  static const Gender defaultGender = Gender.male;
  static const int defaultAge = 18;
  static const double defaultHeightCm = 170;
  static const double defaultWeightKg = 60;

  final StepRecordService _service = StepRecordService.to;
  final StepCounterChannel _channel;

  final Rx<OnboardingStep> selectedStep = Rx(OnboardingStep.gender);

  late final Rx<Gender> gender = Rx(_service.gender.value);
  late final RxInt age = RxInt(_service.age.value);
  late final RxDouble heightCm = RxDouble(_service.heightCm.value);
  late final RxDouble weightKg = RxDouble(_service.weightKg.value);

  final RxBool isSaving = false.obs;

  List<OnboardingStep> get steps =>
      OnboardingStep.values.where((step) => !step.isDone).toList();

  bool canBack() => !selectedStep.value.isDone;

  bool _isLastStep(int index) => index == steps.length - 1;

  void onPreviousStep() {
    final index = selectedStep.value.index;
    if (index <= 0) {
      return;
    }

    selectedStep.value = steps[index - 1];
  }

  Future<void> onNextStep({bool isSkip = false}) async {
    if (selectedStep.value.isDone) {
      await _finish();
      return;
    }

    if (isSkip) {
      _applyDefault();
    }

    final index = selectedStep.value.index;
    if (_isLastStep(index)) {
      selectedStep.value = OnboardingStep.done;
      return;
    }

    selectedStep.value = steps[index + 1];
  }

  void _applyDefault() {
    switch (selectedStep.value) {
      case OnboardingStep.gender:
        gender.value = defaultGender;
      case OnboardingStep.age:
        age.value = defaultAge;
      case OnboardingStep.height:
        heightCm.value = defaultHeightCm;
      case OnboardingStep.weight:
        weightKg.value = defaultWeightKg;
      case OnboardingStep.done:
        break;
    }
  }

  void onGenderSelected(Gender value) => gender.value = value;

  void onAgeChanged(int value) => age.value = value;

  void onHeightChanged(double value) => heightCm.value = value;

  void onWeightChanged(double value) => weightKg.value = value;

  Future<void> _finish() async {
    if (isSaving.value) {
      return;
    }

    isSaving.value = true;
    await _service.updateProfile(
      height: heightCm.value,
      weight: weightKg.value,
      userGender: gender.value,
      userAge: age.value,
    );
    await _channel.setIntroFinished();
    await Get.offAllNamed(Routes.NAVIGATION_BAR);
  }
}
