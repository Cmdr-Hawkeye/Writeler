import 'ai_suggestion.dart';

abstract interface class AISuggestionRepository {
  Future<void> save(AISuggestion suggestion);

  Future<void> delete(String id);

  Future<List<AISuggestion>> listForProject(String projectId);
}
