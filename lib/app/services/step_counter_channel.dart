import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../data/models/hourly_step_bucket.dart';
import '../data/models/step_snapshot.dart';

class StepCounterChannel {
  static const MethodChannel _method = MethodChannel(
    "com.example.project/step_counter",
  );

  static const EventChannel _event = EventChannel(
    "com.example.project/step_counter/events",
  );

  Stream<StepSnapshot>? _stream;

  Future<bool> isSensorAvailable() =>
      _invoke("isSensorAvailable", fallback: false);

  Future<bool> hasPermission() => _invoke("hasPermission", fallback: false);

  Future<bool> requestPermission() =>
      _invoke("requestPermission", fallback: false);

  Future<bool> startBackgroundTracking() =>
      _invoke("startBackgroundTracking", fallback: false);

  Future<bool> stopBackgroundTracking() =>
      _invoke("stopBackgroundTracking", fallback: false);

  Future<bool> isBackgroundTrackingEnabled() =>
      _invoke("isBackgroundTrackingEnabled", fallback: false);

  Future<bool> pauseTracking() => _invoke("pauseTracking", fallback: false);

  Future<bool> resumeTracking() => _invoke("resumeTracking", fallback: false);

  Future<bool> isPaused() => _invoke("isPaused", fallback: false);

  Future<int> getTodaySteps() => _invoke("getTodaySteps", fallback: 0);

  Future<int> getLifetimeSteps() => _invoke("getLifetimeSteps", fallback: 0);

  Future<List<HourlyStepBucket>> getHourlySteps() async {
    final raw = await _invoke<List<Object?>>(
      "getHourlySteps",
      fallback: const [],
    );
    return raw
        .whereType<Map<Object?, Object?>>()
        .map(HourlyStepBucket.fromMap)
        .toList();
  }

  Future<Map<DateTime, int>> getDailySteps() async {
    final raw = await _invoke<Map<Object?, Object?>>(
      "getDailySteps",
      fallback: const {},
    );

    final result = <DateTime, int>{};
    raw.forEach((key, value) {
      final millis = int.tryParse("$key");
      if (millis == null) {
        return;
      }

      final day = DateTime.fromMillisecondsSinceEpoch(millis);
      result[DateTime(day.year, day.month, day.day)] =
          (value as num?)?.toInt() ?? 0;
    });

    return result;
  }

  Future<bool> setHourSteps(DateTime hourStart, int steps) => _invoke(
    "setHourSteps",
    arguments: {
      "hourStartMs": hourStart.millisecondsSinceEpoch,
      "steps": steps,
    },
    fallback: false,
  );

  Future<bool> clearDay(DateTime day) => _invoke(
    "clearDay",
    arguments: {
      "dayStartMs": DateTime(
        day.year,
        day.month,
        day.day,
      ).millisecondsSinceEpoch,
    },
    fallback: false,
  );

  Future<bool> setConfig({
    int? goal,
    double? heightCm,
    double? weightKg,
    double? paceSpeedMps,
    double? paceMet,
  }) => _invoke(
    "setConfig",
    arguments: {
      if (goal != null) "goal": goal,
      if (heightCm != null) "heightCm": heightCm,
      if (weightKg != null) "weightKg": weightKg,
      if (paceSpeedMps != null) "paceSpeedMps": paceSpeedMps,
      if (paceMet != null) "paceMet": paceMet,
    },
    fallback: false,
  );

  Future<Map<String, num>> getConfig() async {
    final raw = await _invoke<Map<Object?, Object?>>(
      "getConfig",
      fallback: const {},
    );

    return {
      for (final entry in raw.entries)
        if (entry.value is num) "${entry.key}": entry.value as num,
    };
  }

  Future<Map<String, DateTime>> getMedals() async {
    final raw = await _invoke<Map<Object?, Object?>>(
      "getMedals",
      fallback: const {},
    );

    return {
      for (final entry in raw.entries)
        if (entry.value is num)
          "${entry.key}": DateTime.fromMillisecondsSinceEpoch(
            (entry.value as num).toInt(),
          ),
    };
  }

  Future<bool> unlockMedal(String name, DateTime at) => _invoke(
    "unlockMedal",
    arguments: {"name": name, "atMs": at.millisecondsSinceEpoch},
    fallback: false,
  );

  Stream<StepSnapshot> get stepStream => _stream ??= _event
      .receiveBroadcastStream()
      .where((event) => event is Map)
      .map((event) => StepSnapshot.fromMap(event as Map<Object?, Object?>))
      .asBroadcastStream();

  Future<T> _invoke<T>(
    String method, {
    Map<String, dynamic>? arguments,
    required T fallback,
  }) async {
    try {
      final result = await _method.invokeMethod<T>(method, arguments);
      return result ?? fallback;
    } on MissingPluginException {
      return fallback;
    } on PlatformException catch (e) {
      debugPrint("StepCounterChannel.$method lỗi: ${e.message}");
      return fallback;
    }
  }
}
