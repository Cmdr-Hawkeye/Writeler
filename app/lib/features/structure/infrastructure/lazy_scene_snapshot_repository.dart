import '../domain/scene_snapshot.dart';
import '../domain/scene_snapshot_repository.dart';

final class LazySceneSnapshotRepository implements SceneSnapshotRepository {
  LazySceneSnapshotRepository(this._create);

  final SceneSnapshotRepository Function() _create;
  SceneSnapshotRepository? _inner;

  SceneSnapshotRepository get _repository => _inner ??= _create();

  @override
  Future<void> delete(String id) => _repository.delete(id);

  @override
  Future<SceneSnapshot?> latestForScene(String sceneId) =>
      _repository.latestForScene(sceneId);

  @override
  Future<List<SceneSnapshot>> listByProject(String projectId) =>
      _repository.listByProject(projectId);

  @override
  Future<List<SceneSnapshot>> listForScene(String sceneId) =>
      _repository.listForScene(sceneId);

  @override
  Future<void> save(SceneSnapshot snapshot) => _repository.save(snapshot);
}
