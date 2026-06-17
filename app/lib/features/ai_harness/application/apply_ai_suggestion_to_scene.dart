import '../../../core/domain/json_map.dart';
import '../../structure/domain/scene.dart';
import '../domain/ai_suggestion.dart';

final class ScenePlanningPatch {
  const ScenePlanningPatch({
    required this.sceneId,
    required this.changes,
  });

  final String sceneId;
  final List<ScenePlanningFieldChange> changes;

  bool get hasChanges => changes.isNotEmpty;

  Scene applyTo(Scene scene) {
    var updated = scene;
    for (final change in changes) {
      updated = switch (change.fieldKey) {
        'summary' => updated.copyWith(summary: change.suggestedValue),
        'goal' => updated.copyWith(goal: change.suggestedValue),
        'conflict' => updated.copyWith(conflict: change.suggestedValue),
        'outcome' => updated.copyWith(outcome: change.suggestedValue),
        _ => updated,
      };
    }
    return updated;
  }

  JsonMap toJson() => {
        'sceneId': sceneId,
        'fields': changes.map((change) => change.toJson()).toList(),
      };
}

final class ScenePlanningFieldChange {
  const ScenePlanningFieldChange({
    required this.fieldKey,
    required this.currentValue,
    required this.suggestedValue,
  });

  final String fieldKey;
  final String currentValue;
  final String suggestedValue;

  JsonMap toJson() => {
        'fieldKey': fieldKey,
        'currentValue': currentValue,
        'suggestedValue': suggestedValue,
      };
}

final class AIScenePlanningPatchBuilder {
  const AIScenePlanningPatchBuilder();

  ScenePlanningPatch build({
    required AISuggestion suggestion,
    required Scene scene,
  }) {
    final suggested = <String, String>{};
    _readStructuredFields(suggestion.structuredResponse, suggested);
    _readTextFields(suggestion.responseText, suggested);

    final changes = <ScenePlanningFieldChange>[
      for (final fieldKey in _fieldKeys)
        if (_valueForField(suggested, fieldKey) case final proposed?)
          if (_normalize(proposed) !=
              _normalize(_currentValue(scene, fieldKey)))
            ScenePlanningFieldChange(
              fieldKey: fieldKey,
              currentValue: _currentValue(scene, fieldKey),
              suggestedValue: proposed,
            ),
    ];

    return ScenePlanningPatch(sceneId: scene.id, changes: changes);
  }

  static const _fieldKeys = ['summary', 'goal', 'conflict', 'outcome'];

  void _readStructuredFields(JsonMap? source, Map<String, String> target) {
    if (source == null) return;
    final candidates = [
      source,
      for (final key in ['scenePatch', 'patch', 'planning', 'scene'])
        if (source[key] is Map) Map<String, Object?>.from(source[key] as Map),
    ];

    for (final candidate in candidates) {
      for (final entry in candidate.entries) {
        final fieldKey = _fieldKeyForLabel(entry.key);
        final value = _stringValue(entry.value);
        if (fieldKey != null && value != null) {
          target.putIfAbsent(fieldKey, () => value);
        }
      }
    }
  }

  void _readTextFields(String text, Map<String, String> target) {
    final lines = text.split(RegExp(r'\r?\n'));
    final pattern = RegExp(
      r'^\s*(?:[-*]\s*)?(?:\d+[.)]\s*)?(?:\*\*)?([A-Za-zÄÖÜäöüß ]+)(?:\*\*)?\s*[:\-–]\s*(.+)$',
      caseSensitive: false,
    );
    for (final line in lines) {
      final match = pattern.firstMatch(line.trim());
      if (match == null) continue;
      final fieldKey = _fieldKeyForLabel(match.group(1) ?? '');
      final value = _cleanValue(match.group(2) ?? '');
      if (fieldKey != null && value != null) {
        target.putIfAbsent(fieldKey, () => value);
      }
    }
  }

  String? _fieldKeyForLabel(String label) {
    final normalized = label.trim().toLowerCase();
    return switch (normalized) {
      'summary' || 'zusammenfassung' || 'kurzfassung' => 'summary',
      'goal' || 'ziel' || 'szenenziel' => 'goal',
      'conflict' || 'konflikt' || 'gegenkraft' => 'conflict',
      'outcome' || 'ausgang' || 'folge' || 'ergebnis' => 'outcome',
      _ => null,
    };
  }

  String? _stringValue(Object? value) {
    if (value is String) return _cleanValue(value);
    return null;
  }

  String? _cleanValue(String value) {
    final cleaned = value.trim().replaceAll(RegExp(r'\s+'), ' ');
    return cleaned.isEmpty ? null : cleaned;
  }

  String? _valueForField(Map<String, String> values, String fieldKey) {
    return values[fieldKey];
  }

  String _currentValue(Scene scene, String fieldKey) {
    return switch (fieldKey) {
      'summary' => scene.summary,
      'goal' => scene.goal ?? '',
      'conflict' => scene.conflict ?? '',
      'outcome' => scene.outcome ?? '',
      _ => '',
    };
  }

  String _normalize(String value) {
    return value.trim().replaceAll(RegExp(r'\s+'), ' ').toLowerCase();
  }
}
