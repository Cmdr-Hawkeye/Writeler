import '../domain/project.dart';
import '../domain/project_repository.dart';

final class InMemoryProjectRepository implements ProjectRepository {
  final Map<String, Project> _projects = {};

  @override
  Future<void> delete(String id) async {
    _projects.remove(id);
  }

  @override
  Future<Project?> findById(String id) async => _projects[id];

  @override
  Future<List<Project>> listActive() async {
    final projects = _projects.values.toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return projects;
  }

  @override
  Future<void> save(Project project) async {
    _projects[project.id] = project;
  }
}
