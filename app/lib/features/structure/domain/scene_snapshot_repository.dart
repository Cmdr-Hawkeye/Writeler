import 'scene_snapshot.dart';

abstract interface class SceneSnapshotRepository {
  Future<void> save(SceneSnapshot snapshot);

  Future<void> delete(String id);

  Future<List<SceneSnapshot>> listByProject(String projectId);

  Future<List<SceneSnapshot>> listForScene(String sceneId);

  Future<SceneSnapshot?> latestForScene(String sceneId);
}
