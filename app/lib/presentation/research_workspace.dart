part of '../main.dart';

// Research library workspace and editor-side source viewer.

final class _ResearchWorkspace extends StatefulWidget {
  const _ResearchWorkspace({
    required this.copy,
    required this.project,
    required this.items,
    required this.scenes,
    required this.catalogItems,
    required this.onSaveItem,
    required this.onDeleteItem,
  });

  final WritelerCopy copy;
  final Project? project;
  final List<ResearchItem> items;
  final List<Scene> scenes;
  final List<CatalogItem> catalogItems;
  final Future<void> Function({
    ResearchItem? existing,
    required ResearchItemKind kind,
    required String title,
    required String uri,
    required String body,
    required String source,
    required List<String> tags,
    required EntityRef? target,
  }) onSaveItem;
  final ValueChanged<ResearchItem> onDeleteItem;

  @override
  State<_ResearchWorkspace> createState() => _ResearchWorkspaceState();
}

final class _ResearchWorkspaceState extends State<_ResearchWorkspace> {
  ResearchItem? _selectedItem;
  ResearchItemKind? _filterKind;

  @override
  void didUpdateWidget(covariant _ResearchWorkspace oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_selectedItem == null) return;
    final updated = widget.items.where((item) => item.id == _selectedItem!.id);
    _selectedItem = updated.firstOrNull;
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filterKind == null
        ? widget.items
        : widget.items.where((item) => item.kind == _filterKind).toList();
    final selected = _selectedItem ?? filtered.firstOrNull;

    return Column(
      children: [
        _WorkspaceHeader(
          title: widget.copy.t('researchLibrary'),
          actionLabel: widget.copy.t('newResearchItem'),
          actionIcon: Icons.add,
          actionHelp: widget.copy.t('helpNewResearchItem'),
          onAction: widget.project == null ? null : _showCreateDialog,
        ),
        const Divider(height: 1),
        Expanded(
          child: widget.project == null
              ? _EmptyWorkspace(copy: widget.copy)
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final compact = constraints.maxWidth < 860;
                    if (compact) {
                      return ListView(
                        padding: const EdgeInsets.all(18),
                        children: [
                          _ResearchFilterBar(
                            copy: widget.copy,
                            selectedKind: _filterKind,
                            onChanged: (kind) =>
                                setState(() => _filterKind = kind),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 320,
                            child: _ResearchList(
                              copy: widget.copy,
                              items: filtered,
                              selectedItem: selected,
                              onSelect: (item) =>
                                  setState(() => _selectedItem = item),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _ResearchDetail(
                            copy: widget.copy,
                            item: selected,
                            scenes: widget.scenes,
                            catalogItems: widget.catalogItems,
                            onEdit: selected == null
                                ? null
                                : () => _showEditDialog(selected),
                            onDelete: selected == null
                                ? null
                                : () => widget.onDeleteItem(selected),
                          ),
                        ],
                      );
                    }

                    return Row(
                      children: [
                        SizedBox(
                          width: 360,
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: _ResearchFilterBar(
                                  copy: widget.copy,
                                  selectedKind: _filterKind,
                                  onChanged: (kind) =>
                                      setState(() => _filterKind = kind),
                                ),
                              ),
                              const Divider(height: 1),
                              Expanded(
                                child: _ResearchList(
                                  copy: widget.copy,
                                  items: filtered,
                                  selectedItem: selected,
                                  onSelect: (item) =>
                                      setState(() => _selectedItem = item),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const VerticalDivider(width: 1),
                        Expanded(
                          child: _ResearchDetail(
                            copy: widget.copy,
                            item: selected,
                            scenes: widget.scenes,
                            catalogItems: widget.catalogItems,
                            onEdit: selected == null
                                ? null
                                : () => _showEditDialog(selected),
                            onDelete: selected == null
                                ? null
                                : () => widget.onDeleteItem(selected),
                          ),
                        ),
                      ],
                    );
                  },
                ),
        ),
      ],
    );
  }

  Future<void> _showCreateDialog() async {
    final result = await showDialog<_ResearchEditResult>(
      context: context,
      builder: (context) => _ResearchEditDialog(
        copy: widget.copy,
        scenes: widget.scenes,
        catalogItems: widget.catalogItems,
      ),
    );
    if (result == null) return;
    await widget.onSaveItem(
      kind: result.kind,
      title: result.title,
      uri: result.uri,
      body: result.body,
      source: result.source,
      tags: result.tags,
      target: result.target,
    );
  }

  Future<void> _showEditDialog(ResearchItem item) async {
    final result = await showDialog<_ResearchEditResult>(
      context: context,
      builder: (context) => _ResearchEditDialog(
        copy: widget.copy,
        scenes: widget.scenes,
        catalogItems: widget.catalogItems,
        item: item,
      ),
    );
    if (result == null) return;
    await widget.onSaveItem(
      existing: item,
      kind: result.kind,
      title: result.title,
      uri: result.uri,
      body: result.body,
      source: result.source,
      tags: result.tags,
      target: result.target,
    );
  }
}

final class _ResearchFilterBar extends StatelessWidget {
  const _ResearchFilterBar({
    required this.copy,
    required this.selectedKind,
    required this.onChanged,
  });

  final WritelerCopy copy;
  final ResearchItemKind? selectedKind;
  final ValueChanged<ResearchItemKind?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<ResearchItemKind?>(
      initialValue: selectedKind,
      icon: const Icon(Icons.keyboard_arrow_down_rounded),
      decoration: InputDecoration(
        labelText: copy.t('researchFilter'),
        border: const OutlineInputBorder(),
        isDense: true,
      ),
      items: [
        DropdownMenuItem(value: null, child: Text(copy.t('allResearch'))),
        for (final kind in ResearchItemKind.values)
          DropdownMenuItem(
            value: kind,
            child: Text(_researchKindLabel(kind, copy)),
          ),
      ],
      onChanged: onChanged,
    );
  }
}

final class _ResearchList extends StatelessWidget {
  const _ResearchList({
    required this.copy,
    required this.items,
    required this.selectedItem,
    required this.onSelect,
  });

  final WritelerCopy copy;
  final List<ResearchItem> items;
  final ResearchItem? selectedItem;
  final ValueChanged<ResearchItem> onSelect;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(18),
        child: _EmptyInlineMessage(message: copy.t('noResearchItems')),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: items.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final item = items[index];
        final selected = selectedItem?.id == item.id;
        return ListTile(
          selected: selected,
          leading: Icon(
            _researchKindIcon(item.kind),
            color: selected ? color.primary : color.onSurfaceVariant,
          ),
          title: Text(
            item.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            item.uri.isEmpty ? item.body : item.uri,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: item.tags.isEmpty
              ? null
              : Text(
                  item.tags.take(2).join(', '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
          onTap: () => onSelect(item),
        );
      },
    );
  }
}

final class _ResearchDetail extends StatelessWidget {
  const _ResearchDetail({
    required this.copy,
    required this.item,
    required this.scenes,
    required this.catalogItems,
    required this.onEdit,
    required this.onDelete,
  });

  final WritelerCopy copy;
  final ResearchItem? item;
  final List<Scene> scenes;
  final List<CatalogItem> catalogItems;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final item = this.item;
    if (item == null) {
      return _EmptyPanel(
        icon: Icons.travel_explore_outlined,
        title: copy.t('researchEmptyTitle'),
        body: copy.t('researchEmptyBody'),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_researchKindIcon(item.kind), color: color.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
              IconButton(
                tooltip: copy.t('editResearchItem'),
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined),
              ),
              IconButton(
                tooltip: copy.t('deleteResearchItem'),
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(label: Text(_researchKindLabel(item.kind, copy))),
              if (item.target != null)
                Chip(
                    label: Text(_researchTargetLabel(
                        item.target!, scenes, catalogItems, copy))),
              for (final tag in item.tags) Chip(label: Text(tag)),
            ],
          ),
          if (item.uri.isNotEmpty) ...[
            const SizedBox(height: 16),
            SelectableText(
              item.uri,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: color.primary,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
          if (item.source.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              '${copy.t('researchSource')}: ${item.source}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: color.onSurfaceVariant,
                  ),
            ),
          ],
          const SizedBox(height: 18),
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: color.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: color.outlineVariant),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(18),
                child: SelectableText(
                  item.body.isEmpty ? copy.t('noResearchBody') : item.body,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        height: 1.55,
                      ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

final class _ResearchEditResult {
  const _ResearchEditResult({
    required this.kind,
    required this.title,
    required this.uri,
    required this.body,
    required this.source,
    required this.tags,
    required this.target,
  });

  final ResearchItemKind kind;
  final String title;
  final String uri;
  final String body;
  final String source;
  final List<String> tags;
  final EntityRef? target;
}

final class _ResearchEditDialog extends StatefulWidget {
  const _ResearchEditDialog({
    required this.copy,
    required this.scenes,
    required this.catalogItems,
    this.item,
  });

  final WritelerCopy copy;
  final List<Scene> scenes;
  final List<CatalogItem> catalogItems;
  final ResearchItem? item;

  @override
  State<_ResearchEditDialog> createState() => _ResearchEditDialogState();
}

final class _ResearchEditDialogState extends State<_ResearchEditDialog> {
  late ResearchItemKind _kind = widget.item?.kind ?? ResearchItemKind.link;
  late EntityRef? _target = widget.item?.target;
  late final TextEditingController _titleController =
      TextEditingController(text: widget.item?.title ?? '');
  late final TextEditingController _uriController =
      TextEditingController(text: widget.item?.uri ?? '');
  late final TextEditingController _bodyController =
      TextEditingController(text: widget.item?.body ?? '');
  late final TextEditingController _sourceController =
      TextEditingController(text: widget.item?.source ?? '');
  late final TextEditingController _tagsController =
      TextEditingController(text: widget.item?.tags.join(', ') ?? '');

  @override
  void dispose() {
    _titleController.dispose();
    _uriController.dispose();
    _bodyController.dispose();
    _sourceController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final copy = widget.copy;
    return AlertDialog(
      title: Text(widget.item == null
          ? copy.t('newResearchItem')
          : copy.t('editResearchItem')),
      content: SizedBox(
        width: 640,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<ResearchItemKind>(
                initialValue: _kind,
                icon: const Icon(Icons.keyboard_arrow_down_rounded),
                decoration: InputDecoration(
                  labelText: copy.t('researchKind'),
                  border: const OutlineInputBorder(),
                ),
                items: [
                  for (final kind in ResearchItemKind.values)
                    DropdownMenuItem(
                      value: kind,
                      child: Text(_researchKindLabel(kind, copy)),
                    ),
                ],
                onChanged: (kind) => setState(() {
                  if (kind != null) _kind = kind;
                }),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: copy.t('researchTitle'),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _uriController,
                      decoration: InputDecoration(
                        labelText: copy.t('researchUri'),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.outlined(
                    tooltip: copy.t('chooseResearchFile'),
                    onPressed: _pickFile,
                    icon: const Icon(Icons.attach_file),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _sourceController,
                decoration: InputDecoration(
                  labelText: copy.t('researchSource'),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _tagsController,
                decoration: InputDecoration(
                  labelText: copy.t('researchTags'),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _targetWire(_target),
                icon: const Icon(Icons.keyboard_arrow_down_rounded),
                decoration: InputDecoration(
                  labelText: copy.t('researchTarget'),
                  border: const OutlineInputBorder(),
                ),
                items: _targetItems(copy),
                onChanged: (value) =>
                    setState(() => _target = _parseTarget(value)),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _bodyController,
                minLines: 5,
                maxLines: 10,
                decoration: InputDecoration(
                  labelText: copy.t('researchBody'),
                  alignLabelWithHint: true,
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(copy.t('cancel')),
        ),
        FilledButton.icon(
          onPressed: _submit,
          icon: const Icon(Icons.save_outlined),
          label: Text(copy.t('save')),
        ),
      ],
    );
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.pickFiles(lockParentWindow: true);
    final file = result?.files.firstOrNull;
    if (file == null) return;
    final path = file.path ?? file.name;
    setState(() {
      _uriController.text = path;
      if (_titleController.text.trim().isEmpty) {
        _titleController.text = file.name;
      }
      final extension = file.extension?.toLowerCase();
      if (extension == 'pdf') {
        _kind = ResearchItemKind.pdf;
      } else if (['png', 'jpg', 'jpeg', 'gif', 'webp'].contains(extension)) {
        _kind = ResearchItemKind.image;
      } else {
        _kind = ResearchItemKind.file;
      }
    });
  }

  void _submit() {
    Navigator.of(context).pop(
      _ResearchEditResult(
        kind: _kind,
        title: _titleController.text,
        uri: _uriController.text,
        body: _bodyController.text,
        source: _sourceController.text,
        tags: _parseTags(_tagsController.text),
        target: _target,
      ),
    );
  }

  List<DropdownMenuItem<String>> _targetItems(WritelerCopy copy) {
    return [
      DropdownMenuItem(value: '', child: Text(copy.t('targetProject'))),
      for (final scene in widget.scenes)
        DropdownMenuItem(
          value: _targetWire(EntityRef(type: EntityType.scene, id: scene.id)),
          child: Text('${copy.t('scene')}: ${scene.title}'),
        ),
      for (final item in widget.catalogItems)
        DropdownMenuItem(
          value: _targetWire(EntityRef(type: item.type, id: item.id)),
          child: Text('${_entityTypeLabel(item.type, copy)}: ${item.name}'),
        ),
    ];
  }
}

final class _SceneResearchViewer extends StatelessWidget {
  const _SceneResearchViewer({
    required this.copy,
    required this.scene,
    required this.items,
  });

  final WritelerCopy copy;
  final Scene scene;
  final List<ResearchItem> items;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final relevant = items
        .where((item) {
          final target = item.target;
          return target == null ||
              (target.type == EntityType.scene && target.id == scene.id);
        })
        .take(6)
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.travel_explore_outlined, color: color.primary, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                copy.t('researchViewer'),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (relevant.isEmpty)
          _EmptyInlineMessage(message: copy.t('noSceneResearch'))
        else
          for (final item in relevant)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: color.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: color.outlineVariant),
                ),
                child: ListTile(
                  dense: true,
                  leading: Icon(_researchKindIcon(item.kind), size: 18),
                  title: Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    item.uri.isNotEmpty ? item.uri : item.body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
      ],
    );
  }
}

String _researchKindLabel(ResearchItemKind kind, WritelerCopy copy) =>
    switch (kind) {
      ResearchItemKind.link => copy.t('researchKindLink'),
      ResearchItemKind.file => copy.t('researchKindFile'),
      ResearchItemKind.image => copy.t('researchKindImage'),
      ResearchItemKind.pdf => copy.t('researchKindPdf'),
      ResearchItemKind.webNote => copy.t('researchKindWebNote'),
      ResearchItemKind.source => copy.t('researchKindSource'),
    };

IconData _researchKindIcon(ResearchItemKind kind) => switch (kind) {
      ResearchItemKind.link => Icons.link_outlined,
      ResearchItemKind.file => Icons.insert_drive_file_outlined,
      ResearchItemKind.image => Icons.image_outlined,
      ResearchItemKind.pdf => Icons.picture_as_pdf_outlined,
      ResearchItemKind.webNote => Icons.public_outlined,
      ResearchItemKind.source => Icons.source_outlined,
    };

String _targetWire(EntityRef? target) {
  if (target == null) return '';
  return '${target.type.wireName}:${target.id}';
}

EntityRef? _parseTarget(String? value) {
  if (value == null || value.isEmpty || !value.contains(':')) return null;
  final parts = value.split(':');
  return EntityRef(
      type: EntityTypeWire.parse(parts.first), id: parts.sublist(1).join(':'));
}

List<String> _parseTags(String value) {
  return value
      .split(',')
      .map((tag) => tag.trim())
      .where((tag) => tag.isNotEmpty)
      .toList();
}

String _researchTargetLabel(
  EntityRef target,
  List<Scene> scenes,
  List<CatalogItem> catalogItems,
  WritelerCopy copy,
) {
  if (target.type == EntityType.scene) {
    final scene = scenes.where((scene) => scene.id == target.id).firstOrNull;
    return '${copy.t('scene')}: ${scene?.title ?? target.id}';
  }
  final item = catalogItems.where((item) => item.id == target.id).firstOrNull;
  return '${_entityTypeLabel(target.type, copy)}: ${item?.name ?? target.id}';
}
