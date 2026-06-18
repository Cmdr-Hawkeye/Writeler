part of '../main.dart';

// Shared workspace primitives used by several feature workspaces.

final class _WorkspaceHeader extends StatelessWidget {
  const _WorkspaceHeader({
    required this.title,
    this.actionLabel,
    this.actionIcon,
    this.onAction,
  });

  final String title;
  final String? actionLabel;
  final IconData? actionIcon;
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
