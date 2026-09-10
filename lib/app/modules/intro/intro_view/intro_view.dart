import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../generated/colors.gen.dart';
import '../../../../generated/text_styles.gen.dart';
import '../../../widgets/scale_tap_widget.dart';
import '../intro_controller/intro_controller.dart';
import 'components/animated_hand.dart';
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
            _buildSkipBar(),
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

  Widget _buildSkipBar() {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Obx(
          () => AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: controller.isLastPage ? 0 : 1,
            child: IgnorePointer(
              ignoring: controller.isLastPage,
              child: ScaleTapWidget(
                onTap: controller.onTapSkip,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: ColorName.primary20,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    "Skip",
                    style: TextStyles.body.semiBold.copyWith(
                      color: ColorName.primary100,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottom() {
    return Obx(() {
      final index = controller.currentIndex.value;
      final showHand = controller.pages[index].showHand;

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
              if (showHand)
                Positioned(right: 16, bottom: 0, child: const AnimatedHand()),
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
            child: child!,
          ),
        );
      },
      child: Obx(
        () => Container(
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 14),
          decoration: BoxDecoration(
            color: ColorName.primary100,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Text(
            controller.isLastPage ? "Get Started" : "Next",
            style: TextStyles.title.bold.copyWith(
              color: ColorName.neutralWhite,
            ),
          ),
        ),
      ),
    );
  }
}
