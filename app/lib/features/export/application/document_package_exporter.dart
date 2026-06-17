import 'dart:convert';
import 'dart:typed_data';

import '../../catalog/domain/catalog_item.dart';
import '../../catalog/domain/relationship.dart';
import '../../notes/domain/project_note.dart';
import '../../projects/domain/project.dart';
import '../../structure/domain/chapter.dart';
import '../../structure/domain/scene.dart';
import 'stored_zip_archive.dart';

final class DocumentPackageExporter {
  const DocumentPackageExporter();

  Uint8List toPdf({
    required Project project,
    required List<Chapter> chapters,
    required List<Scene> scenes,
    required bool includeSceneTitles,
  }) {
    final lines = _manuscriptLines(
      project: project,
      chapters: chapters,
      scenes: scenes,
      includeSceneTitles: includeSceneTitles,
      maxLineLength: 86,
    );
    final pages = <List<String>>[];
    for (var index = 0; index < lines.length; index += 46) {
      pages.add(lines.skip(index).take(46).toList());
    }
    if (pages.isEmpty) pages.add([project.title]);

    final objects = <String>[];
    final pageObjectIds = <int>[];
    final contentObjectIds = <int>[];
    objects.add(''); // 1 catalog
    objects.add(''); // 2 pages
    objects.add('<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>');

    for (final page in pages) {
      final contentId = objects.length + 2;
      final pageId = objects.length + 1;
      pageObjectIds.add(pageId);
      contentObjectIds.add(contentId);
      objects.add(
        '<< /Type /Page /Parent 2 0 R /MediaBox [0 0 595 842] '
        '/Resources << /Font << /F1 3 0 R >> >> /Contents $contentId 0 R >>',
      );
      objects.add(_pdfStream(_pageContent(page)));
    }

    objects[0] = '<< /Type /Catalog /Pages 2 0 R >>';
    objects[1] =
        '<< /Type /Pages /Kids [${pageObjectIds.map((id) => '$id 0 R').join(' ')}] /Count ${pageObjectIds.length} >>';

    final buffer = StringBuffer('%PDF-1.4\n');
    final offsets = <int>[0];
    for (var i = 0; i < objects.length; i++) {
      offsets.add(utf8.encode(buffer.toString()).length);
      buffer
        ..write('${i + 1} 0 obj\n')
        ..write(objects[i])
        ..write('\nendobj\n');
    }
    final xrefOffset = utf8.encode(buffer.toString()).length;
    buffer
      ..write('xref\n0 ${objects.length + 1}\n')
      ..write('0000000000 65535 f \n');
    for (final offset in offsets.skip(1)) {
      buffer.write('${offset.toString().padLeft(10, '0')} 00000 n \n');
    }
    buffer
      ..write('trailer << /Size ${objects.length + 1} /Root 1 0 R >>\n')
      ..write('startxref\n$xrefOffset\n%%EOF');
    return Uint8List.fromList(utf8.encode(buffer.toString()));
  }

  Uint8List toEpub({
    required Project project,
    required List<Chapter> chapters,
    required List<Scene> scenes,
    required bool includeSceneTitles,
  }) {
    final zip = StoredZipArchive();
    zip.addText('mimetype', 'application/epub+zip');
    zip.addText(
        'META-INF/container.xml',
        '''
<?xml version="1.0" encoding="UTF-8"?>
<container version="1.0" xmlns="urn:oasis:names:tc:opendocument:xmlns:container">
  <rootfiles>
    <rootfile full-path="OEBPS/content.opf" media-type="application/oebps-package+xml"/>
  </rootfiles>
</container>
'''
            .trim());
    zip.addText('OEBPS/content.opf', _epubPackage(project));
    zip.addText('OEBPS/nav.xhtml', _epubNav(project));
    zip.addText(
      'OEBPS/manuscript.xhtml',
      _epubManuscript(
        project: project,
        chapters: chapters,
        scenes: scenes,
        includeSceneTitles: includeSceneTitles,
      ),
    );
    return zip.encode();
  }

  Uint8List toDocx({
    required Project project,
    required List<Chapter> chapters,
    required List<Scene> scenes,
    required List<CatalogItem> catalogItems,
    required List<Relationship> relationships,
    required List<ProjectNote> notes,
    required bool includeMetadata,
    required bool includeSceneTitles,
  }) {
    final zip = StoredZipArchive();
    zip.addText(
        '[Content_Types].xml',
        '''
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
  <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
  <Default Extension="xml" ContentType="application/xml"/>
  <Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/>
  <Override PartName="/word/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.styles+xml"/>
</Types>
'''
            .trim());
    zip.addText(
        '_rels/.rels',
        '''
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="word/document.xml"/>
</Relationships>
'''
            .trim());
    zip.addText('word/styles.xml', _docxStyles());
    zip.addText(
      'word/document.xml',
      _docxDocument(
        project: project,
        chapters: chapters,
        scenes: scenes,
        catalogItems: catalogItems,
        relationships: relationships,
        notes: notes,
        includeMetadata: includeMetadata,
        includeSceneTitles: includeSceneTitles,
      ),
    );
    return zip.encode();
  }

  List<String> _manuscriptLines({
    required Project project,
    required List<Chapter> chapters,
    required List<Scene> scenes,
    required bool includeSceneTitles,
    required int maxLineLength,
  }) {
    final lines = <String>[project.title, ''];
    for (final group in _chapterGroups(chapters, scenes)) {
      if (includeSceneTitles && group.chapter != null) {
        lines
          ..add(group.chapter!.title)
          ..add('');
      }
      for (final scene in group.scenes) {
        if (includeSceneTitles) {
          lines
            ..add(scene.title)
            ..add('');
        }
        for (final paragraph in _paragraphs(scene.manuscriptText)) {
          lines.addAll(_wrap(paragraph, maxLineLength));
          lines.add('');
        }
      }
    }
    return lines;
  }

  String _pdfStream(String content) {
    final length = utf8.encode(content).length;
    return '<< /Length $length >>\nstream\n$content\nendstream';
  }

  String _pageContent(List<String> lines) {
    final buffer = StringBuffer('BT\n/F1 11 Tf\n14 TL\n72 770 Td\n');
    for (final line in lines) {
      buffer
        ..write('(${_pdfText(line)}) Tj\n')
        ..write('T*\n');
    }
    buffer.write('ET');
    return buffer.toString();
  }

  String _pdfText(String value) {
    final buffer = StringBuffer();
    for (final codeUnit in value.codeUnits) {
      if (codeUnit == 0x28 || codeUnit == 0x29 || codeUnit == 0x5c) {
        buffer.write('\\${String.fromCharCode(codeUnit)}');
      } else if (codeUnit < 32 || codeUnit > 126) {
        buffer.write(codeUnit <= 255
            ? '\\${codeUnit.toRadixString(8).padLeft(3, '0')}'
            : '?');
      } else {
        buffer.writeCharCode(codeUnit);
      }
    }
    return buffer.toString();
  }

  String _epubPackage(Project project) => '''
<?xml version="1.0" encoding="UTF-8"?>
<package xmlns="http://www.idpf.org/2007/opf" version="3.0" unique-identifier="bookid">
  <metadata xmlns:dc="http://purl.org/dc/elements/1.1/">
    <dc:identifier id="bookid">${_xml(project.id)}</dc:identifier>
    <dc:title>${_xml(project.title)}</dc:title>
    <dc:language>${_xml(project.languageCode)}</dc:language>
  </metadata>
  <manifest>
    <item id="nav" href="nav.xhtml" media-type="application/xhtml+xml" properties="nav"/>
    <item id="manuscript" href="manuscript.xhtml" media-type="application/xhtml+xml"/>
  </manifest>
  <spine>
    <itemref idref="manuscript"/>
  </spine>
</package>
'''
      .trim();

  String _epubNav(Project project) => '''
<?xml version="1.0" encoding="UTF-8"?>
<html xmlns="http://www.w3.org/1999/xhtml">
  <head><title>${_xml(project.title)}</title></head>
  <body>
    <nav epub:type="toc" xmlns:epub="http://www.idpf.org/2007/ops">
      <h1>${_xml(project.title)}</h1>
      <ol><li><a href="manuscript.xhtml">Manuscript</a></li></ol>
    </nav>
  </body>
</html>
'''
      .trim();

  String _epubManuscript({
    required Project project,
    required List<Chapter> chapters,
    required List<Scene> scenes,
    required bool includeSceneTitles,
  }) {
    final body = StringBuffer('<h1>${_xml(project.title)}</h1>');
    for (final group in _chapterGroups(chapters, scenes)) {
      if (includeSceneTitles && group.chapter != null) {
        body.write('<h2>${_xml(group.chapter!.title)}</h2>');
      }
      for (final scene in group.scenes) {
        if (includeSceneTitles) {
          body.write('<h3>${_xml(scene.title)}</h3>');
        }
        for (final paragraph in _paragraphs(scene.manuscriptText)) {
          body.write('<p>${_xml(paragraph)}</p>');
        }
      }
    }
    return '''
<?xml version="1.0" encoding="UTF-8"?>
<html xmlns="http://www.w3.org/1999/xhtml">
  <head><title>${_xml(project.title)}</title></head>
  <body>$body</body>
</html>
'''
        .trim();
  }

  String _docxDocument({
    required Project project,
    required List<Chapter> chapters,
    required List<Scene> scenes,
    required List<CatalogItem> catalogItems,
    required List<Relationship> relationships,
    required List<ProjectNote> notes,
    required bool includeMetadata,
    required bool includeSceneTitles,
  }) {
    final body = StringBuffer()
      ..write(_docxParagraph(project.title, style: 'Title'));
    if (includeMetadata) {
      body
        ..write(_docxParagraph('${scenes.length} scenes'))
        ..write(_docxParagraph(
            '${scenes.fold<int>(0, (sum, scene) => sum + scene.actualWordCount)} words'))
        ..write(_docxParagraph('${catalogItems.length} catalog items'))
        ..write(_docxParagraph('${relationships.length} links'))
        ..write(_docxParagraph('${notes.length} notes'));
    }
    for (final group in _chapterGroups(chapters, scenes)) {
      if (includeSceneTitles && group.chapter != null) {
        body.write(_docxParagraph(group.chapter!.title, style: 'Heading1'));
      }
      for (final scene in group.scenes) {
        if (includeSceneTitles) {
          body.write(_docxParagraph(scene.title,
              style: group.chapter == null ? 'Heading1' : 'Heading2'));
        }
        for (final paragraph in _paragraphs(scene.manuscriptText)) {
          body.write(_docxParagraph(paragraph));
        }
      }
    }
    if (includeMetadata && notes.isNotEmpty) {
      body.write(_docxParagraph('Notes', style: 'Heading1'));
      for (final note in notes) {
        body
          ..write(_docxParagraph(note.title, style: 'Heading2'))
          ..write(_docxParagraph(
            'Target: ${_noteTargetLabel(note, scenes, catalogItems)}',
          ));
        for (final paragraph in _paragraphs(note.body)) {
          body.write(_docxParagraph(paragraph));
        }
      }
    }
    return '''
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
  <w:body>
    $body
    <w:sectPr><w:pgSz w:w="11906" w:h="16838"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440"/></w:sectPr>
  </w:body>
</w:document>
'''
        .trim();
  }

  String _docxParagraph(String text, {String? style}) {
    final styleXml =
        style == null ? '' : '<w:pPr><w:pStyle w:val="$style"/></w:pPr>';
    return '<w:p>$styleXml<w:r><w:t xml:space="preserve">${_xml(text)}</w:t></w:r></w:p>';
  }

  String _docxStyles() => '''
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:styles xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
  <w:style w:type="paragraph" w:styleId="Title"><w:name w:val="Title"/><w:rPr><w:b/><w:sz w:val="36"/></w:rPr></w:style>
  <w:style w:type="paragraph" w:styleId="Heading1"><w:name w:val="heading 1"/><w:rPr><w:b/><w:sz w:val="28"/></w:rPr></w:style>
  <w:style w:type="paragraph" w:styleId="Heading2"><w:name w:val="heading 2"/><w:rPr><w:b/><w:sz w:val="24"/></w:rPr></w:style>
</w:styles>
'''
      .trim();

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

  List<String> _wrap(String text, int maxLineLength) {
    final words = text.split(RegExp(r'\s+')).where((word) => word.isNotEmpty);
    final lines = <String>[];
    var current = '';
    for (final word in words) {
      if (current.isEmpty) {
        current = word;
      } else if ('$current $word'.length <= maxLineLength) {
        current = '$current $word';
      } else {
        lines.add(current);
        current = word;
      }
    }
    if (current.isNotEmpty) lines.add(current);
    return lines;
  }

  String _xml(String value) {
    return const HtmlEscape(HtmlEscapeMode.element).convert(value);
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
