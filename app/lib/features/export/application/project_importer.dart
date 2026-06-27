import 'dart:convert';

import 'package:xml/xml.dart';

import '../../../core/domain/draft_status.dart';
import '../../../core/domain/domain_failure.dart';
import '../../../core/domain/entity_type.dart';
import '../../../core/domain/json_map.dart';
import '../../catalog/domain/catalog_item.dart';
import '../../projects/domain/project.dart';
import '../../structure/domain/chapter.dart';
import '../../structure/domain/scene.dart';
import '../../sync/application/manual_sync_adapter.dart';
import '../../sync/domain/sync_checkpoint.dart';
import 'project_archive_codec.dart';

enum ProjectImportKind {
  writelerArchive,
  writelerSyncCheckpoint,
  yWriter,
  scrivenerOutline,
  plainText,
}

final class ProjectImportInspection {
  const ProjectImportInspection({
    required this.kind,
    required this.archive,
    required this.preview,
    this.syncEnvelope,
  });

  final ProjectImportKind kind;
  final ProjectArchive archive;
  final ProjectArchivePreview preview;
  final SyncEnvelopePreview? syncEnvelope;

  bool get isSyncEnvelope => syncEnvelope != null;
}

final class ProjectImporter {
  const ProjectImporter({
    this.archiveCodec = const ProjectArchiveCodec(),
    this.syncAdapter = const ManualSyncAdapter(),
  });

  final ProjectArchiveCodec archiveCodec;
  final ManualSyncAdapter syncAdapter;

  ProjectImportInspection inspect(
    String source, {
    String? sourceName,
  }) {
    final trimmed = source.trimLeft();
    if (trimmed.isEmpty) {
      throw const DomainFailure('Import source is empty.');
    }

    if (trimmed.startsWith('{')) {
      return _inspectWritelerJson(source, sourceName: sourceName);
    }

    final extension = _extension(sourceName);
    if (trimmed.startsWith('<')) {
      if (extension == 'scrivx' || _looksLikeScrivener(trimmed)) {
        return _inspectScrivener(source, sourceName: sourceName);
      }
      return _inspectYWriter(source, sourceName: sourceName);
    }

    return _inspectPlainText(source, sourceName: sourceName);
  }

  ProjectImportInspection _inspectWritelerJson(
    String source, {
    String? sourceName,
  }) {
    final inspection = syncAdapter.inspectPayload(source);
    final archive = archiveCodec.decode(inspection.archiveSource);
    final preview = _previewForArchive(
      archive,
      schema: inspection.isEnvelope
          ? ManualSyncAdapter.syncSchema
          : 'writeler.project.v3',
      sourceFormat: inspection.isEnvelope ? 'Writeler Sync' : 'Writeler JSON',
      sourceName: sourceName,
    );
    return ProjectImportInspection(
      kind: inspection.isEnvelope
          ? ProjectImportKind.writelerSyncCheckpoint
          : ProjectImportKind.writelerArchive,
      archive: archive,
      preview: preview,
      syncEnvelope: inspection.envelope,
    );
  }

  ProjectImportInspection _inspectYWriter(
    String source, {
    String? sourceName,
  }) {
    final document = XmlDocument.parse(source);
    final now = DateTime.now().toUtc();
    final idFactory = _ImportIdFactory();
    final projectId = idFactory.next('project');
    final root = document.rootElement;
    final projectTitle = _firstText(root, const [
          'Title',
          'ProjectTitle',
          'ProjectName',
          'Name',
        ]) ??
        _sourceTitle(sourceName) ??
        'Imported yWriter Project';
    final project = Project(
      id: projectId,
      title: projectTitle,
      description:
          _firstText(root, const ['Description', 'Desc', 'Notes']) ?? '',
      projectType: 'novel',
      languageCode: 'de',
      status: DraftStatus.planned,
      aiEnabled: true,
      cloudSyncEnabled: false,
      noAiNoCloud: false,
      metadata: {
        'importSource': 'yWriter',
        if (sourceName != null) 'sourceName': sourceName,
      },
      createdAt: now,
      updatedAt: now,
    );

    final chapterElements =
        _elements(document).where((element) => _isName(element, 'chapter'));
    final chapters = <Chapter>[];
    final chapterByElement = <XmlElement, Chapter>{};
    var chapterIndex = 0;
    for (final element in chapterElements) {
      final chapter = Chapter(
        id: idFactory.next('chapter'),
        projectId: projectId,
        title: _elementTitle(element, fallback: 'Kapitel ${chapterIndex + 1}'),
        summary:
            _firstText(element, const ['Description', 'Desc', 'Summary']) ?? '',
        orderIndex: chapterIndex.toDouble(),
        status: DraftStatus.planned,
        metadata: _metadataFor(element, source: 'yWriter'),
        createdAt: now,
        updatedAt: now,
      );
      chapters.add(chapter);
      chapterByElement[element] = chapter;
      chapterIndex++;
    }

    final sceneElements =
        _elements(document).where((element) => _isName(element, 'scene'));
    final scenes = <Scene>[];
    var sceneIndex = 0;
    for (final element in sceneElements) {
      final parentChapter = _ancestorChapter(element, chapterByElement);
      final fallbackChapter =
          parentChapter ?? (chapters.isEmpty ? null : chapters.first);
      final manuscript = _sceneBody(element);
      final summary =
          _firstText(element, const ['Description', 'Desc', 'Summary']) ?? '';
      scenes.add(
        Scene(
          id: idFactory.next('scene'),
          projectId: projectId,
          chapterId: fallbackChapter?.id,
          title: _elementTitle(element, fallback: 'Szene ${sceneIndex + 1}'),
          summary: summary,
          manuscriptText: manuscript,
          status: DraftStatus.planned,
          orderIndex: sceneIndex.toDouble(),
          goal: _firstText(element, const ['Goal', 'Purpose']),
          conflict: _firstText(element, const ['Conflict']),
          outcome: _firstText(element, const ['Outcome', 'Result']),
          aiAssistAllowed: true,
          metadata: _metadataFor(element, source: 'yWriter'),
          createdAt: now,
          updatedAt: now,
        ),
      );
      sceneIndex++;
    }

    if (chapters.isEmpty && scenes.isNotEmpty) {
      final chapter = Chapter(
        id: idFactory.next('chapter'),
        projectId: projectId,
        title: 'Import',
        orderIndex: 0,
        status: DraftStatus.planned,
        metadata: const {'importSource': 'yWriter'},
        createdAt: now,
        updatedAt: now,
      );
      chapters.add(chapter);
      for (var index = 0; index < scenes.length; index++) {
        scenes[index] = scenes[index].copyWith(chapterId: chapter.id);
      }
    }

    final catalogItems = [
      ..._catalogItemsFromXml(
        document,
        projectId: projectId,
        idFactory: idFactory,
        now: now,
        elementName: 'character',
        type: EntityType.character,
        source: 'yWriter',
      ),
      ..._catalogItemsFromXml(
        document,
        projectId: projectId,
        idFactory: idFactory,
        now: now,
        elementName: 'location',
        type: EntityType.location,
        source: 'yWriter',
      ),
      ..._catalogItemsFromXml(
        document,
        projectId: projectId,
        idFactory: idFactory,
        now: now,
        elementName: 'item',
        type: EntityType.object,
        source: 'yWriter',
      ),
    ];

    final hasRecognizedContent =
        chapters.isNotEmpty || scenes.isNotEmpty || catalogItems.isNotEmpty;
    if (!hasRecognizedContent &&
        !_looksLikeYWriterSource(document, sourceName: sourceName)) {
      throw const DomainFailure(
        'XML import is not recognized as yWriter or Scrivener.',
      );
    }

    final archive = ProjectArchive(
      project: project,
      chapters: chapters,
      scenes: scenes,
      catalogItems: catalogItems,
      relationships: const [],
      notes: const [],
    );
    return ProjectImportInspection(
      kind: ProjectImportKind.yWriter,
      archive: archive,
      preview: _previewForArchive(
        archive,
        schema: 'ywriter.xml',
        sourceFormat: 'yWriter',
        sourceName: sourceName,
      ),
    );
  }

  ProjectImportInspection _inspectScrivener(
    String source, {
    String? sourceName,
  }) {
    final document = XmlDocument.parse(source);
    final now = DateTime.now().toUtc();
    final idFactory = _ImportIdFactory();
    final projectId = idFactory.next('project');
    final title = _firstText(document.rootElement, const ['Title', 'Name']) ??
        _sourceTitle(sourceName) ??
        'Imported Scrivener Project';
    final project = Project(
      id: projectId,
      title: title,
      projectType: 'novel',
      languageCode: 'de',
      status: DraftStatus.planned,
      aiEnabled: true,
      cloudSyncEnabled: false,
      noAiNoCloud: false,
      metadata: {
        'importSource': 'Scrivener',
        if (sourceName != null) 'sourceName': sourceName,
      },
      createdAt: now,
      updatedAt: now,
    );
    final chapters = <Chapter>[];
    final scenes = <Scene>[];
    Chapter? currentChapter;
    var chapterIndex = 0;
    var sceneIndex = 0;
    for (final element in _elements(document)
        .where((element) => _isName(element, 'BinderItem'))) {
      final type = _attribute(element, 'Type')?.toLowerCase() ?? '';
      final title =
          _elementTitle(element, fallback: 'Import ${sceneIndex + 1}');
      if (type.contains('folder')) {
        currentChapter = Chapter(
          id: idFactory.next('chapter'),
          projectId: projectId,
          title: title,
          summary: _firstText(element, const ['Synopsis']) ?? '',
          orderIndex: chapterIndex.toDouble(),
          status: DraftStatus.planned,
          metadata: _metadataFor(element, source: 'Scrivener'),
          createdAt: now,
          updatedAt: now,
        );
        chapters.add(currentChapter);
        chapterIndex++;
      } else if (type.contains('text') || type.isEmpty) {
        scenes.add(
          Scene(
            id: idFactory.next('scene'),
            projectId: projectId,
            chapterId: currentChapter?.id,
            title: title,
            summary: _firstText(element, const ['Synopsis']) ?? '',
            manuscriptText:
                _firstText(element, const ['Text', 'Content', 'Synopsis']) ??
                    '',
            status: DraftStatus.planned,
            orderIndex: sceneIndex.toDouble(),
            aiAssistAllowed: true,
            metadata: _metadataFor(element, source: 'Scrivener'),
            createdAt: now,
            updatedAt: now,
          ),
        );
        sceneIndex++;
      }
    }
    if (chapters.isEmpty && scenes.isEmpty) {
      throw const DomainFailure(
          'Scrivener outline contains no importable items.');
    }
    final archive = ProjectArchive(
      project: project,
      chapters: chapters,
      scenes: scenes,
      catalogItems: const [],
      relationships: const [],
      notes: const [],
    );
    return ProjectImportInspection(
      kind: ProjectImportKind.scrivenerOutline,
      archive: archive,
      preview: _previewForArchive(
        archive,
        schema: 'scrivener.scrivx',
        sourceFormat: 'Scrivener Outline',
        sourceName: sourceName,
      ),
    );
  }

  ProjectImportInspection _inspectPlainText(
    String source, {
    String? sourceName,
  }) {
    final now = DateTime.now().toUtc();
    final idFactory = _ImportIdFactory();
    final projectId = idFactory.next('project');
    final title = _sourceTitle(sourceName) ?? 'Imported Text';
    final project = Project(
      id: projectId,
      title: title,
      projectType: 'novel',
      languageCode: 'de',
      status: DraftStatus.planned,
      aiEnabled: true,
      cloudSyncEnabled: false,
      noAiNoCloud: false,
      metadata: {
        'importSource': 'Plain text',
        if (sourceName != null) 'sourceName': sourceName,
      },
      createdAt: now,
      updatedAt: now,
    );
    final chapter = Chapter(
      id: idFactory.next('chapter'),
      projectId: projectId,
      title: 'Import',
      orderIndex: 0,
      status: DraftStatus.planned,
      metadata: const {'importSource': 'Plain text'},
      createdAt: now,
      updatedAt: now,
    );
    final chunks = _splitTextSections(source);
    final scenes = [
      for (var index = 0; index < chunks.length; index++)
        Scene(
          id: idFactory.next('scene'),
          projectId: projectId,
          chapterId: chapter.id,
          title: chunks[index].title,
          manuscriptText: chunks[index].body,
          status: DraftStatus.planned,
          orderIndex: index.toDouble(),
          aiAssistAllowed: true,
          metadata: const {'importSource': 'Plain text'},
          createdAt: now,
          updatedAt: now,
        ),
    ];
    final archive = ProjectArchive(
      project: project,
      chapters: [chapter],
      scenes: scenes,
      catalogItems: const [],
      relationships: const [],
      notes: const [],
    );
    return ProjectImportInspection(
      kind: ProjectImportKind.plainText,
      archive: archive,
      preview: _previewForArchive(
        archive,
        schema: 'text.markdown',
        sourceFormat: 'Text / Markdown',
        sourceName: sourceName,
      ),
    );
  }

  ProjectArchivePreview _previewForArchive(
    ProjectArchive archive, {
    required String schema,
    required String sourceFormat,
    String? sourceName,
  }) {
    return ProjectArchivePreview(
      schema: schema,
      projectTitle: archive.project.title,
      chapterCount: archive.chapters.length,
      sceneCount: archive.scenes.length,
      catalogItemCount: archive.catalogItems.length,
      relationshipCount: archive.relationships.length,
      noteCount: archive.notes.length,
      researchItemCount: archive.researchItems.length,
      sourceFormat: sourceFormat,
      sourceName: sourceName,
    );
  }

  Iterable<XmlElement> _elements(XmlDocument document) =>
      document.descendants.whereType<XmlElement>();

  bool _isName(XmlElement element, String name) =>
      element.name.local.toLowerCase() == name.toLowerCase();

  bool _looksLikeScrivener(String source) {
    final lower = source.toLowerCase();
    return lower.contains('<scrivenerproject') || lower.contains('<binderitem');
  }

  bool _looksLikeYWriterSource(
    XmlDocument document, {
    required String? sourceName,
  }) {
    final extension = _extension(sourceName);
    if (extension == 'yw5' || extension == 'yw6' || extension == 'yw7') {
      return true;
    }
    final rootName = document.rootElement.name.local.toLowerCase();
    return rootName.contains('ywriter');
  }

  String? _firstText(XmlElement element, List<String> names) {
    for (final name in names) {
      final found =
          element.childElements.where((child) => _isName(child, name));
      for (final child in found) {
        final text = _cleanText(child.innerText);
        if (text.isNotEmpty) return text;
      }
    }
    for (final name in names) {
      final value = _attribute(element, name);
      if (value != null && value.trim().isNotEmpty) {
        return _cleanText(value);
      }
    }
    return null;
  }

  String _elementTitle(XmlElement element, {required String fallback}) {
    return _firstText(element, const ['Title', 'Name', 'ShortName']) ??
        _attribute(element, 'Title') ??
        _attribute(element, 'Name') ??
        fallback;
  }

  String _sceneBody(XmlElement element) {
    final value = _firstText(element, const [
          'Text',
          'SceneText',
          'Content',
          'Body',
          'RTF',
          'Rtf',
        ]) ??
        '';
    return _stripRtf(value);
  }

  Chapter? _ancestorChapter(
    XmlElement scene,
    Map<XmlElement, Chapter> chapterByElement,
  ) {
    XmlNode? current = scene.parent;
    while (current != null) {
      if (current is XmlElement && chapterByElement.containsKey(current)) {
        return chapterByElement[current];
      }
      current = current.parent;
    }
    return null;
  }

  List<CatalogItem> _catalogItemsFromXml(
    XmlDocument document, {
    required String projectId,
    required _ImportIdFactory idFactory,
    required DateTime now,
    required String elementName,
    required EntityType type,
    required String source,
  }) {
    final items = <CatalogItem>[];
    for (final element in _elements(document)
        .where((element) => _isName(element, elementName))) {
      final name =
          _elementTitle(element, fallback: '${type.name} ${items.length + 1}');
      items.add(
        CatalogItem(
          id: idFactory.next(type.name),
          projectId: projectId,
          type: type,
          name: name,
          summary:
              _firstText(element, const ['Description', 'Desc', 'Notes']) ?? '',
          status: DraftStatus.planned,
          fields: _fieldsFor(element),
          metadata: _metadataFor(element, source: source),
          createdAt: now,
          updatedAt: now,
        ),
      );
    }
    return items;
  }

  JsonMap _fieldsFor(XmlElement element) {
    final fields = <String, Object?>{};
    for (final child in element.childElements) {
      final name = child.name.local;
      if (_knownStructuralField(name)) continue;
      final value = _cleanText(child.innerText);
      if (value.isNotEmpty) fields[name] = value;
    }
    return fields;
  }

  JsonMap _metadataFor(XmlElement element, {required String source}) {
    return {
      'importSource': source,
      for (final attribute in element.attributes)
        'source.${attribute.name.local}': attribute.value,
    };
  }

  bool _knownStructuralField(String name) {
    final lower = name.toLowerCase();
    return const {
      'title',
      'name',
      'shortname',
      'description',
      'desc',
      'summary',
      'notes',
      'text',
      'scenetext',
      'content',
      'body',
      'rtf',
    }.contains(lower);
  }

  List<_TextSection> _splitTextSections(String source) {
    final lines = const LineSplitter().convert(source);
    final sections = <_TextSection>[];
    var currentTitle = 'Import';
    final buffer = StringBuffer();
    for (final line in lines) {
      final heading = RegExp(r'^\s{0,3}#{1,3}\s+(.+)$').firstMatch(line);
      if (heading != null && buffer.toString().trim().isNotEmpty) {
        sections.add(_TextSection(currentTitle, buffer.toString().trim()));
        buffer.clear();
        currentTitle = heading.group(1)!.trim();
      } else if (heading != null) {
        currentTitle = heading.group(1)!.trim();
      } else {
        buffer.writeln(line);
      }
    }
    if (buffer.toString().trim().isNotEmpty) {
      sections.add(_TextSection(currentTitle, buffer.toString().trim()));
    }
    if (sections.isEmpty) {
      return [_TextSection('Import', source.trim())];
    }
    return sections;
  }

  String? _attribute(XmlElement element, String name) {
    for (final attribute in element.attributes) {
      if (attribute.name.local.toLowerCase() == name.toLowerCase()) {
        return attribute.value;
      }
    }
    return null;
  }

  String _cleanText(String value) {
    return value
        .replaceAll('\r\n', '\n')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trim();
  }

  String _stripRtf(String value) {
    if (!value.trimLeft().startsWith('{\\rtf')) return _cleanText(value);
    return _cleanText(
      value
          .replaceAll(RegExp(r'\\[a-zA-Z]+-?\d* ?'), '')
          .replaceAll(RegExp(r'[{}]'), '')
          .replaceAll("\\'a0", ' '),
    );
  }

  String? _sourceTitle(String? sourceName) {
    if (sourceName == null || sourceName.trim().isEmpty) return null;
    final name = sourceName.split(RegExp(r'[\\/]')).last;
    return name.replaceFirst(RegExp(r'\.[^.]+$'), '').trim();
  }

  String? _extension(String? sourceName) {
    if (sourceName == null) return null;
    final match = RegExp(r'\.([^.]+)$').firstMatch(sourceName);
    return match?.group(1)?.toLowerCase();
  }
}

final class _ImportIdFactory {
  var _counter = 0;

  String next(String prefix) {
    _counter++;
    return '$prefix-${DateTime.now().toUtc().microsecondsSinceEpoch}-$_counter';
  }
}

final class _TextSection {
  const _TextSection(this.title, this.body);

  final String title;
  final String body;
}
