part of '../main.dart';

// Local style and readability cockpit for manuscript review.

final class _StyleCockpit extends StatefulWidget {
  const _StyleCockpit({
    required this.copy,
    required this.chapters,
    required this.scenes,
    required this.selectedScene,
    required this.onOpenScene,
  });

  final WritelerCopy copy;
  final List<Chapter> chapters;
  final List<Scene> scenes;
  final Scene? selectedScene;
  final ValueChanged<Scene> onOpenScene;

  @override
  State<_StyleCockpit> createState() => _StyleCockpitState();
}

final class _StyleCockpitState extends State<_StyleCockpit> {
  String? _selectedAnalysisId;

  @override
  void didUpdateWidget(covariant _StyleCockpit oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedScene?.id != widget.selectedScene?.id &&
        widget.selectedScene != null) {
      _selectedAnalysisId = widget.selectedScene!.id;
    }
  }

  @override
  Widget build(BuildContext context) {
    final result = const StyleAnalyzer().analyzeProject(
      chapters: widget.chapters,
      scenes: widget.scenes,
      languageCode: widget.copy.languageCode,
    );
    final selected = _selectedAnalysis(result);
    final hasText = result.project.wordCount > 0;

    return Column(
      children: [
        _WorkspaceHeader(title: widget.copy.t('styleCockpit')),
        const Divider(height: 1),
        if (!hasText)
          Expanded(
            child: _EmptyPanel(
              icon: Icons.auto_graph_outlined,
              title: widget.copy.t('styleCockpitEmptyTitle'),
              body: widget.copy.t('styleCockpitEmptyBody'),
            ),
          )
        else
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 980;
                final overview = _StyleOverview(
                  copy: widget.copy,
                  analysis: result.project,
                );
                final navigator = _StyleNavigator(
                  copy: widget.copy,
                  result: result,
                  selectedId: selected.id,
                  onSelected: (analysis) =>
                      setState(() => _selectedAnalysisId = analysis.id),
                );
                final detail = _StyleDetailPane(
                  copy: widget.copy,
                  analysis: selected,
                  onOpenScene: selected.scope == StyleScope.scene
                      ? () {
                          final scene = _sceneForAnalysis(selected);
                          if (scene != null) widget.onOpenScene(scene);
                        }
                      : null,
                );

                if (compact) {
                  return ListView(
                    padding: const EdgeInsets.all(18),
                    children: [
                      overview,
                      const SizedBox(height: 18),
                      SizedBox(height: 360, child: navigator),
                      const SizedBox(height: 18),
                      detail,
                    ],
                  );
                }

                return Row(
                  children: [
                    SizedBox(
                      width: 340,
                      child: Column(
                        children: [
                          SizedBox(height: 230, child: overview),
                          const Divider(height: 1),
                          Expanded(child: navigator),
                        ],
                      ),
                    ),
                    const VerticalDivider(width: 1),
                    Expanded(child: detail),
                  ],
                );
              },
            ),
          ),
      ],
    );
  }

  StyleScopeAnalysis _selectedAnalysis(StyleAnalysisResult result) {
    if (_selectedAnalysisId == null && widget.selectedScene != null) {
      _selectedAnalysisId = widget.selectedScene!.id;
    }
    final all = [result.project, ...result.chapters, ...result.scenes];
    return all.firstWhere(
      (analysis) => analysis.id == _selectedAnalysisId,
      orElse: () => result.project,
    );
  }

  Scene? _sceneForAnalysis(StyleScopeAnalysis analysis) {
    if (analysis.scope != StyleScope.scene) return null;
    return widget.scenes.where((scene) => scene.id == analysis.id).firstOrNull;
  }
}

final class _StyleOverview extends StatelessWidget {
  const _StyleOverview({
    required this.copy,
    required this.analysis,
  });

  final WritelerCopy copy;
  final StyleScopeAnalysis analysis;

  @override
  Widget build(BuildContext context) {
    return _AnalysisPanel(
      title: copy.t('styleOverview'),
      child: Column(
        children: [
          Expanded(
            child: GridView.count(
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 2.7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              children: [
                _StyleMetricTile(
                  icon: Icons.menu_book_outlined,
                  label: copy.t('readability'),
                  value: '${analysis.readabilityScore.round()}',
                  detail: _readabilityLabel(copy, analysis.readabilityScore),
                ),
                _StyleMetricTile(
                  icon: Icons.format_line_spacing_outlined,
                  label: copy.t('averageSentenceLength'),
                  value: analysis.averageSentenceLength.toStringAsFixed(1),
                  detail: copy.t('wordsPerSentence'),
                ),
                _StyleMetricTile(
                  icon: Icons.record_voice_over_outlined,
                  label: copy.t('dialogueQuote'),
                  value: _formatPercent(analysis.dialogueShare),
                  detail: copy.t('dialogueQuoteBody'),
                ),
                _StyleMetricTile(
                  icon: Icons.report_gmailerrorred_outlined,
                  label: copy.t('styleSignals'),
                  value: '${analysis.issueCount}',
                  detail: copy.t('styleSignalsBody'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

final class _StyleNavigator extends StatelessWidget {
  const _StyleNavigator({
    required this.copy,
    required this.result,
    required this.selectedId,
    required this.onSelected,
  });

  final WritelerCopy copy;
  final StyleAnalysisResult result;
  final String selectedId;
  final ValueChanged<StyleScopeAnalysis> onSelected;

  @override
  Widget build(BuildContext context) {
    return _AnalysisPanel(
      title: copy.t('styleMap'),
      child: ListView(
        children: [
          _StyleScopeTile(
            copy: copy,
            analysis: result.project,
            selected: result.project.id == selectedId,
            onTap: () => onSelected(result.project),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 14, 8, 6),
            child: Text(
              copy.t('chapters'),
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
          for (final chapter in result.chapters)
            _StyleScopeTile(
              copy: copy,
              analysis: chapter,
              selected: chapter.id == selectedId,
              onTap: () => onSelected(chapter),
            ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 14, 8, 6),
            child: Text(
              copy.t('scenes'),
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
          for (final scene in result.scenes)
            _StyleScopeTile(
              copy: copy,
              analysis: scene,
              selected: scene.id == selectedId,
              onTap: () => onSelected(scene),
            ),
        ],
      ),
    );
  }
}

final class _StyleScopeTile extends StatelessWidget {
  const _StyleScopeTile({
    required this.copy,
    required this.analysis,
    required this.selected,
    required this.onTap,
  });

  final WritelerCopy copy;
  final StyleScopeAnalysis analysis;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final design = Theme.of(context).extension<WritelerDesignTokens>()!;
    final scoreColor = _scoreColor(context, analysis.readabilityScore);
    return ListTile(
      selected: selected,
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      leading: Icon(
        _scopeIcon(analysis.scope),
        color: selected ? design.ink : color.onSurfaceVariant,
      ),
      title: Text(
        analysis.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${analysis.wordCount} ${copy.t('words')} · '
        '${analysis.issueCount} ${copy.t('styleSignalsShort')}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Semantics(
        label: copy.t('readability'),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: scoreColor.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            child: Text(
              '${analysis.readabilityScore.round()}',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: scoreColor,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
        ),
      ),
      onTap: onTap,
    );
  }
}

final class _StyleDetailPane extends StatelessWidget {
  const _StyleDetailPane({
    required this.copy,
    required this.analysis,
    required this.onOpenScene,
  });

  final WritelerCopy copy;
  final StyleScopeAnalysis analysis;
  final VoidCallback? onOpenScene;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_scopeIcon(analysis.scope), color: color.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  analysis.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
              if (onOpenScene != null)
                TextButton.icon(
                  onPressed: onOpenScene,
                  icon: const Icon(Icons.open_in_new),
                  label: Text(copy.t('openScene')),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            copy.t('styleCockpitBody'),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: color.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 18),
          _StyleMetricStrip(copy: copy, analysis: analysis),
          const SizedBox(height: 20),
          Expanded(
            child: analysis.issues.isEmpty
                ? _EmptyInlineMessage(message: copy.t('noStyleIssues'))
                : ListView.separated(
                    itemCount: analysis.issues.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) => _StyleIssueCard(
                      copy: copy,
                      issue: analysis.issues[index],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

final class _StyleMetricStrip extends StatelessWidget {
  const _StyleMetricStrip({
    required this.copy,
    required this.analysis,
  });

  final WritelerCopy copy;
  final StyleScopeAnalysis analysis;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _StylePill(
          icon: Icons.subject_outlined,
          label: copy.t('sentences'),
          value: '${analysis.sentenceCount}',
        ),
        _StylePill(
          icon: Icons.format_size_outlined,
          label: copy.t('longSentences'),
          value: '${analysis.longSentenceCount}',
        ),
        _StylePill(
          icon: Icons.filter_alt_outlined,
          label: copy.t('fillerWords'),
          value: '${analysis.fillerWordCount}',
        ),
        _StylePill(
          icon: Icons.repeat_outlined,
          label: copy.t('repetitions'),
          value: '${analysis.repetitionCount}',
        ),
        _StylePill(
          icon: Icons.texture_outlined,
          label: copy.t('adjectiveClusters'),
          value: '${analysis.adjectiveClusterCount}',
        ),
        _StylePill(
          icon: Icons.low_priority_outlined,
          label: copy.t('passiveVoice'),
          value: '${analysis.passiveVoiceCount}',
        ),
        _StylePill(
          icon: Icons.tune_outlined,
          label: copy.t('modalVerbs'),
          value: '${analysis.modalVerbCount}',
        ),
      ],
    );
  }
}

final class _StyleMetricTile extends StatelessWidget {
  const _StyleMetricTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.detail,
  });

  final IconData icon;
  final String label;
  final String value;
  final String detail;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: color.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(9),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  Text(
                    detail,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: color.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

final class _StylePill extends StatelessWidget {
  const _StylePill({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16),
            const SizedBox(width: 7),
            Text(label),
            const SizedBox(width: 8),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}

final class _StyleIssueCard extends StatelessWidget {
  const _StyleIssueCard({
    required this.copy,
    required this.issue,
  });

  final WritelerCopy copy;
  final StyleIssue issue;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final tone = _severityColor(context, issue.severity);
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: tone.withValues(alpha: 0.34)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_issueIcon(issue.kind), color: tone),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    issue.label,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
                Text(
                  '${issue.count}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: tone,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              issue.detail,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: color.onSurfaceVariant,
                  ),
            ),
            if (issue.examples.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final example in issue.examples)
                    Chip(
                      visualDensity: VisualDensity.compact,
                      label: Text(example),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

IconData _scopeIcon(StyleScope scope) => switch (scope) {
      StyleScope.project => Icons.library_books_outlined,
      StyleScope.chapter => Icons.bookmark_border_outlined,
      StyleScope.scene => Icons.notes_outlined,
    };

IconData _issueIcon(StyleIssueKind kind) => switch (kind) {
      StyleIssueKind.fillerWord => Icons.filter_alt_outlined,
      StyleIssueKind.repetition => Icons.repeat_outlined,
      StyleIssueKind.longSentence => Icons.format_size_outlined,
      StyleIssueKind.adjectiveCluster => Icons.texture_outlined,
      StyleIssueKind.passiveVoice => Icons.low_priority_outlined,
      StyleIssueKind.modalVerb => Icons.tune_outlined,
    };

Color _severityColor(BuildContext context, StyleSeverity severity) {
  final color = Theme.of(context).colorScheme;
  final design = Theme.of(context).extension<WritelerDesignTokens>()!;
  return switch (severity) {
    StyleSeverity.info => color.primary,
    StyleSeverity.notice => design.statusProgress,
    StyleSeverity.warning => color.error,
  };
}

Color _scoreColor(BuildContext context, double score) {
  final design = Theme.of(context).extension<WritelerDesignTokens>()!;
  final color = Theme.of(context).colorScheme;
  if (score >= 65) return design.statusDone;
  if (score >= 42) return design.statusProgress;
  return color.error;
}

String _formatPercent(double value) => '${(value * 100).round()}%';

String _readabilityLabel(WritelerCopy copy, double score) {
  if (score >= 70) return copy.t('readabilityEasy');
  if (score >= 50) return copy.t('readabilityBalanced');
  if (score > 0) return copy.t('readabilityDense');
  return copy.t('readabilityEmpty');
}
