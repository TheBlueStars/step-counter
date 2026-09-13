import 'package:project/generated/assets.gen.dart';

enum Gender {
  male,
  female,
  none;

  static Gender fromName(String? value) => Gender.values.firstWhere(
    (gender) => gender.name == value,
    orElse: () => Gender.none,
  );

  String get displayName => switch (this) {
    Gender.male => "👦🏻 Male",
    Gender.female => "👧🏻 Female",
    Gender.none => "Prefer not to say",
  };

  String get shortName => switch (this) {
    Gender.male => "Male",
    Gender.female => "Female",
    Gender.none => "Prefer not to say",
  };

  AssetGenImage? get icon => switch (this) {
    Gender.male => Assets.images.icMale,
    Gender.female => Assets.images.icFemale,
    Gender.none => null,
  };
}
