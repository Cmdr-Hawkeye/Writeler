import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/domain/entity_ref.dart';
import '../../../core/domain/entity_type.dart';
import '../../../core/domain/json_map.dart';
import '../../../core/infrastructure/database/app_database.dart';
import '../domain/ai_suggestion.dart';
import '../domain/ai_suggestion_repository.dart';

final class DriftAISuggestionRepository implements AISuggestionRepository {
  const DriftAISuggestionRepository(this.database);

  final AppDatabase database;

  @override
  Future<List<AISuggestion>> listForProject(String projectId) async {
    final rows = await (database.select(database.aISuggestions)
          ..where((table) => table.projectId.equals(projectId))
          ..orderBy([(table) => OrderingTerm.desc(table.createdAt)]))
        .get();
    return rows.map(_fromRow).toList();
  }

  @override
  Future<void> save(AISuggestion suggestion) async {
    await database
        .into(database.aISuggestions)
        .insertOnConflictUpdate(_toCompanion(suggestion));
  }

  AISuggestionsCompanion _toCompanion(AISuggestion suggestion) {
    return AISuggestionsCompanion.insert(
      id: suggestion.id,
      projectId: suggestion.projectId,
      targetType: suggestion.target.type.wireName,
      targetId: suggestion.target.id,
      suggestionType: suggestion.suggestionType,
      inputContextHash: suggestion.inputContextHash,
      providerId: suggestion.providerId,
      modelName: suggestion.modelName,
      promptTemplateId: Value(suggestion.promptTemplateId),
      promptText: suggestion.promptText,
      responseText: suggestion.responseText,
      structuredResponseJson: Value(_encodeNullable(suggestion.structuredResponse)),
      userDecision: suggestion.userDecision.name,
      acceptedPatchJson: Value(_encodeNullable(suggestion.acceptedPatch)),
      createdAt: suggestion.createdAt,
    );
  }

  AISuggestion _fromRow(AISuggestionRow row) {
    return AISuggestion(
      id: row.id,
      projectId: row.projectId,
      target: EntityRef(
        type: EntityTypeWire.parse(row.targetType),
        id: row.targetId,
      ),
      suggestionType: row.suggestionType,
      inputContextHash: row.inputContextHash,
      providerId: row.providerId,
      modelName: row.modelName,
      promptTemplateId: row.promptTemplateId,
      promptText: row.promptText,
      responseText: row.responseText,
      structuredResponse: _decodeNullable(row.structuredResponseJson),
      userDecision: SuggestionDecision.values.firstWhere(
        (decision) => decision.name == row.userDecision,
        orElse: () => SuggestionDecision.pending,
      ),
      acceptedPatch: _decodeNullable(row.acceptedPatchJson),
      createdAt: row.createdAt,
    );
  }

  String? _encodeNullable(JsonMap? value) {
    return value == null ? null : jsonEncode(value);
  }

  JsonMap? _decodeNullable(String? value) {
    if (value == null) return null;
    return Map<String, Object?>.from(jsonDecode(value) as Map);
  }
}
