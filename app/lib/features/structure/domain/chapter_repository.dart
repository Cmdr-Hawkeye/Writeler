import 'chapter.dart';

abstract interface class ChapterRepository {
  Future<void> save(Chapter chapter);

  Future<void> delete(String id);

  Future<Chapter?> findById(String id);

  Future<List<Chapter>> listByProject(String projectId);
}
