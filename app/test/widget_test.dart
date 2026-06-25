import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:writeler/features/ai_harness/infrastructure/in_memory_ai_suggestion_repository.dart';
import 'package:writeler/features/catalog/infrastructure/in_memory_catalog_item_repository.dart';
import 'package:writeler/features/catalog/infrastructure/in_memory_relationship_repository.dart';
import 'package:writeler/features/metrics/application/in_memory_metric_repository.dart';
import 'package:writeler/features/notes/infrastructure/in_memory_project_note_repository.dart';
import 'package:writeler/features/projects/infrastructure/in_memory_project_repository.dart';
import 'package:writeler/features/settings/infrastructure/in_memory_ai_provider_config_repository.dart';
import 'package:writeler/features/settings/infrastructure/in_memory_app_preference_repository.dart';
import 'package:writeler/features/settings/infrastructure/in_memory_secret_vault.dart';
import 'package:writeler/features/structure/application/in_memory_chapter_repository.dart';
import 'package:writeler/features/structure/application/in_memory_scene_repository.dart';
import 'package:writeler/main.dart';

Future<void> tapNavigationItem(WidgetTester tester, String label) async {
  final finder = find.text(label).first;
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Writeler shell shows core workspace navigation', (tester) async {
    final appPreferenceRepository = InMemoryAppPreferenceRepository();
    await appPreferenceRepository.write('app.language', 'en');

    await tester.pumpWidget(
      WritelerApp(
        projectRepository: InMemoryProjectRepository(),
        chapterRepository: InMemoryChapterRepository(),
        sceneRepository: InMemorySceneRepository(),
        catalogItemRepository: InMemoryCatalogItemRepository(),
        relationshipRepository: InMemoryRelationshipRepository(),
        metricRepository: InMemoryMetricRepository(),
        aiSuggestionRepository: InMemoryAISuggestionRepository(),
        projectNoteRepository: InMemoryProjectNoteRepository(),
        aiProviderConfigRepository: InMemoryAIProviderConfigRepository(),
        appPreferenceRepository: appPreferenceRepository,
        secretVault: InMemorySecretVault(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('writeler'), findsOneWidget);
    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Editor'), findsOneWidget);
    expect(find.text('Project structure'), findsOneWidget);
    expect(find.text('Notes'), findsOneWidget);
    expect(find.text('AI Workshop'), findsOneWidget);
    expect(find.text('Logs'), findsOneWidget);
    expect(find.text('Self-publishing'), findsOneWidget);
    expect(find.text('New Project'), findsOneWidget);
  });

  testWidgets('new project action creates a local project row', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final appPreferenceRepository = InMemoryAppPreferenceRepository();
    await appPreferenceRepository.write('app.language', 'en');

    await tester.pumpWidget(
      WritelerApp(
        projectRepository: InMemoryProjectRepository(),
        chapterRepository: InMemoryChapterRepository(),
        sceneRepository: InMemorySceneRepository(),
        catalogItemRepository: InMemoryCatalogItemRepository(),
        relationshipRepository: InMemoryRelationshipRepository(),
        metricRepository: InMemoryMetricRepository(),
        aiSuggestionRepository: InMemoryAISuggestionRepository(),
        projectNoteRepository: InMemoryProjectNoteRepository(),
        aiProviderConfigRepository: InMemoryAIProviderConfigRepository(),
        appPreferenceRepository: appPreferenceRepository,
        secretVault: InMemorySecretVault(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('New Project'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(EditableText), 'Draft Atlas');
    await tester.tap(find.text('Create'));
    await tester.pumpAndSettle();

    expect(find.text('Draft Atlas'), findsWidgets);
    expect(find.text('Local - novel'), findsOneWidget);
    expect(find.text('Project created'), findsOneWidget);
    expect(find.text('Activity'), findsNothing);

    await tester.tap(find.text('Logs').first);
    await tester.pumpAndSettle();

    expect(find.text('Logs'), findsWidgets);
    expect(find.textContaining('Chronological events'), findsOneWidget);

    await tester.tap(find.text('Project structure').first);
    await tester.pumpAndSettle();

    expect(find.text('Structure cockpit'), findsOneWidget);
    expect(find.text('Author cockpit'), findsOneWidget);
  });

  testWidgets('AI workshop opens with actionable project context',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final appPreferenceRepository = InMemoryAppPreferenceRepository();
    await appPreferenceRepository.write('app.language', 'en');

    await tester.pumpWidget(
      WritelerApp(
        projectRepository: InMemoryProjectRepository(),
        chapterRepository: InMemoryChapterRepository(),
        sceneRepository: InMemorySceneRepository(),
        catalogItemRepository: InMemoryCatalogItemRepository(),
        relationshipRepository: InMemoryRelationshipRepository(),
        metricRepository: InMemoryMetricRepository(),
        aiSuggestionRepository: InMemoryAISuggestionRepository(),
        projectNoteRepository: InMemoryProjectNoteRepository(),
        aiProviderConfigRepository: InMemoryAIProviderConfigRepository(),
        appPreferenceRepository: appPreferenceRepository,
        secretVault: InMemorySecretVault(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('New Project'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(EditableText), 'AI Draft');
    await tester.tap(find.text('Create'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('AI Workshop').first);
    await tester.pumpAndSettle();

    final sendButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Send task'),
    );

    expect(sendButton.onPressed, isNotNull);
    expect(find.textContaining('Project-wide'), findsWidgets);

    await tester.ensureVisible(find.widgetWithText(FilledButton, 'Send task'));
    await tester.tap(find.widgetWithText(FilledButton, 'Send task'));
    await tester.pumpAndSettle();

    expect(find.textContaining('MockProvider'), findsOneWidget);
  });

  testWidgets('editor opens a scene and focus mode keeps manuscript usable',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final appPreferenceRepository = InMemoryAppPreferenceRepository();
    await appPreferenceRepository.write('app.language', 'en');

    await tester.pumpWidget(
      WritelerApp(
        projectRepository: InMemoryProjectRepository(),
        chapterRepository: InMemoryChapterRepository(),
        sceneRepository: InMemorySceneRepository(),
        catalogItemRepository: InMemoryCatalogItemRepository(),
        relationshipRepository: InMemoryRelationshipRepository(),
        metricRepository: InMemoryMetricRepository(),
        aiSuggestionRepository: InMemoryAISuggestionRepository(),
        projectNoteRepository: InMemoryProjectNoteRepository(),
        aiProviderConfigRepository: InMemoryAIProviderConfigRepository(),
        appPreferenceRepository: appPreferenceRepository,
        secretVault: InMemorySecretVault(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('New Project'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(EditableText), 'Editor Check');
    await tester.tap(find.text('Create'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Editor').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('New Scene').first);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(EditableText), 'Opening');
    await tester.tap(find.text('Create'));
    await tester.pumpAndSettle();

    expect(find.text('Opening'), findsWidgets);
    expect(find.text('Manuscript'), findsWidgets);

    await tester.tap(find.byIcon(Icons.fullscreen).first);
    await tester.pumpAndSettle();

    expect(find.text('Opening'), findsOneWidget);
    expect(find.textContaining('No chapter'), findsNothing);
    expect(find.text('Manuscript'), findsWidgets);
  });

  testWidgets('relationship graph explains required endpoints', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final appPreferenceRepository = InMemoryAppPreferenceRepository();
    await appPreferenceRepository.write('app.language', 'en');

    await tester.pumpWidget(
      WritelerApp(
        projectRepository: InMemoryProjectRepository(),
        chapterRepository: InMemoryChapterRepository(),
        sceneRepository: InMemorySceneRepository(),
        catalogItemRepository: InMemoryCatalogItemRepository(),
        relationshipRepository: InMemoryRelationshipRepository(),
        metricRepository: InMemoryMetricRepository(),
        aiSuggestionRepository: InMemoryAISuggestionRepository(),
        projectNoteRepository: InMemoryProjectNoteRepository(),
        aiProviderConfigRepository: InMemoryAIProviderConfigRepository(),
        appPreferenceRepository: appPreferenceRepository,
        secretVault: InMemorySecretVault(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('New Project'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(EditableText), 'Relationship Check');
    await tester.tap(find.text('Create'));
    await tester.pumpAndSettle();

    await tapNavigationItem(tester, 'Relationship graph');

    expect(
      find.text(
          'Create at least two scenes, characters, locations, or objects first.'),
      findsOneWidget,
    );

    await tester
        .tap(find.widgetWithText(FilledButton, 'New relationship').last);
    await tester.pumpAndSettle();

    expect(
      find.text(
          'Create at least two scenes, characters, locations, or objects first.'),
      findsWidgets,
    );
  });

  testWidgets('top bar language switch updates workspace copy', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final appPreferenceRepository = InMemoryAppPreferenceRepository();
    await appPreferenceRepository.write('app.language', 'en');

    await tester.pumpWidget(
      WritelerApp(
        projectRepository: InMemoryProjectRepository(),
        chapterRepository: InMemoryChapterRepository(),
        sceneRepository: InMemorySceneRepository(),
        catalogItemRepository: InMemoryCatalogItemRepository(),
        relationshipRepository: InMemoryRelationshipRepository(),
        metricRepository: InMemoryMetricRepository(),
        aiSuggestionRepository: InMemoryAISuggestionRepository(),
        projectNoteRepository: InMemoryProjectNoteRepository(),
        aiProviderConfigRepository: InMemoryAIProviderConfigRepository(),
        appPreferenceRepository: appPreferenceRepository,
        secretVault: InMemorySecretVault(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('New Project'), findsOneWidget);

    await tester.tap(find.text('EN'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Deutsch'));
    await tester.pumpAndSettle();

    expect(find.text('Neues Projekt'), findsOneWidget);
    expect(await appPreferenceRepository.read('app.language'), 'de');
  });

  testWidgets('settings and import stay available without a project',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final appPreferenceRepository = InMemoryAppPreferenceRepository();
    await appPreferenceRepository.write('app.language', 'en');

    await tester.pumpWidget(
      WritelerApp(
        projectRepository: InMemoryProjectRepository(),
        chapterRepository: InMemoryChapterRepository(),
        sceneRepository: InMemorySceneRepository(),
        catalogItemRepository: InMemoryCatalogItemRepository(),
        relationshipRepository: InMemoryRelationshipRepository(),
        metricRepository: InMemoryMetricRepository(),
        aiSuggestionRepository: InMemoryAISuggestionRepository(),
        projectNoteRepository: InMemoryProjectNoteRepository(),
        aiProviderConfigRepository: InMemoryAIProviderConfigRepository(),
        appPreferenceRepository: appPreferenceRepository,
        secretVault: InMemorySecretVault(),
      ),
    );
    await tester.pumpAndSettle();

    await tapNavigationItem(tester, 'Settings');

    expect(find.text('Work profile'), findsOneWidget);
    expect(find.text('Provider configuration'), findsOneWidget);

    await tapNavigationItem(tester, 'Export/Import');

    expect(find.text('Drop file here'), findsOneWidget);
    expect(find.text('Choose import file'), findsOneWidget);
  });

  testWidgets('settings store global work profile preferences', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final appPreferenceRepository = InMemoryAppPreferenceRepository();
    await appPreferenceRepository.write('app.language', 'en');

    await tester.pumpWidget(
      WritelerApp(
        projectRepository: InMemoryProjectRepository(),
        chapterRepository: InMemoryChapterRepository(),
        sceneRepository: InMemorySceneRepository(),
        catalogItemRepository: InMemoryCatalogItemRepository(),
        relationshipRepository: InMemoryRelationshipRepository(),
        metricRepository: InMemoryMetricRepository(),
        aiSuggestionRepository: InMemoryAISuggestionRepository(),
        projectNoteRepository: InMemoryProjectNoteRepository(),
        aiProviderConfigRepository: InMemoryAIProviderConfigRepository(),
        appPreferenceRepository: appPreferenceRepository,
        secretVault: InMemorySecretVault(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('New Project'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(EditableText), 'Profile Test');
    await tester.tap(find.text('Create'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    await tapNavigationItem(tester, 'Settings');

    expect(find.text('Work profile'), findsOneWidget);
    expect(find.text('Select a project'), findsNothing);

    await tester.tap(find.text('No AI / No Cloud'));
    await tester.pumpAndSettle();

    expect(await appPreferenceRepository.read('profile.noAiNoCloud'), 'true');
    expect(await appPreferenceRepository.read('profile.aiEnabled'), 'false');
    expect(
      await appPreferenceRepository.read('profile.cloudSyncEnabled'),
      'false',
    );
  });

  testWidgets('stored design theme is applied', (tester) async {
    final appPreferenceRepository = InMemoryAppPreferenceRepository();
    await appPreferenceRepository.write('design.theme', 'sapphire');

    await tester.pumpWidget(
      WritelerApp(
        projectRepository: InMemoryProjectRepository(),
        chapterRepository: InMemoryChapterRepository(),
        sceneRepository: InMemorySceneRepository(),
        catalogItemRepository: InMemoryCatalogItemRepository(),
        relationshipRepository: InMemoryRelationshipRepository(),
        metricRepository: InMemoryMetricRepository(),
        aiSuggestionRepository: InMemoryAISuggestionRepository(),
        projectNoteRepository: InMemoryProjectNoteRepository(),
        aiProviderConfigRepository: InMemoryAIProviderConfigRepository(),
        appPreferenceRepository: appPreferenceRepository,
        secretVault: InMemorySecretVault(),
      ),
    );

    await tester.pumpAndSettle();
    final context = tester.element(find.text('writeler'));

    expect(
      Theme.of(context).colorScheme.primary,
      const Color(0xFF8FC4FF),
    );
  });
}
