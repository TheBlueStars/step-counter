enum UserInfoType {
  gender,
  age,
  height,
  weight;

  String get title => switch (this) {
    UserInfoType.gender => "Gender",
    UserInfoType.age => "Age",
    UserInfoType.height => "Height",
    UserInfoType.weight => "Weight",
  };

  String get question => switch (this) {
    UserInfoType.gender => "What's your gender?",
    UserInfoType.age => "How old are you?",
    UserInfoType.height => "What's your height?",
    UserInfoType.weight => "What's your weight?",
  };

  String get note => switch (this) {
    UserInfoType.gender => "Used to personalize your activity stats.",
    UserInfoType.age => "Helps improve your health insights.",
    UserInfoType.height => "Used to estimate your walking distance.",
    UserInfoType.weight => "Helps calculate calories burned.",
  };
}
