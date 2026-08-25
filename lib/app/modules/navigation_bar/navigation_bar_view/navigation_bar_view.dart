import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_pages.dart';
import '../../../widgets/disposable_page_view.dart';
import '../navigation_bar_argument/navigation_bar_argument.dart';
import '../navigation_bar_controller/navigation_bar_controller.dart';
import 'components/custom_bottom_nav_bar.dart';

class NavigationBarView extends GetView<NavigationBarController> {
  const NavigationBarView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = this.controller;
    return Scaffold(
      body: DisposablePageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: controller.pageController,
        navPages: NavigationPage.values,
        keepAliveOf: (_) => true,
        pageOf: (NavigationPage p1) {
          return switch (p1) {
            .home => Routes.HOME,
            .statistical => Routes.STATISTICAL,
            .achievement => Routes.ACHIEVEMENT,
            .settings => Routes.STATISTICAL,
          };
        },
      ),
      bottomNavigationBar: CustomBottomNavBar(controller: controller),
    );
  }
}
