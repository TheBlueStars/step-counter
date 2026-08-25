import 'package:project/generated/assets.gen.dart';

enum AchievementFilter {
  all,
  inProgress,
  completed;

  String get displayName => switch (this) {
    AchievementFilter.all => "All",
    AchievementFilter.inProgress => "In progress",
    AchievementFilter.completed => "Completed",
  };
}

enum Achievement {
  dailySteps,
  streaks,
  goalCompleted,
  totalDistance,
  totalSteps;

  String get displayName => switch (this) {
    Achievement.dailySteps => "Daily steps",
    Achievement.streaks => "Streaks",
    Achievement.goalCompleted => "Goal completed",
    Achievement.totalDistance => "Total distance",
    Achievement.totalSteps => "Total steps",
  };

  AssetGenImage get backplateImage => switch (this) {
    Achievement.dailySteps =>
      Assets.images.achievements.dailySteps.dailyStepsBackplate,
    Achievement.streaks => Assets.images.achievements.streaks.streakBackplate,
    Achievement.goalCompleted =>
      Assets.images.achievements.goalCompleted.goalCompletedBackplate,
    Achievement.totalDistance =>
      Assets.images.achievements.totalDistances.totalDistanceBackplate,
    Achievement.totalSteps =>
      Assets.images.achievements.totalSteps.totalStepsBackplate,
  };
}
