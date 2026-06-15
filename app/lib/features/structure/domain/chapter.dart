import '../../../core/domain/draft_status.dart';
import '../../../core/domain/json_map.dart';

final class Chapter {
  const Chapter({
    required this.id,
    required this.projectId,
    required this.title,
    required this.orderIndex,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.summary = '',
    this.partId,
    this.metadata = const {},
  });

  final String id;
  final String projectId;
  final String? partId;
  final String title;
  final String summary;
  final double orderIndex;
  final DraftStatus status;
  final JsonMap metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  JsonMap toJson() => {
        'id': id,
        'projectId': projectId,
        'partId': partId,
        'title': title,
        'summary': summary,
        'orderIndex': orderIndex,
        'status': status.wireName,
        'metadata': metadata,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  Chapter copyWith({
    String? title,
    String? summary,
    double? orderIndex,
    DraftStatus? status,
    JsonMap? metadata,
  }) {
    return Chapter(
      id: id,
      projectId: projectId,
      partId: partId,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      orderIndex: orderIndex ?? this.orderIndex,
      status: status ?? this.status,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt,
      updatedAt: DateTime.now().toUtc(),
    );
  }

  factory Chapter.fromJson(JsonMap json) {
    return Chapter(
      id: json['id'] as String,
      projectId: json['projectId'] as String,
      partId: json['partId'] as String?,
      title: json['title'] as String,
      summary: json['summary'] as String? ?? '',
      orderIndex: (json['orderIndex'] as num).toDouble(),
      status: DraftStatusWire.parse(json['status'] as String),
      metadata: Map<String, Object?>.from(json['metadata'] as Map? ?? const {}),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
