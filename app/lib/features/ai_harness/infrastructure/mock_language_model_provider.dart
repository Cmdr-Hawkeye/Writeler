import '../domain/language_model_provider.dart';
import '../domain/model_request.dart';

final class MockLanguageModelProvider implements LanguageModelProvider {
  const MockLanguageModelProvider();

  @override
  ProviderCapabilities get capabilities => const ProviderCapabilities(
        supportsText: true,
        supportsStructuredOutput: true,
        supportsEmbeddings: false,
        maxContextTokens: 16000,
      );

  @override
  String get displayName => 'MockProvider';

  @override
  String get id => 'mock';

  @override
  Future<int> estimateTokens(String text) async {
    return (text.length / 4).ceil();
  }

  @override
  Future<ModelResponse> generateText(ModelRequest request) async {
    return ModelResponse(
      text: 'Suggestion: clarify the scene goal, pressure point, and consequence. '
          'Keep all final manuscript wording under author control.',
      structured: {
        'questions': [
          'What does the point-of-view character want before the scene begins?',
          'What changes by the end of the scene?',
        ],
      },
      estimatedInputTokens: await estimateTokens(request.prompt),
      estimatedOutputTokens: 32,
    );
  }
}
