import 'ai_provider_config.dart';

abstract interface class AIProviderConfigRepository {
  Future<void> save(AIProviderConfig config);

  Future<AIProviderConfig?> findById(String id);

  Future<List<AIProviderConfig>> listAll();
}
