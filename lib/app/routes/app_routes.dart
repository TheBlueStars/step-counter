part of 'app_pages.dart';

abstract class Routes {
  Routes._();
  static const NAVIGATION_BAR = _Paths.NAVIGATION_BAR;
  static const SPLASH = _Paths.SPLASH;
  static const INTRO = _Paths.INTRO;
}

abstract class _Paths {
  _Paths._();
  static const NAVIGATION_BAR = '/navigation_bar';
  static const SPLASH = '/splash';
  static const INTRO = '/intro';
}
