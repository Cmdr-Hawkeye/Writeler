import 'metric_event.dart';

abstract interface class MetricRepository {
  Future<void> record(MetricEvent event);

  Future<List<MetricEvent>> listForProject(String projectId);
}
