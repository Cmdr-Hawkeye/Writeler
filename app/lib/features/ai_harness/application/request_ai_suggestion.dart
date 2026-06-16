import '../../../core/domain/draft_status.dart';
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
    String languageCode = 'en',
    ModelParameters parameters = const ModelParameters(),
  }) async {
    policy.ensureProjectAllowsAI(project);
    policy.ensureSceneAllowsAI(scene);
    policy.ensureAllowedTask(kind: task, targetType: EntityType.scene);

    final prompt = _buildScenePrompt(
      scene: scene,
      task: task,
      userPrompt: userPrompt,
      languageCode: languageCode,
    );

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

  String _buildScenePrompt({
    required Scene scene,
    required AITaskKind task,
    required String userPrompt,
    required String languageCode,
  }) {
    final german = languageCode == 'de';
    final manuscriptExcerpt = _excerpt(scene.manuscriptText);
    return [
      policy.systemBoundary(languageCode: languageCode),
      german
          ? 'Antworte auf Deutsch. Schreibe konkret, knapp und handlungsorientiert. Nutze die vorhandenen Szenendaten; wenn etwas fehlt, benenne die Luecke.'
          : 'Answer in English. Be concrete, concise, and actionable. Use the available scene data; if something is missing, name the gap.',
      german
          ? 'Aufgabe: ${_taskInstruction(task, german: true)}'
          : 'Task: ${_taskInstruction(task, german: false)}',
      german ? 'Szenentitel: ${scene.title}' : 'Scene title: ${scene.title}',
      german
          ? 'Status: ${scene.status.wireName}'
          : 'Status: ${scene.status.wireName}',
      german
          ? 'Autorische Absicht: ${_fallback(scene.authorIntent, 'nicht gesetzt')}'
          : 'Author intent: ${_fallback(scene.authorIntent, 'not set')}',
      german
          ? 'Zusammenfassung: ${_fallback(scene.summary, 'nicht gesetzt')}'
          : 'Summary: ${_fallback(scene.summary, 'not set')}',
      german
          ? 'Ziel: ${_fallback(scene.goal, 'nicht gesetzt')}'
          : 'Goal: ${_fallback(scene.goal, 'not set')}',
      german
          ? 'Konflikt: ${_fallback(scene.conflict, 'nicht gesetzt')}'
          : 'Conflict: ${_fallback(scene.conflict, 'not set')}',
      german
          ? 'Ausgang: ${_fallback(scene.outcome, 'nicht gesetzt')}'
          : 'Outcome: ${_fallback(scene.outcome, 'not set')}',
      german
          ? 'Wortzahl: ${scene.actualWordCount}'
          : 'Word count: ${scene.actualWordCount}',
      if (manuscriptExcerpt.isNotEmpty)
        german
            ? 'Manuskript-Auszug:\n$manuscriptExcerpt'
            : 'Manuscript excerpt:\n$manuscriptExcerpt',
      german
          ? 'Nutzerauftrag: ${_fallback(userPrompt, 'keine Zusatzanweisung')}'
          : 'User request: ${_fallback(userPrompt, 'no extra instruction')}',
      german
          ? 'Format: Gib 3 bis 6 nummerierte Punkte aus. Jeder Punkt soll eine konkrete Beobachtung oder Option enthalten, keine allgemeinen Ratschlaege.'
          : 'Format: Return 3 to 6 numbered points. Each point should contain a concrete observation or option, not generic advice.',
    ].join('\n');
  }

  String _taskInstruction(AITaskKind task, {required bool german}) {
    return switch (task) {
      AITaskKind.sceneIdeas => german
          ? 'Entwickle mehrere Szenenideen oder Varianten, die zur vorhandenen Szene passen.'
          : 'Develop several scene ideas or variants that fit the existing scene.',
      AITaskKind.sceneGoalConflictOutcome => german
          ? 'Pruefe Ziel, Konflikt und Ausgang der Szene. Schlage konkrete Schaerfungen vor.'
          : 'Review the scene goal, conflict, and outcome. Suggest concrete refinements.',
      AITaskKind.customScenePrompt => german
          ? 'Bearbeite den Nutzerauftrag zur Szene.'
          : 'Handle the user request for the scene.',
      AITaskKind.characterProfile => german
          ? 'Pruefe Figurenprofil und Figurenfunktion im Szenenkontext.'
          : 'Review character profile and function in scene context.',
      AITaskKind.consistencyCheck => german
          ? 'Suche nach Anschluss-, Logik- und Konsistenzproblemen.'
          : 'Look for continuity, logic, and consistency problems.',
      AITaskKind.timelineCheck => german
          ? 'Pruefe zeitliche Abfolge, Dauer und Datumslogik.'
          : 'Review chronology, duration, and date logic.',
      AITaskKind.storylineVariants => german
          ? 'Entwickle alternative Storyline-Varianten mit Folgen.'
          : 'Develop alternative storyline variants with consequences.',
      AITaskKind.blurbVariants => german
          ? 'Entwickle Klappentext- oder Pitch-Varianten ohne Manuskripttext zu ersetzen.'
          : 'Develop blurb or pitch variants without replacing manuscript prose.',
      AITaskKind.styleAnalysis => german
          ? 'Analysiere Stilwirkung, Ton und Rhythmus als Hinweise.'
          : 'Analyze style effect, tone, and rhythm as notes.',
      AITaskKind.authorQuestions => german
          ? 'Formuliere starke Fragen, die der Autor entscheiden sollte.'
          : 'Formulate strong questions the author should decide.',
      AITaskKind.researchStructuring => german
          ? 'Strukturiere offene Recherchefragen und naechste Schritte.'
          : 'Structure open research questions and next steps.',
      AITaskKind.plotGapReview => german
          ? 'Suche Plot-Luecken, fehlende Motivation und unklare Kausalitaet.'
          : 'Look for plot gaps, missing motivation, and unclear causality.',
      AITaskKind.dialogueIntentAnalysis => german
          ? 'Pruefe Dialogabsicht, Subtext und Machtverschiebung.'
          : 'Review dialogue intent, subtext, and power shifts.',
    };
  }

  String _fallback(String? value, String fallback) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? fallback : trimmed;
  }

  String _excerpt(String value) {
    final trimmed = value.trim();
    if (trimmed.length <= 1200) return trimmed;
    return '${trimmed.substring(0, 1200)}...';
  }
}
