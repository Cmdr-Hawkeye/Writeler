import '../domain/scene.dart';
import '../domain/scene_repository.dart';

final class LazySceneRepository implements SceneRepository {
  LazySceneRepository(this._create);

  final SceneRepository Function() _create;
  SceneRepository? _inner;

  SceneRepository get _repository => _inner ??= _create();

  @override
  Future<void> delete(String id) => _repository.delete(id);

  @override
  Future<Scene?> findById(String id) => _repository.findById(id);

  @override
  Future<List<Scene>> listByProject(String projectId) =>
      _repository.listByProject(projectId);

  @override
  Future<void> save(Scene scene) => _repository.save(scene);
}
