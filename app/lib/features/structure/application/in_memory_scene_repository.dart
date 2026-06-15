import '../domain/scene.dart';
import '../domain/scene_repository.dart';

final class InMemorySceneRepository implements SceneRepository {
  final Map<String, Scene> _scenes = {};

  @override
  Future<Scene?> findById(String id) async => _scenes[id];

  @override
  Future<List<Scene>> listByProject(String projectId) async {
    final scenes = _scenes.values.where((scene) => scene.projectId == projectId).toList()
      ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
    return scenes;
  }

  @override
  Future<void> save(Scene scene) async {
    _scenes[scene.id] = scene;
  }
}
