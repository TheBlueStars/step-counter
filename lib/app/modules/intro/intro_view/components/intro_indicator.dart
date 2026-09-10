import 'package:flutter/material.dart';

import '../../../../../generated/colors.gen.dart';

class IntroIndicator extends StatelessWidget {
  const IntroIndicator({
    super.key,
    required this.length,
    required this.currentIndex,
    this.size = 10,
  });

  final int length;
  final int currentIndex;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(length, (index) {
        final selected = index == currentIndex;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: selected ? size * 3 : size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            color: selected ? ColorName.primary100 : ColorName.primary20,
          ),
        );
      }),
    );
  }
}
