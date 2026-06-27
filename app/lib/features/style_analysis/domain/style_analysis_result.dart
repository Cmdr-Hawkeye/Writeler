import '../../structure/domain/chapter.dart';
import '../../structure/domain/scene.dart';

enum StyleIssueKind {
  fillerWord,
  repetition,
  longSentence,
  adjectiveCluster,
  passiveVoice,
  modalVerb,
}

enum StyleSeverity { info, notice, warning }

final class StyleAnalysisResult {
  const StyleAnalysisResult({
    required this.project,
    required this.chapters,
    required this.scenes,
  });

  final StyleScopeAnalysis project;
  final List<StyleScopeAnalysis> chapters;
  final List<StyleScopeAnalysis> scenes;

  StyleScopeAnalysis? sceneById(String id) {
    for (final scene in scenes) {
      if (scene.id == id) return scene;
    }
    return null;
  }
}

final class StyleScopeAnalysis {
  const StyleScopeAnalysis({
    required this.id,
    required this.title,
    required this.scope,
    required this.wordCount,
    required this.sentenceCount,
    required this.averageSentenceLength,
    required this.longSentenceCount,
    required this.dialogueShare,
    required this.readabilityScore,
    required this.fillerWordCount,
    required this.repetitionCount,
    required this.adjectiveClusterCount,
    required this.passiveVoiceCount,
    required this.modalVerbCount,
    required this.issues,
  });

  final String id;
  final String title;
  final StyleScope scope;
  final int wordCount;
  final int sentenceCount;
  final double averageSentenceLength;
  final int longSentenceCount;
  final double dialogueShare;
  final double readabilityScore;
  final int fillerWordCount;
  final int repetitionCount;
  final int adjectiveClusterCount;
  final int passiveVoiceCount;
  final int modalVerbCount;
  final List<StyleIssue> issues;

  int get issueCount =>
      fillerWordCount +
      repetitionCount +
      longSentenceCount +
      adjectiveClusterCount +
      passiveVoiceCount +
      modalVerbCount;
}

enum StyleScope { project, chapter, scene }

final class StyleIssue {
  const StyleIssue({
    required this.kind,
    required this.severity,
    required this.label,
    required this.detail,
    required this.count,
    required this.examples,
  });

  final StyleIssueKind kind;
  final StyleSeverity severity;
  final String label;
  final String detail;
  final int count;
  final List<String> examples;
}

final class StyleSceneInput {
  const StyleSceneInput({
    required this.scene,
    required this.chapter,
  });

  final Scene scene;
  final Chapter? chapter;
}
