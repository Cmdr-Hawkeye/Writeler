part of '../main.dart';

// Shared workspace primitives used by several feature workspaces.

final class _WorkspaceHeader extends StatelessWidget {
  const _WorkspaceHeader({
    required this.title,
    this.actionLabel,
    this.actionIcon,
    this.actionHelp,
    this.onAction,
  });

  final String title;
  final String? actionLabel;
  final IconData? actionIcon;
  final String? actionHelp;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    if (actionLabel == null || actionIcon == null) {
      return const SizedBox.shrink();
    }
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: color.surface,
        border: Border(
          bottom: BorderSide(color: color.outlineVariant),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          children: [
            Expanded(child: Semantics(label: title, header: true)),
            if (actionHelp != null) ...[
              _HelpTooltip(message: actionHelp!),
              const SizedBox(width: 8),
            ],
            FilledButton.icon(
              onPressed: onAction,
              icon: Icon(actionIcon),
              label: Text(actionLabel!),
            ),
          ],
        ),
      ),
    );
  }
}

final class _HelpTooltip extends StatelessWidget {
  const _HelpTooltip({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Tooltip(
      message: message,
      preferBelow: false,
      showDuration: const Duration(seconds: 8),
      child: Semantics(
        button: true,
        label: message,
        child: Icon(
          Icons.help_outline,
          size: 18,
          color: color.onSurfaceVariant,
        ),
      ),
    );
  }
}

final class _HelpedLabel extends StatelessWidget {
  const _HelpedLabel({
    required this.label,
    required this.help,
    this.style,
  });

  final String label;
  final String help;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(child: Text(label, style: style)),
        const SizedBox(width: 6),
        _HelpTooltip(message: help),
      ],
    );
  }
}

final class _ActionHelp extends StatelessWidget {
  const _ActionHelp({
    required this.child,
    required this.message,
  });

  final Widget child;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        child,
        _HelpTooltip(message: message),
      ],
    );
  }
}

final class _InkThreadMark extends StatelessWidget {
  const _InkThreadMark({this.size = 28});

  final double size;

  @override
  Widget build(BuildContext context) {
    final design = Theme.of(context).extension<WritelerDesignTokens>()!;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _InkThreadPainter(
          stroke: design.ink,
          dot: design.ink,
        ),
      ),
    );
  }
}

final class _InkThreadPainter extends CustomPainter {
  const _InkThreadPainter({
    required this.stroke,
    required this.dot,
  });

  final Color stroke;
  final Color dot;

  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / 28;
    final scaleY = size.height / 28;
    final path = Path()
      ..moveTo(3 * scaleX, 19 * scaleY)
      ..cubicTo(
        8 * scaleX,
        9 * scaleY,
        14 * scaleX,
        9 * scaleY,
        14 * scaleX,
        14 * scaleY,
      )
      ..cubicTo(
        14 * scaleX,
        19 * scaleY,
        20 * scaleX,
        19 * scaleY,
        25 * scaleX,
        9 * scaleY,
      );
    final paint = Paint()
      ..color = stroke
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, paint);
    canvas.drawCircle(
        Offset(25 * scaleX, 9 * scaleY), 2.1, Paint()..color = dot);
  }

  @override
  bool shouldRepaint(covariant _InkThreadPainter oldDelegate) =>
      stroke != oldDelegate.stroke || dot != oldDelegate.dot;
}

final class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.status,
    required this.label,
    this.compact = false,
  });

  final DraftStatus status;
  final String label;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final tone = _statusTone(context, status);
    final icon = _statusIcon(status);
    return Semantics(
      label: label,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: tone.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: tone.withValues(alpha: 0.28)),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 7 : 9,
            vertical: compact ? 3 : 5,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: compact ? 13 : 15, color: tone),
              const SizedBox(width: 5),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: tone,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Color _statusTone(BuildContext context, DraftStatus status) {
  final design = Theme.of(context).extension<WritelerDesignTokens>()!;
  return switch (status) {
    DraftStatus.idea || DraftStatus.planned => design.statusPlanned,
    DraftStatus.outlined ||
    DraftStatus.drafting ||
    DraftStatus.needsRevision =>
      design.statusProgress,
    DraftStatus.revised || DraftStatus.reviewed => design.statusDone,
    DraftStatus.locked => design.statusLocked,
    DraftStatus.archived => design.statusArchived,
  };
}

IconData _statusIcon(DraftStatus status) {
  return switch (status) {
    DraftStatus.idea || DraftStatus.planned => Icons.radio_button_unchecked,
    DraftStatus.outlined ||
    DraftStatus.drafting ||
    DraftStatus.needsRevision =>
      Icons.contrast,
    DraftStatus.revised || DraftStatus.reviewed => Icons.check_circle_outline,
    DraftStatus.locked => Icons.lock_outline,
    DraftStatus.archived => Icons.archive_outlined,
  };
}

final class _PencilSuggestionFrame extends StatelessWidget {
  const _PencilSuggestionFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final design = Theme.of(context).extension<WritelerDesignTokens>()!;
    return DecoratedBox(
      decoration: ShapeDecoration(
        color: design.pencilBackground,
        shape: _DashedBorderShape(
          color: design.pencilBorder,
          radius: 8,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: child,
      ),
    );
  }
}

final class _DashedBorderShape extends ShapeBorder {
  const _DashedBorderShape({
    required this.color,
    required this.radius,
  });

  final Color color;
  final double radius;

  @override
  EdgeInsetsGeometry get dimensions => const EdgeInsets.all(1.5);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      Path()..addRRect(_rrect(rect.deflate(1)));

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) =>
      Path()..addRRect(_rrect(rect));

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final path = Path()..addRRect(_rrect(rect.deflate(0.75)));
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(distance, distance + 7),
          paint,
        );
        distance += 11;
      }
    }
  }

  @override
  ShapeBorder scale(double t) => _DashedBorderShape(
        color: color,
        radius: radius * t,
      );

  RRect _rrect(Rect rect) =>
      RRect.fromRectAndRadius(rect, Radius.circular(radius));
}

final class _EmptyPanel extends StatelessWidget {
  const _EmptyPanel({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color.primary, size: 34),
              const SizedBox(height: 16),
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(body, style: TextStyle(color: color.onSurfaceVariant)),
            ],
          ),
        ),
      ),
    );
  }
}

final class _ProjectLibrary extends StatelessWidget {
  const _ProjectLibrary({
    required this.copy,
    required this.projects,
    required this.selectedProject,
    required this.onSelect,
    required this.onDelete,
  });

  final WritelerCopy copy;
  final List<Project> projects;
  final Project? selectedProject;
  final ValueChanged<Project> onSelect;
  final ValueChanged<Project> onDelete;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return Align(
      alignment: Alignment.topLeft,
      child: ListView.separated(
        padding: const EdgeInsets.all(24),
        itemBuilder: (context, index) {
          final project = projects[index];
          final selected = selectedProject?.id == project.id;
          return ListTile(
            selected: selected,
            selectedTileColor: color.primaryContainer.withValues(alpha: 0.38),
            leading: Icon(
              Icons.menu_book_outlined,
              color: selected ? color.primary : color.onSurfaceVariant,
            ),
            title: Text(
              project.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              '${copy.t('localOnly')} - ${project.projectType}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: IconButton(
              tooltip: copy.t('deleteProject'),
              onPressed: () => onDelete(project),
              icon: const Icon(Icons.delete_outline),
            ),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            onTap: () => onSelect(project),
          );
        },
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemCount: projects.length,
      ),
    );
  }
}
