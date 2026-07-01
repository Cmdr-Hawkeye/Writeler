part of '../main.dart';

// AI workshop prompt controls, suggestion lists, and AI response review widgets.

final class _SubmitAiPromptIntent extends Intent {
  const _SubmitAiPromptIntent();
}

enum _AIWorkshopContextKind { project, scene }

enum _AISuggestionInboxFilter { open, accepted, noted, rejected, all }

enum _AIConsoleTab { overview, context, instruction, prompt }

typedef _AIWorkshopTaskRequest = void Function(
  AITaskKind task, {
  required _AIWorkshopContextKind contextKind,
  Scene? scene,
  required List<CatalogItem> contextCatalogItems,
  required List<Relationship> contextRelationships,
});

final class _AIWorkshop extends StatefulWidget {
  const _AIWorkshop({
    required this.copy,
    required this.project,
    required this.selectedScene,
    required this.chapters,
    required this.scenes,
    required this.catalogItems,
    required this.relationships,
    required this.suggestions,
    required this.notes,
    required this.activeProviderConfig,
    required this.promptController,
    required this.isRequesting,
    required this.lastError,
    required this.onSelectScene,
    required this.onRequestTask,
    required this.onAcceptSuggestion,
    required this.onRejectSuggestion,
    required this.onConvertSuggestion,
    required this.onDeleteNote,
  });

  final WritellerCopy copy;
  final Project? project;
  final Scene? selectedScene;
  final List<Chapter> chapters;
  final List<Scene> scenes;
  final List<CatalogItem> catalogItems;
  final List<Relationship> relationships;
  final List<AISuggestion> suggestions;
  final List<ProjectNote> notes;
  final AIProviderConfig activeProviderConfig;
  final TextEditingController promptController;
  final bool isRequesting;
  final String? lastError;
  final ValueChanged<Scene> onSelectScene;
  final _AIWorkshopTaskRequest onRequestTask;
  final ValueChanged<AISuggestion> onAcceptSuggestion;
  final ValueChanged<AISuggestion> onRejectSuggestion;
  final ValueChanged<AISuggestion> onConvertSuggestion;
  final ValueChanged<ProjectNote> onDeleteNote;

  @override
  State<_AIWorkshop> createState() => _AIWorkshopState();
}

final class _AIWorkshopState extends State<_AIWorkshop> {
  late _AIWorkshopContextKind _contextKind;
  String? _sceneId;
  final Set<String> _selectedCatalogItemIds = {};
  final Set<String> _selectedRelationshipIds = {};

  @override
  void initState() {
    super.initState();
    _contextKind = widget.selectedScene == null
        ? _AIWorkshopContextKind.project
        : _AIWorkshopContextKind.scene;
    _sceneId = widget.selectedScene?.id ?? widget.scenes.firstOrNull?.id;
  }

  @override
  void didUpdateWidget(covariant _AIWorkshop oldWidget) {
    super.didUpdateWidget(oldWidget);
    final sceneStillExists = widget.scenes.any((scene) => scene.id == _sceneId);
    if (!sceneStillExists) {
      _sceneId = widget.selectedScene?.id ?? widget.scenes.firstOrNull?.id;
    }
    if (_contextKind == _AIWorkshopContextKind.scene &&
        oldWidget.selectedScene?.id != widget.selectedScene?.id &&
        widget.selectedScene != null) {
      _sceneId = widget.selectedScene!.id;
    }
    _pruneContextSelection();
  }

  @override
  Widget build(BuildContext context) {
    final scene = _selectedSceneForContext();
    final project = widget.project;
    final canRequest = project != null &&
        (_contextKind == _AIWorkshopContextKind.project || scene != null);

    return Column(
      children: [
        _WorkspaceHeader(title: widget.copy.t('aiWorkshop')),
        const Divider(height: 1),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final suggestionsPanel = _AISuggestionsPanel(
                copy: widget.copy,
                suggestions: widget.suggestions,
                scenes: widget.scenes,
                onAcceptSuggestion: widget.onAcceptSuggestion,
                onConvertSuggestion: widget.onConvertSuggestion,
                onRejectSuggestion: widget.onRejectSuggestion,
              );
              final notesPanel = _AINotesPanel(
                copy: widget.copy,
                notes: widget.notes,
                scenes: widget.scenes,
                onDeleteNote: widget.onDeleteNote,
              );
              final panelsHeight = constraints.maxHeight < 760
                  ? 360.0
                  : constraints.maxHeight - 430;
              final boundedPanelsHeight =
                  panelsHeight < 320 ? 320.0 : panelsHeight;

              return ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  _AIPromptConsole(
                    copy: widget.copy,
                    project: project,
                    contextKind: _contextKind,
                    scene: scene,
                    chapters: widget.chapters,
                    scenes: widget.scenes,
                    catalogItems: widget.catalogItems,
                    relationships: widget.relationships,
                    selectedCatalogItemIds: _selectedCatalogItemIds,
                    selectedRelationshipIds: _selectedRelationshipIds,
                    canRequest: canRequest,
                    activeProviderConfig: widget.activeProviderConfig,
                    promptController: widget.promptController,
                    isRequesting: widget.isRequesting,
                    lastError: widget.lastError,
                    onContextChanged: _changeContext,
                    onSceneChanged: _changeScene,
                    onToggleCatalogItem: _toggleCatalogItem,
                    onToggleRelationship: _toggleRelationship,
                    onClearAdditionalContext: _clearAdditionalContext,
                    onRequestTask: _requestTask,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: boundedPanelsHeight,
                    child: constraints.maxWidth >= 920
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(flex: 3, child: suggestionsPanel),
                              const SizedBox(width: 24),
                              SizedBox(width: 360, child: notesPanel),
                            ],
                          )
                        : Column(
                            children: [
                              Expanded(child: suggestionsPanel),
                              const SizedBox(height: 16),
                              SizedBox(height: 220, child: notesPanel),
                            ],
                          ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Scene? _selectedSceneForContext() {
    return widget.scenes.where((scene) => scene.id == _sceneId).firstOrNull;
  }

  void _changeContext(_AIWorkshopContextKind contextKind) {
    setState(() {
      _contextKind = contextKind;
      _sceneId ??= widget.selectedScene?.id ?? widget.scenes.firstOrNull?.id;
    });
  }

  void _changeScene(Scene scene) {
    setState(() {
      _contextKind = _AIWorkshopContextKind.scene;
      _sceneId = scene.id;
    });
    widget.onSelectScene(scene);
  }

  void _requestTask(AITaskKind task) {
    widget.onRequestTask(
      task,
      contextKind: _contextKind,
      scene: _selectedSceneForContext(),
      contextCatalogItems: _selectedCatalogItems(),
      contextRelationships: _selectedRelationships(),
    );
  }

  List<CatalogItem> _selectedCatalogItems() {
    return widget.catalogItems
        .where((item) => _selectedCatalogItemIds.contains(item.id))
        .toList();
  }

  List<Relationship> _selectedRelationships() {
    return widget.relationships
        .where((relationship) =>
            _selectedRelationshipIds.contains(relationship.id))
        .toList();
  }

  void _toggleCatalogItem(CatalogItem item) {
    setState(() {
      if (!_selectedCatalogItemIds.remove(item.id)) {
        _selectedCatalogItemIds.add(item.id);
      }
    });
  }

  void _toggleRelationship(Relationship relationship) {
    setState(() {
      if (!_selectedRelationshipIds.remove(relationship.id)) {
        _selectedRelationshipIds.add(relationship.id);
      }
    });
  }

  void _clearAdditionalContext() {
    setState(() {
      _selectedCatalogItemIds.clear();
      _selectedRelationshipIds.clear();
    });
  }

  void _pruneContextSelection() {
    final itemIds = widget.catalogItems.map((item) => item.id).toSet();
    final relationshipIds =
        widget.relationships.map((relationship) => relationship.id).toSet();
    _selectedCatalogItemIds.removeWhere((id) => !itemIds.contains(id));
    _selectedRelationshipIds.removeWhere((id) => !relationshipIds.contains(id));
  }
}

const _primaryAiActions = [
  _AiWorkshopAction(
    task: AITaskKind.sceneIdeas,
    icon: Icons.lightbulb_outline,
  ),
  _AiWorkshopAction(
    task: AITaskKind.sceneGoalConflictOutcome,
    icon: Icons.account_tree_outlined,
  ),
  _AiWorkshopAction(
    task: AITaskKind.consistencyCheck,
    icon: Icons.rule_outlined,
  ),
];

const _secondaryAiActions = [
  _AiWorkshopAction(
    task: AITaskKind.timelineCheck,
    icon: Icons.timeline_outlined,
  ),
  _AiWorkshopAction(
    task: AITaskKind.plotGapReview,
    icon: Icons.troubleshoot_outlined,
  ),
  _AiWorkshopAction(
    task: AITaskKind.authorQuestions,
    icon: Icons.help_outline,
  ),
  _AiWorkshopAction(
    task: AITaskKind.styleAnalysis,
    icon: Icons.auto_fix_high_outlined,
  ),
  _AiWorkshopAction(
    task: AITaskKind.researchStructuring,
    icon: Icons.manage_search_outlined,
  ),
  _AiWorkshopAction(
    task: AITaskKind.dialogueIntentAnalysis,
    icon: Icons.forum_outlined,
  ),
];

const _projectPrimaryAiActions = [
  _AiWorkshopAction(
    task: AITaskKind.storylineVariants,
    icon: Icons.alt_route_outlined,
  ),
  _AiWorkshopAction(
    task: AITaskKind.plotGapReview,
    icon: Icons.troubleshoot_outlined,
  ),
  _AiWorkshopAction(
    task: AITaskKind.consistencyCheck,
    icon: Icons.rule_outlined,
  ),
];

const _projectSecondaryAiActions = [
  _AiWorkshopAction(
    task: AITaskKind.sceneIdeas,
    icon: Icons.lightbulb_outline,
  ),
  _AiWorkshopAction(
    task: AITaskKind.timelineCheck,
    icon: Icons.timeline_outlined,
  ),
  _AiWorkshopAction(
    task: AITaskKind.authorQuestions,
    icon: Icons.help_outline,
  ),
  _AiWorkshopAction(
    task: AITaskKind.researchStructuring,
    icon: Icons.manage_search_outlined,
  ),
  _AiWorkshopAction(
    task: AITaskKind.blurbVariants,
    icon: Icons.short_text_outlined,
  ),
  _AiWorkshopAction(
    task: AITaskKind.characterProfile,
    icon: Icons.person_search_outlined,
  ),
  _AiWorkshopAction(
    task: AITaskKind.styleAnalysis,
    icon: Icons.auto_fix_high_outlined,
  ),
];

final class _AIPromptConsole extends StatefulWidget {
  const _AIPromptConsole({
    required this.copy,
    required this.project,
    required this.contextKind,
    required this.scene,
    required this.chapters,
    required this.scenes,
    required this.catalogItems,
    required this.relationships,
    required this.selectedCatalogItemIds,
    required this.selectedRelationshipIds,
    required this.canRequest,
    required this.activeProviderConfig,
    required this.promptController,
    required this.isRequesting,
    required this.lastError,
    required this.onContextChanged,
    required this.onSceneChanged,
    required this.onToggleCatalogItem,
    required this.onToggleRelationship,
    required this.onClearAdditionalContext,
    required this.onRequestTask,
  });

  final WritellerCopy copy;
  final Project? project;
  final _AIWorkshopContextKind contextKind;
  final Scene? scene;
  final List<Chapter> chapters;
  final List<Scene> scenes;
  final List<CatalogItem> catalogItems;
  final List<Relationship> relationships;
  final Set<String> selectedCatalogItemIds;
  final Set<String> selectedRelationshipIds;
  final bool canRequest;
  final AIProviderConfig activeProviderConfig;
  final TextEditingController promptController;
  final bool isRequesting;
  final String? lastError;
  final ValueChanged<_AIWorkshopContextKind> onContextChanged;
  final ValueChanged<Scene> onSceneChanged;
  final ValueChanged<CatalogItem> onToggleCatalogItem;
  final ValueChanged<Relationship> onToggleRelationship;
  final VoidCallback onClearAdditionalContext;
  final ValueChanged<AITaskKind> onRequestTask;

  @override
  State<_AIPromptConsole> createState() => _AIPromptConsoleState();
}

final class _AIPromptConsoleState extends State<_AIPromptConsole> {
  AITaskKind _previewTask = AITaskKind.customScenePrompt;
  _AIConsoleTab _selectedTab = _AIConsoleTab.overview;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final primaryActions = widget.contextKind == _AIWorkshopContextKind.project
        ? _projectPrimaryAiActions
        : _primaryAiActions;
    final secondaryActions =
        widget.contextKind == _AIWorkshopContextKind.project
            ? _projectSecondaryAiActions
            : _secondaryAiActions;
    final contextTitle = widget.contextKind == _AIWorkshopContextKind.project
        ? widget.copy.t('aiProjectContext')
        : widget.copy.t('aiSceneContext');
    final contextDetail = widget.contextKind == _AIWorkshopContextKind.project
        ? widget.project?.title ?? widget.copy.t('selectProject')
        : widget.scene?.title ?? widget.copy.t('aiNeedsScene');
    final selectedCatalogItems = widget.catalogItems
        .where((item) => widget.selectedCatalogItemIds.contains(item.id))
        .toList();
    final selectedRelationships = widget.relationships
        .where((relationship) =>
            widget.selectedRelationshipIds.contains(relationship.id))
        .toList();
    final selectedContextCount =
        selectedCatalogItems.length + selectedRelationships.length;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.surfaceContainerLow,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.outlineVariant),
      ),
      child: DefaultTabController(
        length: _AIConsoleTab.values.length,
        initialIndex: _selectedTab.index,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TabBar(
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                labelPadding: const EdgeInsets.symmetric(horizontal: 12),
                indicatorSize: TabBarIndicatorSize.label,
                onTap: (index) => setState(
                  () => _selectedTab = _AIConsoleTab.values[index],
                ),
                tabs: [
                  for (final tab in _AIConsoleTab.values)
                    Tab(text: _aiConsoleTabLabel(tab, widget.copy)),
                ],
              ),
              const SizedBox(height: 18),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 150),
                child: KeyedSubtree(
                  key: ValueKey(_selectedTab),
                  child: switch (_selectedTab) {
                    _AIConsoleTab.overview => _AIOverviewTab(
                        copy: widget.copy,
                        contextTitle: contextTitle,
                        contextDetail: contextDetail,
                        taskLabel: _aiTaskLabel(_previewTask.name, widget.copy),
                        selectedContextCount: selectedContextCount,
                        providerConfig: widget.activeProviderConfig,
                      ),
                    _AIConsoleTab.context => _AIContextTab(
                        copy: widget.copy,
                        contextTitle: contextTitle,
                        contextDetail: contextDetail,
                        contextKind: widget.contextKind,
                        scenes: widget.scenes,
                        selectedScene: widget.scene,
                        isRequesting: widget.isRequesting,
                        catalogItems: widget.catalogItems,
                        relationships: widget.relationships,
                        selectedCatalogItemIds: widget.selectedCatalogItemIds,
                        selectedRelationshipIds: widget.selectedRelationshipIds,
                        onContextChanged: widget.onContextChanged,
                        onSceneChanged: widget.onSceneChanged,
                        onToggleCatalogItem: widget.onToggleCatalogItem,
                        onToggleRelationship: widget.onToggleRelationship,
                        onClearAdditionalContext:
                            widget.onClearAdditionalContext,
                      ),
                    _AIConsoleTab.instruction => _AIInstructionTab(
                        copy: widget.copy,
                        primaryActions: primaryActions,
                        secondaryActions: secondaryActions,
                        canRequest: widget.canRequest,
                        isRequesting: widget.isRequesting,
                        promptController: widget.promptController,
                        onUseTemplate: _useTemplate,
                        onSubmit: _submitCurrentTask,
                      ),
                    _AIConsoleTab.prompt => _AIPromptSendTab(
                        copy: widget.copy,
                        project: widget.project,
                        contextKind: widget.contextKind,
                        scene: widget.scene,
                        chapters: widget.chapters,
                        scenes: widget.scenes,
                        selectedCatalogItems: selectedCatalogItems,
                        selectedRelationships: selectedRelationships,
                        promptController: widget.promptController,
                        task: _previewTask,
                        canRequest: widget.canRequest,
                        isRequesting: widget.isRequesting,
                        lastError: widget.lastError,
                        activeProviderConfig: widget.activeProviderConfig,
                        onSubmit: _submitCurrentTask,
                      ),
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitCurrentTask() {
    widget.onRequestTask(_previewTask);
  }

  void _useTemplate(AITaskKind task) {
    setState(() => _previewTask = task);
    widget.promptController.text = _promptTemplateFor(task, widget.copy);
    widget.promptController.selection = TextSelection.collapsed(
      offset: widget.promptController.text.length,
    );
  }
}

final class _AIOverviewTab extends StatelessWidget {
  const _AIOverviewTab({
    required this.copy,
    required this.contextTitle,
    required this.contextDetail,
    required this.taskLabel,
    required this.selectedContextCount,
    required this.providerConfig,
  });

  final WritellerCopy copy;
  final String contextTitle;
  final String contextDetail;
  final String taskLabel;
  final int selectedContextCount;
  final AIProviderConfig providerConfig;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _AIWorkflowGuide(copy: copy),
        const SizedBox(height: 16),
        Text(
          copy.t('aiOverviewTitle'),
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 4),
        Text(
          copy.t('aiOverviewBody'),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 14),
        _AIOverviewRows(
          rows: [
            MapEntry(
              copy.t('aiOverviewContextLabel'),
              '$contextTitle - $contextDetail',
            ),
            MapEntry(copy.t('aiOverviewInstructionLabel'), taskLabel),
            MapEntry(
              copy.t('aiOverviewSelectedContextLabel'),
              '$selectedContextCount',
            ),
            MapEntry(
              copy.t('aiOverviewProviderLabel'),
              '${providerConfig.displayName} - ${providerConfig.modelName}',
            ),
          ],
        ),
      ],
    );
  }
}

final class _AIOverviewRows extends StatelessWidget {
  const _AIOverviewRows({required this.rows});

  final List<MapEntry<String, String>> rows;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 560;
        return DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: color.outlineVariant),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              for (var index = 0; index < rows.length; index++) ...[
                if (index > 0) Divider(height: 1, color: color.outlineVariant),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: compact
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              rows[index].key,
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              rows[index].value,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: color.onSurfaceVariant),
                            ),
                          ],
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 190,
                              child: Text(
                                rows[index].key,
                                style: Theme.of(context).textTheme.labelLarge,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                rows[index].value,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: color.onSurfaceVariant),
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

final class _AIContextTab extends StatelessWidget {
  const _AIContextTab({
    required this.copy,
    required this.contextTitle,
    required this.contextDetail,
    required this.contextKind,
    required this.scenes,
    required this.selectedScene,
    required this.isRequesting,
    required this.catalogItems,
    required this.relationships,
    required this.selectedCatalogItemIds,
    required this.selectedRelationshipIds,
    required this.onContextChanged,
    required this.onSceneChanged,
    required this.onToggleCatalogItem,
    required this.onToggleRelationship,
    required this.onClearAdditionalContext,
  });

  final WritellerCopy copy;
  final String contextTitle;
  final String contextDetail;
  final _AIWorkshopContextKind contextKind;
  final List<Scene> scenes;
  final Scene? selectedScene;
  final bool isRequesting;
  final List<CatalogItem> catalogItems;
  final List<Relationship> relationships;
  final Set<String> selectedCatalogItemIds;
  final Set<String> selectedRelationshipIds;
  final ValueChanged<_AIWorkshopContextKind> onContextChanged;
  final ValueChanged<Scene> onSceneChanged;
  final ValueChanged<CatalogItem> onToggleCatalogItem;
  final ValueChanged<Relationship> onToggleRelationship;
  final VoidCallback onClearAdditionalContext;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _AIWorkflowSectionHeader(
          step: '1',
          title: copy.t('aiStepContextTitle'),
          body: copy.t('aiStepContextBody'),
        ),
        const SizedBox(height: 12),
        _HelpedLabel(
          label: '${copy.t('aiContext')}: $contextTitle - $contextDetail',
          help: copy.t('helpAiContext'),
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 10),
        _AIContextPicker(
          copy: copy,
          contextKind: contextKind,
          scenes: scenes,
          selectedScene: selectedScene,
          isEnabled: !isRequesting,
          onContextChanged: onContextChanged,
          onSceneChanged: onSceneChanged,
        ),
        const SizedBox(height: 12),
        _AIAdditionalContextSelector(
          copy: copy,
          catalogItems: catalogItems,
          relationships: relationships,
          scenes: scenes,
          selectedCatalogItemIds: selectedCatalogItemIds,
          selectedRelationshipIds: selectedRelationshipIds,
          isEnabled: !isRequesting,
          onToggleCatalogItem: onToggleCatalogItem,
          onToggleRelationship: onToggleRelationship,
          onClear: onClearAdditionalContext,
        ),
      ],
    );
  }
}

final class _AIInstructionTab extends StatelessWidget {
  const _AIInstructionTab({
    required this.copy,
    required this.primaryActions,
    required this.secondaryActions,
    required this.canRequest,
    required this.isRequesting,
    required this.promptController,
    required this.onUseTemplate,
    required this.onSubmit,
  });

  final WritellerCopy copy;
  final List<_AiWorkshopAction> primaryActions;
  final List<_AiWorkshopAction> secondaryActions;
  final bool canRequest;
  final bool isRequesting;
  final TextEditingController promptController;
  final ValueChanged<AITaskKind> onUseTemplate;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _AIWorkflowSectionHeader(
          step: '2',
          title: copy.t('aiStepInstructionTitle'),
          body: copy.t('aiStepInstructionBody'),
        ),
        const SizedBox(height: 12),
        _HelpedLabel(
          label: copy.t('promptTemplates'),
          help: copy.t('helpPromptTemplates'),
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final action in primaryActions)
              ActionChip(
                tooltip: _aiTaskHelp(action.task, copy),
                avatar: Icon(action.icon, size: 18),
                label: Text(_aiTaskLabel(action.task.name, copy)),
                onPressed:
                    !isRequesting ? () => onUseTemplate(action.task) : null,
              ),
            PopupMenuButton<AITaskKind>(
              enabled: !isRequesting,
              tooltip: copy.t('moreAiChecks'),
              onSelected: onUseTemplate,
              itemBuilder: (context) => [
                for (final action in secondaryActions)
                  PopupMenuItem(
                    value: action.task,
                    child: ListTile(
                      dense: true,
                      leading: Icon(action.icon),
                      title: Text(_aiTaskLabel(action.task.name, copy)),
                      subtitle: Text(
                        _aiTaskHelp(action.task, copy),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
              ],
              child: _AiMenuAnchor(copy: copy),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Shortcuts(
          shortcuts: const {
            SingleActivator(LogicalKeyboardKey.enter, control: true):
                _SubmitAiPromptIntent(),
            SingleActivator(LogicalKeyboardKey.enter, meta: true):
                _SubmitAiPromptIntent(),
          },
          child: Actions(
            actions: {
              _SubmitAiPromptIntent: CallbackAction<_SubmitAiPromptIntent>(
                onInvoke: (intent) {
                  if (canRequest && !isRequesting) onSubmit();
                  return null;
                },
              ),
            },
            child: TextField(
              controller: promptController,
              minLines: 2,
              maxLines: 4,
              textInputAction: TextInputAction.newline,
              decoration: InputDecoration(
                labelText: copy.t('aiPrompt'),
                helperText: copy.t('aiPromptSubmitHint'),
                suffixIcon: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _HelpTooltip(message: copy.t('helpSubmitAiPrompt')),
                ),
                suffixIconConstraints: const BoxConstraints(minWidth: 42),
                border: const OutlineInputBorder(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

final class _AIPromptSendTab extends StatelessWidget {
  const _AIPromptSendTab({
    required this.copy,
    required this.project,
    required this.contextKind,
    required this.scene,
    required this.chapters,
    required this.scenes,
    required this.selectedCatalogItems,
    required this.selectedRelationships,
    required this.promptController,
    required this.task,
    required this.canRequest,
    required this.isRequesting,
    required this.lastError,
    required this.activeProviderConfig,
    required this.onSubmit,
  });

  final WritellerCopy copy;
  final Project? project;
  final _AIWorkshopContextKind contextKind;
  final Scene? scene;
  final List<Chapter> chapters;
  final List<Scene> scenes;
  final List<CatalogItem> selectedCatalogItems;
  final List<Relationship> selectedRelationships;
  final TextEditingController promptController;
  final AITaskKind task;
  final bool canRequest;
  final bool isRequesting;
  final String? lastError;
  final AIProviderConfig activeProviderConfig;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _AIWorkflowSectionHeader(
          step: '3',
          title: copy.t('aiStepPromptTitle'),
          body: copy.t('aiStepPromptBody'),
        ),
        const SizedBox(height: 4),
        _LivePromptPreview(
          copy: copy,
          project: project,
          contextKind: contextKind,
          scene: scene,
          chapters: chapters,
          scenes: scenes,
          catalogItems: selectedCatalogItems,
          relationships: selectedRelationships,
          promptController: promptController,
          task: task,
        ),
        const SizedBox(height: 12),
        _AIWorkflowSectionHeader(
          step: '4',
          title: copy.t('aiStepSendTitle'),
          body: copy.t('aiStepSendBody'),
        ),
        const SizedBox(height: 10),
        _AIProviderStatusLine(copy: copy, config: activeProviderConfig),
        const SizedBox(height: 12),
        _ActionHelp(
          message: copy.t('helpSubmitAiPrompt'),
          child: FilledButton.icon(
            onPressed: canRequest && !isRequesting ? onSubmit : null,
            icon: const Icon(Icons.send_outlined),
            label: Text(copy.t('submitAiPrompt')),
          ),
        ),
        if (isRequesting || lastError != null) ...[
          const SizedBox(height: 12),
          _AIRequestStatus(
            copy: copy,
            isRequesting: isRequesting,
            message: lastError,
          ),
        ],
      ],
    );
  }
}

final class _AIWorkflowGuide extends StatelessWidget {
  const _AIWorkflowGuide({required this.copy});

  final WritellerCopy copy;

  @override
  Widget build(BuildContext context) {
    final steps = [
      copy.t('aiWorkflowContext'),
      copy.t('aiWorkflowInstruction'),
      copy.t('aiWorkflowPrompt'),
      copy.t('aiWorkflowSend'),
      copy.t('aiWorkflowResult'),
      copy.t('aiWorkflowApply'),
    ];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (var index = 0; index < steps.length; index++) ...[
          _AIWorkflowPill(number: index + 1, label: steps[index]),
          if (index < steps.length - 1)
            Icon(
              Icons.chevron_right,
              size: 18,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
        ],
      ],
    );
  }
}

final class _AIWorkflowPill extends StatelessWidget {
  const _AIWorkflowPill({
    required this.number,
    required this.label,
  });

  final int number;
  final String label;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: color.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: color.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: SizedBox.square(
                dimension: 20,
                child: Center(
                  child: Text(
                    '$number',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: color.onPrimaryContainer,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 7),
            Text(label, style: Theme.of(context).textTheme.labelMedium),
          ],
        ),
      ),
    );
  }
}

final class _AIWorkflowSectionHeader extends StatelessWidget {
  const _AIWorkflowSectionHeader({
    required this.step,
    required this.title,
    required this.body,
  });

  final String step;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: color.primary,
            shape: BoxShape.circle,
          ),
          child: SizedBox.square(
            dimension: 24,
            child: Center(
              child: Text(
                step,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: color.onPrimary,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 2),
              Text(
                body,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: color.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

final class _AIContextPicker extends StatelessWidget {
  const _AIContextPicker({
    required this.copy,
    required this.contextKind,
    required this.scenes,
    required this.selectedScene,
    required this.isEnabled,
    required this.onContextChanged,
    required this.onSceneChanged,
  });

  final WritellerCopy copy;
  final _AIWorkshopContextKind contextKind;
  final List<Scene> scenes;
  final Scene? selectedScene;
  final bool isEnabled;
  final ValueChanged<_AIWorkshopContextKind> onContextChanged;
  final ValueChanged<Scene> onSceneChanged;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final selectedSceneId = scenes.any((scene) => scene.id == selectedScene?.id)
        ? selectedScene?.id
        : scenes.firstOrNull?.id;
    return Wrap(
      spacing: 12,
      runSpacing: 10,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SegmentedButton<_AIWorkshopContextKind>(
          segments: [
            ButtonSegment(
              value: _AIWorkshopContextKind.project,
              label: Text(copy.t('project')),
            ),
            ButtonSegment(
              value: _AIWorkshopContextKind.scene,
              label: Text(copy.t('scene')),
            ),
          ],
          selected: {contextKind},
          onSelectionChanged: isEnabled
              ? (selection) => onContextChanged(selection.first)
              : null,
        ),
        if (contextKind == _AIWorkshopContextKind.scene)
          SizedBox(
            width: 320,
            child: DropdownButtonFormField<String>(
              initialValue: selectedSceneId,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded),
              decoration: InputDecoration(
                labelText: copy.t('selectAiScene'),
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              items: [
                for (final scene in scenes)
                  DropdownMenuItem(
                    value: scene.id,
                    child: Text(
                      scene.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
              onChanged: isEnabled
                  ? (sceneId) {
                      final scene = scenes
                          .where((scene) => scene.id == sceneId)
                          .firstOrNull;
                      if (scene != null) onSceneChanged(scene);
                    }
                  : null,
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Text(
              copy.t('aiProjectScopeHint'),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color.onSurfaceVariant,
                  ),
            ),
          ),
      ],
    );
  }
}

final class _AIAdditionalContextSelector extends StatelessWidget {
  const _AIAdditionalContextSelector({
    required this.copy,
    required this.catalogItems,
    required this.relationships,
    required this.scenes,
    required this.selectedCatalogItemIds,
    required this.selectedRelationshipIds,
    required this.isEnabled,
    required this.onToggleCatalogItem,
    required this.onToggleRelationship,
    required this.onClear,
  });

  final WritellerCopy copy;
  final List<CatalogItem> catalogItems;
  final List<Relationship> relationships;
  final List<Scene> scenes;
  final Set<String> selectedCatalogItemIds;
  final Set<String> selectedRelationshipIds;
  final bool isEnabled;
  final ValueChanged<CatalogItem> onToggleCatalogItem;
  final ValueChanged<Relationship> onToggleRelationship;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final selectableItems = catalogItems
        .where((item) =>
            item.type == EntityType.character ||
            item.type == EntityType.location ||
            item.type == EntityType.object)
        .toList();
    final selectedCount =
        selectedCatalogItemIds.length + selectedRelationshipIds.length;

    return Material(
      color: Colors.transparent,
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        leading: Icon(Icons.tune_outlined, color: color.primary),
        title: _HelpedLabel(
          label: copy.t('additionalAiContext'),
          help: copy.t('helpAdditionalAiContext'),
        ),
        subtitle: Text(
          selectedCount == 0
              ? copy.t('additionalAiContextBody')
              : '${copy.t('selectedAiContextCount')}: $selectedCount',
        ),
        childrenPadding: const EdgeInsets.only(bottom: 8),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (selectedCount > 0)
                  OutlinedButton.icon(
                    onPressed: isEnabled ? onClear : null,
                    icon: const Icon(Icons.backspace_outlined),
                    label: Text(copy.t('clearAiContextSelection')),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          if (selectableItems.isEmpty && relationships.isEmpty)
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                copy.t('noAdditionalAiContext'),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: color.onSurfaceVariant,
                    ),
              ),
            )
          else ...[
            _AIContextChipGroup(
              title: copy.t('aiContextCharacters'),
              items: selectableItems
                  .where((item) => item.type == EntityType.character),
              selectedIds: selectedCatalogItemIds,
              isEnabled: isEnabled,
              labelFor: (item) => item.name,
              onToggle: onToggleCatalogItem,
            ),
            _AIContextChipGroup(
              title: copy.t('aiContextLocations'),
              items: selectableItems
                  .where((item) => item.type == EntityType.location),
              selectedIds: selectedCatalogItemIds,
              isEnabled: isEnabled,
              labelFor: (item) => item.name,
              onToggle: onToggleCatalogItem,
            ),
            _AIContextChipGroup(
              title: copy.t('aiContextObjects'),
              items: selectableItems
                  .where((item) => item.type == EntityType.object),
              selectedIds: selectedCatalogItemIds,
              isEnabled: isEnabled,
              labelFor: (item) => item.name,
              onToggle: onToggleCatalogItem,
            ),
            _AIContextChipGroup(
              title: copy.t('aiContextRelationships'),
              items: relationships,
              selectedIds: selectedRelationshipIds,
              isEnabled: isEnabled,
              labelFor: (relationship) => _aiRelationshipLabel(
                relationship,
                catalogItems: catalogItems,
                scenes: scenes,
                copy: copy,
              ),
              onToggle: onToggleRelationship,
            ),
          ],
        ],
      ),
    );
  }
}

final class _AIContextChipGroup<T extends Object> extends StatelessWidget {
  const _AIContextChipGroup({
    required this.title,
    required this.items,
    required this.selectedIds,
    required this.isEnabled,
    required this.labelFor,
    required this.onToggle,
  });

  final String title;
  final Iterable<T> items;
  final Set<String> selectedIds;
  final bool isEnabled;
  final String Function(T item) labelFor;
  final ValueChanged<T> onToggle;

  @override
  Widget build(BuildContext context) {
    final visibleItems = items.toList();
    if (visibleItems.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final item in visibleItems)
                FilterChip(
                  selected: selectedIds.contains(_contextSelectableId(item)),
                  showCheckmark: true,
                  label: Text(labelFor(item)),
                  onSelected: isEnabled ? (_) => onToggle(item) : null,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

String _contextSelectableId(Object item) {
  return switch (item) {
    CatalogItem() => item.id,
    Relationship() => item.id,
    _ => '',
  };
}

String _aiRelationshipLabel(
  Relationship relationship, {
  required List<CatalogItem> catalogItems,
  required List<Scene> scenes,
  required WritellerCopy copy,
}) {
  final source = _aiEntityLabel(
    relationship.source,
    catalogItems: catalogItems,
    scenes: scenes,
    copy: copy,
  );
  final target = _aiEntityLabel(
    relationship.target,
    catalogItems: catalogItems,
    scenes: scenes,
    copy: copy,
  );
  final label = relationship.label?.trim().isNotEmpty == true
      ? relationship.label!.trim()
      : relationship.relationshipType;
  final arrow =
      relationship.direction == RelationshipDirection.directed ? '->' : '<->';
  return '$source $arrow $target: $label';
}

String _aiEntityLabel(
  EntityRef ref, {
  required List<CatalogItem> catalogItems,
  required List<Scene> scenes,
  required WritellerCopy copy,
}) {
  if (ref.type == EntityType.scene) {
    return scenes.where((scene) => scene.id == ref.id).firstOrNull?.title ??
        copy.t('scene');
  }
  final item = catalogItems.where((item) => item.id == ref.id).firstOrNull;
  return item?.name ?? ref.type.wireName;
}

final class _LivePromptPreview extends StatelessWidget {
  const _LivePromptPreview({
    required this.copy,
    required this.project,
    required this.contextKind,
    required this.scene,
    required this.chapters,
    required this.scenes,
    required this.catalogItems,
    required this.relationships,
    required this.promptController,
    required this.task,
  });

  final WritellerCopy copy;
  final Project? project;
  final _AIWorkshopContextKind contextKind;
  final Scene? scene;
  final List<Chapter> chapters;
  final List<Scene> scenes;
  final List<CatalogItem> catalogItems;
  final List<Relationship> relationships;
  final TextEditingController promptController;
  final AITaskKind task;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        title: _HelpedLabel(
          label: copy.t('promptPreview'),
          help: copy.t('helpPromptPreview'),
        ),
        subtitle: Text(_aiTaskLabel(task.name, copy)),
        childrenPadding: const EdgeInsets.only(bottom: 10),
        children: [
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: promptController,
            builder: (context, value, child) {
              final userPrompt = value.text.trim().isEmpty
                  ? copy.t('defaultAiPrompt')
                  : value.text.trim();
              final prompt = switch (contextKind) {
                _AIWorkshopContextKind.project => project == null
                    ? copy.t('selectProject')
                    : const AIProjectPromptBuilder().build(
                        policy: const AIPolicy(),
                        project: project!,
                        chapters: chapters,
                        scenes: scenes,
                        task: task,
                        userPrompt: userPrompt,
                        languageCode: copy.languageCode,
                        contextCatalogItems: catalogItems,
                        contextRelationships: relationships,
                      ),
                _AIWorkshopContextKind.scene => scene == null
                    ? copy.t('aiNeedsScene')
                    : const AIScenePromptBuilder().build(
                        policy: const AIPolicy(),
                        scene: scene!,
                        task: task,
                        userPrompt: userPrompt,
                        languageCode: copy.languageCode,
                        contextCatalogItems: catalogItems,
                        contextRelationships: relationships,
                      ),
              };
              return DecoratedBox(
                decoration: BoxDecoration(
                  color: color.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: SelectableText(
                      prompt,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontFamily: 'monospace',
                            color: color.onSurfaceVariant,
                          ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

final class _AISuggestionsPanel extends StatefulWidget {
  const _AISuggestionsPanel({
    required this.copy,
    required this.suggestions,
    required this.scenes,
    required this.onAcceptSuggestion,
    required this.onConvertSuggestion,
    required this.onRejectSuggestion,
  });

  final WritellerCopy copy;
  final List<AISuggestion> suggestions;
  final List<Scene> scenes;
  final ValueChanged<AISuggestion> onAcceptSuggestion;
  final ValueChanged<AISuggestion> onConvertSuggestion;
  final ValueChanged<AISuggestion> onRejectSuggestion;

  @override
  State<_AISuggestionsPanel> createState() => _AISuggestionsPanelState();
}

final class _AISuggestionsPanelState extends State<_AISuggestionsPanel> {
  _AISuggestionInboxFilter _filter = _AISuggestionInboxFilter.open;
  String? _selectedSuggestionId;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final sortedSuggestions = [...widget.suggestions]..sort((left, right) {
        final leftPending = left.userDecision == SuggestionDecision.pending;
        final rightPending = right.userDecision == SuggestionDecision.pending;
        if (leftPending != rightPending) return leftPending ? -1 : 1;
        return right.createdAt.compareTo(left.createdAt);
      });
    final filteredSuggestions =
        sortedSuggestions.where((suggestion) => _matchesFilter(suggestion));
    final visibleSuggestions = filteredSuggestions.toList();
    final selectedSuggestion = visibleSuggestions
            .where((suggestion) => suggestion.id == _selectedSuggestionId)
            .firstOrNull ??
        visibleSuggestions.firstOrNull;
    final counts = _AIInboxCounts.from(sortedSuggestions);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.surfaceContainerLow,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.inbox_outlined, color: color.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.copy.t('aiInboxTitle'),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        widget.copy.t('aiInboxBody'),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: color.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
                _HelpTooltip(message: widget.copy.t('helpAiInbox')),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _AIInboxMetric(
                  label: widget.copy.t('aiInboxOpen'),
                  value: counts.open,
                  icon: Icons.mark_email_unread_outlined,
                ),
                _AIInboxMetric(
                  label: widget.copy.t('aiInboxAccepted'),
                  value: counts.accepted,
                  icon: Icons.check_circle_outline,
                ),
                _AIInboxMetric(
                  label: widget.copy.t('aiInboxNoted'),
                  value: counts.noted,
                  icon: Icons.sticky_note_2_outlined,
                ),
                _AIInboxMetric(
                  label: widget.copy.t('aiInboxRejected'),
                  value: counts.rejected,
                  icon: Icons.close,
                ),
                _AIInboxMetric(
                  label: widget.copy.t('aiInboxTotal'),
                  value: counts.total,
                  icon: Icons.all_inbox_outlined,
                ),
              ],
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final filter in _AISuggestionInboxFilter.values) ...[
                    ChoiceChip(
                      label: Text(_filterLabel(filter, widget.copy)),
                      avatar: Icon(_filterIcon(filter), size: 18),
                      selected: _filter == filter,
                      onSelected: (_) => setState(() {
                        _filter = filter;
                        _selectedSuggestionId = null;
                      }),
                    ),
                    const SizedBox(width: 8),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: visibleSuggestions.isEmpty
                  ? _AIInboxEmpty(copy: widget.copy)
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        final list = _AIInboxList(
                          copy: widget.copy,
                          suggestions: visibleSuggestions,
                          scenes: widget.scenes,
                          selectedSuggestion: selectedSuggestion,
                          onSelected: (suggestion) => setState(
                            () => _selectedSuggestionId = suggestion.id,
                          ),
                        );
                        final detail = _AISuggestionDetail(
                          copy: widget.copy,
                          suggestion: selectedSuggestion!,
                          scenes: widget.scenes,
                          onAcceptSuggestion: widget.onAcceptSuggestion,
                          onConvertSuggestion: widget.onConvertSuggestion,
                          onRejectSuggestion: widget.onRejectSuggestion,
                        );
                        if (constraints.maxWidth >= 560) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: constraints.maxWidth * 0.38,
                                child: list,
                              ),
                              const VerticalDivider(width: 24),
                              Expanded(child: detail),
                            ],
                          );
                        }
                        return Column(
                          children: [
                            Expanded(flex: 2, child: list),
                            const SizedBox(height: 12),
                            Expanded(child: detail),
                          ],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  bool _matchesFilter(AISuggestion suggestion) {
    return switch (_filter) {
      _AISuggestionInboxFilter.open =>
        suggestion.userDecision == SuggestionDecision.pending,
      _AISuggestionInboxFilter.accepted =>
        suggestion.userDecision == SuggestionDecision.accepted,
      _AISuggestionInboxFilter.noted =>
        suggestion.userDecision == SuggestionDecision.convertedToNote,
      _AISuggestionInboxFilter.rejected =>
        suggestion.userDecision == SuggestionDecision.rejected,
      _AISuggestionInboxFilter.all => true,
    };
  }
}

final class _AIInboxCounts {
  const _AIInboxCounts({
    required this.open,
    required this.accepted,
    required this.noted,
    required this.rejected,
    required this.total,
  });

  final int open;
  final int accepted;
  final int noted;
  final int rejected;
  final int total;

  factory _AIInboxCounts.from(List<AISuggestion> suggestions) {
    int count(SuggestionDecision decision) => suggestions
        .where((suggestion) => suggestion.userDecision == decision)
        .length;
    return _AIInboxCounts(
      open: count(SuggestionDecision.pending),
      accepted: count(SuggestionDecision.accepted),
      noted: count(SuggestionDecision.convertedToNote),
      rejected: count(SuggestionDecision.rejected),
      total: suggestions.length,
    );
  }
}

final class _AIInboxMetric extends StatelessWidget {
  const _AIInboxMetric({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final int value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.surfaceContainerHighest.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 17, color: color.primary),
            const SizedBox(width: 7),
            Text(
              '$value',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

final class _AIInboxList extends StatelessWidget {
  const _AIInboxList({
    required this.copy,
    required this.suggestions,
    required this.scenes,
    required this.selectedSuggestion,
    required this.onSelected,
  });

  final WritellerCopy copy;
  final List<AISuggestion> suggestions;
  final List<Scene> scenes;
  final AISuggestion? selectedSuggestion;
  final ValueChanged<AISuggestion> onSelected;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: suggestions.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final suggestion = suggestions[index];
        return _AIInboxListItem(
          copy: copy,
          suggestion: suggestion,
          scenes: scenes,
          isSelected: selectedSuggestion?.id == suggestion.id,
          onTap: () => onSelected(suggestion),
        );
      },
    );
  }
}

final class _AIInboxListItem extends StatelessWidget {
  const _AIInboxListItem({
    required this.copy,
    required this.suggestion,
    required this.scenes,
    required this.isSelected,
    required this.onTap,
  });

  final WritellerCopy copy;
  final AISuggestion suggestion;
  final List<Scene> scenes;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final design = Theme.of(context).extension<WritellerDesignTokens>()!;
    final pending = suggestion.userDecision == SuggestionDecision.pending;
    return Material(
      color: isSelected
          ? color.primaryContainer.withValues(alpha: 0.42)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                pending ? Icons.mark_email_unread_outlined : Icons.task_alt,
                size: 20,
                color: pending ? design.pencil : color.onSurfaceVariant,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _aiTaskLabel(suggestion.suggestionType, copy),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _suggestionTargetLabel(suggestion, scenes, copy),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: color.primary,
                          ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${suggestion.modelName} - '
                      '${_formatLocalDateTime(suggestion.createdAt)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: color.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _compactSuggestionSummary(suggestion.responseText),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: color.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _decisionLabel(suggestion.userDecision, copy),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: pending ? design.pencil : color.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final class _AISuggestionDetail extends StatelessWidget {
  const _AISuggestionDetail({
    required this.copy,
    required this.suggestion,
    required this.scenes,
    required this.onAcceptSuggestion,
    required this.onConvertSuggestion,
    required this.onRejectSuggestion,
  });

  final WritellerCopy copy;
  final AISuggestion suggestion;
  final List<Scene> scenes;
  final ValueChanged<AISuggestion> onAcceptSuggestion;
  final ValueChanged<AISuggestion> onConvertSuggestion;
  final ValueChanged<AISuggestion> onRejectSuggestion;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final scene = suggestion.target.type == EntityType.scene
        ? scenes.where((scene) => scene.id == suggestion.target.id).firstOrNull
        : null;
    final patch = scene == null
        ? null
        : const AIScenePlanningPatchBuilder().build(
            suggestion: suggestion,
            scene: scene,
          );
    final body = ListView(
      padding: const EdgeInsets.only(right: 4),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.auto_awesome_outlined, color: color.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _aiTaskLabel(suggestion.suggestionType, copy),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_suggestionTargetLabel(suggestion, scenes, copy)} - '
                    '${suggestion.modelName} - '
                    '${_formatLocalDateTime(suggestion.createdAt)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: color.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            _SuggestionStatusBadge(
              copy: copy,
              decision: suggestion.userDecision,
            ),
          ],
        ),
        const SizedBox(height: 16),
        _AIResultProcessingHint(copy: copy),
        const SizedBox(height: 16),
        Text(
          copy.t('aiResponse'),
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 8),
        _AIResponseDigest(copy: copy, text: suggestion.responseText),
        const SizedBox(height: 10),
        SelectableText(
          suggestion.responseText,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        _ScenePatchPreview(copy: copy, patch: patch),
        const SizedBox(height: 16),
        Text(
          copy.t('sentPrompt'),
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 8),
        DecoratedBox(
          decoration: BoxDecoration(
            color: color.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: SelectableText(
              suggestion.promptText,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontFamily: 'JetBrains Mono',
                    fontFamilyFallback: const ['Consolas', 'monospace'],
                    color: color.onSurfaceVariant,
                  ),
            ),
          ),
        ),
      ],
    );

    final detailBody = suggestion.userDecision == SuggestionDecision.pending
        ? _PencilSuggestionFrame(child: body)
        : body;

    return Column(
      children: [
        Expanded(child: detailBody),
        const Divider(height: 18),
        Align(
          alignment: Alignment.centerRight,
          child: Wrap(
            alignment: WrapAlignment.end,
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _HelpTooltip(message: copy.t('helpSuggestionActions')),
              TextButton.icon(
                onPressed: () => onConvertSuggestion(suggestion),
                icon: const Icon(Icons.sticky_note_2_outlined),
                label: Text(copy.t('convertToNote')),
              ),
              OutlinedButton.icon(
                onPressed: () => onRejectSuggestion(suggestion),
                icon: const Icon(Icons.close),
                label: Text(copy.t('reject')),
              ),
              FilledButton.icon(
                onPressed: () => onAcceptSuggestion(suggestion),
                icon: const Icon(Icons.check),
                label: Text(copy.t('accept')),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

final class _AIResultProcessingHint extends StatelessWidget {
  const _AIResultProcessingHint({required this.copy});

  final WritellerCopy copy;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.secondaryContainer.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.secondary.withValues(alpha: 0.28)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.rule_folder_outlined, color: color.onSecondaryContainer),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                copy.t('aiResultProcessingHint'),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: color.onSecondaryContainer,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final class _SuggestionStatusBadge extends StatelessWidget {
  const _SuggestionStatusBadge({
    required this.copy,
    required this.decision,
  });

  final WritellerCopy copy;
  final SuggestionDecision decision;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: color.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Text(
          _decisionLabel(decision, copy),
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ),
    );
  }
}

final class _AIInboxEmpty extends StatelessWidget {
  const _AIInboxEmpty({required this.copy});

  final WritellerCopy copy;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 42, color: color.onSurfaceVariant),
            const SizedBox(height: 12),
            Text(
              copy.t('aiInboxEmptyTitle'),
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              copy.t('aiInboxEmptyBody'),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: color.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

String _filterLabel(_AISuggestionInboxFilter filter, WritellerCopy copy) {
  return switch (filter) {
    _AISuggestionInboxFilter.open => copy.t('aiInboxOpen'),
    _AISuggestionInboxFilter.accepted => copy.t('aiInboxAccepted'),
    _AISuggestionInboxFilter.noted => copy.t('aiInboxNoted'),
    _AISuggestionInboxFilter.rejected => copy.t('aiInboxRejected'),
    _AISuggestionInboxFilter.all => copy.t('aiInboxAll'),
  };
}

String _aiConsoleTabLabel(_AIConsoleTab tab, WritellerCopy copy) {
  return switch (tab) {
    _AIConsoleTab.overview => copy.t('aiTabOverview'),
    _AIConsoleTab.context => copy.t('aiTabContext'),
    _AIConsoleTab.instruction => copy.t('aiTabInstruction'),
    _AIConsoleTab.prompt => copy.t('aiTabPrompt'),
  };
}

IconData _filterIcon(_AISuggestionInboxFilter filter) {
  return switch (filter) {
    _AISuggestionInboxFilter.open => Icons.mark_email_unread_outlined,
    _AISuggestionInboxFilter.accepted => Icons.check_circle_outline,
    _AISuggestionInboxFilter.noted => Icons.sticky_note_2_outlined,
    _AISuggestionInboxFilter.rejected => Icons.close,
    _AISuggestionInboxFilter.all => Icons.all_inbox_outlined,
  };
}

String _suggestionTargetLabel(
  AISuggestion suggestion,
  List<Scene> scenes,
  WritellerCopy copy,
) {
  if (suggestion.target.type == EntityType.scene) {
    final scene = scenes
        .where((candidate) => candidate.id == suggestion.target.id)
        .firstOrNull;
    return scene?.title ?? copy.t('scene');
  }
  if (suggestion.target.type == EntityType.project) {
    return copy.t('project');
  }
  return suggestion.target.type.wireName;
}

String _compactSuggestionSummary(String text) {
  return text.trim().replaceAll(RegExp(r'\s+'), ' ');
}

final class _AINotesPanel extends StatelessWidget {
  const _AINotesPanel({
    required this.copy,
    required this.notes,
    required this.scenes,
    required this.onDeleteNote,
  });

  final WritellerCopy copy;
  final List<ProjectNote> notes;
  final List<Scene> scenes;
  final ValueChanged<ProjectNote> onDeleteNote;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.surfaceContainerLow,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(copy.t('notes'),
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Expanded(
              child: notes.isEmpty
                  ? Text(
                      copy.t('noNotes'),
                      style: TextStyle(color: color.onSurfaceVariant),
                    )
                  : ListView.separated(
                      itemCount: notes.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final note = notes[index];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.sticky_note_2_outlined),
                          title: Text(
                            note.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (_noteTargetLabel(note, scenes)
                                  case final target?)
                                Text(
                                  target,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(color: color.primary),
                                ),
                              Text(
                                note.body,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                _formatLocalDateTime(note.createdAt),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: color.onSurfaceVariant,
                                    ),
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            tooltip: copy.t('delete'),
                            onPressed: () => onDeleteNote(note),
                            icon: const Icon(Icons.delete_outline),
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

final class _AiWorkshopAction {
  const _AiWorkshopAction({
    required this.task,
    required this.icon,
  });

  final AITaskKind task;
  final IconData icon;
}

final class _AiMenuAnchor extends StatelessWidget {
  const _AiMenuAnchor({required this.copy});

  final WritellerCopy copy;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: color.outline),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.more_horiz, size: 18, color: color.primary),
            const SizedBox(width: 8),
            Text(
              copy.t('moreAiChecks'),
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: color.primary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

final class _AIResponseDigest extends StatelessWidget {
  const _AIResponseDigest({
    required this.copy,
    required this.text,
  });

  final WritellerCopy copy;
  final String text;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final items = _responseDigestItems(text);
    if (items.isEmpty) return const SizedBox.shrink();
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.surfaceContainerHighest.withValues(alpha: 0.72),
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
                Icon(Icons.format_list_numbered,
                    size: 18, color: color.primary),
                const SizedBox(width: 8),
                Text(
                  copy.t('structuredAnswer'),
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ],
            ),
            const SizedBox(height: 8),
            for (final item in items.take(6))
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.check_circle_outline,
                        size: 16, color: color.primary),
                    const SizedBox(width: 8),
                    Expanded(child: Text(item)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

final class _ScenePatchPreview extends StatelessWidget {
  const _ScenePatchPreview({
    required this.copy,
    required this.patch,
  });

  final WritellerCopy copy;
  final ScenePlanningPatch? patch;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final changes = patch?.changes ?? const <ScenePlanningFieldChange>[];
    return DecoratedBox(
      decoration: BoxDecoration(
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
                Icon(Icons.fact_check_outlined, size: 18, color: color.primary),
                const SizedBox(width: 8),
                Text(
                  copy.t('applyPreview'),
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (changes.isEmpty)
              Text(
                copy.t('noApplyPreview'),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: color.onSurfaceVariant,
                    ),
              )
            else
              for (final change in changes) ...[
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _planningFieldLabel(change.fieldKey, copy),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        change.suggestedValue,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
          ],
        ),
      ),
    );
  }
}

String _promptTemplateFor(AITaskKind task, WritellerCopy copy) {
  return switch (task) {
    AITaskKind.sceneIdeas => copy.t('promptTemplateSceneIdeas'),
    AITaskKind.sceneGoalConflictOutcome =>
      copy.t('promptTemplateSceneStructure'),
    AITaskKind.consistencyCheck => copy.t('promptTemplateConsistency'),
    AITaskKind.timelineCheck => copy.t('promptTemplateTimeline'),
    AITaskKind.plotGapReview => copy.t('promptTemplatePlotGaps'),
    AITaskKind.authorQuestions => copy.t('promptTemplateAuthorQuestions'),
    AITaskKind.styleAnalysis => copy.t('promptTemplateStyle'),
    AITaskKind.researchStructuring => copy.t('promptTemplateResearch'),
    AITaskKind.dialogueIntentAnalysis => copy.t('promptTemplateDialogue'),
    AITaskKind.characterProfile => copy.t('promptTemplateCharacter'),
    AITaskKind.storylineVariants => copy.t('promptTemplateStoryline'),
    AITaskKind.blurbVariants => copy.t('promptTemplateBlurb'),
    AITaskKind.worldContextStarter => copy.t('storyContextEmptyPrompt'),
    AITaskKind.customScenePrompt => copy.t('defaultAiPrompt'),
  };
}

String _aiTaskHelp(AITaskKind task, WritellerCopy copy) {
  return _promptTemplateFor(task, copy);
}

List<String> _responseDigestItems(String text) {
  final items = <String>[];
  final lines = text.split(RegExp(r'\r?\n'));
  final pattern = RegExp(r'^\s*(?:[-*\u2022]\s*|\d+[.)]\s+)(.+)$');
  for (final line in lines) {
    final match = pattern.firstMatch(line);
    final value = match?.group(1)?.trim();
    if (value != null && value.isNotEmpty) {
      items.add(value.replaceAll(RegExp(r'\s+'), ' '));
    }
  }
  return items;
}

final class _AIProviderStatusLine extends StatelessWidget {
  const _AIProviderStatusLine({
    required this.copy,
    required this.config,
  });

  final WritellerCopy copy;
  final AIProviderConfig config;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final isMock = config.kind == AIProviderKind.mock;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: isMock ? color.tertiaryContainer : color.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isMock ? Icons.science_outlined : Icons.cloud_done_outlined,
              size: 18,
              color:
                  isMock ? color.onTertiaryContainer : color.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                isMock
                    ? copy.t('aiMockProviderActive')
                    : '${copy.t('activeProvider')}: ${config.displayName} - ${config.modelName}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isMock
                          ? color.onTertiaryContainer
                          : color.onSurfaceVariant,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final class _AIRequestStatus extends StatelessWidget {
  const _AIRequestStatus({
    required this.copy,
    required this.isRequesting,
    required this.message,
  });

  final WritellerCopy copy;
  final bool isRequesting;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final hasError = message != null && message!.isNotEmpty;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: hasError ? color.errorContainer : color.secondaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isRequesting)
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: color.onSecondaryContainer,
                ),
              )
            else
              Icon(
                Icons.error_outline,
                size: 18,
                color: color.onErrorContainer,
              ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                isRequesting
                    ? copy.t('aiRequestInProgress')
                    : message ?? copy.t('aiRequestFailed'),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: hasError
                          ? color.onErrorContainer
                          : color.onSecondaryContainer,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
