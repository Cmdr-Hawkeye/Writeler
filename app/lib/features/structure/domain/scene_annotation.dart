import '../../../core/domain/json_map.dart';

final class SceneAnnotation {
  const SceneAnnotation({
    required this.id,
    required this.sceneId,
    required this.startOffset,
    required this.endOffset,
    required this.selectedText,
    required this.comment,
    required this.createdAt,
    required this.updatedAt,
    this.resolved = false,
  });

  final String id;
  final String sceneId;
  final int startOffset;
  final int endOffset;
  final String selectedText;
  final String comment;
  final bool resolved;
  final DateTime createdAt;
  final DateTime updatedAt;

  int get length => endOffset - startOffset;

  SceneAnnotation copyWith({
    int? startOffset,
    int? endOffset,
    String? selectedText,
    String? comment,
    bool? resolved,
  }) {
    return SceneAnnotation(
      id: id,
      sceneId: sceneId,
      startOffset: startOffset ?? this.startOffset,
      endOffset: endOffset ?? this.endOffset,
      selectedText: selectedText ?? this.selectedText,
      comment: comment ?? this.comment,
      resolved: resolved ?? this.resolved,
      createdAt: createdAt,
      updatedAt: DateTime.now().toUtc(),
    );
  }

  JsonMap toJson() => {
        'id': id,
        'sceneId': sceneId,
        'startOffset': startOffset,
        'endOffset': endOffset,
        'selectedText': selectedText,
        'comment': comment,
        'resolved': resolved,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory SceneAnnotation.fromJson(JsonMap json) {
    return SceneAnnotation(
      id: json['id'] as String,
      sceneId: json['sceneId'] as String,
      startOffset: json['startOffset'] as int? ?? 0,
      endOffset: json['endOffset'] as int? ?? 0,
      selectedText: json['selectedText'] as String? ?? '',
      comment: json['comment'] as String? ?? '',
      resolved: json['resolved'] as bool? ?? false,
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
    );
  }

  static List<SceneAnnotation> listFromMetadata(JsonMap metadata) {
    final raw = metadata['annotations'];
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((entry) => SceneAnnotation.fromJson(
              Map<String, Object?>.from(entry),
            ))
        .toList()
      ..sort((a, b) {
        final resolvedCompare = a.resolved == b.resolved
            ? 0
            : a.resolved
                ? 1
                : -1;
        if (resolvedCompare != 0) return resolvedCompare;
        final offsetCompare = a.startOffset.compareTo(b.startOffset);
        if (offsetCompare != 0) return offsetCompare;
        return b.updatedAt.compareTo(a.updatedAt);
      });
  }

  static JsonMap metadataWithAnnotations(
    JsonMap metadata,
    List<SceneAnnotation> annotations,
  ) {
    final updated = Map<String, Object?>.from(metadata);
    updated['annotations'] =
        annotations.map((annotation) => annotation.toJson()).toList();
    return updated;
  }
}

DateTime _parseDate(Object? value) {
  if (value is String && value.isNotEmpty) {
    return DateTime.tryParse(value)?.toUtc() ?? DateTime.now().toUtc();
  }
  return DateTime.now().toUtc();
}
