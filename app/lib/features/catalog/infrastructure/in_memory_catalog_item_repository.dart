import '../../../core/domain/entity_type.dart';
import '../domain/catalog_item.dart';
import '../domain/catalog_item_repository.dart';

final class InMemoryCatalogItemRepository implements CatalogItemRepository {
  final Map<String, CatalogItem> _items = {};

  @override
  Future<CatalogItem?> findById(String id) async => _items[id];

  @override
  Future<List<CatalogItem>> listByProject(String projectId) async {
    final items = _items.values
        .where((item) => item.projectId == projectId)
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    return items;
  }

  @override
  Future<List<CatalogItem>> listByProjectAndType(
      String projectId, EntityType type) async {
    final items = _items.values
        .where((item) => item.projectId == projectId && item.type == type)
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    return items;
  }

  @override
  Future<void> save(CatalogItem item) async {
    _items[item.id] = item;
  }
}
