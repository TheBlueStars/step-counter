import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/app/modules/home/home_view/components/app_bar_home.dart';
import 'package:project/app/widgets/default/page_default.dart';

import '../home_controller/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return PageDefault(
      appBar: AppBarHome(longStreak: 1),
      body: const Center(child: Text('Home View')),
    );
  }
}
