import '../../../core/domain/domain_failure.dart';
import '../../../core/domain/entity_type.dart';
import '../../projects/domain/project.dart';
import '../../structure/domain/scene.dart';

enum AITaskKind {
  customScenePrompt,
  sceneIdeas,
  sceneGoalConflictOutcome,
  characterProfile,
  consistencyCheck,
  timelineCheck,
  storylineVariants,
  blurbVariants,
  styleAnalysis,
  authorQuestions,
  researchStructuring,
  plotGapReview,
  dialogueIntentAnalysis,
  worldContextStarter,
}

final class AIPolicy {
  const AIPolicy();

  void ensureProjectAllowsAI(Project project) {
    if (!project.aiEnabled || project.noAiNoCloud) {
      throw const DomainFailure('AI is disabled for this project.');
    }
  }

  void ensureSceneAllowsAI(Scene scene) {
    if (!scene.aiAssistAllowed) {
      throw const DomainFailure('AI assistance is disabled for this scene.');
    }
  }

  void ensureAllowedTask({
    required AITaskKind kind,
    required EntityType targetType,
  }) {
    if (targetType == EntityType.scene &&
        kind == AITaskKind.dialogueIntentAnalysis) {
      return;
    }
    if (kind == AITaskKind.sceneIdeas ||
        kind == AITaskKind.customScenePrompt ||
        kind == AITaskKind.sceneGoalConflictOutcome ||
        kind == AITaskKind.consistencyCheck ||
        kind == AITaskKind.timelineCheck ||
        kind == AITaskKind.storylineVariants ||
        kind == AITaskKind.blurbVariants ||
        kind == AITaskKind.styleAnalysis ||
        kind == AITaskKind.authorQuestions ||
        kind == AITaskKind.researchStructuring ||
        kind == AITaskKind.plotGapReview ||
        kind == AITaskKind.worldContextStarter ||
        kind == AITaskKind.characterProfile) {
      return;
    }

    throw const DomainFailure('This AI task is not permitted.');
  }

  String systemBoundary({String languageCode = 'en'}) {
    if (languageCode == 'de') {
      return 'Unterstütze den Autor mit Struktur, Analyse, Alternativen und Fragen. '
          'Erzeuge keinen finalen Manuskripttext als Ersatz für die Autorin oder den Autor. '
          'Alle Vorschläge müssen ausdrücklich geprüft werden.';
    }
    return 'Assist the author with structure, analysis, alternatives, and questions. '
        'Do not produce final manuscript text as a replacement for the author. '
        'Return suggestions that require explicit user review.';
  }
}
