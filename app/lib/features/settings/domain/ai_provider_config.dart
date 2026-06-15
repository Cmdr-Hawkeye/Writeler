import '../../../core/domain/json_map.dart';

enum AIProviderKind { openAICompatible, anthropic, gemini, openRouter, ollama, mock }

final class AIProviderConfig {
  const AIProviderConfig({
    required this.id,
    required this.kind,
    required this.displayName,
    required this.modelName,
    this.baseUrl,
    this.encryptedApiKeyRef,
    this.parameters = const {},
    this.enabled = true,
  });

  final String id;
  final AIProviderKind kind;
  final String displayName;
  final String modelName;
  final String? baseUrl;
  final String? encryptedApiKeyRef;
  final JsonMap parameters;
  final bool enabled;

  JsonMap toJson() => {
        'id': id,
        'kind': kind.name,
        'displayName': displayName,
        'modelName': modelName,
        'baseUrl': baseUrl,
        'encryptedApiKeyRef': encryptedApiKeyRef,
        'parameters': parameters,
        'enabled': enabled,
      };

  AIProviderConfig copyWith({
    AIProviderKind? kind,
    String? displayName,
    String? modelName,
    String? baseUrl,
    String? encryptedApiKeyRef,
    JsonMap? parameters,
    bool? enabled,
  }) {
    return AIProviderConfig(
      id: id,
      kind: kind ?? this.kind,
      displayName: displayName ?? this.displayName,
      modelName: modelName ?? this.modelName,
      baseUrl: baseUrl ?? this.baseUrl,
      encryptedApiKeyRef: encryptedApiKeyRef ?? this.encryptedApiKeyRef,
      parameters: parameters ?? this.parameters,
      enabled: enabled ?? this.enabled,
    );
  }

  factory AIProviderConfig.fromJson(JsonMap json) {
    return AIProviderConfig(
      id: json['id'] as String,
      kind: AIProviderKind.values.firstWhere(
        (kind) => kind.name == json['kind'],
        orElse: () => AIProviderKind.mock,
      ),
      displayName: json['displayName'] as String,
      modelName: json['modelName'] as String,
      baseUrl: json['baseUrl'] as String?,
      encryptedApiKeyRef: json['encryptedApiKeyRef'] as String?,
      parameters: Map<String, Object?>.from(json['parameters'] as Map? ?? const {}),
      enabled: json['enabled'] as bool? ?? true,
    );
  }
}
