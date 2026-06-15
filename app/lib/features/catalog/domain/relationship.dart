import '../../../core/domain/entity_ref.dart';
import '../../../core/domain/json_map.dart';

enum RelationshipDirection { directed, undirected }

final class Relationship {
  const Relationship({
    required this.id,
    required this.projectId,
    required this.source,
    required this.target,
    required this.relationshipType,
    required this.direction,
    required this.createdAt,
    required this.updatedAt,
    this.label,
    this.description,
    this.strength,
    this.validFromStoryTime,
    this.validToStoryTime,
    this.metadata = const {},
  });

  final String id;
  final String projectId;
  final EntityRef source;
  final EntityRef target;
  final String relationshipType;
  final String? label;
  final String? description;
  final double? strength;
  final RelationshipDirection direction;
  final DateTime? validFromStoryTime;
  final DateTime? validToStoryTime;
  final JsonMap metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  JsonMap toJson() => {
        'id': id,
        'projectId': projectId,
        'source': source.toJson(),
        'target': target.toJson(),
        'relationshipType': relationshipType,
        'label': label,
        'description': description,
        'strength': strength,
        'direction': direction.name,
        'validFromStoryTime': validFromStoryTime?.toIso8601String(),
        'validToStoryTime': validToStoryTime?.toIso8601String(),
        'metadata': metadata,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory Relationship.fromJson(JsonMap json) {
    return Relationship(
      id: json['id'] as String,
      projectId: json['projectId'] as String,
      source: EntityRef.fromJson(Map<String, Object?>.from(json['source'] as Map)),
      target: EntityRef.fromJson(Map<String, Object?>.from(json['target'] as Map)),
      relationshipType: json['relationshipType'] as String,
      label: json['label'] as String?,
      description: json['description'] as String?,
      strength: (json['strength'] as num?)?.toDouble(),
      direction: RelationshipDirection.values.firstWhere(
        (direction) => direction.name == json['direction'],
        orElse: () => RelationshipDirection.directed,
      ),
      validFromStoryTime: _parseDate(json['validFromStoryTime']),
      validToStoryTime: _parseDate(json['validToStoryTime']),
      metadata: Map<String, Object?>.from(json['metadata'] as Map? ?? const {}),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

DateTime? _parseDate(Object? value) {
  if (value == null) return null;
  return DateTime.parse(value as String);
}
