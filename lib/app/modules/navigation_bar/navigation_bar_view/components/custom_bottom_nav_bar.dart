import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

import '../../../../../generated/assets.gen.dart';
import '../../../../../generated/colors.gen.dart';
import '../../../../widgets/scale_tap_widget.dart';
import '../../navigation_bar_argument/navigation_bar_argument.dart';
import '../../navigation_bar_controller/navigation_bar_controller.dart';

class CustomBottomNavBar extends StatelessWidget {
  final NavigationBarController controller;

  const CustomBottomNavBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: ColorName.neutralWhite,

        boxShadow: [
          BoxShadow(
            color: ColorName.neutralBlack.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SizedBox(
        height: 70,
        child: Row(
          children: NavigationPage.values
              .map((page) => Expanded(child: _buildTab(page)))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildTab(NavigationPage page) {
    return ScaleTapWidget(
      onTap: () => controller.changePage(page),
      child: Obx(() {
        final isSelected = controller.page == page;
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            isSelected ? _svgActiveOf(page).svg() : _svgOf(page).svg(),
            SizedBox(height: 6),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              height: 3,
              width: isSelected ? 64 : 0,
              decoration: BoxDecoration(
                color: ColorName.primary100,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        );
      }),
    );
  }

  SvgGenImage _svgOf(NavigationPage page) => switch (page) {
    .home => Assets.svg.icLineHome,
    .statistical => Assets.svg.icLineStatistical,
    .achievement => Assets.svg.icLineAchievement,
    .settings => Assets.svg.icLineSetting,
  };

  SvgGenImage _svgActiveOf(NavigationPage page) => switch (page) {
    .home => Assets.svg.icLineHomeActive,
    .statistical => Assets.svg.icLineStatisticalActive,
    .achievement => Assets.svg.icLineAchievementActive,
    .settings => Assets.svg.icLineSettingActive,
  };
}
