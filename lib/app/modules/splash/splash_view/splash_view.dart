import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../splash_controller/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Splash'),
      ),
      body: const Center(
        child: Text('Splash View'),
      ),
    );
  }
}
