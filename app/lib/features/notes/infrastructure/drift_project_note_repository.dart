import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/domain/entity_ref.dart';
import '../../../core/domain/entity_type.dart';
import '../../../core/infrastructure/database/app_database.dart';
import '../domain/project_note.dart';
import '../domain/project_note_repository.dart';

final class DriftProjectNoteRepository implements ProjectNoteRepository {
  const DriftProjectNoteRepository(this.database);

  final AppDatabase database;

  @override
  Future<void> save(ProjectNote note) async {
    await database
        .into(database.projectNotes)
        .insertOnConflictUpdate(_toCompanion(note));
  }

  @override
  Future<void> delete(String id) async {
    await (database.delete(database.projectNotes)
          ..where((table) => table.id.equals(id)))
        .go();
  }

  @override
  Future<List<ProjectNote>> listForProject(String projectId) async {
    final rows = await (database.select(database.projectNotes)
          ..where((table) => table.projectId.equals(projectId))
          ..orderBy([(table) => OrderingTerm.desc(table.updatedAt)]))
        .get();
    return rows.map(_fromRow).toList();
  }

  ProjectNotesCompanion _toCompanion(ProjectNote note) {
    return ProjectNotesCompanion.insert(
      id: note.id,
      projectId: note.projectId,
      targetType: Value(note.target?.type.wireName),
      targetId: Value(note.target?.id),
      title: note.title,
      body: note.body,
      source: Value(note.source),
      sourceSuggestionId: Value(note.sourceSuggestionId),
      metadataJson: Value(jsonEncode(note.metadata)),
      createdAt: note.createdAt,
      updatedAt: note.updatedAt,
    );
  }

  ProjectNote _fromRow(ProjectNoteRow row) {
    final targetType = row.targetType;
    final targetId = row.targetId;
    final metadata = jsonDecode(row.metadataJson);
    return ProjectNote(
      id: row.id,
      projectId: row.projectId,
      target: targetType == null || targetId == null
          ? null
          : EntityRef(type: EntityTypeWire.parse(targetType), id: targetId),
      title: row.title,
      body: row.body,
      source: row.source,
      sourceSuggestionId: row.sourceSuggestionId,
      metadata:
          metadata is Map ? Map<String, Object?>.from(metadata) : const {},
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }
}
