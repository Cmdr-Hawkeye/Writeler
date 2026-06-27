import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:writeler/core/domain/draft_status.dart';
import 'package:writeler/core/domain/entity_ref.dart';
import 'package:writeler/core/domain/entity_type.dart';
import 'package:writeler/core/infrastructure/database/app_database.dart';
import 'package:writeler/features/catalog/domain/relationship.dart';
import 'package:writeler/features/catalog/infrastructure/drift_relationship_repository.dart';
import 'package:writeler/features/metrics/application/record_metric.dart';
import 'package:writeler/features/metrics/infrastructure/drift_metric_repository.dart';
import 'package:writeler/features/notes/domain/project_note.dart';
import 'package:writeler/features/notes/infrastructure/drift_project_note_repository.dart';
import 'package:writeler/features/projects/application/create_project.dart';
import 'package:writeler/features/projects/infrastructure/drift_project_repository.dart';
import 'package:writeler/features/settings/domain/ai_provider_config.dart';
import 'package:writeler/features/settings/infrastructure/drift_ai_provider_config_repository.dart';
import 'package:writeler/features/settings/infrastructure/drift_app_preference_repository.dart';
import 'package:writeler/features/structure/application/create_chapter.dart';
import 'package:writeler/features/structure/application/create_scene.dart';
import 'package:writeler/features/structure/domain/scene_snapshot.dart';
import 'package:writeler/features/structure/infrastructure/drift_chapter_repository.dart';
import 'package:writeler/features/structure/infrastructure/drift_scene_repository.dart';
import 'package:writeler/features/structure/infrastructure/drift_scene_snapshot_repository.dart';

void main() {
  late AppDatabase database;
  late DriftProjectRepository projectRepository;
  late DriftChapterRepository chapterRepository;
  late DriftSceneRepository sceneRepository;
  late DriftSceneSnapshotRepository sceneSnapshotRepository;
  late DriftRelationshipRepository relationshipRepository;
  late DriftMetricRepository metricRepository;
  late DriftProjectNoteRepository noteRepository;
  late DriftAIProviderConfigRepository providerConfigRepository;
  late DriftAppPreferenceRepository appPreferenceRepository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    projectRepository = DriftProjectRepository(database);
    chapterRepository = DriftChapterRepository(database);
    sceneRepository = DriftSceneRepository(database);
    sceneSnapshotRepository = DriftSceneSnapshotRepository(database);
    relationshipRepository = DriftRelationshipRepository(database);
    metricRepository = DriftMetricRepository(database);
    noteRepository = DriftProjectNoteRepository(database);
    providerConfigRepository = DriftAIProviderConfigRepository(database);
    appPreferenceRepository = DriftAppPreferenceRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('database schema creates core local-first tables', () async {
    expect(database.schemaVersion, 9);

    final rows = await database
        .customSelect(
          "select name from sqlite_master where type = 'table' and name in ('a_i_provider_configs', 'a_i_suggestions', 'app_preferences', 'catalog_items', 'chapters', 'metric_events', 'project_notes', 'projects', 'relationships', 'scene_snapshots', 'scenes') order by name",
        )
        .get();

    expect(rows.map((row) => row.read<String>('name')).toList(), [
      'a_i_provider_configs',
      'a_i_suggestions',
      'app_preferences',
      'catalog_items',
      'chapters',
      'metric_events',
      'project_notes',
      'projects',
      'relationships',
      'scene_snapshots',
      'scenes',
    ]);
  });

  test('app preference repository persists user settings', () async {
    await appPreferenceRepository.write('design.theme', 'sapphire');

    expect(await appPreferenceRepository.read('design.theme'), 'sapphire');

    await appPreferenceRepository.write('design.theme', 'sage');

    expect(await appPreferenceRepository.read('design.theme'), 'sage');
  });

  test('project repository persists and filters active projects', () async {
    final createProject = CreateProject(projectRepository);
    final project = await createProject(
      const CreateProjectCommand(
        title: 'Persisted Novel',
        wordTarget: 90000,
      ),
    );

    final loaded = await projectRepository.findById(project.id);
    expect(loaded?.title, 'Persisted Novel');
    expect(loaded?.wordTarget, 90000);

    await projectRepository
        .save(project.copyWith(status: DraftStatus.archived));

    final activeProjects = await projectRepository.listActive();
    expect(activeProjects, isEmpty);
  });

  test('scene repository persists manuscript text and returns project order',
      () async {
    final project = await CreateProject(projectRepository)(
      const CreateProjectCommand(title: 'Structured Book'),
    );
    final createScene = CreateScene(sceneRepository);

    final laterScene = await createScene(
      CreateSceneCommand(
        projectId: project.id,
        title: 'Later Scene',
        orderIndex: 2000,
      ),
    );
    final firstScene = await createScene(
      CreateSceneCommand(
        projectId: project.id,
        title: 'First Scene',
        orderIndex: 1000,
      ),
    );

    await sceneRepository
        .save(laterScene.withAuthorText('Second in reading order.'));
    await sceneRepository
        .save(firstScene.withAuthorText('First in reading order.'));

    final scenes = await sceneRepository.listByProject(project.id);

    expect(scenes.map((scene) => scene.title).toList(),
        ['First Scene', 'Later Scene']);
    expect(scenes.first.actualWordCount, 4);
  });

  test('scene snapshot repository stores restorable scene versions', () async {
    final project = await CreateProject(projectRepository)(
      const CreateProjectCommand(title: 'Versioned Book'),
    );
    final scene = await CreateScene(sceneRepository)(
      CreateSceneCommand(projectId: project.id, title: 'First Draft'),
    );
    final version = scene
        .withAuthorText('Original paragraph.')
        .copyWith(goal: 'Find the truth');

    final snapshot = SceneSnapshot(
      id: 'snapshot-1',
      projectId: project.id,
      sceneId: scene.id,
      sceneTitle: scene.title,
      reason: SceneSnapshotReason.manual,
      scene: version,
      createdAt: DateTime.utc(2026, 1, 2, 3, 4),
    );

    await sceneSnapshotRepository.save(snapshot);

    final snapshots = await sceneSnapshotRepository.listForScene(scene.id);
    expect(snapshots, hasLength(1));
    expect(snapshots.single.scene.manuscriptText, 'Original paragraph.');
    expect(snapshots.single.scene.goal, 'Find the truth');

    final latest = await sceneSnapshotRepository.latestForScene(scene.id);
    expect(latest?.id, 'snapshot-1');
  });

  test('chapter repository persists project structure order', () async {
    final project = await CreateProject(projectRepository)(
      const CreateProjectCommand(title: 'Chaptered Book'),
    );
    final createChapter = CreateChapter(chapterRepository);

    await createChapter(
      CreateChapterCommand(
          projectId: project.id, title: 'Second', orderIndex: 2000),
    );
    await createChapter(
      CreateChapterCommand(
          projectId: project.id, title: 'First', orderIndex: 1000),
    );

    final chapters = await chapterRepository.listByProject(project.id);
    expect(
        chapters.map((chapter) => chapter.title).toList(), ['First', 'Second']);
  });

  test('provider config repository persists model configuration', () async {
    const config = AIProviderConfig(
      id: 'default',
      kind: AIProviderKind.openAICompatible,
      displayName: 'OpenAI Compatible',
      modelName: 'story-structure-model',
      baseUrl: 'https://api.example.test/v1',
      encryptedApiKeyRef: 'local-ref',
    );

    await providerConfigRepository.save(config);

    final loaded = await providerConfigRepository.findById('default');
    expect(loaded?.kind, AIProviderKind.openAICompatible);
    expect(loaded?.modelName, 'story-structure-model');
    expect(loaded?.encryptedApiKeyRef, 'local-ref');
  });

  test('relationship repository links scenes to catalog targets', () async {
    final project = await CreateProject(projectRepository)(
      const CreateProjectCommand(title: 'Linked Book'),
    );
    final scene = await CreateScene(sceneRepository)(
      CreateSceneCommand(projectId: project.id, title: 'Meeting'),
    );
    final now = DateTime.now().toUtc();
    final relationship = Relationship(
      id: 'relationship-1',
      projectId: project.id,
      source: EntityRef(type: EntityType.scene, id: scene.id),
      target: const EntityRef(type: EntityType.character, id: 'character-1'),
      relationshipType: 'appearsIn',
      direction: RelationshipDirection.directed,
      createdAt: now,
      updatedAt: now,
    );

    await relationshipRepository.save(relationship);

    final links = await relationshipRepository.listForSource(
      EntityRef(type: EntityType.scene, id: scene.id),
    );
    expect(links.single.target.id, 'character-1');

    await relationshipRepository.delete(relationship.id);
    expect(
      await relationshipRepository
          .listForSource(EntityRef(type: EntityType.scene, id: scene.id)),
      isEmpty,
    );
  });

  test('metric repository records local project events', () async {
    final project = await CreateProject(projectRepository)(
      const CreateProjectCommand(title: 'Measured Book'),
    );

    await RecordMetric(metricRepository)(
      projectId: project.id,
      eventType: 'scene.saved',
      value: 42,
      metadata: {'sceneId': 'scene-1'},
    );

    final events = await metricRepository.listForProject(project.id);
    expect(events.single.eventType, 'scene.saved');
    expect(events.single.value, 42);
    expect(events.single.metadata['sceneId'], 'scene-1');
  });

  test('project note repository persists and deletes notes', () async {
    final project = await CreateProject(projectRepository)(
      const CreateProjectCommand(title: 'Noted Book'),
    );
    final scene = await CreateScene(sceneRepository)(
      CreateSceneCommand(projectId: project.id, title: 'Noted Scene'),
    );
    final earlier = DateTime.utc(2026);
    final later = DateTime.utc(2026, 1, 2);

    await noteRepository.save(
      ProjectNote(
        id: 'note-1',
        projectId: project.id,
        target: EntityRef(type: EntityType.scene, id: scene.id),
        title: 'Scene idea',
        body: 'Raise the pressure in the middle.',
        source: 'aiSuggestion',
        sourceSuggestionId: 'suggestion-1',
        metadata: {'task': 'sceneIdeas'},
        createdAt: earlier,
        updatedAt: earlier,
      ),
    );
    await noteRepository.save(
      ProjectNote(
        id: 'note-2',
        projectId: project.id,
        title: 'Project note',
        body: 'Keep the ending quiet.',
        source: 'manual',
        createdAt: later,
        updatedAt: later,
      ),
    );

    final notes = await noteRepository.listForProject(project.id);
    expect(notes.map((note) => note.id).toList(), ['note-2', 'note-1']);
    expect(notes.last.target?.id, scene.id);
    expect(notes.last.metadata['task'], 'sceneIdeas');

    await noteRepository.delete('note-1');
    expect(
      (await noteRepository.listForProject(project.id))
          .map((note) => note.id)
          .toList(),
      ['note-2'],
    );
  });
}
