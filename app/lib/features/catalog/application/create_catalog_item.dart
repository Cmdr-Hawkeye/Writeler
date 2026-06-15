import '../../../core/domain/domain_failure.dart';
import '../../../core/domain/draft_status.dart';
import '../../../core/domain/entity_type.dart';
import '../../../core/domain/ids.dart';
import '../domain/catalog_item.dart';
import '../domain/catalog_item_repository.dart';

final class CreateCatalogItem {
  const CreateCatalogItem(this.repository);

  final CatalogItemRepository repository;

  Future<CatalogItem> call(CreateCatalogItemCommand command) async {
    final name = command.name.trim();
    if (name.isEmpty) {
      throw const DomainFailure('Catalog item name is required.');
    }

    final now = DateTime.now().toUtc();
    final item = CatalogItem(
      id: newLocalId(command.type.wireName),
      projectId: command.projectId,
      type: command.type,
      name: name,
      summary: command.summary.trim(),
      status: DraftStatus.planned,
      fields: command.fields,
      createdAt: now,
      updatedAt: now,
    );
    await repository.save(item);
    return item;
  }
}

final class CreateCatalogItemCommand {
  const CreateCatalogItemCommand({
    required this.projectId,
    required this.type,
    required this.name,
    this.summary = '',
    this.fields = const {},
  });

  final String projectId;
  final EntityType type;
  final String name;
  final String summary;
  final Map<String, Object?> fields;
}
