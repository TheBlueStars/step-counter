import 'package:get/get.dart';

import '../data/models/enums/achievement.dart';
import '../data/models/enums/medal.dart';
import '../data/models/medal_record.dart';
import 'step_counter_channel.dart';
import 'step_record_service.dart';

class AchievementService extends GetxService {
  AchievementService({StepCounterChannel? channel})
    : _channel = channel ?? StepCounterChannel();

  static AchievementService get to => Get.find<AchievementService>();

  final StepCounterChannel _channel;

  final RxMap<Achievement, int> progress = <Achievement, int>{}.obs;
  final RxMap<MedalType, DateTime> unlockedAt = <MedalType, DateTime>{}.obs;

  final RxList<MedalType> newlyUnlocked = <MedalType>[].obs;

  StepRecordService get _steps => StepRecordService.to;

  Future<AchievementService> init() async {
    await _loadUnlocked();
    await refresh();

    ever(_steps.dataVersion, (_) => refresh());
    return this;
  }

  Future<void> _loadUnlocked() async {
    final stored = await _channel.getMedals();
    unlockedAt.value = {
      for (final medal in MedalType.values)
        if (stored[medal.name] != null) medal: stored[medal.name]!,
    };
  }

  Future<void> refresh() async {
    progress.value = _currentProgress();
    await _unlockReachedMedals();
  }

  Map<Achievement, int> _currentProgress() {
    final totalSteps = _steps.lifetimeSteps.value;

    return {
      Achievement.dailySteps: _steps.bestDaySteps,
      Achievement.streaks: _steps.longestStreak(),
      Achievement.goalCompleted: _steps.goalCompletedDays,
      Achievement.totalDistance: _steps.distanceKmOf(totalSteps).floor(),
      Achievement.totalSteps: totalSteps,
    };
  }

  Future<void> _unlockReachedMedals() async {
    final unlocked = <MedalType>[];
    final now = DateTime.now();

    for (final medal in MedalType.values) {
      if (unlockedAt.containsKey(medal)) {
        continue;
      }

      if ((progress[medal.achievement] ?? 0) < medal.goal) {
        continue;
      }

      if (await _channel.unlockMedal(medal.name, now)) {
        unlockedAt[medal] = now;
        unlocked.add(medal);
      }
    }

    if (unlocked.isNotEmpty) {
      newlyUnlocked.addAll(unlocked);
    }
  }

  int progressOf(Achievement achievement) => progress[achievement] ?? 0;

  List<MedalRecord> medalsOf(Achievement achievement) => MedalType.values
      .where((medal) => medal.achievement == achievement)
      .map((medal) => MedalRecord(medal: medal, doneAt: unlockedAt[medal]))
      .toList();

  MedalRecord? currentMedal(Achievement achievement) {
    final medals = medalsOf(achievement);
    for (final record in medals) {
      if (!record.isDone) {
        return record;
      }
    }

    return medals.isEmpty ? null : medals.last;
  }

  int get doneCount => unlockedAt.length;

  int get totalCount => MedalType.values.length;

  void clearNewlyUnlocked() => newlyUnlocked.clear();
}
