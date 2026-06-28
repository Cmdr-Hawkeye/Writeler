import '../../../core/domain/json_map.dart';

enum ExportFormat {
  markdown,
  html,
  plainText,
  outline,
  json,
  yWriter,
  scrivener,
  pdf,
  epub,
  docx,
}

enum PublishingStyle { manuscript, paperback, ebook, largePrint }

final class PublishingLayoutProfile {
  const PublishingLayoutProfile({
    required this.style,
    required this.label,
    required this.description,
    required this.pageFormat,
    required this.trimSize,
    required this.fontFamily,
    required this.bodySizePt,
    required this.lineHeightPt,
    required this.marginDescription,
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

  final PublishingStyle style;
  final String label;
  final String description;
  final String pageFormat;
  final String trimSize;
  final String fontFamily;
  final double bodySizePt;
  final double lineHeightPt;
  final String marginDescription;
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

  int estimatedPagesForWords(int words) {
    final wordsPerPage = switch (style) {
      PublishingStyle.manuscript => 250,
      PublishingStyle.paperback => 330,
      PublishingStyle.ebook => 300,
      PublishingStyle.largePrint => 210,
    };
    if (words <= 0) return 0;
    return (words / wordsPerPage).ceil();
  }

  static PublishingLayoutProfile forStyle(PublishingStyle style) {
    return switch (style) {
      PublishingStyle.manuscript => const PublishingLayoutProfile(
          style: PublishingStyle.manuscript,
          label: 'Normseite / Lektorat',
          description:
              'Gut lesbares Manuskript mit breitem Rand, ruhigem Satz und ca. 250 Worten pro Seite.',
          pageFormat: 'A4',
          trimSize: '210 x 297 mm',
          fontFamily: 'Times New Roman',
          bodySizePt: 12,
          lineHeightPt: 18,
          marginDescription: 'ca. 25 mm Rand',
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
      PublishingStyle.paperback => const PublishingLayoutProfile(
          style: PublishingStyle.paperback,
          label: 'Taschenbuch',
          description:
              'Kompakter Buchsatz mit Garamond, engerem Zeilenfall und klassischem Erstzeileneinzug.',
          pageFormat: 'Print',
          trimSize: 'ca. 12 x 19 cm',
          fontFamily: 'Garamond',
          bodySizePt: 11,
          lineHeightPt: 15.6,
          marginDescription: 'innen/außen moderat',
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
      PublishingStyle.ebook => const PublishingLayoutProfile(
          style: PublishingStyle.ebook,
          label: 'E-Book',
          description:
              'Reflow-freundliche Vorlage mit klarer Hierarchie und flexiblen Rändern für Reader.',
          pageFormat: 'Reflow',
          trimSize: 'Readerabhängig',
          fontFamily: 'Georgia',
          bodySizePt: 12,
          lineHeightPt: 17,
          marginDescription: 'relative Reader-Ränder',
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
      PublishingStyle.largePrint => const PublishingLayoutProfile(
          style: PublishingStyle.largePrint,
          label: 'Großdruck',
          description:
              'Barrierearme Ausgabe mit größerer Schrift, weitem Zeilenabstand und großzügiger Vorschau.',
          pageFormat: 'A4 / Print',
          trimSize: '210 x 297 mm',
          fontFamily: 'Georgia',
          bodySizePt: 15,
          lineHeightPt: 22,
          marginDescription: 'großzügiger Leserand',
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

final class ExportProfile {
  const ExportProfile({
    required this.id,
    required this.projectId,
    required this.name,
    required this.format,
    this.includeMetadata = false,
    this.includeSceneTitles = true,
    this.publishingStyle = PublishingStyle.manuscript,
    this.filters = const {},
  });

  final String id;
  final String projectId;
  final String name;
  final ExportFormat format;
  final bool includeMetadata;
  final bool includeSceneTitles;
  final PublishingStyle publishingStyle;
  final JsonMap filters;
}
