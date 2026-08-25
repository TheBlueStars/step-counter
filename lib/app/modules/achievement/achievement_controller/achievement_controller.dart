import 'package:get/get.dart';
import 'package:project/app/data/models/enums/achievement.dart';
import 'package:project/app/data/models/enums/medal.dart';
import 'package:project/app/data/models/medal_record.dart';

typedef MedalGridData = ({Achievement achievement, List<MedalRecord> medals, int progress});

class AchievementController extends GetxController {
  /// Deterministic placeholder lifetime progress per achievement track
  /// (no backing data source yet).
  static const Map<Achievement, int> _mockProgress = {
    Achievement.dailySteps: 32000,
    Achievement.streaks: 45,
    Achievement.goalCompleted: 12,
    Achievement.totalDistance: 260,
    Achievement.totalSteps: 1250000,
  };

  final Rx<AchievementFilter> filter = Rx(AchievementFilter.all);

  Map<Achievement, List<MedalRecord>> get _allMedals {
    final Map<Achievement, List<MedalRecord>> result = {
      for (final achievement in Achievement.values) achievement: <MedalRecord>[],
    };

    for (final medal in MedalType.values) {
      final progress = _mockProgress[medal.achievement] ?? 0;
      final isDone = progress >= medal.goal;
      result[medal.achievement]!.add(
        MedalRecord(
          medal: medal,
          doneAt: isDone
              ? DateTime.now().subtract(Duration(days: (medal.goal % 30) + 1))
              : null,
        ),
      );
    }

    return result;
  }

  int get doneCount => _allMedals.values.fold(
    0,
    (sum, medals) => sum + medals.where((medal) => medal.isDone).length,
  );

  int get totalCount => MedalType.values.length;

  List<Achievement> get _visibleAchievements => Achievement.values
      .where((achievement) => medalsOf(achievement).isNotEmpty)
      .toList();

  List<MedalGridData> get medalGrids => _visibleAchievements
      .map(
        (achievement) => (
          achievement: achievement,
          medals: medalsOf(achievement),
          progress: progressOf(achievement),
        ),
      )
      .toList();

  List<MedalRecord> medalsOf(Achievement achievement) =>
      _filterMedals(_allMedals[achievement] ?? []);

  int progressOf(Achievement achievement) => _mockProgress[achievement] ?? 0;

  MedalRecord? currentMedal(Achievement achievement) {
    final medals = _allMedals[achievement] ?? [];
    for (final medal in medals) {
      if (!medal.isDone) {
        return medal;
      }
    }

    return medals.isEmpty ? null : medals.last;
  }

  List<MedalRecord> _filterMedals(List<MedalRecord> medals) => switch (filter.value) {
    AchievementFilter.all => medals,
    AchievementFilter.inProgress => medals.where((medal) => !medal.isDone).toList(),
    AchievementFilter.completed => medals.where((medal) => medal.isDone).toList(),
  };

  void onTapFilter(AchievementFilter item) => filter.value = item;
}
