part of '../main.dart';

/// Centralizes AI provider defaults, secret migration, and runtime creation.
///
/// The shell owns the editable settings state. This runtime turns persisted
/// settings into executable provider instances and keeps secret handling in one
/// place.
final class _AIProviderRuntime {
  const _AIProviderRuntime({
    required this.configRepository,
    required this.secretVault,
    required this.transport,
  });

  final AIProviderConfigRepository configRepository;
  final SecretVault secretVault;
  final HttpModelHttpTransport transport;

  AIProviderConfig defaultConfig() {
    final preset = AIProviderPreset.forKind(AIProviderKind.mock);
    return AIProviderConfig(
      id: 'default',
      kind: preset.kind,
      displayName: preset.displayName,
      modelName: preset.modelName,
      baseUrl: preset.baseUrl,
    );
  }

  Future<AIProviderConfig?> normalizeConfigSecrets(
    AIProviderConfig? config,
  ) async {
    final apiKeyRef = config?.encryptedApiKeyRef;
    if (config == null || apiKeyRef == null || isSecretVaultRef(apiKeyRef)) {
      return config;
    }

    final ref = providerApiKeyRef(config.id);
    await secretVault.write(ref: ref, secret: apiKeyRef);
    final migrated = config.copyWith(encryptedApiKeyRef: ref);
    await configRepository.save(migrated);
    return migrated;
  }

  String providerApiKeyRef(String providerId) {
    return 'secret://ai-provider/$providerId/api-key';
  }

  bool isSecretVaultRef(String value) => value.startsWith('secret://');

  String normalizeApiKey(String value) {
    var normalized = value.trim();
    while (normalized.toLowerCase().startsWith('bearer ')) {
      normalized = normalized.substring('bearer '.length).trim();
    }
    return normalized;
  }

  Future<LanguageModelProvider> createProvider(
    AIProviderConfig? activeConfig,
  ) async {
    final config = activeConfig ?? defaultConfig();
    if (!config.enabled) {
      throw const DomainFailure('AI provider is disabled in settings.');
    }

    switch (config.kind) {
      case AIProviderKind.mock:
        return const MockLanguageModelProvider();
      case AIProviderKind.openAICompatible:
      case AIProviderKind.openRouter:
        final apiKey = await readApiKey(config, mustExist: true);
        return OpenAICompatibleLanguageModelProvider.fromConfig(
          config,
          apiKey: apiKey,
          transport: transport,
        );
      case AIProviderKind.anthropic:
        final apiKey = await readApiKey(config, mustExist: true);
        return AnthropicLanguageModelProvider.fromConfig(
          config,
          apiKey: apiKey,
          transport: transport,
        );
      case AIProviderKind.gemini:
        final apiKey = await readApiKey(config, mustExist: true);
        return GeminiLanguageModelProvider.fromConfig(
          config,
          apiKey: apiKey,
          transport: transport,
        );
      case AIProviderKind.ollama:
        return OllamaLanguageModelProvider.fromConfig(
          config,
          transport: transport,
        );
    }
  }

  Future<String?> readApiKey(
    AIProviderConfig config, {
    bool mustExist = false,
  }) async {
    final ref = config.encryptedApiKeyRef;
    if (ref == null) {
      if (mustExist) {
        throw const DomainFailure('AI_API_KEY_MISSING');
      }
      return null;
    }

    final secret = await secretVault.read(ref);
    if (secret == null || secret.isEmpty) {
      throw const DomainFailure('AI_API_KEY_MISSING');
    }

    final normalizedSecret = normalizeApiKey(secret);
    if (normalizedSecret.isEmpty) {
      throw const DomainFailure('AI_API_KEY_MISSING');
    }
    return normalizedSecret;
  }
}
