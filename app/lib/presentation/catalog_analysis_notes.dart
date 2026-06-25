part of '../main.dart';

// Catalog, story analysis, notes cockpit, and related reusable analysis widgets.

final class _CatalogWorkspace extends StatelessWidget {
  const _CatalogWorkspace({
    required this.copy,
    required this.type,
    required this.items,
    required this.onCreateItem,
    required this.onEditItem,
    required this.onDeleteItem,
  });

  final WritelerCopy copy;
  final EntityType type;
  final List<CatalogItem> items;
  final VoidCallback onCreateItem;
  final ValueChanged<CatalogItem> onEditItem;
  final ValueChanged<CatalogItem> onDeleteItem;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return Column(
      children: [
        _WorkspaceHeader(
          title: copy.t(_catalogTitleKey(type)),
          actionLabel: copy.t(_newCatalogKey(type)),
          actionIcon: Icons.add,
          actionHelp: copy.t('helpNewCatalogItem'),
          onAction: onCreateItem,
        ),
        const Divider(height: 1),
        Expanded(
          child: items.isEmpty
              ? _EmptyPanel(
                  icon: _catalogIcon(type),
                  title: copy.t(_emptyCatalogTitleKey(type)),
                  body: copy.t('catalogEmptyBody'),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: items.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return ListTile(
                      leading: Icon(_catalogIcon(type), color: color.primary),
                      title: Text(item.name),
                      subtitle: Text(
                        item.summary.isEmpty
                            ? copy.t('noSummary')
                            : item.summary,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Wrap(
                        spacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(_draftStatusLabel(
                              item.status, copy.languageCode)),
                          IconButton(
                            tooltip: copy.t('helpEditCatalogItem'),
                            onPressed: () => onEditItem(item),
                            icon: const Icon(Icons.edit_outlined),
                          ),
                          IconButton(
                            tooltip: copy.t('helpDeleteCatalogItem'),
                            onPressed: () => onDeleteItem(item),
                            icon: const Icon(Icons.delete_outline),
                          ),
                        ],
                      ),
                      onTap: () => onEditItem(item),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

final class _AnalysisWorkspace extends StatelessWidget {
  const _AnalysisWorkspace({
    required this.copy,
    required this.chapters,
    required this.scenes,
    required this.catalogItems,
    required this.relationships,
    required this.onOpenScene,
  });

  final WritelerCopy copy;
  final List<Chapter> chapters;
  final List<Scene> scenes;
  final List<CatalogItem> catalogItems;
  final List<Relationship> relationships;
  final ValueChanged<Scene> onOpenScene;

  @override
  Widget build(BuildContext context) {
    final orderedChapters = [...chapters]
      ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
    final planningGapScenes = scenes
        .where((scene) =>
            scene.goal?.trim().isEmpty != false ||
            scene.conflict?.trim().isEmpty != false ||
            scene.outcome?.trim().isEmpty != false)
        .toList();
    final povMissingScenes = scenes
        .where((scene) => scene.povCharacterId?.trim().isEmpty != false)
        .toList();
    final dateMissingScenes =
        scenes.where((scene) => scene.storyDateStart == null).toList();
    final detachedCatalogItems = catalogItems
        .where((item) => _linkedScenesForItem(item).isEmpty)
        .toList();
    final chapterRows = _chapterRows(orderedChapters);
    final presenceRows = _presenceRows();

    return Column(
      children: [
        _WorkspaceHeader(title: copy.t('storyAnalysis')),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _StructureChip(
                icon: Icons.rule_outlined,
                label: copy.t('openPlanningGaps'),
                value: '${planningGapScenes.length}',
              ),
              _StructureChip(
                icon: Icons.visibility_off_outlined,
                label: copy.t('scenesWithoutPov'),
                value: '${povMissingScenes.length}',
              ),
              _StructureChip(
                icon: Icons.event_busy_outlined,
                label: copy.t('scenesWithoutDate'),
                value: '${dateMissingScenes.length}',
              ),
              _StructureChip(
                icon: Icons.link_off_outlined,
                label: copy.t('detachedCatalogItems'),
                value: '${detachedCatalogItems.length}',
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: Row(
            children: [
              SizedBox(
                width: 340,
                child: _AnalysisPanel(
                  title: copy.t('storylineHealth'),
                  child: _StorylineIssueList(
                    copy: copy,
                    planningGapScenes: planningGapScenes,
                    povMissingScenes: povMissingScenes,
                    dateMissingScenes: dateMissingScenes,
                    detachedCatalogItems: detachedCatalogItems,
                    onOpenScene: onOpenScene,
                  ),
                ),
              ),
              const VerticalDivider(width: 1),
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      flex: 3,
                      child: _AnalysisPanel(
                        title: copy.t('chapterBalance'),
                        child: _ChapterBalanceList(
                          copy: copy,
                          rows: chapterRows,
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                    SizedBox(
                      height: 170,
                      child: _AnalysisPanel(
                        title: copy.t('statusSpread'),
                        child: _StatusSpreadList(copy: copy, scenes: scenes),
                      ),
                    ),
                  ],
                ),
              ),
              const VerticalDivider(width: 1),
              SizedBox(
                width: 380,
                child: _AnalysisPanel(
                  title: copy.t('catalogPresence'),
                  child: _CatalogPresenceList(
                    copy: copy,
                    rows: presenceRows,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<_ChapterAnalysisRow> _chapterRows(List<Chapter> orderedChapters) {
    final rows = <_ChapterAnalysisRow>[
      for (final chapter in orderedChapters)
        _ChapterAnalysisRow(
          title: chapter.title,
          scenes: _scenesForChapter(chapter.id),
        ),
    ];
    final unassigned = _scenesForChapter(null);
    if (unassigned.isNotEmpty || rows.isEmpty) {
      rows.add(
          _ChapterAnalysisRow(title: copy.t('noChapter'), scenes: unassigned));
    }
    return rows;
  }

  List<Scene> _scenesForChapter(String? chapterId) {
    final filtered =
        scenes.where((scene) => scene.chapterId == chapterId).toList();
    filtered.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
    return filtered;
  }

  List<_CatalogPresenceRow> _presenceRows() {
    final rows = [
      for (final item in catalogItems)
        _CatalogPresenceRow(
          item: item,
          scenes: _linkedScenesForItem(item),
        ),
    ];
    rows.sort((a, b) {
      final typeCompare = a.item.type.index.compareTo(b.item.type.index);
      if (typeCompare != 0) return typeCompare;
      return a.item.name.compareTo(b.item.name);
    });
    return rows;
  }

  List<Scene> _linkedScenesForItem(CatalogItem item) {
    final sceneIds = relationships
        .where((relationship) =>
            _relationshipConnects(relationship, EntityType.scene, item.type) &&
            (relationship.source.id == item.id ||
                relationship.target.id == item.id))
        .map((relationship) => relationship.source.type == EntityType.scene
            ? relationship.source.id
            : relationship.target.id)
        .toSet();
    final linked =
        scenes.where((scene) => sceneIds.contains(scene.id)).toList();
    linked.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
    return linked;
  }

  bool _relationshipConnects(
    Relationship relationship,
    EntityType left,
    EntityType right,
  ) {
    return (relationship.source.type == left &&
            relationship.target.type == right) ||
        (relationship.source.type == right && relationship.target.type == left);
  }
}

typedef _SaveNoteCallback = Future<ProjectNote?> Function({
  ProjectNote? existing,
  required String title,
  required String body,
  required EntityRef? target,
});

enum _NoteFilter { all, project, scene, catalog, manual, ai }

final class _NotesCockpit extends StatefulWidget {
  const _NotesCockpit({
    required this.copy,
    required this.project,
    required this.notes,
    required this.scenes,
    required this.catalogItems,
    required this.onSaveNote,
    required this.onDeleteNote,
    required this.onOpenScene,
  });

  final WritelerCopy copy;
  final Project? project;
  final List<ProjectNote> notes;
  final List<Scene> scenes;
  final List<CatalogItem> catalogItems;
  final _SaveNoteCallback onSaveNote;
  final ValueChanged<ProjectNote> onDeleteNote;
  final ValueChanged<Scene> onOpenScene;

  @override
  State<_NotesCockpit> createState() => _NotesCockpitState();
}

final class _NotesCockpitState extends State<_NotesCockpit> {
  late final TextEditingController _searchController = TextEditingController();
  late final TextEditingController _titleController = TextEditingController();
  late final TextEditingController _bodyController = TextEditingController();
  _NoteFilter _filter = _NoteFilter.all;
  String _targetValue = 'project';
  String? _selectedNoteId;
  bool _draftingNew = false;

  @override
  void initState() {
    super.initState();
    _selectInitialNote();
  }

  @override
  void didUpdateWidget(covariant _NotesCockpit oldWidget) {
    super.didUpdateWidget(oldWidget);
    final selectedExists =
        widget.notes.any((note) => note.id == _selectedNoteId);
    if (!_draftingNew && !selectedExists) {
      _selectInitialNote();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  ProjectNote? get _selectedNote => _draftingNew
      ? null
      : widget.notes.where((note) => note.id == _selectedNoteId).firstOrNull;

  void _selectInitialNote() {
    final note = widget.notes.firstOrNull;
    _loadNote(note);
  }

  void _startNewNote() {
    setState(() {
      _draftingNew = true;
      _selectedNoteId = null;
      _titleController.clear();
      _bodyController.clear();
      _targetValue = 'project';
    });
  }

  void _loadNote(ProjectNote? note) {
    _draftingNew = note == null;
    _selectedNoteId = note?.id;
    _titleController.text = note?.title ?? '';
    _bodyController.text = note?.body ?? '';
    _targetValue = _targetValueFor(note?.target);
  }

  Future<void> _saveCurrentNote() async {
    final saved = await widget.onSaveNote(
      existing: _selectedNote,
      title: _titleController.text,
      body: _bodyController.text,
      target: _targetFromValue(_targetValue),
    );
    if (saved == null || !mounted) return;
    setState(() {
      _draftingNew = false;
      _selectedNoteId = saved.id;
      _titleController.text = saved.title;
      _bodyController.text = saved.body;
      _targetValue = _targetValueFor(saved.target);
    });
  }

  void _deleteCurrentNote() {
    final note = _selectedNote;
    if (note == null) return;
    widget.onDeleteNote(note);
    setState(() {
      _selectedNoteId = null;
      _draftingNew = false;
      _titleController.clear();
      _bodyController.clear();
      _targetValue = 'project';
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredNotes = _filteredNotes();
    final selectedNote = _selectedNote;

    return Column(
      children: [
        _WorkspaceHeader(
          title: widget.copy.t('notesCockpit'),
          actionLabel: widget.copy.t('newNote'),
          actionIcon: Icons.add,
          actionHelp: widget.copy.t('helpNewNote'),
          onAction: _startNewNote,
        ),
        const Divider(height: 1),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final list = _NotesListPane(
                copy: widget.copy,
                notes: filteredNotes,
                selectedNoteId: _selectedNoteId,
                searchController: _searchController,
                filter: _filter,
                scenes: widget.scenes,
                catalogItems: widget.catalogItems,
                onFilterChanged: (filter) => setState(() => _filter = filter),
                onSearchChanged: (_) => setState(() {}),
                onSelectNote: (note) => setState(() => _loadNote(note)),
              );
              final editor = _NoteEditorPane(
                copy: widget.copy,
                project: widget.project,
                note: selectedNote,
                titleController: _titleController,
                bodyController: _bodyController,
                targetValue: _targetValue,
                targetOptions: _targetOptions(),
                draftingNew: _draftingNew,
                onTargetChanged: (value) =>
                    setState(() => _targetValue = value ?? 'project'),
                onSave: _saveCurrentNote,
                onDelete: selectedNote == null ? null : _deleteCurrentNote,
                onOpenScene:
                    _sceneForTarget(_targetFromValue(_targetValue)) == null
                        ? null
                        : () => widget.onOpenScene(
                            _sceneForTarget(_targetFromValue(_targetValue))!),
              );

              if (constraints.maxWidth < 980) {
                return Column(
                  children: [
                    SizedBox(height: 280, child: list),
                    const Divider(height: 1),
                    Expanded(child: editor),
                  ],
                );
              }
              return Row(
                children: [
                  SizedBox(width: 380, child: list),
                  const VerticalDivider(width: 1),
                  Expanded(child: editor),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  List<ProjectNote> _filteredNotes() {
    final query = _searchController.text.trim().toLowerCase();
    return widget.notes.where((note) {
      final matchesFilter = switch (_filter) {
        _NoteFilter.all => true,
        _NoteFilter.project => note.target == null,
        _NoteFilter.scene => note.target?.type == EntityType.scene,
        _NoteFilter.catalog => note.target?.type == EntityType.character ||
            note.target?.type == EntityType.location ||
            note.target?.type == EntityType.object,
        _NoteFilter.manual => note.source == 'manual',
        _NoteFilter.ai => note.source == 'aiSuggestion',
      };
      if (!matchesFilter) return false;
      if (query.isEmpty) return true;
      final targetLabel =
          _noteTargetDisplay(note.target, widget.scenes, widget.catalogItems);
      return note.title.toLowerCase().contains(query) ||
          note.body.toLowerCase().contains(query) ||
          targetLabel.toLowerCase().contains(query);
    }).toList();
  }

  List<DropdownMenuItem<String>> _targetOptions() {
    return [
      DropdownMenuItem(
        value: 'project',
        child: Text(widget.copy.t('targetProject')),
      ),
      for (final scene in widget.scenes)
        DropdownMenuItem(
          value:
              _targetValueFor(EntityRef(type: EntityType.scene, id: scene.id)),
          child: Text('${widget.copy.t('scene')}: ${scene.title}'),
        ),
      for (final item in widget.catalogItems)
        DropdownMenuItem(
          value: _targetValueFor(EntityRef(type: item.type, id: item.id)),
          child:
              Text('${_entityTypeLabel(item.type, widget.copy)}: ${item.name}'),
        ),
    ];
  }

  Scene? _sceneForTarget(EntityRef? target) {
    if (target?.type != EntityType.scene) return null;
    return widget.scenes.where((scene) => scene.id == target!.id).firstOrNull;
  }
}

final class _NotesListPane extends StatelessWidget {
  const _NotesListPane({
    required this.copy,
    required this.notes,
    required this.selectedNoteId,
    required this.searchController,
    required this.filter,
    required this.scenes,
    required this.catalogItems,
    required this.onFilterChanged,
    required this.onSearchChanged,
    required this.onSelectNote,
  });

  final WritelerCopy copy;
  final List<ProjectNote> notes;
  final String? selectedNoteId;
  final TextEditingController searchController;
  final _NoteFilter filter;
  final List<Scene> scenes;
  final List<CatalogItem> catalogItems;
  final ValueChanged<_NoteFilter> onFilterChanged;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<ProjectNote> onSelectNote;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: searchController,
            onChanged: onSearchChanged,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              labelText: copy.t('searchNotes'),
              border: const OutlineInputBorder(),
              isDense: true,
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SegmentedButton<_NoteFilter>(
              showSelectedIcon: false,
              selected: {filter},
              onSelectionChanged: (selection) =>
                  onFilterChanged(selection.first),
              segments: [
                for (final option in _NoteFilter.values)
                  ButtonSegment(
                    value: option,
                    icon: Icon(_noteFilterIcon(option), size: 18),
                    label: Text(_noteFilterLabel(option, copy)),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: notes.isEmpty
                ? _EmptyInlineMessage(message: copy.t('noNotesForFilter'))
                : ListView.separated(
                    itemCount: notes.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final note = notes[index];
                      final selected = note.id == selectedNoteId;
                      return ListTile(
                        selected: selected,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        leading: Icon(
                          note.source == 'aiSuggestion'
                              ? Icons.psychology_alt_outlined
                              : Icons.sticky_note_2_outlined,
                          color: selected ? color.primary : null,
                        ),
                        title: Text(
                          note.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          '${_noteTargetDisplay(note.target, scenes, catalogItems)}\n'
                          '${note.body}',
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () => onSelectNote(note),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

final class _NoteEditorPane extends StatelessWidget {
  const _NoteEditorPane({
    required this.copy,
    required this.project,
    required this.note,
    required this.titleController,
    required this.bodyController,
    required this.targetValue,
    required this.targetOptions,
    required this.draftingNew,
    required this.onTargetChanged,
    required this.onSave,
    required this.onDelete,
    required this.onOpenScene,
  });

  final WritelerCopy copy;
  final Project? project;
  final ProjectNote? note;
  final TextEditingController titleController;
  final TextEditingController bodyController;
  final String targetValue;
  final List<DropdownMenuItem<String>> targetOptions;
  final bool draftingNew;
  final ValueChanged<String?> onTargetChanged;
  final VoidCallback onSave;
  final VoidCallback? onDelete;
  final VoidCallback? onOpenScene;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final hasEditableSurface = project != null && (note != null || draftingNew);
    if (!hasEditableSurface) {
      return _EmptyPanel(
        icon: Icons.sticky_note_2_outlined,
        title: copy.t('noNoteSelectedTitle'),
        body: copy.t('noNoteSelectedBody'),
      );
    }

    final sourceText = note == null
        ? copy.t('manualNote')
        : note!.source == 'aiSuggestion'
            ? copy.t('aiNote')
            : copy.t('manualNote');

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  draftingNew ? copy.t('newNote') : copy.t('editNote'),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              Text(
                sourceText,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: color.onSurfaceVariant,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          TextField(
            controller: titleController,
            decoration: InputDecoration(
              labelText: copy.t('noteTitle'),
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            initialValue: targetOptions.any((item) => item.value == targetValue)
                ? targetValue
                : 'project',
            icon: const Icon(Icons.keyboard_arrow_down_rounded),
            items: targetOptions,
            onChanged: onTargetChanged,
            decoration: InputDecoration(
              labelText: copy.t('noteTarget'),
              border: const OutlineInputBorder(),
            ),
          ),
          if (onOpenScene != null) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: _ActionHelp(
                message: copy.t('helpOpenLinkedScene'),
                child: TextButton.icon(
                  onPressed: onOpenScene,
                  icon: const Icon(Icons.open_in_new),
                  label: Text(copy.t('openLinkedScene')),
                ),
              ),
            ),
          ],
          const SizedBox(height: 14),
          Expanded(
            child: TextField(
              controller: bodyController,
              expands: true,
              maxLines: null,
              minLines: null,
              textAlignVertical: TextAlignVertical.top,
              decoration: InputDecoration(
                labelText: copy.t('noteBody'),
                alignLabelWithHint: true,
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _ActionHelp(
                message: copy.t('helpSaveNote'),
                child: FilledButton.icon(
                  onPressed: onSave,
                  icon: const Icon(Icons.save_outlined),
                  label: Text(copy.t('saveNote')),
                ),
              ),
              const SizedBox(width: 12),
              if (onDelete != null)
                _ActionHelp(
                  message: copy.t('helpDeleteNote'),
                  child: OutlinedButton.icon(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline),
                    label: Text(copy.t('delete')),
                  ),
                ),
              const Spacer(),
              if (note != null)
                Text(
                  _formatLocalDateTime(note!.updatedAt),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: color.onSurfaceVariant,
                      ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

final class _AnalysisPanel extends StatelessWidget {
  const _AnalysisPanel({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 12),
          Expanded(child: child),
        ],
      ),
    );
  }
}

final class _StorylineIssueList extends StatelessWidget {
  const _StorylineIssueList({
    required this.copy,
    required this.planningGapScenes,
    required this.povMissingScenes,
    required this.dateMissingScenes,
    required this.detachedCatalogItems,
    required this.onOpenScene,
  });

  final WritelerCopy copy;
  final List<Scene> planningGapScenes;
  final List<Scene> povMissingScenes;
  final List<Scene> dateMissingScenes;
  final List<CatalogItem> detachedCatalogItems;
  final ValueChanged<Scene> onOpenScene;

  @override
  Widget build(BuildContext context) {
    final issues = <_AnalysisIssue>[
      for (final scene in planningGapScenes)
        _AnalysisIssue(
          icon: Icons.rule_outlined,
          title: scene.title,
          subtitle: copy.t('missingStructure'),
          scene: scene,
        ),
      for (final scene in povMissingScenes)
        _AnalysisIssue(
          icon: Icons.visibility_off_outlined,
          title: scene.title,
          subtitle: copy.t('scenesWithoutPov'),
          scene: scene,
        ),
      for (final scene in dateMissingScenes)
        _AnalysisIssue(
          icon: Icons.event_busy_outlined,
          title: scene.title,
          subtitle: copy.t('scenesWithoutDate'),
          scene: scene,
        ),
      for (final item in detachedCatalogItems)
        _AnalysisIssue(
          icon: _catalogIcon(item.type),
          title: item.name,
          subtitle: copy.t('noAppearances'),
        ),
    ];

    if (issues.isEmpty) {
      return _EmptyInlineMessage(message: copy.t('noAnalysisIssues'));
    }

    return ListView.separated(
      itemCount: issues.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final issue = issues[index];
        return ListTile(
          leading: Icon(issue.icon),
          title: Text(
            issue.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(issue.subtitle),
          onTap: issue.scene == null ? null : () => onOpenScene(issue.scene!),
        );
      },
    );
  }
}

final class _ChapterBalanceList extends StatelessWidget {
  const _ChapterBalanceList({
    required this.copy,
    required this.rows,
  });

  final WritelerCopy copy;
  final List<_ChapterAnalysisRow> rows;

  @override
  Widget build(BuildContext context) {
    if (rows.every((row) => row.scenes.isEmpty)) {
      return _EmptyInlineMessage(message: copy.t('noScenesBody'));
    }

    final maxWords = rows.fold<int>(
      1,
      (max, row) => row.words > max ? row.words : max,
    );

    return ListView.separated(
      itemCount: rows.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final row = rows[index];
        final progress = row.words / maxWords;
        return _ChapterBalanceTile(
          copy: copy,
          row: row,
          progress: progress,
        );
      },
    );
  }
}

final class _ChapterBalanceTile extends StatelessWidget {
  const _ChapterBalanceTile({
    required this.copy,
    required this.row,
    required this.progress,
  });

  final WritelerCopy copy;
  final _ChapterAnalysisRow row;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  row.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              Text('${row.scenes.length} ${copy.t('scenes')}'),
              const SizedBox(width: 12),
              Text('${row.words} ${copy.t('words')}'),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(value: progress.clamp(0.0, 1.0)),
        ],
      ),
    );
  }
}

final class _StatusSpreadList extends StatelessWidget {
  const _StatusSpreadList({
    required this.copy,
    required this.scenes,
  });

  final WritelerCopy copy;
  final List<Scene> scenes;

  @override
  Widget build(BuildContext context) {
    final total = scenes.isEmpty ? 1 : scenes.length;
    return ListView(
      scrollDirection: Axis.horizontal,
      children: [
        for (final status in DraftStatus.values)
          SizedBox(
            width: 160,
            child: Padding(
              padding: const EdgeInsets.only(right: 14),
              child: _StatusSpreadTile(
                label: _draftStatusLabel(status, copy.languageCode),
                count: scenes.where((scene) => scene.status == status).length,
                total: total,
              ),
            ),
          ),
      ],
    );
  }
}

final class _StatusSpreadTile extends StatelessWidget {
  const _StatusSpreadTile({
    required this.label,
    required this.count,
    required this.total,
  });

  final String label;
  final int count;
  final int total;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: color.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 10),
            Text(
              '$count',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: count / total),
          ],
        ),
      ),
    );
  }
}

final class _CatalogPresenceList extends StatelessWidget {
  const _CatalogPresenceList({
    required this.copy,
    required this.rows,
  });

  final WritelerCopy copy;
  final List<_CatalogPresenceRow> rows;

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) {
      return _EmptyInlineMessage(message: copy.t('catalogEmptyBody'));
    }

    return ListView.separated(
      itemCount: rows.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final row = rows[index];
        final scenePreview = row.scenes.take(3).map((scene) => scene.title);
        return ListTile(
          leading: Icon(_catalogIcon(row.item.type)),
          title:
              Text(row.item.name, maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Text(
            row.scenes.isEmpty
                ? copy.t('noAppearances')
                : scenePreview.join(', '),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Text('${row.scenes.length}'),
        );
      },
    );
  }
}

final class _EmptyInlineMessage extends StatelessWidget {
  const _EmptyInlineMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Text(
        message,
        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
    );
  }
}

final class _AnalysisIssue {
  const _AnalysisIssue({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.scene,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Scene? scene;
}

final class _ChapterAnalysisRow {
  const _ChapterAnalysisRow({
    required this.title,
    required this.scenes,
  });

  final String title;
  final List<Scene> scenes;

  int get words =>
      scenes.fold<int>(0, (sum, scene) => sum + scene.actualWordCount);
}

final class _CatalogPresenceRow {
  const _CatalogPresenceRow({
    required this.item,
    required this.scenes,
  });

  final CatalogItem item;
  final List<Scene> scenes;
}
