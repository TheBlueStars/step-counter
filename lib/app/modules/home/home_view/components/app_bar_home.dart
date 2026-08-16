import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/widget_extensions.dart';

import '../../../../../generated/assets.gen.dart';
import '../../../../../generated/colors.gen.dart';
import '../../../../../generated/text_styles.gen.dart';
import '../../../../widgets/scale_tap_widget.dart';

class AppBarHome extends StatelessWidget {
  final int longStreak;
  final VoidCallback? onTapShowStreak;
  const AppBarHome({super.key, required this.longStreak, this.onTapShowStreak});

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return "Good Morning";
    }

    if (hour >= 12 && hour < 18) {
      return "Good Afternoon";
    }

    return "Good Evening";
  }

  @override
  Widget build(BuildContext context) {
    final paddingTop = MediaQuery.of(context).padding.top;
    return Row(
      mainAxisAlignment: .spaceBetween,
      children: [
        TnmText.h5(_greeting).semiBold.copyWith(color: ColorName.neutralBlack),
        Row(
          spacing: 12,
          children: [
            Container(
              height: 32,
              decoration: BoxDecoration(
                color: ColorName.neutralWhite,
                borderRadius: .circular(32),
                border: .all(color: ColorName.primary20),
              ),
              child: Row(
                spacing: 4,
                children: [
                  Assets.images.icStreak.image(width: 24, height: 24),
                  TnmText.body(
                    longStreak.toString(),
                  ).copyWith(color: ColorName.primary100),
                ],
              ).paddingSymmetric(horizontal: 6),
            ),
            ScaleTapWidget(
              onTap: onTapShowStreak,
              child: Container(
                width: 32,
                height: 32,
                padding: .all(6),
                decoration: BoxDecoration(
                  color: ColorName.neutralWhite,
                  shape: .circle,
                ),
                child: Assets.svg.icLineQuestion.svg(),
              ),
            ),
          ],
        ),
      ],
    ).paddingOnly(top: paddingTop, left: 16, right: 16);
  }
}
