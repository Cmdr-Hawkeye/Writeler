import '../../../core/domain/entity_ref.dart';
import '../../../core/domain/json_map.dart';

enum ResearchItemKind { link, file, image, pdf, webNote, source }

extension ResearchItemKindWire on ResearchItemKind {
  String get wireName => switch (this) {
        ResearchItemKind.link => 'link',
        ResearchItemKind.file => 'file',
        ResearchItemKind.image => 'image',
        ResearchItemKind.pdf => 'pdf',
        ResearchItemKind.webNote => 'webNote',
        ResearchItemKind.source => 'source',
      };

  static ResearchItemKind parse(String value) => switch (value) {
        'link' => ResearchItemKind.link,
        'file' => ResearchItemKind.file,
        'image' => ResearchItemKind.image,
        'pdf' => ResearchItemKind.pdf,
        'webNote' => ResearchItemKind.webNote,
        'source' => ResearchItemKind.source,
        _ => ResearchItemKind.source,
      };
}

final class ResearchItem {
  const ResearchItem({
    required this.id,
    required this.projectId,
    required this.kind,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    this.uri = '',
    this.body = '',
    this.source = '',
    this.tags = const [],
    this.target,
    this.metadata = const {},
  });

  final String id;
  final String projectId;
  final ResearchItemKind kind;
  final EntityRef? target;
  final String title;
  final String uri;
  final String body;
  final String source;
  final List<String> tags;
  final JsonMap metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  ResearchItem copyWith({
    ResearchItemKind? kind,
    EntityRef? target,
    bool clearTarget = false,
    String? title,
    String? uri,
    String? body,
    String? source,
    List<String>? tags,
    JsonMap? metadata,
    DateTime? updatedAt,
  }) {
    return ResearchItem(
      id: id,
      projectId: projectId,
      kind: kind ?? this.kind,
      target: clearTarget ? null : target ?? this.target,
      title: title ?? this.title,
      uri: uri ?? this.uri,
      body: body ?? this.body,
      source: source ?? this.source,
      tags: tags ?? this.tags,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now().toUtc(),
    );
  }

  JsonMap toJson() => {
        'id': id,
        'projectId': projectId,
        'kind': kind.wireName,
        'target': target?.toJson(),
        'title': title,
        'uri': uri,
        'body': body,
        'source': source,
        'tags': tags,
        'metadata': metadata,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory ResearchItem.fromJson(JsonMap json) {
    return ResearchItem(
      id: json['id'] as String,
      projectId: json['projectId'] as String,
      kind: ResearchItemKindWire.parse(json['kind'] as String? ?? 'source'),
      target: json['target'] == null
          ? null
          : EntityRef.fromJson(
              Map<String, Object?>.from(json['target'] as Map),
            ),
      title: json['title'] as String,
      uri: json['uri'] as String? ?? '',
      body: json['body'] as String? ?? '',
      source: json['source'] as String? ?? '',
      tags: [
        for (final tag in json['tags'] as List? ?? const []) tag.toString(),
      ],
      metadata: Map<String, Object?>.from(json['metadata'] as Map? ?? const {}),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
