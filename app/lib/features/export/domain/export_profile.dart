import '../../../core/domain/json_map.dart';

enum ExportFormat { markdown, html, plainText, outline, json, pdf, epub, docx }

final class ExportProfile {
  const ExportProfile({
    required this.id,
    required this.projectId,
    required this.name,
    required this.format,
    this.includeMetadata = false,
    this.includeSceneTitles = true,
    this.filters = const {},
  });

  final String id;
  final String projectId;
  final String name;
  final ExportFormat format;
  final bool includeMetadata;
  final bool includeSceneTitles;
  final JsonMap filters;
}
