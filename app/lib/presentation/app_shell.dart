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

  final WritelerCopy copy;
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

final class WritelerShell extends StatefulWidget {
  const WritelerShell({
    required this.projectRepository,
    required this.sceneRepository,
    required this.chapterRepository,
    required this.catalogItemRepository,
    required this.relationshipRepository,
    required this.metricRepository,
    required this.aiSuggestionRepository,
    required this.projectNoteRepository,
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
    super.key,
  });

  final ProjectRepository projectRepository;
  final SceneRepository sceneRepository;
  final ChapterRepository chapterRepository;
  final CatalogItemRepository catalogItemRepository;
  final RelationshipRepository relationshipRepository;
  final MetricRepository metricRepository;
  final AISuggestionRepository aiSuggestionRepository;
  final ProjectNoteRepository projectNoteRepository;
  final AIProviderConfigRepository aiProviderConfigRepository;
  final SecretVault secretVault;
  final WritelerDesignTheme designTheme;
  final ValueChanged<WritelerDesignTheme> onDesignThemeChanged;
  final String languageCode;
  final ValueChanged<String> onLanguageChanged;
  final bool globalAiEnabled;
  final bool globalCloudSyncEnabled;
  final bool globalNoAiNoCloud;
  final FutureOr<void> Function({
    required bool aiEnabled,
    required bool cloudSyncEnabled,
    required bool noAiNoCloud,
  }) onGlobalProfileSettingsChanged;

  @override
  State<WritelerShell> createState() => _WritelerShellState();
}

final class _WritelerShellState extends State<WritelerShell> {
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
  Project? _selectedProject;
  Scene? _selectedScene;
  String? _selectedSceneChapterId;
  DraftStatus _selectedSceneStatus = DraftStatus.planned;
  int _selectedRailIndex = 1;
  ExportFormat _selectedPublishingFormat = ExportFormat.pdf;
  bool _includeSceneTitles = true;
  bool _includePublishingMetadata = false;
  bool _isRequestingAi = false;
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
      index: 1,
      icon: Icons.edit_note_outlined,
      selectedIcon: Icons.edit_note,
      labelBuilder: (copy) => copy.t('editor'),
      group: _WorkspaceNavGroup.write,
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
      index: 16,
      icon: Icons.bar_chart_outlined,
      selectedIcon: Icons.bar_chart,
      labelBuilder: (copy) => copy.t('statistics'),
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
      final copy = WritelerCopy(Localizations.localeOf(context).languageCode);
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
    final scenes = await scenesFuture;
    final chapters = await chaptersFuture;
    final catalogItems = await catalogFuture;
    final relationships = await relationshipsFuture;
    final metrics = await metricsFuture;
    final suggestions = await suggestionsFuture;
    final notes = await notesFuture;
    if (!mounted) return;
    setState(() {
      _scenes = scenes;
      _chapters = chapters;
      _catalogItems = catalogItems;
      _relationships = relationships;
      _metrics = metrics;
      _suggestions = suggestions;
      _notes = notes;
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
        final copy = WritelerCopy(Localizations.localeOf(context).languageCode);
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
    WritelerCopy copy, {
    bool showSnackBar = true,
    bool recordMetric = true,
  }) async {
    final scene = _selectedScene;
    final project = _selectedProject;
    if (scene == null || project == null) return;

    _autosaveTimer?.cancel();
    final wordTargetText = _wordTargetController.text.trim();
    final wordTarget = int.tryParse(wordTargetText);
    final updated = scene.copyWith(
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

  Future<void> _deleteProject(Project project, WritelerCopy copy) async {
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

  Future<void> _deleteChapter(Chapter chapter, WritelerCopy copy) async {
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

  Future<void> _deleteScene(Scene scene, WritelerCopy copy) async {
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

  Future<void> _deleteCatalogItem(CatalogItem item, WritelerCopy copy) async {
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
    WritelerCopy copy,
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

  Future<void> _saveProjectAuthorName(String authorName) async {
    final project = _selectedProject;
    if (project == null) return;
    final trimmed = authorName.trim();
    final metadata = Map<String, Object?>.from(project.metadata);
    if (trimmed.isEmpty) {
      metadata.remove('authorName');
    } else {
      metadata['authorName'] = trimmed;
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
      eventType: 'project.author.updated',
      metadata: {'authorNameSet': trimmed.isNotEmpty},
    );
  }

  Future<void> _requestAiSuggestion(
    WritelerCopy copy,
    AITaskKind task, {
    required _AIWorkshopContextKind contextKind,
    Scene? scene,
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
        );
      } else {
        await requester.forScene(
          project: _effectiveProjectForGlobalProfile(project),
          scene: targetScene!,
          task: task,
          languageCode: copy.languageCode,
          userPrompt: userPrompt,
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
    WritelerCopy copy,
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
        return WritelerCopy(Localizations.localeOf(context).languageCode)
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
    WritelerCopy copy,
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

  Future<void> _deleteNote(ProjectNote note, WritelerCopy copy) async {
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
    WritelerCopy copy, {
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

  Future<void> _downloadExport(WritelerCopy copy) async {
    final project = _selectedProject;
    if (project == null) return;

    final artifact = _projectExporter.exportArtifact(
      project: project,
      chapters: _chapters,
      scenes: _scenes,
      catalogItems: _catalogItems,
      relationships: _relationships,
      notes: _notes,
      profile: ExportProfile(
        id: 'ui-download',
        projectId: project.id,
        name: copy.t('exportPreview'),
        format: ExportFormat.json,
        includeMetadata: true,
        includeSceneTitles: true,
      ),
    );
    await _downloadArtifact(copy, artifact, eventPrefix: 'export');
  }

  Future<void> _downloadPublishing(WritelerCopy copy) async {
    final project = _selectedProject;
    if (project == null) return;

    final artifact = _projectExporter.exportArtifact(
      project: project,
      chapters: _chapters,
      scenes: _scenes,
      catalogItems: _catalogItems,
      relationships: _relationships,
      notes: _notes,
      profile: ExportProfile(
        id: 'ui-publishing',
        projectId: project.id,
        name: copy.t('selfPublishing'),
        format: _selectedPublishingFormat,
        includeMetadata: _includePublishingMetadata,
        includeSceneTitles: _includeSceneTitles,
      ),
    );
    await _downloadArtifact(copy, artifact, eventPrefix: 'publishing');
  }

  Future<void> _downloadArtifact(
    WritelerCopy copy,
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

  Future<void> _copySyncCheckpoint(WritelerCopy copy) async {
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

  Future<void> _importArchive(WritelerCopy copy) async {
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

      final projects = await widget.projectRepository.listActive();
      final suggestions = await widget.aiSuggestionRepository
          .listForProject(archive.project.id);
      final notes = await widget.projectNoteRepository.listForProject(
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

  Future<void> _pickImportFile(WritelerCopy copy) async {
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
    WritelerCopy copy,
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
      ProjectImportKind.writelerSyncCheckpoint => 'sync.checkpoint.imported',
      ProjectImportKind.writelerArchive => 'project.imported',
      ProjectImportKind.yWriter => 'project.imported.ywriter',
      ProjectImportKind.scrivenerOutline => 'project.imported.scrivener',
      ProjectImportKind.plainText => 'project.imported.text',
    };
  }

  Future<void> _saveProviderConfig(WritelerCopy copy) async {
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

  Future<void> _deleteProviderApiKey(WritelerCopy copy) async {
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

  String _workspaceTitle(WritelerCopy copy) => switch (_selectedRailIndex) {
        0 => copy.t('dashboard'),
        1 => copy.t('manuscript'),
        2 => copy.t('structureCockpit'),
        13 => copy.t('sceneBoard'),
        3 => copy.t('characters'),
        4 => copy.t('locations'),
        5 => copy.t('objects'),
        14 => copy.t('timeline'),
        15 => copy.t('relationshipGraph'),
        6 => copy.t('analysis'),
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
        3 => Icons.person_outline,
        4 => Icons.place_outlined,
        5 => Icons.category_outlined,
        14 => Icons.timeline_outlined,
        15 => Icons.hub_outlined,
        6 => Icons.query_stats_outlined,
        7 => Icons.sticky_note_2_outlined,
        8 => Icons.psychology_alt_outlined,
        9 => Icons.ios_share_outlined,
        11 => Icons.receipt_long_outlined,
        12 => Icons.auto_stories_outlined,
        16 => Icons.bar_chart_outlined,
        _ => Icons.tune_outlined,
      };

  Future<void> _openCommandPalette(WritelerCopy copy) async {
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

  List<_CommandPaletteEntry> _commandPaletteEntries(WritelerCopy copy) {
    final workspaceEntries = [
      for (final item in _navItems)
        _CommandPaletteEntry(
          title: item.labelBuilder(copy),
          subtitle: copy.t('workspace'),
          icon: item.icon,
          run: () => setState(() => _selectedRailIndex = item.index),
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
              _ => 2,
            },
          ),
        ),
    ];
    return [...workspaceEntries, ...sceneEntries, ...catalogEntries];
  }

  @override
  Widget build(BuildContext context) {
    final copy = WritelerCopy(Localizations.localeOf(context).languageCode);
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
              child: Row(
                children: [
                  _WorkspaceNavigation(
                    copy: copy,
                    items: _navItems,
                    selectedIndex: _selectedRailIndex,
                    onSelected: (index) =>
                        setState(() => _selectedRailIndex = index),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        _StudioTopBar(
                          copy: copy,
                          workspaceTitle: _workspaceTitle(copy),
                          workspaceIcon: _workspaceIcon(),
                          project: _selectedProject,
                          languageCode: widget.languageCode,
                          onLanguageChanged: widget.onLanguageChanged,
                          showCreateProject:
                              _selectedRailIndex == 0 || _projects.isEmpty,
                          onCreateProject: () => _showCreateProjectDialog(copy),
                          onOpenCommandPalette: () => _openCommandPalette(copy),
                        ),
                        const Divider(height: 1),
                        Expanded(
                          child: _buildSelectedWorkspace(copy),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedWorkspace(WritelerCopy copy) {
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
          onSaveScene: () => _saveSelectedScene(copy),
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
          }) =>
              _requestAiSuggestion(
            copy,
            task,
            contextKind: contextKind,
            scene: scene,
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
          exporter: _projectExporter,
          catalogItems: _catalogItems,
          relationships: _relationships,
          importController: _importArchiveController,
          importPreview: _importPreview,
          importPreviewError: _importPreviewError,
          importSourceName: _importSourceName,
          isImportDragging: _isImportDragging,
          lastSyncCheckpoint: _lastSyncCheckpoint,
          syncImportPreview: _syncImportPreview,
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
          includeSceneTitles: _includeSceneTitles,
          includeMetadata: _includePublishingMetadata,
          exporter: _projectExporter,
          onFormatChanged: (format) =>
              setState(() => _selectedPublishingFormat = format),
          onIncludeSceneTitlesChanged: (value) =>
              setState(() => _includeSceneTitles = value),
          onIncludeMetadataChanged: (value) =>
              setState(() => _includePublishingMetadata = value),
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
          onSaveProjectAuthorName: _saveProjectAuthorName,
          onSaveProfileSettings: widget.onGlobalProfileSettingsChanged,
          syncAdapterName: _syncAdapter.adapterName,
        ),
    };
  }

  bool _isGlobalWorkspace(int index) {
    return index == 9 || index == 10;
  }
}
