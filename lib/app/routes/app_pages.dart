import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:project/app/modules/navigation_bar/navigation_bar_binding/navigation_bar_binding.dart';
import 'package:project/app/modules/navigation_bar/navigation_bar_view/navigation_bar_view.dart';

import '../modules/home/home_binding/home_binding.dart';
import '../modules/home/home_view/home_view.dart';
import '../modules/intro/intro_binding/intro_binding.dart';
import '../modules/intro/intro_view/intro_view.dart';
import '../modules/onboarding/onboarding_binding/onboarding_binding.dart';
import '../modules/onboarding/onboarding_view/onboarding_view.dart';
import '../modules/settings/settings_binding/settings_binding.dart';
import '../modules/settings/settings_view/settings_view.dart';
import '../modules/splash/splash_binding/splash_binding.dart';
import '../modules/splash/splash_view/splash_view.dart';
import '../modules/statistical/statistical_binding/statistical_binding.dart';
import '../modules/statistical/statistical_view/statistical_view.dart';
import '../modules/achievement/achievement_binding/achievement_binding.dart';
import '../modules/achievement/achievement_view/achievement_view.dart';


part 'app_routes.dart';

abstract class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: _Paths.INTRO,
      page: () => const IntroView(),
      binding: IntroBinding(),
    ),
    GetPage(
      name: _Paths.ONBOARDING,
      page: () => const OnboardingView(),
      binding: OnboardingBinding(),
    ),
    GetPage(
      name: _Paths.SPLASH,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: _Paths.NAVIGATION_BAR,
      page: () => const NavigationBarView(),
      binding: NavigationBarBinding(),
    ),
    GetPage(
      name: Routes.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: Routes.STATISTICAL,
      page: () => const StatisticalView(),
      binding: StatisticalBinding(),
    ),
    GetPage(
      name: Routes.SETTINGS,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
    ),
      GetPage(
      name: Routes.ACHIEVEMENT,
      page: () => const AchievementView(),
      binding: AchievementBinding(),
    ),
];
}
