import '../../../core/domain/entity_ref.dart';
import 'relationship.dart';

abstract interface class RelationshipRepository {
  Future<void> save(Relationship relationship);

  Future<void> delete(String id);

  Future<List<Relationship>> listByProject(String projectId);

  Future<List<Relationship>> listForSource(EntityRef source);
}
