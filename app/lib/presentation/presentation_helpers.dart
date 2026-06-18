part of '../main.dart';

// Presentation labels, formatting helpers, counters, and small UI-domain adapters.

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
    EntityType.object => Icons.category_outlined,
    _ => Icons.label_outline,
  };
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

String _designThemeLabel(WritelerDesignTheme theme, WritelerCopy copy) {
  return switch (theme) {
    WritelerDesignTheme.paper => copy.t('designThemePaper'),
    WritelerDesignTheme.dusk => copy.t('designThemeDusk'),
    WritelerDesignTheme.sapphire => copy.t('designThemeSapphire'),
    WritelerDesignTheme.sage => copy.t('designThemeSage'),
    WritelerDesignTheme.copper => copy.t('designThemeCopper'),
    WritelerDesignTheme.ink => copy.t('designThemeInk'),
  };
}

String _aiTaskLabel(String taskName, WritelerCopy copy) {
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
  };
}

String _decisionLabel(SuggestionDecision decision, WritelerCopy copy) {
  return switch (decision) {
    SuggestionDecision.pending => copy.t('suggestionPending'),
    SuggestionDecision.accepted => copy.t('suggestionAccepted'),
    SuggestionDecision.rejected => copy.t('suggestionRejected'),
    SuggestionDecision.convertedToNote => copy.t('suggestionConverted'),
  };
}

String _suggestionDecisionFeedback(
  SuggestionDecision decision,
  WritelerCopy copy, {
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

String _planningFieldLabel(String fieldKey, WritelerCopy copy) {
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

String _entityTypeLabel(EntityType type, WritelerCopy copy) {
  return switch (type) {
    EntityType.project => copy.t('project'),
    EntityType.chapter => copy.t('chapter'),
    EntityType.scene => copy.t('scene'),
    EntityType.character => copy.t('character'),
    EntityType.location => copy.t('location'),
    EntityType.object => copy.t('object'),
    _ => type.wireName,
  };
}

String _noteFilterLabel(_NoteFilter filter, WritelerCopy copy) {
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

List<String> _missingScenePlanningLabels(Scene scene, WritelerCopy copy) {
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
      german ? 'Writeler-Archiv JSON' : 'Writeler archive JSON',
    ExportFormat.pdf => 'PDF',
    ExportFormat.epub => 'EPUB',
    ExportFormat.docx => 'DOCX',
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
    DraftStatus.needsRevision => german ? 'Ueberarbeiten' : 'Needs revision',
    DraftStatus.revised => german ? 'Ueberarbeitet' : 'Revised',
    DraftStatus.reviewed => german ? 'Geprueft' : 'Reviewed',
    DraftStatus.locked => german ? 'Gesperrt' : 'Locked',
    DraftStatus.archived => german ? 'Archiviert' : 'Archived',
  };
}
