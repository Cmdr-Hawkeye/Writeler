import '../domain/chapter.dart';
import '../domain/chapter_repository.dart';

final class LazyChapterRepository implements ChapterRepository {
  LazyChapterRepository(this._create);

  final ChapterRepository Function() _create;
  ChapterRepository? _inner;

  ChapterRepository get _repository => _inner ??= _create();

  @override
  Future<Chapter?> findById(String id) => _repository.findById(id);

  @override
  Future<List<Chapter>> listByProject(String projectId) => _repository.listByProject(projectId);

  @override
  Future<void> save(Chapter chapter) => _repository.save(chapter);
}
