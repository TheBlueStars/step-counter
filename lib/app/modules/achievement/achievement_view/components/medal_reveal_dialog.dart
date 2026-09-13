import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:project/app/data/models/medal_record.dart';
import 'package:project/app/extensions/date_time_extension.dart';
import 'package:project/app/widgets/coin_flip_widget.dart';
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
      transitionBuilder: (context, animation, _, child) =>
          FadeTransition(opacity: animation, child: child),
    );
  }

  @override
  State<MedalRevealDialog> createState() => _MedalRevealDialogState();
}

class _MedalRevealDialogState extends State<MedalRevealDialog> {
  static const double _frameWidth = 300;
  static const double _frameHeight = 200;

  bool _isFlipped = false;

  void _onFlipCompleted() {
    if (!mounted) {
      return;
    }

    setState(() => _isFlipped = true);
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
                width: _frameWidth,
                height: _frameHeight,
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
                    CoinFlipWidget(
                      medalTypes: [medal],
                      size: _frameWidth,
                      onCompleted: _onFlipCompleted,
                    ),
                  ],
                ),
              ),
              AnimatedOpacity(
                opacity: _isFlipped ? 1 : 0,
                duration: const Duration(milliseconds: 300),
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
