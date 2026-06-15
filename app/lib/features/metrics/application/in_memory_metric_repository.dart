import '../domain/metric_event.dart';
import '../domain/metric_repository.dart';

final class InMemoryMetricRepository implements MetricRepository {
  final List<MetricEvent> _events = [];

  @override
  Future<List<MetricEvent>> listForProject(String projectId) async {
    return _events.where((event) => event.projectId == projectId).toList();
  }

  @override
  Future<void> record(MetricEvent event) async {
    _events.add(event);
  }
}
