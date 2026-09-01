import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/app/data/models/chart_bar.dart';
import 'package:project/app/data/models/enums/activity_metrics.dart';
import 'package:project/app/data/models/enums/period_type.dart';
import 'package:project/app/extensions/chart_bar_extension.dart';
import 'package:project/app/extensions/date_time_extension.dart';
import 'package:project/app/modules/home/home_view/components/edit_step_sheet_body.dart';
import 'package:project/app/routes/app_pages.dart';
import 'package:project/app/services/step_record_service.dart';
import 'package:project/app/widgets/default/bottom_sheet_default.dart';

class HomeController extends GetxController {
  static const int _daysPerWeek = 7;
  static const int _lastHourOfDay = 23;

  final StepRecordService _service = StepRecordService.to;

  final ValueNotifier<DateTime?> progressChangedDay = ValueNotifier(null);
  final ValueNotifier<DateTime?> selectDayRequest = ValueNotifier(null);

  Worker? _stepWorker;

  @override
  void onInit() {
    super.onInit();

    _stepWorker = debounce(
      _service.selectedSteps,
      (_) => _notifyDayProgress(_service.selectedDate.value),
      time: const Duration(seconds: 1),
    );
  }

  @override
  void onReady() {
    super.onReady();
    if (!_service.isTracking.value && !_service.isPaused.value) {
      _service.startTracking();
    }
  }

  @override
  void onClose() {
    _stepWorker?.dispose();
    progressChangedDay.dispose();
    selectDayRequest.dispose();
    super.onClose();
  }

  int get steps => _service.selectedSteps.value;

  int get stepGoal => _service.stepGoal.value;

  int get streakDays => _service.streakDays.value;

  bool get isTracking => _service.isTracking.value;

  double get calories => _service.caloriesOf(steps);

  double get distanceKm => _service.distanceKmOf(steps);

  Duration get activeTime => _service.activeTimeOf(steps);

  DateTime get selectedDate => _service.selectedDate.value;

  Future<double?> progressOf(DateTime day) async => _service.progressOfDay(day);

  void onDaySelected(DateTime day) => _service.selectDay(day);

  /// ValueNotifier chỉ báo khi giá trị đổi, mà hai DateTime cùng ngày lại bằng
  /// nhau, nên phải gán null trước để lịch chắc chắn nạp lại tiến độ ngày đó.
  void _notifyDayProgress(DateTime day) {
    progressChangedDay.value = null;
    progressChangedDay.value = day.startOfDay;
  }

  List<ChartBar> get weekBars {
    final start = selectedDate.startOfWeek;
    final today = DateTime.now().startOfDay;
    final values = _service.weekSteps;

    return List.generate(values.length, (i) {
      final day = start.add(Duration(days: i));
      final steps = values[i];
      final goal = _service.goalOfDay(day);

      return ChartBar(
        value: steps.toDouble(),
        label: day.EEE,
        tooltip: day.MMM_EEEdd,
        isCurrent: day == today,
        isDone: goal > 0 && steps >= goal,
        isFuture: day.isAfter(today),
      );
    });
  }

  int get weekTotalSteps =>
      _service.weekSteps.fold<int>(0, (sum, steps) => sum + steps);

  int get weekChartMax {
    final start = selectedDate.startOfWeek;
    final weekGoal = List.generate(
      _daysPerWeek,
      (i) => _service.goalOfDay(start.add(Duration(days: i))),
    ).fold<int>(0, (maxGoal, dayGoal) => dayGoal > maxGoal ? dayGoal : maxGoal);

    final peak = weekBars.peak;
    final max = peak > weekGoal ? peak : weekGoal.toDouble();
    return max <= 0 ? 1 : max.ceil();
  }

  double get weekAverage => weekBars.averageFor(PeriodType.week, selectedDate);

  String get weekRangeLabel => selectedDate.weekLabel;

  String get weekTotalLabel =>
      "${ActivityMetrics.steps.format(weekTotalSteps.toDouble())} steps";

  Future<void> onTapPlay() async {
    if (!_service.hasSensor.value) {
      _showMessage("Device dont have sensor");
      return;
    }

    final started = await _service.toggleTracking();
    if (!started && !_service.isTracking.value && !_service.isPaused.value) {
      _showMessage("Please allow permission activities");
    }
  }

  Future<void> onTapReset() async {
    final confirmed = await BottomSheetDefault.showConfirm(
      title: "Reset steps",
      message: "Clear all steps of ${selectedDate.yyyy_MM_dd}?",
      primaryText: "Clear",
      secondaryText: "Cancel",
    );

    if (confirmed != true) {
      return;
    }

    await _service.clearDay(selectedDate);
    _notifyDayProgress(selectedDate);
  }

  Future<void> onTapEditGoal() async {
    final goal = await BottomSheetDefault.showNumberInput(
      title: "Edit goal",
      fieldTitle: "Daily goal",
      initialValue: stepGoal,
      suffixText: "steps",
      minValue: 1,
    );

    if (goal == null) {
      return;
    }

    await _service.updateGoal(goal);
    _notifyDayProgress(selectedDate);
  }

  Future<void> onTapEditStep() async {
    final now = DateTime.now();
    final draft = EditStepDraft(
      day: selectedDate,
      hour: selectedDate.isToday ? now.hour : _lastHourOfDay,
    );

    final input = TextEditingController(text: _stepsOfDraft(draft));
    final canSave = ValueNotifier<bool>(true);
    void onChanged() => canSave.value = int.tryParse(input.text.trim()) != null;
    input.addListener(onChanged);

    EditStepAction? action;
    while (true) {
      onChanged();
      action = await BottomSheetDefault.show<EditStepAction>(
        title: "Edit Steps",
        body: EditStepSheetBody(draft: draft, controller: input),
        primaryText: "Save",
        primaryEnabled: canSave,
        onPrimary: () => Get.back(result: EditStepAction.save),
      );

      if (action == EditStepAction.pickDate) {
        await draft.pickDate();
        input.text = _stepsOfDraft(draft);
        continue;
      }

      if (action == EditStepAction.pickTime) {
        await draft.pickTime();
        input.text = _stepsOfDraft(draft);
        continue;
      }

      break;
    }

    input.removeListener(onChanged);
    final steps = int.tryParse(input.text.trim());
    BottomSheetDefault.disposeLater(() {
      input.dispose();
      canSave.dispose();
    });

    if (action != EditStepAction.save || steps == null) {
      return;
    }

    await _service.setHourSteps(draft.hourStart, steps);
    _service.selectDay(draft.day);
    _notifyDayProgress(draft.day);
  }

  String _stepsOfDraft(EditStepDraft draft) =>
      _service.hourlyStepsForDay(draft.day)[draft.hour].toString();

  void goToStatistical() => Get.toNamed(Routes.STATISTICAL);

  void _showMessage(String message) => Get.snackbar(
    "Step counter",
    message,
    snackPosition: SnackPosition.BOTTOM,
  );
}
