part of '../main.dart';

// Application root, design-theme persistence, and theme token definitions.

final class WritelerApp extends StatefulWidget {
  const WritelerApp({
    required this.projectRepository,
    required this.sceneRepository,
    required this.sceneSnapshotRepository,
    required this.chapterRepository,
    required this.catalogItemRepository,
    required this.relationshipRepository,
    required this.metricRepository,
    required this.aiSuggestionRepository,
    required this.projectNoteRepository,
    this.researchItemRepository,
    required this.aiProviderConfigRepository,
    required this.appPreferenceRepository,
    required this.secretVault,
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
  final ResearchItemRepository? researchItemRepository;
  final AIProviderConfigRepository aiProviderConfigRepository;
  final AppPreferenceRepository appPreferenceRepository;
  final SecretVault secretVault;

  @override
  State<WritelerApp> createState() => _WritelerAppState();
}

final class _WritelerAppState extends State<WritelerApp> {
  static const _designThemePreferenceKey = 'design.theme';
  static const _languagePreferenceKey = 'app.language';
  static const _globalAiEnabledPreferenceKey = 'profile.aiEnabled';
  static const _globalCloudSyncEnabledPreferenceKey =
      'profile.cloudSyncEnabled';
  static const _globalNoAiNoCloudPreferenceKey = 'profile.noAiNoCloud';
  static const _spellCheckEnabledPreferenceKey = 'spellcheck.enabled';
  static const _spellCheckLanguagePreferenceKey = 'spellcheck.language';
  static const _spellCheckProviderPreferenceKey = 'spellcheck.provider';

  WritelerDesignTheme _designTheme = WritelerDesignTheme.paper;
  String _languageCode = WritelerCopy.fallbackLanguageCode;
  bool _globalAiEnabled = true;
  bool _globalCloudSyncEnabled = false;
  bool _globalNoAiNoCloud = false;
  SpellCheckSettings _spellCheckSettings = SpellCheckSettings.fallback;
  late final SpellChecker _spellChecker = LanguageToolSpellChecker();

  @override
  void initState() {
    super.initState();
    unawaited(_loadDesignTheme());
    unawaited(_loadLanguage());
    unawaited(_loadGlobalProfileSettings());
    unawaited(_loadSpellCheckSettings());
  }

  Future<void> _loadDesignTheme() async {
    final value =
        await widget.appPreferenceRepository.read(_designThemePreferenceKey);
    if (!mounted || value == null) return;
    final theme = WritelerDesignThemeWire.tryParse(value);
    if (theme == null || theme == _designTheme) return;
    setState(() => _designTheme = theme);
  }

  void _changeDesignTheme(WritelerDesignTheme theme) {
    if (theme == _designTheme) return;
    setState(() => _designTheme = theme);
    unawaited(
      widget.appPreferenceRepository.write(
        _designThemePreferenceKey,
        theme.wireName,
      ),
    );
  }

  Future<void> _loadLanguage() async {
    final value =
        await widget.appPreferenceRepository.read(_languagePreferenceKey);
    if (!mounted || value == null) return;
    final languageCode = WritelerCopy.normalizeLanguageCode(value);
    if (languageCode == _languageCode) return;
    setState(() => _languageCode = languageCode);
  }

  void _changeLanguage(String languageCode) {
    final normalized = WritelerCopy.normalizeLanguageCode(languageCode);
    if (normalized == _languageCode) return;
    setState(() => _languageCode = normalized);
    unawaited(
      widget.appPreferenceRepository.write(
        _languagePreferenceKey,
        normalized,
      ),
    );
  }

  Future<void> _loadGlobalProfileSettings() async {
    final aiEnabled = await widget.appPreferenceRepository
        .read(_globalAiEnabledPreferenceKey);
    final cloudSyncEnabled = await widget.appPreferenceRepository
        .read(_globalCloudSyncEnabledPreferenceKey);
    final noAiNoCloud = await widget.appPreferenceRepository
        .read(_globalNoAiNoCloudPreferenceKey);
    if (!mounted) return;
    setState(() {
      _globalAiEnabled = _readBoolPreference(aiEnabled, fallback: true);
      _globalCloudSyncEnabled =
          _readBoolPreference(cloudSyncEnabled, fallback: false);
      _globalNoAiNoCloud = _readBoolPreference(noAiNoCloud, fallback: false);
      if (_globalNoAiNoCloud) {
        _globalAiEnabled = false;
        _globalCloudSyncEnabled = false;
      }
    });
  }

  void _changeGlobalProfileSettings({
    required bool aiEnabled,
    required bool cloudSyncEnabled,
    required bool noAiNoCloud,
  }) {
    final normalizedAiEnabled = noAiNoCloud ? false : aiEnabled;
    final normalizedCloudSyncEnabled = noAiNoCloud ? false : cloudSyncEnabled;
    setState(() {
      _globalAiEnabled = normalizedAiEnabled;
      _globalCloudSyncEnabled = normalizedCloudSyncEnabled;
      _globalNoAiNoCloud = noAiNoCloud;
      if (noAiNoCloud && _spellCheckSettings.enabled) {
        _spellCheckSettings = _spellCheckSettings.copyWith(enabled: false);
      }
    });
    unawaited(
      widget.appPreferenceRepository.write(
        _globalAiEnabledPreferenceKey,
        normalizedAiEnabled.toString(),
      ),
    );
    unawaited(
      widget.appPreferenceRepository.write(
        _globalCloudSyncEnabledPreferenceKey,
        normalizedCloudSyncEnabled.toString(),
      ),
    );
    unawaited(
      widget.appPreferenceRepository.write(
        _globalNoAiNoCloudPreferenceKey,
        noAiNoCloud.toString(),
      ),
    );
    if (noAiNoCloud) {
      unawaited(
        widget.appPreferenceRepository.write(
          _spellCheckEnabledPreferenceKey,
          false.toString(),
        ),
      );
    }
  }

  bool _readBoolPreference(String? value, {required bool fallback}) {
    if (value == null) return fallback;
    return value.toLowerCase() == 'true';
  }

  Future<void> _loadSpellCheckSettings() async {
    final enabled = await widget.appPreferenceRepository
        .read(_spellCheckEnabledPreferenceKey);
    final language = await widget.appPreferenceRepository
        .read(_spellCheckLanguagePreferenceKey);
    final provider = await widget.appPreferenceRepository
        .read(_spellCheckProviderPreferenceKey);
    if (!mounted) return;
    setState(() {
      _spellCheckSettings = SpellCheckSettings(
        enabled: _readBoolPreference(enabled, fallback: false),
        languageCode: language ?? SpellCheckSettings.fallback.languageCode,
        provider: SpellCheckProviderWire.parse(provider),
      );
    });
  }

  void _changeSpellCheckSettings(SpellCheckSettings settings) {
    setState(() => _spellCheckSettings = settings);
    unawaited(
      widget.appPreferenceRepository.write(
        _spellCheckEnabledPreferenceKey,
        settings.enabled.toString(),
      ),
    );
    unawaited(
      widget.appPreferenceRepository.write(
        _spellCheckLanguagePreferenceKey,
        settings.languageCode,
      ),
    );
    unawaited(
      widget.appPreferenceRepository.write(
        _spellCheckProviderPreferenceKey,
        settings.provider.wireName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final followsSystem = _designTheme == WritelerDesignTheme.system;
    return MaterialApp(
      title: 'Writeler',
      debugShowCheckedModeBanner: false,
      locale: Locale(_languageCode),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('de'),
        Locale('en'),
      ],
      theme: _buildWritelerTheme(
        followsSystem ? WritelerDesignTheme.paper : _designTheme,
      ),
      darkTheme: _buildWritelerTheme(
        followsSystem ? WritelerDesignTheme.dusk : _designTheme,
      ),
      themeMode: followsSystem ? ThemeMode.system : ThemeMode.light,
      home: WritelerShell(
        projectRepository: widget.projectRepository,
        sceneRepository: widget.sceneRepository,
        sceneSnapshotRepository: widget.sceneSnapshotRepository,
        chapterRepository: widget.chapterRepository,
        catalogItemRepository: widget.catalogItemRepository,
        relationshipRepository: widget.relationshipRepository,
        metricRepository: widget.metricRepository,
        aiSuggestionRepository: widget.aiSuggestionRepository,
        projectNoteRepository: widget.projectNoteRepository,
        researchItemRepository:
            widget.researchItemRepository ?? InMemoryResearchItemRepository(),
        aiProviderConfigRepository: widget.aiProviderConfigRepository,
        secretVault: widget.secretVault,
        designTheme: _designTheme,
        onDesignThemeChanged: _changeDesignTheme,
        languageCode: _languageCode,
        onLanguageChanged: _changeLanguage,
        globalAiEnabled: _globalAiEnabled,
        globalCloudSyncEnabled: _globalCloudSyncEnabled,
        globalNoAiNoCloud: _globalNoAiNoCloud,
        onGlobalProfileSettingsChanged: _changeGlobalProfileSettings,
        spellCheckSettings: _spellCheckSettings,
        spellChecker: _spellChecker,
        onSpellCheckSettingsChanged: _changeSpellCheckSettings,
      ),
    );
  }
}

enum WritelerDesignTheme {
  system,
  paper,
  dusk,
  sapphire,
  sage,
  copper,
  ink,
}

extension WritelerDesignThemeWire on WritelerDesignTheme {
  String get wireName {
    return switch (this) {
      WritelerDesignTheme.paper => 'paper',
      WritelerDesignTheme.system => 'system',
      WritelerDesignTheme.dusk => 'dusk',
      WritelerDesignTheme.sapphire => 'sapphire',
      WritelerDesignTheme.sage => 'sage',
      WritelerDesignTheme.copper => 'copper',
      WritelerDesignTheme.ink => 'ink',
    };
  }

  static WritelerDesignTheme? tryParse(String value) {
    return switch (value) {
      'paper' => WritelerDesignTheme.paper,
      'system' => WritelerDesignTheme.system,
      'dusk' => WritelerDesignTheme.dusk,
      'sapphire' => WritelerDesignTheme.sapphire,
      'sage' => WritelerDesignTheme.sage,
      'copper' => WritelerDesignTheme.copper,
      'ink' => WritelerDesignTheme.ink,
      _ => null,
    };
  }
}

enum _SceneSaveState {
  saved,
  unsaved,
  saving,
  error,
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

final class WritelerDesignTokens extends ThemeExtension<WritelerDesignTokens> {
  const WritelerDesignTokens({
    required this.ink,
    required this.inkSoft,
    required this.inkContrast,
    required this.pencil,
    required this.pencilStrong,
    required this.pencilBackground,
    required this.pencilBorder,
    required this.statusPlanned,
    required this.statusProgress,
    required this.statusDone,
    required this.statusLocked,
    required this.statusArchived,
    required this.panelShadow,
  });

  final Color ink;
  final Color inkSoft;
  final Color inkContrast;
  final Color pencil;
  final Color pencilStrong;
  final Color pencilBackground;
  final Color pencilBorder;
  final Color statusPlanned;
  final Color statusProgress;
  final Color statusDone;
  final Color statusLocked;
  final Color statusArchived;
  final BoxShadow panelShadow;

  @override
  WritelerDesignTokens copyWith({
    Color? ink,
    Color? inkSoft,
    Color? inkContrast,
    Color? pencil,
    Color? pencilStrong,
    Color? pencilBackground,
    Color? pencilBorder,
    Color? statusPlanned,
    Color? statusProgress,
    Color? statusDone,
    Color? statusLocked,
    Color? statusArchived,
    BoxShadow? panelShadow,
  }) {
    return WritelerDesignTokens(
      ink: ink ?? this.ink,
      inkSoft: inkSoft ?? this.inkSoft,
      inkContrast: inkContrast ?? this.inkContrast,
      pencil: pencil ?? this.pencil,
      pencilStrong: pencilStrong ?? this.pencilStrong,
      pencilBackground: pencilBackground ?? this.pencilBackground,
      pencilBorder: pencilBorder ?? this.pencilBorder,
      statusPlanned: statusPlanned ?? this.statusPlanned,
      statusProgress: statusProgress ?? this.statusProgress,
      statusDone: statusDone ?? this.statusDone,
      statusLocked: statusLocked ?? this.statusLocked,
      statusArchived: statusArchived ?? this.statusArchived,
      panelShadow: panelShadow ?? this.panelShadow,
    );
  }

  @override
  WritelerDesignTokens lerp(
    covariant ThemeExtension<WritelerDesignTokens>? other,
    double t,
  ) {
    if (other is! WritelerDesignTokens) return this;
    return WritelerDesignTokens(
      ink: Color.lerp(ink, other.ink, t)!,
      inkSoft: Color.lerp(inkSoft, other.inkSoft, t)!,
      inkContrast: Color.lerp(inkContrast, other.inkContrast, t)!,
      pencil: Color.lerp(pencil, other.pencil, t)!,
      pencilStrong: Color.lerp(pencilStrong, other.pencilStrong, t)!,
      pencilBackground:
          Color.lerp(pencilBackground, other.pencilBackground, t)!,
      pencilBorder: Color.lerp(pencilBorder, other.pencilBorder, t)!,
      statusPlanned: Color.lerp(statusPlanned, other.statusPlanned, t)!,
      statusProgress: Color.lerp(statusProgress, other.statusProgress, t)!,
      statusDone: Color.lerp(statusDone, other.statusDone, t)!,
      statusLocked: Color.lerp(statusLocked, other.statusLocked, t)!,
      statusArchived: Color.lerp(statusArchived, other.statusArchived, t)!,
      panelShadow: BoxShadow.lerp(panelShadow, other.panelShadow, t)!,
    );
  }
}

WritelerDesignTokens _semanticTokensFor(_WritelerThemeTokens tokens) {
  final dark = tokens.brightness == Brightness.dark;
  if (dark) {
    return const WritelerDesignTokens(
      ink: Color(0xFF4FB3AD),
      inkSoft: Color(0x244FB3AD),
      inkContrast: Color(0xFF06201D),
      pencil: Color(0xFFD99A52),
      pencilStrong: Color(0xFFB97A36),
      pencilBackground: Color(0x1AD99A52),
      pencilBorder: Color(0x73D99A52),
      statusPlanned: Color(0xFF8A93A3),
      statusProgress: Color(0xFF4F8FD1),
      statusDone: Color(0xFF5CB37A),
      statusLocked: Color(0xFFA48CC9),
      statusArchived: Color(0xFF5B6472),
      panelShadow: BoxShadow(
        color: Color(0x52000000),
        blurRadius: 24,
        offset: Offset(0, 8),
      ),
    );
  }
  return const WritelerDesignTokens(
    ink: Color(0xFF1F7F78),
    inkSoft: Color(0x1A1F7F78),
    inkContrast: Color(0xFFEAFBF8),
    pencil: Color(0xFF9A6A2E),
    pencilStrong: Color(0xFF7A521F),
    pencilBackground: Color(0x149A6A2E),
    pencilBorder: Color(0x669A6A2E),
    statusPlanned: Color(0xFF6B7480),
    statusProgress: Color(0xFF2F6FAD),
    statusDone: Color(0xFF2F8A57),
    statusLocked: Color(0xFF7A5FA3),
    statusArchived: Color(0xFF7A8390),
    panelShadow: BoxShadow(
      color: Color(0x1A141410),
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  );
}

_WritelerThemeTokens _tokensFor(WritelerDesignTheme theme) {
  return switch (theme) {
    WritelerDesignTheme.system => _tokensFor(WritelerDesignTheme.paper),
    WritelerDesignTheme.paper => const _WritelerThemeTokens(
        brightness: Brightness.light,
        seed: Color(0xFF1F7F78),
        primary: Color(0xFF1F7F78),
        onPrimary: Color(0xFFEAFBF8),
        secondary: Color(0xFF9A6A2E),
        tertiary: Color(0xFF2F6FAD),
        surface: Color(0xFFF3F3EF),
        surfaceLowest: Color(0xFFFFFFFF),
        surfaceLow: Color(0xFFFBFBF9),
        surfaceMid: Color(0xFFE9E8E2),
        surfaceHigh: Color(0xFFE7E5DD),
        surfaceHighest: Color(0xFFDCDAD2),
        outline: Color(0xFF838D97),
        outlineVariant: Color(0xFFDCDAD2),
        error: Color(0xFFC5453D),
      ),
    WritelerDesignTheme.dusk => const _WritelerThemeTokens(
        brightness: Brightness.dark,
        seed: Color(0xFF4FB3AD),
        primary: Color(0xFF4FB3AD),
        onPrimary: Color(0xFF062321),
        secondary: Color(0xFFD99A52),
        tertiary: Color(0xFF4F8FD1),
        surface: Color(0xFF11151A),
        surfaceLowest: Color(0xFF0D1116),
        surfaceLow: Color(0xFF171D24),
        surfaceMid: Color(0xFF1D2430),
        surfaceHigh: Color(0xFF202936),
        surfaceHighest: Color(0xFF262E38),
        outline: Color(0xFF5F6B79),
        outlineVariant: Color(0xFF262E38),
        error: Color(0xFFE2675F),
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
  final design = _semanticTokensFor(tokens);
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
    fontFamily: 'Inter',
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
    extensions: [design],
    scaffoldBackgroundColor: scheme.surface,
    canvasColor: scheme.surface,
    fontFamily: 'Inter',
    fontFamilyFallback: const [
      'Roboto',
      'Segoe UI Variable',
      'Segoe UI',
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
        backgroundColor: design.ink,
        foregroundColor: design.inkContrast,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(48, 44),
        foregroundColor: design.ink,
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
