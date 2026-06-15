import '../../../core/domain/ids.dart';
import '../domain/metric_event.dart';
import '../domain/metric_repository.dart';

final class RecordMetric {
  const RecordMetric(this.repository);

  final MetricRepository repository;

  Future<MetricEvent> call({
    required String projectId,
    required String eventType,
    num? value,
    Map<String, Object?> metadata = const {},
  }) async {
    final event = MetricEvent(
      id: newLocalId('metric'),
      projectId: projectId,
      eventType: eventType,
      occurredAt: DateTime.now().toUtc(),
      value: value,
      metadata: metadata,
    );
    await repository.record(event);
    return event;
  }
}
