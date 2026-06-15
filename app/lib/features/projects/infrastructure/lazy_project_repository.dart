import '../domain/project.dart';
import '../domain/project_repository.dart';

final class LazyProjectRepository implements ProjectRepository {
  LazyProjectRepository(this._create);

  final ProjectRepository Function() _create;
  ProjectRepository? _inner;

  ProjectRepository get _repository => _inner ??= _create();

  @override
  Future<Project?> findById(String id) => _repository.findById(id);

  @override
  Future<List<Project>> listActive() => _repository.listActive();

  @override
  Future<void> save(Project project) => _repository.save(project);
}
