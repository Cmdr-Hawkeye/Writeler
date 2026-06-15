import '../../../core/domain/domain_failure.dart';
import '../../../core/domain/draft_status.dart';
import '../../../core/domain/ids.dart';
import '../domain/chapter.dart';
import '../domain/chapter_repository.dart';

final class CreateChapter {
  const CreateChapter(this.repository);

  final ChapterRepository repository;

  Future<Chapter> call(CreateChapterCommand command) async {
    final title = command.title.trim();
    if (title.isEmpty) {
      throw const DomainFailure('Chapter title is required.');
    }

    final now = DateTime.now().toUtc();
    final chapter = Chapter(
      id: newLocalId('chapter'),
      projectId: command.projectId,
      title: title,
      summary: command.summary.trim(),
      orderIndex: command.orderIndex,
      status: DraftStatus.planned,
      createdAt: now,
      updatedAt: now,
    );

    await repository.save(chapter);
    return chapter;
  }
}

final class CreateChapterCommand {
  const CreateChapterCommand({
    required this.projectId,
    required this.title,
    this.summary = '',
    this.orderIndex = 1000,
  });

  final String projectId;
  final String title;
  final String summary;
  final double orderIndex;
}
