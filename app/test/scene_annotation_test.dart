import 'package:flutter_test/flutter_test.dart';
import 'package:writeler/features/structure/domain/scene_annotation.dart';

void main() {
  test('scene annotations roundtrip through metadata and sort open first', () {
    final now = DateTime.utc(2026, 1, 2, 3, 4, 5);
    final resolved = SceneAnnotation(
      id: 'annotation-resolved',
      sceneId: 'scene-1',
      startOffset: 20,
      endOffset: 28,
      selectedText: 'old note',
      comment: 'Already handled',
      resolved: true,
      createdAt: now,
      updatedAt: now,
    );
    final open = SceneAnnotation(
      id: 'annotation-open',
      sceneId: 'scene-1',
      startOffset: 4,
      endOffset: 12,
      selectedText: 'passage',
      comment: 'Clarify motivation',
      createdAt: now,
      updatedAt: now,
    );

    final metadata = SceneAnnotation.metadataWithAnnotations(
      const {'source': 'test'},
      [resolved, open],
    );
    final annotations = SceneAnnotation.listFromMetadata(metadata);

    expect(metadata['source'], 'test');
    expect(annotations, hasLength(2));
    expect(annotations.first.id, 'annotation-open');
    expect(annotations.first.comment, 'Clarify motivation');
    expect(annotations.last.resolved, isTrue);
  });
}
