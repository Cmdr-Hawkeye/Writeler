import 'dart:convert';

import '../../../core/domain/draft_status.dart';
import '../../../core/domain/entity_ref.dart';
import '../../../core/domain/entity_type.dart';
import '../../../core/domain/ids.dart';
import '../../catalog/domain/catalog_item.dart';
import '../../catalog/domain/character_profile.dart';
import '../../catalog/domain/relationship.dart';
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
    List<CatalogItem> contextCatalogItems = const [],
    List<Relationship> contextRelationships = const [],
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
      contextCatalogItems: contextCatalogItems,
      contextRelationships: contextRelationships,
    );

    final response = await provider.generateText(
      ModelRequest(
        prompt: prompt,
        target: EntityRef(type: EntityType.scene, id: scene.id),
        context: {
          'projectId': project.id,
          'sceneId': scene.id,
          'wordCount': scene.actualWordCount,
          'contextCatalogItemCount': contextCatalogItems.length,
          'contextRelationshipCount': contextRelationships.length,
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
    List<CatalogItem> contextCatalogItems = const [],
    List<Relationship> contextRelationships = const [],
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
      contextCatalogItems: contextCatalogItems,
      contextRelationships: contextRelationships,
    );

    final response = await provider.generateText(
      ModelRequest(
        prompt: prompt,
        target: EntityRef(type: EntityType.project, id: project.id),
        context: {
          'projectId': project.id,
          'sceneCount': scenes.length,
          'chapterCount': chapters.length,
          'contextCatalogItemCount': contextCatalogItems.length,
          'contextRelationshipCount': contextRelationships.length,
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
    List<CatalogItem> contextCatalogItems = const [],
    List<Relationship> contextRelationships = const [],
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
      _fineGrainedContextBlock(
        catalogItems: contextCatalogItems,
        relationships: contextRelationships,
        scenes: orderedScenes,
        german: german,
      ),
      german
          ? 'Nutzerauftrag: ${_fallback(userPrompt, 'keine Zusatzanweisung')}'
          : 'User request: ${_fallback(userPrompt, 'no extra instruction')}',
      if (task == AITaskKind.worldContextStarter)
        german
            ? 'Persona-Steckbrief: Ergänze in jedem Persona-Objekt zusätzlich diese Felder: ${jsonEncode(characterProfileAiSchema)}. Fülle jedes passende Feld konkret, knapp und prüfbar.'
            : 'Persona profile: Add these fields to every persona object: ${jsonEncode(characterProfileAiSchema)}. Fill every useful field concretely, briefly, and reviewably.',
      if (task == AITaskKind.worldContextStarter)
        german
            ? 'Kontext-Starthilfe: Beginne mit einem JSON-Block {"worldStarter":{"personas":[{"name":"","summary":"","background":"","goal":"","conflict":""}],"relationships":[{"sourceName":"","targetName":"","type":"","label":"","description":"","strength":0.7}],"locations":[{"name":"","summary":"","description":"","rules":""}],"drivers":[{"name":"","goal":"","conflict":"","stakes":""}],"events":[{"name":"","time":"","summary":"","goal":"","conflict":"","consequence":""}]}}. Erzeuge genau 10 Personas plus passende Beziehungen, Orte, Ziele/Konflikte und historische Ereignisse. Jeder Eintrag soll als Vorschlag prüfbar sein. Schreibe keine Manuskriptprosa.'
            : 'World starter: Start with a JSON block {"worldStarter":{"personas":[{"name":"","summary":"","background":"","goal":"","conflict":""}],"relationships":[{"sourceName":"","targetName":"","type":"","label":"","description":"","strength":0.7}],"locations":[{"name":"","summary":"","description":"","rules":""}],"drivers":[{"name":"","goal":"","conflict":"","stakes":""}],"events":[{"name":"","time":"","summary":"","goal":"","conflict":"","consequence":""}]}}. Create exactly 10 personas plus fitting relationships, locations, goals/conflicts, and historical events. Each item must be reviewable as a suggestion. Do not write manuscript prose.',
      if (task == AITaskKind.worldContextStarter)
        german
            ? 'Format: Gib zuerst das JSON-Objekt aus. Danach höchstens eine sehr kurze Notiz. Keine Markdown-Tabelle, keine Manuskriptprosa.'
            : 'Format: Return the JSON object first. After it, add at most one very short note. No markdown table, no manuscript prose.'
      else
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
    List<CatalogItem> contextCatalogItems = const [],
    List<Relationship> contextRelationships = const [],
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
      _fineGrainedContextBlock(
        catalogItems: contextCatalogItems,
        relationships: contextRelationships,
        scenes: [scene],
        german: german,
      ),
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
      AITaskKind.worldContextStarter => german
          ? 'Erzeuge prüfbare Bausteine für Kontext, Welt, Vorgeschichte, Regeln, Personen, Orte, Beziehungen, Ziele, Konflikte und historische Ereignisse.'
          : 'Create reviewable building blocks for context, world, backstory, rules, personas, locations, relationships, goals, conflicts, and historical events.',
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

String _fineGrainedContextBlock({
  required List<CatalogItem> catalogItems,
  required List<Relationship> relationships,
  required List<Scene> scenes,
  required bool german,
}) {
  final relevantItems = catalogItems
      .where((item) =>
          item.type == EntityType.character ||
          item.type == EntityType.location ||
          item.type == EntityType.object)
      .take(18)
      .toList();
  final relevantRelationships = relationships.take(18).toList();
  if (relevantItems.isEmpty && relevantRelationships.isEmpty) return '';

  final itemById = {
    for (final item in relevantItems) item.id: item,
  };
  final sceneById = {
    for (final scene in scenes) scene.id: scene,
  };
  final lines = <String>[
    german
        ? 'ZusÃ¤tzlich ausgewÃ¤hlter Kontext:'
        : 'Additional selected context:',
  ];
  if (relevantItems.isNotEmpty) {
    lines.add(german ? 'EntitÃ¤ten:' : 'Entities:');
    for (final item in relevantItems) {
      final type = _catalogTypeLabel(item.type, german: german);
      final summary = _trimForPrompt(item.summary, maxLength: 240);
      final details = _catalogFieldSummary(item, german: german);
      lines.add(
        '- $type: ${item.name}'
        '${summary.isEmpty ? '' : ' - $summary'}'
        '${details.isEmpty ? '' : ' ($details)'}',
      );
    }
  }
  if (relevantRelationships.isNotEmpty) {
    lines.add(german ? 'Beziehungen:' : 'Relationships:');
    for (final relationship in relevantRelationships) {
      final source = _entityPromptLabel(
        relationship.source,
        itemById: itemById,
        sceneById: sceneById,
        german: german,
      );
      final target = _entityPromptLabel(
        relationship.target,
        itemById: itemById,
        sceneById: sceneById,
        german: german,
      );
      final label = relationship.label?.trim().isNotEmpty == true
          ? relationship.label!.trim()
          : relationship.relationshipType;
      final description = _trimForPrompt(
        relationship.description ?? '',
        maxLength: 220,
      );
      final direction = relationship.direction == RelationshipDirection.directed
          ? '->'
          : '<->';
      final strength = relationship.strength == null
          ? ''
          : german
              ? ', StÃ¤rke ${relationship.strength!.toStringAsFixed(1)}'
              : ', strength ${relationship.strength!.toStringAsFixed(1)}';
      lines.add(
        '- $source $direction $target: $label'
        '$strength${description.isEmpty ? '' : ' - $description'}',
      );
    }
  }
  return lines.join('\n');
}

String _catalogTypeLabel(EntityType type, {required bool german}) {
  return switch (type) {
    EntityType.character => german ? 'Figur' : 'Character',
    EntityType.location => german ? 'Ort' : 'Location',
    EntityType.object => german ? 'Objekt' : 'Object',
    _ => type.wireName,
  };
}

String _catalogFieldSummary(CatalogItem item, {required bool german}) {
  final entries = item.fields.entries
      .where(
          (entry) => entry.value != null && '${entry.value}'.trim().isNotEmpty)
      .take(3)
      .map((entry) =>
          '${entry.key}: ${_trimForPrompt('${entry.value}', maxLength: 80)}')
      .toList();
  return entries.join(german ? '; ' : '; ');
}

String _entityPromptLabel(
  EntityRef ref, {
  required Map<String, CatalogItem> itemById,
  required Map<String, Scene> sceneById,
  required bool german,
}) {
  if (ref.type == EntityType.scene) {
    return sceneById[ref.id]?.title ??
        (german ? 'Szene ${ref.id}' : 'Scene ${ref.id}');
  }
  final item = itemById[ref.id];
  if (item != null) {
    return '${_catalogTypeLabel(item.type, german: german)} ${item.name}';
  }
  return '${ref.type.wireName} ${ref.id}';
}

String _trimForPrompt(String value, {required int maxLength}) {
  final trimmed = value.trim().replaceAll(RegExp(r'\s+'), ' ');
  if (trimmed.length <= maxLength) return trimmed;
  return '${trimmed.substring(0, maxLength)}...';
}
