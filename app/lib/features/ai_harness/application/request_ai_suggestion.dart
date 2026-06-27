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
import '../../structure/domain/chapter.dart';

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

    final prompt = const AIScenePromptBuilder().build(
      policy: policy,
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
      promptTemplateId: 'scene.${task.name}.v1',
      promptText: prompt,
      responseText: response.text,
      structuredResponse: response.structured,
      userDecision: SuggestionDecision.pending,
      createdAt: DateTime.now().toUtc(),
    );

    await repository.save(suggestion);
    return suggestion;
  }

  Future<AISuggestion> forProject({
    required Project project,
    required List<Chapter> chapters,
    required List<Scene> scenes,
    required AITaskKind task,
    required String userPrompt,
    String languageCode = 'en',
    ModelParameters parameters = const ModelParameters(),
  }) async {
    policy.ensureProjectAllowsAI(project);
    policy.ensureAllowedTask(kind: task, targetType: EntityType.project);

    final prompt = const AIProjectPromptBuilder().build(
      policy: policy,
      project: project,
      chapters: chapters,
      scenes: scenes,
      task: task,
      userPrompt: userPrompt,
      languageCode: languageCode,
    );

    final response = await provider.generateText(
      ModelRequest(
        prompt: prompt,
        target: EntityRef(type: EntityType.project, id: project.id),
        context: {
          'projectId': project.id,
          'sceneCount': scenes.length,
          'chapterCount': chapters.length,
        },
        parameters: parameters,
      ),
    );

    final suggestion = AISuggestion(
      id: newLocalId('ai-suggestion'),
      projectId: project.id,
      target: EntityRef(type: EntityType.project, id: project.id),
      suggestionType: task.name,
      inputContextHash: prompt.hashCode.toRadixString(16),
      providerId: provider.id,
      modelName: provider.displayName,
      promptTemplateId: 'project.${task.name}.v1',
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

final class AIProjectPromptBuilder {
  const AIProjectPromptBuilder();

  String build({
    required AIPolicy policy,
    required Project project,
    required List<Chapter> chapters,
    required List<Scene> scenes,
    required AITaskKind task,
    required String userPrompt,
    required String languageCode,
  }) {
    final german = languageCode == 'de';
    final orderedChapters = [...chapters]
      ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
    final orderedScenes = [...scenes]
      ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
    return [
      policy.systemBoundary(languageCode: languageCode),
      german
          ? 'Antworte auf Deutsch. Arbeite auf Projektebene: erkenne Muster, Lücken, Prioritäten und nächste Entscheidungen. Schreibe keine finale Manuskriptprosa.'
          : 'Answer in English. Work at project level: identify patterns, gaps, priorities, and next decisions. Do not write final manuscript prose.',
      german
          ? 'Aufgabe: ${const AIScenePromptBuilder().taskInstruction(task, german: true)}'
          : 'Task: ${const AIScenePromptBuilder().taskInstruction(task, german: false)}',
      german
          ? 'Projekttitel: ${project.title}'
          : 'Project title: ${project.title}',
      german
          ? 'Projektbeschreibung: ${_fallback(project.description, 'nicht gesetzt')}'
          : 'Project description: ${_fallback(project.description, 'not set')}',
      german
          ? 'Projektstatus: ${project.status.wireName}'
          : 'Project status: ${project.status.wireName}',
      german
          ? 'Projektumfang: ${_projectTargetDescription(project, german: true)}'
          : 'Project scope: ${_projectTargetDescription(project, german: false)}',
      german
          ? 'Kapitel (${orderedChapters.length}): ${_chapterSummary(orderedChapters, german: true)}'
          : 'Chapters (${orderedChapters.length}): ${_chapterSummary(orderedChapters, german: false)}',
      german
          ? 'Szenen (${orderedScenes.length}):\n${_sceneSummary(orderedScenes, german: true)}'
          : 'Scenes (${orderedScenes.length}):\n${_sceneSummary(orderedScenes, german: false)}',
      german
          ? 'Nutzerauftrag: ${_fallback(userPrompt, 'keine Zusatzanweisung')}'
          : 'User request: ${_fallback(userPrompt, 'no extra instruction')}',
      german
          ? 'Format: Gib 3 bis 6 nummerierte Punkte aus. Beginne mit der wichtigsten Beobachtung oder Entscheidung. Trenne Analyse, Risiko und nächsten Schritt klar.'
          : 'Format: Return 3 to 6 numbered points. Start with the most important observation or decision. Clearly separate analysis, risk, and next step.',
    ].join('\n');
  }

  static String _fallback(String? value, String fallback) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? fallback : trimmed;
  }

  static String _projectTargetDescription(
    Project project, {
    required bool german,
  }) {
    final wordTarget = project.wordTarget;
    if (wordTarget == null || wordTarget <= 0) {
      return german ? 'nicht gesetzt' : 'not set';
    }
    if (project.metadata['targetUnit'] == 'pages') {
      final wordsPerPage =
          _metadataInt(project.metadata['wordsPerPageEstimate']) ?? 250;
      final pageTarget = _metadataInt(project.metadata['pageTarget']) ??
          (wordTarget / wordsPerPage).round();
      return german
          ? '$pageTarget Seiten (geschätzt $wordTarget Wörter)'
          : '$pageTarget pages (estimated $wordTarget words)';
    }
    return german ? '$wordTarget Wörter' : '$wordTarget words';
  }

  static int? _metadataInt(Object? value) {
    return switch (value) {
      int() => value,
      double() => value.round(),
      String() => int.tryParse(value),
      _ => null,
    };
  }

  static String _chapterSummary(
    List<Chapter> chapters, {
    required bool german,
  }) {
    if (chapters.isEmpty) {
      return german ? 'keine Kapitel angelegt' : 'no chapters created';
    }
    return chapters.take(12).map((chapter) => chapter.title).join(', ');
  }

  static String _sceneSummary(
    List<Scene> scenes, {
    required bool german,
  }) {
    if (scenes.isEmpty) {
      return german ? 'Keine Szenen angelegt.' : 'No scenes created.';
    }
    return scenes.take(18).map((scene) {
      final summary = _fallback(
        scene.summary,
        german ? 'keine Zusammenfassung' : 'no summary',
      );
      final planning = [
        if ((scene.goal ?? '').trim().isEmpty)
          german ? 'Ziel fehlt' : 'goal missing',
        if ((scene.conflict ?? '').trim().isEmpty)
          german ? 'Konflikt fehlt' : 'conflict missing',
        if ((scene.outcome ?? '').trim().isEmpty)
          german ? 'Ausgang fehlt' : 'outcome missing',
      ].join(', ');
      final planningNote = planning.isEmpty
          ? german
              ? 'Planung vollständig'
              : 'planning complete'
          : planning;
      final wordLabel = german ? 'Wörter' : 'words';
      return '- ${scene.title} (${scene.status.wireName}, ${scene.actualWordCount} $wordLabel): $summary [$planningNote]';
    }).join('\n');
  }
}

final class AIScenePromptBuilder {
  const AIScenePromptBuilder();

  String build({
    required AIPolicy policy,
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
          ? 'Antworte auf Deutsch. Schreibe konkret, knapp und handlungsorientiert. Nutze die vorhandenen Szenendaten; wenn etwas fehlt, benenne die Lücke.'
          : 'Answer in English. Be concrete, concise, and actionable. Use the available scene data; if something is missing, name the gap.',
      german
          ? 'Aufgabe: ${taskInstruction(task, german: true)}'
          : 'Task: ${taskInstruction(task, german: false)}',
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
      if (task == AITaskKind.sceneGoalConflictOutcome)
        german
            ? 'Strukturfelder: Beginne deine Antwort mit einem JSON-Block mit genau diesem Objekt: {"scenePatch":{"summary":"","goal":"","conflict":"","outcome":""}}. Danach dürfen kurze nummerierte Hinweise folgen. Schreibe keine Manuskriptprosa.'
            : 'Planning fields: Start your response with a JSON block with exactly this object: {"scenePatch":{"summary":"","goal":"","conflict":"","outcome":""}}. After that, you may add short numbered notes. Do not write manuscript prose.',
      german
          ? 'Format: Gib 3 bis 6 nummerierte Punkte aus. Jeder Punkt soll eine konkrete Beobachtung oder Option enthalten, keine allgemeinen Ratschläge.'
          : 'Format: Return 3 to 6 numbered points. Each point should contain a concrete observation or option, not generic advice.',
    ].join('\n');
  }

  String taskInstruction(AITaskKind task, {required bool german}) {
    return switch (task) {
      AITaskKind.sceneIdeas => german
          ? 'Entwickle mehrere Szenenideen oder Varianten, die zur vorhandenen Szene passen.'
          : 'Develop several scene ideas or variants that fit the existing scene.',
      AITaskKind.sceneGoalConflictOutcome => german
          ? 'Prüfe Ziel, Konflikt und Ausgang der Szene. Schlage konkrete Schärfungen vor.'
          : 'Review the scene goal, conflict, and outcome. Suggest concrete refinements.',
      AITaskKind.customScenePrompt => german
          ? 'Bearbeite den Nutzerauftrag zur Szene.'
          : 'Handle the user request for the scene.',
      AITaskKind.characterProfile => german
          ? 'Prüfe Figurenprofil und Figurenfunktion im Szenenkontext.'
          : 'Review character profile and function in scene context.',
      AITaskKind.consistencyCheck => german
          ? 'Suche nach Anschluss-, Logik- und Konsistenzproblemen.'
          : 'Look for continuity, logic, and consistency problems.',
      AITaskKind.timelineCheck => german
          ? 'Prüfe zeitliche Abfolge, Dauer und Datumslogik.'
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
          ? 'Strukturiere offene Recherchefragen und nächste Schritte.'
          : 'Structure open research questions and next steps.',
      AITaskKind.plotGapReview => german
          ? 'Suche Plot-Lücken, fehlende Motivation und unklare Kausalität.'
          : 'Look for plot gaps, missing motivation, and unclear causality.',
      AITaskKind.dialogueIntentAnalysis => german
          ? 'Prüfe Dialogabsicht, Subtext und Machtverschiebung.'
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
