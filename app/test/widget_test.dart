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
import 'package:writeler/features/research/infrastructure/in_memory_research_item_repository.dart';
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
    expect(find.text('Local - Novel'), findsOneWidget);
    expect(find.text('Project created'), findsOneWidget);
    expect(find.text('Activity'), findsNothing);

    await tapNavigationItem(tester, 'Logs');

    expect(find.text('Logs'), findsWidgets);
    expect(find.textContaining('Chronological events'), findsOneWidget);

    await tapNavigationItem(tester, 'Project structure');

    expect(find.text('Structure cockpit'), findsOneWidget);
    expect(find.text('Author cockpit'), findsOneWidget);
  });

  testWidgets('research library creates a linked source', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final appPreferenceRepository = InMemoryAppPreferenceRepository();
    final projectRepository = InMemoryProjectRepository();
    final sceneRepository = InMemorySceneRepository();
    final researchRepository = InMemoryResearchItemRepository();
    await appPreferenceRepository.write('app.language', 'en');
    final project = await CreateProject(projectRepository)(
      const CreateProjectCommand(title: 'Research Book'),
    );
    final scene = await CreateScene(sceneRepository)(
      CreateSceneCommand(projectId: project.id, title: 'Archive Scene'),
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
        researchItemRepository: researchRepository,
        aiProviderConfigRepository: InMemoryAIProviderConfigRepository(),
        appPreferenceRepository: appPreferenceRepository,
        secretVault: InMemorySecretVault(),
      ),
    );
    await tester.pumpAndSettle();

    await tapNavigationItem(tester, 'Research');
    await tester.tap(find.text('New source'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), 'NASA archive');
    await tester.enterText(
        find.byType(TextField).at(1), 'https://example.test');
    await tester.enterText(find.byType(TextField).at(2), 'Example Archive');
    await tester.enterText(find.byType(TextField).at(3), 'space, station');
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Scene: Archive Scene').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'Useful details.');
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();

    final items = await researchRepository.listForProject(project.id);
    expect(items.single.title, 'NASA archive');
    expect(items.single.uri, 'https://example.test');
    expect(items.single.tags, ['space', 'station']);
    expect(items.single.target?.id, scene.id);
    expect(find.text('NASA archive'), findsWidgets);
  });

  testWidgets('story context saves text and accepts AI starter suggestions',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(1400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final appPreferenceRepository = InMemoryAppPreferenceRepository();
    final projectRepository = InMemoryProjectRepository();
    final catalogRepository = InMemoryCatalogItemRepository();
    final suggestionRepository = InMemoryAISuggestionRepository();
    await appPreferenceRepository.write('app.language', 'en');
    final project = await CreateProject(projectRepository)(
      const CreateProjectCommand(title: 'World Book'),
    );

    await tester.pumpWidget(
      WritelerApp(
        projectRepository: projectRepository,
        chapterRepository: InMemoryChapterRepository(),
        sceneRepository: InMemorySceneRepository(),
        sceneSnapshotRepository: InMemorySceneSnapshotRepository(),
        catalogItemRepository: catalogRepository,
        relationshipRepository: InMemoryRelationshipRepository(),
        metricRepository: InMemoryMetricRepository(),
        aiSuggestionRepository: suggestionRepository,
        projectNoteRepository: InMemoryProjectNoteRepository(),
        researchItemRepository: InMemoryResearchItemRepository(),
        aiProviderConfigRepository: InMemoryAIProviderConfigRepository(),
        appPreferenceRepository: appPreferenceRepository,
        secretVault: InMemorySecretVault(),
      ),
    );
    await tester.pumpAndSettle();

    await tapNavigationItem(tester, 'Context');
    await tester.enterText(
      find.byType(TextField).first,
      'A city remembers a false peace and everyone pays with secrets.',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Save context'));
    await tester.pumpAndSettle();

    final savedProject = await projectRepository.findById(project.id);
    expect(savedProject?.metadata['storyContext'], contains('false peace'));

    await tester.tap(find.widgetWithText(OutlinedButton, 'AI starter'));
    await tester.pumpAndSettle();

    final suggestions = await suggestionRepository.listForProject(project.id);
    expect(
      suggestions.where((suggestion) =>
          suggestion.suggestionType.startsWith('worldContextStarter.persona')),
      hasLength(10),
    );
    expect(find.text('Mara Venn'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.check).first);
    await tester.pumpAndSettle();

    final catalogItems = await catalogRepository.listByProject(project.id);
    expect(catalogItems.map((item) => item.name), contains('Mara Venn'));
    expect(catalogItems.single.type, EntityType.character);
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

  testWidgets('project wizard supports research projects with page targets',
      (tester) async {
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
    await tester.enterText(find.byType(EditableText), 'Research Atlas');
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownButtonFormField<String>).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Research project').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pages'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(EditableText).first, '120');
    await tester.tap(find.text('Create'));
    await tester.pumpAndSettle();

    final project = (await projectRepository.listActive()).single;
    expect(project.projectType, 'research');
    expect(project.wordTarget, 30000);
    expect(project.metadata['targetUnit'], 'pages');
    expect(project.metadata['pageTarget'], 120);
    expect(project.metadata['wordsPerPageEstimate'], 250);
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

  testWidgets('storyboard persists layout and can reorder scenes',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(1500, 960));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final appPreferenceRepository = InMemoryAppPreferenceRepository();
    final projectRepository = InMemoryProjectRepository();
    final chapterRepository = InMemoryChapterRepository();
    final sceneRepository = InMemorySceneRepository();
    await appPreferenceRepository.write('app.language', 'en');
    final project = await CreateProject(projectRepository)(
      const CreateProjectCommand(title: 'Storyboard Book'),
    );
    final chapterOne = await CreateChapter(chapterRepository)(
      CreateChapterCommand(
        projectId: project.id,
        title: 'Act One',
        orderIndex: 1,
      ),
    );
    final chapterTwo = await CreateChapter(chapterRepository)(
      CreateChapterCommand(
        projectId: project.id,
        title: 'Act Two',
        orderIndex: 2,
      ),
    );
    final opening = await CreateScene(sceneRepository)(
      CreateSceneCommand(
        projectId: project.id,
        chapterId: chapterOne.id,
        title: 'Opening',
        orderIndex: 1000,
      ),
    );
    final second = await CreateScene(sceneRepository)(
      CreateSceneCommand(
        projectId: project.id,
        chapterId: chapterTwo.id,
        title: 'Second',
        orderIndex: 2000,
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

    await tapNavigationItem(tester, 'Storyboard');
    await tester.drag(find.text('Opening').first, const Offset(90, 40));
    await tester.pump(const Duration(milliseconds: 700));

    await tester.tap(find.text('Connect'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Opening').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Second').first);
    await tester.pump(const Duration(milliseconds: 700));

    final savedProject = await projectRepository.findById(project.id);
    final storyboard = savedProject?.metadata['storyboard'] as Map?;
    final positions = storyboard?['positions'] as Map?;
    final connections = storyboard?['connections'] as List?;
    final timeline = storyboard?['timeline'] as List?;
    final expectedConnection = ['scene:${opening.id}', 'scene:${second.id}']
      ..sort();
    expect(positions?.containsKey('scene:${opening.id}'), isTrue);
    expect(
      connections,
      contains('${expectedConnection.first}|${expectedConnection.last}'),
    );
    expect(
        timeline, containsAll(['scene:${opening.id}', 'scene:${second.id}']));

    final sourceCenter = tester.getCenter(find.text('Second').last);
    final targetCenter = tester.getCenter(find.text('Opening').last);
    final gesture = await tester.startGesture(sourceCenter);
    await tester.pump(const Duration(milliseconds: 650));
    await gesture.moveTo(targetCenter);
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();

    final moved = await sceneRepository.findById(second.id);
    expect(moved?.chapterId, chapterOne.id);
    expect(moved!.orderIndex, lessThan(opening.orderIndex));
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

  testWidgets('full manuscript mode edits scenes without flattening structure',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(1400, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final appPreferenceRepository = InMemoryAppPreferenceRepository();
    final projectRepository = InMemoryProjectRepository();
    final chapterRepository = InMemoryChapterRepository();
    final sceneRepository = InMemorySceneRepository();
    await appPreferenceRepository.write('app.language', 'en');

    final project = await CreateProject(projectRepository)(
      const CreateProjectCommand(title: 'Continuous Book'),
    );
    final chapter = await CreateChapter(chapterRepository)(
      CreateChapterCommand(
        projectId: project.id,
        title: 'Chapter Flow',
        orderIndex: 1,
      ),
    );
    final firstScene = await CreateScene(sceneRepository)(
      CreateSceneCommand(
        projectId: project.id,
        chapterId: chapter.id,
        title: 'First Beat',
      ),
    );
    final secondScene = await CreateScene(sceneRepository)(
      CreateSceneCommand(
        projectId: project.id,
        chapterId: chapter.id,
        title: 'Second Beat',
        orderIndex: 2,
      ),
    );
    await sceneRepository.save(
      firstScene.copyWith(manuscriptText: 'Alpha opening.'),
    );
    await sceneRepository.save(
      secondScene.copyWith(manuscriptText: 'Beta turn.'),
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

    await tester.tap(find.text('Editor').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Full manuscript'));
    await tester.pumpAndSettle();

    expect(find.text('Chapter Flow'), findsWidgets);
    expect(find.text('First Beat'), findsOneWidget);
    expect(find.text('Second Beat'), findsOneWidget);

    await tester.enterText(
      find.byKey(ValueKey('full-manuscript-field-${firstScene.id}')),
      'Alpha opening.\nA new line in the same scene.',
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save changes'));
    await tester.pumpAndSettle();

    final updatedFirst = await sceneRepository.findById(firstScene.id);
    final updatedSecond = await sceneRepository.findById(secondScene.id);
    expect(
      updatedFirst?.manuscriptText,
      'Alpha opening.\nA new line in the same scene.',
    );
    expect(updatedFirst?.chapterId, chapter.id);
    expect(updatedSecond?.manuscriptText, 'Beta turn.');
    expect(updatedSecond?.chapterId, chapter.id);
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
