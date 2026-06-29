part of '../main.dart';

const double _storyboardCanvasWidth = 1680;
const double _storyboardCanvasHeight = 1040;
const double _storyboardCardWidth = 230;
const double _storyboardCardHeight = 92;
const double _storyboardCanvasPadding = 96;
const int _storyboardDefaultRowsPerLane = 7;

enum _StoryboardNodeKind { scene, character, location, object, note }

final class _StoryboardWorkspace extends StatefulWidget {
  const _StoryboardWorkspace({
    required this.copy,
    required this.project,
    required this.scenes,
    required this.catalogItems,
    required this.notes,
    required this.onSaveStoryboard,
    required this.onReorderScene,
  });

  final WritellerCopy copy;
  final Project? project;
  final List<Scene> scenes;
  final List<CatalogItem> catalogItems;
  final List<ProjectNote> notes;
  final Future<void> Function(Map<String, Object?> storyboard) onSaveStoryboard;
  final Future<void> Function(String sourceNodeId, String targetNodeId)
      onReorderScene;

  @override
  State<_StoryboardWorkspace> createState() => _StoryboardWorkspaceState();
}

final class _StoryboardWorkspaceState extends State<_StoryboardWorkspace> {
  final Map<String, Offset> _positions = {};
  final Set<String> _connections = {};
  final List<String> _timelineOrder = [];
  Size _canvasSize = const Size(
    _storyboardCanvasWidth,
    _storyboardCanvasHeight,
  );
  bool _connectMode = false;
  String? _pendingConnectionStartId;
  Timer? _persistTimer;
  bool _storyboardDirty = false;

  @override
  void initState() {
    super.initState();
    _loadPersistedState();
  }

  @override
  void didUpdateWidget(covariant _StoryboardWorkspace oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.project?.id != widget.project?.id ||
        oldWidget.project?.metadata['storyboard'] !=
            widget.project?.metadata['storyboard']) {
      _loadPersistedState();
    }
  }

  @override
  void dispose() {
    if (_storyboardDirty) {
      unawaited(widget.onSaveStoryboard(_storyboardToJson()));
    }
    _persistTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final project = widget.project;
    if (project == null) return _EmptyWorkspace(copy: widget.copy);

    final nodes = _buildNodes(project);
    _syncCanvasState(nodes);
    _canvasSize = _resolvedCanvasSize();
    final nodesById = {for (final node in nodes) node.id: node};
    final nodesByIdForTimeline = {for (final node in nodes) node.id: node};
    final timelineNodes = [
      for (final id in _timelineOrder)
        if (nodesByIdForTimeline[id] != null) nodesByIdForTimeline[id]!,
    ];

    return Column(
      children: [
        _StoryboardToolbar(
          copy: widget.copy,
          nodeCount: nodes.length,
          connectionCount: _connections.length,
          connectMode: _connectMode,
          onConnectModeChanged: (value) {
            setState(() {
              _connectMode = value;
              _pendingConnectionStartId = null;
            });
          },
          onClearConnections: _connections.isEmpty
              ? null
              : () {
                  setState(() {
                    _connections.clear();
                    _pendingConnectionStartId = null;
                  });
                  _schedulePersist();
                },
        ),
        const Divider(height: 1),
        Expanded(
          child: nodes.isEmpty
              ? _StoryboardEmptyState(copy: widget.copy)
              : _StoryboardCanvas(
                  copy: widget.copy,
                  nodes: nodes,
                  canvasSize: _canvasSize,
                  positions: _positions,
                  connections: _connections,
                  connectMode: _connectMode,
                  pendingConnectionStartId: _pendingConnectionStartId,
                  onMoveNode: _moveNode,
                  onTapNode: _tapNode,
                ),
        ),
        if (_connections.isNotEmpty) ...[
          const Divider(height: 1),
          _StoryboardConnectionStrip(
            copy: widget.copy,
            connections: _connections,
            nodesById: nodesById,
            onRemoveConnection: _removeConnection,
          ),
        ],
        if (timelineNodes.isNotEmpty) ...[
          const Divider(height: 1),
          _StoryboardTimeRail(
            copy: widget.copy,
            nodes: timelineNodes,
            onReorder: _reorderTimeline,
          ),
        ],
      ],
    );
  }

  List<_StoryboardNode> _buildNodes(Project project) {
    final projectScenes = widget.scenes
        .where((scene) => scene.projectId == project.id)
        .toList()
      ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
    final projectCatalog = widget.catalogItems
        .where((item) => item.projectId == project.id)
        .toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    final projectNotes = widget.notes
        .where((note) => note.projectId == project.id)
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    final nodes = <_StoryboardNode>[
      for (final scene in projectScenes)
        _StoryboardNode(
          id: 'scene:${scene.id}',
          kind: _StoryboardNodeKind.scene,
          title: scene.title.trim().isEmpty
              ? widget.copy.t('untitledScene')
              : scene.title.trim(),
          subtitle:
              '${_draftStatusLabel(scene.status, widget.copy.languageCode)} · '
              '${scene.actualWordCount} ${widget.copy.t('words')}',
          body: _firstFilled([scene.summary, scene.goal, scene.conflict]),
          icon: Icons.movie_filter_outlined,
        ),
      for (final item in projectCatalog)
        if (item.type == EntityType.character ||
            item.type == EntityType.location ||
            item.type == EntityType.object)
          _StoryboardNode(
            id: 'catalog:${item.id}',
            kind: switch (item.type) {
              EntityType.character => _StoryboardNodeKind.character,
              EntityType.location => _StoryboardNodeKind.location,
              EntityType.object => _StoryboardNodeKind.object,
              _ => _StoryboardNodeKind.object,
            },
            title: item.name.trim().isEmpty
                ? widget.copy.t('untitledCatalogItem')
                : item.name.trim(),
            subtitle: widget.copy.t(_catalogTitleKey(item.type)),
            body: item.summary,
            icon: _catalogIcon(item.type),
          ),
      for (final note in projectNotes)
        _StoryboardNode(
          id: 'note:${note.id}',
          kind: _StoryboardNodeKind.note,
          title: note.title.trim().isEmpty
              ? widget.copy.t('notes')
              : note.title.trim(),
          subtitle: widget.copy.t('notes'),
          body: note.body,
          icon: Icons.sticky_note_2_outlined,
        ),
    ];

    return nodes;
  }

  void _syncCanvasState(List<_StoryboardNode> nodes) {
    final nodeIds = nodes.map((node) => node.id).toSet();
    final sceneNodeIds = nodes
        .where((node) => node.kind == _StoryboardNodeKind.scene)
        .map((node) => node.id)
        .toSet();
    _positions.removeWhere((id, _) => !nodeIds.contains(id));
    _connections.removeWhere((key) {
      final parts = key.split('|');
      return parts.length != 2 ||
          !nodeIds.contains(parts.first) ||
          !nodeIds.contains(parts.last);
    });
    _timelineOrder.removeWhere((id) => !sceneNodeIds.contains(id));
    for (final node in nodes) {
      if (node.kind == _StoryboardNodeKind.scene &&
          !_timelineOrder.contains(node.id)) {
        _timelineOrder.add(node.id);
      }
    }

    final usedByKind = <_StoryboardNodeKind, int>{};
    for (final node in nodes) {
      if (_positions.containsKey(node.id)) continue;
      final index =
          usedByKind.update(node.kind, (value) => value + 1, ifAbsent: () => 0);
      _positions[node.id] = _defaultPosition(node.kind, index);
    }
  }

  Offset _defaultPosition(_StoryboardNodeKind kind, int index) {
    final baseColumn = switch (kind) {
      _StoryboardNodeKind.character => 0,
      _StoryboardNodeKind.location => 1,
      _StoryboardNodeKind.object => 1,
      _StoryboardNodeKind.scene => 2,
      _StoryboardNodeKind.note => 3,
    };
    final lane = index ~/ _storyboardDefaultRowsPerLane;
    final row = index % _storyboardDefaultRowsPerLane;
    final stagger = switch (kind) {
      _StoryboardNodeKind.object => 52.0,
      _StoryboardNodeKind.note => 28.0,
      _ => 0.0,
    };
    return Offset(
      56 + baseColumn * 390 + lane * 260,
      64 + row * 124 + stagger,
    );
  }

  Size _resolvedCanvasSize([Offset? additionalPosition]) {
    var width = _storyboardCanvasWidth;
    var height = _storyboardCanvasHeight;
    final positions = [
      ..._positions.values,
      if (additionalPosition != null) additionalPosition,
    ];
    for (final position in positions) {
      width = math.max(
        width,
        position.dx + _storyboardCardWidth + _storyboardCanvasPadding,
      );
      height = math.max(
        height,
        position.dy + _storyboardCardHeight + _storyboardCanvasPadding,
      );
    }
    return Size(width, height);
  }

  void _moveNode(String id, Offset delta) {
    setState(() {
      final current = _positions[id] ?? Offset.zero;
      final proposed = current + delta;
      _canvasSize = _resolvedCanvasSize(proposed);
      _positions[id] = _clampPosition(proposed);
    });
    _schedulePersist();
  }

  Offset _clampPosition(Offset position) {
    final x = position.dx.clamp(
      24,
      _canvasSize.width - _storyboardCardWidth - 24,
    );
    final y = position.dy.clamp(
      24,
      _canvasSize.height - _storyboardCardHeight - 24,
    );
    return Offset(x.toDouble(), y.toDouble());
  }

  void _tapNode(String id) {
    if (!_connectMode) return;
    setState(() {
      final startId = _pendingConnectionStartId;
      if (startId == null) {
        _pendingConnectionStartId = id;
        return;
      }
      if (startId == id) {
        _pendingConnectionStartId = null;
        return;
      }
      _connections.add(_connectionKey(startId, id));
      _pendingConnectionStartId = null;
    });
    _schedulePersist();
  }

  void _removeConnection(String key) {
    setState(() => _connections.remove(key));
    _schedulePersist();
  }

  void _reorderTimeline(String sourceNodeId, String targetNodeId) {
    if (sourceNodeId == targetNodeId) return;
    setState(() {
      _timelineOrder.remove(sourceNodeId);
      final targetIndex = _timelineOrder.indexOf(targetNodeId);
      if (targetIndex == -1) {
        _timelineOrder.add(sourceNodeId);
      } else {
        _timelineOrder.insert(targetIndex, sourceNodeId);
      }
    });
    _schedulePersist();
    unawaited(widget.onReorderScene(sourceNodeId, targetNodeId));
  }

  void _loadPersistedState() {
    _persistTimer?.cancel();
    _positions.clear();
    _connections.clear();
    _timelineOrder.clear();
    final storyboard = _storyboardMetadata(widget.project);
    final positions = storyboard['positions'];
    if (positions is Map) {
      for (final entry in positions.entries) {
        final id = entry.key.toString();
        final value = entry.value;
        if (value is Map) {
          final x = _asDouble(value['x']);
          final y = _asDouble(value['y']);
          if (x != null && y != null) {
            _positions[id] = Offset(x, y);
          }
        }
      }
    }
    final connections = storyboard['connections'];
    if (connections is List) {
      _connections.addAll(connections.whereType<String>());
    }
    final timeline = storyboard['timeline'];
    if (timeline is List) {
      _timelineOrder.addAll(timeline.whereType<String>());
    }
  }

  void _schedulePersist() {
    _storyboardDirty = true;
    _persistTimer?.cancel();
    _persistTimer = Timer(const Duration(milliseconds: 450), () {
      _storyboardDirty = false;
      unawaited(widget.onSaveStoryboard(_storyboardToJson()));
    });
  }

  Map<String, Object?> _storyboardToJson() {
    return {
      'version': 1,
      'positions': {
        for (final entry in _positions.entries)
          entry.key: {
            'x': entry.value.dx,
            'y': entry.value.dy,
          },
      },
      'connections': (_connections.toList()..sort()),
      'timeline': List<String>.unmodifiable(_timelineOrder),
      'updatedAt': DateTime.now().toUtc().toIso8601String(),
    };
  }
}

final class _StoryboardToolbar extends StatelessWidget {
  const _StoryboardToolbar({
    required this.copy,
    required this.nodeCount,
    required this.connectionCount,
    required this.connectMode,
    required this.onConnectModeChanged,
    required this.onClearConnections,
  });

  final WritellerCopy copy;
  final int nodeCount;
  final int connectionCount;
  final bool connectMode;
  final ValueChanged<bool> onConnectModeChanged;
  final VoidCallback? onClearConnections;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return ColoredBox(
      color: color.surface,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
        child: Wrap(
          spacing: 12,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Semantics(
              header: true,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.polyline_outlined, color: color.primary),
                  const SizedBox(width: 10),
                  Text(
                    copy.t('storyboard'),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ],
              ),
            ),
            _StoryboardInfoPill(
              icon: Icons.dashboard_customize_outlined,
              label: copy.t('storyboardElements'),
              value: '$nodeCount',
            ),
            _StoryboardInfoPill(
              icon: Icons.link_outlined,
              label: copy.t('storyboardConnections'),
              value: '$connectionCount',
            ),
            SegmentedButton<bool>(
              segments: [
                ButtonSegment(
                  value: false,
                  icon: const Icon(Icons.open_with_outlined),
                  label: Text(copy.t('storyboardMoveMode')),
                ),
                ButtonSegment(
                  value: true,
                  icon: const Icon(Icons.add_link_outlined),
                  label: Text(copy.t('storyboardConnectMode')),
                ),
              ],
              selected: {connectMode},
              onSelectionChanged: (selection) =>
                  onConnectModeChanged(selection.first),
            ),
            Tooltip(
              message: copy.t('storyboardConnectHint'),
              child: Icon(Icons.help_outline, size: 20, color: color.primary),
            ),
            OutlinedButton.icon(
              onPressed: onClearConnections,
              icon: const Icon(Icons.link_off_outlined),
              label: Text(copy.t('storyboardClearConnections')),
            ),
          ],
        ),
      ),
    );
  }
}

final class _StoryboardCanvas extends StatefulWidget {
  const _StoryboardCanvas({
    required this.copy,
    required this.nodes,
    required this.canvasSize,
    required this.positions,
    required this.connections,
    required this.connectMode,
    required this.pendingConnectionStartId,
    required this.onMoveNode,
    required this.onTapNode,
  });

  final WritellerCopy copy;
  final List<_StoryboardNode> nodes;
  final Size canvasSize;
  final Map<String, Offset> positions;
  final Set<String> connections;
  final bool connectMode;
  final String? pendingConnectionStartId;
  final void Function(String id, Offset delta) onMoveNode;
  final ValueChanged<String> onTapNode;

  @override
  State<_StoryboardCanvas> createState() => _StoryboardCanvasState();
}

final class _StoryboardCanvasState extends State<_StoryboardCanvas> {
  late final TransformationController _transformationController;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  void _resetView() {
    _transformationController.value = Matrix4.identity();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final nodeById = {for (final node in widget.nodes) node.id: node};

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.surfaceContainerLowest,
      ),
      child: ClipRect(
        child: Stack(
          children: [
            Positioned.fill(
              child: InteractiveViewer(
                transformationController: _transformationController,
                alignment: Alignment.topLeft,
                constrained: false,
                boundaryMargin: const EdgeInsets.all(80),
                minScale: 0.45,
                maxScale: 1.65,
                child: Semantics(
                  label: widget.copy.t('storyboardCanvas'),
                  child: SizedBox(
                    width: widget.canvasSize.width,
                    height: widget.canvasSize.height,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _StoryboardBackgroundPainter(
                              lineColor:
                                  color.outlineVariant.withValues(alpha: 0.3),
                              accentColor:
                                  color.primary.withValues(alpha: 0.16),
                            ),
                          ),
                        ),
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _StoryboardConnectionPainter(
                              connections: Set.unmodifiable(widget.connections),
                              positions: Map.unmodifiable(widget.positions),
                              lineColor: color.primary.withValues(alpha: 0.62),
                              shadowColor:
                                  color.primary.withValues(alpha: 0.12),
                            ),
                          ),
                        ),
                        for (final node in widget.nodes)
                          Positioned(
                            left: widget.positions[node.id]?.dx ?? 0,
                            top: widget.positions[node.id]?.dy ?? 0,
                            child: _StoryboardNodeCard(
                              copy: widget.copy,
                              node: node,
                              tone: _toneForNode(context, node.kind),
                              selected:
                                  widget.pendingConnectionStartId == node.id,
                              connected: _hasConnection(
                                node.id,
                                widget.connections,
                              ),
                              connectMode: widget.connectMode,
                              onTap: () => widget.onTapNode(node.id),
                              onDrag: (delta) =>
                                  widget.onMoveNode(node.id, delta),
                            ),
                          ),
                        if (widget.connectMode &&
                            widget.pendingConnectionStartId != null)
                          Positioned(
                            left: (widget
                                        .positions[
                                            widget.pendingConnectionStartId!]
                                        ?.dx ??
                                    0) +
                                14,
                            top: (widget
                                        .positions[
                                            widget.pendingConnectionStartId!]
                                        ?.dy ??
                                    0) -
                                34,
                            child: _StoryboardHintBubble(
                              text: widget.copy.t('storyboardPickSecondNode'),
                            ),
                          ),
                        Positioned(
                          right: 28,
                          bottom: 24,
                          child: _StoryboardLegend(
                            copy: widget.copy,
                            nodeById: nodeById,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 18,
              bottom: 18,
              child: Tooltip(
                message: widget.copy.t('storyboardResetView'),
                child: IconButton.filledTonal(
                  onPressed: _resetView,
                  icon: const Icon(Icons.center_focus_strong_outlined),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final class _StoryboardNodeCard extends StatelessWidget {
  const _StoryboardNodeCard({
    required this.copy,
    required this.node,
    required this.tone,
    required this.selected,
    required this.connected,
    required this.connectMode,
    required this.onTap,
    required this.onDrag,
  });

  final WritellerCopy copy;
  final _StoryboardNode node;
  final Color tone;
  final bool selected;
  final bool connected;
  final bool connectMode;
  final VoidCallback onTap;
  final ValueChanged<Offset> onDrag;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final borderColor = selected
        ? tone
        : connected
            ? tone.withValues(alpha: 0.52)
            : color.outlineVariant;
    return MouseRegion(
      cursor: connectMode ? SystemMouseCursors.click : SystemMouseCursors.move,
      child: GestureDetector(
        onTap: onTap,
        onPanUpdate: connectMode ? null : (details) => onDrag(details.delta),
        child: Tooltip(
          message: connectMode
              ? copy.t('storyboardNodeConnectTooltip')
              : copy.t('storyboardNodeMoveTooltip'),
          waitDuration: const Duration(milliseconds: 500),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 130),
            width: _storyboardCardWidth,
            height: _storyboardCardHeight,
            decoration: BoxDecoration(
              color: color.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: borderColor,
                width: selected ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.shadow.withValues(alpha: selected ? 0.16 : 0.08),
                  blurRadius: selected ? 18 : 10,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 6,
                  decoration: BoxDecoration(
                    color: tone,
                    borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(7),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(node.icon, size: 18, color: tone),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                node.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(fontWeight: FontWeight.w800),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text(
                          node.subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: color.onSurfaceVariant,
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _shorten(node.body, 74),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: color.onSurfaceVariant,
                                    height: 1.15,
                                  ),
                        ),
                      ],
                    ),
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

final class _StoryboardConnectionStrip extends StatelessWidget {
  const _StoryboardConnectionStrip({
    required this.copy,
    required this.connections,
    required this.nodesById,
    required this.onRemoveConnection,
  });

  final WritellerCopy copy;
  final Set<String> connections;
  final Map<String, _StoryboardNode> nodesById;
  final ValueChanged<String> onRemoveConnection;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final sortedConnections = connections.toList()..sort();
    return ColoredBox(
      color: color.surface,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
        child: Row(
          children: [
            Icon(Icons.link_outlined, size: 17, color: color.primary),
            const SizedBox(width: 8),
            Text(
              copy.t('storyboardConnections'),
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final key in sortedConnections) ...[
                      _StoryboardConnectionChip(
                        label: _connectionLabel(key, nodesById),
                        onRemove: () => onRemoveConnection(key),
                        removeTooltip: copy.t('storyboardRemoveConnection'),
                      ),
                      const SizedBox(width: 8),
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

final class _StoryboardConnectionChip extends StatelessWidget {
  const _StoryboardConnectionChip({
    required this.label,
    required this.onRemove,
    required this.removeTooltip,
  });

  final String label;
  final VoidCallback onRemove;
  final String removeTooltip;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.surfaceContainerHighest.withValues(alpha: 0.56),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 10, right: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 240),
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
            Tooltip(
              message: removeTooltip,
              child: IconButton(
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints.tightFor(
                  width: 30,
                  height: 30,
                ),
                onPressed: onRemove,
                icon: const Icon(Icons.close, size: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final class _StoryboardTimeRail extends StatelessWidget {
  const _StoryboardTimeRail({
    required this.copy,
    required this.nodes,
    required this.onReorder,
  });

  final WritellerCopy copy;
  final List<_StoryboardNode> nodes;
  final void Function(String sourceNodeId, String targetNodeId) onReorder;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final railWidth =
        math.max(760, 132 + math.max(0, nodes.length - 1) * 184).toDouble();
    return ColoredBox(
      color: color.surface,
      child: SizedBox(
        height: 124,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.timeline_outlined, size: 18, color: color.primary),
                  const SizedBox(width: 8),
                  Text(
                    copy.t('storyboardTimeline'),
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      copy.t('storyboardTimelineHint'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: color.onSurfaceVariant,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: railWidth,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _StoryboardTimeRailPainter(
                              itemCount: nodes.length,
                              lineColor: color.outlineVariant,
                              dotColor: color.primary,
                            ),
                          ),
                        ),
                        for (var index = 0; index < nodes.length; index++)
                          Positioned(
                            left:
                                _timeRailX(index, nodes.length, railWidth) - 78,
                            top: 8,
                            width: 156,
                            child: _StoryboardTimeRailEvent(
                              index: index + 1,
                              node: nodes[index],
                              onReorder: onReorder,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final class _StoryboardTimeRailEvent extends StatelessWidget {
  const _StoryboardTimeRailEvent({
    required this.index,
    required this.node,
    required this.onReorder,
  });

  final int index;
  final _StoryboardNode node;
  final void Function(String sourceNodeId, String targetNodeId) onReorder;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final tone = _toneForNode(context, _StoryboardNodeKind.scene);
    final content = Column(
      children: [
        Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color.surface,
            shape: BoxShape.circle,
            border: Border.all(color: tone, width: 2),
            boxShadow: [
              BoxShadow(
                color: tone.withValues(alpha: 0.16),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            '$index',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: tone,
                  fontWeight: FontWeight.w900,
                ),
          ),
        ),
        const SizedBox(height: 9),
        Text(
          node.title,
          maxLines: 1,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 2),
        Text(
          node.subtitle,
          maxLines: 1,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: color.onSurfaceVariant,
              ),
        ),
      ],
    );
    return DragTarget<String>(
      onWillAcceptWithDetails: (details) => details.data != node.id,
      onAcceptWithDetails: (details) => onReorder(details.data, node.id),
      builder: (context, candidateData, rejectedData) {
        final highlighted = candidateData.isNotEmpty;
        final child = AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: highlighted
              ? BoxDecoration(
                  color: tone.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: tone.withValues(alpha: 0.48)),
                )
              : null,
          child: content,
        );
        return LongPressDraggable<String>(
          data: node.id,
          feedback: Material(
            color: Colors.transparent,
            child: SizedBox(width: 156, child: child),
          ),
          childWhenDragging: Opacity(opacity: 0.42, child: child),
          child: child,
        );
      },
    );
  }
}

final class _StoryboardTimeRailPainter extends CustomPainter {
  const _StoryboardTimeRailPainter({
    required this.itemCount,
    required this.lineColor,
    required this.dotColor,
  });

  final int itemCount;
  final Color lineColor;
  final Color dotColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (itemCount == 0) return;
    const railY = 22.0;
    final start = Offset(_timeRailX(0, itemCount, size.width), railY);
    final end = Offset(
      _timeRailX(itemCount - 1, itemCount, size.width),
      railY,
    );
    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(start, end, linePaint);

    for (var index = 0; index < itemCount; index++) {
      final x = _timeRailX(index, itemCount, size.width);
      canvas.drawCircle(
        Offset(x, railY),
        5,
        Paint()
          ..color = dotColor.withValues(alpha: 0.18)
          ..style = PaintingStyle.fill,
      );
      canvas.drawCircle(
        Offset(x, railY),
        2.6,
        Paint()
          ..color = dotColor
          ..style = PaintingStyle.fill,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _StoryboardTimeRailPainter oldDelegate) {
    return itemCount != oldDelegate.itemCount ||
        lineColor != oldDelegate.lineColor ||
        dotColor != oldDelegate.dotColor;
  }
}

double _timeRailX(int index, int itemCount, double width) {
  if (itemCount <= 1) return width / 2;
  const inset = 66.0;
  return inset + index * ((width - inset * 2) / (itemCount - 1));
}

final class _StoryboardInfoPill extends StatelessWidget {
  const _StoryboardInfoPill({
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
        color: color.surfaceContainerHighest.withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color.primary),
            const SizedBox(width: 7),
            Text(label, style: Theme.of(context).textTheme.labelSmall),
            const SizedBox(width: 6),
            Text(
              value,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

final class _StoryboardHintBubble extends StatelessWidget {
  const _StoryboardHintBubble({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.inverseSurface,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
        child: Text(
          text,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: color.onInverseSurface,
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
    );
  }
}

final class _StoryboardLegend extends StatelessWidget {
  const _StoryboardLegend({
    required this.copy,
    required this.nodeById,
  });

  final WritellerCopy copy;
  final Map<String, _StoryboardNode> nodeById;

  @override
  Widget build(BuildContext context) {
    final counts = <_StoryboardNodeKind, int>{};
    for (final node in nodeById.values) {
      counts.update(node.kind, (value) => value + 1, ifAbsent: () => 1);
    }
    final entries = [
      _StoryboardNodeKind.scene,
      _StoryboardNodeKind.character,
      _StoryboardNodeKind.location,
      _StoryboardNodeKind.object,
      _StoryboardNodeKind.note,
    ];
    final color = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final kind in entries)
              if ((counts[kind] ?? 0) > 0) ...[
                _StoryboardLegendDot(
                  tone: _toneForNode(context, kind),
                  label: '${_labelForKind(copy, kind)} ${counts[kind]}',
                ),
                const SizedBox(width: 10),
              ],
          ],
        ),
      ),
    );
  }
}

final class _StoryboardLegendDot extends StatelessWidget {
  const _StoryboardLegendDot({
    required this.tone,
    required this.label,
  });

  final Color tone;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(color: tone, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}

final class _StoryboardEmptyState extends StatelessWidget {
  const _StoryboardEmptyState({required this.copy});

  final WritellerCopy copy;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.dashboard_customize_outlined,
              size: 48,
              color: color.primary,
            ),
            const SizedBox(height: 14),
            Text(
              copy.t('storyboardEmptyTitle'),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              copy.t('storyboardEmptyBody'),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: color.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

final class _StoryboardBackgroundPainter extends CustomPainter {
  const _StoryboardBackgroundPainter({
    required this.lineColor,
    required this.accentColor,
  });

  final Color lineColor;
  final Color accentColor;

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = lineColor
      ..strokeWidth = 1;
    for (var x = 40.0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (var y = 40.0; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final lanePaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    for (final x in [56.0, 446.0, 836.0, 1226.0]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x - 24, 34, 312, size.height - 72),
          const Radius.circular(16),
        ),
        lanePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _StoryboardBackgroundPainter oldDelegate) =>
      lineColor != oldDelegate.lineColor ||
      accentColor != oldDelegate.accentColor;
}

final class _StoryboardConnectionPainter extends CustomPainter {
  const _StoryboardConnectionPainter({
    required this.connections,
    required this.positions,
    required this.lineColor,
    required this.shadowColor,
  });

  final Set<String> connections;
  final Map<String, Offset> positions;
  final Color lineColor;
  final Color shadowColor;

  @override
  void paint(Canvas canvas, Size size) {
    final shadowPaint = Paint()
      ..color = shadowColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;
    final linePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;

    for (final key in connections) {
      final parts = key.split('|');
      if (parts.length != 2) continue;
      final start = positions[parts.first];
      final end = positions[parts.last];
      if (start == null || end == null) continue;

      final startCenter = start +
          const Offset(_storyboardCardWidth / 2, _storyboardCardHeight / 2);
      final endCenter = end +
          const Offset(_storyboardCardWidth / 2, _storyboardCardHeight / 2);
      final distance = (endCenter.dx - startCenter.dx).abs();
      final bend = math.max(90, distance * 0.36).toDouble();
      final path = Path()
        ..moveTo(startCenter.dx, startCenter.dy)
        ..cubicTo(
          startCenter.dx + bend,
          startCenter.dy,
          endCenter.dx - bend,
          endCenter.dy,
          endCenter.dx,
          endCenter.dy,
        );

      canvas.drawPath(path, shadowPaint);
      canvas.drawPath(path, linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _StoryboardConnectionPainter oldDelegate) =>
      connections != oldDelegate.connections ||
      positions != oldDelegate.positions ||
      lineColor != oldDelegate.lineColor ||
      shadowColor != oldDelegate.shadowColor;
}

final class _StoryboardNode {
  const _StoryboardNode({
    required this.id,
    required this.kind,
    required this.title,
    required this.subtitle,
    required this.body,
    required this.icon,
  });

  final String id;
  final _StoryboardNodeKind kind;
  final String title;
  final String subtitle;
  final String body;
  final IconData icon;
}

Color _toneForNode(BuildContext context, _StoryboardNodeKind kind) {
  final color = Theme.of(context).colorScheme;
  final design = Theme.of(context).extension<WritellerDesignTokens>()!;
  return switch (kind) {
    _StoryboardNodeKind.scene => color.primary,
    _StoryboardNodeKind.character => design.statusProgress,
    _StoryboardNodeKind.location => design.statusDone,
    _StoryboardNodeKind.object => design.statusPlanned,
    _StoryboardNodeKind.note => color.tertiary,
  };
}

String _labelForKind(WritellerCopy copy, _StoryboardNodeKind kind) {
  return switch (kind) {
    _StoryboardNodeKind.scene => copy.t('scenes'),
    _StoryboardNodeKind.character => copy.t('characters'),
    _StoryboardNodeKind.location => copy.t('locations'),
    _StoryboardNodeKind.object => copy.t('objects'),
    _StoryboardNodeKind.note => copy.t('notes'),
  };
}

bool _hasConnection(String id, Set<String> connections) {
  return connections.any((key) {
    final parts = key.split('|');
    return parts.contains(id);
  });
}

String _connectionKey(String firstId, String secondId) {
  final sorted = [firstId, secondId]..sort();
  return '${sorted.first}|${sorted.last}';
}

String _connectionLabel(String key, Map<String, _StoryboardNode> nodesById) {
  final parts = key.split('|');
  if (parts.length != 2) return key;
  final first = nodesById[parts.first]?.title ?? parts.first;
  final second = nodesById[parts.last]?.title ?? parts.last;
  return '$first - $second';
}

Map<String, Object?> _storyboardMetadata(Project? project) {
  final storyboard = project?.metadata['storyboard'];
  if (storyboard is Map) return Map<String, Object?>.from(storyboard);
  return const {};
}

double? _asDouble(Object? value) {
  return switch (value) {
    int() => value.toDouble(),
    double() => value,
    String() => double.tryParse(value),
    _ => null,
  };
}

String _firstFilled(Iterable<String?> values) {
  for (final value in values) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isNotEmpty) return trimmed;
  }
  return '';
}

String _shorten(String value, int maxLength) {
  final normalized = value.trim().replaceAll(RegExp(r'\s+'), ' ');
  if (normalized.isEmpty) return '';
  if (normalized.length <= maxLength) return normalized;
  return '${normalized.substring(0, maxLength - 3)}...';
}
