enum ProgressIndicatorType {
  linear,
  separated;

  bool get isLinear => this == ProgressIndicatorType.linear;
  bool get isSeparated => this == ProgressIndicatorType.separated;
}
