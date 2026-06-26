import 'dart:convert';
import 'dart:typed_data';

import '../../catalog/domain/catalog_item.dart';
import '../../catalog/domain/relationship.dart';
import '../../notes/domain/project_note.dart';
import '../../projects/domain/project.dart';
import '../../structure/domain/chapter.dart';
import '../../structure/domain/scene.dart';
import '../domain/export_profile.dart';
import 'stored_zip_archive.dart';

final class DocumentPackageExporter {
  const DocumentPackageExporter();

  Uint8List toPdf({
    required Project project,
    required List<Chapter> chapters,
    required List<Scene> scenes,
    required List<CatalogItem> catalogItems,
    required List<Relationship> relationships,
    required List<ProjectNote> notes,
    required bool includeMetadata,
    required bool includeSceneTitles,
    required PublishingStyle style,
  }) {
    final spec = _PublishingStyleSpec.forStyle(style);
    final pages = _pdfPages(
      project: project,
      chapters: chapters,
      scenes: scenes,
      catalogItems: catalogItems,
      relationships: relationships,
      notes: notes,
      includeMetadata: includeMetadata,
      includeSceneTitles: includeSceneTitles,
      spec: spec,
    );

    final objects = <String>[];
    final pageObjectIds = <int>[];
    objects.add(''); // 1 catalog
    objects.add(''); // 2 pages
    objects.add('<< /Type /Font /Subtype /Type1 /BaseFont /Times-Roman >>');
    objects.add('<< /Type /Font /Subtype /Type1 /BaseFont /Times-Bold >>');
    objects.add('<< /Type /Font /Subtype /Type1 /BaseFont /Times-Italic >>');
    objects.add('<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>');

    for (var index = 0; index < pages.length; index++) {
      final page = pages[index];
      final contentId = objects.length + 2;
      final pageId = objects.length + 1;
      pageObjectIds.add(pageId);
      objects.add(
        '<< /Type /Page /Parent 2 0 R /MediaBox [0 0 595 842] '
        '/Resources << /Font << /F1 3 0 R /F2 4 0 R /F3 5 0 R /F4 6 0 R >> >> '
        '/Contents $contentId 0 R >>',
      );
      objects.add(_pdfStream(_pageContent(
        projectTitle: project.title,
        pageNumber: index + 1,
        pageCount: pages.length,
        lines: page,
      )));
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
    required PublishingStyle style,
  }) {
    final spec = _PublishingStyleSpec.forStyle(style);
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
    zip.addText('OEBPS/styles.css', _epubStyles(spec));
    zip.addText(
      'OEBPS/manuscript.xhtml',
      _epubManuscript(
        project: project,
        chapters: chapters,
        scenes: scenes,
        includeSceneTitles: includeSceneTitles,
        spec: spec,
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
    required PublishingStyle style,
  }) {
    final spec = _PublishingStyleSpec.forStyle(style);
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
  <Override PartName="/docProps/core.xml" ContentType="application/vnd.openxmlformats-package.core-properties+xml"/>
  <Override PartName="/docProps/app.xml" ContentType="application/vnd.openxmlformats-officedocument.extended-properties+xml"/>
</Types>
'''
            .trim());
    zip.addText(
        '_rels/.rels',
        '''
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="word/document.xml"/>
  <Relationship Id="rId2" Type="http://schemas.openxmlformats.org/package/2006/relationships/metadata/core-properties" Target="docProps/core.xml"/>
  <Relationship Id="rId3" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/extended-properties" Target="docProps/app.xml"/>
</Relationships>
'''
            .trim());
    zip.addText('docProps/core.xml', _docxCoreProperties(project));
    zip.addText('docProps/app.xml', _docxAppProperties());
    zip.addText('word/styles.xml', _docxStyles(spec));
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
        spec: spec,
      ),
    );
    return zip.encode();
  }

  List<List<_PdfLine>> _pdfPages({
    required Project project,
    required List<Chapter> chapters,
    required List<Scene> scenes,
    required List<CatalogItem> catalogItems,
    required List<Relationship> relationships,
    required List<ProjectNote> notes,
    required bool includeMetadata,
    required bool includeSceneTitles,
    required _PublishingStyleSpec spec,
  }) {
    const pageWidth = 595.0;
    final left = spec.pdfHorizontalMargin;
    const top = 740.0;
    const bottom = 76.0;
    final contentWidth = pageWidth - left - spec.pdfHorizontalMargin;
    final pages = <List<_PdfLine>>[[]];
    var y = top;

    void addPage() {
      pages.add([]);
      y = top;
    }

    void ensure(double height) {
      if (y - height < bottom && pages.last.isNotEmpty) {
        addPage();
      }
    }

    void addLine(
      String text, {
      String font = 'F1',
      double fontSize = 11,
      double lineHeight = 16,
      double before = 0,
      double after = 0,
      double indent = 0,
      double gray = 0,
    }) {
      ensure(before + lineHeight + after);
      y -= before;
      pages.last.add(_PdfLine(
        text: text,
        x: left + indent,
        y: y,
        font: font,
        fontSize: fontSize,
        gray: gray,
      ));
      y -= lineHeight + after;
    }

    void addWrappedParagraph(
      String text, {
      String font = 'F1',
      double fontSize = 11.5,
      double lineHeight = 17,
      double before = 0,
      double after = 8,
      double indent = 0,
      double firstLineIndent = 18,
      double gray = 0,
    }) {
      final maxLineLength =
          ((contentWidth - indent - firstLineIndent) / (fontSize * 0.47))
              .floor()
              .clamp(28, 92);
      final lines = _wrap(text, maxLineLength.toInt());
      for (var index = 0; index < lines.length; index++) {
        addLine(
          lines[index],
          font: font,
          fontSize: fontSize,
          lineHeight: lineHeight,
          before: index == 0 ? before : 0,
          after: index == lines.length - 1 ? after : 0,
          indent: indent + (index == 0 ? firstLineIndent : 0),
          gray: gray,
        );
      }
    }

    addLine(
      project.title,
      font: 'F2',
      fontSize: spec.pdfTitleSize,
      lineHeight: spec.pdfTitleSize + 6,
      before: 16,
      after: 8,
    );
    addLine(
      'Manuscript export',
      font: 'F3',
      fontSize: 12,
      lineHeight: 18,
      after: includeMetadata ? 18 : 32,
      gray: 0.35,
    );
    addLine(
      spec.label,
      font: 'F4',
      fontSize: 9.5,
      lineHeight: 14,
      after: includeMetadata ? 10 : 24,
      gray: 0.40,
    );

    if (includeMetadata) {
      final words =
          scenes.fold<int>(0, (sum, scene) => sum + scene.actualWordCount);
      for (final line in [
        '${chapters.length} chapters  |  ${scenes.length} scenes  |  $words words',
        '${catalogItems.length} catalog items  |  ${relationships.length} links  |  ${notes.length} notes',
      ]) {
        addLine(
          line,
          font: 'F4',
          fontSize: 10,
          lineHeight: 15,
          gray: 0.30,
        );
      }
      y -= 20;
    }

    for (final group in _chapterGroups(chapters, scenes)) {
      if (includeSceneTitles && group.chapter != null) {
        if (pages.last.isNotEmpty && y < 650) addPage();
        addLine(
          group.chapter!.title,
          font: 'F2',
          fontSize: 18,
          lineHeight: 24,
          before: 14,
          after: 10,
        );
      }
      for (final scene in group.scenes) {
        if (includeSceneTitles) {
          addLine(
            scene.title,
            font: group.chapter == null ? 'F2' : 'F3',
            fontSize: group.chapter == null ? 17 : 13,
            lineHeight: group.chapter == null ? 23 : 19,
            before: 8,
            after: 6,
            gray: group.chapter == null ? 0 : 0.20,
          );
        }
        for (final paragraph in _paragraphs(scene.manuscriptText)) {
          addWrappedParagraph(
            paragraph,
            fontSize: spec.pdfBodySize,
            lineHeight: spec.pdfLineHeight,
            firstLineIndent: spec.pdfFirstLineIndent,
          );
        }
      }
    }
    if (includeMetadata && notes.isNotEmpty) {
      addPage();
      addLine(
        'Notes',
        font: 'F2',
        fontSize: 18,
        lineHeight: 24,
        before: 14,
        after: 10,
      );
      for (final note in notes) {
        addLine(
          note.title,
          font: 'F2',
          fontSize: 12,
          lineHeight: 18,
          before: 6,
          after: 2,
        );
        addWrappedParagraph(
          'Target: ${_noteTargetLabel(note, scenes, catalogItems)}',
          font: 'F4',
          fontSize: 9.5,
          lineHeight: 14,
          after: 4,
          firstLineIndent: 0,
          gray: 0.35,
        );
        for (final paragraph in _paragraphs(note.body)) {
          addWrappedParagraph(
            paragraph,
            fontSize: 10.5,
            lineHeight: 15,
            firstLineIndent: 0,
          );
        }
      }
    }
    return pages.where((page) => page.isNotEmpty).toList(growable: false);
  }

  String _pdfStream(String content) {
    final length = utf8.encode(content).length;
    return '<< /Length $length >>\nstream\n$content\nendstream';
  }

  String _pageContent({
    required String projectTitle,
    required int pageNumber,
    required int pageCount,
    required List<_PdfLine> lines,
  }) {
    final buffer = StringBuffer()
      ..write('BT\n')
      ..write('/F4 8 Tf\n0.45 g\n1 0 0 1 72 798 Tm\n')
      ..write('(${_pdfText(projectTitle)}) Tj\n')
      ..write('1 0 0 1 72 46 Tm\n')
      ..write('(${_pdfText('Page $pageNumber of $pageCount')}) Tj\n')
      ..write('0 g\n');
    for (final line in lines) {
      buffer
        ..write('/${line.font} ${line.fontSize.toStringAsFixed(1)} Tf\n')
        ..write('${line.gray.toStringAsFixed(2)} g\n')
        ..write(
          '1 0 0 1 ${line.x.toStringAsFixed(1)} ${line.y.toStringAsFixed(1)} Tm\n',
        )
        ..write('(${_pdfText(line.text)}) Tj\n');
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
    <item id="styles" href="styles.css" media-type="text/css"/>
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
    required _PublishingStyleSpec spec,
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
  <head><title>${_xml(project.title)}</title><link rel="stylesheet" type="text/css" href="styles.css"/></head>
  <body>$body</body>
</html>
'''
        .trim();
  }

  String _epubStyles(_PublishingStyleSpec spec) => '''
body {
  font-family: ${spec.epubFontFamily};
  line-height: ${spec.epubLineHeight};
  margin: ${spec.epubMargin};
}
h1, h2, h3 {
  font-family: ${spec.epubHeadingFamily};
  line-height: 1.25;
}
p {
  margin: 0 0 ${spec.epubParagraphSpacing} 0;
  text-indent: ${spec.epubFirstLineIndent};
}
'''
      .trim();

  String _docxDocument({
    required Project project,
    required List<Chapter> chapters,
    required List<Scene> scenes,
    required List<CatalogItem> catalogItems,
    required List<Relationship> relationships,
    required List<ProjectNote> notes,
    required bool includeMetadata,
    required bool includeSceneTitles,
    required _PublishingStyleSpec spec,
  }) {
    final words =
        scenes.fold<int>(0, (sum, scene) => sum + scene.actualWordCount);
    final body = StringBuffer()
      ..write(_docxParagraph(project.title, style: 'Title'))
      ..write(_docxParagraph('Manuscript export', style: 'Subtitle'));
    body.write(_docxParagraph(spec.label, style: 'BookInfo'));
    if (includeMetadata) {
      body
        ..write(_docxParagraph(
          '${chapters.length} chapters  |  ${scenes.length} scenes  |  $words words',
          style: 'BookInfo',
        ))
        ..write(_docxParagraph(
          '${catalogItems.length} catalog items  |  ${relationships.length} links  |  ${notes.length} notes',
          style: 'BookInfo',
        ));
    }
    if (scenes.isNotEmpty) {
      body.write(_docxPageBreak());
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
          body.write(_docxParagraph(paragraph, style: 'Manuscript'));
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
            style: 'BookInfo',
          ));
        for (final paragraph in _paragraphs(note.body)) {
          body.write(_docxParagraph(paragraph, style: 'Manuscript'));
        }
      }
    }
    return '''
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
  <w:body>
    $body
    <w:sectPr>
      <w:pgSz w:w="11906" w:h="16838"/>
      <w:pgMar w:top="${spec.docxMarginTwips}" w:right="${spec.docxMarginTwips}" w:bottom="${spec.docxMarginTwips}" w:left="${spec.docxMarginTwips}"/>
      <w:cols w:space="720"/>
      <w:docGrid w:linePitch="360"/>
    </w:sectPr>
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

  String _docxPageBreak() => '<w:p><w:r><w:br w:type="page"/></w:r></w:p>';

  String _docxStyles(_PublishingStyleSpec spec) => '''
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:styles xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
  <w:docDefaults>
    <w:rPrDefault><w:rPr><w:rFonts w:ascii="${spec.docxBodyFont}" w:hAnsi="${spec.docxBodyFont}"/><w:sz w:val="${spec.docxBodySizeHalfPoints}"/></w:rPr></w:rPrDefault>
    <w:pPrDefault><w:pPr><w:spacing w:after="${spec.docxParagraphAfter}" w:line="${spec.docxLineTwips}" w:lineRule="auto"/></w:pPr></w:pPrDefault>
  </w:docDefaults>
  <w:style w:type="paragraph" w:default="1" w:styleId="Normal">
    <w:name w:val="Normal"/>
    <w:pPr><w:spacing w:after="${spec.docxParagraphAfter}" w:line="${spec.docxLineTwips}" w:lineRule="auto"/></w:pPr>
    <w:rPr><w:rFonts w:ascii="${spec.docxBodyFont}" w:hAnsi="${spec.docxBodyFont}"/><w:sz w:val="${spec.docxBodySizeHalfPoints}"/></w:rPr>
  </w:style>
  <w:style w:type="paragraph" w:styleId="Title">
    <w:name w:val="Title"/>
    <w:pPr><w:jc w:val="center"/><w:spacing w:before="288" w:after="120"/></w:pPr>
    <w:rPr><w:rFonts w:ascii="Georgia" w:hAnsi="Georgia"/><w:b/><w:color w:val="1F2A32"/><w:sz w:val="52"/></w:rPr>
  </w:style>
  <w:style w:type="paragraph" w:styleId="Subtitle">
    <w:name w:val="Subtitle"/>
    <w:pPr><w:jc w:val="center"/><w:spacing w:after="420"/></w:pPr>
    <w:rPr><w:rFonts w:ascii="Arial" w:hAnsi="Arial"/><w:i/><w:color w:val="69747C"/><w:sz w:val="22"/></w:rPr>
  </w:style>
  <w:style w:type="paragraph" w:styleId="BookInfo">
    <w:name w:val="Book Info"/>
    <w:pPr><w:jc w:val="center"/><w:spacing w:before="0" w:after="80"/></w:pPr>
    <w:rPr><w:rFonts w:ascii="Arial" w:hAnsi="Arial"/><w:color w:val="56616A"/><w:sz w:val="18"/></w:rPr>
  </w:style>
  <w:style w:type="paragraph" w:styleId="Heading1">
    <w:name w:val="Heading 1"/>
    <w:pPr><w:keepNext/><w:spacing w:before="240" w:after="180"/></w:pPr>
    <w:rPr><w:rFonts w:ascii="Georgia" w:hAnsi="Georgia"/><w:b/><w:color w:val="1F2A32"/><w:sz w:val="34"/></w:rPr>
  </w:style>
  <w:style w:type="paragraph" w:styleId="Heading2">
    <w:name w:val="Heading 2"/>
    <w:pPr><w:keepNext/><w:spacing w:before="240" w:after="120"/></w:pPr>
    <w:rPr><w:rFonts w:ascii="Arial" w:hAnsi="Arial"/><w:b/><w:color w:val="2F5963"/><w:sz w:val="24"/></w:rPr>
  </w:style>
  <w:style w:type="paragraph" w:styleId="Manuscript">
    <w:name w:val="Manuscript"/>
    <w:pPr><w:ind w:firstLine="${spec.docxFirstLineIndent}"/><w:spacing w:before="0" w:after="${spec.docxParagraphAfter}" w:line="${spec.docxLineTwips}" w:lineRule="auto"/></w:pPr>
    <w:rPr><w:rFonts w:ascii="${spec.docxBodyFont}" w:hAnsi="${spec.docxBodyFont}"/><w:sz w:val="${spec.docxBodySizeHalfPoints}"/></w:rPr>
  </w:style>
</w:styles>
'''
      .trim();

  String _docxCoreProperties(Project project) {
    final now = DateTime.now().toUtc().toIso8601String();
    return '''
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<cp:coreProperties xmlns:cp="http://schemas.openxmlformats.org/package/2006/metadata/core-properties" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <dc:title>${_xml(project.title)}</dc:title>
  <dc:creator>Writeler</dc:creator>
  <cp:lastModifiedBy>Writeler</cp:lastModifiedBy>
  <dcterms:created xsi:type="dcterms:W3CDTF">$now</dcterms:created>
  <dcterms:modified xsi:type="dcterms:W3CDTF">$now</dcterms:modified>
</cp:coreProperties>
'''
        .trim();
  }

  String _docxAppProperties() => '''
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Properties xmlns="http://schemas.openxmlformats.org/officeDocument/2006/extended-properties" xmlns:vt="http://schemas.openxmlformats.org/officeDocument/2006/docPropsVTypes">
  <Application>Writeler</Application>
  <DocSecurity>0</DocSecurity>
  <ScaleCrop>false</ScaleCrop>
  <LinksUpToDate>false</LinksUpToDate>
  <SharedDoc>false</SharedDoc>
  <HyperlinksChanged>false</HyperlinksChanged>
  <AppVersion>1.0</AppVersion>
</Properties>
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

final class _PublishingStyleSpec {
  const _PublishingStyleSpec({
    required this.label,
    required this.pdfHorizontalMargin,
    required this.pdfBodySize,
    required this.pdfLineHeight,
    required this.pdfFirstLineIndent,
    required this.pdfTitleSize,
    required this.docxBodyFont,
    required this.docxBodySizeHalfPoints,
    required this.docxLineTwips,
    required this.docxParagraphAfter,
    required this.docxFirstLineIndent,
    required this.docxMarginTwips,
    required this.epubFontFamily,
    required this.epubHeadingFamily,
    required this.epubLineHeight,
    required this.epubMargin,
    required this.epubParagraphSpacing,
    required this.epubFirstLineIndent,
  });

  final String label;
  final double pdfHorizontalMargin;
  final double pdfBodySize;
  final double pdfLineHeight;
  final double pdfFirstLineIndent;
  final double pdfTitleSize;
  final String docxBodyFont;
  final int docxBodySizeHalfPoints;
  final int docxLineTwips;
  final int docxParagraphAfter;
  final int docxFirstLineIndent;
  final int docxMarginTwips;
  final String epubFontFamily;
  final String epubHeadingFamily;
  final String epubLineHeight;
  final String epubMargin;
  final String epubParagraphSpacing;
  final String epubFirstLineIndent;

  static _PublishingStyleSpec forStyle(PublishingStyle style) {
    return switch (style) {
      PublishingStyle.manuscript => const _PublishingStyleSpec(
          label: 'Manuscript / editorial review',
          pdfHorizontalMargin: 72,
          pdfBodySize: 11.5,
          pdfLineHeight: 17,
          pdfFirstLineIndent: 18,
          pdfTitleSize: 28,
          docxBodyFont: 'Times New Roman',
          docxBodySizeHalfPoints: 24,
          docxLineTwips: 360,
          docxParagraphAfter: 160,
          docxFirstLineIndent: 360,
          docxMarginTwips: 1440,
          epubFontFamily: 'serif',
          epubHeadingFamily: 'serif',
          epubLineHeight: '1.65',
          epubMargin: '8%',
          epubParagraphSpacing: '0.8em',
          epubFirstLineIndent: '1.2em',
        ),
      PublishingStyle.paperback => const _PublishingStyleSpec(
          label: 'Paperback print layout',
          pdfHorizontalMargin: 54,
          pdfBodySize: 10.8,
          pdfLineHeight: 15.2,
          pdfFirstLineIndent: 14,
          pdfTitleSize: 25,
          docxBodyFont: 'Garamond',
          docxBodySizeHalfPoints: 22,
          docxLineTwips: 312,
          docxParagraphAfter: 80,
          docxFirstLineIndent: 300,
          docxMarginTwips: 1080,
          epubFontFamily: 'serif',
          epubHeadingFamily: 'serif',
          epubLineHeight: '1.5',
          epubMargin: '6%',
          epubParagraphSpacing: '0.35em',
          epubFirstLineIndent: '1.1em',
        ),
      PublishingStyle.ebook => const _PublishingStyleSpec(
          label: 'E-book reader layout',
          pdfHorizontalMargin: 64,
          pdfBodySize: 11.2,
          pdfLineHeight: 16.5,
          pdfFirstLineIndent: 16,
          pdfTitleSize: 26,
          docxBodyFont: 'Georgia',
          docxBodySizeHalfPoints: 24,
          docxLineTwips: 340,
          docxParagraphAfter: 120,
          docxFirstLineIndent: 320,
          docxMarginTwips: 1260,
          epubFontFamily: 'serif',
          epubHeadingFamily: 'sans-serif',
          epubLineHeight: '1.55',
          epubMargin: '5%',
          epubParagraphSpacing: '0.55em',
          epubFirstLineIndent: '1em',
        ),
      PublishingStyle.largePrint => const _PublishingStyleSpec(
          label: 'Large print',
          pdfHorizontalMargin: 64,
          pdfBodySize: 14,
          pdfLineHeight: 21,
          pdfFirstLineIndent: 18,
          pdfTitleSize: 30,
          docxBodyFont: 'Georgia',
          docxBodySizeHalfPoints: 30,
          docxLineTwips: 440,
          docxParagraphAfter: 180,
          docxFirstLineIndent: 360,
          docxMarginTwips: 1260,
          epubFontFamily: 'serif',
          epubHeadingFamily: 'serif',
          epubLineHeight: '1.7',
          epubMargin: '7%',
          epubParagraphSpacing: '0.9em',
          epubFirstLineIndent: '1em',
        ),
    };
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

final class _PdfLine {
  const _PdfLine({
    required this.text,
    required this.x,
    required this.y,
    required this.font,
    required this.fontSize,
    required this.gray,
  });

  final String text;
  final double x;
  final double y;
  final String font;
  final double fontSize;
  final double gray;
}
