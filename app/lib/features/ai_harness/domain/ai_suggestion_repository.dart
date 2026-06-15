import 'ai_suggestion.dart';

abstract interface class AISuggestionRepository {
  Future<void> save(AISuggestion suggestion);

  Future<List<AISuggestion>> listForProject(String projectId);
}
