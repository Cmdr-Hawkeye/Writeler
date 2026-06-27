import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/domain/entity_ref.dart';
import '../../../core/domain/entity_type.dart';
import '../../../core/infrastructure/database/app_database.dart';
import '../domain/research_item.dart';
import '../domain/research_item_repository.dart';

final class DriftResearchItemRepository implements ResearchItemRepository {
  const DriftResearchItemRepository(this.database);

  final AppDatabase database;

  @override
  Future<void> save(ResearchItem item) async {
    await database
        .into(database.researchItems)
        .insertOnConflictUpdate(_toCompanion(item));
  }

  @override
  Future<void> delete(String id) async {
    await (database.delete(database.researchItems)
          ..where((table) => table.id.equals(id)))
        .go();
  }

  @override
  Future<List<ResearchItem>> listForProject(String projectId) async {
    final rows = await (database.select(database.researchItems)
          ..where((table) => table.projectId.equals(projectId))
          ..orderBy([(table) => OrderingTerm.desc(table.updatedAt)]))
        .get();
    return rows.map(_fromRow).toList();
  }

  ResearchItemsCompanion _toCompanion(ResearchItem item) {
    return ResearchItemsCompanion.insert(
      id: item.id,
      projectId: item.projectId,
      kind: item.kind.wireName,
      targetType: Value(item.target?.type.wireName),
      targetId: Value(item.target?.id),
      title: item.title,
      uri: Value(item.uri),
      body: Value(item.body),
      source: Value(item.source),
      tagsJson: Value(jsonEncode(item.tags)),
      metadataJson: Value(jsonEncode(item.metadata)),
      createdAt: item.createdAt,
      updatedAt: item.updatedAt,
    );
  }

  ResearchItem _fromRow(ResearchItemRow row) {
    final tags = jsonDecode(row.tagsJson);
    final metadata = jsonDecode(row.metadataJson);
    final targetType = row.targetType;
    final targetId = row.targetId;
    return ResearchItem(
      id: row.id,
      projectId: row.projectId,
      kind: ResearchItemKindWire.parse(row.kind),
      target: targetType == null || targetId == null
          ? null
          : EntityRef(type: EntityTypeWire.parse(targetType), id: targetId),
      title: row.title,
      uri: row.uri,
      body: row.body,
      source: row.source,
      tags: [
        for (final tag in tags is List ? tags : const []) tag.toString(),
      ],
      metadata:
          metadata is Map ? Map<String, Object?>.from(metadata) : const {},
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }
}
