import '../../../core/domain/json_map.dart';

final class MetricEvent {
  const MetricEvent({
    required this.id,
    required this.projectId,
    required this.eventType,
    required this.occurredAt,
    this.value,
    this.metadata = const {},
  });

  final String id;
  final String projectId;
  final String eventType;
  final DateTime occurredAt;
  final num? value;
  final JsonMap metadata;

  JsonMap toJson() => {
        'id': id,
        'projectId': projectId,
        'eventType': eventType,
        'occurredAt': occurredAt.toIso8601String(),
        'value': value,
        'metadata': metadata,
      };

  factory MetricEvent.fromJson(JsonMap json) {
    return MetricEvent(
      id: json['id'] as String,
      projectId: json['projectId'] as String,
      eventType: json['eventType'] as String,
      occurredAt: DateTime.parse(json['occurredAt'] as String),
      value: json['value'] as num?,
      metadata: Map<String, Object?>.from(json['metadata'] as Map? ?? const {}),
    );
  }
}
