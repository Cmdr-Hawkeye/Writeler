import '../domain/research_item.dart';
import '../domain/research_item_repository.dart';

final class InMemoryResearchItemRepository implements ResearchItemRepository {
  final List<ResearchItem> _items = [];

  @override
  Future<void> save(ResearchItem item) async {
    _items.removeWhere((entry) => entry.id == item.id);
    _items.add(item);
  }

  @override
  Future<void> delete(String id) async {
    _items.removeWhere((entry) => entry.id == id);
  }

  @override
  Future<List<ResearchItem>> listForProject(String projectId) async {
    return _items.where((item) => item.projectId == projectId).toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }
}
