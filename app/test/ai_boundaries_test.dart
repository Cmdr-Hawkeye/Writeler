import 'package:test/test.dart';
import 'package:writeller/core/domain/domain_failure.dart';
import 'package:writeller/features/ai_harness/application/request_ai_suggestion.dart';
import 'package:writeller/features/ai_harness/domain/ai_policy.dart';
import 'package:writeller/features/ai_harness/domain/ai_suggestion.dart';
import 'package:writeller/features/ai_harness/infrastructure/in_memory_ai_suggestion_repository.dart';
import 'package:writeller/features/ai_harness/infrastructure/mock_language_model_provider.dart';
import 'package:writeller/features/projects/application/create_project.dart';
import 'package:writeller/features/projects/infrastructure/in_memory_project_repository.dart';
import 'package:writeller/features/structure/application/create_scene.dart';
import 'package:writeller/features/structure/application/in_memory_scene_repository.dart';

void main() {
  test('AI suggestions are saved separately and do not change manuscript text',
      () async {
    final projectRepository = InMemoryProjectRepository();
    final sceneRepository = InMemorySceneRepository();
    final suggestionRepository = InMemoryAISuggestionRepository();

    final project = await CreateProject(projectRepository)(
      const CreateProjectCommand(title: 'A Local Novel'),
    );
    final scene = await CreateScene(sceneRepository)(
      CreateSceneCommand(
        projectId: project.id,
        title: 'Opening',
        authorIntent: 'Set up the central conflict.',
      ),
    );
    final editedScene = scene.withAuthorText('Only the author wrote this.');
    await sceneRepository.save(editedScene);

    final suggestion = await RequestAISuggestion(
      provider: const MockLanguageModelProvider(),
      repository: suggestionRepository,
    ).forScene(
      project: project,
      scene: editedScene,
      task: AITaskKind.sceneGoalConflictOutcome,
      userPrompt: 'Review the scene structure.',
    );

    final reloaded = await sceneRepository.findById(scene.id);
    final suggestions = await suggestionRepository.listForProject(project.id);

    expect(reloaded?.manuscriptText, 'Only the author wrote this.');
    expect(suggestion.userDecision, SuggestionDecision.pending);
    expect(suggestions, hasLength(1));
  });

  test('AI requests fail when project disables AI', () async {
    final projectRepository = InMemoryProjectRepository();
    final sceneRepository = InMemorySceneRepository();

    final project = await CreateProject(projectRepository)(
      const CreateProjectCommand(title: 'Private Draft', aiEnabled: false),
    );
    final scene = await CreateScene(sceneRepository)(
      CreateSceneCommand(projectId: project.id, title: 'Locked Scene'),
    );

    final service = RequestAISuggestion(
      provider: const MockLanguageModelProvider(),
      repository: InMemoryAISuggestionRepository(),
    );

    expect(
      () => service.forScene(
        project: project,
        scene: scene,
        task: AITaskKind.sceneIdeas,
        userPrompt: 'Suggest alternatives.',
      ),
      throwsA(isA<DomainFailure>()),
    );
  });

  test('AI suggestions can be deleted after review', () async {
    final projectRepository = InMemoryProjectRepository();
    final sceneRepository = InMemorySceneRepository();
    final suggestionRepository = InMemoryAISuggestionRepository();

    final project = await CreateProject(projectRepository)(
      const CreateProjectCommand(title: 'Review Queue'),
    );
    final scene = await CreateScene(sceneRepository)(
      CreateSceneCommand(projectId: project.id, title: 'Decision Point'),
    );

    final suggestion = await RequestAISuggestion(
      provider: const MockLanguageModelProvider(),
      repository: suggestionRepository,
    ).forScene(
      project: project,
      scene: scene,
      task: AITaskKind.authorQuestions,
      userPrompt: 'Ask useful questions.',
    );

    await suggestionRepository.delete(suggestion.id);

    expect(await suggestionRepository.listForProject(project.id), isEmpty);
  });
}
