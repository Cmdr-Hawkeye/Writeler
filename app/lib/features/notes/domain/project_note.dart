import '../../../core/domain/entity_ref.dart';
import '../../../core/domain/json_map.dart';

final class ProjectNote {
  const ProjectNote({
    required this.id,
    required this.projectId,
    required this.title,
    required this.body,
    required this.source,
    required this.createdAt,
    required this.updatedAt,
    this.target,
    this.sourceSuggestionId,
    this.metadata = const {},
  });

  final String id;
  final String projectId;
  final EntityRef? target;
  final String title;
  final String body;
  final String source;
  final String? sourceSuggestionId;
  final JsonMap metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProjectNote copyWith({
    EntityRef? target,
    bool clearTarget = false,
    String? title,
    String? body,
    String? source,
    String? sourceSuggestionId,
    bool clearSourceSuggestionId = false,
    JsonMap? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProjectNote(
      id: id,
      projectId: projectId,
      target: clearTarget ? null : target ?? this.target,
      title: title ?? this.title,
      body: body ?? this.body,
      source: source ?? this.source,
      sourceSuggestionId: clearSourceSuggestionId
          ? null
          : sourceSuggestionId ?? this.sourceSuggestionId,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  JsonMap toJson() => {
        'id': id,
        'projectId': projectId,
        'target': target?.toJson(),
        'title': title,
        'body': body,
        'source': source,
        'sourceSuggestionId': sourceSuggestionId,
        'metadata': metadata,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory ProjectNote.fromJson(JsonMap json) {
    return ProjectNote(
      id: json['id'] as String,
      projectId: json['projectId'] as String,
      target: json['target'] == null
          ? null
          : EntityRef.fromJson(
              Map<String, Object?>.from(json['target'] as Map),
            ),
      title: json['title'] as String,
      body: json['body'] as String,
      source: json['source'] as String? ?? 'manual',
      sourceSuggestionId: json['sourceSuggestionId'] as String?,
      metadata: Map<String, Object?>.from(json['metadata'] as Map? ?? const {}),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
