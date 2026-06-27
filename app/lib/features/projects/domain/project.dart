import '../../../core/domain/draft_status.dart';
import '../../../core/domain/json_map.dart';

final class Project {
  const Project({
    required this.id,
    required this.title,
    required this.projectType,
    required this.languageCode,
    required this.status,
    required this.aiEnabled,
    required this.cloudSyncEnabled,
    required this.noAiNoCloud,
    required this.createdAt,
    required this.updatedAt,
    this.description = '',
    this.wordTarget,
    this.metadata = const {},
  });

  final String id;
  final String title;
  final String description;
  final String projectType;
  final String languageCode;
  final DraftStatus status;
  final int? wordTarget;
  final bool aiEnabled;
  final bool cloudSyncEnabled;
  final bool noAiNoCloud;
  final JsonMap metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  Project copyWith({
    String? title,
    String? description,
    String? projectType,
    String? languageCode,
    DraftStatus? status,
    int? wordTarget,
    bool clearWordTarget = false,
    bool? aiEnabled,
    bool? cloudSyncEnabled,
    bool? noAiNoCloud,
    JsonMap? metadata,
    DateTime? updatedAt,
  }) {
    return Project(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      projectType: projectType ?? this.projectType,
      languageCode: languageCode ?? this.languageCode,
      status: status ?? this.status,
      wordTarget: clearWordTarget ? null : wordTarget ?? this.wordTarget,
      aiEnabled: aiEnabled ?? this.aiEnabled,
      cloudSyncEnabled: cloudSyncEnabled ?? this.cloudSyncEnabled,
      noAiNoCloud: noAiNoCloud ?? this.noAiNoCloud,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now().toUtc(),
    );
  }

  JsonMap toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'projectType': projectType,
        'languageCode': languageCode,
        'status': status.wireName,
        'wordTarget': wordTarget,
        'aiEnabled': aiEnabled,
        'cloudSyncEnabled': cloudSyncEnabled,
        'noAiNoCloud': noAiNoCloud,
        'metadata': metadata,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory Project.fromJson(JsonMap json) {
    return Project(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      projectType: json['projectType'] as String,
      languageCode: json['languageCode'] as String,
      status: DraftStatusWire.parse(json['status'] as String),
      wordTarget: json['wordTarget'] as int?,
      aiEnabled: json['aiEnabled'] as bool,
      cloudSyncEnabled: json['cloudSyncEnabled'] as bool,
      noAiNoCloud: json['noAiNoCloud'] as bool,
      metadata: Map<String, Object?>.from(json['metadata'] as Map? ?? const {}),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
