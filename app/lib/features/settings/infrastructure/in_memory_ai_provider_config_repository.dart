import '../domain/ai_provider_config.dart';
import '../domain/ai_provider_config_repository.dart';

final class InMemoryAIProviderConfigRepository
    implements AIProviderConfigRepository {
  final Map<String, AIProviderConfig> _configs = {};

  @override
  Future<AIProviderConfig?> findById(String id) async => _configs[id];

  @override
  Future<List<AIProviderConfig>> listAll() async {
    final configs = _configs.values.toList()
      ..sort((a, b) => a.displayName.compareTo(b.displayName));
    return configs;
  }

  @override
  Future<void> save(AIProviderConfig config) async {
    _configs[config.id] = config;
  }
}
