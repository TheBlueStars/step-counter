import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_pages.dart';
import '../../../services/step_counter_channel.dart';

class SplashController extends GetxController
    with GetSingleTickerProviderStateMixin {
  SplashController({StepCounterChannel? channel})
    : _channel = channel ?? StepCounterChannel();

  final StepCounterChannel _channel;

  late final AnimationController animationController;

  @override
  void onInit() {
    super.onInit();
    animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 3))
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              _openNextScreen();
            }
          });
    animationController.forward();
  }

  @override
  void onClose() {
    animationController.dispose();
    super.onClose();
  }

  /// Lần đầu mở app thì vào Intro, các lần sau vào thẳng màn chính.
  Future<void> _openNextScreen() async {
    final isIntroFinished = await _channel.isIntroFinished();

    await Get.offAllNamed(
      isIntroFinished ? Routes.NAVIGATION_BAR : Routes.INTRO,
    );
  }
}
