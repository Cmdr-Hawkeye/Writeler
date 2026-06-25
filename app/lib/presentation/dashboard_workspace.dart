part of '../main.dart';

// Dashboard and project overview workspace surfaces.

final class _WorkspaceView extends StatelessWidget {
  const _WorkspaceView({
    required this.copy,
    required this.projects,
    required this.selectedProject,
    required this.chapters,
    required this.catalogItems,
    required this.relationships,
    required this.suggestions,
    required this.scenes,
    required this.selectedScene,
    required this.manuscriptController,
    required this.summaryController,
    required this.goalController,
    required this.conflictController,
    required this.outcomeController,
    required this.wordTargetController,
    required this.selectedSceneStatus,
    required this.selectedSceneChapterId,
    required this.sceneSaveState,
    required this.lastSceneSavedAt,
    required this.onSelectProject,
    required this.onDeleteProject,
    required this.onSelectScene,
    required this.onDeleteScene,
    required this.onSceneChapterChanged,
    required this.onToggleSceneCatalogLink,
    required this.onAddExistingSceneCatalogItems,
    required this.onCreateSceneCatalogItem,
    required this.onSceneStatusChanged,
    required this.onCreateChapter,
    required this.onCreateScene,
    required this.isRequestingAi,
    required this.onRequestSceneAiHelp,
    required this.onSaveScene,
  });

  final WritelerCopy copy;
  final List<Project> projects;
  final Project? selectedProject;
  final List<Chapter> chapters;
  final List<CatalogItem> catalogItems;
  final List<Relationship> relationships;
  final List<AISuggestion> suggestions;
  final List<Scene> scenes;
  final Scene? selectedScene;
  final TextEditingController manuscriptController;
  final TextEditingController summaryController;
  final TextEditingController goalController;
  final TextEditingController conflictController;
  final TextEditingController outcomeController;
  final TextEditingController wordTargetController;
  final DraftStatus selectedSceneStatus;
  final String? selectedSceneChapterId;
  final _SceneSaveState sceneSaveState;
  final DateTime? lastSceneSavedAt;
  final ValueChanged<Project> onSelectProject;
  final ValueChanged<Project> onDeleteProject;
  final ValueChanged<Scene> onSelectScene;
  final ValueChanged<Scene> onDeleteScene;
  final ValueChanged<String?> onSceneChapterChanged;
  final Future<void> Function(CatalogItem item, bool selected)
      onToggleSceneCatalogLink;
  final Future<void> Function(List<CatalogItem> items)
      onAddExistingSceneCatalogItems;
  final ValueChanged<EntityType> onCreateSceneCatalogItem;
  final ValueChanged<DraftStatus> onSceneStatusChanged;
  final VoidCallback onCreateChapter;
  final VoidCallback onCreateScene;
  final bool isRequestingAi;
  final void Function(AITaskKind task, String prompt) onRequestSceneAiHelp;
  final VoidCallback onSaveScene;

  @override
  Widget build(BuildContext context) {
    final library = _ProjectLibrary(
      copy: copy,
      projects: projects,
      selectedProject: selectedProject,
      onSelect: onSelectProject,
      onDelete: onDeleteProject,
    );
    final workspace = _ProjectWorkspace(
      copy: copy,
      project: selectedProject,
      chapters: chapters,
      catalogItems: catalogItems,
      relationships: relationships,
      suggestions: suggestions,
      scenes: scenes,
      selectedScene: selectedScene,
      manuscriptController: manuscriptController,
      summaryController: summaryController,
      goalController: goalController,
      conflictController: conflictController,
      outcomeController: outcomeController,
      wordTargetController: wordTargetController,
      selectedSceneStatus: selectedSceneStatus,
      selectedSceneChapterId: selectedSceneChapterId,
      sceneSaveState: sceneSaveState,
      lastSceneSavedAt: lastSceneSavedAt,
      onSelectScene: onSelectScene,
      onDeleteScene: onDeleteScene,
      onSceneChapterChanged: onSceneChapterChanged,
      onToggleSceneCatalogLink: onToggleSceneCatalogLink,
      onAddExistingSceneCatalogItems: onAddExistingSceneCatalogItems,
      onCreateSceneCatalogItem: onCreateSceneCatalogItem,
      onSceneStatusChanged: onSceneStatusChanged,
      onCreateChapter: onCreateChapter,
      onCreateScene: onCreateScene,
      isRequestingAi: isRequestingAi,
      onRequestSceneAiHelp: onRequestSceneAiHelp,
      onSaveScene: onSaveScene,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 760) {
          return Column(
            children: [
              SizedBox(height: 150, child: library),
              const Divider(height: 1),
              Expanded(child: workspace),
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(width: 300, child: library),
            const VerticalDivider(width: 1),
            Expanded(child: workspace),
          ],
        );
      },
    );
  }
}

final class _EmptyWorkspace extends StatelessWidget {
  const _EmptyWorkspace({required this.copy});

  final WritelerCopy copy;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: color.surfaceContainerLow,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.outlineVariant),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: color.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.menu_book_outlined,
                  color: color.primary,
                  size: 30,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                copy.t('emptyTitle'),
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              Text(
                copy.t('emptyBody'),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: color.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final class _ProjectOverview extends StatelessWidget {
  const _ProjectOverview({
    required this.copy,
    required this.projects,
    required this.selectedProject,
    required this.chapters,
    required this.scenes,
    required this.notes,
    required this.catalogItems,
    required this.relationships,
    required this.metrics,
    required this.suggestions,
    required this.onSelectProject,
    required this.onDeleteProject,
    required this.onOpenEditor,
    required this.onOpenStructure,
    required this.onOpenNotes,
    required this.onOpenAiWorkshop,
    required this.onOpenScene,
  });

  final WritelerCopy copy;
  final List<Project> projects;
  final Project? selectedProject;
  final List<Chapter> chapters;
  final List<Scene> scenes;
  final List<ProjectNote> notes;
  final List<CatalogItem> catalogItems;
  final List<Relationship> relationships;
  final List<MetricEvent> metrics;
  final List<AISuggestion> suggestions;
  final ValueChanged<Project> onSelectProject;
  final ValueChanged<Project> onDeleteProject;
  final VoidCallback onOpenEditor;
  final VoidCallback onOpenStructure;
  final VoidCallback onOpenNotes;
  final VoidCallback onOpenAiWorkshop;
  final ValueChanged<Scene> onOpenScene;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final project = selectedProject;
    final words =
        scenes.fold<int>(0, (sum, scene) => sum + scene.actualWordCount);
    final wordTarget = project?.wordTarget;
    final wordProgress = wordTarget == null || wordTarget <= 0
        ? null
        : (words / wordTarget).clamp(0.0, 1.0);
    final pendingSuggestionItems = suggestions
        .where((suggestion) =>
            suggestion.userDecision == SuggestionDecision.pending)
        .toList(growable: false)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final pendingSuggestions = pendingSuggestionItems.length;
    final planningGaps = scenes
        .where((scene) => _missingScenePlanningLabels(scene, copy).isNotEmpty)
        .toList(growable: false);
    final scenesWithoutText = scenes
        .where((scene) => scene.manuscriptText.trim().isEmpty)
        .toList(growable: false)
      ..sort(_compareScenesByReadingOrder);
    final unassignedScenes = scenes
        .where((scene) => scene.chapterId == null)
        .toList(growable: false);
    final detachedCatalogItems = catalogItems
        .where(
            (item) => _linkedSceneCountForCatalogItem(item, relationships) == 0)
        .toList(growable: false);
    final today = DateTime.now().toLocal();
    final todaySaves = metrics
        .where(
          (event) =>
              event.eventType == 'scene.saved' &&
              event.occurredAt.toLocal().year == today.year &&
              event.occurredAt.toLocal().month == today.month &&
              event.occurredAt.toLocal().day == today.day,
        )
        .length;
    final aiEvents =
        metrics.where((event) => event.eventType.startsWith('ai.')).length;
    final recentScenes = [...scenes]
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    final urgentPlanningGaps = [...planningGaps]
      ..sort(_compareScenesByPlanningUrgency);
    final latestPendingSuggestion = pendingSuggestionItems.firstOrNull;
    final untargetedNotes = notes
        .where((note) => note.target == null)
        .toList(growable: false)
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    final nextSceneWithoutText = scenesWithoutText.firstOrNull;
    final urgentPlanningGap = urgentPlanningGaps.firstOrNull;
    final untargetedNote = untargetedNotes.firstOrNull;
    final nextActions = [
      if (nextSceneWithoutText != null)
        _DashboardAction(
          icon: Icons.edit_off_outlined,
          title: copy.t('nextSceneWithoutText'),
          body: nextSceneWithoutText.title,
          onTap: () => onOpenScene(nextSceneWithoutText),
        ),
      if (urgentPlanningGap != null)
        _DashboardAction(
          icon: Icons.account_tree_outlined,
          title: copy.t('mostUrgentPlanningGap'),
          body: '${urgentPlanningGap.title} · ${copy.t('missing')}: '
              '${_missingScenePlanningLabels(urgentPlanningGap, copy).join(', ')}',
          onTap: () => onOpenScene(urgentPlanningGap),
        ),
      if (latestPendingSuggestion != null)
        _DashboardAction(
          icon: Icons.psychology_alt_outlined,
          title: copy.t('latestOpenAiResponse'),
          body:
              '${_aiTaskLabel(latestPendingSuggestion.suggestionType, copy)} · '
              '${_formatLocalDateTime(latestPendingSuggestion.createdAt)}',
          onTap: onOpenAiWorkshop,
        ),
      if (untargetedNote != null)
        _DashboardAction(
          icon: Icons.sticky_note_2_outlined,
          title: copy.t('noteWithoutTarget'),
          body: untargetedNote.title,
          onTap: onOpenNotes,
        ),
      if (nextSceneWithoutText == null &&
          urgentPlanningGap == null &&
          latestPendingSuggestion == null &&
          untargetedNote == null &&
          scenes.isNotEmpty)
        _DashboardAction(
          icon: Icons.edit_note_outlined,
          title: copy.t('continueWriting'),
          body: recentScenes.first.title,
          onTap: () => onOpenScene(recentScenes.first),
        ),
    ];

    return Row(
      children: [
        SizedBox(
          width: 320,
          child: _ProjectLibrary(
            copy: copy,
            projects: projects,
            selectedProject: selectedProject,
            onSelect: onSelectProject,
            onDelete: onDeleteProject,
          ),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(-0.92, -1.12),
                radius: 0.9,
                colors: [
                  color.primary.withValues(alpha: 0.10),
                  Colors.transparent,
                ],
              ),
            ),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(28, 24, 28, 32),
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            project?.title ?? copy.t('projects'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            copy.t('dashboardBody'),
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: color.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    FilledButton.icon(
                      onPressed: onOpenEditor,
                      icon: const Icon(Icons.edit_note_outlined),
                      label: Text(copy.t('openEditor')),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _DashboardPulse(
                  copy: copy,
                  words: words,
                  wordTarget: wordTarget,
                  wordProgress: wordProgress,
                  scenes: scenes.length,
                  chapters: chapters.length,
                  catalogItems: catalogItems.length,
                  todaySaves: todaySaves,
                ),
                const SizedBox(height: 24),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final compact = constraints.maxWidth < 960;
                    final actions = _DashboardSection(
                      title: copy.t('nextActions'),
                      body: copy.t('nextActionsBody'),
                      child: nextActions.isEmpty
                          ? _EmptyInlineMessage(
                              message: copy.t('noDashboardActions'),
                            )
                          : Column(
                              children: [
                                for (final action in nextActions)
                                  _DashboardActionRow(action: action),
                              ],
                            ),
                    );
                    final health = _DashboardSection(
                      title: copy.t('structureFocus'),
                      body: copy.t('structureFocusBody'),
                      child: Column(
                        children: [
                          _DashboardHealthRow(
                            icon: Icons.account_tree_outlined,
                            label: copy.t('planningGaps'),
                            value: '${planningGaps.length}',
                            tone: planningGaps.isEmpty
                                ? color.primary
                                : color.error,
                            onTap:
                                planningGaps.isEmpty ? null : onOpenStructure,
                          ),
                          _DashboardHealthRow(
                            icon: Icons.edit_off_outlined,
                            label: copy.t('emptyDraftScenes'),
                            value: '${scenesWithoutText.length}',
                            tone: scenesWithoutText.isEmpty
                                ? color.primary
                                : color.tertiary,
                            onTap: scenesWithoutText.isEmpty
                                ? null
                                : () => onOpenScene(scenesWithoutText.first),
                          ),
                          _DashboardHealthRow(
                            icon: Icons.folder_off_outlined,
                            label: copy.t('unassignedScenes'),
                            value: '${unassignedScenes.length}',
                            tone: unassignedScenes.isEmpty
                                ? color.primary
                                : color.tertiary,
                            onTap: unassignedScenes.isEmpty
                                ? null
                                : onOpenStructure,
                          ),
                          _DashboardHealthRow(
                            icon: Icons.category_outlined,
                            label: copy.t('detachedCatalogItems'),
                            value: '${detachedCatalogItems.length}',
                            tone: detachedCatalogItems.isEmpty
                                ? color.primary
                                : color.tertiary,
                            onTap: detachedCatalogItems.isEmpty
                                ? null
                                : onOpenStructure,
                          ),
                        ],
                      ),
                    );

                    if (compact) {
                      return Column(
                        children: [
                          actions,
                          const SizedBox(height: 22),
                          health,
                        ],
                      );
                    }
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: actions),
                        const SizedBox(width: 24),
                        Expanded(child: health),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),
                _DashboardSection(
                  title: copy.t('recentScenes'),
                  body: copy.t('recentScenesBody'),
                  child: recentScenes.isEmpty
                      ? _EmptyInlineMessage(message: copy.t('noRecentScenes'))
                      : Column(
                          children: [
                            for (final scene in recentScenes.take(5))
                              _DashboardSceneRow(
                                copy: copy,
                                scene: scene,
                                onTap: () => onOpenScene(scene),
                              ),
                          ],
                        ),
                ),
                const SizedBox(height: 24),
                _DashboardSection(
                  title: copy.t('dashboardSignals'),
                  body: copy.t('dashboardSignalsBody'),
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _DashboardSignalChip(
                        icon: Icons.psychology_alt_outlined,
                        label: copy.t('aiQueue'),
                        value: '$pendingSuggestions',
                        onTap: pendingSuggestions > 0 ? onOpenAiWorkshop : null,
                      ),
                      _DashboardSignalChip(
                        icon: Icons.sticky_note_2_outlined,
                        label: copy.t('notesQueue'),
                        value: '${notes.length}',
                        onTap: notes.isNotEmpty ? onOpenNotes : null,
                      ),
                      _DashboardSignalChip(
                        icon: Icons.auto_awesome_outlined,
                        label: copy.t('aiUses'),
                        value: '$aiEvents',
                        onTap: onOpenAiWorkshop,
                      ),
                      _DashboardSignalChip(
                        icon: Icons.event_available_outlined,
                        label: copy.t('todaySaves'),
                        value: '$todaySaves',
                        onTap: onOpenEditor,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

final class _DashboardPulse extends StatelessWidget {
  const _DashboardPulse({
    required this.copy,
    required this.words,
    required this.wordTarget,
    required this.wordProgress,
    required this.scenes,
    required this.chapters,
    required this.catalogItems,
    required this.todaySaves,
  });

  final WritelerCopy copy;
  final int words;
  final int? wordTarget;
  final double? wordProgress;
  final int scenes;
  final int chapters;
  final int catalogItems;
  final int todaySaves;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.surfaceContainerLowest,
        border: Border(
          top: BorderSide(color: color.outlineVariant),
          bottom: BorderSide(color: color.outlineVariant),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 820;
            final summary = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  copy.t('projectPulse'),
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: color.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  wordTarget == null || wordTarget! <= 0
                      ? '$words ${copy.t('words')}'
                      : '$words / $wordTarget ${copy.t('words')}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: wordProgress,
                  minHeight: 3,
                  color: color.primary.withValues(alpha: 0.58),
                  backgroundColor: color.outlineVariant.withValues(alpha: 0.42),
                  borderRadius: BorderRadius.circular(99),
                ),
              ],
            );
            final metrics = Wrap(
              spacing: 18,
              runSpacing: 14,
              children: [
                _DashboardPulseMetric(
                    label: copy.t('scenes'), value: '$scenes'),
                _DashboardPulseMetric(
                    label: copy.t('chapters'), value: '$chapters'),
                _DashboardPulseMetric(
                    label: copy.t('catalog'), value: '$catalogItems'),
                _DashboardPulseMetric(
                    label: copy.t('todaySaves'), value: '$todaySaves'),
              ],
            );

            if (compact) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  summary,
                  const SizedBox(height: 18),
                  metrics,
                ],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(flex: 2, child: summary),
                const SizedBox(width: 28),
                Expanded(flex: 3, child: metrics),
              ],
            );
          },
        ),
      ),
    );
  }
}

final class _StatisticsWorkspace extends StatelessWidget {
  const _StatisticsWorkspace({
    required this.copy,
    required this.project,
    required this.chapters,
    required this.scenes,
    required this.catalogItems,
    required this.relationships,
    required this.metrics,
  });

  final WritelerCopy copy;
  final Project? project;
  final List<Chapter> chapters;
  final List<Scene> scenes;
  final List<CatalogItem> catalogItems;
  final List<Relationship> relationships;
  final List<MetricEvent> metrics;

  @override
  Widget build(BuildContext context) {
    final words =
        scenes.fold<int>(0, (sum, scene) => sum + scene.actualWordCount);
    final target = project?.wordTarget;
    final progress = target == null || target <= 0 ? null : words / target;
    final today = DateTime.now().toLocal();
    final todaySaves = metrics
        .where((event) =>
            event.eventType == 'scene.saved' &&
            event.occurredAt.toLocal().year == today.year &&
            event.occurredAt.toLocal().month == today.month &&
            event.occurredAt.toLocal().day == today.day)
        .length;
    return _SimpleWorkspace(
      title: copy.t('statistics'),
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(copy.t('statisticsBody'),
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 20),
          Wrap(
            spacing: 24,
            runSpacing: 18,
            children: [
              _StatisticValue(label: copy.t('words'), value: '$words'),
              _StatisticValue(
                  label: copy.t('chapters'), value: '${chapters.length}'),
              _StatisticValue(
                  label: copy.t('scenes'), value: '${scenes.length}'),
              _StatisticValue(
                  label: copy.t('catalog'), value: '${catalogItems.length}'),
              _StatisticValue(
                  label: copy.t('relationships'),
                  value: '${relationships.length}'),
              _StatisticValue(
                  label: copy.t('todaySaves'), value: '$todaySaves'),
            ],
          ),
          if (progress != null) ...[
            const SizedBox(height: 24),
            Text(
              '${copy.t('targetProgress')}: $words / $target',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(value: progress.clamp(0, 1)),
          ],
        ],
      ),
    );
  }
}

final class _StatisticValue extends StatelessWidget {
  const _StatisticValue({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return SizedBox(
      width: 150,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: color.outlineVariant)),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: color.onSurfaceVariant,
                      )),
              const SizedBox(height: 4),
              Text(value, style: Theme.of(context).textTheme.headlineSmall),
            ],
          ),
        ),
      ),
    );
  }
}

final class _DashboardPulseMetric extends StatelessWidget {
  const _DashboardPulseMetric({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return SizedBox(
      width: 126,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ],
      ),
    );
  }
}

final class _DashboardSection extends StatelessWidget {
  const _DashboardSection({
    required this.title,
    required this.body,
    required this.child,
  });

  final String title;
  final String body;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: color.outlineVariant)),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              body,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

final class _DashboardAction {
  const _DashboardAction({
    required this.icon,
    required this.title,
    required this.body,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String body;
  final VoidCallback onTap;
}

final class _DashboardActionRow extends StatelessWidget {
  const _DashboardActionRow({required this.action});

  final _DashboardAction action;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: action.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 9),
        child: Row(
          children: [
            Icon(action.icon, color: color.primary, size: 21),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(action.title,
                      style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 2),
                  Text(
                    action.body,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: color.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: color.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

final class _DashboardHealthRow extends StatelessWidget {
  const _DashboardHealthRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.tone,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color tone;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 9),
        child: Row(
          children: [
            Icon(icon, color: tone, size: 21),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: tone,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            if (onTap != null) ...[
              const SizedBox(width: 8),
              Icon(Icons.chevron_right, color: color.onSurfaceVariant),
            ],
          ],
        ),
      ),
    );
  }
}

final class _DashboardSceneRow extends StatelessWidget {
  const _DashboardSceneRow({
    required this.copy,
    required this.scene,
    required this.onTap,
  });

  final WritelerCopy copy;
  final Scene scene;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final missing = _missingScenePlanningLabels(scene, copy);
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 9),
        child: Row(
          children: [
            Icon(Icons.notes_outlined, color: color.primary, size: 21),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    scene.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 2),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        '${scene.actualWordCount} ${copy.t('words')}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: color.onSurfaceVariant,
                            ),
                      ),
                      _StatusChip(
                        status: scene.status,
                        label: _draftStatusLabel(
                          scene.status,
                          copy.languageCode,
                        ),
                        compact: true,
                      ),
                      if (missing.isNotEmpty)
                        Text(
                          '${copy.t('missing')}: ${missing.join(', ')}',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: color.error,
                                  ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: color.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

final class _DashboardSignalChip extends StatelessWidget {
  const _DashboardSignalChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return ActionChip(
      avatar: Icon(icon, size: 18),
      label: Text('$label: $value'),
      onPressed: onTap,
      side: BorderSide(color: color.outlineVariant),
      backgroundColor: color.surfaceContainerLow,
    );
  }
}

int _compareScenesByReadingOrder(Scene a, Scene b) {
  final orderCompare = a.orderIndex.compareTo(b.orderIndex);
  if (orderCompare != 0) return orderCompare;
  return a.createdAt.compareTo(b.createdAt);
}

int _compareScenesByPlanningUrgency(Scene a, Scene b) {
  final urgencyCompare =
      _scenePlanningUrgencyScore(b).compareTo(_scenePlanningUrgencyScore(a));
  if (urgencyCompare != 0) return urgencyCompare;
  return _compareScenesByReadingOrder(a, b);
}

int _scenePlanningUrgencyScore(Scene scene) {
  var score = 0;
  if (scene.summary.trim().isEmpty) score += 3;
  if (scene.goal?.trim().isEmpty != false) score += 4;
  if (scene.conflict?.trim().isEmpty != false) score += 4;
  if (scene.outcome?.trim().isEmpty != false) score += 4;
  if (scene.manuscriptText.trim().isNotEmpty) score += 5;
  score += _draftStatusPlanningUrgency(scene.status);
  return score;
}

int _draftStatusPlanningUrgency(DraftStatus status) {
  return switch (status) {
    DraftStatus.needsRevision => 6,
    DraftStatus.drafting => 5,
    DraftStatus.revised => 4,
    DraftStatus.reviewed => 3,
    DraftStatus.outlined => 3,
    DraftStatus.planned => 2,
    DraftStatus.idea => 1,
    DraftStatus.locked => -6,
    DraftStatus.archived => -10,
  };
}

int _linkedSceneCountForCatalogItem(
  CatalogItem item,
  List<Relationship> relationships,
) {
  return relationships
      .where(
        (relationship) =>
            relationship.source.type == EntityType.scene &&
            relationship.target.type == item.type &&
            relationship.target.id == item.id &&
            relationship.relationshipType == 'appearsIn',
      )
      .length;
}

List<Scene> _linkedScenesForCatalogItem(
  CatalogItem item,
  List<Relationship> relationships,
  List<Scene> scenes,
) {
  final sceneIds = relationships
      .where(
        (relationship) =>
            relationship.relationshipType == 'appearsIn' &&
            ((relationship.source.type == EntityType.scene &&
                    relationship.target.type == item.type &&
                    relationship.target.id == item.id) ||
                (relationship.target.type == EntityType.scene &&
                    relationship.source.type == item.type &&
                    relationship.source.id == item.id)),
      )
      .map((relationship) => relationship.source.type == EntityType.scene
          ? relationship.source.id
          : relationship.target.id)
      .toSet();
  final linked = scenes.where((scene) => sceneIds.contains(scene.id)).toList();
  linked.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
  return linked;
}

final class _StructureMotifRow {
  const _StructureMotifRow({
    required this.label,
    required this.count,
    required this.share,
  });

  final String label;
  final int count;
  final double share;
}

List<_StructureMotifRow> _structureMotifRows(
  List<Scene> scenes,
  WritelerCopy copy,
) {
  final counts = <String, int>{};
  for (final scene in scenes) {
    final sceneType = scene.sceneType.trim();
    if (sceneType.isNotEmpty) {
      final label = '${copy.t('sceneType')}: $sceneType';
      counts[label] = (counts[label] ?? 0) + 1;
    }
    final tone = scene.emotionalTone?.trim();
    if (tone != null && tone.isNotEmpty) {
      final label = '${copy.t('emotionalTone')}: $tone';
      counts[label] = (counts[label] ?? 0) + 1;
    }
    final status =
        '${copy.t('status')}: ${_draftStatusLabel(scene.status, copy.languageCode)}';
    counts[status] = (counts[status] ?? 0) + 1;
  }
  if (counts.isEmpty) return const [];
  var maxCount = 1;
  for (final count in counts.values) {
    if (count > maxCount) maxCount = count;
  }
  final rows = [
    for (final entry in counts.entries)
      _StructureMotifRow(
        label: entry.key,
        count: entry.value,
        share: entry.value / maxCount,
      ),
  ];
  rows.sort((a, b) {
    final countCompare = b.count.compareTo(a.count);
    if (countCompare != 0) return countCompare;
    return a.label.compareTo(b.label);
  });
  return rows;
}
