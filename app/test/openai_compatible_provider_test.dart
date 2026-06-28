import 'package:test/test.dart';
import 'package:writeler/core/domain/domain_failure.dart';
import 'package:writeler/core/domain/json_map.dart';
import 'package:writeler/features/ai_harness/domain/model_http_transport.dart';
import 'package:writeler/features/ai_harness/domain/model_request.dart';
import 'package:writeler/features/ai_harness/infrastructure/anthropic_language_model_provider.dart';
import 'package:writeler/features/ai_harness/infrastructure/gemini_language_model_provider.dart';
import 'package:writeler/features/ai_harness/infrastructure/ollama_language_model_provider.dart';
import 'package:writeler/features/ai_harness/infrastructure/openai_compatible_language_model_provider.dart';
import 'package:writeler/features/settings/domain/ai_provider_config.dart';
import 'package:writeler/features/settings/domain/ai_provider_preset.dart';

void main() {
  test('provider presets include base URLs and economical example models', () {
    expect(
      AIProviderPreset.forKind(AIProviderKind.openAICompatible).modelName,
      'gpt-5.4-nano',
    );
    expect(
      AIProviderPreset.forKind(AIProviderKind.anthropic).modelName,
      'claude-haiku-4-5-20251001',
    );
    expect(
      AIProviderPreset.forKind(AIProviderKind.gemini).baseUrl,
      'https://generativelanguage.googleapis.com/v1beta',
    );
    expect(
      AIProviderPreset.forKind(AIProviderKind.openRouter).baseUrl,
      'https://openrouter.ai/api/v1',
    );
    expect(
      AIProviderPreset.forKind(AIProviderKind.ollama).modelName,
      'llama3.2:3b',
    );
  });

  test(
      'OpenAI-compatible provider posts chat completion requests and parses text',
      () async {
    final transport = _FakeTransport(
      response: const ModelHttpResponse(
        statusCode: 200,
        body: '''
{
  "choices": [
    {
      "message": {
        "content": "Clarify the character goal before the midpoint."
      }
    }
  ],
  "usage": {
    "prompt_tokens": 18,
    "completion_tokens": 9
  }
}
''',
      ),
    );
    final provider = OpenAICompatibleLanguageModelProvider(
      id: 'default',
      displayName: 'OpenAI Compatible',
      modelName: 'gpt-test',
      baseUrl: Uri.parse('https://example.test/v1'),
      apiKey: 'Bearer test-key',
      transport: transport,
    );

    final response = await provider.generateText(
      const ModelRequest(
        prompt: 'Review the scene structure.',
        context: {'sceneId': 'scene-1'},
        parameters: ModelParameters(maxTokens: 600, temperature: 0.2),
      ),
    );

    expect(response.text, 'Clarify the character goal before the midpoint.');
    expect(response.estimatedInputTokens, 18);
    expect(response.estimatedOutputTokens, 9);
    expect(
        transport.uri.toString(), 'https://example.test/v1/chat/completions');
    expect(transport.headers['Authorization'], 'Bearer test-key');
    expect(transport.headers.containsKey('authorization'), isFalse);
    expect(transport.headers['Content-Type'], 'application/json');
    expect(transport.headers['Accept'], 'application/json');
    expect(transport.body['model'], 'gpt-test');
    expect(transport.body['max_tokens'], 600);
    expect(transport.body['temperature'], 0.2);
    expect(transport.body['metadata'], containsPair('sceneId', 'scene-1'));
  });

  test('OpenAI-compatible provider extracts fenced structured JSON', () async {
    final provider = OpenAICompatibleLanguageModelProvider(
      id: 'default',
      displayName: 'OpenAI Compatible',
      modelName: 'gpt-test',
      baseUrl: Uri.parse('https://example.test/v1'),
      transport: _FakeTransport(
        response: const ModelHttpResponse(
          statusCode: 200,
          body: '''
{
  "choices": [
    {
      "message": {
        "content": "```json\\n{\\"scenePatch\\":{\\"goal\\":\\"Reach the relay.\\"}}\\n```\\n1. Keep the pressure visible."
      }
    }
  ]
}
''',
        ),
      ),
    );

    final response = await provider.generateText(
      const ModelRequest(
        prompt: 'Review the scene structure.',
        context: {},
        parameters: ModelParameters(),
      ),
    );

    expect(
      response.structured?['scenePatch'],
      containsPair('goal', 'Reach the relay.'),
    );
  });

  test('OpenAI-compatible provider extracts structured JSON from prose',
      () async {
    final provider = OpenAICompatibleLanguageModelProvider(
      id: 'default',
      displayName: 'OpenAI Compatible',
      modelName: 'gpt-test',
      baseUrl: Uri.parse('https://example.test/v1'),
      transport: _FakeTransport(
        response: const ModelHttpResponse(
          statusCode: 200,
          body: '''
{
  "choices": [
    {
      "message": {
        "content": "Hier ist die Starthilfe:\\n{\\"worldStarter\\":{\\"personas\\":[{\\"name\\":\\"Mara\\",\\"summary\\":\\"Archivarin\\"}],\\"locations\\":[{\\"name\\":\\"Archiv\\"}]}}\\nKurzer Hinweis: Bitte prüfen."
      }
    }
  ]
}
''',
        ),
      ),
    );

    final response = await provider.generateText(
      const ModelRequest(
        prompt: 'Kontext-Starthilfe',
        context: {},
        parameters: ModelParameters(),
      ),
    );

    final worldStarter = response.structured?['worldStarter'] as Map?;
    final personas = worldStarter?['personas'] as List?;
    expect(personas?.single, containsPair('name', 'Mara'));
  });

  test('OpenRouter provider includes attribution headers', () async {
    final transport = _FakeTransport(
      response: const ModelHttpResponse(
        statusCode: 200,
        body: '''
{
  "choices": [
    {
      "message": {
        "content": "OpenRouter is connected."
      }
    }
  ]
}
''',
      ),
    );
    final preset = AIProviderPreset.forKind(AIProviderKind.openRouter);
    final provider = OpenAICompatibleLanguageModelProvider.fromConfig(
      AIProviderConfig(
        id: 'openrouter',
        kind: AIProviderKind.openRouter,
        displayName: preset.displayName,
        modelName: preset.modelName,
        baseUrl: preset.baseUrl,
      ),
      apiKey: 'Bearer test-key',
      transport: transport,
    );

    await provider.generateText(
      const ModelRequest(
        prompt: 'Check connection.',
        context: {},
        parameters: ModelParameters(maxTokens: 16),
      ),
    );

    expect(
      transport.uri.toString(),
      'https://openrouter.ai/api/v1/chat/completions',
    );
    expect(
      transport.headers['HTTP-Referer'],
      'https://github.com/Cmdr-Hawkeye/Writeler',
    );
    expect(transport.headers['X-OpenRouter-Title'], 'Writeler');
    expect(transport.headers['Authorization'], 'Bearer test-key');
    expect(transport.headers['X-Api-Key'], 'test-key');
    expect(transport.headers.containsKey('authorization'), isFalse);
    expect(transport.body['model'], 'google/gemini-2.5-flash-lite');
  });

  test('OpenAI-compatible provider reports HTTP failures', () async {
    final provider = OpenAICompatibleLanguageModelProvider(
      id: 'default',
      displayName: 'OpenAI Compatible',
      modelName: 'gpt-test',
      baseUrl: Uri.parse('https://example.test/v1'),
      transport: _FakeTransport(
        response:
            const ModelHttpResponse(statusCode: 429, body: 'rate limited'),
      ),
    );

    expect(
      () => provider.generateText(
        const ModelRequest(
          prompt: 'Review the scene structure.',
          context: {},
          parameters: ModelParameters(),
        ),
      ),
      throwsA(isA<DomainFailure>()),
    );
  });

  test('Anthropic provider posts messages requests and parses text blocks',
      () async {
    final transport = _FakeTransport(
      response: const ModelHttpResponse(
        statusCode: 200,
        body: '''
{
  "content": [
    {"type": "text", "text": "Tighten the character decision."}
  ],
  "usage": {
    "input_tokens": 22,
    "output_tokens": 7
  }
}
''',
      ),
    );
    final provider = AnthropicLanguageModelProvider(
      id: 'default',
      displayName: 'Anthropic Claude',
      modelName: 'claude-haiku-test',
      baseUrl: Uri.parse('https://api.anthropic.com'),
      apiKey: 'test-key',
      transport: transport,
    );

    final response = await provider.generateText(
      const ModelRequest(
        prompt: 'Review the scene structure.',
        context: {},
        parameters: ModelParameters(),
      ),
    );

    expect(response.text, 'Tighten the character decision.');
    expect(response.estimatedInputTokens, 22);
    expect(response.estimatedOutputTokens, 7);
    expect(transport.uri.toString(), 'https://api.anthropic.com/v1/messages');
    expect(transport.headers['x-api-key'], 'test-key');
    expect(transport.headers['anthropic-version'], '2023-06-01');
    expect(transport.body['model'], 'claude-haiku-test');
  });

  test('Gemini provider posts generateContent requests and parses text parts',
      () async {
    final transport = _FakeTransport(
      response: const ModelHttpResponse(
        statusCode: 200,
        body: '''
{
  "candidates": [
    {
      "content": {
        "parts": [
          {"text": "Make the conflict more visible."}
        ]
      }
    }
  ],
  "usageMetadata": {
    "promptTokenCount": 12,
    "candidatesTokenCount": 6
  }
}
''',
      ),
    );
    final provider = GeminiLanguageModelProvider(
      id: 'default',
      displayName: 'Google Gemini',
      modelName: 'gemini-test',
      baseUrl: Uri.parse('https://generativelanguage.googleapis.com/v1beta'),
      apiKey: 'test-key',
      transport: transport,
    );

    final response = await provider.generateText(
      const ModelRequest(
        prompt: 'Review the scene structure.',
        context: {},
        parameters: ModelParameters(maxTokens: 300),
      ),
    );

    expect(response.text, 'Make the conflict more visible.');
    expect(response.estimatedInputTokens, 12);
    expect(response.estimatedOutputTokens, 6);
    expect(
      transport.uri.toString(),
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-test:generateContent?key=test-key',
    );
    final generationConfig = transport.body['generationConfig'] as JsonMap;
    expect(generationConfig['maxOutputTokens'], 300);
  });

  test('Ollama provider posts local chat requests and parses message content',
      () async {
    final transport = _FakeTransport(
      response: const ModelHttpResponse(
        statusCode: 200,
        body: '''
{
  "message": {"role": "assistant", "content": "Ask what changes by the scene end."},
  "prompt_eval_count": 10,
  "eval_count": 8
}
''',
      ),
    );
    final provider = OllamaLanguageModelProvider(
      id: 'default',
      displayName: 'Ollama Local',
      modelName: 'llama3.2:3b',
      baseUrl: Uri.parse('http://localhost:11434'),
      transport: transport,
    );

    final response = await provider.generateText(
      const ModelRequest(
        prompt: 'Review the scene structure.',
        context: {},
        parameters: ModelParameters(),
      ),
    );

    expect(response.text, 'Ask what changes by the scene end.');
    expect(response.estimatedInputTokens, 10);
    expect(response.estimatedOutputTokens, 8);
    expect(transport.uri.toString(), 'http://localhost:11434/api/chat');
    expect(transport.body['model'], 'llama3.2:3b');
    expect(transport.body['stream'], isFalse);
  });
}

final class _FakeTransport implements ModelHttpTransport {
  _FakeTransport({required this.response});

  final ModelHttpResponse response;
  late Uri uri;
  late Map<String, String> headers;
  late JsonMap body;

  @override
  Future<ModelHttpResponse> postJson({
    required Uri uri,
    required Map<String, String> headers,
    required JsonMap body,
  }) async {
    this.uri = uri;
    this.headers = headers;
    this.body = body;
    return response;
  }
}
