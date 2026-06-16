import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/domain/draft_status.dart';
import '../../../core/domain/json_map.dart';
import '../../../core/infrastructure/database/app_database.dart';
import '../domain/scene.dart';
import '../domain/scene_repository.dart';

final class DriftSceneRepository implements SceneRepository {
  const DriftSceneRepository(this.database);

  final AppDatabase database;

  @override
  Future<void> delete(String id) async {
    await (database.delete(database.scenes)
          ..where((table) => table.id.equals(id)))
        .go();
  }

  @override
  Future<Scene?> findById(String id) async {
    final row = await (database.select(database.scenes)
          ..where((table) => table.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _fromRow(row);
  }

  @override
  Future<List<Scene>> listByProject(String projectId) async {
    final rows = await (database.select(database.scenes)
          ..where((table) => table.projectId.equals(projectId))
          ..orderBy([(table) => OrderingTerm.asc(table.orderIndex)]))
        .get();
    return rows.map(_fromRow).toList();
  }

  @override
  Future<void> save(Scene scene) async {
    await database
        .into(database.scenes)
        .insertOnConflictUpdate(_toCompanion(scene));
  }

  ScenesCompanion _toCompanion(Scene scene) {
    return ScenesCompanion.insert(
      id: scene.id,
      projectId: scene.projectId,
      chapterId: Value(scene.chapterId),
      parentSceneId: Value(scene.parentSceneId),
      title: scene.title,
      summary: Value(scene.summary),
      manuscriptText: Value(scene.manuscriptText),
      authorIntent: Value(scene.authorIntent),
      povCharacterId: Value(scene.povCharacterId),
      sceneType: Value(scene.sceneType),
      status: scene.status.wireName,
      orderIndex: scene.orderIndex,
      storyDateStart: Value(scene.storyDateStart),
      storyDateEnd: Value(scene.storyDateEnd),
      estimatedWordTarget: Value(scene.estimatedWordTarget),
      actualWordCount: Value(scene.actualWordCount),
      tensionLevel: Value(scene.tensionLevel),
      emotionalTone: Value(scene.emotionalTone),
      goal: Value(scene.goal),
      conflict: Value(scene.conflict),
      outcome: Value(scene.outcome),
      aiAssistAllowed: scene.aiAssistAllowed,
      metadataJson: Value(jsonEncode(scene.metadata)),
      createdAt: scene.createdAt,
      updatedAt: scene.updatedAt,
    );
  }

  Scene _fromRow(SceneRow row) {
    return Scene(
      id: row.id,
      projectId: row.projectId,
      chapterId: row.chapterId,
      parentSceneId: row.parentSceneId,
      title: row.title,
      summary: row.summary,
      manuscriptText: row.manuscriptText,
      authorIntent: row.authorIntent,
      povCharacterId: row.povCharacterId,
      sceneType: row.sceneType,
      status: DraftStatusWire.parse(row.status),
      orderIndex: row.orderIndex,
      storyDateStart: row.storyDateStart,
      storyDateEnd: row.storyDateEnd,
      estimatedWordTarget: row.estimatedWordTarget,
      tensionLevel: row.tensionLevel,
      emotionalTone: row.emotionalTone,
      goal: row.goal,
      conflict: row.conflict,
      outcome: row.outcome,
      aiAssistAllowed: row.aiAssistAllowed,
      metadata: _decodeJson(row.metadataJson),
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }
}

JsonMap _decodeJson(String value) {
  return Map<String, Object?>.from(jsonDecode(value) as Map);
}
