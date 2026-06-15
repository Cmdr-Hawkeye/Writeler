import 'ai_provider_config.dart';

final class AIProviderPreset {
  const AIProviderPreset({
    required this.kind,
    required this.displayName,
    required this.modelName,
    this.baseUrl,
  });

  final AIProviderKind kind;
  final String displayName;
  final String modelName;
  final String? baseUrl;

  static AIProviderPreset forKind(AIProviderKind kind) {
    return switch (kind) {
      AIProviderKind.openAICompatible => const AIProviderPreset(
          kind: AIProviderKind.openAICompatible,
          displayName: 'OpenAI Compatible',
          modelName: 'gpt-5.4-nano',
          baseUrl: 'https://api.openai.com/v1',
        ),
      AIProviderKind.anthropic => const AIProviderPreset(
          kind: AIProviderKind.anthropic,
          displayName: 'Anthropic Claude',
          modelName: 'claude-haiku-4-5-20251001',
          baseUrl: 'https://api.anthropic.com',
        ),
      AIProviderKind.gemini => const AIProviderPreset(
          kind: AIProviderKind.gemini,
          displayName: 'Google Gemini',
          modelName: 'gemini-2.5-flash-lite',
          baseUrl: 'https://generativelanguage.googleapis.com/v1beta',
        ),
      AIProviderKind.openRouter => const AIProviderPreset(
          kind: AIProviderKind.openRouter,
          displayName: 'OpenRouter',
          modelName: 'google/gemini-2.5-flash-lite',
          baseUrl: 'https://openrouter.ai/api/v1',
        ),
      AIProviderKind.ollama => const AIProviderPreset(
          kind: AIProviderKind.ollama,
          displayName: 'Ollama Local',
          modelName: 'llama3.2:3b',
          baseUrl: 'http://localhost:11434',
        ),
      AIProviderKind.mock => const AIProviderPreset(
          kind: AIProviderKind.mock,
          displayName: 'MockProvider',
          modelName: 'mock-structure-v1',
        ),
    };
  }
}
