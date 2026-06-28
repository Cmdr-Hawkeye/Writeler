import 'dart:convert';

import '../../../core/domain/domain_failure.dart';
import '../../../core/domain/json_map.dart';
import '../../settings/domain/ai_provider_config.dart';
import '../domain/language_model_provider.dart';
import '../domain/model_http_transport.dart';
import '../domain/model_request.dart';
import 'structured_response_parser.dart';

final class OpenAICompatibleLanguageModelProvider
    implements LanguageModelProvider {
  const OpenAICompatibleLanguageModelProvider({
    required this.id,
    required this.displayName,
    required this.modelName,
    required this.baseUrl,
    this.apiKey,
    this.defaultHeaders = const {},
    this.mirrorApiKeyInXApiKeyHeader = false,
    this.transport = const MissingModelHttpTransport(),
  });

  factory OpenAICompatibleLanguageModelProvider.fromConfig(
    AIProviderConfig config, {
    String? apiKey,
    ModelHttpTransport transport = const MissingModelHttpTransport(),
  }) {
    final baseUrl = config.baseUrl?.trim().isEmpty ?? true
        ? 'https://api.openai.com/v1'
        : config.baseUrl!.trim();
    return OpenAICompatibleLanguageModelProvider(
      id: config.id,
      displayName: config.displayName,
      modelName: config.modelName,
      baseUrl: Uri.parse(baseUrl),
      apiKey: apiKey,
      defaultHeaders: _defaultHeadersFor(config.kind),
      mirrorApiKeyInXApiKeyHeader: config.kind == AIProviderKind.openRouter,
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
  final Map<String, String> defaultHeaders;
  final bool mirrorApiKeyInXApiKeyHeader;
  final ModelHttpTransport transport;

  @override
  ProviderCapabilities get capabilities => const ProviderCapabilities(
        supportsText: true,
        supportsStructuredOutput: true,
        supportsEmbeddings: false,
        maxContextTokens: 128000,
      );

  @override
  Future<int> estimateTokens(String text) async {
    return (text.length / 4).ceil();
  }

  @override
  Future<ModelResponse> generateText(ModelRequest request) async {
    final response = await transport.postJson(
      uri: _chatCompletionsUri(),
      headers: _headers(),
      body: _requestBody(request),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw DomainFailure(
        'Provider "$displayName" returned HTTP ${response.statusCode}: ${response.body}',
      );
    }

    final json = _decodeObject(response.body);
    final choices = json['choices'];
    if (choices is! List || choices.isEmpty) {
      throw const DomainFailure(
          'Provider response did not include any choices.');
    }

    final firstChoice = choices.first;
    if (firstChoice is! Map) {
      throw const DomainFailure('Provider choice has an unsupported shape.');
    }

    final message = firstChoice['message'];
    final content = message is Map ? message['content'] : firstChoice['text'];
    if (content is! String || content.trim().isEmpty) {
      throw const DomainFailure(
          'Provider response did not include text content.');
    }

    final usage = json['usage'];
    return ModelResponse(
      text: content.trim(),
      structured: extractStructuredJson(content.trim()),
      estimatedInputTokens:
          usage is Map ? _asInt(usage['prompt_tokens']) : null,
      estimatedOutputTokens:
          usage is Map ? _asInt(usage['completion_tokens']) : null,
    );
  }

  Uri _chatCompletionsUri() {
    final localOpenRouterProxy = _localOpenRouterProxyUri();
    if (localOpenRouterProxy != null) return localOpenRouterProxy;

    final normalized = baseUrl.path.endsWith('/')
        ? baseUrl.path.substring(0, baseUrl.path.length - 1)
        : baseUrl.path;
    final alreadyChatCompletions = normalized.endsWith('/chat/completions');
    return baseUrl.replace(
      path:
          alreadyChatCompletions ? normalized : '$normalized/chat/completions',
    );
  }

  Uri? _localOpenRouterProxyUri() {
    if (!mirrorApiKeyInXApiKeyHeader) return null;
    final current = Uri.base;
    final isLocalWeb =
        (current.scheme == 'http' || current.scheme == 'https') &&
            (current.host == '127.0.0.1' || current.host == 'localhost');
    if (!isLocalWeb) return null;
    return current.replace(
      path: '/.writeler-ai/openrouter/chat/completions',
      query: '',
      fragment: '',
    );
  }

  Map<String, String> _headers() {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      ...defaultHeaders,
    };
    final token = _normalizedApiKey();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
      if (mirrorApiKeyInXApiKeyHeader) {
        headers['X-Api-Key'] = token;
      }
    }
    return headers;
  }

  String? _normalizedApiKey() {
    final rawToken = apiKey?.trim();
    if (rawToken == null || rawToken.isEmpty) return null;
    var token = rawToken;
    while (token.toLowerCase().startsWith('bearer ')) {
      token = token.substring('bearer '.length).trim();
    }
    return token.isEmpty ? null : token;
  }

  static Map<String, String> _defaultHeadersFor(AIProviderKind kind) {
    return switch (kind) {
      AIProviderKind.openRouter => const {
          'HTTP-Referer': 'https://github.com/Cmdr-Hawkeye/Writeler',
          'X-OpenRouter-Title': 'Writeler',
        },
      _ => const {},
    };
  }

  JsonMap _requestBody(ModelRequest request) {
    return {
      'model': modelName,
      'messages': [
        {
          'role': 'system',
          'content':
              'You are an analysis assistant for authors. Do not write manuscript prose.',
        },
        {
          'role': 'user',
          'content': request.prompt,
        },
      ],
      'temperature': request.parameters.temperature,
      'top_p': request.parameters.topP,
      'max_tokens': request.parameters.maxTokens,
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

final class MissingModelHttpTransport implements ModelHttpTransport {
  const MissingModelHttpTransport();

  @override
  Future<ModelHttpResponse> postJson({
    required Uri uri,
    required Map<String, String> headers,
    required JsonMap body,
  }) {
    throw const DomainFailure(
      'No HTTP transport is configured for this provider yet. Use MockProvider or wire a platform transport.',
    );
  }
}
