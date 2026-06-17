import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

@DataClassName('ProjectRow')
class Projects extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get description => text().withDefault(const Constant(''))();
  TextColumn get projectType => text()();
  TextColumn get languageCode => text()();
  TextColumn get status => text()();
  IntColumn get wordTarget => integer().nullable()();
  BoolColumn get aiEnabled => boolean()();
  BoolColumn get cloudSyncEnabled => boolean()();
  BoolColumn get noAiNoCloud => boolean()();
  TextColumn get metadataJson => text().withDefault(const Constant('{}'))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('ChapterRow')
class Chapters extends Table {
  TextColumn get id => text()();
  TextColumn get projectId => text().references(Projects, #id)();
  TextColumn get partId => text().nullable()();
  TextColumn get title => text()();
  TextColumn get summary => text().withDefault(const Constant(''))();
  RealColumn get orderIndex => real()();
  TextColumn get status => text()();
  TextColumn get metadataJson => text().withDefault(const Constant('{}'))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('SceneRow')
class Scenes extends Table {
  TextColumn get id => text()();
  TextColumn get projectId => text().references(Projects, #id)();
  TextColumn get chapterId => text().nullable()();
  TextColumn get parentSceneId => text().nullable()();
  TextColumn get title => text()();
  TextColumn get summary => text().withDefault(const Constant(''))();
  TextColumn get manuscriptText => text().withDefault(const Constant(''))();
  TextColumn get authorIntent => text().withDefault(const Constant(''))();
  TextColumn get povCharacterId => text().nullable()();
  TextColumn get sceneType => text().withDefault(const Constant('scene'))();
  TextColumn get status => text()();
  RealColumn get orderIndex => real()();
  DateTimeColumn get storyDateStart => dateTime().nullable()();
  DateTimeColumn get storyDateEnd => dateTime().nullable()();
  IntColumn get estimatedWordTarget => integer().nullable()();
  IntColumn get actualWordCount => integer().withDefault(const Constant(0))();
  IntColumn get tensionLevel => integer().nullable()();
  TextColumn get emotionalTone => text().nullable()();
  TextColumn get goal => text().nullable()();
  TextColumn get conflict => text().nullable()();
  TextColumn get outcome => text().nullable()();
  BoolColumn get aiAssistAllowed => boolean()();
  TextColumn get metadataJson => text().withDefault(const Constant('{}'))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('CatalogItemRow')
class CatalogItems extends Table {
  TextColumn get id => text()();
  TextColumn get projectId => text().references(Projects, #id)();
  TextColumn get type => text()();
  TextColumn get name => text()();
  TextColumn get summary => text().withDefault(const Constant(''))();
  TextColumn get status => text()();
  TextColumn get fieldsJson => text().withDefault(const Constant('{}'))();
  TextColumn get metadataJson => text().withDefault(const Constant('{}'))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('RelationshipRow')
class Relationships extends Table {
  TextColumn get id => text()();
  TextColumn get projectId => text().references(Projects, #id)();
  TextColumn get sourceType => text()();
  TextColumn get sourceId => text()();
  TextColumn get targetType => text()();
  TextColumn get targetId => text()();
  TextColumn get relationshipType => text()();
  TextColumn get label => text().nullable()();
  TextColumn get description => text().nullable()();
  RealColumn get strength => real().nullable()();
  TextColumn get direction => text()();
  DateTimeColumn get validFromStoryTime => dateTime().nullable()();
  DateTimeColumn get validToStoryTime => dateTime().nullable()();
  TextColumn get metadataJson => text().withDefault(const Constant('{}'))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('AISuggestionRow')
class AISuggestions extends Table {
  TextColumn get id => text()();
  TextColumn get projectId => text().references(Projects, #id)();
  TextColumn get targetType => text()();
  TextColumn get targetId => text()();
  TextColumn get suggestionType => text()();
  TextColumn get inputContextHash => text()();
  TextColumn get providerId => text()();
  TextColumn get modelName => text()();
  TextColumn get promptTemplateId => text().nullable()();
  TextColumn get promptText => text()();
  TextColumn get responseText => text()();
  TextColumn get structuredResponseJson => text().nullable()();
  TextColumn get userDecision => text()();
  TextColumn get acceptedPatchJson => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('ProjectNoteRow')
class ProjectNotes extends Table {
  TextColumn get id => text()();
  TextColumn get projectId => text().references(Projects, #id)();
  TextColumn get targetType => text().nullable()();
  TextColumn get targetId => text().nullable()();
  TextColumn get title => text()();
  TextColumn get body => text()();
  TextColumn get source => text().withDefault(const Constant('manual'))();
  TextColumn get sourceSuggestionId => text().nullable()();
  TextColumn get metadataJson => text().withDefault(const Constant('{}'))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('AIProviderConfigRow')
class AIProviderConfigs extends Table {
  TextColumn get id => text()();
  TextColumn get kind => text()();
  TextColumn get displayName => text()();
  TextColumn get modelName => text()();
  TextColumn get baseUrl => text().nullable()();
  TextColumn get encryptedApiKeyRef => text().nullable()();
  TextColumn get parametersJson => text().withDefault(const Constant('{}'))();
  BoolColumn get enabled => boolean()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('MetricEventRow')
class MetricEvents extends Table {
  TextColumn get id => text()();
  TextColumn get projectId => text().references(Projects, #id)();
  TextColumn get eventType => text()();
  RealColumn get value => real().nullable()();
  TextColumn get metadataJson => text().withDefault(const Constant('{}'))();
  DateTimeColumn get occurredAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DriftDatabase(
  tables: [
    Projects,
    Chapters,
    Scenes,
    CatalogItems,
    Relationships,
    AISuggestions,
    ProjectNotes,
    AIProviderConfigs,
    MetricEvents,
  ],
)
final class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(
          executor ??
              driftDatabase(
                name: 'writeler',
                web: DriftWebOptions(
                  sqlite3Wasm: Uri.parse('sqlite3.wasm'),
                  driftWorker: Uri.parse('drift_worker.js'),
                ),
              ),
        );

  @override
  int get schemaVersion => 7;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (migrator) async {
          await migrator.createAll();
        },
        onUpgrade: (migrator, from, to) async {
          if (from < 2) {
            await migrator.createTable(catalogItems);
            await migrator.createTable(aISuggestions);
          }
          if (from < 3) {
            await migrator.createTable(aIProviderConfigs);
          }
          if (from < 4) {
            await migrator.createTable(chapters);
          }
          if (from < 5) {
            await migrator.createTable(relationships);
          }
          if (from < 6) {
            await migrator.createTable(metricEvents);
          }
          if (from < 7) {
            await migrator.createTable(projectNotes);
          }
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );
}
