import '../../../core/domain/entity_type.dart';
import '../domain/catalog_item.dart';
import '../domain/catalog_item_repository.dart';

final class LazyCatalogItemRepository implements CatalogItemRepository {
  LazyCatalogItemRepository(this._create);

  final CatalogItemRepository Function() _create;
  CatalogItemRepository? _inner;

  CatalogItemRepository get _repository => _inner ??= _create();

  @override
  Future<CatalogItem?> findById(String id) => _repository.findById(id);

  @override
  Future<List<CatalogItem>> listByProject(String projectId) =>
      _repository.listByProject(projectId);

  @override
  Future<List<CatalogItem>> listByProjectAndType(String projectId, EntityType type) =>
      _repository.listByProjectAndType(projectId, type);

  @override
  Future<void> save(CatalogItem item) => _repository.save(item);
}
