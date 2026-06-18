part of '../main.dart';

// Application root, design-theme persistence, and theme token definitions.

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
    required this.appPreferenceRepository,
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
  final AppPreferenceRepository appPreferenceRepository;
  final SecretVault secretVault;

  @override
  State<WritelerApp> createState() => _WritelerAppState();
}

final class _WritelerAppState extends State<WritelerApp> {
  static const _designThemePreferenceKey = 'design.theme';

  WritelerDesignTheme _designTheme = WritelerDesignTheme.paper;

  @override
  void initState() {
    super.initState();
    unawaited(_loadDesignTheme());
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
        onDesignThemeChanged: _changeDesignTheme,
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

extension WritelerDesignThemeWire on WritelerDesignTheme {
  String get wireName {
    return switch (this) {
      WritelerDesignTheme.paper => 'paper',
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
