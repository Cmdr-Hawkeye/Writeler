import '../../../core/domain/entity_ref.dart';
import '../domain/relationship.dart';
import '../domain/relationship_repository.dart';

final class InMemoryRelationshipRepository implements RelationshipRepository {
  final Map<String, Relationship> _relationships = {};

  @override
  Future<void> delete(String id) async {
    _relationships.remove(id);
  }

  @override
  Future<List<Relationship>> listByProject(String projectId) async {
    final items = _relationships.values
        .where((relationship) => relationship.projectId == projectId)
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return items;
  }

  @override
  Future<List<Relationship>> listForSource(EntityRef source) async {
    final items = _relationships.values
        .where(
          (relationship) =>
              relationship.source.type == source.type && relationship.source.id == source.id,
        )
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return items;
  }

  @override
  Future<void> save(Relationship relationship) async {
    _relationships[relationship.id] = relationship;
  }
}
