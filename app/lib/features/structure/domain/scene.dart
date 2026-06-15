import '../../../core/domain/draft_status.dart';
import '../../../core/domain/json_map.dart';

final class Scene {
  const Scene({
    required this.id,
    required this.projectId,
    required this.title,
    required this.status,
    required this.orderIndex,
    required this.aiAssistAllowed,
    required this.createdAt,
    required this.updatedAt,
    this.chapterId,
    this.parentSceneId,
    this.summary = '',
    this.manuscriptText = '',
    this.authorIntent = '',
    this.povCharacterId,
    this.sceneType = 'scene',
    this.storyDateStart,
    this.storyDateEnd,
    this.estimatedWordTarget,
    this.tensionLevel,
    this.emotionalTone,
    this.goal,
    this.conflict,
    this.outcome,
    this.metadata = const {},
  });

  final String id;
  final String projectId;
  final String? chapterId;
  final String? parentSceneId;
  final String title;
  final String summary;
  final String manuscriptText;
  final String authorIntent;
  final String? povCharacterId;
  final String sceneType;
  final DraftStatus status;
  final double orderIndex;
  final DateTime? storyDateStart;
  final DateTime? storyDateEnd;
  final int? estimatedWordTarget;
  final int? tensionLevel;
  final String? emotionalTone;
  final String? goal;
  final String? conflict;
  final String? outcome;
  final bool aiAssistAllowed;
  final JsonMap metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  int get actualWordCount {
    final trimmed = manuscriptText.trim();
    if (trimmed.isEmpty) return 0;
    return trimmed.split(RegExp(r'\s+')).length;
  }

  Scene copyWith({
    String? chapterId,
    bool clearChapterId = false,
    String? title,
    String? summary,
    String? manuscriptText,
    String? authorIntent,
    String? povCharacterId,
    String? sceneType,
    DraftStatus? status,
    double? orderIndex,
    DateTime? storyDateStart,
    DateTime? storyDateEnd,
    int? estimatedWordTarget,
    bool clearEstimatedWordTarget = false,
    int? tensionLevel,
    String? emotionalTone,
    String? goal,
    String? conflict,
    String? outcome,
    bool? aiAssistAllowed,
    JsonMap? metadata,
  }) {
    return Scene(
      id: id,
      projectId: projectId,
      chapterId: clearChapterId ? null : chapterId ?? this.chapterId,
      parentSceneId: parentSceneId,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      manuscriptText: manuscriptText ?? this.manuscriptText,
      authorIntent: authorIntent ?? this.authorIntent,
      povCharacterId: povCharacterId ?? this.povCharacterId,
      sceneType: sceneType ?? this.sceneType,
      status: status ?? this.status,
      orderIndex: orderIndex ?? this.orderIndex,
      storyDateStart: storyDateStart ?? this.storyDateStart,
      storyDateEnd: storyDateEnd ?? this.storyDateEnd,
      estimatedWordTarget:
          clearEstimatedWordTarget ? null : estimatedWordTarget ?? this.estimatedWordTarget,
      tensionLevel: tensionLevel ?? this.tensionLevel,
      emotionalTone: emotionalTone ?? this.emotionalTone,
      goal: goal ?? this.goal,
      conflict: conflict ?? this.conflict,
      outcome: outcome ?? this.outcome,
      aiAssistAllowed: aiAssistAllowed ?? this.aiAssistAllowed,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt,
      updatedAt: DateTime.now().toUtc(),
    );
  }

  Scene withAuthorText(String text) {
    return copyWith(manuscriptText: text);
  }

  JsonMap toJson() => {
        'id': id,
        'projectId': projectId,
        'chapterId': chapterId,
        'parentSceneId': parentSceneId,
        'title': title,
        'summary': summary,
        'manuscriptText': manuscriptText,
        'authorIntent': authorIntent,
        'povCharacterId': povCharacterId,
        'sceneType': sceneType,
        'status': status.wireName,
        'orderIndex': orderIndex,
        'storyDateStart': storyDateStart?.toIso8601String(),
        'storyDateEnd': storyDateEnd?.toIso8601String(),
        'estimatedWordTarget': estimatedWordTarget,
        'actualWordCount': actualWordCount,
        'tensionLevel': tensionLevel,
        'emotionalTone': emotionalTone,
        'goal': goal,
        'conflict': conflict,
        'outcome': outcome,
        'aiAssistAllowed': aiAssistAllowed,
        'metadata': metadata,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory Scene.fromJson(JsonMap json) {
    return Scene(
      id: json['id'] as String,
      projectId: json['projectId'] as String,
      chapterId: json['chapterId'] as String?,
      parentSceneId: json['parentSceneId'] as String?,
      title: json['title'] as String,
      summary: json['summary'] as String? ?? '',
      manuscriptText: json['manuscriptText'] as String? ?? '',
      authorIntent: json['authorIntent'] as String? ?? '',
      povCharacterId: json['povCharacterId'] as String?,
      sceneType: json['sceneType'] as String? ?? 'scene',
      status: DraftStatusWire.parse(json['status'] as String),
      orderIndex: (json['orderIndex'] as num).toDouble(),
      storyDateStart: _parseDate(json['storyDateStart']),
      storyDateEnd: _parseDate(json['storyDateEnd']),
      estimatedWordTarget: json['estimatedWordTarget'] as int?,
      tensionLevel: json['tensionLevel'] as int?,
      emotionalTone: json['emotionalTone'] as String?,
      goal: json['goal'] as String?,
      conflict: json['conflict'] as String?,
      outcome: json['outcome'] as String?,
      aiAssistAllowed: json['aiAssistAllowed'] as bool? ?? true,
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
