import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../intro_controller/intro_controller.dart';

class IntroView extends GetView<IntroController> {
  const IntroView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Intro'),
      ),
      body: const Center(
        child: Text('Intro View'),
      ),
    );
  }
}
