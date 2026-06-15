import 'chapter.dart';

abstract interface class ChapterRepository {
  Future<void> save(Chapter chapter);

  Future<Chapter?> findById(String id);

  Future<List<Chapter>> listByProject(String projectId);
}
