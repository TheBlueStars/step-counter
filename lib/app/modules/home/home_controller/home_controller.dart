import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/app/extensions/date_time_extension.dart';
import 'package:project/app/routes/app_pages.dart';
import 'package:project/app/services/step_record_service.dart';

class HomeController extends GetxController {
  final StepRecordService _service = StepRecordService.to;

  final ValueNotifier<DateTime?> progressChangedDay = ValueNotifier(null);
  final ValueNotifier<DateTime?> selectDayRequest = ValueNotifier(null);

  Worker? _stepWorker;

  @override
  void onInit() {
    super.onInit();
    _stepWorker = debounce(
      _service.selectedSteps,
      (_) => progressChangedDay.value = _service.selectedDate.value,
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
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text("Reset"),
        content: Text("Clear ${selectedDate.yyyy_MM_dd}?"),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text("Huỷ"),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text("Xoá"),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    await _service.clearDay(selectedDate);
    progressChangedDay.value = selectedDate;
  }

  Future<void> onTapEditGoal() async {
    final goal = await _askNumber(
      title: "Mục tiêu mỗi ngày",
      initialValue: stepGoal,
      suffix: "bước",
    );

    if (goal == null) {
      return;
    }

    await _service.updateGoal(goal);
    progressChangedDay.value = selectedDate;
  }

  Future<void> onTapEditStep() async {
    final now = DateTime.now();
    final hourStart = DateTime(now.year, now.month, now.day, now.hour);
    final steps = await _askNumber(
      title: "Số bước giờ hiện tại (${now.hour}:00)",
      initialValue: _service.hourlyStepsForDay(now)[now.hour],
      suffix: "bước",
    );

    if (steps == null) {
      return;
    }

    await _service.setHourSteps(hourStart, steps);
    progressChangedDay.value = selectedDate;
  }

  void goToStatistical() => Get.toNamed(Routes.STATISTICAL);

  Future<int?> _askNumber({
    required String title,
    required int initialValue,
    required String suffix,
  }) {
    final textController = TextEditingController(text: initialValue.toString());

    return Get.dialog<int>(
      AlertDialog(
        title: Text(title),
        content: TextField(
          controller: textController,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(suffixText: suffix),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Huỷ")),
          TextButton(
            onPressed: () {
              final value = int.tryParse(textController.text.trim());
              Get.back(result: value != null && value >= 0 ? value : null);
            },
            child: const Text("Lưu"),
          ),
        ],
      ),
    );
  }

  void _showMessage(String message) => Get.snackbar(
    "Đếm bước chân",
    message,
    snackPosition: SnackPosition.BOTTOM,
  );
}
