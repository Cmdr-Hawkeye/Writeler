import '../../../core/domain/entity_ref.dart';
import '../domain/relationship.dart';
import '../domain/relationship_repository.dart';

final class LazyRelationshipRepository implements RelationshipRepository {
  LazyRelationshipRepository(this._create);

  final RelationshipRepository Function() _create;
  RelationshipRepository? _inner;

  RelationshipRepository get _repository => _inner ??= _create();

  @override
  Future<void> delete(String id) => _repository.delete(id);

  @override
  Future<List<Relationship>> listByProject(String projectId) =>
      _repository.listByProject(projectId);

  @override
  Future<List<Relationship>> listForSource(EntityRef source) =>
      _repository.listForSource(source);

  @override
  Future<void> save(Relationship relationship) =>
      _repository.save(relationship);
}
