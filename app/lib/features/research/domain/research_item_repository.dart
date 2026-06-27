import 'research_item.dart';

abstract interface class ResearchItemRepository {
  Future<void> save(ResearchItem item);

  Future<void> delete(String id);

  Future<List<ResearchItem>> listForProject(String projectId);
}
