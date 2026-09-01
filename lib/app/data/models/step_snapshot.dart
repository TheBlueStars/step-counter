class StepSnapshot {
  final int todaySteps;
  final int hourSteps;
  final int activeMinutes;
  final DateTime time;

  const StepSnapshot({
    required this.todaySteps,
    required this.hourSteps,
    required this.activeMinutes,
    required this.time,
  });

  factory StepSnapshot.fromMap(Map<Object?, Object?> map) => StepSnapshot(
    todaySteps: (map["todaySteps"] as num?)?.toInt() ?? 0,
    hourSteps: (map["hourSteps"] as num?)?.toInt() ?? 0,
    activeMinutes: (map["activeMinutes"] as num?)?.toInt() ?? 0,
    time: DateTime.fromMillisecondsSinceEpoch(
      (map["timestampMs"] as num?)?.toInt() ??
          DateTime.now().millisecondsSinceEpoch,
    ),
  );

  DateTime get hourStart =>
      DateTime(time.year, time.month, time.day, time.hour);

  DateTime get dayStart => DateTime(time.year, time.month, time.day);
}
