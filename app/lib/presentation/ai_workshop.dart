part of '../main.dart';

// AI workshop prompt controls, suggestion lists, and AI response review widgets.

final class _SubmitAiPromptIntent extends Intent {
  const _SubmitAiPromptIntent();
}

enum _AIWorkshopContextKind { project, scene }

enum _AISuggestionInboxFilter { open, accepted, noted, rejected, all }

typedef _AIWorkshopTaskRequest = void Function(
  AITaskKind task, {
  required _AIWorkshopContextKind contextKind,
  Scene? scene,
});

final class _AIWorkshop extends StatefulWidget {
  const _AIWorkshop({
    required this.copy,
    required this.project,
    required this.selectedScene,
    required this.chapters,
    required this.scenes,
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
                    canRequest: canRequest,
                    activeProviderConfig: widget.activeProviderConfig,
                    promptController: widget.promptController,
                    isRequesting: widget.isRequesting,
                    lastError: widget.lastError,
                    onContextChanged: _changeContext,
                    onSceneChanged: _changeScene,
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
    );
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
    required this.canRequest,
    required this.activeProviderConfig,
    required this.promptController,
    required this.isRequesting,
    required this.lastError,
    required this.onContextChanged,
    required this.onSceneChanged,
    required this.onRequestTask,
  });

  final WritellerCopy copy;
  final Project? project;
  final _AIWorkshopContextKind contextKind;
  final Scene? scene;
  final List<Chapter> chapters;
  final List<Scene> scenes;
  final bool canRequest;
  final AIProviderConfig activeProviderConfig;
  final TextEditingController promptController;
  final bool isRequesting;
  final String? lastError;
  final ValueChanged<_AIWorkshopContextKind> onContextChanged;
  final ValueChanged<Scene> onSceneChanged;
  final ValueChanged<AITaskKind> onRequestTask;

  @override
  State<_AIPromptConsole> createState() => _AIPromptConsoleState();
}

final class _AIPromptConsoleState extends State<_AIPromptConsole> {
  AITaskKind _previewTask = AITaskKind.customScenePrompt;

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

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.surfaceContainerLow,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.psychology_alt_outlined, color: color.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '${widget.copy.t('aiContext')}: $contextTitle - $contextDetail',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const SizedBox(width: 8),
                _HelpTooltip(message: widget.copy.t('helpAiContext')),
              ],
            ),
            const SizedBox(height: 10),
            _AIContextPicker(
              copy: widget.copy,
              contextKind: widget.contextKind,
              scenes: widget.scenes,
              selectedScene: widget.scene,
              isEnabled: !widget.isRequesting,
              onContextChanged: widget.onContextChanged,
              onSceneChanged: widget.onSceneChanged,
            ),
            const SizedBox(height: 12),
            _AIProviderStatusLine(
              copy: widget.copy,
              config: widget.activeProviderConfig,
            ),
            const SizedBox(height: 14),
            _HelpedLabel(
              label: widget.copy.t('promptTemplates'),
              help: widget.copy.t('helpPromptTemplates'),
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final action in [...primaryActions, ...secondaryActions])
                  ActionChip(
                    avatar: Icon(action.icon, size: 18),
                    label: Text(_aiTaskLabel(action.task.name, widget.copy)),
                    onPressed: !widget.isRequesting
                        ? () => _useTemplate(action.task)
                        : null,
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
                      if (widget.canRequest && !widget.isRequesting) {
                        _submitCurrentTask();
                      }
                      return null;
                    },
                  ),
                },
                child: TextField(
                  controller: widget.promptController,
                  minLines: 2,
                  maxLines: 4,
                  textInputAction: TextInputAction.newline,
                  decoration: InputDecoration(
                    labelText: widget.copy.t('aiPrompt'),
                    helperText: widget.copy.t('aiPromptSubmitHint'),
                    suffixIcon: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _HelpTooltip(
                        message: widget.copy.t('helpSubmitAiPrompt'),
                      ),
                    ),
                    suffixIconConstraints: const BoxConstraints(minWidth: 42),
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _ActionHelp(
                  message: widget.copy.t('helpSubmitAiPrompt'),
                  child: FilledButton.icon(
                    onPressed: widget.canRequest && !widget.isRequesting
                        ? _submitCurrentTask
                        : null,
                    icon: const Icon(Icons.send_outlined),
                    label: Text(widget.copy.t('submitAiPrompt')),
                  ),
                ),
                for (final action in primaryActions)
                  OutlinedButton.icon(
                    onPressed: widget.canRequest && !widget.isRequesting
                        ? () => _requestTask(action.task)
                        : null,
                    icon: Icon(action.icon),
                    label: Text(_aiTaskLabel(action.task.name, widget.copy)),
                  ),
                PopupMenuButton<AITaskKind>(
                  enabled: widget.canRequest && !widget.isRequesting,
                  tooltip: widget.copy.t('moreAiChecks'),
                  onSelected: _requestTask,
                  itemBuilder: (context) => [
                    for (final action in secondaryActions)
                      PopupMenuItem(
                        value: action.task,
                        child: ListTile(
                          dense: true,
                          leading: Icon(action.icon),
                          title:
                              Text(_aiTaskLabel(action.task.name, widget.copy)),
                        ),
                      ),
                  ],
                  child: _AiMenuAnchor(copy: widget.copy),
                ),
                _HelpTooltip(message: widget.copy.t('helpAiQuickActions')),
              ],
            ),
            const SizedBox(height: 12),
            _LivePromptPreview(
              copy: widget.copy,
              project: widget.project,
              contextKind: widget.contextKind,
              scene: widget.scene,
              chapters: widget.chapters,
              scenes: widget.scenes,
              promptController: widget.promptController,
              task: _previewTask,
            ),
            if (widget.isRequesting || widget.lastError != null) ...[
              const SizedBox(height: 12),
              _AIRequestStatus(
                copy: widget.copy,
                isRequesting: widget.isRequesting,
                message: widget.lastError,
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _requestTask(AITaskKind task) {
    setState(() => _previewTask = task);
    widget.onRequestTask(task);
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
              icon: const Icon(Icons.folder_special_outlined),
              label: Text(copy.t('project')),
            ),
            ButtonSegment(
              value: _AIWorkshopContextKind.scene,
              icon: const Icon(Icons.auto_awesome_motion_outlined),
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
                prefixIcon: const Icon(Icons.view_agenda_outlined),
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

final class _LivePromptPreview extends StatelessWidget {
  const _LivePromptPreview({
    required this.copy,
    required this.project,
    required this.contextKind,
    required this.scene,
    required this.chapters,
    required this.scenes,
    required this.promptController,
    required this.task,
  });

  final WritellerCopy copy;
  final Project? project;
  final _AIWorkshopContextKind contextKind;
  final Scene? scene;
  final List<Chapter> chapters;
  final List<Scene> scenes;
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
                      ),
                _AIWorkshopContextKind.scene => scene == null
                    ? copy.t('aiNeedsScene')
                    : const AIScenePromptBuilder().build(
                        policy: const AIPolicy(),
                        scene: scene!,
                        task: task,
                        userPrompt: userPrompt,
                        languageCode: copy.languageCode,
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
