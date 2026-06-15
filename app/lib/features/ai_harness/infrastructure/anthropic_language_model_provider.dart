import 'dart:convert';

import '../../../core/domain/domain_failure.dart';
import '../../../core/domain/json_map.dart';
import '../../settings/domain/ai_provider_config.dart';
import '../../settings/domain/ai_provider_preset.dart';
import '../domain/language_model_provider.dart';
import '../domain/model_http_transport.dart';
import '../domain/model_request.dart';
import 'openai_compatible_language_model_provider.dart';

final class AnthropicLanguageModelProvider implements LanguageModelProvider {
  const AnthropicLanguageModelProvider({
    required this.id,
    required this.displayName,
    required this.modelName,
    required this.baseUrl,
    this.apiKey,
    this.transport = const MissingModelHttpTransport(),
  });

  factory AnthropicLanguageModelProvider.fromConfig(
    AIProviderConfig config, {
    String? apiKey,
    ModelHttpTransport transport = const MissingModelHttpTransport(),
  }) {
    final preset = AIProviderPreset.forKind(AIProviderKind.anthropic);
    return AnthropicLanguageModelProvider(
      id: config.id,
      displayName: config.displayName,
      modelName: config.modelName,
      baseUrl: Uri.parse(config.baseUrl ?? preset.baseUrl!),
      apiKey: apiKey,
      transport: transport,
    );
  }

  @override
  final String id;

  @override
  final String displayName;

  final String modelName;
  final Uri baseUrl;
  final String? apiKey;
  final ModelHttpTransport transport;

  @override
  ProviderCapabilities get capabilities => const ProviderCapabilities(
        supportsText: true,
        supportsStructuredOutput: true,
        supportsEmbeddings: false,
        maxContextTokens: 200000,
      );

  @override
  Future<int> estimateTokens(String text) async => (text.length / 4).ceil();

  @override
  Future<ModelResponse> generateText(ModelRequest request) async {
    final response = await transport.postJson(
      uri: _messagesUri(),
      headers: _headers(),
      body: _requestBody(request),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw DomainFailure(
        'Provider "$displayName" returned HTTP ${response.statusCode}: ${response.body}',
      );
    }

    final json = _decodeObject(response.body);
    final content = json['content'];
    if (content is! List) {
      throw const DomainFailure('Anthropic response did not include content.');
    }

    final text = content
        .whereType<Map>()
        .where((part) => part['type'] == 'text')
        .map((part) => part['text'])
        .whereType<String>()
        .join('\n')
        .trim();
    if (text.isEmpty) {
      throw const DomainFailure(
          'Anthropic response did not include text content.');
    }

    final usage = json['usage'];
    return ModelResponse(
      text: text,
      estimatedInputTokens: usage is Map ? _asInt(usage['input_tokens']) : null,
      estimatedOutputTokens:
          usage is Map ? _asInt(usage['output_tokens']) : null,
    );
  }

  Uri _messagesUri() {
    final normalized = baseUrl.path.endsWith('/')
        ? baseUrl.path.substring(0, baseUrl.path.length - 1)
        : baseUrl.path;
    final alreadyMessages = normalized.endsWith('/v1/messages');
    return baseUrl.replace(
        path: alreadyMessages ? normalized : '$normalized/v1/messages');
  }

  Map<String, String> _headers() {
    final token = apiKey?.trim();
    return {
      'content-type': 'application/json',
      'accept': 'application/json',
      'anthropic-version': '2023-06-01',
      if (token != null && token.isNotEmpty) 'x-api-key': token,
    };
  }

  JsonMap _requestBody(ModelRequest request) {
    return {
      'model': modelName,
      'max_tokens': request.parameters.maxTokens,
      'temperature': request.parameters.temperature,
      'top_p': request.parameters.topP,
      'system':
          'You are an analysis assistant for authors. Do not write manuscript prose.',
      'messages': [
        {'role': 'user', 'content': request.prompt},
      ],
      'metadata': {
        ...request.context,
        if (request.target != null) 'target': request.target!.toJson(),
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
