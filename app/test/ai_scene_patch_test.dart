import 'package:test/test.dart';
import 'package:writeller/core/domain/draft_status.dart';
import 'package:writeller/core/domain/entity_ref.dart';
import 'package:writeller/core/domain/entity_type.dart';
import 'package:writeller/features/ai_harness/application/apply_ai_suggestion_to_scene.dart';
import 'package:writeller/features/ai_harness/domain/ai_suggestion.dart';
import 'package:writeller/features/structure/domain/scene.dart';

void main() {
  test('builds scene planning patch from structured provider response', () {
    final scene = _scene(goal: 'Old goal');
    final suggestion = _suggestion(
      structuredResponse: const {
        'scenePatch': {
          'summary': 'New beat summary.',
          'goal': 'Find the missing signal.',
          'conflict': 'A locked system blocks the search.',
          'outcome': 'The team leaves with a narrower lead.',
        },
      },
    );

    final patch = const AIScenePlanningPatchBuilder().build(
      suggestion: suggestion,
      scene: scene,
    );
    final updated = patch.applyTo(scene);

    expect(patch.changes.map((change) => change.fieldKey), [
      'summary',
      'goal',
      'conflict',
      'outcome',
    ]);
    expect(updated.manuscriptText, scene.manuscriptText);
    expect(updated.goal, 'Find the missing signal.');
    expect(updated.conflict, 'A locked system blocks the search.');
    expect(updated.outcome, 'The team leaves with a narrower lead.');
  });

  test('builds scene planning patch from labelled text response', () {
    final scene = _scene();
    final suggestion = _suggestion(
      responseText: '''
1. Ziel: Die Figur will den Zugangscode sichern.
2. Konflikt: Der Wachplan aendert sich frueher als erwartet.
3. Ausgang: Sie hat den Code, aber ist nun identifiziert.
''',
    );

    final patch = const AIScenePlanningPatchBuilder().build(
      suggestion: suggestion,
      scene: scene,
    );

    expect(patch.changes.map((change) => change.fieldKey), [
      'goal',
      'conflict',
      'outcome',
    ]);
  });

  test('does not create changes for identical planning values', () {
    final scene = _scene(goal: 'Already clear.');
    final suggestion = _suggestion(
      structuredResponse: const {
        'scenePatch': {'goal': 'Already clear.'},
      },
    );

    final patch = const AIScenePlanningPatchBuilder().build(
      suggestion: suggestion,
      scene: scene,
    );

    expect(patch.hasChanges, isFalse);
  });
}

Scene _scene({String? goal}) {
  return Scene(
    id: 'scene-1',
    projectId: 'project-1',
    title: 'Signal Room',
    summary: '',
    manuscriptText: 'Only the author wrote this.',
    status: DraftStatus.drafting,
    orderIndex: 1000,
    goal: goal,
    aiAssistAllowed: true,
    createdAt: DateTime.utc(2026),
    updatedAt: DateTime.utc(2026),
  );
}

AISuggestion _suggestion({
  String responseText = '',
  Map<String, Object?>? structuredResponse,
}) {
  return AISuggestion(
    id: 'suggestion-1',
    projectId: 'project-1',
    target: const EntityRef(type: EntityType.scene, id: 'scene-1'),
    suggestionType: 'sceneGoalConflictOutcome',
    inputContextHash: 'hash',
    providerId: 'mock',
    modelName: 'mock',
    promptText: 'prompt',
    responseText: responseText,
    structuredResponse: structuredResponse,
    userDecision: SuggestionDecision.pending,
    createdAt: DateTime.utc(2026),
  );
}
