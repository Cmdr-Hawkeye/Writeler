import 'project_note.dart';

abstract interface class ProjectNoteRepository {
  Future<void> save(ProjectNote note);

  Future<void> delete(String id);

  Future<List<ProjectNote>> listForProject(String projectId);
}
