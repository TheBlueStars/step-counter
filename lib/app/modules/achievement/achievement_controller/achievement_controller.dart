import 'package:get/get.dart';
import 'package:project/app/data/models/enums/achievement.dart';
import 'package:project/app/data/models/medal_record.dart';
import 'package:project/app/services/achievement_service.dart';

typedef MedalGridData = ({
  Achievement achievement,
  List<MedalRecord> medals,
  int progress,
});

class AchievementController extends GetxController {
  final AchievementService _service = AchievementService.to;

  final Rx<AchievementFilter> filter = Rx(AchievementFilter.all);

  @override
  void onReady() {
    super.onReady();
    _service.refresh();
  }

  int get doneCount => _service.doneCount;

  int get totalCount => _service.totalCount;

  List<MedalGridData> get medalGrids => Achievement.values
      .map(
        (achievement) => (
          achievement: achievement,
          medals: medalsOf(achievement),
          progress: _service.progressOf(achievement),
        ),
      )
      .where((data) => data.medals.isNotEmpty)
      .toList();

  List<MedalRecord> medalsOf(Achievement achievement) =>
      _filterMedals(_service.medalsOf(achievement));

  int progressOf(Achievement achievement) => _service.progressOf(achievement);

  MedalRecord? currentMedal(Achievement achievement) =>
      _service.currentMedal(achievement);

  List<MedalRecord> _filterMedals(List<MedalRecord> medals) =>
      switch (filter.value) {
        AchievementFilter.all => medals,
        AchievementFilter.inProgress =>
          medals.where((medal) => !medal.isDone).toList(),
        AchievementFilter.completed =>
          medals.where((medal) => medal.isDone).toList(),
      };

  void onTapFilter(AchievementFilter item) => filter.value = item;
}
