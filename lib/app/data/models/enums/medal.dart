import 'package:project/generated/assets.gen.dart';

import 'achievement.dart';

enum MedalType {
  dailySteps1,
  dailySteps2,
  dailySteps3,
  dailySteps4,
  dailySteps5,
  dailySteps6,
  dailySteps7,
  dailySteps8,
  dailySteps9,
  dailySteps10,
  streak1,
  streak2,
  streak3,
  streak4,
  streak5,
  streak6,
  streak7,
  streak8,
  streak9,
  streak10,
  goalCompleted1,
  goalCompleted2,
  goalCompleted3,
  goalCompleted4,
  goalCompleted5,
  goalCompleted6,
  totalDistance1,
  totalDistance2,
  totalDistance3,
  totalDistance4,
  totalDistance5,
  totalDistance6,
  totalDistance7,
  totalDistance8,
  totalDistance9,
  totalDistance10,
  totalSteps1,
  totalSteps2,
  totalSteps3,
  totalSteps4,
  totalSteps5,
  totalSteps6,
  totalSteps7,
  totalSteps8;

  Achievement get achievement => switch (this) {
    MedalType.dailySteps1 ||
    MedalType.dailySteps2 ||
    MedalType.dailySteps3 ||
    MedalType.dailySteps4 ||
    MedalType.dailySteps5 ||
    MedalType.dailySteps6 ||
    MedalType.dailySteps7 ||
    MedalType.dailySteps8 ||
    MedalType.dailySteps9 ||
    MedalType.dailySteps10 => Achievement.dailySteps,
    MedalType.streak1 ||
    MedalType.streak2 ||
    MedalType.streak3 ||
    MedalType.streak4 ||
    MedalType.streak5 ||
    MedalType.streak6 ||
    MedalType.streak7 ||
    MedalType.streak8 ||
    MedalType.streak9 ||
    MedalType.streak10 => Achievement.streaks,
    MedalType.goalCompleted1 ||
    MedalType.goalCompleted2 ||
    MedalType.goalCompleted3 ||
    MedalType.goalCompleted4 ||
    MedalType.goalCompleted5 ||
    MedalType.goalCompleted6 => Achievement.goalCompleted,
    MedalType.totalDistance1 ||
    MedalType.totalDistance2 ||
    MedalType.totalDistance3 ||
    MedalType.totalDistance4 ||
    MedalType.totalDistance5 ||
    MedalType.totalDistance6 ||
    MedalType.totalDistance7 ||
    MedalType.totalDistance8 ||
    MedalType.totalDistance9 ||
    MedalType.totalDistance10 => Achievement.totalDistance,
    MedalType.totalSteps1 ||
    MedalType.totalSteps2 ||
    MedalType.totalSteps3 ||
    MedalType.totalSteps4 ||
    MedalType.totalSteps5 ||
    MedalType.totalSteps6 ||
    MedalType.totalSteps7 ||
    MedalType.totalSteps8 => Achievement.totalSteps,
  };

  int get goal => switch (this) {
    MedalType.dailySteps1 => 3000,
    MedalType.dailySteps2 => 7000,
    MedalType.dailySteps3 => 10000,
    MedalType.dailySteps4 => 14000,
    MedalType.dailySteps5 => 20000,
    MedalType.dailySteps6 => 30000,
    MedalType.dailySteps7 => 40000,
    MedalType.dailySteps8 => 50000,
    MedalType.dailySteps9 => 80000,
    MedalType.dailySteps10 => 100000,
    MedalType.streak1 => 3,
    MedalType.streak2 => 7,
    MedalType.streak3 => 14,
    MedalType.streak4 => 21,
    MedalType.streak5 => 30,
    MedalType.streak6 => 60,
    MedalType.streak7 => 90,
    MedalType.streak8 => 180,
    MedalType.streak9 => 365,
    MedalType.streak10 => 730,
    MedalType.goalCompleted1 => 1,
    MedalType.goalCompleted2 => 7,
    MedalType.goalCompleted3 => 30,
    MedalType.goalCompleted4 => 100,
    MedalType.goalCompleted5 => 365,
    MedalType.goalCompleted6 => 1000,
    MedalType.totalDistance1 => 5,
    MedalType.totalDistance2 => 9,
    MedalType.totalDistance3 => 20,
    MedalType.totalDistance4 => 42,
    MedalType.totalDistance5 => 100,
    MedalType.totalDistance6 => 220,
    MedalType.totalDistance7 => 450,
    MedalType.totalDistance8 => 800,
    MedalType.totalDistance9 => 1900,
    MedalType.totalDistance10 => 6350,
    MedalType.totalSteps1 => 10000,
    MedalType.totalSteps2 => 50000,
    MedalType.totalSteps3 => 100000,
    MedalType.totalSteps4 => 250000,
    MedalType.totalSteps5 => 500000,
    MedalType.totalSteps6 => 1000000,
    MedalType.totalSteps7 => 2000000,
    MedalType.totalSteps8 => 5000000,
  };

  String get title => switch (this) {
    MedalType.dailySteps1 => "Beginner Walker",
    MedalType.dailySteps2 => "Explorer",
    MedalType.dailySteps3 => "Endurance Walker",
    MedalType.dailySteps4 => "Steady Strider",
    MedalType.dailySteps5 => "Power Walker",
    MedalType.dailySteps6 => "Elite Walker",
    MedalType.dailySteps7 => "Peak Performer",
    MedalType.dailySteps8 => "Trail Blazer",
    MedalType.dailySteps9 => "Ultimate Strider",
    MedalType.dailySteps10 => "Step Titan",
    MedalType.streak1 => "Fresh Start",
    MedalType.streak2 => "Habit Builder",
    MedalType.streak3 => "Consistency Keeper",
    MedalType.streak4 => "Routine Master",
    MedalType.streak5 => "Monthly Champion",
    MedalType.streak6 => "Iron Will",
    MedalType.streak7 => "Dedicated Walker",
    MedalType.streak8 => "Half-Year Hero",
    MedalType.streak9 => "Year of Motion",
    MedalType.streak10 => "Walking Legend",
    MedalType.goalCompleted1 => "Goal Starter",
    MedalType.goalCompleted2 => "Goal Chaser",
    MedalType.goalCompleted3 => "Goal Achiever",
    MedalType.goalCompleted4 => "Goal Master",
    MedalType.goalCompleted5 => "Goal Legend",
    MedalType.goalCompleted6 => "Ultimate Goal Hunter",
    MedalType.totalDistance1 => "First Journey",
    MedalType.totalDistance2 => "Road Explorer",
    MedalType.totalDistance3 => "Trail Walker",
    MedalType.totalDistance4 => "Marathon Spirit",
    MedalType.totalDistance5 => "Path Finder",
    MedalType.totalDistance6 => "Journey Master",
    MedalType.totalDistance7 => "Road Warrior",
    MedalType.totalDistance8 => "Trail Legend",
    MedalType.totalDistance9 => "Globe Trekker",
    MedalType.totalDistance10 => "World Walker",
    MedalType.totalSteps1 => "First 10K",
    MedalType.totalSteps2 => "Rising Walker",
    MedalType.totalSteps3 => "Step Collector",
    MedalType.totalSteps4 => "Trail Maker",
    MedalType.totalSteps5 => "Step Champion",
    MedalType.totalSteps6 => "Million Steps",
    MedalType.totalSteps7 => "Marathon Soul",
    MedalType.totalSteps8 => "Walking Legend",
  };

  AssetGenImage get image => switch (this) {
    MedalType.dailySteps1 => Assets.images.achievements.dailySteps.dailySteps1,
    MedalType.dailySteps2 => Assets.images.achievements.dailySteps.dailySteps2,
    MedalType.dailySteps3 => Assets.images.achievements.dailySteps.dailySteps3,
    MedalType.dailySteps4 => Assets.images.achievements.dailySteps.dailySteps4,
    MedalType.dailySteps5 => Assets.images.achievements.dailySteps.dailySteps5,
    MedalType.dailySteps6 => Assets.images.achievements.dailySteps.dailySteps6,
    MedalType.dailySteps7 => Assets.images.achievements.dailySteps.dailySteps7,
    MedalType.dailySteps8 => Assets.images.achievements.dailySteps.dailySteps8,
    MedalType.dailySteps9 => Assets.images.achievements.dailySteps.dailySteps9,
    MedalType.dailySteps10 =>
      Assets.images.achievements.dailySteps.dailySteps10,
    MedalType.streak1 => Assets.images.achievements.streaks.streak1,
    MedalType.streak2 => Assets.images.achievements.streaks.streak2,
    MedalType.streak3 => Assets.images.achievements.streaks.streak3,
    MedalType.streak4 => Assets.images.achievements.streaks.streak4,
    MedalType.streak5 => Assets.images.achievements.streaks.streak5,
    MedalType.streak6 => Assets.images.achievements.streaks.streak6,
    MedalType.streak7 => Assets.images.achievements.streaks.streak7,
    MedalType.streak8 => Assets.images.achievements.streaks.streak8,
    MedalType.streak9 => Assets.images.achievements.streaks.streak9,
    MedalType.streak10 => Assets.images.achievements.streaks.streak10,
    MedalType.goalCompleted1 =>
      Assets.images.achievements.goalCompleted.goalCompleted1,
    MedalType.goalCompleted2 =>
      Assets.images.achievements.goalCompleted.goalCompleted2,
    MedalType.goalCompleted3 =>
      Assets.images.achievements.goalCompleted.goalCompleted3,
    MedalType.goalCompleted4 =>
      Assets.images.achievements.goalCompleted.goalCompleted4,
    MedalType.goalCompleted5 =>
      Assets.images.achievements.goalCompleted.goalCompleted5,
    MedalType.goalCompleted6 =>
      Assets.images.achievements.goalCompleted.goalCompleted6,
    MedalType.totalDistance1 =>
      Assets.images.achievements.totalDistances.totalDistance1,
    MedalType.totalDistance2 =>
      Assets.images.achievements.totalDistances.totalDistance2,
    MedalType.totalDistance3 =>
      Assets.images.achievements.totalDistances.totalDistance3,
    MedalType.totalDistance4 =>
      Assets.images.achievements.totalDistances.totalDistance4,
    MedalType.totalDistance5 =>
      Assets.images.achievements.totalDistances.totalDistance5,
    MedalType.totalDistance6 =>
      Assets.images.achievements.totalDistances.totalDistance6,
    MedalType.totalDistance7 =>
      Assets.images.achievements.totalDistances.totalDistance7,
    MedalType.totalDistance8 =>
      Assets.images.achievements.totalDistances.totalDistance8,
    MedalType.totalDistance9 =>
      Assets.images.achievements.totalDistances.totalDistance9,
    MedalType.totalDistance10 =>
      Assets.images.achievements.totalDistances.totalDistance10,
    MedalType.totalSteps1 => Assets.images.achievements.totalSteps.totalSteps1,
    MedalType.totalSteps2 => Assets.images.achievements.totalSteps.totalSteps2,
    MedalType.totalSteps3 => Assets.images.achievements.totalSteps.totalSteps3,
    MedalType.totalSteps4 => Assets.images.achievements.totalSteps.totalSteps4,
    MedalType.totalSteps5 => Assets.images.achievements.totalSteps.totalSteps5,
    MedalType.totalSteps6 => Assets.images.achievements.totalSteps.totalSteps6,
    MedalType.totalSteps7 => Assets.images.achievements.totalSteps.totalSteps7,
    MedalType.totalSteps8 => Assets.images.achievements.totalSteps.totalSteps8,
  };
}
