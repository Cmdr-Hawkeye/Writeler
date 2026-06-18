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
import 'features/ai_harness/application/apply_ai_suggestion_to_scene.dart';
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
import 'features/notes/domain/project_note.dart';
import 'features/notes/domain/project_note_repository.dart';
import 'features/notes/infrastructure/drift_project_note_repository.dart';
import 'features/notes/infrastructure/lazy_project_note_repository.dart';
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
      projectNoteRepository: LazyProjectNoteRepository(
        () => DriftProjectNoteRepository(getDatabase()),
      ),
      aiProviderConfigRepository: LazyAIProviderConfigRepository(
        () => DriftAIProviderConfigRepository(getDatabase()),
      ),
      secretVault: const FlutterSecureSecretVault(),
    ),
  );
}

final class WritelerApp extends StatefulWidget {
  const WritelerApp({
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

  @override
  State<WritelerApp> createState() => _WritelerAppState();
}

final class _WritelerAppState extends State<WritelerApp> {
  WritelerDesignTheme _designTheme = WritelerDesignTheme.paper;

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
      theme: _buildWritelerTheme(_designTheme),
      themeMode: ThemeMode.light,
      home: WritelerShell(
        projectRepository: widget.projectRepository,
        sceneRepository: widget.sceneRepository,
        chapterRepository: widget.chapterRepository,
        catalogItemRepository: widget.catalogItemRepository,
        relationshipRepository: widget.relationshipRepository,
        metricRepository: widget.metricRepository,
        aiSuggestionRepository: widget.aiSuggestionRepository,
        projectNoteRepository: widget.projectNoteRepository,
        aiProviderConfigRepository: widget.aiProviderConfigRepository,
        secretVault: widget.secretVault,
        designTheme: _designTheme,
        onDesignThemeChanged: (theme) => setState(() => _designTheme = theme),
      ),
    );
  }
}

enum WritelerDesignTheme {
  paper,
  dusk,
  sapphire,
  sage,
  copper,
  ink,
}

final class _WritelerThemeTokens {
  const _WritelerThemeTokens({
    required this.brightness,
    required this.seed,
    required this.primary,
    required this.onPrimary,
    required this.secondary,
    required this.tertiary,
    required this.surface,
    required this.surfaceLowest,
    required this.surfaceLow,
    required this.surfaceMid,
    required this.surfaceHigh,
    required this.surfaceHighest,
    required this.outline,
    required this.outlineVariant,
    required this.error,
  });

  final Brightness brightness;
  final Color seed;
  final Color primary;
  final Color onPrimary;
  final Color secondary;
  final Color tertiary;
  final Color surface;
  final Color surfaceLowest;
  final Color surfaceLow;
  final Color surfaceMid;
  final Color surfaceHigh;
  final Color surfaceHighest;
  final Color outline;
  final Color outlineVariant;
  final Color error;
}

_WritelerThemeTokens _tokensFor(WritelerDesignTheme theme) {
  return switch (theme) {
    WritelerDesignTheme.paper => const _WritelerThemeTokens(
        brightness: Brightness.light,
        seed: Color(0xFF2A8C7D),
        primary: Color(0xFF087467),
        onPrimary: Colors.white,
        secondary: Color(0xFF7D5A16),
        tertiary: Color(0xFF35618C),
        surface: Color(0xFFF6FAFB),
        surfaceLowest: Color(0xFFFFFFFF),
        surfaceLow: Color(0xFFF0F7F8),
        surfaceMid: Color(0xFFE9F2F3),
        surfaceHigh: Color(0xFFDDE9EA),
        surfaceHighest: Color(0xFFD1E0E2),
        outline: Color(0xFF8BA2A5),
        outlineVariant: Color(0xFFC9D8DA),
        error: Color(0xFFBA1A1A),
      ),
    WritelerDesignTheme.dusk => const _WritelerThemeTokens(
        brightness: Brightness.dark,
        seed: Color(0xFF9BE7D8),
        primary: Color(0xFFA7EEE1),
        onPrimary: Color(0xFF062321),
        secondary: Color(0xFFFFCE7A),
        tertiary: Color(0xFFAFCBFF),
        surface: Color(0xFF081312),
        surfaceLowest: Color(0xFF040908),
        surfaceLow: Color(0xFF0A1715),
        surfaceMid: Color(0xFF0F201D),
        surfaceHigh: Color(0xFF152A27),
        surfaceHighest: Color(0xFF1B3430),
        outline: Color(0xFF4D6864),
        outlineVariant: Color(0xFF243C38),
        error: Color(0xFFFFA0A8),
      ),
    WritelerDesignTheme.sapphire => const _WritelerThemeTokens(
        brightness: Brightness.dark,
        seed: Color(0xFF7FB8FF),
        primary: Color(0xFF8FC4FF),
        onPrimary: Color(0xFF071A33),
        secondary: Color(0xFFA7D5FF),
        tertiary: Color(0xFFFFC68F),
        surface: Color(0xFF07111E),
        surfaceLowest: Color(0xFF030915),
        surfaceLow: Color(0xFF0B1726),
        surfaceMid: Color(0xFF102033),
        surfaceHigh: Color(0xFF172C45),
        surfaceHighest: Color(0xFF1F3958),
        outline: Color(0xFF536D8B),
        outlineVariant: Color(0xFF273E59),
        error: Color(0xFFFFA0A8),
      ),
    WritelerDesignTheme.sage => const _WritelerThemeTokens(
        brightness: Brightness.light,
        seed: Color(0xFF73956F),
        primary: Color(0xFF3F6E44),
        onPrimary: Colors.white,
        secondary: Color(0xFF7D6232),
        tertiary: Color(0xFF3F6B75),
        surface: Color(0xFFF7F8F1),
        surfaceLowest: Color(0xFFFFFFFF),
        surfaceLow: Color(0xFFF0F2E7),
        surfaceMid: Color(0xFFE7EBD9),
        surfaceHigh: Color(0xFFDDE4CC),
        surfaceHighest: Color(0xFFD1DABD),
        outline: Color(0xFF95A285),
        outlineVariant: Color(0xFFD0D8C1),
        error: Color(0xFFBA1A1A),
      ),
    WritelerDesignTheme.copper => const _WritelerThemeTokens(
        brightness: Brightness.light,
        seed: Color(0xFFB86F45),
        primary: Color(0xFF9C4F2B),
        onPrimary: Colors.white,
        secondary: Color(0xFF526A75),
        tertiary: Color(0xFF76603A),
        surface: Color(0xFFFFF8F3),
        surfaceLowest: Color(0xFFFFFFFF),
        surfaceLow: Color(0xFFF8EFE8),
        surfaceMid: Color(0xFFF0E3DA),
        surfaceHigh: Color(0xFFE8D7CB),
        surfaceHighest: Color(0xFFDDCABD),
        outline: Color(0xFFA99385),
        outlineVariant: Color(0xFFD9C9BE),
        error: Color(0xFFBA1A1A),
      ),
    WritelerDesignTheme.ink => const _WritelerThemeTokens(
        brightness: Brightness.dark,
        seed: Color(0xFFD8D1FF),
        primary: Color(0xFFD6D0FF),
        onPrimary: Color(0xFF17142A),
        secondary: Color(0xFFFFC9A9),
        tertiary: Color(0xFF9BE7D8),
        surface: Color(0xFF111018),
        surfaceLowest: Color(0xFF08070E),
        surfaceLow: Color(0xFF16141F),
        surfaceMid: Color(0xFF1D1A29),
        surfaceHigh: Color(0xFF252135),
        surfaceHighest: Color(0xFF302A43),
        outline: Color(0xFF6B647D),
        outlineVariant: Color(0xFF3B354D),
        error: Color(0xFFFFA0A8),
      ),
  };
}

ThemeData _buildWritelerTheme(WritelerDesignTheme designTheme) {
  final tokens = _tokensFor(designTheme);
  final dark = tokens.brightness == Brightness.dark;
  final baseScheme = ColorScheme.fromSeed(
    seedColor: tokens.seed,
    brightness: tokens.brightness,
  );
  final scheme = baseScheme.copyWith(
    primary: tokens.primary,
    onPrimary: tokens.onPrimary,
    secondary: tokens.secondary,
    tertiary: tokens.tertiary,
    surface: tokens.surface,
    surfaceContainerLowest: tokens.surfaceLowest,
    surfaceContainerLow: tokens.surfaceLow,
    surfaceContainer: tokens.surfaceMid,
    surfaceContainerHigh: tokens.surfaceHigh,
    surfaceContainerHighest: tokens.surfaceHighest,
    outline: tokens.outline,
    outlineVariant: tokens.outlineVariant,
    error: tokens.error,
  );
  final textTheme =
      (dark ? Typography.material2021().white : Typography.material2021().black)
          .apply(
    fontFamily: 'Roboto',
    displayColor: scheme.onSurface,
    bodyColor: scheme.onSurface,
  );

  const radius = 8.0;
  final outlineBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(radius),
    borderSide: BorderSide(color: scheme.outlineVariant),
  );

  return ThemeData(
    brightness: tokens.brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: scheme.surface,
    canvasColor: scheme.surface,
    fontFamily: 'Aptos',
    fontFamilyFallback: const [
      'Segoe UI Variable',
      'Segoe UI',
      'Inter',
      'Roboto',
      'Arial',
      'sans-serif',
    ],
    textTheme: textTheme.copyWith(
      headlineMedium: textTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: 0,
      ),
      headlineSmall: textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: 0,
      ),
      titleLarge: textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: 0,
      ),
      titleMedium: textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
      ),
      labelLarge: textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: 0,
      ),
      labelMedium: textTheme.labelMedium?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
      ),
      bodyMedium: textTheme.bodyMedium?.copyWith(height: 1.45),
      bodyLarge: textTheme.bodyLarge?.copyWith(height: 1.5),
    ),
    useMaterial3: true,
    visualDensity: VisualDensity.standard,
    dividerTheme: DividerThemeData(
      color: scheme.outlineVariant.withValues(alpha: dark ? 0.72 : 0.9),
      thickness: 1,
      space: 1,
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: Colors.transparent,
      indicatorColor: scheme.primary.withValues(alpha: dark ? 0.18 : 0.12),
      indicatorShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
      ),
      selectedIconTheme: IconThemeData(color: scheme.primary, size: 23),
      unselectedIconTheme:
          IconThemeData(color: scheme.onSurfaceVariant, size: 22),
      selectedLabelTextStyle: TextStyle(
        color: scheme.primary,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
      ),
      unselectedLabelTextStyle: TextStyle(
        color: scheme.onSurfaceVariant,
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
      ),
    ),
    listTileTheme: ListTileThemeData(
      minLeadingWidth: 28,
      minVerticalPadding: 10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
      ),
      selectedTileColor: scheme.primary.withValues(alpha: dark ? 0.14 : 0.09),
      iconColor: scheme.onSurfaceVariant,
      selectedColor: scheme.primary,
      titleTextStyle: textTheme.bodyLarge?.copyWith(
        color: scheme.onSurface,
        fontWeight: FontWeight.w600,
      ),
      subtitleTextStyle: textTheme.bodyMedium?.copyWith(
        color: scheme.onSurfaceVariant,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: scheme.surfaceContainerLow,
      border: outlineBorder,
      enabledBorder: outlineBorder,
      focusedBorder: outlineBorder.copyWith(
        borderSide: BorderSide(color: scheme.primary, width: 1.6),
      ),
      errorBorder: outlineBorder.copyWith(
        borderSide: BorderSide(color: scheme.error),
      ),
      focusedErrorBorder: outlineBorder.copyWith(
        borderSide: BorderSide(color: scheme.error, width: 1.6),
      ),
      labelStyle: TextStyle(color: scheme.onSurfaceVariant),
      floatingLabelStyle: TextStyle(color: scheme.primary),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(48, 44),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(48, 44),
        foregroundColor: scheme.primary,
        side: BorderSide(color: scheme.outline),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        minimumSize: const Size(44, 40),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        minimumSize: const Size(44, 44),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: scheme.surfaceContainerHigh,
      selectedColor: scheme.primary.withValues(alpha: dark ? 0.18 : 0.12),
      side: BorderSide(color: scheme.outlineVariant),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
      ),
      labelStyle: TextStyle(color: scheme.onSurface),
      secondaryLabelStyle: TextStyle(color: scheme.primary),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
        ),
        side: WidgetStatePropertyAll(BorderSide(color: scheme.outlineVariant)),
      ),
    ),
    dropdownMenuTheme: DropdownMenuThemeData(
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerLow,
        border: outlineBorder,
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: scheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: scheme.outlineVariant),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: dark ? const Color(0xFF19312C) : scheme.inverseSurface,
      contentTextStyle: TextStyle(color: dark ? scheme.onSurface : null),
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: scheme.inverseSurface,
        borderRadius: BorderRadius.circular(radius),
      ),
      textStyle: TextStyle(color: scheme.onInverseSurface),
    ),
    scrollbarTheme: ScrollbarThemeData(
      thumbVisibility: WidgetStateProperty.all(false),
      thickness: WidgetStateProperty.all(7),
      radius: const Radius.circular(radius),
      thumbColor: WidgetStateProperty.all(
        scheme.primary.withValues(alpha: dark ? 0.44 : 0.34),
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? scheme.primary
            : scheme.outline,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? scheme.primary.withValues(alpha: 0.34)
            : scheme.surfaceContainerHighest,
      ),
    ),
  );
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
  late final List<_WorkspaceNavItem> _navItems = [
    _WorkspaceNavItem(
      index: 0,
      icon: Icons.library_books_outlined,
      selectedIcon: Icons.library_books,
      labelBuilder: (copy) => copy.t('projects'),
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
        0 => copy.t('projects'),
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
        0 => Icons.library_books_outlined,
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
          metrics: _metrics,
          suggestions: _suggestions,
          onSelectProject: _selectProject,
          onDeleteProject: (project) => _deleteProject(project, copy),
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

enum _WorkspaceNavGroup { organize, write, world, review, output }

final class _WorkspaceNavItem {
  const _WorkspaceNavItem({
    required this.index,
    required this.icon,
    required this.selectedIcon,
    required this.labelBuilder,
    required this.group,
  });

  final int index;
  final IconData icon;
  final IconData selectedIcon;
  final String Function(WritelerCopy copy) labelBuilder;
  final _WorkspaceNavGroup group;
}

final class _WorkspaceNavigation extends StatelessWidget {
  const _WorkspaceNavigation({
    required this.copy,
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
  });

  final WritelerCopy copy;
  final List<_WorkspaceNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Container(
      width: 244,
      decoration: BoxDecoration(
        color: color.surfaceContainerLowest,
        border: Border(
          right: BorderSide(color: color.outlineVariant),
        ),
      ),
      child: SafeArea(
        right: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(18, 16, 18, 12),
              child: _BrandMark(),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final group in _WorkspaceNavGroup.values) ...[
                      _NavigationGroupLabel(label: _navGroupLabel(group, copy)),
                      for (final item
                          in items.where((item) => item.group == group))
                        _WorkspaceNavButton(
                          item: item,
                          label: item.labelBuilder(copy),
                          selected: item.index == selectedIndex,
                          onTap: () => onSelected(item.index),
                        ),
                      const SizedBox(height: 4),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _navGroupLabel(_WorkspaceNavGroup group, WritelerCopy copy) =>
    switch (group) {
      _WorkspaceNavGroup.organize => copy.t('project'),
      _WorkspaceNavGroup.write => copy.t('manuscript'),
      _WorkspaceNavGroup.world => copy.t('catalog'),
      _WorkspaceNavGroup.review => copy.t('analysis'),
      _WorkspaceNavGroup.output => copy.t('exports'),
    };

final class _NavigationGroupLabel extends StatelessWidget {
  const _NavigationGroupLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 4),
      child: Text(
        label.toUpperCase(),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color.onSurfaceVariant,
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }
}

final class _WorkspaceNavButton extends StatefulWidget {
  const _WorkspaceNavButton({
    required this.item,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final _WorkspaceNavItem item;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_WorkspaceNavButton> createState() => _WorkspaceNavButtonState();
}

final class _WorkspaceNavButtonState extends State<_WorkspaceNavButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final active = widget.selected || _hovered;
    final foreground = widget.selected
        ? color.primary
        : color.onSurface.withValues(alpha: 0.86);
    final background = widget.selected
        ? color.primary.withValues(alpha: 0.12)
        : _hovered
            ? color.surfaceContainer
            : Colors.transparent;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Semantics(
        button: true,
        selected: widget.selected,
        label: widget.label,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: widget.onTap,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 130),
                curve: Curves.easeOutCubic,
                constraints: const BoxConstraints(minHeight: 36),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: background,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: widget.selected
                        ? color.primary.withValues(alpha: 0.24)
                        : Colors.transparent,
                  ),
                ),
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 130),
                      width: 3,
                      height: active ? 20 : 12,
                      decoration: BoxDecoration(
                        color: widget.selected
                            ? color.primary
                            : _hovered
                                ? color.outline
                                : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Icon(
                      widget.selected
                          ? widget.item.selectedIcon
                          : widget.item.icon,
                      size: 20,
                      color: foreground,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        widget.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: foreground,
                              fontWeight: widget.selected
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

final class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Tooltip(
      message: 'Writeler',
      child: Semantics(
        label: 'Writeler',
        child: Row(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: color.primary.withValues(alpha: 0.12),
                border: Border.all(
                  color: color.primary.withValues(alpha: 0.36),
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SizedBox(
                width: 46,
                height: 46,
                child: CustomPaint(
                  painter: _WritelerMarkPainter(
                    primary: color.primary,
                    secondary: color.secondary,
                    surface: color.surfaceContainerLowest,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Writeler',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: color.onSurface,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final class _WritelerMarkPainter extends CustomPainter {
  const _WritelerMarkPainter({
    required this.primary,
    required this.secondary,
    required this.surface,
  });

  final Color primary;
  final Color secondary;
  final Color surface;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final fill = Paint()
      ..color = primary.withValues(alpha: 0.14)
      ..style = PaintingStyle.fill;
    final accent = Paint()
      ..color = secondary
      ..style = PaintingStyle.fill;

    final page = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.22,
        size.height * 0.22,
        size.width * 0.46,
        size.height * 0.52,
      ),
      const Radius.circular(5),
    );
    canvas.drawRRect(page, fill);
    canvas.drawRRect(page, stroke);

    final path = Path()
      ..moveTo(size.width * 0.24, size.height * 0.66)
      ..lineTo(size.width * 0.35, size.height * 0.43)
      ..lineTo(size.width * 0.46, size.height * 0.66)
      ..lineTo(size.width * 0.58, size.height * 0.39)
      ..lineTo(size.width * 0.72, size.height * 0.66);
    canvas.drawPath(path, stroke);

    canvas.drawCircle(
      Offset(size.width * 0.72, size.height * 0.70),
      3.3,
      accent,
    );
    canvas.drawCircle(
      Offset(size.width * 0.72, size.height * 0.70),
      1.4,
      Paint()..color = surface,
    );
  }

  @override
  bool shouldRepaint(covariant _WritelerMarkPainter oldDelegate) {
    return primary != oldDelegate.primary ||
        secondary != oldDelegate.secondary ||
        surface != oldDelegate.surface;
  }
}

final class _StudioTopBar extends StatelessWidget {
  const _StudioTopBar({
    required this.copy,
    required this.workspaceTitle,
    required this.workspaceIcon,
    required this.project,
    required this.showCreateProject,
    required this.onCreateProject,
  });

  final WritelerCopy copy;
  final String workspaceTitle;
  final IconData workspaceIcon;
  final Project? project;
  final bool showCreateProject;
  final VoidCallback onCreateProject;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final projectTitle = project?.title ?? copy.t('selectProject');

    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: color.surfaceContainerLowest,
        border: Border(
          bottom: BorderSide(color: color.outlineVariant),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color.primary.withValues(alpha: 0.24)),
            ),
            child: Icon(workspaceIcon, color: color.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  workspaceTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 2),
                Text(
                  projectTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: color.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          if (showCreateProject)
            FilledButton.icon(
              onPressed: onCreateProject,
              icon: const Icon(Icons.add),
              label: Text(copy.t('newProject')),
            ),
        ],
      ),
    );
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
    required this.onDeleteProject,
    required this.onSelectScene,
    required this.onDeleteScene,
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
  final ValueChanged<Project> onDeleteProject;
  final ValueChanged<Scene> onSelectScene;
  final ValueChanged<Scene> onDeleteScene;
  final ValueChanged<String?> onSceneChapterChanged;
  final void Function(CatalogItem item, bool selected) onToggleSceneCatalogLink;
  final ValueChanged<DraftStatus> onSceneStatusChanged;
  final VoidCallback onCreateChapter;
  final VoidCallback onCreateScene;
  final VoidCallback onSaveScene;

  @override
  Widget build(BuildContext context) {
    final library = _ProjectLibrary(
      copy: copy,
      projects: projects,
      selectedProject: selectedProject,
      onSelect: onSelectProject,
      onDelete: onDeleteProject,
    );
    final workspace = _ProjectWorkspace(
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
      onDeleteScene: onDeleteScene,
      onSceneChapterChanged: onSceneChapterChanged,
      onToggleSceneCatalogLink: onToggleSceneCatalogLink,
      onSceneStatusChanged: onSceneStatusChanged,
      onCreateChapter: onCreateChapter,
      onCreateScene: onCreateScene,
      onSaveScene: onSaveScene,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 760) {
          return Column(
            children: [
              SizedBox(height: 150, child: library),
              const Divider(height: 1),
              Expanded(child: workspace),
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(width: 300, child: library),
            const VerticalDivider(width: 1),
            Expanded(child: workspace),
          ],
        );
      },
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
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: color.surfaceContainerLow,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.outlineVariant),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: color.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.menu_book_outlined,
                  color: color.primary,
                  size: 30,
                ),
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
    required this.notes,
    required this.catalogItems,
    required this.metrics,
    required this.suggestions,
    required this.onSelectProject,
    required this.onDeleteProject,
  });

  final WritelerCopy copy;
  final List<Project> projects;
  final Project? selectedProject;
  final List<Chapter> chapters;
  final List<Scene> scenes;
  final List<ProjectNote> notes;
  final List<CatalogItem> catalogItems;
  final List<MetricEvent> metrics;
  final List<AISuggestion> suggestions;
  final ValueChanged<Project> onSelectProject;
  final ValueChanged<Project> onDeleteProject;

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
            onDelete: onDeleteProject,
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
                        label: copy.t('notes'), value: notes.length.toString()),
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
                                '${_draftStatusLabel(scene.status, copy.languageCode)} - '
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

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.outlineVariant),
      ),
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(16),
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
    required this.onDeleteScene,
    required this.onDeleteChapter,
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
  final ValueChanged<Scene> onDeleteScene;
  final ValueChanged<Chapter> onDeleteChapter;
  final VoidCallback onCreateScene;
  final VoidCallback onCreateChapter;

  @override
  Widget build(BuildContext context) {
    final orderedChapters = [...chapters]
      ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
    final datedScenes = scenes
        .where((scene) => scene.storyDateStart != null)
        .toList()
      ..sort((a, b) => a.storyDateStart!.compareTo(b.storyDateStart!));
    final planningGaps = scenes
        .where((scene) =>
            scene.goal?.trim().isEmpty != false ||
            scene.conflict?.trim().isEmpty != false ||
            scene.outcome?.trim().isEmpty != false)
        .toList();
    final unscheduledScenes =
        scenes.where((scene) => scene.storyDateStart == null).toList();
    final unassignedScenes =
        scenes.where((scene) => scene.chapterId == null).length;
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
          title: copy.t('structureCockpit'),
          actionLabel: copy.t('newScene'),
          actionIcon: Icons.add,
          onAction: onCreateScene,
        ),
        const Divider(height: 1),
        _StructureCockpitSummary(
          copy: copy,
          scenes: scenes,
          chapters: orderedChapters,
          planningGaps: planningGaps.length,
          unassignedScenes: unassignedScenes,
          datedScenes: datedScenes,
        ),
        const Divider(height: 1),
        if (chapters.isNotEmpty)
          SizedBox(
            height: 52,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return OutlinedButton.icon(
                    onPressed: onCreateChapter,
                    icon: const Icon(Icons.create_new_folder_outlined),
                    label: Text(copy.t('newChapter')),
                  );
                }
                final chapter = orderedChapters[index - 1];
                final sceneCount = scenes
                    .where((scene) => scene.chapterId == chapter.id)
                    .length;
                return Chip(
                  avatar: const Icon(Icons.folder_outlined, size: 18),
                  label: Text('${chapter.title} - $sceneCount'),
                  deleteIcon: const Icon(Icons.delete_outline, size: 18),
                  onDeleted: () => onDeleteChapter(chapter),
                );
              },
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemCount: orderedChapters.length + 1,
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
          child: LayoutBuilder(
            builder: (context, constraints) {
              final structureList = ListView.separated(
                padding: const EdgeInsets.all(20),
                scrollDirection: Axis.horizontal,
                itemCount: visibleGroups.length,
                separatorBuilder: (context, index) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  final group = visibleGroups[index];
                  return SizedBox(
                    width: 340,
                    child: _SceneStructureColumn(
                      copy: copy,
                      group: group,
                      chapters: orderedChapters,
                      selectedScene: selectedScene,
                      onSelectScene: onSelectScene,
                      onMoveSceneUp: onMoveSceneUp,
                      onMoveSceneDown: onMoveSceneDown,
                      onMoveSceneToChapter: onMoveSceneToChapter,
                      onDeleteScene: onDeleteScene,
                    ),
                  );
                },
              );
              final inspector = _StructureInspector(
                copy: copy,
                planningGapScenes: planningGaps,
                unscheduledScenes: unscheduledScenes,
                datedScenes: datedScenes,
                onOpenScene: onSelectScene,
              );
              if (constraints.maxWidth < 980) {
                final inspectorHeight =
                    (constraints.maxHeight * 0.42).clamp(120.0, 260.0);
                return Column(
                  children: [
                    Expanded(child: structureList),
                    const Divider(height: 1),
                    SizedBox(height: inspectorHeight, child: inspector),
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(child: structureList),
                  const VerticalDivider(width: 1),
                  SizedBox(width: 380, child: inspector),
                ],
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

final class _StructureCockpitSummary extends StatelessWidget {
  const _StructureCockpitSummary({
    required this.copy,
    required this.scenes,
    required this.chapters,
    required this.planningGaps,
    required this.unassignedScenes,
    required this.datedScenes,
  });

  final WritelerCopy copy;
  final List<Scene> scenes;
  final List<Chapter> chapters;
  final int planningGaps;
  final int unassignedScenes;
  final List<Scene> datedScenes;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final words =
        scenes.fold<int>(0, (sum, scene) => sum + scene.actualWordCount);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          _StructureChip(
            icon: Icons.account_tree_outlined,
            label: copy.t('chapterOverview'),
            value: '${chapters.length}',
          ),
          _StructureChip(
            icon: Icons.auto_awesome_motion_outlined,
            label: copy.t('scenes'),
            value: '${scenes.length}',
          ),
          _StructureChip(
            icon: Icons.notes_outlined,
            label: copy.t('words'),
            value: '$words',
          ),
          _StructureChip(
            icon: Icons.rule_outlined,
            label: copy.t('planningGaps'),
            value: '$planningGaps',
          ),
          _StructureChip(
            icon: Icons.folder_off_outlined,
            label: copy.t('unassignedScenes'),
            value: '$unassignedScenes',
          ),
          _StructureChip(
            icon: Icons.timeline_outlined,
            label: copy.t('datedScenes'),
            value: '${datedScenes.length}',
          ),
          if (datedScenes.isNotEmpty)
            DecoratedBox(
              decoration: BoxDecoration(
                color: color.surfaceContainerHighest.withValues(alpha: 0.58),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Text(
                  '${copy.t('timeline')}: ${datedScenes.first.title}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

final class _StructureChip extends StatelessWidget {
  const _StructureChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: color.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color.primary),
            const SizedBox(width: 8),
            Text(label, style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(width: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
      ),
    );
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
    required this.onDeleteScene,
  });

  final WritelerCopy copy;
  final _SceneStructureGroup group;
  final List<Chapter> chapters;
  final Scene? selectedScene;
  final ValueChanged<Scene> onSelectScene;
  final ValueChanged<Scene> onMoveSceneUp;
  final ValueChanged<Scene> onMoveSceneDown;
  final void Function(Scene scene, String? chapterId) onMoveSceneToChapter;
  final ValueChanged<Scene> onDeleteScene;

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
                return _SceneStructureTile(
                  copy: copy,
                  scene: scene,
                  selected: selected,
                  chapters: chapters,
                  onTap: () => onSelectScene(scene),
                  onMoveSceneUp: () => onMoveSceneUp(scene),
                  onMoveSceneDown: () => onMoveSceneDown(scene),
                  onMoveSceneToChapter: (chapterId) =>
                      onMoveSceneToChapter(scene, chapterId),
                  onDeleteScene: () => onDeleteScene(scene),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

final class _StructureInspector extends StatelessWidget {
  const _StructureInspector({
    required this.copy,
    required this.planningGapScenes,
    required this.unscheduledScenes,
    required this.datedScenes,
    required this.onOpenScene,
  });

  final WritelerCopy copy;
  final List<Scene> planningGapScenes;
  final List<Scene> unscheduledScenes;
  final List<Scene> datedScenes;
  final ValueChanged<Scene> onOpenScene;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            copy.t('structureInspector'),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: ListView(
              children: [
                _StructureSceneSection(
                  copy: copy,
                  title: copy.t('planningGaps'),
                  emptyText: copy.t('noPlanningGaps'),
                  icon: Icons.rule_outlined,
                  scenes: planningGapScenes,
                  subtitleBuilder: (scene) =>
                      _missingScenePlanningLabels(scene, copy).join(', '),
                  onOpenScene: onOpenScene,
                ),
                const SizedBox(height: 18),
                _StructureSceneSection(
                  copy: copy,
                  title: copy.t('unscheduled'),
                  emptyText: copy.t('noUnscheduledScenes'),
                  icon: Icons.event_busy_outlined,
                  scenes: unscheduledScenes,
                  subtitleBuilder: (scene) =>
                      _draftStatusLabel(scene.status, copy.languageCode),
                  onOpenScene: onOpenScene,
                ),
                const SizedBox(height: 18),
                _StructureTimelineSection(
                  copy: copy,
                  scenes: datedScenes,
                  onOpenScene: onOpenScene,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

final class _StructureSceneSection extends StatelessWidget {
  const _StructureSceneSection({
    required this.copy,
    required this.title,
    required this.emptyText,
    required this.icon,
    required this.scenes,
    required this.subtitleBuilder,
    required this.onOpenScene,
  });

  final WritelerCopy copy;
  final String title;
  final String emptyText;
  final IconData icon;
  final List<Scene> scenes;
  final String Function(Scene scene) subtitleBuilder;
  final ValueChanged<Scene> onOpenScene;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: color.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '$title (${scenes.length})',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (scenes.isEmpty)
          _EmptyInlineMessage(message: emptyText)
        else
          for (final scene in scenes.take(6))
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.chevron_right),
              title: Text(
                scene.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                subtitleBuilder(scene),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Tooltip(
                message: copy.t('openScene'),
                child: IconButton(
                  onPressed: () => onOpenScene(scene),
                  icon: const Icon(Icons.open_in_new),
                ),
              ),
              onTap: () => onOpenScene(scene),
            ),
      ],
    );
  }
}

final class _StructureTimelineSection extends StatelessWidget {
  const _StructureTimelineSection({
    required this.copy,
    required this.scenes,
    required this.onOpenScene,
  });

  final WritelerCopy copy;
  final List<Scene> scenes;
  final ValueChanged<Scene> onOpenScene;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.timeline_outlined, size: 18, color: color.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${copy.t('timeline')} (${scenes.length})',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (scenes.isEmpty)
          _EmptyInlineMessage(message: copy.t('noTimelineScenes'))
        else
          for (final scene in scenes.take(8))
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event_outlined),
              title: Text(
                scene.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(_formatLocalDate(scene.storyDateStart!)),
              onTap: () => onOpenScene(scene),
            ),
      ],
    );
  }
}

final class _SceneStructureTile extends StatelessWidget {
  const _SceneStructureTile({
    required this.copy,
    required this.scene,
    required this.selected,
    required this.chapters,
    required this.onTap,
    required this.onMoveSceneUp,
    required this.onMoveSceneDown,
    required this.onMoveSceneToChapter,
    required this.onDeleteScene,
  });

  final WritelerCopy copy;
  final Scene scene;
  final bool selected;
  final List<Chapter> chapters;
  final VoidCallback onTap;
  final VoidCallback onMoveSceneUp;
  final VoidCallback onMoveSceneDown;
  final ValueChanged<String?> onMoveSceneToChapter;
  final VoidCallback onDeleteScene;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final missing = _missingScenePlanningLabels(scene, copy);
    final progress = _scenePlanningProgress(scene);
    return Material(
      color: selected ? color.primaryContainer.withValues(alpha: 0.38) : null,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 4, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      scene.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  _SceneStructureMenu(
                    copy: copy,
                    scene: scene,
                    chapters: chapters,
                    onMoveUp: onMoveSceneUp,
                    onMoveDown: onMoveSceneDown,
                    onMoveToChapter: onMoveSceneToChapter,
                    onDelete: onDeleteScene,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    _draftStatusLabel(scene.status, copy.languageCode),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: color.onSurfaceVariant,
                        ),
                  ),
                  Text(
                    '${scene.actualWordCount} ${copy.t('words')}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: color.onSurfaceVariant,
                        ),
                  ),
                  if (scene.storyDateStart != null)
                    Text(
                      _formatLocalDate(scene.storyDateStart!),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: color.onSurfaceVariant,
                          ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(value: progress),
              const SizedBox(height: 8),
              if (missing.isEmpty)
                Text(
                  copy.t('structureComplete'),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: color.primary,
                        fontWeight: FontWeight.w700,
                      ),
                )
              else
                Text(
                  '${copy.t('missing')}: ${missing.join(', ')}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: color.error,
                      ),
                ),
            ],
          ),
        ),
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
    required this.onDelete,
  });

  final WritelerCopy copy;
  final Scene scene;
  final List<Chapter> chapters;
  final VoidCallback onMoveUp;
  final VoidCallback onMoveDown;
  final ValueChanged<String?> onMoveToChapter;
  final VoidCallback onDelete;

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
          case _SceneStructureActionKind.delete:
            onDelete();
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
          const PopupMenuDivider(),
          PopupMenuItem(
            value:
                const _SceneStructureAction(_SceneStructureActionKind.delete),
            child: Text(copy.t('deleteScene')),
          ),
        ];
      },
    );
  }
}

enum _SceneStructureActionKind { moveUp, moveDown, moveToChapter, delete }

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
    required this.onDeleteItem,
  });

  final WritelerCopy copy;
  final EntityType type;
  final List<CatalogItem> items;
  final VoidCallback onCreateItem;
  final ValueChanged<CatalogItem> onDeleteItem;

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
                      trailing: Wrap(
                        spacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(_draftStatusLabel(
                              item.status, copy.languageCode)),
                          IconButton(
                            tooltip: copy.t('deleteCatalogItem'),
                            onPressed: () => onDeleteItem(item),
                            icon: const Icon(Icons.delete_outline),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

final class _AnalysisWorkspace extends StatelessWidget {
  const _AnalysisWorkspace({
    required this.copy,
    required this.chapters,
    required this.scenes,
    required this.catalogItems,
    required this.relationships,
    required this.onOpenScene,
  });

  final WritelerCopy copy;
  final List<Chapter> chapters;
  final List<Scene> scenes;
  final List<CatalogItem> catalogItems;
  final List<Relationship> relationships;
  final ValueChanged<Scene> onOpenScene;

  @override
  Widget build(BuildContext context) {
    final orderedChapters = [...chapters]
      ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
    final planningGapScenes = scenes
        .where((scene) =>
            scene.goal?.trim().isEmpty != false ||
            scene.conflict?.trim().isEmpty != false ||
            scene.outcome?.trim().isEmpty != false)
        .toList();
    final povMissingScenes = scenes
        .where((scene) => scene.povCharacterId?.trim().isEmpty != false)
        .toList();
    final dateMissingScenes =
        scenes.where((scene) => scene.storyDateStart == null).toList();
    final detachedCatalogItems = catalogItems
        .where((item) => _linkedScenesForItem(item).isEmpty)
        .toList();
    final chapterRows = _chapterRows(orderedChapters);
    final presenceRows = _presenceRows();

    return Column(
      children: [
        _WorkspaceHeader(title: copy.t('storyAnalysis')),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _StructureChip(
                icon: Icons.rule_outlined,
                label: copy.t('openPlanningGaps'),
                value: '${planningGapScenes.length}',
              ),
              _StructureChip(
                icon: Icons.visibility_off_outlined,
                label: copy.t('scenesWithoutPov'),
                value: '${povMissingScenes.length}',
              ),
              _StructureChip(
                icon: Icons.event_busy_outlined,
                label: copy.t('scenesWithoutDate'),
                value: '${dateMissingScenes.length}',
              ),
              _StructureChip(
                icon: Icons.link_off_outlined,
                label: copy.t('detachedCatalogItems'),
                value: '${detachedCatalogItems.length}',
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: Row(
            children: [
              SizedBox(
                width: 340,
                child: _AnalysisPanel(
                  title: copy.t('storylineHealth'),
                  child: _StorylineIssueList(
                    copy: copy,
                    planningGapScenes: planningGapScenes,
                    povMissingScenes: povMissingScenes,
                    dateMissingScenes: dateMissingScenes,
                    detachedCatalogItems: detachedCatalogItems,
                    onOpenScene: onOpenScene,
                  ),
                ),
              ),
              const VerticalDivider(width: 1),
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      flex: 3,
                      child: _AnalysisPanel(
                        title: copy.t('chapterBalance'),
                        child: _ChapterBalanceList(
                          copy: copy,
                          rows: chapterRows,
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                    SizedBox(
                      height: 170,
                      child: _AnalysisPanel(
                        title: copy.t('statusSpread'),
                        child: _StatusSpreadList(copy: copy, scenes: scenes),
                      ),
                    ),
                  ],
                ),
              ),
              const VerticalDivider(width: 1),
              SizedBox(
                width: 380,
                child: _AnalysisPanel(
                  title: copy.t('catalogPresence'),
                  child: _CatalogPresenceList(
                    copy: copy,
                    rows: presenceRows,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<_ChapterAnalysisRow> _chapterRows(List<Chapter> orderedChapters) {
    final rows = <_ChapterAnalysisRow>[
      for (final chapter in orderedChapters)
        _ChapterAnalysisRow(
          title: chapter.title,
          scenes: _scenesForChapter(chapter.id),
        ),
    ];
    final unassigned = _scenesForChapter(null);
    if (unassigned.isNotEmpty || rows.isEmpty) {
      rows.add(
          _ChapterAnalysisRow(title: copy.t('noChapter'), scenes: unassigned));
    }
    return rows;
  }

  List<Scene> _scenesForChapter(String? chapterId) {
    final filtered =
        scenes.where((scene) => scene.chapterId == chapterId).toList();
    filtered.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
    return filtered;
  }

  List<_CatalogPresenceRow> _presenceRows() {
    final rows = [
      for (final item in catalogItems)
        _CatalogPresenceRow(
          item: item,
          scenes: _linkedScenesForItem(item),
        ),
    ];
    rows.sort((a, b) {
      final typeCompare = a.item.type.index.compareTo(b.item.type.index);
      if (typeCompare != 0) return typeCompare;
      return a.item.name.compareTo(b.item.name);
    });
    return rows;
  }

  List<Scene> _linkedScenesForItem(CatalogItem item) {
    final sceneIds = relationships
        .where((relationship) =>
            _relationshipConnects(relationship, EntityType.scene, item.type) &&
            (relationship.source.id == item.id ||
                relationship.target.id == item.id))
        .map((relationship) => relationship.source.type == EntityType.scene
            ? relationship.source.id
            : relationship.target.id)
        .toSet();
    final linked =
        scenes.where((scene) => sceneIds.contains(scene.id)).toList();
    linked.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
    return linked;
  }

  bool _relationshipConnects(
    Relationship relationship,
    EntityType left,
    EntityType right,
  ) {
    return (relationship.source.type == left &&
            relationship.target.type == right) ||
        (relationship.source.type == right && relationship.target.type == left);
  }
}

typedef _SaveNoteCallback = Future<ProjectNote?> Function({
  ProjectNote? existing,
  required String title,
  required String body,
  required EntityRef? target,
});

enum _NoteFilter { all, project, scene, catalog, manual, ai }

final class _NotesCockpit extends StatefulWidget {
  const _NotesCockpit({
    required this.copy,
    required this.project,
    required this.notes,
    required this.scenes,
    required this.catalogItems,
    required this.onSaveNote,
    required this.onDeleteNote,
    required this.onOpenScene,
  });

  final WritelerCopy copy;
  final Project? project;
  final List<ProjectNote> notes;
  final List<Scene> scenes;
  final List<CatalogItem> catalogItems;
  final _SaveNoteCallback onSaveNote;
  final ValueChanged<ProjectNote> onDeleteNote;
  final ValueChanged<Scene> onOpenScene;

  @override
  State<_NotesCockpit> createState() => _NotesCockpitState();
}

final class _NotesCockpitState extends State<_NotesCockpit> {
  late final TextEditingController _searchController = TextEditingController();
  late final TextEditingController _titleController = TextEditingController();
  late final TextEditingController _bodyController = TextEditingController();
  _NoteFilter _filter = _NoteFilter.all;
  String _targetValue = 'project';
  String? _selectedNoteId;
  bool _draftingNew = false;

  @override
  void initState() {
    super.initState();
    _selectInitialNote();
  }

  @override
  void didUpdateWidget(covariant _NotesCockpit oldWidget) {
    super.didUpdateWidget(oldWidget);
    final selectedExists =
        widget.notes.any((note) => note.id == _selectedNoteId);
    if (!_draftingNew && !selectedExists) {
      _selectInitialNote();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  ProjectNote? get _selectedNote => _draftingNew
      ? null
      : widget.notes.where((note) => note.id == _selectedNoteId).firstOrNull;

  void _selectInitialNote() {
    final note = widget.notes.firstOrNull;
    _loadNote(note);
  }

  void _startNewNote() {
    setState(() {
      _draftingNew = true;
      _selectedNoteId = null;
      _titleController.clear();
      _bodyController.clear();
      _targetValue = 'project';
    });
  }

  void _loadNote(ProjectNote? note) {
    _draftingNew = note == null;
    _selectedNoteId = note?.id;
    _titleController.text = note?.title ?? '';
    _bodyController.text = note?.body ?? '';
    _targetValue = _targetValueFor(note?.target);
  }

  Future<void> _saveCurrentNote() async {
    final saved = await widget.onSaveNote(
      existing: _selectedNote,
      title: _titleController.text,
      body: _bodyController.text,
      target: _targetFromValue(_targetValue),
    );
    if (saved == null || !mounted) return;
    setState(() {
      _draftingNew = false;
      _selectedNoteId = saved.id;
      _titleController.text = saved.title;
      _bodyController.text = saved.body;
      _targetValue = _targetValueFor(saved.target);
    });
  }

  void _deleteCurrentNote() {
    final note = _selectedNote;
    if (note == null) return;
    widget.onDeleteNote(note);
    setState(() {
      _selectedNoteId = null;
      _draftingNew = false;
      _titleController.clear();
      _bodyController.clear();
      _targetValue = 'project';
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredNotes = _filteredNotes();
    final selectedNote = _selectedNote;

    return Column(
      children: [
        _WorkspaceHeader(
          title: widget.copy.t('notesCockpit'),
          actionLabel: widget.copy.t('newNote'),
          actionIcon: Icons.add,
          onAction: _startNewNote,
        ),
        const Divider(height: 1),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final list = _NotesListPane(
                copy: widget.copy,
                notes: filteredNotes,
                selectedNoteId: _selectedNoteId,
                searchController: _searchController,
                filter: _filter,
                scenes: widget.scenes,
                catalogItems: widget.catalogItems,
                onFilterChanged: (filter) => setState(() => _filter = filter),
                onSearchChanged: (_) => setState(() {}),
                onSelectNote: (note) => setState(() => _loadNote(note)),
              );
              final editor = _NoteEditorPane(
                copy: widget.copy,
                project: widget.project,
                note: selectedNote,
                titleController: _titleController,
                bodyController: _bodyController,
                targetValue: _targetValue,
                targetOptions: _targetOptions(),
                draftingNew: _draftingNew,
                onTargetChanged: (value) =>
                    setState(() => _targetValue = value ?? 'project'),
                onSave: _saveCurrentNote,
                onDelete: selectedNote == null ? null : _deleteCurrentNote,
                onOpenScene:
                    _sceneForTarget(_targetFromValue(_targetValue)) == null
                        ? null
                        : () => widget.onOpenScene(
                            _sceneForTarget(_targetFromValue(_targetValue))!),
              );

              if (constraints.maxWidth < 980) {
                return Column(
                  children: [
                    SizedBox(height: 280, child: list),
                    const Divider(height: 1),
                    Expanded(child: editor),
                  ],
                );
              }
              return Row(
                children: [
                  SizedBox(width: 380, child: list),
                  const VerticalDivider(width: 1),
                  Expanded(child: editor),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  List<ProjectNote> _filteredNotes() {
    final query = _searchController.text.trim().toLowerCase();
    return widget.notes.where((note) {
      final matchesFilter = switch (_filter) {
        _NoteFilter.all => true,
        _NoteFilter.project => note.target == null,
        _NoteFilter.scene => note.target?.type == EntityType.scene,
        _NoteFilter.catalog => note.target?.type == EntityType.character ||
            note.target?.type == EntityType.location ||
            note.target?.type == EntityType.object,
        _NoteFilter.manual => note.source == 'manual',
        _NoteFilter.ai => note.source == 'aiSuggestion',
      };
      if (!matchesFilter) return false;
      if (query.isEmpty) return true;
      final targetLabel =
          _noteTargetDisplay(note.target, widget.scenes, widget.catalogItems);
      return note.title.toLowerCase().contains(query) ||
          note.body.toLowerCase().contains(query) ||
          targetLabel.toLowerCase().contains(query);
    }).toList();
  }

  List<DropdownMenuItem<String>> _targetOptions() {
    return [
      DropdownMenuItem(
        value: 'project',
        child: Text(widget.copy.t('targetProject')),
      ),
      for (final scene in widget.scenes)
        DropdownMenuItem(
          value:
              _targetValueFor(EntityRef(type: EntityType.scene, id: scene.id)),
          child: Text('${widget.copy.t('scene')}: ${scene.title}'),
        ),
      for (final item in widget.catalogItems)
        DropdownMenuItem(
          value: _targetValueFor(EntityRef(type: item.type, id: item.id)),
          child:
              Text('${_entityTypeLabel(item.type, widget.copy)}: ${item.name}'),
        ),
    ];
  }

  Scene? _sceneForTarget(EntityRef? target) {
    if (target?.type != EntityType.scene) return null;
    return widget.scenes.where((scene) => scene.id == target!.id).firstOrNull;
  }
}

final class _NotesListPane extends StatelessWidget {
  const _NotesListPane({
    required this.copy,
    required this.notes,
    required this.selectedNoteId,
    required this.searchController,
    required this.filter,
    required this.scenes,
    required this.catalogItems,
    required this.onFilterChanged,
    required this.onSearchChanged,
    required this.onSelectNote,
  });

  final WritelerCopy copy;
  final List<ProjectNote> notes;
  final String? selectedNoteId;
  final TextEditingController searchController;
  final _NoteFilter filter;
  final List<Scene> scenes;
  final List<CatalogItem> catalogItems;
  final ValueChanged<_NoteFilter> onFilterChanged;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<ProjectNote> onSelectNote;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: searchController,
            onChanged: onSearchChanged,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              labelText: copy.t('searchNotes'),
              border: const OutlineInputBorder(),
              isDense: true,
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SegmentedButton<_NoteFilter>(
              showSelectedIcon: false,
              selected: {filter},
              onSelectionChanged: (selection) =>
                  onFilterChanged(selection.first),
              segments: [
                for (final option in _NoteFilter.values)
                  ButtonSegment(
                    value: option,
                    icon: Icon(_noteFilterIcon(option), size: 18),
                    label: Text(_noteFilterLabel(option, copy)),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: notes.isEmpty
                ? _EmptyInlineMessage(message: copy.t('noNotesForFilter'))
                : ListView.separated(
                    itemCount: notes.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final note = notes[index];
                      final selected = note.id == selectedNoteId;
                      return ListTile(
                        selected: selected,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        leading: Icon(
                          note.source == 'aiSuggestion'
                              ? Icons.psychology_alt_outlined
                              : Icons.sticky_note_2_outlined,
                          color: selected ? color.primary : null,
                        ),
                        title: Text(
                          note.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          '${_noteTargetDisplay(note.target, scenes, catalogItems)}\n'
                          '${note.body}',
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () => onSelectNote(note),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

final class _NoteEditorPane extends StatelessWidget {
  const _NoteEditorPane({
    required this.copy,
    required this.project,
    required this.note,
    required this.titleController,
    required this.bodyController,
    required this.targetValue,
    required this.targetOptions,
    required this.draftingNew,
    required this.onTargetChanged,
    required this.onSave,
    required this.onDelete,
    required this.onOpenScene,
  });

  final WritelerCopy copy;
  final Project? project;
  final ProjectNote? note;
  final TextEditingController titleController;
  final TextEditingController bodyController;
  final String targetValue;
  final List<DropdownMenuItem<String>> targetOptions;
  final bool draftingNew;
  final ValueChanged<String?> onTargetChanged;
  final VoidCallback onSave;
  final VoidCallback? onDelete;
  final VoidCallback? onOpenScene;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final hasEditableSurface = project != null && (note != null || draftingNew);
    if (!hasEditableSurface) {
      return _EmptyPanel(
        icon: Icons.sticky_note_2_outlined,
        title: copy.t('noNoteSelectedTitle'),
        body: copy.t('noNoteSelectedBody'),
      );
    }

    final sourceText = note == null
        ? copy.t('manualNote')
        : note!.source == 'aiSuggestion'
            ? copy.t('aiNote')
            : copy.t('manualNote');

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  draftingNew ? copy.t('newNote') : copy.t('editNote'),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              Text(
                sourceText,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: color.onSurfaceVariant,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          TextField(
            controller: titleController,
            decoration: InputDecoration(
              labelText: copy.t('noteTitle'),
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            initialValue: targetOptions.any((item) => item.value == targetValue)
                ? targetValue
                : 'project',
            items: targetOptions,
            onChanged: onTargetChanged,
            decoration: InputDecoration(
              labelText: copy.t('noteTarget'),
              border: const OutlineInputBorder(),
            ),
          ),
          if (onOpenScene != null) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: onOpenScene,
                icon: const Icon(Icons.open_in_new),
                label: Text(copy.t('openLinkedScene')),
              ),
            ),
          ],
          const SizedBox(height: 14),
          Expanded(
            child: TextField(
              controller: bodyController,
              expands: true,
              maxLines: null,
              minLines: null,
              textAlignVertical: TextAlignVertical.top,
              decoration: InputDecoration(
                labelText: copy.t('noteBody'),
                alignLabelWithHint: true,
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              FilledButton.icon(
                onPressed: onSave,
                icon: const Icon(Icons.save_outlined),
                label: Text(copy.t('saveNote')),
              ),
              const SizedBox(width: 12),
              if (onDelete != null)
                OutlinedButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline),
                  label: Text(copy.t('delete')),
                ),
              const Spacer(),
              if (note != null)
                Text(
                  _formatLocalDateTime(note!.updatedAt),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: color.onSurfaceVariant,
                      ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

final class _AnalysisPanel extends StatelessWidget {
  const _AnalysisPanel({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 12),
          Expanded(child: child),
        ],
      ),
    );
  }
}

final class _StorylineIssueList extends StatelessWidget {
  const _StorylineIssueList({
    required this.copy,
    required this.planningGapScenes,
    required this.povMissingScenes,
    required this.dateMissingScenes,
    required this.detachedCatalogItems,
    required this.onOpenScene,
  });

  final WritelerCopy copy;
  final List<Scene> planningGapScenes;
  final List<Scene> povMissingScenes;
  final List<Scene> dateMissingScenes;
  final List<CatalogItem> detachedCatalogItems;
  final ValueChanged<Scene> onOpenScene;

  @override
  Widget build(BuildContext context) {
    final issues = <_AnalysisIssue>[
      for (final scene in planningGapScenes)
        _AnalysisIssue(
          icon: Icons.rule_outlined,
          title: scene.title,
          subtitle: copy.t('missingStructure'),
          scene: scene,
        ),
      for (final scene in povMissingScenes)
        _AnalysisIssue(
          icon: Icons.visibility_off_outlined,
          title: scene.title,
          subtitle: copy.t('scenesWithoutPov'),
          scene: scene,
        ),
      for (final scene in dateMissingScenes)
        _AnalysisIssue(
          icon: Icons.event_busy_outlined,
          title: scene.title,
          subtitle: copy.t('scenesWithoutDate'),
          scene: scene,
        ),
      for (final item in detachedCatalogItems)
        _AnalysisIssue(
          icon: _catalogIcon(item.type),
          title: item.name,
          subtitle: copy.t('noAppearances'),
        ),
    ];

    if (issues.isEmpty) {
      return _EmptyInlineMessage(message: copy.t('noAnalysisIssues'));
    }

    return ListView.separated(
      itemCount: issues.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final issue = issues[index];
        return ListTile(
          leading: Icon(issue.icon),
          title: Text(
            issue.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(issue.subtitle),
          onTap: issue.scene == null ? null : () => onOpenScene(issue.scene!),
        );
      },
    );
  }
}

final class _ChapterBalanceList extends StatelessWidget {
  const _ChapterBalanceList({
    required this.copy,
    required this.rows,
  });

  final WritelerCopy copy;
  final List<_ChapterAnalysisRow> rows;

  @override
  Widget build(BuildContext context) {
    if (rows.every((row) => row.scenes.isEmpty)) {
      return _EmptyInlineMessage(message: copy.t('noScenesBody'));
    }

    final maxWords = rows.fold<int>(
      1,
      (max, row) => row.words > max ? row.words : max,
    );

    return ListView.separated(
      itemCount: rows.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final row = rows[index];
        final progress = row.words / maxWords;
        return _ChapterBalanceTile(
          copy: copy,
          row: row,
          progress: progress,
        );
      },
    );
  }
}

final class _ChapterBalanceTile extends StatelessWidget {
  const _ChapterBalanceTile({
    required this.copy,
    required this.row,
    required this.progress,
  });

  final WritelerCopy copy;
  final _ChapterAnalysisRow row;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  row.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              Text('${row.scenes.length} ${copy.t('scenes')}'),
              const SizedBox(width: 12),
              Text('${row.words} ${copy.t('words')}'),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(value: progress.clamp(0.0, 1.0)),
        ],
      ),
    );
  }
}

final class _StatusSpreadList extends StatelessWidget {
  const _StatusSpreadList({
    required this.copy,
    required this.scenes,
  });

  final WritelerCopy copy;
  final List<Scene> scenes;

  @override
  Widget build(BuildContext context) {
    final total = scenes.isEmpty ? 1 : scenes.length;
    return ListView(
      scrollDirection: Axis.horizontal,
      children: [
        for (final status in DraftStatus.values)
          SizedBox(
            width: 160,
            child: Padding(
              padding: const EdgeInsets.only(right: 14),
              child: _StatusSpreadTile(
                label: _draftStatusLabel(status, copy.languageCode),
                count: scenes.where((scene) => scene.status == status).length,
                total: total,
              ),
            ),
          ),
      ],
    );
  }
}

final class _StatusSpreadTile extends StatelessWidget {
  const _StatusSpreadTile({
    required this.label,
    required this.count,
    required this.total,
  });

  final String label;
  final int count;
  final int total;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: color.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 10),
            Text(
              '$count',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: count / total),
          ],
        ),
      ),
    );
  }
}

final class _CatalogPresenceList extends StatelessWidget {
  const _CatalogPresenceList({
    required this.copy,
    required this.rows,
  });

  final WritelerCopy copy;
  final List<_CatalogPresenceRow> rows;

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) {
      return _EmptyInlineMessage(message: copy.t('catalogEmptyBody'));
    }

    return ListView.separated(
      itemCount: rows.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final row = rows[index];
        final scenePreview = row.scenes.take(3).map((scene) => scene.title);
        return ListTile(
          leading: Icon(_catalogIcon(row.item.type)),
          title:
              Text(row.item.name, maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Text(
            row.scenes.isEmpty
                ? copy.t('noAppearances')
                : scenePreview.join(', '),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Text('${row.scenes.length}'),
        );
      },
    );
  }
}

final class _EmptyInlineMessage extends StatelessWidget {
  const _EmptyInlineMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Text(
        message,
        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
    );
  }
}

final class _AnalysisIssue {
  const _AnalysisIssue({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.scene,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Scene? scene;
}

final class _ChapterAnalysisRow {
  const _ChapterAnalysisRow({
    required this.title,
    required this.scenes,
  });

  final String title;
  final List<Scene> scenes;

  int get words =>
      scenes.fold<int>(0, (sum, scene) => sum + scene.actualWordCount);
}

final class _CatalogPresenceRow {
  const _CatalogPresenceRow({
    required this.item,
    required this.scenes,
  });

  final CatalogItem item;
  final List<Scene> scenes;
}

final class _SubmitAiPromptIntent extends Intent {
  const _SubmitAiPromptIntent();
}

final class _AIWorkshop extends StatelessWidget {
  const _AIWorkshop({
    required this.copy,
    required this.project,
    required this.selectedScene,
    required this.scenes,
    required this.suggestions,
    required this.notes,
    required this.activeProviderConfig,
    required this.promptController,
    required this.isRequesting,
    required this.lastError,
    required this.onSubmitPrompt,
    required this.onRequestTask,
    required this.onAcceptSuggestion,
    required this.onRejectSuggestion,
    required this.onConvertSuggestion,
    required this.onDeleteNote,
  });

  final WritelerCopy copy;
  final Project? project;
  final Scene? selectedScene;
  final List<Scene> scenes;
  final List<AISuggestion> suggestions;
  final List<ProjectNote> notes;
  final AIProviderConfig activeProviderConfig;
  final TextEditingController promptController;
  final bool isRequesting;
  final String? lastError;
  final VoidCallback onSubmitPrompt;
  final ValueChanged<AITaskKind> onRequestTask;
  final ValueChanged<AISuggestion> onAcceptSuggestion;
  final ValueChanged<AISuggestion> onRejectSuggestion;
  final ValueChanged<AISuggestion> onConvertSuggestion;
  final ValueChanged<ProjectNote> onDeleteNote;

  @override
  Widget build(BuildContext context) {
    final scene = selectedScene ?? scenes.firstOrNull;
    final aiAvailable = project?.aiEnabled == true &&
        project?.noAiNoCloud == false &&
        scene != null;
    const primaryActions = [
      _AiWorkshopAction(
        task: AITaskKind.sceneIdeas,
        icon: Icons.lightbulb_outline,
      ),
      _AiWorkshopAction(
        task: AITaskKind.sceneGoalConflictOutcome,
        icon: Icons.account_tree_outlined,
      ),
      _AiWorkshopAction(
        task: AITaskKind.consistencyCheck,
        icon: Icons.rule_outlined,
      ),
    ];
    const secondaryActions = [
      _AiWorkshopAction(
        task: AITaskKind.timelineCheck,
        icon: Icons.timeline_outlined,
      ),
      _AiWorkshopAction(
        task: AITaskKind.plotGapReview,
        icon: Icons.troubleshoot_outlined,
      ),
      _AiWorkshopAction(
        task: AITaskKind.authorQuestions,
        icon: Icons.help_outline,
      ),
      _AiWorkshopAction(
        task: AITaskKind.styleAnalysis,
        icon: Icons.auto_fix_high_outlined,
      ),
    ];

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
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.psychology_alt_outlined,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                scene == null
                                    ? copy.t('aiNeedsScene')
                                    : '${copy.t('aiContext')}: ${scene.title}',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _AIProviderStatusLine(
                          copy: copy,
                          config: activeProviderConfig,
                        ),
                        const SizedBox(height: 14),
                        Shortcuts(
                          shortcuts: const {
                            SingleActivator(LogicalKeyboardKey.enter,
                                control: true): _SubmitAiPromptIntent(),
                            SingleActivator(LogicalKeyboardKey.enter,
                                meta: true): _SubmitAiPromptIntent(),
                          },
                          child: Actions(
                            actions: {
                              _SubmitAiPromptIntent:
                                  CallbackAction<_SubmitAiPromptIntent>(
                                onInvoke: (intent) {
                                  if (aiAvailable && !isRequesting) {
                                    onSubmitPrompt();
                                  }
                                  return null;
                                },
                              ),
                            },
                            child: TextField(
                              controller: promptController,
                              minLines: 2,
                              maxLines: 4,
                              textInputAction: TextInputAction.newline,
                              decoration: InputDecoration(
                                labelText: copy.t('aiPrompt'),
                                helperText: copy.t('aiPromptSubmitHint'),
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            FilledButton.icon(
                              onPressed: aiAvailable && !isRequesting
                                  ? onSubmitPrompt
                                  : null,
                              icon: const Icon(Icons.send_outlined),
                              label: Text(copy.t('submitAiPrompt')),
                            ),
                            for (final action in primaryActions)
                              OutlinedButton.icon(
                                onPressed: aiAvailable && !isRequesting
                                    ? () => onRequestTask(action.task)
                                    : null,
                                icon: Icon(action.icon),
                                label:
                                    Text(_aiTaskLabel(action.task.name, copy)),
                              ),
                            PopupMenuButton<AITaskKind>(
                              enabled: aiAvailable && !isRequesting,
                              tooltip: copy.t('moreAiChecks'),
                              onSelected: onRequestTask,
                              itemBuilder: (context) => [
                                for (final action in secondaryActions)
                                  PopupMenuItem(
                                    value: action.task,
                                    child: ListTile(
                                      dense: true,
                                      leading: Icon(action.icon),
                                      title: Text(
                                        _aiTaskLabel(action.task.name, copy),
                                      ),
                                    ),
                                  ),
                              ],
                              child: _AiMenuAnchor(copy: copy),
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
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final suggestionsPanel = _AISuggestionsPanel(
                        copy: copy,
                        suggestions: suggestions,
                        scenes: scenes,
                        onAcceptSuggestion: onAcceptSuggestion,
                        onConvertSuggestion: onConvertSuggestion,
                        onRejectSuggestion: onRejectSuggestion,
                      );
                      final notesPanel = _AINotesPanel(
                        copy: copy,
                        notes: notes,
                        scenes: scenes,
                        onDeleteNote: onDeleteNote,
                      );
                      if (constraints.maxWidth >= 920) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 3, child: suggestionsPanel),
                            const SizedBox(width: 24),
                            SizedBox(width: 360, child: notesPanel),
                          ],
                        );
                      }
                      return Column(
                        children: [
                          Expanded(child: suggestionsPanel),
                          const SizedBox(height: 16),
                          SizedBox(height: 220, child: notesPanel),
                        ],
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

final class _AISuggestionsPanel extends StatelessWidget {
  const _AISuggestionsPanel({
    required this.copy,
    required this.suggestions,
    required this.scenes,
    required this.onAcceptSuggestion,
    required this.onConvertSuggestion,
    required this.onRejectSuggestion,
  });

  final WritelerCopy copy;
  final List<AISuggestion> suggestions;
  final List<Scene> scenes;
  final ValueChanged<AISuggestion> onAcceptSuggestion;
  final ValueChanged<AISuggestion> onConvertSuggestion;
  final ValueChanged<AISuggestion> onRejectSuggestion;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.surfaceContainerLow,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                        return _AISuggestionTile(
                          copy: copy,
                          suggestion: suggestion,
                          scenes: scenes,
                          onAcceptSuggestion: onAcceptSuggestion,
                          onConvertSuggestion: onConvertSuggestion,
                          onRejectSuggestion: onRejectSuggestion,
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

final class _AINotesPanel extends StatelessWidget {
  const _AINotesPanel({
    required this.copy,
    required this.notes,
    required this.scenes,
    required this.onDeleteNote,
  });

  final WritelerCopy copy;
  final List<ProjectNote> notes;
  final List<Scene> scenes;
  final ValueChanged<ProjectNote> onDeleteNote;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.surfaceContainerLow,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(copy.t('notes'),
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Expanded(
              child: notes.isEmpty
                  ? Text(
                      copy.t('noNotes'),
                      style: TextStyle(color: color.onSurfaceVariant),
                    )
                  : ListView.separated(
                      itemCount: notes.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final note = notes[index];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.sticky_note_2_outlined),
                          title: Text(
                            note.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (_noteTargetLabel(note, scenes)
                                  case final target?)
                                Text(
                                  target,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(color: color.primary),
                                ),
                              Text(
                                note.body,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                _formatLocalDateTime(note.createdAt),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: color.onSurfaceVariant,
                                    ),
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            tooltip: copy.t('delete'),
                            onPressed: () => onDeleteNote(note),
                            icon: const Icon(Icons.delete_outline),
                          ),
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

final class _AiWorkshopAction {
  const _AiWorkshopAction({
    required this.task,
    required this.icon,
  });

  final AITaskKind task;
  final IconData icon;
}

final class _AiMenuAnchor extends StatelessWidget {
  const _AiMenuAnchor({required this.copy});

  final WritelerCopy copy;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: color.outline),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.more_horiz, size: 18, color: color.primary),
            const SizedBox(width: 8),
            Text(
              copy.t('moreAiChecks'),
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: color.primary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

final class _AISuggestionTile extends StatelessWidget {
  const _AISuggestionTile({
    required this.copy,
    required this.suggestion,
    required this.scenes,
    required this.onAcceptSuggestion,
    required this.onConvertSuggestion,
    required this.onRejectSuggestion,
  });

  final WritelerCopy copy;
  final AISuggestion suggestion;
  final List<Scene> scenes;
  final ValueChanged<AISuggestion> onAcceptSuggestion;
  final ValueChanged<AISuggestion> onConvertSuggestion;
  final ValueChanged<AISuggestion> onRejectSuggestion;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final scene = suggestion.target.type == EntityType.scene
        ? scenes.where((scene) => scene.id == suggestion.target.id).firstOrNull
        : null;
    final patch = scene == null
        ? null
        : const AIScenePlanningPatchBuilder().build(
            suggestion: suggestion,
            scene: scene,
          );
    return ExpansionTile(
      leading: const Icon(Icons.psychology_alt_outlined),
      title: Text(_aiTaskLabel(suggestion.suggestionType, copy)),
      subtitle: Text(
        '${suggestion.modelName} - ${_decisionLabel(suggestion.userDecision, copy)}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      childrenPadding: const EdgeInsets.fromLTRB(56, 0, 16, 16),
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                copy.t('aiResponse'),
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 6),
              SelectableText(
                suggestion.responseText,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              _ScenePatchPreview(
                copy: copy,
                patch: patch,
              ),
              const SizedBox(height: 16),
              Text(
                copy.t('sentPrompt'),
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 6),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: color.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: SelectableText(
                    suggestion.promptText,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontFamily: 'monospace',
                          color: color.onSurfaceVariant,
                        ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Text(
              _formatLocalDateTime(suggestion.createdAt),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color.onSurfaceVariant,
                  ),
            ),
            const Spacer(),
            IconButton(
              tooltip: copy.t('accept'),
              onPressed: () => onAcceptSuggestion(suggestion),
              icon: const Icon(Icons.check),
            ),
            IconButton(
              tooltip: copy.t('convertToNote'),
              onPressed: () => onConvertSuggestion(suggestion),
              icon: const Icon(Icons.sticky_note_2_outlined),
            ),
            IconButton(
              tooltip: copy.t('reject'),
              onPressed: () => onRejectSuggestion(suggestion),
              icon: const Icon(Icons.close),
            ),
          ],
        ),
      ],
    );
  }
}

final class _ScenePatchPreview extends StatelessWidget {
  const _ScenePatchPreview({
    required this.copy,
    required this.patch,
  });

  final WritelerCopy copy;
  final ScenePlanningPatch? patch;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final changes = patch?.changes ?? const <ScenePlanningFieldChange>[];
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: color.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.fact_check_outlined, size: 18, color: color.primary),
                const SizedBox(width: 8),
                Text(
                  copy.t('applyPreview'),
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (changes.isEmpty)
              Text(
                copy.t('noApplyPreview'),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: color.onSurfaceVariant,
                    ),
              )
            else
              for (final change in changes) ...[
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _planningFieldLabel(change.fieldKey, copy),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        change.suggestedValue,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
          ],
        ),
      ),
    );
  }
}

final class _AIProviderStatusLine extends StatelessWidget {
  const _AIProviderStatusLine({
    required this.copy,
    required this.config,
  });

  final WritelerCopy copy;
  final AIProviderConfig config;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final isMock = config.kind == AIProviderKind.mock;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: isMock ? color.tertiaryContainer : color.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isMock ? Icons.science_outlined : Icons.cloud_done_outlined,
              size: 18,
              color:
                  isMock ? color.onTertiaryContainer : color.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                isMock
                    ? copy.t('aiMockProviderActive')
                    : '${copy.t('activeProvider')}: ${config.displayName} - ${config.modelName}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isMock
                          ? color.onTertiaryContainer
                          : color.onSurfaceVariant,
                    ),
              ),
            ),
          ],
        ),
      ),
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
    required this.notes,
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
  final List<ProjectNote> notes;
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
            notes: notes,
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
                    '${copy.t('chapters')}: ${preview.chapterCount} - '
                    '${copy.t('scenes')}: ${preview.sceneCount}\n'
                    '${copy.t('catalog')}: ${preview.catalogItemCount} - '
                    '${copy.t('relationships')}: ${preview.relationshipCount}\n'
                    '${copy.t('notes')}: ${preview.noteCount}',
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
    required this.designTheme,
    required this.onDesignThemeChanged,
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
  final WritelerDesignTheme designTheme;
  final ValueChanged<WritelerDesignTheme> onDesignThemeChanged;
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
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(copy.t('settings'),
            style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        _SettingsSection(
          title: copy.t('designSettings'),
          body: copy.t('designSettingsBody'),
          child: _DesignThemeSelector(
            copy: copy,
            value: designTheme,
            onChanged: onDesignThemeChanged,
          ),
        ),
        _SettingsSection(
          title: copy.t('privacySettings'),
          body: copy.t('privacySettingsBody'),
          child: project == null
              ? Text(copy.t('selectProject'))
              : Column(
                  children: [
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
                    SwitchListTile(
                      value: project.noAiNoCloud,
                      title: Text(copy.t('noAiNoCloud')),
                      onChanged: (value) => onSavePrivacySettings(
                        aiEnabled: value ? false : project.aiEnabled,
                        cloudSyncEnabled:
                            value ? false : project.cloudSyncEnabled,
                        noAiNoCloud: value,
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                        child: Text(
                          '${copy.t('syncAdapter')}: $syncAdapterName. ${copy.t('syncAdapterHint')}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ),
                  ],
                ),
        ),
        _SettingsSection(
          title: copy.t('providerConfig'),
          body: copy.t('providerSettingsBody'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                '${activeProviderConfig?.displayName ?? providerNameController.text} - '
                '${activeProviderConfig?.modelName ?? modelNameController.text}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

final class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.title,
    required this.body,
    required this.child,
  });

  final String title;
  final String body;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: color.outlineVariant),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(
                body,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: color.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 14),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

final class _DesignThemeSelector extends StatelessWidget {
  const _DesignThemeSelector({
    required this.copy,
    required this.value,
    required this.onChanged,
  });

  final WritelerCopy copy;
  final WritelerDesignTheme value;
  final ValueChanged<WritelerDesignTheme> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final theme in WritelerDesignTheme.values)
          _DesignThemeSwatch(
            copy: copy,
            theme: theme,
            selected: theme == value,
            onTap: () => onChanged(theme),
          ),
      ],
    );
  }
}

final class _DesignThemeSwatch extends StatelessWidget {
  const _DesignThemeSwatch({
    required this.copy,
    required this.theme,
    required this.selected,
    required this.onTap,
  });

  final WritelerCopy copy;
  final WritelerDesignTheme theme;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = _tokensFor(theme);
    final color = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      selected: selected,
      label: _designThemeLabel(theme, copy),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          width: 150,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: selected
                ? color.primary.withValues(alpha: 0.10)
                : color.surfaceContainerLow,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected ? color.primary : color.outlineVariant,
              width: selected ? 1.6 : 1,
            ),
          ),
          child: Row(
            children: [
              _ThemeMiniature(tokens: tokens),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _designThemeLabel(theme, copy),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight:
                            selected ? FontWeight.w800 : FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final class _ThemeMiniature extends StatelessWidget {
  const _ThemeMiniature({required this.tokens});

  final _WritelerThemeTokens tokens;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 34,
      height: 30,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: tokens.surface,
          borderRadius: BorderRadius.circular(7),
          border: Border.all(color: tokens.outlineVariant),
        ),
        child: Align(
          alignment: Alignment.bottomRight,
          child: Container(
            width: 17,
            height: 17,
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: tokens.primary,
              borderRadius: BorderRadius.circular(5),
            ),
          ),
        ),
      ),
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
    final color = Theme.of(context).colorScheme;
    if (actionLabel == null || actionIcon == null) {
      return const SizedBox.shrink();
    }
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: color.surface,
        border: Border(
          bottom: BorderSide(color: color.outlineVariant),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          children: [
            Expanded(child: Semantics(label: title, header: true)),
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
    required this.onDelete,
  });

  final WritelerCopy copy;
  final List<Project> projects;
  final Project? selectedProject;
  final ValueChanged<Project> onSelect;
  final ValueChanged<Project> onDelete;

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
            title: Text(
              project.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              '${copy.t('localOnly')} - ${project.projectType}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: IconButton(
              tooltip: copy.t('deleteProject'),
              onPressed: () => onDelete(project),
              icon: const Icon(Icons.delete_outline),
            ),
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
    required this.onDeleteScene,
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
  final ValueChanged<Scene> onDeleteScene;
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
                        onDeleteScene: onDeleteScene,
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
    required this.onDeleteScene,
  });

  final WritelerCopy copy;
  final List<Scene> scenes;
  final Scene? selectedScene;
  final ValueChanged<Scene> onSelectScene;
  final ValueChanged<Scene> onDeleteScene;

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
          trailing: IconButton(
            tooltip: copy.t('deleteScene'),
            onPressed: () => onDeleteScene(scene),
            icon: const Icon(Icons.delete_outline),
          ),
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

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      padding: EdgeInsets.all(_focusMode ? 32 : 24),
      color: _focusMode ? color.surfaceContainerLowest : Colors.transparent,
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
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: _focusMode
                    ? color.surfaceContainerLowest
                    : color.surfaceContainerLow,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _focusMode
                      ? color.primary.withValues(alpha: 0.42)
                      : color.outlineVariant,
                ),
              ),
              child: TextField(
                controller: widget.controller,
                expands: true,
                maxLines: null,
                minLines: null,
                textAlignVertical: TextAlignVertical.top,
                cursorColor: color.primary,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontSize: _focusMode ? 19 : 17,
                      height: 1.7,
                    ),
                decoration: InputDecoration(
                  labelText: copy.t('manuscript'),
                  alignLabelWithHint: true,
                  filled: false,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.all(22),
                ),
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
        color: color.surfaceContainerLow,
        border: Border.all(
          color: focusMode
              ? color.primary.withValues(alpha: 0.46)
              : color.outlineVariant,
        ),
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
    'chapter.deleted' => german ? 'Kapitel geloescht' : 'Chapter deleted',
    'scene.created' => german ? 'Szene angelegt' : 'Scene created',
    'scene.saved' => german ? 'Szene gespeichert' : 'Scene saved',
    'scene.deleted' => german ? 'Szene geloescht' : 'Scene deleted',
    'scene.reordered' => german ? 'Szene sortiert' : 'Scene reordered',
    'scene.moved' => german ? 'Szene verschoben' : 'Scene moved',
    'catalog.created' =>
      german ? 'Katalogeintrag angelegt' : 'Catalog item created',
    'catalog.deleted' =>
      german ? 'Katalogeintrag geloescht' : 'Catalog item deleted',
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
