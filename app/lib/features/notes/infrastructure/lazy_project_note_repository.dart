import '../domain/project_note.dart';
import '../domain/project_note_repository.dart';

final class LazyProjectNoteRepository implements ProjectNoteRepository {
  LazyProjectNoteRepository(this._create);

  final ProjectNoteRepository Function() _create;
  ProjectNoteRepository? _inner;

  ProjectNoteRepository get _repository => _inner ??= _create();

  @override
  Future<void> save(ProjectNote note) => _repository.save(note);

  @override
  Future<void> delete(String id) => _repository.delete(id);

  @override
  Future<List<ProjectNote>> listForProject(String projectId) =>
      _repository.listForProject(projectId);
}
