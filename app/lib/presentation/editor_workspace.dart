part of '../main.dart';

// Manuscript editor, scene navigator, focus mode, autosave status, and scene planning widgets.

final class _ProjectWorkspace extends StatelessWidget {
  const _ProjectWorkspace({
    required this.copy,
    required this.project,
    required this.chapters,
    required this.catalogItems,
    required this.relationships,
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
    required this.onSelectScene,
    required this.onDeleteScene,
    required this.onSceneChapterChanged,
    required this.onToggleSceneCatalogLink,
    required this.onSceneStatusChanged,
    required this.onCreateChapter,
    required this.onCreateScene,
    required this.onSaveScene,
  });

  final WritelerCopy copy;
  final Project? project;
  final List<Chapter> chapters;
  final List<CatalogItem> catalogItems;
  final List<Relationship> relationships;
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
  final ValueChanged<Scene> onSelectScene;
  final ValueChanged<Scene> onDeleteScene;
  final ValueChanged<String?> onSceneChapterChanged;
  final void Function(CatalogItem item, bool selected) onToggleSceneCatalogLink;
  final ValueChanged<DraftStatus> onSceneStatusChanged;
  final VoidCallback onCreateChapter;
  final VoidCallback onCreateScene;
  final VoidCallback onSaveScene;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final project = this.project;
    if (project == null) {
      return _EmptyWorkspace(copy: copy);
    }

    return Column(
      children: [
        SizedBox(
          height: 64,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    project.title,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                FilledButton.icon(
                  onPressed: onCreateScene,
                  icon: const Icon(Icons.add),
                  label: Text(copy.t('newScene')),
                ),
                const SizedBox(width: 8),
                IconButton.outlined(
                  tooltip: copy.t('newChapter'),
                  onPressed: onCreateChapter,
                  icon: const Icon(Icons.create_new_folder_outlined),
                ),
              ],
            ),
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: Row(
            children: [
              SizedBox(
                width: 320,
                child: scenes.isEmpty
                    ? _NoScenes(copy: copy, onCreateScene: onCreateScene)
                    : _SceneNavigator(
                        copy: copy,
                        chapters: chapters,
                        scenes: scenes,
                        selectedScene: selectedScene,
                        onSelectScene: onSelectScene,
                        onDeleteScene: onDeleteScene,
                      ),
              ),
              const VerticalDivider(width: 1),
              Expanded(
                child: selectedScene == null
                    ? Center(
                        child: Text(
                          copy.t('selectScene'),
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: color.onSurfaceVariant,
                                  ),
                        ),
                      )
                    : _SceneEditor(
                        copy: copy,
                        scene: selectedScene!,
                        chapters: chapters,
                        catalogItems: catalogItems,
                        relationships: relationships,
                        controller: manuscriptController,
                        summaryController: summaryController,
                        goalController: goalController,
                        conflictController: conflictController,
                        outcomeController: outcomeController,
                        wordTargetController: wordTargetController,
                        selectedSceneStatus: selectedSceneStatus,
                        selectedSceneChapterId: selectedSceneChapterId,
                        saveState: sceneSaveState,
                        lastSavedAt: lastSceneSavedAt,
                        onSceneChapterChanged: onSceneChapterChanged,
                        onToggleSceneCatalogLink: onToggleSceneCatalogLink,
                        onSceneStatusChanged: onSceneStatusChanged,
                        onSaveScene: onSaveScene,
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

final class _NoScenes extends StatelessWidget {
  const _NoScenes({
    required this.copy,
    required this.onCreateScene,
  });

  final WritelerCopy copy;
  final VoidCallback onCreateScene;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.auto_awesome_motion_outlined, color: color.primary),
          const SizedBox(height: 16),
          Text(copy.t('noScenesTitle'),
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            copy.t('noScenesBody'),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: color.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: onCreateScene,
            icon: const Icon(Icons.add),
            label: Text(copy.t('newScene')),
          ),
        ],
      ),
    );
  }
}

final class _SceneNavigator extends StatelessWidget {
  const _SceneNavigator({
    required this.copy,
    required this.chapters,
    required this.scenes,
    required this.selectedScene,
    required this.onSelectScene,
    required this.onDeleteScene,
  });

  final WritelerCopy copy;
  final List<Chapter> chapters;
  final List<Scene> scenes;
  final Scene? selectedScene;
  final ValueChanged<Scene> onSelectScene;
  final ValueChanged<Scene> onDeleteScene;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final groups = <_SceneNavigatorGroup>[
      for (final chapter in chapters)
        _SceneNavigatorGroup(
          title: chapter.title,
          scenes: scenes
              .where((scene) => scene.chapterId == chapter.id)
              .toList(growable: false),
        ),
      _SceneNavigatorGroup(
        title: copy.t('noChapter'),
        scenes: scenes
            .where((scene) => scene.chapterId == null)
            .toList(growable: false),
      ),
    ].where((group) => group.scenes.isNotEmpty).toList(growable: false);

    final words = scenes.fold<int>(
      0,
      (sum, scene) => sum + scene.actualWordCount,
    );
    final planningGaps = scenes
        .where((scene) => _missingScenePlanningLabels(scene, copy).isNotEmpty)
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
          child: Row(
            children: [
              Expanded(
                child: _EditorMiniMetric(
                  label: copy.t('scenes'),
                  value: '${scenes.length}',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _EditorMiniMetric(
                  label: copy.t('words'),
                  value: '$words',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _EditorMiniMetric(
                  label: copy.t('missing'),
                  value: '$planningGaps',
                ),
              ),
            ],
          ),
        ),
        Divider(height: 1, color: color.outlineVariant),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
            itemCount: groups.length,
            itemBuilder: (context, groupIndex) {
              final group = groups[groupIndex];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 4, 8, 6),
                      child: Text(
                        '${group.title} - ${group.scenes.length}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:
                            Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: color.onSurfaceVariant,
                                  fontWeight: FontWeight.w800,
                                ),
                      ),
                    ),
                    for (final scene in group.scenes)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _SceneNavigatorTile(
                          copy: copy,
                          scene: scene,
                          selected: selectedScene?.id == scene.id,
                          onSelect: () => onSelectScene(scene),
                          onDelete: () => onDeleteScene(scene),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

final class _SceneNavigatorGroup {
  const _SceneNavigatorGroup({
    required this.title,
    required this.scenes,
  });

  final String title;
  final List<Scene> scenes;
}

final class _SceneNavigatorTile extends StatelessWidget {
  const _SceneNavigatorTile({
    required this.copy,
    required this.scene,
    required this.selected,
    required this.onSelect,
    required this.onDelete,
  });

  final WritelerCopy copy;
  final Scene scene;
  final bool selected;
  final VoidCallback onSelect;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final missing = _missingScenePlanningLabels(scene, copy);
    return Semantics(
      selected: selected,
      button: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onSelect,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          padding: const EdgeInsets.fromLTRB(10, 9, 6, 9),
          decoration: BoxDecoration(
            color: selected
                ? color.primary.withValues(alpha: 0.12)
                : color.surfaceContainerLow,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected ? color.primary : color.outlineVariant,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(
                  selected ? Icons.edit_note : Icons.notes_outlined,
                  size: 20,
                  color: selected ? color.primary : color.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      scene.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${scene.actualWordCount} ${copy.t('words')} - '
                      '${_draftStatusLabel(scene.status, copy.languageCode)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: color.onSurfaceVariant,
                          ),
                    ),
                    if (missing.isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Text(
                        '${copy.t('missing')}: ${missing.join(', ')}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: color.error,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                tooltip: copy.t('deleteScene'),
                visualDensity: VisualDensity.compact,
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final class _EditorMiniMetric extends StatelessWidget {
  const _EditorMiniMetric({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.surfaceContainerLow,
        border: Border.all(color: color.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
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
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

final class _SceneEditor extends StatefulWidget {
  const _SceneEditor({
    required this.copy,
    required this.scene,
    required this.chapters,
    required this.catalogItems,
    required this.relationships,
    required this.controller,
    required this.summaryController,
    required this.goalController,
    required this.conflictController,
    required this.outcomeController,
    required this.wordTargetController,
    required this.selectedSceneStatus,
    required this.selectedSceneChapterId,
    required this.saveState,
    required this.lastSavedAt,
    required this.onSceneChapterChanged,
    required this.onToggleSceneCatalogLink,
    required this.onSceneStatusChanged,
    required this.onSaveScene,
  });

  final WritelerCopy copy;
  final Scene scene;
  final List<Chapter> chapters;
  final List<CatalogItem> catalogItems;
  final List<Relationship> relationships;
  final TextEditingController controller;
  final TextEditingController summaryController;
  final TextEditingController goalController;
  final TextEditingController conflictController;
  final TextEditingController outcomeController;
  final TextEditingController wordTargetController;
  final DraftStatus selectedSceneStatus;
  final String? selectedSceneChapterId;
  final _SceneSaveState saveState;
  final DateTime? lastSavedAt;
  final ValueChanged<String?> onSceneChapterChanged;
  final void Function(CatalogItem item, bool selected) onToggleSceneCatalogLink;
  final ValueChanged<DraftStatus> onSceneStatusChanged;
  final VoidCallback onSaveScene;

  @override
  State<_SceneEditor> createState() => _SceneEditorState();
}

final class _SceneEditorState extends State<_SceneEditor> {
  late final TextEditingController _searchController = TextEditingController();
  late final TextEditingController _replaceController = TextEditingController();
  bool _focusMode = false;
  bool _showSearch = false;

  @override
  void dispose() {
    _searchController.dispose();
    _replaceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final copy = widget.copy;
    final scene = widget.scene;
    final color = Theme.of(context).colorScheme;
    final manuscriptField = _ManuscriptField(
      copy: copy,
      controller: widget.controller,
      focusMode: _focusMode,
    );
    final inspector = _SceneInspector(
      copy: copy,
      scene: scene,
      chapters: widget.chapters,
      catalogItems: widget.catalogItems,
      relationships: widget.relationships,
      summaryController: widget.summaryController,
      goalController: widget.goalController,
      conflictController: widget.conflictController,
      outcomeController: widget.outcomeController,
      wordTargetController: widget.wordTargetController,
      selectedSceneStatus: widget.selectedSceneStatus,
      selectedSceneChapterId: widget.selectedSceneChapterId,
      onSceneChapterChanged: widget.onSceneChapterChanged,
      onSceneStatusChanged: widget.onSceneStatusChanged,
      onToggleSceneCatalogLink: widget.onToggleSceneCatalogLink,
    );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      padding: EdgeInsets.all(_focusMode ? 32 : 24),
      color: _focusMode ? color.surfaceContainerLowest : Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  scene.title,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              const SizedBox(width: 12),
              _SaveStatePill(
                copy: copy,
                state: widget.saveState,
                savedAt: widget.lastSavedAt,
              ),
              const SizedBox(width: 8),
              Tooltip(
                message: copy.t('searchReplace'),
                child: IconButton.outlined(
                  isSelected: _showSearch,
                  onPressed: () => setState(() => _showSearch = !_showSearch),
                  icon: const Icon(Icons.find_replace_outlined),
                ),
              ),
              const SizedBox(width: 8),
              Tooltip(
                message:
                    _focusMode ? copy.t('exitFocusMode') : copy.t('focusMode'),
                child: IconButton.outlined(
                  isSelected: _focusMode,
                  onPressed: () => setState(() => _focusMode = !_focusMode),
                  icon: Icon(
                      _focusMode ? Icons.fullscreen_exit : Icons.fullscreen),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: widget.onSaveScene,
                icon: const Icon(Icons.save_outlined),
                label: Text(copy.t('saveScene')),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: widget.controller,
            builder: (context, value, child) {
              return _ManuscriptToolbar(
                copy: copy,
                text: value.text,
                targetText: widget.wordTargetController.text,
              );
            },
          ),
          if (_showSearch) ...[
            const SizedBox(height: 12),
            _ManuscriptSearchBar(
              copy: copy,
              manuscriptController: widget.controller,
              searchController: _searchController,
              replaceController: _replaceController,
              onChanged: () => setState(() {}),
            ),
          ],
          const SizedBox(height: 12),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 980;
                if (_focusMode) {
                  return manuscriptField;
                }
                if (compact) {
                  return Column(
                    children: [
                      Expanded(child: manuscriptField),
                      const SizedBox(height: 12),
                      SizedBox(height: 280, child: inspector),
                    ],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: manuscriptField),
                    const SizedBox(width: 18),
                    SizedBox(width: 330, child: inspector),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

final class _ManuscriptField extends StatelessWidget {
  const _ManuscriptField({
    required this.copy,
    required this.controller,
    required this.focusMode,
  });

  final WritelerCopy copy;
  final TextEditingController controller;
  final bool focusMode;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: focusMode
            ? color.surfaceContainerLowest
            : color.surfaceContainerLow,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: focusMode
              ? color.primary.withValues(alpha: 0.42)
              : color.outlineVariant,
        ),
      ),
      child: TextField(
        controller: controller,
        expands: true,
        maxLines: null,
        minLines: null,
        textAlignVertical: TextAlignVertical.top,
        cursorColor: color.primary,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontSize: focusMode ? 19 : 17,
              height: 1.7,
            ),
        decoration: InputDecoration(
          labelText: copy.t('manuscript'),
          alignLabelWithHint: true,
          filled: false,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.all(22),
        ),
      ),
    );
  }
}

final class _SaveStatePill extends StatelessWidget {
  const _SaveStatePill({
    required this.copy,
    required this.state,
    required this.savedAt,
  });

  final WritelerCopy copy;
  final _SceneSaveState state;
  final DateTime? savedAt;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final (icon, label, tone) = switch (state) {
      _SceneSaveState.saved => (
          Icons.cloud_done_outlined,
          _savedLabel(copy, savedAt),
          color.primary,
        ),
      _SceneSaveState.unsaved => (
          Icons.edit_outlined,
          copy.t('autosavePending'),
          color.tertiary,
        ),
      _SceneSaveState.saving => (
          Icons.sync_outlined,
          copy.t('autosaveSaving'),
          color.primary,
        ),
      _SceneSaveState.error => (
          Icons.error_outline,
          copy.t('autosaveError'),
          color.error,
        ),
    };

    return Semantics(
      label: label,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: tone.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: tone.withValues(alpha: 0.34)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 17, color: tone),
            const SizedBox(width: 7),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: tone,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  static String _savedLabel(WritelerCopy copy, DateTime? savedAt) {
    if (savedAt == null) return copy.t('autosaveSaved');
    final local = savedAt.toLocal();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '${copy.t('autosaveSaved')} $hour:$minute';
  }
}

final class _SceneInspector extends StatelessWidget {
  const _SceneInspector({
    required this.copy,
    required this.scene,
    required this.chapters,
    required this.catalogItems,
    required this.relationships,
    required this.summaryController,
    required this.goalController,
    required this.conflictController,
    required this.outcomeController,
    required this.wordTargetController,
    required this.selectedSceneStatus,
    required this.selectedSceneChapterId,
    required this.onSceneChapterChanged,
    required this.onSceneStatusChanged,
    required this.onToggleSceneCatalogLink,
  });

  final WritelerCopy copy;
  final Scene scene;
  final List<Chapter> chapters;
  final List<CatalogItem> catalogItems;
  final List<Relationship> relationships;
  final TextEditingController summaryController;
  final TextEditingController goalController;
  final TextEditingController conflictController;
  final TextEditingController outcomeController;
  final TextEditingController wordTargetController;
  final DraftStatus selectedSceneStatus;
  final String? selectedSceneChapterId;
  final ValueChanged<String?> onSceneChapterChanged;
  final ValueChanged<DraftStatus> onSceneStatusChanged;
  final void Function(CatalogItem item, bool selected) onToggleSceneCatalogLink;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.surfaceContainerLow,
        border: Border.all(color: color.outlineVariant),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          Row(
            children: [
              Icon(Icons.tune_outlined, color: color.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                copy.t('sceneInspector'),
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ],
          ),
          const SizedBox(height: 12),
          _ScenePlanningFields(
            copy: copy,
            summaryController: summaryController,
            goalController: goalController,
            conflictController: conflictController,
            outcomeController: outcomeController,
            wordTargetController: wordTargetController,
            selectedSceneStatus: selectedSceneStatus,
            chapters: chapters,
            selectedSceneChapterId: selectedSceneChapterId,
            onSceneChapterChanged: onSceneChapterChanged,
            onSceneStatusChanged: onSceneStatusChanged,
          ),
          const SizedBox(height: 16),
          Divider(height: 1, color: color.outlineVariant),
          const SizedBox(height: 14),
          _SceneContextLinks(
            copy: copy,
            scene: scene,
            catalogItems: catalogItems,
            relationships: relationships,
            onToggleLink: onToggleSceneCatalogLink,
          ),
        ],
      ),
    );
  }
}

final class _ManuscriptToolbar extends StatelessWidget {
  const _ManuscriptToolbar({
    required this.copy,
    required this.text,
    required this.targetText,
  });

  final WritelerCopy copy;
  final String text;
  final String targetText;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final words = _countWords(text);
    final characters = text.characters.length;
    final target = int.tryParse(targetText);
    final progress =
        target == null || target <= 0 ? null : (words / target).clamp(0.0, 1.0);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.surfaceContainerLow,
        border: Border.all(color: color.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            _EditorStat(label: copy.t('words'), value: '$words'),
            const SizedBox(width: 16),
            _EditorStat(label: copy.t('characterCount'), value: '$characters'),
            if (target != null && target > 0) ...[
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${copy.t('targetProgress')}: $words / $target',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 6),
                    LinearProgressIndicator(value: progress),
                  ],
                ),
              ),
            ] else
              const Spacer(),
          ],
        ),
      ),
    );
  }
}

final class _EditorStat extends StatelessWidget {
  const _EditorStat({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return SizedBox(
      width: 84,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

final class _ManuscriptSearchBar extends StatelessWidget {
  const _ManuscriptSearchBar({
    required this.copy,
    required this.manuscriptController,
    required this.searchController,
    required this.replaceController,
    required this.onChanged,
  });

  final WritelerCopy copy;
  final TextEditingController manuscriptController;
  final TextEditingController searchController;
  final TextEditingController replaceController;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final matchCount =
        _countMatches(manuscriptController.text, searchController.text);
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 760;
        final searchField = TextField(
          controller: searchController,
          onChanged: (_) => onChanged(),
          decoration: InputDecoration(
            labelText: copy.t('findText'),
            border: const OutlineInputBorder(),
            isDense: true,
          ),
        );
        final replaceField = TextField(
          controller: replaceController,
          decoration: InputDecoration(
            labelText: copy.t('replaceWith'),
            border: const OutlineInputBorder(),
            isDense: true,
          ),
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (compact)
              Column(
                children: [
                  searchField,
                  const SizedBox(height: 12),
                  replaceField,
                ],
              )
            else
              Row(
                children: [
                  Expanded(child: searchField),
                  const SizedBox(width: 12),
                  Expanded(child: replaceField),
                ],
              ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text('${copy.t('matches')}: $matchCount'),
                OutlinedButton.icon(
                  onPressed: matchCount == 0 ? null : _selectNextMatch,
                  icon: const Icon(Icons.keyboard_arrow_down),
                  label: Text(copy.t('nextMatch')),
                ),
                OutlinedButton.icon(
                  onPressed: matchCount == 0 ? null : _replaceCurrentOrNext,
                  icon: const Icon(Icons.find_replace),
                  label: Text(copy.t('replaceNext')),
                ),
                FilledButton.icon(
                  onPressed: matchCount == 0 ? null : _replaceAll,
                  icon: const Icon(Icons.done_all),
                  label: Text(copy.t('replaceAll')),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _selectNextMatch() {
    final query = searchController.text;
    final text = manuscriptController.text;
    final range = _nextMatchRange(
      text: text,
      query: query,
      from: manuscriptController.selection.end,
    );
    if (range == null) return;
    manuscriptController.selection =
        TextSelection(baseOffset: range.start, extentOffset: range.end);
    onChanged();
  }

  void _replaceCurrentOrNext() {
    final query = searchController.text;
    if (query.isEmpty) return;
    final text = manuscriptController.text;
    final selection = manuscriptController.selection;
    var start = selection.start;
    var end = selection.end;
    if (start < 0 || end < 0 || start == end) {
      final range =
          _nextMatchRange(text: text, query: query, from: selection.end);
      if (range == null) return;
      start = range.start;
      end = range.end;
    }
    final selected = text.substring(start, end);
    if (selected.toLowerCase() != query.toLowerCase()) {
      final range = _nextMatchRange(text: text, query: query, from: end);
      if (range == null) return;
      start = range.start;
      end = range.end;
    }
    final replacement = replaceController.text;
    final updated = text.replaceRange(start, end, replacement);
    manuscriptController.value = TextEditingValue(
      text: updated,
      selection: TextSelection.collapsed(offset: start + replacement.length),
    );
    onChanged();
  }

  void _replaceAll() {
    final query = searchController.text;
    if (query.isEmpty) return;
    final escaped = RegExp.escape(query);
    final updated = manuscriptController.text.replaceAll(
      RegExp(escaped, caseSensitive: false),
      replaceController.text,
    );
    manuscriptController.value = TextEditingValue(
      text: updated,
      selection: TextSelection.collapsed(offset: updated.length),
    );
    onChanged();
  }
}

final class _ScenePlanningFields extends StatelessWidget {
  const _ScenePlanningFields({
    required this.copy,
    required this.summaryController,
    required this.goalController,
    required this.conflictController,
    required this.outcomeController,
    required this.wordTargetController,
    required this.selectedSceneStatus,
    required this.chapters,
    required this.selectedSceneChapterId,
    required this.onSceneChapterChanged,
    required this.onSceneStatusChanged,
  });

  final WritelerCopy copy;
  final TextEditingController summaryController;
  final TextEditingController goalController;
  final TextEditingController conflictController;
  final TextEditingController outcomeController;
  final TextEditingController wordTargetController;
  final DraftStatus selectedSceneStatus;
  final List<Chapter> chapters;
  final String? selectedSceneChapterId;
  final ValueChanged<String?> onSceneChapterChanged;
  final ValueChanged<DraftStatus> onSceneStatusChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 760;
        final statusAndTarget = _responsivePair(
          compact: compact,
          firstFlex: 2,
          first: DropdownButtonFormField<DraftStatus>(
            key: ValueKey(selectedSceneStatus),
            initialValue: selectedSceneStatus,
            decoration: InputDecoration(
              labelText: copy.t('status'),
              border: const OutlineInputBorder(),
              isDense: true,
            ),
            items: [
              for (final status in DraftStatus.values)
                DropdownMenuItem(
                  value: status,
                  child: Text(_draftStatusLabel(status, copy.languageCode)),
                ),
            ],
            onChanged: (status) {
              if (status != null) onSceneStatusChanged(status);
            },
          ),
          second: TextField(
            controller: wordTargetController,
            decoration: InputDecoration(
              labelText: copy.t('wordTarget'),
              border: const OutlineInputBorder(),
              isDense: true,
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
        );

        final goalAndConflict = _responsivePair(
          compact: compact,
          first: _planningTextField(
            controller: goalController,
            label: copy.t('goal'),
            maxLines: 2,
          ),
          second: _planningTextField(
            controller: conflictController,
            label: copy.t('conflict'),
            maxLines: 2,
          ),
        );

        return Column(
          children: [
            DropdownButtonFormField<String?>(
              key: ValueKey(selectedSceneChapterId ?? 'no-chapter'),
              initialValue: selectedSceneChapterId,
              decoration: InputDecoration(
                labelText: copy.t('chapter'),
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              items: [
                DropdownMenuItem<String?>(
                  value: null,
                  child: Text(copy.t('noChapter')),
                ),
                for (final chapter in chapters)
                  DropdownMenuItem<String?>(
                    value: chapter.id,
                    child: Text(chapter.title),
                  ),
              ],
              onChanged: onSceneChapterChanged,
            ),
            const SizedBox(height: 12),
            statusAndTarget,
            const SizedBox(height: 12),
            _planningTextField(
              controller: summaryController,
              label: copy.t('summary'),
              maxLines: compact ? 3 : 2,
            ),
            const SizedBox(height: 12),
            goalAndConflict,
            const SizedBox(height: 12),
            _planningTextField(
              controller: outcomeController,
              label: copy.t('outcome'),
              maxLines: 2,
            ),
          ],
        );
      },
    );
  }

  Widget _responsivePair({
    required bool compact,
    required Widget first,
    required Widget second,
    int firstFlex = 1,
  }) {
    if (compact) {
      return Column(
        children: [
          first,
          const SizedBox(height: 12),
          second,
        ],
      );
    }

    return Row(
      children: [
        Expanded(flex: firstFlex, child: first),
        const SizedBox(width: 12),
        Expanded(child: second),
      ],
    );
  }

  Widget _planningTextField({
    required TextEditingController controller,
    required String label,
    required int maxLines,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        alignLabelWithHint: true,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
    );
  }
}

final class _SceneContextLinks extends StatelessWidget {
  const _SceneContextLinks({
    required this.copy,
    required this.scene,
    required this.catalogItems,
    required this.relationships,
    required this.onToggleLink,
  });

  final WritelerCopy copy;
  final Scene scene;
  final List<CatalogItem> catalogItems;
  final List<Relationship> relationships;
  final void Function(CatalogItem item, bool selected) onToggleLink;

  @override
  Widget build(BuildContext context) {
    final relevantItems = catalogItems
        .where(
          (item) =>
              item.type == EntityType.character ||
              item.type == EntityType.location ||
              item.type == EntityType.object,
        )
        .toList();
    if (relevantItems.isEmpty) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Text(
          copy.t('sceneContextEmpty'),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(copy.t('sceneContext'),
            style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final item in relevantItems)
              FilterChip(
                avatar: Icon(_catalogIcon(item.type), size: 18),
                label: Text(item.name),
                selected: _isLinked(item),
                onSelected: (selected) => onToggleLink(item, selected),
              ),
          ],
        ),
      ],
    );
  }

  bool _isLinked(CatalogItem item) {
    return relationships.any(
      (relationship) =>
          relationship.source.type == EntityType.scene &&
          relationship.source.id == scene.id &&
          relationship.target.type == item.type &&
          relationship.target.id == item.id &&
          relationship.relationshipType == 'appearsIn',
    );
  }
}
