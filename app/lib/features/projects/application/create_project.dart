import '../../../core/domain/draft_status.dart';
import '../../../core/domain/domain_failure.dart';
import '../../../core/domain/ids.dart';
import '../domain/project.dart';
import '../domain/project_repository.dart';

final class CreateProject {
  const CreateProject(this.repository);

  final ProjectRepository repository;

  Future<Project> call(CreateProjectCommand command) async {
    final title = command.title.trim();
    if (title.isEmpty) {
      throw const DomainFailure('Project title is required.');
    }

    final now = DateTime.now().toUtc();
    final project = Project(
      id: newLocalId('project'),
      title: title,
      description: command.description.trim(),
      projectType: command.projectType,
      languageCode: command.languageCode,
      status: DraftStatus.planned,
      wordTarget: command.wordTarget,
      aiEnabled: command.aiEnabled,
      cloudSyncEnabled: false,
      noAiNoCloud: command.noAiNoCloud,
      createdAt: now,
      updatedAt: now,
    );

    await repository.save(project);
    return project;
  }
}

final class CreateProjectCommand {
  const CreateProjectCommand({
    required this.title,
    this.description = '',
    this.projectType = 'novel',
    this.languageCode = 'de',
    this.wordTarget,
    this.aiEnabled = true,
    this.noAiNoCloud = false,
  });

  final String title;
  final String description;
  final String projectType;
  final String languageCode;
  final int? wordTarget;
  final bool aiEnabled;
  final bool noAiNoCloud;
}
