import 'model_request.dart';

final class ProviderCapabilities {
  const ProviderCapabilities({
    required this.supportsText,
    required this.supportsStructuredOutput,
    required this.supportsEmbeddings,
    required this.maxContextTokens,
  });

  final bool supportsText;
  final bool supportsStructuredOutput;
  final bool supportsEmbeddings;
  final int maxContextTokens;
}

abstract interface class LanguageModelProvider {
  String get id;

  String get displayName;

  ProviderCapabilities get capabilities;

  Future<ModelResponse> generateText(ModelRequest request);

  Future<int> estimateTokens(String text);
}
