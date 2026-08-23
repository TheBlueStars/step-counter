extension NumberExtension on num {
  String get compact {
    if (this < 1000) {
      return toInt().toString();
    }
    final k = (this / 1000).toStringAsFixed(1).replaceAll('.', ',');
    return "${k}k";
  }

  String get trimDecimal {
    final text = toStringAsFixed(1);
    return text.endsWith(".0") ? text.substring(0, text.length - 2) : text;
  }

  String get hourRangeLabel =>
      "${toString().padLeft(2, '0')}:00 - "
      "${(this + 1).toString().padLeft(2, '0')}:00";
  }
