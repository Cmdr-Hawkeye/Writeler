part of '../main.dart';

// Stateful application shell: orchestration, repositories, commands, and workspace routing.

final class _OpenCommandPaletteIntent extends Intent {
  const _OpenCommandPaletteIntent();
}

final class _CommandPaletteEntry {
  const _CommandPaletteEntry({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.run,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback run;
}

final class _CommandPaletteDialog extends StatefulWidget {
  const _CommandPaletteDialog({
    required this.copy,
    required this.entries,
  });

  final WritellerCopy copy;
  final List<_CommandPaletteEntry> entries;

  @override
  State<_CommandPaletteDialog> createState() => _CommandPaletteDialogState();
}

final class _CommandPaletteDialogState extends State<_CommandPaletteDialog> {
  late final TextEditingController _queryController = TextEditingController();

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final query = _queryController.text.trim().toLowerCase();
    final entries = query.isEmpty
        ? widget.entries
        : widget.entries
            .where(
              (entry) =>
                  entry.title.toLowerCase().contains(query) ||
                  entry.subtitle.toLowerCase().contains(query),
            )
            .toList();

    return Dialog(
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640, maxHeight: 560),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
              child: TextField(
                controller: _queryController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: widget.copy.t('searchCommands'),
                  prefixIcon: const Icon(Icons.manage_search_outlined),
                  border: const OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.search,
                onChanged: (_) => setState(() {}),
                onSubmitted: (_) {
                  if (entries.isNotEmpty) {
                    Navigator.of(context).pop(entries.first);
                  }
                },
              ),
            ),
            Flexible(
              child: entries.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Text(
                          widget.copy.t('noCommandMatches'),
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: color.onSurfaceVariant),
                        ),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                      itemCount: entries.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final entry = entries[index];
                        return ListTile(
                          leading: Icon(entry.icon),
                          title: Text(entry.title),
                          subtitle: Text(entry.subtitle),
                          onTap: () => Navigator.of(context).pop(entry),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

final class WritellerShell extends StatefulWidget {
  const WritellerShell({
    required this.projectRepository,
    required this.sceneRepository,
    required this.sceneSnapshotRepository,
    required this.chapterRepository,
    required this.catalogItemRepository,
    required this.relationshipRepository,
    required this.metricRepository,
    required this.aiSuggestionRepository,
    required this.projectNoteRepository,
    required this.researchItemRepository,
    required this.aiProviderConfigRepository,
    required this.secretVault,
    required this.designTheme,
    required this.onDesignThemeChanged,
    required this.languageCode,
    required this.onLanguageChanged,
    required this.globalAiEnabled,
    required this.globalCloudSyncEnabled,
    required this.globalNoAiNoCloud,
    required this.onGlobalProfileSettingsChanged,
    required this.spellCheckSettings,
    required this.spellChecker,
    required this.onSpellCheckSettingsChanged,
    super.key,
  });

  final ProjectRepository projectRepository;
  final SceneRepository sceneRepository;
  final SceneSnapshotRepository sceneSnapshotRepository;
  final ChapterRepository chapterRepository;
  final CatalogItemRepository catalogItemRepository;
  final RelationshipRepository relationshipRepository;
  final MetricRepository metricRepository;
  final AISuggestionRepository aiSuggestionRepository;
  final ProjectNoteRepository projectNoteRepository;
  final ResearchItemRepository researchItemRepository;
  final AIProviderConfigRepository aiProviderConfigRepository;
  final SecretVault secretVault;
  final WritellerDesignTheme designTheme;
  final ValueChanged<WritellerDesignTheme> onDesignThemeChanged;
  final String languageCode;
  final ValueChanged<String> onLanguageChanged;
  final bool globalAiEnabled;
  final bool globalCloudSyncEnabled;
  final bool globalNoAiNoCloud;
  final SpellCheckSettings spellCheckSettings;
  final SpellChecker spellChecker;
  final FutureOr<void> Function({
    required bool aiEnabled,
    required bool cloudSyncEnabled,
    required bool noAiNoCloud,
  }) onGlobalProfileSettingsChanged;
  final ValueChanged<SpellCheckSettings> onSpellCheckSettingsChanged;

  @override
  State<WritellerShell> createState() => _WritellerShellState();
}

final class _WritellerShellState extends State<WritellerShell> {
  late final CreateProject _createProject =
      CreateProject(widget.projectRepository);
  late final CreateChapter _createChapter =
      CreateChapter(widget.chapterRepository);
  late final CreateScene _createScene = CreateScene(widget.sceneRepository);
  late final CreateCatalogItem _createCatalogItem =
      CreateCatalogItem(widget.catalogItemRepository);
  late final RecordMetric _recordMetric = RecordMetric(widget.metricRepository);
  late final ProjectExporter _projectExporter = const ProjectExporter();
  late final ProjectArchiveCodec _archiveCodec = const ProjectArchiveCodec();
  late final ManualSyncAdapter _syncAdapter = const ManualSyncAdapter();
  late final ProjectImporter _projectImporter = ProjectImporter(
    archiveCodec: _archiveCodec,
    syncAdapter: _syncAdapter,
  );
  late final _AIProviderRuntime _aiProviderRuntime = _AIProviderRuntime(
    configRepository: widget.aiProviderConfigRepository,
    secretVault: widget.secretVault,
    transport: const HttpModelHttpTransport(),
  );
  late final TextEditingController _manuscriptController =
      TextEditingController();
  late final TextEditingController _summaryController = TextEditingController();
  late final TextEditingController _goalController = TextEditingController();
  late final TextEditingController _conflictController =
      TextEditingController();
  late final TextEditingController _outcomeController = TextEditingController();
  late final TextEditingController _wordTargetController =
      TextEditingController();
  late final TextEditingController _aiPromptController =
      TextEditingController();
  late final TextEditingController _providerNameController =
      TextEditingController(text: 'MockProvider');
  late final TextEditingController _modelNameController =
      TextEditingController(text: 'mock-structure-v1');
  late final TextEditingController _baseUrlController = TextEditingController();
  late final TextEditingController _apiKeyRefController =
      TextEditingController();
  late final TextEditingController _importArchiveController =
      TextEditingController();

  List<Project> _projects = const [];
  List<Chapter> _chapters = const [];
  List<Scene> _scenes = const [];
  List<CatalogItem> _catalogItems = const [];
  List<Relationship> _relationships = const [];
  List<MetricEvent> _metrics = const [];
  List<AISuggestion> _suggestions = const [];
  List<ProjectNote> _notes = const [];
  List<ResearchItem> _researchItems = const [];
  List<SceneSnapshot> _sceneSnapshots = const [];
  Project? _selectedProject;
  Scene? _selectedScene;
  String? _selectedSceneChapterId;
  DraftStatus _selectedSceneStatus = DraftStatus.planned;
  int _selectedRailIndex = 1;
  ExportFormat _selectedExportFormat = ExportFormat.json;
  ExportFormat _selectedPublishingFormat = ExportFormat.pdf;
  PublishingStyle _selectedPublishingStyle = PublishingStyle.manuscript;
  bool _includeSceneTitles = true;
  bool _includePublishingMetadata = false;
  bool _isRequestingAi = false;
  bool _navigationCollapsed = false;
  String? _lastAiError;
  ProjectArchivePreview? _importPreview;
  String? _importPreviewError;
  String? _importSourceName;
  SyncCheckpoint? _lastSyncCheckpoint;
  SyncEnvelopePreview? _syncImportPreview;
  ProjectImportInspection? _importInspection;
  bool _isImportDragging = false;
  AIProviderKind _selectedProviderKind = AIProviderKind.mock;
  AIProviderConfig? _activeProviderConfig;
  bool _providerEnabled = true;
  bool _providerHasStoredApiKey = false;
  Timer? _loadTimer;
  Timer? _autosaveTimer;
  bool _syncingSceneControllers = false;
  _SceneSaveState _sceneSaveState = _SceneSaveState.saved;
  DateTime? _lastSceneSavedAt;
  late final List<_WorkspaceNavItem> _navItems = [
    _WorkspaceNavItem(
      index: 0,
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard,
      labelBuilder: (copy) => copy.t('dashboard'),
      group: _WorkspaceNavGroup.write,
    ),
    _WorkspaceNavItem(
      index: 1,
      icon: Icons.edit_note_outlined,
      selectedIcon: Icons.edit_note,
      labelBuilder: (copy) => copy.t('editor'),
      group: _WorkspaceNavGroup.write,
    ),
    _WorkspaceNavItem(
      index: 2,
      icon: Icons.account_tree_outlined,
      selectedIcon: Icons.account_tree,
      labelBuilder: (copy) => copy.t('projectStructure'),
      group: _WorkspaceNavGroup.write,
    ),
    _WorkspaceNavItem(
      index: 13,
      icon: Icons.view_kanban_outlined,
      selectedIcon: Icons.view_kanban,
      labelBuilder: (copy) => copy.t('sceneBoard'),
      group: _WorkspaceNavGroup.write,
    ),
    _WorkspaceNavItem(
      index: 17,
      icon: Icons.polyline_outlined,
      selectedIcon: Icons.polyline,
      labelBuilder: (copy) => copy.t('storyboard'),
      group: _WorkspaceNavGroup.write,
    ),
    _WorkspaceNavItem(
      index: 20,
      icon: Icons.public_outlined,
      selectedIcon: Icons.public,
      labelBuilder: (copy) => copy.t('storyContext'),
      group: _WorkspaceNavGroup.world,
    ),
    _WorkspaceNavItem(
      index: 19,
      icon: Icons.travel_explore_outlined,
      selectedIcon: Icons.travel_explore,
      labelBuilder: (copy) => copy.t('researchLibrary'),
      group: _WorkspaceNavGroup.world,
    ),
    _WorkspaceNavItem(
      index: 3,
      icon: Icons.person_outline,
      selectedIcon: Icons.person,
      labelBuilder: (copy) => copy.t('characters'),
      group: _WorkspaceNavGroup.world,
    ),
    _WorkspaceNavItem(
      index: 4,
      icon: Icons.place_outlined,
      selectedIcon: Icons.place,
      labelBuilder: (copy) => copy.t('locations'),
      group: _WorkspaceNavGroup.world,
    ),
    _WorkspaceNavItem(
      index: 5,
      icon: Icons.category_outlined,
      selectedIcon: Icons.category,
      labelBuilder: (copy) => copy.t('objects'),
      group: _WorkspaceNavGroup.world,
    ),
    _WorkspaceNavItem(
      index: 14,
      icon: Icons.timeline_outlined,
      selectedIcon: Icons.timeline,
      labelBuilder: (copy) => copy.t('timeline'),
      group: _WorkspaceNavGroup.world,
    ),
    _WorkspaceNavItem(
      index: 15,
      icon: Icons.hub_outlined,
      selectedIcon: Icons.hub,
      labelBuilder: (copy) => copy.t('relationshipGraph'),
      group: _WorkspaceNavGroup.world,
    ),
    _WorkspaceNavItem(
      index: 6,
      icon: Icons.query_stats_outlined,
      selectedIcon: Icons.query_stats,
      labelBuilder: (copy) => copy.t('analysis'),
      group: _WorkspaceNavGroup.review,
    ),
    _WorkspaceNavItem(
      index: 18,
      icon: Icons.auto_graph_outlined,
      selectedIcon: Icons.auto_graph,
      labelBuilder: (copy) => copy.t('styleCockpit'),
      group: _WorkspaceNavGroup.review,
    ),
    _WorkspaceNavItem(
      index: 21,
      icon: Icons.collections_bookmark_outlined,
      selectedIcon: Icons.collections_bookmark,
      labelBuilder: (copy) => copy.t('smartCollections'),
      group: _WorkspaceNavGroup.review,
    ),
    _WorkspaceNavItem(
      index: 7,
      icon: Icons.sticky_note_2_outlined,
      selectedIcon: Icons.sticky_note_2,
      labelBuilder: (copy) => copy.t('notes'),
      group: _WorkspaceNavGroup.review,
    ),
    _WorkspaceNavItem(
      index: 8,
      icon: Icons.psychology_alt_outlined,
      selectedIcon: Icons.psychology_alt,
      labelBuilder: (copy) => copy.t('aiWorkshop'),
      group: _WorkspaceNavGroup.review,
    ),
    _WorkspaceNavItem(
      index: 11,
      icon: Icons.receipt_long_outlined,
      selectedIcon: Icons.receipt_long,
      labelBuilder: (copy) => copy.t('protocols'),
      group: _WorkspaceNavGroup.output,
    ),
    _WorkspaceNavItem(
      index: 9,
      icon: Icons.ios_share_outlined,
      selectedIcon: Icons.ios_share,
      labelBuilder: (copy) => copy.t('exports'),
      group: _WorkspaceNavGroup.output,
    ),
    _WorkspaceNavItem(
      index: 12,
      icon: Icons.auto_stories_outlined,
      selectedIcon: Icons.auto_stories,
      labelBuilder: (copy) => copy.t('selfPublishing'),
      group: _WorkspaceNavGroup.output,
    ),
    _WorkspaceNavItem(
      index: 10,
      icon: Icons.tune_outlined,
      selectedIcon: Icons.tune,
      labelBuilder: (copy) => copy.t('settings'),
      group: _WorkspaceNavGroup.output,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _addSceneDraftListeners();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTimer = Timer(const Duration(milliseconds: 250), _loadProjects);
    });
  }

  @override
  void dispose() {
    _loadTimer?.cancel();
    _autosaveTimer?.cancel();
    _manuscriptController.dispose();
    _summaryController.dispose();
    _goalController.dispose();
    _conflictController.dispose();
    _outcomeController.dispose();
    _wordTargetController.dispose();
    _aiPromptController.dispose();
    _providerNameController.dispose();
    _modelNameController.dispose();
    _baseUrlController.dispose();
    _apiKeyRefController.dispose();
    _importArchiveController.dispose();
    super.dispose();
  }

  void _addSceneDraftListeners() {
    for (final controller in [
      _manuscriptController,
      _summaryController,
      _goalController,
      _conflictController,
      _outcomeController,
      _wordTargetController,
    ]) {
      controller.addListener(_handleSceneDraftChanged);
    }
  }

  void _handleSceneDraftChanged() {
    if (_syncingSceneControllers || _selectedScene == null) return;
    _autosaveTimer?.cancel();
    if (_sceneSaveState != _SceneSaveState.unsaved && mounted) {
      setState(() => _sceneSaveState = _SceneSaveState.unsaved);
    }
    _autosaveTimer = Timer(const Duration(seconds: 3), _autosaveSelectedScene);
  }

  void _setShellState(VoidCallback update) {
    setState(update);
  }

  Future<void> _autosaveSelectedScene() async {
    if (!mounted || _selectedScene == null || _selectedProject == null) return;
    setState(() => _sceneSaveState = _SceneSaveState.saving);
    try {
      final copy = WritellerCopy(Localizations.localeOf(context).languageCode);
      await _saveSelectedScene(
        copy,
        showSnackBar: false,
        recordMetric: false,
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _sceneSaveState = _SceneSaveState.error);
    }
  }

  Future<void> _loadProjects() async {
    final providerConfig = await _aiProviderRuntime.normalizeConfigSecrets(
      await widget.aiProviderConfigRepository.findById('default'),
    );
    final projects = await widget.projectRepository.listActive();
    if (!mounted) return;
    final selectedProject = projects.firstOrNull;
    setState(() {
      _projects = projects;
      _selectedProject = selectedProject;
      _syncProviderConfig(providerConfig ?? _aiProviderRuntime.defaultConfig());
    });
    if (selectedProject != null) {
      await _loadProjectData(selectedProject.id);
    }
  }

  void _syncProviderConfig(AIProviderConfig config) {
    _activeProviderConfig = config;
    _selectedProviderKind = config.kind;
    _providerEnabled = config.enabled;
    _providerNameController.text = config.displayName;
    _modelNameController.text = config.modelName;
    _baseUrlController.text = config.baseUrl ?? '';
    _apiKeyRefController.clear();
    _providerHasStoredApiKey = config.encryptedApiKeyRef != null;
  }

  void _selectProviderKind(AIProviderKind kind) {
    final preset = AIProviderPreset.forKind(kind);
    setState(() {
      _selectedProviderKind = kind;
      _providerNameController.text = preset.displayName;
      _modelNameController.text = preset.modelName;
      _baseUrlController.text = preset.baseUrl ?? '';
      _apiKeyRefController.clear();
      _providerHasStoredApiKey = false;
    });
  }

  Future<RequestAISuggestion> _createSuggestionRequester() async {
    return RequestAISuggestion(
      provider: await _aiProviderRuntime.createProvider(_activeProviderConfig),
      repository: widget.aiSuggestionRepository,
    );
  }

  Future<void> _loadProjectData(String projectId) async {
    final scenesFuture = widget.sceneRepository.listByProject(projectId);
    final chaptersFuture = widget.chapterRepository.listByProject(projectId);
    final catalogFuture = widget.catalogItemRepository.listByProject(projectId);
    final relationshipsFuture =
        widget.relationshipRepository.listByProject(projectId);
    final metricsFuture = widget.metricRepository.listForProject(projectId);
    final suggestionsFuture =
        widget.aiSuggestionRepository.listForProject(projectId);
    final notesFuture = widget.projectNoteRepository.listForProject(projectId);
    final snapshotsFuture =
        widget.sceneSnapshotRepository.listByProject(projectId);
    final researchFuture =
        widget.researchItemRepository.listForProject(projectId);
    final scenes = await scenesFuture;
    final chapters = await chaptersFuture;
    final catalogItems = await catalogFuture;
    final relationships = await relationshipsFuture;
    final metrics = await metricsFuture;
    final suggestions = await suggestionsFuture;
    final notes = await notesFuture;
    final snapshots = await snapshotsFuture;
    final researchItems = await researchFuture;
    if (!mounted) return;
    setState(() {
      _scenes = scenes;
      _chapters = chapters;
      _catalogItems = catalogItems;
      _relationships = relationships;
      _metrics = metrics;
      _suggestions = suggestions;
      _notes = notes;
      _sceneSnapshots = snapshots;
      _researchItems = researchItems;
      _selectedScene = scenes.firstOrNull;
      _syncSceneControllers(_selectedScene);
    });
  }

  Future<void> _selectProject(Project project) async {
    setState(() {
      _selectedProject = project;
      _selectedScene = null;
      _chapters = const [];
      _scenes = const [];
      _catalogItems = const [];
      _relationships = const [];
      _metrics = const [];
      _suggestions = const [];
      _notes = const [];
      _sceneSnapshots = const [];
      _researchItems = const [];
      _syncSceneControllers(null);
    });
    await _loadProjectData(project.id);
  }

  void _selectScene(Scene scene) {
    unawaited(_selectSceneAfterPendingSave(scene));
  }

  Future<void> _selectSceneAfterPendingSave(Scene scene) async {
    if (_selectedScene?.id == scene.id) return;
    if (_sceneSaveState == _SceneSaveState.unsaved) {
      try {
        final copy =
            WritellerCopy(Localizations.localeOf(context).languageCode);
        await _saveSelectedScene(
          copy,
          showSnackBar: false,
          recordMetric: false,
        );
      } catch (_) {
        if (!mounted) return;
        setState(() => _sceneSaveState = _SceneSaveState.error);
        return;
      }
    }
    if (!mounted) return;
    _autosaveTimer?.cancel();
    setState(() {
      _selectedScene = scene;
      _syncSceneControllers(scene);
    });
  }

  void _syncSceneControllers(Scene? scene) {
    _syncingSceneControllers = true;
    try {
      _manuscriptController.text = scene?.manuscriptText ?? '';
      _summaryController.text = scene?.summary ?? '';
      _goalController.text = scene?.goal ?? '';
      _conflictController.text = scene?.conflict ?? '';
      _outcomeController.text = scene?.outcome ?? '';
      _wordTargetController.text = scene?.estimatedWordTarget?.toString() ?? '';
      _selectedSceneChapterId = scene?.chapterId;
      _selectedSceneStatus = scene?.status ?? DraftStatus.planned;
      _sceneSaveState = _SceneSaveState.saved;
      _lastSceneSavedAt = scene?.updatedAt;
    } finally {
      _syncingSceneControllers = false;
    }
  }

  Future<void> _recordProjectMetric({
    required String eventType,
    num? value,
    Map<String, Object?> metadata = const {},
  }) async {
    final project = _selectedProject;
    if (project == null) return;

    await _recordMetric(
      projectId: project.id,
      eventType: eventType,
      value: value,
      metadata: metadata,
    );
    final metrics = await widget.metricRepository.listForProject(project.id);
    if (!mounted) return;
    setState(() => _metrics = metrics);
  }

  Future<void> _saveSelectedScene(
    WritellerCopy copy, {
    bool showSnackBar = true,
    bool recordMetric = true,
  }) async {
    final scene = _selectedScene;
    final project = _selectedProject;
    if (scene == null || project == null) return;

    _autosaveTimer?.cancel();
    final updated = _sceneDraftFromControllers(scene);
    if (_shouldCreateAutomaticSnapshot(scene, updated)) {
      await _createSceneSnapshot(
        scene,
        reason: SceneSnapshotReason.majorEdit,
      );
    }
    await widget.sceneRepository.save(updated);
    final scenes = await widget.sceneRepository.listByProject(project.id);

    if (!mounted) return;
    final stillSelected = _selectedScene?.id == updated.id;
    setState(() {
      _scenes = scenes;
      if (stillSelected) {
        _selectedScene = updated;
        _sceneSaveState = _SceneSaveState.saved;
        _lastSceneSavedAt = DateTime.now().toUtc();
      }
    });
    if (recordMetric) {
      await _recordProjectMetric(
        eventType: 'scene.saved',
        value: updated.actualWordCount,
        metadata: {'sceneId': updated.id, 'title': updated.title},
      );
      if (!mounted) return;
    }

    if (showSnackBar) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(copy.t('sceneSaved'))),
      );
    }
  }

  Future<void> _saveSceneManuscriptText(
    Scene scene,
    String manuscriptText,
    WritellerCopy copy,
  ) async {
    final project = _selectedProject;
    if (project == null) return;

    final current = _scenes.firstWhere(
      (item) => item.id == scene.id,
      orElse: () => scene,
    );
    if (current.manuscriptText == manuscriptText) return;

    final updated = current.copyWith(manuscriptText: manuscriptText);
    if (_shouldCreateAutomaticSnapshot(current, updated)) {
      await _createSceneSnapshot(
        current,
        reason: SceneSnapshotReason.majorEdit,
      );
    }
    await widget.sceneRepository.save(updated);
    final scenes = await widget.sceneRepository.listByProject(project.id);

    if (!mounted) return;
    final stillSelected = _selectedScene?.id == updated.id;
    setState(() {
      _scenes = scenes;
      if (stillSelected) {
        _selectedScene = updated;
        _syncingSceneControllers = true;
        try {
          _manuscriptController.text = manuscriptText;
        } finally {
          _syncingSceneControllers = false;
        }
        _sceneSaveState = _SceneSaveState.saved;
        _lastSceneSavedAt = updated.updatedAt;
      }
    });
    await _recordProjectMetric(
      eventType: 'scene.saved',
      value: updated.actualWordCount,
      metadata: {
        'sceneId': updated.id,
        'title': updated.title,
        'source': 'fullManuscript',
      },
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(copy.t('sceneSaved'))),
    );
  }

  Future<void> _saveSelectedSceneAnnotations(
    List<SceneAnnotation> annotations,
  ) async {
    final scene = _selectedScene;
    final project = _selectedProject;
    if (scene == null || project == null) return;

    _autosaveTimer?.cancel();
    final draft = _sceneDraftFromControllers(scene);
    final updated = draft.copyWith(
      metadata: SceneAnnotation.metadataWithAnnotations(
        draft.metadata,
        annotations,
      ),
    );
    await widget.sceneRepository.save(updated);
    final scenes = await widget.sceneRepository.listByProject(project.id);

    if (!mounted) return;
    setState(() {
      _scenes = scenes;
      _selectedScene = updated;
      _sceneSaveState = _SceneSaveState.saved;
      _lastSceneSavedAt = updated.updatedAt;
    });
    await _recordProjectMetric(
      eventType: 'scene.annotation.updated',
      value: annotations.where((annotation) => !annotation.resolved).length,
      metadata: {
        'sceneId': updated.id,
        'annotations': annotations.length,
      },
    );
  }

  Scene _sceneDraftFromControllers(Scene scene) {
    final wordTargetText = _wordTargetController.text.trim();
    final wordTarget = int.tryParse(wordTargetText);
    return scene.copyWith(
      summary: _summaryController.text.trim(),
      manuscriptText: _manuscriptController.text,
      chapterId: _selectedSceneChapterId,
      clearChapterId: _selectedSceneChapterId == null,
      status: _selectedSceneStatus,
      estimatedWordTarget: wordTarget,
      clearEstimatedWordTarget: wordTargetText.isEmpty,
      goal: _goalController.text.trim(),
      conflict: _conflictController.text.trim(),
      outcome: _outcomeController.text.trim(),
    );
  }

  bool _shouldCreateAutomaticSnapshot(Scene before, Scene after) {
    final manuscriptDelta =
        (after.manuscriptText.length - before.manuscriptText.length).abs();
    final planningChanged = before.summary != after.summary ||
        before.goal != after.goal ||
        before.conflict != after.conflict ||
        before.outcome != after.outcome;
    final statusChanged = before.status != after.status ||
        before.chapterId != after.chapterId ||
        before.estimatedWordTarget != after.estimatedWordTarget;
    final substantialTextChange = manuscriptDelta >= 500 ||
        (before.manuscriptText.isNotEmpty &&
            manuscriptDelta / before.manuscriptText.length >= 0.18);
    return substantialTextChange || planningChanged || statusChanged;
  }

  Future<void> _createSceneSnapshot(
    Scene scene, {
    required SceneSnapshotReason reason,
    String label = '',
  }) async {
    final latest =
        await widget.sceneSnapshotRepository.latestForScene(scene.id);
    if (latest != null &&
        jsonEncode(latest.scene.toJson()) == jsonEncode(scene.toJson())) {
      return;
    }
    final snapshot = SceneSnapshot(
      id: newLocalId('sceneSnapshot'),
      projectId: scene.projectId,
      sceneId: scene.id,
      sceneTitle: scene.title,
      label: label,
      reason: reason,
      scene: scene,
      createdAt: DateTime.now().toUtc(),
    );
    await widget.sceneSnapshotRepository.save(snapshot);
    final snapshots =
        await widget.sceneSnapshotRepository.listByProject(scene.projectId);
    if (!mounted) return;
    setState(() => _sceneSnapshots = snapshots);
    await _recordProjectMetric(
      eventType: 'scene.snapshot.created',
      metadata: {
        'sceneId': scene.id,
        'reason': reason.wireName,
      },
    );
  }

  Future<void> _createManualSceneSnapshot(WritellerCopy copy) async {
    final scene = _selectedScene;
    if (scene == null) return;
    if (_sceneSaveState == _SceneSaveState.unsaved) {
      await _saveSelectedScene(copy, showSnackBar: false);
    }
    final current = _selectedScene ?? scene;
    await _createSceneSnapshot(
      current,
      reason: SceneSnapshotReason.manual,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(copy.t('snapshotCreated'))),
    );
  }

  Future<void> _deleteSceneSnapshot(
    SceneSnapshot snapshot,
    WritellerCopy copy,
  ) async {
    await widget.sceneSnapshotRepository.delete(snapshot.id);
    final snapshots =
        await widget.sceneSnapshotRepository.listByProject(snapshot.projectId);
    if (!mounted) return;
    setState(() => _sceneSnapshots = snapshots);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(copy.t('snapshotDeleted'))),
    );
  }

  Future<void> _restoreSceneSnapshot(
    SceneSnapshot snapshot,
    WritellerCopy copy,
  ) async {
    var current =
        _scenes.where((scene) => scene.id == snapshot.sceneId).firstOrNull;
    if (_selectedScene?.id == snapshot.sceneId &&
        _sceneSaveState == _SceneSaveState.unsaved) {
      current = _sceneDraftFromControllers(_selectedScene!);
    }
    if (current != null) {
      await _createSceneSnapshot(
        current,
        reason: SceneSnapshotReason.restore,
      );
    }
    final restored = snapshot.scene.copyWith();
    await widget.sceneRepository.save(restored);
    final scenes =
        await widget.sceneRepository.listByProject(restored.projectId);
    final snapshots =
        await widget.sceneSnapshotRepository.listByProject(restored.projectId);
    if (!mounted) return;
    setState(() {
      _scenes = scenes;
      _sceneSnapshots = snapshots;
      _selectedScene = scenes.firstWhere(
        (scene) => scene.id == restored.id,
        orElse: () => restored,
      );
      _syncSceneControllers(_selectedScene);
    });
    await _recordProjectMetric(
      eventType: 'scene.snapshot.restored',
      metadata: {
        'sceneId': restored.id,
        'snapshotId': snapshot.id,
      },
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(copy.t('snapshotRestored'))),
    );
  }

  Future<void> _deleteProject(Project project, WritellerCopy copy) async {
    final confirmed = await _confirmDelete(
      copy: copy,
      title: copy.t('deleteProject'),
      body: copy.t('deleteProjectBody'),
    );
    if (!confirmed) return;

    await widget.projectRepository.delete(project.id);
    final projects = await widget.projectRepository.listActive();
    final selectedProject = projects.firstOrNull;
    if (!mounted) return;
    setState(() {
      _projects = projects;
      _selectedProject = selectedProject;
      _chapters = const [];
      _scenes = const [];
      _catalogItems = const [];
      _relationships = const [];
      _metrics = const [];
      _suggestions = const [];
      _selectedScene = null;
      _syncSceneControllers(null);
    });
    if (selectedProject != null) {
      await _loadProjectData(selectedProject.id);
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(copy.t('projectDeleted'))),
    );
  }

  Future<void> _deleteChapter(Chapter chapter, WritellerCopy copy) async {
    final project = _selectedProject;
    if (project == null) return;
    final confirmed = await _confirmDelete(
      copy: copy,
      title: copy.t('deleteChapter'),
      body: copy.t('deleteChapterBody'),
    );
    if (!confirmed) return;

    final affectedScenes =
        _scenes.where((scene) => scene.chapterId == chapter.id).toList();
    for (final scene in affectedScenes) {
      await widget.sceneRepository.save(scene.copyWith(clearChapterId: true));
    }
    await widget.chapterRepository.delete(chapter.id);
    final chapters = await widget.chapterRepository.listByProject(project.id);
    final scenes = await widget.sceneRepository.listByProject(project.id);
    final selected = _selectedScene == null
        ? null
        : scenes.firstWhere(
            (scene) => scene.id == _selectedScene!.id,
            orElse: () => _selectedScene!.copyWith(clearChapterId: true),
          );
    if (!mounted) return;
    setState(() {
      _chapters = chapters;
      _scenes = scenes;
      _selectedScene = selected;
      _syncSceneControllers(selected);
    });
    await _recordProjectMetric(
      eventType: 'chapter.deleted',
      metadata: {'chapterId': chapter.id, 'title': chapter.title},
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(copy.t('chapterDeleted'))),
    );
  }

  Future<void> _deleteScene(Scene scene, WritellerCopy copy) async {
    final project = _selectedProject;
    if (project == null) return;
    final confirmed = await _confirmDelete(
      copy: copy,
      title: copy.t('deleteScene'),
      body: copy.t('deleteSceneBody'),
    );
    if (!confirmed) return;

    await _deleteRelationshipsForRef(
      EntityRef(type: EntityType.scene, id: scene.id),
    );
    await _deleteNotesForRef(EntityRef(type: EntityType.scene, id: scene.id));
    await widget.sceneRepository.delete(scene.id);
    final scenes = await widget.sceneRepository.listByProject(project.id);
    final relationships =
        await widget.relationshipRepository.listByProject(project.id);
    final notes = await widget.projectNoteRepository.listForProject(project.id);
    final selected = _selectedScene?.id == scene.id
        ? scenes.firstOrNull
        : scenes.firstWhere(
            (item) => item.id == _selectedScene?.id,
            orElse: () => scenes.firstOrNull ?? scene,
          );
    if (!mounted) return;
    setState(() {
      _scenes = scenes;
      _relationships = relationships;
      _notes = notes;
      _selectedScene = scenes.isEmpty ? null : selected;
      _syncSceneControllers(_selectedScene);
    });
    await _recordProjectMetric(
      eventType: 'scene.deleted',
      metadata: {'sceneId': scene.id, 'title': scene.title},
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(copy.t('sceneDeleted'))),
    );
  }

  Future<void> _deleteCatalogItem(CatalogItem item, WritellerCopy copy) async {
    final project = _selectedProject;
    if (project == null) return;
    final confirmed = await _confirmDelete(
      copy: copy,
      title: copy.t('deleteCatalogItem'),
      body: copy.t('deleteCatalogItemBody'),
    );
    if (!confirmed) return;

    await _deleteRelationshipsForRef(EntityRef(type: item.type, id: item.id));
    await _deleteNotesForRef(EntityRef(type: item.type, id: item.id));
    await widget.catalogItemRepository.delete(item.id);
    final items = await widget.catalogItemRepository.listByProject(project.id);
    final relationships =
        await widget.relationshipRepository.listByProject(project.id);
    final notes = await widget.projectNoteRepository.listForProject(project.id);
    if (!mounted) return;
    setState(() {
      _catalogItems = items;
      _relationships = relationships;
      _notes = notes;
    });
    await _recordProjectMetric(
      eventType: 'catalog.deleted',
      metadata: {'itemId': item.id, 'type': item.type.wireName},
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(copy.t('catalogItemDeleted'))),
    );
  }

  Future<void> _deleteRelationshipsForRef(EntityRef ref) async {
    final project = _selectedProject;
    if (project == null) return;
    final relationships =
        await widget.relationshipRepository.listByProject(project.id);
    for (final relationship in relationships.where(
      (relationship) =>
          _sameRef(relationship.source, ref) ||
          _sameRef(relationship.target, ref),
    )) {
      await widget.relationshipRepository.delete(relationship.id);
    }
  }

  Future<void> _deleteNotesForRef(EntityRef ref) async {
    final notes = _notes
        .where((note) =>
            note.target?.type == ref.type && note.target?.id == ref.id)
        .toList();
    for (final note in notes) {
      await widget.projectNoteRepository.delete(note.id);
    }
  }

  bool _sameRef(EntityRef left, EntityRef right) {
    return left.type == right.type && left.id == right.id;
  }

  Future<void> _toggleSceneCatalogLink(CatalogItem item, bool selected) async {
    final project = _selectedProject;
    final scene = _selectedScene;
    if (project == null || scene == null) return;

    final existing = _relationships.where(
      (relationship) =>
          relationship.source.type == EntityType.scene &&
          relationship.source.id == scene.id &&
          relationship.target.type == item.type &&
          relationship.target.id == item.id &&
          relationship.relationshipType == 'appearsIn',
    );

    if (selected) {
      if (existing.isNotEmpty) return;
      final now = DateTime.now().toUtc();
      await widget.relationshipRepository.save(
        Relationship(
          id: newLocalId('relationship'),
          projectId: project.id,
          source: EntityRef(type: EntityType.scene, id: scene.id),
          target: EntityRef(type: item.type, id: item.id),
          relationshipType: 'appearsIn',
          label: item.name,
          direction: RelationshipDirection.directed,
          createdAt: now,
          updatedAt: now,
        ),
      );
    } else {
      for (final relationship in existing) {
        await widget.relationshipRepository.delete(relationship.id);
      }
    }

    final relationships =
        await widget.relationshipRepository.listByProject(project.id);
    if (!mounted) return;
    setState(() => _relationships = relationships);
    await _recordProjectMetric(
      eventType: selected ? 'relationship.linked' : 'relationship.unlinked',
      metadata: {
        'sceneId': scene.id,
        'targetType': item.type.wireName,
        'targetId': item.id
      },
    );
  }

  Future<void> _addExistingSceneCatalogItems(List<CatalogItem> items) async {
    final project = _selectedProject;
    final scene = _selectedScene;
    if (project == null || scene == null || items.isEmpty) return;

    final relationships =
        await widget.relationshipRepository.listByProject(project.id);
    final existingKeys = relationships
        .where(
          (relationship) =>
              relationship.source.type == EntityType.scene &&
              relationship.source.id == scene.id &&
              relationship.relationshipType == 'appearsIn',
        )
        .map(
          (relationship) =>
              '${relationship.target.type.wireName}:${relationship.target.id}',
        )
        .toSet();

    var createdCount = 0;
    for (final item in items) {
      final key = '${item.type.wireName}:${item.id}';
      if (existingKeys.contains(key)) continue;
      final now = DateTime.now().toUtc();
      await widget.relationshipRepository.save(
        Relationship(
          id: newLocalId('relationship'),
          projectId: project.id,
          source: EntityRef(type: EntityType.scene, id: scene.id),
          target: EntityRef(type: item.type, id: item.id),
          relationshipType: 'appearsIn',
          label: item.name,
          direction: RelationshipDirection.directed,
          createdAt: now,
          updatedAt: now,
        ),
      );
      existingKeys.add(key);
      createdCount += 1;
    }

    if (createdCount == 0) return;
    final updatedRelationships =
        await widget.relationshipRepository.listByProject(project.id);
    if (!mounted) return;
    setState(() => _relationships = updatedRelationships);
    await _recordProjectMetric(
      eventType: 'relationship.linked.batch',
      metadata: {
        'sceneId': scene.id,
        'count': createdCount,
        'targetIds': items.map((item) => item.id).join(','),
      },
    );
  }

  Future<void> _createSceneCatalogItem(
    WritellerCopy copy,
    EntityType type,
  ) async {
    final scene = _selectedScene;
    if (scene == null) return;
    final item = await _showCreateCatalogItemDialog(copy, type);
    if (item == null) return;
    await _toggleSceneCatalogLink(item, true);
  }

  Future<void> _moveSceneInStructure(Scene scene, int direction) async {
    final project = _selectedProject;
    if (project == null) return;

    final ordered = _scenes
        .where((item) => item.chapterId == scene.chapterId)
        .toList()
      ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
    final index = ordered.indexWhere((item) => item.id == scene.id);
    final targetIndex = index + direction;
    if (index == -1 || targetIndex < 0 || targetIndex >= ordered.length) return;

    final moving = ordered[index];
    final target = ordered[targetIndex];
    await widget.sceneRepository
        .save(moving.copyWith(orderIndex: target.orderIndex));
    await widget.sceneRepository
        .save(target.copyWith(orderIndex: moving.orderIndex));

    final scenes = await widget.sceneRepository.listByProject(project.id);
    final selected = scenes.firstWhere(
      (item) => item.id == scene.id,
      orElse: () => scene,
    );
    if (!mounted) return;
    setState(() {
      _scenes = scenes;
      _selectedScene = selected;
      _syncSceneControllers(selected);
    });
    await _recordProjectMetric(
      eventType: 'scene.reordered',
      metadata: {'sceneId': scene.id, 'direction': direction},
    );
  }

  Future<void> _moveSceneToChapter(Scene scene, String? chapterId) async {
    final project = _selectedProject;
    if (project == null || scene.chapterId == chapterId) return;

    final updated = scene.copyWith(
      chapterId: chapterId,
      clearChapterId: chapterId == null,
    );
    await widget.sceneRepository.save(updated);
    final scenes = await widget.sceneRepository.listByProject(project.id);
    if (!mounted) return;
    setState(() {
      _scenes = scenes;
      _selectedScene = updated;
      _syncSceneControllers(updated);
    });
    await _recordProjectMetric(
      eventType: 'scene.moved',
      metadata: {'sceneId': scene.id, 'chapterId': chapterId},
    );
  }

  Future<void> _moveSceneToChapterOrder(
    Scene scene, {
    required String? chapterId,
    double? orderIndex,
  }) async {
    final project = _selectedProject;
    if (project == null) return;
    if (scene.chapterId == chapterId && orderIndex == null) return;

    final updated = scene.copyWith(
      chapterId: chapterId,
      clearChapterId: chapterId == null,
      orderIndex: orderIndex,
    );
    await widget.sceneRepository.save(updated);
    final scenes = await widget.sceneRepository.listByProject(project.id);
    final selected = scenes.firstWhere(
      (item) => item.id == scene.id,
      orElse: () => updated,
    );
    if (!mounted) return;
    setState(() {
      _scenes = scenes;
      _selectedScene = selected;
      _syncSceneControllers(selected);
    });
    await _recordProjectMetric(
      eventType: 'scene.moved',
      metadata: {'sceneId': scene.id, 'chapterId': chapterId},
    );
  }

  Future<void> _changeSceneStatus(Scene scene, DraftStatus status) async {
    final project = _selectedProject;
    if (project == null || scene.status == status) return;

    final updated = scene.copyWith(status: status);
    await widget.sceneRepository.save(updated);
    final scenes = await widget.sceneRepository.listByProject(project.id);
    if (!mounted) return;
    setState(() {
      _scenes = scenes;
      if (_selectedScene?.id == scene.id) {
        _selectedScene = updated;
        _selectedSceneStatus = status;
      }
    });
    await _recordProjectMetric(
      eventType: 'scene.status.changed',
      metadata: {'sceneId': scene.id, 'status': status.wireName},
    );
  }

  Future<void> _saveProjectMetadata(_ProjectMetadataUpdate update) async {
    final project = _selectedProject;
    if (project == null) return;
    final authorName = update.authorName.trim();
    final metadata = Map<String, Object?>.from(project.metadata);
    if (authorName.isEmpty) {
      metadata.remove('authorName');
    } else {
      metadata['authorName'] = authorName;
    }
    final targetValue = update.targetValue;
    final int? wordTarget = switch (update.targetUnit) {
      _ProjectTargetUnit.words => targetValue,
      _ProjectTargetUnit.pages =>
        targetValue == null ? null : targetValue * _estimatedWordsPerPage,
    };
    if (targetValue == null) {
      metadata.remove('targetUnit');
      metadata.remove('pageTarget');
      metadata.remove('wordsPerPageEstimate');
    } else {
      metadata['targetUnit'] = update.targetUnit.name;
      if (update.targetUnit == _ProjectTargetUnit.pages) {
        metadata['pageTarget'] = targetValue;
        metadata['wordsPerPageEstimate'] = _estimatedWordsPerPage;
      } else {
        metadata.remove('pageTarget');
        metadata.remove('wordsPerPageEstimate');
      }
    }
    final updated = project.copyWith(
      projectType: update.projectType,
      wordTarget: wordTarget,
      clearWordTarget: targetValue == null,
      metadata: metadata,
    );
    await widget.projectRepository.save(updated);
    final projects = await widget.projectRepository.listActive();
    if (!mounted) return;
    setState(() {
      _projects = projects;
      _selectedProject = updated;
    });
    await _recordProjectMetric(
      eventType: 'project.metadata.updated',
      metadata: {
        'authorNameSet': authorName.isNotEmpty,
        'projectType': update.projectType,
        'targetUnit': targetValue == null ? null : update.targetUnit.name,
      },
    );
  }

  Future<void> _saveProjectContext(String value) async {
    final project = _selectedProject;
    if (project == null) return;
    final metadata = Map<String, Object?>.from(project.metadata);
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      metadata.remove('storyContext');
    } else {
      metadata['storyContext'] = trimmed;
    }
    final updated = project.copyWith(metadata: metadata);
    await widget.projectRepository.save(updated);
    final projects = await widget.projectRepository.listActive();
    if (!mounted) return;
    setState(() {
      _projects = projects;
      _selectedProject = updated;
    });
    await _recordProjectMetric(
      eventType: 'project.context.updated',
      metadata: {'hasContext': trimmed.isNotEmpty},
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
              WritellerCopy(Localizations.localeOf(context).languageCode)
                  .t('storyContextSaved'))),
    );
  }

  Future<void> _saveStoryboardState(Map<String, Object?> storyboard) async {
    final project = _selectedProject;
    if (project == null) return;
    final metadata = Map<String, Object?>.from(project.metadata);
    metadata['storyboard'] = storyboard;
    final updated = project.copyWith(metadata: metadata);
    await widget.projectRepository.save(updated);
    final projects = await widget.projectRepository.listActive();
    if (!mounted) return;
    setState(() {
      _projects = projects;
      _selectedProject = updated;
    });
  }

  Future<void> _reorderSceneFromStoryboard(
    String sourceNodeId,
    String targetNodeId,
  ) async {
    final sourceSceneId = _sceneIdFromStoryboardNode(sourceNodeId);
    final targetSceneId = _sceneIdFromStoryboardNode(targetNodeId);
    if (sourceSceneId == null ||
        targetSceneId == null ||
        sourceSceneId == targetSceneId) {
      return;
    }
    final source =
        _scenes.where((scene) => scene.id == sourceSceneId).firstOrNull;
    final target =
        _scenes.where((scene) => scene.id == targetSceneId).firstOrNull;
    if (source == null || target == null) return;

    await _moveSceneToChapterOrder(
      source,
      chapterId: target.chapterId,
      orderIndex: _orderIndexBeforeTarget(
        source: source,
        target: target,
      ),
    );
    await _recordProjectMetric(
      eventType: 'storyboard.timeline.reordered',
      metadata: {
        'sceneId': source.id,
        'beforeSceneId': target.id,
        'chapterId': target.chapterId,
      },
    );
  }

  double _orderIndexBeforeTarget({
    required Scene source,
    required Scene target,
  }) {
    final ordered = _scenes
        .where(
          (scene) =>
              scene.id != source.id && scene.chapterId == target.chapterId,
        )
        .toList()
      ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
    final targetIndex = ordered.indexWhere((scene) => scene.id == target.id);
    if (targetIndex <= 0) return target.orderIndex - 1000;
    final previous = ordered[targetIndex - 1];
    return (previous.orderIndex + target.orderIndex) / 2;
  }

  String? _sceneIdFromStoryboardNode(String nodeId) {
    const prefix = 'scene:';
    if (!nodeId.startsWith(prefix)) return null;
    return nodeId.substring(prefix.length);
  }

  Future<void> _requestWorldStarter(WritellerCopy copy) async {
    final project = _selectedProject;
    if (project == null || _isRequestingAi) return;
    setState(() {
      _isRequestingAi = true;
      _lastAiError = null;
    });
    try {
      final effectiveProject = _effectiveProjectForGlobalProfile(project);
      const policy = AIPolicy();
      policy.ensureProjectAllowsAI(effectiveProject);
      final provider =
          await _aiProviderRuntime.createProvider(_activeProviderConfig);
      final prompt = const AIProjectPromptBuilder().build(
        policy: policy,
        project: effectiveProject,
        chapters: _chapters,
        scenes: _scenes,
        task: AITaskKind.worldContextStarter,
        userPrompt: _projectContextText(project).isEmpty
            ? copy.t('storyContextEmptyPrompt')
            : _projectContextText(project),
        languageCode: copy.languageCode,
      );
      final response = await provider.generateText(
        ModelRequest(
          prompt: prompt,
          target: EntityRef(type: EntityType.project, id: project.id),
          context: {
            'projectId': project.id,
            'task': AITaskKind.worldContextStarter.name,
          },
          parameters: const ModelParameters(maxTokens: 5000),
        ),
      );
      final created = await _saveWorldStarterSuggestions(
        project: project,
        provider: provider,
        prompt: prompt,
        responseText: response.text,
        structured: response.structured,
      );
      final suggestions =
          await widget.aiSuggestionRepository.listForProject(project.id);
      if (!mounted) return;
      setState(() => _suggestions = suggestions);
      await _recordProjectMetric(
        eventType: 'ai.world_starter.created',
        metadata: {'suggestions': created},
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            created == 0
                ? copy.t('worldStarterNoStructuredSuggestions')
                : copy.t('worldStarterCreated'),
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      final message = _providerErrorMessage(error);
      setState(() => _lastAiError = message);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } finally {
      if (mounted) setState(() => _isRequestingAi = false);
    }
  }

  Future<int> _saveWorldStarterSuggestions({
    required Project project,
    required LanguageModelProvider provider,
    required String prompt,
    required String responseText,
    required Map<String, Object?>? structured,
  }) async {
    final normalized = _worldStarterPayload(
      structured ?? extractStructuredJson(responseText),
    );
    if (normalized == null) return 0;
    final entries = <({String kind, Map<String, Object?> item})>[
      for (final item in _worldStarterList(
        normalized,
        const ['personas', 'persona', 'characters', 'figures', 'figuren'],
      ))
        (kind: 'persona', item: item),
      for (final item in _worldStarterList(
        normalized,
        const ['relationships', 'beziehungen'],
      ))
        (kind: 'relationship', item: item),
      for (final item in _worldStarterList(
        normalized,
        const ['locations', 'places', 'orte'],
      ))
        (kind: 'location', item: item),
      for (final item in _worldStarterList(
        normalized,
        const [
          'drivers',
          'goalsConflicts',
          'goals',
          'conflicts',
          'zieleKonflikte',
          'ziele',
          'konflikte',
        ],
      ))
        (kind: 'driver', item: item),
      for (final item in _worldStarterList(
        normalized,
        const ['events', 'historicalEvents', 'timeline', 'ereignisse'],
      ))
        (kind: 'event', item: item),
    ];
    final now = DateTime.now().toUtc();
    var offset = 0;
    for (final entry in entries) {
      final item = {
        'kind': entry.kind,
        ...entry.item,
      };
      final suggestion = AISuggestion(
        id: newLocalId('ai-suggestion'),
        projectId: project.id,
        target: EntityRef(type: EntityType.project, id: project.id),
        suggestionType: 'worldContextStarter.${entry.kind}',
        inputContextHash: '${prompt.hashCode.toRadixString(16)}-$offset',
        providerId: provider.id,
        modelName: provider.displayName,
        promptTemplateId: 'project.worldContextStarter.v1',
        promptText: prompt,
        responseText: _worldStarterSuggestionText(item),
        structuredResponse: {'worldStarterItem': item},
        userDecision: SuggestionDecision.pending,
        createdAt: now.add(Duration(milliseconds: offset)),
      );
      await widget.aiSuggestionRepository.save(suggestion);
      offset += 1;
    }
    return entries.length;
  }

  Map<String, Object?>? _worldStarterPayload(Map<String, Object?>? structured) {
    if (structured == null) return null;
    for (final key in const [
      'worldStarter',
      'contextStarter',
      'storyContext',
      'kontext',
    ]) {
      final value = structured[key];
      if (value is Map) return Map<String, Object?>.from(value);
    }
    if (_hasAnyWorldStarterList(structured)) return structured;
    return null;
  }

  bool _hasAnyWorldStarterList(Map<String, Object?> value) {
    const keys = [
      'personas',
      'characters',
      'figures',
      'relationships',
      'locations',
      'places',
      'drivers',
      'goalsConflicts',
      'events',
      'historicalEvents',
      'timeline',
      'figuren',
      'beziehungen',
      'orte',
      'zieleKonflikte',
      'ereignisse',
    ];
    return keys.any((key) => value[key] is List);
  }

  List<Map<String, Object?>> _worldStarterList(
    Map<String, Object?> source,
    List<String> keys,
  ) {
    final value = keys.map((key) => source[key]).whereType<List>().firstOrNull;
    if (value == null) return const [];
    return [
      for (final item in value)
        if (item is Map) Map<String, Object?>.from(item),
    ];
  }

  String _worldStarterSuggestionText(Map<String, Object?> item) {
    final title = item['name'] ?? item['label'] ?? item['type'] ?? item['kind'];
    final details = item.entries
        .where((entry) => entry.key != 'kind')
        .map((entry) => '${entry.key}: ${entry.value}')
        .join('\n');
    return '$title\n$details'.trim();
  }

  Future<void> _requestAiSuggestion(
    WritellerCopy copy,
    AITaskKind task, {
    required _AIWorkshopContextKind contextKind,
    Scene? scene,
    required List<CatalogItem> contextCatalogItems,
    required List<Relationship> contextRelationships,
  }) async {
    final project = _selectedProject;
    final targetScene = scene ?? _selectedScene ?? _scenes.firstOrNull;
    if (project == null || _isRequestingAi) return;
    if (contextKind == _AIWorkshopContextKind.scene && targetScene == null) {
      return;
    }

    setState(() => _isRequestingAi = true);
    try {
      final requester = await _createSuggestionRequester();
      final userPrompt = _aiPromptController.text.trim().isEmpty
          ? copy.t('defaultAiPrompt')
          : _aiPromptController.text.trim();
      if (contextKind == _AIWorkshopContextKind.project) {
        await requester.forProject(
          project: _effectiveProjectForGlobalProfile(project),
          chapters: _chapters,
          scenes: _scenes,
          task: task,
          languageCode: copy.languageCode,
          userPrompt: userPrompt,
          contextCatalogItems: contextCatalogItems,
          contextRelationships: contextRelationships,
        );
      } else {
        await requester.forScene(
          project: _effectiveProjectForGlobalProfile(project),
          scene: targetScene!,
          task: task,
          languageCode: copy.languageCode,
          userPrompt: userPrompt,
          contextCatalogItems: contextCatalogItems,
          contextRelationships: contextRelationships,
        );
      }
      final suggestions =
          await widget.aiSuggestionRepository.listForProject(project.id);
      if (!mounted) return;
      setState(() {
        _suggestions = suggestions;
        _aiPromptController.clear();
        _lastAiError = null;
        if (contextKind == _AIWorkshopContextKind.scene &&
            targetScene != null) {
          _selectedScene = targetScene;
          _syncSceneControllers(targetScene);
        }
      });
      await _recordProjectMetric(
        eventType: 'ai.suggestion.created',
        metadata: {
          'task': task.name,
          'context': contextKind.name,
          if (targetScene != null) 'sceneId': targetScene.id,
          'contextCatalogItems': contextCatalogItems.length,
          'contextRelationships': contextRelationships.length,
        },
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(copy.t('aiSuggestionCreated'))),
      );
    } catch (error) {
      if (!mounted) return;
      final message = _providerErrorMessage(error);
      setState(() => _lastAiError = message);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } finally {
      if (mounted) setState(() => _isRequestingAi = false);
    }
  }

  Future<void> _requestEditorSceneAiHelp(
    WritellerCopy copy,
    AITaskKind task,
    String prompt,
  ) async {
    final project = _selectedProject;
    final scene = _selectedScene;
    if (project == null || scene == null || _isRequestingAi) return;
    if (_sceneSaveState == _SceneSaveState.unsaved) {
      await _saveSelectedScene(copy, showSnackBar: false);
    }
    if (!mounted) return;

    setState(() => _isRequestingAi = true);
    try {
      final requester = await _createSuggestionRequester();
      await requester.forScene(
        project: _effectiveProjectForGlobalProfile(project),
        scene: _selectedScene ?? scene,
        task: task,
        languageCode: copy.languageCode,
        userPrompt: prompt.trim().isEmpty
            ? copy.t('defaultEditorAiHelpPrompt')
            : prompt,
      );
      final suggestions =
          await widget.aiSuggestionRepository.listForProject(project.id);
      if (!mounted) return;
      setState(() {
        _suggestions = suggestions;
        _lastAiError = null;
      });
      await _recordProjectMetric(
        eventType: 'ai.suggestion.created',
        metadata: {
          'task': task.name,
          'context': 'editorScene',
          'sceneId': scene.id,
        },
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(copy.t('aiSuggestionCreated'))),
      );
    } catch (error) {
      if (!mounted) return;
      final message = _providerErrorMessage(error);
      setState(() => _lastAiError = message);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } finally {
      if (mounted) setState(() => _isRequestingAi = false);
    }
  }

  String _providerErrorMessage(Object error) {
    if (error is DomainFailure) {
      if (error.message == 'AI_API_KEY_MISSING') {
        return WritellerCopy(Localizations.localeOf(context).languageCode)
            .t('aiApiKeyMissing');
      }
      return error.message;
    }
    return error.toString().replaceFirst('Exception: ', '');
  }

  Project _effectiveProjectForGlobalProfile(Project project) {
    return project.copyWith(
      aiEnabled: widget.globalAiEnabled,
      cloudSyncEnabled: widget.globalCloudSyncEnabled,
      noAiNoCloud: widget.globalNoAiNoCloud,
    );
  }

  ProjectArchive _currentArchive(Project project) {
    return ProjectArchive(
      project: project,
      chapters: _chapters,
      scenes: _scenes,
      catalogItems: _catalogItems,
      relationships: _relationships,
      notes: _notes,
    );
  }

  Future<void> _decideSuggestion(
    WritellerCopy copy,
    AISuggestion suggestion,
    SuggestionDecision decision,
  ) async {
    final project = _selectedProject;
    if (project == null) return;
    var appliedPlanningFields = false;

    if (decision == SuggestionDecision.rejected) {
      await widget.aiSuggestionRepository.delete(suggestion.id);
    } else {
      var acceptedPatch = <String, Object?>{
        'decision': decision.name,
        'decidedAt': DateTime.now().toUtc().toIso8601String(),
      };
      if (decision == SuggestionDecision.accepted) {
        final applyResult = await _applyAcceptedSuggestion(suggestion);
        appliedPlanningFields = applyResult['applied'] == true;
        acceptedPatch = {
          ...acceptedPatch,
          ...applyResult,
        };
      }
      if (decision == SuggestionDecision.convertedToNote) {
        final now = DateTime.now().toUtc();
        await widget.projectNoteRepository.save(
          ProjectNote(
            id: newLocalId('note'),
            projectId: project.id,
            target: suggestion.target,
            title: _aiTaskLabel(suggestion.suggestionType, copy),
            body: suggestion.responseText,
            source: 'aiSuggestion',
            sourceSuggestionId: suggestion.id,
            metadata: {
              'suggestionType': suggestion.suggestionType,
              'providerId': suggestion.providerId,
              'modelName': suggestion.modelName,
              'promptText': suggestion.promptText,
            },
            createdAt: now,
            updatedAt: now,
          ),
        );
      }
      await widget.aiSuggestionRepository.save(
        suggestion.copyWith(
          userDecision: decision,
          acceptedPatch: acceptedPatch,
        ),
      );
    }
    final suggestions =
        await widget.aiSuggestionRepository.listForProject(project.id);
    final notes = await widget.projectNoteRepository.listForProject(project.id);
    if (!mounted) return;
    setState(() {
      _suggestions = suggestions;
      _notes = notes;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _suggestionDecisionFeedback(
            decision,
            copy,
            applied: appliedPlanningFields,
          ),
        ),
      ),
    );
  }

  Future<Map<String, Object?>> _applyAcceptedSuggestion(
    AISuggestion suggestion,
  ) async {
    if (_isWorldStarterSuggestion(suggestion)) {
      return _applyWorldStarterSuggestion(suggestion);
    }
    if (suggestion.target.type != EntityType.scene) {
      return {'applied': false, 'reason': 'unsupportedTarget'};
    }
    final scene = _scenes
        .where((candidate) => candidate.id == suggestion.target.id)
        .firstOrNull;
    if (scene == null) {
      return {'applied': false, 'reason': 'missingScene'};
    }

    final patch = const AIScenePlanningPatchBuilder().build(
      suggestion: suggestion,
      scene: scene,
    );
    if (!patch.hasChanges) {
      return {'applied': false, 'reason': 'noScenePlanningFields'};
    }

    final updated = patch.applyTo(scene);
    await _createSceneSnapshot(
      scene,
      reason: SceneSnapshotReason.aiAccepted,
    );
    await widget.sceneRepository.save(updated);
    final scenes = await widget.sceneRepository.listByProject(scene.projectId);
    final selected = _selectedScene?.id == updated.id
        ? scenes.firstWhere((candidate) => candidate.id == updated.id)
        : _selectedScene;
    if (mounted) {
      setState(() {
        _scenes = scenes;
        _selectedScene = selected;
        if (selected?.id == updated.id) {
          _syncSceneControllers(selected);
        }
      });
    }
    await _recordProjectMetric(
      eventType: 'ai.suggestion.applied',
      metadata: {
        'suggestionId': suggestion.id,
        'sceneId': scene.id,
        'fields': patch.changes.map((change) => change.fieldKey).toList(),
      },
    );
    return {
      'applied': true,
      'scenePatch': patch.toJson(),
    };
  }

  Future<Map<String, Object?>> _applyWorldStarterSuggestion(
    AISuggestion suggestion,
  ) async {
    final project = _selectedProject;
    if (project == null) return {'applied': false, 'reason': 'missingProject'};
    final item = _worldSuggestionItem(suggestion);
    final kind = item['kind'] as String? ?? _worldSuggestionKind(suggestion);
    final createdIds = <String>[];

    switch (kind) {
      case 'persona':
        final catalogItem = await _createContextCatalogItem(
          projectId: project.id,
          type: EntityType.character,
          name: item['name'] as String?,
          summary: item['summary'] as String?,
          fields: {
            'background': item['background'],
            'goal': item['goal'],
            'conflict': item['conflict'],
          },
          role: 'persona',
          suggestionId: suggestion.id,
        );
        if (catalogItem != null) createdIds.add(catalogItem.id);
        break;
      case 'location':
        final catalogItem = await _createContextCatalogItem(
          projectId: project.id,
          type: EntityType.location,
          name: item['name'] as String?,
          summary: item['summary'] as String?,
          fields: {
            'description': item['description'],
            'rules': item['rules'],
          },
          role: 'worldLocation',
          suggestionId: suggestion.id,
        );
        if (catalogItem != null) createdIds.add(catalogItem.id);
        break;
      case 'driver':
        final catalogItem = await _createContextCatalogItem(
          projectId: project.id,
          type: EntityType.object,
          name: item['name'] as String?,
          summary: item['goal'] as String? ?? item['conflict'] as String?,
          fields: {
            'goal': item['goal'],
            'conflict': item['conflict'],
            'stakes': item['stakes'],
          },
          role: 'goalConflict',
          suggestionId: suggestion.id,
        );
        if (catalogItem != null) createdIds.add(catalogItem.id);
        break;
      case 'event':
        final catalogItem = await _createContextCatalogItem(
          projectId: project.id,
          type: EntityType.timelineEvent,
          name: item['name'] as String?,
          summary: item['summary'] as String?,
          fields: {
            'time': item['time'],
            'goal': item['goal'],
            'conflict': item['conflict'],
            'consequence': item['consequence'],
          },
          role: 'historicalEvent',
          suggestionId: suggestion.id,
        );
        if (catalogItem != null) createdIds.add(catalogItem.id);
        break;
      case 'relationship':
        final relationship = await _createContextRelationship(
          projectId: project.id,
          item: item,
          suggestionId: suggestion.id,
        );
        if (relationship != null) createdIds.add(relationship.id);
        break;
      default:
        return {'applied': false, 'reason': 'unknownWorldSuggestionKind'};
    }

    final catalogItems =
        await widget.catalogItemRepository.listByProject(project.id);
    final relationships =
        await widget.relationshipRepository.listByProject(project.id);
    if (mounted) {
      setState(() {
        _catalogItems = catalogItems;
        _relationships = relationships;
      });
    }
    await _recordProjectMetric(
      eventType: 'ai.world_suggestion.applied',
      metadata: {
        'suggestionId': suggestion.id,
        'kind': kind,
        'createdIds': createdIds,
      },
    );
    return {
      'applied': createdIds.isNotEmpty,
      'kind': kind,
      'createdIds': createdIds,
    };
  }

  Future<CatalogItem?> _createContextCatalogItem({
    required String projectId,
    required EntityType type,
    required String? name,
    required String? summary,
    required Map<String, Object?> fields,
    required String role,
    required String suggestionId,
  }) async {
    final normalizedName = name?.trim();
    if (normalizedName == null || normalizedName.isEmpty) return null;
    final existing = _findCatalogItemByName(normalizedName, type);
    if (existing != null) return existing;
    return _createCatalogItem(
      CreateCatalogItemCommand(
        projectId: projectId,
        type: type,
        name: normalizedName,
        summary: summary?.trim() ?? '',
        fields: {
          ...fields,
          'contextRole': role,
          'sourceSuggestionId': suggestionId,
        },
      ),
    );
  }

  Future<Relationship?> _createContextRelationship({
    required String projectId,
    required Map<String, Object?> item,
    required String suggestionId,
  }) async {
    final sourceName = (item['sourceName'] as String?)?.trim();
    final targetName = (item['targetName'] as String?)?.trim();
    if (sourceName == null ||
        sourceName.isEmpty ||
        targetName == null ||
        targetName.isEmpty) {
      return null;
    }
    final source = await _findOrCreateNamedContextEntity(
      projectId: projectId,
      name: sourceName,
      suggestionId: suggestionId,
    );
    final target = await _findOrCreateNamedContextEntity(
      projectId: projectId,
      name: targetName,
      suggestionId: suggestionId,
    );
    final relationshipType =
        (item['type'] as String?)?.trim().isNotEmpty == true
            ? (item['type'] as String).trim()
            : 'relatedTo';
    final duplicate = _relationships.where(
      (relationship) =>
          relationship.source.type == source.type &&
          relationship.source.id == source.id &&
          relationship.target.type == target.type &&
          relationship.target.id == target.id &&
          relationship.relationshipType == relationshipType,
    );
    if (duplicate.isNotEmpty) return duplicate.first;
    final now = DateTime.now().toUtc();
    final relationship = Relationship(
      id: newLocalId('relationship'),
      projectId: projectId,
      source: EntityRef(type: source.type, id: source.id),
      target: EntityRef(type: target.type, id: target.id),
      relationshipType: relationshipType,
      label: (item['label'] as String?)?.trim().isEmpty == false
          ? (item['label'] as String).trim()
          : null,
      description: (item['description'] as String?)?.trim().isEmpty == false
          ? (item['description'] as String).trim()
          : null,
      strength: (item['strength'] as num?)?.toDouble(),
      direction: RelationshipDirection.directed,
      createdAt: now,
      updatedAt: now,
      metadata: {
        'contextRole': 'worldStarterRelationship',
        'sourceSuggestionId': suggestionId,
      },
    );
    await widget.relationshipRepository.save(relationship);
    return relationship;
  }

  Future<CatalogItem> _findOrCreateNamedContextEntity({
    required String projectId,
    required String name,
    required String suggestionId,
  }) async {
    final existing = _findCatalogItemByName(name, null);
    if (existing != null) return existing;
    return _createCatalogItem(
      CreateCatalogItemCommand(
        projectId: projectId,
        type: EntityType.character,
        name: name,
        summary: '',
        fields: {
          'contextRole': 'relationshipEndpoint',
          'sourceSuggestionId': suggestionId,
        },
      ),
    );
  }

  CatalogItem? _findCatalogItemByName(String name, EntityType? type) {
    final normalized = name.trim().toLowerCase();
    return _catalogItems
        .where(
          (item) =>
              (type == null || item.type == type) &&
              item.name.trim().toLowerCase() == normalized,
        )
        .firstOrNull;
  }

  Future<void> _deleteNote(ProjectNote note, WritellerCopy copy) async {
    final project = _selectedProject;
    if (project == null) return;

    await widget.projectNoteRepository.delete(note.id);
    final notes = await widget.projectNoteRepository.listForProject(project.id);
    if (!mounted) return;
    setState(() => _notes = notes);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(copy.t('noteDeleted'))),
    );
  }

  Future<ProjectNote?> _saveNote(
    WritellerCopy copy, {
    ProjectNote? existing,
    required String title,
    required String body,
    required EntityRef? target,
  }) async {
    final project = _selectedProject;
    if (project == null) return null;
    final now = DateTime.now().toUtc();
    final trimmedTitle = title.trim();
    final trimmedBody = body.trim();
    if (trimmedTitle.isEmpty && trimmedBody.isEmpty) return null;

    final note = existing == null
        ? ProjectNote(
            id: newLocalId('note'),
            projectId: project.id,
            target: target,
            title: trimmedTitle.isEmpty ? copy.t('untitledNote') : trimmedTitle,
            body: trimmedBody,
            source: 'manual',
            createdAt: now,
            updatedAt: now,
          )
        : existing.copyWith(
            target: target,
            clearTarget: target == null,
            title: trimmedTitle.isEmpty ? copy.t('untitledNote') : trimmedTitle,
            body: trimmedBody,
            updatedAt: now,
          );

    await widget.projectNoteRepository.save(note);
    final notes = await widget.projectNoteRepository.listForProject(project.id);
    if (!mounted) return note;
    setState(() => _notes = notes);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            existing == null ? copy.t('noteCreated') : copy.t('noteSaved')),
      ),
    );
    return note;
  }

  Future<void> _saveResearchItem(
    WritellerCopy copy, {
    ResearchItem? existing,
    required ResearchItemKind kind,
    required String title,
    required String uri,
    required String body,
    required String source,
    required List<String> tags,
    required EntityRef? target,
  }) async {
    final project = _selectedProject;
    if (project == null) return;

    final now = DateTime.now().toUtc();
    final item = existing == null
        ? ResearchItem(
            id: newLocalId('research'),
            projectId: project.id,
            kind: kind,
            target: target,
            title: title.trim().isEmpty
                ? copy.t('untitledResearchItem')
                : title.trim(),
            uri: uri.trim(),
            body: body.trim(),
            source: source.trim(),
            tags: tags,
            createdAt: now,
            updatedAt: now,
          )
        : existing.copyWith(
            kind: kind,
            target: target,
            clearTarget: target == null,
            title: title.trim().isEmpty
                ? copy.t('untitledResearchItem')
                : title.trim(),
            uri: uri.trim(),
            body: body.trim(),
            source: source.trim(),
            tags: tags,
            updatedAt: now,
          );

    await widget.researchItemRepository.save(item);
    final items =
        await widget.researchItemRepository.listForProject(project.id);
    if (!mounted) return;
    setState(() => _researchItems = items);
    await _recordProjectMetric(
      eventType: existing == null ? 'research.created' : 'research.updated',
      metadata: {'researchId': item.id, 'kind': item.kind.wireName},
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(copy.t('researchSaved'))),
    );
  }

  Future<void> _deleteResearchItem(
    ResearchItem item,
    WritellerCopy copy,
  ) async {
    final project = _selectedProject;
    if (project == null) return;

    await widget.researchItemRepository.delete(item.id);
    final items =
        await widget.researchItemRepository.listForProject(project.id);
    if (!mounted) return;
    setState(() => _researchItems = items);
    await _recordProjectMetric(
      eventType: 'research.deleted',
      metadata: {'researchId': item.id, 'kind': item.kind.wireName},
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(copy.t('researchDeleted'))),
    );
  }

  Future<void> _downloadExport(WritellerCopy copy) async {
    final project = _selectedProject;
    if (project == null) return;

    final artifact = _projectExporter.exportArtifact(
      project: project,
      chapters: _chapters,
      scenes: _scenes,
      catalogItems: _catalogItems,
      relationships: _relationships,
      notes: _notes,
      researchItems: _researchItems,
      profile: ExportProfile(
        id: 'ui-download',
        projectId: project.id,
        name: copy.t('exportPreview'),
        format: _selectedExportFormat,
        includeMetadata: true,
        includeSceneTitles: true,
      ),
    );
    await _downloadArtifact(copy, artifact, eventPrefix: 'export');
  }

  Future<void> _downloadPublishing(WritellerCopy copy) async {
    final project = _selectedProject;
    if (project == null) return;

    final artifact = _projectExporter.exportArtifact(
      project: project,
      chapters: _chapters,
      scenes: _scenes,
      catalogItems: _catalogItems,
      relationships: _relationships,
      notes: _notes,
      researchItems: _researchItems,
      profile: ExportProfile(
        id: 'ui-publishing',
        projectId: project.id,
        name: copy.t('selfPublishing'),
        format: _selectedPublishingFormat,
        publishingStyle: _selectedPublishingStyle,
        includeMetadata: _includePublishingMetadata,
        includeSceneTitles: _includeSceneTitles,
      ),
    );
    await _downloadArtifact(copy, artifact, eventPrefix: 'publishing');
  }

  Future<void> _savePublishingMetadata(
    Map<String, String> fields,
    WritellerCopy copy,
  ) async {
    final project = _selectedProject;
    if (project == null) return;
    final metadata = Map<String, Object?>.from(project.metadata);
    for (final entry in fields.entries) {
      final value = entry.value.trim();
      if (value.isEmpty) {
        metadata.remove(entry.key);
      } else {
        metadata[entry.key] = value;
      }
    }
    final updated = project.copyWith(metadata: metadata);
    await widget.projectRepository.save(updated);
    final projects = await widget.projectRepository.listActive();
    if (!mounted) return;
    setState(() {
      _projects = projects;
      _selectedProject = updated;
    });
    await _recordProjectMetric(
      eventType: 'publishing.metadata.updated',
      metadata: {'projectId': updated.id},
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(copy.t('publishingMetadataSaved'))),
    );
  }

  Future<void> _saveSmartCollectionIds(Set<String> collectionIds) async {
    final project = _selectedProject;
    if (project == null) return;
    final metadata = Map<String, Object?>.from(project.metadata);
    metadata['smartCollections'] = collectionIds.toList()..sort();
    final updated = project.copyWith(metadata: metadata);
    await widget.projectRepository.save(updated);
    final projects = await widget.projectRepository.listActive();
    if (!mounted) return;
    setState(() {
      _projects = projects;
      _selectedProject = updated;
    });
    await _recordProjectMetric(
      eventType: 'smartCollections.saved',
      value: collectionIds.length,
      metadata: {'projectId': updated.id},
    );
  }

  Future<void> _downloadArtifact(
    WritellerCopy copy,
    ExportArtifact artifact, {
    required String eventPrefix,
  }) async {
    final downloaded = await downloadExportArtifact(artifact);
    if (!mounted) return;
    await _recordProjectMetric(
      eventType:
          downloaded ? '$eventPrefix.downloaded' : '$eventPrefix.cancelled',
      value: artifact.bytes.length,
      metadata: {
        'format': artifact.fileName.split('.').last,
        'fileName': artifact.fileName,
        'mimeType': artifact.mimeType,
      },
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
              copy.t(downloaded ? 'exportDownloaded' : 'exportCancelled'))),
    );
  }

  Future<void> _copySyncCheckpoint(WritellerCopy copy) async {
    final project = _selectedProject;
    if (project == null) return;

    final checkpoint = _syncAdapter.createCheckpoint(_currentArchive(project));
    await Clipboard.setData(ClipboardData(text: checkpoint.payload));
    if (!mounted) return;
    setState(() => _lastSyncCheckpoint = checkpoint);
    await _recordProjectMetric(
      eventType: 'sync.checkpoint.copied',
      value: checkpoint.byteLength,
      metadata: {
        'adapter': checkpoint.adapterName,
        'fingerprint': checkpoint.fingerprint,
        'scenes': checkpoint.sceneCount,
        'chapters': checkpoint.chapterCount,
      },
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(copy.t('syncCheckpointCopied'))),
    );
  }

  void _refreshImportPreview() {
    final source = _importArchiveController.text.trim();
    if (source.isEmpty) {
      setState(() {
        _importPreview = null;
        _importPreviewError = null;
        _importSourceName = null;
        _syncImportPreview = null;
        _importInspection = null;
        _isImportDragging = false;
      });
      return;
    }

    try {
      final inspection = _projectImporter.inspect(
        source,
        sourceName: _importSourceName,
      );
      setState(() {
        _importPreview = inspection.preview;
        _importPreviewError = null;
        _syncImportPreview = inspection.syncEnvelope;
        _importInspection = inspection;
      });
    } catch (error) {
      setState(() {
        _importPreview = null;
        _importPreviewError = _providerErrorMessage(error);
        _syncImportPreview = null;
        _importInspection = null;
      });
    }
  }

  void _refreshPastedImportPreview() {
    _importSourceName = null;
    _refreshImportPreview();
  }

  Future<void> _importArchive(WritellerCopy copy) async {
    final source = _importArchiveController.text.trim();
    final inspection = _importInspection;
    if (source.isEmpty || inspection == null) return;

    try {
      final archive = inspection.archive;
      await widget.projectRepository.save(archive.project);
      for (final chapter in archive.chapters) {
        await widget.chapterRepository.save(chapter);
      }
      for (final scene in archive.scenes) {
        await widget.sceneRepository.save(scene);
      }
      for (final item in archive.catalogItems) {
        await widget.catalogItemRepository.save(item);
      }
      for (final relationship in archive.relationships) {
        await widget.relationshipRepository.save(relationship);
      }
      for (final note in archive.notes) {
        await widget.projectNoteRepository.save(note);
      }
      for (final item in archive.researchItems) {
        await widget.researchItemRepository.save(item);
      }

      final projects = await widget.projectRepository.listActive();
      final suggestions = await widget.aiSuggestionRepository
          .listForProject(archive.project.id);
      final notes = await widget.projectNoteRepository.listForProject(
        archive.project.id,
      );
      final researchItems = await widget.researchItemRepository.listForProject(
        archive.project.id,
      );
      if (!mounted) return;
      setState(() {
        _projects = projects;
        _selectedProject = archive.project;
        _chapters = archive.chapters;
        _scenes = archive.scenes;
        _catalogItems = archive.catalogItems;
        _relationships = archive.relationships;
        _suggestions = suggestions;
        _notes = notes;
        _researchItems = researchItems;
        _selectedScene = archive.scenes.firstOrNull;
        _syncSceneControllers(_selectedScene);
        _importArchiveController.clear();
        _importPreview = null;
        _importPreviewError = null;
        _importSourceName = null;
        _syncImportPreview = null;
        _importInspection = null;
        _isImportDragging = false;
      });
      await _recordMetric(
        projectId: archive.project.id,
        eventType: _importEventType(inspection.kind),
        metadata: {
          'importKind': inspection.kind.name,
          if (inspection.preview.sourceName != null)
            'sourceName': inspection.preview.sourceName,
          'scenes': archive.scenes.length,
          'catalogItems': archive.catalogItems.length,
          'relationships': archive.relationships.length,
          'notes': archive.notes.length,
          'researchItems': archive.researchItems.length,
          if (inspection.syncEnvelope != null)
            ...inspection.syncEnvelope!.toJson(),
        },
      );
      final metrics =
          await widget.metricRepository.listForProject(archive.project.id);
      if (mounted) {
        setState(() => _metrics = metrics);
      }
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(copy.t('importComplete'))),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    }
  }

  Future<void> _pickImportFile(WritellerCopy copy) async {
    final result = await FilePicker.pickFiles(
      dialogTitle: copy.t('chooseImportFile'),
      type: FileType.custom,
      allowedExtensions: const [
        'json',
        'yw5',
        'yw6',
        'yw7',
        'xml',
        'scrivx',
        'txt',
        'md',
      ],
      withData: true,
      lockParentWindow: true,
    );
    final file = result?.files.firstOrNull;
    final bytes = file?.bytes;
    if (file == null || bytes == null) return;
    _loadImportSource(
      utf8.decode(bytes, allowMalformed: true),
      sourceName: file.name,
    );
  }

  Future<void> _handleImportDrop(
    WritellerCopy copy,
    DropDoneDetails details,
  ) async {
    final file = details.files.firstOrNull;
    if (file == null) return;
    try {
      final bytes = await file.readAsBytes();
      _loadImportSource(
        utf8.decode(bytes, allowMalformed: true),
        sourceName: file.name,
      );
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _importPreview = null;
        _importPreviewError = _providerErrorMessage(error);
        _syncImportPreview = null;
        _importInspection = null;
      });
    }
  }

  void _loadImportSource(String source, {required String sourceName}) {
    _importArchiveController.text = source;
    setState(() => _importSourceName = sourceName);
    _refreshImportPreview();
  }

  String _importEventType(ProjectImportKind kind) {
    return switch (kind) {
      ProjectImportKind.writellerSyncCheckpoint => 'sync.checkpoint.imported',
      ProjectImportKind.writellerArchive => 'project.imported',
      ProjectImportKind.yWriter => 'project.imported.ywriter',
      ProjectImportKind.scrivenerOutline => 'project.imported.scrivener',
      ProjectImportKind.plainText => 'project.imported.text',
    };
  }

  Future<void> _saveProviderConfig(WritellerCopy copy) async {
    const providerId = 'default';
    final apiKeyInput =
        _aiProviderRuntime.normalizeApiKey(_apiKeyRefController.text);
    final existingApiKeyRef = _activeProviderConfig?.encryptedApiKeyRef;
    String? apiKeyRef = existingApiKeyRef;

    if (apiKeyInput.isNotEmpty) {
      apiKeyRef = _aiProviderRuntime.providerApiKeyRef(providerId);
      await widget.secretVault.write(ref: apiKeyRef, secret: apiKeyInput);
    }

    final config = AIProviderConfig(
      id: providerId,
      kind: _selectedProviderKind,
      displayName: _providerNameController.text.trim().isEmpty
          ? copy.t('providerNameFallback')
          : _providerNameController.text.trim(),
      modelName: _modelNameController.text.trim().isEmpty
          ? copy.t('modelNameFallback')
          : _modelNameController.text.trim(),
      baseUrl: _baseUrlController.text.trim().isEmpty
          ? null
          : _baseUrlController.text.trim(),
      encryptedApiKeyRef: apiKeyRef,
      enabled: _providerEnabled,
    );
    await widget.aiProviderConfigRepository.save(config);
    if (!mounted) return;
    setState(() => _syncProviderConfig(config));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(copy.t('providerConfigSaved'))),
    );
  }

  Future<void> _deleteProviderApiKey(WritellerCopy copy) async {
    final config = _activeProviderConfig;
    final ref = config?.encryptedApiKeyRef;
    if (config == null || ref == null) return;

    await widget.secretVault.delete(ref);
    final updated = AIProviderConfig(
      id: config.id,
      kind: config.kind,
      displayName: config.displayName,
      modelName: config.modelName,
      baseUrl: config.baseUrl,
      parameters: config.parameters,
      enabled: config.enabled,
    );
    await widget.aiProviderConfigRepository.save(updated);
    if (!mounted) return;
    setState(() => _syncProviderConfig(updated));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(copy.t('apiKeyDeleted'))),
    );
  }

  String _workspaceTitle(WritellerCopy copy) => switch (_selectedRailIndex) {
        0 => copy.t('dashboard'),
        1 => copy.t('manuscript'),
        2 => copy.t('structureCockpit'),
        13 => copy.t('sceneBoard'),
        17 => copy.t('storyboard'),
        20 => copy.t('storyContext'),
        3 => copy.t('characters'),
        4 => copy.t('locations'),
        5 => copy.t('objects'),
        14 => copy.t('timeline'),
        15 => copy.t('relationshipGraph'),
        19 => copy.t('researchLibrary'),
        6 => copy.t('analysis'),
        18 => copy.t('styleCockpit'),
        21 => copy.t('smartCollections'),
        7 => copy.t('notesCockpit'),
        8 => copy.t('aiWorkshop'),
        9 => copy.t('exports'),
        11 => copy.t('protocols'),
        12 => copy.t('selfPublishing'),
        16 => copy.t('statistics'),
        _ => copy.t('settings'),
      };

  IconData _workspaceIcon() => switch (_selectedRailIndex) {
        0 => Icons.dashboard_outlined,
        1 => Icons.edit_note_outlined,
        2 => Icons.account_tree_outlined,
        13 => Icons.view_kanban_outlined,
        17 => Icons.polyline_outlined,
        20 => Icons.public_outlined,
        3 => Icons.person_outline,
        4 => Icons.place_outlined,
        5 => Icons.category_outlined,
        14 => Icons.timeline_outlined,
        15 => Icons.hub_outlined,
        19 => Icons.travel_explore_outlined,
        6 => Icons.query_stats_outlined,
        18 => Icons.auto_graph_outlined,
        21 => Icons.collections_bookmark_outlined,
        7 => Icons.sticky_note_2_outlined,
        8 => Icons.psychology_alt_outlined,
        9 => Icons.ios_share_outlined,
        11 => Icons.receipt_long_outlined,
        12 => Icons.auto_stories_outlined,
        16 => Icons.bar_chart_outlined,
        _ => Icons.tune_outlined,
      };

  _WorkspaceNavGroup _workspaceGroupForIndex(int index) {
    final navItem = _navItems.where((item) => item.index == index).firstOrNull;
    if (navItem != null) return navItem.group;
    return switch (index) {
      16 => _WorkspaceNavGroup.output,
      _ => _WorkspaceNavGroup.output,
    };
  }

  String _workspaceGroupTitle(WritellerCopy copy) {
    return _navGroupLabel(_workspaceGroupForIndex(_selectedRailIndex), copy);
  }

  Future<void> _openCommandPalette(WritellerCopy copy) async {
    final entries = _commandPaletteEntries(copy);
    final selected = await showDialog<_CommandPaletteEntry>(
      context: context,
      builder: (context) => _CommandPaletteDialog(
        copy: copy,
        entries: entries,
      ),
    );
    selected?.run();
  }

  List<_CommandPaletteEntry> _commandPaletteEntries(WritellerCopy copy) {
    final workspaceEntries = [
      for (final item in _navItems)
        _CommandPaletteEntry(
          title: item.labelBuilder(copy),
          subtitle: _navGroupLabel(item.group, copy),
          icon: item.icon,
          run: () => setState(() => _selectedRailIndex = item.index),
        ),
    ];
    final secondaryWorkspaceEntries = [
      _CommandPaletteEntry(
        title: copy.t('statistics'),
        subtitle: '${_navGroupLabel(_WorkspaceNavGroup.output, copy)} · '
            '${copy.t('workspace')}',
        icon: Icons.bar_chart_outlined,
        run: () => setState(() => _selectedRailIndex = 16),
      ),
    ];
    final sceneEntries = [
      for (final scene in _scenes)
        _CommandPaletteEntry(
          title: scene.title,
          subtitle: copy.t('scene'),
          icon: Icons.notes_outlined,
          run: () {
            _selectScene(scene);
            setState(() => _selectedRailIndex = 1);
          },
        ),
    ];
    final catalogEntries = [
      for (final item in _catalogItems)
        _CommandPaletteEntry(
          title: item.name,
          subtitle: copy.t(_catalogTitleKey(item.type)),
          icon: _catalogIcon(item.type),
          run: () => setState(
            () => _selectedRailIndex = switch (item.type) {
              EntityType.character => 3,
              EntityType.location => 4,
              EntityType.object => 5,
              EntityType.timelineEvent => 14,
              _ => 2,
            },
          ),
        ),
    ];
    return [
      ...workspaceEntries,
      ...secondaryWorkspaceEntries,
      ...sceneEntries,
      ...catalogEntries,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final copy = WritellerCopy(Localizations.localeOf(context).languageCode);
    final color = Theme.of(context).colorScheme;

    return Shortcuts(
      shortcuts: const {
        SingleActivator(LogicalKeyboardKey.keyK, control: true):
            _OpenCommandPaletteIntent(),
        SingleActivator(LogicalKeyboardKey.keyK, meta: true):
            _OpenCommandPaletteIntent(),
      },
      child: Actions(
        actions: {
          _OpenCommandPaletteIntent: CallbackAction<_OpenCommandPaletteIntent>(
            onInvoke: (intent) {
              unawaited(_openCommandPalette(copy));
              return null;
            },
          ),
        },
        child: Scaffold(
          backgroundColor: color.surface,
          body: Material(
            color: color.surface,
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: color.outlineVariant.withValues(alpha: 0.7),
                  ),
                ),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final compactNavigation =
                      _navigationCollapsed || constraints.maxWidth < 560;
                  return Row(
                    children: [
                      _WorkspaceNavigation(
                        copy: copy,
                        items: _navItems,
                        selectedIndex: _selectedRailIndex,
                        collapsed: compactNavigation,
                        onToggleCollapsed: () => setState(
                          () => _navigationCollapsed = !_navigationCollapsed,
                        ),
                        onSelected: (index) =>
                            setState(() => _selectedRailIndex = index),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            _StudioTopBar(
                              copy: copy,
                              workspaceTitle: _workspaceTitle(copy),
                              workspaceGroupLabel: _workspaceGroupTitle(copy),
                              workspaceIcon: _workspaceIcon(),
                              project: _selectedProject,
                              languageCode: widget.languageCode,
                              onLanguageChanged: widget.onLanguageChanged,
                              globalAiEnabled: widget.globalAiEnabled,
                              noAiNoCloud: widget.globalNoAiNoCloud,
                              onGlobalAiChanged: (enabled) =>
                                  widget.onGlobalProfileSettingsChanged(
                                aiEnabled: enabled,
                                cloudSyncEnabled: widget.globalCloudSyncEnabled,
                                noAiNoCloud:
                                    enabled ? false : widget.globalNoAiNoCloud,
                              ),
                              showCreateProject:
                                  _selectedRailIndex == 0 || _projects.isEmpty,
                              onCreateProject: () =>
                                  _showCreateProjectDialog(copy),
                              onOpenCommandPalette: () =>
                                  _openCommandPalette(copy),
                            ),
                            const Divider(height: 1),
                            Expanded(
                              child: _buildSelectedWorkspace(copy),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedWorkspace(WritellerCopy copy) {
    if (_projects.isEmpty && !_isGlobalWorkspace(_selectedRailIndex)) {
      return _EmptyWorkspace(copy: copy);
    }

    return switch (_selectedRailIndex) {
      0 => _ProjectOverview(
          copy: copy,
          projects: _projects,
          selectedProject: _selectedProject,
          chapters: _chapters,
          scenes: _scenes,
          notes: _notes,
          catalogItems: _catalogItems,
          relationships: _relationships,
          metrics: _metrics,
          suggestions: _suggestions,
          onSelectProject: _selectProject,
          onDeleteProject: (project) => _deleteProject(project, copy),
          onOpenEditor: () => setState(() => _selectedRailIndex = 1),
          onOpenStructure: () => setState(() => _selectedRailIndex = 2),
          onOpenNotes: () => setState(() => _selectedRailIndex = 7),
          onOpenAiWorkshop: () => setState(() => _selectedRailIndex = 8),
          onOpenStatistics: () => setState(() => _selectedRailIndex = 16),
          onOpenScene: (scene) {
            _selectScene(scene);
            setState(() => _selectedRailIndex = 1);
          },
        ),
      1 => _WorkspaceView(
          copy: copy,
          projects: _projects,
          selectedProject: _selectedProject,
          scenes: _scenes,
          chapters: _chapters,
          catalogItems: _catalogItems,
          relationships: _relationships,
          researchItems: _researchItems,
          suggestions: _suggestions,
          selectedScene: _selectedScene,
          manuscriptController: _manuscriptController,
          summaryController: _summaryController,
          goalController: _goalController,
          conflictController: _conflictController,
          outcomeController: _outcomeController,
          wordTargetController: _wordTargetController,
          selectedSceneStatus: _selectedSceneStatus,
          selectedSceneChapterId: _selectedSceneChapterId,
          sceneSaveState: _sceneSaveState,
          lastSceneSavedAt: _lastSceneSavedAt,
          sceneSnapshots: _sceneSnapshots,
          spellCheckSettings: widget.spellCheckSettings,
          spellChecker: widget.spellChecker,
          onSelectProject: _selectProject,
          onDeleteProject: (project) => _deleteProject(project, copy),
          onSelectScene: _selectScene,
          onDeleteScene: (scene) => _deleteScene(scene, copy),
          onSceneChapterChanged: (chapterId) => setState(
            () => _selectedSceneChapterId = chapterId,
          ),
          onToggleSceneCatalogLink: _toggleSceneCatalogLink,
          onAddExistingSceneCatalogItems: _addExistingSceneCatalogItems,
          onCreateSceneCatalogItem: (type) =>
              _createSceneCatalogItem(copy, type),
          onSceneStatusChanged: (status) => setState(
            () => _selectedSceneStatus = status,
          ),
          onCreateChapter: () => _showCreateChapterDialog(copy),
          onCreateScene: () => _showCreateSceneDialog(copy),
          isRequestingAi: _isRequestingAi,
          onRequestSceneAiHelp: (task, prompt) =>
              _requestEditorSceneAiHelp(copy, task, prompt),
          onCreateSceneSnapshot: () => _createManualSceneSnapshot(copy),
          onRestoreSceneSnapshot: (snapshot) =>
              _restoreSceneSnapshot(snapshot, copy),
          onDeleteSceneSnapshot: (snapshot) =>
              _deleteSceneSnapshot(snapshot, copy),
          onSaveSceneAnnotations: _saveSelectedSceneAnnotations,
          onSaveScene: () => _saveSelectedScene(copy),
          onSaveSceneManuscript: (scene, manuscriptText) =>
              _saveSceneManuscriptText(scene, manuscriptText, copy),
          onOpenContext: () => setState(() => _selectedRailIndex = 20),
        ),
      2 => _SceneBoard(
          copy: copy,
          chapters: _chapters,
          scenes: _scenes,
          catalogItems: _catalogItems,
          relationships: _relationships,
          selectedScene: _selectedScene,
          onSelectScene: (scene) {
            _selectScene(scene);
            setState(() => _selectedRailIndex = 1);
          },
          onMoveSceneUp: (scene) => _moveSceneInStructure(scene, -1),
          onMoveSceneDown: (scene) => _moveSceneInStructure(scene, 1),
          onMoveSceneToChapter: _moveSceneToChapter,
          onDropSceneToChapter: (scene, chapterId) => _moveSceneToChapterOrder(
            scene,
            chapterId: chapterId,
          ),
          onDeleteScene: (scene) => _deleteScene(scene, copy),
          onDeleteChapter: (chapter) => _deleteChapter(chapter, copy),
          onCreateScene: () => _showCreateSceneDialog(copy),
          onCreateChapter: () => _showCreateChapterDialog(copy),
          onCreateRelationship: (source) => _showRelationshipDialog(
            copy,
            initialSource: source,
          ),
          onEditRelationship: (relationship) => _showRelationshipDialog(
            copy,
            existing: relationship,
          ),
          onDeleteRelationship: (relationship) =>
              _deleteRelationship(relationship, copy),
        ),
      13 => _SceneStatusBoard(
          copy: copy,
          scenes: _scenes,
          onOpenScene: (scene) {
            _selectScene(scene);
            setState(() => _selectedRailIndex = 1);
          },
          onCreateScene: () => _showCreateSceneDialog(copy),
          onDeleteScene: (scene) => _deleteScene(scene, copy),
          onChangeSceneStatus: _changeSceneStatus,
        ),
      17 => _StoryboardWorkspace(
          copy: copy,
          project: _selectedProject,
          scenes: _scenes,
          catalogItems: _catalogItems,
          notes: _notes,
          onSaveStoryboard: _saveStoryboardState,
          onReorderScene: _reorderSceneFromStoryboard,
        ),
      20 => _ContextWorkspace(
          copy: copy,
          project: _selectedProject,
          suggestions: _suggestions,
          isRequestingAi: _isRequestingAi,
          lastAiError: _lastAiError,
          onSaveContext: _saveProjectContext,
          onRequestStarter: () => _requestWorldStarter(copy),
          onAcceptSuggestion: (suggestion) =>
              _decideSuggestion(copy, suggestion, SuggestionDecision.accepted),
          onRejectSuggestion: (suggestion) =>
              _decideSuggestion(copy, suggestion, SuggestionDecision.rejected),
        ),
      3 => _CatalogWorkspace(
          copy: copy,
          type: EntityType.character,
          items: _catalogItems
              .where((item) => item.type == EntityType.character)
              .toList(),
          onCreateItem: () =>
              _showCreateCatalogItemDialog(copy, EntityType.character),
          onEditItem: (item) => _showEditCatalogItemDialog(copy, item),
          onDeleteItem: (item) => _deleteCatalogItem(item, copy),
        ),
      4 => _CatalogWorkspace(
          copy: copy,
          type: EntityType.location,
          items: _catalogItems
              .where((item) => item.type == EntityType.location)
              .toList(),
          onCreateItem: () =>
              _showCreateCatalogItemDialog(copy, EntityType.location),
          onEditItem: (item) => _showEditCatalogItemDialog(copy, item),
          onDeleteItem: (item) => _deleteCatalogItem(item, copy),
        ),
      5 => _CatalogWorkspace(
          copy: copy,
          type: EntityType.object,
          items: _catalogItems
              .where((item) => item.type == EntityType.object)
              .toList(),
          onCreateItem: () =>
              _showCreateCatalogItemDialog(copy, EntityType.object),
          onEditItem: (item) => _showEditCatalogItemDialog(copy, item),
          onDeleteItem: (item) => _deleteCatalogItem(item, copy),
        ),
      14 => _TimelineWorkspace(
          copy: copy,
          scenes: _scenes,
          catalogItems: _catalogItems,
          onOpenScene: (scene) {
            _selectScene(scene);
            setState(() => _selectedRailIndex = 1);
          },
        ),
      15 => _RelationshipGraphWorkspace(
          copy: copy,
          relationships: _relationships,
          scenes: _scenes,
          catalogItems: _catalogItems,
          onCreateRelationship: (source) => _showRelationshipDialog(
            copy,
            initialSource: source,
          ),
          onEditRelationship: (relationship) => _showRelationshipDialog(
            copy,
            existing: relationship,
          ),
          onDeleteRelationship: (relationship) =>
              _deleteRelationship(relationship, copy),
        ),
      19 => _ResearchWorkspace(
          copy: copy,
          project: _selectedProject,
          items: _researchItems,
          scenes: _scenes,
          catalogItems: _catalogItems,
          onSaveItem: ({
            existing,
            required kind,
            required title,
            required uri,
            required body,
            required source,
            required tags,
            required target,
          }) =>
              _saveResearchItem(
            copy,
            existing: existing,
            kind: kind,
            title: title,
            uri: uri,
            body: body,
            source: source,
            tags: tags,
            target: target,
          ),
          onDeleteItem: (item) => _deleteResearchItem(item, copy),
        ),
      6 => _AnalysisWorkspace(
          copy: copy,
          chapters: _chapters,
          scenes: _scenes,
          catalogItems: _catalogItems,
          relationships: _relationships,
          onOpenScene: (scene) {
            _selectScene(scene);
            setState(() => _selectedRailIndex = 1);
          },
        ),
      18 => _StyleCockpit(
          copy: copy,
          chapters: _chapters,
          scenes: _scenes,
          selectedScene: _selectedScene,
          onOpenScene: (scene) {
            _selectScene(scene);
            setState(() => _selectedRailIndex = 1);
          },
        ),
      21 => _SmartCollectionsWorkspace(
          copy: copy,
          project: _selectedProject,
          chapters: _chapters,
          scenes: _scenes,
          catalogItems: _catalogItems,
          suggestions: _suggestions,
          notes: _notes,
          onSaveCollections: _saveSmartCollectionIds,
          onOpenScene: (scene) {
            _selectScene(scene);
            setState(() => _selectedRailIndex = 1);
          },
          onOpenAiWorkshop: () => setState(() => _selectedRailIndex = 8),
          onOpenNotes: () => setState(() => _selectedRailIndex = 7),
          onOpenStructure: () => setState(() => _selectedRailIndex = 2),
        ),
      7 => _NotesCockpit(
          copy: copy,
          project: _selectedProject,
          notes: _notes,
          scenes: _scenes,
          catalogItems: _catalogItems,
          onSaveNote: ({
            existing,
            required title,
            required body,
            required target,
          }) =>
              _saveNote(
            copy,
            existing: existing,
            title: title,
            body: body,
            target: target,
          ),
          onDeleteNote: (note) => _deleteNote(note, copy),
          onOpenScene: (scene) {
            _selectScene(scene);
            setState(() => _selectedRailIndex = 1);
          },
        ),
      8 => _AIWorkshop(
          copy: copy,
          project: _selectedProject,
          selectedScene: _selectedScene,
          chapters: _chapters,
          scenes: _scenes,
          catalogItems: _catalogItems,
          relationships: _relationships,
          suggestions: _suggestions,
          notes: _notes,
          activeProviderConfig:
              _activeProviderConfig ?? _aiProviderRuntime.defaultConfig(),
          promptController: _aiPromptController,
          isRequesting: _isRequestingAi,
          lastError: _lastAiError,
          onSelectScene: _selectScene,
          onRequestTask: (
            task, {
            required contextKind,
            scene,
            required contextCatalogItems,
            required contextRelationships,
          }) =>
              _requestAiSuggestion(
            copy,
            task,
            contextKind: contextKind,
            scene: scene,
            contextCatalogItems: contextCatalogItems,
            contextRelationships: contextRelationships,
          ),
          onAcceptSuggestion: (suggestion) =>
              _decideSuggestion(copy, suggestion, SuggestionDecision.accepted),
          onRejectSuggestion: (suggestion) =>
              _decideSuggestion(copy, suggestion, SuggestionDecision.rejected),
          onConvertSuggestion: (suggestion) => _decideSuggestion(
              copy, suggestion, SuggestionDecision.convertedToNote),
          onDeleteNote: (note) => _deleteNote(note, copy),
        ),
      11 => _ProtocolsWorkspace(
          copy: copy,
          project: _selectedProject,
          metrics: _metrics,
        ),
      9 => _ExportCenter(
          copy: copy,
          project: _selectedProject,
          chapters: _chapters,
          scenes: _scenes,
          notes: _notes,
          researchItems: _researchItems,
          exporter: _projectExporter,
          catalogItems: _catalogItems,
          relationships: _relationships,
          format: _selectedExportFormat,
          importController: _importArchiveController,
          importPreview: _importPreview,
          importPreviewError: _importPreviewError,
          importSourceName: _importSourceName,
          isImportDragging: _isImportDragging,
          lastSyncCheckpoint: _lastSyncCheckpoint,
          syncImportPreview: _syncImportPreview,
          onFormatChanged: (format) =>
              setState(() => _selectedExportFormat = format),
          onDownloadExport: () => _downloadExport(copy),
          onCopySyncCheckpoint: () => _copySyncCheckpoint(copy),
          onImportSourceChanged: _refreshPastedImportPreview,
          onPickImportFile: () => _pickImportFile(copy),
          onImportDropped: (details) => _handleImportDrop(copy, details),
          onImportDragChanged: (value) =>
              setState(() => _isImportDragging = value),
          onImportArchive: () => _importArchive(copy),
        ),
      12 => _SelfPublishingCenter(
          copy: copy,
          project: _selectedProject,
          chapters: _chapters,
          scenes: _scenes,
          notes: _notes,
          catalogItems: _catalogItems,
          relationships: _relationships,
          format: _selectedPublishingFormat,
          publishingStyle: _selectedPublishingStyle,
          includeSceneTitles: _includeSceneTitles,
          includeMetadata: _includePublishingMetadata,
          exporter: _projectExporter,
          onFormatChanged: (format) =>
              setState(() => _selectedPublishingFormat = format),
          onPublishingStyleChanged: (style) =>
              setState(() => _selectedPublishingStyle = style),
          onIncludeSceneTitlesChanged: (value) =>
              setState(() => _includeSceneTitles = value),
          onIncludeMetadataChanged: (value) =>
              setState(() => _includePublishingMetadata = value),
          onSavePublishingMetadata: (fields) =>
              _savePublishingMetadata(fields, copy),
          onDownload: () => _downloadPublishing(copy),
        ),
      16 => _StatisticsWorkspace(
          copy: copy,
          project: _selectedProject,
          chapters: _chapters,
          scenes: _scenes,
          catalogItems: _catalogItems,
          relationships: _relationships,
          metrics: _metrics,
        ),
      _ => _SettingsWorkspace(
          copy: copy,
          project: _selectedProject,
          aiEnabled: widget.globalAiEnabled,
          cloudSyncEnabled: widget.globalCloudSyncEnabled,
          noAiNoCloud: widget.globalNoAiNoCloud,
          providerNameController: _providerNameController,
          modelNameController: _modelNameController,
          baseUrlController: _baseUrlController,
          apiKeyRefController: _apiKeyRefController,
          providerKind: _selectedProviderKind,
          providerEnabled: _providerEnabled,
          providerHasStoredApiKey: _providerHasStoredApiKey,
          activeProviderConfig: _activeProviderConfig,
          designTheme: widget.designTheme,
          onDesignThemeChanged: widget.onDesignThemeChanged,
          onProviderKindChanged: _selectProviderKind,
          onProviderEnabledChanged: (enabled) =>
              setState(() => _providerEnabled = enabled),
          onSaveProviderConfig: () => _saveProviderConfig(copy),
          onDeleteProviderApiKey: () => _deleteProviderApiKey(copy),
          onSaveProjectMetadata: _saveProjectMetadata,
          onSaveProfileSettings: widget.onGlobalProfileSettingsChanged,
          spellCheckSettings: widget.spellCheckSettings,
          onSpellCheckSettingsChanged: widget.onSpellCheckSettingsChanged,
          syncAdapterName: _syncAdapter.adapterName,
        ),
    };
  }

  bool _isGlobalWorkspace(int index) {
    return index == 9 || index == 10;
  }
}
