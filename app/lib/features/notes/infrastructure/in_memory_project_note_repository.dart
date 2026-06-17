import '../domain/project_note.dart';
import '../domain/project_note_repository.dart';

final class InMemoryProjectNoteRepository implements ProjectNoteRepository {
  final List<ProjectNote> _items = [];

  @override
  Future<void> save(ProjectNote note) async {
    _items.removeWhere((item) => item.id == note.id);
    _items.add(note);
  }

  @override
  Future<void> delete(String id) async {
    _items.removeWhere((item) => item.id == id);
  }

  @override
  Future<List<ProjectNote>> listForProject(String projectId) async {
    return _items.where((note) => note.projectId == projectId).toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }
}
