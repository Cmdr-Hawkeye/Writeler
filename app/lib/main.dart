import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';

import 'core/domain/domain_failure.dart';
import 'core/domain/draft_status.dart';
import 'core/domain/entity_ref.dart';
import 'core/domain/entity_type.dart';
import 'core/domain/ids.dart';
import 'features/ai_harness/application/request_ai_suggestion.dart';
import 'features/ai_harness/domain/ai_policy.dart';
import 'features/ai_harness/domain/ai_suggestion.dart';
import 'features/ai_harness/domain/ai_suggestion_repository.dart';
import 'features/ai_harness/domain/language_model_provider.dart';
import 'features/ai_harness/infrastructure/drift_ai_suggestion_repository.dart';
import 'features/ai_harness/infrastructure/anthropic_language_model_provider.dart';
import 'features/ai_harness/infrastructure/gemini_language_model_provider.dart';
import 'features/ai_harness/infrastructure/http_model_http_transport.dart';
import 'features/ai_harness/infrastructure/lazy_ai_suggestion_repository.dart';
import 'features/ai_harness/infrastructure/mock_language_model_provider.dart';
import 'features/ai_harness/infrastructure/ollama_language_model_provider.dart';
import 'features/ai_harness/infrastructure/openai_compatible_language_model_provider.dart';
import 'features/catalog/application/create_catalog_item.dart';
import 'features/catalog/domain/catalog_item.dart';
import 'features/catalog/domain/catalog_item_repository.dart';
import 'features/catalog/domain/relationship.dart';
import 'features/catalog/domain/relationship_repository.dart';
import 'features/catalog/infrastructure/drift_catalog_item_repository.dart';
import 'features/catalog/infrastructure/drift_relationship_repository.dart';
import 'features/catalog/infrastructure/lazy_catalog_item_repository.dart';
import 'features/catalog/infrastructure/lazy_relationship_repository.dart';
import 'features/export/application/download_export.dart';
import 'features/export/application/project_archive_codec.dart';
import 'features/export/application/project_exporter.dart';
import 'features/export/domain/export_profile.dart';
import 'features/metrics/application/record_metric.dart';
import 'features/metrics/domain/metric_event.dart';
import 'features/metrics/domain/metric_repository.dart';
import 'features/metrics/infrastructure/drift_metric_repository.dart';
import 'features/metrics/infrastructure/lazy_metric_repository.dart';
import 'features/projects/application/create_project.dart';
import 'features/projects/domain/project.dart';
import 'features/projects/domain/project_repository.dart';
import 'features/projects/infrastructure/drift_project_repository.dart';
import 'features/projects/infrastructure/lazy_project_repository.dart';
import 'features/settings/domain/ai_provider_config.dart';
import 'features/settings/domain/ai_provider_config_repository.dart';
import 'features/settings/domain/ai_provider_preset.dart';
import 'features/settings/domain/secret_vault.dart';
import 'features/settings/infrastructure/drift_ai_provider_config_repository.dart';
import 'features/settings/infrastructure/flutter_secure_secret_vault.dart';
import 'features/settings/infrastructure/lazy_ai_provider_config_repository.dart';
import 'features/sync/application/manual_sync_adapter.dart';
import 'features/sync/domain/sync_checkpoint.dart';
import 'core/infrastructure/database/app_database.dart';
import 'features/structure/application/create_chapter.dart';
import 'features/structure/application/create_scene.dart';
import 'features/structure/domain/chapter.dart';
import 'features/structure/domain/chapter_repository.dart';
import 'features/structure/domain/scene.dart';
import 'features/structure/domain/scene_repository.dart';
import 'features/structure/infrastructure/drift_chapter_repository.dart';
import 'features/structure/infrastructure/drift_scene_repository.dart';
import 'features/structure/infrastructure/lazy_chapter_repository.dart';
import 'features/structure/infrastructure/lazy_scene_repository.dart';
import 'shared/writeler_copy.dart';

void main() {
  AppDatabase? database;
  AppDatabase getDatabase() => database ??= AppDatabase();

  runApp(
    WritelerApp(
      projectRepository: LazyProjectRepository(
        () => DriftProjectRepository(getDatabase()),
      ),
      sceneRepository: LazySceneRepository(
        () => DriftSceneRepository(getDatabase()),
      ),
      chapterRepository: LazyChapterRepository(
        () => DriftChapterRepository(getDatabase()),
      ),
      catalogItemRepository: LazyCatalogItemRepository(
        () => DriftCatalogItemRepository(getDatabase()),
      ),
      relationshipRepository: LazyRelationshipRepository(
        () => DriftRelationshipRepository(getDatabase()),
      ),
      metricRepository: LazyMetricRepository(
        () => DriftMetricRepository(getDatabase()),
      ),
      aiSuggestionRepository: LazyAISuggestionRepository(
        () => DriftAISuggestionRepository(getDatabase()),
      ),
      aiProviderConfigRepository: LazyAIProviderConfigRepository(
        () => DriftAIProviderConfigRepository(getDatabase()),
      ),
      secretVault: const FlutterSecureSecretVault(),
    ),
  );
}

final class WritelerApp extends StatelessWidget {
  const WritelerApp({
    required this.projectRepository,
    required this.sceneRepository,
    required this.chapterRepository,
    required this.catalogItemRepository,
    required this.relationshipRepository,
    required this.metricRepository,
    required this.aiSuggestionRepository,
    required this.aiProviderConfigRepository,
    required this.secretVault,
    super.key,
  });

  final ProjectRepository projectRepository;
  final SceneRepository sceneRepository;
  final ChapterRepository chapterRepository;
  final CatalogItemRepository catalogItemRepository;
  final RelationshipRepository relationshipRepository;
  final MetricRepository metricRepository;
  final AISuggestionRepository aiSuggestionRepository;
  final AIProviderConfigRepository aiProviderConfigRepository;
  final SecretVault secretVault;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Writeler',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('de'),
        Locale('en'),
      ],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2F6F73),
          brightness: Brightness.light,
        ),
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7BC8B8),
          brightness: Brightness.dark,
        ),
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      home: WritelerShell(
        projectRepository: projectRepository,
        sceneRepository: sceneRepository,
        chapterRepository: chapterRepository,
        catalogItemRepository: catalogItemRepository,
        relationshipRepository: relationshipRepository,
        metricRepository: metricRepository,
        aiSuggestionRepository: aiSuggestionRepository,
        aiProviderConfigRepository: aiProviderConfigRepository,
        secretVault: secretVault,
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
    required this.aiProviderConfigRepository,
    required this.secretVault,
    super.key,
  });

  final ProjectRepository projectRepository;
  final SceneRepository sceneRepository;
  final ChapterRepository chapterRepository;
  final CatalogItemRepository catalogItemRepository;
  final RelationshipRepository relationshipRepository;
  final MetricRepository metricRepository;
  final AISuggestionRepository aiSuggestionRepository;
  final AIProviderConfigRepository aiProviderConfigRepository;
  final SecretVault secretVault;

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTimer = Timer(const Duration(milliseconds: 250), _loadProjects);
    });
  }

  @override
  void dispose() {
    _loadTimer?.cancel();
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
        final apiKey = await _readApiKey(config);
        return OpenAICompatibleLanguageModelProvider.fromConfig(
          config,
          apiKey: apiKey,
          transport: const HttpModelHttpTransport(),
        );
      case AIProviderKind.anthropic:
        final apiKey = await _readApiKey(config);
        return AnthropicLanguageModelProvider.fromConfig(
          config,
          apiKey: apiKey,
          transport: const HttpModelHttpTransport(),
        );
      case AIProviderKind.gemini:
        final apiKey = await _readApiKey(config);
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

  Future<String?> _readApiKey(AIProviderConfig config) async {
    final ref = config.encryptedApiKeyRef;
    if (ref == null) return null;
    final secret = await widget.secretVault.read(ref);
    if (secret == null || secret.isEmpty) {
      throw const DomainFailure(
          'The configured API key could not be found in secure storage.');
    }
    return secret;
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
    final scenes = await scenesFuture;
    final chapters = await chaptersFuture;
    final catalogItems = await catalogFuture;
    final relationships = await relationshipsFuture;
    final metrics = await metricsFuture;
    final suggestions = await suggestionsFuture;
    if (!mounted) return;
    setState(() {
      _scenes = scenes;
      _chapters = chapters;
      _catalogItems = catalogItems;
      _relationships = relationships;
      _metrics = metrics;
      _suggestions = suggestions;
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
      _syncSceneControllers(null);
    });
    await _loadProjectData(project.id);
  }

  void _selectScene(Scene scene) {
    setState(() {
      _selectedScene = scene;
      _syncSceneControllers(scene);
    });
  }

  void _syncSceneControllers(Scene? scene) {
    _manuscriptController.text = scene?.manuscriptText ?? '';
    _summaryController.text = scene?.summary ?? '';
    _goalController.text = scene?.goal ?? '';
    _conflictController.text = scene?.conflict ?? '';
    _outcomeController.text = scene?.outcome ?? '';
    _wordTargetController.text = scene?.estimatedWordTarget?.toString() ?? '';
    _selectedSceneChapterId = scene?.chapterId;
    _selectedSceneStatus = scene?.status ?? DraftStatus.planned;
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

  Future<void> _saveSelectedScene(WritelerCopy copy) async {
    final scene = _selectedScene;
    final project = _selectedProject;
    if (scene == null || project == null) return;

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
    setState(() {
      _scenes = scenes;
      _selectedScene = updated;
    });
    await _recordProjectMetric(
      eventType: 'scene.saved',
      value: updated.actualWordCount,
      metadata: {'sceneId': updated.id, 'title': updated.title},
    );
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(copy.t('sceneSaved'))),
    );
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
    if (error is DomainFailure) return error.message;
    return error.toString().replaceFirst('Exception: ', '');
  }

  ProjectArchive _currentArchive(Project project) {
    return ProjectArchive(
      project: project,
      chapters: _chapters,
      scenes: _scenes,
      catalogItems: _catalogItems,
      relationships: _relationships,
    );
  }

  Future<void> _decideSuggestion(
      AISuggestion suggestion, SuggestionDecision decision) async {
    final project = _selectedProject;
    if (project == null) return;

    await widget.aiSuggestionRepository
        .save(suggestion.copyWith(userDecision: decision));
    final suggestions =
        await widget.aiSuggestionRepository.listForProject(project.id);
    if (!mounted) return;
    setState(() => _suggestions = suggestions);
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

      final projects = await widget.projectRepository.listActive();
      final suggestions = await widget.aiSuggestionRepository
          .listForProject(archive.project.id);
      if (!mounted) return;
      setState(() {
        _projects = projects;
        _selectedProject = archive.project;
        _chapters = archive.chapters;
        _scenes = archive.scenes;
        _catalogItems = archive.catalogItems;
        _relationships = archive.relationships;
        _suggestions = suggestions;
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
    final apiKeyInput = _apiKeyRefController.text.trim();
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

  @override
  Widget build(BuildContext context) {
    final copy = WritelerCopy(Localizations.localeOf(context).languageCode);

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedRailIndex,
            onDestinationSelected: (index) =>
                setState(() => _selectedRailIndex = index),
            labelType: NavigationRailLabelType.all,
            destinations: [
              NavigationRailDestination(
                icon: const Icon(Icons.library_books_outlined),
                selectedIcon: const Icon(Icons.library_books),
                label: Text(copy.t('projects')),
              ),
              NavigationRailDestination(
                icon: const Icon(Icons.edit_note_outlined),
                selectedIcon: const Icon(Icons.edit_note),
                label: Text(copy.t('editor')),
              ),
              NavigationRailDestination(
                icon: const Icon(Icons.auto_awesome_motion_outlined),
                selectedIcon: const Icon(Icons.auto_awesome_motion),
                label: Text(copy.t('scenes')),
              ),
              NavigationRailDestination(
                icon: const Icon(Icons.person_outline),
                selectedIcon: const Icon(Icons.person),
                label: Text(copy.t('characters')),
              ),
              NavigationRailDestination(
                icon: const Icon(Icons.place_outlined),
                selectedIcon: const Icon(Icons.place),
                label: Text(copy.t('locations')),
              ),
              NavigationRailDestination(
                icon: const Icon(Icons.category_outlined),
                selectedIcon: const Icon(Icons.category),
                label: Text(copy.t('objects')),
              ),
              NavigationRailDestination(
                icon: const Icon(Icons.psychology_alt_outlined),
                selectedIcon: const Icon(Icons.psychology_alt),
                label: Text(copy.t('aiWorkshop')),
              ),
              NavigationRailDestination(
                icon: const Icon(Icons.ios_share_outlined),
                selectedIcon: const Icon(Icons.ios_share),
                label: Text(copy.t('exports')),
              ),
              NavigationRailDestination(
                icon: const Icon(Icons.tune_outlined),
                selectedIcon: const Icon(Icons.tune),
                label: Text(copy.t('settings')),
              ),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: Column(
              children: [
                SizedBox(
                  height: 64,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        Text(
                          copy.t('appTitle'),
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                        const Spacer(),
                        FilledButton.icon(
                          onPressed: () => _showCreateProjectDialog(copy),
                          icon: const Icon(Icons.add),
                          label: Text(copy.t('newProject')),
                        ),
                      ],
                    ),
                  ),
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
          catalogItems: _catalogItems,
          metrics: _metrics,
          suggestions: _suggestions,
          onSelectProject: _selectProject,
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
          onSelectProject: _selectProject,
          onSelectScene: _selectScene,
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
          selectedScene: _selectedScene,
          onSelectScene: (scene) {
            _selectScene(scene);
            setState(() => _selectedRailIndex = 1);
          },
          onMoveSceneUp: (scene) => _moveSceneInStructure(scene, -1),
          onMoveSceneDown: (scene) => _moveSceneInStructure(scene, 1),
          onMoveSceneToChapter: _moveSceneToChapter,
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
        ),
      4 => _CatalogWorkspace(
          copy: copy,
          type: EntityType.location,
          items: _catalogItems
              .where((item) => item.type == EntityType.location)
              .toList(),
          onCreateItem: () =>
              _showCreateCatalogItemDialog(copy, EntityType.location),
        ),
      5 => _CatalogWorkspace(
          copy: copy,
          type: EntityType.object,
          items: _catalogItems
              .where((item) => item.type == EntityType.object)
              .toList(),
          onCreateItem: () =>
              _showCreateCatalogItemDialog(copy, EntityType.object),
        ),
      6 => _AIWorkshop(
          copy: copy,
          project: _selectedProject,
          selectedScene: _selectedScene,
          scenes: _scenes,
          suggestions: _suggestions,
          promptController: _aiPromptController,
          isRequesting: _isRequestingAi,
          lastError: _lastAiError,
          onRequestSceneIdeas: () =>
              _requestSceneSuggestion(copy, AITaskKind.sceneIdeas),
          onRequestStructure: () => _requestSceneSuggestion(
              copy, AITaskKind.sceneGoalConflictOutcome),
          onAcceptSuggestion: (suggestion) =>
              _decideSuggestion(suggestion, SuggestionDecision.accepted),
          onRejectSuggestion: (suggestion) =>
              _decideSuggestion(suggestion, SuggestionDecision.rejected),
          onConvertSuggestion: (suggestion) =>
              _decideSuggestion(suggestion, SuggestionDecision.convertedToNote),
        ),
      7 => _ExportCenter(
          copy: copy,
          project: _selectedProject,
          chapters: _chapters,
          scenes: _scenes,
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

final class _WorkspaceView extends StatelessWidget {
  const _WorkspaceView({
    required this.copy,
    required this.projects,
    required this.selectedProject,
    required this.chapters,
    required this.catalogItems,
    required this.relationships,
    required this.scenes,
    required this.selectedScene,
    required this.manuscriptController,
    required this.summaryController,
    required this.goalController,
    required this.conflictController,
    required this.outcomeController,
    required this.wordTargetController,
    required this.selectedSceneStatus,
    required this.selectedSceneChapterId,
    required this.onSelectProject,
    required this.onSelectScene,
    required this.onSceneChapterChanged,
    required this.onToggleSceneCatalogLink,
    required this.onSceneStatusChanged,
    required this.onCreateChapter,
    required this.onCreateScene,
    required this.onSaveScene,
  });

  final WritelerCopy copy;
  final List<Project> projects;
  final Project? selectedProject;
  final List<Chapter> chapters;
  final List<CatalogItem> catalogItems;
  final List<Relationship> relationships;
  final List<Scene> scenes;
  final Scene? selectedScene;
  final TextEditingController manuscriptController;
  final TextEditingController summaryController;
  final TextEditingController goalController;
  final TextEditingController conflictController;
  final TextEditingController outcomeController;
  final TextEditingController wordTargetController;
  final DraftStatus selectedSceneStatus;
  final String? selectedSceneChapterId;
  final ValueChanged<Project> onSelectProject;
  final ValueChanged<Scene> onSelectScene;
  final ValueChanged<String?> onSceneChapterChanged;
  final void Function(CatalogItem item, bool selected) onToggleSceneCatalogLink;
  final ValueChanged<DraftStatus> onSceneStatusChanged;
  final VoidCallback onCreateChapter;
  final VoidCallback onCreateScene;
  final VoidCallback onSaveScene;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: 300,
          child: _ProjectLibrary(
            copy: copy,
            projects: projects,
            selectedProject: selectedProject,
            onSelect: onSelectProject,
          ),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          child: _ProjectWorkspace(
            copy: copy,
            project: selectedProject,
            chapters: chapters,
            catalogItems: catalogItems,
            relationships: relationships,
            scenes: scenes,
            selectedScene: selectedScene,
            manuscriptController: manuscriptController,
            summaryController: summaryController,
            goalController: goalController,
            conflictController: conflictController,
            outcomeController: outcomeController,
            wordTargetController: wordTargetController,
            selectedSceneStatus: selectedSceneStatus,
            selectedSceneChapterId: selectedSceneChapterId,
            onSelectScene: onSelectScene,
            onSceneChapterChanged: onSceneChapterChanged,
            onToggleSceneCatalogLink: onToggleSceneCatalogLink,
            onSceneStatusChanged: onSceneStatusChanged,
            onCreateChapter: onCreateChapter,
            onCreateScene: onCreateScene,
            onSaveScene: onSaveScene,
          ),
        ),
      ],
    );
  }
}

final class _EmptyWorkspace extends StatelessWidget {
  const _EmptyWorkspace({required this.copy});

  final WritelerCopy copy;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.menu_book_outlined,
                color: color.primary,
                size: 40,
              ),
              const SizedBox(height: 20),
              Text(
                copy.t('emptyTitle'),
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              Text(
                copy.t('emptyBody'),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: color.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final class _ProjectOverview extends StatelessWidget {
  const _ProjectOverview({
    required this.copy,
    required this.projects,
    required this.selectedProject,
    required this.chapters,
    required this.scenes,
    required this.catalogItems,
    required this.metrics,
    required this.suggestions,
    required this.onSelectProject,
  });

  final WritelerCopy copy;
  final List<Project> projects;
  final Project? selectedProject;
  final List<Chapter> chapters;
  final List<Scene> scenes;
  final List<CatalogItem> catalogItems;
  final List<MetricEvent> metrics;
  final List<AISuggestion> suggestions;
  final ValueChanged<Project> onSelectProject;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final words =
        scenes.fold<int>(0, (sum, scene) => sum + scene.actualWordCount);
    final pendingSuggestions = suggestions
        .where((suggestion) =>
            suggestion.userDecision == SuggestionDecision.pending)
        .length;
    final today = DateTime.now().toLocal();
    final todaySaves = metrics
        .where(
          (event) =>
              event.eventType == 'scene.saved' &&
              event.occurredAt.toLocal().year == today.year &&
              event.occurredAt.toLocal().month == today.month &&
              event.occurredAt.toLocal().day == today.day,
        )
        .length;
    final aiEvents =
        metrics.where((event) => event.eventType.startsWith('ai.')).length;
    final exportEvents =
        metrics.where((event) => event.eventType.startsWith('export.')).length;

    return Row(
      children: [
        SizedBox(
          width: 320,
          child: _ProjectLibrary(
            copy: copy,
            projects: projects,
            selectedProject: selectedProject,
            onSelect: onSelectProject,
          ),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  selectedProject?.title ?? copy.t('projects'),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    _MetricTile(
                        label: copy.t('scenes'),
                        value: scenes.length.toString()),
                    _MetricTile(
                        label: copy.t('chapters'),
                        value: chapters.length.toString()),
                    _MetricTile(
                        label: copy.t('words'), value: words.toString()),
                    _MetricTile(
                        label: copy.t('catalog'),
                        value: catalogItems.length.toString()),
                    _MetricTile(
                      label: copy.t('openSuggestions'),
                      value: pendingSuggestions.toString(),
                    ),
                    _MetricTile(
                        label: copy.t('metricEvents'),
                        value: metrics.length.toString()),
                    _MetricTile(
                        label: copy.t('todaySaves'),
                        value: todaySaves.toString()),
                    _MetricTile(
                        label: copy.t('aiUses'), value: aiEvents.toString()),
                    _MetricTile(
                        label: copy.t('exports'),
                        value: exportEvents.toString()),
                  ],
                ),
                const SizedBox(height: 28),
                Text(copy.t('recentMetrics'),
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                SizedBox(
                  height: 120,
                  child: metrics.isEmpty
                      ? Text(
                          copy.t('noMetricsYet'),
                          style: TextStyle(color: color.onSurfaceVariant),
                        )
                      : ListView.separated(
                          itemCount: metrics.take(5).length,
                          separatorBuilder: (context, index) =>
                              const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final event = metrics[index];
                            return ListTile(
                              dense: true,
                              leading: const Icon(Icons.insights_outlined),
                              title: Text(_metricEventLabel(
                                  event.eventType, copy.languageCode)),
                              subtitle:
                                  Text(event.occurredAt.toLocal().toString()),
                              trailing: event.value == null
                                  ? null
                                  : Text('${event.value}'),
                            );
                          },
                        ),
                ),
                const SizedBox(height: 20),
                Text(copy.t('recentScenes'),
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Expanded(
                  child: scenes.isEmpty
                      ? Text(
                          copy.t('noScenesBody'),
                          style: TextStyle(color: color.onSurfaceVariant),
                        )
                      : ListView.separated(
                          itemCount: scenes.length,
                          separatorBuilder: (context, index) =>
                              const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final scene = scenes[index];
                            return ListTile(
                              leading: const Icon(Icons.notes_outlined),
                              title: Text(scene.title),
                              subtitle: Text(
                                '${_draftStatusLabel(scene.status, copy.languageCode)} · '
                                '${scene.actualWordCount} ${copy.t('words')}',
                              ),
                              dense: true,
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

final class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: color.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: TextStyle(color: color.onSurfaceVariant)),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

final class _SceneBoard extends StatelessWidget {
  const _SceneBoard({
    required this.copy,
    required this.chapters,
    required this.scenes,
    required this.selectedScene,
    required this.onSelectScene,
    required this.onMoveSceneUp,
    required this.onMoveSceneDown,
    required this.onMoveSceneToChapter,
    required this.onCreateScene,
    required this.onCreateChapter,
  });

  final WritelerCopy copy;
  final List<Chapter> chapters;
  final List<Scene> scenes;
  final Scene? selectedScene;
  final ValueChanged<Scene> onSelectScene;
  final ValueChanged<Scene> onMoveSceneUp;
  final ValueChanged<Scene> onMoveSceneDown;
  final void Function(Scene scene, String? chapterId) onMoveSceneToChapter;
  final VoidCallback onCreateScene;
  final VoidCallback onCreateChapter;

  @override
  Widget build(BuildContext context) {
    final orderedChapters = [...chapters]
      ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
    final groups = <_SceneStructureGroup>[
      for (final chapter in orderedChapters)
        _SceneStructureGroup(
          id: chapter.id,
          title: chapter.title,
          summary: chapter.summary,
          scenes: _scenesForChapter(chapter.id),
        ),
      _SceneStructureGroup(
        id: null,
        title: copy.t('noChapter'),
        summary: '',
        scenes: _scenesForChapter(null),
      ),
    ].where((group) => group.scenes.isNotEmpty || group.id != null).toList();
    final visibleGroups = groups.isEmpty
        ? [
            _SceneStructureGroup(
              id: null,
              title: copy.t('noChapter'),
              summary: '',
              scenes: const [],
            ),
          ]
        : groups;

    return Column(
      children: [
        _WorkspaceHeader(
          title: copy.t('sceneBoard'),
          actionLabel: copy.t('newScene'),
          actionIcon: Icons.add,
          onAction: onCreateScene,
        ),
        const Divider(height: 1),
        if (chapters.isNotEmpty)
          SizedBox(
            height: 52,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                final chapter = orderedChapters[index];
                final sceneCount = scenes
                    .where((scene) => scene.chapterId == chapter.id)
                    .length;
                return Chip(
                  avatar: const Icon(Icons.folder_outlined, size: 18),
                  label: Text('${chapter.title} · $sceneCount'),
                );
              },
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemCount: orderedChapters.length,
            ),
          )
        else
          SizedBox(
            height: 52,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: OutlinedButton.icon(
                  onPressed: onCreateChapter,
                  icon: const Icon(Icons.create_new_folder_outlined),
                  label: Text(copy.t('newChapter')),
                ),
              ),
            ),
          ),
        const Divider(height: 1),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(20),
            scrollDirection: Axis.horizontal,
            itemCount: visibleGroups.length,
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final group = visibleGroups[index];
              return SizedBox(
                width: 320,
                child: _SceneStructureColumn(
                  copy: copy,
                  group: group,
                  chapters: orderedChapters,
                  selectedScene: selectedScene,
                  onSelectScene: onSelectScene,
                  onMoveSceneUp: onMoveSceneUp,
                  onMoveSceneDown: onMoveSceneDown,
                  onMoveSceneToChapter: onMoveSceneToChapter,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  List<Scene> _scenesForChapter(String? chapterId) {
    final filtered =
        scenes.where((scene) => scene.chapterId == chapterId).toList();
    filtered.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
    return filtered;
  }
}

final class _SceneStructureGroup {
  const _SceneStructureGroup({
    required this.id,
    required this.title,
    required this.summary,
    required this.scenes,
  });

  final String? id;
  final String title;
  final String summary;
  final List<Scene> scenes;
}

final class _SceneStructureColumn extends StatelessWidget {
  const _SceneStructureColumn({
    required this.copy,
    required this.group,
    required this.chapters,
    required this.selectedScene,
    required this.onSelectScene,
    required this.onMoveSceneUp,
    required this.onMoveSceneDown,
    required this.onMoveSceneToChapter,
  });

  final WritelerCopy copy;
  final _SceneStructureGroup group;
  final List<Chapter> chapters;
  final Scene? selectedScene;
  final ValueChanged<Scene> onSelectScene;
  final ValueChanged<Scene> onMoveSceneUp;
  final ValueChanged<Scene> onMoveSceneDown;
  final void Function(Scene scene, String? chapterId) onMoveSceneToChapter;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: color.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    group.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                Text('${group.scenes.length}'),
              ],
            ),
          ),
          if (group.summary.trim().isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  group.summary,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: color.onSurfaceVariant,
                      ),
                ),
              ),
            ),
            const Divider(height: 1),
          ],
          if (group.summary.trim().isEmpty) const Divider(height: 1),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(8),
              itemCount: group.scenes.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final scene = group.scenes[index];
                final selected = selectedScene?.id == scene.id;
                return ListTile(
                  selected: selected,
                  selectedTileColor:
                      color.primaryContainer.withValues(alpha: 0.38),
                  title: Text(scene.title,
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text(
                    '${_draftStatusLabel(scene.status, copy.languageCode)} - '
                    '${scene.actualWordCount} ${copy.t('words')}',
                  ),
                  trailing: _SceneStructureMenu(
                    copy: copy,
                    scene: scene,
                    chapters: chapters,
                    onMoveUp: () => onMoveSceneUp(scene),
                    onMoveDown: () => onMoveSceneDown(scene),
                    onMoveToChapter: (chapterId) =>
                        onMoveSceneToChapter(scene, chapterId),
                  ),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  onTap: () => onSelectScene(scene),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

final class _SceneStructureMenu extends StatelessWidget {
  const _SceneStructureMenu({
    required this.copy,
    required this.scene,
    required this.chapters,
    required this.onMoveUp,
    required this.onMoveDown,
    required this.onMoveToChapter,
  });

  final WritelerCopy copy;
  final Scene scene;
  final List<Chapter> chapters;
  final VoidCallback onMoveUp;
  final VoidCallback onMoveDown;
  final ValueChanged<String?> onMoveToChapter;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_SceneStructureAction>(
      tooltip: copy.t('structureActions'),
      icon: const Icon(Icons.more_vert),
      onSelected: (action) {
        switch (action.kind) {
          case _SceneStructureActionKind.moveUp:
            onMoveUp();
          case _SceneStructureActionKind.moveDown:
            onMoveDown();
          case _SceneStructureActionKind.moveToChapter:
            onMoveToChapter(action.chapterId);
        }
      },
      itemBuilder: (context) {
        return [
          PopupMenuItem(
            value:
                const _SceneStructureAction(_SceneStructureActionKind.moveUp),
            child: Text(copy.t('moveSceneUp')),
          ),
          PopupMenuItem(
            value:
                const _SceneStructureAction(_SceneStructureActionKind.moveDown),
            child: Text(copy.t('moveSceneDown')),
          ),
          const PopupMenuDivider(),
          PopupMenuItem(
            value: const _SceneStructureAction(
              _SceneStructureActionKind.moveToChapter,
              chapterId: null,
            ),
            child: Text(copy.t('moveToNoChapter')),
          ),
          for (final chapter in chapters)
            PopupMenuItem(
              value: _SceneStructureAction(
                _SceneStructureActionKind.moveToChapter,
                chapterId: chapter.id,
              ),
              child: Text('${copy.t('moveToChapter')}: ${chapter.title}'),
            ),
        ];
      },
    );
  }
}

enum _SceneStructureActionKind { moveUp, moveDown, moveToChapter }

final class _SceneStructureAction {
  const _SceneStructureAction(this.kind, {this.chapterId});

  final _SceneStructureActionKind kind;
  final String? chapterId;
}

final class _CatalogWorkspace extends StatelessWidget {
  const _CatalogWorkspace({
    required this.copy,
    required this.type,
    required this.items,
    required this.onCreateItem,
  });

  final WritelerCopy copy;
  final EntityType type;
  final List<CatalogItem> items;
  final VoidCallback onCreateItem;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return Column(
      children: [
        _WorkspaceHeader(
          title: copy.t(_catalogTitleKey(type)),
          actionLabel: copy.t(_newCatalogKey(type)),
          actionIcon: Icons.add,
          onAction: onCreateItem,
        ),
        const Divider(height: 1),
        Expanded(
          child: items.isEmpty
              ? _EmptyPanel(
                  icon: _catalogIcon(type),
                  title: copy.t(_emptyCatalogTitleKey(type)),
                  body: copy.t('catalogEmptyBody'),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: items.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return ListTile(
                      leading: Icon(_catalogIcon(type), color: color.primary),
                      title: Text(item.name),
                      subtitle: Text(
                        item.summary.isEmpty
                            ? copy.t('noSummary')
                            : item.summary,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Text(
                          _draftStatusLabel(item.status, copy.languageCode)),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

final class _AIWorkshop extends StatelessWidget {
  const _AIWorkshop({
    required this.copy,
    required this.project,
    required this.selectedScene,
    required this.scenes,
    required this.suggestions,
    required this.promptController,
    required this.isRequesting,
    required this.lastError,
    required this.onRequestSceneIdeas,
    required this.onRequestStructure,
    required this.onAcceptSuggestion,
    required this.onRejectSuggestion,
    required this.onConvertSuggestion,
  });

  final WritelerCopy copy;
  final Project? project;
  final Scene? selectedScene;
  final List<Scene> scenes;
  final List<AISuggestion> suggestions;
  final TextEditingController promptController;
  final bool isRequesting;
  final String? lastError;
  final VoidCallback onRequestSceneIdeas;
  final VoidCallback onRequestStructure;
  final ValueChanged<AISuggestion> onAcceptSuggestion;
  final ValueChanged<AISuggestion> onRejectSuggestion;
  final ValueChanged<AISuggestion> onConvertSuggestion;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final scene = selectedScene ?? scenes.firstOrNull;
    final aiAvailable = project?.aiEnabled == true &&
        project?.noAiNoCloud == false &&
        scene != null;

    return Column(
      children: [
        _WorkspaceHeader(title: copy.t('aiWorkshop')),
        const Divider(height: 1),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  scene == null
                      ? copy.t('aiNeedsScene')
                      : '${copy.t('aiContext')}: ${scene.title}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: promptController,
                  minLines: 2,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: copy.t('aiPrompt'),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    FilledButton.icon(
                      onPressed: aiAvailable && !isRequesting
                          ? onRequestSceneIdeas
                          : null,
                      icon: const Icon(Icons.lightbulb_outline),
                      label: Text(copy.t('requestSceneIdeas')),
                    ),
                    OutlinedButton.icon(
                      onPressed: aiAvailable && !isRequesting
                          ? onRequestStructure
                          : null,
                      icon: const Icon(Icons.account_tree_outlined),
                      label: Text(copy.t('requestStructure')),
                    ),
                  ],
                ),
                if (isRequesting || lastError != null) ...[
                  const SizedBox(height: 12),
                  _AIRequestStatus(
                    copy: copy,
                    isRequesting: isRequesting,
                    message: lastError,
                  ),
                ],
                const SizedBox(height: 24),
                Text(copy.t('suggestions'),
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Expanded(
                  child: suggestions.isEmpty
                      ? Text(copy.t('noSuggestions'),
                          style: TextStyle(color: color.onSurfaceVariant))
                      : ListView.separated(
                          itemCount: suggestions.length,
                          separatorBuilder: (context, index) =>
                              const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final suggestion = suggestions[index];
                            return ListTile(
                              leading:
                                  const Icon(Icons.psychology_alt_outlined),
                              title: Text(suggestion.suggestionType),
                              subtitle: Text(
                                suggestion.responseText,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: Wrap(
                                spacing: 4,
                                children: [
                                  IconButton(
                                    tooltip: copy.t('accept'),
                                    onPressed: () =>
                                        onAcceptSuggestion(suggestion),
                                    icon: const Icon(Icons.check),
                                  ),
                                  IconButton(
                                    tooltip: copy.t('convertToNote'),
                                    onPressed: () =>
                                        onConvertSuggestion(suggestion),
                                    icon: const Icon(
                                        Icons.sticky_note_2_outlined),
                                  ),
                                  IconButton(
                                    tooltip: copy.t('reject'),
                                    onPressed: () =>
                                        onRejectSuggestion(suggestion),
                                    icon: const Icon(Icons.close),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

final class _AIRequestStatus extends StatelessWidget {
  const _AIRequestStatus({
    required this.copy,
    required this.isRequesting,
    required this.message,
  });

  final WritelerCopy copy;
  final bool isRequesting;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final hasError = message != null && message!.isNotEmpty;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: hasError ? color.errorContainer : color.secondaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isRequesting)
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: color.onSecondaryContainer,
                ),
              )
            else
              Icon(
                Icons.error_outline,
                size: 18,
                color: color.onErrorContainer,
              ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                isRequesting
                    ? copy.t('aiRequestInProgress')
                    : message ?? copy.t('aiRequestFailed'),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: hasError
                          ? color.onErrorContainer
                          : color.onSecondaryContainer,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final class _ExportCenter extends StatelessWidget {
  const _ExportCenter({
    required this.copy,
    required this.project,
    required this.chapters,
    required this.scenes,
    required this.catalogItems,
    required this.relationships,
    required this.format,
    required this.includeSceneTitles,
    required this.includeMetadata,
    required this.exporter,
    required this.importController,
    required this.importPreview,
    required this.importPreviewError,
    required this.lastSyncCheckpoint,
    required this.syncImportPreview,
    required this.onFormatChanged,
    required this.onIncludeSceneTitlesChanged,
    required this.onIncludeMetadataChanged,
    required this.onCopyExport,
    required this.onDownloadExport,
    required this.onCopySyncCheckpoint,
    required this.onImportSourceChanged,
    required this.onImportArchive,
  });

  final WritelerCopy copy;
  final Project? project;
  final List<Chapter> chapters;
  final List<Scene> scenes;
  final List<CatalogItem> catalogItems;
  final List<Relationship> relationships;
  final ExportFormat format;
  final bool includeSceneTitles;
  final bool includeMetadata;
  final ProjectExporter exporter;
  final TextEditingController importController;
  final ProjectArchivePreview? importPreview;
  final String? importPreviewError;
  final SyncCheckpoint? lastSyncCheckpoint;
  final SyncEnvelopePreview? syncImportPreview;
  final ValueChanged<ExportFormat> onFormatChanged;
  final ValueChanged<bool> onIncludeSceneTitlesChanged;
  final ValueChanged<bool> onIncludeMetadataChanged;
  final VoidCallback onCopyExport;
  final VoidCallback onDownloadExport;
  final VoidCallback onCopySyncCheckpoint;
  final VoidCallback onImportSourceChanged;
  final VoidCallback onImportArchive;

  @override
  Widget build(BuildContext context) {
    final project = this.project;
    final preview = project == null
        ? ''
        : exporter.exportProject(
            project: project,
            chapters: chapters,
            scenes: scenes,
            catalogItems: catalogItems,
            relationships: relationships,
            profile: ExportProfile(
              id: 'preview',
              projectId: project.id,
              name: copy.t('exportPreview'),
              format: format,
              includeMetadata: includeMetadata,
              includeSceneTitles: includeSceneTitles,
            ),
          );

    return Column(
      children: [
        _WorkspaceHeader(
          title: copy.t('exports'),
          actionLabel: copy.t('copyExport'),
          actionIcon: Icons.copy,
          onAction: project == null ? null : onCopyExport,
        ),
        const Divider(height: 1),
        Expanded(
          child: Row(
            children: [
              SizedBox(
                width: 300,
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    DropdownButtonFormField<ExportFormat>(
                      initialValue: format,
                      decoration: InputDecoration(
                        labelText: copy.t('format'),
                        border: const OutlineInputBorder(),
                      ),
                      items: [
                        for (final item in ExportFormat.values)
                          DropdownMenuItem(
                            value: item,
                            child: Text(
                                _exportFormatLabel(item, copy.languageCode)),
                          ),
                      ],
                      onChanged: (value) {
                        if (value != null) onFormatChanged(value);
                      },
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      value: includeSceneTitles,
                      title: Text(copy.t('includeSceneTitles')),
                      onChanged: onIncludeSceneTitlesChanged,
                    ),
                    SwitchListTile(
                      value: includeMetadata,
                      title: Text(copy.t('includeMetadata')),
                      onChanged: onIncludeMetadataChanged,
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: project == null ? null : onDownloadExport,
                      icon: const Icon(Icons.download_outlined),
                      label: Text(copy.t('downloadExport')),
                    ),
                    const Divider(height: 28),
                    Text(copy.t('syncCheckpoint'),
                        style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 6),
                    Text(
                      copy.t('syncCheckpointBody'),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if (lastSyncCheckpoint != null) ...[
                      const SizedBox(height: 10),
                      _SyncStatusPanel(
                        copy: copy,
                        checkpoint: lastSyncCheckpoint!,
                      ),
                    ],
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: project == null ? null : onCopySyncCheckpoint,
                      icon: const Icon(Icons.sync_outlined),
                      label: Text(copy.t('copySyncCheckpoint')),
                    ),
                    const Divider(height: 28),
                    Text(copy.t('importArchive'),
                        style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 8),
                    TextField(
                      controller: importController,
                      onChanged: (_) => onImportSourceChanged(),
                      minLines: 5,
                      maxLines: 8,
                      decoration: InputDecoration(
                        labelText: copy.t('pasteArchiveJson'),
                        border: const OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                    ),
                    if (importPreview != null ||
                        importPreviewError != null) ...[
                      const SizedBox(height: 12),
                      if (syncImportPreview != null) ...[
                        _SyncEnvelopePanel(
                          copy: copy,
                          preview: syncImportPreview!,
                        ),
                        const SizedBox(height: 12),
                      ],
                      _ImportArchivePreview(
                        copy: copy,
                        preview: importPreview,
                        error: importPreviewError,
                      ),
                    ],
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: importPreview == null ? null : onImportArchive,
                      icon: const Icon(Icons.upload_file_outlined),
                      label: Text(copy.t('importProject')),
                    ),
                  ],
                ),
              ),
              const VerticalDivider(width: 1),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: SelectableText(
                    preview.isEmpty ? copy.t('nothingToExport') : preview,
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

final class _SyncStatusPanel extends StatelessWidget {
  const _SyncStatusPanel({
    required this.copy,
    required this.checkpoint,
  });

  final WritelerCopy copy;
  final SyncCheckpoint checkpoint;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              copy.t('lastSyncCheckpoint'),
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 6),
            Text(
              '${copy.t('syncFingerprint')}: ${checkpoint.fingerprint}\n'
              '${copy.t('syncAdapter')}: ${checkpoint.adapterName}\n'
              '${copy.t('syncPayloadSize')}: ${checkpoint.byteLength} B',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

final class _SyncEnvelopePanel extends StatelessWidget {
  const _SyncEnvelopePanel({
    required this.copy,
    required this.preview,
  });

  final WritelerCopy copy;
  final SyncEnvelopePreview preview;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.tertiaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.verified_outlined,
                color: color.onTertiaryContainer, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${copy.t('syncPayloadDetected')}\n'
                '${copy.t('syncFingerprint')}: ${preview.fingerprint}\n'
                '${copy.t('syncAdapter')}: ${preview.adapterName}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: color.onTertiaryContainer,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final class _ImportArchivePreview extends StatelessWidget {
  const _ImportArchivePreview({
    required this.copy,
    required this.preview,
    required this.error,
  });

  final WritelerCopy copy;
  final ProjectArchivePreview? preview;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final preview = this.preview;
    final hasError = error != null && error!.isNotEmpty;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: hasError ? color.errorContainer : color.secondaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: preview == null
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.error_outline,
                      color: color.onErrorContainer, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      error ?? copy.t('archivePreviewInvalid'),
                      style: TextStyle(color: color.onErrorContainer),
                    ),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    preview.projectTitle,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: color.onSecondaryContainer,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${copy.t('archiveSchema')}: ${preview.schema}\n'
                    '${copy.t('chapters')}: ${preview.chapterCount} · '
                    '${copy.t('scenes')}: ${preview.sceneCount}\n'
                    '${copy.t('catalog')}: ${preview.catalogItemCount} · '
                    '${copy.t('relationships')}: ${preview.relationshipCount}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: color.onSecondaryContainer,
                        ),
                  ),
                ],
              ),
      ),
    );
  }
}

final class _SettingsWorkspace extends StatelessWidget {
  const _SettingsWorkspace({
    required this.copy,
    required this.project,
    required this.providerNameController,
    required this.modelNameController,
    required this.baseUrlController,
    required this.apiKeyRefController,
    required this.providerKind,
    required this.providerEnabled,
    required this.providerHasStoredApiKey,
    required this.activeProviderConfig,
    required this.onProviderKindChanged,
    required this.onProviderEnabledChanged,
    required this.onSaveProviderConfig,
    required this.onDeleteProviderApiKey,
    required this.onSavePrivacySettings,
    required this.syncAdapterName,
  });

  final WritelerCopy copy;
  final Project? project;
  final TextEditingController providerNameController;
  final TextEditingController modelNameController;
  final TextEditingController baseUrlController;
  final TextEditingController apiKeyRefController;
  final AIProviderKind providerKind;
  final bool providerEnabled;
  final bool providerHasStoredApiKey;
  final AIProviderConfig? activeProviderConfig;
  final ValueChanged<AIProviderKind> onProviderKindChanged;
  final ValueChanged<bool> onProviderEnabledChanged;
  final VoidCallback onSaveProviderConfig;
  final VoidCallback onDeleteProviderApiKey;
  final String syncAdapterName;
  final Future<void> Function({
    required bool aiEnabled,
    required bool cloudSyncEnabled,
    required bool noAiNoCloud,
  }) onSavePrivacySettings;

  @override
  Widget build(BuildContext context) {
    final project = this.project;
    if (project == null) {
      return _EmptyPanel(
        icon: Icons.tune_outlined,
        title: copy.t('settings'),
        body: copy.t('selectProject'),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(copy.t('settings'),
            style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 20),
        SwitchListTile(
          value: project.aiEnabled,
          title: Text(copy.t('aiEnabled')),
          onChanged: (value) => onSavePrivacySettings(
            aiEnabled: value,
            cloudSyncEnabled: project.cloudSyncEnabled,
            noAiNoCloud: value ? false : project.noAiNoCloud,
          ),
        ),
        SwitchListTile(
          value: project.cloudSyncEnabled,
          title: Text(copy.t('cloudSyncEnabled')),
          onChanged: project.noAiNoCloud
              ? null
              : (value) => onSavePrivacySettings(
                    aiEnabled: project.aiEnabled,
                    cloudSyncEnabled: value,
                    noAiNoCloud: project.noAiNoCloud,
                  ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
          child: Text(
            '${copy.t('syncAdapter')}: $syncAdapterName. ${copy.t('syncAdapterHint')}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        SwitchListTile(
          value: project.noAiNoCloud,
          title: Text(copy.t('noAiNoCloud')),
          onChanged: (value) => onSavePrivacySettings(
            aiEnabled: value ? false : project.aiEnabled,
            cloudSyncEnabled: value ? false : project.cloudSyncEnabled,
            noAiNoCloud: value,
          ),
        ),
        const SizedBox(height: 24),
        Text(copy.t('providerConfig'),
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        DropdownButtonFormField<AIProviderKind>(
          initialValue: providerKind,
          decoration: InputDecoration(
            labelText: copy.t('providerKind'),
            border: const OutlineInputBorder(),
          ),
          items: [
            for (final kind in AIProviderKind.values)
              DropdownMenuItem(
                value: kind,
                child: Text(_providerKindLabel(kind, copy.languageCode)),
              ),
          ],
          onChanged: (kind) {
            if (kind != null) onProviderKindChanged(kind);
          },
        ),
        const SizedBox(height: 12),
        SwitchListTile(
          value: providerEnabled,
          title: Text(copy.t('providerEnabled')),
          onChanged: onProviderEnabledChanged,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: providerNameController,
          decoration: InputDecoration(
            labelText: copy.t('providerName'),
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: modelNameController,
          decoration: InputDecoration(
            labelText: copy.t('modelName'),
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: baseUrlController,
          decoration: InputDecoration(
            labelText: copy.t('baseUrl'),
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: apiKeyRefController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: copy.t('apiKeyRef'),
            helperText: providerHasStoredApiKey
                ? copy.t('apiKeyStoredHint')
                : copy.t('apiKeyWebWarning'),
            border: const OutlineInputBorder(),
          ),
        ),
        if (providerHasStoredApiKey) ...[
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: onDeleteProviderApiKey,
              icon: const Icon(Icons.delete_outline),
              label: Text(copy.t('deleteApiKey')),
            ),
          ),
        ],
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: FilledButton.icon(
            onPressed: onSaveProviderConfig,
            icon: const Icon(Icons.save_outlined),
            label: Text(copy.t('saveProviderConfig')),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '${copy.t('activeProvider')}: '
          '${activeProviderConfig?.displayName ?? providerNameController.text} · '
          '${activeProviderConfig?.modelName ?? modelNameController.text}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

final class _WorkspaceHeader extends StatelessWidget {
  const _WorkspaceHeader({
    required this.title,
    this.actionLabel,
    this.actionIcon,
    this.onAction,
  });

  final String title;
  final String? actionLabel;
  final IconData? actionIcon;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
            if (actionLabel != null && actionIcon != null)
              FilledButton.icon(
                onPressed: onAction,
                icon: Icon(actionIcon),
                label: Text(actionLabel!),
              ),
          ],
        ),
      ),
    );
  }
}

final class _EmptyPanel extends StatelessWidget {
  const _EmptyPanel({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color.primary, size: 34),
              const SizedBox(height: 16),
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(body, style: TextStyle(color: color.onSurfaceVariant)),
            ],
          ),
        ),
      ),
    );
  }
}

final class _ProjectLibrary extends StatelessWidget {
  const _ProjectLibrary({
    required this.copy,
    required this.projects,
    required this.selectedProject,
    required this.onSelect,
  });

  final WritelerCopy copy;
  final List<Project> projects;
  final Project? selectedProject;
  final ValueChanged<Project> onSelect;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return Align(
      alignment: Alignment.topLeft,
      child: ListView.separated(
        padding: const EdgeInsets.all(24),
        itemBuilder: (context, index) {
          final project = projects[index];
          final selected = selectedProject?.id == project.id;
          return ListTile(
            selected: selected,
            selectedTileColor: color.primaryContainer.withValues(alpha: 0.38),
            leading: Icon(
              Icons.menu_book_outlined,
              color: selected ? color.primary : color.onSurfaceVariant,
            ),
            title: Text(project.title),
            subtitle: Text('${copy.t('localOnly')} - ${project.projectType}'),
            trailing: Text(project.status.name),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            onTap: () => onSelect(project),
          );
        },
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemCount: projects.length,
      ),
    );
  }
}

final class _ProjectWorkspace extends StatelessWidget {
  const _ProjectWorkspace({
    required this.copy,
    required this.project,
    required this.chapters,
    required this.catalogItems,
    required this.relationships,
    required this.scenes,
    required this.selectedScene,
    required this.manuscriptController,
    required this.summaryController,
    required this.goalController,
    required this.conflictController,
    required this.outcomeController,
    required this.wordTargetController,
    required this.selectedSceneStatus,
    required this.selectedSceneChapterId,
    required this.onSelectScene,
    required this.onSceneChapterChanged,
    required this.onToggleSceneCatalogLink,
    required this.onSceneStatusChanged,
    required this.onCreateChapter,
    required this.onCreateScene,
    required this.onSaveScene,
  });

  final WritelerCopy copy;
  final Project? project;
  final List<Chapter> chapters;
  final List<CatalogItem> catalogItems;
  final List<Relationship> relationships;
  final List<Scene> scenes;
  final Scene? selectedScene;
  final TextEditingController manuscriptController;
  final TextEditingController summaryController;
  final TextEditingController goalController;
  final TextEditingController conflictController;
  final TextEditingController outcomeController;
  final TextEditingController wordTargetController;
  final DraftStatus selectedSceneStatus;
  final String? selectedSceneChapterId;
  final ValueChanged<Scene> onSelectScene;
  final ValueChanged<String?> onSceneChapterChanged;
  final void Function(CatalogItem item, bool selected) onToggleSceneCatalogLink;
  final ValueChanged<DraftStatus> onSceneStatusChanged;
  final VoidCallback onCreateChapter;
  final VoidCallback onCreateScene;
  final VoidCallback onSaveScene;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final project = this.project;
    if (project == null) {
      return _EmptyWorkspace(copy: copy);
    }

    return Column(
      children: [
        SizedBox(
          height: 64,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    project.title,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                FilledButton.icon(
                  onPressed: onCreateScene,
                  icon: const Icon(Icons.add),
                  label: Text(copy.t('newScene')),
                ),
                const SizedBox(width: 8),
                IconButton.outlined(
                  tooltip: copy.t('newChapter'),
                  onPressed: onCreateChapter,
                  icon: const Icon(Icons.create_new_folder_outlined),
                ),
              ],
            ),
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: Row(
            children: [
              SizedBox(
                width: 320,
                child: scenes.isEmpty
                    ? _NoScenes(copy: copy, onCreateScene: onCreateScene)
                    : _SceneList(
                        copy: copy,
                        scenes: scenes,
                        selectedScene: selectedScene,
                        onSelectScene: onSelectScene,
                      ),
              ),
              const VerticalDivider(width: 1),
              Expanded(
                child: selectedScene == null
                    ? Center(
                        child: Text(
                          copy.t('selectScene'),
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: color.onSurfaceVariant,
                                  ),
                        ),
                      )
                    : _SceneEditor(
                        copy: copy,
                        scene: selectedScene!,
                        chapters: chapters,
                        catalogItems: catalogItems,
                        relationships: relationships,
                        controller: manuscriptController,
                        summaryController: summaryController,
                        goalController: goalController,
                        conflictController: conflictController,
                        outcomeController: outcomeController,
                        wordTargetController: wordTargetController,
                        selectedSceneStatus: selectedSceneStatus,
                        selectedSceneChapterId: selectedSceneChapterId,
                        onSceneChapterChanged: onSceneChapterChanged,
                        onToggleSceneCatalogLink: onToggleSceneCatalogLink,
                        onSceneStatusChanged: onSceneStatusChanged,
                        onSaveScene: onSaveScene,
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

final class _NoScenes extends StatelessWidget {
  const _NoScenes({
    required this.copy,
    required this.onCreateScene,
  });

  final WritelerCopy copy;
  final VoidCallback onCreateScene;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.auto_awesome_motion_outlined, color: color.primary),
          const SizedBox(height: 16),
          Text(copy.t('noScenesTitle'),
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            copy.t('noScenesBody'),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: color.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: onCreateScene,
            icon: const Icon(Icons.add),
            label: Text(copy.t('newScene')),
          ),
        ],
      ),
    );
  }
}

final class _SceneList extends StatelessWidget {
  const _SceneList({
    required this.copy,
    required this.scenes,
    required this.selectedScene,
    required this.onSelectScene,
  });

  final WritelerCopy copy;
  final List<Scene> scenes;
  final Scene? selectedScene;
  final ValueChanged<Scene> onSelectScene;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final scene = scenes[index];
        final selected = selectedScene?.id == scene.id;
        return ListTile(
          selected: selected,
          selectedTileColor: color.primaryContainer.withValues(alpha: 0.38),
          leading: Icon(
            Icons.notes_outlined,
            color: selected ? color.primary : color.onSurfaceVariant,
          ),
          title:
              Text(scene.title, maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Text('${scene.actualWordCount} ${copy.t('words')}'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          onTap: () => onSelectScene(scene),
        );
      },
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemCount: scenes.length,
    );
  }
}

final class _SceneEditor extends StatefulWidget {
  const _SceneEditor({
    required this.copy,
    required this.scene,
    required this.chapters,
    required this.catalogItems,
    required this.relationships,
    required this.controller,
    required this.summaryController,
    required this.goalController,
    required this.conflictController,
    required this.outcomeController,
    required this.wordTargetController,
    required this.selectedSceneStatus,
    required this.selectedSceneChapterId,
    required this.onSceneChapterChanged,
    required this.onToggleSceneCatalogLink,
    required this.onSceneStatusChanged,
    required this.onSaveScene,
  });

  final WritelerCopy copy;
  final Scene scene;
  final List<Chapter> chapters;
  final List<CatalogItem> catalogItems;
  final List<Relationship> relationships;
  final TextEditingController controller;
  final TextEditingController summaryController;
  final TextEditingController goalController;
  final TextEditingController conflictController;
  final TextEditingController outcomeController;
  final TextEditingController wordTargetController;
  final DraftStatus selectedSceneStatus;
  final String? selectedSceneChapterId;
  final ValueChanged<String?> onSceneChapterChanged;
  final void Function(CatalogItem item, bool selected) onToggleSceneCatalogLink;
  final ValueChanged<DraftStatus> onSceneStatusChanged;
  final VoidCallback onSaveScene;

  @override
  State<_SceneEditor> createState() => _SceneEditorState();
}

final class _SceneEditorState extends State<_SceneEditor> {
  late final TextEditingController _searchController = TextEditingController();
  late final TextEditingController _replaceController = TextEditingController();
  bool _focusMode = false;
  bool _showSearch = false;

  @override
  void dispose() {
    _searchController.dispose();
    _replaceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final copy = widget.copy;
    final scene = widget.scene;
    final color = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  scene.title,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              FilledButton.icon(
                onPressed: widget.onSaveScene,
                icon: const Icon(Icons.save_outlined),
                label: Text(copy.t('saveScene')),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (!_focusMode) ...[
            _ScenePlanningFields(
              copy: copy,
              summaryController: widget.summaryController,
              goalController: widget.goalController,
              conflictController: widget.conflictController,
              outcomeController: widget.outcomeController,
              wordTargetController: widget.wordTargetController,
              selectedSceneStatus: widget.selectedSceneStatus,
              chapters: widget.chapters,
              selectedSceneChapterId: widget.selectedSceneChapterId,
              onSceneChapterChanged: widget.onSceneChapterChanged,
              onSceneStatusChanged: widget.onSceneStatusChanged,
            ),
            const SizedBox(height: 16),
            _SceneContextLinks(
              copy: copy,
              scene: scene,
              catalogItems: widget.catalogItems,
              relationships: widget.relationships,
              onToggleLink: widget.onToggleSceneCatalogLink,
            ),
            const SizedBox(height: 16),
          ],
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: widget.controller,
            builder: (context, value, child) {
              return _ManuscriptToolbar(
                copy: copy,
                text: value.text,
                targetText: widget.wordTargetController.text,
                focusMode: _focusMode,
                searchOpen: _showSearch,
                onToggleFocus: () => setState(() => _focusMode = !_focusMode),
                onToggleSearch: () =>
                    setState(() => _showSearch = !_showSearch),
              );
            },
          ),
          if (_showSearch) ...[
            const SizedBox(height: 12),
            _ManuscriptSearchBar(
              copy: copy,
              manuscriptController: widget.controller,
              searchController: _searchController,
              replaceController: _replaceController,
              onChanged: () => setState(() {}),
            ),
          ],
          const SizedBox(height: 12),
          Expanded(
            child: TextField(
              controller: widget.controller,
              expands: true,
              maxLines: null,
              minLines: null,
              textAlignVertical: TextAlignVertical.top,
              decoration: InputDecoration(
                labelText: copy.t('manuscript'),
                alignLabelWithHint: true,
                filled: true,
                fillColor:
                    color.surfaceContainerHighest.withValues(alpha: 0.28),
                border: const OutlineInputBorder(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

final class _ManuscriptToolbar extends StatelessWidget {
  const _ManuscriptToolbar({
    required this.copy,
    required this.text,
    required this.targetText,
    required this.focusMode,
    required this.searchOpen,
    required this.onToggleFocus,
    required this.onToggleSearch,
  });

  final WritelerCopy copy;
  final String text;
  final String targetText;
  final bool focusMode;
  final bool searchOpen;
  final VoidCallback onToggleFocus;
  final VoidCallback onToggleSearch;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final words = _countWords(text);
    final characters = text.characters.length;
    final target = int.tryParse(targetText);
    final progress =
        target == null || target <= 0 ? null : (words / target).clamp(0.0, 1.0);

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: color.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            _EditorStat(label: copy.t('words'), value: '$words'),
            const SizedBox(width: 16),
            _EditorStat(label: copy.t('characterCount'), value: '$characters'),
            if (target != null && target > 0) ...[
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${copy.t('targetProgress')}: $words / $target',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 6),
                    LinearProgressIndicator(value: progress),
                  ],
                ),
              ),
            ] else
              const Spacer(),
            const SizedBox(width: 12),
            Tooltip(
              message: copy.t('searchReplace'),
              child: IconButton.outlined(
                isSelected: searchOpen,
                onPressed: onToggleSearch,
                icon: const Icon(Icons.find_replace_outlined),
              ),
            ),
            const SizedBox(width: 8),
            Tooltip(
              message:
                  focusMode ? copy.t('exitFocusMode') : copy.t('focusMode'),
              child: IconButton.outlined(
                isSelected: focusMode,
                onPressed: onToggleFocus,
                icon:
                    Icon(focusMode ? Icons.fullscreen_exit : Icons.fullscreen),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final class _EditorStat extends StatelessWidget {
  const _EditorStat({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return SizedBox(
      width: 84,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

final class _ManuscriptSearchBar extends StatelessWidget {
  const _ManuscriptSearchBar({
    required this.copy,
    required this.manuscriptController,
    required this.searchController,
    required this.replaceController,
    required this.onChanged,
  });

  final WritelerCopy copy;
  final TextEditingController manuscriptController;
  final TextEditingController searchController;
  final TextEditingController replaceController;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final matchCount =
        _countMatches(manuscriptController.text, searchController.text);
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 760;
        final searchField = TextField(
          controller: searchController,
          onChanged: (_) => onChanged(),
          decoration: InputDecoration(
            labelText: copy.t('findText'),
            border: const OutlineInputBorder(),
            isDense: true,
          ),
        );
        final replaceField = TextField(
          controller: replaceController,
          decoration: InputDecoration(
            labelText: copy.t('replaceWith'),
            border: const OutlineInputBorder(),
            isDense: true,
          ),
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (compact)
              Column(
                children: [
                  searchField,
                  const SizedBox(height: 12),
                  replaceField,
                ],
              )
            else
              Row(
                children: [
                  Expanded(child: searchField),
                  const SizedBox(width: 12),
                  Expanded(child: replaceField),
                ],
              ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text('${copy.t('matches')}: $matchCount'),
                OutlinedButton.icon(
                  onPressed: matchCount == 0 ? null : _selectNextMatch,
                  icon: const Icon(Icons.keyboard_arrow_down),
                  label: Text(copy.t('nextMatch')),
                ),
                OutlinedButton.icon(
                  onPressed: matchCount == 0 ? null : _replaceCurrentOrNext,
                  icon: const Icon(Icons.find_replace),
                  label: Text(copy.t('replaceNext')),
                ),
                FilledButton.icon(
                  onPressed: matchCount == 0 ? null : _replaceAll,
                  icon: const Icon(Icons.done_all),
                  label: Text(copy.t('replaceAll')),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _selectNextMatch() {
    final query = searchController.text;
    final text = manuscriptController.text;
    final range = _nextMatchRange(
      text: text,
      query: query,
      from: manuscriptController.selection.end,
    );
    if (range == null) return;
    manuscriptController.selection =
        TextSelection(baseOffset: range.start, extentOffset: range.end);
    onChanged();
  }

  void _replaceCurrentOrNext() {
    final query = searchController.text;
    if (query.isEmpty) return;
    final text = manuscriptController.text;
    final selection = manuscriptController.selection;
    var start = selection.start;
    var end = selection.end;
    if (start < 0 || end < 0 || start == end) {
      final range =
          _nextMatchRange(text: text, query: query, from: selection.end);
      if (range == null) return;
      start = range.start;
      end = range.end;
    }
    final selected = text.substring(start, end);
    if (selected.toLowerCase() != query.toLowerCase()) {
      final range = _nextMatchRange(text: text, query: query, from: end);
      if (range == null) return;
      start = range.start;
      end = range.end;
    }
    final replacement = replaceController.text;
    final updated = text.replaceRange(start, end, replacement);
    manuscriptController.value = TextEditingValue(
      text: updated,
      selection: TextSelection.collapsed(offset: start + replacement.length),
    );
    onChanged();
  }

  void _replaceAll() {
    final query = searchController.text;
    if (query.isEmpty) return;
    final escaped = RegExp.escape(query);
    final updated = manuscriptController.text.replaceAll(
      RegExp(escaped, caseSensitive: false),
      replaceController.text,
    );
    manuscriptController.value = TextEditingValue(
      text: updated,
      selection: TextSelection.collapsed(offset: updated.length),
    );
    onChanged();
  }
}

final class _ScenePlanningFields extends StatelessWidget {
  const _ScenePlanningFields({
    required this.copy,
    required this.summaryController,
    required this.goalController,
    required this.conflictController,
    required this.outcomeController,
    required this.wordTargetController,
    required this.selectedSceneStatus,
    required this.chapters,
    required this.selectedSceneChapterId,
    required this.onSceneChapterChanged,
    required this.onSceneStatusChanged,
  });

  final WritelerCopy copy;
  final TextEditingController summaryController;
  final TextEditingController goalController;
  final TextEditingController conflictController;
  final TextEditingController outcomeController;
  final TextEditingController wordTargetController;
  final DraftStatus selectedSceneStatus;
  final List<Chapter> chapters;
  final String? selectedSceneChapterId;
  final ValueChanged<String?> onSceneChapterChanged;
  final ValueChanged<DraftStatus> onSceneStatusChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 760;
        final statusAndTarget = _responsivePair(
          compact: compact,
          firstFlex: 2,
          first: DropdownButtonFormField<DraftStatus>(
            key: ValueKey(selectedSceneStatus),
            initialValue: selectedSceneStatus,
            decoration: InputDecoration(
              labelText: copy.t('status'),
              border: const OutlineInputBorder(),
              isDense: true,
            ),
            items: [
              for (final status in DraftStatus.values)
                DropdownMenuItem(
                  value: status,
                  child: Text(_draftStatusLabel(status, copy.languageCode)),
                ),
            ],
            onChanged: (status) {
              if (status != null) onSceneStatusChanged(status);
            },
          ),
          second: TextField(
            controller: wordTargetController,
            decoration: InputDecoration(
              labelText: copy.t('wordTarget'),
              border: const OutlineInputBorder(),
              isDense: true,
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
        );

        final goalAndConflict = _responsivePair(
          compact: compact,
          first: _planningTextField(
            controller: goalController,
            label: copy.t('goal'),
            maxLines: 2,
          ),
          second: _planningTextField(
            controller: conflictController,
            label: copy.t('conflict'),
            maxLines: 2,
          ),
        );

        return Column(
          children: [
            DropdownButtonFormField<String?>(
              key: ValueKey(selectedSceneChapterId ?? 'no-chapter'),
              initialValue: selectedSceneChapterId,
              decoration: InputDecoration(
                labelText: copy.t('chapter'),
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              items: [
                DropdownMenuItem<String?>(
                  value: null,
                  child: Text(copy.t('noChapter')),
                ),
                for (final chapter in chapters)
                  DropdownMenuItem<String?>(
                    value: chapter.id,
                    child: Text(chapter.title),
                  ),
              ],
              onChanged: onSceneChapterChanged,
            ),
            const SizedBox(height: 12),
            statusAndTarget,
            const SizedBox(height: 12),
            _planningTextField(
              controller: summaryController,
              label: copy.t('summary'),
              maxLines: compact ? 3 : 2,
            ),
            const SizedBox(height: 12),
            goalAndConflict,
            const SizedBox(height: 12),
            _planningTextField(
              controller: outcomeController,
              label: copy.t('outcome'),
              maxLines: 2,
            ),
          ],
        );
      },
    );
  }

  Widget _responsivePair({
    required bool compact,
    required Widget first,
    required Widget second,
    int firstFlex = 1,
  }) {
    if (compact) {
      return Column(
        children: [
          first,
          const SizedBox(height: 12),
          second,
        ],
      );
    }

    return Row(
      children: [
        Expanded(flex: firstFlex, child: first),
        const SizedBox(width: 12),
        Expanded(child: second),
      ],
    );
  }

  Widget _planningTextField({
    required TextEditingController controller,
    required String label,
    required int maxLines,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        alignLabelWithHint: true,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
    );
  }
}

final class _SceneContextLinks extends StatelessWidget {
  const _SceneContextLinks({
    required this.copy,
    required this.scene,
    required this.catalogItems,
    required this.relationships,
    required this.onToggleLink,
  });

  final WritelerCopy copy;
  final Scene scene;
  final List<CatalogItem> catalogItems;
  final List<Relationship> relationships;
  final void Function(CatalogItem item, bool selected) onToggleLink;

  @override
  Widget build(BuildContext context) {
    final relevantItems = catalogItems
        .where(
          (item) =>
              item.type == EntityType.character ||
              item.type == EntityType.location ||
              item.type == EntityType.object,
        )
        .toList();
    if (relevantItems.isEmpty) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Text(
          copy.t('sceneContextEmpty'),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(copy.t('sceneContext'),
            style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final item in relevantItems)
              FilterChip(
                avatar: Icon(_catalogIcon(item.type), size: 18),
                label: Text(item.name),
                selected: _isLinked(item),
                onSelected: (selected) => onToggleLink(item, selected),
              ),
          ],
        ),
      ],
    );
  }

  bool _isLinked(CatalogItem item) {
    return relationships.any(
      (relationship) =>
          relationship.source.type == EntityType.scene &&
          relationship.source.id == scene.id &&
          relationship.target.type == item.type &&
          relationship.target.id == item.id &&
          relationship.relationshipType == 'appearsIn',
    );
  }
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
    'scene.created' => german ? 'Szene angelegt' : 'Scene created',
    'scene.saved' => german ? 'Szene gespeichert' : 'Scene saved',
    'scene.reordered' => german ? 'Szene sortiert' : 'Scene reordered',
    'scene.moved' => german ? 'Szene verschoben' : 'Scene moved',
    'catalog.created' =>
      german ? 'Katalogeintrag angelegt' : 'Catalog item created',
    'relationship.linked' => german ? 'Kontext verknuepft' : 'Context linked',
    'relationship.unlinked' => german ? 'Kontext geloest' : 'Context unlinked',
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
