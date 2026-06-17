import '../domain/ai_suggestion.dart';
import '../domain/ai_suggestion_repository.dart';

final class InMemoryAISuggestionRepository implements AISuggestionRepository {
  final List<AISuggestion> _items = [];

  @override
  Future<List<AISuggestion>> listForProject(String projectId) async {
    return _items
        .where((suggestion) => suggestion.projectId == projectId)
        .toList();
  }

  @override
  Future<void> save(AISuggestion suggestion) async {
    _items.removeWhere((item) => item.id == suggestion.id);
    _items.add(suggestion);
  }

  @override
  Future<void> delete(String id) async {
    _items.removeWhere((item) => item.id == id);
  }
}
