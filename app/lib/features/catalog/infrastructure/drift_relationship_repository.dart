import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/domain/entity_ref.dart';
import '../../../core/domain/entity_type.dart';
import '../../../core/domain/json_map.dart';
import '../../../core/infrastructure/database/app_database.dart';
import '../domain/relationship.dart';
import '../domain/relationship_repository.dart';

final class DriftRelationshipRepository implements RelationshipRepository {
  const DriftRelationshipRepository(this.database);

  final AppDatabase database;

  @override
  Future<void> delete(String id) async {
    await (database.delete(database.relationships)
          ..where((table) => table.id.equals(id)))
        .go();
  }

  @override
  Future<List<Relationship>> listByProject(String projectId) async {
    final rows = await (database.select(database.relationships)
          ..where((table) => table.projectId.equals(projectId))
          ..orderBy([(table) => OrderingTerm.asc(table.createdAt)]))
        .get();
    return rows.map(_fromRow).toList();
  }

  @override
  Future<List<Relationship>> listForSource(EntityRef source) async {
    final rows = await (database.select(database.relationships)
          ..where(
            (table) =>
                table.sourceType.equals(source.type.wireName) &
                table.sourceId.equals(source.id),
          )
          ..orderBy([(table) => OrderingTerm.asc(table.createdAt)]))
        .get();
    return rows.map(_fromRow).toList();
  }

  @override
  Future<void> save(Relationship relationship) async {
    await database
        .into(database.relationships)
        .insertOnConflictUpdate(_toCompanion(relationship));
  }

  RelationshipsCompanion _toCompanion(Relationship relationship) {
    return RelationshipsCompanion.insert(
      id: relationship.id,
      projectId: relationship.projectId,
      sourceType: relationship.source.type.wireName,
      sourceId: relationship.source.id,
      targetType: relationship.target.type.wireName,
      targetId: relationship.target.id,
      relationshipType: relationship.relationshipType,
      label: Value(relationship.label),
      description: Value(relationship.description),
      strength: Value(relationship.strength),
      direction: relationship.direction.name,
      validFromStoryTime: Value(relationship.validFromStoryTime),
      validToStoryTime: Value(relationship.validToStoryTime),
      metadataJson: Value(jsonEncode(relationship.metadata)),
      createdAt: relationship.createdAt,
      updatedAt: relationship.updatedAt,
    );
  }

  Relationship _fromRow(RelationshipRow row) {
    return Relationship(
      id: row.id,
      projectId: row.projectId,
      source: EntityRef(
          type: EntityTypeWire.parse(row.sourceType), id: row.sourceId),
      target: EntityRef(
          type: EntityTypeWire.parse(row.targetType), id: row.targetId),
      relationshipType: row.relationshipType,
      label: row.label,
      description: row.description,
      strength: row.strength,
      direction: RelationshipDirection.values.firstWhere(
        (direction) => direction.name == row.direction,
        orElse: () => RelationshipDirection.directed,
      ),
      validFromStoryTime: row.validFromStoryTime,
      validToStoryTime: row.validToStoryTime,
      metadata: _decodeJson(row.metadataJson),
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  JsonMap _decodeJson(String value) {
    return Map<String, Object?>.from(jsonDecode(value) as Map);
  }
}
