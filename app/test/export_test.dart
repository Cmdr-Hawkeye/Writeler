import 'dart:convert';

import 'package:test/test.dart';
import 'package:writeler/core/domain/entity_ref.dart';
import 'package:writeler/core/domain/entity_type.dart';
import 'package:writeler/features/catalog/application/create_catalog_item.dart';
import 'package:writeler/features/catalog/domain/relationship.dart';
import 'package:writeler/features/catalog/infrastructure/in_memory_catalog_item_repository.dart';
import 'package:writeler/features/export/application/project_archive_codec.dart';
import 'package:writeler/features/export/application/project_exporter.dart';
import 'package:writeler/features/export/domain/export_profile.dart';
import 'package:writeler/features/projects/application/create_project.dart';
import 'package:writeler/features/projects/infrastructure/in_memory_project_repository.dart';
import 'package:writeler/features/structure/application/create_chapter.dart';
import 'package:writeler/features/structure/application/create_scene.dart';
import 'package:writeler/features/structure/application/in_memory_chapter_repository.dart';
import 'package:writeler/features/structure/application/in_memory_scene_repository.dart';

void main() {
  test('project can be exported as markdown and structured json', () async {
    final projectRepository = InMemoryProjectRepository();
    final chapterRepository = InMemoryChapterRepository();
    final sceneRepository = InMemorySceneRepository();
    final catalogRepository = InMemoryCatalogItemRepository();
    final project = await CreateProject(projectRepository)(
      const CreateProjectCommand(title: 'Exportable Book'),
    );
    final chapter = await CreateChapter(chapterRepository)(
      CreateChapterCommand(projectId: project.id, title: 'Opening'),
    );
    final scene = (await CreateScene(sceneRepository)(
      CreateSceneCommand(projectId: project.id, chapterId: chapter.id, title: 'Scene One'),
    ))
        .withAuthorText('A short authored paragraph.');
    final character = await CreateCatalogItem(catalogRepository)(
      CreateCatalogItemCommand(
        projectId: project.id,
        type: EntityType.character,
        name: 'Mara',
        summary: 'Keeps the expedition honest.',
      ),
    );
    final now = DateTime.now().toUtc();
    final relationship = Relationship(
      id: 'relationship-1',
      projectId: project.id,
      source: EntityRef(type: EntityType.scene, id: scene.id),
      target: EntityRef(type: EntityType.character, id: character.id),
      relationshipType: 'appearsIn',
      direction: RelationshipDirection.directed,
      createdAt: now,
      updatedAt: now,
    );

    const exporter = ProjectExporter();
    final markdown = exporter.exportProject(
      project: project,
      chapters: [chapter],
      scenes: [scene],
      catalogItems: [character],
      relationships: [relationship],
      profile: ExportProfile(
        id: 'markdown',
        projectId: project.id,
        name: 'Markdown',
        format: ExportFormat.markdown,
      ),
    );

    final jsonText = exporter.exportProject(
      project: project,
      chapters: [chapter],
      scenes: [scene],
      catalogItems: [character],
      relationships: [relationship],
      profile: ExportProfile(
        id: 'json',
        projectId: project.id,
        name: 'JSON',
        format: ExportFormat.json,
      ),
    );

    expect(markdown, contains('# Exportable Book'));
    expect(markdown, contains('A short authored paragraph.'));

    final plainText = exporter.exportProject(
      project: project,
      chapters: [chapter],
      scenes: [scene],
      profile: ExportProfile(
        id: 'txt',
        projectId: project.id,
        name: 'Text',
        format: ExportFormat.plainText,
      ),
    );
    expect(plainText, contains('Scene One'));
    expect(plainText, contains('A short authored paragraph.'));

    final outline = exporter.exportProject(
      project: project,
      chapters: [chapter],
      scenes: [scene.copyWith(summary: 'Opening beat.', goal: 'Find the map.')],
      catalogItems: [character],
      relationships: [relationship],
      profile: ExportProfile(
        id: 'outline',
        projectId: project.id,
        name: 'Outline',
        format: ExportFormat.outline,
        includeMetadata: true,
      ),
    );
    expect(outline, contains('# Exportable Book - Outline'));
    expect(outline, contains('## Opening'));
    expect(outline, contains('Summary: Opening beat.'));
    expect(outline, contains('Goal: Find the map.'));

    final html = exporter.exportProject(
      project: project,
      chapters: [chapter],
      scenes: [scene],
      catalogItems: [character],
      relationships: [relationship],
      profile: ExportProfile(
        id: 'html',
        projectId: project.id,
        name: 'HTML',
        format: ExportFormat.html,
        includeMetadata: true,
      ),
    );
    expect(html, contains('<h1>Exportable Book</h1>'));
    expect(html, contains('<div class="meta">'));
    expect(html, contains('<p>A short authored paragraph.</p>'));

    final json = jsonDecode(jsonText) as Map<String, Object?>;
    expect(json['schema'], 'writeler.project.v2');

    final archive = const ProjectArchiveCodec().decode(jsonText);
    final preview = const ProjectArchiveCodec().preview(jsonText);
    expect(archive.project.title, 'Exportable Book');
    expect(archive.chapters.single.title, 'Opening');
    expect(archive.scenes.single.title, 'Scene One');
    expect(archive.catalogItems.single.name, 'Mara');
    expect(archive.relationships.single.target.id, character.id);
    expect(preview.projectTitle, 'Exportable Book');
    expect(preview.sceneCount, 1);
    expect(preview.catalogItemCount, 1);
  });
}
