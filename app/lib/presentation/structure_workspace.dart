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
    required this.onDropSceneToChapter,
    required this.onDeleteScene,
    required this.onDeleteChapter,
    required this.onCreateScene,
    required this.onCreateChapter,
    required this.onCreateRelationship,
    required this.onEditRelationship,
    required this.onDeleteRelationship,
  });

  final WritellerCopy copy;
  final List<Chapter> chapters;
  final List<Scene> scenes;
  final List<CatalogItem> catalogItems;
  final List<Relationship> relationships;
  final Scene? selectedScene;
  final ValueChanged<Scene> onSelectScene;
  final ValueChanged<Scene> onMoveSceneUp;
  final ValueChanged<Scene> onMoveSceneDown;
  final void Function(Scene scene, String? chapterId) onMoveSceneToChapter;
  final void Function(Scene scene, String? chapterId) onDropSceneToChapter;
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
                      onDropSceneToChapter: onDropSceneToChapter,
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

final class _SceneStatusBoard extends StatelessWidget {
  const _SceneStatusBoard({
    required this.copy,
    required this.scenes,
    required this.onOpenScene,
    required this.onCreateScene,
    required this.onDeleteScene,
    required this.onChangeSceneStatus,
  });

  final WritellerCopy copy;
  final List<Scene> scenes;
  final ValueChanged<Scene> onOpenScene;
  final VoidCallback onCreateScene;
  final ValueChanged<Scene> onDeleteScene;
  final void Function(Scene scene, DraftStatus status) onChangeSceneStatus;

  @override
  Widget build(BuildContext context) {
    final columns = [
      _StatusBoardColumn(
        title: _draftStatusLabel(DraftStatus.planned, copy.languageCode),
        statuses: const [DraftStatus.idea, DraftStatus.planned],
      ),
      _StatusBoardColumn(
        title: copy.t('inProgress'),
        statuses: const [
          DraftStatus.outlined,
          DraftStatus.drafting,
          DraftStatus.needsRevision,
        ],
      ),
      _StatusBoardColumn(
        title: copy.t('done'),
        statuses: const [DraftStatus.revised, DraftStatus.reviewed],
      ),
      _StatusBoardColumn(
        title: copy.t('lockedOrArchived'),
        statuses: const [DraftStatus.locked, DraftStatus.archived],
      ),
    ];
    return Column(
      children: [
        _WorkspaceHeader(
          title: copy.t('sceneBoard'),
          actionLabel: copy.t('newScene'),
          actionIcon: Icons.add,
          actionHelp: copy.t('helpNewScene'),
          onAction: onCreateScene,
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(20),
            scrollDirection: Axis.horizontal,
            itemCount: columns.length,
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final column = columns[index];
              final columnScenes = scenes
                  .where((scene) => column.statuses.contains(scene.status))
                  .toList()
                ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
              return SizedBox(
                width: 320,
                child: _SceneStatusColumn(
                  copy: copy,
                  title: column.title,
                  scenes: columnScenes,
                  statuses: column.statuses,
                  onOpenScene: onOpenScene,
                  onDeleteScene: onDeleteScene,
                  onChangeSceneStatus: onChangeSceneStatus,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

final class _StatusBoardColumn {
  const _StatusBoardColumn({
    required this.title,
    required this.statuses,
  });

  final String title;
  final List<DraftStatus> statuses;
}

final class _SceneStatusColumn extends StatelessWidget {
  const _SceneStatusColumn({
    required this.copy,
    required this.title,
    required this.scenes,
    required this.statuses,
    required this.onOpenScene,
    required this.onDeleteScene,
    required this.onChangeSceneStatus,
  });

  final WritellerCopy copy;
  final String title;
  final List<Scene> scenes;
  final List<DraftStatus> statuses;
  final ValueChanged<Scene> onOpenScene;
  final ValueChanged<Scene> onDeleteScene;
  final void Function(Scene scene, DraftStatus status) onChangeSceneStatus;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final column = DecoratedBox(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: color.outlineVariant)),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(title,
                      style: Theme.of(context).textTheme.titleSmall),
                ),
                Text(
                  '${scenes.length}',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: color.onSurfaceVariant,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: scenes.isEmpty
                  ? _EmptyInlineMessage(message: copy.t('noScenesInStatus'))
                  : ListView.separated(
                      itemCount: scenes.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final scene = scenes[index];
                        final tile = ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.drag_indicator, size: 18),
                          title: Text(
                            scene.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            '${scene.actualWordCount} ${copy.t('words')}',
                          ),
                          trailing: Wrap(
                            spacing: 4,
                            children: [
                              IconButton(
                                tooltip: copy.t('openEditor'),
                                onPressed: () => onOpenScene(scene),
                                icon: const Icon(Icons.open_in_new),
                              ),
                              IconButton(
                                tooltip: copy.t('deleteScene'),
                                onPressed: () => onDeleteScene(scene),
                                icon: const Icon(Icons.delete_outline),
                              ),
                            ],
                          ),
                          onTap: () => onOpenScene(scene),
                        );
                        return Draggable<Scene>(
                          data: scene,
                          dragAnchorStrategy: pointerDragAnchorStrategy,
                          feedback: _DragSceneFeedback(title: scene.title),
                          childWhenDragging:
                              Opacity(opacity: 0.36, child: tile),
                          child: MouseRegion(
                            cursor: SystemMouseCursors.grab,
                            child: tile,
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
    return _StatusSceneDropTarget(
      copy: copy,
      statuses: statuses,
      onChangeSceneStatus: onChangeSceneStatus,
      child: column,
    );
  }
}

final class _TimelineWorkspace extends StatelessWidget {
  const _TimelineWorkspace({
    required this.copy,
    required this.scenes,
    required this.catalogItems,
    required this.onOpenScene,
  });

  final WritellerCopy copy;
  final List<Scene> scenes;
  final List<CatalogItem> catalogItems;
  final ValueChanged<Scene> onOpenScene;

  @override
  Widget build(BuildContext context) {
    final dated = scenes.where((scene) => scene.storyDateStart != null).toList()
      ..sort((a, b) => a.storyDateStart!.compareTo(b.storyDateStart!));
    final undated = scenes
        .where((scene) => scene.storyDateStart == null)
        .toList()
      ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
    final events = catalogItems
        .where((item) => item.type == EntityType.timelineEvent)
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    return _SimpleWorkspace(
      title: copy.t('timeline'),
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(copy.t('timelineBody'),
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 18),
          Text(copy.t('historicalEvents'),
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          if (events.isEmpty)
            _EmptyInlineMessage(message: copy.t('noHistoricalEvents')),
          for (final event in events)
            _TimelineEventRow(copy: copy, item: event),
          const SizedBox(height: 24),
          Text(copy.t('datedScenes'),
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          if (dated.isEmpty)
            _EmptyInlineMessage(message: copy.t('noDatedScenes')),
          for (final scene in dated)
            _TimelineRow(copy: copy, scene: scene, onOpenScene: onOpenScene),
          const SizedBox(height: 24),
          Text(copy.t('undatedScenes'),
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          if (undated.isEmpty)
            _EmptyInlineMessage(message: copy.t('noUndatedScenes')),
          for (final scene in undated)
            _TimelineRow(copy: copy, scene: scene, onOpenScene: onOpenScene),
        ],
      ),
    );
  }
}

final class _TimelineEventRow extends StatelessWidget {
  const _TimelineEventRow({
    required this.copy,
    required this.item,
  });

  final WritellerCopy copy;
  final CatalogItem item;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final time = item.fields['time'] as String? ?? copy.t('withoutDate');
    final consequence = item.fields['consequence'] as String?;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: color.tertiary, width: 2)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.only(left: 14),
        leading: const Icon(Icons.event_note_outlined),
        title: Text(item.name),
        subtitle: Text(
          [
            time,
            if (item.summary.trim().isNotEmpty) item.summary,
            if (consequence?.trim().isNotEmpty == true) consequence!,
          ].join(' · '),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

final class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.copy,
    required this.scene,
    required this.onOpenScene,
  });

  final WritellerCopy copy;
  final Scene scene;
  final ValueChanged<Scene> onOpenScene;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final date = scene.storyDateStart == null
        ? copy.t('withoutDate')
        : _formatLocalDate(scene.storyDateStart!);
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: color.primary, width: 2)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.only(left: 14),
        title: Text(scene.title),
        subtitle: Text('$date · ${scene.actualWordCount} ${copy.t('words')}'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => onOpenScene(scene),
      ),
    );
  }
}

final class _RelationshipGraphWorkspace extends StatefulWidget {
  const _RelationshipGraphWorkspace({
    required this.copy,
    required this.relationships,
    required this.scenes,
    required this.catalogItems,
    required this.onCreateRelationship,
    required this.onEditRelationship,
    required this.onDeleteRelationship,
  });

  final WritellerCopy copy;
  final List<Relationship> relationships;
  final List<Scene> scenes;
  final List<CatalogItem> catalogItems;
  final ValueChanged<EntityRef?> onCreateRelationship;
  final ValueChanged<Relationship> onEditRelationship;
  final ValueChanged<Relationship> onDeleteRelationship;

  @override
  State<_RelationshipGraphWorkspace> createState() =>
      _RelationshipGraphWorkspaceState();
}

final class _RelationshipGraphWorkspaceState
    extends State<_RelationshipGraphWorkspace> {
  String? _selectedRelationshipId;

  @override
  Widget build(BuildContext context) {
    final endpointCount = widget.scenes.length + widget.catalogItems.length;
    final canCreateRelationship = endpointCount >= 2;
    final selectedRelationship = widget.relationships
            .where((relationship) => relationship.id == _selectedRelationshipId)
            .firstOrNull ??
        widget.relationships.firstOrNull;
    return Column(
      children: [
        _WorkspaceHeader(
          title: widget.copy.t('relationshipGraph'),
          actionLabel: widget.copy.t('newRelationship'),
          actionIcon: Icons.add,
          actionHelp: widget.copy.t('helpNewRelationship'),
          onAction: () => widget.onCreateRelationship(null),
        ),
        const Divider(height: 1),
        Expanded(
          child: widget.relationships.isEmpty
              ? _EmptyPanel(
                  icon: Icons.hub_outlined,
                  title: widget.copy.t('noRelationshipsTitle'),
                  body: canCreateRelationship
                      ? widget.copy.t('noRelationshipsBody')
                      : widget.copy.t('relationshipNeedsEndpoints'),
                  action: FilledButton.icon(
                    onPressed: () => widget.onCreateRelationship(null),
                    icon: const Icon(Icons.add),
                    label: Text(widget.copy.t('newRelationship')),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(24),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final compact = constraints.maxWidth < 920;
                      final canvas = _RelationshipGraphCanvas(
                        copy: widget.copy,
                        relationships: widget.relationships,
                        scenes: widget.scenes,
                        catalogItems: widget.catalogItems,
                        selectedRelationship: selectedRelationship,
                        onSelectRelationship: (relationship) => setState(
                          () => _selectedRelationshipId = relationship.id,
                        ),
                      );
                      final inspector = _RelationshipGraphInspector(
                        copy: widget.copy,
                        relationship: selectedRelationship,
                        scenes: widget.scenes,
                        catalogItems: widget.catalogItems,
                        onEdit: selectedRelationship == null
                            ? null
                            : () => widget.onEditRelationship(
                                  selectedRelationship,
                                ),
                        onDelete: selectedRelationship == null
                            ? null
                            : () => widget.onDeleteRelationship(
                                  selectedRelationship,
                                ),
                      );

                      if (compact) {
                        return Column(
                          children: [
                            Expanded(child: canvas),
                            const SizedBox(height: 16),
                            SizedBox(height: 250, child: inspector),
                          ],
                        );
                      }
                      return Row(
                        children: [
                          Expanded(child: canvas),
                          const SizedBox(width: 18),
                          SizedBox(width: 320, child: inspector),
                        ],
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }
}

final class _RelationshipGraphCanvas extends StatelessWidget {
  const _RelationshipGraphCanvas({
    required this.copy,
    required this.relationships,
    required this.scenes,
    required this.catalogItems,
    required this.selectedRelationship,
    required this.onSelectRelationship,
  });

  final WritellerCopy copy;
  final List<Relationship> relationships;
  final List<Scene> scenes;
  final List<CatalogItem> catalogItems;
  final Relationship? selectedRelationship;
  final ValueChanged<Relationship> onSelectRelationship;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final nodes = _relationshipGraphNodes(
      relationships,
      scenes,
      catalogItems,
      copy,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.surfaceContainerLowest,
        border: Border.all(color: color.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final size = Size(
              math.max(1, constraints.maxWidth),
              math.max(1, constraints.maxHeight),
            );
            final positions = _relationshipGraphPositions(nodes, size);
            return Stack(
              fit: StackFit.expand,
              children: [
                CustomPaint(
                  painter: _RelationshipGraphPainter(
                    colorScheme: color,
                    relationships: relationships,
                    positions: positions,
                    selectedRelationship: selectedRelationship,
                  ),
                ),
                for (final relationship in relationships)
                  if (_relationshipMidpoint(relationship, positions)
                      case final midpoint?)
                    _RelationshipEdgeLabel(
                      copy: copy,
                      relationship: relationship,
                      selected: relationship.id == selectedRelationship?.id,
                      midpoint: midpoint,
                      canvasSize: size,
                      onTap: () => onSelectRelationship(relationship),
                    ),
                for (final node in nodes)
                  if (positions[_relationshipNodeKey(node.ref)] case final pos?)
                    _RelationshipGraphNodeChip(
                      node: node,
                      position: pos,
                      highlighted: selectedRelationship == null ||
                          _relationshipTouchesRef(
                            selectedRelationship!,
                            node.ref,
                          ),
                    ),
              ],
            );
          },
        ),
      ),
    );
  }
}

final class _RelationshipGraphInspector extends StatelessWidget {
  const _RelationshipGraphInspector({
    required this.copy,
    required this.relationship,
    required this.scenes,
    required this.catalogItems,
    required this.onEdit,
    required this.onDelete,
  });

  final WritellerCopy copy;
  final Relationship? relationship;
  final List<Scene> scenes;
  final List<CatalogItem> catalogItems;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final relationship = this.relationship;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: color.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: relationship == null
            ? Center(child: Text(copy.t('noRelationshipsYet')))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    copy.t('relationshipGraphInspector'),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _relationshipTitle(relationship, copy),
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _relationshipSubtitle(
                              relationship,
                              copy,
                              scenes: scenes,
                              catalogItems: catalogItems,
                            ),
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: color.onSurfaceVariant),
                          ),
                          const SizedBox(height: 16),
                          _RelationshipDetailLine(
                            label: copy.t('relationshipType'),
                            value: _relationshipTypeLabel(
                              relationship.relationshipType,
                              copy,
                            ),
                          ),
                          _RelationshipDetailLine(
                            label: copy.t('relationshipDirected'),
                            value: relationship.direction ==
                                    RelationshipDirection.directed
                                ? copy.t('relationshipDirected')
                                : copy.t('relationshipUndirected'),
                          ),
                          _RelationshipDetailLine(
                            label: copy.t('relationshipStrength'),
                            value: relationship.strength == null
                                ? copy.t('missing')
                                : '${(relationship.strength! * 100).round()}%',
                          ),
                          if (relationship.description?.trim().isNotEmpty ==
                              true) ...[
                            const SizedBox(height: 14),
                            Text(
                              relationship.description!.trim(),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onEdit,
                          icon: const Icon(Icons.edit_outlined),
                          label: Text(copy.t('editRelationship')),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.outlined(
                        tooltip: copy.t('deleteRelationship'),
                        onPressed: onDelete,
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}

final class _RelationshipGraphNodeChip extends StatelessWidget {
  const _RelationshipGraphNodeChip({
    required this.node,
    required this.position,
    required this.highlighted,
  });

  final _RelationshipGraphNode node;
  final Offset position;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final accent = _relationshipNodeColor(node.type, color);
    return Positioned(
      left: position.dx - 72,
      top: position.dy - 28,
      width: 144,
      height: 56,
      child: Tooltip(
        message: node.tooltip,
        waitDuration: const Duration(milliseconds: 350),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: highlighted
                ? accent.withValues(alpha: 0.16)
                : color.surfaceContainerHighest.withValues(alpha: 0.72),
            border: Border.all(
              color: highlighted ? accent : color.outlineVariant,
              width: highlighted ? 1.6 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
            boxShadow: highlighted
                ? [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.16),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                Icon(_catalogIcon(node.type), size: 18, color: accent),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _TooltipText(
                        node.label,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      _TooltipText(
                        node.typeLabel,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: color.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

final class _RelationshipDetailLine extends StatelessWidget {
  const _RelationshipDetailLine({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 104,
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: color.onSurfaceVariant,
                  ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

final class _RelationshipEdgeLabel extends StatelessWidget {
  const _RelationshipEdgeLabel({
    required this.copy,
    required this.relationship,
    required this.selected,
    required this.midpoint,
    required this.canvasSize,
    required this.onTap,
  });

  final WritellerCopy copy;
  final Relationship relationship;
  final bool selected;
  final Offset midpoint;
  final Size canvasSize;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final label = _relationshipTitle(relationship, copy);
    final left = (midpoint.dx - 70).clamp(12.0, canvasSize.width - 152.0);
    final top = (midpoint.dy - 18).clamp(12.0, canvasSize.height - 48.0);
    return Positioned(
      left: left,
      top: top,
      width: 140,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: selected
                  ? color.primaryContainer
                  : color.surface.withValues(alpha: 0.92),
              border: Border.all(
                color: selected ? color.primary : color.outlineVariant,
              ),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: selected
                        ? color.onPrimaryContainer
                        : color.onSurfaceVariant,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}

final class _RelationshipGraphPainter extends CustomPainter {
  const _RelationshipGraphPainter({
    required this.colorScheme,
    required this.relationships,
    required this.positions,
    required this.selectedRelationship,
  });

  final ColorScheme colorScheme;
  final List<Relationship> relationships;
  final Map<String, Offset> positions;
  final Relationship? selectedRelationship;

  @override
  void paint(Canvas canvas, Size size) {
    _drawBackground(canvas, size);
    for (final relationship in relationships) {
      final source = positions[_relationshipNodeKey(relationship.source)];
      final target = positions[_relationshipNodeKey(relationship.target)];
      if (source == null || target == null) continue;
      final vector = target - source;
      final distance = vector.distance;
      if (distance < 1) continue;
      final unit = vector / distance;
      final start = source + unit * 62;
      final end = target - unit * 62;
      final selected = relationship.id == selectedRelationship?.id;
      final strength = relationship.strength?.clamp(0.0, 1.0) ?? 0.44;
      final paint = Paint()
        ..color = selected
            ? colorScheme.primary
            : colorScheme.outline.withValues(alpha: 0.62)
        ..strokeWidth = selected ? 3.4 : 1.3 + (strength * 2.3)
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      canvas.drawLine(start, end, paint);
      if (relationship.direction == RelationshipDirection.directed) {
        _drawArrow(canvas, end, unit, paint.color);
      }
    }
  }

  void _drawBackground(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = colorScheme.outlineVariant.withValues(alpha: 0.18)
      ..strokeWidth = 1;
    const gap = 72.0;
    for (var x = gap; x < size.width; x += gap) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var y = gap; y < size.height; y += gap) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  void _drawArrow(Canvas canvas, Offset tip, Offset unit, Color color) {
    final normal = Offset(-unit.dy, unit.dx);
    final base = tip - unit * 14;
    final path = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo((base + normal * 7).dx, (base + normal * 7).dy)
      ..lineTo((base - normal * 7).dx, (base - normal * 7).dy)
      ..close();
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant _RelationshipGraphPainter oldDelegate) {
    return oldDelegate.relationships != relationships ||
        oldDelegate.positions != positions ||
        oldDelegate.selectedRelationship?.id != selectedRelationship?.id ||
        oldDelegate.colorScheme != colorScheme;
  }
}

final class _RelationshipGraphNode {
  const _RelationshipGraphNode({
    required this.ref,
    required this.label,
    required this.typeLabel,
    required this.type,
    required this.tooltip,
  });

  final EntityRef ref;
  final String label;
  final String typeLabel;
  final EntityType type;
  final String tooltip;
}

List<_RelationshipGraphNode> _relationshipGraphNodes(
  List<Relationship> relationships,
  List<Scene> scenes,
  List<CatalogItem> catalogItems,
  WritellerCopy copy,
) {
  final refs = <String, EntityRef>{};
  for (final relationship in relationships) {
    refs[_relationshipNodeKey(relationship.source)] = relationship.source;
    refs[_relationshipNodeKey(relationship.target)] = relationship.target;
  }
  return [
    for (final ref in refs.values)
      _RelationshipGraphNode(
        ref: ref,
        label: _entityLabel(ref, scenes, catalogItems, copy),
        typeLabel: _entityTypeLabel(ref.type, copy),
        type: ref.type,
        tooltip: _entityTooltip(ref, scenes, catalogItems, copy),
      ),
  ]..sort((a, b) {
      final typeCompare = a.type.index.compareTo(b.type.index);
      if (typeCompare != 0) return typeCompare;
      return a.label.compareTo(b.label);
    });
}

Map<String, Offset> _relationshipGraphPositions(
  List<_RelationshipGraphNode> nodes,
  Size size,
) {
  if (nodes.isEmpty) return const {};
  final center = Offset(size.width / 2, size.height / 2);
  if (nodes.length == 1) {
    return {_relationshipNodeKey(nodes.first.ref): center};
  }
  final horizontalRadius = math.max(100.0, (size.width - 190) / 2);
  final verticalRadius = math.max(90.0, (size.height - 150) / 2);
  final radius = math.min(horizontalRadius, verticalRadius);
  return {
    for (var index = 0; index < nodes.length; index++)
      _relationshipNodeKey(nodes[index].ref): Offset(
        center.dx +
            math.cos((-math.pi / 2) + (index * 2 * math.pi / nodes.length)) *
                radius,
        center.dy +
            math.sin((-math.pi / 2) + (index * 2 * math.pi / nodes.length)) *
                radius,
      ),
  };
}

String _relationshipNodeKey(EntityRef ref) => '${ref.type.wireName}:${ref.id}';

Offset? _relationshipMidpoint(
  Relationship relationship,
  Map<String, Offset> positions,
) {
  final source = positions[_relationshipNodeKey(relationship.source)];
  final target = positions[_relationshipNodeKey(relationship.target)];
  if (source == null || target == null) return null;
  return Offset((source.dx + target.dx) / 2, (source.dy + target.dy) / 2);
}

Color _relationshipNodeColor(EntityType type, ColorScheme color) {
  return switch (type) {
    EntityType.character => color.primary,
    EntityType.location => color.tertiary,
    EntityType.object => color.secondary,
    EntityType.scene => color.error,
    _ => color.primary,
  };
}

// ignore: unused_element
final class _RelationshipGraphRow extends StatelessWidget {
  const _RelationshipGraphRow({
    required this.copy,
    required this.relationship,
    required this.sourceLabel,
    required this.targetLabel,
    required this.onEdit,
    required this.onDelete,
  });

  final WritellerCopy copy;
  final Relationship relationship;
  final String sourceLabel;
  final String targetLabel;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(Icons.hub_outlined, color: color.primary),
      title: Text('$sourceLabel -> $targetLabel'),
      subtitle: Text(
        '${relationship.relationshipType} · ${copy.t('strength')}: '
        '${((relationship.strength ?? 0) * 100).round()}%',
      ),
      trailing: Wrap(
        spacing: 4,
        children: [
          IconButton(
            tooltip: copy.t('editRelationship'),
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            tooltip: copy.t('delete'),
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
    );
  }
}

String _entityLabel(
  EntityRef ref,
  List<Scene> scenes,
  List<CatalogItem> catalogItems,
  WritellerCopy copy,
) {
  if (ref.type == EntityType.scene) {
    return scenes.where((scene) => scene.id == ref.id).firstOrNull?.title ??
        copy.t('scene');
  }
  return catalogItems.where((item) => item.id == ref.id).firstOrNull?.name ??
      ref.type.wireName;
}

String _entityTooltip(
  EntityRef ref,
  List<Scene> scenes,
  List<CatalogItem> catalogItems,
  WritellerCopy copy,
) {
  if (ref.type == EntityType.scene) {
    final scene = scenes.where((scene) => scene.id == ref.id).firstOrNull;
    if (scene == null) return copy.t('scene');
    return [
      '${copy.t('scene')}: ${scene.title}',
      if (scene.summary.trim().isNotEmpty)
        '${copy.t('summary')}: ${scene.summary.trim()}',
      if (scene.goal?.trim().isNotEmpty == true)
        '${copy.t('goal')}: ${scene.goal!.trim()}',
      if (scene.conflict?.trim().isNotEmpty == true)
        '${copy.t('conflict')}: ${scene.conflict!.trim()}',
      if (scene.outcome?.trim().isNotEmpty == true)
        '${copy.t('outcome')}: ${scene.outcome!.trim()}',
    ].join('\n');
  }
  final item = catalogItems
      .where((item) => item.type == ref.type && item.id == ref.id)
      .firstOrNull;
  return item == null ? ref.type.wireName : _catalogItemTooltipText(item, copy);
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

  final WritellerCopy copy;
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
    required this.onDropSceneToChapter,
    required this.onDeleteScene,
  });

  final WritellerCopy copy;
  final _SceneStructureGroup group;
  final List<Chapter> chapters;
  final Scene? selectedScene;
  final ValueChanged<Scene> onSelectScene;
  final ValueChanged<Scene> onMoveSceneUp;
  final ValueChanged<Scene> onMoveSceneDown;
  final void Function(Scene scene, String? chapterId) onMoveSceneToChapter;
  final void Function(Scene scene, String? chapterId) onDropSceneToChapter;
  final ValueChanged<Scene> onDeleteScene;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return DragTarget<Scene>(
      onWillAcceptWithDetails: (details) => details.data.chapterId != group.id,
      onAcceptWithDetails: (details) =>
          onDropSceneToChapter(details.data, group.id),
      builder: (context, candidateData, rejectedData) {
        final highlighted = candidateData.isNotEmpty;
        return DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(
              color: highlighted ? color.primary : color.outlineVariant,
              width: highlighted ? 1.6 : 1,
            ),
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
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final scene = group.scenes[index];
                    final selected = selectedScene?.id == scene.id;
                    final tile = _SceneStructureTile(
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
                    return Draggable<Scene>(
                      data: scene,
                      dragAnchorStrategy: pointerDragAnchorStrategy,
                      feedback: _DragSceneFeedback(title: scene.title),
                      childWhenDragging: Opacity(opacity: 0.36, child: tile),
                      child: MouseRegion(
                        cursor: SystemMouseCursors.grab,
                        child: tile,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

final class _DragSceneFeedback extends StatelessWidget {
  const _DragSceneFeedback({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(8),
      color: color.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.drag_indicator, color: color.onSurfaceVariant),
            const SizedBox(width: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 240),
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final class _StatusSceneDropTarget extends StatelessWidget {
  const _StatusSceneDropTarget({
    required this.copy,
    required this.statuses,
    required this.onChangeSceneStatus,
    required this.child,
  });

  final WritellerCopy copy;
  final List<DraftStatus> statuses;
  final void Function(Scene scene, DraftStatus status) onChangeSceneStatus;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return DragTarget<Scene>(
      onWillAcceptWithDetails: (details) =>
          !statuses.contains(details.data.status),
      onAcceptWithDetails: (details) async {
        final status = statuses.length == 1
            ? statuses.first
            : await showDialog<DraftStatus>(
                context: context,
                builder: (context) => SimpleDialog(
                  title: Text(copy.t('chooseStatus')),
                  children: [
                    for (final status in statuses)
                      SimpleDialogOption(
                        onPressed: () => Navigator.of(context).pop(status),
                        child:
                            Text(_draftStatusLabel(status, copy.languageCode)),
                      ),
                  ],
                ),
              );
        if (status != null) onChangeSceneStatus(details.data, status);
      },
      builder: (context, candidateData, rejectedData) {
        final highlighted = candidateData.isNotEmpty;
        return DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(
              color: highlighted ? color.primary : Colors.transparent,
              width: 1.4,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: child,
        );
      },
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

  final WritellerCopy copy;
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

  final WritellerCopy copy;
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

  final WritellerCopy copy;
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

  final WritellerCopy copy;
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

  final WritellerCopy copy;
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

  final WritellerCopy copy;
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

  final WritellerCopy copy;
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

  final WritellerCopy copy;
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

  final WritellerCopy copy;
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

  final WritellerCopy copy;
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

String _relationshipTitle(Relationship relationship, WritellerCopy copy) {
  final label = relationship.label?.trim();
  if (label != null && label.isNotEmpty) return label;
  return _relationshipTypeLabel(relationship.relationshipType, copy);
}

String _relationshipSubtitle(
  Relationship relationship,
  WritellerCopy copy, {
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
  WritellerCopy copy,
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

String _relationshipTypeLabel(String value, WritellerCopy copy) {
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
