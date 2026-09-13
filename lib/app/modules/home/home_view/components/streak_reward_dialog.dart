import 'package:flutter/material.dart';
import 'package:project/app/services/step_record_service.dart';
import 'package:project/app/widgets/scale_tap_widget.dart';
import 'package:project/generated/assets.gen.dart';
import 'package:project/generated/colors.gen.dart';
import 'package:project/generated/text_styles.gen.dart';

/// Hộp thoại giải thích cách chuỗi streak hoạt động, bật khi người dùng bấm
/// vào chip streak trên thanh tiêu đề. Popup chúc mừng khi vừa đạt streak nằm
/// ở [RewardOverlay], không dùng hộp thoại này.
class StreakInfoDialog extends StatelessWidget {
  const StreakInfoDialog({super.key});

  static const double _artSize = 160;

  static Future<void> show(BuildContext context) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Streak",
      barrierColor: Colors.black.withValues(alpha: .55),
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, _, _) => const StreakInfoDialog(),
      transitionBuilder: (context, animation, _, child) => FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween<double>(begin: .92, end: 1).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
          ),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 32),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: ColorName.neutralWhite,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Assets.images.imgStreak.image(
                width: _artSize,
                height: _artSize,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 12),
              TnmText.h5("How Streak Works").semiBold.copyWith(
                color: ColorName.neutralBlack,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              TnmText.body(
                "Complete ${StepRecordService.streakStepThreshold} or more "
                "steps every day to extend your streak. "
                "Missing a day will reset it.",
              ).copyWith(
                color: ColorName.neutralGray,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ScaleTapWidget(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: ColorName.primary100,
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: TnmText.title("Got it").semiBold.copyWith(
                    color: ColorName.neutralWhite,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
