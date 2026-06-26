import 'dart:convert';

import 'package:test/test.dart';
import 'package:writeler/core/domain/entity_ref.dart';
import 'package:writeler/core/domain/entity_type.dart';
import 'package:writeler/features/catalog/application/create_catalog_item.dart';
import 'package:writeler/features/catalog/domain/relationship.dart';
import 'package:writeler/features/catalog/infrastructure/in_memory_catalog_item_repository.dart';
import 'package:writeler/features/export/application/project_archive_codec.dart';
import 'package:writeler/features/export/application/project_exporter.dart';
import 'package:writeler/features/export/application/project_importer.dart';
import 'package:writeler/features/export/domain/export_profile.dart';
import 'package:writeler/features/notes/domain/project_note.dart';
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
      CreateSceneCommand(
          projectId: project.id, chapterId: chapter.id, title: 'Scene One'),
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
    final note = ProjectNote(
      id: 'note-1',
      projectId: project.id,
      target: EntityRef(type: EntityType.scene, id: scene.id),
      title: 'Scene idea',
      body: 'Keep the pressure visible.',
      source: 'aiSuggestion',
      sourceSuggestionId: 'suggestion-1',
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
      notes: [note],
      profile: ExportProfile(
        id: 'markdown',
        projectId: project.id,
        name: 'Markdown',
        format: ExportFormat.markdown,
        includeMetadata: true,
      ),
    );

    final jsonText = exporter.exportProject(
      project: project,
      chapters: [chapter],
      scenes: [scene],
      catalogItems: [character],
      relationships: [relationship],
      notes: [note],
      profile: ExportProfile(
        id: 'json',
        projectId: project.id,
        name: 'JSON',
        format: ExportFormat.json,
      ),
    );

    expect(markdown, contains('# Exportable Book'));
    expect(markdown, contains('A short authored paragraph.'));
    expect(markdown, contains('Notes: 1'));
    expect(markdown, contains('## Notes'));
    expect(markdown, contains('Keep the pressure visible.'));

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
      notes: [note],
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
    expect(outline, contains('## Notes'));
    expect(outline, contains('Scene idea'));

    final html = exporter.exportProject(
      project: project,
      chapters: [chapter],
      scenes: [scene],
      catalogItems: [character],
      relationships: [relationship],
      notes: [note],
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
    expect(html, contains('<section class="notes"><h2>Notes</h2>'));
    expect(html, contains('Keep the pressure visible.'));

    final pdf = exporter.exportArtifact(
      project: project,
      chapters: [chapter],
      scenes: [scene],
      profile: ExportProfile(
        id: 'pdf',
        projectId: project.id,
        name: 'PDF',
        format: ExportFormat.pdf,
      ),
    );
    expect(pdf.fileName, 'exportable-book.pdf');
    final pdfText = utf8.decode(pdf.bytes, allowMalformed: true);
    expect(pdfText, startsWith('%PDF'));
    expect(pdfText, contains('/BaseFont /Times-Roman'));
    expect(pdfText, contains('Manuscript export'));
    expect(pdfText, contains('Page 1 of'));

    final epub = exporter.exportArtifact(
      project: project,
      chapters: [chapter],
      scenes: [scene],
      profile: ExportProfile(
        id: 'epub',
        projectId: project.id,
        name: 'EPUB',
        format: ExportFormat.epub,
      ),
    );
    expect(epub.mimeType, 'application/epub+zip');
    expect(epub.bytes.take(2), [0x50, 0x4b]);

    final docx = exporter.exportArtifact(
      project: project,
      chapters: [chapter],
      scenes: [scene],
      catalogItems: [character],
      relationships: [relationship],
      notes: [note],
      profile: ExportProfile(
        id: 'docx',
        projectId: project.id,
        name: 'DOCX',
        format: ExportFormat.docx,
        includeMetadata: true,
      ),
    );
    expect(docx.mimeType, contains('wordprocessingml.document'));
    expect(docx.bytes.take(2), [0x50, 0x4b]);
    expect(docx.previewText, contains('Notes: 1'));
    final docxPackageText = utf8.decode(docx.bytes, allowMalformed: true);
    expect(docxPackageText, contains('docProps/core.xml'));
    expect(docxPackageText, contains('w:styleId="Manuscript"'));
    expect(docxPackageText, contains('w:styleId="BookInfo"'));
    expect(docxPackageText, contains('Manuscript export'));

    final paperbackDocx = exporter.exportArtifact(
      project: project,
      chapters: [chapter],
      scenes: [scene],
      profile: ExportProfile(
        id: 'paperback',
        projectId: project.id,
        name: 'Paperback',
        format: ExportFormat.docx,
        publishingStyle: PublishingStyle.paperback,
      ),
    );
    final paperbackPackageText =
        utf8.decode(paperbackDocx.bytes, allowMalformed: true);
    expect(paperbackDocx.previewText, contains('Style: paperback'));
    expect(paperbackPackageText, contains('Paperback print layout'));
    expect(paperbackPackageText, contains('w:rFonts w:ascii="Garamond"'));

    final json = jsonDecode(jsonText) as Map<String, Object?>;
    expect(json['schema'], 'writeler.project.v3');

    final archive = const ProjectArchiveCodec().decode(jsonText);
    final preview = const ProjectArchiveCodec().preview(jsonText);
    expect(archive.project.title, 'Exportable Book');
    expect(archive.chapters.single.title, 'Opening');
    expect(archive.scenes.single.title, 'Scene One');
    expect(archive.catalogItems.single.name, 'Mara');
    expect(archive.relationships.single.target.id, character.id);
    expect(archive.notes.single.body, 'Keep the pressure visible.');
    expect(preview.projectTitle, 'Exportable Book');
    expect(preview.sceneCount, 1);
    expect(preview.catalogItemCount, 1);
    expect(preview.noteCount, 1);
  });

  test('yWriter xml can be inspected as a Writeler project archive', () {
    const source = '''
<YWRITER7>
  <Title>Orbitale Schatten</Title>
  <Chapter>
    <Title>Ankunft</Title>
    <Description>Der Druck steigt.</Description>
    <Scene>
      <Title>Turnhalle im Ring</Title>
      <Description>Training vor dem Einsatz.</Description>
      <Goal>Die Crew testen</Goal>
      <Conflict>Die Gravitation kippt</Conflict>
      <Outcome>Mara erkennt das Sabotagemuster</Outcome>
      <Text>Kaltes Licht lag auf den Matten.</Text>
    </Scene>
  </Chapter>
  <Character>
    <Name>Mara</Name>
    <Description>Pilotin mit zu viel Mut.</Description>
    <Role>Protagonist</Role>
  </Character>
  <Location>
    <Name>Orbitalhalle</Name>
    <Description>Eine Trainingshalle auf Station C.</Description>
  </Location>
  <Item>
    <Name>Grav-Stiefel</Name>
    <Description>Haften an fast allem.</Description>
  </Item>
</YWRITER7>
''';

    final inspection = const ProjectImporter().inspect(
      source,
      sourceName: 'orbitale-schatten.yw7',
    );

    expect(inspection.kind, ProjectImportKind.yWriter);
    expect(inspection.preview.sourceFormat, 'yWriter');
    expect(inspection.preview.sourceName, 'orbitale-schatten.yw7');
    expect(inspection.archive.project.title, 'Orbitale Schatten');
    expect(inspection.archive.chapters.single.title, 'Ankunft');
    expect(inspection.archive.scenes.single.title, 'Turnhalle im Ring');
    expect(inspection.archive.scenes.single.goal, 'Die Crew testen');
    expect(inspection.archive.scenes.single.manuscriptText,
        'Kaltes Licht lag auf den Matten.');
    expect(inspection.archive.catalogItems, hasLength(3));
    expect(inspection.preview.catalogItemCount, 3);
  });

  test('plain text and markdown import creates scenes from headings', () {
    const source = '''
# Auftakt
Ein erster Absatz.

## Bruchpunkt
Ein zweiter Absatz.
''';

    final inspection = const ProjectImporter().inspect(
      source,
      sourceName: 'rohfassung.md',
    );

    expect(inspection.kind, ProjectImportKind.plainText);
    expect(inspection.preview.sourceFormat, 'Text / Markdown');
    expect(inspection.archive.project.title, 'rohfassung');
    expect(inspection.archive.chapters.single.title, 'Import');
    expect(inspection.archive.scenes, hasLength(2));
    expect(inspection.archive.scenes.first.title, 'Auftakt');
    expect(inspection.archive.scenes.last.title, 'Bruchpunkt');
  });
}
