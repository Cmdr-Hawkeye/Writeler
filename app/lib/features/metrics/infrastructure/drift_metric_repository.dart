import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/domain/json_map.dart';
import '../../../core/infrastructure/database/app_database.dart';
import '../domain/metric_event.dart';
import '../domain/metric_repository.dart';

final class DriftMetricRepository implements MetricRepository {
  const DriftMetricRepository(this.database);

  final AppDatabase database;

  @override
  Future<List<MetricEvent>> listForProject(String projectId) async {
    final rows = await (database.select(database.metricEvents)
          ..where((table) => table.projectId.equals(projectId))
          ..orderBy([(table) => OrderingTerm.desc(table.occurredAt)]))
        .get();
    return rows.map(_fromRow).toList();
  }

  @override
  Future<void> record(MetricEvent event) async {
    await database.into(database.metricEvents).insertOnConflictUpdate(_toCompanion(event));
  }

  MetricEventsCompanion _toCompanion(MetricEvent event) {
    return MetricEventsCompanion.insert(
      id: event.id,
      projectId: event.projectId,
      eventType: event.eventType,
      value: Value(event.value?.toDouble()),
      metadataJson: Value(jsonEncode(event.metadata)),
      occurredAt: event.occurredAt,
    );
  }

  MetricEvent _fromRow(MetricEventRow row) {
    return MetricEvent(
      id: row.id,
      projectId: row.projectId,
      eventType: row.eventType,
      value: row.value,
      metadata: _decodeJson(row.metadataJson),
      occurredAt: row.occurredAt,
    );
  }

  JsonMap _decodeJson(String value) {
    return Map<String, Object?>.from(jsonDecode(value) as Map);
  }
}
