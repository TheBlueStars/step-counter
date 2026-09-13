import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../generated/colors.gen.dart';
import '../../../../generated/text_styles.gen.dart';
import '../../../widgets/scale_tap_widget.dart';
import '../intro_controller/intro_controller.dart';
import 'components/intro_indicator.dart';
import 'components/intro_page_item.dart';

class IntroView extends GetView<IntroController> {
  const IntroView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorName.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: controller.pageController,
                onPageChanged: controller.onPageChanged,
                itemCount: controller.pages.length,
                itemBuilder: (context, index) =>
                    IntroPageItem(page: controller.pages[index]),
              ),
            ),
            _buildBottom(),
          ],
        ),
      ),
    );
  }

  Widget _buildBottom() {
    return Obx(() {
      final index = controller.currentIndex.value;

      return SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IntroIndicator(
                    length: controller.pages.length,
                    currentIndex: index,
                  ),
                  const SizedBox(height: 20),
                  _buildNextButton(),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildNextButton() {
    return AnimatedBuilder(
      animation: controller.animationController,
      builder: (context, child) {
        final value = controller.animationController.value;

        return Opacity(
          opacity: value,
          child: ScaleTapWidget(
            onTap: value < 1 ? null : controller.onTapNext,
            child: TnmText.body(
              "Next",
            ).regular.copyWith(color: ColorName.primary100),
          ),
        );
      },
    );
  }
}
