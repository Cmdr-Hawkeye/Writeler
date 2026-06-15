import '../../../core/domain/entity_type.dart';
import 'catalog_item.dart';

abstract interface class CatalogItemRepository {
  Future<void> save(CatalogItem item);

  Future<CatalogItem?> findById(String id);

  Future<List<CatalogItem>> listByProject(String projectId);

  Future<List<CatalogItem>> listByProjectAndType(String projectId, EntityType type);
}
