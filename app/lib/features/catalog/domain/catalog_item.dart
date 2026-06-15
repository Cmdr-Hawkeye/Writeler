import '../../../core/domain/draft_status.dart';
import '../../../core/domain/entity_type.dart';
import '../../../core/domain/json_map.dart';

final class CatalogItem {
  const CatalogItem({
    required this.id,
    required this.projectId,
    required this.type,
    required this.name,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.summary = '',
    this.fields = const {},
    this.metadata = const {},
  });

  final String id;
  final String projectId;
  final EntityType type;
  final String name;
  final String summary;
  final DraftStatus status;
  final JsonMap fields;
  final JsonMap metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  JsonMap toJson() => {
        'id': id,
        'projectId': projectId,
        'type': type.wireName,
        'name': name,
        'summary': summary,
        'status': status.wireName,
        'fields': fields,
        'metadata': metadata,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  CatalogItem copyWith({
    String? name,
    String? summary,
    DraftStatus? status,
    JsonMap? fields,
    JsonMap? metadata,
  }) {
    return CatalogItem(
      id: id,
      projectId: projectId,
      type: type,
      name: name ?? this.name,
      summary: summary ?? this.summary,
      status: status ?? this.status,
      fields: fields ?? this.fields,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt,
      updatedAt: DateTime.now().toUtc(),
    );
  }

  factory CatalogItem.fromJson(JsonMap json) {
    return CatalogItem(
      id: json['id'] as String,
      projectId: json['projectId'] as String,
      type: EntityTypeWire.parse(json['type'] as String),
      name: json['name'] as String,
      summary: json['summary'] as String? ?? '',
      status: DraftStatusWire.parse(json['status'] as String),
      fields: Map<String, Object?>.from(json['fields'] as Map? ?? const {}),
      metadata: Map<String, Object?>.from(json['metadata'] as Map? ?? const {}),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
