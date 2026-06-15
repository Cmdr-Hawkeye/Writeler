import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/domain/draft_status.dart';
import '../../../core/domain/entity_type.dart';
import '../../../core/domain/json_map.dart';
import '../../../core/infrastructure/database/app_database.dart';
import '../domain/catalog_item.dart';
import '../domain/catalog_item_repository.dart';

final class DriftCatalogItemRepository implements CatalogItemRepository {
  const DriftCatalogItemRepository(this.database);

  final AppDatabase database;

  @override
  Future<CatalogItem?> findById(String id) async {
    final row = await (database.select(database.catalogItems)
          ..where((table) => table.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _fromRow(row);
  }

  @override
  Future<List<CatalogItem>> listByProject(String projectId) async {
    final rows = await (database.select(database.catalogItems)
          ..where((table) => table.projectId.equals(projectId))
          ..orderBy([(table) => OrderingTerm.asc(table.name)]))
        .get();
    return rows.map(_fromRow).toList();
  }

  @override
  Future<List<CatalogItem>> listByProjectAndType(String projectId, EntityType type) async {
    final rows = await (database.select(database.catalogItems)
          ..where(
            (table) => table.projectId.equals(projectId) & table.type.equals(type.wireName),
          )
          ..orderBy([(table) => OrderingTerm.asc(table.name)]))
        .get();
    return rows.map(_fromRow).toList();
  }

  @override
  Future<void> save(CatalogItem item) async {
    await database.into(database.catalogItems).insertOnConflictUpdate(_toCompanion(item));
  }

  CatalogItemsCompanion _toCompanion(CatalogItem item) {
    return CatalogItemsCompanion.insert(
      id: item.id,
      projectId: item.projectId,
      type: item.type.wireName,
      name: item.name,
      summary: Value(item.summary),
      status: item.status.wireName,
      fieldsJson: Value(jsonEncode(item.fields)),
      metadataJson: Value(jsonEncode(item.metadata)),
      createdAt: item.createdAt,
      updatedAt: item.updatedAt,
    );
  }

  CatalogItem _fromRow(CatalogItemRow row) {
    return CatalogItem(
      id: row.id,
      projectId: row.projectId,
      type: EntityTypeWire.parse(row.type),
      name: row.name,
      summary: row.summary,
      status: DraftStatusWire.parse(row.status),
      fields: _decodeJson(row.fieldsJson),
      metadata: _decodeJson(row.metadataJson),
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  JsonMap _decodeJson(String value) {
    return Map<String, Object?>.from(jsonDecode(value) as Map);
  }
}
