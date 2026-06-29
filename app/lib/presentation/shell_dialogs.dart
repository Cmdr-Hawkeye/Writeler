part of '../main.dart';

// Dialog workflows used by the shell. Kept as an extension so the shell state
// remains private while dialog code stays out of the main orchestration file.

final class _ProjectWizardResult {
  const _ProjectWizardResult({
    required this.title,
    required this.authorName,
    required this.projectType,
    required this.languageCode,
    required this.description,
    required this.wordTarget,
    required this.metadata,
  });

  final String title;
  final String authorName;
  final String projectType;
  final String languageCode;
  final String description;
  final int? wordTarget;
  final Map<String, Object?> metadata;
}

enum _ProjectTargetUnit { words, pages }

final class _ProjectWizardDialog extends StatefulWidget {
  const _ProjectWizardDialog({required this.copy});

  final WritellerCopy copy;

  @override
  State<_ProjectWizardDialog> createState() => _ProjectWizardDialogState();
}

final class _ProjectWizardDialogState extends State<_ProjectWizardDialog> {
  late final TextEditingController _titleController = TextEditingController();
  late final TextEditingController _authorController = TextEditingController();
  late final TextEditingController _descriptionController =
      TextEditingController();
  late final TextEditingController _wordTargetController =
      TextEditingController();
  var _step = 0;
  var _projectType = 'novel';
  var _targetUnit = _ProjectTargetUnit.words;
  late var _languageCode = WritellerCopy.normalizeLanguageCode(
    Localizations.localeOf(context).languageCode,
  );

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _descriptionController.dispose();
    _wordTargetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final copy = widget.copy;
    final steps = [
      _ProjectWizardStep(
        title: copy.t('projectWizardBasics'),
        child: TextField(
          controller: _titleController,
          autofocus: true,
          decoration: InputDecoration(labelText: copy.t('projectTitle')),
          textInputAction: TextInputAction.next,
          onSubmitted: (_) => setState(() => _step = 1),
        ),
      ),
      _ProjectWizardStep(
        title: copy.t('projectWizardAuthor'),
        child: Column(
          children: [
            TextField(
              controller: _authorController,
              decoration: InputDecoration(labelText: copy.t('authorName')),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _projectType,
              icon: const Icon(Icons.keyboard_arrow_down_rounded),
              decoration: InputDecoration(
                labelText: copy.t('projectType'),
                border: const OutlineInputBorder(),
              ),
              items: [
                for (final option in _projectTypeOptions)
                  DropdownMenuItem(
                    value: option.value,
                    child: Text(copy.t(option.labelKey)),
                  ),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _projectType = value);
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _languageCode,
              icon: const Icon(Icons.keyboard_arrow_down_rounded),
              decoration: InputDecoration(
                labelText: copy.t('projectLanguage'),
                border: const OutlineInputBorder(),
              ),
              items: [
                for (final language in WritellerCopy.supportedLanguages)
                  DropdownMenuItem(
                    value: language.code,
                    child: Text(language.nativeName),
                  ),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _languageCode = value);
              },
            ),
          ],
        ),
      ),
      _ProjectWizardStep(
        title: copy.t('projectWizardScope'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SegmentedButton<_ProjectTargetUnit>(
              segments: [
                ButtonSegment(
                  value: _ProjectTargetUnit.words,
                  icon: const Icon(Icons.notes_outlined),
                  label: Text(copy.t('targetUnitWords')),
                ),
                ButtonSegment(
                  value: _ProjectTargetUnit.pages,
                  icon: const Icon(Icons.description_outlined),
                  label: Text(copy.t('targetUnitPages')),
                ),
              ],
              selected: {_targetUnit},
              onSelectionChanged: (selection) {
                _changeTargetUnit(selection.single);
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _wordTargetController,
              decoration: InputDecoration(
                labelText: _targetUnit == _ProjectTargetUnit.pages
                    ? copy.t('pageTarget')
                    : copy.t('wordTarget'),
                helperText: _targetUnit == _ProjectTargetUnit.pages
                    ? copy.t('pageTargetHelper')
                    : null,
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: copy.t('projectDescription'),
                alignLabelWithHint: true,
              ),
              maxLines: 4,
            ),
          ],
        ),
      ),
    ];
    final current = steps[_step];

    return AlertDialog(
      title: Text(copy.t('newProject')),
      content: SizedBox(
        width: 520,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ProjectWizardProgress(
              step: _step,
              stepCount: steps.length,
              copy: copy,
            ),
            const SizedBox(height: 18),
            Text(
              current.title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            current.child,
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(copy.t('cancel')),
        ),
        if (_step > 0)
          TextButton(
            onPressed: () => setState(() => _step -= 1),
            child: Text(copy.t('back')),
          ),
        if (_step < steps.length - 1)
          OutlinedButton(
            onPressed: () => setState(() => _step += 1),
            child: Text(copy.t('next')),
          ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_result()),
          child: Text(copy.t('create')),
        ),
      ],
    );
  }

  _ProjectWizardResult _result() {
    final targetText = _wordTargetController.text.trim();
    final targetValue = int.tryParse(targetText);
    final wordTarget = switch (_targetUnit) {
      _ProjectTargetUnit.words => targetValue,
      _ProjectTargetUnit.pages =>
        targetValue == null ? null : targetValue * _estimatedWordsPerPage,
    };
    return _ProjectWizardResult(
      title: _titleController.text.trim(),
      authorName: _authorController.text.trim(),
      projectType: _projectType,
      languageCode: _languageCode,
      description: _descriptionController.text.trim(),
      wordTarget: wordTarget,
      metadata: {
        'targetUnit': _targetUnit.name,
        if (_targetUnit == _ProjectTargetUnit.pages && targetValue != null)
          'pageTarget': targetValue,
        if (_targetUnit == _ProjectTargetUnit.pages)
          'wordsPerPageEstimate': _estimatedWordsPerPage,
      },
    );
  }

  void _changeTargetUnit(_ProjectTargetUnit unit) {
    final converted = _convertedProjectTargetText(
      _wordTargetController.text,
      from: _targetUnit,
      to: unit,
    );
    setState(() {
      _targetUnit = unit;
      if (converted != null) {
        _wordTargetController.text = converted;
        _wordTargetController.selection = TextSelection.collapsed(
          offset: converted.length,
        );
      }
    });
  }
}

final class _ProjectWizardStep {
  const _ProjectWizardStep({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;
}

final class _ProjectWizardProgress extends StatelessWidget {
  const _ProjectWizardProgress({
    required this.step,
    required this.stepCount,
    required this.copy,
  });

  final int step;
  final int stepCount;
  final WritellerCopy copy;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Row(
      children: [
        Text(
          '${copy.t('step')} ${step + 1}/$stepCount',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: color.onSurfaceVariant,
              ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: LinearProgressIndicator(
            value: (step + 1) / stepCount,
            minHeight: 3,
            borderRadius: BorderRadius.circular(99),
          ),
        ),
      ],
    );
  }
}

extension _WritellerShellDialogs on _WritellerShellState {
  Future<void> _showCreateProjectDialog(WritellerCopy copy) async {
    final result = await showDialog<_ProjectWizardResult>(
      context: context,
      builder: (context) => _ProjectWizardDialog(copy: copy),
    );

    if (result == null) return;
    if (!mounted) return;

    final project = await _createProject(
      CreateProjectCommand(
        title: result.title.isEmpty ? copy.t('untitledProject') : result.title,
        description: result.description,
        projectType: result.projectType,
        languageCode: result.languageCode,
        wordTarget: result.wordTarget,
        metadata: {
          ...result.metadata,
          if (result.authorName.isNotEmpty) 'authorName': result.authorName,
        },
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

  Future<void> _showCreateSceneDialog(WritellerCopy copy) async {
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

  Future<void> _showCreateChapterDialog(WritellerCopy copy) async {
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

  Future<CatalogItem?> _showCreateCatalogItemDialog(
    WritellerCopy copy,
    EntityType type,
  ) async {
    final project = _selectedProject;
    if (project == null) return null;

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

    if (created != true) return null;
    final name = draftName.trim();
    final item = await _createCatalogItem(
      CreateCatalogItemCommand(
        projectId: project.id,
        type: type,
        name: name.isEmpty ? copy.t(_untitledCatalogKey(type)) : name,
        summary: draftSummary,
      ),
    );
    final items = await widget.catalogItemRepository.listByProject(project.id);

    if (!mounted) return null;
    _setShellState(() {
      _catalogItems = items;
    });
    await _recordProjectMetric(
      eventType: 'catalog.created',
      metadata: {'type': type.wireName},
    );
    if (!mounted) return null;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(copy.t('catalogItemCreated'))),
    );
    return item;
  }

  Future<void> _showEditCatalogItemDialog(
    WritellerCopy copy,
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
                  icon: const Icon(Icons.keyboard_arrow_down_rounded),
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
            _ActionHelp(
              message: copy.t('helpSaveCatalogItem'),
              child: FilledButton.icon(
                onPressed: () => Navigator.of(context).pop(true),
                icon: const Icon(Icons.save_outlined),
                label: Text(copy.t('saveCatalogItem')),
              ),
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

  Future<void> _showRelationshipDialog(
    WritellerCopy copy, {
    Relationship? existing,
    EntityRef? initialSource,
  }) async {
    final project = _selectedProject;
    if (project == null) return;

    final endpoints = _relationshipEndpoints(copy);
    if (endpoints.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(copy.t('relationshipNeedsEndpoints'))),
      );
      return;
    }

    final sourceFallback = initialSource ?? existing?.source;
    var sourceKey = _endpointKey(sourceFallback) ?? endpoints.first.key;
    if (!endpoints.any((endpoint) => endpoint.key == sourceKey)) {
      sourceKey = endpoints.first.key;
    }
    var targetKey = _endpointKey(existing?.target);
    if (targetKey == null ||
        targetKey == sourceKey ||
        !endpoints.any((endpoint) => endpoint.key == targetKey)) {
      targetKey =
          endpoints.firstWhere((endpoint) => endpoint.key != sourceKey).key;
    }

    const commonTypes = [
      'appearsIn',
      'ally',
      'conflict',
      'family',
      'owns',
      'locatedAt',
      'foreshadows',
    ];
    var selectedType = commonTypes.contains(existing?.relationshipType)
        ? existing!.relationshipType
        : 'custom';
    final customTypeController = TextEditingController(
      text: selectedType == 'custom' ? existing?.relationshipType ?? '' : '',
    );
    final labelController = TextEditingController(text: existing?.label ?? '');
    final descriptionController =
        TextEditingController(text: existing?.description ?? '');
    var direction = existing?.direction ?? RelationshipDirection.directed;
    var strength = existing?.strength ?? 0.5;

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final targetOptions = endpoints
                .where((endpoint) => endpoint.key != sourceKey)
                .toList(growable: false);
            if (!targetOptions.any((endpoint) => endpoint.key == targetKey)) {
              targetKey = targetOptions.first.key;
            }
            return AlertDialog(
              title: Text(
                existing == null
                    ? copy.t('newRelationship')
                    : copy.t('editRelationship'),
              ),
              content: SizedBox(
                width: 520,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<String>(
                        initialValue: sourceKey,
                        icon: const Icon(Icons.keyboard_arrow_down_rounded),
                        decoration: InputDecoration(
                          labelText: copy.t('relationshipSource'),
                          border: const OutlineInputBorder(),
                        ),
                        items: [
                          for (final endpoint in endpoints)
                            DropdownMenuItem(
                              value: endpoint.key,
                              child: Text(endpoint.label),
                            ),
                        ],
                        onChanged: (value) {
                          if (value == null) return;
                          setDialogState(() => sourceKey = value);
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: targetKey,
                        icon: const Icon(Icons.keyboard_arrow_down_rounded),
                        decoration: InputDecoration(
                          labelText: copy.t('relationshipTarget'),
                          border: const OutlineInputBorder(),
                        ),
                        items: [
                          for (final endpoint in targetOptions)
                            DropdownMenuItem(
                              value: endpoint.key,
                              child: Text(endpoint.label),
                            ),
                        ],
                        onChanged: (value) {
                          if (value == null) return;
                          setDialogState(() => targetKey = value);
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: selectedType,
                        icon: const Icon(Icons.keyboard_arrow_down_rounded),
                        decoration: InputDecoration(
                          labelText: copy.t('relationshipType'),
                          border: const OutlineInputBorder(),
                        ),
                        items: [
                          for (final type in commonTypes)
                            DropdownMenuItem(
                              value: type,
                              child: Text(_relationshipTypeLabel(type, copy)),
                            ),
                          DropdownMenuItem(
                            value: 'custom',
                            child: Text(copy.t('relationTypeCustom')),
                          ),
                        ],
                        onChanged: (value) {
                          if (value == null) return;
                          setDialogState(() => selectedType = value);
                        },
                      ),
                      if (selectedType == 'custom') ...[
                        const SizedBox(height: 12),
                        TextField(
                          controller: customTypeController,
                          decoration: InputDecoration(
                            labelText: copy.t('relationshipType'),
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      SegmentedButton<RelationshipDirection>(
                        segments: [
                          ButtonSegment(
                            value: RelationshipDirection.directed,
                            icon: const Icon(Icons.arrow_forward),
                            label: Text(copy.t('relationshipDirected')),
                          ),
                          ButtonSegment(
                            value: RelationshipDirection.undirected,
                            icon: const Icon(Icons.sync_alt),
                            label: Text(copy.t('relationshipUndirected')),
                          ),
                        ],
                        selected: {direction},
                        onSelectionChanged: (selection) {
                          setDialogState(() => direction = selection.first);
                        },
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: labelController,
                        decoration: InputDecoration(
                          labelText: copy.t('relationshipLabel'),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: descriptionController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: copy.t('relationshipDescription'),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Text(copy.t('relationshipStrength')),
                          ),
                          Text('${(strength * 100).round()}%'),
                        ],
                      ),
                      Slider(
                        value: strength,
                        onChanged: (value) {
                          setDialogState(() => strength = value);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(copy.t('cancel')),
                ),
                _ActionHelp(
                  message: copy.t('helpSaveRelationship'),
                  child: FilledButton.icon(
                    onPressed: () => Navigator.of(context).pop(true),
                    icon: const Icon(Icons.save_outlined),
                    label: Text(copy.t('saveRelationship')),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (saved != true) {
      customTypeController.dispose();
      labelController.dispose();
      descriptionController.dispose();
      return;
    }

    final source =
        endpoints.where((endpoint) => endpoint.key == sourceKey).first.ref;
    final target =
        endpoints.where((endpoint) => endpoint.key == targetKey).first.ref;
    final now = DateTime.now().toUtc();
    final relationshipType = selectedType == 'custom'
        ? customTypeController.text.trim()
        : selectedType;
    final relationship = Relationship(
      id: existing?.id ?? newLocalId('relationship'),
      projectId: project.id,
      source: source,
      target: target,
      relationshipType:
          relationshipType.isEmpty ? 'relatedTo' : relationshipType,
      label: labelController.text.trim().isEmpty
          ? null
          : labelController.text.trim(),
      description: descriptionController.text.trim().isEmpty
          ? null
          : descriptionController.text.trim(),
      strength: strength,
      direction: direction,
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
      metadata: existing?.metadata ?? const {},
    );
    customTypeController.dispose();
    labelController.dispose();
    descriptionController.dispose();

    await widget.relationshipRepository.save(relationship);
    final relationships =
        await widget.relationshipRepository.listByProject(project.id);
    if (!mounted) return;
    _setShellState(() => _relationships = relationships);
    await _recordProjectMetric(
      eventType: 'relationship.saved',
      metadata: {
        'relationshipId': relationship.id,
        'relationshipType': relationship.relationshipType,
      },
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(copy.t('relationshipSaved'))),
    );
  }

  Future<void> _deleteRelationship(
    Relationship relationship,
    WritellerCopy copy,
  ) async {
    final project = _selectedProject;
    if (project == null) return;
    final confirmed = await _confirmDelete(
      copy: copy,
      title: copy.t('deleteRelationship'),
      body: copy.t('deleteRelationshipBody'),
    );
    if (!confirmed) return;

    await widget.relationshipRepository.delete(relationship.id);
    final relationships =
        await widget.relationshipRepository.listByProject(project.id);
    if (!mounted) return;
    _setShellState(() => _relationships = relationships);
    await _recordProjectMetric(
      eventType: 'relationship.deleted',
      metadata: {'relationshipId': relationship.id},
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(copy.t('relationshipDeleted'))),
    );
  }

  List<_RelationshipEndpoint> _relationshipEndpoints(WritellerCopy copy) {
    return [
      for (final scene in _scenes)
        _RelationshipEndpoint(
          ref: EntityRef(type: EntityType.scene, id: scene.id),
          label: '${copy.t('scene')}: ${scene.title}',
        ),
      for (final item in _catalogItems)
        _RelationshipEndpoint(
          ref: EntityRef(type: item.type, id: item.id),
          label: '${_entityTypeLabel(item.type, copy)}: ${item.name}',
        ),
    ];
  }

  String? _endpointKey(EntityRef? ref) {
    if (ref == null) return null;
    return '${ref.type.wireName}:${ref.id}';
  }

  Future<bool> _confirmDelete({
    required WritellerCopy copy,
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
            _ActionHelp(
              message: copy.t('helpDeletePermanently'),
              child: FilledButton.tonalIcon(
                onPressed: () => Navigator.of(context).pop(true),
                icon: const Icon(Icons.delete_outline),
                label: Text(copy.t('deletePermanently')),
              ),
            ),
          ],
        );
      },
    );
    return confirmed == true;
  }
}

final class _RelationshipEndpoint {
  const _RelationshipEndpoint({
    required this.ref,
    required this.label,
  });

  final EntityRef ref;
  final String label;

  String get key => '${ref.type.wireName}:${ref.id}';
}
