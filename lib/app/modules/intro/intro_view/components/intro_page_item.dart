import 'package:flutter/material.dart';

import '../../../../../generated/colors.gen.dart';
import '../../../../../generated/text_styles.gen.dart';
import '../../intro_controller/intro_controller.dart';

class IntroPageItem extends StatelessWidget {
  const IntroPageItem({super.key, required this.page});

  final IntroPageModel page;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SizedBox(
            width: double.infinity,
            child: page.image.image(
              fit: BoxFit.cover,
              alignment: Alignment.bottomCenter,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            page.title,
            textAlign: TextAlign.center,
            style: TextStyles.h5.semiBold.copyWith(color: ColorName.primary100),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            page.message,
            textAlign: TextAlign.center,
            style: TextStyles.body.medium.copyWith(
              color: ColorName.neutralGray,
            ),
          ),
        ),
      ],
    );
  }
}
