part of '../main.dart';

// AI workshop prompt controls, suggestion lists, and AI response review widgets.

final class _SubmitAiPromptIntent extends Intent {
  const _SubmitAiPromptIntent();
}

final class _AIWorkshop extends StatelessWidget {
  const _AIWorkshop({
    required this.copy,
    required this.project,
    required this.selectedScene,
    required this.scenes,
    required this.suggestions,
    required this.notes,
    required this.activeProviderConfig,
    required this.promptController,
    required this.isRequesting,
    required this.lastError,
    required this.onSubmitPrompt,
    required this.onRequestTask,
    required this.onAcceptSuggestion,
    required this.onRejectSuggestion,
    required this.onConvertSuggestion,
    required this.onDeleteNote,
  });

  final WritelerCopy copy;
  final Project? project;
  final Scene? selectedScene;
  final List<Scene> scenes;
  final List<AISuggestion> suggestions;
  final List<ProjectNote> notes;
  final AIProviderConfig activeProviderConfig;
  final TextEditingController promptController;
  final bool isRequesting;
  final String? lastError;
  final VoidCallback onSubmitPrompt;
  final ValueChanged<AITaskKind> onRequestTask;
  final ValueChanged<AISuggestion> onAcceptSuggestion;
  final ValueChanged<AISuggestion> onRejectSuggestion;
  final ValueChanged<AISuggestion> onConvertSuggestion;
  final ValueChanged<ProjectNote> onDeleteNote;

  @override
  Widget build(BuildContext context) {
    final scene = selectedScene ?? scenes.firstOrNull;
    final aiAvailable = project?.aiEnabled == true &&
        project?.noAiNoCloud == false &&
        scene != null;
    const primaryActions = [
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
    const secondaryActions = [
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
    ];

    return Column(
      children: [
        _WorkspaceHeader(title: copy.t('aiWorkshop')),
        const Divider(height: 1),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.psychology_alt_outlined,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                scene == null
                                    ? copy.t('aiNeedsScene')
                                    : '${copy.t('aiContext')}: ${scene.title}',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _AIProviderStatusLine(
                          copy: copy,
                          config: activeProviderConfig,
                        ),
                        const SizedBox(height: 14),
                        Shortcuts(
                          shortcuts: const {
                            SingleActivator(LogicalKeyboardKey.enter,
                                control: true): _SubmitAiPromptIntent(),
                            SingleActivator(LogicalKeyboardKey.enter,
                                meta: true): _SubmitAiPromptIntent(),
                          },
                          child: Actions(
                            actions: {
                              _SubmitAiPromptIntent:
                                  CallbackAction<_SubmitAiPromptIntent>(
                                onInvoke: (intent) {
                                  if (aiAvailable && !isRequesting) {
                                    onSubmitPrompt();
                                  }
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
                            FilledButton.icon(
                              onPressed: aiAvailable && !isRequesting
                                  ? onSubmitPrompt
                                  : null,
                              icon: const Icon(Icons.send_outlined),
                              label: Text(copy.t('submitAiPrompt')),
                            ),
                            for (final action in primaryActions)
                              OutlinedButton.icon(
                                onPressed: aiAvailable && !isRequesting
                                    ? () => onRequestTask(action.task)
                                    : null,
                                icon: Icon(action.icon),
                                label:
                                    Text(_aiTaskLabel(action.task.name, copy)),
                              ),
                            PopupMenuButton<AITaskKind>(
                              enabled: aiAvailable && !isRequesting,
                              tooltip: copy.t('moreAiChecks'),
                              onSelected: onRequestTask,
                              itemBuilder: (context) => [
                                for (final action in secondaryActions)
                                  PopupMenuItem(
                                    value: action.task,
                                    child: ListTile(
                                      dense: true,
                                      leading: Icon(action.icon),
                                      title: Text(
                                        _aiTaskLabel(action.task.name, copy),
                                      ),
                                    ),
                                  ),
                              ],
                              child: _AiMenuAnchor(copy: copy),
                            ),
                          ],
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
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final suggestionsPanel = _AISuggestionsPanel(
                        copy: copy,
                        suggestions: suggestions,
                        scenes: scenes,
                        onAcceptSuggestion: onAcceptSuggestion,
                        onConvertSuggestion: onConvertSuggestion,
                        onRejectSuggestion: onRejectSuggestion,
                      );
                      final notesPanel = _AINotesPanel(
                        copy: copy,
                        notes: notes,
                        scenes: scenes,
                        onDeleteNote: onDeleteNote,
                      );
                      if (constraints.maxWidth >= 920) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 3, child: suggestionsPanel),
                            const SizedBox(width: 24),
                            SizedBox(width: 360, child: notesPanel),
                          ],
                        );
                      }
                      return Column(
                        children: [
                          Expanded(child: suggestionsPanel),
                          const SizedBox(height: 16),
                          SizedBox(height: 220, child: notesPanel),
                        ],
                      );
                    },
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

final class _AISuggestionsPanel extends StatelessWidget {
  const _AISuggestionsPanel({
    required this.copy,
    required this.suggestions,
    required this.scenes,
    required this.onAcceptSuggestion,
    required this.onConvertSuggestion,
    required this.onRejectSuggestion,
  });

  final WritelerCopy copy;
  final List<AISuggestion> suggestions;
  final List<Scene> scenes;
  final ValueChanged<AISuggestion> onAcceptSuggestion;
  final ValueChanged<AISuggestion> onConvertSuggestion;
  final ValueChanged<AISuggestion> onRejectSuggestion;

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
            Text(copy.t('suggestions'),
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Expanded(
              child: suggestions.isEmpty
                  ? Text(copy.t('noSuggestions'),
                      style: TextStyle(color: color.onSurfaceVariant))
                  : ListView.separated(
                      itemCount: suggestions.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final suggestion = suggestions[index];
                        return _AISuggestionTile(
                          copy: copy,
                          suggestion: suggestion,
                          scenes: scenes,
                          onAcceptSuggestion: onAcceptSuggestion,
                          onConvertSuggestion: onConvertSuggestion,
                          onRejectSuggestion: onRejectSuggestion,
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

final class _AINotesPanel extends StatelessWidget {
  const _AINotesPanel({
    required this.copy,
    required this.notes,
    required this.scenes,
    required this.onDeleteNote,
  });

  final WritelerCopy copy;
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

  final WritelerCopy copy;

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

final class _AISuggestionTile extends StatelessWidget {
  const _AISuggestionTile({
    required this.copy,
    required this.suggestion,
    required this.scenes,
    required this.onAcceptSuggestion,
    required this.onConvertSuggestion,
    required this.onRejectSuggestion,
  });

  final WritelerCopy copy;
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
    return ExpansionTile(
      leading: const Icon(Icons.psychology_alt_outlined),
      title: Text(_aiTaskLabel(suggestion.suggestionType, copy)),
      subtitle: Text(
        '${suggestion.modelName} - ${_decisionLabel(suggestion.userDecision, copy)}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      childrenPadding: const EdgeInsets.fromLTRB(56, 0, 16, 16),
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                copy.t('aiResponse'),
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 6),
              SelectableText(
                suggestion.responseText,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              _ScenePatchPreview(
                copy: copy,
                patch: patch,
              ),
              const SizedBox(height: 16),
              Text(
                copy.t('sentPrompt'),
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 6),
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
                          fontFamily: 'monospace',
                          color: color.onSurfaceVariant,
                        ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Text(
              _formatLocalDateTime(suggestion.createdAt),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color.onSurfaceVariant,
                  ),
            ),
            const Spacer(),
            IconButton(
              tooltip: copy.t('accept'),
              onPressed: () => onAcceptSuggestion(suggestion),
              icon: const Icon(Icons.check),
            ),
            IconButton(
              tooltip: copy.t('convertToNote'),
              onPressed: () => onConvertSuggestion(suggestion),
              icon: const Icon(Icons.sticky_note_2_outlined),
            ),
            IconButton(
              tooltip: copy.t('reject'),
              onPressed: () => onRejectSuggestion(suggestion),
              icon: const Icon(Icons.close),
            ),
          ],
        ),
      ],
    );
  }
}

final class _ScenePatchPreview extends StatelessWidget {
  const _ScenePatchPreview({
    required this.copy,
    required this.patch,
  });

  final WritelerCopy copy;
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

final class _AIProviderStatusLine extends StatelessWidget {
  const _AIProviderStatusLine({
    required this.copy,
    required this.config,
  });

  final WritelerCopy copy;
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

  final WritelerCopy copy;
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
