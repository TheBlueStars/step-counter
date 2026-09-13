import 'package:flutter/material.dart';

import '../../../generated/assets.gen.dart';
import '../../../generated/colors.gen.dart';
import '../../../generated/text_styles.gen.dart';

/// Lottie "done" chạy một lần rồi gọi [onCompleted] — dùng ở bước cuối
/// của onboarding.
class DoneLottieOverlay extends StatefulWidget {
  const DoneLottieOverlay({
    super.key,
    this.title,
    this.message,
    this.size = 200,
    this.durationMs = 3000,
    this.onCompleted,
  });

  final String? title;
  final String? message;
  final double size;
  final int durationMs;
  final VoidCallback? onCompleted;

  @override
  State<DoneLottieOverlay> createState() => _DoneLottieOverlayState();
}

class _DoneLottieOverlayState extends State<DoneLottieOverlay> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: widget.durationMs), () {
      if (mounted) {
        widget.onCompleted?.call();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Assets.lottie.done.lottie(
          width: widget.size,
          height: widget.size,
          animate: true,
          repeat: false,
        ),
        if (widget.title != null)
          Text(
            widget.title!,
            textAlign: TextAlign.center,
            style: TextStyles.h5.semiBold.copyWith(
              color: ColorName.neutralBlack,
            ),
          ),
        if (widget.message != null) ...[
          const SizedBox(height: 8),
          Text(
            widget.message!,
            textAlign: TextAlign.center,
            style: TextStyles.body.copyWith(color: ColorName.neutralGray),
          ),
        ],
      ],
    );
  }
}
