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
    if (prompt.contains('konsistenz') ||
        prompt.contains('continuity') ||
        prompt.contains('consistency')) {
      return german
          ? 'Demo-Antwort des lokalen Mock-Providers:\n'
              '1. Pruefe, ob Ziel, Konflikt und Ausgang dieselbe Kausalitaetskette bilden.\n'
              '2. Markiere Begriffe, Fakten oder Beziehungen, die spaeter wieder auftauchen muessen.\n'
              '3. Notiere eine offene Anschlussfrage fuer die naechste Szene.'
          : 'Demo response from the local mock provider:\n'
              '1. Check whether goal, conflict, and outcome form one causal chain.\n'
              '2. Mark facts, terms, or relationships that must recur later.\n'
              '3. Note one continuity question for the next scene.';
    }
    if (prompt.contains('timeline') ||
        prompt.contains('zeitliche abfolge') ||
        prompt.contains('chronology')) {
      return german
          ? 'Demo-Antwort des lokalen Mock-Providers:\n'
              '1. Klaere, wann die Szene relativ zur vorherigen Szene beginnt.\n'
              '2. Pruefe, ob Dauer, Ortswechsel und Erholungszeit plausibel sind.\n'
              '3. Gib der Szene ein fixes Datum oder ein relatives Zeitfenster.'
          : 'Demo response from the local mock provider:\n'
              '1. Clarify when the scene starts relative to the previous scene.\n'
              '2. Check whether duration, travel, and recovery time are plausible.\n'
              '3. Give the scene a fixed date or a relative time window.';
    }
    if (prompt.contains('plot-luecken') ||
        prompt.contains('plot gaps') ||
        prompt.contains('kausalitaet')) {
      return german
          ? 'Demo-Antwort des lokalen Mock-Providers:\n'
              '1. Suche nach einer Entscheidung, die noch nicht motiviert ist.\n'
              '2. Benenne eine Information, die die Szene voraussetzt, aber nicht zeigt.\n'
              '3. Formuliere eine kleine Ursache, die den Ausgang zwingender macht.'
          : 'Demo response from the local mock provider:\n'
              '1. Look for a decision that is not motivated yet.\n'
              '2. Name one piece of information the scene assumes but does not show.\n'
              '3. Add one small cause that makes the outcome feel inevitable.';
    }
    if (prompt.contains('autorenfragen') ||
        prompt.contains('author questions')) {
      return german
          ? 'Demo-Antwort des lokalen Mock-Providers:\n'
              '1. Welche Entscheidung darf die Figur am Ende nicht mehr vermeiden?\n'
              '2. Was kostet es, wenn sie ihr Ziel erreicht?\n'
              '3. Welche Information sollte der Leser nach dieser Szene neu bewerten?'
          : 'Demo response from the local mock provider:\n'
              '1. Which decision can the character no longer avoid at the end?\n'
              '2. What does it cost if they reach their goal?\n'
              '3. Which information should the reader reassess after this scene?';
    }
    if (prompt.contains('stilanalyse') ||
        prompt.contains('style effect') ||
        prompt.contains('rhythm')) {
      return german
          ? 'Demo-Antwort des lokalen Mock-Providers:\n'
              '1. Pruefe, ob Satzlaenge und Rhythmus zum Druck der Szene passen.\n'
              '2. Markiere eine Stelle, an der Ton oder Perspektive kippen darf.\n'
              '3. Achte darauf, dass Stilhinweise keine Autorensaetze ersetzen.'
          : 'Demo response from the local mock provider:\n'
              '1. Check whether sentence length and rhythm match the scene pressure.\n'
              '2. Mark one place where tone or perspective may shift.\n'
              '3. Keep style notes separate from author prose.';
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
