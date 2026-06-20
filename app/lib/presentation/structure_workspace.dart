part of '../main.dart';

// Structure cockpit, scene board, author-inspection, and structural insight widgets.

final class _SceneBoard extends StatelessWidget {
  const _SceneBoard({
    required this.copy,
    required this.chapters,
    required this.scenes,
    required this.catalogItems,
    required this.relationships,
    required this.selectedScene,
    required this.onSelectScene,
    required this.onMoveSceneUp,
    required this.onMoveSceneDown,
    required this.onMoveSceneToChapter,
    required this.onDeleteScene,
    required this.onDeleteChapter,
    required this.onCreateScene,
    required this.onCreateChapter,
    required this.onCreateRelationship,
    required this.onEditRelationship,
    required this.onDeleteRelationship,
  });

  final WritelerCopy copy;
  final List<Chapter> chapters;
  final List<Scene> scenes;
  final List<CatalogItem> catalogItems;
  final List<Relationship> relationships;
  final Scene? selectedScene;
  final ValueChanged<Scene> onSelectScene;
  final ValueChanged<Scene> onMoveSceneUp;
  final ValueChanged<Scene> onMoveSceneDown;
  final void Function(Scene scene, String? chapterId) onMoveSceneToChapter;
  final ValueChanged<Scene> onDeleteScene;
  final ValueChanged<Chapter> onDeleteChapter;
  final VoidCallback onCreateScene;
  final VoidCallback onCreateChapter;
  final ValueChanged<EntityRef?> onCreateRelationship;
  final ValueChanged<Relationship> onEditRelationship;
  final ValueChanged<Relationship> onDeleteRelationship;

  @override
  Widget build(BuildContext context) {
    final orderedChapters = [...chapters]
      ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
    final datedScenes = scenes
        .where((scene) => scene.storyDateStart != null)
        .toList()
      ..sort((a, b) => a.storyDateStart!.compareTo(b.storyDateStart!));
    final planningGaps = scenes
        .where((scene) =>
            scene.goal?.trim().isEmpty != false ||
            scene.conflict?.trim().isEmpty != false ||
            scene.outcome?.trim().isEmpty != false)
        .toList();
    final openConflictScenes = scenes
        .where((scene) =>
            scene.conflict?.trim().isNotEmpty == true &&
            scene.outcome?.trim().isNotEmpty != true)
        .toList();
    final unscheduledScenes =
        scenes.where((scene) => scene.storyDateStart == null).toList();
    final unassignedScenes =
        scenes.where((scene) => scene.chapterId == null).length;
    final entityRows = [
      for (final item in catalogItems)
        _CatalogPresenceRow(
          item: item,
          scenes: _linkedScenesForCatalogItem(item, relationships, scenes),
        ),
    ]..sort((a, b) {
        final countCompare = b.scenes.length.compareTo(a.scenes.length);
        if (countCompare != 0) return countCompare;
        final typeCompare = a.item.type.index.compareTo(b.item.type.index);
        if (typeCompare != 0) return typeCompare;
        return a.item.name.compareTo(b.item.name);
      });
    final motifRows = _structureMotifRows(scenes, copy);
    final groups = <_SceneStructureGroup>[
      for (final chapter in orderedChapters)
        _SceneStructureGroup(
          id: chapter.id,
          title: chapter.title,
          summary: chapter.summary,
          scenes: _scenesForChapter(chapter.id),
        ),
      _SceneStructureGroup(
        id: null,
        title: copy.t('noChapter'),
        summary: '',
        scenes: _scenesForChapter(null),
      ),
    ].where((group) => group.scenes.isNotEmpty || group.id != null).toList();
    final visibleGroups = groups.isEmpty
        ? [
            _SceneStructureGroup(
              id: null,
              title: copy.t('noChapter'),
              summary: '',
              scenes: const [],
            ),
          ]
        : groups;

    return Column(
      children: [
        _WorkspaceHeader(
          title: copy.t('structureCockpit'),
          actionLabel: copy.t('newScene'),
          actionIcon: Icons.add,
          actionHelp: copy.t('helpNewScene'),
          onAction: onCreateScene,
        ),
        const Divider(height: 1),
        _StructureCockpitSummary(
          copy: copy,
          scenes: scenes,
          chapters: orderedChapters,
          planningGaps: planningGaps.length,
          openConflicts: openConflictScenes.length,
          unassignedScenes: unassignedScenes,
          datedScenes: datedScenes,
          catalogItems: catalogItems.length,
          relationships: relationships.length,
        ),
        const Divider(height: 1),
        if (chapters.isNotEmpty)
          SizedBox(
            height: 52,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _ActionHelp(
                    message: copy.t('helpNewChapter'),
                    child: OutlinedButton.icon(
                      onPressed: onCreateChapter,
                      icon: const Icon(Icons.create_new_folder_outlined),
                      label: Text(copy.t('newChapter')),
                    ),
                  );
                }
                final chapter = orderedChapters[index - 1];
                final sceneCount = scenes
                    .where((scene) => scene.chapterId == chapter.id)
                    .length;
                return Chip(
                  avatar: const Icon(Icons.folder_outlined, size: 18),
                  label: Text('${chapter.title} - $sceneCount'),
                  deleteIcon: const Icon(Icons.delete_outline, size: 18),
                  deleteButtonTooltipMessage: copy.t('helpDeleteChapter'),
                  onDeleted: () => onDeleteChapter(chapter),
                );
              },
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemCount: orderedChapters.length + 1,
            ),
          )
        else
          SizedBox(
            height: 52,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _ActionHelp(
                  message: copy.t('helpNewChapter'),
                  child: OutlinedButton.icon(
                    onPressed: onCreateChapter,
                    icon: const Icon(Icons.create_new_folder_outlined),
                    label: Text(copy.t('newChapter')),
                  ),
                ),
              ),
            ),
          ),
        const Divider(height: 1),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final structureList = ListView.separated(
                padding: const EdgeInsets.all(20),
                scrollDirection: Axis.horizontal,
                itemCount: visibleGroups.length,
                separatorBuilder: (context, index) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  final group = visibleGroups[index];
                  return SizedBox(
                    width: 340,
                    child: _SceneStructureColumn(
                      copy: copy,
                      group: group,
                      chapters: orderedChapters,
                      selectedScene: selectedScene,
                      onSelectScene: onSelectScene,
                      onMoveSceneUp: onMoveSceneUp,
                      onMoveSceneDown: onMoveSceneDown,
                      onMoveSceneToChapter: onMoveSceneToChapter,
                      onDeleteScene: onDeleteScene,
                    ),
                  );
                },
              );
              final inspector = _StructureInspector(
                copy: copy,
                scenes: scenes,
                planningGapScenes: planningGaps,
                openConflictScenes: openConflictScenes,
                unscheduledScenes: unscheduledScenes,
                datedScenes: datedScenes,
                entityRows: entityRows,
                motifRows: motifRows,
                relationships: relationships,
                onOpenScene: onSelectScene,
                onCreateRelationship: onCreateRelationship,
                onEditRelationship: onEditRelationship,
                onDeleteRelationship: onDeleteRelationship,
              );
              if (constraints.maxHeight < 320) {
                return structureList;
              }
              if (constraints.maxWidth < 980) {
                final inspectorHeight =
                    (constraints.maxHeight * 0.42).clamp(120.0, 260.0);
                return Column(
                  children: [
                    Expanded(child: structureList),
                    const Divider(height: 1),
                    SizedBox(height: inspectorHeight, child: inspector),
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(child: structureList),
                  const VerticalDivider(width: 1),
                  SizedBox(width: 380, child: inspector),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  List<Scene> _scenesForChapter(String? chapterId) {
    final filtered =
        scenes.where((scene) => scene.chapterId == chapterId).toList();
    filtered.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
    return filtered;
  }
}

final class _StructureCockpitSummary extends StatelessWidget {
  const _StructureCockpitSummary({
    required this.copy,
    required this.scenes,
    required this.chapters,
    required this.planningGaps,
    required this.openConflicts,
    required this.unassignedScenes,
    required this.datedScenes,
    required this.catalogItems,
    required this.relationships,
  });

  final WritelerCopy copy;
  final List<Scene> scenes;
  final List<Chapter> chapters;
  final int planningGaps;
  final int openConflicts;
  final int unassignedScenes;
  final List<Scene> datedScenes;
  final int catalogItems;
  final int relationships;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final words =
        scenes.fold<int>(0, (sum, scene) => sum + scene.actualWordCount);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          _StructureChip(
            icon: Icons.account_tree_outlined,
            label: copy.t('chapterOverview'),
            value: '${chapters.length}',
          ),
          _StructureChip(
            icon: Icons.auto_awesome_motion_outlined,
            label: copy.t('scenes'),
            value: '${scenes.length}',
          ),
          _StructureChip(
            icon: Icons.notes_outlined,
            label: copy.t('words'),
            value: '$words',
          ),
          _StructureChip(
            icon: Icons.rule_outlined,
            label: copy.t('planningGaps'),
            value: '$planningGaps',
          ),
          _StructureChip(
            icon: Icons.warning_amber_outlined,
            label: copy.t('openConflicts'),
            value: '$openConflicts',
          ),
          _StructureChip(
            icon: Icons.folder_off_outlined,
            label: copy.t('unassignedScenes'),
            value: '$unassignedScenes',
          ),
          _StructureChip(
            icon: Icons.category_outlined,
            label: copy.t('catalog'),
            value: '$catalogItems',
          ),
          _StructureChip(
            icon: Icons.hub_outlined,
            label: copy.t('relationships'),
            value: '$relationships',
          ),
          _StructureChip(
            icon: Icons.timeline_outlined,
            label: copy.t('datedScenes'),
            value: '${datedScenes.length}',
          ),
          if (datedScenes.isNotEmpty)
            DecoratedBox(
              decoration: BoxDecoration(
                color: color.surfaceContainerHighest.withValues(alpha: 0.58),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Text(
                  '${copy.t('timeline')}: ${datedScenes.first.title}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

final class _StructureChip extends StatelessWidget {
  const _StructureChip({
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
        border: Border.all(color: color.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color.primary),
            const SizedBox(width: 8),
            Text(label, style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(width: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

final class _SceneStructureGroup {
  const _SceneStructureGroup({
    required this.id,
    required this.title,
    required this.summary,
    required this.scenes,
  });

  final String? id;
  final String title;
  final String summary;
  final List<Scene> scenes;
}

final class _SceneStructureColumn extends StatelessWidget {
  const _SceneStructureColumn({
    required this.copy,
    required this.group,
    required this.chapters,
    required this.selectedScene,
    required this.onSelectScene,
    required this.onMoveSceneUp,
    required this.onMoveSceneDown,
    required this.onMoveSceneToChapter,
    required this.onDeleteScene,
  });

  final WritelerCopy copy;
  final _SceneStructureGroup group;
  final List<Chapter> chapters;
  final Scene? selectedScene;
  final ValueChanged<Scene> onSelectScene;
  final ValueChanged<Scene> onMoveSceneUp;
  final ValueChanged<Scene> onMoveSceneDown;
  final void Function(Scene scene, String? chapterId) onMoveSceneToChapter;
  final ValueChanged<Scene> onDeleteScene;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: color.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    group.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                Text('${group.scenes.length}'),
              ],
            ),
          ),
          if (group.summary.trim().isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  group.summary,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: color.onSurfaceVariant,
                      ),
                ),
              ),
            ),
            const Divider(height: 1),
          ],
          if (group.summary.trim().isEmpty) const Divider(height: 1),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(8),
              itemCount: group.scenes.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final scene = group.scenes[index];
                final selected = selectedScene?.id == scene.id;
                return _SceneStructureTile(
                  copy: copy,
                  scene: scene,
                  selected: selected,
                  chapters: chapters,
                  onTap: () => onSelectScene(scene),
                  onMoveSceneUp: () => onMoveSceneUp(scene),
                  onMoveSceneDown: () => onMoveSceneDown(scene),
                  onMoveSceneToChapter: (chapterId) =>
                      onMoveSceneToChapter(scene, chapterId),
                  onDeleteScene: () => onDeleteScene(scene),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

final class _StructureInspector extends StatelessWidget {
  const _StructureInspector({
    required this.copy,
    required this.scenes,
    required this.planningGapScenes,
    required this.openConflictScenes,
    required this.unscheduledScenes,
    required this.datedScenes,
    required this.entityRows,
    required this.motifRows,
    required this.relationships,
    required this.onOpenScene,
    required this.onCreateRelationship,
    required this.onEditRelationship,
    required this.onDeleteRelationship,
  });

  final WritelerCopy copy;
  final List<Scene> scenes;
  final List<Scene> planningGapScenes;
  final List<Scene> openConflictScenes;
  final List<Scene> unscheduledScenes;
  final List<Scene> datedScenes;
  final List<_CatalogPresenceRow> entityRows;
  final List<_StructureMotifRow> motifRows;
  final List<Relationship> relationships;
  final ValueChanged<Scene> onOpenScene;
  final ValueChanged<EntityRef?> onCreateRelationship;
  final ValueChanged<Relationship> onEditRelationship;
  final ValueChanged<Relationship> onDeleteRelationship;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            copy.t('authorStructureCockpit'),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            copy.t('authorStructureCockpitBody'),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: ListView(
              children: [
                _StructureSceneSection(
                  copy: copy,
                  title: copy.t('planningGaps'),
                  emptyText: copy.t('noPlanningGaps'),
                  icon: Icons.rule_outlined,
                  scenes: planningGapScenes,
                  subtitleBuilder: (scene) =>
                      _missingScenePlanningLabels(scene, copy).join(', '),
                  onOpenScene: onOpenScene,
                ),
                const SizedBox(height: 18),
                _StructureSceneSection(
                  copy: copy,
                  title: copy.t('openConflicts'),
                  emptyText: copy.t('noOpenConflicts'),
                  icon: Icons.warning_amber_outlined,
                  scenes: openConflictScenes,
                  subtitleBuilder: (scene) => scene.conflict ?? '',
                  onOpenScene: onOpenScene,
                ),
                const SizedBox(height: 18),
                _StructureSceneSection(
                  copy: copy,
                  title: copy.t('unscheduled'),
                  emptyText: copy.t('noUnscheduledScenes'),
                  icon: Icons.event_busy_outlined,
                  scenes: unscheduledScenes,
                  subtitleBuilder: (scene) =>
                      _draftStatusLabel(scene.status, copy.languageCode),
                  onOpenScene: onOpenScene,
                ),
                const SizedBox(height: 18),
                _StructureTimelineSection(
                  copy: copy,
                  scenes: datedScenes,
                  onOpenScene: onOpenScene,
                ),
                const SizedBox(height: 18),
                _StructureEntitySection(
                  copy: copy,
                  scenes: scenes,
                  catalogItems: [
                    for (final row in entityRows) row.item,
                  ],
                  rows: entityRows,
                  relationships: relationships,
                  onOpenScene: onOpenScene,
                  onCreateRelationship: onCreateRelationship,
                  onEditRelationship: onEditRelationship,
                  onDeleteRelationship: onDeleteRelationship,
                ),
                const SizedBox(height: 18),
                _StructureMotifSection(copy: copy, rows: motifRows),
                const SizedBox(height: 18),
                _StructureRelationshipSection(
                  copy: copy,
                  scenes: scenes,
                  catalogItems: [
                    for (final row in entityRows) row.item,
                  ],
                  relationships: relationships,
                  onCreateRelationship: () => onCreateRelationship(null),
                  onEditRelationship: onEditRelationship,
                  onDeleteRelationship: onDeleteRelationship,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

final class _StructureSceneSection extends StatelessWidget {
  const _StructureSceneSection({
    required this.copy,
    required this.title,
    required this.emptyText,
    required this.icon,
    required this.scenes,
    required this.subtitleBuilder,
    required this.onOpenScene,
  });

  final WritelerCopy copy;
  final String title;
  final String emptyText;
  final IconData icon;
  final List<Scene> scenes;
  final String Function(Scene scene) subtitleBuilder;
  final ValueChanged<Scene> onOpenScene;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: color.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '$title (${scenes.length})',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (scenes.isEmpty)
          _EmptyInlineMessage(message: emptyText)
        else
          for (final scene in scenes.take(6))
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.chevron_right),
              title: Text(
                scene.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                subtitleBuilder(scene),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Tooltip(
                message: copy.t('openScene'),
                child: IconButton(
                  onPressed: () => onOpenScene(scene),
                  icon: const Icon(Icons.open_in_new),
                ),
              ),
              onTap: () => onOpenScene(scene),
            ),
      ],
    );
  }
}

final class _StructureTimelineSection extends StatelessWidget {
  const _StructureTimelineSection({
    required this.copy,
    required this.scenes,
    required this.onOpenScene,
  });

  final WritelerCopy copy;
  final List<Scene> scenes;
  final ValueChanged<Scene> onOpenScene;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.timeline_outlined, size: 18, color: color.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${copy.t('timeline')} (${scenes.length})',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (scenes.isEmpty)
          _EmptyInlineMessage(message: copy.t('noTimelineScenes'))
        else
          for (final scene in scenes.take(8))
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event_outlined),
              title: Text(
                scene.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(_formatLocalDate(scene.storyDateStart!)),
              onTap: () => onOpenScene(scene),
            ),
      ],
    );
  }
}

final class _StructureEntitySection extends StatelessWidget {
  const _StructureEntitySection({
    required this.copy,
    required this.scenes,
    required this.catalogItems,
    required this.rows,
    required this.relationships,
    required this.onOpenScene,
    required this.onCreateRelationship,
    required this.onEditRelationship,
    required this.onDeleteRelationship,
  });

  final WritelerCopy copy;
  final List<Scene> scenes;
  final List<CatalogItem> catalogItems;
  final List<_CatalogPresenceRow> rows;
  final List<Relationship> relationships;
  final ValueChanged<Scene> onOpenScene;
  final ValueChanged<EntityRef?> onCreateRelationship;
  final ValueChanged<Relationship> onEditRelationship;
  final ValueChanged<Relationship> onDeleteRelationship;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StructureSectionHeading(
          icon: Icons.hub_outlined,
          title: '${copy.t('entityWeb')} (${rows.length})',
        ),
        const SizedBox(height: 8),
        if (rows.isEmpty)
          _EmptyInlineMessage(message: copy.t('catalogEmptyBody'))
        else
          for (final row in rows.take(8))
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: color.surfaceContainerLowest,
                  border: Border(
                    bottom: BorderSide(color: color.outlineVariant),
                  ),
                ),
                child: _StructureEntityDetailTile(
                  copy: copy,
                  row: row,
                  scenes: scenes,
                  catalogItems: catalogItems,
                  relationships: relationships
                      .where((relationship) => _relationshipTouchesRef(
                            relationship,
                            EntityRef(type: row.item.type, id: row.item.id),
                          ))
                      .toList(growable: false),
                  onOpenScene: onOpenScene,
                  onCreateRelationship: () => onCreateRelationship(
                    EntityRef(type: row.item.type, id: row.item.id),
                  ),
                  onEditRelationship: onEditRelationship,
                  onDeleteRelationship: onDeleteRelationship,
                ),
              ),
            ),
      ],
    );
  }
}

final class _StructureEntityDetailTile extends StatelessWidget {
  const _StructureEntityDetailTile({
    required this.copy,
    required this.row,
    required this.scenes,
    required this.catalogItems,
    required this.relationships,
    required this.onOpenScene,
    required this.onCreateRelationship,
    required this.onEditRelationship,
    required this.onDeleteRelationship,
  });

  final WritelerCopy copy;
  final _CatalogPresenceRow row;
  final List<Scene> scenes;
  final List<CatalogItem> catalogItems;
  final List<Relationship> relationships;
  final ValueChanged<Scene> onOpenScene;
  final VoidCallback onCreateRelationship;
  final ValueChanged<Relationship> onEditRelationship;
  final ValueChanged<Relationship> onDeleteRelationship;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(left: 30, right: 4, bottom: 10),
      leading: Icon(_catalogIcon(row.item.type), color: color.primary),
      title: Text(
        row.item.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.labelLarge,
      ),
      subtitle: Text(
        '${_entityTypeLabel(row.item.type, copy)} - '
        '${_draftStatusLabel(row.item.status, copy.languageCode)} - '
        '${row.scenes.length} ${copy.t('appearances')}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: IconButton(
        tooltip: copy.t('helpNewRelationship'),
        visualDensity: VisualDensity.compact,
        onPressed: onCreateRelationship,
        icon: const Icon(Icons.add_link),
      ),
      children: [
        if (row.item.summary.trim().isNotEmpty) ...[
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              row.item.summary,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color.onSurfaceVariant,
                  ),
            ),
          ),
          const SizedBox(height: 8),
        ],
        if (row.scenes.isEmpty)
          _EmptyInlineMessage(message: copy.t('noAppearances'))
        else
          Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final scene in row.scenes.take(5))
                  ActionChip(
                    avatar: const Icon(Icons.notes_outlined, size: 16),
                    label: Text(scene.title),
                    onPressed: () => onOpenScene(scene),
                  ),
              ],
            ),
          ),
        const SizedBox(height: 10),
        _RelationshipMiniList(
          copy: copy,
          relationships: relationships,
          scenes: scenes,
          catalogItems: catalogItems,
          onEditRelationship: onEditRelationship,
          onDeleteRelationship: onDeleteRelationship,
        ),
      ],
    );
  }
}

final class _StructureMotifSection extends StatelessWidget {
  const _StructureMotifSection({
    required this.copy,
    required this.rows,
  });

  final WritelerCopy copy;
  final List<_StructureMotifRow> rows;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StructureSectionHeading(
          icon: Icons.blur_on_outlined,
          title: copy.t('motifTracker'),
        ),
        const SizedBox(height: 8),
        if (rows.isEmpty)
          _EmptyInlineMessage(message: copy.t('noMotifsYet'))
        else
          for (final row in rows.take(8))
            Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          row.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        const SizedBox(height: 5),
                        LinearProgressIndicator(value: row.share),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${row.count}',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
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

final class _StructureRelationshipSection extends StatelessWidget {
  const _StructureRelationshipSection({
    required this.copy,
    required this.scenes,
    required this.catalogItems,
    required this.relationships,
    required this.onCreateRelationship,
    required this.onEditRelationship,
    required this.onDeleteRelationship,
  });

  final WritelerCopy copy;
  final List<Scene> scenes;
  final List<CatalogItem> catalogItems;
  final List<Relationship> relationships;
  final VoidCallback onCreateRelationship;
  final ValueChanged<Relationship> onEditRelationship;
  final ValueChanged<Relationship> onDeleteRelationship;

  @override
  Widget build(BuildContext context) {
    final rows = relationships.take(8).toList(growable: false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StructureSectionHeading(
          icon: Icons.device_hub_outlined,
          title: '${copy.t('relationshipMap')} (${relationships.length})',
          trailing: IconButton(
            tooltip: copy.t('helpNewRelationship'),
            visualDensity: VisualDensity.compact,
            onPressed: onCreateRelationship,
            icon: const Icon(Icons.add_link),
          ),
        ),
        const SizedBox(height: 8),
        if (rows.isEmpty)
          _EmptyInlineMessage(message: copy.t('noRelationshipsYet'))
        else
          _RelationshipMiniList(
            copy: copy,
            relationships: rows,
            scenes: scenes,
            catalogItems: catalogItems,
            onEditRelationship: onEditRelationship,
            onDeleteRelationship: onDeleteRelationship,
          ),
      ],
    );
  }
}

final class _RelationshipMiniList extends StatelessWidget {
  const _RelationshipMiniList({
    required this.copy,
    required this.relationships,
    required this.onEditRelationship,
    required this.onDeleteRelationship,
    this.scenes = const [],
    this.catalogItems = const [],
  });

  final WritelerCopy copy;
  final List<Relationship> relationships;
  final List<Scene> scenes;
  final List<CatalogItem> catalogItems;
  final ValueChanged<Relationship> onEditRelationship;
  final ValueChanged<Relationship> onDeleteRelationship;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    if (relationships.isEmpty) {
      return _EmptyInlineMessage(message: copy.t('noRelationshipsYet'));
    }
    return Column(
      children: [
        for (final relationship in relationships)
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              relationship.direction == RelationshipDirection.directed
                  ? Icons.arrow_forward
                  : Icons.sync_alt,
            ),
            title: Text(
              _relationshipTitle(relationship, copy),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              _relationshipSubtitle(
                relationship,
                copy,
                scenes: scenes,
                catalogItems: catalogItems,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (relationship.strength case final strength?)
                  Text(
                    '${(strength * 100).round()}%',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: color.onSurfaceVariant,
                        ),
                  ),
                IconButton(
                  tooltip: copy.t('helpEditRelationship'),
                  visualDensity: VisualDensity.compact,
                  onPressed: () => onEditRelationship(relationship),
                  icon: const Icon(Icons.edit_outlined),
                ),
                IconButton(
                  tooltip: copy.t('helpDeleteRelationship'),
                  visualDensity: VisualDensity.compact,
                  onPressed: () => onDeleteRelationship(relationship),
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

final class _StructureSectionHeading extends StatelessWidget {
  const _StructureSectionHeading({
    required this.icon,
    required this.title,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 18, color: color.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

final class _SceneStructureTile extends StatelessWidget {
  const _SceneStructureTile({
    required this.copy,
    required this.scene,
    required this.selected,
    required this.chapters,
    required this.onTap,
    required this.onMoveSceneUp,
    required this.onMoveSceneDown,
    required this.onMoveSceneToChapter,
    required this.onDeleteScene,
  });

  final WritelerCopy copy;
  final Scene scene;
  final bool selected;
  final List<Chapter> chapters;
  final VoidCallback onTap;
  final VoidCallback onMoveSceneUp;
  final VoidCallback onMoveSceneDown;
  final ValueChanged<String?> onMoveSceneToChapter;
  final VoidCallback onDeleteScene;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final missing = _missingScenePlanningLabels(scene, copy);
    final progress = _scenePlanningProgress(scene);
    return Material(
      color: selected ? color.primaryContainer.withValues(alpha: 0.38) : null,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 4, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      scene.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  _SceneStructureMenu(
                    copy: copy,
                    scene: scene,
                    chapters: chapters,
                    onMoveUp: onMoveSceneUp,
                    onMoveDown: onMoveSceneDown,
                    onMoveToChapter: onMoveSceneToChapter,
                    onDelete: onDeleteScene,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    _draftStatusLabel(scene.status, copy.languageCode),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: color.onSurfaceVariant,
                        ),
                  ),
                  Text(
                    '${scene.actualWordCount} ${copy.t('words')}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: color.onSurfaceVariant,
                        ),
                  ),
                  if (scene.storyDateStart != null)
                    Text(
                      _formatLocalDate(scene.storyDateStart!),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: color.onSurfaceVariant,
                          ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(value: progress),
              const SizedBox(height: 8),
              if (missing.isEmpty)
                Text(
                  copy.t('structureComplete'),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: color.primary,
                        fontWeight: FontWeight.w700,
                      ),
                )
              else
                Text(
                  '${copy.t('missing')}: ${missing.join(', ')}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: color.error,
                      ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

final class _SceneStructureMenu extends StatelessWidget {
  const _SceneStructureMenu({
    required this.copy,
    required this.scene,
    required this.chapters,
    required this.onMoveUp,
    required this.onMoveDown,
    required this.onMoveToChapter,
    required this.onDelete,
  });

  final WritelerCopy copy;
  final Scene scene;
  final List<Chapter> chapters;
  final VoidCallback onMoveUp;
  final VoidCallback onMoveDown;
  final ValueChanged<String?> onMoveToChapter;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _HelpTooltip(message: copy.t('helpStructureActions')),
        PopupMenuButton<_SceneStructureAction>(
          tooltip: copy.t('helpStructureActions'),
          icon: const Icon(Icons.more_vert),
          onSelected: (action) {
            switch (action.kind) {
              case _SceneStructureActionKind.moveUp:
                onMoveUp();
              case _SceneStructureActionKind.moveDown:
                onMoveDown();
              case _SceneStructureActionKind.moveToChapter:
                onMoveToChapter(action.chapterId);
              case _SceneStructureActionKind.delete:
                onDelete();
            }
          },
          itemBuilder: (context) {
            return [
              PopupMenuItem(
                value: const _SceneStructureAction(
                  _SceneStructureActionKind.moveUp,
                ),
                child: Text(copy.t('moveSceneUp')),
              ),
              PopupMenuItem(
                value: const _SceneStructureAction(
                  _SceneStructureActionKind.moveDown,
                ),
                child: Text(copy.t('moveSceneDown')),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: const _SceneStructureAction(
                  _SceneStructureActionKind.moveToChapter,
                  chapterId: null,
                ),
                child: Text(copy.t('moveToNoChapter')),
              ),
              for (final chapter in chapters)
                PopupMenuItem(
                  value: _SceneStructureAction(
                    _SceneStructureActionKind.moveToChapter,
                    chapterId: chapter.id,
                  ),
                  child: Text('${copy.t('moveToChapter')}: ${chapter.title}'),
                ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: const _SceneStructureAction(
                  _SceneStructureActionKind.delete,
                ),
                child: Text(copy.t('deleteScene')),
              ),
            ];
          },
        ),
      ],
    );
  }
}

enum _SceneStructureActionKind { moveUp, moveDown, moveToChapter, delete }

final class _SceneStructureAction {
  const _SceneStructureAction(this.kind, {this.chapterId});

  final _SceneStructureActionKind kind;
  final String? chapterId;
}

bool _relationshipTouchesRef(Relationship relationship, EntityRef ref) {
  return (relationship.source.type == ref.type &&
          relationship.source.id == ref.id) ||
      (relationship.target.type == ref.type &&
          relationship.target.id == ref.id);
}

String _relationshipTitle(Relationship relationship, WritelerCopy copy) {
  final label = relationship.label?.trim();
  if (label != null && label.isNotEmpty) return label;
  return _relationshipTypeLabel(relationship.relationshipType, copy);
}

String _relationshipSubtitle(
  Relationship relationship,
  WritelerCopy copy, {
  List<Scene> scenes = const [],
  List<CatalogItem> catalogItems = const [],
}) {
  final arrow =
      relationship.direction == RelationshipDirection.directed ? '->' : '<->';
  final strength = relationship.strength == null
      ? ''
      : ' - ${copy.t('relationshipStrength')}: '
          '${(relationship.strength! * 100).round()}%';
  return '${_entityRefDisplay(relationship.source, copy, scenes, catalogItems)} '
      '$arrow ${_entityRefDisplay(relationship.target, copy, scenes, catalogItems)}'
      '$strength';
}

String _entityRefDisplay(
  EntityRef ref,
  WritelerCopy copy,
  List<Scene> scenes,
  List<CatalogItem> catalogItems,
) {
  if (ref.type == EntityType.scene) {
    final scene = scenes.where((scene) => scene.id == ref.id).firstOrNull;
    return scene == null ? '${copy.t('scene')} ${ref.id}' : scene.title;
  }
  final item = catalogItems
      .where((item) => item.type == ref.type && item.id == ref.id)
      .firstOrNull;
  return item == null
      ? '${_entityTypeLabel(ref.type, copy)} ${ref.id}'
      : item.name;
}

String _relationshipTypeLabel(String value, WritelerCopy copy) {
  return switch (value) {
    'appearsIn' => copy.t('relationTypeAppearsIn'),
    'ally' => copy.t('relationTypeAlly'),
    'conflict' => copy.t('relationTypeConflict'),
    'family' => copy.t('relationTypeFamily'),
    'owns' => copy.t('relationTypeOwns'),
    'locatedAt' => copy.t('relationTypeLocatedAt'),
    'foreshadows' => copy.t('relationTypeForeshadows'),
    _ => value,
  };
}
