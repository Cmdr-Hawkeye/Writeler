import 'project.dart';

abstract interface class ProjectRepository {
  Future<void> save(Project project);

  Future<Project?> findById(String id);

  Future<List<Project>> listActive();
}
