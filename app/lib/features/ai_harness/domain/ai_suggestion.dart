import '../../../core/domain/entity_ref.dart';
import '../../../core/domain/json_map.dart';

enum SuggestionDecision { pending, accepted, rejected, convertedToNote }

final class AISuggestion {
  const AISuggestion({
    required this.id,
    required this.projectId,
    required this.target,
    required this.suggestionType,
    required this.inputContextHash,
    required this.providerId,
    required this.modelName,
    required this.promptText,
    required this.responseText,
    required this.userDecision,
    required this.createdAt,
    this.promptTemplateId,
    this.structuredResponse,
    this.acceptedPatch,
  });

  final String id;
  final String projectId;
  final EntityRef target;
  final String suggestionType;
  final String inputContextHash;
  final String providerId;
  final String modelName;
  final String? promptTemplateId;
  final String promptText;
  final String responseText;
  final JsonMap? structuredResponse;
  final SuggestionDecision userDecision;
  final JsonMap? acceptedPatch;
  final DateTime createdAt;

  JsonMap toJson() => {
        'id': id,
        'projectId': projectId,
        'target': target.toJson(),
        'suggestionType': suggestionType,
        'inputContextHash': inputContextHash,
        'providerId': providerId,
        'modelName': modelName,
        'promptTemplateId': promptTemplateId,
        'promptText': promptText,
        'responseText': responseText,
        'structuredResponse': structuredResponse,
        'userDecision': userDecision.name,
        'acceptedPatch': acceptedPatch,
        'createdAt': createdAt.toIso8601String(),
      };

  AISuggestion copyWith({
    SuggestionDecision? userDecision,
    JsonMap? acceptedPatch,
  }) {
    return AISuggestion(
      id: id,
      projectId: projectId,
      target: target,
      suggestionType: suggestionType,
      inputContextHash: inputContextHash,
      providerId: providerId,
      modelName: modelName,
      promptTemplateId: promptTemplateId,
      promptText: promptText,
      responseText: responseText,
      structuredResponse: structuredResponse,
      userDecision: userDecision ?? this.userDecision,
      acceptedPatch: acceptedPatch ?? this.acceptedPatch,
      createdAt: createdAt,
    );
  }

  factory AISuggestion.fromJson(JsonMap json) {
    return AISuggestion(
      id: json['id'] as String,
      projectId: json['projectId'] as String,
      target: EntityRef.fromJson(Map<String, Object?>.from(json['target'] as Map)),
      suggestionType: json['suggestionType'] as String,
      inputContextHash: json['inputContextHash'] as String,
      providerId: json['providerId'] as String,
      modelName: json['modelName'] as String,
      promptTemplateId: json['promptTemplateId'] as String?,
      promptText: json['promptText'] as String,
      responseText: json['responseText'] as String,
      structuredResponse: json['structuredResponse'] == null
          ? null
          : Map<String, Object?>.from(json['structuredResponse'] as Map),
      userDecision: SuggestionDecision.values.firstWhere(
        (decision) => decision.name == json['userDecision'],
        orElse: () => SuggestionDecision.pending,
      ),
      acceptedPatch: json['acceptedPatch'] == null
          ? null
          : Map<String, Object?>.from(json['acceptedPatch'] as Map),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

}
