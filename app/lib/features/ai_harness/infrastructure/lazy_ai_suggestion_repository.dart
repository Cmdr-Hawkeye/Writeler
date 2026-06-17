import '../domain/ai_suggestion.dart';
import '../domain/ai_suggestion_repository.dart';

final class LazyAISuggestionRepository implements AISuggestionRepository {
  LazyAISuggestionRepository(this._create);

  final AISuggestionRepository Function() _create;
  AISuggestionRepository? _inner;

  AISuggestionRepository get _repository => _inner ??= _create();

  @override
  Future<List<AISuggestion>> listForProject(String projectId) =>
      _repository.listForProject(projectId);

  @override
  Future<void> save(AISuggestion suggestion) => _repository.save(suggestion);

  @override
  Future<void> delete(String id) => _repository.delete(id);
}
