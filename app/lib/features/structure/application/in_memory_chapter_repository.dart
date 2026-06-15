import '../domain/chapter.dart';
import '../domain/chapter_repository.dart';

final class InMemoryChapterRepository implements ChapterRepository {
  final Map<String, Chapter> _chapters = {};

  @override
  Future<Chapter?> findById(String id) async => _chapters[id];

  @override
  Future<List<Chapter>> listByProject(String projectId) async {
    final chapters = _chapters.values.where((chapter) => chapter.projectId == projectId).toList()
      ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
    return chapters;
  }

  @override
  Future<void> save(Chapter chapter) async {
    _chapters[chapter.id] = chapter;
  }
}
