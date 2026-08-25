import 'enums/medal.dart';

class MedalRecord {
  final MedalType medal;
  final DateTime? doneAt;

  const MedalRecord({required this.medal, this.doneAt});

  bool get isDone => doneAt != null;

  int percentOf(int progress) {
    final targetGoal = medal.goal;
    if (targetGoal == 0) {
      return 0;
    }

    return (progress / targetGoal * 100).clamp(0, 100).toInt();
  }
}
