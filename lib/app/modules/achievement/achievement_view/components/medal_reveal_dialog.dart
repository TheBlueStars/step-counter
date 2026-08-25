import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:project/app/data/models/medal_record.dart';
import 'package:project/app/extensions/date_time_extension.dart';
import 'package:project/app/widgets/scale_tap_widget.dart';
import 'package:project/generated/colors.gen.dart';
import 'package:project/generated/text_styles.gen.dart';

class MedalRevealDialog extends StatefulWidget {
  final MedalRecord record;

  const MedalRevealDialog({super.key, required this.record});

  static Future<void> show(BuildContext context, MedalRecord record) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Medal reveal",
      barrierColor: Colors.black.withValues(alpha: .55),
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, _, _) => MedalRevealDialog(record: record),
      transitionBuilder: (context, animation, _, child) => FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  }

  @override
  State<MedalRevealDialog> createState() => _MedalRevealDialogState();
}

class _MedalRevealDialogState extends State<MedalRevealDialog>
    with SingleTickerProviderStateMixin {
  static const double _size = 180;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..forward();

  late final Animation<double> _flip = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0, 0.7, curve: Curves.easeOutBack),
  );

  late final Animation<double> _scale = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0, 0.6, curve: Curves.elasticOut),
  );

  late final Animation<double> _contentFade = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.5, 1, curve: Curves.easeOut),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final medal = widget.record.medal;
    final doneAt = widget.record.doneAt;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 32),
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          decoration: BoxDecoration(
            color: ColorName.neutralWhite,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: _size * 1.4,
                height: _size * 1.2,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    IgnorePointer(
                      child: Lottie.asset(
                        "assets/lottie/congrats.json",
                        repeat: false,
                        fit: BoxFit.cover,
                      ),
                    ),
                    AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        final angle = _flip.value * math.pi;
                        return Transform.scale(
                          scale: _scale.value,
                          child: Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()
                              ..setEntry(3, 2, 0.0015)
                              ..rotateY(angle),
                            child: angle > math.pi / 2
                                ? Transform(
                                    alignment: Alignment.center,
                                    transform: Matrix4.identity()
                                      ..rotateY(math.pi),
                                    child: medal.image.image(
                                      width: _size,
                                      height: _size,
                                    ),
                                  )
                                : medal.achievement.backplateImage.image(
                                    width: _size,
                                    height: _size,
                                  ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              FadeTransition(
                opacity: _contentFade,
                child: Column(
                  children: [
                    TnmText.h5(medal.title).semiBold.copyWith(
                      color: ColorName.neutralBlack,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 6),
                    if (doneAt != null)
                      TnmText.body(
                        "Badge earned on ${doneAt.yyyy_MM_dd}",
                      ).copyWith(
                        color: ColorName.neutralGray,
                        textAlign: TextAlign.center,
                      ),
                    SizedBox(height: 20),
                    ScaleTapWidget(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: ColorName.primary100,
                          borderRadius: BorderRadius.circular(32),
                        ),
                        alignment: Alignment.center,
                        child: TnmText.title(
                          "Nice!",
                        ).semiBold.copyWith(color: ColorName.neutralWhite),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
