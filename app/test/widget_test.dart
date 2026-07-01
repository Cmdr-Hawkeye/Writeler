import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:writeller/core/domain/draft_status.dart';
import 'package:writeller/core/domain/entity_ref.dart';
import 'package:writeller/core/domain/entity_type.dart';
import 'package:writeller/features/ai_harness/domain/ai_suggestion.dart';
import 'package:writeller/features/ai_harness/infrastructure/in_memory_ai_suggestion_repository.dart';
import 'package:writeller/features/catalog/application/create_catalog_item.dart';
import 'package:writeller/features/catalog/domain/relationship.dart';
import 'package:writeller/features/catalog/infrastructure/in_memory_catalog_item_repository.dart';
import 'package:writeller/features/catalog/infrastructure/in_memory_relationship_repository.dart';
import 'package:writeller/features/metrics/application/in_memory_metric_repository.dart';
import 'package:writeller/features/notes/domain/project_note.dart';
import 'package:writeller/features/notes/infrastructure/in_memory_project_note_repository.dart';
import 'package:writeller/features/projects/application/create_project.dart';
import 'package:writeller/features/research/infrastructure/in_memory_research_item_repository.dart';
import 'package:writeller/features/projects/infrastructure/in_memory_project_repository.dart';
import 'package:writeller/features/settings/infrastructure/in_memory_ai_provider_config_repository.dart';
import 'package:writeller/features/settings/infrastructure/in_memory_app_preference_repository.dart';
import 'package:writeller/features/settings/infrastructure/in_memory_secret_vault.dart';
import 'package:writeller/features/structure/application/create_chapter.dart';
import 'package:writeller/features/structure/application/create_scene.dart';
import 'package:writeller/features/structure/application/in_memory_chapter_repository.dart';
import 'package:writeller/features/structure/application/in_memory_scene_repository.dart';
import 'package:writeller/features/structure/application/in_memory_scene_snapshot_repository.dart';
import 'package:writeller/main.dart';

Future<void> tapNavigationItem(WidgetTester tester, String label) async {
  final finder = find.text(label).first;
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Writeller shell shows core workspace navigation',
      (tester) async {
    final appPreferenceRepository = InMemoryAppPreferenceRepository();
    await appPreferenceRepository.write('app.language', 'en');

    await tester.pumpWidget(
      WritellerApp(
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

    expect(find.text('writeller'), findsOneWidget);
    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Editor'), findsOneWidget);
    expect(find.text('Project structure'), findsOneWidget);
    expect(find.text('Notes'), findsOneWidget);
    expect(find.text('AI Workshop'), findsOneWidget);
    expect(find.text('Logs'), findsOneWidget);
    expect(find.text('Self-publishing'), findsOneWidget);
    expect(find.byTooltip('New Project'), findsOneWidget);
    expect(find.byType(Switch), findsOneWidget);
  });

  testWidgets('new project action appears in the top bar project menu',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final appPreferenceRepository = InMemoryAppPreferenceRepository();
    await appPreferenceRepository.write('app.language', 'en');

    await tester.pumpWidget(
      WritellerApp(
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
    await tester.tap(find.text('Draft Atlas').first);
    await tester.pumpAndSettle();
    expect(find.text('Novel'), findsOneWidget);
    await tester.tapAt(const Offset(20, 20));
    await tester.pumpAndSettle();
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
      WritellerApp(
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
      WritellerApp(
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
      WritellerApp(
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
      WritellerApp(
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
      WritellerApp(
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
      WritellerApp(
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
      WritellerApp(
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
    expect(find.text('1 · Opening'), findsOneWidget);
    expect(find.text('2 · Second'), findsOneWidget);
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

  testWidgets('smart collections show dynamic saved project views',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(1400, 950));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final appPreferenceRepository = InMemoryAppPreferenceRepository();
    final projectRepository = InMemoryProjectRepository();
    final chapterRepository = InMemoryChapterRepository();
    final sceneRepository = InMemorySceneRepository();
    final catalogRepository = InMemoryCatalogItemRepository();
    final suggestionRepository = InMemoryAISuggestionRepository();
    final noteRepository = InMemoryProjectNoteRepository();
    await appPreferenceRepository.write('app.language', 'en');

    final project = await CreateProject(projectRepository)(
      const CreateProjectCommand(title: 'Collections Book'),
    );
    final chapter = await CreateChapter(chapterRepository)(
      CreateChapterCommand(projectId: project.id, title: 'Act One'),
    );
    final emptyScene = await CreateScene(sceneRepository)(
      CreateSceneCommand(
        projectId: project.id,
        chapterId: chapter.id,
        title: 'Opening Empty',
      ),
    );
    final character = await CreateCatalogItem(catalogRepository)(
      CreateCatalogItemCommand(
        projectId: project.id,
        type: EntityType.character,
        name: 'Mara',
      ),
    );
    await sceneRepository.save(
      emptyScene.copyWith(
        povCharacterId: character.id,
        goal: 'Find the signal',
        conflict: '',
        outcome: 'The door opens',
      ),
    );
    final now = DateTime.now().toUtc();
    await suggestionRepository.save(
      AISuggestion(
        id: 'suggestion-1',
        projectId: project.id,
        target: EntityRef(type: EntityType.scene, id: emptyScene.id),
        suggestionType: 'sceneIdeas',
        inputContextHash: 'hash',
        providerId: 'mock',
        modelName: 'mock',
        promptText: 'Suggest a scene.',
        responseText: 'Give Mara a sharper choice.',
        userDecision: SuggestionDecision.pending,
        createdAt: now,
      ),
    );
    await noteRepository.save(
      ProjectNote(
        id: 'note-1',
        projectId: project.id,
        title: 'Loose thought',
        body: 'Could become a subplot.',
        source: 'manual',
        createdAt: now,
        updatedAt: now,
      ),
    );

    await tester.pumpWidget(
      WritellerApp(
        projectRepository: projectRepository,
        chapterRepository: chapterRepository,
        sceneRepository: sceneRepository,
        sceneSnapshotRepository: InMemorySceneSnapshotRepository(),
        catalogItemRepository: catalogRepository,
        relationshipRepository: InMemoryRelationshipRepository(),
        metricRepository: InMemoryMetricRepository(),
        aiSuggestionRepository: suggestionRepository,
        projectNoteRepository: noteRepository,
        aiProviderConfigRepository: InMemoryAIProviderConfigRepository(),
        appPreferenceRepository: appPreferenceRepository,
        secretVault: InMemorySecretVault(),
      ),
    );
    await tester.pumpAndSettle();

    await tapNavigationItem(tester, 'Smart Collections');
    await tester.pumpAndSettle();

    expect(find.text('Open AI suggestions'), findsWidgets);
    expect(find.text('Scenes without text'), findsOneWidget);
    expect(find.text('Chapters with low conflict'), findsOneWidget);
    expect(find.text('Notes without target'), findsOneWidget);
    expect(find.text('POV Mara'), findsOneWidget);
    expect(find.text('Opening Empty'), findsWidgets);

    await tester.tap(find.text('Notes without target').first);
    await tester.pumpAndSettle();
    expect(find.text('Loose thought'), findsOneWidget);
  });

  testWidgets('AI workshop opens with actionable project context',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final appPreferenceRepository = InMemoryAppPreferenceRepository();
    final projectRepository = InMemoryProjectRepository();
    final catalogRepository = InMemoryCatalogItemRepository();
    final relationshipRepository = InMemoryRelationshipRepository();
    await appPreferenceRepository.write('app.language', 'en');
    final project = await CreateProject(projectRepository)(
      const CreateProjectCommand(title: 'AI Draft'),
    );
    final character = await CreateCatalogItem(catalogRepository)(
      CreateCatalogItemCommand(
        projectId: project.id,
        type: EntityType.character,
        name: 'Mara',
        summary: 'Engineer with a careful eye for weak signals.',
      ),
    );
    await relationshipRepository.save(
      Relationship(
        id: 'relationship-1',
        projectId: project.id,
        source: EntityRef(type: EntityType.character, id: character.id),
        target: EntityRef(type: EntityType.project, id: project.id),
        relationshipType: 'coreCast',
        label: 'core cast',
        description: 'Mara carries the technical mystery.',
        direction: RelationshipDirection.directed,
        createdAt: DateTime.utc(2026),
        updatedAt: DateTime.utc(2026),
      ),
    );

    await tester.pumpWidget(
      WritellerApp(
        projectRepository: projectRepository,
        chapterRepository: InMemoryChapterRepository(),
        sceneRepository: InMemorySceneRepository(),
        sceneSnapshotRepository: InMemorySceneSnapshotRepository(),
        catalogItemRepository: catalogRepository,
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

    await tapNavigationItem(tester, 'AI Workshop');

    expect(find.text('Overview'), findsWidgets);
    expect(find.text('How the AI workshop works'), findsOneWidget);
    await tester.tap(find.widgetWithText(Tab, 'Context'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Project-wide'), findsWidgets);
    expect(find.text('Additional AI context'), findsOneWidget);

    await tester.tap(find.text('Additional AI context'));
    await tester.pumpAndSettle();
    expect(find.text('Characters'), findsWidgets);
    expect(find.text('Mara'), findsWidgets);

    await tester.tap(find.text('Mara'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(Tab, 'Prompt & Send'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Exact prompt sent to the LLM'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Additional selected context'), findsOneWidget);
    expect(find.textContaining('Character: Mara'), findsOneWidget);

    final sendButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Send task'),
    );
    expect(sendButton.onPressed, isNotNull);

    await tester.ensureVisible(find.widgetWithText(FilledButton, 'Send task'));
    await tester.tap(find.widgetWithText(FilledButton, 'Send task'));
    await tester.pumpAndSettle();

    await tester.drag(find.byType(ListView).first, const Offset(0, -520));
    await tester.pumpAndSettle();

    expect(find.text('AI inbox'), findsOneWidget);
    expect(find.text('Open'), findsWidgets);
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
      WritellerApp(
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
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    final savedScene = (await sceneRepository.listByProject(project.id)).single;
    expect(savedScene.manuscriptText, 'Plain words**text**');

    expect(find.text('Scene meta'), findsOneWidget);
    expect(find.byKey(const ValueKey('editor-panel-planning')), findsOneWidget);
    expect(find.byKey(const ValueKey('editor-panel-context')), findsOneWidget);
    expect(find.byKey(const ValueKey('editor-panel-research')), findsOneWidget);
    expect(find.byKey(const ValueKey('editor-panel-ai')), findsOneWidget);

    final contextPanelTab = find.byKey(const ValueKey('editor-panel-context'));
    await tester.ensureVisible(contextPanelTab);
    await tester.tap(contextPanelTab);
    await tester.pumpAndSettle();
    expect(find.text('Scene context'), findsOneWidget);

    final addSceneContextButton =
        find.byKey(const ValueKey('new-scene-context-menu'));
    await tester.ensureVisible(addSceneContextButton);
    await tester.tap(addSceneContextButton);
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

    await tester.ensureVisible(addSceneContextButton);
    await tester.tap(addSceneContextButton);
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
      find.byKey(const ValueKey('scene-inspector-compact-context')),
      const Offset(0, 1400),
    );
    await tester.pumpAndSettle();
    final aiPanelTab = find.byKey(const ValueKey('editor-panel-ai'));
    await tester.ensureVisible(aiPanelTab);
    await tester.tap(aiPanelTab);
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
      WritellerApp(
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
      WritellerApp(
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

  testWidgets('relationship graph renders connected entities', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final appPreferenceRepository = InMemoryAppPreferenceRepository();
    final projectRepository = InMemoryProjectRepository();
    final catalogRepository = InMemoryCatalogItemRepository();
    final relationshipRepository = InMemoryRelationshipRepository();
    await appPreferenceRepository.write('app.language', 'en');

    final project = await CreateProject(projectRepository)(
      const CreateProjectCommand(title: 'Graph Book'),
    );
    final character = await CreateCatalogItem(catalogRepository)(
      CreateCatalogItemCommand(
        projectId: project.id,
        type: EntityType.character,
        name: 'Mara',
      ),
    );
    final location = await CreateCatalogItem(catalogRepository)(
      CreateCatalogItemCommand(
        projectId: project.id,
        type: EntityType.location,
        name: 'Orbital Gym',
      ),
    );
    await relationshipRepository.save(
      Relationship(
        id: 'relationship-graph-1',
        projectId: project.id,
        source: EntityRef(type: EntityType.character, id: character.id),
        target: EntityRef(type: EntityType.location, id: location.id),
        relationshipType: 'locatedAt',
        label: 'trains at',
        description: 'Mara uses the gym as a quiet calibration room.',
        strength: 0.8,
        direction: RelationshipDirection.directed,
        createdAt: DateTime.utc(2026),
        updatedAt: DateTime.utc(2026),
      ),
    );

    await tester.pumpWidget(
      WritellerApp(
        projectRepository: projectRepository,
        chapterRepository: InMemoryChapterRepository(),
        sceneRepository: InMemorySceneRepository(),
        sceneSnapshotRepository: InMemorySceneSnapshotRepository(),
        catalogItemRepository: catalogRepository,
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

    await tapNavigationItem(tester, 'Relationship graph');

    expect(find.text('Relationship details'), findsOneWidget);
    expect(find.text('Mara'), findsWidgets);
    expect(find.text('Orbital Gym'), findsWidgets);
    expect(find.text('trains at'), findsWidgets);
    expect(find.byType(CustomPaint), findsWidgets);
  });

  testWidgets('top bar language switch updates workspace copy', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final appPreferenceRepository = InMemoryAppPreferenceRepository();
    await appPreferenceRepository.write('app.language', 'en');

    await tester.pumpWidget(
      WritellerApp(
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
      WritellerApp(
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

    expect(find.text('Work profile'), findsWidgets);
    expect(find.text('Spelling & dictionaries'), findsWidgets);
    await tester.tap(find.text('Provider configuration').first);
    await tester.pumpAndSettle();
    expect(find.text('Provider configuration'), findsWidgets);
    expect(find.text('Context and model-training notice'), findsOneWidget);

    await tapNavigationItem(tester, 'Export/Import');

    expect(find.text('Drop file here'), findsOneWidget);
    expect(find.text('Choose import file'), findsOneWidget);
  });

  testWidgets('settings convert project target between words and pages',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final appPreferenceRepository = InMemoryAppPreferenceRepository();
    await appPreferenceRepository.write('app.language', 'en');
    final projectRepository = InMemoryProjectRepository();
    await CreateProject(projectRepository)(
      const CreateProjectCommand(
        title: 'Target Conversion',
        wordTarget: 30000,
      ),
    );

    await tester.pumpWidget(
      WritellerApp(
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

    await tapNavigationItem(tester, 'Settings');
    await tester.tap(find.text('Project details').first);
    await tester.pumpAndSettle();

    expect(find.text('Project details'), findsWidgets);
    expect(find.text('30000'), findsOneWidget);

    await tester.tap(find.text('Pages').last);
    await tester.pumpAndSettle();

    expect(find.text('120'), findsOneWidget);

    await tester.tap(find.text('Save project details'));
    await tester.pumpAndSettle();

    final saved = (await projectRepository.listActive()).single;
    expect(saved.wordTarget, 30000);
    expect(saved.metadata['targetUnit'], 'pages');
    expect(saved.metadata['pageTarget'], 120);
  });

  testWidgets('settings store global work profile preferences', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final appPreferenceRepository = InMemoryAppPreferenceRepository();
    await appPreferenceRepository.write('app.language', 'en');

    await tester.pumpWidget(
      WritellerApp(
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
    await tester.tap(find.text('Work profile').first);
    await tester.pumpAndSettle();

    expect(find.text('Work profile'), findsWidgets);
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
      WritellerApp(
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
    final context = tester.element(find.text('writeller'));

    expect(
      Theme.of(context).colorScheme.primary,
      const Color(0xFF8FC4FF),
    );
  });
}
