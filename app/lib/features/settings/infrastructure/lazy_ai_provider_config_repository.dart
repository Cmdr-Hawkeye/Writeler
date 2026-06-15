import '../domain/ai_provider_config.dart';
import '../domain/ai_provider_config_repository.dart';

final class LazyAIProviderConfigRepository
    implements AIProviderConfigRepository {
  LazyAIProviderConfigRepository(this._create);

  final AIProviderConfigRepository Function() _create;
  AIProviderConfigRepository? _inner;

  AIProviderConfigRepository get _repository => _inner ??= _create();

  @override
  Future<AIProviderConfig?> findById(String id) => _repository.findById(id);

  @override
  Future<List<AIProviderConfig>> listAll() => _repository.listAll();

  @override
  Future<void> save(AIProviderConfig config) => _repository.save(config);
}
