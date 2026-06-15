import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/domain/json_map.dart';
import '../../../core/infrastructure/database/app_database.dart';
import '../domain/ai_provider_config.dart';
import '../domain/ai_provider_config_repository.dart';

final class DriftAIProviderConfigRepository
    implements AIProviderConfigRepository {
  const DriftAIProviderConfigRepository(this.database);

  final AppDatabase database;

  @override
  Future<AIProviderConfig?> findById(String id) async {
    final row = await (database.select(database.aIProviderConfigs)
          ..where((table) => table.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _fromRow(row);
  }

  @override
  Future<List<AIProviderConfig>> listAll() async {
    final rows = await (database.select(database.aIProviderConfigs)
          ..orderBy([(table) => OrderingTerm.asc(table.displayName)]))
        .get();
    return rows.map(_fromRow).toList();
  }

  @override
  Future<void> save(AIProviderConfig config) async {
    await database
        .into(database.aIProviderConfigs)
        .insertOnConflictUpdate(_toCompanion(config));
  }

  AIProviderConfigsCompanion _toCompanion(AIProviderConfig config) {
    return AIProviderConfigsCompanion.insert(
      id: config.id,
      kind: config.kind.name,
      displayName: config.displayName,
      modelName: config.modelName,
      baseUrl: Value(config.baseUrl),
      encryptedApiKeyRef: Value(config.encryptedApiKeyRef),
      parametersJson: Value(jsonEncode(config.parameters)),
      enabled: config.enabled,
      updatedAt: DateTime.now().toUtc(),
    );
  }

  AIProviderConfig _fromRow(AIProviderConfigRow row) {
    return AIProviderConfig(
      id: row.id,
      kind: AIProviderKind.values.firstWhere(
        (kind) => kind.name == row.kind,
        orElse: () => AIProviderKind.mock,
      ),
      displayName: row.displayName,
      modelName: row.modelName,
      baseUrl: row.baseUrl,
      encryptedApiKeyRef: row.encryptedApiKeyRef,
      parameters: _decodeJson(row.parametersJson),
      enabled: row.enabled,
    );
  }

  JsonMap _decodeJson(String value) {
    return Map<String, Object?>.from(jsonDecode(value) as Map);
  }
}
