import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:writeler/core/domain/draft_status.dart';
import 'package:writeler/core/domain/entity_type.dart';
import 'package:writeler/features/ai_harness/infrastructure/in_memory_ai_suggestion_repository.dart';
import 'package:writeler/features/catalog/infrastructure/in_memory_catalog_item_repository.dart';
import 'package:writeler/features/catalog/infrastructure/in_memory_relationship_repository.dart';
import 'package:writeler/features/metrics/application/in_memory_metric_repository.dart';
import 'package:writeler/features/notes/infrastructure/in_memory_project_note_repository.dart';
import 'package:writeler/features/projects/application/create_project.dart';
import 'package:writeler/features/projects/infrastructure/in_memory_project_repository.dart';
import 'package:writeler/features/settings/infrastructure/in_memory_ai_provider_config_repository.dart';
import 'package:writeler/features/settings/infrastructure/in_memory_app_preference_repository.dart';
import 'package:writeler/features/settings/infrastructure/in_memory_secret_vault.dart';
import 'package:writeler/features/structure/application/create_chapter.dart';
import 'package:writeler/features/structure/application/create_scene.dart';
import 'package:writeler/features/structure/application/in_memory_chapter_repository.dart';
import 'package:writeler/features/structure/application/in_memory_scene_repository.dart';
import 'package:writeler/features/structure/application/in_memory_scene_snapshot_repository.dart';
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
        sceneSnapshotRepository: InMemorySceneSnapshotRepository(),
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
        sceneSnapshotRepository: InMemorySceneSnapshotRepository(),
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

  testWidgets('project wizard stores author metadata', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final appPreferenceRepository = InMemoryAppPreferenceRepository();
    final projectRepository = InMemoryProjectRepository();
    await appPreferenceRepository.write('app.language', 'en');

    await tester.pumpWidget(
      WritelerApp(
        projectRepository: projectRepository,
        chapterRepository: InMemoryChapterRepository(),
        sceneRepository: InMemorySceneRepository(),
        sceneSnapshotRepository: InMemorySceneSnapshotRepository(),
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
    await tester.enterText(find.byType(EditableText), 'Wizard Book');
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(EditableText).first, 'Ada Author');
    await tester.tap(find.text('Create'));
    await tester.pumpAndSettle();

    final projects = await projectRepository.listActive();
    expect(projects.single.title, 'Wizard Book');
    expect(projects.single.metadata['authorName'], 'Ada Author');
  });

  testWidgets('desktop drag moves a scene to another chapter', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final appPreferenceRepository = InMemoryAppPreferenceRepository();
    final projectRepository = InMemoryProjectRepository();
    final chapterRepository = InMemoryChapterRepository();
    final sceneRepository = InMemorySceneRepository();
    await appPreferenceRepository.write('app.language', 'en');
    final project = await CreateProject(projectRepository)(
      const CreateProjectCommand(title: 'Drag Book'),
    );
    final chapterOne = await CreateChapter(chapterRepository)(
      CreateChapterCommand(
        projectId: project.id,
        title: 'Chapter One',
        orderIndex: 1,
      ),
    );
    final chapterTwo = await CreateChapter(chapterRepository)(
      CreateChapterCommand(
        projectId: project.id,
        title: 'Chapter Two',
        orderIndex: 2,
      ),
    );
    final scene = await CreateScene(sceneRepository)(
      CreateSceneCommand(
        projectId: project.id,
        chapterId: chapterOne.id,
        title: 'Move Me',
      ),
    );

    await tester.pumpWidget(
      WritelerApp(
        projectRepository: projectRepository,
        chapterRepository: chapterRepository,
        sceneRepository: sceneRepository,
        sceneSnapshotRepository: InMemorySceneSnapshotRepository(),
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

    await tester.tap(find.text('Project structure').first);
    await tester.pumpAndSettle();

    final sourceCenter = tester.getCenter(find.text('Move Me').first);
    final targetCenter = tester.getCenter(find.text('Chapter Two').last);
    await tester.dragFrom(sourceCenter, targetCenter - sourceCenter);
    await tester.pumpAndSettle();

    final moved = await sceneRepository.findById(scene.id);
    expect(moved?.chapterId, chapterTwo.id);
  });

  testWidgets('desktop drag on scene board asks for grouped target status',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(1400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final appPreferenceRepository = InMemoryAppPreferenceRepository();
    final projectRepository = InMemoryProjectRepository();
    final sceneRepository = InMemorySceneRepository();
    await appPreferenceRepository.write('app.language', 'en');
    final project = await CreateProject(projectRepository)(
      const CreateProjectCommand(title: 'Status Drag Book'),
    );
    final scene = await CreateScene(sceneRepository)(
      CreateSceneCommand(projectId: project.id, title: 'Status Move'),
    );

    await tester.pumpWidget(
      WritelerApp(
        projectRepository: projectRepository,
        chapterRepository: InMemoryChapterRepository(),
        sceneRepository: sceneRepository,
        sceneSnapshotRepository: InMemorySceneSnapshotRepository(),
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

    await tapNavigationItem(tester, 'Scene board');

    final sourceCenter = tester.getCenter(find.text('Status Move').first);
    final targetCenter = tester.getCenter(find.text('Done').first);
    await tester.dragFrom(sourceCenter, targetCenter - sourceCenter);
    await tester.pumpAndSettle();

    expect(find.text('Choose status'), findsOneWidget);

    await tester.tap(find.text('Revised'));
    await tester.pumpAndSettle();

    final moved = await sceneRepository.findById(scene.id);
    expect(moved?.status, DraftStatus.revised);
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
        sceneSnapshotRepository: InMemorySceneSnapshotRepository(),
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
    await tester.binding.setSurfaceSize(const Size(1280, 1100));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final appPreferenceRepository = InMemoryAppPreferenceRepository();
    await appPreferenceRepository.write('app.language', 'en');
    final projectRepository = InMemoryProjectRepository();
    final chapterRepository = InMemoryChapterRepository();
    final sceneRepository = InMemorySceneRepository();
    final catalogItemRepository = InMemoryCatalogItemRepository();
    final relationshipRepository = InMemoryRelationshipRepository();

    await tester.pumpWidget(
      WritelerApp(
        projectRepository: projectRepository,
        chapterRepository: chapterRepository,
        sceneRepository: sceneRepository,
        sceneSnapshotRepository: InMemorySceneSnapshotRepository(),
        catalogItemRepository: catalogItemRepository,
        relationshipRepository: relationshipRepository,
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
    final project = (await projectRepository.listActive()).single;

    expect(find.text('Opening'), findsWidgets);
    expect(find.text('Manuscript'), findsWidgets);
    expect(find.byTooltip('Bold'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('manuscript-field')),
      'Plain words',
    );
    await tester.tap(find.byTooltip('Bold'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Save Scene'));
    await tester.pumpAndSettle();

    final savedScene = (await sceneRepository.listByProject(project.id)).single;
    expect(savedScene.manuscriptText, 'Plain words**text**');

    await tester.drag(
      find.byKey(const ValueKey('scene-inspector-scroll')),
      const Offset(0, -900),
    );
    await tester.pumpAndSettle();
    expect(find.text('Scene context'), findsOneWidget);

    await tester.tap(find.byTooltip(
      'Add character, location, or object to this scene',
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.text('New Character'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find
          .descendant(
            of: find.byType(AlertDialog),
            matching: find.byType(TextField),
          )
          .first,
      'Mara',
    );
    await tester.tap(find.text('Create'));
    await tester.pumpAndSettle();

    expect(find.text('Mara'), findsOneWidget);

    await tester.tap(find.byTooltip('Remove from scene').first);
    await tester.pumpAndSettle();
    expect(
      (await relationshipRepository.listByProject(project.id)).where(
        (relationship) => relationship.relationshipType == 'appearsIn',
      ),
      isEmpty,
    );
    expect(find.text('Mara'), findsNothing);

    await tester.tap(find.byTooltip(
      'Add character, location, or object to this scene',
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.text('New Character'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find
          .descendant(
            of: find.byType(AlertDialog),
            matching: find.byType(TextField),
          )
          .first,
      'Noah',
    );
    await tester.tap(find.text('Create'));
    await tester.pumpAndSettle();

    expect(find.text('Noah'), findsOneWidget);

    await tester.tap(find.byTooltip('Remove from scene').first);
    await tester.pumpAndSettle();
    expect(
      (await relationshipRepository.listByProject(project.id)).where(
        (relationship) => relationship.relationshipType == 'appearsIn',
      ),
      isEmpty,
    );
    expect(find.text('Noah'), findsNothing);

    await tester.tap(find.widgetWithText(OutlinedButton, 'Add existing'));
    await tester.pumpAndSettle();
    expect(find.text('Mara'), findsOneWidget);
    expect(find.text('Noah'), findsOneWidget);
    await tester.tap(find.byType(Checkbox).at(0));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(Checkbox).at(1));
    await tester.pumpAndSettle();
    expect(tester.widget<Checkbox>(find.byType(Checkbox).at(0)).value, isTrue);
    expect(tester.widget<Checkbox>(find.byType(Checkbox).at(1)).value, isTrue);
    await tester.tap(find.text('Add selection'));
    await tester.pumpAndSettle();

    final relationships =
        await relationshipRepository.listByProject(project.id);
    final sceneLinks = relationships
        .where(
          (relationship) =>
              relationship.relationshipType == 'appearsIn' &&
              relationship.source.type == EntityType.scene,
        )
        .toList();
    expect(sceneLinks, hasLength(2));
    expect(
      sceneLinks.map((relationship) => relationship.label),
      containsAll(['Mara', 'Noah']),
    );

    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    await tester.drag(
      find.byKey(const ValueKey('scene-inspector-scroll')),
      const Offset(0, -1400),
    );
    await tester.pumpAndSettle();
    expect(find.text('AI help'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.fullscreen).first);
    await tester.pumpAndSettle();

    expect(find.text('Opening'), findsOneWidget);
    expect(find.textContaining('No chapter'), findsNothing);
    expect(find.text('Manuscript'), findsWidgets);
    expect(find.text('AI help'), findsNothing);
    expect(find.byTooltip('Bold'), findsNothing);
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
        sceneSnapshotRepository: InMemorySceneSnapshotRepository(),
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
        sceneSnapshotRepository: InMemorySceneSnapshotRepository(),
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
        sceneSnapshotRepository: InMemorySceneSnapshotRepository(),
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
    expect(find.text('Spelling & dictionaries'), findsOneWidget);
    await tester.drag(find.byType(ListView).last, const Offset(0, -520));
    await tester.pumpAndSettle();
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
        sceneSnapshotRepository: InMemorySceneSnapshotRepository(),
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
        sceneSnapshotRepository: InMemorySceneSnapshotRepository(),
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
