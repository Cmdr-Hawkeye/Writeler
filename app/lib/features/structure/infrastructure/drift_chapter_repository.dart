import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/domain/draft_status.dart';
import '../../../core/domain/json_map.dart';
import '../../../core/infrastructure/database/app_database.dart';
import '../domain/chapter.dart';
import '../domain/chapter_repository.dart';

final class DriftChapterRepository implements ChapterRepository {
  const DriftChapterRepository(this.database);

  final AppDatabase database;

  @override
  Future<Chapter?> findById(String id) async {
    final row = await (database.select(database.chapters)
          ..where((table) => table.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _fromRow(row);
  }

  @override
  Future<List<Chapter>> listByProject(String projectId) async {
    final rows = await (database.select(database.chapters)
          ..where((table) => table.projectId.equals(projectId))
          ..orderBy([(table) => OrderingTerm.asc(table.orderIndex)]))
        .get();
    return rows.map(_fromRow).toList();
  }

  @override
  Future<void> save(Chapter chapter) async {
    await database
        .into(database.chapters)
        .insertOnConflictUpdate(_toCompanion(chapter));
  }

  ChaptersCompanion _toCompanion(Chapter chapter) {
    return ChaptersCompanion.insert(
      id: chapter.id,
      projectId: chapter.projectId,
      partId: Value(chapter.partId),
      title: chapter.title,
      summary: Value(chapter.summary),
      orderIndex: chapter.orderIndex,
      status: chapter.status.wireName,
      metadataJson: Value(jsonEncode(chapter.metadata)),
      createdAt: chapter.createdAt,
      updatedAt: chapter.updatedAt,
    );
  }

  Chapter _fromRow(ChapterRow row) {
    return Chapter(
      id: row.id,
      projectId: row.projectId,
      partId: row.partId,
      title: row.title,
      summary: row.summary,
      orderIndex: row.orderIndex,
      status: DraftStatusWire.parse(row.status),
      metadata: _decodeJson(row.metadataJson),
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  JsonMap _decodeJson(String value) {
    return Map<String, Object?>.from(jsonDecode(value) as Map);
  }
}
