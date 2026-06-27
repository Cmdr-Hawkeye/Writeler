import '../../../core/domain/json_map.dart';
import 'scene.dart';

enum SceneSnapshotReason {
  manual,
  majorEdit,
  aiAccepted,
  restore,
}

final class SceneSnapshot {
  const SceneSnapshot({
    required this.id,
    required this.projectId,
    required this.sceneId,
    required this.sceneTitle,
    required this.reason,
    required this.scene,
    required this.createdAt,
    this.label = '',
  });

  final String id;
  final String projectId;
  final String sceneId;
  final String sceneTitle;
  final String label;
  final SceneSnapshotReason reason;
  final Scene scene;
  final DateTime createdAt;

  JsonMap toJson() => {
        'id': id,
        'projectId': projectId,
        'sceneId': sceneId,
        'sceneTitle': sceneTitle,
        'label': label,
        'reason': reason.wireName,
        'scene': scene.toJson(),
        'createdAt': createdAt.toIso8601String(),
      };

  factory SceneSnapshot.fromJson(JsonMap json) {
    return SceneSnapshot(
      id: json['id'] as String,
      projectId: json['projectId'] as String,
      sceneId: json['sceneId'] as String,
      sceneTitle: json['sceneTitle'] as String? ?? '',
      label: json['label'] as String? ?? '',
      reason: SceneSnapshotReasonWire.parse(json['reason'] as String?),
      scene: Scene.fromJson(
        Map<String, Object?>.from(json['scene'] as Map),
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

extension SceneSnapshotReasonWire on SceneSnapshotReason {
  String get wireName => name;

  static SceneSnapshotReason parse(String? value) {
    return SceneSnapshotReason.values.firstWhere(
      (reason) => reason.name == value,
      orElse: () => SceneSnapshotReason.manual,
    );
  }
}
