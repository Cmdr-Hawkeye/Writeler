import '../../../core/domain/draft_status.dart';
import '../../../core/domain/domain_failure.dart';
import '../../../core/domain/ids.dart';
import '../domain/scene.dart';
import '../domain/scene_repository.dart';

final class CreateScene {
  const CreateScene(this.repository);

  final SceneRepository repository;

  Future<Scene> call(CreateSceneCommand command) async {
    final title = command.title.trim();
    if (title.isEmpty) {
      throw const DomainFailure('Scene title is required.');
    }

    final now = DateTime.now().toUtc();
    final scene = Scene(
      id: newLocalId('scene'),
      projectId: command.projectId,
      chapterId: command.chapterId,
      title: title,
      summary: command.summary.trim(),
      authorIntent: command.authorIntent.trim(),
      status: DraftStatus.planned,
      orderIndex: command.orderIndex,
      aiAssistAllowed: command.aiAssistAllowed,
      createdAt: now,
      updatedAt: now,
    );

    await repository.save(scene);
    return scene;
  }
}

final class CreateSceneCommand {
  const CreateSceneCommand({
    required this.projectId,
    required this.title,
    this.chapterId,
    this.summary = '',
    this.authorIntent = '',
    this.orderIndex = 1000,
    this.aiAssistAllowed = true,
  });

  final String projectId;
  final String? chapterId;
  final String title;
  final String summary;
  final String authorIntent;
  final double orderIndex;
  final bool aiAssistAllowed;
}
