import '../domain/metric_event.dart';
import '../domain/metric_repository.dart';

final class LazyMetricRepository implements MetricRepository {
  LazyMetricRepository(this._create);

  final MetricRepository Function() _create;
  MetricRepository? _inner;

  MetricRepository get _repository => _inner ??= _create();

  @override
  Future<List<MetricEvent>> listForProject(String projectId) =>
      _repository.listForProject(projectId);

  @override
  Future<void> record(MetricEvent event) => _repository.record(event);
}
