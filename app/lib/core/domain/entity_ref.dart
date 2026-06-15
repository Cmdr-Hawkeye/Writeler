import 'entity_type.dart';
import 'json_map.dart';

final class EntityRef {
  const EntityRef({
    required this.type,
    required this.id,
  });

  final EntityType type;
  final String id;

  JsonMap toJson() => {
        'type': type.wireName,
        'id': id,
      };

  factory EntityRef.fromJson(JsonMap json) {
    return EntityRef(
      type: EntityTypeWire.parse(json['type'] as String),
      id: json['id'] as String,
    );
  }
}
