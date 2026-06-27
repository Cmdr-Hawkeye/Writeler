import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/infrastructure/database/app_database.dart';
import '../domain/scene.dart';
import '../domain/scene_snapshot.dart';
import '../domain/scene_snapshot_repository.dart';

final class DriftSceneSnapshotRepository implements SceneSnapshotRepository {
  const DriftSceneSnapshotRepository(this.database);

  final AppDatabase database;

  @override
  Future<void> delete(String id) async {
    await (database.delete(database.sceneSnapshots)
          ..where((table) => table.id.equals(id)))
        .go();
  }

  @override
  Future<SceneSnapshot?> latestForScene(String sceneId) async {
    final row = await (database.select(database.sceneSnapshots)
          ..where((table) => table.sceneId.equals(sceneId))
          ..orderBy([(table) => OrderingTerm.desc(table.createdAt)])
          ..limit(1))
        .getSingleOrNull();
    return row == null ? null : _fromRow(row);
  }

  @override
  Future<List<SceneSnapshot>> listByProject(String projectId) async {
    final rows = await (database.select(database.sceneSnapshots)
          ..where((table) => table.projectId.equals(projectId))
          ..orderBy([(table) => OrderingTerm.desc(table.createdAt)]))
        .get();
    return rows.map(_fromRow).toList();
  }

  @override
  Future<List<SceneSnapshot>> listForScene(String sceneId) async {
    final rows = await (database.select(database.sceneSnapshots)
          ..where((table) => table.sceneId.equals(sceneId))
          ..orderBy([(table) => OrderingTerm.desc(table.createdAt)]))
        .get();
    return rows.map(_fromRow).toList();
  }

  @override
  Future<void> save(SceneSnapshot snapshot) async {
    await database
        .into(database.sceneSnapshots)
        .insertOnConflictUpdate(_toCompanion(snapshot));
  }

  SceneSnapshotsCompanion _toCompanion(SceneSnapshot snapshot) {
    return SceneSnapshotsCompanion.insert(
      id: snapshot.id,
      projectId: snapshot.projectId,
      sceneId: snapshot.sceneId,
      sceneTitle: snapshot.sceneTitle,
      label: Value(snapshot.label),
      reason: snapshot.reason.wireName,
      sceneJson: jsonEncode(snapshot.scene.toJson()),
      createdAt: snapshot.createdAt,
    );
  }

  SceneSnapshot _fromRow(SceneSnapshotRow row) {
    final sceneJson = jsonDecode(row.sceneJson) as Map;
    return SceneSnapshot(
      id: row.id,
      projectId: row.projectId,
      sceneId: row.sceneId,
      sceneTitle: row.sceneTitle,
      label: row.label,
      reason: SceneSnapshotReasonWire.parse(row.reason),
      scene: Scene.fromJson(Map<String, Object?>.from(sceneJson)),
      createdAt: row.createdAt,
    );
  }
}
