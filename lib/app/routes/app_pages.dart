import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:project/app/modules/navigation_bar/navigation_bar_binding/navigation_bar_binding.dart';
import 'package:project/app/modules/navigation_bar/navigation_bar_view/navigation_bar_view.dart';

import '../modules/intro/intro_binding/intro_binding.dart';
import '../modules/intro/intro_view/intro_view.dart';
import '../modules/splash/splash_binding/splash_binding.dart';
import '../modules/splash/splash_view/splash_view.dart';

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
      name: _Paths.SPLASH,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: _Paths.NAVIGATION_BAR,
      page: () => const NavigationBarView(),
      binding: NavigationBarBinding(),
    ),
  ];
}
