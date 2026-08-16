part of 'app_pages.dart';

abstract class Routes {
  Routes._();
  static const NAVIGATION_BAR = _Paths.NAVIGATION_BAR;
  static const SPLASH = _Paths.SPLASH;
  static const INTRO = _Paths.INTRO;
  static const HOME = _Paths.HOME;
  static const STATISTICAL = _Paths.STATISTICAL;
  static const SETTINGS = _Paths.SETTINGS;
}

abstract class _Paths {
  _Paths._();
  static const NAVIGATION_BAR = '/navigation_bar';
  static const SPLASH = '/splash';
  static const INTRO = '/intro';
  static const HOME = '/home';
  static const STATISTICAL = '/statistical';
  static const SETTINGS = '/settings';
}
