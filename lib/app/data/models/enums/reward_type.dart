import 'package:project/generated/assets.gen.dart';

/// Loại phần thưởng hiển thị trên [RewardOverlay]. Nội dung mặc định của tiêu
/// đề, mô tả và lottie đi kèm được gom vào đây giống cách a64 tổ chức.
enum RewardType {
  streak,
  achievement;

  bool get isAchievement => this == RewardType.achievement;

  String get title => switch (this) {
    RewardType.streak => "1-Day Streak! 🔥",
    RewardType.achievement => "Badge Unlocked! 🏅",
  };

  String get description => switch (this) {
    RewardType.streak => "Keep moving daily to grow your streak.",
    RewardType.achievement =>
      "Keep moving every day to unlock more amazing achievements.",
  };

  /// Lottie hiển thị ở giữa vòng sáng. Riêng achievement trả về null vì phần
  /// giữa được thay bằng hiệu ứng lật huy hiệu (CoinFlipWidget).
  LottieGenImage? get lottie => switch (this) {
    RewardType.streak => Assets.lottie.streak,
    RewardType.achievement => null,
  };
}
