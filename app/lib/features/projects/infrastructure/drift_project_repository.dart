import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/domain/draft_status.dart';
import '../../../core/domain/json_map.dart';
import '../../../core/infrastructure/database/app_database.dart';
import '../domain/project.dart';
import '../domain/project_repository.dart';

final class DriftProjectRepository implements ProjectRepository {
  const DriftProjectRepository(this.database);

  final AppDatabase database;

  @override
  Future<Project?> findById(String id) async {
    final row = await (database.select(database.projects)
          ..where((table) => table.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _fromRow(row);
  }

  @override
  Future<List<Project>> listActive() async {
    final rows = await (database.select(database.projects)
          ..where(
              (table) => table.status.isNotValue(DraftStatus.archived.wireName))
          ..orderBy([(table) => OrderingTerm.desc(table.updatedAt)]))
        .get();
    return rows.map(_fromRow).toList();
  }

  @override
  Future<void> save(Project project) async {
    await database
        .into(database.projects)
        .insertOnConflictUpdate(_toCompanion(project));
  }

  ProjectsCompanion _toCompanion(Project project) {
    return ProjectsCompanion.insert(
      id: project.id,
      title: project.title,
      description: Value(project.description),
      projectType: project.projectType,
      languageCode: project.languageCode,
      status: project.status.wireName,
      wordTarget: Value(project.wordTarget),
      aiEnabled: project.aiEnabled,
      cloudSyncEnabled: project.cloudSyncEnabled,
      noAiNoCloud: project.noAiNoCloud,
      metadataJson: Value(jsonEncode(project.metadata)),
      createdAt: project.createdAt,
      updatedAt: project.updatedAt,
    );
  }

  Project _fromRow(ProjectRow row) {
    return Project(
      id: row.id,
      title: row.title,
      description: row.description,
      projectType: row.projectType,
      languageCode: row.languageCode,
      status: DraftStatusWire.parse(row.status),
      wordTarget: row.wordTarget,
      aiEnabled: row.aiEnabled,
      cloudSyncEnabled: row.cloudSyncEnabled,
      noAiNoCloud: row.noAiNoCloud,
      metadata: _decodeJson(row.metadataJson),
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }
}

JsonMap _decodeJson(String value) {
  return Map<String, Object?>.from(jsonDecode(value) as Map);
}
