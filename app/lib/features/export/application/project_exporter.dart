import 'dart:convert';

import '../../catalog/domain/catalog_item.dart';
import '../../catalog/domain/relationship.dart';
import '../../projects/domain/project.dart';
import '../../structure/domain/chapter.dart';
import '../../structure/domain/scene.dart';
import 'project_archive_codec.dart';
import '../domain/export_profile.dart';

final class ProjectExporter {
  const ProjectExporter({
    this.archiveCodec = const ProjectArchiveCodec(),
  });

  final ProjectArchiveCodec archiveCodec;

  String exportProject({
    required Project project,
    required List<Scene> scenes,
    required ExportProfile profile,
    List<Chapter> chapters = const [],
    List<CatalogItem> catalogItems = const [],
    List<Relationship> relationships = const [],
  }) {
    switch (profile.format) {
      case ExportFormat.markdown:
        return _toMarkdown(
          project: project,
          chapters: chapters,
          scenes: scenes,
          catalogItems: catalogItems,
          relationships: relationships,
          profile: profile,
        );
      case ExportFormat.plainText:
        return _toPlainText(project, scenes, profile);
      case ExportFormat.outline:
        return _toOutline(
            project, chapters, scenes, catalogItems, relationships, profile);
      case ExportFormat.json:
        return archiveCodec.encode(
          ProjectArchive(
            project: project,
            chapters: chapters,
            scenes: scenes,
            catalogItems: catalogItems,
            relationships: relationships,
          ),
        );
      case ExportFormat.html:
        return _toHtml(
          project: project,
          chapters: chapters,
          scenes: scenes,
          catalogItems: catalogItems,
          relationships: relationships,
          profile: profile,
        );
    }
  }

  String _toMarkdown({
    required Project project,
    required List<Chapter> chapters,
    required List<Scene> scenes,
    required List<CatalogItem> catalogItems,
    required List<Relationship> relationships,
    required ExportProfile profile,
  }) {
    final buffer = StringBuffer()
      ..writeln('# ${project.title}')
      ..writeln();
    if (profile.includeMetadata) {
      _writeMarkdownMetadata(
          buffer, project, scenes, catalogItems, relationships);
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
    ExportProfile profile,
  ) {
    final buffer = StringBuffer()
      ..writeln('# ${project.title} - Outline')
      ..writeln();
    if (profile.includeMetadata) {
      _writeMarkdownMetadata(
          buffer, project, scenes, catalogItems, relationships);
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
    return buffer.toString();
  }

  String _toHtml({
    required Project project,
    required List<Chapter> chapters,
    required List<Scene> scenes,
    required List<CatalogItem> catalogItems,
    required List<Relationship> relationships,
    required ExportProfile profile,
  }) {
    final escape = const HtmlEscape().convert;
    final buffer = StringBuffer()
      ..write('<!doctype html><html><head><meta charset="utf-8">')
      ..write('<title>${escape(project.title)}</title>')
      ..write(
          '<style>body{font-family:serif;max-width:760px;margin:48px auto;line-height:1.65;padding:0 24px;}')
      ..write(
          'h1,h2,h3{line-height:1.2;} .meta{font-family:sans-serif;color:#555;border-bottom:1px solid #ddd;padding-bottom:16px;margin-bottom:28px;}')
      ..write('</style></head><body>')
      ..write('<h1>${escape(project.title)}</h1>');

    if (profile.includeMetadata) {
      buffer.write(
        '<div class="meta">${scenes.length} scenes · '
        '${scenes.fold<int>(0, (sum, scene) => sum + scene.actualWordCount)} words · '
        '${catalogItems.length} catalog items · ${relationships.length} links</div>',
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

    return '${buffer.toString()}</body></html>';
  }

  void _writeMarkdownMetadata(
    StringBuffer buffer,
    Project project,
    List<Scene> scenes,
    List<CatalogItem> catalogItems,
    List<Relationship> relationships,
  ) {
    buffer
      ..writeln('Project type: ${project.projectType}')
      ..writeln('Scenes: ${scenes.length}')
      ..writeln(
          'Words: ${scenes.fold<int>(0, (sum, scene) => sum + scene.actualWordCount)}')
      ..writeln('Catalog items: ${catalogItems.length}')
      ..writeln('Relationships: ${relationships.length}')
      ..writeln();
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
}

final class _ChapterSceneGroup {
  const _ChapterSceneGroup({
    required this.chapter,
    required this.scenes,
  });

  final Chapter? chapter;
  final List<Scene> scenes;
}
