import 'dart:convert';

import '../../../core/domain/domain_failure.dart';
import '../../../core/domain/json_map.dart';
import '../../catalog/domain/catalog_item.dart';
import '../../catalog/domain/relationship.dart';
import '../../notes/domain/project_note.dart';
import '../../projects/domain/project.dart';
import '../../research/domain/research_item.dart';
import '../../structure/domain/chapter.dart';
import '../../structure/domain/scene.dart';

final class ProjectArchive {
  const ProjectArchive({
    required this.project,
    required this.chapters,
    required this.scenes,
    required this.catalogItems,
    required this.relationships,
    this.notes = const [],
    this.researchItems = const [],
  });

  final Project project;
  final List<Chapter> chapters;
  final List<Scene> scenes;
  final List<CatalogItem> catalogItems;
  final List<Relationship> relationships;
  final List<ProjectNote> notes;
  final List<ResearchItem> researchItems;
}

final class ProjectArchivePreview {
  const ProjectArchivePreview({
    required this.schema,
    required this.projectTitle,
    required this.chapterCount,
    required this.sceneCount,
    required this.catalogItemCount,
    required this.relationshipCount,
    required this.noteCount,
    required this.researchItemCount,
    this.sourceFormat = 'Writeler',
    this.sourceName,
  });

  final String schema;
  final String projectTitle;
  final int chapterCount;
  final int sceneCount;
  final int catalogItemCount;
  final int relationshipCount;
  final int noteCount;
  final int researchItemCount;
  final String sourceFormat;
  final String? sourceName;
}

final class ProjectArchiveCodec {
  const ProjectArchiveCodec();

  String encode(ProjectArchive archive) {
    return const JsonEncoder.withIndent('  ').convert({
      'schema': 'writeler.project.v3',
      'project': archive.project.toJson(),
      'chapters': archive.chapters.map((chapter) => chapter.toJson()).toList(),
      'scenes': archive.scenes.map((scene) => scene.toJson()).toList(),
      'catalogItems':
          archive.catalogItems.map((item) => item.toJson()).toList(),
      'relationships': archive.relationships
          .map((relationship) => relationship.toJson())
          .toList(),
      'notes': archive.notes.map((note) => note.toJson()).toList(),
      'researchItems':
          archive.researchItems.map((item) => item.toJson()).toList(),
    });
  }

  ProjectArchive decode(String source) {
    final decoded = jsonDecode(source);
    if (decoded is! Map) {
      throw const DomainFailure('Project archive must be a JSON object.');
    }

    final json = Map<String, Object?>.from(decoded);
    final schema = json['schema'] as String?;
    if (!_supportedSchema(schema)) {
      throw DomainFailure(
          'Unsupported project archive schema: ${schema ?? 'missing'}.');
    }

    final projectJson = _object(json['project'], 'project');
    final chapterJson = _list(json['chapters'] ?? const [], 'chapters');
    final sceneJson = _list(json['scenes'], 'scenes');
    final catalogJson = _list(json['catalogItems'] ?? const [], 'catalogItems');
    final relationshipJson =
        _list(json['relationships'] ?? const [], 'relationships');
    final noteJson = _list(json['notes'] ?? const [], 'notes');
    final researchJson =
        _list(json['researchItems'] ?? const [], 'researchItems');

    return ProjectArchive(
      project: Project.fromJson(projectJson),
      chapters: chapterJson.map(Chapter.fromJson).toList(),
      scenes: sceneJson.map(Scene.fromJson).toList(),
      catalogItems: catalogJson.map(CatalogItem.fromJson).toList(),
      relationships: relationshipJson.map(Relationship.fromJson).toList(),
      notes: noteJson.map(ProjectNote.fromJson).toList(),
      researchItems: researchJson.map(ResearchItem.fromJson).toList(),
    );
  }

  ProjectArchivePreview preview(String source) {
    final decoded = jsonDecode(source);
    if (decoded is! Map) {
      throw const DomainFailure('Project archive must be a JSON object.');
    }

    final json = Map<String, Object?>.from(decoded);
    final schema = json['schema'] as String?;
    if (!_supportedSchema(schema)) {
      throw DomainFailure(
          'Unsupported project archive schema: ${schema ?? 'missing'}.');
    }

    final projectJson = _object(json['project'], 'project');
    return ProjectArchivePreview(
      schema: schema!,
      projectTitle: projectJson['title'] as String? ?? 'Untitled Project',
      chapterCount: _list(json['chapters'] ?? const [], 'chapters').length,
      sceneCount: _list(json['scenes'], 'scenes').length,
      catalogItemCount:
          _list(json['catalogItems'] ?? const [], 'catalogItems').length,
      relationshipCount:
          _list(json['relationships'] ?? const [], 'relationships').length,
      noteCount: _list(json['notes'] ?? const [], 'notes').length,
      researchItemCount:
          _list(json['researchItems'] ?? const [], 'researchItems').length,
    );
  }

  bool _supportedSchema(String? schema) {
    return schema == 'writeler.project.v1' ||
        schema == 'writeler.project.v2' ||
        schema == 'writeler.project.v3';
  }

  JsonMap _object(Object? value, String fieldName) {
    if (value is! Map) {
      throw DomainFailure(
          'Project archive field "$fieldName" must be an object.');
    }
    return Map<String, Object?>.from(value);
  }

  List<JsonMap> _list(Object? value, String fieldName) {
    if (value is! List) {
      throw DomainFailure('Project archive field "$fieldName" must be a list.');
    }
    return [
      for (final item in value) _object(item, fieldName),
    ];
  }
}
