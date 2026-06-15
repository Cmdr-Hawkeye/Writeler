import '../../../core/domain/entity_ref.dart';
import '../../../core/domain/json_map.dart';

final class ModelRequest {
  const ModelRequest({
    required this.prompt,
    required this.context,
    required this.parameters,
    this.target,
  });

  final String prompt;
  final EntityRef? target;
  final JsonMap context;
  final ModelParameters parameters;
}

final class ModelParameters {
  const ModelParameters({
    this.temperature = 0.4,
    this.maxTokens = 1200,
    this.topP = 1,
  });

  final double temperature;
  final int maxTokens;
  final double topP;

  JsonMap toJson() => {
        'temperature': temperature,
        'maxTokens': maxTokens,
        'topP': topP,
      };
}

final class ModelResponse {
  const ModelResponse({
    required this.text,
    this.structured,
    this.estimatedInputTokens,
    this.estimatedOutputTokens,
  });

  final String text;
  final JsonMap? structured;
  final int? estimatedInputTokens;
  final int? estimatedOutputTokens;
}
