import 'scene.dart';

abstract interface class SceneRepository {
  Future<void> save(Scene scene);

  Future<void> delete(String id);

  Future<Scene?> findById(String id);

  Future<List<Scene>> listByProject(String projectId);
}
