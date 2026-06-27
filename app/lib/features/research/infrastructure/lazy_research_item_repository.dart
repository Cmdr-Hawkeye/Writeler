import '../domain/research_item.dart';
import '../domain/research_item_repository.dart';

final class LazyResearchItemRepository implements ResearchItemRepository {
  LazyResearchItemRepository(this._create);

  final ResearchItemRepository Function() _create;
  ResearchItemRepository? _inner;

  ResearchItemRepository get _repository => _inner ??= _create();

  @override
  Future<void> save(ResearchItem item) => _repository.save(item);

  @override
  Future<void> delete(String id) => _repository.delete(id);

  @override
  Future<List<ResearchItem>> listForProject(String projectId) =>
      _repository.listForProject(projectId);
}
