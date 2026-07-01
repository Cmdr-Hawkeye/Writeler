part of '../main.dart';

// Manuscript editor, scene navigator, focus mode, autosave status, and scene planning widgets.

final class _ProjectWorkspace extends StatefulWidget {
  const _ProjectWorkspace({
    required this.copy,
    required this.project,
    required this.chapters,
    required this.catalogItems,
    required this.relationships,
    required this.researchItems,
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
    required this.sceneSnapshots,
    required this.spellCheckSettings,
    required this.spellChecker,
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
    required this.onCreateSceneSnapshot,
    required this.onRestoreSceneSnapshot,
    required this.onDeleteSceneSnapshot,
    required this.onSaveSceneAnnotations,
    required this.onSaveScene,
    required this.onSaveSceneManuscript,
    required this.onOpenContext,
  });

  final WritellerCopy copy;
  final Project? project;
  final List<Chapter> chapters;
  final List<CatalogItem> catalogItems;
  final List<Relationship> relationships;
  final List<ResearchItem> researchItems;
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
  final List<SceneSnapshot> sceneSnapshots;
  final SpellCheckSettings spellCheckSettings;
  final SpellChecker spellChecker;
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
  final VoidCallback onCreateSceneSnapshot;
  final ValueChanged<SceneSnapshot> onRestoreSceneSnapshot;
  final ValueChanged<SceneSnapshot> onDeleteSceneSnapshot;
  final Future<void> Function(List<SceneAnnotation> annotations)
      onSaveSceneAnnotations;
  final VoidCallback onSaveScene;
  final Future<void> Function(Scene scene, String manuscriptText)
      onSaveSceneManuscript;
  final VoidCallback onOpenContext;

  @override
  State<_ProjectWorkspace> createState() => _ProjectWorkspaceState();
}

final class _ProjectWorkspaceState extends State<_ProjectWorkspace> {
  bool _focusMode = false;
  double _editorFontSize = 18;
  _ManuscriptEditorMode _editorMode = _ManuscriptEditorMode.scene;

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

    return LayoutBuilder(
      builder: (context, constraints) {
        final fullManuscriptMode =
            _editorMode == _ManuscriptEditorMode.fullManuscript;
        final hideSceneNavigator =
            fullManuscriptMode || constraints.maxWidth < 640;
        final compactActions = constraints.maxWidth < 760;
        final compactAuxiliaryActions = constraints.maxWidth < 980;

        return Column(
          children: [
            if (!_focusMode) ...[
              SizedBox(
                height: 64,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: compactActions ? 14 : 24,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          project.title,
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                      ),
                      if (!compactActions) ...[
                        const SizedBox(width: 12),
                        SegmentedButton<_ManuscriptEditorMode>(
                          showSelectedIcon: false,
                          selected: {_editorMode},
                          onSelectionChanged: (selection) => setState(
                            () => _editorMode = selection.first,
                          ),
                          segments: [
                            ButtonSegment(
                              value: _ManuscriptEditorMode.scene,
                              icon: const Icon(Icons.notes_outlined, size: 18),
                              label: Text(widget.copy.t('sceneMode')),
                            ),
                            ButtonSegment(
                              value: _ManuscriptEditorMode.fullManuscript,
                              icon: const Icon(
                                Icons.article_outlined,
                                size: 18,
                              ),
                              label: Text(widget.copy.t('fullManuscriptMode')),
                            ),
                          ],
                        ),
                      ] else ...[
                        const SizedBox(width: 8),
                        PopupMenuButton<_ManuscriptEditorMode>(
                          tooltip: widget.copy.t('manuscriptMode'),
                          icon: Icon(
                            fullManuscriptMode
                                ? Icons.article_outlined
                                : Icons.notes_outlined,
                          ),
                          onSelected: (mode) =>
                              setState(() => _editorMode = mode),
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: _ManuscriptEditorMode.scene,
                              child: Text(widget.copy.t('sceneMode')),
                            ),
                            PopupMenuItem(
                              value: _ManuscriptEditorMode.fullManuscript,
                              child: Text(widget.copy.t('fullManuscriptMode')),
                            ),
                          ],
                        ),
                      ],
                      if (!fullManuscriptMode &&
                          hideSceneNavigator &&
                          widget.scenes.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        _CompactSceneSelector(
                          copy: widget.copy,
                          scenes: widget.scenes,
                          selectedScene: widget.selectedScene,
                          onSelectScene: widget.onSelectScene,
                        ),
                      ],
                      const SizedBox(width: 8),
                      compactAuxiliaryActions
                          ? IconButton.outlined(
                              tooltip: widget.copy.t('openStoryContext'),
                              onPressed: widget.onOpenContext,
                              icon: const Icon(Icons.public_outlined),
                            )
                          : OutlinedButton.icon(
                              onPressed: widget.onOpenContext,
                              icon: const Icon(Icons.public_outlined),
                              label: Text(widget.copy.t('storyContext')),
                            ),
                      const SizedBox(width: 8),
                      compactAuxiliaryActions
                          ? IconButton.filled(
                              tooltip: widget.copy.t('newScene'),
                              onPressed: widget.onCreateScene,
                              icon: const Icon(Icons.add),
                            )
                          : FilledButton.icon(
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
                  if (!_focusMode && !hideSceneNavigator) ...[
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
                    child: fullManuscriptMode
                        ? _FullManuscriptEditor(
                            copy: widget.copy,
                            chapters: widget.chapters,
                            scenes: _scenesForFullManuscript(),
                            fontSize: _editorFontSize,
                            onFontSizeChanged: (value) =>
                                setState(() => _editorFontSize = value),
                            onSaveScene: widget.onSaveSceneManuscript,
                            onOpenScene: (scene) {
                              widget.onSelectScene(scene);
                              setState(
                                () => _editorMode = _ManuscriptEditorMode.scene,
                              );
                            },
                          )
                        : widget.selectedScene == null
                            ? Center(
                                child: Text(
                                  widget.copy.t('selectScene'),
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
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
                                researchItems: widget.researchItems,
                                suggestions: widget.suggestions,
                                controller: widget.manuscriptController,
                                summaryController: widget.summaryController,
                                goalController: widget.goalController,
                                conflictController: widget.conflictController,
                                outcomeController: widget.outcomeController,
                                wordTargetController:
                                    widget.wordTargetController,
                                selectedSceneStatus: widget.selectedSceneStatus,
                                selectedSceneChapterId:
                                    widget.selectedSceneChapterId,
                                saveState: widget.sceneSaveState,
                                lastSavedAt: widget.lastSceneSavedAt,
                                snapshots: widget.sceneSnapshots
                                    .where((snapshot) =>
                                        snapshot.sceneId ==
                                        widget.selectedScene!.id)
                                    .toList(),
                                spellCheckSettings: widget.spellCheckSettings,
                                spellChecker: widget.spellChecker,
                                focusMode: _focusMode,
                                editorFontSize: _editorFontSize,
                                onEditorFontSizeChanged: (value) =>
                                    setState(() => _editorFontSize = value),
                                onFocusModeChanged: (value) =>
                                    setState(() => _focusMode = value),
                                onSceneChapterChanged:
                                    widget.onSceneChapterChanged,
                                onToggleSceneCatalogLink:
                                    widget.onToggleSceneCatalogLink,
                                onAddExistingSceneCatalogItems:
                                    widget.onAddExistingSceneCatalogItems,
                                onCreateSceneCatalogItem:
                                    widget.onCreateSceneCatalogItem,
                                onSceneStatusChanged:
                                    widget.onSceneStatusChanged,
                                isRequestingAi: widget.isRequestingAi,
                                onRequestSceneAiHelp:
                                    widget.onRequestSceneAiHelp,
                                onCreateSnapshot: widget.onCreateSceneSnapshot,
                                onRestoreSnapshot:
                                    widget.onRestoreSceneSnapshot,
                                onDeleteSnapshot: widget.onDeleteSceneSnapshot,
                                onSaveSceneAnnotations:
                                    widget.onSaveSceneAnnotations,
                                onSaveScene: widget.onSaveScene,
                              ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  List<Scene> _scenesForFullManuscript() {
    final selected = widget.selectedScene;
    final scenes = [
      for (final scene in widget.scenes)
        if (selected != null && scene.id == selected.id)
          scene.copyWith(manuscriptText: widget.manuscriptController.text)
        else
          scene,
    ];
    scenes.sort((a, b) {
      final chapterOrder = {
        for (final chapter in widget.chapters) chapter.id: chapter.orderIndex,
      };
      final chapterCompare = (chapterOrder[a.chapterId] ?? double.maxFinite)
          .compareTo(chapterOrder[b.chapterId] ?? double.maxFinite);
      if (chapterCompare != 0) return chapterCompare;
      return a.orderIndex.compareTo(b.orderIndex);
    });
    return scenes;
  }
}

enum _ManuscriptEditorMode { scene, fullManuscript }

enum _EditorSidePanelKind { planning, context, research, ai }

final class _FullManuscriptEditor extends StatefulWidget {
  const _FullManuscriptEditor({
    required this.copy,
    required this.chapters,
    required this.scenes,
    required this.fontSize,
    required this.onFontSizeChanged,
    required this.onSaveScene,
    required this.onOpenScene,
  });

  final WritellerCopy copy;
  final List<Chapter> chapters;
  final List<Scene> scenes;
  final double fontSize;
  final ValueChanged<double> onFontSizeChanged;
  final Future<void> Function(Scene scene, String manuscriptText) onSaveScene;
  final ValueChanged<Scene> onOpenScene;

  @override
  State<_FullManuscriptEditor> createState() => _FullManuscriptEditorState();
}

final class _FullManuscriptEditorState extends State<_FullManuscriptEditor> {
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, String> _lastSyncedText = {};
  final Set<String> _savingSceneIds = {};

  @override
  void initState() {
    super.initState();
    _syncControllers();
  }

  @override
  void didUpdateWidget(covariant _FullManuscriptEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncControllers();
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    if (widget.scenes.isEmpty) {
      return _EmptyPanel(
        icon: Icons.article_outlined,
        title: widget.copy.t('fullManuscriptEmptyTitle'),
        body: widget.copy.t('fullManuscriptEmptyBody'),
      );
    }

    return ColoredBox(
      color: color.surfaceContainerLowest,
      child: Column(
        children: [
          Container(
            height: 58,
            padding: const EdgeInsets.symmetric(horizontal: 22),
            decoration: BoxDecoration(
              color: color.surface,
              border: Border(
                bottom: BorderSide(color: color.outlineVariant),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.article_outlined, color: color.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.copy.t('fullManuscriptMode'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
                Text(
                  '${_dirtySceneCount()} ${widget.copy.t('changedScenes')}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: color.onSurfaceVariant,
                      ),
                ),
                const SizedBox(width: 12),
                Tooltip(
                  message: widget.copy.t('editorFontSize'),
                  child: PopupMenuButton<double>(
                    tooltip: widget.copy.t('editorFontSize'),
                    icon: const Icon(Icons.format_size),
                    onSelected: widget.onFontSizeChanged,
                    itemBuilder: (context) => [
                      for (final size in const [16.0, 18.0, 20.0, 22.0])
                        PopupMenuItem(
                          value: size,
                          child: Row(
                            children: [
                              Icon(
                                widget.fontSize == size
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
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed:
                      _dirtySceneCount() == 0 || _savingSceneIds.isNotEmpty
                          ? null
                          : _saveAllDirtyScenes,
                  icon: const Icon(Icons.save_outlined),
                  label: Text(widget.copy.t('saveChangedScenes')),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(24, 18, 24, 34),
              itemCount: widget.scenes.length,
              itemBuilder: (context, index) {
                final scene = widget.scenes[index];
                final previous = index == 0 ? null : widget.scenes[index - 1];
                final showChapterBoundary =
                    index == 0 || previous?.chapterId != scene.chapterId;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (showChapterBoundary)
                      _FullManuscriptChapterBoundary(
                        title: _chapterTitle(scene.chapterId),
                      ),
                    _FullManuscriptSceneSection(
                      copy: widget.copy,
                      scene: scene,
                      controller: _controllers[scene.id]!,
                      fontSize: widget.fontSize,
                      dirty: _isDirty(scene),
                      saving: _savingSceneIds.contains(scene.id),
                      onChanged: () => setState(() {}),
                      onSave: () => _saveScene(scene),
                      onOpenScene: () => widget.onOpenScene(scene),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _syncControllers() {
    final sceneIds = widget.scenes.map((scene) => scene.id).toSet();
    final removed = _controllers.keys
        .where((sceneId) => !sceneIds.contains(sceneId))
        .toList(growable: false);
    for (final sceneId in removed) {
      _controllers.remove(sceneId)?.dispose();
      _lastSyncedText.remove(sceneId);
      _savingSceneIds.remove(sceneId);
    }

    for (final scene in widget.scenes) {
      final controller = _controllers[scene.id];
      if (controller == null) {
        _controllers[scene.id] =
            TextEditingController(text: scene.manuscriptText);
        _lastSyncedText[scene.id] = scene.manuscriptText;
        continue;
      }
      final lastSynced = _lastSyncedText[scene.id] ?? '';
      if (controller.text == lastSynced && scene.manuscriptText != lastSynced) {
        controller.text = scene.manuscriptText;
        _lastSyncedText[scene.id] = scene.manuscriptText;
      }
    }
  }

  bool _isDirty(Scene scene) {
    return _controllers[scene.id]?.text != (_lastSyncedText[scene.id] ?? '');
  }

  int _dirtySceneCount() {
    return widget.scenes.where(_isDirty).length;
  }

  Future<void> _saveScene(Scene scene) async {
    final controller = _controllers[scene.id];
    if (controller == null || !_isDirty(scene)) return;
    setState(() => _savingSceneIds.add(scene.id));
    try {
      await widget.onSaveScene(scene, controller.text);
      if (!mounted) return;
      setState(() => _lastSyncedText[scene.id] = controller.text);
    } finally {
      if (mounted) {
        setState(() => _savingSceneIds.remove(scene.id));
      }
    }
  }

  Future<void> _saveAllDirtyScenes() async {
    final dirtyScenes = widget.scenes.where(_isDirty).toList(growable: false);
    for (final scene in dirtyScenes) {
      await _saveScene(scene);
      if (!mounted) return;
    }
  }

  String _chapterTitle(String? chapterId) {
    if (chapterId == null) return widget.copy.t('noChapter');
    return widget.chapters
            .where((chapter) => chapter.id == chapterId)
            .firstOrNull
            ?.title ??
        widget.copy.t('noChapter');
  }
}

final class _FullManuscriptChapterBoundary extends StatelessWidget {
  const _FullManuscriptChapterBoundary({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 18, 0, 12),
      child: Row(
        children: [
          Expanded(child: Divider(color: color.outlineVariant)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: color.onSurfaceVariant,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                  ),
            ),
          ),
          Expanded(child: Divider(color: color.outlineVariant)),
        ],
      ),
    );
  }
}

final class _FullManuscriptSceneSection extends StatelessWidget {
  const _FullManuscriptSceneSection({
    required this.copy,
    required this.scene,
    required this.controller,
    required this.fontSize,
    required this.dirty,
    required this.saving,
    required this.onChanged,
    required this.onSave,
    required this.onOpenScene,
  });

  final WritellerCopy copy;
  final Scene scene;
  final TextEditingController controller;
  final double fontSize;
  final bool dirty;
  final bool saving;
  final VoidCallback onChanged;
  final VoidCallback onSave;
  final VoidCallback onOpenScene;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final maxWidth = math.min(MediaQuery.sizeOf(context).width - 48, 780.0);
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: color.surface,
            border: Border(
              left: BorderSide(color: color.outlineVariant),
              right: BorderSide(color: color.outlineVariant),
              top: BorderSide(
                  color: color.outlineVariant.withValues(alpha: 0.5)),
              bottom: BorderSide(
                  color: color.outlineVariant.withValues(alpha: 0.5)),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(26, 18, 26, 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(Icons.drag_handle, color: color.onSurfaceVariant),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        scene.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                      ),
                    ),
                    if (dirty)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _StatusDot(
                          label: copy.t('autosavePending'),
                          color: color.tertiary,
                        ),
                      ),
                    IconButton(
                      tooltip: copy.t('openScene'),
                      onPressed: onOpenScene,
                      icon: const Icon(Icons.open_in_new),
                    ),
                    IconButton.filledTonal(
                      tooltip: copy.t('saveScene'),
                      onPressed: dirty && !saving ? onSave : null,
                      icon: saving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.save_outlined),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  key: ValueKey('full-manuscript-field-${scene.id}'),
                  controller: controller,
                  onChanged: (_) => onChanged(),
                  minLines: _minimumLines(controller.text),
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
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
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  int _minimumLines(String text) {
    final paragraphs =
        text.trim().isEmpty ? 4 : text.split(RegExp(r'\r?\n')).length + 2;
    return paragraphs.clamp(4, 14);
  }
}

final class _StatusDot extends StatelessWidget {
  const _StatusDot({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 8, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
}

final class _NoScenes extends StatelessWidget {
  const _NoScenes({
    required this.copy,
    required this.onCreateScene,
  });

  final WritellerCopy copy;
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

final class _CompactSceneSelector extends StatelessWidget {
  const _CompactSceneSelector({
    required this.copy,
    required this.scenes,
    required this.selectedScene,
    required this.onSelectScene,
  });

  final WritellerCopy copy;
  final List<Scene> scenes;
  final Scene? selectedScene;
  final ValueChanged<Scene> onSelectScene;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return PopupMenuButton<Scene>(
      tooltip: copy.t('selectScene'),
      onSelected: onSelectScene,
      itemBuilder: (context) => [
        for (final scene in scenes)
          PopupMenuItem(
            value: scene,
            child: Row(
              children: [
                Icon(
                  selectedScene?.id == scene.id
                      ? Icons.radio_button_checked
                      : Icons.notes_outlined,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    scene.title,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
      ],
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: color.outlineVariant),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 8, 8, 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.notes_outlined, size: 18, color: color.primary),
              const SizedBox(width: 6),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 150),
                child: Text(
                  selectedScene?.title ?? copy.t('scene'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.keyboard_arrow_down,
                size: 18,
                color: color.onSurfaceVariant,
              ),
            ],
          ),
        ),
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

  final WritellerCopy copy;
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

  final WritellerCopy copy;
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
    required this.researchItems,
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
    required this.snapshots,
    required this.spellCheckSettings,
    required this.spellChecker,
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
    required this.onCreateSnapshot,
    required this.onRestoreSnapshot,
    required this.onDeleteSnapshot,
    required this.onSaveSceneAnnotations,
    required this.onSaveScene,
  });

  final WritellerCopy copy;
  final Scene scene;
  final List<Chapter> chapters;
  final List<CatalogItem> catalogItems;
  final List<Relationship> relationships;
  final List<ResearchItem> researchItems;
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
  final List<SceneSnapshot> snapshots;
  final SpellCheckSettings spellCheckSettings;
  final SpellChecker spellChecker;
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
  final VoidCallback onCreateSnapshot;
  final ValueChanged<SceneSnapshot> onRestoreSnapshot;
  final ValueChanged<SceneSnapshot> onDeleteSnapshot;
  final Future<void> Function(List<SceneAnnotation> annotations)
      onSaveSceneAnnotations;
  final VoidCallback onSaveScene;

  @override
  State<_SceneEditor> createState() => _SceneEditorState();
}

final class _SceneEditorState extends State<_SceneEditor> {
  late final TextEditingController _searchController = TextEditingController();
  late final TextEditingController _replaceController = TextEditingController();
  late final FocusNode _manuscriptFocusNode = FocusNode();
  late final ScrollController _manuscriptScrollController = ScrollController();
  bool _showSearch = false;
  bool _isCheckingSpelling = false;
  bool _spellCheckCompleted = false;
  String? _spellCheckError;
  List<SpellCheckIssue> _spellIssues = const [];
  bool _showSnapshots = false;
  bool _showAnnotations = false;
  _EditorSidePanelKind _selectedSidePanel = _EditorSidePanelKind.planning;
  SceneSnapshot? _selectedSnapshot;

  @override
  void didUpdateWidget(covariant _SceneEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_selectedSnapshot == null) return;
    final stillExists = widget.snapshots
        .any((snapshot) => snapshot.id == _selectedSnapshot!.id);
    if (!stillExists) {
      _selectedSnapshot = null;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _replaceController.dispose();
    _manuscriptFocusNode.dispose();
    _manuscriptScrollController.dispose();
    super.dispose();
  }

  Future<void> _checkSpelling() async {
    if (!widget.spellCheckSettings.enabled) return;
    setState(() {
      _isCheckingSpelling = true;
      _spellCheckCompleted = false;
      _spellCheckError = null;
    });
    try {
      final issues = await widget.spellChecker.check(
        text: widget.controller.text,
        settings: widget.spellCheckSettings,
      );
      if (!mounted) return;
      setState(() {
        _spellIssues = issues;
        _spellCheckCompleted = true;
        _isCheckingSpelling = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _spellIssues = const [];
        _spellCheckCompleted = true;
        _spellCheckError = error.toString();
        _isCheckingSpelling = false;
      });
    }
  }

  void _applySpellingReplacement(SpellCheckIssue issue, String replacement) {
    final text = widget.controller.text;
    if (issue.offset < 0 || issue.offset + issue.length > text.length) return;
    final updated = text.replaceRange(
      issue.offset,
      issue.offset + issue.length,
      replacement,
    );
    widget.controller.value = TextEditingValue(
      text: updated,
      selection: TextSelection.collapsed(
        offset: issue.offset + replacement.length,
      ),
    );
    setState(() {
      _spellIssues = const [];
      _spellCheckCompleted = false;
    });
  }

  Future<void> _createAnnotationFromSelection() async {
    final selection = widget.controller.selection;
    if (!selection.isValid || selection.isCollapsed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.copy.t('annotationNeedsSelection'))),
      );
      return;
    }
    final start = math.min(selection.start, selection.end);
    final end = math.max(selection.start, selection.end);
    final text = widget.controller.text;
    if (start < 0 || end > text.length || start == end) return;
    final selectedText = text.substring(start, end).trim();
    if (selectedText.isEmpty) return;

    final comment = await _showAnnotationDialog(
      initialSelectedText: selectedText,
    );
    if (comment == null || comment.trim().isEmpty) return;

    final now = DateTime.now().toUtc();
    final annotations = [
      ...SceneAnnotation.listFromMetadata(widget.scene.metadata),
      SceneAnnotation(
        id: newLocalId('annotation'),
        sceneId: widget.scene.id,
        startOffset: start,
        endOffset: end,
        selectedText: selectedText,
        comment: comment.trim(),
        createdAt: now,
        updatedAt: now,
      ),
    ];
    await widget.onSaveSceneAnnotations(annotations);
    if (!mounted) return;
    setState(() => _showAnnotations = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(widget.copy.t('annotationCreated'))),
    );
  }

  Future<void> _editAnnotation(SceneAnnotation annotation) async {
    final comment = await _showAnnotationDialog(
      initialSelectedText: annotation.selectedText,
      initialComment: annotation.comment,
    );
    if (comment == null || comment.trim().isEmpty) return;
    final annotations = SceneAnnotation.listFromMetadata(widget.scene.metadata)
        .map(
          (item) => item.id == annotation.id
              ? item.copyWith(comment: comment.trim())
              : item,
        )
        .toList();
    await widget.onSaveSceneAnnotations(annotations);
  }

  Future<void> _toggleAnnotationResolved(SceneAnnotation annotation) async {
    final annotations = SceneAnnotation.listFromMetadata(widget.scene.metadata)
        .map(
          (item) => item.id == annotation.id
              ? item.copyWith(resolved: !item.resolved)
              : item,
        )
        .toList();
    await widget.onSaveSceneAnnotations(annotations);
  }

  Future<void> _deleteAnnotation(SceneAnnotation annotation) async {
    final annotations = SceneAnnotation.listFromMetadata(widget.scene.metadata)
        .where((item) => item.id != annotation.id)
        .toList();
    await widget.onSaveSceneAnnotations(annotations);
  }

  void _selectAnnotationText(SceneAnnotation annotation) {
    final range = _annotationTextRange(annotation, widget.controller.text);
    if (range == null) return;
    widget.controller.selection =
        TextSelection(baseOffset: range.start, extentOffset: range.end);
    _manuscriptFocusNode.requestFocus();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_manuscriptScrollController.hasClients) return;
      final offset = _estimatedScrollOffsetForTextOffset(
        widget.controller.text,
        range.start,
        widget.editorFontSize,
      );
      final target = offset
          .clamp(
            0.0,
            _manuscriptScrollController.position.maxScrollExtent,
          )
          .toDouble();
      unawaited(
        _manuscriptScrollController.animateTo(
          target,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
        ),
      );
    });
  }

  Future<String?> _showAnnotationDialog({
    required String initialSelectedText,
    String initialComment = '',
  }) async {
    final controller = TextEditingController(text: initialComment);
    try {
      return showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(widget.copy.t('annotationDialogTitle')),
          content: SizedBox(
            width: 460,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  initialSelectedText,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                ),
                const SizedBox(height: 14),
                TextField(
                  autofocus: true,
                  controller: controller,
                  maxLines: 5,
                  decoration: InputDecoration(
                    labelText: widget.copy.t('annotationCommentLabel'),
                    alignLabelWithHint: true,
                    border: const OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(widget.copy.t('cancel')),
            ),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).pop(controller.text),
              icon: const Icon(Icons.add_comment_outlined),
              label: Text(widget.copy.t('saveAnnotation')),
            ),
          ],
        ),
      );
    } finally {
      controller.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final copy = widget.copy;
    final scene = widget.scene;
    final color = Theme.of(context).colorScheme;
    final annotations = SceneAnnotation.listFromMetadata(scene.metadata);
    final openAnnotationCount =
        annotations.where((annotation) => !annotation.resolved).length;
    final manuscriptField = _ManuscriptField(
      copy: copy,
      controller: widget.controller,
      focusNode: _manuscriptFocusNode,
      scrollController: _manuscriptScrollController,
      focusMode: widget.focusMode,
      fontSize: widget.editorFontSize,
    );
    final inspector = _SceneInspector(
      copy: copy,
      scene: scene,
      chapters: widget.chapters,
      catalogItems: widget.catalogItems,
      relationships: widget.relationships,
      researchItems: widget.researchItems,
      suggestions: widget.suggestions,
      selectedPanel: _selectedSidePanel,
      onPanelChanged: (panel) => setState(() => _selectedSidePanel = panel),
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
              final compactHeader = constraints.maxWidth < 900;
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
                ],
              );
              final focusButton = _FocusModeButton(
                copy: copy,
                focusMode: widget.focusMode,
                onPressed: () => widget.onFocusModeChanged(!widget.focusMode),
              );
              final actions = Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _SaveStatePill(
                    copy: copy,
                    state: widget.saveState,
                    savedAt: widget.lastSavedAt,
                  ),
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
                    message: widget.spellCheckSettings.enabled
                        ? copy.t('checkSpelling')
                        : copy.t('spellCheckDisabledHint'),
                    child: IconButton.outlined(
                      onPressed: widget.spellCheckSettings.enabled &&
                              !_isCheckingSpelling
                          ? _checkSpelling
                          : null,
                      icon: _isCheckingSpelling
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.spellcheck_outlined),
                    ),
                  ),
                  Tooltip(
                    message: copy.t('addAnnotation'),
                    child: IconButton.outlined(
                      onPressed: _createAnnotationFromSelection,
                      icon: const Icon(Icons.add_comment_outlined),
                    ),
                  ),
                  Tooltip(
                    message: copy.t('annotations'),
                    child: IconButton.outlined(
                      isSelected: _showAnnotations,
                      onPressed: () => setState(
                        () => _showAnnotations = !_showAnnotations,
                      ),
                      icon: Badge.count(
                        count: openAnnotationCount,
                        isLabelVisible: openAnnotationCount > 0,
                        child: const Icon(Icons.rate_review_outlined),
                      ),
                    ),
                  ),
                  Tooltip(
                    message: copy.t('sceneSnapshots'),
                    child: IconButton.outlined(
                      isSelected: _showSnapshots,
                      onPressed: () => setState(
                        () => _showSnapshots = !_showSnapshots,
                      ),
                      icon: Badge.count(
                        count: widget.snapshots.length,
                        isLabelVisible: widget.snapshots.isNotEmpty,
                        child: const Icon(Icons.history_outlined),
                      ),
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
                    const SizedBox(height: 10),
                    Center(child: focusButton),
                    const SizedBox(height: 10),
                    Align(alignment: Alignment.centerRight, child: actions),
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(child: titleRow),
                  const SizedBox(width: 12),
                  focusButton,
                  const SizedBox(width: 12),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: actions,
                    ),
                  ),
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
          if (!widget.focusMode &&
              (_spellIssues.isNotEmpty ||
                  _spellCheckError != null ||
                  _spellCheckCompleted)) ...[
            _SpellCheckResultsPanel(
              copy: copy,
              issues: _spellIssues,
              error: _spellCheckError,
              onApplyReplacement: _applySpellingReplacement,
              onDismiss: () => setState(() {
                _spellIssues = const [];
                _spellCheckError = null;
                _spellCheckCompleted = false;
              }),
            ),
            const SizedBox(height: 12),
          ],
          if (!widget.focusMode && _showSnapshots) ...[
            _SceneSnapshotsPanel(
              copy: copy,
              currentScene: scene,
              snapshots: widget.snapshots,
              selectedSnapshot: _selectedSnapshot,
              onSelectSnapshot: (snapshot) => setState(
                () => _selectedSnapshot =
                    _selectedSnapshot?.id == snapshot.id ? null : snapshot,
              ),
              onCreateSnapshot: widget.onCreateSnapshot,
              onRestoreSnapshot: widget.onRestoreSnapshot,
              onDeleteSnapshot: widget.onDeleteSnapshot,
            ),
            const SizedBox(height: 12),
          ],
          if (!widget.focusMode && _showAnnotations) ...[
            _SceneAnnotationsPanel(
              copy: copy,
              annotations: annotations,
              manuscriptText: widget.controller.text,
              onSelectText: _selectAnnotationText,
              onEdit: _editAnnotation,
              onToggleResolved: _toggleAnnotationResolved,
              onDelete: _deleteAnnotation,
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
                  final hideInspector = constraints.maxHeight < 430;
                  if (hideInspector) {
                    return manuscriptField;
                  }
                  final minimumManuscriptHeight =
                      constraints.maxHeight < 620 ? 260.0 : 360.0;
                  final availableInspectorHeight =
                      constraints.maxHeight - minimumManuscriptHeight;
                  if (availableInspectorHeight < 180) {
                    return manuscriptField;
                  }
                  final inspectorHeight = math.min(
                    (constraints.maxHeight * 0.40).clamp(220.0, 340.0),
                    availableInspectorHeight,
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
    required this.focusNode,
    required this.scrollController,
    required this.focusMode,
    required this.fontSize,
  });

  final WritellerCopy copy;
  final TextEditingController controller;
  final FocusNode focusNode;
  final ScrollController scrollController;
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
                  focusNode: focusNode,
                  scrollController: scrollController,
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

final class _SceneAnnotationsPanel extends StatelessWidget {
  const _SceneAnnotationsPanel({
    required this.copy,
    required this.annotations,
    required this.manuscriptText,
    required this.onSelectText,
    required this.onEdit,
    required this.onToggleResolved,
    required this.onDelete,
  });

  final WritellerCopy copy;
  final List<SceneAnnotation> annotations;
  final String manuscriptText;
  final ValueChanged<SceneAnnotation> onSelectText;
  final ValueChanged<SceneAnnotation> onEdit;
  final ValueChanged<SceneAnnotation> onToggleResolved;
  final ValueChanged<SceneAnnotation> onDelete;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final openCount =
        annotations.where((annotation) => !annotation.resolved).length;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.rate_review_outlined, color: color.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${copy.t('annotations')} · $openCount ${copy.t('open')}',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
                _HelpTooltip(message: copy.t('helpAnnotations')),
              ],
            ),
            const SizedBox(height: 10),
            if (annotations.isEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 4, 10, 10),
                child: Text(
                  copy.t('noAnnotationsYet'),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: color.onSurfaceVariant,
                      ),
                ),
              )
            else
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 260),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: annotations.length,
                  separatorBuilder: (_, __) => Divider(
                    height: 1,
                    color: color.outlineVariant,
                  ),
                  itemBuilder: (context, index) {
                    final annotation = annotations[index];
                    return _SceneAnnotationTile(
                      copy: copy,
                      annotation: annotation,
                      manuscriptText: manuscriptText,
                      onSelectText: onSelectText,
                      onEdit: onEdit,
                      onToggleResolved: onToggleResolved,
                      onDelete: onDelete,
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

final class _SceneAnnotationTile extends StatelessWidget {
  const _SceneAnnotationTile({
    required this.copy,
    required this.annotation,
    required this.manuscriptText,
    required this.onSelectText,
    required this.onEdit,
    required this.onToggleResolved,
    required this.onDelete,
  });

  final WritellerCopy copy;
  final SceneAnnotation annotation;
  final String manuscriptText;
  final ValueChanged<SceneAnnotation> onSelectText;
  final ValueChanged<SceneAnnotation> onEdit;
  final ValueChanged<SceneAnnotation> onToggleResolved;
  final ValueChanged<SceneAnnotation> onDelete;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final range = _annotationTextRange(annotation, manuscriptText);
    final resolved = annotation.resolved;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Opacity(
        opacity: resolved ? 0.68 : 1,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Icon(
                resolved
                    ? Icons.task_alt_outlined
                    : Icons.radio_button_unchecked,
                size: 18,
                color: resolved ? color.onSurfaceVariant : color.primary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    annotation.comment,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '“${annotation.selectedText}”',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: color.onSurfaceVariant,
                          fontStyle: FontStyle.italic,
                        ),
                  ),
                  if (range == null) ...[
                    const SizedBox(height: 4),
                    Text(
                      copy.t('annotationTextMoved'),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: color.tertiary,
                          ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Wrap(
              spacing: 2,
              children: [
                IconButton(
                  tooltip: copy.t('selectAnnotationText'),
                  onPressed:
                      range == null ? null : () => onSelectText(annotation),
                  icon: const Icon(Icons.my_location_outlined, size: 18),
                ),
                IconButton(
                  tooltip: copy.t('editAnnotation'),
                  onPressed: () => onEdit(annotation),
                  icon: const Icon(Icons.edit_outlined, size: 18),
                ),
                IconButton(
                  tooltip: resolved
                      ? copy.t('reopenAnnotation')
                      : copy.t('resolveAnnotation'),
                  onPressed: () => onToggleResolved(annotation),
                  icon: Icon(
                    resolved ? Icons.undo_outlined : Icons.check_circle_outline,
                    size: 18,
                  ),
                ),
                IconButton(
                  tooltip: copy.t('deleteAnnotation'),
                  onPressed: () => onDelete(annotation),
                  icon: const Icon(Icons.delete_outline, size: 18),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

final class _SpellCheckResultsPanel extends StatelessWidget {
  const _SpellCheckResultsPanel({
    required this.copy,
    required this.issues,
    required this.error,
    required this.onApplyReplacement,
    required this.onDismiss,
  });

  final WritellerCopy copy;
  final List<SpellCheckIssue> issues;
  final String? error;
  final void Function(SpellCheckIssue issue, String replacement)
      onApplyReplacement;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.spellcheck_outlined, size: 18, color: color.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    copy.t('spellCheckResults'),
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
                IconButton(
                  tooltip: copy.t('close'),
                  onPressed: onDismiss,
                  icon: const Icon(Icons.close, size: 18),
                ),
              ],
            ),
            if (error != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 4, 10, 8),
                child: Text(
                  error!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: color.error,
                      ),
                ),
              )
            else if (issues.isEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 4, 10, 8),
                child: Text(
                  copy.t('spellCheckNoIssues'),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: color.onSurfaceVariant,
                      ),
                ),
              )
            else
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 210),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: issues.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final issue = issues[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            issue.message,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          if (issue.context.isNotEmpty) ...[
                            const SizedBox(height: 3),
                            Text(
                              issue.context,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(color: color.onSurfaceVariant),
                            ),
                          ],
                          if (issue.replacements.isNotEmpty) ...[
                            const SizedBox(height: 7),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: [
                                for (final replacement in issue.replacements)
                                  ActionChip(
                                    label: Text(replacement),
                                    onPressed: () => onApplyReplacement(
                                      issue,
                                      replacement,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

final class _SceneSnapshotsPanel extends StatelessWidget {
  const _SceneSnapshotsPanel({
    required this.copy,
    required this.currentScene,
    required this.snapshots,
    required this.selectedSnapshot,
    required this.onSelectSnapshot,
    required this.onCreateSnapshot,
    required this.onRestoreSnapshot,
    required this.onDeleteSnapshot,
  });

  final WritellerCopy copy;
  final Scene currentScene;
  final List<SceneSnapshot> snapshots;
  final SceneSnapshot? selectedSnapshot;
  final ValueChanged<SceneSnapshot> onSelectSnapshot;
  final VoidCallback onCreateSnapshot;
  final ValueChanged<SceneSnapshot> onRestoreSnapshot;
  final ValueChanged<SceneSnapshot> onDeleteSnapshot;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.history_outlined, color: color.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    copy.t('sceneSnapshots'),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: onCreateSnapshot,
                  icon: const Icon(Icons.add_circle_outline),
                  label: Text(copy.t('createSnapshot')),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (snapshots.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  copy.t('noSnapshotsYet'),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: color.onSurfaceVariant,
                      ),
                ),
              )
            else
              LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxWidth < 760;
                  final list = _SnapshotList(
                    copy: copy,
                    snapshots: snapshots,
                    selectedSnapshot: selectedSnapshot,
                    onSelectSnapshot: onSelectSnapshot,
                    onRestoreSnapshot: onRestoreSnapshot,
                    onDeleteSnapshot: onDeleteSnapshot,
                  );
                  final diff = selectedSnapshot == null
                      ? _SnapshotDiffPlaceholder(copy: copy)
                      : _SceneSnapshotDiff(
                          copy: copy,
                          currentScene: currentScene,
                          snapshot: selectedSnapshot!,
                        );
                  if (compact) {
                    return Column(
                      children: [
                        SizedBox(height: 190, child: list),
                        const SizedBox(height: 10),
                        diff,
                      ],
                    );
                  }
                  return SizedBox(
                    height: 260,
                    child: Row(
                      children: [
                        SizedBox(width: 320, child: list),
                        const SizedBox(width: 12),
                        Expanded(child: diff),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

final class _SnapshotList extends StatelessWidget {
  const _SnapshotList({
    required this.copy,
    required this.snapshots,
    required this.selectedSnapshot,
    required this.onSelectSnapshot,
    required this.onRestoreSnapshot,
    required this.onDeleteSnapshot,
  });

  final WritellerCopy copy;
  final List<SceneSnapshot> snapshots;
  final SceneSnapshot? selectedSnapshot;
  final ValueChanged<SceneSnapshot> onSelectSnapshot;
  final ValueChanged<SceneSnapshot> onRestoreSnapshot;
  final ValueChanged<SceneSnapshot> onDeleteSnapshot;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: snapshots.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final snapshot = snapshots[index];
        final selected = selectedSnapshot?.id == snapshot.id;
        return ListTile(
          selected: selected,
          leading: Icon(_snapshotReasonIcon(snapshot.reason)),
          title: Text(
            _snapshotReasonLabel(snapshot.reason, copy),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(_formatLocalDateTime(snapshot.createdAt)),
          onTap: () => onSelectSnapshot(snapshot),
          trailing: Wrap(
            spacing: 2,
            children: [
              Tooltip(
                message: copy.t('restoreSnapshot'),
                child: IconButton(
                  onPressed: () => onRestoreSnapshot(snapshot),
                  icon: const Icon(Icons.restore_outlined),
                ),
              ),
              Tooltip(
                message: copy.t('deleteSnapshot'),
                child: IconButton(
                  onPressed: () => onDeleteSnapshot(snapshot),
                  icon: const Icon(Icons.delete_outline),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

final class _SnapshotDiffPlaceholder extends StatelessWidget {
  const _SnapshotDiffPlaceholder({required this.copy});

  final WritellerCopy copy;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: color.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            copy.t('selectSnapshotForDiff'),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color.onSurfaceVariant,
                ),
          ),
        ),
      ),
    );
  }
}

final class _SceneSnapshotDiff extends StatelessWidget {
  const _SceneSnapshotDiff({
    required this.copy,
    required this.currentScene,
    required this.snapshot,
  });

  final WritellerCopy copy;
  final Scene currentScene;
  final SceneSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final fields = _snapshotDiffRows(currentScene, snapshot.scene, copy);
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: fields.isEmpty
          ? Center(child: Text(copy.t('snapshotNoDiff')))
          : ListView.separated(
              padding: const EdgeInsets.all(10),
              itemCount: fields.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) =>
                  _SnapshotDiffRow(row: fields[index]),
            ),
    );
  }
}

final class _SnapshotDiffRow extends StatelessWidget {
  const _SnapshotDiffRow({required this.row});

  final _SnapshotDiffData row;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          row.label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _DiffTextBox(
                title: row.beforeTitle,
                text: row.before,
                color: color.errorContainer.withValues(alpha: 0.36),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _DiffTextBox(
                title: row.afterTitle,
                text: row.after,
                color: color.primaryContainer.withValues(alpha: 0.34),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

final class _DiffTextBox extends StatelessWidget {
  const _DiffTextBox({
    required this.title,
    required this.text,
    required this.color,
  });

  final String title;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              text.trim().isEmpty ? '-' : _shortPreview(text),
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

final class _SnapshotDiffData {
  const _SnapshotDiffData({
    required this.label,
    required this.beforeTitle,
    required this.before,
    required this.afterTitle,
    required this.after,
  });

  final String label;
  final String beforeTitle;
  final String before;
  final String afterTitle;
  final String after;
}

List<_SnapshotDiffData> _snapshotDiffRows(
  Scene current,
  Scene snapshot,
  WritellerCopy copy,
) {
  final rows = <_SnapshotDiffData>[];
  void addIfChanged(String label, String before, String after) {
    if (before.trim() == after.trim()) return;
    rows.add(
      _SnapshotDiffData(
        label: label,
        beforeTitle: copy.t('snapshotVersion'),
        before: before,
        afterTitle: copy.t('currentVersion'),
        after: after,
      ),
    );
  }

  addIfChanged(copy.t('sceneTitle'), snapshot.title, current.title);
  addIfChanged(copy.t('summary'), snapshot.summary, current.summary);
  addIfChanged(copy.t('goal'), snapshot.goal ?? '', current.goal ?? '');
  addIfChanged(
    copy.t('conflict'),
    snapshot.conflict ?? '',
    current.conflict ?? '',
  );
  addIfChanged(
      copy.t('outcome'), snapshot.outcome ?? '', current.outcome ?? '');
  addIfChanged(
      copy.t('manuscript'), snapshot.manuscriptText, current.manuscriptText);
  return rows;
}

String _shortPreview(String value) {
  final lines = value.trim().split(RegExp(r'\r?\n'));
  if (lines.length <= 8) return value.trim();
  return [...lines.take(8), '...'].join('\n');
}

String _snapshotReasonLabel(SceneSnapshotReason reason, WritellerCopy copy) {
  return switch (reason) {
    SceneSnapshotReason.manual => copy.t('snapshotReasonManual'),
    SceneSnapshotReason.majorEdit => copy.t('snapshotReasonMajorEdit'),
    SceneSnapshotReason.aiAccepted => copy.t('snapshotReasonAiAccepted'),
    SceneSnapshotReason.restore => copy.t('snapshotReasonRestore'),
  };
}

IconData _snapshotReasonIcon(SceneSnapshotReason reason) {
  return switch (reason) {
    SceneSnapshotReason.manual => Icons.bookmark_add_outlined,
    SceneSnapshotReason.majorEdit => Icons.edit_note_outlined,
    SceneSnapshotReason.aiAccepted => Icons.psychology_alt_outlined,
    SceneSnapshotReason.restore => Icons.restore_outlined,
  };
}

final class _FocusModeButton extends StatelessWidget {
  const _FocusModeButton({
    required this.copy,
    required this.focusMode,
    required this.onPressed,
  });

  final WritellerCopy copy;
  final bool focusMode;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final label = focusMode ? copy.t('exitFocusMode') : copy.t('focusMode');
    final caption = copy.t('focusModeCaption');
    final icon = focusMode ? Icons.fullscreen_exit : Icons.fullscreen;

    if (focusMode) {
      return Tooltip(
        message: label,
        child: Semantics(
          button: true,
          label: label,
          child: OutlinedButton.icon(
            onPressed: onPressed,
            icon: Icon(icon, size: 18),
            label: Text(label),
            style: OutlinedButton.styleFrom(
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              foregroundColor: color.onSurfaceVariant,
              side: BorderSide(color: color.outlineVariant),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      );
    }

    return Tooltip(
      message: label,
      child: Semantics(
        button: true,
        label: '$label. $caption',
        child: FilledButton.tonal(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            backgroundColor:
                focusMode ? color.primaryContainer : color.secondaryContainer,
            foregroundColor: focusMode
                ? color.onPrimaryContainer
                : color.onSecondaryContainer,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 21),
              const SizedBox(width: 10),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: focusMode
                              ? color.onPrimaryContainer
                              : color.onSecondaryContainer,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  Text(
                    caption,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: (focusMode
                                  ? color.onPrimaryContainer
                                  : color.onSecondaryContainer)
                              .withValues(alpha: 0.78),
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _ManuscriptBlockFormat {
  normal,
  heading,
  subheading,
  quote,
}

final class _ManuscriptFormatToolbar extends StatelessWidget {
  const _ManuscriptFormatToolbar({
    required this.copy,
    required this.controller,
  });

  final WritellerCopy copy;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final textStyle = Theme.of(context).textTheme.labelLarge?.copyWith(
          color: color.onSurfaceVariant,
          fontWeight: FontWeight.w700,
        );
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.surfaceContainerLow,
        border: Border.all(color: color.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              Text(copy.t('formatToolbarLabel'), style: textStyle),
              const SizedBox(width: 10),
              PopupMenuButton<_ManuscriptBlockFormat>(
                tooltip: copy.t('formatParagraphMenu'),
                onSelected: _applyBlockFormat,
                itemBuilder: (context) => [
                  _formatMenuItem(
                    _ManuscriptBlockFormat.normal,
                    Icons.notes,
                    copy.t('formatNormalText'),
                  ),
                  _formatMenuItem(
                    _ManuscriptBlockFormat.heading,
                    Icons.title,
                    copy.t('formatHeading'),
                  ),
                  _formatMenuItem(
                    _ManuscriptBlockFormat.subheading,
                    Icons.short_text,
                    copy.t('formatSubheading'),
                  ),
                  _formatMenuItem(
                    _ManuscriptBlockFormat.quote,
                    Icons.format_quote,
                    copy.t('formatQuote'),
                  ),
                ],
                child: _FormatMenuButton(
                  icon: Icons.text_fields,
                  label: copy.t('formatParagraphMenu'),
                ),
              ),
              _ToolbarDivider(color: color.outlineVariant),
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
                tooltip: copy.t('formatUnderline'),
                icon: Icons.format_underlined,
                onPressed: () => _wrapSelection(
                  prefix: '<u>',
                  suffix: '</u>',
                  placeholder: copy.t('formatPlaceholder'),
                ),
              ),
              _FormatIconButton(
                tooltip: copy.t('formatStrikethrough'),
                icon: Icons.format_strikethrough,
                onPressed: () => _wrapSelection(
                  prefix: '~~',
                  suffix: '~~',
                  placeholder: copy.t('formatPlaceholder'),
                ),
              ),
              _ToolbarDivider(color: color.outlineVariant),
              _FormatIconButton(
                tooltip: copy.t('formatQuote'),
                icon: Icons.format_quote,
                onPressed: () => _prefixSelectedLines(
                  (_, line) => '> ${_stripLinePrefix(line)}',
                ),
              ),
              _FormatIconButton(
                tooltip: copy.t('formatBulletedList'),
                icon: Icons.format_list_bulleted,
                onPressed: () => _prefixSelectedLines(
                  (_, line) => '- ${_stripLinePrefix(line)}',
                ),
              ),
              _FormatIconButton(
                tooltip: copy.t('formatNumberedList'),
                icon: Icons.format_list_numbered,
                onPressed: () => _prefixSelectedLines(
                  (index, line) => '${index + 1}. ${_stripLinePrefix(line)}',
                ),
              ),
              _ToolbarDivider(color: color.outlineVariant),
              _FormatIconButton(
                tooltip: copy.t('formatOutdent'),
                icon: Icons.format_indent_decrease,
                onPressed: _outdentSelection,
              ),
              _FormatIconButton(
                tooltip: copy.t('formatIndent'),
                icon: Icons.format_indent_increase,
                onPressed: _indentSelection,
              ),
              _ToolbarDivider(color: color.outlineVariant),
              _FormatIconButton(
                tooltip: copy.t('formatClear'),
                icon: Icons.format_clear,
                onPressed: _clearSelectionFormatting,
              ),
            ],
          ),
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
      case _ManuscriptBlockFormat.normal:
        _prefixSelectedLines(
            (_, line) => _stripLinePrefix(_stripHeading(line)));
      case _ManuscriptBlockFormat.heading:
        _prefixSelectedLines((_, line) => '# ${_stripHeading(line)}');
      case _ManuscriptBlockFormat.subheading:
        _prefixSelectedLines((_, line) => '## ${_stripHeading(line)}');
      case _ManuscriptBlockFormat.quote:
        _prefixSelectedLines((_, line) => '> ${_stripLinePrefix(line)}');
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
    final alreadyWrapped =
        !selection.isCollapsed && _hasWrapping(selectedText, prefix, suffix);
    final replacement = alreadyWrapped
        ? selectedText.substring(
            prefix.length,
            selectedText.length - suffix.length,
          )
        : '$prefix$selectedText$suffix';
    final updated =
        text.replaceRange(selection.start, selection.end, replacement);
    final selectionStart =
        selection.start + (alreadyWrapped ? 0 : prefix.length);
    final selectionEnd = selectionStart +
        (alreadyWrapped ? replacement.length : selectedText.length);
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

  bool _hasWrapping(String selectedText, String prefix, String suffix) {
    return selectedText.length >= prefix.length + suffix.length &&
        selectedText.startsWith(prefix) &&
        selectedText.endsWith(suffix);
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

  void _indentSelection() {
    _prefixSelectedLines((_, line) => line.isEmpty ? line : '  $line');
  }

  void _outdentSelection() {
    _prefixSelectedLines(
      (_, line) => line.replaceFirst(RegExp(r'^\s{1,2}'), ''),
    );
  }

  void _clearSelectionFormatting() {
    final value = controller.value;
    final text = value.text;
    final selection = _safeSelection(value);
    final selectedText = selection.isCollapsed
        ? _currentLine(text, selection)
        : text.substring(selection.start, selection.end);
    final replacement = _clearInlineFormatting(selectedText)
        .split('\n')
        .map((line) => _stripLinePrefix(_stripHeading(line)))
        .join('\n');

    if (selection.isCollapsed) {
      final lineStart =
          text.lastIndexOf('\n', math.max(0, selection.start - 1)) + 1;
      final lineEnd = _selectedLineEnd(text, selection);
      final updated = text.replaceRange(lineStart, lineEnd, replacement);
      controller.value = value.copyWith(
        text: updated,
        selection: TextSelection.collapsed(
          offset: math.min(lineStart + replacement.length, updated.length),
        ),
        composing: TextRange.empty,
      );
      return;
    }

    final updated =
        text.replaceRange(selection.start, selection.end, replacement);
    controller.value = value.copyWith(
      text: updated,
      selection: TextSelection(
        baseOffset: selection.start,
        extentOffset: selection.start + replacement.length,
      ),
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

  String _currentLine(String text, TextSelection selection) {
    final lineStart =
        text.lastIndexOf('\n', math.max(0, selection.start - 1)) + 1;
    final lineEnd = _selectedLineEnd(text, selection);
    return text.substring(lineStart, lineEnd);
  }

  String _clearInlineFormatting(String text) {
    return text
        .replaceAllMapped(
          RegExp(r'\*\*(.*?)\*\*', dotAll: true),
          (match) => match.group(1) ?? '',
        )
        .replaceAllMapped(
          RegExp(r'~~(.*?)~~', dotAll: true),
          (match) => match.group(1) ?? '',
        )
        .replaceAllMapped(
          RegExp(r'<u>(.*?)</u>', caseSensitive: false, dotAll: true),
          (match) => match.group(1) ?? '',
        )
        .replaceAllMapped(
          RegExp(r'\*(.*?)\*', dotAll: true),
          (match) => match.group(1) ?? '',
        );
  }
}

final class _FormatMenuButton extends StatelessWidget {
  const _FormatMenuButton({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: color.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 7, 8, 7),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color.onSurfaceVariant),
            const SizedBox(width: 7),
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down,
              size: 18,
              color: color.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
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

  final WritellerCopy copy;
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

  static String _savedLabel(WritellerCopy copy, DateTime? savedAt) {
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
    required this.researchItems,
    required this.suggestions,
    required this.selectedPanel,
    required this.onPanelChanged,
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

  final WritellerCopy copy;
  final Scene scene;
  final List<Chapter> chapters;
  final List<CatalogItem> catalogItems;
  final List<Relationship> relationships;
  final List<ResearchItem> researchItems;
  final List<AISuggestion> suggestions;
  final _EditorSidePanelKind selectedPanel;
  final ValueChanged<_EditorSidePanelKind> onPanelChanged;
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
    final panel = switch (selectedPanel) {
      _EditorSidePanelKind.planning => _ScenePlanningFields(
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
      _EditorSidePanelKind.context => _SceneContextLinks(
          copy: copy,
          scene: scene,
          catalogItems: catalogItems,
          relationships: relationships,
          onToggleLink: onToggleSceneCatalogLink,
          onAddExistingItems: onAddExistingSceneCatalogItems,
          onCreateItem: onCreateSceneCatalogItem,
        ),
      _EditorSidePanelKind.research => _SceneResearchViewer(
          copy: copy,
          scene: scene,
          items: researchItems,
        ),
      _EditorSidePanelKind.ai => _SceneAiHelpBox(
          copy: copy,
          scene: scene,
          isRequesting: isRequestingAi,
          latestSuggestion: _latestSceneSuggestion(scene, suggestions),
          onRequest: onRequestSceneAiHelp,
        ),
    };
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.surfaceContainerLow,
        border: Border.all(color: color.outlineVariant),
        borderRadius: BorderRadius.circular(10),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final header = _SceneInspectorHeader(
            copy: copy,
            scene: scene,
            chapters: chapters,
            catalogItems: catalogItems,
            relationships: relationships,
            suggestions: suggestions,
            targetText: wordTargetController.text,
            selectedPanel: selectedPanel,
            onPanelChanged: onPanelChanged,
            showMeta: constraints.maxHeight >= 320,
          );

          if (constraints.maxHeight < 320) {
            final meta = _SceneMetaOverview(
              copy: copy,
              scene: scene,
              chapters: chapters,
              catalogItems: catalogItems,
              relationships: relationships,
              suggestions: suggestions,
              targetText: wordTargetController.text,
            );
            return ListView(
              key: ValueKey('scene-inspector-compact-${selectedPanel.name}'),
              padding: EdgeInsets.zero,
              children: [
                header,
                Divider(height: 1, color: color.outlineVariant),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      panel,
                      const SizedBox(height: 14),
                      Divider(height: 1, color: color.outlineVariant),
                      const SizedBox(height: 14),
                      meta,
                    ],
                  ),
                ),
              ],
            );
          }

          return Column(
            children: [
              header,
              Divider(height: 1, color: color.outlineVariant),
              Expanded(
                child: ListView(
                  key: ValueKey('scene-inspector-${selectedPanel.name}'),
                  padding: const EdgeInsets.all(14),
                  children: [panel],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

final class _SceneInspectorHeader extends StatelessWidget {
  const _SceneInspectorHeader({
    required this.copy,
    required this.scene,
    required this.chapters,
    required this.catalogItems,
    required this.relationships,
    required this.suggestions,
    required this.targetText,
    required this.selectedPanel,
    required this.onPanelChanged,
    required this.showMeta,
  });

  final WritellerCopy copy;
  final Scene scene;
  final List<Chapter> chapters;
  final List<CatalogItem> catalogItems;
  final List<Relationship> relationships;
  final List<AISuggestion> suggestions;
  final String targetText;
  final _EditorSidePanelKind selectedPanel;
  final ValueChanged<_EditorSidePanelKind> onPanelChanged;
  final bool showMeta;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.tune_outlined, color: color.primary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  copy.t('sceneInspector'),
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
            ],
          ),
          if (showMeta) ...[
            const SizedBox(height: 12),
            _SceneMetaOverview(
              copy: copy,
              scene: scene,
              chapters: chapters,
              catalogItems: catalogItems,
              relationships: relationships,
              suggestions: suggestions,
              targetText: targetText,
            ),
          ],
          const SizedBox(height: 12),
          _EditorSidePanelTabs(
            copy: copy,
            selected: selectedPanel,
            onSelected: onPanelChanged,
          ),
        ],
      ),
    );
  }
}

final class _EditorSidePanelTabs extends StatelessWidget {
  const _EditorSidePanelTabs({
    required this.copy,
    required this.selected,
    required this.onSelected,
  });

  final WritellerCopy copy;
  final _EditorSidePanelKind selected;
  final ValueChanged<_EditorSidePanelKind> onSelected;

  @override
  Widget build(BuildContext context) {
    final options = [
      _EditorSidePanelOption(
        kind: _EditorSidePanelKind.planning,
        icon: Icons.account_tree_outlined,
        label: copy.t('editorPanelPlanning'),
        key: const ValueKey('editor-panel-planning'),
      ),
      _EditorSidePanelOption(
        kind: _EditorSidePanelKind.context,
        icon: Icons.hub_outlined,
        label: copy.t('editorPanelContext'),
        key: const ValueKey('editor-panel-context'),
      ),
      _EditorSidePanelOption(
        kind: _EditorSidePanelKind.research,
        icon: Icons.travel_explore_outlined,
        label: copy.t('editorPanelResearch'),
        key: const ValueKey('editor-panel-research'),
      ),
      _EditorSidePanelOption(
        kind: _EditorSidePanelKind.ai,
        icon: Icons.psychology_alt_outlined,
        label: copy.t('editorPanelAi'),
        key: const ValueKey('editor-panel-ai'),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final showLabel = constraints.maxWidth >= 250;
        final selectedLabel =
            options.firstWhere((option) => option.kind == selected).label;
        return Row(
          children: [
            if (showLabel) ...[
              Expanded(
                child: Text(
                  selectedLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            for (final option in options)
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: _EditorSidePanelButton(
                  option: option,
                  selected: selected == option.kind,
                  onPressed: () => onSelected(option.kind),
                  showText: !showLabel,
                ),
              ),
          ],
        );
      },
    );
  }
}

final class _EditorSidePanelOption {
  const _EditorSidePanelOption({
    required this.kind,
    required this.icon,
    required this.label,
    required this.key,
  });

  final _EditorSidePanelKind kind;
  final IconData icon;
  final String label;
  final ValueKey<String> key;
}

final class _EditorSidePanelButton extends StatelessWidget {
  const _EditorSidePanelButton({
    required this.option,
    required this.selected,
    required this.onPressed,
    required this.showText,
  });

  final _EditorSidePanelOption option;
  final bool selected;
  final VoidCallback onPressed;
  final bool showText;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final design = Theme.of(context).extension<WritellerDesignTokens>()!;
    final foreground = selected ? design.ink : color.onSurfaceVariant;
    final background = selected ? design.inkSoft : color.surfaceContainerLowest;
    final icon = Icon(option.icon, size: 18, color: foreground);
    return Tooltip(
      message: option.label,
      child: Semantics(
        button: true,
        selected: selected,
        label: option.label,
        child: showText
            ? SizedBox(
                width: 118,
                child: OutlinedButton.icon(
                  key: option.key,
                  onPressed: onPressed,
                  icon: icon,
                  label: Text(
                    option.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  style: OutlinedButton.styleFrom(
                    alignment: Alignment.centerLeft,
                    foregroundColor: foreground,
                    backgroundColor: background,
                    side: BorderSide(
                      color: selected
                          ? design.ink.withValues(alpha: 0.34)
                          : color.outlineVariant,
                    ),
                    minimumSize: const Size(0, 38),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    textStyle:
                        Theme.of(context).textTheme.labelMedium?.copyWith(
                              fontWeight:
                                  selected ? FontWeight.w800 : FontWeight.w700,
                            ),
                  ),
                ),
              )
            : SizedBox.square(
                dimension: 38,
                child: selected
                    ? IconButton.filledTonal(
                        key: option.key,
                        onPressed: onPressed,
                        icon: icon,
                      )
                    : IconButton.outlined(
                        key: option.key,
                        onPressed: onPressed,
                        icon: icon,
                      ),
              ),
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

  final WritellerCopy copy;
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

  final WritellerCopy copy;
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
            const SizedBox(height: 8),
            Text(
              copy.t('editorAiWorkflowHint'),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _ActionHelp(
                  message: _aiTaskHelp(AITaskKind.authorQuestions, copy),
                  child: OutlinedButton.icon(
                    onPressed: widget.isRequesting
                        ? null
                        : () => _useTemplate(AITaskKind.authorQuestions),
                    icon: const Icon(Icons.help_outline),
                    label: Text(copy.t('aiTaskAuthorQuestions')),
                  ),
                ),
                _ActionHelp(
                  message:
                      _aiTaskHelp(AITaskKind.sceneGoalConflictOutcome, copy),
                  child: OutlinedButton.icon(
                    onPressed: widget.isRequesting
                        ? null
                        : () => _useTemplate(
                              AITaskKind.sceneGoalConflictOutcome,
                            ),
                    icon: const Icon(Icons.account_tree_outlined),
                    label: Text(copy.t('requestStructure')),
                  ),
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

  void _useTemplate(AITaskKind task) {
    _promptController.text = _promptTemplateFor(task, widget.copy);
    _promptController.selection = TextSelection.collapsed(
      offset: _promptController.text.length,
    );
  }
}

final class _ManuscriptToolbar extends StatelessWidget {
  const _ManuscriptToolbar({
    required this.copy,
    required this.text,
    required this.targetText,
  });

  final WritellerCopy copy;
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

  final WritellerCopy copy;
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

  final WritellerCopy copy;
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

  final WritellerCopy copy;
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
            Builder(
              builder: (buttonContext) => OutlinedButton.icon(
                key: const ValueKey('new-scene-context-menu'),
                onPressed: () => _showNewContextMenu(buttonContext),
                icon: const Icon(Icons.add),
                label: Text(copy.t('newSceneContextItem')),
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

  Future<void> _showNewContextMenu(BuildContext context) async {
    final button = context.findRenderObject() as RenderBox;
    final overlay =
        Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;
    final topLeft = button.localToGlobal(Offset.zero, ancestor: overlay);
    final bottomRight = button.localToGlobal(
      button.size.bottomRight(Offset.zero),
      ancestor: overlay,
    );
    final selected = await showMenu<EntityType>(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromPoints(topLeft, bottomRight),
        Offset.zero & overlay.size,
      ),
      items: [
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
    );
    if (selected != null) onCreateItem(selected);
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

  final WritellerCopy copy;
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

TextRange? _annotationTextRange(
  SceneAnnotation annotation,
  String manuscriptText,
) {
  final start = annotation.startOffset;
  final end = annotation.endOffset;
  if (start >= 0 && end <= manuscriptText.length && start < end) {
    final current = manuscriptText.substring(start, end);
    if (current == annotation.selectedText) {
      return TextRange(start: start, end: end);
    }
  }
  if (annotation.selectedText.isEmpty) return null;
  final fallbackStart = manuscriptText.indexOf(annotation.selectedText);
  if (fallbackStart < 0) return null;
  return TextRange(
    start: fallbackStart,
    end: fallbackStart + annotation.selectedText.length,
  );
}

double _estimatedScrollOffsetForTextOffset(
  String text,
  int textOffset,
  double fontSize,
) {
  final safeOffset = textOffset.clamp(0, text.length).toInt();
  final beforeSelection = text.substring(0, safeOffset);
  final explicitLines = '\n'.allMatches(beforeSelection).length;
  final wrappedLines = beforeSelection.length ~/ 68;
  return math.max(0, explicitLines + wrappedLines - 2) * fontSize * 1.75;
}
