import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:writeler/features/ai_harness/infrastructure/in_memory_ai_suggestion_repository.dart';
import 'package:writeler/features/catalog/infrastructure/in_memory_catalog_item_repository.dart';
import 'package:writeler/features/catalog/infrastructure/in_memory_relationship_repository.dart';
import 'package:writeler/features/metrics/application/in_memory_metric_repository.dart';
import 'package:writeler/features/notes/infrastructure/in_memory_project_note_repository.dart';
import 'package:writeler/features/projects/infrastructure/in_memory_project_repository.dart';
import 'package:writeler/features/settings/infrastructure/in_memory_ai_provider_config_repository.dart';
import 'package:writeler/features/settings/infrastructure/in_memory_secret_vault.dart';
import 'package:writeler/features/structure/application/in_memory_chapter_repository.dart';
import 'package:writeler/features/structure/application/in_memory_scene_repository.dart';
import 'package:writeler/main.dart';

void main() {
  testWidgets('Writeler shell shows core workspace navigation', (tester) async {
    await tester.pumpWidget(
      WritelerApp(
        projectRepository: InMemoryProjectRepository(),
        chapterRepository: InMemoryChapterRepository(),
        sceneRepository: InMemorySceneRepository(),
        catalogItemRepository: InMemoryCatalogItemRepository(),
        relationshipRepository: InMemoryRelationshipRepository(),
        metricRepository: InMemoryMetricRepository(),
        aiSuggestionRepository: InMemoryAISuggestionRepository(),
        projectNoteRepository: InMemoryProjectNoteRepository(),
        aiProviderConfigRepository: InMemoryAIProviderConfigRepository(),
        secretVault: InMemorySecretVault(),
      ),
    );

    expect(find.text('Writeler'), findsOneWidget);
    expect(find.text('Projects'), findsOneWidget);
    expect(find.text('Editor'), findsOneWidget);
    expect(find.text('Scenes'), findsOneWidget);
    expect(find.text('Notes'), findsOneWidget);
    expect(find.text('AI Workshop'), findsOneWidget);
    expect(find.text('New Project'), findsOneWidget);
  });

  testWidgets('new project action creates a local project row', (tester) async {
    await tester.pumpWidget(
      WritelerApp(
        projectRepository: InMemoryProjectRepository(),
        chapterRepository: InMemoryChapterRepository(),
        sceneRepository: InMemorySceneRepository(),
        catalogItemRepository: InMemoryCatalogItemRepository(),
        relationshipRepository: InMemoryRelationshipRepository(),
        metricRepository: InMemoryMetricRepository(),
        aiSuggestionRepository: InMemoryAISuggestionRepository(),
        projectNoteRepository: InMemoryProjectNoteRepository(),
        aiProviderConfigRepository: InMemoryAIProviderConfigRepository(),
        secretVault: InMemorySecretVault(),
      ),
    );

    await tester.tap(find.text('New Project'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(EditableText), 'Draft Atlas');
    await tester.tap(find.text('Create'));
    await tester.pumpAndSettle();

    expect(find.text('Draft Atlas'), findsWidgets);
    expect(find.text('Local - novel'), findsOneWidget);
    expect(find.text('Project created'), findsOneWidget);
  });
}
