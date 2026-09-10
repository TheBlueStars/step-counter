import 'package:flutter/material.dart';

import '../../../../../generated/assets.gen.dart';

/// Lottie bàn tay gợi ý người dùng bấm Next / vuốt sang trang kế.
class AnimatedHand extends StatelessWidget {
  const AnimatedHand({super.key, this.size = 72});

  final double size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Assets.lottie.icHand.lottie(
        width: size,
        height: size,
        animate: true,
        repeat: true,
      ),
    );
  }
}
