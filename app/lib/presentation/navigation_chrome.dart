part of '../main.dart';

// Workspace navigation, brand mark, and top bar chrome.

enum _WorkspaceNavGroup { organize, write, world, review, output }

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
    required this.onSelected,
  });

  final WritelerCopy copy;
  final List<_WorkspaceNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Container(
      width: 244,
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
            const Padding(
              padding: EdgeInsets.fromLTRB(18, 16, 18, 12),
              child: _BrandMark(),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final group in _WorkspaceNavGroup.values) ...[
                      _NavigationGroupLabel(label: _navGroupLabel(group, copy)),
                      for (final item
                          in items.where((item) => item.group == group))
                        _WorkspaceNavButton(
                          item: item,
                          label: item.labelBuilder(copy),
                          selected: item.index == selectedIndex,
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
      _WorkspaceNavGroup.organize => copy.t('project'),
      _WorkspaceNavGroup.write => copy.t('manuscript'),
      _WorkspaceNavGroup.world => copy.t('catalog'),
      _WorkspaceNavGroup.review => copy.t('analysis'),
      _WorkspaceNavGroup.output => copy.t('exports'),
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
    required this.onTap,
  });

  final _WorkspaceNavItem item;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_WorkspaceNavButton> createState() => _WorkspaceNavButtonState();
}

final class _WorkspaceNavButtonState extends State<_WorkspaceNavButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final active = widget.selected || _hovered;
    final foreground = widget.selected
        ? color.primary
        : color.onSurface.withValues(alpha: 0.86);
    final background = widget.selected
        ? color.primary.withValues(alpha: 0.12)
        : _hovered
            ? color.surfaceContainer
            : Colors.transparent;

    return MouseRegion(
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: background,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: widget.selected
                        ? color.primary.withValues(alpha: 0.24)
                        : Colors.transparent,
                  ),
                ),
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 130),
                      width: 3,
                      height: active ? 20 : 12,
                      decoration: BoxDecoration(
                        color: widget.selected
                            ? color.primary
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
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
  }
}

final class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Tooltip(
      message: 'Writeler',
      child: Semantics(
        label: 'Writeler',
        child: Row(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: color.primary.withValues(alpha: 0.12),
                border: Border.all(
                  color: color.primary.withValues(alpha: 0.36),
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SizedBox(
                width: 46,
                height: 46,
                child: CustomPaint(
                  painter: _WritelerMarkPainter(
                    primary: color.primary,
                    secondary: color.secondary,
                    surface: color.surfaceContainerLowest,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Writeler',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: color.onSurface,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final class _WritelerMarkPainter extends CustomPainter {
  const _WritelerMarkPainter({
    required this.primary,
    required this.secondary,
    required this.surface,
  });

  final Color primary;
  final Color secondary;
  final Color surface;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final fill = Paint()
      ..color = primary.withValues(alpha: 0.14)
      ..style = PaintingStyle.fill;
    final accent = Paint()
      ..color = secondary
      ..style = PaintingStyle.fill;

    final page = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.22,
        size.height * 0.22,
        size.width * 0.46,
        size.height * 0.52,
      ),
      const Radius.circular(5),
    );
    canvas.drawRRect(page, fill);
    canvas.drawRRect(page, stroke);

    final path = Path()
      ..moveTo(size.width * 0.24, size.height * 0.66)
      ..lineTo(size.width * 0.35, size.height * 0.43)
      ..lineTo(size.width * 0.46, size.height * 0.66)
      ..lineTo(size.width * 0.58, size.height * 0.39)
      ..lineTo(size.width * 0.72, size.height * 0.66);
    canvas.drawPath(path, stroke);

    canvas.drawCircle(
      Offset(size.width * 0.72, size.height * 0.70),
      3.3,
      accent,
    );
    canvas.drawCircle(
      Offset(size.width * 0.72, size.height * 0.70),
      1.4,
      Paint()..color = surface,
    );
  }

  @override
  bool shouldRepaint(covariant _WritelerMarkPainter oldDelegate) {
    return primary != oldDelegate.primary ||
        secondary != oldDelegate.secondary ||
        surface != oldDelegate.surface;
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
  });

  final WritelerCopy copy;
  final String workspaceTitle;
  final IconData workspaceIcon;
  final Project? project;
  final String languageCode;
  final ValueChanged<String> onLanguageChanged;
  final bool showCreateProject;
  final VoidCallback onCreateProject;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final projectTitle = project?.title ?? copy.t('selectProject');

    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: color.surfaceContainerLowest,
        border: Border(
          bottom: BorderSide(color: color.outlineVariant),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color.primary.withValues(alpha: 0.24)),
            ),
            child: Icon(workspaceIcon, color: color.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  workspaceTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge,
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
            child: _LanguageMenuAnchor(
              copy: copy,
              languageCode: languageCode,
            ),
          ),
          const SizedBox(width: 10),
          if (showCreateProject)
            _ActionHelp(
              message: copy.t('helpNewProject'),
              child: FilledButton.icon(
                onPressed: onCreateProject,
                icon: const Icon(Icons.add),
                label: Text(copy.t('newProject')),
              ),
            ),
        ],
      ),
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
