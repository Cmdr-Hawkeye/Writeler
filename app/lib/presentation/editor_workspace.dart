part of '../main.dart';

// Manuscript editor, scene navigator, focus mode, autosave status, and scene planning widgets.

final class _ProjectWorkspace extends StatefulWidget {
  const _ProjectWorkspace({
    required this.copy,
    required this.project,
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
  final Project? project;
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
  State<_ProjectWorkspace> createState() => _ProjectWorkspaceState();
}

final class _ProjectWorkspaceState extends State<_ProjectWorkspace> {
  bool _focusMode = false;
  double _editorFontSize = 18;

  @override
  void didUpdateWidget(covariant _ProjectWorkspace oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedScene == null && _focusMode) {
      _focusMode = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final project = widget.project;
    if (project == null) {
      return _EmptyWorkspace(copy: widget.copy);
    }

    return Column(
      children: [
        if (!_focusMode) ...[
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
                    onPressed: widget.onCreateScene,
                    icon: const Icon(Icons.add),
                    label: Text(widget.copy.t('newScene')),
                  ),
                  const SizedBox(width: 8),
                  IconButton.outlined(
                    tooltip: widget.copy.t('newChapter'),
                    onPressed: widget.onCreateChapter,
                    icon: const Icon(Icons.create_new_folder_outlined),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
        ],
        Expanded(
          child: Row(
            children: [
              if (!_focusMode) ...[
                SizedBox(
                  width: 320,
                  child: widget.scenes.isEmpty
                      ? _NoScenes(
                          copy: widget.copy,
                          onCreateScene: widget.onCreateScene,
                        )
                      : _SceneNavigator(
                          copy: widget.copy,
                          chapters: widget.chapters,
                          scenes: widget.scenes,
                          selectedScene: widget.selectedScene,
                          onSelectScene: widget.onSelectScene,
                          onDeleteScene: widget.onDeleteScene,
                        ),
                ),
                const VerticalDivider(width: 1),
              ],
              Expanded(
                child: widget.selectedScene == null
                    ? Center(
                        child: Text(
                          widget.copy.t('selectScene'),
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: color.onSurfaceVariant,
                                  ),
                        ),
                      )
                    : _SceneEditor(
                        copy: widget.copy,
                        scene: widget.selectedScene!,
                        chapters: widget.chapters,
                        catalogItems: widget.catalogItems,
                        relationships: widget.relationships,
                        suggestions: widget.suggestions,
                        controller: widget.manuscriptController,
                        summaryController: widget.summaryController,
                        goalController: widget.goalController,
                        conflictController: widget.conflictController,
                        outcomeController: widget.outcomeController,
                        wordTargetController: widget.wordTargetController,
                        selectedSceneStatus: widget.selectedSceneStatus,
                        selectedSceneChapterId: widget.selectedSceneChapterId,
                        saveState: widget.sceneSaveState,
                        lastSavedAt: widget.lastSceneSavedAt,
                        focusMode: _focusMode,
                        editorFontSize: _editorFontSize,
                        onEditorFontSizeChanged: (value) =>
                            setState(() => _editorFontSize = value),
                        onFocusModeChanged: (value) =>
                            setState(() => _focusMode = value),
                        onSceneChapterChanged: widget.onSceneChapterChanged,
                        onToggleSceneCatalogLink:
                            widget.onToggleSceneCatalogLink,
                        onAddExistingSceneCatalogItems:
                            widget.onAddExistingSceneCatalogItems,
                        onCreateSceneCatalogItem:
                            widget.onCreateSceneCatalogItem,
                        onSceneStatusChanged: widget.onSceneStatusChanged,
                        isRequestingAi: widget.isRequestingAi,
                        onRequestSceneAiHelp: widget.onRequestSceneAiHelp,
                        onSaveScene: widget.onSaveScene,
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
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            '${scene.actualWordCount} ${copy.t('words')}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: color.onSurfaceVariant,
                                    ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _StatusChip(
                          status: scene.status,
                          label: _draftStatusLabel(
                              scene.status, copy.languageCode),
                          compact: true,
                        ),
                      ],
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
    required this.suggestions,
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
    required this.focusMode,
    required this.editorFontSize,
    required this.onEditorFontSizeChanged,
    required this.onFocusModeChanged,
    required this.onSceneChapterChanged,
    required this.onToggleSceneCatalogLink,
    required this.onAddExistingSceneCatalogItems,
    required this.onCreateSceneCatalogItem,
    required this.onSceneStatusChanged,
    required this.isRequestingAi,
    required this.onRequestSceneAiHelp,
    required this.onSaveScene,
  });

  final WritelerCopy copy;
  final Scene scene;
  final List<Chapter> chapters;
  final List<CatalogItem> catalogItems;
  final List<Relationship> relationships;
  final List<AISuggestion> suggestions;
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
  final bool focusMode;
  final double editorFontSize;
  final ValueChanged<double> onEditorFontSizeChanged;
  final ValueChanged<bool> onFocusModeChanged;
  final ValueChanged<String?> onSceneChapterChanged;
  final Future<void> Function(CatalogItem item, bool selected)
      onToggleSceneCatalogLink;
  final Future<void> Function(List<CatalogItem> items)
      onAddExistingSceneCatalogItems;
  final ValueChanged<EntityType> onCreateSceneCatalogItem;
  final ValueChanged<DraftStatus> onSceneStatusChanged;
  final bool isRequestingAi;
  final void Function(AITaskKind task, String prompt) onRequestSceneAiHelp;
  final VoidCallback onSaveScene;

  @override
  State<_SceneEditor> createState() => _SceneEditorState();
}

final class _SceneEditorState extends State<_SceneEditor> {
  late final TextEditingController _searchController = TextEditingController();
  late final TextEditingController _replaceController = TextEditingController();
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
      focusMode: widget.focusMode,
      fontSize: widget.editorFontSize,
    );
    final inspector = _SceneInspector(
      copy: copy,
      scene: scene,
      chapters: widget.chapters,
      catalogItems: widget.catalogItems,
      relationships: widget.relationships,
      suggestions: widget.suggestions,
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
      onAddExistingSceneCatalogItems: widget.onAddExistingSceneCatalogItems,
      onCreateSceneCatalogItem: widget.onCreateSceneCatalogItem,
      isRequestingAi: widget.isRequestingAi,
      onRequestSceneAiHelp: widget.onRequestSceneAiHelp,
    );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      padding: EdgeInsets.all(widget.focusMode ? 32 : 24),
      color: color.surfaceContainerLowest,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final compactHeader = constraints.maxWidth < 760;
              final titleRow = Row(
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
                  Flexible(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: _SaveStatePill(
                        copy: copy,
                        state: widget.saveState,
                        savedAt: widget.lastSavedAt,
                      ),
                    ),
                  ),
                ],
              );
              final actions = Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Tooltip(
                    message: copy.t('searchReplace'),
                    child: IconButton.outlined(
                      isSelected: _showSearch,
                      onPressed: () =>
                          setState(() => _showSearch = !_showSearch),
                      icon: const Icon(Icons.find_replace_outlined),
                    ),
                  ),
                  Tooltip(
                    message: copy.t('editorFontSize'),
                    child: PopupMenuButton<double>(
                      tooltip: copy.t('editorFontSize'),
                      icon: const Icon(Icons.format_size),
                      onSelected: widget.onEditorFontSizeChanged,
                      itemBuilder: (context) => [
                        for (final size in const [16.0, 18.0, 20.0, 22.0])
                          PopupMenuItem(
                            value: size,
                            child: Row(
                              children: [
                                Icon(
                                  widget.editorFontSize == size
                                      ? Icons.check
                                      : Icons.text_fields,
                                  size: 18,
                                ),
                                const SizedBox(width: 10),
                                Text('${size.round()} px'),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  Tooltip(
                    message: widget.focusMode
                        ? copy.t('exitFocusMode')
                        : copy.t('focusMode'),
                    child: IconButton.outlined(
                      isSelected: widget.focusMode,
                      onPressed: () =>
                          widget.onFocusModeChanged(!widget.focusMode),
                      icon: Icon(
                        widget.focusMode
                            ? Icons.fullscreen_exit
                            : Icons.fullscreen,
                      ),
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: widget.onSaveScene,
                    icon: const Icon(Icons.save_outlined),
                    label: Text(copy.t('saveScene')),
                  ),
                ],
              );
              if (compactHeader) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    titleRow,
                    const SizedBox(height: 8),
                    Align(alignment: Alignment.centerLeft, child: actions),
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(child: titleRow),
                  const SizedBox(width: 12),
                  actions,
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          if (_showSearch) ...[
            _ManuscriptSearchBar(
              copy: copy,
              manuscriptController: widget.controller,
              searchController: _searchController,
              replaceController: _replaceController,
              onChanged: () => setState(() {}),
            ),
            const SizedBox(height: 12),
          ],
          if (!widget.focusMode) ...[
            _ManuscriptFormatToolbar(
              copy: copy,
              controller: widget.controller,
            ),
            const SizedBox(height: 12),
          ],
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 980;
                if (widget.focusMode) {
                  return manuscriptField;
                }
                if (compact) {
                  final desiredInspectorHeight =
                      (constraints.maxHeight * 0.48).clamp(280.0, 440.0);
                  final inspectorHeight = math.min(
                    desiredInspectorHeight,
                    math.max(220.0, constraints.maxHeight - 180.0),
                  );
                  return Column(
                    children: [
                      Expanded(child: manuscriptField),
                      const SizedBox(height: 12),
                      SizedBox(height: inspectorHeight, child: inspector),
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
          const SizedBox(height: 10),
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
    required this.fontSize,
  });

  final WritelerCopy copy;
  final TextEditingController controller;
  final bool focusMode;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width =
            constraints.maxWidth < 680.0 ? constraints.maxWidth : 680.0;
        return ColoredBox(
          color: color.surfaceContainerLowest,
          child: Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: width,
              height: constraints.maxHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(
                      color: color.outlineVariant.withValues(alpha: 0.92),
                    ),
                    right: BorderSide(
                      color: color.outlineVariant.withValues(alpha: 0.92),
                    ),
                    top: BorderSide(
                      color: color.outlineVariant.withValues(alpha: 0.48),
                    ),
                    bottom: BorderSide(
                      color: color.outlineVariant.withValues(alpha: 0.48),
                    ),
                  ),
                ),
                child: TextField(
                  key: const ValueKey('manuscript-field'),
                  controller: controller,
                  expands: true,
                  maxLines: null,
                  minLines: null,
                  textAlignVertical: TextAlignVertical.top,
                  cursorColor: color.primary,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontFamily: 'Literata',
                        fontFamilyFallback: const [
                          'Iowan Old Style',
                          'Source Serif Pro',
                          'Georgia',
                          'Times New Roman',
                          'serif',
                        ],
                        fontSize: fontSize,
                        height: 1.75,
                      ),
                  decoration: InputDecoration(
                    hintText: copy.t('manuscript'),
                    alignLabelWithHint: true,
                    filled: false,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.fromLTRB(28, 30, 28, 30),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

enum _ManuscriptBlockFormat {
  heading1,
  heading2,
  quote,
  bulletList,
  numberedList,
  sceneBreak,
}

final class _ManuscriptFormatToolbar extends StatelessWidget {
  const _ManuscriptFormatToolbar({
    required this.copy,
    required this.controller,
  });

  final WritelerCopy copy;
  final TextEditingController controller;

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
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Wrap(
          spacing: 6,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _FormatIconButton(
              tooltip: copy.t('formatBold'),
              icon: Icons.format_bold,
              onPressed: () => _wrapSelection(
                prefix: '**',
                suffix: '**',
                placeholder: copy.t('formatPlaceholder'),
              ),
            ),
            _FormatIconButton(
              tooltip: copy.t('formatItalic'),
              icon: Icons.format_italic,
              onPressed: () => _wrapSelection(
                prefix: '*',
                suffix: '*',
                placeholder: copy.t('formatPlaceholder'),
              ),
            ),
            _FormatIconButton(
              tooltip: copy.t('formatEmphasis'),
              icon: Icons.format_underlined,
              onPressed: () => _wrapSelection(
                prefix: '_',
                suffix: '_',
                placeholder: copy.t('formatPlaceholder'),
              ),
            ),
            _ToolbarDivider(color: color.outlineVariant),
            PopupMenuButton<_ManuscriptBlockFormat>(
              tooltip: copy.t('formatParagraphMenu'),
              icon: const Icon(Icons.text_fields),
              onSelected: _applyBlockFormat,
              itemBuilder: (context) => [
                _formatMenuItem(
                  _ManuscriptBlockFormat.heading1,
                  Icons.title,
                  copy.t('formatHeading1'),
                ),
                _formatMenuItem(
                  _ManuscriptBlockFormat.heading2,
                  Icons.short_text,
                  copy.t('formatHeading2'),
                ),
                _formatMenuItem(
                  _ManuscriptBlockFormat.quote,
                  Icons.format_quote,
                  copy.t('formatQuote'),
                ),
                _formatMenuItem(
                  _ManuscriptBlockFormat.bulletList,
                  Icons.format_list_bulleted,
                  copy.t('formatBulletedList'),
                ),
                _formatMenuItem(
                  _ManuscriptBlockFormat.numberedList,
                  Icons.format_list_numbered,
                  copy.t('formatNumberedList'),
                ),
                _formatMenuItem(
                  _ManuscriptBlockFormat.sceneBreak,
                  Icons.horizontal_rule,
                  copy.t('formatSceneBreak'),
                ),
              ],
            ),
            _ToolbarDivider(color: color.outlineVariant),
            _FormatIconButton(
              tooltip: copy.t('formatSceneBreak'),
              icon: Icons.horizontal_rule,
              onPressed: () => _insertBlock('***'),
            ),
            _FormatIconButton(
              tooltip: copy.t('formatDialogueDash'),
              icon: Icons.keyboard_return,
              onPressed: () => _insertAtCursor('- '),
            ),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<_ManuscriptBlockFormat> _formatMenuItem(
    _ManuscriptBlockFormat value,
    IconData icon,
    String label,
  ) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 10),
          Text(label),
        ],
      ),
    );
  }

  void _applyBlockFormat(_ManuscriptBlockFormat format) {
    switch (format) {
      case _ManuscriptBlockFormat.heading1:
        _prefixSelectedLines((_, line) => '# ${_stripHeading(line)}');
      case _ManuscriptBlockFormat.heading2:
        _prefixSelectedLines((_, line) => '## ${_stripHeading(line)}');
      case _ManuscriptBlockFormat.quote:
        _prefixSelectedLines((_, line) => '> ${_stripLinePrefix(line)}');
      case _ManuscriptBlockFormat.bulletList:
        _prefixSelectedLines((_, line) => '- ${_stripLinePrefix(line)}');
      case _ManuscriptBlockFormat.numberedList:
        _prefixSelectedLines(
          (index, line) => '${index + 1}. ${_stripLinePrefix(line)}',
        );
      case _ManuscriptBlockFormat.sceneBreak:
        _insertBlock('***');
    }
  }

  void _wrapSelection({
    required String prefix,
    required String suffix,
    required String placeholder,
  }) {
    final value = controller.value;
    final text = value.text;
    final selection = _safeSelection(value);
    final selectedText = selection.isCollapsed
        ? placeholder
        : text.substring(selection.start, selection.end);
    final replacement = '$prefix$selectedText$suffix';
    final updated =
        text.replaceRange(selection.start, selection.end, replacement);
    final selectionStart = selection.start + prefix.length;
    final selectionEnd = selectionStart + selectedText.length;
    controller.value = value.copyWith(
      text: updated,
      selection: selection.isCollapsed
          ? TextSelection(
              baseOffset: selectionStart, extentOffset: selectionEnd)
          : TextSelection.collapsed(
              offset: selection.start + replacement.length),
      composing: TextRange.empty,
    );
  }

  void _prefixSelectedLines(String Function(int index, String line) transform) {
    final value = controller.value;
    final text = value.text;
    final selection = _safeSelection(value);
    final lineStart =
        text.lastIndexOf('\n', math.max(0, selection.start - 1)) + 1;
    final lineEnd = _selectedLineEnd(text, selection);
    final segment = text.substring(lineStart, lineEnd);
    final lines = segment.isEmpty ? [''] : segment.split('\n');
    final replacement = [
      for (var index = 0; index < lines.length; index++)
        transform(index, lines[index]),
    ].join('\n');
    final updated = text.replaceRange(lineStart, lineEnd, replacement);
    controller.value = value.copyWith(
      text: updated,
      selection: TextSelection(
        baseOffset: lineStart,
        extentOffset: lineStart + replacement.length,
      ),
      composing: TextRange.empty,
    );
  }

  void _insertBlock(String block) {
    final value = controller.value;
    final text = value.text;
    final selection = _safeSelection(value);
    final before = selection.start == 0 ||
            text.substring(0, selection.start).endsWith('\n\n')
        ? ''
        : '\n\n';
    final after = selection.end >= text.length ||
            text.substring(selection.end).startsWith('\n\n')
        ? ''
        : '\n\n';
    _replaceRange(selection, '$before$block$after');
  }

  void _insertAtCursor(String insert) {
    final value = controller.value;
    final selection = _safeSelection(value);
    _replaceRange(selection, insert);
  }

  void _replaceRange(TextSelection selection, String replacement) {
    final value = controller.value;
    final text = value.text;
    final updated =
        text.replaceRange(selection.start, selection.end, replacement);
    final offset = selection.start + replacement.length;
    controller.value = value.copyWith(
      text: updated,
      selection: TextSelection.collapsed(offset: offset),
      composing: TextRange.empty,
    );
  }

  TextSelection _safeSelection(TextEditingValue value) {
    final textLength = value.text.length;
    final selection = value.selection;
    if (!selection.isValid) {
      return TextSelection.collapsed(offset: textLength);
    }
    final start = selection.start.clamp(0, textLength);
    final end = selection.end.clamp(0, textLength);
    return TextSelection(
        baseOffset: math.min(start, end), extentOffset: math.max(start, end));
  }

  int _selectedLineEnd(String text, TextSelection selection) {
    var probe = selection.end;
    if (!selection.isCollapsed &&
        probe > selection.start &&
        text[probe - 1] == '\n') {
      probe -= 1;
    }
    final nextBreak = text.indexOf('\n', probe);
    return nextBreak == -1 ? text.length : nextBreak;
  }

  String _stripHeading(String line) {
    return line.replaceFirst(RegExp(r'^\s{0,3}#{1,6}\s+'), '');
  }

  String _stripLinePrefix(String line) {
    return line
        .replaceFirst(RegExp(r'^\s{0,3}([>*-]|\d+\.)\s+'), '')
        .trimLeft();
  }
}

final class _FormatIconButton extends StatelessWidget {
  const _FormatIconButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton.outlined(
      visualDensity: VisualDensity.compact,
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(icon),
    );
  }
}

final class _ToolbarDivider extends StatelessWidget {
  const _ToolbarDivider({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: VerticalDivider(width: 12, color: color),
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
    final label = switch (state) {
      _SceneSaveState.saved => _savedLabel(copy, savedAt),
      _SceneSaveState.unsaved => copy.t('autosavePending'),
      _SceneSaveState.saving => copy.t('autosaveSaving'),
      _SceneSaveState.error => copy.t('autosaveError'),
    };

    return Semantics(
      label: label,
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: state == _SceneSaveState.error
                  ? color.error
                  : color.onSurfaceVariant,
              fontWeight: FontWeight.w600,
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
    required this.suggestions,
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
    required this.onAddExistingSceneCatalogItems,
    required this.onCreateSceneCatalogItem,
    required this.isRequestingAi,
    required this.onRequestSceneAiHelp,
  });

  final WritelerCopy copy;
  final Scene scene;
  final List<Chapter> chapters;
  final List<CatalogItem> catalogItems;
  final List<Relationship> relationships;
  final List<AISuggestion> suggestions;
  final TextEditingController summaryController;
  final TextEditingController goalController;
  final TextEditingController conflictController;
  final TextEditingController outcomeController;
  final TextEditingController wordTargetController;
  final DraftStatus selectedSceneStatus;
  final String? selectedSceneChapterId;
  final ValueChanged<String?> onSceneChapterChanged;
  final ValueChanged<DraftStatus> onSceneStatusChanged;
  final Future<void> Function(CatalogItem item, bool selected)
      onToggleSceneCatalogLink;
  final Future<void> Function(List<CatalogItem> items)
      onAddExistingSceneCatalogItems;
  final ValueChanged<EntityType> onCreateSceneCatalogItem;
  final bool isRequestingAi;
  final void Function(AITaskKind task, String prompt) onRequestSceneAiHelp;

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
        key: const ValueKey('scene-inspector-scroll'),
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
          _SceneMetaOverview(
            copy: copy,
            scene: scene,
            chapters: chapters,
            catalogItems: catalogItems,
            relationships: relationships,
            suggestions: suggestions,
            targetText: wordTargetController.text,
          ),
          const SizedBox(height: 14),
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
            onAddExistingItems: onAddExistingSceneCatalogItems,
            onCreateItem: onCreateSceneCatalogItem,
          ),
          const SizedBox(height: 16),
          Divider(height: 1, color: color.outlineVariant),
          const SizedBox(height: 14),
          _SceneAiHelpBox(
            copy: copy,
            scene: scene,
            isRequesting: isRequestingAi,
            latestSuggestion: _latestSceneSuggestion(scene, suggestions),
            onRequest: onRequestSceneAiHelp,
          ),
        ],
      ),
    );
  }
}

final class _SceneMetaOverview extends StatelessWidget {
  const _SceneMetaOverview({
    required this.copy,
    required this.scene,
    required this.chapters,
    required this.catalogItems,
    required this.relationships,
    required this.suggestions,
    required this.targetText,
  });

  final WritelerCopy copy;
  final Scene scene;
  final List<Chapter> chapters;
  final List<CatalogItem> catalogItems;
  final List<Relationship> relationships;
  final List<AISuggestion> suggestions;
  final String targetText;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final chapter =
        chapters.where((chapter) => chapter.id == scene.chapterId).firstOrNull;
    final missing = _missingScenePlanningLabels(scene, copy);
    final planningProgress = _scenePlanningProgress(scene);
    final linkedItems = _linkedSceneCatalogItems().length;
    final pendingSuggestions = suggestions
        .where((suggestion) =>
            suggestion.target.type == EntityType.scene &&
            suggestion.target.id == scene.id &&
            suggestion.userDecision == SuggestionDecision.pending)
        .length;
    final target = int.tryParse(targetText);
    final wordValue = target == null || target <= 0
        ? '${scene.actualWordCount}'
        : '${scene.actualWordCount} / $target';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.info_outline, size: 17, color: color.onSurfaceVariant),
            const SizedBox(width: 7),
            Text(
              copy.t('sceneMeta'),
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: color.onSurfaceVariant,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 9),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _SceneMetaChip(
              icon: Icons.account_tree_outlined,
              label: copy.t('chapter'),
              value: chapter?.title ?? copy.t('noChapter'),
            ),
            _SceneMetaChip(
              icon: Icons.flag_outlined,
              label: copy.t('status'),
              value: _draftStatusLabel(scene.status, copy.languageCode),
            ),
            _SceneMetaChip(
              icon: Icons.notes_outlined,
              label: copy.t('words'),
              value: wordValue,
            ),
            _SceneMetaChip(
              icon: missing.isEmpty
                  ? Icons.check_circle_outline
                  : Icons.radio_button_unchecked,
              label: copy.t('planningProgress'),
              value: missing.isEmpty
                  ? copy.t('planningComplete')
                  : '${(planningProgress * 100).round()}%',
              accent: missing.isEmpty ? color.primary : color.tertiary,
            ),
            _SceneMetaChip(
              icon: Icons.hub_outlined,
              label: copy.t('linkedContext'),
              value: '$linkedItems',
            ),
            _SceneMetaChip(
              icon: Icons.psychology_alt_outlined,
              label: copy.t('openAiSuggestions'),
              value: '$pendingSuggestions',
              accent: pendingSuggestions > 0 ? color.primary : null,
            ),
          ],
        ),
        if (missing.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            '${copy.t('missing')}: ${missing.join(', ')}',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color.onSurfaceVariant,
                ),
          ),
        ],
      ],
    );
  }

  List<CatalogItem> _linkedSceneCatalogItems() {
    return catalogItems.where((item) {
      return relationships.any(
        (relationship) =>
            relationship.source.type == EntityType.scene &&
            relationship.source.id == scene.id &&
            relationship.target.type == item.type &&
            relationship.target.id == item.id &&
            relationship.relationshipType == 'appearsIn',
      );
    }).toList(growable: false);
  }
}

final class _SceneMetaChip extends StatelessWidget {
  const _SceneMetaChip({
    required this.icon,
    required this.label,
    required this.value,
    this.accent,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final foreground = accent ?? color.onSurfaceVariant;
    return Container(
      constraints: const BoxConstraints(minHeight: 38, maxWidth: 158),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
      decoration: BoxDecoration(
        color: color.surfaceContainerLowest,
        border: Border.all(color: color.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: foreground),
          const SizedBox(width: 7),
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: color.onSurfaceVariant,
                      ),
                ),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: color.onSurface,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

AISuggestion? _latestSceneSuggestion(
  Scene scene,
  List<AISuggestion> suggestions,
) {
  final sceneSuggestions = suggestions
      .where((suggestion) =>
          suggestion.target.type == EntityType.scene &&
          suggestion.target.id == scene.id &&
          suggestion.userDecision == SuggestionDecision.pending)
      .toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  return sceneSuggestions.firstOrNull;
}

final class _SceneAiHelpBox extends StatefulWidget {
  const _SceneAiHelpBox({
    required this.copy,
    required this.scene,
    required this.isRequesting,
    required this.latestSuggestion,
    required this.onRequest,
  });

  final WritelerCopy copy;
  final Scene scene;
  final bool isRequesting;
  final AISuggestion? latestSuggestion;
  final void Function(AITaskKind task, String prompt) onRequest;

  @override
  State<_SceneAiHelpBox> createState() => _SceneAiHelpBoxState();
}

final class _SceneAiHelpBoxState extends State<_SceneAiHelpBox> {
  late final TextEditingController _promptController = TextEditingController();

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _SceneAiHelpBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scene.id != widget.scene.id) {
      _promptController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final copy = widget.copy;
    final color = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.surfaceContainerLowest,
        border: Border.all(color: color.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.psychology_alt_outlined,
                    color: color.primary, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    copy.t('editorAiHelp'),
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                _HelpTooltip(message: copy.t('helpEditorAiHelp')),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${copy.t('sceneContext')}: ${widget.scene.title}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: widget.isRequesting
                      ? null
                      : () => _send(AITaskKind.authorQuestions),
                  icon: const Icon(Icons.help_outline),
                  label: Text(copy.t('aiTaskAuthorQuestions')),
                ),
                OutlinedButton.icon(
                  onPressed: widget.isRequesting
                      ? null
                      : () => _send(AITaskKind.sceneGoalConflictOutcome),
                  icon: const Icon(Icons.account_tree_outlined),
                  label: Text(copy.t('requestStructure')),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _promptController,
              minLines: 2,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: copy.t('editorAiHelpInput'),
                alignLabelWithHint: true,
                border: const OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.newline,
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: widget.isRequesting
                    ? null
                    : () => _send(AITaskKind.customScenePrompt),
                icon: widget.isRequesting
                    ? const SizedBox.square(
                        dimension: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send_outlined),
                label: Text(copy.t('sendAiHelp')),
              ),
            ),
            if (widget.latestSuggestion != null) ...[
              const SizedBox(height: 12),
              Divider(height: 1, color: color.outlineVariant),
              const SizedBox(height: 10),
              Text(
                copy.t('latestAiHelpAnswer'),
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              _AIResponseDigest(
                copy: copy,
                text: widget.latestSuggestion!.responseText,
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _send(AITaskKind task) {
    widget.onRequest(task, _promptController.text.trim());
    if (task == AITaskKind.customScenePrompt) {
      _promptController.clear();
    }
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
        border: Border(top: BorderSide(color: color.outlineVariant)),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Row(
          children: [
            _EditorStat(label: copy.t('words'), value: '$words'),
            const SizedBox(width: 18),
            _EditorStat(label: copy.t('characterCount'), value: '$characters'),
            if (target != null && target > 0) ...[
              const SizedBox(width: 18),
              Expanded(
                child: SizedBox(
                  height: 34,
                  child: CustomPaint(
                    painter: _ThreadProgressPainter(
                      color: color.primary,
                      trackColor: color.outlineVariant,
                      progress: progress ?? 0,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          '${copy.t('targetProgress')}: $words / $target',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: color.onSurfaceVariant,
                                  ),
                        ),
                      ),
                    ),
                  ),
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

final class _ThreadProgressPainter extends CustomPainter {
  const _ThreadProgressPainter({
    required this.color,
    required this.trackColor,
    required this.progress,
  });

  final Color color;
  final Color trackColor;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height * 0.28;
    final track = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    final active = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset.zero.translate(0, y), Offset(size.width, y), track);
    canvas.drawLine(
      Offset.zero.translate(0, y),
      Offset(size.width * progress.clamp(0, 1), y),
      active,
    );
  }

  @override
  bool shouldRepaint(covariant _ThreadProgressPainter oldDelegate) {
    return color != oldDelegate.color ||
        trackColor != oldDelegate.trackColor ||
        progress != oldDelegate.progress;
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
            icon: const Icon(Icons.keyboard_arrow_down_rounded),
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
              icon: const Icon(Icons.keyboard_arrow_down_rounded),
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
    required this.onAddExistingItems,
    required this.onCreateItem,
  });

  final WritelerCopy copy;
  final Scene scene;
  final List<CatalogItem> catalogItems;
  final List<Relationship> relationships;
  final Future<void> Function(CatalogItem item, bool selected) onToggleLink;
  final Future<void> Function(List<CatalogItem> items) onAddExistingItems;
  final ValueChanged<EntityType> onCreateItem;

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
    final linkedItems = relevantItems.where(_isLinked).toList(growable: false);
    final availableItems =
        relevantItems.where((item) => !_isLinked(item)).toList(growable: false);
    final color = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          copy.t('sceneContext'),
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            PopupMenuButton<EntityType>(
              tooltip: copy.t('addSceneContext'),
              onSelected: onCreateItem,
              itemBuilder: (context) => [
                for (final type in const [
                  EntityType.character,
                  EntityType.location,
                  EntityType.object,
                ])
                  PopupMenuItem(
                    value: type,
                    child: Row(
                      children: [
                        Icon(_catalogIcon(type), size: 18),
                        const SizedBox(width: 10),
                        Text(copy.t(_newCatalogKey(type))),
                      ],
                    ),
                  ),
              ],
              child: IgnorePointer(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add),
                  label: Text(copy.t('newSceneContextItem')),
                ),
              ),
            ),
            OutlinedButton.icon(
              onPressed: availableItems.isEmpty
                  ? null
                  : () => _showExistingContextDialog(context, availableItems),
              icon: const Icon(Icons.library_add_outlined),
              label: Text(copy.t('addExistingSceneContext')),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (linkedItems.isEmpty)
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              relevantItems.isEmpty
                  ? copy.t('sceneContextEmpty')
                  : copy.t('sceneContextNoLinkedItems'),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color.onSurfaceVariant,
                  ),
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final item in linkedItems)
                InputChip(
                  avatar: Icon(_catalogIcon(item.type), size: 18),
                  label: Text(item.name),
                  tooltip: copy.t('removeSceneContext'),
                  deleteButtonTooltipMessage: copy.t('removeSceneContext'),
                  onDeleted: () async => onToggleLink(item, false),
                ),
            ],
          ),
      ],
    );
  }

  Future<void> _showExistingContextDialog(
    BuildContext context,
    List<CatalogItem> availableItems,
  ) async {
    final selectedItems = await showDialog<List<CatalogItem>>(
      context: context,
      builder: (context) => _ExistingSceneContextDialog(
        copy: copy,
        availableItems: availableItems,
      ),
    );
    if (selectedItems == null || selectedItems.isEmpty) return;
    await onAddExistingItems(selectedItems);
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

final class _ExistingSceneContextDialog extends StatefulWidget {
  const _ExistingSceneContextDialog({
    required this.copy,
    required this.availableItems,
  });

  final WritelerCopy copy;
  final List<CatalogItem> availableItems;

  @override
  State<_ExistingSceneContextDialog> createState() =>
      _ExistingSceneContextDialogState();
}

final class _ExistingSceneContextDialogState
    extends State<_ExistingSceneContextDialog> {
  EntityType _typeFilter = EntityType.character;
  final Set<String> _selectedIds = {};

  @override
  Widget build(BuildContext context) {
    final copy = widget.copy;
    final filteredItems = widget.availableItems
        .where((item) => item.type == _typeFilter)
        .toList(growable: false);
    return AlertDialog(
      title: Text(copy.t('addExistingSceneContext')),
      content: SizedBox(
        width: 460,
        height: 420,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SegmentedButton<EntityType>(
              segments: [
                for (final type in const [
                  EntityType.character,
                  EntityType.location,
                  EntityType.object,
                ])
                  ButtonSegment(
                    value: type,
                    icon: Icon(_catalogIcon(type), size: 18),
                    label: Text(copy.t(_catalogTitleKey(type))),
                  ),
              ],
              selected: {_typeFilter},
              onSelectionChanged: (selection) {
                setState(() => _typeFilter = selection.first);
              },
            ),
            const SizedBox(height: 12),
            Expanded(
              child: filteredItems.isEmpty
                  ? Center(
                      child: Text(
                        copy.t('noExistingSceneContextItems'),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ListView.separated(
                      itemCount: filteredItems.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final item = filteredItems[index];
                        return CheckboxListTile(
                          secondary: Icon(_catalogIcon(item.type)),
                          title: Text(item.name),
                          subtitle: item.summary.trim().isEmpty
                              ? null
                              : Text(
                                  item.summary,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                          value: _selectedIds.contains(item.id),
                          onChanged: (selected) {
                            setState(() {
                              if (selected ?? false) {
                                _selectedIds.add(item.id);
                              } else {
                                _selectedIds.remove(item.id);
                              }
                            });
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(copy.t('cancel')),
        ),
        FilledButton.icon(
          onPressed: _selectedIds.isEmpty
              ? null
              : () {
                  final selectedItems = widget.availableItems
                      .where((item) => _selectedIds.contains(item.id))
                      .toList(growable: false);
                  Navigator.of(context).pop(selectedItems);
                },
          icon: const Icon(Icons.add_link_outlined),
          label: Text(copy.t('addSelectedSceneContext')),
        ),
      ],
    );
  }
}
