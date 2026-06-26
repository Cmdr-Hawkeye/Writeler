part of '../main.dart';

// Workspace navigation, brand mark, and top bar chrome.

enum _WorkspaceNavGroup { write, world, review, output }

final class _WorkspaceNavItem {
  const _WorkspaceNavItem({
    required this.index,
    required this.icon,
    required this.selectedIcon,
    required this.labelBuilder,
    required this.group,
  });

  final int index;
  final IconData icon;
  final IconData selectedIcon;
  final String Function(WritelerCopy copy) labelBuilder;
  final _WorkspaceNavGroup group;
}

final class _WorkspaceNavigation extends StatelessWidget {
  const _WorkspaceNavigation({
    required this.copy,
    required this.items,
    required this.selectedIndex,
    required this.collapsed,
    required this.onToggleCollapsed,
    required this.onSelected,
  });

  final WritelerCopy copy;
  final List<_WorkspaceNavItem> items;
  final int selectedIndex;
  final bool collapsed;
  final VoidCallback onToggleCollapsed;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      width: collapsed ? 76 : 244,
      decoration: BoxDecoration(
        color: color.surfaceContainerLowest,
        border: Border(
          right: BorderSide(color: color.outlineVariant),
        ),
      ),
      child: SafeArea(
        right: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                collapsed ? 12 : 18,
                16,
                collapsed ? 12 : 18,
                12,
              ),
              child: _BrandMark(collapsed: collapsed),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: collapsed ? 12 : 14),
              child: Tooltip(
                message: collapsed
                    ? copy.t('expandNavigation')
                    : copy.t('collapseNavigation'),
                child: IconButton.outlined(
                  visualDensity: VisualDensity.compact,
                  onPressed: onToggleCollapsed,
                  icon: Icon(
                    collapsed
                        ? Icons.keyboard_double_arrow_right
                        : Icons.keyboard_double_arrow_left,
                  ),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  collapsed ? 10 : 12,
                  8,
                  collapsed ? 10 : 12,
                  16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final group in _WorkspaceNavGroup.values) ...[
                      if (collapsed)
                        const SizedBox(height: 8)
                      else
                        _NavigationGroupLabel(
                          label: _navGroupLabel(group, copy),
                        ),
                      for (final item
                          in items.where((item) => item.group == group))
                        _WorkspaceNavButton(
                          item: item,
                          label: item.labelBuilder(copy),
                          selected: item.index == selectedIndex,
                          collapsed: collapsed,
                          onTap: () => onSelected(item.index),
                        ),
                      const SizedBox(height: 4),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _navGroupLabel(_WorkspaceNavGroup group, WritelerCopy copy) =>
    switch (group) {
      _WorkspaceNavGroup.write => copy.t('navGroupWriting'),
      _WorkspaceNavGroup.world => copy.t('catalog'),
      _WorkspaceNavGroup.review => copy.t('navGroupAnalysisAi'),
      _WorkspaceNavGroup.output => copy.t('navGroupAdministration'),
    };

final class _NavigationGroupLabel extends StatelessWidget {
  const _NavigationGroupLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 4),
      child: Text(
        label.toUpperCase(),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color.onSurfaceVariant,
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }
}

final class _WorkspaceNavButton extends StatefulWidget {
  const _WorkspaceNavButton({
    required this.item,
    required this.label,
    required this.selected,
    required this.collapsed,
    required this.onTap,
  });

  final _WorkspaceNavItem item;
  final String label;
  final bool selected;
  final bool collapsed;
  final VoidCallback onTap;

  @override
  State<_WorkspaceNavButton> createState() => _WorkspaceNavButtonState();
}

final class _WorkspaceNavButtonState extends State<_WorkspaceNavButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final design = Theme.of(context).extension<WritelerDesignTokens>()!;
    final active = widget.selected || _hovered;
    final foreground =
        widget.selected ? design.ink : color.onSurface.withValues(alpha: 0.86);
    final background = widget.selected
        ? design.inkSoft
        : _hovered
            ? color.surfaceContainer
            : Colors.transparent;

    final button = MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Semantics(
        button: true,
        selected: widget.selected,
        label: widget.label,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: widget.onTap,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 130),
                curve: Curves.easeOutCubic,
                constraints: const BoxConstraints(minHeight: 36),
                padding: EdgeInsets.symmetric(
                  horizontal: widget.collapsed ? 8 : 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: background,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: widget.selected
                        ? design.ink.withValues(alpha: 0.24)
                        : Colors.transparent,
                  ),
                ),
                child: widget.collapsed
                    ? Center(
                        child: Icon(
                          widget.selected
                              ? widget.item.selectedIcon
                              : widget.item.icon,
                          size: 21,
                          color: foreground,
                        ),
                      )
                    : Row(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 130),
                            width: 3,
                            height: active ? 20 : 12,
                            decoration: BoxDecoration(
                              color: widget.selected
                                  ? design.ink
                                  : _hovered
                                      ? color.outline
                                      : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Icon(
                            widget.selected
                                ? widget.item.selectedIcon
                                : widget.item.icon,
                            size: 20,
                            color: foreground,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              widget.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: foreground,
                                    fontWeight: widget.selected
                                        ? FontWeight.w800
                                        : FontWeight.w600,
                                  ),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
    return widget.collapsed
        ? Tooltip(message: widget.label, child: button)
        : button;
  }
}

final class _BrandMark extends StatelessWidget {
  const _BrandMark({required this.collapsed});

  final bool collapsed;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final design = Theme.of(context).extension<WritelerDesignTokens>()!;
    return Tooltip(
      message: 'Writeler',
      child: Semantics(
        label: 'Writeler',
        child: Row(
          mainAxisAlignment:
              collapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: design.inkSoft,
                border: Border.all(color: design.ink.withValues(alpha: 0.36)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Padding(
                padding: EdgeInsets.all(9),
                child: _InkThreadMark(size: 28),
              ),
            ),
            if (!collapsed) ...[
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'writeler',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: color.onSurface,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

final class _StudioTopBar extends StatelessWidget {
  const _StudioTopBar({
    required this.copy,
    required this.workspaceTitle,
    required this.workspaceIcon,
    required this.project,
    required this.languageCode,
    required this.onLanguageChanged,
    required this.showCreateProject,
    required this.onCreateProject,
    required this.onOpenCommandPalette,
  });

  final WritelerCopy copy;
  final String workspaceTitle;
  final IconData workspaceIcon;
  final Project? project;
  final String languageCode;
  final ValueChanged<String> onLanguageChanged;
  final bool showCreateProject;
  final VoidCallback onCreateProject;
  final VoidCallback onOpenCommandPalette;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final projectTitle = project?.title ?? copy.t('selectProject');

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 520;
        return Container(
          height: 72,
          padding: EdgeInsets.symmetric(horizontal: compact ? 14 : 24),
          decoration: BoxDecoration(
            color: color.surfaceContainerLowest,
            border: Border(
              bottom: BorderSide(color: color.outlineVariant),
            ),
          ),
          child: Row(
            children: [
              if (!compact) ...[
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: color.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: color.primary.withValues(alpha: 0.24),
                    ),
                  ),
                  child: Icon(workspaceIcon, color: color.primary, size: 22),
                ),
                const SizedBox(width: 14),
              ],
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      workspaceTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: compact
                          ? Theme.of(context).textTheme.titleMedium
                          : Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      projectTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: color.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                tooltip: copy.t('language'),
                onSelected: onLanguageChanged,
                itemBuilder: (context) => [
                  for (final language in WritelerCopy.supportedLanguages)
                    PopupMenuItem(
                      value: language.code,
                      child: Row(
                        children: [
                          Icon(
                            language.code == languageCode
                                ? Icons.check
                                : Icons.language,
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                          Text(language.nativeName),
                        ],
                      ),
                    ),
                ],
                child: compact
                    ? Tooltip(
                        message: copy.t('language'),
                        child: const SizedBox.square(
                          dimension: 40,
                          child: Icon(Icons.language),
                        ),
                      )
                    : _LanguageMenuAnchor(
                        copy: copy,
                        languageCode: languageCode,
                      ),
              ),
              const SizedBox(width: 8),
              IconButton.outlined(
                tooltip: copy.t('commandPalette'),
                onPressed: onOpenCommandPalette,
                icon: const Icon(Icons.manage_search_outlined),
              ),
              if (showCreateProject) ...[
                const SizedBox(width: 8),
                _ActionHelp(
                  message: copy.t('helpNewProject'),
                  child: compact
                      ? IconButton.filled(
                          tooltip: copy.t('newProject'),
                          onPressed: onCreateProject,
                          icon: const Icon(Icons.add),
                        )
                      : FilledButton.icon(
                          onPressed: onCreateProject,
                          icon: const Icon(Icons.add),
                          label: Text(copy.t('newProject')),
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

final class _LanguageMenuAnchor extends StatelessWidget {
  const _LanguageMenuAnchor({
    required this.copy,
    required this.languageCode,
  });

  final WritelerCopy copy;
  final String languageCode;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final language = WritelerCopy.languageFor(languageCode);
    return Semantics(
      button: true,
      label: copy.t('language'),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color.surfaceContainerLow,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.outlineVariant),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.language, size: 18, color: color.primary),
              const SizedBox(width: 8),
              Text(
                language.code.toUpperCase(),
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: color.onSurface,
                    ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.arrow_drop_down, size: 18, color: color.primary),
            ],
          ),
        ),
      ),
    );
  }
}
