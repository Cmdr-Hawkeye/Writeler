part of '../main.dart';

const double _storyboardCanvasWidth = 1680;
const double _storyboardCanvasHeight = 1040;
const double _storyboardCardWidth = 230;
const double _storyboardCardHeight = 92;

enum _StoryboardNodeKind { scene, character, location, object, note }

final class _StoryboardWorkspace extends StatefulWidget {
  const _StoryboardWorkspace({
    required this.copy,
    required this.project,
    required this.scenes,
    required this.catalogItems,
    required this.notes,
  });

  final WritelerCopy copy;
  final Project? project;
  final List<Scene> scenes;
  final List<CatalogItem> catalogItems;
  final List<ProjectNote> notes;

  @override
  State<_StoryboardWorkspace> createState() => _StoryboardWorkspaceState();
}

final class _StoryboardWorkspaceState extends State<_StoryboardWorkspace> {
  final Map<String, Offset> _positions = {};
  final Set<String> _connections = {};
  bool _connectMode = false;
  String? _pendingConnectionStartId;

  @override
  Widget build(BuildContext context) {
    final project = widget.project;
    if (project == null) return _EmptyWorkspace(copy: widget.copy);

    final nodes = _buildNodes(project);
    _syncCanvasState(nodes);

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
              : () => setState(() {
                    _connections.clear();
                    _pendingConnectionStartId = null;
                  }),
        ),
        const Divider(height: 1),
        Expanded(
          child: nodes.isEmpty
              ? _StoryboardEmptyState(copy: widget.copy)
              : _StoryboardCanvas(
                  copy: widget.copy,
                  nodes: nodes,
                  positions: _positions,
                  connections: _connections,
                  connectMode: _connectMode,
                  pendingConnectionStartId: _pendingConnectionStartId,
                  onMoveNode: _moveNode,
                  onTapNode: _tapNode,
                ),
        ),
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
    _positions.removeWhere((id, _) => !nodeIds.contains(id));
    _connections.removeWhere((key) {
      final parts = key.split('|');
      return parts.length != 2 ||
          !nodeIds.contains(parts.first) ||
          !nodeIds.contains(parts.last);
    });

    final usedByKind = <_StoryboardNodeKind, int>{};
    for (final node in nodes) {
      if (_positions.containsKey(node.id)) continue;
      final index =
          usedByKind.update(node.kind, (value) => value + 1, ifAbsent: () => 0);
      _positions[node.id] = _defaultPosition(node.kind, index);
    }
  }

  Offset _defaultPosition(_StoryboardNodeKind kind, int index) {
    final column = switch (kind) {
      _StoryboardNodeKind.character => 0,
      _StoryboardNodeKind.location => 1,
      _StoryboardNodeKind.object => 1,
      _StoryboardNodeKind.scene => 2,
      _StoryboardNodeKind.note => 3,
    };
    final stagger = switch (kind) {
      _StoryboardNodeKind.object => 52.0,
      _StoryboardNodeKind.note => 28.0,
      _ => 0.0,
    };
    return Offset(56 + column * 390, 64 + index * 124 + stagger);
  }

  void _moveNode(String id, Offset delta) {
    setState(() {
      final current = _positions[id] ?? Offset.zero;
      _positions[id] = _clampPosition(current + delta);
    });
  }

  Offset _clampPosition(Offset position) {
    final x = position.dx.clamp(
      24,
      _storyboardCanvasWidth - _storyboardCardWidth - 24,
    );
    final y = position.dy.clamp(
      24,
      _storyboardCanvasHeight - _storyboardCardHeight - 24,
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

  final WritelerCopy copy;
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

final class _StoryboardCanvas extends StatelessWidget {
  const _StoryboardCanvas({
    required this.copy,
    required this.nodes,
    required this.positions,
    required this.connections,
    required this.connectMode,
    required this.pendingConnectionStartId,
    required this.onMoveNode,
    required this.onTapNode,
  });

  final WritelerCopy copy;
  final List<_StoryboardNode> nodes;
  final Map<String, Offset> positions;
  final Set<String> connections;
  final bool connectMode;
  final String? pendingConnectionStartId;
  final void Function(String id, Offset delta) onMoveNode;
  final ValueChanged<String> onTapNode;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final nodeById = {for (final node in nodes) node.id: node};

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.surfaceContainerLowest,
      ),
      child: ClipRect(
        child: InteractiveViewer(
          constrained: false,
          boundaryMargin: const EdgeInsets.all(360),
          minScale: 0.45,
          maxScale: 1.65,
          child: Semantics(
            label: copy.t('storyboardCanvas'),
            child: SizedBox(
              width: _storyboardCanvasWidth,
              height: _storyboardCanvasHeight,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _StoryboardBackgroundPainter(
                        lineColor: color.outlineVariant.withValues(alpha: 0.3),
                        accentColor: color.primary.withValues(alpha: 0.16),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _StoryboardConnectionPainter(
                        connections: Set.unmodifiable(connections),
                        positions: Map.unmodifiable(positions),
                        lineColor: color.primary.withValues(alpha: 0.62),
                        shadowColor: color.primary.withValues(alpha: 0.12),
                      ),
                    ),
                  ),
                  for (final node in nodes)
                    Positioned(
                      left: positions[node.id]?.dx ?? 0,
                      top: positions[node.id]?.dy ?? 0,
                      child: _StoryboardNodeCard(
                        copy: copy,
                        node: node,
                        tone: _toneForNode(context, node.kind),
                        selected: pendingConnectionStartId == node.id,
                        connected: _hasConnection(node.id, connections),
                        connectMode: connectMode,
                        onTap: () => onTapNode(node.id),
                        onDrag: (delta) => onMoveNode(node.id, delta),
                      ),
                    ),
                  if (connectMode && pendingConnectionStartId != null)
                    Positioned(
                      left:
                          (positions[pendingConnectionStartId!]?.dx ?? 0) + 14,
                      top: (positions[pendingConnectionStartId!]?.dy ?? 0) - 34,
                      child: _StoryboardHintBubble(
                        text: copy.t('storyboardPickSecondNode'),
                      ),
                    ),
                  Positioned(
                    right: 28,
                    bottom: 24,
                    child: _StoryboardLegend(copy: copy, nodeById: nodeById),
                  ),
                ],
              ),
            ),
          ),
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

  final WritelerCopy copy;
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

  final WritelerCopy copy;
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

  final WritelerCopy copy;

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
  final design = Theme.of(context).extension<WritelerDesignTokens>()!;
  return switch (kind) {
    _StoryboardNodeKind.scene => color.primary,
    _StoryboardNodeKind.character => design.statusProgress,
    _StoryboardNodeKind.location => design.statusDone,
    _StoryboardNodeKind.object => design.statusPlanned,
    _StoryboardNodeKind.note => color.tertiary,
  };
}

String _labelForKind(WritelerCopy copy, _StoryboardNodeKind kind) {
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
