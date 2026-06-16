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
    final prompt = request.prompt.toLowerCase();
    final german = prompt.contains('antworte auf deutsch') ||
        prompt.contains('szenentitel:') ||
        prompt.contains('aufgabe:');
    final text = _mockText(prompt: prompt, german: german);
    return ModelResponse(
      text: text,
      structured: {
        'questions': [
          german
              ? 'Was will die Perspektivfigur vor Beginn der Szene?'
              : 'What does the point-of-view character want before the scene begins?',
          german
              ? 'Was veraendert sich bis zum Ende der Szene?'
              : 'What changes by the end of the scene?',
        ],
      },
      estimatedInputTokens: await estimateTokens(request.prompt),
      estimatedOutputTokens: 32,
    );
  }

  String _mockText({
    required String prompt,
    required bool german,
  }) {
    if (prompt.contains('sceneideas') || prompt.contains('szenenideen')) {
      return german
          ? 'Demo-Antwort des lokalen Mock-Providers:\n'
              '1. Variante: Erhoehe den Druck, indem eine konkrete Frist sichtbar wird.\n'
              '2. Variante: Lass eine Figur ein widerspruechliches Ziel verfolgen.\n'
              '3. Naechster Schritt: Entscheide, welche Information am Szenenende neu ist.'
          : 'Demo response from the local mock provider:\n'
              '1. Variant: Raise pressure by making a concrete deadline visible.\n'
              '2. Variant: Let one character pursue a conflicting goal.\n'
              '3. Next step: Decide what information is new at the scene ending.';
    }
    if (prompt.contains('scenegoalconflictoutcome') ||
        prompt.contains('ziel, konflikt und ausgang')) {
      return german
          ? 'Demo-Antwort des lokalen Mock-Providers:\n'
              '1. Ziel: Formuliere, was die Figur in dieser Szene aktiv erreichen will.\n'
              '2. Konflikt: Benenne die Gegenkraft, die jetzt und nicht spaeter wirkt.\n'
              '3. Ausgang: Halte fest, welche Lage sich nach der Szene unumkehrbar veraendert.'
          : 'Demo response from the local mock provider:\n'
              '1. Goal: Name what the character actively wants in this scene.\n'
              '2. Conflict: Name the opposing force acting now, not later.\n'
              '3. Outcome: Capture what has irreversibly changed after the scene.';
    }
    return german
        ? 'Demo-Antwort des lokalen Mock-Providers:\n'
            '1. Der echte Provider ist offenbar noch nicht aktiv.\n'
            '2. Speichere unter Einstellungen den Provider-Typ, Modellnamen, Base-URL und API-Key.\n'
            '3. Danach sollte diese Demo-Antwort durch eine echte Modellantwort ersetzt werden.'
        : 'Demo response from the local mock provider:\n'
            '1. The real provider does not appear to be active yet.\n'
            '2. Save provider type, model name, base URL, and API key in Settings.\n'
            '3. After that, this demo response should be replaced by a real model response.';
  }
}
