import 'user_info_type.dart';

enum OnboardingStep {
  gender(UserInfoType.gender),
  age(UserInfoType.age),
  height(UserInfoType.height),
  weight(UserInfoType.weight),
  done(null);

  const OnboardingStep(this.field);

  final UserInfoType? field;

  bool get isDone => this == OnboardingStep.done;
}
