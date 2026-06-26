import 'dart:convert';
import 'dart:typed_data';

import '../../../core/domain/entity_type.dart';
import '../../catalog/domain/catalog_item.dart';
import '../../catalog/domain/relationship.dart';
import '../../notes/domain/project_note.dart';
import '../../projects/domain/project.dart';
import '../../structure/domain/chapter.dart';
import '../../structure/domain/scene.dart';
import '../domain/export_artifact.dart';
import 'project_archive_codec.dart';
import 'document_package_exporter.dart';
import '../domain/export_profile.dart';

final class ProjectExporter {
  const ProjectExporter({
    this.archiveCodec = const ProjectArchiveCodec(),
    this.documentPackageExporter = const DocumentPackageExporter(),
  });

  final ProjectArchiveCodec archiveCodec;
  final DocumentPackageExporter documentPackageExporter;

  String exportProject({
    required Project project,
    required List<Scene> scenes,
    required ExportProfile profile,
    List<Chapter> chapters = const [],
    List<CatalogItem> catalogItems = const [],
    List<Relationship> relationships = const [],
    List<ProjectNote> notes = const [],
  }) {
    switch (profile.format) {
      case ExportFormat.markdown:
        return _toMarkdown(
          project: project,
          chapters: chapters,
          scenes: scenes,
          catalogItems: catalogItems,
          relationships: relationships,
          notes: notes,
          profile: profile,
        );
      case ExportFormat.plainText:
        return _toPlainText(project, scenes, profile);
      case ExportFormat.outline:
        return _toOutline(
          project,
          chapters,
          scenes,
          catalogItems,
          relationships,
          notes,
          profile,
        );
      case ExportFormat.json:
        return archiveCodec.encode(
          ProjectArchive(
            project: project,
            chapters: chapters,
            scenes: scenes,
            catalogItems: catalogItems,
            relationships: relationships,
            notes: notes,
          ),
        );
      case ExportFormat.yWriter:
        return _toYWriterXml(
          project: project,
          chapters: chapters,
          scenes: scenes,
          catalogItems: catalogItems,
        );
      case ExportFormat.scrivener:
        return _toScrivenerOutline(
          project: project,
          chapters: chapters,
          scenes: scenes,
        );
      case ExportFormat.html:
        return _toHtml(
          project: project,
          chapters: chapters,
          scenes: scenes,
          catalogItems: catalogItems,
          relationships: relationships,
          notes: notes,
          profile: profile,
        );
      case ExportFormat.pdf:
      case ExportFormat.epub:
      case ExportFormat.docx:
        return _toPackagedPreview(
          project: project,
          chapters: chapters,
          scenes: scenes,
          catalogItems: catalogItems,
          relationships: relationships,
          notes: notes,
          profile: profile,
        );
    }
  }

  ExportArtifact exportArtifact({
    required Project project,
    required List<Scene> scenes,
    required ExportProfile profile,
    List<Chapter> chapters = const [],
    List<CatalogItem> catalogItems = const [],
    List<Relationship> relationships = const [],
    List<ProjectNote> notes = const [],
  }) {
    final previewText = exportProject(
      project: project,
      scenes: scenes,
      profile: profile,
      chapters: chapters,
      catalogItems: catalogItems,
      relationships: relationships,
      notes: notes,
    );
    final slug = _fileSlug(project.title);
    switch (profile.format) {
      case ExportFormat.markdown:
        return _textArtifact(
            '$slug.md', 'text/markdown; charset=utf-8', previewText);
      case ExportFormat.html:
        return _textArtifact(
            '$slug.html', 'text/html; charset=utf-8', previewText);
      case ExportFormat.plainText:
        return _textArtifact(
            '$slug.txt', 'text/plain; charset=utf-8', previewText);
      case ExportFormat.outline:
        return _textArtifact(
            '$slug-outline.md', 'text/markdown; charset=utf-8', previewText);
      case ExportFormat.json:
        return _textArtifact('$slug.writeler.json',
            'application/json; charset=utf-8', previewText);
      case ExportFormat.yWriter:
        return _textArtifact(
            '$slug.yw7', 'application/xml; charset=utf-8', previewText);
      case ExportFormat.scrivener:
        return _textArtifact(
            '$slug.scrivx', 'application/xml; charset=utf-8', previewText);
      case ExportFormat.pdf:
        return ExportArtifact(
          fileName: '$slug.pdf',
          mimeType: 'application/pdf',
          bytes: documentPackageExporter.toPdf(
            project: project,
            chapters: chapters,
            scenes: scenes,
            catalogItems: catalogItems,
            relationships: relationships,
            notes: notes,
            includeMetadata: profile.includeMetadata,
            includeSceneTitles: profile.includeSceneTitles,
            style: profile.publishingStyle,
          ),
          previewText: previewText,
        );
      case ExportFormat.epub:
        return ExportArtifact(
          fileName: '$slug.epub',
          mimeType: 'application/epub+zip',
          bytes: documentPackageExporter.toEpub(
            project: project,
            chapters: chapters,
            scenes: scenes,
            includeSceneTitles: profile.includeSceneTitles,
            style: profile.publishingStyle,
          ),
          previewText: previewText,
        );
      case ExportFormat.docx:
        return ExportArtifact(
          fileName: '$slug.docx',
          mimeType:
              'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
          bytes: documentPackageExporter.toDocx(
            project: project,
            chapters: chapters,
            scenes: scenes,
            catalogItems: catalogItems,
            relationships: relationships,
            notes: notes,
            includeMetadata: profile.includeMetadata,
            includeSceneTitles: profile.includeSceneTitles,
            style: profile.publishingStyle,
          ),
          previewText: previewText,
        );
    }
  }

  ExportArtifact _textArtifact(
      String fileName, String mimeType, String source) {
    return ExportArtifact(
      fileName: fileName,
      mimeType: mimeType,
      bytes: Uint8List.fromList(utf8.encode(source)),
      previewText: source,
      isText: true,
    );
  }

  String _toMarkdown({
    required Project project,
    required List<Chapter> chapters,
    required List<Scene> scenes,
    required List<CatalogItem> catalogItems,
    required List<Relationship> relationships,
    required List<ProjectNote> notes,
    required ExportProfile profile,
  }) {
    final buffer = StringBuffer()
      ..writeln('# ${project.title}')
      ..writeln();
    if (profile.includeMetadata) {
      _writeMarkdownMetadata(
        buffer,
        project,
        scenes,
        catalogItems,
        relationships,
        notes,
      );
    }

    for (final group in _chapterGroups(chapters, scenes)) {
      if (group.chapter != null && profile.includeSceneTitles) {
        buffer
          ..writeln('## ${group.chapter!.title}')
          ..writeln();
      }
      for (final scene in group.scenes) {
        if (profile.includeSceneTitles) {
          buffer
            ..writeln(group.chapter == null
                ? '## ${scene.title}'
                : '### ${scene.title}')
            ..writeln();
        }
        if (scene.manuscriptText.trim().isNotEmpty) {
          buffer
            ..writeln(scene.manuscriptText.trim())
            ..writeln();
        }
      }
    }
    if (profile.includeMetadata) {
      _writeMarkdownNotes(
        buffer,
        notes,
        scenes: scenes,
        catalogItems: catalogItems,
      );
    }
    return buffer.toString();
  }

  String _toPlainText(
      Project project, List<Scene> scenes, ExportProfile profile) {
    final buffer = StringBuffer();
    for (final scene in scenes) {
      if (profile.includeSceneTitles) {
        buffer
          ..writeln(scene.title)
          ..writeln(List.filled(scene.title.length, '=').join())
          ..writeln();
      }
      if (scene.manuscriptText.trim().isNotEmpty) {
        buffer
          ..writeln(scene.manuscriptText.trim())
          ..writeln();
      }
    }
    return buffer.toString();
  }

  String _toOutline(
    Project project,
    List<Chapter> chapters,
    List<Scene> scenes,
    List<CatalogItem> catalogItems,
    List<Relationship> relationships,
    List<ProjectNote> notes,
    ExportProfile profile,
  ) {
    final buffer = StringBuffer()
      ..writeln('# ${project.title} - Outline')
      ..writeln();
    if (profile.includeMetadata) {
      _writeMarkdownMetadata(
        buffer,
        project,
        scenes,
        catalogItems,
        relationships,
        notes,
      );
    }

    for (final group in _chapterGroups(chapters, scenes)) {
      if (group.chapter != null) {
        buffer
          ..writeln('## ${group.chapter!.title}')
          ..writeln();
        if (group.chapter!.summary.trim().isNotEmpty) {
          buffer
            ..writeln(group.chapter!.summary.trim())
            ..writeln();
        }
      }
      for (final scene in group.scenes) {
        buffer.writeln(
            '- ${scene.title} (${scene.status.name}, ${scene.actualWordCount} words)');
        if (scene.summary.trim().isNotEmpty) {
          buffer.writeln('  - Summary: ${scene.summary.trim()}');
        }
        _writeOptionalOutlineField(buffer, 'Goal', scene.goal);
        _writeOptionalOutlineField(buffer, 'Conflict', scene.conflict);
        _writeOptionalOutlineField(buffer, 'Outcome', scene.outcome);
      }
      buffer.writeln();
    }
    _writeMarkdownNotes(
      buffer,
      notes,
      scenes: scenes,
      catalogItems: catalogItems,
    );
    return buffer.toString();
  }

  String _toHtml({
    required Project project,
    required List<Chapter> chapters,
    required List<Scene> scenes,
    required List<CatalogItem> catalogItems,
    required List<Relationship> relationships,
    required List<ProjectNote> notes,
    required ExportProfile profile,
  }) {
    final escape = const HtmlEscape().convert;
    final style = _htmlPublishingStyle(profile.publishingStyle);
    final buffer = StringBuffer()
      ..write('<!doctype html><html><head><meta charset="utf-8">')
      ..write('<title>${escape(project.title)}</title>')
      ..write('<style>$style')
      ..write(
          'h1,h2,h3{line-height:1.2;} .meta,.notes{font-family:sans-serif;color:#555;border-bottom:1px solid #ddd;padding-bottom:16px;margin-bottom:28px;} .note-target{font-weight:bold;color:#333;}')
      ..write('</style></head><body>')
      ..write('<h1>${escape(project.title)}</h1>');

    if (profile.includeMetadata) {
      buffer.write(
        '<div class="meta">${scenes.length} scenes - '
        '${scenes.fold<int>(0, (sum, scene) => sum + scene.actualWordCount)} words - '
        '${catalogItems.length} catalog items - ${relationships.length} links - '
        '${notes.length} notes</div>',
      );
    }

    for (final group in _chapterGroups(chapters, scenes)) {
      if (group.chapter != null && profile.includeSceneTitles) {
        buffer.write('<h2>${escape(group.chapter!.title)}</h2>');
      }
      for (final scene in group.scenes) {
        if (profile.includeSceneTitles) {
          buffer.write(group.chapter == null
              ? '<h2>${escape(scene.title)}</h2>'
              : '<h3>${escape(scene.title)}</h3>');
        }
        for (final paragraph in _paragraphs(scene.manuscriptText)) {
          buffer.write('<p>${escape(paragraph)}</p>');
        }
      }
    }

    if (profile.includeMetadata && notes.isNotEmpty) {
      buffer.write('<section class="notes"><h2>Notes</h2>');
      for (final note in notes) {
        buffer
          ..write('<article>')
          ..write('<h3>${escape(note.title)}</h3>')
          ..write(
            '<p class="note-target">${escape(_noteTargetLabel(note, scenes, catalogItems))}</p>',
          );
        for (final paragraph in _paragraphs(note.body)) {
          buffer.write('<p>${escape(paragraph)}</p>');
        }
        buffer.write('</article>');
      }
      buffer.write('</section>');
    }

    return '${buffer.toString()}</body></html>';
  }

  String _htmlPublishingStyle(PublishingStyle style) {
    return switch (style) {
      PublishingStyle.manuscript =>
        'body{font-family:serif;max-width:760px;margin:48px auto;line-height:1.65;padding:0 24px;}p{text-indent:1.2em;margin:0 0 .8em;}',
      PublishingStyle.paperback =>
        'body{font-family:Garamond,serif;max-width:680px;margin:44px auto;line-height:1.5;padding:0 20px;}p{text-indent:1.1em;margin:0 0 .35em;}',
      PublishingStyle.ebook =>
        'body{font-family:Georgia,serif;max-width:720px;margin:36px auto;line-height:1.55;padding:0 20px;}p{text-indent:1em;margin:0 0 .55em;}',
      PublishingStyle.largePrint =>
        'body{font-family:Georgia,serif;max-width:780px;margin:44px auto;line-height:1.7;font-size:1.2rem;padding:0 24px;}p{text-indent:1em;margin:0 0 .9em;}',
    };
  }

  String _toPackagedPreview({
    required Project project,
    required List<Chapter> chapters,
    required List<Scene> scenes,
    required List<CatalogItem> catalogItems,
    required List<Relationship> relationships,
    required List<ProjectNote> notes,
    required ExportProfile profile,
  }) {
    final extension = switch (profile.format) {
      ExportFormat.pdf => 'PDF',
      ExportFormat.epub => 'EPUB',
      ExportFormat.docx => 'DOCX',
      ExportFormat.yWriter => 'yWriter',
      ExportFormat.scrivener => 'Scrivener',
      _ => profile.format.name,
    };
    final words =
        scenes.fold<int>(0, (sum, scene) => sum + scene.actualWordCount);
    final buffer = StringBuffer()
      ..writeln('$extension export')
      ..writeln()
      ..writeln('Project: ${project.title}')
      ..writeln('Chapters: ${chapters.length}')
      ..writeln('Scenes: ${scenes.length}')
      ..writeln('Words: $words')
      ..writeln('Catalog items: ${catalogItems.length}')
      ..writeln('Relationships: ${relationships.length}')
      ..writeln('Notes: ${notes.length}')
      ..writeln('Style: ${profile.publishingStyle.name}')
      ..writeln()
      ..writeln(
          'Use the download action to save the generated .$extension file.');
    return buffer.toString();
  }

  void _writeMarkdownMetadata(
    StringBuffer buffer,
    Project project,
    List<Scene> scenes,
    List<CatalogItem> catalogItems,
    List<Relationship> relationships,
    List<ProjectNote> notes,
  ) {
    buffer
      ..writeln('Project type: ${project.projectType}')
      ..writeln('Scenes: ${scenes.length}')
      ..writeln(
          'Words: ${scenes.fold<int>(0, (sum, scene) => sum + scene.actualWordCount)}')
      ..writeln('Catalog items: ${catalogItems.length}')
      ..writeln('Relationships: ${relationships.length}')
      ..writeln('Notes: ${notes.length}')
      ..writeln();
  }

  String _toYWriterXml({
    required Project project,
    required List<Chapter> chapters,
    required List<Scene> scenes,
    required List<CatalogItem> catalogItems,
  }) {
    final buffer = StringBuffer()
      ..writeln('<?xml version="1.0" encoding="UTF-8"?>')
      ..writeln('<YWriterProject>')
      ..writeln('  <Title>${_xml(project.title)}</Title>')
      ..writeln('  <Description>${_xml(project.description)}</Description>')
      ..writeln('  <Chapters>');

    for (final group in _chapterGroups(chapters, scenes)) {
      final chapterTitle = group.chapter?.title ?? 'Import';
      buffer
        ..writeln('    <Chapter>')
        ..writeln('      <Title>${_xml(chapterTitle)}</Title>');
      final summary = group.chapter?.summary.trim();
      if (summary != null && summary.isNotEmpty) {
        buffer.writeln('      <Description>${_xml(summary)}</Description>');
      }
      buffer.writeln('      <Scenes>');
      for (final scene in group.scenes) {
        buffer
          ..writeln('        <Scene>')
          ..writeln('          <Title>${_xml(scene.title)}</Title>');
        if (scene.summary.trim().isNotEmpty) {
          buffer.writeln(
              '          <Description>${_xml(scene.summary.trim())}</Description>');
        }
        if (scene.goal?.trim().isNotEmpty ?? false) {
          buffer.writeln('          <Goal>${_xml(scene.goal!.trim())}</Goal>');
        }
        if (scene.conflict?.trim().isNotEmpty ?? false) {
          buffer.writeln(
              '          <Conflict>${_xml(scene.conflict!.trim())}</Conflict>');
        }
        if (scene.outcome?.trim().isNotEmpty ?? false) {
          buffer.writeln(
              '          <Outcome>${_xml(scene.outcome!.trim())}</Outcome>');
        }
        buffer
          ..writeln(
              '          <Text>${_xml(scene.manuscriptText.trim())}</Text>')
          ..writeln('        </Scene>');
      }
      buffer
        ..writeln('      </Scenes>')
        ..writeln('    </Chapter>');
    }
    buffer.writeln('  </Chapters>');

    void writeCatalog(
        String container, String itemTag, Iterable<CatalogItem> items) {
      buffer.writeln('  <$container>');
      for (final item in items) {
        buffer
          ..writeln('    <$itemTag>')
          ..writeln('      <Name>${_xml(item.name)}</Name>');
        if (item.summary.trim().isNotEmpty) {
          buffer.writeln(
              '      <Description>${_xml(item.summary.trim())}</Description>');
        }
        for (final entry in item.fields.entries) {
          final value = entry.value?.toString().trim();
          if (value == null || value.isEmpty) continue;
          buffer.writeln(
              '      <${_safeXmlName(entry.key)}>${_xml(value)}</${_safeXmlName(entry.key)}>');
        }
        buffer.writeln('    </$itemTag>');
      }
      buffer.writeln('  </$container>');
    }

    writeCatalog(
      'Characters',
      'Character',
      catalogItems.where((item) => item.type == EntityType.character),
    );
    writeCatalog(
      'Locations',
      'Location',
      catalogItems.where((item) => item.type == EntityType.location),
    );
    writeCatalog(
      'Items',
      'Item',
      catalogItems.where((item) => item.type == EntityType.object),
    );

    buffer.writeln('</YWriterProject>');
    return buffer.toString();
  }

  String _toScrivenerOutline({
    required Project project,
    required List<Chapter> chapters,
    required List<Scene> scenes,
  }) {
    final buffer = StringBuffer()
      ..writeln('<?xml version="1.0" encoding="UTF-8"?>')
      ..writeln('<ScrivenerProject>')
      ..writeln('  <Title>${_xml(project.title)}</Title>')
      ..writeln('  <Binder>');

    for (final group in _chapterGroups(chapters, scenes)) {
      final chapterTitle = group.chapter?.title ?? 'Import';
      buffer
        ..writeln('    <BinderItem Type="Folder">')
        ..writeln('      <Title>${_xml(chapterTitle)}</Title>');
      final summary = group.chapter?.summary.trim();
      if (summary != null && summary.isNotEmpty) {
        buffer.writeln('      <Synopsis>${_xml(summary)}</Synopsis>');
      }
      for (final scene in group.scenes) {
        buffer
          ..writeln('      <BinderItem Type="Text">')
          ..writeln('        <Title>${_xml(scene.title)}</Title>');
        if (scene.summary.trim().isNotEmpty) {
          buffer.writeln(
              '        <Synopsis>${_xml(scene.summary.trim())}</Synopsis>');
        }
        buffer
          ..writeln('        <Text>${_xml(scene.manuscriptText.trim())}</Text>')
          ..writeln('      </BinderItem>');
      }
      buffer.writeln('    </BinderItem>');
    }

    buffer
      ..writeln('  </Binder>')
      ..writeln('</ScrivenerProject>');
    return buffer.toString();
  }

  void _writeMarkdownNotes(
    StringBuffer buffer,
    List<ProjectNote> notes, {
    required List<Scene> scenes,
    required List<CatalogItem> catalogItems,
  }) {
    if (notes.isEmpty) return;
    buffer
      ..writeln('## Notes')
      ..writeln();
    for (final note in notes) {
      buffer
        ..writeln('### ${note.title}')
        ..writeln()
        ..writeln('Target: ${_noteTargetLabel(note, scenes, catalogItems)}')
        ..writeln();
      if (note.body.trim().isNotEmpty) {
        buffer
          ..writeln(note.body.trim())
          ..writeln();
      }
    }
  }

  String _noteTargetLabel(
    ProjectNote note,
    List<Scene> scenes,
    List<CatalogItem> catalogItems,
  ) {
    final target = note.target;
    if (target == null) return 'Project';
    final scene = target.type.name == 'scene'
        ? scenes.where((scene) => scene.id == target.id).firstOrNull
        : null;
    if (scene != null) return 'Scene: ${scene.title}';
    final item = catalogItems
        .where((item) => item.type == target.type && item.id == target.id)
        .firstOrNull;
    if (item != null) return '${item.type.name}: ${item.name}';
    return '${target.type.name}: ${target.id}';
  }

  List<_ChapterSceneGroup> _chapterGroups(
      List<Chapter> chapters, List<Scene> scenes) {
    final grouped = <_ChapterSceneGroup>[
      for (final chapter in chapters)
        _ChapterSceneGroup(
          chapter: chapter,
          scenes:
              scenes.where((scene) => scene.chapterId == chapter.id).toList(),
        ),
    ];
    final unchaptered =
        scenes.where((scene) => scene.chapterId == null).toList();
    if (unchaptered.isNotEmpty || grouped.isEmpty) {
      grouped.add(_ChapterSceneGroup(chapter: null, scenes: unchaptered));
    }
    return grouped
        .where((group) => group.scenes.isNotEmpty || group.chapter != null)
        .toList();
  }

  List<String> _paragraphs(String text) {
    return text
        .split(RegExp(r'\n\s*\n'))
        .map((paragraph) => paragraph.trim())
        .where((paragraph) => paragraph.isNotEmpty)
        .toList();
  }

  void _writeOptionalOutlineField(
      StringBuffer buffer, String label, String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return;
    buffer.writeln('  - $label: $trimmed');
  }

  String _fileSlug(String title) {
    final slug = title
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    return slug.isEmpty ? 'writeler-export' : slug;
  }

  String _xml(String value) {
    return const HtmlEscape(HtmlEscapeMode.element).convert(value);
  }

  String _safeXmlName(String value) {
    final cleaned =
        value.replaceAll(RegExp(r'[^A-Za-z0-9_.-]+'), '_').replaceFirstMapped(
              RegExp(r'^([^A-Za-z_])'),
              (match) => '_${match.group(1)}',
            );
    return cleaned.isEmpty ? 'Field' : cleaned;
  }
}

final class _ChapterSceneGroup {
  const _ChapterSceneGroup({
    required this.chapter,
    required this.scenes,
  });

  final Chapter? chapter;
  final List<Scene> scenes;
}
