import 'dart:math' as math;

import '../../structure/domain/chapter.dart';
import '../../structure/domain/scene.dart';
import '../domain/style_analysis_result.dart';

final class StyleAnalyzer {
  const StyleAnalyzer();

  StyleAnalysisResult analyzeProject({
    required List<Chapter> chapters,
    required List<Scene> scenes,
    required String languageCode,
  }) {
    final language = _StyleLanguage.fromCode(languageCode);
    final orderedChapters = [...chapters]
      ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
    final orderedScenes = [...scenes]..sort((a, b) {
        final chapterCompare = (a.chapterId ?? '').compareTo(b.chapterId ?? '');
        if (chapterCompare != 0) return chapterCompare;
        return a.orderIndex.compareTo(b.orderIndex);
      });
    final sceneAnalyses = [
      for (final scene in orderedScenes)
        _analyzeText(
          id: scene.id,
          title: scene.title,
          scope: StyleScope.scene,
          text: scene.manuscriptText,
          language: language,
        ),
    ];
    final chapterAnalyses = [
      for (final chapter in orderedChapters)
        _analyzeText(
          id: chapter.id,
          title: chapter.title,
          scope: StyleScope.chapter,
          text: orderedScenes
              .where((scene) => scene.chapterId == chapter.id)
              .map((scene) => scene.manuscriptText)
              .join('\n\n'),
          language: language,
        ),
    ];
    final unassignedScenes =
        orderedScenes.where((scene) => scene.chapterId == null).toList();
    if (unassignedScenes.isNotEmpty || chapterAnalyses.isEmpty) {
      chapterAnalyses.add(
        _analyzeText(
          id: 'unassigned',
          title: language.unassignedChapterTitle,
          scope: StyleScope.chapter,
          text: unassignedScenes
              .map((scene) => scene.manuscriptText)
              .join('\n\n'),
          language: language,
        ),
      );
    }

    return StyleAnalysisResult(
      project: _analyzeText(
        id: 'project',
        title: language.projectTitle,
        scope: StyleScope.project,
        text: orderedScenes.map((scene) => scene.manuscriptText).join('\n\n'),
        language: language,
      ),
      chapters: chapterAnalyses,
      scenes: [
        for (final analysis in sceneAnalyses) analysis,
      ],
    );
  }

  StyleScopeAnalysis _analyzeText({
    required String id,
    required String title,
    required StyleScope scope,
    required String text,
    required _StyleLanguage language,
  }) {
    final sentences = _sentences(text);
    final words = _words(text);
    final wordCount = words.length;
    final sentenceLengths = [
      for (final sentence in sentences) _words(sentence).length,
    ];
    final longSentenceThreshold = language.longSentenceThreshold;
    final longSentences = [
      for (var i = 0; i < sentences.length; i++)
        if (sentenceLengths[i] >= longSentenceThreshold) sentences[i],
    ];
    final fillerMatches = _matchesFromWordSet(words, language.fillerWords);
    final repeatedWords = _repeatedWords(words, language);
    final adjectiveClusters = _adjectiveClusters(words, language);
    final passiveMatches = _passiveMatches(sentences, language);
    final modalMatches = _matchesFromWordSet(words, language.modalVerbs);
    final dialogueShare = _dialogueShare(text);
    final averageSentenceLength = sentenceLengths.isEmpty
        ? 0.0
        : sentenceLengths.reduce((a, b) => a + b) / sentenceLengths.length;
    final readabilityScore = _readabilityScore(
      wordCount: wordCount,
      sentenceCount: sentences.length,
      syllableCount: _syllableCount(words, language),
      averageSentenceLength: averageSentenceLength,
      language: language,
    );

    final issues = <StyleIssue>[
      if (fillerMatches.isNotEmpty)
        StyleIssue(
          kind: StyleIssueKind.fillerWord,
          severity: fillerMatches.length >= math.max(4, wordCount / 80)
              ? StyleSeverity.warning
              : StyleSeverity.notice,
          label: language.fillerLabel,
          detail: language.fillerDetail,
          count: fillerMatches.length,
          examples: _topExamples(fillerMatches),
        ),
      if (repeatedWords.isNotEmpty)
        StyleIssue(
          kind: StyleIssueKind.repetition,
          severity: repeatedWords.length >= 4
              ? StyleSeverity.warning
              : StyleSeverity.notice,
          label: language.repetitionLabel,
          detail: language.repetitionDetail,
          count: repeatedWords.length,
          examples: repeatedWords.take(6).toList(),
        ),
      if (longSentences.isNotEmpty)
        StyleIssue(
          kind: StyleIssueKind.longSentence,
          severity: longSentences.length >= math.max(3, sentences.length / 4)
              ? StyleSeverity.warning
              : StyleSeverity.notice,
          label: language.longSentenceLabel,
          detail: language.longSentenceDetail,
          count: longSentences.length,
          examples: longSentences.take(3).map(_compactSentence).toList(),
        ),
      if (adjectiveClusters.isNotEmpty)
        StyleIssue(
          kind: StyleIssueKind.adjectiveCluster,
          severity: adjectiveClusters.length > 2
              ? StyleSeverity.warning
              : StyleSeverity.notice,
          label: language.adjectiveLabel,
          detail: language.adjectiveDetail,
          count: adjectiveClusters.length,
          examples: adjectiveClusters.take(5).toList(),
        ),
      if (passiveMatches.isNotEmpty)
        StyleIssue(
          kind: StyleIssueKind.passiveVoice,
          severity: passiveMatches.length >= math.max(3, sentences.length / 5)
              ? StyleSeverity.warning
              : StyleSeverity.notice,
          label: language.passiveLabel,
          detail: language.passiveDetail,
          count: passiveMatches.length,
          examples: passiveMatches.take(3).toList(),
        ),
      if (modalMatches.isNotEmpty)
        StyleIssue(
          kind: StyleIssueKind.modalVerb,
          severity: modalMatches.length >= math.max(5, wordCount / 90)
              ? StyleSeverity.warning
              : StyleSeverity.info,
          label: language.modalLabel,
          detail: language.modalDetail,
          count: modalMatches.length,
          examples: _topExamples(modalMatches),
        ),
    ];

    return StyleScopeAnalysis(
      id: id,
      title: title,
      scope: scope,
      wordCount: wordCount,
      sentenceCount: sentences.length,
      averageSentenceLength: averageSentenceLength,
      longSentenceCount: longSentences.length,
      dialogueShare: dialogueShare,
      readabilityScore: readabilityScore,
      fillerWordCount: fillerMatches.length,
      repetitionCount: repeatedWords.length,
      adjectiveClusterCount: adjectiveClusters.length,
      passiveVoiceCount: passiveMatches.length,
      modalVerbCount: modalMatches.length,
      issues: issues,
    );
  }
}

List<String> _sentences(String text) {
  final normalized = text.replaceAll(RegExp(r'\s+'), ' ').trim();
  if (normalized.isEmpty) return const [];
  final matches = RegExp(r'[^.!?]+[.!?]+|[^.!?]+$')
      .allMatches(normalized)
      .map((match) => match.group(0)!.trim())
      .where((sentence) => _words(sentence).isNotEmpty)
      .toList();
  return matches;
}

List<String> _words(String text) {
  return RegExp(r"[A-Za-zÀ-ÖØ-öø-ÿÄÖÜäöüß]+(?:['’-][A-Za-zÀ-ÖØ-öø-ÿÄÖÜäöüß]+)?")
      .allMatches(text)
      .map((match) => match.group(0)!.toLowerCase())
      .toList();
}

List<String> _matchesFromWordSet(List<String> words, Set<String> terms) {
  return [
    for (final word in words)
      if (terms.contains(word)) word,
  ];
}

List<String> _repeatedWords(List<String> words, _StyleLanguage language) {
  final counts = <String, int>{};
  for (final word in words) {
    if (word.length < 4 || language.stopWords.contains(word)) continue;
    counts[word] = (counts[word] ?? 0) + 1;
  }
  final threshold = math.max(3, (words.length / 140).ceil());
  final repeated = counts.entries
      .where((entry) => entry.value >= threshold)
      .map((entry) => '${entry.key} (${entry.value})')
      .toList();
  repeated.sort((a, b) {
    final aCount = int.parse(RegExp(r'\((\d+)\)').firstMatch(a)!.group(1)!);
    final bCount = int.parse(RegExp(r'\((\d+)\)').firstMatch(b)!.group(1)!);
    return bCount.compareTo(aCount);
  });
  return repeated;
}

List<String> _adjectiveClusters(List<String> words, _StyleLanguage language) {
  final clusters = <String>[];
  var current = <String>[];
  for (final word in words) {
    if (language.looksAdjective(word)) {
      current.add(word);
      continue;
    }
    if (current.length >= 3) clusters.add(current.join(' '));
    current = <String>[];
  }
  if (current.length >= 3) clusters.add(current.join(' '));
  return clusters;
}

List<String> _passiveMatches(List<String> sentences, _StyleLanguage language) {
  final matches = <String>[];
  for (final sentence in sentences) {
    final lower = sentence.toLowerCase();
    if (language.passivePattern.hasMatch(lower)) {
      matches.add(_compactSentence(sentence));
    }
  }
  return matches;
}

double _dialogueShare(String text) {
  final trimmed = text.trim();
  if (trimmed.isEmpty) return 0;
  final quoted = RegExp(r'["„“»«][^"„“»«]+["„“»«]')
      .allMatches(trimmed)
      .fold<int>(0, (sum, match) => sum + match.group(0)!.length);
  final dialogueLines = trimmed
      .split(RegExp(r'\r?\n'))
      .where((line) => RegExp(r'^\s*[-–—]').hasMatch(line))
      .fold<int>(0, (sum, line) => sum + line.trim().length);
  return ((quoted + dialogueLines) / trimmed.length).clamp(0, 1).toDouble();
}

double _readabilityScore({
  required int wordCount,
  required int sentenceCount,
  required int syllableCount,
  required double averageSentenceLength,
  required _StyleLanguage language,
}) {
  if (wordCount == 0 || sentenceCount == 0) return 0.0;
  if (language.code == 'de') {
    final score =
        180 - averageSentenceLength - (58.5 * (syllableCount / wordCount));
    return score.clamp(0, 100).toDouble();
  }
  final score = 206.835 -
      (1.015 * (wordCount / sentenceCount)) -
      (84.6 * (syllableCount / wordCount));
  return score.clamp(0, 100).toDouble();
}

int _syllableCount(List<String> words, _StyleLanguage language) {
  return words.fold<int>(0, (sum, word) => sum + language.syllables(word));
}

List<String> _topExamples(List<String> values) {
  final counts = <String, int>{};
  for (final value in values) {
    counts[value] = (counts[value] ?? 0) + 1;
  }
  final entries = counts.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  return [
    for (final entry in entries.take(6)) '${entry.key} (${entry.value})',
  ];
}

String _compactSentence(String sentence) {
  final compact = sentence.replaceAll(RegExp(r'\s+'), ' ').trim();
  if (compact.length <= 130) return compact;
  return '${compact.substring(0, 127)}...';
}

final class _StyleLanguage {
  const _StyleLanguage({
    required this.code,
    required this.projectTitle,
    required this.unassignedChapterTitle,
    required this.longSentenceThreshold,
    required this.fillerWords,
    required this.modalVerbs,
    required this.stopWords,
    required this.passivePattern,
    required this.fillerLabel,
    required this.fillerDetail,
    required this.repetitionLabel,
    required this.repetitionDetail,
    required this.longSentenceLabel,
    required this.longSentenceDetail,
    required this.adjectiveLabel,
    required this.adjectiveDetail,
    required this.passiveLabel,
    required this.passiveDetail,
    required this.modalLabel,
    required this.modalDetail,
    required this.looksAdjective,
    required this.syllables,
  });

  final String code;
  final String projectTitle;
  final String unassignedChapterTitle;
  final int longSentenceThreshold;
  final Set<String> fillerWords;
  final Set<String> modalVerbs;
  final Set<String> stopWords;
  final RegExp passivePattern;
  final String fillerLabel;
  final String fillerDetail;
  final String repetitionLabel;
  final String repetitionDetail;
  final String longSentenceLabel;
  final String longSentenceDetail;
  final String adjectiveLabel;
  final String adjectiveDetail;
  final String passiveLabel;
  final String passiveDetail;
  final String modalLabel;
  final String modalDetail;
  final bool Function(String word) looksAdjective;
  final int Function(String word) syllables;

  static _StyleLanguage fromCode(String languageCode) {
    return languageCode.toLowerCase().startsWith('en') ? english : german;
  }

  static final german = _StyleLanguage(
    code: 'de',
    projectTitle: 'Projekt',
    unassignedChapterTitle: 'Ohne Kapitel',
    longSentenceThreshold: 24,
    fillerWords: {
      'aber',
      'also',
      'auch',
      'eben',
      'eigentlich',
      'einfach',
      'etwa',
      'halt',
      'irgendwie',
      'ja',
      'mal',
      'nämlich',
      'nun',
      'plötzlich',
      'quasi',
      'recht',
      'schon',
      'sehr',
      'vielleicht',
      'wohl',
      'ziemlich',
    },
    modalVerbs: {
      'darf',
      'dürfen',
      'durfte',
      'kann',
      'können',
      'konnte',
      'mag',
      'möchte',
      'muss',
      'müssen',
      'musste',
      'soll',
      'sollen',
      'sollte',
      'will',
      'wollen',
      'wollte',
    },
    stopWords: {
      'aber',
      'alle',
      'als',
      'auch',
      'auf',
      'aus',
      'bei',
      'das',
      'dem',
      'den',
      'der',
      'die',
      'ein',
      'eine',
      'einer',
      'eines',
      'für',
      'hat',
      'ich',
      'ist',
      'mit',
      'nicht',
      'sich',
      'sie',
      'und',
      'von',
      'war',
      'wie',
      'wir',
      'zu',
    },
    passivePattern: RegExp(
      r'\b(wird|wurde|werden|wurden|worden|ist|war|waren|sei|seien)\b.+\b\w+(?:t|en)\b',
    ),
    fillerLabel: 'Füllwörter',
    fillerDetail:
        'Prüfe, ob diese Wörter Rhythmus oder Stimme stärken oder nur dämpfen.',
    repetitionLabel: 'Wiederholungen',
    repetitionDetail:
        'Auffällige Wortwiederholungen können gewollt sein, fallen beim Lesen aber schnell auf.',
    longSentenceLabel: 'Lange Sätze',
    longSentenceDetail:
        'Lange Sätze verlangsamen den Rhythmus. Prüfe Atem, Fokus und Verständlichkeit.',
    adjectiveLabel: 'Adjektivhäufung',
    adjectiveDetail:
        'Mehrere beschreibende Wörter hintereinander können Bildkraft erzeugen oder überladen wirken.',
    passiveLabel: 'Passivnähe',
    passiveDetail:
        'Passiv kann Distanz erzeugen. Prüfe, ob handelnde Figuren klar genug bleiben.',
    modalLabel: 'Modalverben',
    modalDetail:
        'Viele Modalverben können Absicht und Handlung weicher machen.',
    looksAdjective: _looksGermanAdjective,
    syllables: _germanSyllables,
  );

  static final english = _StyleLanguage(
    code: 'en',
    projectTitle: 'Project',
    unassignedChapterTitle: 'No chapter',
    longSentenceThreshold: 26,
    fillerWords: {
      'actually',
      'basically',
      'certainly',
      'clearly',
      'completely',
      'definitely',
      'even',
      'fairly',
      'just',
      'kind',
      'literally',
      'maybe',
      'perhaps',
      'quite',
      'rather',
      'really',
      'simply',
      'somehow',
      'somewhat',
      'suddenly',
      'that',
      'very',
    },
    modalVerbs: {
      'can',
      'could',
      'may',
      'might',
      'must',
      'shall',
      'should',
      'will',
      'would',
    },
    stopWords: {
      'about',
      'after',
      'also',
      'and',
      'are',
      'because',
      'but',
      'for',
      'from',
      'have',
      'into',
      'not',
      'that',
      'the',
      'their',
      'then',
      'there',
      'they',
      'this',
      'was',
      'were',
      'with',
      'you',
    },
    passivePattern: RegExp(
      r'\b(am|are|be|been|being|is|was|were)\b\s+\w+(?:ed|en)\b',
    ),
    fillerLabel: 'Filler words',
    fillerDetail:
        'Check whether these words support voice and rhythm or soften the prose.',
    repetitionLabel: 'Repetitions',
    repetitionDetail:
        'Repeated words can be intentional, but they become visible quickly.',
    longSentenceLabel: 'Long sentences',
    longSentenceDetail:
        'Long sentences slow rhythm. Check breath, focus, and clarity.',
    adjectiveLabel: 'Adjective clusters',
    adjectiveDetail:
        'Several descriptors in a row can build imagery or overload the line.',
    passiveLabel: 'Passive voice',
    passiveDetail:
        'Passive voice can create distance. Check whether agency remains clear.',
    modalLabel: 'Modal verbs',
    modalDetail: 'Many modal verbs can soften intention and action.',
    looksAdjective: _looksEnglishAdjective,
    syllables: _englishSyllables,
  );
}

bool _looksGermanAdjective(String word) {
  return word.length > 5 &&
      RegExp(r'(ig|lich|isch|haft|los|voll|bar|sam|ern|ene|ende|er|es|en)$')
          .hasMatch(word);
}

bool _looksEnglishAdjective(String word) {
  return word.length > 5 &&
      RegExp(r'(able|al|ful|ic|ish|ive|less|ous|y)$').hasMatch(word);
}

int _germanSyllables(String word) {
  final matches = RegExp(r'[aeiouyäöü]+').allMatches(word.toLowerCase()).length;
  return math.max(1, matches);
}

int _englishSyllables(String word) {
  var normalized = word.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');
  if (normalized.isEmpty) return 1;
  if (normalized.endsWith('e') && normalized.length > 3) {
    normalized = normalized.substring(0, normalized.length - 1);
  }
  final matches = RegExp(r'[aeiouy]+').allMatches(normalized).length;
  return math.max(1, matches);
}
