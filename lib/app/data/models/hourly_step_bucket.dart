class HourlyStepBucket {
  final DateTime hourStart;
  final int steps;
  final int activeMinutes;

  const HourlyStepBucket({
    required this.hourStart,
    required this.steps,
    required this.activeMinutes,
  });

  factory HourlyStepBucket.fromMap(Map<Object?, Object?> map) =>
      HourlyStepBucket(
        hourStart: DateTime.fromMillisecondsSinceEpoch(
          (map["hourStartMs"] as num?)?.toInt() ?? 0,
        ),
        steps: (map["steps"] as num?)?.toInt() ?? 0,
        activeMinutes: (map["activeMinutes"] as num?)?.toInt() ?? 0,
      );
}
