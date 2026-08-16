class NavigationBarArguments {}

class NavigationBarResult {}

enum NavigationPage {
  home,
  statistical,
  achievement,
  settings;

  String get displayName => switch (this) {
    NavigationPage.home => "Home",
    NavigationPage.statistical => "Statistical",
    NavigationPage.achievement => "Achievement",
    NavigationPage.settings => "Settings",
  };
}
