import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../navigation_bar_controller/navigation_bar_controller.dart';

class NavigationBarView extends GetView<NavigationBarController> {
  const NavigationBarView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NavigationBar'),
      ),
      body: const Center(
        child: Text('NavigationBar View'),
      ),
    );
  }
}
