import '../data/models/enums/walking_pace.dart';

/// stride   = height(m) x 0.414
/// distance = stride x steps
/// time     = distance / speed
/// calories = time(min) x MET x 3.5 x weight(kg) / 200
class StepMetricsUtils {
  static const double _strideFactor = 0.414;

  static double strideMeters(double heightCm) => heightCm / 100 * _strideFactor;

  static double distanceMeters(int steps, double heightCm) =>
      strideMeters(heightCm) * steps;

  static double distanceKm(int steps, double heightCm) =>
      distanceMeters(steps, heightCm) / 1000;

  static Duration walkingTime(
    int steps,
    double heightCm, {
    WalkingPace pace = WalkingPace.average,
  }) {
    if (pace.speedMps <= 0) {
      return Duration.zero;
    }

    final seconds = distanceMeters(steps, heightCm) / pace.speedMps;
    return Duration(seconds: seconds.round());
  }

  static double calories(
    int steps,
    double heightCm,
    double weightKg, {
    WalkingPace pace = WalkingPace.average,
  }) {
    final minutes = walkingTime(steps, heightCm, pace: pace).inSeconds / 60;
    return minutes * pace.met * 3.5 * weightKg / 200;
  }
}
