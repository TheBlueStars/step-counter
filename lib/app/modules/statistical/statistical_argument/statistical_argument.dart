import 'package:project/app/data/models/enums/activity_metrics.dart';
import 'package:project/app/data/models/enums/period_type.dart';

class StatisticalArgument {
  const StatisticalArgument({this.metric, this.period, this.date});

  final ActivityMetrics? metric;
  final PeriodType? period;
  final DateTime? date;
}

class StatisticalResult {
  const StatisticalResult();
}
