import 'dart:async';
import 'dart:math' as math;

import 'package:get/get.dart';

import '../data/models/enums/walking_pace.dart';
import '../data/models/step_snapshot.dart';
import '../extensions/date_time_extension.dart';
import '../utils/step_metrics_utils.dart';
import 'step_counter_channel.dart';

class StepRecordService extends GetxService {
  StepRecordService({StepCounterChannel? channel})
    : _channel = channel ?? StepCounterChannel();

  static StepRecordService get to => Get.find<StepRecordService>();

  static const int defaultStepGoal = 10000;

  final StepCounterChannel _channel;

  final RxBool hasSensor = true.obs;
  final RxBool isTracking = false.obs;
  final RxBool isPaused = false.obs;
  final RxInt stepGoal = defaultStepGoal.obs;
  final RxInt lifetimeSteps = 0.obs;
  final RxDouble heightCm = 170.0.obs;
  final RxDouble weightKg = 60.0.obs;
  final Rx<DateTime> selectedDate = DateTime.now().startOfDay.obs;

  final RxInt selectedSteps = 0.obs;

  final RxList<int> weekSteps = <int>[].obs;

  final RxInt streakDays = 0.obs;

  final RxInt longestStreakDays = 0.obs;

  final RxInt dataVersion = 0.obs;

  final Map<DateTime, int> _dayGoals = {};
  final Map<DateTime, int> _hourSteps = {};
  final Map<DateTime, int> _hourActiveMinutes = {};
  final Map<DateTime, int> _daySteps = {};

  int _defaultGoal = defaultStepGoal;

  StreamSubscription<StepSnapshot>? _subscription;
  Timer? _dayRolloverTimer;

  Future<StepRecordService> init() async {
    hasSensor.value = await _channel.isSensorAvailable();
    await _loadConfig();
    await reload();
    _scheduleDayRollover();
    ever(selectedDate, (_) => _refreshDerived());

    if (await _channel.hasPermission()) {
      await startTracking(askPermission: false);
    }

    return this;
  }

  @override
  void onClose() {
    _subscription?.cancel();
    _dayRolloverTimer?.cancel();
    super.onClose();
  }

  Future<bool> startTracking({bool askPermission = true}) async {
    if (!hasSensor.value) {
      return false;
    }

    if (!await _channel.hasPermission()) {
      if (!askPermission || !await _channel.requestPermission()) {
        return false;
      }
    }

    if (await _channel.isPaused()) {
      await _channel.resumeTracking();
    } else {
      await _channel.startBackgroundTracking();
    }

    _subscription ??= _channel.stepStream.listen(
      _onSnapshot,
      onError: (Object error) =>
          Get.log("Step stream error: $error", isError: true),
    );

    isPaused.value = false;
    isTracking.value = true;
    await reload();
    return true;
  }

  Future<bool> pauseTracking() async {
    if (!await _channel.pauseTracking()) {
      return false;
    }

    await _subscription?.cancel();
    _subscription = null;
    isPaused.value = true;
    isTracking.value = false;
    return true;
  }

  Future<bool> toggleTracking() =>
      isTracking.value ? pauseTracking() : startTracking();

  Future<void> reload() async {
    final buckets = await _channel.getHourlySteps();
    _hourSteps
      ..clear()
      ..addEntries(buckets.map((b) => MapEntry(b.hourStart, b.steps)));
    _hourActiveMinutes
      ..clear()
      ..addEntries(buckets.map((b) => MapEntry(b.hourStart, b.activeMinutes)));

    final days = await _channel.getDailySteps();
    _daySteps
      ..clear()
      ..addAll(days);

    final goals = await _channel.getDayGoals();
    _dayGoals
      ..clear()
      ..addAll(goals);

    lifetimeSteps.value = await _channel.getLifetimeSteps();
    isPaused.value = await _channel.isPaused();
    isTracking.value =
        !isPaused.value && await _channel.isBackgroundTrackingEnabled();
    _refreshDerived();
    dataVersion.value++;
  }

  void _refreshDerived() {
    final day = selectedDate.value;
    final weekStart = day.startOfWeek;

    selectedSteps.value = stepsOfDay(day);
    stepGoal.value = goalOfDay(day);
    streakDays.value = currentStreakUntil(day);
    longestStreakDays.value = longestStreak();
    weekSteps.value = dailyStepsInRange(
      weekStart,
      weekStart.add(const Duration(days: 6)),
    );
  }

  Future<void> _loadConfig() async {
    final config = await _channel.getConfig();
    final goal = config["goal"]?.toInt() ?? 0;
    _defaultGoal = goal > 0 ? goal : defaultStepGoal;
    heightCm.value = config["heightCm"]?.toDouble() ?? heightCm.value;
    weightKg.value = config["weightKg"]?.toDouble() ?? weightKg.value;
  }

  void _onSnapshot(StepSnapshot snapshot) {
    _hourSteps[snapshot.hourStart] = snapshot.hourSteps;
    _hourActiveMinutes[snapshot.hourStart] = snapshot.activeMinutes;
    _daySteps[snapshot.dayStart] = snapshot.todaySteps;
    _refreshDerived();
    dataVersion.value++;
  }

  void _scheduleDayRollover() {
    _dayRolloverTimer?.cancel();
    final now = DateTime.now();
    final nextDay = now.startOfDay.add(const Duration(days: 1));
    _dayRolloverTimer = Timer(
      nextDay.difference(now) + const Duration(seconds: 1),
      () async {
        selectedDate.value = DateTime.now().startOfDay;
        await reload();
        _scheduleDayRollover();
      },
    );
  }

  int get todaySteps => stepsOfDay(DateTime.now());

  int get selectedDaySteps => stepsOfDay(selectedDate.value);

  int stepsOfDay(DateTime day) => _daySteps[day.startOfDay] ?? 0;

  /// Mục tiêu của một ngày cụ thể; ngày chưa đặt riêng thì dùng mục tiêu mặc định.
  int goalOfDay(DateTime day) => _dayGoals[day.startOfDay] ?? _defaultGoal;

  double progressOfDay(DateTime day) {
    final goal = goalOfDay(day);
    if (goal <= 0) {
      return 0;
    }

    return (stepsOfDay(day) / goal).clamp(0.0, 1.0);
  }

  List<int> hourlyStepsForDay(DateTime day) {
    final start = day.startOfDay;
    return List.generate(
      24,
      (hour) => _hourSteps[start.add(Duration(hours: hour))] ?? 0,
    );
  }

  List<int> hourlyActiveMinutesForDay(DateTime day) {
    final start = day.startOfDay;
    return List.generate(
      24,
      (hour) => _hourActiveMinutes[start.add(Duration(hours: hour))] ?? 0,
    );
  }

  List<int> dailyStepsInRange(DateTime from, DateTime to) {
    final start = from.startOfDay;
    final days = to.startOfDay.difference(start).inDays;
    return List.generate(
      days + 1,
      (i) => stepsOfDay(start.add(Duration(days: i))),
    );
  }

  List<int> monthlyStepsForYear(int year) {
    final steps = List.filled(12, 0);
    for (final entry in _daySteps.entries) {
      if (entry.key.year != year) {
        continue;
      }

      steps[entry.key.month - 1] += entry.value;
    }

    return steps;
  }

  bool isStreakDay(DateTime day) {
    final goal = goalOfDay(day);
    return goal > 0 && stepsOfDay(day) >= goal;
  }

  int currentStreakUntil([DateTime? day]) {
    var cursor = (day ?? DateTime.now()).startOfDay;
    if (!isStreakDay(cursor)) {
      return 0;
    }

    var count = 0;
    while (isStreakDay(cursor)) {
      count++;
      cursor = cursor.subtract(const Duration(days: 1));
    }

    return count;
  }

  int longestStreak({DateTime? from, DateTime? to}) {
    final days = _streakDays(from: from, to: to);
    if (days.isEmpty) {
      return 0;
    }

    var best = 0;
    for (final day in days) {
      if (days.contains(day.subtract(const Duration(days: 1)))) {
        continue;
      }

      var length = 0;
      var cursor = day;
      while (days.contains(cursor)) {
        length++;
        cursor = cursor.add(const Duration(days: 1));
      }

      best = math.max(best, length);
    }

    return best;
  }

  Set<DateTime> _streakDays({DateTime? from, DateTime? to}) {
    final start = from?.startOfDay;
    final end = to?.startOfDay;

    return {
      for (final entry in _daySteps.entries)
        if (isStreakDay(entry.key))
          if ((start == null || !entry.key.isBefore(start)) &&
              (end == null || !entry.key.isAfter(end)))
            entry.key,
    };
  }

  int get bestDaySteps =>
      _daySteps.values.fold<int>(0, (best, steps) => math.max(best, steps));

  int get goalCompletedDays => _streakDays().length;

  double caloriesOf(int steps) =>
      StepMetricsUtils.calories(steps, heightCm.value, weightKg.value);

  double distanceKmOf(int steps) =>
      StepMetricsUtils.distanceKm(steps, heightCm.value);

  Duration activeTimeOf(int steps) =>
      StepMetricsUtils.walkingTime(steps, heightCm.value);

  WalkingPace get pace => WalkingPace.average;

  Future<void> updateGoalForDay(DateTime day, int goal) async {
    if (goal <= 0) {
      return;
    }

    await _channel.setDayGoal(day, goal);
    _dayGoals[day.startOfDay] = goal;
    _refreshDerived();
    dataVersion.value++;
  }

  Future<void> updateGoal(int goal) =>
      updateGoalForDay(selectedDate.value, goal);

  Future<void> updateProfile({double? height, double? weight}) async {
    await _channel.setConfig(
      heightCm: height,
      weightKg: weight,
      paceSpeedMps: pace.speedMps,
      paceMet: pace.met,
    );

    if (height != null) {
      heightCm.value = height;
    }

    if (weight != null) {
      weightKg.value = weight;
    }

    dataVersion.value++;
  }

  Future<void> setHourSteps(DateTime hourStart, int steps) async {
    await _channel.setHourSteps(hourStart, steps);
    await reload();
  }

  Future<void> clearDay(DateTime day) async {
    await _channel.clearDay(day);
    await reload();
  }

  void selectDay(DateTime day) => selectedDate.value = day.startOfDay;
}
