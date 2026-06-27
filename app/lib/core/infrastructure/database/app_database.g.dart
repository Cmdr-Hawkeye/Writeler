// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ProjectsTable extends Projects
    with TableInfo<$ProjectsTable, ProjectRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProjectsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _projectTypeMeta =
      const VerificationMeta('projectType');
  @override
  late final GeneratedColumn<String> projectType = GeneratedColumn<String>(
      'project_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _languageCodeMeta =
      const VerificationMeta('languageCode');
  @override
  late final GeneratedColumn<String> languageCode = GeneratedColumn<String>(
      'language_code', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _wordTargetMeta =
      const VerificationMeta('wordTarget');
  @override
  late final GeneratedColumn<int> wordTarget = GeneratedColumn<int>(
      'word_target', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _aiEnabledMeta =
      const VerificationMeta('aiEnabled');
  @override
  late final GeneratedColumn<bool> aiEnabled = GeneratedColumn<bool>(
      'ai_enabled', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("ai_enabled" IN (0, 1))'));
  static const VerificationMeta _cloudSyncEnabledMeta =
      const VerificationMeta('cloudSyncEnabled');
  @override
  late final GeneratedColumn<bool> cloudSyncEnabled = GeneratedColumn<bool>(
      'cloud_sync_enabled', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("cloud_sync_enabled" IN (0, 1))'));
  static const VerificationMeta _noAiNoCloudMeta =
      const VerificationMeta('noAiNoCloud');
  @override
  late final GeneratedColumn<bool> noAiNoCloud = GeneratedColumn<bool>(
      'no_ai_no_cloud', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("no_ai_no_cloud" IN (0, 1))'));
  static const VerificationMeta _metadataJsonMeta =
      const VerificationMeta('metadataJson');
  @override
  late final GeneratedColumn<String> metadataJson = GeneratedColumn<String>(
      'metadata_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('{}'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        title,
        description,
        projectType,
        languageCode,
        status,
        wordTarget,
        aiEnabled,
        cloudSyncEnabled,
        noAiNoCloud,
        metadataJson,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'projects';
  @override
  VerificationContext validateIntegrity(Insertable<ProjectRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('project_type')) {
      context.handle(
          _projectTypeMeta,
          projectType.isAcceptableOrUnknown(
              data['project_type']!, _projectTypeMeta));
    } else if (isInserting) {
      context.missing(_projectTypeMeta);
    }
    if (data.containsKey('language_code')) {
      context.handle(
          _languageCodeMeta,
          languageCode.isAcceptableOrUnknown(
              data['language_code']!, _languageCodeMeta));
    } else if (isInserting) {
      context.missing(_languageCodeMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('word_target')) {
      context.handle(
          _wordTargetMeta,
          wordTarget.isAcceptableOrUnknown(
              data['word_target']!, _wordTargetMeta));
    }
    if (data.containsKey('ai_enabled')) {
      context.handle(_aiEnabledMeta,
          aiEnabled.isAcceptableOrUnknown(data['ai_enabled']!, _aiEnabledMeta));
    } else if (isInserting) {
      context.missing(_aiEnabledMeta);
    }
    if (data.containsKey('cloud_sync_enabled')) {
      context.handle(
          _cloudSyncEnabledMeta,
          cloudSyncEnabled.isAcceptableOrUnknown(
              data['cloud_sync_enabled']!, _cloudSyncEnabledMeta));
    } else if (isInserting) {
      context.missing(_cloudSyncEnabledMeta);
    }
    if (data.containsKey('no_ai_no_cloud')) {
      context.handle(
          _noAiNoCloudMeta,
          noAiNoCloud.isAcceptableOrUnknown(
              data['no_ai_no_cloud']!, _noAiNoCloudMeta));
    } else if (isInserting) {
      context.missing(_noAiNoCloudMeta);
    }
    if (data.containsKey('metadata_json')) {
      context.handle(
          _metadataJsonMeta,
          metadataJson.isAcceptableOrUnknown(
              data['metadata_json']!, _metadataJsonMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProjectRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProjectRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      projectType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}project_type'])!,
      languageCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}language_code'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      wordTarget: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}word_target']),
      aiEnabled: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}ai_enabled'])!,
      cloudSyncEnabled: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}cloud_sync_enabled'])!,
      noAiNoCloud: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}no_ai_no_cloud'])!,
      metadataJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}metadata_json'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $ProjectsTable createAlias(String alias) {
    return $ProjectsTable(attachedDatabase, alias);
  }
}

class ProjectRow extends DataClass implements Insertable<ProjectRow> {
  final String id;
  final String title;
  final String description;
  final String projectType;
  final String languageCode;
  final String status;
  final int? wordTarget;
  final bool aiEnabled;
  final bool cloudSyncEnabled;
  final bool noAiNoCloud;
  final String metadataJson;
  final DateTime createdAt;
  final DateTime updatedAt;
  const ProjectRow(
      {required this.id,
      required this.title,
      required this.description,
      required this.projectType,
      required this.languageCode,
      required this.status,
      this.wordTarget,
      required this.aiEnabled,
      required this.cloudSyncEnabled,
      required this.noAiNoCloud,
      required this.metadataJson,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    map['project_type'] = Variable<String>(projectType);
    map['language_code'] = Variable<String>(languageCode);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || wordTarget != null) {
      map['word_target'] = Variable<int>(wordTarget);
    }
    map['ai_enabled'] = Variable<bool>(aiEnabled);
    map['cloud_sync_enabled'] = Variable<bool>(cloudSyncEnabled);
    map['no_ai_no_cloud'] = Variable<bool>(noAiNoCloud);
    map['metadata_json'] = Variable<String>(metadataJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ProjectsCompanion toCompanion(bool nullToAbsent) {
    return ProjectsCompanion(
      id: Value(id),
      title: Value(title),
      description: Value(description),
      projectType: Value(projectType),
      languageCode: Value(languageCode),
      status: Value(status),
      wordTarget: wordTarget == null && nullToAbsent
          ? const Value.absent()
          : Value(wordTarget),
      aiEnabled: Value(aiEnabled),
      cloudSyncEnabled: Value(cloudSyncEnabled),
      noAiNoCloud: Value(noAiNoCloud),
      metadataJson: Value(metadataJson),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory ProjectRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProjectRow(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String>(json['description']),
      projectType: serializer.fromJson<String>(json['projectType']),
      languageCode: serializer.fromJson<String>(json['languageCode']),
      status: serializer.fromJson<String>(json['status']),
      wordTarget: serializer.fromJson<int?>(json['wordTarget']),
      aiEnabled: serializer.fromJson<bool>(json['aiEnabled']),
      cloudSyncEnabled: serializer.fromJson<bool>(json['cloudSyncEnabled']),
      noAiNoCloud: serializer.fromJson<bool>(json['noAiNoCloud']),
      metadataJson: serializer.fromJson<String>(json['metadataJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String>(description),
      'projectType': serializer.toJson<String>(projectType),
      'languageCode': serializer.toJson<String>(languageCode),
      'status': serializer.toJson<String>(status),
      'wordTarget': serializer.toJson<int?>(wordTarget),
      'aiEnabled': serializer.toJson<bool>(aiEnabled),
      'cloudSyncEnabled': serializer.toJson<bool>(cloudSyncEnabled),
      'noAiNoCloud': serializer.toJson<bool>(noAiNoCloud),
      'metadataJson': serializer.toJson<String>(metadataJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ProjectRow copyWith(
          {String? id,
          String? title,
          String? description,
          String? projectType,
          String? languageCode,
          String? status,
          Value<int?> wordTarget = const Value.absent(),
          bool? aiEnabled,
          bool? cloudSyncEnabled,
          bool? noAiNoCloud,
          String? metadataJson,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      ProjectRow(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description ?? this.description,
        projectType: projectType ?? this.projectType,
        languageCode: languageCode ?? this.languageCode,
        status: status ?? this.status,
        wordTarget: wordTarget.present ? wordTarget.value : this.wordTarget,
        aiEnabled: aiEnabled ?? this.aiEnabled,
        cloudSyncEnabled: cloudSyncEnabled ?? this.cloudSyncEnabled,
        noAiNoCloud: noAiNoCloud ?? this.noAiNoCloud,
        metadataJson: metadataJson ?? this.metadataJson,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  ProjectRow copyWithCompanion(ProjectsCompanion data) {
    return ProjectRow(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      description:
          data.description.present ? data.description.value : this.description,
      projectType:
          data.projectType.present ? data.projectType.value : this.projectType,
      languageCode: data.languageCode.present
          ? data.languageCode.value
          : this.languageCode,
      status: data.status.present ? data.status.value : this.status,
      wordTarget:
          data.wordTarget.present ? data.wordTarget.value : this.wordTarget,
      aiEnabled: data.aiEnabled.present ? data.aiEnabled.value : this.aiEnabled,
      cloudSyncEnabled: data.cloudSyncEnabled.present
          ? data.cloudSyncEnabled.value
          : this.cloudSyncEnabled,
      noAiNoCloud:
          data.noAiNoCloud.present ? data.noAiNoCloud.value : this.noAiNoCloud,
      metadataJson: data.metadataJson.present
          ? data.metadataJson.value
          : this.metadataJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProjectRow(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('projectType: $projectType, ')
          ..write('languageCode: $languageCode, ')
          ..write('status: $status, ')
          ..write('wordTarget: $wordTarget, ')
          ..write('aiEnabled: $aiEnabled, ')
          ..write('cloudSyncEnabled: $cloudSyncEnabled, ')
          ..write('noAiNoCloud: $noAiNoCloud, ')
          ..write('metadataJson: $metadataJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      title,
      description,
      projectType,
      languageCode,
      status,
      wordTarget,
      aiEnabled,
      cloudSyncEnabled,
      noAiNoCloud,
      metadataJson,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProjectRow &&
          other.id == this.id &&
          other.title == this.title &&
          other.description == this.description &&
          other.projectType == this.projectType &&
          other.languageCode == this.languageCode &&
          other.status == this.status &&
          other.wordTarget == this.wordTarget &&
          other.aiEnabled == this.aiEnabled &&
          other.cloudSyncEnabled == this.cloudSyncEnabled &&
          other.noAiNoCloud == this.noAiNoCloud &&
          other.metadataJson == this.metadataJson &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ProjectsCompanion extends UpdateCompanion<ProjectRow> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> description;
  final Value<String> projectType;
  final Value<String> languageCode;
  final Value<String> status;
  final Value<int?> wordTarget;
  final Value<bool> aiEnabled;
  final Value<bool> cloudSyncEnabled;
  final Value<bool> noAiNoCloud;
  final Value<String> metadataJson;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ProjectsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.projectType = const Value.absent(),
    this.languageCode = const Value.absent(),
    this.status = const Value.absent(),
    this.wordTarget = const Value.absent(),
    this.aiEnabled = const Value.absent(),
    this.cloudSyncEnabled = const Value.absent(),
    this.noAiNoCloud = const Value.absent(),
    this.metadataJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProjectsCompanion.insert({
    required String id,
    required String title,
    this.description = const Value.absent(),
    required String projectType,
    required String languageCode,
    required String status,
    this.wordTarget = const Value.absent(),
    required bool aiEnabled,
    required bool cloudSyncEnabled,
    required bool noAiNoCloud,
    this.metadataJson = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        title = Value(title),
        projectType = Value(projectType),
        languageCode = Value(languageCode),
        status = Value(status),
        aiEnabled = Value(aiEnabled),
        cloudSyncEnabled = Value(cloudSyncEnabled),
        noAiNoCloud = Value(noAiNoCloud),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<ProjectRow> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? projectType,
    Expression<String>? languageCode,
    Expression<String>? status,
    Expression<int>? wordTarget,
    Expression<bool>? aiEnabled,
    Expression<bool>? cloudSyncEnabled,
    Expression<bool>? noAiNoCloud,
    Expression<String>? metadataJson,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (projectType != null) 'project_type': projectType,
      if (languageCode != null) 'language_code': languageCode,
      if (status != null) 'status': status,
      if (wordTarget != null) 'word_target': wordTarget,
      if (aiEnabled != null) 'ai_enabled': aiEnabled,
      if (cloudSyncEnabled != null) 'cloud_sync_enabled': cloudSyncEnabled,
      if (noAiNoCloud != null) 'no_ai_no_cloud': noAiNoCloud,
      if (metadataJson != null) 'metadata_json': metadataJson,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProjectsCompanion copyWith(
      {Value<String>? id,
      Value<String>? title,
      Value<String>? description,
      Value<String>? projectType,
      Value<String>? languageCode,
      Value<String>? status,
      Value<int?>? wordTarget,
      Value<bool>? aiEnabled,
      Value<bool>? cloudSyncEnabled,
      Value<bool>? noAiNoCloud,
      Value<String>? metadataJson,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return ProjectsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      projectType: projectType ?? this.projectType,
      languageCode: languageCode ?? this.languageCode,
      status: status ?? this.status,
      wordTarget: wordTarget ?? this.wordTarget,
      aiEnabled: aiEnabled ?? this.aiEnabled,
      cloudSyncEnabled: cloudSyncEnabled ?? this.cloudSyncEnabled,
      noAiNoCloud: noAiNoCloud ?? this.noAiNoCloud,
      metadataJson: metadataJson ?? this.metadataJson,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (projectType.present) {
      map['project_type'] = Variable<String>(projectType.value);
    }
    if (languageCode.present) {
      map['language_code'] = Variable<String>(languageCode.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (wordTarget.present) {
      map['word_target'] = Variable<int>(wordTarget.value);
    }
    if (aiEnabled.present) {
      map['ai_enabled'] = Variable<bool>(aiEnabled.value);
    }
    if (cloudSyncEnabled.present) {
      map['cloud_sync_enabled'] = Variable<bool>(cloudSyncEnabled.value);
    }
    if (noAiNoCloud.present) {
      map['no_ai_no_cloud'] = Variable<bool>(noAiNoCloud.value);
    }
    if (metadataJson.present) {
      map['metadata_json'] = Variable<String>(metadataJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProjectsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('projectType: $projectType, ')
          ..write('languageCode: $languageCode, ')
          ..write('status: $status, ')
          ..write('wordTarget: $wordTarget, ')
          ..write('aiEnabled: $aiEnabled, ')
          ..write('cloudSyncEnabled: $cloudSyncEnabled, ')
          ..write('noAiNoCloud: $noAiNoCloud, ')
          ..write('metadataJson: $metadataJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ChaptersTable extends Chapters
    with TableInfo<$ChaptersTable, ChapterRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChaptersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _projectIdMeta =
      const VerificationMeta('projectId');
  @override
  late final GeneratedColumn<String> projectId = GeneratedColumn<String>(
      'project_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES projects (id)'));
  static const VerificationMeta _partIdMeta = const VerificationMeta('partId');
  @override
  late final GeneratedColumn<String> partId = GeneratedColumn<String>(
      'part_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _summaryMeta =
      const VerificationMeta('summary');
  @override
  late final GeneratedColumn<String> summary = GeneratedColumn<String>(
      'summary', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _orderIndexMeta =
      const VerificationMeta('orderIndex');
  @override
  late final GeneratedColumn<double> orderIndex = GeneratedColumn<double>(
      'order_index', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _metadataJsonMeta =
      const VerificationMeta('metadataJson');
  @override
  late final GeneratedColumn<String> metadataJson = GeneratedColumn<String>(
      'metadata_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('{}'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        projectId,
        partId,
        title,
        summary,
        orderIndex,
        status,
        metadataJson,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chapters';
  @override
  VerificationContext validateIntegrity(Insertable<ChapterRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('project_id')) {
      context.handle(_projectIdMeta,
          projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta));
    } else if (isInserting) {
      context.missing(_projectIdMeta);
    }
    if (data.containsKey('part_id')) {
      context.handle(_partIdMeta,
          partId.isAcceptableOrUnknown(data['part_id']!, _partIdMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('summary')) {
      context.handle(_summaryMeta,
          summary.isAcceptableOrUnknown(data['summary']!, _summaryMeta));
    }
    if (data.containsKey('order_index')) {
      context.handle(
          _orderIndexMeta,
          orderIndex.isAcceptableOrUnknown(
              data['order_index']!, _orderIndexMeta));
    } else if (isInserting) {
      context.missing(_orderIndexMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('metadata_json')) {
      context.handle(
          _metadataJsonMeta,
          metadataJson.isAcceptableOrUnknown(
              data['metadata_json']!, _metadataJsonMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChapterRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChapterRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      projectId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}project_id'])!,
      partId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}part_id']),
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      summary: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}summary'])!,
      orderIndex: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}order_index'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      metadataJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}metadata_json'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $ChaptersTable createAlias(String alias) {
    return $ChaptersTable(attachedDatabase, alias);
  }
}

class ChapterRow extends DataClass implements Insertable<ChapterRow> {
  final String id;
  final String projectId;
  final String? partId;
  final String title;
  final String summary;
  final double orderIndex;
  final String status;
  final String metadataJson;
  final DateTime createdAt;
  final DateTime updatedAt;
  const ChapterRow(
      {required this.id,
      required this.projectId,
      this.partId,
      required this.title,
      required this.summary,
      required this.orderIndex,
      required this.status,
      required this.metadataJson,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['project_id'] = Variable<String>(projectId);
    if (!nullToAbsent || partId != null) {
      map['part_id'] = Variable<String>(partId);
    }
    map['title'] = Variable<String>(title);
    map['summary'] = Variable<String>(summary);
    map['order_index'] = Variable<double>(orderIndex);
    map['status'] = Variable<String>(status);
    map['metadata_json'] = Variable<String>(metadataJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ChaptersCompanion toCompanion(bool nullToAbsent) {
    return ChaptersCompanion(
      id: Value(id),
      projectId: Value(projectId),
      partId:
          partId == null && nullToAbsent ? const Value.absent() : Value(partId),
      title: Value(title),
      summary: Value(summary),
      orderIndex: Value(orderIndex),
      status: Value(status),
      metadataJson: Value(metadataJson),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory ChapterRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChapterRow(
      id: serializer.fromJson<String>(json['id']),
      projectId: serializer.fromJson<String>(json['projectId']),
      partId: serializer.fromJson<String?>(json['partId']),
      title: serializer.fromJson<String>(json['title']),
      summary: serializer.fromJson<String>(json['summary']),
      orderIndex: serializer.fromJson<double>(json['orderIndex']),
      status: serializer.fromJson<String>(json['status']),
      metadataJson: serializer.fromJson<String>(json['metadataJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'projectId': serializer.toJson<String>(projectId),
      'partId': serializer.toJson<String?>(partId),
      'title': serializer.toJson<String>(title),
      'summary': serializer.toJson<String>(summary),
      'orderIndex': serializer.toJson<double>(orderIndex),
      'status': serializer.toJson<String>(status),
      'metadataJson': serializer.toJson<String>(metadataJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ChapterRow copyWith(
          {String? id,
          String? projectId,
          Value<String?> partId = const Value.absent(),
          String? title,
          String? summary,
          double? orderIndex,
          String? status,
          String? metadataJson,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      ChapterRow(
        id: id ?? this.id,
        projectId: projectId ?? this.projectId,
        partId: partId.present ? partId.value : this.partId,
        title: title ?? this.title,
        summary: summary ?? this.summary,
        orderIndex: orderIndex ?? this.orderIndex,
        status: status ?? this.status,
        metadataJson: metadataJson ?? this.metadataJson,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  ChapterRow copyWithCompanion(ChaptersCompanion data) {
    return ChapterRow(
      id: data.id.present ? data.id.value : this.id,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      partId: data.partId.present ? data.partId.value : this.partId,
      title: data.title.present ? data.title.value : this.title,
      summary: data.summary.present ? data.summary.value : this.summary,
      orderIndex:
          data.orderIndex.present ? data.orderIndex.value : this.orderIndex,
      status: data.status.present ? data.status.value : this.status,
      metadataJson: data.metadataJson.present
          ? data.metadataJson.value
          : this.metadataJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChapterRow(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('partId: $partId, ')
          ..write('title: $title, ')
          ..write('summary: $summary, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('status: $status, ')
          ..write('metadataJson: $metadataJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, projectId, partId, title, summary,
      orderIndex, status, metadataJson, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChapterRow &&
          other.id == this.id &&
          other.projectId == this.projectId &&
          other.partId == this.partId &&
          other.title == this.title &&
          other.summary == this.summary &&
          other.orderIndex == this.orderIndex &&
          other.status == this.status &&
          other.metadataJson == this.metadataJson &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ChaptersCompanion extends UpdateCompanion<ChapterRow> {
  final Value<String> id;
  final Value<String> projectId;
  final Value<String?> partId;
  final Value<String> title;
  final Value<String> summary;
  final Value<double> orderIndex;
  final Value<String> status;
  final Value<String> metadataJson;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ChaptersCompanion({
    this.id = const Value.absent(),
    this.projectId = const Value.absent(),
    this.partId = const Value.absent(),
    this.title = const Value.absent(),
    this.summary = const Value.absent(),
    this.orderIndex = const Value.absent(),
    this.status = const Value.absent(),
    this.metadataJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChaptersCompanion.insert({
    required String id,
    required String projectId,
    this.partId = const Value.absent(),
    required String title,
    this.summary = const Value.absent(),
    required double orderIndex,
    required String status,
    this.metadataJson = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        projectId = Value(projectId),
        title = Value(title),
        orderIndex = Value(orderIndex),
        status = Value(status),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<ChapterRow> custom({
    Expression<String>? id,
    Expression<String>? projectId,
    Expression<String>? partId,
    Expression<String>? title,
    Expression<String>? summary,
    Expression<double>? orderIndex,
    Expression<String>? status,
    Expression<String>? metadataJson,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (projectId != null) 'project_id': projectId,
      if (partId != null) 'part_id': partId,
      if (title != null) 'title': title,
      if (summary != null) 'summary': summary,
      if (orderIndex != null) 'order_index': orderIndex,
      if (status != null) 'status': status,
      if (metadataJson != null) 'metadata_json': metadataJson,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChaptersCompanion copyWith(
      {Value<String>? id,
      Value<String>? projectId,
      Value<String?>? partId,
      Value<String>? title,
      Value<String>? summary,
      Value<double>? orderIndex,
      Value<String>? status,
      Value<String>? metadataJson,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return ChaptersCompanion(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      partId: partId ?? this.partId,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      orderIndex: orderIndex ?? this.orderIndex,
      status: status ?? this.status,
      metadataJson: metadataJson ?? this.metadataJson,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<String>(projectId.value);
    }
    if (partId.present) {
      map['part_id'] = Variable<String>(partId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (summary.present) {
      map['summary'] = Variable<String>(summary.value);
    }
    if (orderIndex.present) {
      map['order_index'] = Variable<double>(orderIndex.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (metadataJson.present) {
      map['metadata_json'] = Variable<String>(metadataJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChaptersCompanion(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('partId: $partId, ')
          ..write('title: $title, ')
          ..write('summary: $summary, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('status: $status, ')
          ..write('metadataJson: $metadataJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ScenesTable extends Scenes with TableInfo<$ScenesTable, SceneRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScenesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _projectIdMeta =
      const VerificationMeta('projectId');
  @override
  late final GeneratedColumn<String> projectId = GeneratedColumn<String>(
      'project_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES projects (id)'));
  static const VerificationMeta _chapterIdMeta =
      const VerificationMeta('chapterId');
  @override
  late final GeneratedColumn<String> chapterId = GeneratedColumn<String>(
      'chapter_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _parentSceneIdMeta =
      const VerificationMeta('parentSceneId');
  @override
  late final GeneratedColumn<String> parentSceneId = GeneratedColumn<String>(
      'parent_scene_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _summaryMeta =
      const VerificationMeta('summary');
  @override
  late final GeneratedColumn<String> summary = GeneratedColumn<String>(
      'summary', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _manuscriptTextMeta =
      const VerificationMeta('manuscriptText');
  @override
  late final GeneratedColumn<String> manuscriptText = GeneratedColumn<String>(
      'manuscript_text', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _authorIntentMeta =
      const VerificationMeta('authorIntent');
  @override
  late final GeneratedColumn<String> authorIntent = GeneratedColumn<String>(
      'author_intent', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _povCharacterIdMeta =
      const VerificationMeta('povCharacterId');
  @override
  late final GeneratedColumn<String> povCharacterId = GeneratedColumn<String>(
      'pov_character_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _sceneTypeMeta =
      const VerificationMeta('sceneType');
  @override
  late final GeneratedColumn<String> sceneType = GeneratedColumn<String>(
      'scene_type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('scene'));
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _orderIndexMeta =
      const VerificationMeta('orderIndex');
  @override
  late final GeneratedColumn<double> orderIndex = GeneratedColumn<double>(
      'order_index', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _storyDateStartMeta =
      const VerificationMeta('storyDateStart');
  @override
  late final GeneratedColumn<DateTime> storyDateStart =
      GeneratedColumn<DateTime>('story_date_start', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _storyDateEndMeta =
      const VerificationMeta('storyDateEnd');
  @override
  late final GeneratedColumn<DateTime> storyDateEnd = GeneratedColumn<DateTime>(
      'story_date_end', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _estimatedWordTargetMeta =
      const VerificationMeta('estimatedWordTarget');
  @override
  late final GeneratedColumn<int> estimatedWordTarget = GeneratedColumn<int>(
      'estimated_word_target', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _actualWordCountMeta =
      const VerificationMeta('actualWordCount');
  @override
  late final GeneratedColumn<int> actualWordCount = GeneratedColumn<int>(
      'actual_word_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _tensionLevelMeta =
      const VerificationMeta('tensionLevel');
  @override
  late final GeneratedColumn<int> tensionLevel = GeneratedColumn<int>(
      'tension_level', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _emotionalToneMeta =
      const VerificationMeta('emotionalTone');
  @override
  late final GeneratedColumn<String> emotionalTone = GeneratedColumn<String>(
      'emotional_tone', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _goalMeta = const VerificationMeta('goal');
  @override
  late final GeneratedColumn<String> goal = GeneratedColumn<String>(
      'goal', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _conflictMeta =
      const VerificationMeta('conflict');
  @override
  late final GeneratedColumn<String> conflict = GeneratedColumn<String>(
      'conflict', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _outcomeMeta =
      const VerificationMeta('outcome');
  @override
  late final GeneratedColumn<String> outcome = GeneratedColumn<String>(
      'outcome', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _aiAssistAllowedMeta =
      const VerificationMeta('aiAssistAllowed');
  @override
  late final GeneratedColumn<bool> aiAssistAllowed = GeneratedColumn<bool>(
      'ai_assist_allowed', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("ai_assist_allowed" IN (0, 1))'));
  static const VerificationMeta _metadataJsonMeta =
      const VerificationMeta('metadataJson');
  @override
  late final GeneratedColumn<String> metadataJson = GeneratedColumn<String>(
      'metadata_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('{}'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        projectId,
        chapterId,
        parentSceneId,
        title,
        summary,
        manuscriptText,
        authorIntent,
        povCharacterId,
        sceneType,
        status,
        orderIndex,
        storyDateStart,
        storyDateEnd,
        estimatedWordTarget,
        actualWordCount,
        tensionLevel,
        emotionalTone,
        goal,
        conflict,
        outcome,
        aiAssistAllowed,
        metadataJson,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'scenes';
  @override
  VerificationContext validateIntegrity(Insertable<SceneRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('project_id')) {
      context.handle(_projectIdMeta,
          projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta));
    } else if (isInserting) {
      context.missing(_projectIdMeta);
    }
    if (data.containsKey('chapter_id')) {
      context.handle(_chapterIdMeta,
          chapterId.isAcceptableOrUnknown(data['chapter_id']!, _chapterIdMeta));
    }
    if (data.containsKey('parent_scene_id')) {
      context.handle(
          _parentSceneIdMeta,
          parentSceneId.isAcceptableOrUnknown(
              data['parent_scene_id']!, _parentSceneIdMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('summary')) {
      context.handle(_summaryMeta,
          summary.isAcceptableOrUnknown(data['summary']!, _summaryMeta));
    }
    if (data.containsKey('manuscript_text')) {
      context.handle(
          _manuscriptTextMeta,
          manuscriptText.isAcceptableOrUnknown(
              data['manuscript_text']!, _manuscriptTextMeta));
    }
    if (data.containsKey('author_intent')) {
      context.handle(
          _authorIntentMeta,
          authorIntent.isAcceptableOrUnknown(
              data['author_intent']!, _authorIntentMeta));
    }
    if (data.containsKey('pov_character_id')) {
      context.handle(
          _povCharacterIdMeta,
          povCharacterId.isAcceptableOrUnknown(
              data['pov_character_id']!, _povCharacterIdMeta));
    }
    if (data.containsKey('scene_type')) {
      context.handle(_sceneTypeMeta,
          sceneType.isAcceptableOrUnknown(data['scene_type']!, _sceneTypeMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('order_index')) {
      context.handle(
          _orderIndexMeta,
          orderIndex.isAcceptableOrUnknown(
              data['order_index']!, _orderIndexMeta));
    } else if (isInserting) {
      context.missing(_orderIndexMeta);
    }
    if (data.containsKey('story_date_start')) {
      context.handle(
          _storyDateStartMeta,
          storyDateStart.isAcceptableOrUnknown(
              data['story_date_start']!, _storyDateStartMeta));
    }
    if (data.containsKey('story_date_end')) {
      context.handle(
          _storyDateEndMeta,
          storyDateEnd.isAcceptableOrUnknown(
              data['story_date_end']!, _storyDateEndMeta));
    }
    if (data.containsKey('estimated_word_target')) {
      context.handle(
          _estimatedWordTargetMeta,
          estimatedWordTarget.isAcceptableOrUnknown(
              data['estimated_word_target']!, _estimatedWordTargetMeta));
    }
    if (data.containsKey('actual_word_count')) {
      context.handle(
          _actualWordCountMeta,
          actualWordCount.isAcceptableOrUnknown(
              data['actual_word_count']!, _actualWordCountMeta));
    }
    if (data.containsKey('tension_level')) {
      context.handle(
          _tensionLevelMeta,
          tensionLevel.isAcceptableOrUnknown(
              data['tension_level']!, _tensionLevelMeta));
    }
    if (data.containsKey('emotional_tone')) {
      context.handle(
          _emotionalToneMeta,
          emotionalTone.isAcceptableOrUnknown(
              data['emotional_tone']!, _emotionalToneMeta));
    }
    if (data.containsKey('goal')) {
      context.handle(
          _goalMeta, goal.isAcceptableOrUnknown(data['goal']!, _goalMeta));
    }
    if (data.containsKey('conflict')) {
      context.handle(_conflictMeta,
          conflict.isAcceptableOrUnknown(data['conflict']!, _conflictMeta));
    }
    if (data.containsKey('outcome')) {
      context.handle(_outcomeMeta,
          outcome.isAcceptableOrUnknown(data['outcome']!, _outcomeMeta));
    }
    if (data.containsKey('ai_assist_allowed')) {
      context.handle(
          _aiAssistAllowedMeta,
          aiAssistAllowed.isAcceptableOrUnknown(
              data['ai_assist_allowed']!, _aiAssistAllowedMeta));
    } else if (isInserting) {
      context.missing(_aiAssistAllowedMeta);
    }
    if (data.containsKey('metadata_json')) {
      context.handle(
          _metadataJsonMeta,
          metadataJson.isAcceptableOrUnknown(
              data['metadata_json']!, _metadataJsonMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SceneRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SceneRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      projectId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}project_id'])!,
      chapterId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}chapter_id']),
      parentSceneId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}parent_scene_id']),
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      summary: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}summary'])!,
      manuscriptText: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}manuscript_text'])!,
      authorIntent: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}author_intent'])!,
      povCharacterId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}pov_character_id']),
      sceneType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}scene_type'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      orderIndex: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}order_index'])!,
      storyDateStart: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}story_date_start']),
      storyDateEnd: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}story_date_end']),
      estimatedWordTarget: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}estimated_word_target']),
      actualWordCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}actual_word_count'])!,
      tensionLevel: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}tension_level']),
      emotionalTone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}emotional_tone']),
      goal: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}goal']),
      conflict: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}conflict']),
      outcome: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}outcome']),
      aiAssistAllowed: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}ai_assist_allowed'])!,
      metadataJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}metadata_json'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $ScenesTable createAlias(String alias) {
    return $ScenesTable(attachedDatabase, alias);
  }
}

class SceneRow extends DataClass implements Insertable<SceneRow> {
  final String id;
  final String projectId;
  final String? chapterId;
  final String? parentSceneId;
  final String title;
  final String summary;
  final String manuscriptText;
  final String authorIntent;
  final String? povCharacterId;
  final String sceneType;
  final String status;
  final double orderIndex;
  final DateTime? storyDateStart;
  final DateTime? storyDateEnd;
  final int? estimatedWordTarget;
  final int actualWordCount;
  final int? tensionLevel;
  final String? emotionalTone;
  final String? goal;
  final String? conflict;
  final String? outcome;
  final bool aiAssistAllowed;
  final String metadataJson;
  final DateTime createdAt;
  final DateTime updatedAt;
  const SceneRow(
      {required this.id,
      required this.projectId,
      this.chapterId,
      this.parentSceneId,
      required this.title,
      required this.summary,
      required this.manuscriptText,
      required this.authorIntent,
      this.povCharacterId,
      required this.sceneType,
      required this.status,
      required this.orderIndex,
      this.storyDateStart,
      this.storyDateEnd,
      this.estimatedWordTarget,
      required this.actualWordCount,
      this.tensionLevel,
      this.emotionalTone,
      this.goal,
      this.conflict,
      this.outcome,
      required this.aiAssistAllowed,
      required this.metadataJson,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['project_id'] = Variable<String>(projectId);
    if (!nullToAbsent || chapterId != null) {
      map['chapter_id'] = Variable<String>(chapterId);
    }
    if (!nullToAbsent || parentSceneId != null) {
      map['parent_scene_id'] = Variable<String>(parentSceneId);
    }
    map['title'] = Variable<String>(title);
    map['summary'] = Variable<String>(summary);
    map['manuscript_text'] = Variable<String>(manuscriptText);
    map['author_intent'] = Variable<String>(authorIntent);
    if (!nullToAbsent || povCharacterId != null) {
      map['pov_character_id'] = Variable<String>(povCharacterId);
    }
    map['scene_type'] = Variable<String>(sceneType);
    map['status'] = Variable<String>(status);
    map['order_index'] = Variable<double>(orderIndex);
    if (!nullToAbsent || storyDateStart != null) {
      map['story_date_start'] = Variable<DateTime>(storyDateStart);
    }
    if (!nullToAbsent || storyDateEnd != null) {
      map['story_date_end'] = Variable<DateTime>(storyDateEnd);
    }
    if (!nullToAbsent || estimatedWordTarget != null) {
      map['estimated_word_target'] = Variable<int>(estimatedWordTarget);
    }
    map['actual_word_count'] = Variable<int>(actualWordCount);
    if (!nullToAbsent || tensionLevel != null) {
      map['tension_level'] = Variable<int>(tensionLevel);
    }
    if (!nullToAbsent || emotionalTone != null) {
      map['emotional_tone'] = Variable<String>(emotionalTone);
    }
    if (!nullToAbsent || goal != null) {
      map['goal'] = Variable<String>(goal);
    }
    if (!nullToAbsent || conflict != null) {
      map['conflict'] = Variable<String>(conflict);
    }
    if (!nullToAbsent || outcome != null) {
      map['outcome'] = Variable<String>(outcome);
    }
    map['ai_assist_allowed'] = Variable<bool>(aiAssistAllowed);
    map['metadata_json'] = Variable<String>(metadataJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ScenesCompanion toCompanion(bool nullToAbsent) {
    return ScenesCompanion(
      id: Value(id),
      projectId: Value(projectId),
      chapterId: chapterId == null && nullToAbsent
          ? const Value.absent()
          : Value(chapterId),
      parentSceneId: parentSceneId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentSceneId),
      title: Value(title),
      summary: Value(summary),
      manuscriptText: Value(manuscriptText),
      authorIntent: Value(authorIntent),
      povCharacterId: povCharacterId == null && nullToAbsent
          ? const Value.absent()
          : Value(povCharacterId),
      sceneType: Value(sceneType),
      status: Value(status),
      orderIndex: Value(orderIndex),
      storyDateStart: storyDateStart == null && nullToAbsent
          ? const Value.absent()
          : Value(storyDateStart),
      storyDateEnd: storyDateEnd == null && nullToAbsent
          ? const Value.absent()
          : Value(storyDateEnd),
      estimatedWordTarget: estimatedWordTarget == null && nullToAbsent
          ? const Value.absent()
          : Value(estimatedWordTarget),
      actualWordCount: Value(actualWordCount),
      tensionLevel: tensionLevel == null && nullToAbsent
          ? const Value.absent()
          : Value(tensionLevel),
      emotionalTone: emotionalTone == null && nullToAbsent
          ? const Value.absent()
          : Value(emotionalTone),
      goal: goal == null && nullToAbsent ? const Value.absent() : Value(goal),
      conflict: conflict == null && nullToAbsent
          ? const Value.absent()
          : Value(conflict),
      outcome: outcome == null && nullToAbsent
          ? const Value.absent()
          : Value(outcome),
      aiAssistAllowed: Value(aiAssistAllowed),
      metadataJson: Value(metadataJson),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory SceneRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SceneRow(
      id: serializer.fromJson<String>(json['id']),
      projectId: serializer.fromJson<String>(json['projectId']),
      chapterId: serializer.fromJson<String?>(json['chapterId']),
      parentSceneId: serializer.fromJson<String?>(json['parentSceneId']),
      title: serializer.fromJson<String>(json['title']),
      summary: serializer.fromJson<String>(json['summary']),
      manuscriptText: serializer.fromJson<String>(json['manuscriptText']),
      authorIntent: serializer.fromJson<String>(json['authorIntent']),
      povCharacterId: serializer.fromJson<String?>(json['povCharacterId']),
      sceneType: serializer.fromJson<String>(json['sceneType']),
      status: serializer.fromJson<String>(json['status']),
      orderIndex: serializer.fromJson<double>(json['orderIndex']),
      storyDateStart: serializer.fromJson<DateTime?>(json['storyDateStart']),
      storyDateEnd: serializer.fromJson<DateTime?>(json['storyDateEnd']),
      estimatedWordTarget:
          serializer.fromJson<int?>(json['estimatedWordTarget']),
      actualWordCount: serializer.fromJson<int>(json['actualWordCount']),
      tensionLevel: serializer.fromJson<int?>(json['tensionLevel']),
      emotionalTone: serializer.fromJson<String?>(json['emotionalTone']),
      goal: serializer.fromJson<String?>(json['goal']),
      conflict: serializer.fromJson<String?>(json['conflict']),
      outcome: serializer.fromJson<String?>(json['outcome']),
      aiAssistAllowed: serializer.fromJson<bool>(json['aiAssistAllowed']),
      metadataJson: serializer.fromJson<String>(json['metadataJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'projectId': serializer.toJson<String>(projectId),
      'chapterId': serializer.toJson<String?>(chapterId),
      'parentSceneId': serializer.toJson<String?>(parentSceneId),
      'title': serializer.toJson<String>(title),
      'summary': serializer.toJson<String>(summary),
      'manuscriptText': serializer.toJson<String>(manuscriptText),
      'authorIntent': serializer.toJson<String>(authorIntent),
      'povCharacterId': serializer.toJson<String?>(povCharacterId),
      'sceneType': serializer.toJson<String>(sceneType),
      'status': serializer.toJson<String>(status),
      'orderIndex': serializer.toJson<double>(orderIndex),
      'storyDateStart': serializer.toJson<DateTime?>(storyDateStart),
      'storyDateEnd': serializer.toJson<DateTime?>(storyDateEnd),
      'estimatedWordTarget': serializer.toJson<int?>(estimatedWordTarget),
      'actualWordCount': serializer.toJson<int>(actualWordCount),
      'tensionLevel': serializer.toJson<int?>(tensionLevel),
      'emotionalTone': serializer.toJson<String?>(emotionalTone),
      'goal': serializer.toJson<String?>(goal),
      'conflict': serializer.toJson<String?>(conflict),
      'outcome': serializer.toJson<String?>(outcome),
      'aiAssistAllowed': serializer.toJson<bool>(aiAssistAllowed),
      'metadataJson': serializer.toJson<String>(metadataJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  SceneRow copyWith(
          {String? id,
          String? projectId,
          Value<String?> chapterId = const Value.absent(),
          Value<String?> parentSceneId = const Value.absent(),
          String? title,
          String? summary,
          String? manuscriptText,
          String? authorIntent,
          Value<String?> povCharacterId = const Value.absent(),
          String? sceneType,
          String? status,
          double? orderIndex,
          Value<DateTime?> storyDateStart = const Value.absent(),
          Value<DateTime?> storyDateEnd = const Value.absent(),
          Value<int?> estimatedWordTarget = const Value.absent(),
          int? actualWordCount,
          Value<int?> tensionLevel = const Value.absent(),
          Value<String?> emotionalTone = const Value.absent(),
          Value<String?> goal = const Value.absent(),
          Value<String?> conflict = const Value.absent(),
          Value<String?> outcome = const Value.absent(),
          bool? aiAssistAllowed,
          String? metadataJson,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      SceneRow(
        id: id ?? this.id,
        projectId: projectId ?? this.projectId,
        chapterId: chapterId.present ? chapterId.value : this.chapterId,
        parentSceneId:
            parentSceneId.present ? parentSceneId.value : this.parentSceneId,
        title: title ?? this.title,
        summary: summary ?? this.summary,
        manuscriptText: manuscriptText ?? this.manuscriptText,
        authorIntent: authorIntent ?? this.authorIntent,
        povCharacterId:
            povCharacterId.present ? povCharacterId.value : this.povCharacterId,
        sceneType: sceneType ?? this.sceneType,
        status: status ?? this.status,
        orderIndex: orderIndex ?? this.orderIndex,
        storyDateStart:
            storyDateStart.present ? storyDateStart.value : this.storyDateStart,
        storyDateEnd:
            storyDateEnd.present ? storyDateEnd.value : this.storyDateEnd,
        estimatedWordTarget: estimatedWordTarget.present
            ? estimatedWordTarget.value
            : this.estimatedWordTarget,
        actualWordCount: actualWordCount ?? this.actualWordCount,
        tensionLevel:
            tensionLevel.present ? tensionLevel.value : this.tensionLevel,
        emotionalTone:
            emotionalTone.present ? emotionalTone.value : this.emotionalTone,
        goal: goal.present ? goal.value : this.goal,
        conflict: conflict.present ? conflict.value : this.conflict,
        outcome: outcome.present ? outcome.value : this.outcome,
        aiAssistAllowed: aiAssistAllowed ?? this.aiAssistAllowed,
        metadataJson: metadataJson ?? this.metadataJson,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  SceneRow copyWithCompanion(ScenesCompanion data) {
    return SceneRow(
      id: data.id.present ? data.id.value : this.id,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      chapterId: data.chapterId.present ? data.chapterId.value : this.chapterId,
      parentSceneId: data.parentSceneId.present
          ? data.parentSceneId.value
          : this.parentSceneId,
      title: data.title.present ? data.title.value : this.title,
      summary: data.summary.present ? data.summary.value : this.summary,
      manuscriptText: data.manuscriptText.present
          ? data.manuscriptText.value
          : this.manuscriptText,
      authorIntent: data.authorIntent.present
          ? data.authorIntent.value
          : this.authorIntent,
      povCharacterId: data.povCharacterId.present
          ? data.povCharacterId.value
          : this.povCharacterId,
      sceneType: data.sceneType.present ? data.sceneType.value : this.sceneType,
      status: data.status.present ? data.status.value : this.status,
      orderIndex:
          data.orderIndex.present ? data.orderIndex.value : this.orderIndex,
      storyDateStart: data.storyDateStart.present
          ? data.storyDateStart.value
          : this.storyDateStart,
      storyDateEnd: data.storyDateEnd.present
          ? data.storyDateEnd.value
          : this.storyDateEnd,
      estimatedWordTarget: data.estimatedWordTarget.present
          ? data.estimatedWordTarget.value
          : this.estimatedWordTarget,
      actualWordCount: data.actualWordCount.present
          ? data.actualWordCount.value
          : this.actualWordCount,
      tensionLevel: data.tensionLevel.present
          ? data.tensionLevel.value
          : this.tensionLevel,
      emotionalTone: data.emotionalTone.present
          ? data.emotionalTone.value
          : this.emotionalTone,
      goal: data.goal.present ? data.goal.value : this.goal,
      conflict: data.conflict.present ? data.conflict.value : this.conflict,
      outcome: data.outcome.present ? data.outcome.value : this.outcome,
      aiAssistAllowed: data.aiAssistAllowed.present
          ? data.aiAssistAllowed.value
          : this.aiAssistAllowed,
      metadataJson: data.metadataJson.present
          ? data.metadataJson.value
          : this.metadataJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SceneRow(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('chapterId: $chapterId, ')
          ..write('parentSceneId: $parentSceneId, ')
          ..write('title: $title, ')
          ..write('summary: $summary, ')
          ..write('manuscriptText: $manuscriptText, ')
          ..write('authorIntent: $authorIntent, ')
          ..write('povCharacterId: $povCharacterId, ')
          ..write('sceneType: $sceneType, ')
          ..write('status: $status, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('storyDateStart: $storyDateStart, ')
          ..write('storyDateEnd: $storyDateEnd, ')
          ..write('estimatedWordTarget: $estimatedWordTarget, ')
          ..write('actualWordCount: $actualWordCount, ')
          ..write('tensionLevel: $tensionLevel, ')
          ..write('emotionalTone: $emotionalTone, ')
          ..write('goal: $goal, ')
          ..write('conflict: $conflict, ')
          ..write('outcome: $outcome, ')
          ..write('aiAssistAllowed: $aiAssistAllowed, ')
          ..write('metadataJson: $metadataJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        projectId,
        chapterId,
        parentSceneId,
        title,
        summary,
        manuscriptText,
        authorIntent,
        povCharacterId,
        sceneType,
        status,
        orderIndex,
        storyDateStart,
        storyDateEnd,
        estimatedWordTarget,
        actualWordCount,
        tensionLevel,
        emotionalTone,
        goal,
        conflict,
        outcome,
        aiAssistAllowed,
        metadataJson,
        createdAt,
        updatedAt
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SceneRow &&
          other.id == this.id &&
          other.projectId == this.projectId &&
          other.chapterId == this.chapterId &&
          other.parentSceneId == this.parentSceneId &&
          other.title == this.title &&
          other.summary == this.summary &&
          other.manuscriptText == this.manuscriptText &&
          other.authorIntent == this.authorIntent &&
          other.povCharacterId == this.povCharacterId &&
          other.sceneType == this.sceneType &&
          other.status == this.status &&
          other.orderIndex == this.orderIndex &&
          other.storyDateStart == this.storyDateStart &&
          other.storyDateEnd == this.storyDateEnd &&
          other.estimatedWordTarget == this.estimatedWordTarget &&
          other.actualWordCount == this.actualWordCount &&
          other.tensionLevel == this.tensionLevel &&
          other.emotionalTone == this.emotionalTone &&
          other.goal == this.goal &&
          other.conflict == this.conflict &&
          other.outcome == this.outcome &&
          other.aiAssistAllowed == this.aiAssistAllowed &&
          other.metadataJson == this.metadataJson &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ScenesCompanion extends UpdateCompanion<SceneRow> {
  final Value<String> id;
  final Value<String> projectId;
  final Value<String?> chapterId;
  final Value<String?> parentSceneId;
  final Value<String> title;
  final Value<String> summary;
  final Value<String> manuscriptText;
  final Value<String> authorIntent;
  final Value<String?> povCharacterId;
  final Value<String> sceneType;
  final Value<String> status;
  final Value<double> orderIndex;
  final Value<DateTime?> storyDateStart;
  final Value<DateTime?> storyDateEnd;
  final Value<int?> estimatedWordTarget;
  final Value<int> actualWordCount;
  final Value<int?> tensionLevel;
  final Value<String?> emotionalTone;
  final Value<String?> goal;
  final Value<String?> conflict;
  final Value<String?> outcome;
  final Value<bool> aiAssistAllowed;
  final Value<String> metadataJson;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ScenesCompanion({
    this.id = const Value.absent(),
    this.projectId = const Value.absent(),
    this.chapterId = const Value.absent(),
    this.parentSceneId = const Value.absent(),
    this.title = const Value.absent(),
    this.summary = const Value.absent(),
    this.manuscriptText = const Value.absent(),
    this.authorIntent = const Value.absent(),
    this.povCharacterId = const Value.absent(),
    this.sceneType = const Value.absent(),
    this.status = const Value.absent(),
    this.orderIndex = const Value.absent(),
    this.storyDateStart = const Value.absent(),
    this.storyDateEnd = const Value.absent(),
    this.estimatedWordTarget = const Value.absent(),
    this.actualWordCount = const Value.absent(),
    this.tensionLevel = const Value.absent(),
    this.emotionalTone = const Value.absent(),
    this.goal = const Value.absent(),
    this.conflict = const Value.absent(),
    this.outcome = const Value.absent(),
    this.aiAssistAllowed = const Value.absent(),
    this.metadataJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ScenesCompanion.insert({
    required String id,
    required String projectId,
    this.chapterId = const Value.absent(),
    this.parentSceneId = const Value.absent(),
    required String title,
    this.summary = const Value.absent(),
    this.manuscriptText = const Value.absent(),
    this.authorIntent = const Value.absent(),
    this.povCharacterId = const Value.absent(),
    this.sceneType = const Value.absent(),
    required String status,
    required double orderIndex,
    this.storyDateStart = const Value.absent(),
    this.storyDateEnd = const Value.absent(),
    this.estimatedWordTarget = const Value.absent(),
    this.actualWordCount = const Value.absent(),
    this.tensionLevel = const Value.absent(),
    this.emotionalTone = const Value.absent(),
    this.goal = const Value.absent(),
    this.conflict = const Value.absent(),
    this.outcome = const Value.absent(),
    required bool aiAssistAllowed,
    this.metadataJson = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        projectId = Value(projectId),
        title = Value(title),
        status = Value(status),
        orderIndex = Value(orderIndex),
        aiAssistAllowed = Value(aiAssistAllowed),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<SceneRow> custom({
    Expression<String>? id,
    Expression<String>? projectId,
    Expression<String>? chapterId,
    Expression<String>? parentSceneId,
    Expression<String>? title,
    Expression<String>? summary,
    Expression<String>? manuscriptText,
    Expression<String>? authorIntent,
    Expression<String>? povCharacterId,
    Expression<String>? sceneType,
    Expression<String>? status,
    Expression<double>? orderIndex,
    Expression<DateTime>? storyDateStart,
    Expression<DateTime>? storyDateEnd,
    Expression<int>? estimatedWordTarget,
    Expression<int>? actualWordCount,
    Expression<int>? tensionLevel,
    Expression<String>? emotionalTone,
    Expression<String>? goal,
    Expression<String>? conflict,
    Expression<String>? outcome,
    Expression<bool>? aiAssistAllowed,
    Expression<String>? metadataJson,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (projectId != null) 'project_id': projectId,
      if (chapterId != null) 'chapter_id': chapterId,
      if (parentSceneId != null) 'parent_scene_id': parentSceneId,
      if (title != null) 'title': title,
      if (summary != null) 'summary': summary,
      if (manuscriptText != null) 'manuscript_text': manuscriptText,
      if (authorIntent != null) 'author_intent': authorIntent,
      if (povCharacterId != null) 'pov_character_id': povCharacterId,
      if (sceneType != null) 'scene_type': sceneType,
      if (status != null) 'status': status,
      if (orderIndex != null) 'order_index': orderIndex,
      if (storyDateStart != null) 'story_date_start': storyDateStart,
      if (storyDateEnd != null) 'story_date_end': storyDateEnd,
      if (estimatedWordTarget != null)
        'estimated_word_target': estimatedWordTarget,
      if (actualWordCount != null) 'actual_word_count': actualWordCount,
      if (tensionLevel != null) 'tension_level': tensionLevel,
      if (emotionalTone != null) 'emotional_tone': emotionalTone,
      if (goal != null) 'goal': goal,
      if (conflict != null) 'conflict': conflict,
      if (outcome != null) 'outcome': outcome,
      if (aiAssistAllowed != null) 'ai_assist_allowed': aiAssistAllowed,
      if (metadataJson != null) 'metadata_json': metadataJson,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ScenesCompanion copyWith(
      {Value<String>? id,
      Value<String>? projectId,
      Value<String?>? chapterId,
      Value<String?>? parentSceneId,
      Value<String>? title,
      Value<String>? summary,
      Value<String>? manuscriptText,
      Value<String>? authorIntent,
      Value<String?>? povCharacterId,
      Value<String>? sceneType,
      Value<String>? status,
      Value<double>? orderIndex,
      Value<DateTime?>? storyDateStart,
      Value<DateTime?>? storyDateEnd,
      Value<int?>? estimatedWordTarget,
      Value<int>? actualWordCount,
      Value<int?>? tensionLevel,
      Value<String?>? emotionalTone,
      Value<String?>? goal,
      Value<String?>? conflict,
      Value<String?>? outcome,
      Value<bool>? aiAssistAllowed,
      Value<String>? metadataJson,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return ScenesCompanion(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      chapterId: chapterId ?? this.chapterId,
      parentSceneId: parentSceneId ?? this.parentSceneId,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      manuscriptText: manuscriptText ?? this.manuscriptText,
      authorIntent: authorIntent ?? this.authorIntent,
      povCharacterId: povCharacterId ?? this.povCharacterId,
      sceneType: sceneType ?? this.sceneType,
      status: status ?? this.status,
      orderIndex: orderIndex ?? this.orderIndex,
      storyDateStart: storyDateStart ?? this.storyDateStart,
      storyDateEnd: storyDateEnd ?? this.storyDateEnd,
      estimatedWordTarget: estimatedWordTarget ?? this.estimatedWordTarget,
      actualWordCount: actualWordCount ?? this.actualWordCount,
      tensionLevel: tensionLevel ?? this.tensionLevel,
      emotionalTone: emotionalTone ?? this.emotionalTone,
      goal: goal ?? this.goal,
      conflict: conflict ?? this.conflict,
      outcome: outcome ?? this.outcome,
      aiAssistAllowed: aiAssistAllowed ?? this.aiAssistAllowed,
      metadataJson: metadataJson ?? this.metadataJson,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<String>(projectId.value);
    }
    if (chapterId.present) {
      map['chapter_id'] = Variable<String>(chapterId.value);
    }
    if (parentSceneId.present) {
      map['parent_scene_id'] = Variable<String>(parentSceneId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (summary.present) {
      map['summary'] = Variable<String>(summary.value);
    }
    if (manuscriptText.present) {
      map['manuscript_text'] = Variable<String>(manuscriptText.value);
    }
    if (authorIntent.present) {
      map['author_intent'] = Variable<String>(authorIntent.value);
    }
    if (povCharacterId.present) {
      map['pov_character_id'] = Variable<String>(povCharacterId.value);
    }
    if (sceneType.present) {
      map['scene_type'] = Variable<String>(sceneType.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (orderIndex.present) {
      map['order_index'] = Variable<double>(orderIndex.value);
    }
    if (storyDateStart.present) {
      map['story_date_start'] = Variable<DateTime>(storyDateStart.value);
    }
    if (storyDateEnd.present) {
      map['story_date_end'] = Variable<DateTime>(storyDateEnd.value);
    }
    if (estimatedWordTarget.present) {
      map['estimated_word_target'] = Variable<int>(estimatedWordTarget.value);
    }
    if (actualWordCount.present) {
      map['actual_word_count'] = Variable<int>(actualWordCount.value);
    }
    if (tensionLevel.present) {
      map['tension_level'] = Variable<int>(tensionLevel.value);
    }
    if (emotionalTone.present) {
      map['emotional_tone'] = Variable<String>(emotionalTone.value);
    }
    if (goal.present) {
      map['goal'] = Variable<String>(goal.value);
    }
    if (conflict.present) {
      map['conflict'] = Variable<String>(conflict.value);
    }
    if (outcome.present) {
      map['outcome'] = Variable<String>(outcome.value);
    }
    if (aiAssistAllowed.present) {
      map['ai_assist_allowed'] = Variable<bool>(aiAssistAllowed.value);
    }
    if (metadataJson.present) {
      map['metadata_json'] = Variable<String>(metadataJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScenesCompanion(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('chapterId: $chapterId, ')
          ..write('parentSceneId: $parentSceneId, ')
          ..write('title: $title, ')
          ..write('summary: $summary, ')
          ..write('manuscriptText: $manuscriptText, ')
          ..write('authorIntent: $authorIntent, ')
          ..write('povCharacterId: $povCharacterId, ')
          ..write('sceneType: $sceneType, ')
          ..write('status: $status, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('storyDateStart: $storyDateStart, ')
          ..write('storyDateEnd: $storyDateEnd, ')
          ..write('estimatedWordTarget: $estimatedWordTarget, ')
          ..write('actualWordCount: $actualWordCount, ')
          ..write('tensionLevel: $tensionLevel, ')
          ..write('emotionalTone: $emotionalTone, ')
          ..write('goal: $goal, ')
          ..write('conflict: $conflict, ')
          ..write('outcome: $outcome, ')
          ..write('aiAssistAllowed: $aiAssistAllowed, ')
          ..write('metadataJson: $metadataJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SceneSnapshotsTable extends SceneSnapshots
    with TableInfo<$SceneSnapshotsTable, SceneSnapshotRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SceneSnapshotsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _projectIdMeta =
      const VerificationMeta('projectId');
  @override
  late final GeneratedColumn<String> projectId = GeneratedColumn<String>(
      'project_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES projects (id)'));
  static const VerificationMeta _sceneIdMeta =
      const VerificationMeta('sceneId');
  @override
  late final GeneratedColumn<String> sceneId = GeneratedColumn<String>(
      'scene_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES scenes (id)'));
  static const VerificationMeta _sceneTitleMeta =
      const VerificationMeta('sceneTitle');
  @override
  late final GeneratedColumn<String> sceneTitle = GeneratedColumn<String>(
      'scene_title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
      'label', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
      'reason', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sceneJsonMeta =
      const VerificationMeta('sceneJson');
  @override
  late final GeneratedColumn<String> sceneJson = GeneratedColumn<String>(
      'scene_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, projectId, sceneId, sceneTitle, label, reason, sceneJson, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'scene_snapshots';
  @override
  VerificationContext validateIntegrity(Insertable<SceneSnapshotRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('project_id')) {
      context.handle(_projectIdMeta,
          projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta));
    } else if (isInserting) {
      context.missing(_projectIdMeta);
    }
    if (data.containsKey('scene_id')) {
      context.handle(_sceneIdMeta,
          sceneId.isAcceptableOrUnknown(data['scene_id']!, _sceneIdMeta));
    } else if (isInserting) {
      context.missing(_sceneIdMeta);
    }
    if (data.containsKey('scene_title')) {
      context.handle(
          _sceneTitleMeta,
          sceneTitle.isAcceptableOrUnknown(
              data['scene_title']!, _sceneTitleMeta));
    } else if (isInserting) {
      context.missing(_sceneTitleMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
          _labelMeta, label.isAcceptableOrUnknown(data['label']!, _labelMeta));
    }
    if (data.containsKey('reason')) {
      context.handle(_reasonMeta,
          reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta));
    } else if (isInserting) {
      context.missing(_reasonMeta);
    }
    if (data.containsKey('scene_json')) {
      context.handle(_sceneJsonMeta,
          sceneJson.isAcceptableOrUnknown(data['scene_json']!, _sceneJsonMeta));
    } else if (isInserting) {
      context.missing(_sceneJsonMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SceneSnapshotRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SceneSnapshotRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      projectId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}project_id'])!,
      sceneId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}scene_id'])!,
      sceneTitle: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}scene_title'])!,
      label: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}label'])!,
      reason: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reason'])!,
      sceneJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}scene_json'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $SceneSnapshotsTable createAlias(String alias) {
    return $SceneSnapshotsTable(attachedDatabase, alias);
  }
}

class SceneSnapshotRow extends DataClass
    implements Insertable<SceneSnapshotRow> {
  final String id;
  final String projectId;
  final String sceneId;
  final String sceneTitle;
  final String label;
  final String reason;
  final String sceneJson;
  final DateTime createdAt;
  const SceneSnapshotRow(
      {required this.id,
      required this.projectId,
      required this.sceneId,
      required this.sceneTitle,
      required this.label,
      required this.reason,
      required this.sceneJson,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['project_id'] = Variable<String>(projectId);
    map['scene_id'] = Variable<String>(sceneId);
    map['scene_title'] = Variable<String>(sceneTitle);
    map['label'] = Variable<String>(label);
    map['reason'] = Variable<String>(reason);
    map['scene_json'] = Variable<String>(sceneJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SceneSnapshotsCompanion toCompanion(bool nullToAbsent) {
    return SceneSnapshotsCompanion(
      id: Value(id),
      projectId: Value(projectId),
      sceneId: Value(sceneId),
      sceneTitle: Value(sceneTitle),
      label: Value(label),
      reason: Value(reason),
      sceneJson: Value(sceneJson),
      createdAt: Value(createdAt),
    );
  }

  factory SceneSnapshotRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SceneSnapshotRow(
      id: serializer.fromJson<String>(json['id']),
      projectId: serializer.fromJson<String>(json['projectId']),
      sceneId: serializer.fromJson<String>(json['sceneId']),
      sceneTitle: serializer.fromJson<String>(json['sceneTitle']),
      label: serializer.fromJson<String>(json['label']),
      reason: serializer.fromJson<String>(json['reason']),
      sceneJson: serializer.fromJson<String>(json['sceneJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'projectId': serializer.toJson<String>(projectId),
      'sceneId': serializer.toJson<String>(sceneId),
      'sceneTitle': serializer.toJson<String>(sceneTitle),
      'label': serializer.toJson<String>(label),
      'reason': serializer.toJson<String>(reason),
      'sceneJson': serializer.toJson<String>(sceneJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  SceneSnapshotRow copyWith(
          {String? id,
          String? projectId,
          String? sceneId,
          String? sceneTitle,
          String? label,
          String? reason,
          String? sceneJson,
          DateTime? createdAt}) =>
      SceneSnapshotRow(
        id: id ?? this.id,
        projectId: projectId ?? this.projectId,
        sceneId: sceneId ?? this.sceneId,
        sceneTitle: sceneTitle ?? this.sceneTitle,
        label: label ?? this.label,
        reason: reason ?? this.reason,
        sceneJson: sceneJson ?? this.sceneJson,
        createdAt: createdAt ?? this.createdAt,
      );
  SceneSnapshotRow copyWithCompanion(SceneSnapshotsCompanion data) {
    return SceneSnapshotRow(
      id: data.id.present ? data.id.value : this.id,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      sceneId: data.sceneId.present ? data.sceneId.value : this.sceneId,
      sceneTitle:
          data.sceneTitle.present ? data.sceneTitle.value : this.sceneTitle,
      label: data.label.present ? data.label.value : this.label,
      reason: data.reason.present ? data.reason.value : this.reason,
      sceneJson: data.sceneJson.present ? data.sceneJson.value : this.sceneJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SceneSnapshotRow(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('sceneId: $sceneId, ')
          ..write('sceneTitle: $sceneTitle, ')
          ..write('label: $label, ')
          ..write('reason: $reason, ')
          ..write('sceneJson: $sceneJson, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, projectId, sceneId, sceneTitle, label, reason, sceneJson, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SceneSnapshotRow &&
          other.id == this.id &&
          other.projectId == this.projectId &&
          other.sceneId == this.sceneId &&
          other.sceneTitle == this.sceneTitle &&
          other.label == this.label &&
          other.reason == this.reason &&
          other.sceneJson == this.sceneJson &&
          other.createdAt == this.createdAt);
}

class SceneSnapshotsCompanion extends UpdateCompanion<SceneSnapshotRow> {
  final Value<String> id;
  final Value<String> projectId;
  final Value<String> sceneId;
  final Value<String> sceneTitle;
  final Value<String> label;
  final Value<String> reason;
  final Value<String> sceneJson;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const SceneSnapshotsCompanion({
    this.id = const Value.absent(),
    this.projectId = const Value.absent(),
    this.sceneId = const Value.absent(),
    this.sceneTitle = const Value.absent(),
    this.label = const Value.absent(),
    this.reason = const Value.absent(),
    this.sceneJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SceneSnapshotsCompanion.insert({
    required String id,
    required String projectId,
    required String sceneId,
    required String sceneTitle,
    this.label = const Value.absent(),
    required String reason,
    required String sceneJson,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        projectId = Value(projectId),
        sceneId = Value(sceneId),
        sceneTitle = Value(sceneTitle),
        reason = Value(reason),
        sceneJson = Value(sceneJson),
        createdAt = Value(createdAt);
  static Insertable<SceneSnapshotRow> custom({
    Expression<String>? id,
    Expression<String>? projectId,
    Expression<String>? sceneId,
    Expression<String>? sceneTitle,
    Expression<String>? label,
    Expression<String>? reason,
    Expression<String>? sceneJson,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (projectId != null) 'project_id': projectId,
      if (sceneId != null) 'scene_id': sceneId,
      if (sceneTitle != null) 'scene_title': sceneTitle,
      if (label != null) 'label': label,
      if (reason != null) 'reason': reason,
      if (sceneJson != null) 'scene_json': sceneJson,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SceneSnapshotsCompanion copyWith(
      {Value<String>? id,
      Value<String>? projectId,
      Value<String>? sceneId,
      Value<String>? sceneTitle,
      Value<String>? label,
      Value<String>? reason,
      Value<String>? sceneJson,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return SceneSnapshotsCompanion(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      sceneId: sceneId ?? this.sceneId,
      sceneTitle: sceneTitle ?? this.sceneTitle,
      label: label ?? this.label,
      reason: reason ?? this.reason,
      sceneJson: sceneJson ?? this.sceneJson,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<String>(projectId.value);
    }
    if (sceneId.present) {
      map['scene_id'] = Variable<String>(sceneId.value);
    }
    if (sceneTitle.present) {
      map['scene_title'] = Variable<String>(sceneTitle.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (sceneJson.present) {
      map['scene_json'] = Variable<String>(sceneJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SceneSnapshotsCompanion(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('sceneId: $sceneId, ')
          ..write('sceneTitle: $sceneTitle, ')
          ..write('label: $label, ')
          ..write('reason: $reason, ')
          ..write('sceneJson: $sceneJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CatalogItemsTable extends CatalogItems
    with TableInfo<$CatalogItemsTable, CatalogItemRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CatalogItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _projectIdMeta =
      const VerificationMeta('projectId');
  @override
  late final GeneratedColumn<String> projectId = GeneratedColumn<String>(
      'project_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES projects (id)'));
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _summaryMeta =
      const VerificationMeta('summary');
  @override
  late final GeneratedColumn<String> summary = GeneratedColumn<String>(
      'summary', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _fieldsJsonMeta =
      const VerificationMeta('fieldsJson');
  @override
  late final GeneratedColumn<String> fieldsJson = GeneratedColumn<String>(
      'fields_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('{}'));
  static const VerificationMeta _metadataJsonMeta =
      const VerificationMeta('metadataJson');
  @override
  late final GeneratedColumn<String> metadataJson = GeneratedColumn<String>(
      'metadata_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('{}'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        projectId,
        type,
        name,
        summary,
        status,
        fieldsJson,
        metadataJson,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'catalog_items';
  @override
  VerificationContext validateIntegrity(Insertable<CatalogItemRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('project_id')) {
      context.handle(_projectIdMeta,
          projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta));
    } else if (isInserting) {
      context.missing(_projectIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('summary')) {
      context.handle(_summaryMeta,
          summary.isAcceptableOrUnknown(data['summary']!, _summaryMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('fields_json')) {
      context.handle(
          _fieldsJsonMeta,
          fieldsJson.isAcceptableOrUnknown(
              data['fields_json']!, _fieldsJsonMeta));
    }
    if (data.containsKey('metadata_json')) {
      context.handle(
          _metadataJsonMeta,
          metadataJson.isAcceptableOrUnknown(
              data['metadata_json']!, _metadataJsonMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CatalogItemRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CatalogItemRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      projectId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}project_id'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      summary: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}summary'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      fieldsJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}fields_json'])!,
      metadataJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}metadata_json'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $CatalogItemsTable createAlias(String alias) {
    return $CatalogItemsTable(attachedDatabase, alias);
  }
}

class CatalogItemRow extends DataClass implements Insertable<CatalogItemRow> {
  final String id;
  final String projectId;
  final String type;
  final String name;
  final String summary;
  final String status;
  final String fieldsJson;
  final String metadataJson;
  final DateTime createdAt;
  final DateTime updatedAt;
  const CatalogItemRow(
      {required this.id,
      required this.projectId,
      required this.type,
      required this.name,
      required this.summary,
      required this.status,
      required this.fieldsJson,
      required this.metadataJson,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['project_id'] = Variable<String>(projectId);
    map['type'] = Variable<String>(type);
    map['name'] = Variable<String>(name);
    map['summary'] = Variable<String>(summary);
    map['status'] = Variable<String>(status);
    map['fields_json'] = Variable<String>(fieldsJson);
    map['metadata_json'] = Variable<String>(metadataJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CatalogItemsCompanion toCompanion(bool nullToAbsent) {
    return CatalogItemsCompanion(
      id: Value(id),
      projectId: Value(projectId),
      type: Value(type),
      name: Value(name),
      summary: Value(summary),
      status: Value(status),
      fieldsJson: Value(fieldsJson),
      metadataJson: Value(metadataJson),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory CatalogItemRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CatalogItemRow(
      id: serializer.fromJson<String>(json['id']),
      projectId: serializer.fromJson<String>(json['projectId']),
      type: serializer.fromJson<String>(json['type']),
      name: serializer.fromJson<String>(json['name']),
      summary: serializer.fromJson<String>(json['summary']),
      status: serializer.fromJson<String>(json['status']),
      fieldsJson: serializer.fromJson<String>(json['fieldsJson']),
      metadataJson: serializer.fromJson<String>(json['metadataJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'projectId': serializer.toJson<String>(projectId),
      'type': serializer.toJson<String>(type),
      'name': serializer.toJson<String>(name),
      'summary': serializer.toJson<String>(summary),
      'status': serializer.toJson<String>(status),
      'fieldsJson': serializer.toJson<String>(fieldsJson),
      'metadataJson': serializer.toJson<String>(metadataJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  CatalogItemRow copyWith(
          {String? id,
          String? projectId,
          String? type,
          String? name,
          String? summary,
          String? status,
          String? fieldsJson,
          String? metadataJson,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      CatalogItemRow(
        id: id ?? this.id,
        projectId: projectId ?? this.projectId,
        type: type ?? this.type,
        name: name ?? this.name,
        summary: summary ?? this.summary,
        status: status ?? this.status,
        fieldsJson: fieldsJson ?? this.fieldsJson,
        metadataJson: metadataJson ?? this.metadataJson,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  CatalogItemRow copyWithCompanion(CatalogItemsCompanion data) {
    return CatalogItemRow(
      id: data.id.present ? data.id.value : this.id,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      type: data.type.present ? data.type.value : this.type,
      name: data.name.present ? data.name.value : this.name,
      summary: data.summary.present ? data.summary.value : this.summary,
      status: data.status.present ? data.status.value : this.status,
      fieldsJson:
          data.fieldsJson.present ? data.fieldsJson.value : this.fieldsJson,
      metadataJson: data.metadataJson.present
          ? data.metadataJson.value
          : this.metadataJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CatalogItemRow(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('type: $type, ')
          ..write('name: $name, ')
          ..write('summary: $summary, ')
          ..write('status: $status, ')
          ..write('fieldsJson: $fieldsJson, ')
          ..write('metadataJson: $metadataJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, projectId, type, name, summary, status,
      fieldsJson, metadataJson, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CatalogItemRow &&
          other.id == this.id &&
          other.projectId == this.projectId &&
          other.type == this.type &&
          other.name == this.name &&
          other.summary == this.summary &&
          other.status == this.status &&
          other.fieldsJson == this.fieldsJson &&
          other.metadataJson == this.metadataJson &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class CatalogItemsCompanion extends UpdateCompanion<CatalogItemRow> {
  final Value<String> id;
  final Value<String> projectId;
  final Value<String> type;
  final Value<String> name;
  final Value<String> summary;
  final Value<String> status;
  final Value<String> fieldsJson;
  final Value<String> metadataJson;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const CatalogItemsCompanion({
    this.id = const Value.absent(),
    this.projectId = const Value.absent(),
    this.type = const Value.absent(),
    this.name = const Value.absent(),
    this.summary = const Value.absent(),
    this.status = const Value.absent(),
    this.fieldsJson = const Value.absent(),
    this.metadataJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CatalogItemsCompanion.insert({
    required String id,
    required String projectId,
    required String type,
    required String name,
    this.summary = const Value.absent(),
    required String status,
    this.fieldsJson = const Value.absent(),
    this.metadataJson = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        projectId = Value(projectId),
        type = Value(type),
        name = Value(name),
        status = Value(status),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<CatalogItemRow> custom({
    Expression<String>? id,
    Expression<String>? projectId,
    Expression<String>? type,
    Expression<String>? name,
    Expression<String>? summary,
    Expression<String>? status,
    Expression<String>? fieldsJson,
    Expression<String>? metadataJson,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (projectId != null) 'project_id': projectId,
      if (type != null) 'type': type,
      if (name != null) 'name': name,
      if (summary != null) 'summary': summary,
      if (status != null) 'status': status,
      if (fieldsJson != null) 'fields_json': fieldsJson,
      if (metadataJson != null) 'metadata_json': metadataJson,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CatalogItemsCompanion copyWith(
      {Value<String>? id,
      Value<String>? projectId,
      Value<String>? type,
      Value<String>? name,
      Value<String>? summary,
      Value<String>? status,
      Value<String>? fieldsJson,
      Value<String>? metadataJson,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return CatalogItemsCompanion(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      type: type ?? this.type,
      name: name ?? this.name,
      summary: summary ?? this.summary,
      status: status ?? this.status,
      fieldsJson: fieldsJson ?? this.fieldsJson,
      metadataJson: metadataJson ?? this.metadataJson,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<String>(projectId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (summary.present) {
      map['summary'] = Variable<String>(summary.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (fieldsJson.present) {
      map['fields_json'] = Variable<String>(fieldsJson.value);
    }
    if (metadataJson.present) {
      map['metadata_json'] = Variable<String>(metadataJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CatalogItemsCompanion(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('type: $type, ')
          ..write('name: $name, ')
          ..write('summary: $summary, ')
          ..write('status: $status, ')
          ..write('fieldsJson: $fieldsJson, ')
          ..write('metadataJson: $metadataJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RelationshipsTable extends Relationships
    with TableInfo<$RelationshipsTable, RelationshipRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RelationshipsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _projectIdMeta =
      const VerificationMeta('projectId');
  @override
  late final GeneratedColumn<String> projectId = GeneratedColumn<String>(
      'project_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES projects (id)'));
  static const VerificationMeta _sourceTypeMeta =
      const VerificationMeta('sourceType');
  @override
  late final GeneratedColumn<String> sourceType = GeneratedColumn<String>(
      'source_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sourceIdMeta =
      const VerificationMeta('sourceId');
  @override
  late final GeneratedColumn<String> sourceId = GeneratedColumn<String>(
      'source_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _targetTypeMeta =
      const VerificationMeta('targetType');
  @override
  late final GeneratedColumn<String> targetType = GeneratedColumn<String>(
      'target_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _targetIdMeta =
      const VerificationMeta('targetId');
  @override
  late final GeneratedColumn<String> targetId = GeneratedColumn<String>(
      'target_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _relationshipTypeMeta =
      const VerificationMeta('relationshipType');
  @override
  late final GeneratedColumn<String> relationshipType = GeneratedColumn<String>(
      'relationship_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
      'label', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _strengthMeta =
      const VerificationMeta('strength');
  @override
  late final GeneratedColumn<double> strength = GeneratedColumn<double>(
      'strength', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _directionMeta =
      const VerificationMeta('direction');
  @override
  late final GeneratedColumn<String> direction = GeneratedColumn<String>(
      'direction', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _validFromStoryTimeMeta =
      const VerificationMeta('validFromStoryTime');
  @override
  late final GeneratedColumn<DateTime> validFromStoryTime =
      GeneratedColumn<DateTime>('valid_from_story_time', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _validToStoryTimeMeta =
      const VerificationMeta('validToStoryTime');
  @override
  late final GeneratedColumn<DateTime> validToStoryTime =
      GeneratedColumn<DateTime>('valid_to_story_time', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _metadataJsonMeta =
      const VerificationMeta('metadataJson');
  @override
  late final GeneratedColumn<String> metadataJson = GeneratedColumn<String>(
      'metadata_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('{}'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        projectId,
        sourceType,
        sourceId,
        targetType,
        targetId,
        relationshipType,
        label,
        description,
        strength,
        direction,
        validFromStoryTime,
        validToStoryTime,
        metadataJson,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'relationships';
  @override
  VerificationContext validateIntegrity(Insertable<RelationshipRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('project_id')) {
      context.handle(_projectIdMeta,
          projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta));
    } else if (isInserting) {
      context.missing(_projectIdMeta);
    }
    if (data.containsKey('source_type')) {
      context.handle(
          _sourceTypeMeta,
          sourceType.isAcceptableOrUnknown(
              data['source_type']!, _sourceTypeMeta));
    } else if (isInserting) {
      context.missing(_sourceTypeMeta);
    }
    if (data.containsKey('source_id')) {
      context.handle(_sourceIdMeta,
          sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta));
    } else if (isInserting) {
      context.missing(_sourceIdMeta);
    }
    if (data.containsKey('target_type')) {
      context.handle(
          _targetTypeMeta,
          targetType.isAcceptableOrUnknown(
              data['target_type']!, _targetTypeMeta));
    } else if (isInserting) {
      context.missing(_targetTypeMeta);
    }
    if (data.containsKey('target_id')) {
      context.handle(_targetIdMeta,
          targetId.isAcceptableOrUnknown(data['target_id']!, _targetIdMeta));
    } else if (isInserting) {
      context.missing(_targetIdMeta);
    }
    if (data.containsKey('relationship_type')) {
      context.handle(
          _relationshipTypeMeta,
          relationshipType.isAcceptableOrUnknown(
              data['relationship_type']!, _relationshipTypeMeta));
    } else if (isInserting) {
      context.missing(_relationshipTypeMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
          _labelMeta, label.isAcceptableOrUnknown(data['label']!, _labelMeta));
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('strength')) {
      context.handle(_strengthMeta,
          strength.isAcceptableOrUnknown(data['strength']!, _strengthMeta));
    }
    if (data.containsKey('direction')) {
      context.handle(_directionMeta,
          direction.isAcceptableOrUnknown(data['direction']!, _directionMeta));
    } else if (isInserting) {
      context.missing(_directionMeta);
    }
    if (data.containsKey('valid_from_story_time')) {
      context.handle(
          _validFromStoryTimeMeta,
          validFromStoryTime.isAcceptableOrUnknown(
              data['valid_from_story_time']!, _validFromStoryTimeMeta));
    }
    if (data.containsKey('valid_to_story_time')) {
      context.handle(
          _validToStoryTimeMeta,
          validToStoryTime.isAcceptableOrUnknown(
              data['valid_to_story_time']!, _validToStoryTimeMeta));
    }
    if (data.containsKey('metadata_json')) {
      context.handle(
          _metadataJsonMeta,
          metadataJson.isAcceptableOrUnknown(
              data['metadata_json']!, _metadataJsonMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RelationshipRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RelationshipRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      projectId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}project_id'])!,
      sourceType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source_type'])!,
      sourceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source_id'])!,
      targetType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}target_type'])!,
      targetId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}target_id'])!,
      relationshipType: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}relationship_type'])!,
      label: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}label']),
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      strength: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}strength']),
      direction: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}direction'])!,
      validFromStoryTime: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime,
          data['${effectivePrefix}valid_from_story_time']),
      validToStoryTime: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}valid_to_story_time']),
      metadataJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}metadata_json'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $RelationshipsTable createAlias(String alias) {
    return $RelationshipsTable(attachedDatabase, alias);
  }
}

class RelationshipRow extends DataClass implements Insertable<RelationshipRow> {
  final String id;
  final String projectId;
  final String sourceType;
  final String sourceId;
  final String targetType;
  final String targetId;
  final String relationshipType;
  final String? label;
  final String? description;
  final double? strength;
  final String direction;
  final DateTime? validFromStoryTime;
  final DateTime? validToStoryTime;
  final String metadataJson;
  final DateTime createdAt;
  final DateTime updatedAt;
  const RelationshipRow(
      {required this.id,
      required this.projectId,
      required this.sourceType,
      required this.sourceId,
      required this.targetType,
      required this.targetId,
      required this.relationshipType,
      this.label,
      this.description,
      this.strength,
      required this.direction,
      this.validFromStoryTime,
      this.validToStoryTime,
      required this.metadataJson,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['project_id'] = Variable<String>(projectId);
    map['source_type'] = Variable<String>(sourceType);
    map['source_id'] = Variable<String>(sourceId);
    map['target_type'] = Variable<String>(targetType);
    map['target_id'] = Variable<String>(targetId);
    map['relationship_type'] = Variable<String>(relationshipType);
    if (!nullToAbsent || label != null) {
      map['label'] = Variable<String>(label);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || strength != null) {
      map['strength'] = Variable<double>(strength);
    }
    map['direction'] = Variable<String>(direction);
    if (!nullToAbsent || validFromStoryTime != null) {
      map['valid_from_story_time'] = Variable<DateTime>(validFromStoryTime);
    }
    if (!nullToAbsent || validToStoryTime != null) {
      map['valid_to_story_time'] = Variable<DateTime>(validToStoryTime);
    }
    map['metadata_json'] = Variable<String>(metadataJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  RelationshipsCompanion toCompanion(bool nullToAbsent) {
    return RelationshipsCompanion(
      id: Value(id),
      projectId: Value(projectId),
      sourceType: Value(sourceType),
      sourceId: Value(sourceId),
      targetType: Value(targetType),
      targetId: Value(targetId),
      relationshipType: Value(relationshipType),
      label:
          label == null && nullToAbsent ? const Value.absent() : Value(label),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      strength: strength == null && nullToAbsent
          ? const Value.absent()
          : Value(strength),
      direction: Value(direction),
      validFromStoryTime: validFromStoryTime == null && nullToAbsent
          ? const Value.absent()
          : Value(validFromStoryTime),
      validToStoryTime: validToStoryTime == null && nullToAbsent
          ? const Value.absent()
          : Value(validToStoryTime),
      metadataJson: Value(metadataJson),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory RelationshipRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RelationshipRow(
      id: serializer.fromJson<String>(json['id']),
      projectId: serializer.fromJson<String>(json['projectId']),
      sourceType: serializer.fromJson<String>(json['sourceType']),
      sourceId: serializer.fromJson<String>(json['sourceId']),
      targetType: serializer.fromJson<String>(json['targetType']),
      targetId: serializer.fromJson<String>(json['targetId']),
      relationshipType: serializer.fromJson<String>(json['relationshipType']),
      label: serializer.fromJson<String?>(json['label']),
      description: serializer.fromJson<String?>(json['description']),
      strength: serializer.fromJson<double?>(json['strength']),
      direction: serializer.fromJson<String>(json['direction']),
      validFromStoryTime:
          serializer.fromJson<DateTime?>(json['validFromStoryTime']),
      validToStoryTime:
          serializer.fromJson<DateTime?>(json['validToStoryTime']),
      metadataJson: serializer.fromJson<String>(json['metadataJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'projectId': serializer.toJson<String>(projectId),
      'sourceType': serializer.toJson<String>(sourceType),
      'sourceId': serializer.toJson<String>(sourceId),
      'targetType': serializer.toJson<String>(targetType),
      'targetId': serializer.toJson<String>(targetId),
      'relationshipType': serializer.toJson<String>(relationshipType),
      'label': serializer.toJson<String?>(label),
      'description': serializer.toJson<String?>(description),
      'strength': serializer.toJson<double?>(strength),
      'direction': serializer.toJson<String>(direction),
      'validFromStoryTime': serializer.toJson<DateTime?>(validFromStoryTime),
      'validToStoryTime': serializer.toJson<DateTime?>(validToStoryTime),
      'metadataJson': serializer.toJson<String>(metadataJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  RelationshipRow copyWith(
          {String? id,
          String? projectId,
          String? sourceType,
          String? sourceId,
          String? targetType,
          String? targetId,
          String? relationshipType,
          Value<String?> label = const Value.absent(),
          Value<String?> description = const Value.absent(),
          Value<double?> strength = const Value.absent(),
          String? direction,
          Value<DateTime?> validFromStoryTime = const Value.absent(),
          Value<DateTime?> validToStoryTime = const Value.absent(),
          String? metadataJson,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      RelationshipRow(
        id: id ?? this.id,
        projectId: projectId ?? this.projectId,
        sourceType: sourceType ?? this.sourceType,
        sourceId: sourceId ?? this.sourceId,
        targetType: targetType ?? this.targetType,
        targetId: targetId ?? this.targetId,
        relationshipType: relationshipType ?? this.relationshipType,
        label: label.present ? label.value : this.label,
        description: description.present ? description.value : this.description,
        strength: strength.present ? strength.value : this.strength,
        direction: direction ?? this.direction,
        validFromStoryTime: validFromStoryTime.present
            ? validFromStoryTime.value
            : this.validFromStoryTime,
        validToStoryTime: validToStoryTime.present
            ? validToStoryTime.value
            : this.validToStoryTime,
        metadataJson: metadataJson ?? this.metadataJson,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  RelationshipRow copyWithCompanion(RelationshipsCompanion data) {
    return RelationshipRow(
      id: data.id.present ? data.id.value : this.id,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      sourceType:
          data.sourceType.present ? data.sourceType.value : this.sourceType,
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      targetType:
          data.targetType.present ? data.targetType.value : this.targetType,
      targetId: data.targetId.present ? data.targetId.value : this.targetId,
      relationshipType: data.relationshipType.present
          ? data.relationshipType.value
          : this.relationshipType,
      label: data.label.present ? data.label.value : this.label,
      description:
          data.description.present ? data.description.value : this.description,
      strength: data.strength.present ? data.strength.value : this.strength,
      direction: data.direction.present ? data.direction.value : this.direction,
      validFromStoryTime: data.validFromStoryTime.present
          ? data.validFromStoryTime.value
          : this.validFromStoryTime,
      validToStoryTime: data.validToStoryTime.present
          ? data.validToStoryTime.value
          : this.validToStoryTime,
      metadataJson: data.metadataJson.present
          ? data.metadataJson.value
          : this.metadataJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RelationshipRow(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('sourceType: $sourceType, ')
          ..write('sourceId: $sourceId, ')
          ..write('targetType: $targetType, ')
          ..write('targetId: $targetId, ')
          ..write('relationshipType: $relationshipType, ')
          ..write('label: $label, ')
          ..write('description: $description, ')
          ..write('strength: $strength, ')
          ..write('direction: $direction, ')
          ..write('validFromStoryTime: $validFromStoryTime, ')
          ..write('validToStoryTime: $validToStoryTime, ')
          ..write('metadataJson: $metadataJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      projectId,
      sourceType,
      sourceId,
      targetType,
      targetId,
      relationshipType,
      label,
      description,
      strength,
      direction,
      validFromStoryTime,
      validToStoryTime,
      metadataJson,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RelationshipRow &&
          other.id == this.id &&
          other.projectId == this.projectId &&
          other.sourceType == this.sourceType &&
          other.sourceId == this.sourceId &&
          other.targetType == this.targetType &&
          other.targetId == this.targetId &&
          other.relationshipType == this.relationshipType &&
          other.label == this.label &&
          other.description == this.description &&
          other.strength == this.strength &&
          other.direction == this.direction &&
          other.validFromStoryTime == this.validFromStoryTime &&
          other.validToStoryTime == this.validToStoryTime &&
          other.metadataJson == this.metadataJson &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class RelationshipsCompanion extends UpdateCompanion<RelationshipRow> {
  final Value<String> id;
  final Value<String> projectId;
  final Value<String> sourceType;
  final Value<String> sourceId;
  final Value<String> targetType;
  final Value<String> targetId;
  final Value<String> relationshipType;
  final Value<String?> label;
  final Value<String?> description;
  final Value<double?> strength;
  final Value<String> direction;
  final Value<DateTime?> validFromStoryTime;
  final Value<DateTime?> validToStoryTime;
  final Value<String> metadataJson;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const RelationshipsCompanion({
    this.id = const Value.absent(),
    this.projectId = const Value.absent(),
    this.sourceType = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.targetType = const Value.absent(),
    this.targetId = const Value.absent(),
    this.relationshipType = const Value.absent(),
    this.label = const Value.absent(),
    this.description = const Value.absent(),
    this.strength = const Value.absent(),
    this.direction = const Value.absent(),
    this.validFromStoryTime = const Value.absent(),
    this.validToStoryTime = const Value.absent(),
    this.metadataJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RelationshipsCompanion.insert({
    required String id,
    required String projectId,
    required String sourceType,
    required String sourceId,
    required String targetType,
    required String targetId,
    required String relationshipType,
    this.label = const Value.absent(),
    this.description = const Value.absent(),
    this.strength = const Value.absent(),
    required String direction,
    this.validFromStoryTime = const Value.absent(),
    this.validToStoryTime = const Value.absent(),
    this.metadataJson = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        projectId = Value(projectId),
        sourceType = Value(sourceType),
        sourceId = Value(sourceId),
        targetType = Value(targetType),
        targetId = Value(targetId),
        relationshipType = Value(relationshipType),
        direction = Value(direction),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<RelationshipRow> custom({
    Expression<String>? id,
    Expression<String>? projectId,
    Expression<String>? sourceType,
    Expression<String>? sourceId,
    Expression<String>? targetType,
    Expression<String>? targetId,
    Expression<String>? relationshipType,
    Expression<String>? label,
    Expression<String>? description,
    Expression<double>? strength,
    Expression<String>? direction,
    Expression<DateTime>? validFromStoryTime,
    Expression<DateTime>? validToStoryTime,
    Expression<String>? metadataJson,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (projectId != null) 'project_id': projectId,
      if (sourceType != null) 'source_type': sourceType,
      if (sourceId != null) 'source_id': sourceId,
      if (targetType != null) 'target_type': targetType,
      if (targetId != null) 'target_id': targetId,
      if (relationshipType != null) 'relationship_type': relationshipType,
      if (label != null) 'label': label,
      if (description != null) 'description': description,
      if (strength != null) 'strength': strength,
      if (direction != null) 'direction': direction,
      if (validFromStoryTime != null)
        'valid_from_story_time': validFromStoryTime,
      if (validToStoryTime != null) 'valid_to_story_time': validToStoryTime,
      if (metadataJson != null) 'metadata_json': metadataJson,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RelationshipsCompanion copyWith(
      {Value<String>? id,
      Value<String>? projectId,
      Value<String>? sourceType,
      Value<String>? sourceId,
      Value<String>? targetType,
      Value<String>? targetId,
      Value<String>? relationshipType,
      Value<String?>? label,
      Value<String?>? description,
      Value<double?>? strength,
      Value<String>? direction,
      Value<DateTime?>? validFromStoryTime,
      Value<DateTime?>? validToStoryTime,
      Value<String>? metadataJson,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return RelationshipsCompanion(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      sourceType: sourceType ?? this.sourceType,
      sourceId: sourceId ?? this.sourceId,
      targetType: targetType ?? this.targetType,
      targetId: targetId ?? this.targetId,
      relationshipType: relationshipType ?? this.relationshipType,
      label: label ?? this.label,
      description: description ?? this.description,
      strength: strength ?? this.strength,
      direction: direction ?? this.direction,
      validFromStoryTime: validFromStoryTime ?? this.validFromStoryTime,
      validToStoryTime: validToStoryTime ?? this.validToStoryTime,
      metadataJson: metadataJson ?? this.metadataJson,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<String>(projectId.value);
    }
    if (sourceType.present) {
      map['source_type'] = Variable<String>(sourceType.value);
    }
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (targetType.present) {
      map['target_type'] = Variable<String>(targetType.value);
    }
    if (targetId.present) {
      map['target_id'] = Variable<String>(targetId.value);
    }
    if (relationshipType.present) {
      map['relationship_type'] = Variable<String>(relationshipType.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (strength.present) {
      map['strength'] = Variable<double>(strength.value);
    }
    if (direction.present) {
      map['direction'] = Variable<String>(direction.value);
    }
    if (validFromStoryTime.present) {
      map['valid_from_story_time'] =
          Variable<DateTime>(validFromStoryTime.value);
    }
    if (validToStoryTime.present) {
      map['valid_to_story_time'] = Variable<DateTime>(validToStoryTime.value);
    }
    if (metadataJson.present) {
      map['metadata_json'] = Variable<String>(metadataJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RelationshipsCompanion(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('sourceType: $sourceType, ')
          ..write('sourceId: $sourceId, ')
          ..write('targetType: $targetType, ')
          ..write('targetId: $targetId, ')
          ..write('relationshipType: $relationshipType, ')
          ..write('label: $label, ')
          ..write('description: $description, ')
          ..write('strength: $strength, ')
          ..write('direction: $direction, ')
          ..write('validFromStoryTime: $validFromStoryTime, ')
          ..write('validToStoryTime: $validToStoryTime, ')
          ..write('metadataJson: $metadataJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AISuggestionsTable extends AISuggestions
    with TableInfo<$AISuggestionsTable, AISuggestionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AISuggestionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _projectIdMeta =
      const VerificationMeta('projectId');
  @override
  late final GeneratedColumn<String> projectId = GeneratedColumn<String>(
      'project_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES projects (id)'));
  static const VerificationMeta _targetTypeMeta =
      const VerificationMeta('targetType');
  @override
  late final GeneratedColumn<String> targetType = GeneratedColumn<String>(
      'target_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _targetIdMeta =
      const VerificationMeta('targetId');
  @override
  late final GeneratedColumn<String> targetId = GeneratedColumn<String>(
      'target_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _suggestionTypeMeta =
      const VerificationMeta('suggestionType');
  @override
  late final GeneratedColumn<String> suggestionType = GeneratedColumn<String>(
      'suggestion_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _inputContextHashMeta =
      const VerificationMeta('inputContextHash');
  @override
  late final GeneratedColumn<String> inputContextHash = GeneratedColumn<String>(
      'input_context_hash', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _providerIdMeta =
      const VerificationMeta('providerId');
  @override
  late final GeneratedColumn<String> providerId = GeneratedColumn<String>(
      'provider_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _modelNameMeta =
      const VerificationMeta('modelName');
  @override
  late final GeneratedColumn<String> modelName = GeneratedColumn<String>(
      'model_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _promptTemplateIdMeta =
      const VerificationMeta('promptTemplateId');
  @override
  late final GeneratedColumn<String> promptTemplateId = GeneratedColumn<String>(
      'prompt_template_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _promptTextMeta =
      const VerificationMeta('promptText');
  @override
  late final GeneratedColumn<String> promptText = GeneratedColumn<String>(
      'prompt_text', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _responseTextMeta =
      const VerificationMeta('responseText');
  @override
  late final GeneratedColumn<String> responseText = GeneratedColumn<String>(
      'response_text', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _structuredResponseJsonMeta =
      const VerificationMeta('structuredResponseJson');
  @override
  late final GeneratedColumn<String> structuredResponseJson =
      GeneratedColumn<String>('structured_response_json', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _userDecisionMeta =
      const VerificationMeta('userDecision');
  @override
  late final GeneratedColumn<String> userDecision = GeneratedColumn<String>(
      'user_decision', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _acceptedPatchJsonMeta =
      const VerificationMeta('acceptedPatchJson');
  @override
  late final GeneratedColumn<String> acceptedPatchJson =
      GeneratedColumn<String>('accepted_patch_json', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        projectId,
        targetType,
        targetId,
        suggestionType,
        inputContextHash,
        providerId,
        modelName,
        promptTemplateId,
        promptText,
        responseText,
        structuredResponseJson,
        userDecision,
        acceptedPatchJson,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'a_i_suggestions';
  @override
  VerificationContext validateIntegrity(Insertable<AISuggestionRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('project_id')) {
      context.handle(_projectIdMeta,
          projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta));
    } else if (isInserting) {
      context.missing(_projectIdMeta);
    }
    if (data.containsKey('target_type')) {
      context.handle(
          _targetTypeMeta,
          targetType.isAcceptableOrUnknown(
              data['target_type']!, _targetTypeMeta));
    } else if (isInserting) {
      context.missing(_targetTypeMeta);
    }
    if (data.containsKey('target_id')) {
      context.handle(_targetIdMeta,
          targetId.isAcceptableOrUnknown(data['target_id']!, _targetIdMeta));
    } else if (isInserting) {
      context.missing(_targetIdMeta);
    }
    if (data.containsKey('suggestion_type')) {
      context.handle(
          _suggestionTypeMeta,
          suggestionType.isAcceptableOrUnknown(
              data['suggestion_type']!, _suggestionTypeMeta));
    } else if (isInserting) {
      context.missing(_suggestionTypeMeta);
    }
    if (data.containsKey('input_context_hash')) {
      context.handle(
          _inputContextHashMeta,
          inputContextHash.isAcceptableOrUnknown(
              data['input_context_hash']!, _inputContextHashMeta));
    } else if (isInserting) {
      context.missing(_inputContextHashMeta);
    }
    if (data.containsKey('provider_id')) {
      context.handle(
          _providerIdMeta,
          providerId.isAcceptableOrUnknown(
              data['provider_id']!, _providerIdMeta));
    } else if (isInserting) {
      context.missing(_providerIdMeta);
    }
    if (data.containsKey('model_name')) {
      context.handle(_modelNameMeta,
          modelName.isAcceptableOrUnknown(data['model_name']!, _modelNameMeta));
    } else if (isInserting) {
      context.missing(_modelNameMeta);
    }
    if (data.containsKey('prompt_template_id')) {
      context.handle(
          _promptTemplateIdMeta,
          promptTemplateId.isAcceptableOrUnknown(
              data['prompt_template_id']!, _promptTemplateIdMeta));
    }
    if (data.containsKey('prompt_text')) {
      context.handle(
          _promptTextMeta,
          promptText.isAcceptableOrUnknown(
              data['prompt_text']!, _promptTextMeta));
    } else if (isInserting) {
      context.missing(_promptTextMeta);
    }
    if (data.containsKey('response_text')) {
      context.handle(
          _responseTextMeta,
          responseText.isAcceptableOrUnknown(
              data['response_text']!, _responseTextMeta));
    } else if (isInserting) {
      context.missing(_responseTextMeta);
    }
    if (data.containsKey('structured_response_json')) {
      context.handle(
          _structuredResponseJsonMeta,
          structuredResponseJson.isAcceptableOrUnknown(
              data['structured_response_json']!, _structuredResponseJsonMeta));
    }
    if (data.containsKey('user_decision')) {
      context.handle(
          _userDecisionMeta,
          userDecision.isAcceptableOrUnknown(
              data['user_decision']!, _userDecisionMeta));
    } else if (isInserting) {
      context.missing(_userDecisionMeta);
    }
    if (data.containsKey('accepted_patch_json')) {
      context.handle(
          _acceptedPatchJsonMeta,
          acceptedPatchJson.isAcceptableOrUnknown(
              data['accepted_patch_json']!, _acceptedPatchJsonMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AISuggestionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AISuggestionRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      projectId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}project_id'])!,
      targetType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}target_type'])!,
      targetId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}target_id'])!,
      suggestionType: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}suggestion_type'])!,
      inputContextHash: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}input_context_hash'])!,
      providerId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}provider_id'])!,
      modelName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}model_name'])!,
      promptTemplateId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}prompt_template_id']),
      promptText: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}prompt_text'])!,
      responseText: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}response_text'])!,
      structuredResponseJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}structured_response_json']),
      userDecision: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_decision'])!,
      acceptedPatchJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}accepted_patch_json']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $AISuggestionsTable createAlias(String alias) {
    return $AISuggestionsTable(attachedDatabase, alias);
  }
}

class AISuggestionRow extends DataClass implements Insertable<AISuggestionRow> {
  final String id;
  final String projectId;
  final String targetType;
  final String targetId;
  final String suggestionType;
  final String inputContextHash;
  final String providerId;
  final String modelName;
  final String? promptTemplateId;
  final String promptText;
  final String responseText;
  final String? structuredResponseJson;
  final String userDecision;
  final String? acceptedPatchJson;
  final DateTime createdAt;
  const AISuggestionRow(
      {required this.id,
      required this.projectId,
      required this.targetType,
      required this.targetId,
      required this.suggestionType,
      required this.inputContextHash,
      required this.providerId,
      required this.modelName,
      this.promptTemplateId,
      required this.promptText,
      required this.responseText,
      this.structuredResponseJson,
      required this.userDecision,
      this.acceptedPatchJson,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['project_id'] = Variable<String>(projectId);
    map['target_type'] = Variable<String>(targetType);
    map['target_id'] = Variable<String>(targetId);
    map['suggestion_type'] = Variable<String>(suggestionType);
    map['input_context_hash'] = Variable<String>(inputContextHash);
    map['provider_id'] = Variable<String>(providerId);
    map['model_name'] = Variable<String>(modelName);
    if (!nullToAbsent || promptTemplateId != null) {
      map['prompt_template_id'] = Variable<String>(promptTemplateId);
    }
    map['prompt_text'] = Variable<String>(promptText);
    map['response_text'] = Variable<String>(responseText);
    if (!nullToAbsent || structuredResponseJson != null) {
      map['structured_response_json'] =
          Variable<String>(structuredResponseJson);
    }
    map['user_decision'] = Variable<String>(userDecision);
    if (!nullToAbsent || acceptedPatchJson != null) {
      map['accepted_patch_json'] = Variable<String>(acceptedPatchJson);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  AISuggestionsCompanion toCompanion(bool nullToAbsent) {
    return AISuggestionsCompanion(
      id: Value(id),
      projectId: Value(projectId),
      targetType: Value(targetType),
      targetId: Value(targetId),
      suggestionType: Value(suggestionType),
      inputContextHash: Value(inputContextHash),
      providerId: Value(providerId),
      modelName: Value(modelName),
      promptTemplateId: promptTemplateId == null && nullToAbsent
          ? const Value.absent()
          : Value(promptTemplateId),
      promptText: Value(promptText),
      responseText: Value(responseText),
      structuredResponseJson: structuredResponseJson == null && nullToAbsent
          ? const Value.absent()
          : Value(structuredResponseJson),
      userDecision: Value(userDecision),
      acceptedPatchJson: acceptedPatchJson == null && nullToAbsent
          ? const Value.absent()
          : Value(acceptedPatchJson),
      createdAt: Value(createdAt),
    );
  }

  factory AISuggestionRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AISuggestionRow(
      id: serializer.fromJson<String>(json['id']),
      projectId: serializer.fromJson<String>(json['projectId']),
      targetType: serializer.fromJson<String>(json['targetType']),
      targetId: serializer.fromJson<String>(json['targetId']),
      suggestionType: serializer.fromJson<String>(json['suggestionType']),
      inputContextHash: serializer.fromJson<String>(json['inputContextHash']),
      providerId: serializer.fromJson<String>(json['providerId']),
      modelName: serializer.fromJson<String>(json['modelName']),
      promptTemplateId: serializer.fromJson<String?>(json['promptTemplateId']),
      promptText: serializer.fromJson<String>(json['promptText']),
      responseText: serializer.fromJson<String>(json['responseText']),
      structuredResponseJson:
          serializer.fromJson<String?>(json['structuredResponseJson']),
      userDecision: serializer.fromJson<String>(json['userDecision']),
      acceptedPatchJson:
          serializer.fromJson<String?>(json['acceptedPatchJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'projectId': serializer.toJson<String>(projectId),
      'targetType': serializer.toJson<String>(targetType),
      'targetId': serializer.toJson<String>(targetId),
      'suggestionType': serializer.toJson<String>(suggestionType),
      'inputContextHash': serializer.toJson<String>(inputContextHash),
      'providerId': serializer.toJson<String>(providerId),
      'modelName': serializer.toJson<String>(modelName),
      'promptTemplateId': serializer.toJson<String?>(promptTemplateId),
      'promptText': serializer.toJson<String>(promptText),
      'responseText': serializer.toJson<String>(responseText),
      'structuredResponseJson':
          serializer.toJson<String?>(structuredResponseJson),
      'userDecision': serializer.toJson<String>(userDecision),
      'acceptedPatchJson': serializer.toJson<String?>(acceptedPatchJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  AISuggestionRow copyWith(
          {String? id,
          String? projectId,
          String? targetType,
          String? targetId,
          String? suggestionType,
          String? inputContextHash,
          String? providerId,
          String? modelName,
          Value<String?> promptTemplateId = const Value.absent(),
          String? promptText,
          String? responseText,
          Value<String?> structuredResponseJson = const Value.absent(),
          String? userDecision,
          Value<String?> acceptedPatchJson = const Value.absent(),
          DateTime? createdAt}) =>
      AISuggestionRow(
        id: id ?? this.id,
        projectId: projectId ?? this.projectId,
        targetType: targetType ?? this.targetType,
        targetId: targetId ?? this.targetId,
        suggestionType: suggestionType ?? this.suggestionType,
        inputContextHash: inputContextHash ?? this.inputContextHash,
        providerId: providerId ?? this.providerId,
        modelName: modelName ?? this.modelName,
        promptTemplateId: promptTemplateId.present
            ? promptTemplateId.value
            : this.promptTemplateId,
        promptText: promptText ?? this.promptText,
        responseText: responseText ?? this.responseText,
        structuredResponseJson: structuredResponseJson.present
            ? structuredResponseJson.value
            : this.structuredResponseJson,
        userDecision: userDecision ?? this.userDecision,
        acceptedPatchJson: acceptedPatchJson.present
            ? acceptedPatchJson.value
            : this.acceptedPatchJson,
        createdAt: createdAt ?? this.createdAt,
      );
  AISuggestionRow copyWithCompanion(AISuggestionsCompanion data) {
    return AISuggestionRow(
      id: data.id.present ? data.id.value : this.id,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      targetType:
          data.targetType.present ? data.targetType.value : this.targetType,
      targetId: data.targetId.present ? data.targetId.value : this.targetId,
      suggestionType: data.suggestionType.present
          ? data.suggestionType.value
          : this.suggestionType,
      inputContextHash: data.inputContextHash.present
          ? data.inputContextHash.value
          : this.inputContextHash,
      providerId:
          data.providerId.present ? data.providerId.value : this.providerId,
      modelName: data.modelName.present ? data.modelName.value : this.modelName,
      promptTemplateId: data.promptTemplateId.present
          ? data.promptTemplateId.value
          : this.promptTemplateId,
      promptText:
          data.promptText.present ? data.promptText.value : this.promptText,
      responseText: data.responseText.present
          ? data.responseText.value
          : this.responseText,
      structuredResponseJson: data.structuredResponseJson.present
          ? data.structuredResponseJson.value
          : this.structuredResponseJson,
      userDecision: data.userDecision.present
          ? data.userDecision.value
          : this.userDecision,
      acceptedPatchJson: data.acceptedPatchJson.present
          ? data.acceptedPatchJson.value
          : this.acceptedPatchJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AISuggestionRow(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('targetType: $targetType, ')
          ..write('targetId: $targetId, ')
          ..write('suggestionType: $suggestionType, ')
          ..write('inputContextHash: $inputContextHash, ')
          ..write('providerId: $providerId, ')
          ..write('modelName: $modelName, ')
          ..write('promptTemplateId: $promptTemplateId, ')
          ..write('promptText: $promptText, ')
          ..write('responseText: $responseText, ')
          ..write('structuredResponseJson: $structuredResponseJson, ')
          ..write('userDecision: $userDecision, ')
          ..write('acceptedPatchJson: $acceptedPatchJson, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      projectId,
      targetType,
      targetId,
      suggestionType,
      inputContextHash,
      providerId,
      modelName,
      promptTemplateId,
      promptText,
      responseText,
      structuredResponseJson,
      userDecision,
      acceptedPatchJson,
      createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AISuggestionRow &&
          other.id == this.id &&
          other.projectId == this.projectId &&
          other.targetType == this.targetType &&
          other.targetId == this.targetId &&
          other.suggestionType == this.suggestionType &&
          other.inputContextHash == this.inputContextHash &&
          other.providerId == this.providerId &&
          other.modelName == this.modelName &&
          other.promptTemplateId == this.promptTemplateId &&
          other.promptText == this.promptText &&
          other.responseText == this.responseText &&
          other.structuredResponseJson == this.structuredResponseJson &&
          other.userDecision == this.userDecision &&
          other.acceptedPatchJson == this.acceptedPatchJson &&
          other.createdAt == this.createdAt);
}

class AISuggestionsCompanion extends UpdateCompanion<AISuggestionRow> {
  final Value<String> id;
  final Value<String> projectId;
  final Value<String> targetType;
  final Value<String> targetId;
  final Value<String> suggestionType;
  final Value<String> inputContextHash;
  final Value<String> providerId;
  final Value<String> modelName;
  final Value<String?> promptTemplateId;
  final Value<String> promptText;
  final Value<String> responseText;
  final Value<String?> structuredResponseJson;
  final Value<String> userDecision;
  final Value<String?> acceptedPatchJson;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const AISuggestionsCompanion({
    this.id = const Value.absent(),
    this.projectId = const Value.absent(),
    this.targetType = const Value.absent(),
    this.targetId = const Value.absent(),
    this.suggestionType = const Value.absent(),
    this.inputContextHash = const Value.absent(),
    this.providerId = const Value.absent(),
    this.modelName = const Value.absent(),
    this.promptTemplateId = const Value.absent(),
    this.promptText = const Value.absent(),
    this.responseText = const Value.absent(),
    this.structuredResponseJson = const Value.absent(),
    this.userDecision = const Value.absent(),
    this.acceptedPatchJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AISuggestionsCompanion.insert({
    required String id,
    required String projectId,
    required String targetType,
    required String targetId,
    required String suggestionType,
    required String inputContextHash,
    required String providerId,
    required String modelName,
    this.promptTemplateId = const Value.absent(),
    required String promptText,
    required String responseText,
    this.structuredResponseJson = const Value.absent(),
    required String userDecision,
    this.acceptedPatchJson = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        projectId = Value(projectId),
        targetType = Value(targetType),
        targetId = Value(targetId),
        suggestionType = Value(suggestionType),
        inputContextHash = Value(inputContextHash),
        providerId = Value(providerId),
        modelName = Value(modelName),
        promptText = Value(promptText),
        responseText = Value(responseText),
        userDecision = Value(userDecision),
        createdAt = Value(createdAt);
  static Insertable<AISuggestionRow> custom({
    Expression<String>? id,
    Expression<String>? projectId,
    Expression<String>? targetType,
    Expression<String>? targetId,
    Expression<String>? suggestionType,
    Expression<String>? inputContextHash,
    Expression<String>? providerId,
    Expression<String>? modelName,
    Expression<String>? promptTemplateId,
    Expression<String>? promptText,
    Expression<String>? responseText,
    Expression<String>? structuredResponseJson,
    Expression<String>? userDecision,
    Expression<String>? acceptedPatchJson,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (projectId != null) 'project_id': projectId,
      if (targetType != null) 'target_type': targetType,
      if (targetId != null) 'target_id': targetId,
      if (suggestionType != null) 'suggestion_type': suggestionType,
      if (inputContextHash != null) 'input_context_hash': inputContextHash,
      if (providerId != null) 'provider_id': providerId,
      if (modelName != null) 'model_name': modelName,
      if (promptTemplateId != null) 'prompt_template_id': promptTemplateId,
      if (promptText != null) 'prompt_text': promptText,
      if (responseText != null) 'response_text': responseText,
      if (structuredResponseJson != null)
        'structured_response_json': structuredResponseJson,
      if (userDecision != null) 'user_decision': userDecision,
      if (acceptedPatchJson != null) 'accepted_patch_json': acceptedPatchJson,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AISuggestionsCompanion copyWith(
      {Value<String>? id,
      Value<String>? projectId,
      Value<String>? targetType,
      Value<String>? targetId,
      Value<String>? suggestionType,
      Value<String>? inputContextHash,
      Value<String>? providerId,
      Value<String>? modelName,
      Value<String?>? promptTemplateId,
      Value<String>? promptText,
      Value<String>? responseText,
      Value<String?>? structuredResponseJson,
      Value<String>? userDecision,
      Value<String?>? acceptedPatchJson,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return AISuggestionsCompanion(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      targetType: targetType ?? this.targetType,
      targetId: targetId ?? this.targetId,
      suggestionType: suggestionType ?? this.suggestionType,
      inputContextHash: inputContextHash ?? this.inputContextHash,
      providerId: providerId ?? this.providerId,
      modelName: modelName ?? this.modelName,
      promptTemplateId: promptTemplateId ?? this.promptTemplateId,
      promptText: promptText ?? this.promptText,
      responseText: responseText ?? this.responseText,
      structuredResponseJson:
          structuredResponseJson ?? this.structuredResponseJson,
      userDecision: userDecision ?? this.userDecision,
      acceptedPatchJson: acceptedPatchJson ?? this.acceptedPatchJson,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<String>(projectId.value);
    }
    if (targetType.present) {
      map['target_type'] = Variable<String>(targetType.value);
    }
    if (targetId.present) {
      map['target_id'] = Variable<String>(targetId.value);
    }
    if (suggestionType.present) {
      map['suggestion_type'] = Variable<String>(suggestionType.value);
    }
    if (inputContextHash.present) {
      map['input_context_hash'] = Variable<String>(inputContextHash.value);
    }
    if (providerId.present) {
      map['provider_id'] = Variable<String>(providerId.value);
    }
    if (modelName.present) {
      map['model_name'] = Variable<String>(modelName.value);
    }
    if (promptTemplateId.present) {
      map['prompt_template_id'] = Variable<String>(promptTemplateId.value);
    }
    if (promptText.present) {
      map['prompt_text'] = Variable<String>(promptText.value);
    }
    if (responseText.present) {
      map['response_text'] = Variable<String>(responseText.value);
    }
    if (structuredResponseJson.present) {
      map['structured_response_json'] =
          Variable<String>(structuredResponseJson.value);
    }
    if (userDecision.present) {
      map['user_decision'] = Variable<String>(userDecision.value);
    }
    if (acceptedPatchJson.present) {
      map['accepted_patch_json'] = Variable<String>(acceptedPatchJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AISuggestionsCompanion(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('targetType: $targetType, ')
          ..write('targetId: $targetId, ')
          ..write('suggestionType: $suggestionType, ')
          ..write('inputContextHash: $inputContextHash, ')
          ..write('providerId: $providerId, ')
          ..write('modelName: $modelName, ')
          ..write('promptTemplateId: $promptTemplateId, ')
          ..write('promptText: $promptText, ')
          ..write('responseText: $responseText, ')
          ..write('structuredResponseJson: $structuredResponseJson, ')
          ..write('userDecision: $userDecision, ')
          ..write('acceptedPatchJson: $acceptedPatchJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProjectNotesTable extends ProjectNotes
    with TableInfo<$ProjectNotesTable, ProjectNoteRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProjectNotesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _projectIdMeta =
      const VerificationMeta('projectId');
  @override
  late final GeneratedColumn<String> projectId = GeneratedColumn<String>(
      'project_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES projects (id)'));
  static const VerificationMeta _targetTypeMeta =
      const VerificationMeta('targetType');
  @override
  late final GeneratedColumn<String> targetType = GeneratedColumn<String>(
      'target_type', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _targetIdMeta =
      const VerificationMeta('targetId');
  @override
  late final GeneratedColumn<String> targetId = GeneratedColumn<String>(
      'target_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
      'body', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
      'source', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('manual'));
  static const VerificationMeta _sourceSuggestionIdMeta =
      const VerificationMeta('sourceSuggestionId');
  @override
  late final GeneratedColumn<String> sourceSuggestionId =
      GeneratedColumn<String>('source_suggestion_id', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _metadataJsonMeta =
      const VerificationMeta('metadataJson');
  @override
  late final GeneratedColumn<String> metadataJson = GeneratedColumn<String>(
      'metadata_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('{}'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        projectId,
        targetType,
        targetId,
        title,
        body,
        source,
        sourceSuggestionId,
        metadataJson,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'project_notes';
  @override
  VerificationContext validateIntegrity(Insertable<ProjectNoteRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('project_id')) {
      context.handle(_projectIdMeta,
          projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta));
    } else if (isInserting) {
      context.missing(_projectIdMeta);
    }
    if (data.containsKey('target_type')) {
      context.handle(
          _targetTypeMeta,
          targetType.isAcceptableOrUnknown(
              data['target_type']!, _targetTypeMeta));
    }
    if (data.containsKey('target_id')) {
      context.handle(_targetIdMeta,
          targetId.isAcceptableOrUnknown(data['target_id']!, _targetIdMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
          _bodyMeta, body.isAcceptableOrUnknown(data['body']!, _bodyMeta));
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('source')) {
      context.handle(_sourceMeta,
          source.isAcceptableOrUnknown(data['source']!, _sourceMeta));
    }
    if (data.containsKey('source_suggestion_id')) {
      context.handle(
          _sourceSuggestionIdMeta,
          sourceSuggestionId.isAcceptableOrUnknown(
              data['source_suggestion_id']!, _sourceSuggestionIdMeta));
    }
    if (data.containsKey('metadata_json')) {
      context.handle(
          _metadataJsonMeta,
          metadataJson.isAcceptableOrUnknown(
              data['metadata_json']!, _metadataJsonMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProjectNoteRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProjectNoteRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      projectId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}project_id'])!,
      targetType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}target_type']),
      targetId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}target_id']),
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      body: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}body'])!,
      source: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source'])!,
      sourceSuggestionId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}source_suggestion_id']),
      metadataJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}metadata_json'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $ProjectNotesTable createAlias(String alias) {
    return $ProjectNotesTable(attachedDatabase, alias);
  }
}

class ProjectNoteRow extends DataClass implements Insertable<ProjectNoteRow> {
  final String id;
  final String projectId;
  final String? targetType;
  final String? targetId;
  final String title;
  final String body;
  final String source;
  final String? sourceSuggestionId;
  final String metadataJson;
  final DateTime createdAt;
  final DateTime updatedAt;
  const ProjectNoteRow(
      {required this.id,
      required this.projectId,
      this.targetType,
      this.targetId,
      required this.title,
      required this.body,
      required this.source,
      this.sourceSuggestionId,
      required this.metadataJson,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['project_id'] = Variable<String>(projectId);
    if (!nullToAbsent || targetType != null) {
      map['target_type'] = Variable<String>(targetType);
    }
    if (!nullToAbsent || targetId != null) {
      map['target_id'] = Variable<String>(targetId);
    }
    map['title'] = Variable<String>(title);
    map['body'] = Variable<String>(body);
    map['source'] = Variable<String>(source);
    if (!nullToAbsent || sourceSuggestionId != null) {
      map['source_suggestion_id'] = Variable<String>(sourceSuggestionId);
    }
    map['metadata_json'] = Variable<String>(metadataJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ProjectNotesCompanion toCompanion(bool nullToAbsent) {
    return ProjectNotesCompanion(
      id: Value(id),
      projectId: Value(projectId),
      targetType: targetType == null && nullToAbsent
          ? const Value.absent()
          : Value(targetType),
      targetId: targetId == null && nullToAbsent
          ? const Value.absent()
          : Value(targetId),
      title: Value(title),
      body: Value(body),
      source: Value(source),
      sourceSuggestionId: sourceSuggestionId == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceSuggestionId),
      metadataJson: Value(metadataJson),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory ProjectNoteRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProjectNoteRow(
      id: serializer.fromJson<String>(json['id']),
      projectId: serializer.fromJson<String>(json['projectId']),
      targetType: serializer.fromJson<String?>(json['targetType']),
      targetId: serializer.fromJson<String?>(json['targetId']),
      title: serializer.fromJson<String>(json['title']),
      body: serializer.fromJson<String>(json['body']),
      source: serializer.fromJson<String>(json['source']),
      sourceSuggestionId:
          serializer.fromJson<String?>(json['sourceSuggestionId']),
      metadataJson: serializer.fromJson<String>(json['metadataJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'projectId': serializer.toJson<String>(projectId),
      'targetType': serializer.toJson<String?>(targetType),
      'targetId': serializer.toJson<String?>(targetId),
      'title': serializer.toJson<String>(title),
      'body': serializer.toJson<String>(body),
      'source': serializer.toJson<String>(source),
      'sourceSuggestionId': serializer.toJson<String?>(sourceSuggestionId),
      'metadataJson': serializer.toJson<String>(metadataJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ProjectNoteRow copyWith(
          {String? id,
          String? projectId,
          Value<String?> targetType = const Value.absent(),
          Value<String?> targetId = const Value.absent(),
          String? title,
          String? body,
          String? source,
          Value<String?> sourceSuggestionId = const Value.absent(),
          String? metadataJson,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      ProjectNoteRow(
        id: id ?? this.id,
        projectId: projectId ?? this.projectId,
        targetType: targetType.present ? targetType.value : this.targetType,
        targetId: targetId.present ? targetId.value : this.targetId,
        title: title ?? this.title,
        body: body ?? this.body,
        source: source ?? this.source,
        sourceSuggestionId: sourceSuggestionId.present
            ? sourceSuggestionId.value
            : this.sourceSuggestionId,
        metadataJson: metadataJson ?? this.metadataJson,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  ProjectNoteRow copyWithCompanion(ProjectNotesCompanion data) {
    return ProjectNoteRow(
      id: data.id.present ? data.id.value : this.id,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      targetType:
          data.targetType.present ? data.targetType.value : this.targetType,
      targetId: data.targetId.present ? data.targetId.value : this.targetId,
      title: data.title.present ? data.title.value : this.title,
      body: data.body.present ? data.body.value : this.body,
      source: data.source.present ? data.source.value : this.source,
      sourceSuggestionId: data.sourceSuggestionId.present
          ? data.sourceSuggestionId.value
          : this.sourceSuggestionId,
      metadataJson: data.metadataJson.present
          ? data.metadataJson.value
          : this.metadataJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProjectNoteRow(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('targetType: $targetType, ')
          ..write('targetId: $targetId, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('source: $source, ')
          ..write('sourceSuggestionId: $sourceSuggestionId, ')
          ..write('metadataJson: $metadataJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, projectId, targetType, targetId, title,
      body, source, sourceSuggestionId, metadataJson, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProjectNoteRow &&
          other.id == this.id &&
          other.projectId == this.projectId &&
          other.targetType == this.targetType &&
          other.targetId == this.targetId &&
          other.title == this.title &&
          other.body == this.body &&
          other.source == this.source &&
          other.sourceSuggestionId == this.sourceSuggestionId &&
          other.metadataJson == this.metadataJson &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ProjectNotesCompanion extends UpdateCompanion<ProjectNoteRow> {
  final Value<String> id;
  final Value<String> projectId;
  final Value<String?> targetType;
  final Value<String?> targetId;
  final Value<String> title;
  final Value<String> body;
  final Value<String> source;
  final Value<String?> sourceSuggestionId;
  final Value<String> metadataJson;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ProjectNotesCompanion({
    this.id = const Value.absent(),
    this.projectId = const Value.absent(),
    this.targetType = const Value.absent(),
    this.targetId = const Value.absent(),
    this.title = const Value.absent(),
    this.body = const Value.absent(),
    this.source = const Value.absent(),
    this.sourceSuggestionId = const Value.absent(),
    this.metadataJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProjectNotesCompanion.insert({
    required String id,
    required String projectId,
    this.targetType = const Value.absent(),
    this.targetId = const Value.absent(),
    required String title,
    required String body,
    this.source = const Value.absent(),
    this.sourceSuggestionId = const Value.absent(),
    this.metadataJson = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        projectId = Value(projectId),
        title = Value(title),
        body = Value(body),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<ProjectNoteRow> custom({
    Expression<String>? id,
    Expression<String>? projectId,
    Expression<String>? targetType,
    Expression<String>? targetId,
    Expression<String>? title,
    Expression<String>? body,
    Expression<String>? source,
    Expression<String>? sourceSuggestionId,
    Expression<String>? metadataJson,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (projectId != null) 'project_id': projectId,
      if (targetType != null) 'target_type': targetType,
      if (targetId != null) 'target_id': targetId,
      if (title != null) 'title': title,
      if (body != null) 'body': body,
      if (source != null) 'source': source,
      if (sourceSuggestionId != null)
        'source_suggestion_id': sourceSuggestionId,
      if (metadataJson != null) 'metadata_json': metadataJson,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProjectNotesCompanion copyWith(
      {Value<String>? id,
      Value<String>? projectId,
      Value<String?>? targetType,
      Value<String?>? targetId,
      Value<String>? title,
      Value<String>? body,
      Value<String>? source,
      Value<String?>? sourceSuggestionId,
      Value<String>? metadataJson,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return ProjectNotesCompanion(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      targetType: targetType ?? this.targetType,
      targetId: targetId ?? this.targetId,
      title: title ?? this.title,
      body: body ?? this.body,
      source: source ?? this.source,
      sourceSuggestionId: sourceSuggestionId ?? this.sourceSuggestionId,
      metadataJson: metadataJson ?? this.metadataJson,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<String>(projectId.value);
    }
    if (targetType.present) {
      map['target_type'] = Variable<String>(targetType.value);
    }
    if (targetId.present) {
      map['target_id'] = Variable<String>(targetId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (sourceSuggestionId.present) {
      map['source_suggestion_id'] = Variable<String>(sourceSuggestionId.value);
    }
    if (metadataJson.present) {
      map['metadata_json'] = Variable<String>(metadataJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProjectNotesCompanion(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('targetType: $targetType, ')
          ..write('targetId: $targetId, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('source: $source, ')
          ..write('sourceSuggestionId: $sourceSuggestionId, ')
          ..write('metadataJson: $metadataJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ResearchItemsTable extends ResearchItems
    with TableInfo<$ResearchItemsTable, ResearchItemRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ResearchItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _projectIdMeta =
      const VerificationMeta('projectId');
  @override
  late final GeneratedColumn<String> projectId = GeneratedColumn<String>(
      'project_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES projects (id)'));
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
      'kind', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _targetTypeMeta =
      const VerificationMeta('targetType');
  @override
  late final GeneratedColumn<String> targetType = GeneratedColumn<String>(
      'target_type', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _targetIdMeta =
      const VerificationMeta('targetId');
  @override
  late final GeneratedColumn<String> targetId = GeneratedColumn<String>(
      'target_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _uriMeta = const VerificationMeta('uri');
  @override
  late final GeneratedColumn<String> uri = GeneratedColumn<String>(
      'uri', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
      'body', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
      'source', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _tagsJsonMeta =
      const VerificationMeta('tagsJson');
  @override
  late final GeneratedColumn<String> tagsJson = GeneratedColumn<String>(
      'tags_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _metadataJsonMeta =
      const VerificationMeta('metadataJson');
  @override
  late final GeneratedColumn<String> metadataJson = GeneratedColumn<String>(
      'metadata_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('{}'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        projectId,
        kind,
        targetType,
        targetId,
        title,
        uri,
        body,
        source,
        tagsJson,
        metadataJson,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'research_items';
  @override
  VerificationContext validateIntegrity(Insertable<ResearchItemRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('project_id')) {
      context.handle(_projectIdMeta,
          projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta));
    } else if (isInserting) {
      context.missing(_projectIdMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
          _kindMeta, kind.isAcceptableOrUnknown(data['kind']!, _kindMeta));
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('target_type')) {
      context.handle(
          _targetTypeMeta,
          targetType.isAcceptableOrUnknown(
              data['target_type']!, _targetTypeMeta));
    }
    if (data.containsKey('target_id')) {
      context.handle(_targetIdMeta,
          targetId.isAcceptableOrUnknown(data['target_id']!, _targetIdMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('uri')) {
      context.handle(
          _uriMeta, uri.isAcceptableOrUnknown(data['uri']!, _uriMeta));
    }
    if (data.containsKey('body')) {
      context.handle(
          _bodyMeta, body.isAcceptableOrUnknown(data['body']!, _bodyMeta));
    }
    if (data.containsKey('source')) {
      context.handle(_sourceMeta,
          source.isAcceptableOrUnknown(data['source']!, _sourceMeta));
    }
    if (data.containsKey('tags_json')) {
      context.handle(_tagsJsonMeta,
          tagsJson.isAcceptableOrUnknown(data['tags_json']!, _tagsJsonMeta));
    }
    if (data.containsKey('metadata_json')) {
      context.handle(
          _metadataJsonMeta,
          metadataJson.isAcceptableOrUnknown(
              data['metadata_json']!, _metadataJsonMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ResearchItemRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ResearchItemRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      projectId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}project_id'])!,
      kind: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}kind'])!,
      targetType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}target_type']),
      targetId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}target_id']),
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      uri: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uri'])!,
      body: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}body'])!,
      source: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source'])!,
      tagsJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tags_json'])!,
      metadataJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}metadata_json'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $ResearchItemsTable createAlias(String alias) {
    return $ResearchItemsTable(attachedDatabase, alias);
  }
}

class ResearchItemRow extends DataClass implements Insertable<ResearchItemRow> {
  final String id;
  final String projectId;
  final String kind;
  final String? targetType;
  final String? targetId;
  final String title;
  final String uri;
  final String body;
  final String source;
  final String tagsJson;
  final String metadataJson;
  final DateTime createdAt;
  final DateTime updatedAt;
  const ResearchItemRow(
      {required this.id,
      required this.projectId,
      required this.kind,
      this.targetType,
      this.targetId,
      required this.title,
      required this.uri,
      required this.body,
      required this.source,
      required this.tagsJson,
      required this.metadataJson,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['project_id'] = Variable<String>(projectId);
    map['kind'] = Variable<String>(kind);
    if (!nullToAbsent || targetType != null) {
      map['target_type'] = Variable<String>(targetType);
    }
    if (!nullToAbsent || targetId != null) {
      map['target_id'] = Variable<String>(targetId);
    }
    map['title'] = Variable<String>(title);
    map['uri'] = Variable<String>(uri);
    map['body'] = Variable<String>(body);
    map['source'] = Variable<String>(source);
    map['tags_json'] = Variable<String>(tagsJson);
    map['metadata_json'] = Variable<String>(metadataJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ResearchItemsCompanion toCompanion(bool nullToAbsent) {
    return ResearchItemsCompanion(
      id: Value(id),
      projectId: Value(projectId),
      kind: Value(kind),
      targetType: targetType == null && nullToAbsent
          ? const Value.absent()
          : Value(targetType),
      targetId: targetId == null && nullToAbsent
          ? const Value.absent()
          : Value(targetId),
      title: Value(title),
      uri: Value(uri),
      body: Value(body),
      source: Value(source),
      tagsJson: Value(tagsJson),
      metadataJson: Value(metadataJson),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory ResearchItemRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ResearchItemRow(
      id: serializer.fromJson<String>(json['id']),
      projectId: serializer.fromJson<String>(json['projectId']),
      kind: serializer.fromJson<String>(json['kind']),
      targetType: serializer.fromJson<String?>(json['targetType']),
      targetId: serializer.fromJson<String?>(json['targetId']),
      title: serializer.fromJson<String>(json['title']),
      uri: serializer.fromJson<String>(json['uri']),
      body: serializer.fromJson<String>(json['body']),
      source: serializer.fromJson<String>(json['source']),
      tagsJson: serializer.fromJson<String>(json['tagsJson']),
      metadataJson: serializer.fromJson<String>(json['metadataJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'projectId': serializer.toJson<String>(projectId),
      'kind': serializer.toJson<String>(kind),
      'targetType': serializer.toJson<String?>(targetType),
      'targetId': serializer.toJson<String?>(targetId),
      'title': serializer.toJson<String>(title),
      'uri': serializer.toJson<String>(uri),
      'body': serializer.toJson<String>(body),
      'source': serializer.toJson<String>(source),
      'tagsJson': serializer.toJson<String>(tagsJson),
      'metadataJson': serializer.toJson<String>(metadataJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ResearchItemRow copyWith(
          {String? id,
          String? projectId,
          String? kind,
          Value<String?> targetType = const Value.absent(),
          Value<String?> targetId = const Value.absent(),
          String? title,
          String? uri,
          String? body,
          String? source,
          String? tagsJson,
          String? metadataJson,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      ResearchItemRow(
        id: id ?? this.id,
        projectId: projectId ?? this.projectId,
        kind: kind ?? this.kind,
        targetType: targetType.present ? targetType.value : this.targetType,
        targetId: targetId.present ? targetId.value : this.targetId,
        title: title ?? this.title,
        uri: uri ?? this.uri,
        body: body ?? this.body,
        source: source ?? this.source,
        tagsJson: tagsJson ?? this.tagsJson,
        metadataJson: metadataJson ?? this.metadataJson,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  ResearchItemRow copyWithCompanion(ResearchItemsCompanion data) {
    return ResearchItemRow(
      id: data.id.present ? data.id.value : this.id,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      kind: data.kind.present ? data.kind.value : this.kind,
      targetType:
          data.targetType.present ? data.targetType.value : this.targetType,
      targetId: data.targetId.present ? data.targetId.value : this.targetId,
      title: data.title.present ? data.title.value : this.title,
      uri: data.uri.present ? data.uri.value : this.uri,
      body: data.body.present ? data.body.value : this.body,
      source: data.source.present ? data.source.value : this.source,
      tagsJson: data.tagsJson.present ? data.tagsJson.value : this.tagsJson,
      metadataJson: data.metadataJson.present
          ? data.metadataJson.value
          : this.metadataJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ResearchItemRow(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('kind: $kind, ')
          ..write('targetType: $targetType, ')
          ..write('targetId: $targetId, ')
          ..write('title: $title, ')
          ..write('uri: $uri, ')
          ..write('body: $body, ')
          ..write('source: $source, ')
          ..write('tagsJson: $tagsJson, ')
          ..write('metadataJson: $metadataJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, projectId, kind, targetType, targetId,
      title, uri, body, source, tagsJson, metadataJson, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ResearchItemRow &&
          other.id == this.id &&
          other.projectId == this.projectId &&
          other.kind == this.kind &&
          other.targetType == this.targetType &&
          other.targetId == this.targetId &&
          other.title == this.title &&
          other.uri == this.uri &&
          other.body == this.body &&
          other.source == this.source &&
          other.tagsJson == this.tagsJson &&
          other.metadataJson == this.metadataJson &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ResearchItemsCompanion extends UpdateCompanion<ResearchItemRow> {
  final Value<String> id;
  final Value<String> projectId;
  final Value<String> kind;
  final Value<String?> targetType;
  final Value<String?> targetId;
  final Value<String> title;
  final Value<String> uri;
  final Value<String> body;
  final Value<String> source;
  final Value<String> tagsJson;
  final Value<String> metadataJson;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ResearchItemsCompanion({
    this.id = const Value.absent(),
    this.projectId = const Value.absent(),
    this.kind = const Value.absent(),
    this.targetType = const Value.absent(),
    this.targetId = const Value.absent(),
    this.title = const Value.absent(),
    this.uri = const Value.absent(),
    this.body = const Value.absent(),
    this.source = const Value.absent(),
    this.tagsJson = const Value.absent(),
    this.metadataJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ResearchItemsCompanion.insert({
    required String id,
    required String projectId,
    required String kind,
    this.targetType = const Value.absent(),
    this.targetId = const Value.absent(),
    required String title,
    this.uri = const Value.absent(),
    this.body = const Value.absent(),
    this.source = const Value.absent(),
    this.tagsJson = const Value.absent(),
    this.metadataJson = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        projectId = Value(projectId),
        kind = Value(kind),
        title = Value(title),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<ResearchItemRow> custom({
    Expression<String>? id,
    Expression<String>? projectId,
    Expression<String>? kind,
    Expression<String>? targetType,
    Expression<String>? targetId,
    Expression<String>? title,
    Expression<String>? uri,
    Expression<String>? body,
    Expression<String>? source,
    Expression<String>? tagsJson,
    Expression<String>? metadataJson,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (projectId != null) 'project_id': projectId,
      if (kind != null) 'kind': kind,
      if (targetType != null) 'target_type': targetType,
      if (targetId != null) 'target_id': targetId,
      if (title != null) 'title': title,
      if (uri != null) 'uri': uri,
      if (body != null) 'body': body,
      if (source != null) 'source': source,
      if (tagsJson != null) 'tags_json': tagsJson,
      if (metadataJson != null) 'metadata_json': metadataJson,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ResearchItemsCompanion copyWith(
      {Value<String>? id,
      Value<String>? projectId,
      Value<String>? kind,
      Value<String?>? targetType,
      Value<String?>? targetId,
      Value<String>? title,
      Value<String>? uri,
      Value<String>? body,
      Value<String>? source,
      Value<String>? tagsJson,
      Value<String>? metadataJson,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return ResearchItemsCompanion(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      kind: kind ?? this.kind,
      targetType: targetType ?? this.targetType,
      targetId: targetId ?? this.targetId,
      title: title ?? this.title,
      uri: uri ?? this.uri,
      body: body ?? this.body,
      source: source ?? this.source,
      tagsJson: tagsJson ?? this.tagsJson,
      metadataJson: metadataJson ?? this.metadataJson,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<String>(projectId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (targetType.present) {
      map['target_type'] = Variable<String>(targetType.value);
    }
    if (targetId.present) {
      map['target_id'] = Variable<String>(targetId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (uri.present) {
      map['uri'] = Variable<String>(uri.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (tagsJson.present) {
      map['tags_json'] = Variable<String>(tagsJson.value);
    }
    if (metadataJson.present) {
      map['metadata_json'] = Variable<String>(metadataJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ResearchItemsCompanion(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('kind: $kind, ')
          ..write('targetType: $targetType, ')
          ..write('targetId: $targetId, ')
          ..write('title: $title, ')
          ..write('uri: $uri, ')
          ..write('body: $body, ')
          ..write('source: $source, ')
          ..write('tagsJson: $tagsJson, ')
          ..write('metadataJson: $metadataJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AIProviderConfigsTable extends AIProviderConfigs
    with TableInfo<$AIProviderConfigsTable, AIProviderConfigRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AIProviderConfigsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
      'kind', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _displayNameMeta =
      const VerificationMeta('displayName');
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
      'display_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _modelNameMeta =
      const VerificationMeta('modelName');
  @override
  late final GeneratedColumn<String> modelName = GeneratedColumn<String>(
      'model_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _baseUrlMeta =
      const VerificationMeta('baseUrl');
  @override
  late final GeneratedColumn<String> baseUrl = GeneratedColumn<String>(
      'base_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _encryptedApiKeyRefMeta =
      const VerificationMeta('encryptedApiKeyRef');
  @override
  late final GeneratedColumn<String> encryptedApiKeyRef =
      GeneratedColumn<String>('encrypted_api_key_ref', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _parametersJsonMeta =
      const VerificationMeta('parametersJson');
  @override
  late final GeneratedColumn<String> parametersJson = GeneratedColumn<String>(
      'parameters_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('{}'));
  static const VerificationMeta _enabledMeta =
      const VerificationMeta('enabled');
  @override
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
      'enabled', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("enabled" IN (0, 1))'));
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        kind,
        displayName,
        modelName,
        baseUrl,
        encryptedApiKeyRef,
        parametersJson,
        enabled,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'a_i_provider_configs';
  @override
  VerificationContext validateIntegrity(
      Insertable<AIProviderConfigRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
          _kindMeta, kind.isAcceptableOrUnknown(data['kind']!, _kindMeta));
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
          _displayNameMeta,
          displayName.isAcceptableOrUnknown(
              data['display_name']!, _displayNameMeta));
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('model_name')) {
      context.handle(_modelNameMeta,
          modelName.isAcceptableOrUnknown(data['model_name']!, _modelNameMeta));
    } else if (isInserting) {
      context.missing(_modelNameMeta);
    }
    if (data.containsKey('base_url')) {
      context.handle(_baseUrlMeta,
          baseUrl.isAcceptableOrUnknown(data['base_url']!, _baseUrlMeta));
    }
    if (data.containsKey('encrypted_api_key_ref')) {
      context.handle(
          _encryptedApiKeyRefMeta,
          encryptedApiKeyRef.isAcceptableOrUnknown(
              data['encrypted_api_key_ref']!, _encryptedApiKeyRefMeta));
    }
    if (data.containsKey('parameters_json')) {
      context.handle(
          _parametersJsonMeta,
          parametersJson.isAcceptableOrUnknown(
              data['parameters_json']!, _parametersJsonMeta));
    }
    if (data.containsKey('enabled')) {
      context.handle(_enabledMeta,
          enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta));
    } else if (isInserting) {
      context.missing(_enabledMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AIProviderConfigRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AIProviderConfigRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      kind: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}kind'])!,
      displayName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}display_name'])!,
      modelName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}model_name'])!,
      baseUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}base_url']),
      encryptedApiKeyRef: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}encrypted_api_key_ref']),
      parametersJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}parameters_json'])!,
      enabled: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}enabled'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $AIProviderConfigsTable createAlias(String alias) {
    return $AIProviderConfigsTable(attachedDatabase, alias);
  }
}

class AIProviderConfigRow extends DataClass
    implements Insertable<AIProviderConfigRow> {
  final String id;
  final String kind;
  final String displayName;
  final String modelName;
  final String? baseUrl;
  final String? encryptedApiKeyRef;
  final String parametersJson;
  final bool enabled;
  final DateTime updatedAt;
  const AIProviderConfigRow(
      {required this.id,
      required this.kind,
      required this.displayName,
      required this.modelName,
      this.baseUrl,
      this.encryptedApiKeyRef,
      required this.parametersJson,
      required this.enabled,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['kind'] = Variable<String>(kind);
    map['display_name'] = Variable<String>(displayName);
    map['model_name'] = Variable<String>(modelName);
    if (!nullToAbsent || baseUrl != null) {
      map['base_url'] = Variable<String>(baseUrl);
    }
    if (!nullToAbsent || encryptedApiKeyRef != null) {
      map['encrypted_api_key_ref'] = Variable<String>(encryptedApiKeyRef);
    }
    map['parameters_json'] = Variable<String>(parametersJson);
    map['enabled'] = Variable<bool>(enabled);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  AIProviderConfigsCompanion toCompanion(bool nullToAbsent) {
    return AIProviderConfigsCompanion(
      id: Value(id),
      kind: Value(kind),
      displayName: Value(displayName),
      modelName: Value(modelName),
      baseUrl: baseUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(baseUrl),
      encryptedApiKeyRef: encryptedApiKeyRef == null && nullToAbsent
          ? const Value.absent()
          : Value(encryptedApiKeyRef),
      parametersJson: Value(parametersJson),
      enabled: Value(enabled),
      updatedAt: Value(updatedAt),
    );
  }

  factory AIProviderConfigRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AIProviderConfigRow(
      id: serializer.fromJson<String>(json['id']),
      kind: serializer.fromJson<String>(json['kind']),
      displayName: serializer.fromJson<String>(json['displayName']),
      modelName: serializer.fromJson<String>(json['modelName']),
      baseUrl: serializer.fromJson<String?>(json['baseUrl']),
      encryptedApiKeyRef:
          serializer.fromJson<String?>(json['encryptedApiKeyRef']),
      parametersJson: serializer.fromJson<String>(json['parametersJson']),
      enabled: serializer.fromJson<bool>(json['enabled']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'kind': serializer.toJson<String>(kind),
      'displayName': serializer.toJson<String>(displayName),
      'modelName': serializer.toJson<String>(modelName),
      'baseUrl': serializer.toJson<String?>(baseUrl),
      'encryptedApiKeyRef': serializer.toJson<String?>(encryptedApiKeyRef),
      'parametersJson': serializer.toJson<String>(parametersJson),
      'enabled': serializer.toJson<bool>(enabled),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  AIProviderConfigRow copyWith(
          {String? id,
          String? kind,
          String? displayName,
          String? modelName,
          Value<String?> baseUrl = const Value.absent(),
          Value<String?> encryptedApiKeyRef = const Value.absent(),
          String? parametersJson,
          bool? enabled,
          DateTime? updatedAt}) =>
      AIProviderConfigRow(
        id: id ?? this.id,
        kind: kind ?? this.kind,
        displayName: displayName ?? this.displayName,
        modelName: modelName ?? this.modelName,
        baseUrl: baseUrl.present ? baseUrl.value : this.baseUrl,
        encryptedApiKeyRef: encryptedApiKeyRef.present
            ? encryptedApiKeyRef.value
            : this.encryptedApiKeyRef,
        parametersJson: parametersJson ?? this.parametersJson,
        enabled: enabled ?? this.enabled,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  AIProviderConfigRow copyWithCompanion(AIProviderConfigsCompanion data) {
    return AIProviderConfigRow(
      id: data.id.present ? data.id.value : this.id,
      kind: data.kind.present ? data.kind.value : this.kind,
      displayName:
          data.displayName.present ? data.displayName.value : this.displayName,
      modelName: data.modelName.present ? data.modelName.value : this.modelName,
      baseUrl: data.baseUrl.present ? data.baseUrl.value : this.baseUrl,
      encryptedApiKeyRef: data.encryptedApiKeyRef.present
          ? data.encryptedApiKeyRef.value
          : this.encryptedApiKeyRef,
      parametersJson: data.parametersJson.present
          ? data.parametersJson.value
          : this.parametersJson,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AIProviderConfigRow(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('displayName: $displayName, ')
          ..write('modelName: $modelName, ')
          ..write('baseUrl: $baseUrl, ')
          ..write('encryptedApiKeyRef: $encryptedApiKeyRef, ')
          ..write('parametersJson: $parametersJson, ')
          ..write('enabled: $enabled, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, kind, displayName, modelName, baseUrl,
      encryptedApiKeyRef, parametersJson, enabled, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AIProviderConfigRow &&
          other.id == this.id &&
          other.kind == this.kind &&
          other.displayName == this.displayName &&
          other.modelName == this.modelName &&
          other.baseUrl == this.baseUrl &&
          other.encryptedApiKeyRef == this.encryptedApiKeyRef &&
          other.parametersJson == this.parametersJson &&
          other.enabled == this.enabled &&
          other.updatedAt == this.updatedAt);
}

class AIProviderConfigsCompanion extends UpdateCompanion<AIProviderConfigRow> {
  final Value<String> id;
  final Value<String> kind;
  final Value<String> displayName;
  final Value<String> modelName;
  final Value<String?> baseUrl;
  final Value<String?> encryptedApiKeyRef;
  final Value<String> parametersJson;
  final Value<bool> enabled;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const AIProviderConfigsCompanion({
    this.id = const Value.absent(),
    this.kind = const Value.absent(),
    this.displayName = const Value.absent(),
    this.modelName = const Value.absent(),
    this.baseUrl = const Value.absent(),
    this.encryptedApiKeyRef = const Value.absent(),
    this.parametersJson = const Value.absent(),
    this.enabled = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AIProviderConfigsCompanion.insert({
    required String id,
    required String kind,
    required String displayName,
    required String modelName,
    this.baseUrl = const Value.absent(),
    this.encryptedApiKeyRef = const Value.absent(),
    this.parametersJson = const Value.absent(),
    required bool enabled,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        kind = Value(kind),
        displayName = Value(displayName),
        modelName = Value(modelName),
        enabled = Value(enabled),
        updatedAt = Value(updatedAt);
  static Insertable<AIProviderConfigRow> custom({
    Expression<String>? id,
    Expression<String>? kind,
    Expression<String>? displayName,
    Expression<String>? modelName,
    Expression<String>? baseUrl,
    Expression<String>? encryptedApiKeyRef,
    Expression<String>? parametersJson,
    Expression<bool>? enabled,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (kind != null) 'kind': kind,
      if (displayName != null) 'display_name': displayName,
      if (modelName != null) 'model_name': modelName,
      if (baseUrl != null) 'base_url': baseUrl,
      if (encryptedApiKeyRef != null)
        'encrypted_api_key_ref': encryptedApiKeyRef,
      if (parametersJson != null) 'parameters_json': parametersJson,
      if (enabled != null) 'enabled': enabled,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AIProviderConfigsCompanion copyWith(
      {Value<String>? id,
      Value<String>? kind,
      Value<String>? displayName,
      Value<String>? modelName,
      Value<String?>? baseUrl,
      Value<String?>? encryptedApiKeyRef,
      Value<String>? parametersJson,
      Value<bool>? enabled,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return AIProviderConfigsCompanion(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      displayName: displayName ?? this.displayName,
      modelName: modelName ?? this.modelName,
      baseUrl: baseUrl ?? this.baseUrl,
      encryptedApiKeyRef: encryptedApiKeyRef ?? this.encryptedApiKeyRef,
      parametersJson: parametersJson ?? this.parametersJson,
      enabled: enabled ?? this.enabled,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (modelName.present) {
      map['model_name'] = Variable<String>(modelName.value);
    }
    if (baseUrl.present) {
      map['base_url'] = Variable<String>(baseUrl.value);
    }
    if (encryptedApiKeyRef.present) {
      map['encrypted_api_key_ref'] = Variable<String>(encryptedApiKeyRef.value);
    }
    if (parametersJson.present) {
      map['parameters_json'] = Variable<String>(parametersJson.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AIProviderConfigsCompanion(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('displayName: $displayName, ')
          ..write('modelName: $modelName, ')
          ..write('baseUrl: $baseUrl, ')
          ..write('encryptedApiKeyRef: $encryptedApiKeyRef, ')
          ..write('parametersJson: $parametersJson, ')
          ..write('enabled: $enabled, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppPreferencesTable extends AppPreferences
    with TableInfo<$AppPreferencesTable, AppPreferenceRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppPreferencesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
      'key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
      'value', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [key, value, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_preferences';
  @override
  VerificationContext validateIntegrity(Insertable<AppPreferenceRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
          _keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppPreferenceRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppPreferenceRow(
      key: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}value'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $AppPreferencesTable createAlias(String alias) {
    return $AppPreferencesTable(attachedDatabase, alias);
  }
}

class AppPreferenceRow extends DataClass
    implements Insertable<AppPreferenceRow> {
  final String key;
  final String value;
  final DateTime updatedAt;
  const AppPreferenceRow(
      {required this.key, required this.value, required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  AppPreferencesCompanion toCompanion(bool nullToAbsent) {
    return AppPreferencesCompanion(
      key: Value(key),
      value: Value(value),
      updatedAt: Value(updatedAt),
    );
  }

  factory AppPreferenceRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppPreferenceRow(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  AppPreferenceRow copyWith(
          {String? key, String? value, DateTime? updatedAt}) =>
      AppPreferenceRow(
        key: key ?? this.key,
        value: value ?? this.value,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  AppPreferenceRow copyWithCompanion(AppPreferencesCompanion data) {
    return AppPreferenceRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppPreferenceRow(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppPreferenceRow &&
          other.key == this.key &&
          other.value == this.value &&
          other.updatedAt == this.updatedAt);
}

class AppPreferencesCompanion extends UpdateCompanion<AppPreferenceRow> {
  final Value<String> key;
  final Value<String> value;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const AppPreferencesCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppPreferencesCompanion.insert({
    required String key,
    required String value,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : key = Value(key),
        value = Value(value),
        updatedAt = Value(updatedAt);
  static Insertable<AppPreferenceRow> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppPreferencesCompanion copyWith(
      {Value<String>? key,
      Value<String>? value,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return AppPreferencesCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppPreferencesCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MetricEventsTable extends MetricEvents
    with TableInfo<$MetricEventsTable, MetricEventRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MetricEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _projectIdMeta =
      const VerificationMeta('projectId');
  @override
  late final GeneratedColumn<String> projectId = GeneratedColumn<String>(
      'project_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES projects (id)'));
  static const VerificationMeta _eventTypeMeta =
      const VerificationMeta('eventType');
  @override
  late final GeneratedColumn<String> eventType = GeneratedColumn<String>(
      'event_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<double> value = GeneratedColumn<double>(
      'value', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _metadataJsonMeta =
      const VerificationMeta('metadataJson');
  @override
  late final GeneratedColumn<String> metadataJson = GeneratedColumn<String>(
      'metadata_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('{}'));
  static const VerificationMeta _occurredAtMeta =
      const VerificationMeta('occurredAt');
  @override
  late final GeneratedColumn<DateTime> occurredAt = GeneratedColumn<DateTime>(
      'occurred_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, projectId, eventType, value, metadataJson, occurredAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'metric_events';
  @override
  VerificationContext validateIntegrity(Insertable<MetricEventRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('project_id')) {
      context.handle(_projectIdMeta,
          projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta));
    } else if (isInserting) {
      context.missing(_projectIdMeta);
    }
    if (data.containsKey('event_type')) {
      context.handle(_eventTypeMeta,
          eventType.isAcceptableOrUnknown(data['event_type']!, _eventTypeMeta));
    } else if (isInserting) {
      context.missing(_eventTypeMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    }
    if (data.containsKey('metadata_json')) {
      context.handle(
          _metadataJsonMeta,
          metadataJson.isAcceptableOrUnknown(
              data['metadata_json']!, _metadataJsonMeta));
    }
    if (data.containsKey('occurred_at')) {
      context.handle(
          _occurredAtMeta,
          occurredAt.isAcceptableOrUnknown(
              data['occurred_at']!, _occurredAtMeta));
    } else if (isInserting) {
      context.missing(_occurredAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MetricEventRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MetricEventRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      projectId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}project_id'])!,
      eventType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}event_type'])!,
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}value']),
      metadataJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}metadata_json'])!,
      occurredAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}occurred_at'])!,
    );
  }

  @override
  $MetricEventsTable createAlias(String alias) {
    return $MetricEventsTable(attachedDatabase, alias);
  }
}

class MetricEventRow extends DataClass implements Insertable<MetricEventRow> {
  final String id;
  final String projectId;
  final String eventType;
  final double? value;
  final String metadataJson;
  final DateTime occurredAt;
  const MetricEventRow(
      {required this.id,
      required this.projectId,
      required this.eventType,
      this.value,
      required this.metadataJson,
      required this.occurredAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['project_id'] = Variable<String>(projectId);
    map['event_type'] = Variable<String>(eventType);
    if (!nullToAbsent || value != null) {
      map['value'] = Variable<double>(value);
    }
    map['metadata_json'] = Variable<String>(metadataJson);
    map['occurred_at'] = Variable<DateTime>(occurredAt);
    return map;
  }

  MetricEventsCompanion toCompanion(bool nullToAbsent) {
    return MetricEventsCompanion(
      id: Value(id),
      projectId: Value(projectId),
      eventType: Value(eventType),
      value:
          value == null && nullToAbsent ? const Value.absent() : Value(value),
      metadataJson: Value(metadataJson),
      occurredAt: Value(occurredAt),
    );
  }

  factory MetricEventRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MetricEventRow(
      id: serializer.fromJson<String>(json['id']),
      projectId: serializer.fromJson<String>(json['projectId']),
      eventType: serializer.fromJson<String>(json['eventType']),
      value: serializer.fromJson<double?>(json['value']),
      metadataJson: serializer.fromJson<String>(json['metadataJson']),
      occurredAt: serializer.fromJson<DateTime>(json['occurredAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'projectId': serializer.toJson<String>(projectId),
      'eventType': serializer.toJson<String>(eventType),
      'value': serializer.toJson<double?>(value),
      'metadataJson': serializer.toJson<String>(metadataJson),
      'occurredAt': serializer.toJson<DateTime>(occurredAt),
    };
  }

  MetricEventRow copyWith(
          {String? id,
          String? projectId,
          String? eventType,
          Value<double?> value = const Value.absent(),
          String? metadataJson,
          DateTime? occurredAt}) =>
      MetricEventRow(
        id: id ?? this.id,
        projectId: projectId ?? this.projectId,
        eventType: eventType ?? this.eventType,
        value: value.present ? value.value : this.value,
        metadataJson: metadataJson ?? this.metadataJson,
        occurredAt: occurredAt ?? this.occurredAt,
      );
  MetricEventRow copyWithCompanion(MetricEventsCompanion data) {
    return MetricEventRow(
      id: data.id.present ? data.id.value : this.id,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      eventType: data.eventType.present ? data.eventType.value : this.eventType,
      value: data.value.present ? data.value.value : this.value,
      metadataJson: data.metadataJson.present
          ? data.metadataJson.value
          : this.metadataJson,
      occurredAt:
          data.occurredAt.present ? data.occurredAt.value : this.occurredAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MetricEventRow(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('eventType: $eventType, ')
          ..write('value: $value, ')
          ..write('metadataJson: $metadataJson, ')
          ..write('occurredAt: $occurredAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, projectId, eventType, value, metadataJson, occurredAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MetricEventRow &&
          other.id == this.id &&
          other.projectId == this.projectId &&
          other.eventType == this.eventType &&
          other.value == this.value &&
          other.metadataJson == this.metadataJson &&
          other.occurredAt == this.occurredAt);
}

class MetricEventsCompanion extends UpdateCompanion<MetricEventRow> {
  final Value<String> id;
  final Value<String> projectId;
  final Value<String> eventType;
  final Value<double?> value;
  final Value<String> metadataJson;
  final Value<DateTime> occurredAt;
  final Value<int> rowid;
  const MetricEventsCompanion({
    this.id = const Value.absent(),
    this.projectId = const Value.absent(),
    this.eventType = const Value.absent(),
    this.value = const Value.absent(),
    this.metadataJson = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MetricEventsCompanion.insert({
    required String id,
    required String projectId,
    required String eventType,
    this.value = const Value.absent(),
    this.metadataJson = const Value.absent(),
    required DateTime occurredAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        projectId = Value(projectId),
        eventType = Value(eventType),
        occurredAt = Value(occurredAt);
  static Insertable<MetricEventRow> custom({
    Expression<String>? id,
    Expression<String>? projectId,
    Expression<String>? eventType,
    Expression<double>? value,
    Expression<String>? metadataJson,
    Expression<DateTime>? occurredAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (projectId != null) 'project_id': projectId,
      if (eventType != null) 'event_type': eventType,
      if (value != null) 'value': value,
      if (metadataJson != null) 'metadata_json': metadataJson,
      if (occurredAt != null) 'occurred_at': occurredAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MetricEventsCompanion copyWith(
      {Value<String>? id,
      Value<String>? projectId,
      Value<String>? eventType,
      Value<double?>? value,
      Value<String>? metadataJson,
      Value<DateTime>? occurredAt,
      Value<int>? rowid}) {
    return MetricEventsCompanion(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      eventType: eventType ?? this.eventType,
      value: value ?? this.value,
      metadataJson: metadataJson ?? this.metadataJson,
      occurredAt: occurredAt ?? this.occurredAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<String>(projectId.value);
    }
    if (eventType.present) {
      map['event_type'] = Variable<String>(eventType.value);
    }
    if (value.present) {
      map['value'] = Variable<double>(value.value);
    }
    if (metadataJson.present) {
      map['metadata_json'] = Variable<String>(metadataJson.value);
    }
    if (occurredAt.present) {
      map['occurred_at'] = Variable<DateTime>(occurredAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MetricEventsCompanion(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('eventType: $eventType, ')
          ..write('value: $value, ')
          ..write('metadataJson: $metadataJson, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ProjectsTable projects = $ProjectsTable(this);
  late final $ChaptersTable chapters = $ChaptersTable(this);
  late final $ScenesTable scenes = $ScenesTable(this);
  late final $SceneSnapshotsTable sceneSnapshots = $SceneSnapshotsTable(this);
  late final $CatalogItemsTable catalogItems = $CatalogItemsTable(this);
  late final $RelationshipsTable relationships = $RelationshipsTable(this);
  late final $AISuggestionsTable aISuggestions = $AISuggestionsTable(this);
  late final $ProjectNotesTable projectNotes = $ProjectNotesTable(this);
  late final $ResearchItemsTable researchItems = $ResearchItemsTable(this);
  late final $AIProviderConfigsTable aIProviderConfigs =
      $AIProviderConfigsTable(this);
  late final $AppPreferencesTable appPreferences = $AppPreferencesTable(this);
  late final $MetricEventsTable metricEvents = $MetricEventsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        projects,
        chapters,
        scenes,
        sceneSnapshots,
        catalogItems,
        relationships,
        aISuggestions,
        projectNotes,
        researchItems,
        aIProviderConfigs,
        appPreferences,
        metricEvents
      ];
}

typedef $$ProjectsTableCreateCompanionBuilder = ProjectsCompanion Function({
  required String id,
  required String title,
  Value<String> description,
  required String projectType,
  required String languageCode,
  required String status,
  Value<int?> wordTarget,
  required bool aiEnabled,
  required bool cloudSyncEnabled,
  required bool noAiNoCloud,
  Value<String> metadataJson,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$ProjectsTableUpdateCompanionBuilder = ProjectsCompanion Function({
  Value<String> id,
  Value<String> title,
  Value<String> description,
  Value<String> projectType,
  Value<String> languageCode,
  Value<String> status,
  Value<int?> wordTarget,
  Value<bool> aiEnabled,
  Value<bool> cloudSyncEnabled,
  Value<bool> noAiNoCloud,
  Value<String> metadataJson,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

final class $$ProjectsTableReferences
    extends BaseReferences<_$AppDatabase, $ProjectsTable, ProjectRow> {
  $$ProjectsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ChaptersTable, List<ChapterRow>>
      _chaptersRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.chapters,
              aliasName: 'projects__id__chapters__project_id');

  $$ChaptersTableProcessedTableManager get chaptersRefs {
    final manager = $$ChaptersTableTableManager($_db, $_db.chapters)
        .filter((f) => f.projectId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_chaptersRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$ScenesTable, List<SceneRow>> _scenesRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.scenes,
          aliasName: 'projects__id__scenes__project_id');

  $$ScenesTableProcessedTableManager get scenesRefs {
    final manager = $$ScenesTableTableManager($_db, $_db.scenes)
        .filter((f) => f.projectId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_scenesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$SceneSnapshotsTable, List<SceneSnapshotRow>>
      _sceneSnapshotsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.sceneSnapshots,
              aliasName: 'projects__id__scene_snapshots__project_id');

  $$SceneSnapshotsTableProcessedTableManager get sceneSnapshotsRefs {
    final manager = $$SceneSnapshotsTableTableManager($_db, $_db.sceneSnapshots)
        .filter((f) => f.projectId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_sceneSnapshotsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$CatalogItemsTable, List<CatalogItemRow>>
      _catalogItemsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.catalogItems,
              aliasName: 'projects__id__catalog_items__project_id');

  $$CatalogItemsTableProcessedTableManager get catalogItemsRefs {
    final manager = $$CatalogItemsTableTableManager($_db, $_db.catalogItems)
        .filter((f) => f.projectId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_catalogItemsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$RelationshipsTable, List<RelationshipRow>>
      _relationshipsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.relationships,
              aliasName: 'projects__id__relationships__project_id');

  $$RelationshipsTableProcessedTableManager get relationshipsRefs {
    final manager = $$RelationshipsTableTableManager($_db, $_db.relationships)
        .filter((f) => f.projectId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_relationshipsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$AISuggestionsTable, List<AISuggestionRow>>
      _aISuggestionsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.aISuggestions,
              aliasName: 'projects__id__a_i_suggestions__project_id');

  $$AISuggestionsTableProcessedTableManager get aISuggestionsRefs {
    final manager = $$AISuggestionsTableTableManager($_db, $_db.aISuggestions)
        .filter((f) => f.projectId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_aISuggestionsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$ProjectNotesTable, List<ProjectNoteRow>>
      _projectNotesRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.projectNotes,
              aliasName: 'projects__id__project_notes__project_id');

  $$ProjectNotesTableProcessedTableManager get projectNotesRefs {
    final manager = $$ProjectNotesTableTableManager($_db, $_db.projectNotes)
        .filter((f) => f.projectId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_projectNotesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$ResearchItemsTable, List<ResearchItemRow>>
      _researchItemsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.researchItems,
              aliasName: 'projects__id__research_items__project_id');

  $$ResearchItemsTableProcessedTableManager get researchItemsRefs {
    final manager = $$ResearchItemsTableTableManager($_db, $_db.researchItems)
        .filter((f) => f.projectId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_researchItemsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$MetricEventsTable, List<MetricEventRow>>
      _metricEventsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.metricEvents,
              aliasName: 'projects__id__metric_events__project_id');

  $$MetricEventsTableProcessedTableManager get metricEventsRefs {
    final manager = $$MetricEventsTableTableManager($_db, $_db.metricEvents)
        .filter((f) => f.projectId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_metricEventsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$ProjectsTableFilterComposer
    extends Composer<_$AppDatabase, $ProjectsTable> {
  $$ProjectsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get projectType => $composableBuilder(
      column: $table.projectType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get languageCode => $composableBuilder(
      column: $table.languageCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get wordTarget => $composableBuilder(
      column: $table.wordTarget, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get aiEnabled => $composableBuilder(
      column: $table.aiEnabled, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get cloudSyncEnabled => $composableBuilder(
      column: $table.cloudSyncEnabled,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get noAiNoCloud => $composableBuilder(
      column: $table.noAiNoCloud, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get metadataJson => $composableBuilder(
      column: $table.metadataJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  Expression<bool> chaptersRefs(
      Expression<bool> Function($$ChaptersTableFilterComposer f) f) {
    final $$ChaptersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.chapters,
        getReferencedColumn: (t) => t.projectId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ChaptersTableFilterComposer(
              $db: $db,
              $table: $db.chapters,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> scenesRefs(
      Expression<bool> Function($$ScenesTableFilterComposer f) f) {
    final $$ScenesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.scenes,
        getReferencedColumn: (t) => t.projectId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ScenesTableFilterComposer(
              $db: $db,
              $table: $db.scenes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> sceneSnapshotsRefs(
      Expression<bool> Function($$SceneSnapshotsTableFilterComposer f) f) {
    final $$SceneSnapshotsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.sceneSnapshots,
        getReferencedColumn: (t) => t.projectId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SceneSnapshotsTableFilterComposer(
              $db: $db,
              $table: $db.sceneSnapshots,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> catalogItemsRefs(
      Expression<bool> Function($$CatalogItemsTableFilterComposer f) f) {
    final $$CatalogItemsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.catalogItems,
        getReferencedColumn: (t) => t.projectId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CatalogItemsTableFilterComposer(
              $db: $db,
              $table: $db.catalogItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> relationshipsRefs(
      Expression<bool> Function($$RelationshipsTableFilterComposer f) f) {
    final $$RelationshipsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.relationships,
        getReferencedColumn: (t) => t.projectId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RelationshipsTableFilterComposer(
              $db: $db,
              $table: $db.relationships,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> aISuggestionsRefs(
      Expression<bool> Function($$AISuggestionsTableFilterComposer f) f) {
    final $$AISuggestionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.aISuggestions,
        getReferencedColumn: (t) => t.projectId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AISuggestionsTableFilterComposer(
              $db: $db,
              $table: $db.aISuggestions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> projectNotesRefs(
      Expression<bool> Function($$ProjectNotesTableFilterComposer f) f) {
    final $$ProjectNotesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.projectNotes,
        getReferencedColumn: (t) => t.projectId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProjectNotesTableFilterComposer(
              $db: $db,
              $table: $db.projectNotes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> researchItemsRefs(
      Expression<bool> Function($$ResearchItemsTableFilterComposer f) f) {
    final $$ResearchItemsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.researchItems,
        getReferencedColumn: (t) => t.projectId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ResearchItemsTableFilterComposer(
              $db: $db,
              $table: $db.researchItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> metricEventsRefs(
      Expression<bool> Function($$MetricEventsTableFilterComposer f) f) {
    final $$MetricEventsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.metricEvents,
        getReferencedColumn: (t) => t.projectId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MetricEventsTableFilterComposer(
              $db: $db,
              $table: $db.metricEvents,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ProjectsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProjectsTable> {
  $$ProjectsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get projectType => $composableBuilder(
      column: $table.projectType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get languageCode => $composableBuilder(
      column: $table.languageCode,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get wordTarget => $composableBuilder(
      column: $table.wordTarget, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get aiEnabled => $composableBuilder(
      column: $table.aiEnabled, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get cloudSyncEnabled => $composableBuilder(
      column: $table.cloudSyncEnabled,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get noAiNoCloud => $composableBuilder(
      column: $table.noAiNoCloud, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get metadataJson => $composableBuilder(
      column: $table.metadataJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$ProjectsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProjectsTable> {
  $$ProjectsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get projectType => $composableBuilder(
      column: $table.projectType, builder: (column) => column);

  GeneratedColumn<String> get languageCode => $composableBuilder(
      column: $table.languageCode, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get wordTarget => $composableBuilder(
      column: $table.wordTarget, builder: (column) => column);

  GeneratedColumn<bool> get aiEnabled =>
      $composableBuilder(column: $table.aiEnabled, builder: (column) => column);

  GeneratedColumn<bool> get cloudSyncEnabled => $composableBuilder(
      column: $table.cloudSyncEnabled, builder: (column) => column);

  GeneratedColumn<bool> get noAiNoCloud => $composableBuilder(
      column: $table.noAiNoCloud, builder: (column) => column);

  GeneratedColumn<String> get metadataJson => $composableBuilder(
      column: $table.metadataJson, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> chaptersRefs<T extends Object>(
      Expression<T> Function($$ChaptersTableAnnotationComposer a) f) {
    final $$ChaptersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.chapters,
        getReferencedColumn: (t) => t.projectId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ChaptersTableAnnotationComposer(
              $db: $db,
              $table: $db.chapters,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> scenesRefs<T extends Object>(
      Expression<T> Function($$ScenesTableAnnotationComposer a) f) {
    final $$ScenesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.scenes,
        getReferencedColumn: (t) => t.projectId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ScenesTableAnnotationComposer(
              $db: $db,
              $table: $db.scenes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> sceneSnapshotsRefs<T extends Object>(
      Expression<T> Function($$SceneSnapshotsTableAnnotationComposer a) f) {
    final $$SceneSnapshotsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.sceneSnapshots,
        getReferencedColumn: (t) => t.projectId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SceneSnapshotsTableAnnotationComposer(
              $db: $db,
              $table: $db.sceneSnapshots,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> catalogItemsRefs<T extends Object>(
      Expression<T> Function($$CatalogItemsTableAnnotationComposer a) f) {
    final $$CatalogItemsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.catalogItems,
        getReferencedColumn: (t) => t.projectId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CatalogItemsTableAnnotationComposer(
              $db: $db,
              $table: $db.catalogItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> relationshipsRefs<T extends Object>(
      Expression<T> Function($$RelationshipsTableAnnotationComposer a) f) {
    final $$RelationshipsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.relationships,
        getReferencedColumn: (t) => t.projectId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RelationshipsTableAnnotationComposer(
              $db: $db,
              $table: $db.relationships,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> aISuggestionsRefs<T extends Object>(
      Expression<T> Function($$AISuggestionsTableAnnotationComposer a) f) {
    final $$AISuggestionsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.aISuggestions,
        getReferencedColumn: (t) => t.projectId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AISuggestionsTableAnnotationComposer(
              $db: $db,
              $table: $db.aISuggestions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> projectNotesRefs<T extends Object>(
      Expression<T> Function($$ProjectNotesTableAnnotationComposer a) f) {
    final $$ProjectNotesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.projectNotes,
        getReferencedColumn: (t) => t.projectId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProjectNotesTableAnnotationComposer(
              $db: $db,
              $table: $db.projectNotes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> researchItemsRefs<T extends Object>(
      Expression<T> Function($$ResearchItemsTableAnnotationComposer a) f) {
    final $$ResearchItemsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.researchItems,
        getReferencedColumn: (t) => t.projectId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ResearchItemsTableAnnotationComposer(
              $db: $db,
              $table: $db.researchItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> metricEventsRefs<T extends Object>(
      Expression<T> Function($$MetricEventsTableAnnotationComposer a) f) {
    final $$MetricEventsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.metricEvents,
        getReferencedColumn: (t) => t.projectId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MetricEventsTableAnnotationComposer(
              $db: $db,
              $table: $db.metricEvents,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ProjectsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ProjectsTable,
    ProjectRow,
    $$ProjectsTableFilterComposer,
    $$ProjectsTableOrderingComposer,
    $$ProjectsTableAnnotationComposer,
    $$ProjectsTableCreateCompanionBuilder,
    $$ProjectsTableUpdateCompanionBuilder,
    (ProjectRow, $$ProjectsTableReferences),
    ProjectRow,
    PrefetchHooks Function(
        {bool chaptersRefs,
        bool scenesRefs,
        bool sceneSnapshotsRefs,
        bool catalogItemsRefs,
        bool relationshipsRefs,
        bool aISuggestionsRefs,
        bool projectNotesRefs,
        bool researchItemsRefs,
        bool metricEventsRefs})> {
  $$ProjectsTableTableManager(_$AppDatabase db, $ProjectsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProjectsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProjectsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProjectsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<String> projectType = const Value.absent(),
            Value<String> languageCode = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int?> wordTarget = const Value.absent(),
            Value<bool> aiEnabled = const Value.absent(),
            Value<bool> cloudSyncEnabled = const Value.absent(),
            Value<bool> noAiNoCloud = const Value.absent(),
            Value<String> metadataJson = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ProjectsCompanion(
            id: id,
            title: title,
            description: description,
            projectType: projectType,
            languageCode: languageCode,
            status: status,
            wordTarget: wordTarget,
            aiEnabled: aiEnabled,
            cloudSyncEnabled: cloudSyncEnabled,
            noAiNoCloud: noAiNoCloud,
            metadataJson: metadataJson,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String title,
            Value<String> description = const Value.absent(),
            required String projectType,
            required String languageCode,
            required String status,
            Value<int?> wordTarget = const Value.absent(),
            required bool aiEnabled,
            required bool cloudSyncEnabled,
            required bool noAiNoCloud,
            Value<String> metadataJson = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              ProjectsCompanion.insert(
            id: id,
            title: title,
            description: description,
            projectType: projectType,
            languageCode: languageCode,
            status: status,
            wordTarget: wordTarget,
            aiEnabled: aiEnabled,
            cloudSyncEnabled: cloudSyncEnabled,
            noAiNoCloud: noAiNoCloud,
            metadataJson: metadataJson,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$ProjectsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {chaptersRefs = false,
              scenesRefs = false,
              sceneSnapshotsRefs = false,
              catalogItemsRefs = false,
              relationshipsRefs = false,
              aISuggestionsRefs = false,
              projectNotesRefs = false,
              researchItemsRefs = false,
              metricEventsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (chaptersRefs) db.chapters,
                if (scenesRefs) db.scenes,
                if (sceneSnapshotsRefs) db.sceneSnapshots,
                if (catalogItemsRefs) db.catalogItems,
                if (relationshipsRefs) db.relationships,
                if (aISuggestionsRefs) db.aISuggestions,
                if (projectNotesRefs) db.projectNotes,
                if (researchItemsRefs) db.researchItems,
                if (metricEventsRefs) db.metricEvents
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (chaptersRefs)
                    await $_getPrefetchedData<ProjectRow, $ProjectsTable,
                            ChapterRow>(
                        currentTable: table,
                        referencedTable:
                            $$ProjectsTableReferences._chaptersRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ProjectsTableReferences(db, table, p0)
                                .chaptersRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.projectId == item.id),
                        typedResults: items),
                  if (scenesRefs)
                    await $_getPrefetchedData<ProjectRow, $ProjectsTable,
                            SceneRow>(
                        currentTable: table,
                        referencedTable:
                            $$ProjectsTableReferences._scenesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ProjectsTableReferences(db, table, p0).scenesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.projectId == item.id),
                        typedResults: items),
                  if (sceneSnapshotsRefs)
                    await $_getPrefetchedData<ProjectRow, $ProjectsTable,
                            SceneSnapshotRow>(
                        currentTable: table,
                        referencedTable: $$ProjectsTableReferences
                            ._sceneSnapshotsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ProjectsTableReferences(db, table, p0)
                                .sceneSnapshotsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.projectId == item.id),
                        typedResults: items),
                  if (catalogItemsRefs)
                    await $_getPrefetchedData<ProjectRow, $ProjectsTable,
                            CatalogItemRow>(
                        currentTable: table,
                        referencedTable: $$ProjectsTableReferences
                            ._catalogItemsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ProjectsTableReferences(db, table, p0)
                                .catalogItemsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.projectId == item.id),
                        typedResults: items),
                  if (relationshipsRefs)
                    await $_getPrefetchedData<ProjectRow, $ProjectsTable,
                            RelationshipRow>(
                        currentTable: table,
                        referencedTable: $$ProjectsTableReferences
                            ._relationshipsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ProjectsTableReferences(db, table, p0)
                                .relationshipsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.projectId == item.id),
                        typedResults: items),
                  if (aISuggestionsRefs)
                    await $_getPrefetchedData<ProjectRow, $ProjectsTable,
                            AISuggestionRow>(
                        currentTable: table,
                        referencedTable: $$ProjectsTableReferences
                            ._aISuggestionsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ProjectsTableReferences(db, table, p0)
                                .aISuggestionsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.projectId == item.id),
                        typedResults: items),
                  if (projectNotesRefs)
                    await $_getPrefetchedData<ProjectRow, $ProjectsTable,
                            ProjectNoteRow>(
                        currentTable: table,
                        referencedTable: $$ProjectsTableReferences
                            ._projectNotesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ProjectsTableReferences(db, table, p0)
                                .projectNotesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.projectId == item.id),
                        typedResults: items),
                  if (researchItemsRefs)
                    await $_getPrefetchedData<ProjectRow, $ProjectsTable,
                            ResearchItemRow>(
                        currentTable: table,
                        referencedTable: $$ProjectsTableReferences
                            ._researchItemsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ProjectsTableReferences(db, table, p0)
                                .researchItemsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.projectId == item.id),
                        typedResults: items),
                  if (metricEventsRefs)
                    await $_getPrefetchedData<ProjectRow, $ProjectsTable,
                            MetricEventRow>(
                        currentTable: table,
                        referencedTable: $$ProjectsTableReferences
                            ._metricEventsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ProjectsTableReferences(db, table, p0)
                                .metricEventsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.projectId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$ProjectsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ProjectsTable,
    ProjectRow,
    $$ProjectsTableFilterComposer,
    $$ProjectsTableOrderingComposer,
    $$ProjectsTableAnnotationComposer,
    $$ProjectsTableCreateCompanionBuilder,
    $$ProjectsTableUpdateCompanionBuilder,
    (ProjectRow, $$ProjectsTableReferences),
    ProjectRow,
    PrefetchHooks Function(
        {bool chaptersRefs,
        bool scenesRefs,
        bool sceneSnapshotsRefs,
        bool catalogItemsRefs,
        bool relationshipsRefs,
        bool aISuggestionsRefs,
        bool projectNotesRefs,
        bool researchItemsRefs,
        bool metricEventsRefs})>;
typedef $$ChaptersTableCreateCompanionBuilder = ChaptersCompanion Function({
  required String id,
  required String projectId,
  Value<String?> partId,
  required String title,
  Value<String> summary,
  required double orderIndex,
  required String status,
  Value<String> metadataJson,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$ChaptersTableUpdateCompanionBuilder = ChaptersCompanion Function({
  Value<String> id,
  Value<String> projectId,
  Value<String?> partId,
  Value<String> title,
  Value<String> summary,
  Value<double> orderIndex,
  Value<String> status,
  Value<String> metadataJson,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

final class $$ChaptersTableReferences
    extends BaseReferences<_$AppDatabase, $ChaptersTable, ChapterRow> {
  $$ChaptersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProjectsTable _projectIdTable(_$AppDatabase db) =>
      db.projects.createAlias('chapters__project_id__projects__id');

  $$ProjectsTableProcessedTableManager get projectId {
    final $_column = $_itemColumn<String>('project_id')!;

    final manager = $$ProjectsTableTableManager($_db, $_db.projects)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_projectIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$ChaptersTableFilterComposer
    extends Composer<_$AppDatabase, $ChaptersTable> {
  $$ChaptersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get partId => $composableBuilder(
      column: $table.partId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get summary => $composableBuilder(
      column: $table.summary, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get orderIndex => $composableBuilder(
      column: $table.orderIndex, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get metadataJson => $composableBuilder(
      column: $table.metadataJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  $$ProjectsTableFilterComposer get projectId {
    final $$ProjectsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.projectId,
        referencedTable: $db.projects,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProjectsTableFilterComposer(
              $db: $db,
              $table: $db.projects,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ChaptersTableOrderingComposer
    extends Composer<_$AppDatabase, $ChaptersTable> {
  $$ChaptersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get partId => $composableBuilder(
      column: $table.partId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get summary => $composableBuilder(
      column: $table.summary, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get orderIndex => $composableBuilder(
      column: $table.orderIndex, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get metadataJson => $composableBuilder(
      column: $table.metadataJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  $$ProjectsTableOrderingComposer get projectId {
    final $$ProjectsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.projectId,
        referencedTable: $db.projects,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProjectsTableOrderingComposer(
              $db: $db,
              $table: $db.projects,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ChaptersTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChaptersTable> {
  $$ChaptersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get partId =>
      $composableBuilder(column: $table.partId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get summary =>
      $composableBuilder(column: $table.summary, builder: (column) => column);

  GeneratedColumn<double> get orderIndex => $composableBuilder(
      column: $table.orderIndex, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get metadataJson => $composableBuilder(
      column: $table.metadataJson, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$ProjectsTableAnnotationComposer get projectId {
    final $$ProjectsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.projectId,
        referencedTable: $db.projects,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProjectsTableAnnotationComposer(
              $db: $db,
              $table: $db.projects,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ChaptersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ChaptersTable,
    ChapterRow,
    $$ChaptersTableFilterComposer,
    $$ChaptersTableOrderingComposer,
    $$ChaptersTableAnnotationComposer,
    $$ChaptersTableCreateCompanionBuilder,
    $$ChaptersTableUpdateCompanionBuilder,
    (ChapterRow, $$ChaptersTableReferences),
    ChapterRow,
    PrefetchHooks Function({bool projectId})> {
  $$ChaptersTableTableManager(_$AppDatabase db, $ChaptersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChaptersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChaptersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChaptersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> projectId = const Value.absent(),
            Value<String?> partId = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> summary = const Value.absent(),
            Value<double> orderIndex = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String> metadataJson = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ChaptersCompanion(
            id: id,
            projectId: projectId,
            partId: partId,
            title: title,
            summary: summary,
            orderIndex: orderIndex,
            status: status,
            metadataJson: metadataJson,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String projectId,
            Value<String?> partId = const Value.absent(),
            required String title,
            Value<String> summary = const Value.absent(),
            required double orderIndex,
            required String status,
            Value<String> metadataJson = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              ChaptersCompanion.insert(
            id: id,
            projectId: projectId,
            partId: partId,
            title: title,
            summary: summary,
            orderIndex: orderIndex,
            status: status,
            metadataJson: metadataJson,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$ChaptersTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({projectId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (projectId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.projectId,
                    referencedTable:
                        $$ChaptersTableReferences._projectIdTable(db),
                    referencedColumn:
                        $$ChaptersTableReferences._projectIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$ChaptersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ChaptersTable,
    ChapterRow,
    $$ChaptersTableFilterComposer,
    $$ChaptersTableOrderingComposer,
    $$ChaptersTableAnnotationComposer,
    $$ChaptersTableCreateCompanionBuilder,
    $$ChaptersTableUpdateCompanionBuilder,
    (ChapterRow, $$ChaptersTableReferences),
    ChapterRow,
    PrefetchHooks Function({bool projectId})>;
typedef $$ScenesTableCreateCompanionBuilder = ScenesCompanion Function({
  required String id,
  required String projectId,
  Value<String?> chapterId,
  Value<String?> parentSceneId,
  required String title,
  Value<String> summary,
  Value<String> manuscriptText,
  Value<String> authorIntent,
  Value<String?> povCharacterId,
  Value<String> sceneType,
  required String status,
  required double orderIndex,
  Value<DateTime?> storyDateStart,
  Value<DateTime?> storyDateEnd,
  Value<int?> estimatedWordTarget,
  Value<int> actualWordCount,
  Value<int?> tensionLevel,
  Value<String?> emotionalTone,
  Value<String?> goal,
  Value<String?> conflict,
  Value<String?> outcome,
  required bool aiAssistAllowed,
  Value<String> metadataJson,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$ScenesTableUpdateCompanionBuilder = ScenesCompanion Function({
  Value<String> id,
  Value<String> projectId,
  Value<String?> chapterId,
  Value<String?> parentSceneId,
  Value<String> title,
  Value<String> summary,
  Value<String> manuscriptText,
  Value<String> authorIntent,
  Value<String?> povCharacterId,
  Value<String> sceneType,
  Value<String> status,
  Value<double> orderIndex,
  Value<DateTime?> storyDateStart,
  Value<DateTime?> storyDateEnd,
  Value<int?> estimatedWordTarget,
  Value<int> actualWordCount,
  Value<int?> tensionLevel,
  Value<String?> emotionalTone,
  Value<String?> goal,
  Value<String?> conflict,
  Value<String?> outcome,
  Value<bool> aiAssistAllowed,
  Value<String> metadataJson,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

final class $$ScenesTableReferences
    extends BaseReferences<_$AppDatabase, $ScenesTable, SceneRow> {
  $$ScenesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProjectsTable _projectIdTable(_$AppDatabase db) =>
      db.projects.createAlias('scenes__project_id__projects__id');

  $$ProjectsTableProcessedTableManager get projectId {
    final $_column = $_itemColumn<String>('project_id')!;

    final manager = $$ProjectsTableTableManager($_db, $_db.projects)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_projectIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$SceneSnapshotsTable, List<SceneSnapshotRow>>
      _sceneSnapshotsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.sceneSnapshots,
              aliasName: 'scenes__id__scene_snapshots__scene_id');

  $$SceneSnapshotsTableProcessedTableManager get sceneSnapshotsRefs {
    final manager = $$SceneSnapshotsTableTableManager($_db, $_db.sceneSnapshots)
        .filter((f) => f.sceneId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_sceneSnapshotsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$ScenesTableFilterComposer
    extends Composer<_$AppDatabase, $ScenesTable> {
  $$ScenesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get chapterId => $composableBuilder(
      column: $table.chapterId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get parentSceneId => $composableBuilder(
      column: $table.parentSceneId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get summary => $composableBuilder(
      column: $table.summary, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get manuscriptText => $composableBuilder(
      column: $table.manuscriptText,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get authorIntent => $composableBuilder(
      column: $table.authorIntent, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get povCharacterId => $composableBuilder(
      column: $table.povCharacterId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sceneType => $composableBuilder(
      column: $table.sceneType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get orderIndex => $composableBuilder(
      column: $table.orderIndex, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get storyDateStart => $composableBuilder(
      column: $table.storyDateStart,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get storyDateEnd => $composableBuilder(
      column: $table.storyDateEnd, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get estimatedWordTarget => $composableBuilder(
      column: $table.estimatedWordTarget,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get actualWordCount => $composableBuilder(
      column: $table.actualWordCount,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get tensionLevel => $composableBuilder(
      column: $table.tensionLevel, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get emotionalTone => $composableBuilder(
      column: $table.emotionalTone, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get goal => $composableBuilder(
      column: $table.goal, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get conflict => $composableBuilder(
      column: $table.conflict, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get outcome => $composableBuilder(
      column: $table.outcome, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get aiAssistAllowed => $composableBuilder(
      column: $table.aiAssistAllowed,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get metadataJson => $composableBuilder(
      column: $table.metadataJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  $$ProjectsTableFilterComposer get projectId {
    final $$ProjectsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.projectId,
        referencedTable: $db.projects,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProjectsTableFilterComposer(
              $db: $db,
              $table: $db.projects,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> sceneSnapshotsRefs(
      Expression<bool> Function($$SceneSnapshotsTableFilterComposer f) f) {
    final $$SceneSnapshotsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.sceneSnapshots,
        getReferencedColumn: (t) => t.sceneId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SceneSnapshotsTableFilterComposer(
              $db: $db,
              $table: $db.sceneSnapshots,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ScenesTableOrderingComposer
    extends Composer<_$AppDatabase, $ScenesTable> {
  $$ScenesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get chapterId => $composableBuilder(
      column: $table.chapterId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get parentSceneId => $composableBuilder(
      column: $table.parentSceneId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get summary => $composableBuilder(
      column: $table.summary, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get manuscriptText => $composableBuilder(
      column: $table.manuscriptText,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get authorIntent => $composableBuilder(
      column: $table.authorIntent,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get povCharacterId => $composableBuilder(
      column: $table.povCharacterId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sceneType => $composableBuilder(
      column: $table.sceneType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get orderIndex => $composableBuilder(
      column: $table.orderIndex, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get storyDateStart => $composableBuilder(
      column: $table.storyDateStart,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get storyDateEnd => $composableBuilder(
      column: $table.storyDateEnd,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get estimatedWordTarget => $composableBuilder(
      column: $table.estimatedWordTarget,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get actualWordCount => $composableBuilder(
      column: $table.actualWordCount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get tensionLevel => $composableBuilder(
      column: $table.tensionLevel,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get emotionalTone => $composableBuilder(
      column: $table.emotionalTone,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get goal => $composableBuilder(
      column: $table.goal, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get conflict => $composableBuilder(
      column: $table.conflict, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get outcome => $composableBuilder(
      column: $table.outcome, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get aiAssistAllowed => $composableBuilder(
      column: $table.aiAssistAllowed,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get metadataJson => $composableBuilder(
      column: $table.metadataJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  $$ProjectsTableOrderingComposer get projectId {
    final $$ProjectsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.projectId,
        referencedTable: $db.projects,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProjectsTableOrderingComposer(
              $db: $db,
              $table: $db.projects,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ScenesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ScenesTable> {
  $$ScenesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get chapterId =>
      $composableBuilder(column: $table.chapterId, builder: (column) => column);

  GeneratedColumn<String> get parentSceneId => $composableBuilder(
      column: $table.parentSceneId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get summary =>
      $composableBuilder(column: $table.summary, builder: (column) => column);

  GeneratedColumn<String> get manuscriptText => $composableBuilder(
      column: $table.manuscriptText, builder: (column) => column);

  GeneratedColumn<String> get authorIntent => $composableBuilder(
      column: $table.authorIntent, builder: (column) => column);

  GeneratedColumn<String> get povCharacterId => $composableBuilder(
      column: $table.povCharacterId, builder: (column) => column);

  GeneratedColumn<String> get sceneType =>
      $composableBuilder(column: $table.sceneType, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<double> get orderIndex => $composableBuilder(
      column: $table.orderIndex, builder: (column) => column);

  GeneratedColumn<DateTime> get storyDateStart => $composableBuilder(
      column: $table.storyDateStart, builder: (column) => column);

  GeneratedColumn<DateTime> get storyDateEnd => $composableBuilder(
      column: $table.storyDateEnd, builder: (column) => column);

  GeneratedColumn<int> get estimatedWordTarget => $composableBuilder(
      column: $table.estimatedWordTarget, builder: (column) => column);

  GeneratedColumn<int> get actualWordCount => $composableBuilder(
      column: $table.actualWordCount, builder: (column) => column);

  GeneratedColumn<int> get tensionLevel => $composableBuilder(
      column: $table.tensionLevel, builder: (column) => column);

  GeneratedColumn<String> get emotionalTone => $composableBuilder(
      column: $table.emotionalTone, builder: (column) => column);

  GeneratedColumn<String> get goal =>
      $composableBuilder(column: $table.goal, builder: (column) => column);

  GeneratedColumn<String> get conflict =>
      $composableBuilder(column: $table.conflict, builder: (column) => column);

  GeneratedColumn<String> get outcome =>
      $composableBuilder(column: $table.outcome, builder: (column) => column);

  GeneratedColumn<bool> get aiAssistAllowed => $composableBuilder(
      column: $table.aiAssistAllowed, builder: (column) => column);

  GeneratedColumn<String> get metadataJson => $composableBuilder(
      column: $table.metadataJson, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$ProjectsTableAnnotationComposer get projectId {
    final $$ProjectsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.projectId,
        referencedTable: $db.projects,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProjectsTableAnnotationComposer(
              $db: $db,
              $table: $db.projects,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> sceneSnapshotsRefs<T extends Object>(
      Expression<T> Function($$SceneSnapshotsTableAnnotationComposer a) f) {
    final $$SceneSnapshotsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.sceneSnapshots,
        getReferencedColumn: (t) => t.sceneId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SceneSnapshotsTableAnnotationComposer(
              $db: $db,
              $table: $db.sceneSnapshots,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ScenesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ScenesTable,
    SceneRow,
    $$ScenesTableFilterComposer,
    $$ScenesTableOrderingComposer,
    $$ScenesTableAnnotationComposer,
    $$ScenesTableCreateCompanionBuilder,
    $$ScenesTableUpdateCompanionBuilder,
    (SceneRow, $$ScenesTableReferences),
    SceneRow,
    PrefetchHooks Function({bool projectId, bool sceneSnapshotsRefs})> {
  $$ScenesTableTableManager(_$AppDatabase db, $ScenesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ScenesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ScenesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ScenesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> projectId = const Value.absent(),
            Value<String?> chapterId = const Value.absent(),
            Value<String?> parentSceneId = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> summary = const Value.absent(),
            Value<String> manuscriptText = const Value.absent(),
            Value<String> authorIntent = const Value.absent(),
            Value<String?> povCharacterId = const Value.absent(),
            Value<String> sceneType = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<double> orderIndex = const Value.absent(),
            Value<DateTime?> storyDateStart = const Value.absent(),
            Value<DateTime?> storyDateEnd = const Value.absent(),
            Value<int?> estimatedWordTarget = const Value.absent(),
            Value<int> actualWordCount = const Value.absent(),
            Value<int?> tensionLevel = const Value.absent(),
            Value<String?> emotionalTone = const Value.absent(),
            Value<String?> goal = const Value.absent(),
            Value<String?> conflict = const Value.absent(),
            Value<String?> outcome = const Value.absent(),
            Value<bool> aiAssistAllowed = const Value.absent(),
            Value<String> metadataJson = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ScenesCompanion(
            id: id,
            projectId: projectId,
            chapterId: chapterId,
            parentSceneId: parentSceneId,
            title: title,
            summary: summary,
            manuscriptText: manuscriptText,
            authorIntent: authorIntent,
            povCharacterId: povCharacterId,
            sceneType: sceneType,
            status: status,
            orderIndex: orderIndex,
            storyDateStart: storyDateStart,
            storyDateEnd: storyDateEnd,
            estimatedWordTarget: estimatedWordTarget,
            actualWordCount: actualWordCount,
            tensionLevel: tensionLevel,
            emotionalTone: emotionalTone,
            goal: goal,
            conflict: conflict,
            outcome: outcome,
            aiAssistAllowed: aiAssistAllowed,
            metadataJson: metadataJson,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String projectId,
            Value<String?> chapterId = const Value.absent(),
            Value<String?> parentSceneId = const Value.absent(),
            required String title,
            Value<String> summary = const Value.absent(),
            Value<String> manuscriptText = const Value.absent(),
            Value<String> authorIntent = const Value.absent(),
            Value<String?> povCharacterId = const Value.absent(),
            Value<String> sceneType = const Value.absent(),
            required String status,
            required double orderIndex,
            Value<DateTime?> storyDateStart = const Value.absent(),
            Value<DateTime?> storyDateEnd = const Value.absent(),
            Value<int?> estimatedWordTarget = const Value.absent(),
            Value<int> actualWordCount = const Value.absent(),
            Value<int?> tensionLevel = const Value.absent(),
            Value<String?> emotionalTone = const Value.absent(),
            Value<String?> goal = const Value.absent(),
            Value<String?> conflict = const Value.absent(),
            Value<String?> outcome = const Value.absent(),
            required bool aiAssistAllowed,
            Value<String> metadataJson = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              ScenesCompanion.insert(
            id: id,
            projectId: projectId,
            chapterId: chapterId,
            parentSceneId: parentSceneId,
            title: title,
            summary: summary,
            manuscriptText: manuscriptText,
            authorIntent: authorIntent,
            povCharacterId: povCharacterId,
            sceneType: sceneType,
            status: status,
            orderIndex: orderIndex,
            storyDateStart: storyDateStart,
            storyDateEnd: storyDateEnd,
            estimatedWordTarget: estimatedWordTarget,
            actualWordCount: actualWordCount,
            tensionLevel: tensionLevel,
            emotionalTone: emotionalTone,
            goal: goal,
            conflict: conflict,
            outcome: outcome,
            aiAssistAllowed: aiAssistAllowed,
            metadataJson: metadataJson,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$ScenesTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {projectId = false, sceneSnapshotsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (sceneSnapshotsRefs) db.sceneSnapshots
              ],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (projectId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.projectId,
                    referencedTable:
                        $$ScenesTableReferences._projectIdTable(db),
                    referencedColumn:
                        $$ScenesTableReferences._projectIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (sceneSnapshotsRefs)
                    await $_getPrefetchedData<SceneRow, $ScenesTable,
                            SceneSnapshotRow>(
                        currentTable: table,
                        referencedTable: $$ScenesTableReferences
                            ._sceneSnapshotsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ScenesTableReferences(db, table, p0)
                                .sceneSnapshotsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.sceneId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$ScenesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ScenesTable,
    SceneRow,
    $$ScenesTableFilterComposer,
    $$ScenesTableOrderingComposer,
    $$ScenesTableAnnotationComposer,
    $$ScenesTableCreateCompanionBuilder,
    $$ScenesTableUpdateCompanionBuilder,
    (SceneRow, $$ScenesTableReferences),
    SceneRow,
    PrefetchHooks Function({bool projectId, bool sceneSnapshotsRefs})>;
typedef $$SceneSnapshotsTableCreateCompanionBuilder = SceneSnapshotsCompanion
    Function({
  required String id,
  required String projectId,
  required String sceneId,
  required String sceneTitle,
  Value<String> label,
  required String reason,
  required String sceneJson,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$SceneSnapshotsTableUpdateCompanionBuilder = SceneSnapshotsCompanion
    Function({
  Value<String> id,
  Value<String> projectId,
  Value<String> sceneId,
  Value<String> sceneTitle,
  Value<String> label,
  Value<String> reason,
  Value<String> sceneJson,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

final class $$SceneSnapshotsTableReferences extends BaseReferences<
    _$AppDatabase, $SceneSnapshotsTable, SceneSnapshotRow> {
  $$SceneSnapshotsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $ProjectsTable _projectIdTable(_$AppDatabase db) =>
      db.projects.createAlias('scene_snapshots__project_id__projects__id');

  $$ProjectsTableProcessedTableManager get projectId {
    final $_column = $_itemColumn<String>('project_id')!;

    final manager = $$ProjectsTableTableManager($_db, $_db.projects)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_projectIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $ScenesTable _sceneIdTable(_$AppDatabase db) =>
      db.scenes.createAlias('scene_snapshots__scene_id__scenes__id');

  $$ScenesTableProcessedTableManager get sceneId {
    final $_column = $_itemColumn<String>('scene_id')!;

    final manager = $$ScenesTableTableManager($_db, $_db.scenes)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sceneIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$SceneSnapshotsTableFilterComposer
    extends Composer<_$AppDatabase, $SceneSnapshotsTable> {
  $$SceneSnapshotsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sceneTitle => $composableBuilder(
      column: $table.sceneTitle, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get label => $composableBuilder(
      column: $table.label, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get reason => $composableBuilder(
      column: $table.reason, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sceneJson => $composableBuilder(
      column: $table.sceneJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$ProjectsTableFilterComposer get projectId {
    final $$ProjectsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.projectId,
        referencedTable: $db.projects,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProjectsTableFilterComposer(
              $db: $db,
              $table: $db.projects,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ScenesTableFilterComposer get sceneId {
    final $$ScenesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sceneId,
        referencedTable: $db.scenes,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ScenesTableFilterComposer(
              $db: $db,
              $table: $db.scenes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SceneSnapshotsTableOrderingComposer
    extends Composer<_$AppDatabase, $SceneSnapshotsTable> {
  $$SceneSnapshotsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sceneTitle => $composableBuilder(
      column: $table.sceneTitle, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get label => $composableBuilder(
      column: $table.label, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get reason => $composableBuilder(
      column: $table.reason, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sceneJson => $composableBuilder(
      column: $table.sceneJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$ProjectsTableOrderingComposer get projectId {
    final $$ProjectsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.projectId,
        referencedTable: $db.projects,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProjectsTableOrderingComposer(
              $db: $db,
              $table: $db.projects,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ScenesTableOrderingComposer get sceneId {
    final $$ScenesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sceneId,
        referencedTable: $db.scenes,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ScenesTableOrderingComposer(
              $db: $db,
              $table: $db.scenes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SceneSnapshotsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SceneSnapshotsTable> {
  $$SceneSnapshotsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sceneTitle => $composableBuilder(
      column: $table.sceneTitle, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<String> get sceneJson =>
      $composableBuilder(column: $table.sceneJson, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$ProjectsTableAnnotationComposer get projectId {
    final $$ProjectsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.projectId,
        referencedTable: $db.projects,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProjectsTableAnnotationComposer(
              $db: $db,
              $table: $db.projects,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ScenesTableAnnotationComposer get sceneId {
    final $$ScenesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sceneId,
        referencedTable: $db.scenes,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ScenesTableAnnotationComposer(
              $db: $db,
              $table: $db.scenes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SceneSnapshotsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SceneSnapshotsTable,
    SceneSnapshotRow,
    $$SceneSnapshotsTableFilterComposer,
    $$SceneSnapshotsTableOrderingComposer,
    $$SceneSnapshotsTableAnnotationComposer,
    $$SceneSnapshotsTableCreateCompanionBuilder,
    $$SceneSnapshotsTableUpdateCompanionBuilder,
    (SceneSnapshotRow, $$SceneSnapshotsTableReferences),
    SceneSnapshotRow,
    PrefetchHooks Function({bool projectId, bool sceneId})> {
  $$SceneSnapshotsTableTableManager(
      _$AppDatabase db, $SceneSnapshotsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SceneSnapshotsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SceneSnapshotsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SceneSnapshotsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> projectId = const Value.absent(),
            Value<String> sceneId = const Value.absent(),
            Value<String> sceneTitle = const Value.absent(),
            Value<String> label = const Value.absent(),
            Value<String> reason = const Value.absent(),
            Value<String> sceneJson = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SceneSnapshotsCompanion(
            id: id,
            projectId: projectId,
            sceneId: sceneId,
            sceneTitle: sceneTitle,
            label: label,
            reason: reason,
            sceneJson: sceneJson,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String projectId,
            required String sceneId,
            required String sceneTitle,
            Value<String> label = const Value.absent(),
            required String reason,
            required String sceneJson,
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              SceneSnapshotsCompanion.insert(
            id: id,
            projectId: projectId,
            sceneId: sceneId,
            sceneTitle: sceneTitle,
            label: label,
            reason: reason,
            sceneJson: sceneJson,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$SceneSnapshotsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({projectId = false, sceneId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (projectId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.projectId,
                    referencedTable:
                        $$SceneSnapshotsTableReferences._projectIdTable(db),
                    referencedColumn:
                        $$SceneSnapshotsTableReferences._projectIdTable(db).id,
                  ) as T;
                }
                if (sceneId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.sceneId,
                    referencedTable:
                        $$SceneSnapshotsTableReferences._sceneIdTable(db),
                    referencedColumn:
                        $$SceneSnapshotsTableReferences._sceneIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$SceneSnapshotsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SceneSnapshotsTable,
    SceneSnapshotRow,
    $$SceneSnapshotsTableFilterComposer,
    $$SceneSnapshotsTableOrderingComposer,
    $$SceneSnapshotsTableAnnotationComposer,
    $$SceneSnapshotsTableCreateCompanionBuilder,
    $$SceneSnapshotsTableUpdateCompanionBuilder,
    (SceneSnapshotRow, $$SceneSnapshotsTableReferences),
    SceneSnapshotRow,
    PrefetchHooks Function({bool projectId, bool sceneId})>;
typedef $$CatalogItemsTableCreateCompanionBuilder = CatalogItemsCompanion
    Function({
  required String id,
  required String projectId,
  required String type,
  required String name,
  Value<String> summary,
  required String status,
  Value<String> fieldsJson,
  Value<String> metadataJson,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$CatalogItemsTableUpdateCompanionBuilder = CatalogItemsCompanion
    Function({
  Value<String> id,
  Value<String> projectId,
  Value<String> type,
  Value<String> name,
  Value<String> summary,
  Value<String> status,
  Value<String> fieldsJson,
  Value<String> metadataJson,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

final class $$CatalogItemsTableReferences
    extends BaseReferences<_$AppDatabase, $CatalogItemsTable, CatalogItemRow> {
  $$CatalogItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProjectsTable _projectIdTable(_$AppDatabase db) =>
      db.projects.createAlias('catalog_items__project_id__projects__id');

  $$ProjectsTableProcessedTableManager get projectId {
    final $_column = $_itemColumn<String>('project_id')!;

    final manager = $$ProjectsTableTableManager($_db, $_db.projects)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_projectIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$CatalogItemsTableFilterComposer
    extends Composer<_$AppDatabase, $CatalogItemsTable> {
  $$CatalogItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get summary => $composableBuilder(
      column: $table.summary, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fieldsJson => $composableBuilder(
      column: $table.fieldsJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get metadataJson => $composableBuilder(
      column: $table.metadataJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  $$ProjectsTableFilterComposer get projectId {
    final $$ProjectsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.projectId,
        referencedTable: $db.projects,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProjectsTableFilterComposer(
              $db: $db,
              $table: $db.projects,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$CatalogItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $CatalogItemsTable> {
  $$CatalogItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get summary => $composableBuilder(
      column: $table.summary, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fieldsJson => $composableBuilder(
      column: $table.fieldsJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get metadataJson => $composableBuilder(
      column: $table.metadataJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  $$ProjectsTableOrderingComposer get projectId {
    final $$ProjectsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.projectId,
        referencedTable: $db.projects,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProjectsTableOrderingComposer(
              $db: $db,
              $table: $db.projects,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$CatalogItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CatalogItemsTable> {
  $$CatalogItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get summary =>
      $composableBuilder(column: $table.summary, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get fieldsJson => $composableBuilder(
      column: $table.fieldsJson, builder: (column) => column);

  GeneratedColumn<String> get metadataJson => $composableBuilder(
      column: $table.metadataJson, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$ProjectsTableAnnotationComposer get projectId {
    final $$ProjectsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.projectId,
        referencedTable: $db.projects,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProjectsTableAnnotationComposer(
              $db: $db,
              $table: $db.projects,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$CatalogItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CatalogItemsTable,
    CatalogItemRow,
    $$CatalogItemsTableFilterComposer,
    $$CatalogItemsTableOrderingComposer,
    $$CatalogItemsTableAnnotationComposer,
    $$CatalogItemsTableCreateCompanionBuilder,
    $$CatalogItemsTableUpdateCompanionBuilder,
    (CatalogItemRow, $$CatalogItemsTableReferences),
    CatalogItemRow,
    PrefetchHooks Function({bool projectId})> {
  $$CatalogItemsTableTableManager(_$AppDatabase db, $CatalogItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CatalogItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CatalogItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CatalogItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> projectId = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> summary = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String> fieldsJson = const Value.absent(),
            Value<String> metadataJson = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CatalogItemsCompanion(
            id: id,
            projectId: projectId,
            type: type,
            name: name,
            summary: summary,
            status: status,
            fieldsJson: fieldsJson,
            metadataJson: metadataJson,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String projectId,
            required String type,
            required String name,
            Value<String> summary = const Value.absent(),
            required String status,
            Value<String> fieldsJson = const Value.absent(),
            Value<String> metadataJson = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              CatalogItemsCompanion.insert(
            id: id,
            projectId: projectId,
            type: type,
            name: name,
            summary: summary,
            status: status,
            fieldsJson: fieldsJson,
            metadataJson: metadataJson,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$CatalogItemsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({projectId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (projectId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.projectId,
                    referencedTable:
                        $$CatalogItemsTableReferences._projectIdTable(db),
                    referencedColumn:
                        $$CatalogItemsTableReferences._projectIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$CatalogItemsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CatalogItemsTable,
    CatalogItemRow,
    $$CatalogItemsTableFilterComposer,
    $$CatalogItemsTableOrderingComposer,
    $$CatalogItemsTableAnnotationComposer,
    $$CatalogItemsTableCreateCompanionBuilder,
    $$CatalogItemsTableUpdateCompanionBuilder,
    (CatalogItemRow, $$CatalogItemsTableReferences),
    CatalogItemRow,
    PrefetchHooks Function({bool projectId})>;
typedef $$RelationshipsTableCreateCompanionBuilder = RelationshipsCompanion
    Function({
  required String id,
  required String projectId,
  required String sourceType,
  required String sourceId,
  required String targetType,
  required String targetId,
  required String relationshipType,
  Value<String?> label,
  Value<String?> description,
  Value<double?> strength,
  required String direction,
  Value<DateTime?> validFromStoryTime,
  Value<DateTime?> validToStoryTime,
  Value<String> metadataJson,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$RelationshipsTableUpdateCompanionBuilder = RelationshipsCompanion
    Function({
  Value<String> id,
  Value<String> projectId,
  Value<String> sourceType,
  Value<String> sourceId,
  Value<String> targetType,
  Value<String> targetId,
  Value<String> relationshipType,
  Value<String?> label,
  Value<String?> description,
  Value<double?> strength,
  Value<String> direction,
  Value<DateTime?> validFromStoryTime,
  Value<DateTime?> validToStoryTime,
  Value<String> metadataJson,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

final class $$RelationshipsTableReferences extends BaseReferences<_$AppDatabase,
    $RelationshipsTable, RelationshipRow> {
  $$RelationshipsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $ProjectsTable _projectIdTable(_$AppDatabase db) =>
      db.projects.createAlias('relationships__project_id__projects__id');

  $$ProjectsTableProcessedTableManager get projectId {
    final $_column = $_itemColumn<String>('project_id')!;

    final manager = $$ProjectsTableTableManager($_db, $_db.projects)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_projectIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$RelationshipsTableFilterComposer
    extends Composer<_$AppDatabase, $RelationshipsTable> {
  $$RelationshipsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sourceType => $composableBuilder(
      column: $table.sourceType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sourceId => $composableBuilder(
      column: $table.sourceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get targetType => $composableBuilder(
      column: $table.targetType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get targetId => $composableBuilder(
      column: $table.targetId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get relationshipType => $composableBuilder(
      column: $table.relationshipType,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get label => $composableBuilder(
      column: $table.label, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get strength => $composableBuilder(
      column: $table.strength, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get direction => $composableBuilder(
      column: $table.direction, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get validFromStoryTime => $composableBuilder(
      column: $table.validFromStoryTime,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get validToStoryTime => $composableBuilder(
      column: $table.validToStoryTime,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get metadataJson => $composableBuilder(
      column: $table.metadataJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  $$ProjectsTableFilterComposer get projectId {
    final $$ProjectsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.projectId,
        referencedTable: $db.projects,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProjectsTableFilterComposer(
              $db: $db,
              $table: $db.projects,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$RelationshipsTableOrderingComposer
    extends Composer<_$AppDatabase, $RelationshipsTable> {
  $$RelationshipsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sourceType => $composableBuilder(
      column: $table.sourceType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sourceId => $composableBuilder(
      column: $table.sourceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get targetType => $composableBuilder(
      column: $table.targetType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get targetId => $composableBuilder(
      column: $table.targetId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get relationshipType => $composableBuilder(
      column: $table.relationshipType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get label => $composableBuilder(
      column: $table.label, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get strength => $composableBuilder(
      column: $table.strength, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get direction => $composableBuilder(
      column: $table.direction, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get validFromStoryTime => $composableBuilder(
      column: $table.validFromStoryTime,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get validToStoryTime => $composableBuilder(
      column: $table.validToStoryTime,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get metadataJson => $composableBuilder(
      column: $table.metadataJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  $$ProjectsTableOrderingComposer get projectId {
    final $$ProjectsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.projectId,
        referencedTable: $db.projects,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProjectsTableOrderingComposer(
              $db: $db,
              $table: $db.projects,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$RelationshipsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RelationshipsTable> {
  $$RelationshipsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sourceType => $composableBuilder(
      column: $table.sourceType, builder: (column) => column);

  GeneratedColumn<String> get sourceId =>
      $composableBuilder(column: $table.sourceId, builder: (column) => column);

  GeneratedColumn<String> get targetType => $composableBuilder(
      column: $table.targetType, builder: (column) => column);

  GeneratedColumn<String> get targetId =>
      $composableBuilder(column: $table.targetId, builder: (column) => column);

  GeneratedColumn<String> get relationshipType => $composableBuilder(
      column: $table.relationshipType, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<double> get strength =>
      $composableBuilder(column: $table.strength, builder: (column) => column);

  GeneratedColumn<String> get direction =>
      $composableBuilder(column: $table.direction, builder: (column) => column);

  GeneratedColumn<DateTime> get validFromStoryTime => $composableBuilder(
      column: $table.validFromStoryTime, builder: (column) => column);

  GeneratedColumn<DateTime> get validToStoryTime => $composableBuilder(
      column: $table.validToStoryTime, builder: (column) => column);

  GeneratedColumn<String> get metadataJson => $composableBuilder(
      column: $table.metadataJson, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$ProjectsTableAnnotationComposer get projectId {
    final $$ProjectsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.projectId,
        referencedTable: $db.projects,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProjectsTableAnnotationComposer(
              $db: $db,
              $table: $db.projects,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$RelationshipsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RelationshipsTable,
    RelationshipRow,
    $$RelationshipsTableFilterComposer,
    $$RelationshipsTableOrderingComposer,
    $$RelationshipsTableAnnotationComposer,
    $$RelationshipsTableCreateCompanionBuilder,
    $$RelationshipsTableUpdateCompanionBuilder,
    (RelationshipRow, $$RelationshipsTableReferences),
    RelationshipRow,
    PrefetchHooks Function({bool projectId})> {
  $$RelationshipsTableTableManager(_$AppDatabase db, $RelationshipsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RelationshipsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RelationshipsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RelationshipsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> projectId = const Value.absent(),
            Value<String> sourceType = const Value.absent(),
            Value<String> sourceId = const Value.absent(),
            Value<String> targetType = const Value.absent(),
            Value<String> targetId = const Value.absent(),
            Value<String> relationshipType = const Value.absent(),
            Value<String?> label = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<double?> strength = const Value.absent(),
            Value<String> direction = const Value.absent(),
            Value<DateTime?> validFromStoryTime = const Value.absent(),
            Value<DateTime?> validToStoryTime = const Value.absent(),
            Value<String> metadataJson = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RelationshipsCompanion(
            id: id,
            projectId: projectId,
            sourceType: sourceType,
            sourceId: sourceId,
            targetType: targetType,
            targetId: targetId,
            relationshipType: relationshipType,
            label: label,
            description: description,
            strength: strength,
            direction: direction,
            validFromStoryTime: validFromStoryTime,
            validToStoryTime: validToStoryTime,
            metadataJson: metadataJson,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String projectId,
            required String sourceType,
            required String sourceId,
            required String targetType,
            required String targetId,
            required String relationshipType,
            Value<String?> label = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<double?> strength = const Value.absent(),
            required String direction,
            Value<DateTime?> validFromStoryTime = const Value.absent(),
            Value<DateTime?> validToStoryTime = const Value.absent(),
            Value<String> metadataJson = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              RelationshipsCompanion.insert(
            id: id,
            projectId: projectId,
            sourceType: sourceType,
            sourceId: sourceId,
            targetType: targetType,
            targetId: targetId,
            relationshipType: relationshipType,
            label: label,
            description: description,
            strength: strength,
            direction: direction,
            validFromStoryTime: validFromStoryTime,
            validToStoryTime: validToStoryTime,
            metadataJson: metadataJson,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$RelationshipsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({projectId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (projectId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.projectId,
                    referencedTable:
                        $$RelationshipsTableReferences._projectIdTable(db),
                    referencedColumn:
                        $$RelationshipsTableReferences._projectIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$RelationshipsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $RelationshipsTable,
    RelationshipRow,
    $$RelationshipsTableFilterComposer,
    $$RelationshipsTableOrderingComposer,
    $$RelationshipsTableAnnotationComposer,
    $$RelationshipsTableCreateCompanionBuilder,
    $$RelationshipsTableUpdateCompanionBuilder,
    (RelationshipRow, $$RelationshipsTableReferences),
    RelationshipRow,
    PrefetchHooks Function({bool projectId})>;
typedef $$AISuggestionsTableCreateCompanionBuilder = AISuggestionsCompanion
    Function({
  required String id,
  required String projectId,
  required String targetType,
  required String targetId,
  required String suggestionType,
  required String inputContextHash,
  required String providerId,
  required String modelName,
  Value<String?> promptTemplateId,
  required String promptText,
  required String responseText,
  Value<String?> structuredResponseJson,
  required String userDecision,
  Value<String?> acceptedPatchJson,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$AISuggestionsTableUpdateCompanionBuilder = AISuggestionsCompanion
    Function({
  Value<String> id,
  Value<String> projectId,
  Value<String> targetType,
  Value<String> targetId,
  Value<String> suggestionType,
  Value<String> inputContextHash,
  Value<String> providerId,
  Value<String> modelName,
  Value<String?> promptTemplateId,
  Value<String> promptText,
  Value<String> responseText,
  Value<String?> structuredResponseJson,
  Value<String> userDecision,
  Value<String?> acceptedPatchJson,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

final class $$AISuggestionsTableReferences extends BaseReferences<_$AppDatabase,
    $AISuggestionsTable, AISuggestionRow> {
  $$AISuggestionsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $ProjectsTable _projectIdTable(_$AppDatabase db) =>
      db.projects.createAlias('a_i_suggestions__project_id__projects__id');

  $$ProjectsTableProcessedTableManager get projectId {
    final $_column = $_itemColumn<String>('project_id')!;

    final manager = $$ProjectsTableTableManager($_db, $_db.projects)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_projectIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$AISuggestionsTableFilterComposer
    extends Composer<_$AppDatabase, $AISuggestionsTable> {
  $$AISuggestionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get targetType => $composableBuilder(
      column: $table.targetType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get targetId => $composableBuilder(
      column: $table.targetId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get suggestionType => $composableBuilder(
      column: $table.suggestionType,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get inputContextHash => $composableBuilder(
      column: $table.inputContextHash,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get providerId => $composableBuilder(
      column: $table.providerId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get modelName => $composableBuilder(
      column: $table.modelName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get promptTemplateId => $composableBuilder(
      column: $table.promptTemplateId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get promptText => $composableBuilder(
      column: $table.promptText, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get responseText => $composableBuilder(
      column: $table.responseText, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get structuredResponseJson => $composableBuilder(
      column: $table.structuredResponseJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userDecision => $composableBuilder(
      column: $table.userDecision, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get acceptedPatchJson => $composableBuilder(
      column: $table.acceptedPatchJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$ProjectsTableFilterComposer get projectId {
    final $$ProjectsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.projectId,
        referencedTable: $db.projects,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProjectsTableFilterComposer(
              $db: $db,
              $table: $db.projects,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$AISuggestionsTableOrderingComposer
    extends Composer<_$AppDatabase, $AISuggestionsTable> {
  $$AISuggestionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get targetType => $composableBuilder(
      column: $table.targetType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get targetId => $composableBuilder(
      column: $table.targetId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get suggestionType => $composableBuilder(
      column: $table.suggestionType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get inputContextHash => $composableBuilder(
      column: $table.inputContextHash,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get providerId => $composableBuilder(
      column: $table.providerId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get modelName => $composableBuilder(
      column: $table.modelName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get promptTemplateId => $composableBuilder(
      column: $table.promptTemplateId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get promptText => $composableBuilder(
      column: $table.promptText, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get responseText => $composableBuilder(
      column: $table.responseText,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get structuredResponseJson => $composableBuilder(
      column: $table.structuredResponseJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userDecision => $composableBuilder(
      column: $table.userDecision,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get acceptedPatchJson => $composableBuilder(
      column: $table.acceptedPatchJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$ProjectsTableOrderingComposer get projectId {
    final $$ProjectsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.projectId,
        referencedTable: $db.projects,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProjectsTableOrderingComposer(
              $db: $db,
              $table: $db.projects,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$AISuggestionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AISuggestionsTable> {
  $$AISuggestionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get targetType => $composableBuilder(
      column: $table.targetType, builder: (column) => column);

  GeneratedColumn<String> get targetId =>
      $composableBuilder(column: $table.targetId, builder: (column) => column);

  GeneratedColumn<String> get suggestionType => $composableBuilder(
      column: $table.suggestionType, builder: (column) => column);

  GeneratedColumn<String> get inputContextHash => $composableBuilder(
      column: $table.inputContextHash, builder: (column) => column);

  GeneratedColumn<String> get providerId => $composableBuilder(
      column: $table.providerId, builder: (column) => column);

  GeneratedColumn<String> get modelName =>
      $composableBuilder(column: $table.modelName, builder: (column) => column);

  GeneratedColumn<String> get promptTemplateId => $composableBuilder(
      column: $table.promptTemplateId, builder: (column) => column);

  GeneratedColumn<String> get promptText => $composableBuilder(
      column: $table.promptText, builder: (column) => column);

  GeneratedColumn<String> get responseText => $composableBuilder(
      column: $table.responseText, builder: (column) => column);

  GeneratedColumn<String> get structuredResponseJson => $composableBuilder(
      column: $table.structuredResponseJson, builder: (column) => column);

  GeneratedColumn<String> get userDecision => $composableBuilder(
      column: $table.userDecision, builder: (column) => column);

  GeneratedColumn<String> get acceptedPatchJson => $composableBuilder(
      column: $table.acceptedPatchJson, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$ProjectsTableAnnotationComposer get projectId {
    final $$ProjectsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.projectId,
        referencedTable: $db.projects,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProjectsTableAnnotationComposer(
              $db: $db,
              $table: $db.projects,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$AISuggestionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AISuggestionsTable,
    AISuggestionRow,
    $$AISuggestionsTableFilterComposer,
    $$AISuggestionsTableOrderingComposer,
    $$AISuggestionsTableAnnotationComposer,
    $$AISuggestionsTableCreateCompanionBuilder,
    $$AISuggestionsTableUpdateCompanionBuilder,
    (AISuggestionRow, $$AISuggestionsTableReferences),
    AISuggestionRow,
    PrefetchHooks Function({bool projectId})> {
  $$AISuggestionsTableTableManager(_$AppDatabase db, $AISuggestionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AISuggestionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AISuggestionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AISuggestionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> projectId = const Value.absent(),
            Value<String> targetType = const Value.absent(),
            Value<String> targetId = const Value.absent(),
            Value<String> suggestionType = const Value.absent(),
            Value<String> inputContextHash = const Value.absent(),
            Value<String> providerId = const Value.absent(),
            Value<String> modelName = const Value.absent(),
            Value<String?> promptTemplateId = const Value.absent(),
            Value<String> promptText = const Value.absent(),
            Value<String> responseText = const Value.absent(),
            Value<String?> structuredResponseJson = const Value.absent(),
            Value<String> userDecision = const Value.absent(),
            Value<String?> acceptedPatchJson = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AISuggestionsCompanion(
            id: id,
            projectId: projectId,
            targetType: targetType,
            targetId: targetId,
            suggestionType: suggestionType,
            inputContextHash: inputContextHash,
            providerId: providerId,
            modelName: modelName,
            promptTemplateId: promptTemplateId,
            promptText: promptText,
            responseText: responseText,
            structuredResponseJson: structuredResponseJson,
            userDecision: userDecision,
            acceptedPatchJson: acceptedPatchJson,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String projectId,
            required String targetType,
            required String targetId,
            required String suggestionType,
            required String inputContextHash,
            required String providerId,
            required String modelName,
            Value<String?> promptTemplateId = const Value.absent(),
            required String promptText,
            required String responseText,
            Value<String?> structuredResponseJson = const Value.absent(),
            required String userDecision,
            Value<String?> acceptedPatchJson = const Value.absent(),
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              AISuggestionsCompanion.insert(
            id: id,
            projectId: projectId,
            targetType: targetType,
            targetId: targetId,
            suggestionType: suggestionType,
            inputContextHash: inputContextHash,
            providerId: providerId,
            modelName: modelName,
            promptTemplateId: promptTemplateId,
            promptText: promptText,
            responseText: responseText,
            structuredResponseJson: structuredResponseJson,
            userDecision: userDecision,
            acceptedPatchJson: acceptedPatchJson,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$AISuggestionsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({projectId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (projectId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.projectId,
                    referencedTable:
                        $$AISuggestionsTableReferences._projectIdTable(db),
                    referencedColumn:
                        $$AISuggestionsTableReferences._projectIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$AISuggestionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AISuggestionsTable,
    AISuggestionRow,
    $$AISuggestionsTableFilterComposer,
    $$AISuggestionsTableOrderingComposer,
    $$AISuggestionsTableAnnotationComposer,
    $$AISuggestionsTableCreateCompanionBuilder,
    $$AISuggestionsTableUpdateCompanionBuilder,
    (AISuggestionRow, $$AISuggestionsTableReferences),
    AISuggestionRow,
    PrefetchHooks Function({bool projectId})>;
typedef $$ProjectNotesTableCreateCompanionBuilder = ProjectNotesCompanion
    Function({
  required String id,
  required String projectId,
  Value<String?> targetType,
  Value<String?> targetId,
  required String title,
  required String body,
  Value<String> source,
  Value<String?> sourceSuggestionId,
  Value<String> metadataJson,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$ProjectNotesTableUpdateCompanionBuilder = ProjectNotesCompanion
    Function({
  Value<String> id,
  Value<String> projectId,
  Value<String?> targetType,
  Value<String?> targetId,
  Value<String> title,
  Value<String> body,
  Value<String> source,
  Value<String?> sourceSuggestionId,
  Value<String> metadataJson,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

final class $$ProjectNotesTableReferences
    extends BaseReferences<_$AppDatabase, $ProjectNotesTable, ProjectNoteRow> {
  $$ProjectNotesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProjectsTable _projectIdTable(_$AppDatabase db) =>
      db.projects.createAlias('project_notes__project_id__projects__id');

  $$ProjectsTableProcessedTableManager get projectId {
    final $_column = $_itemColumn<String>('project_id')!;

    final manager = $$ProjectsTableTableManager($_db, $_db.projects)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_projectIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$ProjectNotesTableFilterComposer
    extends Composer<_$AppDatabase, $ProjectNotesTable> {
  $$ProjectNotesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get targetType => $composableBuilder(
      column: $table.targetType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get targetId => $composableBuilder(
      column: $table.targetId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get body => $composableBuilder(
      column: $table.body, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sourceSuggestionId => $composableBuilder(
      column: $table.sourceSuggestionId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get metadataJson => $composableBuilder(
      column: $table.metadataJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  $$ProjectsTableFilterComposer get projectId {
    final $$ProjectsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.projectId,
        referencedTable: $db.projects,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProjectsTableFilterComposer(
              $db: $db,
              $table: $db.projects,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ProjectNotesTableOrderingComposer
    extends Composer<_$AppDatabase, $ProjectNotesTable> {
  $$ProjectNotesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get targetType => $composableBuilder(
      column: $table.targetType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get targetId => $composableBuilder(
      column: $table.targetId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get body => $composableBuilder(
      column: $table.body, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sourceSuggestionId => $composableBuilder(
      column: $table.sourceSuggestionId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get metadataJson => $composableBuilder(
      column: $table.metadataJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  $$ProjectsTableOrderingComposer get projectId {
    final $$ProjectsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.projectId,
        referencedTable: $db.projects,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProjectsTableOrderingComposer(
              $db: $db,
              $table: $db.projects,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ProjectNotesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProjectNotesTable> {
  $$ProjectNotesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get targetType => $composableBuilder(
      column: $table.targetType, builder: (column) => column);

  GeneratedColumn<String> get targetId =>
      $composableBuilder(column: $table.targetId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get sourceSuggestionId => $composableBuilder(
      column: $table.sourceSuggestionId, builder: (column) => column);

  GeneratedColumn<String> get metadataJson => $composableBuilder(
      column: $table.metadataJson, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$ProjectsTableAnnotationComposer get projectId {
    final $$ProjectsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.projectId,
        referencedTable: $db.projects,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProjectsTableAnnotationComposer(
              $db: $db,
              $table: $db.projects,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ProjectNotesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ProjectNotesTable,
    ProjectNoteRow,
    $$ProjectNotesTableFilterComposer,
    $$ProjectNotesTableOrderingComposer,
    $$ProjectNotesTableAnnotationComposer,
    $$ProjectNotesTableCreateCompanionBuilder,
    $$ProjectNotesTableUpdateCompanionBuilder,
    (ProjectNoteRow, $$ProjectNotesTableReferences),
    ProjectNoteRow,
    PrefetchHooks Function({bool projectId})> {
  $$ProjectNotesTableTableManager(_$AppDatabase db, $ProjectNotesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProjectNotesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProjectNotesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProjectNotesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> projectId = const Value.absent(),
            Value<String?> targetType = const Value.absent(),
            Value<String?> targetId = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> body = const Value.absent(),
            Value<String> source = const Value.absent(),
            Value<String?> sourceSuggestionId = const Value.absent(),
            Value<String> metadataJson = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ProjectNotesCompanion(
            id: id,
            projectId: projectId,
            targetType: targetType,
            targetId: targetId,
            title: title,
            body: body,
            source: source,
            sourceSuggestionId: sourceSuggestionId,
            metadataJson: metadataJson,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String projectId,
            Value<String?> targetType = const Value.absent(),
            Value<String?> targetId = const Value.absent(),
            required String title,
            required String body,
            Value<String> source = const Value.absent(),
            Value<String?> sourceSuggestionId = const Value.absent(),
            Value<String> metadataJson = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              ProjectNotesCompanion.insert(
            id: id,
            projectId: projectId,
            targetType: targetType,
            targetId: targetId,
            title: title,
            body: body,
            source: source,
            sourceSuggestionId: sourceSuggestionId,
            metadataJson: metadataJson,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$ProjectNotesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({projectId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (projectId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.projectId,
                    referencedTable:
                        $$ProjectNotesTableReferences._projectIdTable(db),
                    referencedColumn:
                        $$ProjectNotesTableReferences._projectIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$ProjectNotesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ProjectNotesTable,
    ProjectNoteRow,
    $$ProjectNotesTableFilterComposer,
    $$ProjectNotesTableOrderingComposer,
    $$ProjectNotesTableAnnotationComposer,
    $$ProjectNotesTableCreateCompanionBuilder,
    $$ProjectNotesTableUpdateCompanionBuilder,
    (ProjectNoteRow, $$ProjectNotesTableReferences),
    ProjectNoteRow,
    PrefetchHooks Function({bool projectId})>;
typedef $$ResearchItemsTableCreateCompanionBuilder = ResearchItemsCompanion
    Function({
  required String id,
  required String projectId,
  required String kind,
  Value<String?> targetType,
  Value<String?> targetId,
  required String title,
  Value<String> uri,
  Value<String> body,
  Value<String> source,
  Value<String> tagsJson,
  Value<String> metadataJson,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$ResearchItemsTableUpdateCompanionBuilder = ResearchItemsCompanion
    Function({
  Value<String> id,
  Value<String> projectId,
  Value<String> kind,
  Value<String?> targetType,
  Value<String?> targetId,
  Value<String> title,
  Value<String> uri,
  Value<String> body,
  Value<String> source,
  Value<String> tagsJson,
  Value<String> metadataJson,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

final class $$ResearchItemsTableReferences extends BaseReferences<_$AppDatabase,
    $ResearchItemsTable, ResearchItemRow> {
  $$ResearchItemsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $ProjectsTable _projectIdTable(_$AppDatabase db) =>
      db.projects.createAlias('research_items__project_id__projects__id');

  $$ProjectsTableProcessedTableManager get projectId {
    final $_column = $_itemColumn<String>('project_id')!;

    final manager = $$ProjectsTableTableManager($_db, $_db.projects)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_projectIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$ResearchItemsTableFilterComposer
    extends Composer<_$AppDatabase, $ResearchItemsTable> {
  $$ResearchItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get kind => $composableBuilder(
      column: $table.kind, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get targetType => $composableBuilder(
      column: $table.targetType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get targetId => $composableBuilder(
      column: $table.targetId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get uri => $composableBuilder(
      column: $table.uri, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get body => $composableBuilder(
      column: $table.body, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tagsJson => $composableBuilder(
      column: $table.tagsJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get metadataJson => $composableBuilder(
      column: $table.metadataJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  $$ProjectsTableFilterComposer get projectId {
    final $$ProjectsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.projectId,
        referencedTable: $db.projects,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProjectsTableFilterComposer(
              $db: $db,
              $table: $db.projects,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ResearchItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $ResearchItemsTable> {
  $$ResearchItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get kind => $composableBuilder(
      column: $table.kind, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get targetType => $composableBuilder(
      column: $table.targetType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get targetId => $composableBuilder(
      column: $table.targetId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get uri => $composableBuilder(
      column: $table.uri, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get body => $composableBuilder(
      column: $table.body, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tagsJson => $composableBuilder(
      column: $table.tagsJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get metadataJson => $composableBuilder(
      column: $table.metadataJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  $$ProjectsTableOrderingComposer get projectId {
    final $$ProjectsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.projectId,
        referencedTable: $db.projects,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProjectsTableOrderingComposer(
              $db: $db,
              $table: $db.projects,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ResearchItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ResearchItemsTable> {
  $$ResearchItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get targetType => $composableBuilder(
      column: $table.targetType, builder: (column) => column);

  GeneratedColumn<String> get targetId =>
      $composableBuilder(column: $table.targetId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get uri =>
      $composableBuilder(column: $table.uri, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get tagsJson =>
      $composableBuilder(column: $table.tagsJson, builder: (column) => column);

  GeneratedColumn<String> get metadataJson => $composableBuilder(
      column: $table.metadataJson, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$ProjectsTableAnnotationComposer get projectId {
    final $$ProjectsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.projectId,
        referencedTable: $db.projects,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProjectsTableAnnotationComposer(
              $db: $db,
              $table: $db.projects,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ResearchItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ResearchItemsTable,
    ResearchItemRow,
    $$ResearchItemsTableFilterComposer,
    $$ResearchItemsTableOrderingComposer,
    $$ResearchItemsTableAnnotationComposer,
    $$ResearchItemsTableCreateCompanionBuilder,
    $$ResearchItemsTableUpdateCompanionBuilder,
    (ResearchItemRow, $$ResearchItemsTableReferences),
    ResearchItemRow,
    PrefetchHooks Function({bool projectId})> {
  $$ResearchItemsTableTableManager(_$AppDatabase db, $ResearchItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ResearchItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ResearchItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ResearchItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> projectId = const Value.absent(),
            Value<String> kind = const Value.absent(),
            Value<String?> targetType = const Value.absent(),
            Value<String?> targetId = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> uri = const Value.absent(),
            Value<String> body = const Value.absent(),
            Value<String> source = const Value.absent(),
            Value<String> tagsJson = const Value.absent(),
            Value<String> metadataJson = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ResearchItemsCompanion(
            id: id,
            projectId: projectId,
            kind: kind,
            targetType: targetType,
            targetId: targetId,
            title: title,
            uri: uri,
            body: body,
            source: source,
            tagsJson: tagsJson,
            metadataJson: metadataJson,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String projectId,
            required String kind,
            Value<String?> targetType = const Value.absent(),
            Value<String?> targetId = const Value.absent(),
            required String title,
            Value<String> uri = const Value.absent(),
            Value<String> body = const Value.absent(),
            Value<String> source = const Value.absent(),
            Value<String> tagsJson = const Value.absent(),
            Value<String> metadataJson = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              ResearchItemsCompanion.insert(
            id: id,
            projectId: projectId,
            kind: kind,
            targetType: targetType,
            targetId: targetId,
            title: title,
            uri: uri,
            body: body,
            source: source,
            tagsJson: tagsJson,
            metadataJson: metadataJson,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$ResearchItemsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({projectId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (projectId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.projectId,
                    referencedTable:
                        $$ResearchItemsTableReferences._projectIdTable(db),
                    referencedColumn:
                        $$ResearchItemsTableReferences._projectIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$ResearchItemsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ResearchItemsTable,
    ResearchItemRow,
    $$ResearchItemsTableFilterComposer,
    $$ResearchItemsTableOrderingComposer,
    $$ResearchItemsTableAnnotationComposer,
    $$ResearchItemsTableCreateCompanionBuilder,
    $$ResearchItemsTableUpdateCompanionBuilder,
    (ResearchItemRow, $$ResearchItemsTableReferences),
    ResearchItemRow,
    PrefetchHooks Function({bool projectId})>;
typedef $$AIProviderConfigsTableCreateCompanionBuilder
    = AIProviderConfigsCompanion Function({
  required String id,
  required String kind,
  required String displayName,
  required String modelName,
  Value<String?> baseUrl,
  Value<String?> encryptedApiKeyRef,
  Value<String> parametersJson,
  required bool enabled,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$AIProviderConfigsTableUpdateCompanionBuilder
    = AIProviderConfigsCompanion Function({
  Value<String> id,
  Value<String> kind,
  Value<String> displayName,
  Value<String> modelName,
  Value<String?> baseUrl,
  Value<String?> encryptedApiKeyRef,
  Value<String> parametersJson,
  Value<bool> enabled,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$AIProviderConfigsTableFilterComposer
    extends Composer<_$AppDatabase, $AIProviderConfigsTable> {
  $$AIProviderConfigsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get kind => $composableBuilder(
      column: $table.kind, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get modelName => $composableBuilder(
      column: $table.modelName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get baseUrl => $composableBuilder(
      column: $table.baseUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get encryptedApiKeyRef => $composableBuilder(
      column: $table.encryptedApiKeyRef,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get parametersJson => $composableBuilder(
      column: $table.parametersJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get enabled => $composableBuilder(
      column: $table.enabled, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$AIProviderConfigsTableOrderingComposer
    extends Composer<_$AppDatabase, $AIProviderConfigsTable> {
  $$AIProviderConfigsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get kind => $composableBuilder(
      column: $table.kind, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get modelName => $composableBuilder(
      column: $table.modelName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get baseUrl => $composableBuilder(
      column: $table.baseUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get encryptedApiKeyRef => $composableBuilder(
      column: $table.encryptedApiKeyRef,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get parametersJson => $composableBuilder(
      column: $table.parametersJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get enabled => $composableBuilder(
      column: $table.enabled, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$AIProviderConfigsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AIProviderConfigsTable> {
  $$AIProviderConfigsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => column);

  GeneratedColumn<String> get modelName =>
      $composableBuilder(column: $table.modelName, builder: (column) => column);

  GeneratedColumn<String> get baseUrl =>
      $composableBuilder(column: $table.baseUrl, builder: (column) => column);

  GeneratedColumn<String> get encryptedApiKeyRef => $composableBuilder(
      column: $table.encryptedApiKeyRef, builder: (column) => column);

  GeneratedColumn<String> get parametersJson => $composableBuilder(
      column: $table.parametersJson, builder: (column) => column);

  GeneratedColumn<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AIProviderConfigsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AIProviderConfigsTable,
    AIProviderConfigRow,
    $$AIProviderConfigsTableFilterComposer,
    $$AIProviderConfigsTableOrderingComposer,
    $$AIProviderConfigsTableAnnotationComposer,
    $$AIProviderConfigsTableCreateCompanionBuilder,
    $$AIProviderConfigsTableUpdateCompanionBuilder,
    (
      AIProviderConfigRow,
      BaseReferences<_$AppDatabase, $AIProviderConfigsTable,
          AIProviderConfigRow>
    ),
    AIProviderConfigRow,
    PrefetchHooks Function()> {
  $$AIProviderConfigsTableTableManager(
      _$AppDatabase db, $AIProviderConfigsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AIProviderConfigsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AIProviderConfigsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AIProviderConfigsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> kind = const Value.absent(),
            Value<String> displayName = const Value.absent(),
            Value<String> modelName = const Value.absent(),
            Value<String?> baseUrl = const Value.absent(),
            Value<String?> encryptedApiKeyRef = const Value.absent(),
            Value<String> parametersJson = const Value.absent(),
            Value<bool> enabled = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AIProviderConfigsCompanion(
            id: id,
            kind: kind,
            displayName: displayName,
            modelName: modelName,
            baseUrl: baseUrl,
            encryptedApiKeyRef: encryptedApiKeyRef,
            parametersJson: parametersJson,
            enabled: enabled,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String kind,
            required String displayName,
            required String modelName,
            Value<String?> baseUrl = const Value.absent(),
            Value<String?> encryptedApiKeyRef = const Value.absent(),
            Value<String> parametersJson = const Value.absent(),
            required bool enabled,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              AIProviderConfigsCompanion.insert(
            id: id,
            kind: kind,
            displayName: displayName,
            modelName: modelName,
            baseUrl: baseUrl,
            encryptedApiKeyRef: encryptedApiKeyRef,
            parametersJson: parametersJson,
            enabled: enabled,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AIProviderConfigsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AIProviderConfigsTable,
    AIProviderConfigRow,
    $$AIProviderConfigsTableFilterComposer,
    $$AIProviderConfigsTableOrderingComposer,
    $$AIProviderConfigsTableAnnotationComposer,
    $$AIProviderConfigsTableCreateCompanionBuilder,
    $$AIProviderConfigsTableUpdateCompanionBuilder,
    (
      AIProviderConfigRow,
      BaseReferences<_$AppDatabase, $AIProviderConfigsTable,
          AIProviderConfigRow>
    ),
    AIProviderConfigRow,
    PrefetchHooks Function()>;
typedef $$AppPreferencesTableCreateCompanionBuilder = AppPreferencesCompanion
    Function({
  required String key,
  required String value,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$AppPreferencesTableUpdateCompanionBuilder = AppPreferencesCompanion
    Function({
  Value<String> key,
  Value<String> value,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$AppPreferencesTableFilterComposer
    extends Composer<_$AppDatabase, $AppPreferencesTable> {
  $$AppPreferencesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$AppPreferencesTableOrderingComposer
    extends Composer<_$AppDatabase, $AppPreferencesTable> {
  $$AppPreferencesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$AppPreferencesTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppPreferencesTable> {
  $$AppPreferencesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AppPreferencesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AppPreferencesTable,
    AppPreferenceRow,
    $$AppPreferencesTableFilterComposer,
    $$AppPreferencesTableOrderingComposer,
    $$AppPreferencesTableAnnotationComposer,
    $$AppPreferencesTableCreateCompanionBuilder,
    $$AppPreferencesTableUpdateCompanionBuilder,
    (
      AppPreferenceRow,
      BaseReferences<_$AppDatabase, $AppPreferencesTable, AppPreferenceRow>
    ),
    AppPreferenceRow,
    PrefetchHooks Function()> {
  $$AppPreferencesTableTableManager(
      _$AppDatabase db, $AppPreferencesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppPreferencesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppPreferencesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppPreferencesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AppPreferencesCompanion(
            key: key,
            value: value,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String key,
            required String value,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              AppPreferencesCompanion.insert(
            key: key,
            value: value,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AppPreferencesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AppPreferencesTable,
    AppPreferenceRow,
    $$AppPreferencesTableFilterComposer,
    $$AppPreferencesTableOrderingComposer,
    $$AppPreferencesTableAnnotationComposer,
    $$AppPreferencesTableCreateCompanionBuilder,
    $$AppPreferencesTableUpdateCompanionBuilder,
    (
      AppPreferenceRow,
      BaseReferences<_$AppDatabase, $AppPreferencesTable, AppPreferenceRow>
    ),
    AppPreferenceRow,
    PrefetchHooks Function()>;
typedef $$MetricEventsTableCreateCompanionBuilder = MetricEventsCompanion
    Function({
  required String id,
  required String projectId,
  required String eventType,
  Value<double?> value,
  Value<String> metadataJson,
  required DateTime occurredAt,
  Value<int> rowid,
});
typedef $$MetricEventsTableUpdateCompanionBuilder = MetricEventsCompanion
    Function({
  Value<String> id,
  Value<String> projectId,
  Value<String> eventType,
  Value<double?> value,
  Value<String> metadataJson,
  Value<DateTime> occurredAt,
  Value<int> rowid,
});

final class $$MetricEventsTableReferences
    extends BaseReferences<_$AppDatabase, $MetricEventsTable, MetricEventRow> {
  $$MetricEventsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProjectsTable _projectIdTable(_$AppDatabase db) =>
      db.projects.createAlias('metric_events__project_id__projects__id');

  $$ProjectsTableProcessedTableManager get projectId {
    final $_column = $_itemColumn<String>('project_id')!;

    final manager = $$ProjectsTableTableManager($_db, $_db.projects)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_projectIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$MetricEventsTableFilterComposer
    extends Composer<_$AppDatabase, $MetricEventsTable> {
  $$MetricEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get eventType => $composableBuilder(
      column: $table.eventType, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get metadataJson => $composableBuilder(
      column: $table.metadataJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get occurredAt => $composableBuilder(
      column: $table.occurredAt, builder: (column) => ColumnFilters(column));

  $$ProjectsTableFilterComposer get projectId {
    final $$ProjectsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.projectId,
        referencedTable: $db.projects,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProjectsTableFilterComposer(
              $db: $db,
              $table: $db.projects,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$MetricEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $MetricEventsTable> {
  $$MetricEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get eventType => $composableBuilder(
      column: $table.eventType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get metadataJson => $composableBuilder(
      column: $table.metadataJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get occurredAt => $composableBuilder(
      column: $table.occurredAt, builder: (column) => ColumnOrderings(column));

  $$ProjectsTableOrderingComposer get projectId {
    final $$ProjectsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.projectId,
        referencedTable: $db.projects,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProjectsTableOrderingComposer(
              $db: $db,
              $table: $db.projects,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$MetricEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MetricEventsTable> {
  $$MetricEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get eventType =>
      $composableBuilder(column: $table.eventType, builder: (column) => column);

  GeneratedColumn<double> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<String> get metadataJson => $composableBuilder(
      column: $table.metadataJson, builder: (column) => column);

  GeneratedColumn<DateTime> get occurredAt => $composableBuilder(
      column: $table.occurredAt, builder: (column) => column);

  $$ProjectsTableAnnotationComposer get projectId {
    final $$ProjectsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.projectId,
        referencedTable: $db.projects,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProjectsTableAnnotationComposer(
              $db: $db,
              $table: $db.projects,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$MetricEventsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MetricEventsTable,
    MetricEventRow,
    $$MetricEventsTableFilterComposer,
    $$MetricEventsTableOrderingComposer,
    $$MetricEventsTableAnnotationComposer,
    $$MetricEventsTableCreateCompanionBuilder,
    $$MetricEventsTableUpdateCompanionBuilder,
    (MetricEventRow, $$MetricEventsTableReferences),
    MetricEventRow,
    PrefetchHooks Function({bool projectId})> {
  $$MetricEventsTableTableManager(_$AppDatabase db, $MetricEventsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MetricEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MetricEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MetricEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> projectId = const Value.absent(),
            Value<String> eventType = const Value.absent(),
            Value<double?> value = const Value.absent(),
            Value<String> metadataJson = const Value.absent(),
            Value<DateTime> occurredAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MetricEventsCompanion(
            id: id,
            projectId: projectId,
            eventType: eventType,
            value: value,
            metadataJson: metadataJson,
            occurredAt: occurredAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String projectId,
            required String eventType,
            Value<double?> value = const Value.absent(),
            Value<String> metadataJson = const Value.absent(),
            required DateTime occurredAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              MetricEventsCompanion.insert(
            id: id,
            projectId: projectId,
            eventType: eventType,
            value: value,
            metadataJson: metadataJson,
            occurredAt: occurredAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$MetricEventsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({projectId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (projectId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.projectId,
                    referencedTable:
                        $$MetricEventsTableReferences._projectIdTable(db),
                    referencedColumn:
                        $$MetricEventsTableReferences._projectIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$MetricEventsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MetricEventsTable,
    MetricEventRow,
    $$MetricEventsTableFilterComposer,
    $$MetricEventsTableOrderingComposer,
    $$MetricEventsTableAnnotationComposer,
    $$MetricEventsTableCreateCompanionBuilder,
    $$MetricEventsTableUpdateCompanionBuilder,
    (MetricEventRow, $$MetricEventsTableReferences),
    MetricEventRow,
    PrefetchHooks Function({bool projectId})>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ProjectsTableTableManager get projects =>
      $$ProjectsTableTableManager(_db, _db.projects);
  $$ChaptersTableTableManager get chapters =>
      $$ChaptersTableTableManager(_db, _db.chapters);
  $$ScenesTableTableManager get scenes =>
      $$ScenesTableTableManager(_db, _db.scenes);
  $$SceneSnapshotsTableTableManager get sceneSnapshots =>
      $$SceneSnapshotsTableTableManager(_db, _db.sceneSnapshots);
  $$CatalogItemsTableTableManager get catalogItems =>
      $$CatalogItemsTableTableManager(_db, _db.catalogItems);
  $$RelationshipsTableTableManager get relationships =>
      $$RelationshipsTableTableManager(_db, _db.relationships);
  $$AISuggestionsTableTableManager get aISuggestions =>
      $$AISuggestionsTableTableManager(_db, _db.aISuggestions);
  $$ProjectNotesTableTableManager get projectNotes =>
      $$ProjectNotesTableTableManager(_db, _db.projectNotes);
  $$ResearchItemsTableTableManager get researchItems =>
      $$ResearchItemsTableTableManager(_db, _db.researchItems);
  $$AIProviderConfigsTableTableManager get aIProviderConfigs =>
      $$AIProviderConfigsTableTableManager(_db, _db.aIProviderConfigs);
  $$AppPreferencesTableTableManager get appPreferences =>
      $$AppPreferencesTableTableManager(_db, _db.appPreferences);
  $$MetricEventsTableTableManager get metricEvents =>
      $$MetricEventsTableTableManager(_db, _db.metricEvents);
}
