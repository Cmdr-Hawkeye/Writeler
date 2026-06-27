import '../domain/scene_snapshot.dart';
import '../domain/scene_snapshot_repository.dart';

final class InMemorySceneSnapshotRepository implements SceneSnapshotRepository {
  final Map<String, SceneSnapshot> _snapshots = {};

  @override
  Future<void> delete(String id) async {
    _snapshots.remove(id);
  }

  @override
  Future<SceneSnapshot?> latestForScene(String sceneId) async {
    final snapshots = await listForScene(sceneId);
    return snapshots.isEmpty ? null : snapshots.first;
  }

  @override
  Future<List<SceneSnapshot>> listByProject(String projectId) async {
    final snapshots = _snapshots.values
        .where((snapshot) => snapshot.projectId == projectId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return snapshots;
  }

  @override
  Future<List<SceneSnapshot>> listForScene(String sceneId) async {
    final snapshots = _snapshots.values
        .where((snapshot) => snapshot.sceneId == sceneId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return snapshots;
  }

  @override
  Future<void> save(SceneSnapshot snapshot) async {
    _snapshots[snapshot.id] = snapshot;
  }
}
