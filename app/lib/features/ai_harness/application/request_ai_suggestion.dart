import '../../../core/domain/entity_ref.dart';
import '../../../core/domain/entity_type.dart';
import '../../../core/domain/ids.dart';
import '../../projects/domain/project.dart';
import '../../structure/domain/scene.dart';
import '../domain/ai_policy.dart';
import '../domain/ai_suggestion.dart';
import '../domain/ai_suggestion_repository.dart';
import '../domain/language_model_provider.dart';
import '../domain/model_request.dart';

final class RequestAISuggestion {
  const RequestAISuggestion({
    required this.provider,
    required this.repository,
    this.policy = const AIPolicy(),
  });

  final LanguageModelProvider provider;
  final AISuggestionRepository repository;
  final AIPolicy policy;

  Future<AISuggestion> forScene({
    required Project project,
    required Scene scene,
    required AITaskKind task,
    required String userPrompt,
    ModelParameters parameters = const ModelParameters(),
  }) async {
    policy.ensureProjectAllowsAI(project);
    policy.ensureSceneAllowsAI(scene);
    policy.ensureAllowedTask(kind: task, targetType: EntityType.scene);

    final prompt = [
      policy.systemBoundary(),
      'Task: ${task.name}',
      'Scene title: ${scene.title}',
      'Author intent: ${scene.authorIntent}',
      'Summary: ${scene.summary}',
      'User request: $userPrompt',
    ].join('\n');

    final response = await provider.generateText(
      ModelRequest(
        prompt: prompt,
        target: EntityRef(type: EntityType.scene, id: scene.id),
        context: {
          'projectId': project.id,
          'sceneId': scene.id,
          'wordCount': scene.actualWordCount,
        },
        parameters: parameters,
      ),
    );

    final suggestion = AISuggestion(
      id: newLocalId('ai-suggestion'),
      projectId: project.id,
      target: EntityRef(type: EntityType.scene, id: scene.id),
      suggestionType: task.name,
      inputContextHash: prompt.hashCode.toRadixString(16),
      providerId: provider.id,
      modelName: provider.displayName,
      promptText: prompt,
      responseText: response.text,
      structuredResponse: response.structured,
      userDecision: SuggestionDecision.pending,
      createdAt: DateTime.now().toUtc(),
    );

    await repository.save(suggestion);
    return suggestion;
  }
}
