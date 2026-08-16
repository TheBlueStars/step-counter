import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../navigation_bar_argument/navigation_bar_argument.dart';

class NavigationBarController extends GetxController {
  final PageController pageController = PageController();
  final Rx<NavigationPage> _page = Rx(.home);

  NavigationPage get page => _page.value;

  Future<void> changePage(NavigationPage page) async {
    if (this.page == page) {
      return;
    }
    _page.value = page;
    await pageController.animateToPage(
      page.index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
}
