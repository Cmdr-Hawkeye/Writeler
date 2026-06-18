import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';

import 'core/domain/domain_failure.dart';
import 'core/domain/draft_status.dart';
import 'core/domain/entity_ref.dart';
import 'core/domain/entity_type.dart';
import 'core/domain/ids.dart';
import 'features/ai_harness/application/request_ai_suggestion.dart';
import 'features/ai_harness/application/apply_ai_suggestion_to_scene.dart';
import 'features/ai_harness/domain/ai_policy.dart';
import 'features/ai_harness/domain/ai_suggestion.dart';
import 'features/ai_harness/domain/ai_suggestion_repository.dart';
import 'features/ai_harness/domain/language_model_provider.dart';
import 'features/ai_harness/infrastructure/drift_ai_suggestion_repository.dart';
import 'features/ai_harness/infrastructure/anthropic_language_model_provider.dart';
import 'features/ai_harness/infrastructure/gemini_language_model_provider.dart';
import 'features/ai_harness/infrastructure/http_model_http_transport.dart';
import 'features/ai_harness/infrastructure/lazy_ai_suggestion_repository.dart';
import 'features/ai_harness/infrastructure/mock_language_model_provider.dart';
import 'features/ai_harness/infrastructure/ollama_language_model_provider.dart';
import 'features/ai_harness/infrastructure/openai_compatible_language_model_provider.dart';
import 'features/catalog/application/create_catalog_item.dart';
import 'features/catalog/domain/catalog_item.dart';
import 'features/catalog/domain/catalog_item_repository.dart';
import 'features/catalog/domain/relationship.dart';
import 'features/catalog/domain/relationship_repository.dart';
import 'features/catalog/infrastructure/drift_catalog_item_repository.dart';
import 'features/catalog/infrastructure/drift_relationship_repository.dart';
import 'features/catalog/infrastructure/lazy_catalog_item_repository.dart';
import 'features/catalog/infrastructure/lazy_relationship_repository.dart';
import 'features/export/application/download_export.dart';
import 'features/export/application/project_archive_codec.dart';
import 'features/export/application/project_exporter.dart';
import 'features/export/domain/export_profile.dart';
import 'features/metrics/application/record_metric.dart';
import 'features/metrics/domain/metric_event.dart';
import 'features/metrics/domain/metric_repository.dart';
import 'features/metrics/infrastructure/drift_metric_repository.dart';
import 'features/metrics/infrastructure/lazy_metric_repository.dart';
import 'features/notes/domain/project_note.dart';
import 'features/notes/domain/project_note_repository.dart';
import 'features/notes/infrastructure/drift_project_note_repository.dart';
import 'features/notes/infrastructure/lazy_project_note_repository.dart';
import 'features/projects/application/create_project.dart';
import 'features/projects/domain/project.dart';
import 'features/projects/domain/project_repository.dart';
import 'features/projects/infrastructure/drift_project_repository.dart';
import 'features/projects/infrastructure/lazy_project_repository.dart';
import 'features/settings/domain/ai_provider_config.dart';
import 'features/settings/domain/ai_provider_config_repository.dart';
import 'features/settings/domain/ai_provider_preset.dart';
import 'features/settings/domain/app_preference_repository.dart';
import 'features/settings/domain/secret_vault.dart';
import 'features/settings/infrastructure/drift_app_preference_repository.dart';
import 'features/settings/infrastructure/drift_ai_provider_config_repository.dart';
import 'features/settings/infrastructure/flutter_secure_secret_vault.dart';
import 'features/settings/infrastructure/lazy_app_preference_repository.dart';
import 'features/settings/infrastructure/lazy_ai_provider_config_repository.dart';
import 'features/sync/application/manual_sync_adapter.dart';
import 'features/sync/domain/sync_checkpoint.dart';
import 'core/infrastructure/database/app_database.dart';
import 'features/structure/application/create_chapter.dart';
import 'features/structure/application/create_scene.dart';
import 'features/structure/domain/chapter.dart';
import 'features/structure/domain/chapter_repository.dart';
import 'features/structure/domain/scene.dart';
import 'features/structure/domain/scene_repository.dart';
import 'features/structure/infrastructure/drift_chapter_repository.dart';
import 'features/structure/infrastructure/drift_scene_repository.dart';
import 'features/structure/infrastructure/lazy_chapter_repository.dart';
import 'features/structure/infrastructure/lazy_scene_repository.dart';
import 'shared/writeler_copy.dart';

part 'presentation/app_root.dart';
part 'presentation/app_shell.dart';
part 'presentation/navigation_chrome.dart';
part 'presentation/dashboard_workspace.dart';
part 'presentation/structure_workspace.dart';
part 'presentation/catalog_analysis_notes.dart';
part 'presentation/ai_workshop.dart';
part 'presentation/export_settings_workspace.dart';
part 'presentation/shared_workspace_widgets.dart';
part 'presentation/editor_workspace.dart';
part 'presentation/presentation_helpers.dart';

void main() {
  AppDatabase? database;
  AppDatabase getDatabase() => database ??= AppDatabase();

  runApp(
    WritelerApp(
      projectRepository: LazyProjectRepository(
        () => DriftProjectRepository(getDatabase()),
      ),
      sceneRepository: LazySceneRepository(
        () => DriftSceneRepository(getDatabase()),
      ),
      chapterRepository: LazyChapterRepository(
        () => DriftChapterRepository(getDatabase()),
      ),
      catalogItemRepository: LazyCatalogItemRepository(
        () => DriftCatalogItemRepository(getDatabase()),
      ),
      relationshipRepository: LazyRelationshipRepository(
        () => DriftRelationshipRepository(getDatabase()),
      ),
      metricRepository: LazyMetricRepository(
        () => DriftMetricRepository(getDatabase()),
      ),
      aiSuggestionRepository: LazyAISuggestionRepository(
        () => DriftAISuggestionRepository(getDatabase()),
      ),
      projectNoteRepository: LazyProjectNoteRepository(
        () => DriftProjectNoteRepository(getDatabase()),
      ),
      aiProviderConfigRepository: LazyAIProviderConfigRepository(
        () => DriftAIProviderConfigRepository(getDatabase()),
      ),
      appPreferenceRepository: LazyAppPreferenceRepository(
        () => DriftAppPreferenceRepository(getDatabase()),
      ),
      secretVault: const FlutterSecureSecretVault(),
    ),
  );
}
