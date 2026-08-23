enum WalkingPace {
  slow(speedMps: 0.9, met: 2.8),
  average(speedMps: 1.34, met: 3.5),
  fast(speedMps: 1.79, met: 5.0);

  const WalkingPace({required this.speedMps, required this.met});

  final double speedMps;
  final double met;

  String get label => switch (this) {
    WalkingPace.slow => "Slow",
    WalkingPace.average => "Average",
    WalkingPace.fast => "Fast",
  };
}
