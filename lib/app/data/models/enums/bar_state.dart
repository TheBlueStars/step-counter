import 'dart:ui';

import '../../../../generated/colors.gen.dart';

enum BarState {
  peak,
  active,
  done,
  next;

  static BarState resolve({
    required bool hasData,
    required bool isPeak,
    required bool isDone,
    required bool isFuture,
  }) {
    if (isFuture || !hasData) {
      return BarState.next;
    }

    if (isPeak) {
      return BarState.peak;
    }

    if (isDone) {
      return BarState.done;
    }

    return BarState.active;
  }

  List<Color> get colors => switch (this) {
    BarState.peak => [ColorName.extra.extra4, ColorName.warningStatus],
    BarState.active => [ColorName.extra.extra3, ColorName.infoStatus],
    BarState.done => [ColorName.extra.extra5, ColorName.successStatus],
    BarState.next => [ColorName.neutralGray, ColorName.neutralGray],
  };

  Color get colorShadow => switch (this) {
    BarState.peak => ColorName.warningStatus,
    BarState.active => ColorName.infoStatus,
    BarState.done => ColorName.successStatus,
    BarState.next => ColorName.neutralGray,
  };

  String get label => switch (this) {
    BarState.peak => "Peak",
    BarState.active => "Active",
    BarState.done => "Done",
    BarState.next => "Next",
  };
}
