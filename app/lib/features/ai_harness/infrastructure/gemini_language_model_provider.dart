import 'dart:convert';

import '../../../core/domain/domain_failure.dart';
import '../../../core/domain/json_map.dart';
import '../../settings/domain/ai_provider_config.dart';
import '../../settings/domain/ai_provider_preset.dart';
import '../domain/language_model_provider.dart';
import '../domain/model_http_transport.dart';
import '../domain/model_request.dart';
import 'openai_compatible_language_model_provider.dart';

final class GeminiLanguageModelProvider implements LanguageModelProvider {
  const GeminiLanguageModelProvider({
    required this.id,
    required this.displayName,
    required this.modelName,
    required this.baseUrl,
    this.apiKey,
    this.transport = const MissingModelHttpTransport(),
  });

  factory GeminiLanguageModelProvider.fromConfig(
    AIProviderConfig config, {
    String? apiKey,
    ModelHttpTransport transport = const MissingModelHttpTransport(),
  }) {
    final preset = AIProviderPreset.forKind(AIProviderKind.gemini);
    return GeminiLanguageModelProvider(
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
        maxContextTokens: 1000000,
      );

  @override
  Future<int> estimateTokens(String text) async => (text.length / 4).ceil();

  @override
  Future<ModelResponse> generateText(ModelRequest request) async {
    final response = await transport.postJson(
      uri: _generateContentUri(),
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
    final candidates = json['candidates'];
    if (candidates is! List || candidates.isEmpty) {
      throw const DomainFailure('Gemini response did not include candidates.');
    }

    final firstCandidate = candidates.first;
    final content = firstCandidate is Map ? firstCandidate['content'] : null;
    final parts = content is Map ? content['parts'] : null;
    if (parts is! List) {
      throw const DomainFailure('Gemini response did not include text parts.');
    }

    final text = parts
        .whereType<Map>()
        .map((part) => part['text'])
        .whereType<String>()
        .join('\n')
        .trim();
    if (text.isEmpty) {
      throw const DomainFailure('Gemini response did not include text content.');
    }

    final usage = json['usageMetadata'];
    return ModelResponse(
      text: text,
      estimatedInputTokens: usage is Map ? _asInt(usage['promptTokenCount']) : null,
      estimatedOutputTokens: usage is Map ? _asInt(usage['candidatesTokenCount']) : null,
    );
  }

  Uri _generateContentUri() {
    final normalized = baseUrl.path.endsWith('/')
        ? baseUrl.path.substring(0, baseUrl.path.length - 1)
        : baseUrl.path;
    final path = '$normalized/models/$modelName:generateContent';
    final token = apiKey?.trim();
    return baseUrl.replace(
      path: path,
      queryParameters: {
        if (token != null && token.isNotEmpty) 'key': token,
      },
    );
  }

  JsonMap _requestBody(ModelRequest request) {
    return {
      'systemInstruction': {
        'parts': [
          {'text': 'You are an analysis assistant for authors. Do not write manuscript prose.'},
        ],
      },
      'contents': [
        {
          'role': 'user',
          'parts': [
            {'text': request.prompt},
          ],
        },
      ],
      'generationConfig': {
        'temperature': request.parameters.temperature,
        'topP': request.parameters.topP,
        'maxOutputTokens': request.parameters.maxTokens,
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
