import 'package:flutter_test/flutter_test.dart';
import 'package:writeller/core/domain/draft_status.dart';
import 'package:writeller/features/structure/domain/chapter.dart';
import 'package:writeller/features/structure/domain/scene.dart';
import 'package:writeller/features/style_analysis/application/style_analyzer.dart';
import 'package:writeller/features/style_analysis/domain/style_analysis_result.dart';

void main() {
  test('detects style signals for a German scene', () {
    final now = DateTime.utc(2026);
    final scene = Scene(
      id: 'scene-1',
      projectId: 'project-1',
      title: 'Turnhalle',
      status: DraftStatus.drafting,
      orderIndex: 1000,
      aiAssistAllowed: true,
      createdAt: now,
      updatedAt: now,
      manuscriptText: 'Eigentlich war die große dunkle kalte Halle sehr still. '
          'Die Halle wurde von blauem Licht gefüllt, und Mira musste '
          'vielleicht einfach warten, obwohl die Halle die Halle blieb. '
          '„Wir gehen jetzt“, sagte sie.',
    );

    final result = const StyleAnalyzer().analyzeProject(
      chapters: const [],
      scenes: [scene],
      languageCode: 'de',
    );
    final analysis = result.sceneById('scene-1')!;

    expect(analysis.wordCount, greaterThan(20));
    expect(analysis.fillerWordCount, greaterThanOrEqualTo(3));
    expect(analysis.repetitionCount, greaterThanOrEqualTo(1));
    expect(analysis.passiveVoiceCount, greaterThanOrEqualTo(1));
    expect(analysis.modalVerbCount, greaterThanOrEqualTo(1));
    expect(analysis.dialogueShare, greaterThan(0));
    expect(
      analysis.issues.map((issue) => issue.kind),
      containsAll([
        StyleIssueKind.fillerWord,
        StyleIssueKind.repetition,
        StyleIssueKind.passiveVoice,
        StyleIssueKind.modalVerb,
      ]),
    );
  });

  test('aggregates readability by chapter', () {
    final now = DateTime.utc(2026);
    final chapter = Chapter(
      id: 'chapter-1',
      projectId: 'project-1',
      title: 'Ankunft',
      orderIndex: 1000,
      status: DraftStatus.drafting,
      createdAt: now,
      updatedAt: now,
    );
    final scenes = [
      _scene(
        id: 'scene-1',
        chapterId: chapter.id,
        text: 'Mira öffnete die Tür. Licht fiel in den Raum.',
        now: now,
      ),
      _scene(
        id: 'scene-2',
        chapterId: chapter.id,
        text: 'Jon wartete am Fenster. Er nickte langsam.',
        now: now,
      ),
    ];

    final result = const StyleAnalyzer().analyzeProject(
      chapters: [chapter],
      scenes: scenes,
      languageCode: 'de',
    );
    final chapterAnalysis = result.chapters.single;

    expect(chapterAnalysis.title, 'Ankunft');
    expect(chapterAnalysis.wordCount, 16);
    expect(chapterAnalysis.scope, StyleScope.chapter);
    expect(result.project.wordCount, 16);
  });
}

Scene _scene({
  required String id,
  required String chapterId,
  required String text,
  required DateTime now,
}) {
  return Scene(
    id: id,
    projectId: 'project-1',
    chapterId: chapterId,
    title: id,
    status: DraftStatus.drafting,
    orderIndex: 1000,
    aiAssistAllowed: true,
    createdAt: now,
    updatedAt: now,
    manuscriptText: text,
  );
}
