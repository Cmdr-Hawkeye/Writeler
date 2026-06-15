import 'dart:convert';

import '../../../core/domain/domain_failure.dart';
import '../../../core/domain/json_map.dart';
import '../../settings/domain/ai_provider_config.dart';
import '../../settings/domain/ai_provider_preset.dart';
import '../domain/language_model_provider.dart';
import '../domain/model_http_transport.dart';
import '../domain/model_request.dart';
import 'openai_compatible_language_model_provider.dart';

final class OllamaLanguageModelProvider implements LanguageModelProvider {
  const OllamaLanguageModelProvider({
    required this.id,
    required this.displayName,
    required this.modelName,
    required this.baseUrl,
    this.transport = const MissingModelHttpTransport(),
  });

  factory OllamaLanguageModelProvider.fromConfig(
    AIProviderConfig config, {
    ModelHttpTransport transport = const MissingModelHttpTransport(),
  }) {
    final preset = AIProviderPreset.forKind(AIProviderKind.ollama);
    return OllamaLanguageModelProvider(
      id: config.id,
      displayName: config.displayName,
      modelName: config.modelName,
      baseUrl: Uri.parse(config.baseUrl ?? preset.baseUrl!),
      transport: transport,
    );
  }

  @override
  final String id;

  @override
  final String displayName;

  final String modelName;
  final Uri baseUrl;
  final ModelHttpTransport transport;

  @override
  ProviderCapabilities get capabilities => const ProviderCapabilities(
        supportsText: true,
        supportsStructuredOutput: false,
        supportsEmbeddings: false,
        maxContextTokens: 128000,
      );

  @override
  Future<int> estimateTokens(String text) async => (text.length / 4).ceil();

  @override
  Future<ModelResponse> generateText(ModelRequest request) async {
    final response = await transport.postJson(
      uri: _chatUri(),
      headers: const {
        'content-type': 'application/json',
        'accept': 'application/json',
      },
      body: _requestBody(request),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw DomainFailure(
        'Provider "$displayName" returned HTTP ${response.statusCode}: ${response.body}',
      );
    }

    final json = _decodeObject(response.body);
    final message = json['message'];
    final content = message is Map ? message['content'] : json['response'];
    if (content is! String || content.trim().isEmpty) {
      throw const DomainFailure('Ollama response did not include text content.');
    }

    return ModelResponse(
      text: content.trim(),
      estimatedInputTokens: _asInt(json['prompt_eval_count']),
      estimatedOutputTokens: _asInt(json['eval_count']),
    );
  }

  Uri _chatUri() {
    final normalized = baseUrl.path.endsWith('/')
        ? baseUrl.path.substring(0, baseUrl.path.length - 1)
        : baseUrl.path;
    final alreadyChat = normalized.endsWith('/api/chat');
    return baseUrl.replace(path: alreadyChat ? normalized : '$normalized/api/chat');
  }

  JsonMap _requestBody(ModelRequest request) {
    return {
      'model': modelName,
      'stream': false,
      'messages': [
        {
          'role': 'system',
          'content': 'You are an analysis assistant for authors. Do not write manuscript prose.',
        },
        {'role': 'user', 'content': request.prompt},
      ],
      'options': {
        'temperature': request.parameters.temperature,
        'top_p': request.parameters.topP,
        'num_predict': request.parameters.maxTokens,
      },
    };
  }

  JsonMap _decodeObject(String body) {
    final decoded = jsonDecode(body);
    if (decoded is! Map) {
      throw const DomainFailure('Provider response was not a JSON object.');
    }
    return Map<String, Object?>.from(decoded);
  }

  int? _asInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.round();
    if (value is String) return int.tryParse(value);
    return null;
  }
}
