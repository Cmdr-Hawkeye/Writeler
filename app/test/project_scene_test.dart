import 'package:test/test.dart';
import 'package:writeller/core/domain/domain_failure.dart';
import 'package:writeller/features/projects/application/create_project.dart';
import 'package:writeller/features/projects/infrastructure/in_memory_project_repository.dart';
import 'package:writeller/features/structure/application/create_scene.dart';
import 'package:writeller/features/structure/application/in_memory_scene_repository.dart';

void main() {
  test('project and scene creation validate required titles', () async {
    final projectRepository = InMemoryProjectRepository();
    final sceneRepository = InMemorySceneRepository();

    expect(
      () => CreateProject(projectRepository)(
          const CreateProjectCommand(title: '')),
      throwsA(isA<DomainFailure>()),
    );

    final project = await CreateProject(projectRepository)(
      const CreateProjectCommand(title: 'Working Book'),
    );

    expect(
      () => CreateScene(sceneRepository)(
        CreateSceneCommand(projectId: project.id, title: ' '),
      ),
      throwsA(isA<DomainFailure>()),
    );
  });

  test('scene word count is derived from manuscript text', () async {
    final repository = InMemorySceneRepository();
    final scene = await CreateScene(repository)(
      const CreateSceneCommand(projectId: 'project-1', title: 'Quiet Start'),
    );

    final edited = scene.withAuthorText('One two three.');

    expect(edited.actualWordCount, 3);
  });
}
