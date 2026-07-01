part of '../main.dart';

// Presentation labels, formatting helpers, counters, and small UI-domain adapters.

const _estimatedWordsPerPage = 250;

int _wordTargetToPageTarget(int words) {
  if (words <= 0) return 0;
  return math.max(1, (words / _estimatedWordsPerPage).round());
}

String? _convertedProjectTargetText(
  String source, {
  required _ProjectTargetUnit from,
  required _ProjectTargetUnit to,
}) {
  final value = int.tryParse(source.trim());
  if (value == null || from == to) return null;
  final converted = switch ((from, to)) {
    (_ProjectTargetUnit.words, _ProjectTargetUnit.pages) =>
      _wordTargetToPageTarget(value),
    (_ProjectTargetUnit.pages, _ProjectTargetUnit.words) =>
      value * _estimatedWordsPerPage,
    _ => value,
  };
  return '$converted';
}

final class _ProjectTypeOption {
  const _ProjectTypeOption({
    required this.value,
    required this.labelKey,
  });

  final String value;
  final String labelKey;
}

const _projectTypeOptions = [
  _ProjectTypeOption(value: 'novel', labelKey: 'projectTypeNovel'),
  _ProjectTypeOption(value: 'shortStory', labelKey: 'projectTypeShortStory'),
  _ProjectTypeOption(value: 'novella', labelKey: 'projectTypeNovella'),
  _ProjectTypeOption(value: 'series', labelKey: 'projectTypeSeries'),
  _ProjectTypeOption(value: 'nonfiction', labelKey: 'projectTypeNonfiction'),
  _ProjectTypeOption(value: 'research', labelKey: 'projectTypeResearch'),
  _ProjectTypeOption(value: 'article', labelKey: 'projectTypeArticle'),
  _ProjectTypeOption(value: 'essay', labelKey: 'projectTypeEssay'),
  _ProjectTypeOption(value: 'thesis', labelKey: 'projectTypeThesis'),
  _ProjectTypeOption(value: 'screenplay', labelKey: 'projectTypeScreenplay'),
  _ProjectTypeOption(value: 'stagePlay', labelKey: 'projectTypeStagePlay'),
  _ProjectTypeOption(value: 'poetry', labelKey: 'projectTypePoetry'),
  _ProjectTypeOption(value: 'memoir', labelKey: 'projectTypeMemoir'),
  _ProjectTypeOption(
    value: 'worldbuilding',
    labelKey: 'projectTypeWorldbuilding',
  ),
  _ProjectTypeOption(value: 'other', labelKey: 'projectTypeOther'),
];

String _projectTypeLabel(String projectType, WritellerCopy copy) {
  final option = _projectTypeOptions
      .where((candidate) => candidate.value == projectType)
      .firstOrNull;
  return option == null ? projectType : copy.t(option.labelKey);
}

String _projectTargetProgressLabel(
  Project? project,
  int words,
  WritellerCopy copy,
) {
  final wordTarget = project?.wordTarget;
  if (project == null || wordTarget == null || wordTarget <= 0) {
    return '$words ${copy.t('words')}';
  }
  if (project.metadata['targetUnit'] == 'pages') {
    final wordsPerPage = _metadataInt(project.metadata['wordsPerPageEstimate'])
            ?.clamp(1, 1000) ??
        _estimatedWordsPerPage;
    final targetPages = _metadataInt(project.metadata['pageTarget']) ??
        (wordTarget / wordsPerPage).round();
    final currentPages = words <= 0 ? 0 : (words / wordsPerPage).ceil();
    return '$currentPages / $targetPages ${copy.t('pages')} '
        '($wordTarget ${copy.t('words')})';
  }
  return '$words / $wordTarget ${copy.t('words')}';
}

int? _metadataInt(Object? value) {
  return switch (value) {
    int() => value,
    double() => value.round(),
    String() => int.tryParse(value),
    _ => null,
  };
}

String _catalogTitleKey(EntityType type) {
  return switch (type) {
    EntityType.character => 'characters',
    EntityType.location => 'locations',
    EntityType.object => 'objects',
    _ => 'catalog',
  };
}

String _newCatalogKey(EntityType type) {
  return switch (type) {
    EntityType.character => 'newCharacter',
    EntityType.location => 'newLocation',
    EntityType.object => 'newObject',
    _ => 'newCatalogItem',
  };
}

String _untitledCatalogKey(EntityType type) {
  return switch (type) {
    EntityType.character => 'untitledCharacter',
    EntityType.location => 'untitledLocation',
    EntityType.object => 'untitledObject',
    _ => 'untitledCatalogItem',
  };
}

String _emptyCatalogTitleKey(EntityType type) {
  return switch (type) {
    EntityType.character => 'noCharactersTitle',
    EntityType.location => 'noLocationsTitle',
    EntityType.object => 'noObjectsTitle',
    _ => 'noCatalogItemsTitle',
  };
}

IconData _catalogIcon(EntityType type) {
  return switch (type) {
    EntityType.character => Icons.person_outline,
    EntityType.location => Icons.place_outlined,
    EntityType.timelineEvent => Icons.event_note_outlined,
    EntityType.object => Icons.category_outlined,
    _ => Icons.label_outline,
  };
}

String _characterProfileFieldLabel(String key, WritellerCopy copy) {
  return switch (key) {
    'roleFunction' => copy.t('characterRoleFunction'),
    'age' => copy.t('characterAge'),
    'appearance' => copy.t('characterAppearance'),
    'personality' => copy.t('characterPersonality'),
    'motivation' => copy.t('characterMotivation'),
    'fear' => copy.t('characterFear'),
    'secret' => copy.t('characterSecret'),
    'background' => copy.t('characterBackground'),
    'goal' => copy.t('characterGoal'),
    'conflict' => copy.t('characterConflict'),
    'arc' => copy.t('characterArc'),
    'voice' => copy.t('characterVoice'),
    'relationshipNotes' => copy.t('characterRelationshipNotes'),
    _ => key,
  };
}

String _fieldText(Map<String, Object?> fields, String key) {
  final value = fields[key];
  if (value == null) return '';
  return value.toString().trim();
}

Map<String, Object?> _mergedCharacterProfileFields({
  required Map<String, Object?> existing,
  required Map<String, String> profileValues,
}) {
  return {
    ...existing,
    for (final entry in profileValues.entries)
      if (entry.value.trim().isNotEmpty) entry.key: entry.value.trim(),
    for (final entry in profileValues.entries)
      if (entry.value.trim().isEmpty) entry.key: null,
  }..removeWhere((key, value) => value == null);
}

List<MapEntry<String, String>> _characterProfileEntries(
  CatalogItem item,
  WritellerCopy copy,
) {
  if (item.type != EntityType.character) return const [];
  return [
    for (final key in characterProfileFieldKeys)
      if (_fieldText(item.fields, key).isNotEmpty)
        MapEntry(_characterProfileFieldLabel(key, copy),
            _fieldText(item.fields, key)),
  ];
}

String _catalogItemTooltipText(CatalogItem item, WritellerCopy copy) {
  final lines = <String>[
    '${_entityTypeLabel(item.type, copy)}: ${item.name}',
    if (item.summary.trim().isNotEmpty)
      '${copy.t('summary')}: ${item.summary.trim()}',
    for (final entry in _characterProfileEntries(item, copy))
      '${entry.key}: ${entry.value}',
  ];
  return lines.join('\n');
}

final class _TooltipText extends StatelessWidget {
  const _TooltipText(
    this.text, {
    this.maxLines = 1,
    this.style,
  });

  final String text;
  final int? maxLines;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: text,
      waitDuration: const Duration(milliseconds: 350),
      child: Text(
        text,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        style: style,
      ),
    );
  }
}

extension _TooltipWidgetExtension on Widget {
  Widget withTooltip(String message) {
    if (message.trim().isEmpty) return this;
    return Tooltip(
      message: message,
      waitDuration: const Duration(milliseconds: 350),
      child: this,
    );
  }
}

int _countWords(String text) {
  final trimmed = text.trim();
  if (trimmed.isEmpty) return 0;
  return trimmed.split(RegExp(r'\s+')).length;
}

int _countMatches(String text, String query) {
  if (query.isEmpty) return 0;
  final pattern = RegExp(RegExp.escape(query), caseSensitive: false);
  return pattern.allMatches(text).length;
}

({int start, int end})? _nextMatchRange({
  required String text,
  required String query,
  required int from,
}) {
  if (query.isEmpty || text.isEmpty) return null;
  final normalizedText = text.toLowerCase();
  final normalizedQuery = query.toLowerCase();
  final safeStart = from.clamp(0, text.length);
  var index = normalizedText.indexOf(normalizedQuery, safeStart);
  if (index == -1 && safeStart > 0) {
    index = normalizedText.indexOf(normalizedQuery);
  }
  if (index == -1) return null;
  return (start: index, end: index + query.length);
}

String _providerKindLabel(AIProviderKind kind, String languageCode) {
  final german = languageCode == 'de';
  return switch (kind) {
    AIProviderKind.openAICompatible =>
      german ? 'OpenAI-kompatibel' : 'OpenAI-compatible',
    AIProviderKind.anthropic => 'Anthropic',
    AIProviderKind.gemini => 'Gemini',
    AIProviderKind.openRouter => 'OpenRouter',
    AIProviderKind.ollama => 'Ollama',
    AIProviderKind.mock => german ? 'Mock / lokal' : 'Mock / local',
  };
}

String _designThemeLabel(WritellerDesignTheme theme, WritellerCopy copy) {
  return switch (theme) {
    WritellerDesignTheme.system => copy.t('designThemeSystem'),
    WritellerDesignTheme.paper => copy.t('designThemePaper'),
    WritellerDesignTheme.dusk => copy.t('designThemeDusk'),
    WritellerDesignTheme.sapphire => copy.t('designThemeSapphire'),
    WritellerDesignTheme.sage => copy.t('designThemeSage'),
    WritellerDesignTheme.copper => copy.t('designThemeCopper'),
    WritellerDesignTheme.ink => copy.t('designThemeInk'),
  };
}

String _aiTaskLabel(String taskName, WritellerCopy copy) {
  if (taskName.startsWith('worldContextStarter')) {
    return copy.t('aiTaskWorldContextStarter');
  }
  final task = AITaskKind.values
      .where((candidate) => candidate.name == taskName)
      .firstOrNull;
  if (task == null) return taskName;
  return switch (task) {
    AITaskKind.customScenePrompt => copy.t('aiTaskCustomScenePrompt'),
    AITaskKind.sceneIdeas => copy.t('requestSceneIdeas'),
    AITaskKind.sceneGoalConflictOutcome => copy.t('requestStructure'),
    AITaskKind.characterProfile => copy.t('aiTaskCharacterProfile'),
    AITaskKind.consistencyCheck => copy.t('aiTaskConsistencyCheck'),
    AITaskKind.timelineCheck => copy.t('aiTaskTimelineCheck'),
    AITaskKind.storylineVariants => copy.t('aiTaskStorylineVariants'),
    AITaskKind.blurbVariants => copy.t('aiTaskBlurbVariants'),
    AITaskKind.styleAnalysis => copy.t('aiTaskStyleAnalysis'),
    AITaskKind.authorQuestions => copy.t('aiTaskAuthorQuestions'),
    AITaskKind.researchStructuring => copy.t('aiTaskResearchStructuring'),
    AITaskKind.plotGapReview => copy.t('aiTaskPlotGapReview'),
    AITaskKind.dialogueIntentAnalysis => copy.t('aiTaskDialogueIntentAnalysis'),
    AITaskKind.worldContextStarter => copy.t('aiTaskWorldContextStarter'),
  };
}

String _decisionLabel(SuggestionDecision decision, WritellerCopy copy) {
  return switch (decision) {
    SuggestionDecision.pending => copy.t('suggestionPending'),
    SuggestionDecision.accepted => copy.t('suggestionAccepted'),
    SuggestionDecision.rejected => copy.t('suggestionRejected'),
    SuggestionDecision.convertedToNote => copy.t('suggestionConverted'),
  };
}

String _suggestionDecisionFeedback(
  SuggestionDecision decision,
  WritellerCopy copy, {
  bool applied = false,
}) {
  return switch (decision) {
    SuggestionDecision.pending => copy.t('suggestionPending'),
    SuggestionDecision.accepted => applied
        ? copy.t('suggestionAppliedFeedback')
        : copy.t('suggestionAcceptedNoPatchFeedback'),
    SuggestionDecision.rejected => copy.t('suggestionDeletedFeedback'),
    SuggestionDecision.convertedToNote => copy.t('suggestionConvertedFeedback'),
  };
}

String _planningFieldLabel(String fieldKey, WritellerCopy copy) {
  return switch (fieldKey) {
    'summary' => copy.t('summary'),
    'goal' => copy.t('goal'),
    'conflict' => copy.t('conflict'),
    'outcome' => copy.t('outcome'),
    _ => fieldKey,
  };
}

String? _noteTargetLabel(ProjectNote note, List<Scene> scenes) {
  final target = note.target;
  if (target?.type == EntityType.scene) {
    final targetId = target?.id;
    final scene = scenes.where((scene) => scene.id == targetId).firstOrNull;
    return scene?.title;
  }
  return target?.id;
}

String _targetValueFor(EntityRef? target) {
  if (target == null) return 'project';
  return '${target.type.wireName}:${target.id}';
}

EntityRef? _targetFromValue(String value) {
  if (value == 'project') return null;
  final separator = value.indexOf(':');
  if (separator <= 0 || separator == value.length - 1) return null;
  return EntityRef(
    type: EntityTypeWire.parse(value.substring(0, separator)),
    id: value.substring(separator + 1),
  );
}

String _noteTargetDisplay(
  EntityRef? target,
  List<Scene> scenes,
  List<CatalogItem> catalogItems,
) {
  if (target == null) return 'Projekt';
  if (target.type == EntityType.scene) {
    final scene = scenes.where((scene) => scene.id == target.id).firstOrNull;
    return scene == null ? target.id : scene.title;
  }
  final item = catalogItems
      .where((item) => item.type == target.type && item.id == target.id)
      .firstOrNull;
  return item == null ? target.id : item.name;
}

String _entityTypeLabel(EntityType type, WritellerCopy copy) {
  return switch (type) {
    EntityType.project => copy.t('project'),
    EntityType.chapter => copy.t('chapter'),
    EntityType.scene => copy.t('scene'),
    EntityType.character => copy.t('character'),
    EntityType.location => copy.t('location'),
    EntityType.object => copy.t('object'),
    EntityType.timelineEvent => copy.t('timelineEvent'),
    _ => type.wireName,
  };
}

String _projectContextText(Project? project) {
  return project?.metadata['storyContext'] as String? ?? '';
}

bool _isWorldStarterSuggestion(AISuggestion suggestion) {
  return suggestion.suggestionType.startsWith('worldContextStarter');
}

String _worldSuggestionKind(AISuggestion suggestion) {
  final item = _worldSuggestionItem(suggestion);
  return item['kind'] as String? ?? 'unknown';
}

Map<String, Object?> _worldSuggestionItem(AISuggestion suggestion) {
  final raw = suggestion.structuredResponse?['worldStarterItem'];
  if (raw is Map) return Map<String, Object?>.from(raw);
  return const {};
}

String _worldSuggestionTitle(AISuggestion suggestion, WritellerCopy copy) {
  final item = _worldSuggestionItem(suggestion);
  final name = item['name'] as String? ??
      item['label'] as String? ??
      item['type'] as String? ??
      copy.t('untitledCatalogItem');
  return name;
}

String _worldSuggestionBody(AISuggestion suggestion) {
  final item = _worldSuggestionItem(suggestion);
  final fields = [
    item['summary'],
    item['roleFunction'],
    item['age'],
    item['appearance'],
    item['personality'],
    item['motivation'],
    item['fear'],
    item['secret'],
    item['background'],
    item['description'],
    item['goal'],
    item['conflict'],
    item['arc'],
    item['voice'],
    item['relationshipNotes'],
    item['consequence'],
    item['stakes'],
  ].whereType<String>().where((value) => value.trim().isNotEmpty).toList();
  return fields.isEmpty ? suggestion.responseText : fields.join('\n');
}

String _worldSuggestionKindLabel(String kind, WritellerCopy copy) {
  return switch (kind) {
    'persona' => copy.t('worldSuggestionPersona'),
    'relationship' => copy.t('worldSuggestionRelationship'),
    'location' => copy.t('worldSuggestionLocation'),
    'driver' => copy.t('worldSuggestionDriver'),
    'event' => copy.t('worldSuggestionEvent'),
    _ => copy.t('suggestions'),
  };
}

IconData _worldSuggestionKindIcon(String kind) {
  return switch (kind) {
    'persona' => Icons.person_outline,
    'relationship' => Icons.hub_outlined,
    'location' => Icons.place_outlined,
    'driver' => Icons.flag_outlined,
    'event' => Icons.event_note_outlined,
    _ => Icons.lightbulb_outline,
  };
}

String _noteFilterLabel(_NoteFilter filter, WritellerCopy copy) {
  return switch (filter) {
    _NoteFilter.all => copy.t('allNotes'),
    _NoteFilter.project => copy.t('projectNotes'),
    _NoteFilter.scene => copy.t('sceneNotes'),
    _NoteFilter.catalog => copy.t('catalogNotes'),
    _NoteFilter.manual => copy.t('manualNotes'),
    _NoteFilter.ai => copy.t('aiNotes'),
  };
}

IconData _noteFilterIcon(_NoteFilter filter) {
  return switch (filter) {
    _NoteFilter.all => Icons.notes_outlined,
    _NoteFilter.project => Icons.library_books_outlined,
    _NoteFilter.scene => Icons.edit_note_outlined,
    _NoteFilter.catalog => Icons.category_outlined,
    _NoteFilter.manual => Icons.edit_outlined,
    _NoteFilter.ai => Icons.psychology_alt_outlined,
  };
}

List<String> _missingScenePlanningLabels(Scene scene, WritellerCopy copy) {
  return [
    if (scene.summary.trim().isEmpty) copy.t('summary'),
    if (scene.goal?.trim().isEmpty != false) copy.t('goal'),
    if (scene.conflict?.trim().isEmpty != false) copy.t('conflict'),
    if (scene.outcome?.trim().isEmpty != false) copy.t('outcome'),
  ];
}

double _scenePlanningProgress(Scene scene) {
  var complete = 0;
  if (scene.summary.trim().isNotEmpty) complete += 1;
  if (scene.goal?.trim().isEmpty == false) complete += 1;
  if (scene.conflict?.trim().isEmpty == false) complete += 1;
  if (scene.outcome?.trim().isEmpty == false) complete += 1;
  return complete / 4;
}

String _formatLocalDateTime(DateTime value) {
  final local = value.toLocal();
  String twoDigits(int value) => value.toString().padLeft(2, '0');
  return '${twoDigits(local.day)}.${twoDigits(local.month)}.${local.year} '
      '${twoDigits(local.hour)}:${twoDigits(local.minute)}';
}

String _formatLocalDate(DateTime value) {
  final local = value.toLocal();
  String twoDigits(int value) => value.toString().padLeft(2, '0');
  return '${twoDigits(local.day)}.${twoDigits(local.month)}.${local.year}';
}

String _exportFormatLabel(ExportFormat format, String languageCode) {
  final german = languageCode == 'de';
  return switch (format) {
    ExportFormat.markdown => 'Markdown',
    ExportFormat.html => 'HTML',
    ExportFormat.plainText => german ? 'TXT / Manuskript' : 'TXT / manuscript',
    ExportFormat.outline =>
      german ? 'Outline / Struktur' : 'Outline / structure',
    ExportFormat.json =>
      german ? 'Writeller-Archiv JSON' : 'Writeller archive JSON',
    ExportFormat.yWriter => 'yWriter (.yw7)',
    ExportFormat.scrivener => 'Scrivener (.scrivx)',
    ExportFormat.pdf => 'PDF',
    ExportFormat.epub => 'EPUB',
    ExportFormat.docx => 'Word (.docx)',
  };
}

String _publishingStyleLabel(PublishingStyle style, String languageCode) {
  final german = languageCode == 'de';
  return switch (style) {
    PublishingStyle.manuscript =>
      german ? 'Manuskript / Lektorat' : 'Manuscript / editing',
    PublishingStyle.paperback =>
      german ? 'Taschenbuchsatz' : 'Paperback layout',
    PublishingStyle.ebook => german ? 'E-Book' : 'E-book',
    PublishingStyle.largePrint => german ? 'Großdruck' : 'Large print',
  };
}

String _metricEventLabel(String eventType, String languageCode) {
  final german = languageCode == 'de';
  return switch (eventType) {
    'project.created' => german ? 'Projekt angelegt' : 'Project created',
    'project.imported' => german ? 'Projekt importiert' : 'Project imported',
    'chapter.created' => german ? 'Kapitel angelegt' : 'Chapter created',
    'chapter.deleted' => german ? 'Kapitel gelöscht' : 'Chapter deleted',
    'scene.created' => german ? 'Szene angelegt' : 'Scene created',
    'scene.saved' => german ? 'Szene gespeichert' : 'Scene saved',
    'scene.deleted' => german ? 'Szene gelöscht' : 'Scene deleted',
    'scene.reordered' => german ? 'Szene sortiert' : 'Scene reordered',
    'scene.moved' => german ? 'Szene verschoben' : 'Scene moved',
    'catalog.created' =>
      german ? 'Katalogeintrag angelegt' : 'Catalog item created',
    'catalog.updated' =>
      german ? 'Katalogeintrag gespeichert' : 'Catalog item saved',
    'catalog.deleted' =>
      german ? 'Katalogeintrag gelöscht' : 'Catalog item deleted',
    'relationship.linked' => german ? 'Kontext verknüpft' : 'Context linked',
    'relationship.unlinked' => german ? 'Kontext gelöst' : 'Context unlinked',
    'relationship.saved' =>
      german ? 'Beziehung gespeichert' : 'Relationship saved',
    'relationship.deleted' =>
      german ? 'Beziehung gelöscht' : 'Relationship deleted',
    'ai.suggestion.created' =>
      german ? 'KI-Vorschlag erzeugt' : 'AI suggestion created',
    'export.copied' => german ? 'Export kopiert' : 'Export copied',
    'export.downloaded' =>
      german ? 'Export heruntergeladen' : 'Export downloaded',
    'sync.checkpoint.copied' =>
      german ? 'Sync-Checkpoint kopiert' : 'Sync checkpoint copied',
    'sync.checkpoint.imported' =>
      german ? 'Sync-Checkpoint importiert' : 'Sync checkpoint imported',
    _ => eventType,
  };
}

String _draftStatusLabel(DraftStatus status, String languageCode) {
  final german = languageCode == 'de';
  return switch (status) {
    DraftStatus.idea => german ? 'Idee' : 'Idea',
    DraftStatus.planned => german ? 'Geplant' : 'Planned',
    DraftStatus.outlined => german ? 'Strukturiert' : 'Outlined',
    DraftStatus.drafting => german ? 'Im Entwurf' : 'Drafting',
    DraftStatus.needsRevision => german ? 'Überarbeiten' : 'Needs revision',
    DraftStatus.revised => german ? 'Überarbeitet' : 'Revised',
    DraftStatus.reviewed => german ? 'Geprüft' : 'Reviewed',
    DraftStatus.locked => german ? 'Gesperrt' : 'Locked',
    DraftStatus.archived => german ? 'Archiviert' : 'Archived',
  };
}
