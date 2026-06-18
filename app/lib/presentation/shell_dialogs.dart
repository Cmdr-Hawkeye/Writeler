part of '../main.dart';

// Dialog workflows used by the shell. Kept as an extension so the shell state
// remains private while dialog code stays out of the main orchestration file.

extension _WritelerShellDialogs on _WritelerShellState {
  Future<void> _showCreateProjectDialog(WritelerCopy copy) async {
    var draftTitle = '';
    final title = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(copy.t('newProject')),
          content: TextField(
            autofocus: true,
            decoration: InputDecoration(labelText: copy.t('projectTitle')),
            textInputAction: TextInputAction.done,
            onChanged: (value) => draftTitle = value,
            onSubmitted: (value) => Navigator.of(context).pop(value),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(copy.t('cancel')),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(draftTitle),
              child: Text(copy.t('create')),
            ),
          ],
        );
      },
    );

    final normalizedTitle = title?.trim();
    if (normalizedTitle == null) return;
    if (!mounted) return;

    final project = await _createProject(
      CreateProjectCommand(
        title: normalizedTitle.isEmpty
            ? copy.t('untitledProject')
            : normalizedTitle,
        languageCode: Localizations.localeOf(context).languageCode,
      ),
    );
    final projects = await widget.projectRepository.listActive();

    if (!mounted) return;
    _setShellState(() {
      _projects = projects;
      _selectedProject = project;
      _chapters = const [];
      _scenes = const [];
      _catalogItems = const [];
      _relationships = const [];
      _metrics = const [];
      _suggestions = const [];
      _notes = const [];
      _selectedScene = null;
      _syncSceneControllers(null);
    });
    await _recordMetric(
      projectId: project.id,
      eventType: 'project.created',
      metadata: {'title': project.title},
    );
    final metrics = await widget.metricRepository.listForProject(project.id);
    if (mounted) {
      _setShellState(() => _metrics = metrics);
    }
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(copy.t('projectCreated'))),
    );
  }

  Future<void> _showCreateSceneDialog(WritelerCopy copy) async {
    final project = _selectedProject;
    if (project == null) return;

    var draftTitle = '';
    final title = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(copy.t('newScene')),
          content: TextField(
            autofocus: true,
            decoration: InputDecoration(labelText: copy.t('sceneTitle')),
            textInputAction: TextInputAction.done,
            onChanged: (value) => draftTitle = value,
            onSubmitted: (value) => Navigator.of(context).pop(value),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(copy.t('cancel')),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(draftTitle),
              child: Text(copy.t('create')),
            ),
          ],
        );
      },
    );

    final normalizedTitle = title?.trim();
    if (normalizedTitle == null) return;

    final scene = await _createScene(
      CreateSceneCommand(
        projectId: project.id,
        title:
            normalizedTitle.isEmpty ? copy.t('untitledScene') : normalizedTitle,
        orderIndex: (_scenes.length + 1) * 1000,
      ),
    );
    final scenes = await widget.sceneRepository.listByProject(project.id);

    if (!mounted) return;
    _setShellState(() {
      _scenes = scenes;
      _selectedScene = scene;
      _syncSceneControllers(scene);
    });
    await _recordProjectMetric(
      eventType: 'scene.created',
      metadata: {'sceneId': scene.id, 'title': scene.title},
    );
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(copy.t('sceneCreated'))),
    );
  }

  Future<void> _showCreateChapterDialog(WritelerCopy copy) async {
    final project = _selectedProject;
    if (project == null) return;

    var draftTitle = '';
    var draftSummary = '';
    final created = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(copy.t('newChapter')),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  autofocus: true,
                  decoration:
                      InputDecoration(labelText: copy.t('chapterTitle')),
                  textInputAction: TextInputAction.next,
                  onChanged: (value) => draftTitle = value,
                ),
                const SizedBox(height: 12),
                TextField(
                  decoration: InputDecoration(labelText: copy.t('summary')),
                  maxLines: 3,
                  onChanged: (value) => draftSummary = value,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(copy.t('cancel')),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(copy.t('create')),
            ),
          ],
        );
      },
    );

    if (created != true) return;
    final title = draftTitle.trim();
    final chapter = await _createChapter(
      CreateChapterCommand(
        projectId: project.id,
        title: title.isEmpty ? copy.t('untitledChapter') : title,
        summary: draftSummary,
        orderIndex: (_chapters.length + 1) * 1000,
      ),
    );
    final chapters = await widget.chapterRepository.listByProject(project.id);
    if (!mounted) return;
    _setShellState(() {
      _chapters = chapters;
      _selectedSceneChapterId ??= chapter.id;
    });
    await _recordProjectMetric(
      eventType: 'chapter.created',
      metadata: {'chapterId': chapter.id, 'title': chapter.title},
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(copy.t('chapterCreated'))),
    );
  }

  Future<void> _showCreateCatalogItemDialog(
    WritelerCopy copy,
    EntityType type,
  ) async {
    final project = _selectedProject;
    if (project == null) return;

    var draftName = '';
    var draftSummary = '';
    final created = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(copy.t(_newCatalogKey(type))),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  autofocus: true,
                  decoration: InputDecoration(labelText: copy.t('name')),
                  textInputAction: TextInputAction.next,
                  onChanged: (value) => draftName = value,
                ),
                const SizedBox(height: 12),
                TextField(
                  decoration: InputDecoration(labelText: copy.t('summary')),
                  maxLines: 3,
                  onChanged: (value) => draftSummary = value,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(copy.t('cancel')),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(copy.t('create')),
            ),
          ],
        );
      },
    );

    if (created != true) return;
    final name = draftName.trim();
    await _createCatalogItem(
      CreateCatalogItemCommand(
        projectId: project.id,
        type: type,
        name: name.isEmpty ? copy.t(_untitledCatalogKey(type)) : name,
        summary: draftSummary,
      ),
    );
    final items = await widget.catalogItemRepository.listByProject(project.id);

    if (!mounted) return;
    _setShellState(() {
      _catalogItems = items;
    });
    await _recordProjectMetric(
      eventType: 'catalog.created',
      metadata: {'type': type.wireName},
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(copy.t('catalogItemCreated'))),
    );
  }

  Future<void> _showEditCatalogItemDialog(
    WritelerCopy copy,
    CatalogItem item,
  ) async {
    final project = _selectedProject;
    if (project == null) return;

    final nameController = TextEditingController(text: item.name);
    final summaryController = TextEditingController(text: item.summary);
    var draftStatus = item.status;
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(copy.t('editCatalogItem')),
          content: SizedBox(
            width: 460,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  autofocus: true,
                  decoration: InputDecoration(labelText: copy.t('name')),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<DraftStatus>(
                  initialValue: draftStatus,
                  decoration: InputDecoration(
                    labelText: copy.t('status'),
                    border: const OutlineInputBorder(),
                  ),
                  items: [
                    for (final status in DraftStatus.values)
                      DropdownMenuItem(
                        value: status,
                        child:
                            Text(_draftStatusLabel(status, copy.languageCode)),
                      ),
                  ],
                  onChanged: (status) {
                    if (status != null) draftStatus = status;
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: summaryController,
                  decoration: InputDecoration(labelText: copy.t('summary')),
                  maxLines: 5,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(copy.t('cancel')),
            ),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).pop(true),
              icon: const Icon(Icons.save_outlined),
              label: Text(copy.t('saveCatalogItem')),
            ),
          ],
        );
      },
    );

    if (saved != true) {
      nameController.dispose();
      summaryController.dispose();
      return;
    }

    final fallbackName = copy.t(_untitledCatalogKey(item.type));
    final updated = item.copyWith(
      name: nameController.text.trim().isEmpty
          ? fallbackName
          : nameController.text.trim(),
      summary: summaryController.text.trim(),
      status: draftStatus,
    );
    nameController.dispose();
    summaryController.dispose();

    await widget.catalogItemRepository.save(updated);
    final items = await widget.catalogItemRepository.listByProject(project.id);
    if (!mounted) return;
    _setShellState(() => _catalogItems = items);
    await _recordProjectMetric(
      eventType: 'catalog.updated',
      metadata: {'itemId': updated.id, 'type': updated.type.wireName},
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(copy.t('catalogItemSaved'))),
    );
  }

  Future<bool> _confirmDelete({
    required WritelerCopy copy,
    required String title,
    required String body,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(body),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(copy.t('cancel')),
            ),
            FilledButton.tonalIcon(
              onPressed: () => Navigator.of(context).pop(true),
              icon: const Icon(Icons.delete_outline),
              label: Text(copy.t('deletePermanently')),
            ),
          ],
        );
      },
    );
    return confirmed == true;
  }
}
