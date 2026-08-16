import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../generated/assets.gen.dart';
import '../../../../generated/colors.gen.dart';
import '../../../../generated/text_styles.gen.dart';
import '../../../widgets/default/page_default.dart';
import '../splash_controller/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;

    return PageDefault(
      useBackgroundImage: true,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: screenHeight * 0.25),
          Center(
            child: Container(
              decoration: BoxDecoration(
                boxShadow: kElevationToShadow[4],
                borderRadius: BorderRadius.circular(40),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: Assets.images.appIcon.image(
                  height: screenHeight * 0.25,
                  width: screenHeight * 0.25,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              'Step Counter',
              textAlign: TextAlign.center,
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: AnimatedBuilder(
              animation: controller.animationController,
              builder: (BuildContext context, Widget? child) {
                final value = controller.animationController.value;
                return Column(
                  children: [
                    Text(
                      'Loading ${(value * 100).toStringAsFixed(0)}%',
                      style: TextStyles.title.regular,
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 65),
                      child: SizedBox(
                        height: 8,
                        child: LinearProgressIndicator(
                          value: value,
                          borderRadius: BorderRadius.circular(100),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            ColorName.primary100,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          Text(
            'This action can contain ads',
            style: TextStyles.title,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
