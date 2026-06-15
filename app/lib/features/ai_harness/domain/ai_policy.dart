import '../../../core/domain/domain_failure.dart';
import '../../../core/domain/entity_type.dart';
import '../../projects/domain/project.dart';
import '../../structure/domain/scene.dart';

enum AITaskKind {
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
        kind == AITaskKind.sceneGoalConflictOutcome ||
        kind == AITaskKind.consistencyCheck ||
        kind == AITaskKind.timelineCheck ||
        kind == AITaskKind.storylineVariants ||
        kind == AITaskKind.blurbVariants ||
        kind == AITaskKind.styleAnalysis ||
        kind == AITaskKind.authorQuestions ||
        kind == AITaskKind.researchStructuring ||
        kind == AITaskKind.plotGapReview ||
        kind == AITaskKind.characterProfile) {
      return;
    }

    throw const DomainFailure('This AI task is not permitted.');
  }

  String systemBoundary() {
    return 'Assist the author with structure, analysis, alternatives, and questions. '
        'Do not produce final manuscript text as a replacement for the author. '
        'Return suggestions that require explicit user review.';
  }
}
