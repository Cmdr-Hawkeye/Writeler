part of '../main.dart';

// Dynamic saved project views for scenes, suggestions, chapters, POV and notes.

const _defaultSmartCollectionIds = {
  'openAiSuggestions',
  'scenesWithoutText',
  'chaptersLowConflict',
  'notesWithoutTarget',
};

final class _SmartCollectionsWorkspace extends StatefulWidget {
  const _SmartCollectionsWorkspace({
    required this.copy,
    required this.project,
    required this.chapters,
    required this.scenes,
    required this.catalogItems,
    required this.suggestions,
    required this.notes,
    required this.onSaveCollections,
    required this.onOpenScene,
    required this.onOpenAiWorkshop,
    required this.onOpenNotes,
    required this.onOpenStructure,
  });

  final WritellerCopy copy;
  final Project? project;
  final List<Chapter> chapters;
  final List<Scene> scenes;
  final List<CatalogItem> catalogItems;
  final List<AISuggestion> suggestions;
  final List<ProjectNote> notes;
  final Future<void> Function(Set<String> collectionIds) onSaveCollections;
  final ValueChanged<Scene> onOpenScene;
  final VoidCallback onOpenAiWorkshop;
  final VoidCallback onOpenNotes;
  final VoidCallback onOpenStructure;

  @override
  State<_SmartCollectionsWorkspace> createState() =>
      _SmartCollectionsWorkspaceState();
}

final class _SmartCollectionsWorkspaceState
    extends State<_SmartCollectionsWorkspace> {
  String? _selectedId;

  @override
  void didUpdateWidget(covariant _SmartCollectionsWorkspace oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.project?.id != widget.project?.id) {
      _selectedId = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final project = widget.project;
    if (project == null) return _EmptyWorkspace(copy: widget.copy);

    final savedIds = _savedCollectionIds(project);
    final collections = _buildCollections(savedIds);
    final savedCollections = collections
        .where((collection) => savedIds.contains(collection.id))
        .toList(growable: false);
    final suggestedCollections = collections
        .where((collection) => !savedIds.contains(collection.id))
        .toList(growable: false);
    final selected = savedCollections
            .where((collection) => collection.id == _selectedId)
            .firstOrNull ??
        savedCollections.firstOrNull;

    if (_selectedId == null && selected != null) {
      _selectedId = selected.id;
    }

    return Column(
      children: [
        _WorkspaceHeader(title: widget.copy.t('smartCollections')),
        const Divider(height: 1),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 860;
              final list = _SmartCollectionList(
                copy: widget.copy,
                savedCollections: savedCollections,
                suggestedCollections: suggestedCollections,
                selectedId: selected?.id,
                onSelect: (collection) =>
                    setState(() => _selectedId = collection.id),
                onSave: _saveCollection,
                onRemove: _removeCollection,
              );
              final detail = _SmartCollectionDetail(
                copy: widget.copy,
                collection: selected,
                onOpenScene: widget.onOpenScene,
                onOpenAiWorkshop: widget.onOpenAiWorkshop,
                onOpenNotes: widget.onOpenNotes,
                onOpenStructure: widget.onOpenStructure,
              );
              if (compact) {
                return Column(
                  children: [
                    SizedBox(height: 270, child: list),
                    const Divider(height: 1),
                    Expanded(child: detail),
                  ],
                );
              }
              return Row(
                children: [
                  SizedBox(width: 360, child: list),
                  const VerticalDivider(width: 1),
                  Expanded(child: detail),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Set<String> _savedCollectionIds(Project project) {
    final raw = project.metadata['smartCollections'];
    if (raw is List) {
      final saved = raw.whereType<String>().toSet();
      if (saved.isNotEmpty) return saved;
    }
    return _defaultSmartCollectionIds.toSet();
  }

  List<_SmartCollection> _buildCollections(Set<String> savedIds) {
    final staticCollections = [
      _openAiSuggestionsCollection(),
      _scenesWithoutTextCollection(),
      _chaptersLowConflictCollection(),
      _notesWithoutTargetCollection(),
    ];
    final povCollections = [
      for (final character in widget.catalogItems
          .where((item) => item.type == EntityType.character))
        _povCharacterCollection(character),
    ];
    return [...staticCollections, ...povCollections];
  }

  _SmartCollection _openAiSuggestionsCollection() {
    final pending = widget.suggestions
        .where((suggestion) =>
            suggestion.userDecision == SuggestionDecision.pending)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return _SmartCollection(
      id: 'openAiSuggestions',
      title: widget.copy.t('collectionOpenAiSuggestions'),
      subtitle: widget.copy.t('collectionOpenAiSuggestionsBody'),
      icon: Icons.psychology_alt_outlined,
      kind: _SmartCollectionKind.aiSuggestions,
      items: [
        for (final suggestion in pending)
          _SmartCollectionItem(
            title: _suggestionTitle(suggestion),
            subtitle: _compactText(suggestion.responseText),
            badge: widget.copy.t('suggestionPending'),
            icon: Icons.auto_awesome_outlined,
            payload: suggestion,
          ),
      ],
    );
  }

  _SmartCollection _scenesWithoutTextCollection() {
    final scenes = widget.scenes
        .where((scene) => scene.manuscriptText.trim().isEmpty)
        .toList()
      ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
    return _SmartCollection(
      id: 'scenesWithoutText',
      title: widget.copy.t('collectionScenesWithoutText'),
      subtitle: widget.copy.t('collectionScenesWithoutTextBody'),
      icon: Icons.subject_outlined,
      kind: _SmartCollectionKind.scenes,
      items: [
        for (final scene in scenes)
          _SmartCollectionItem(
            title: scene.title,
            subtitle: _sceneSubtitle(scene),
            badge: _draftStatusLabel(scene.status, widget.copy.languageCode),
            icon: Icons.notes_outlined,
            payload: scene,
          ),
      ],
    );
  }

  _SmartCollection _povCharacterCollection(CatalogItem character) {
    final scenes = widget.scenes
        .where((scene) => scene.povCharacterId == character.id)
        .toList()
      ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
    return _SmartCollection(
      id: 'pov:${character.id}',
      title: '${widget.copy.t('collectionPovPrefix')} ${character.name}',
      subtitle: widget.copy.t('collectionPovBody'),
      icon: Icons.visibility_outlined,
      kind: _SmartCollectionKind.scenes,
      items: [
        for (final scene in scenes)
          _SmartCollectionItem(
            title: scene.title,
            subtitle: _sceneSubtitle(scene),
            badge: '${scene.actualWordCount} ${widget.copy.t('words')}',
            icon: Icons.visibility_outlined,
            payload: scene,
          ),
      ],
    );
  }

  _SmartCollection _chaptersLowConflictCollection() {
    final rows = <_SmartCollectionItem>[];
    for (final chapter in widget.chapters) {
      final chapterScenes = widget.scenes
          .where((scene) => scene.chapterId == chapter.id)
          .toList();
      if (chapterScenes.isEmpty) continue;
      final weakConflictScenes = chapterScenes
          .where((scene) => (scene.conflict ?? '').trim().length < 24)
          .toList();
      final weakRatio = weakConflictScenes.length / chapterScenes.length;
      if (weakConflictScenes.isEmpty && weakRatio < 0.5) continue;
      rows.add(
        _SmartCollectionItem(
          title: chapter.title,
          subtitle:
              '${weakConflictScenes.length}/${chapterScenes.length} ${widget.copy.t('collectionWeakConflictScenes')}',
          badge: '${(weakRatio * 100).round()}%',
          icon: Icons.bolt_outlined,
          payload: chapter,
        ),
      );
    }
    rows.sort((a, b) => b.badge.compareTo(a.badge));
    return _SmartCollection(
      id: 'chaptersLowConflict',
      title: widget.copy.t('collectionChaptersLowConflict'),
      subtitle: widget.copy.t('collectionChaptersLowConflictBody'),
      icon: Icons.bolt_outlined,
      kind: _SmartCollectionKind.chapters,
      items: rows,
    );
  }

  _SmartCollection _notesWithoutTargetCollection() {
    final notes = widget.notes.where((note) => note.target == null).toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return _SmartCollection(
      id: 'notesWithoutTarget',
      title: widget.copy.t('collectionNotesWithoutTarget'),
      subtitle: widget.copy.t('collectionNotesWithoutTargetBody'),
      icon: Icons.sticky_note_2_outlined,
      kind: _SmartCollectionKind.notes,
      items: [
        for (final note in notes)
          _SmartCollectionItem(
            title: note.title,
            subtitle: _compactText(note.body),
            badge: note.source == 'aiSuggestion'
                ? widget.copy.t('aiNote')
                : widget.copy.t('manualNote'),
            icon: Icons.sticky_note_2_outlined,
            payload: note,
          ),
      ],
    );
  }

  Future<void> _saveCollection(_SmartCollection collection) async {
    final project = widget.project;
    if (project == null) return;
    final ids = _savedCollectionIds(project)..add(collection.id);
    await widget.onSaveCollections(ids);
    if (!mounted) return;
    setState(() => _selectedId = collection.id);
  }

  Future<void> _removeCollection(_SmartCollection collection) async {
    final project = widget.project;
    if (project == null) return;
    final ids = _savedCollectionIds(project)..remove(collection.id);
    await widget.onSaveCollections(ids);
    if (!mounted) return;
    setState(() {
      if (_selectedId == collection.id) _selectedId = null;
    });
  }

  String _sceneSubtitle(Scene scene) {
    final chapter = widget.chapters
        .where((chapter) => chapter.id == scene.chapterId)
        .firstOrNull;
    final pieces = [
      chapter?.title ?? widget.copy.t('noChapter'),
      if ((scene.goal ?? '').trim().isEmpty) widget.copy.t('goal'),
      if ((scene.conflict ?? '').trim().isEmpty) widget.copy.t('conflict'),
      if ((scene.outcome ?? '').trim().isEmpty) widget.copy.t('outcome'),
    ];
    return pieces.join(' · ');
  }

  String _suggestionTitle(AISuggestion suggestion) {
    final scene = suggestion.target.type == EntityType.scene
        ? widget.scenes
            .where((scene) => scene.id == suggestion.target.id)
            .firstOrNull
        : null;
    if (scene != null) return scene.title;
    return suggestion.suggestionType;
  }
}

final class _SmartCollectionList extends StatelessWidget {
  const _SmartCollectionList({
    required this.copy,
    required this.savedCollections,
    required this.suggestedCollections,
    required this.selectedId,
    required this.onSelect,
    required this.onSave,
    required this.onRemove,
  });

  final WritellerCopy copy;
  final List<_SmartCollection> savedCollections;
  final List<_SmartCollection> suggestedCollections;
  final String? selectedId;
  final ValueChanged<_SmartCollection> onSelect;
  final ValueChanged<_SmartCollection> onSave;
  final ValueChanged<_SmartCollection> onRemove;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          copy.t('savedCollections'),
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        if (savedCollections.isEmpty)
          _EmptyInlineMessage(message: copy.t('noSavedCollections'))
        else
          for (final collection in savedCollections)
            _SmartCollectionTile(
              copy: copy,
              collection: collection,
              selected: collection.id == selectedId,
              trailing: IconButton(
                tooltip: copy.t('hideCollection'),
                onPressed: () => onRemove(collection),
                icon: const Icon(Icons.visibility_off_outlined),
              ),
              onTap: () => onSelect(collection),
            ),
        if (suggestedCollections.isNotEmpty) ...[
          const SizedBox(height: 18),
          Divider(color: color.outlineVariant),
          const SizedBox(height: 10),
          Text(
            copy.t('suggestedCollections'),
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          for (final collection in suggestedCollections)
            _SmartCollectionTile(
              copy: copy,
              collection: collection,
              selected: false,
              trailing: IconButton(
                tooltip: copy.t('saveCollection'),
                onPressed: () => onSave(collection),
                icon: const Icon(Icons.add_circle_outline),
              ),
              onTap: () => onSave(collection),
            ),
        ],
      ],
    );
  }
}

final class _SmartCollectionTile extends StatelessWidget {
  const _SmartCollectionTile({
    required this.copy,
    required this.collection,
    required this.selected,
    required this.trailing,
    required this.onTap,
  });

  final WritellerCopy copy;
  final _SmartCollection collection;
  final bool selected;
  final Widget trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: selected ? color.primaryContainer : color.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
        child: ListTile(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          leading: Icon(
            collection.icon,
            color: selected ? color.onPrimaryContainer : color.primary,
          ),
          title: Text(
            collection.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            collection.subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Chip(
                label: Text('${collection.items.length}'),
                visualDensity: VisualDensity.compact,
              ),
              trailing,
            ],
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}

final class _SmartCollectionDetail extends StatelessWidget {
  const _SmartCollectionDetail({
    required this.copy,
    required this.collection,
    required this.onOpenScene,
    required this.onOpenAiWorkshop,
    required this.onOpenNotes,
    required this.onOpenStructure,
  });

  final WritellerCopy copy;
  final _SmartCollection? collection;
  final ValueChanged<Scene> onOpenScene;
  final VoidCallback onOpenAiWorkshop;
  final VoidCallback onOpenNotes;
  final VoidCallback onOpenStructure;

  @override
  Widget build(BuildContext context) {
    final collection = this.collection;
    if (collection == null) {
      return _EmptyPanel(
        icon: Icons.collections_bookmark_outlined,
        title: copy.t('noSavedCollections'),
        body: copy.t('noSavedCollectionsBody'),
      );
    }
    final color = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 16),
          decoration: BoxDecoration(
            color: color.surface,
            border: Border(bottom: BorderSide(color: color.outlineVariant)),
          ),
          child: Row(
            children: [
              Icon(collection.icon, color: color.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      collection.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      collection.subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: color.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              Chip(label: Text('${collection.items.length}')),
            ],
          ),
        ),
        Expanded(
          child: collection.items.isEmpty
              ? _EmptyPanel(
                  icon: Icons.check_circle_outline,
                  title: copy.t('collectionEmptyTitle'),
                  body: copy.t('collectionEmptyBody'),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(18),
                  itemCount: collection.items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final item = collection.items[index];
                    return _SmartCollectionResultTile(
                      copy: copy,
                      item: item,
                      onTap: () => _openItem(collection.kind, item),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _openItem(_SmartCollectionKind kind, _SmartCollectionItem item) {
    switch (kind) {
      case _SmartCollectionKind.scenes:
        final scene = item.payload;
        if (scene is Scene) onOpenScene(scene);
      case _SmartCollectionKind.aiSuggestions:
        onOpenAiWorkshop();
      case _SmartCollectionKind.notes:
        onOpenNotes();
      case _SmartCollectionKind.chapters:
        onOpenStructure();
    }
  }
}

final class _SmartCollectionResultTile extends StatelessWidget {
  const _SmartCollectionResultTile({
    required this.copy,
    required this.item,
    required this.onTap,
  });

  final WritellerCopy copy;
  final _SmartCollectionItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Material(
      color: color.surfaceContainerLow,
      borderRadius: BorderRadius.circular(8),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        leading: Icon(item.icon, color: color.primary),
        title: Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle:
            Text(item.subtitle, maxLines: 2, overflow: TextOverflow.ellipsis),
        trailing: Chip(
          label: Text(item.badge),
          visualDensity: VisualDensity.compact,
        ),
        onTap: onTap,
      ),
    );
  }
}

enum _SmartCollectionKind { scenes, aiSuggestions, notes, chapters }

final class _SmartCollection {
  const _SmartCollection({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.kind,
    required this.items,
  });

  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final _SmartCollectionKind kind;
  final List<_SmartCollectionItem> items;
}

final class _SmartCollectionItem {
  const _SmartCollectionItem({
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.icon,
    required this.payload,
  });

  final String title;
  final String subtitle;
  final String badge;
  final IconData icon;
  final Object payload;
}

String _compactText(String value) {
  final normalized = value.trim().replaceAll(RegExp(r'\s+'), ' ');
  if (normalized.isEmpty) return '';
  return normalized.length <= 130
      ? normalized
      : '${normalized.substring(0, 130)}...';
}
