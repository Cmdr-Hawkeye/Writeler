part of '../main.dart';

// Stateful application shell: orchestration, repositories, commands, and workspace routing.

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
  ExportFormat _selectedExportFormat = ExportFormat.markdown;
  bool _includeSceneTitles = true;
  bool _includeExportMetadata = false;
  bool _isRequestingAi = false;
  String? _lastAiError;
  ProjectArchivePreview? _importPreview;
  String? _importPreviewError;
  SyncCheckpoint? _lastSyncCheckpoint;
  SyncEnvelopePreview? _syncImportPreview;
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
      group: _WorkspaceNavGroup.organize,
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
      icon: Icons.auto_awesome_motion_outlined,
      selectedIcon: Icons.auto_awesome_motion,
      labelBuilder: (copy) => copy.t('scenes'),
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
      index: 9,
      icon: Icons.ios_share_outlined,
      selectedIcon: Icons.ios_share,
      labelBuilder: (copy) => copy.t('exports'),
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
    final providerConfig = await _normalizeProviderConfigSecrets(
      await widget.aiProviderConfigRepository.findById('default'),
    );
    final projects = await widget.projectRepository.listActive();
    if (!mounted) return;
    final selectedProject = projects.firstOrNull;
    setState(() {
      _projects = projects;
      _selectedProject = selectedProject;
      _syncProviderConfig(providerConfig ?? _defaultProviderConfig());
    });
    if (selectedProject != null) {
      await _loadProjectData(selectedProject.id);
    }
  }

  AIProviderConfig _defaultProviderConfig() {
    final preset = AIProviderPreset.forKind(AIProviderKind.mock);
    return AIProviderConfig(
      id: 'default',
      kind: preset.kind,
      displayName: preset.displayName,
      modelName: preset.modelName,
      baseUrl: preset.baseUrl,
    );
  }

  Future<AIProviderConfig?> _normalizeProviderConfigSecrets(
      AIProviderConfig? config) async {
    final apiKeyRef = config?.encryptedApiKeyRef;
    if (config == null || apiKeyRef == null || _isSecretVaultRef(apiKeyRef)) {
      return config;
    }

    final ref = _providerApiKeyRef(config.id);
    await widget.secretVault.write(ref: ref, secret: apiKeyRef);
    final migrated = config.copyWith(encryptedApiKeyRef: ref);
    await widget.aiProviderConfigRepository.save(migrated);
    return migrated;
  }

  String _providerApiKeyRef(String providerId) {
    return 'secret://ai-provider/$providerId/api-key';
  }

  bool _isSecretVaultRef(String value) => value.startsWith('secret://');

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
      provider: await _activeLanguageModelProvider(),
      repository: widget.aiSuggestionRepository,
    );
  }

  Future<LanguageModelProvider> _activeLanguageModelProvider() async {
    final config = _activeProviderConfig ?? _defaultProviderConfig();
    if (!config.enabled) {
      throw const DomainFailure('AI provider is disabled in settings.');
    }

    switch (config.kind) {
      case AIProviderKind.mock:
        return const MockLanguageModelProvider();
      case AIProviderKind.openAICompatible:
      case AIProviderKind.openRouter:
        final apiKey = await _readApiKey(config, required: true);
        return OpenAICompatibleLanguageModelProvider.fromConfig(
          config,
          apiKey: apiKey,
          transport: const HttpModelHttpTransport(),
        );
      case AIProviderKind.anthropic:
        final apiKey = await _readApiKey(config, required: true);
        return AnthropicLanguageModelProvider.fromConfig(
          config,
          apiKey: apiKey,
          transport: const HttpModelHttpTransport(),
        );
      case AIProviderKind.gemini:
        final apiKey = await _readApiKey(config, required: true);
        return GeminiLanguageModelProvider.fromConfig(
          config,
          apiKey: apiKey,
          transport: const HttpModelHttpTransport(),
        );
      case AIProviderKind.ollama:
        return OllamaLanguageModelProvider.fromConfig(
          config,
          transport: const HttpModelHttpTransport(),
        );
    }
  }

  Future<String?> _readApiKey(
    AIProviderConfig config, {
    bool required = false,
  }) async {
    final ref = config.encryptedApiKeyRef;
    if (ref == null) {
      if (required) {
        throw const DomainFailure(
          'AI_API_KEY_MISSING',
        );
      }
      return null;
    }
    final secret = await widget.secretVault.read(ref);
    if (secret == null || secret.isEmpty) {
      throw const DomainFailure(
        'AI_API_KEY_MISSING',
      );
    }
    final normalizedSecret = _normalizeProviderApiKey(secret);
    if (normalizedSecret.isEmpty) {
      throw const DomainFailure(
        'AI_API_KEY_MISSING',
      );
    }
    return normalizedSecret;
  }

  String _normalizeProviderApiKey(String value) {
    var normalized = value.trim();
    while (normalized.toLowerCase().startsWith('bearer ')) {
      normalized = normalized.substring('bearer '.length).trim();
    }
    return normalized;
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

  Future<void> _showCreateProjectDialog(WritelerCopy copy) async {
    var draftTitle = '';
    final title = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(copy.t('newProject')),
          content: TextField(
            autofocus: true,
            decoration: InputDecoration(labelText: copy.t('projectTitle')),
            textInputAction: TextInputAction.done,
            onChanged: (value) => draftTitle = value,
            onSubmitted: (value) => Navigator.of(context).pop(value),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(copy.t('cancel')),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(draftTitle),
              child: Text(copy.t('create')),
            ),
          ],
        );
      },
    );

    final normalizedTitle = title?.trim();
    if (normalizedTitle == null) return;
    if (!mounted) return;

    final project = await _createProject(
      CreateProjectCommand(
        title: normalizedTitle.isEmpty
            ? copy.t('untitledProject')
            : normalizedTitle,
        languageCode: Localizations.localeOf(context).languageCode,
      ),
    );
    final projects = await widget.projectRepository.listActive();

    if (!mounted) return;
    setState(() {
      _projects = projects;
      _selectedProject = project;
      _chapters = const [];
      _scenes = const [];
      _catalogItems = const [];
      _relationships = const [];
      _metrics = const [];
      _suggestions = const [];
      _notes = const [];
      _selectedScene = null;
      _syncSceneControllers(null);
    });
    await _recordMetric(
      projectId: project.id,
      eventType: 'project.created',
      metadata: {'title': project.title},
    );
    final metrics = await widget.metricRepository.listForProject(project.id);
    if (mounted) {
      setState(() => _metrics = metrics);
    }
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(copy.t('projectCreated'))),
    );
  }

  Future<void> _showCreateSceneDialog(WritelerCopy copy) async {
    final project = _selectedProject;
    if (project == null) return;

    var draftTitle = '';
    final title = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(copy.t('newScene')),
          content: TextField(
            autofocus: true,
            decoration: InputDecoration(labelText: copy.t('sceneTitle')),
            textInputAction: TextInputAction.done,
            onChanged: (value) => draftTitle = value,
            onSubmitted: (value) => Navigator.of(context).pop(value),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(copy.t('cancel')),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(draftTitle),
              child: Text(copy.t('create')),
            ),
          ],
        );
      },
    );

    final normalizedTitle = title?.trim();
    if (normalizedTitle == null) return;

    final scene = await _createScene(
      CreateSceneCommand(
        projectId: project.id,
        title:
            normalizedTitle.isEmpty ? copy.t('untitledScene') : normalizedTitle,
        orderIndex: (_scenes.length + 1) * 1000,
      ),
    );
    final scenes = await widget.sceneRepository.listByProject(project.id);

    if (!mounted) return;
    setState(() {
      _scenes = scenes;
      _selectedScene = scene;
      _syncSceneControllers(scene);
    });
    await _recordProjectMetric(
      eventType: 'scene.created',
      metadata: {'sceneId': scene.id, 'title': scene.title},
    );
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(copy.t('sceneCreated'))),
    );
  }

  Future<void> _showCreateChapterDialog(WritelerCopy copy) async {
    final project = _selectedProject;
    if (project == null) return;

    var draftTitle = '';
    var draftSummary = '';
    final created = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(copy.t('newChapter')),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  autofocus: true,
                  decoration:
                      InputDecoration(labelText: copy.t('chapterTitle')),
                  textInputAction: TextInputAction.next,
                  onChanged: (value) => draftTitle = value,
                ),
                const SizedBox(height: 12),
                TextField(
                  decoration: InputDecoration(labelText: copy.t('summary')),
                  maxLines: 3,
                  onChanged: (value) => draftSummary = value,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(copy.t('cancel')),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(copy.t('create')),
            ),
          ],
        );
      },
    );

    if (created != true) return;
    final title = draftTitle.trim();
    final chapter = await _createChapter(
      CreateChapterCommand(
        projectId: project.id,
        title: title.isEmpty ? copy.t('untitledChapter') : title,
        summary: draftSummary,
        orderIndex: (_chapters.length + 1) * 1000,
      ),
    );
    final chapters = await widget.chapterRepository.listByProject(project.id);
    if (!mounted) return;
    setState(() {
      _chapters = chapters;
      _selectedSceneChapterId ??= chapter.id;
    });
    await _recordProjectMetric(
      eventType: 'chapter.created',
      metadata: {'chapterId': chapter.id, 'title': chapter.title},
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(copy.t('chapterCreated'))),
    );
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

  Future<void> _showCreateCatalogItemDialog(
      WritelerCopy copy, EntityType type) async {
    final project = _selectedProject;
    if (project == null) return;

    var draftName = '';
    var draftSummary = '';
    final created = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(copy.t(_newCatalogKey(type))),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  autofocus: true,
                  decoration: InputDecoration(labelText: copy.t('name')),
                  textInputAction: TextInputAction.next,
                  onChanged: (value) => draftName = value,
                ),
                const SizedBox(height: 12),
                TextField(
                  decoration: InputDecoration(labelText: copy.t('summary')),
                  maxLines: 3,
                  onChanged: (value) => draftSummary = value,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(copy.t('cancel')),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(copy.t('create')),
            ),
          ],
        );
      },
    );

    if (created != true) return;
    final name = draftName.trim();
    await _createCatalogItem(
      CreateCatalogItemCommand(
        projectId: project.id,
        type: type,
        name: name.isEmpty ? copy.t(_untitledCatalogKey(type)) : name,
        summary: draftSummary,
      ),
    );
    final items = await widget.catalogItemRepository.listByProject(project.id);

    if (!mounted) return;
    setState(() {
      _catalogItems = items;
    });
    await _recordProjectMetric(
      eventType: 'catalog.created',
      metadata: {'type': type.wireName},
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(copy.t('catalogItemCreated'))),
    );
  }

  Future<void> _showEditCatalogItemDialog(
    WritelerCopy copy,
    CatalogItem item,
  ) async {
    final project = _selectedProject;
    if (project == null) return;

    final nameController = TextEditingController(text: item.name);
    final summaryController = TextEditingController(text: item.summary);
    var draftStatus = item.status;
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(copy.t('editCatalogItem')),
          content: SizedBox(
            width: 460,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  autofocus: true,
                  decoration: InputDecoration(labelText: copy.t('name')),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<DraftStatus>(
                  initialValue: draftStatus,
                  decoration: InputDecoration(
                    labelText: copy.t('status'),
                    border: const OutlineInputBorder(),
                  ),
                  items: [
                    for (final status in DraftStatus.values)
                      DropdownMenuItem(
                        value: status,
                        child:
                            Text(_draftStatusLabel(status, copy.languageCode)),
                      ),
                  ],
                  onChanged: (status) {
                    if (status != null) draftStatus = status;
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: summaryController,
                  decoration: InputDecoration(labelText: copy.t('summary')),
                  maxLines: 5,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(copy.t('cancel')),
            ),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).pop(true),
              icon: const Icon(Icons.save_outlined),
              label: Text(copy.t('saveCatalogItem')),
            ),
          ],
        );
      },
    );

    if (saved != true) {
      nameController.dispose();
      summaryController.dispose();
      return;
    }

    final fallbackName = copy.t(_untitledCatalogKey(item.type));
    final updated = item.copyWith(
      name: nameController.text.trim().isEmpty
          ? fallbackName
          : nameController.text.trim(),
      summary: summaryController.text.trim(),
      status: draftStatus,
    );
    nameController.dispose();
    summaryController.dispose();

    await widget.catalogItemRepository.save(updated);
    final items = await widget.catalogItemRepository.listByProject(project.id);
    if (!mounted) return;
    setState(() => _catalogItems = items);
    await _recordProjectMetric(
      eventType: 'catalog.updated',
      metadata: {'itemId': updated.id, 'type': updated.type.wireName},
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(copy.t('catalogItemSaved'))),
    );
  }

  Future<bool> _confirmDelete({
    required WritelerCopy copy,
    required String title,
    required String body,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(body),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(copy.t('cancel')),
            ),
            FilledButton.tonalIcon(
              onPressed: () => Navigator.of(context).pop(true),
              icon: const Icon(Icons.delete_outline),
              label: Text(copy.t('deletePermanently')),
            ),
          ],
        );
      },
    );
    return confirmed == true;
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

  Future<void> _requestSceneSuggestion(
      WritelerCopy copy, AITaskKind task) async {
    final project = _selectedProject;
    final scene = _selectedScene ?? _scenes.firstOrNull;
    if (project == null || scene == null || _isRequestingAi) return;

    setState(() => _isRequestingAi = true);
    try {
      final requester = await _createSuggestionRequester();
      await requester.forScene(
        project: project,
        scene: scene,
        task: task,
        languageCode: copy.languageCode,
        userPrompt: _aiPromptController.text.trim().isEmpty
            ? copy.t('defaultAiPrompt')
            : _aiPromptController.text.trim(),
      );
      final suggestions =
          await widget.aiSuggestionRepository.listForProject(project.id);
      if (!mounted) return;
      setState(() {
        _suggestions = suggestions;
        _aiPromptController.clear();
        _lastAiError = null;
      });
      await _recordProjectMetric(
        eventType: 'ai.suggestion.created',
        metadata: {'task': task.name, 'sceneId': scene.id},
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

  Future<void> _copyExport(WritelerCopy copy) async {
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
        id: 'ui-preview',
        projectId: project.id,
        name: copy.t('exportPreview'),
        format: _selectedExportFormat,
        includeMetadata: _includeExportMetadata,
        includeSceneTitles: _includeSceneTitles,
      ),
    );
    await Clipboard.setData(ClipboardData(text: artifact.clipboardText));
    if (!mounted) return;
    await _recordProjectMetric(
      eventType: 'export.copied',
      value: artifact.bytes.length,
      metadata: {
        'format': _selectedExportFormat.name,
        'fileName': artifact.fileName,
        'mimeType': artifact.mimeType,
      },
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(copy.t('exportCopied'))),
    );
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
        format: _selectedExportFormat,
        includeMetadata: _includeExportMetadata,
        includeSceneTitles: _includeSceneTitles,
      ),
    );
    final downloaded = await downloadExportArtifact(artifact);
    if (!downloaded) {
      await Clipboard.setData(ClipboardData(text: artifact.clipboardText));
    }
    if (!mounted) return;
    await _recordProjectMetric(
      eventType: downloaded ? 'export.downloaded' : 'export.copied',
      value: artifact.bytes.length,
      metadata: {
        'format': _selectedExportFormat.name,
        'fileName': artifact.fileName,
        'mimeType': artifact.mimeType,
      },
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content:
              Text(copy.t(downloaded ? 'exportDownloaded' : 'exportCopied'))),
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
        _syncImportPreview = null;
      });
      return;
    }

    try {
      final inspection = _syncAdapter.inspectPayload(source);
      final preview = _archiveCodec.preview(inspection.archiveSource);
      setState(() {
        _importPreview = preview;
        _importPreviewError = null;
        _syncImportPreview = inspection.envelope;
      });
    } catch (error) {
      setState(() {
        _importPreview = null;
        _importPreviewError = _providerErrorMessage(error);
        _syncImportPreview = null;
      });
    }
  }

  Future<void> _importArchive(WritelerCopy copy) async {
    final source = _importArchiveController.text.trim();
    if (source.isEmpty) return;

    try {
      final inspection = _syncAdapter.inspectPayload(source);
      final archive = _archiveCodec.decode(inspection.archiveSource);
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
        _syncImportPreview = null;
      });
      await _recordMetric(
        projectId: archive.project.id,
        eventType: inspection.isEnvelope
            ? 'sync.checkpoint.imported'
            : 'project.imported',
        metadata: {
          'scenes': archive.scenes.length,
          'catalogItems': archive.catalogItems.length,
          'relationships': archive.relationships.length,
          'notes': archive.notes.length,
          if (inspection.envelope != null) ...inspection.envelope!.toJson(),
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

  Future<void> _saveProjectPrivacySettings({
    required bool aiEnabled,
    required bool cloudSyncEnabled,
    required bool noAiNoCloud,
  }) async {
    final project = _selectedProject;
    if (project == null) return;

    final updated = project.copyWith(
      aiEnabled: aiEnabled,
      cloudSyncEnabled: cloudSyncEnabled,
      noAiNoCloud: noAiNoCloud,
    );
    await widget.projectRepository.save(updated);
    final projects = await widget.projectRepository.listActive();
    if (!mounted) return;
    setState(() {
      _projects = projects;
      _selectedProject = updated;
    });
  }

  Future<void> _saveProviderConfig(WritelerCopy copy) async {
    const providerId = 'default';
    final apiKeyInput = _normalizeProviderApiKey(_apiKeyRefController.text);
    final existingApiKeyRef = _activeProviderConfig?.encryptedApiKeyRef;
    String? apiKeyRef = existingApiKeyRef;

    if (apiKeyInput.isNotEmpty) {
      apiKeyRef = _providerApiKeyRef(providerId);
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
        3 => copy.t('characters'),
        4 => copy.t('locations'),
        5 => copy.t('objects'),
        6 => copy.t('analysis'),
        7 => copy.t('notesCockpit'),
        8 => copy.t('aiWorkshop'),
        9 => copy.t('exports'),
        _ => copy.t('settings'),
      };

  IconData _workspaceIcon() => switch (_selectedRailIndex) {
        0 => Icons.dashboard_outlined,
        1 => Icons.edit_note_outlined,
        2 => Icons.auto_awesome_motion_outlined,
        3 => Icons.person_outline,
        4 => Icons.place_outlined,
        5 => Icons.category_outlined,
        6 => Icons.query_stats_outlined,
        7 => Icons.sticky_note_2_outlined,
        8 => Icons.psychology_alt_outlined,
        9 => Icons.ios_share_outlined,
        _ => Icons.tune_outlined,
      };

  @override
  Widget build(BuildContext context) {
    final copy = WritelerCopy(Localizations.localeOf(context).languageCode);
    final color = Theme.of(context).colorScheme;

    return Scaffold(
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
                      showCreateProject:
                          _selectedRailIndex == 0 || _projects.isEmpty,
                      onCreateProject: () => _showCreateProjectDialog(copy),
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
    );
  }

  Widget _buildSelectedWorkspace(WritelerCopy copy) {
    if (_projects.isEmpty) {
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
          onSceneStatusChanged: (status) => setState(
            () => _selectedSceneStatus = status,
          ),
          onCreateChapter: () => _showCreateChapterDialog(copy),
          onCreateScene: () => _showCreateSceneDialog(copy),
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
          onDeleteScene: (scene) => _deleteScene(scene, copy),
          onDeleteChapter: (chapter) => _deleteChapter(chapter, copy),
          onCreateScene: () => _showCreateSceneDialog(copy),
          onCreateChapter: () => _showCreateChapterDialog(copy),
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
          scenes: _scenes,
          suggestions: _suggestions,
          notes: _notes,
          activeProviderConfig:
              _activeProviderConfig ?? _defaultProviderConfig(),
          promptController: _aiPromptController,
          isRequesting: _isRequestingAi,
          lastError: _lastAiError,
          onSubmitPrompt: () =>
              _requestSceneSuggestion(copy, AITaskKind.customScenePrompt),
          onRequestTask: (task) => _requestSceneSuggestion(copy, task),
          onAcceptSuggestion: (suggestion) =>
              _decideSuggestion(copy, suggestion, SuggestionDecision.accepted),
          onRejectSuggestion: (suggestion) =>
              _decideSuggestion(copy, suggestion, SuggestionDecision.rejected),
          onConvertSuggestion: (suggestion) => _decideSuggestion(
              copy, suggestion, SuggestionDecision.convertedToNote),
          onDeleteNote: (note) => _deleteNote(note, copy),
        ),
      9 => _ExportCenter(
          copy: copy,
          project: _selectedProject,
          chapters: _chapters,
          scenes: _scenes,
          notes: _notes,
          format: _selectedExportFormat,
          includeSceneTitles: _includeSceneTitles,
          includeMetadata: _includeExportMetadata,
          exporter: _projectExporter,
          catalogItems: _catalogItems,
          relationships: _relationships,
          importController: _importArchiveController,
          importPreview: _importPreview,
          importPreviewError: _importPreviewError,
          lastSyncCheckpoint: _lastSyncCheckpoint,
          syncImportPreview: _syncImportPreview,
          onFormatChanged: (format) =>
              setState(() => _selectedExportFormat = format),
          onIncludeSceneTitlesChanged: (value) =>
              setState(() => _includeSceneTitles = value),
          onIncludeMetadataChanged: (value) =>
              setState(() => _includeExportMetadata = value),
          onCopyExport: () => _copyExport(copy),
          onDownloadExport: () => _downloadExport(copy),
          onCopySyncCheckpoint: () => _copySyncCheckpoint(copy),
          onImportSourceChanged: _refreshImportPreview,
          onImportArchive: () => _importArchive(copy),
        ),
      _ => _SettingsWorkspace(
          copy: copy,
          project: _selectedProject,
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
          onSavePrivacySettings: _saveProjectPrivacySettings,
          syncAdapterName: _syncAdapter.adapterName,
        ),
    };
  }
}
