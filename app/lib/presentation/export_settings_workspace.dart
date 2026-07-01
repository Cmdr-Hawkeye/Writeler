part of '../main.dart';

// Export, sync, import, provider, privacy, and design-settings workspaces.

final class _ExportCenter extends StatelessWidget {
  const _ExportCenter({
    required this.copy,
    required this.project,
    required this.chapters,
    required this.scenes,
    required this.notes,
    required this.researchItems,
    required this.catalogItems,
    required this.relationships,
    required this.exporter,
    required this.format,
    required this.importController,
    required this.importPreview,
    required this.importPreviewError,
    required this.importSourceName,
    required this.isImportDragging,
    required this.lastSyncCheckpoint,
    required this.syncImportPreview,
    required this.onFormatChanged,
    required this.onDownloadExport,
    required this.onCopySyncCheckpoint,
    required this.onImportSourceChanged,
    required this.onPickImportFile,
    required this.onImportDropped,
    required this.onImportDragChanged,
    required this.onImportArchive,
  });

  final WritellerCopy copy;
  final Project? project;
  final List<Chapter> chapters;
  final List<Scene> scenes;
  final List<ProjectNote> notes;
  final List<ResearchItem> researchItems;
  final List<CatalogItem> catalogItems;
  final List<Relationship> relationships;
  final ProjectExporter exporter;
  final ExportFormat format;
  final TextEditingController importController;
  final ProjectArchivePreview? importPreview;
  final String? importPreviewError;
  final String? importSourceName;
  final bool isImportDragging;
  final SyncCheckpoint? lastSyncCheckpoint;
  final SyncEnvelopePreview? syncImportPreview;
  final ValueChanged<ExportFormat> onFormatChanged;
  final VoidCallback onDownloadExport;
  final VoidCallback onCopySyncCheckpoint;
  final VoidCallback onImportSourceChanged;
  final VoidCallback onPickImportFile;
  final ValueChanged<DropDoneDetails> onImportDropped;
  final ValueChanged<bool> onImportDragChanged;
  final VoidCallback onImportArchive;

  @override
  Widget build(BuildContext context) {
    final project = this.project;
    final preview = project == null
        ? ''
        : exporter.exportProject(
            project: project,
            chapters: chapters,
            scenes: scenes,
            catalogItems: catalogItems,
            relationships: relationships,
            notes: notes,
            researchItems: researchItems,
            profile: ExportProfile(
              id: 'preview',
              projectId: project.id,
              name: copy.t('exportPreview'),
              format: format,
              includeMetadata: true,
              includeSceneTitles: true,
            ),
          );

    return Column(
      children: [
        _WorkspaceHeader(
          title: copy.t('exports'),
        ),
        const Divider(height: 1),
        Expanded(
          child: DropTarget(
            onDragEntered: (_) => onImportDragChanged(true),
            onDragExited: (_) => onImportDragChanged(false),
            onDragDone: (details) {
              onImportDragChanged(false);
              onImportDropped(details);
            },
            child: Row(
              children: [
                SizedBox(
                  width: 300,
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      Text(
                        copy.t('archiveExportBody'),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<ExportFormat>(
                        initialValue: format,
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down_rounded),
                        decoration: InputDecoration(
                          labelText: copy.t('migrationExportFormat'),
                          suffixIcon: Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: _HelpTooltip(
                              message: copy.t('helpMigrationExportFormat'),
                            ),
                          ),
                          suffixIconConstraints:
                              const BoxConstraints(minWidth: 42),
                          border: const OutlineInputBorder(),
                        ),
                        items: [
                          for (final item in _migrationExportFormats)
                            DropdownMenuItem(
                              value: item,
                              child: Text(
                                _exportFormatLabel(item, copy.languageCode),
                              ),
                            ),
                        ],
                        onChanged: (value) {
                          if (value != null) onFormatChanged(value);
                        },
                      ),
                      const SizedBox(height: 12),
                      _ActionHelp(
                        message: copy.t('helpDownloadExport'),
                        child: FilledButton.icon(
                          onPressed: project == null ? null : onDownloadExport,
                          icon: const Icon(Icons.download_outlined),
                          label: Text(copy.t('downloadExport')),
                        ),
                      ),
                      const Divider(height: 28),
                      Text(copy.t('syncCheckpoint'),
                          style: Theme.of(context).textTheme.titleSmall),
                      const SizedBox(height: 6),
                      Text(
                        copy.t('syncCheckpointBody'),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      if (lastSyncCheckpoint != null) ...[
                        const SizedBox(height: 10),
                        _SyncStatusPanel(
                          copy: copy,
                          checkpoint: lastSyncCheckpoint!,
                        ),
                      ],
                      const SizedBox(height: 12),
                      _ActionHelp(
                        message: copy.t('helpCopySyncCheckpoint'),
                        child: FilledButton.icon(
                          onPressed:
                              project == null ? null : onCopySyncCheckpoint,
                          icon: const Icon(Icons.sync_outlined),
                          label: Text(copy.t('copySyncCheckpoint')),
                        ),
                      ),
                      const Divider(height: 28),
                      Text(copy.t('importArchive'),
                          style: Theme.of(context).textTheme.titleSmall),
                      const SizedBox(height: 8),
                      _ImportDropZone(
                        copy: copy,
                        sourceName: importSourceName,
                        preview: importPreview,
                        isDragging: isImportDragging,
                        onPickFile: onPickImportFile,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: importController,
                        onChanged: (_) => onImportSourceChanged(),
                        minLines: 5,
                        maxLines: 8,
                        decoration: InputDecoration(
                          labelText: copy.t('pasteArchiveJson'),
                          suffixIcon: Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: _HelpTooltip(
                              message: copy.t('helpPasteImport'),
                            ),
                          ),
                          suffixIconConstraints:
                              const BoxConstraints(minWidth: 42),
                          border: const OutlineInputBorder(),
                          alignLabelWithHint: true,
                        ),
                      ),
                      if (importPreview != null ||
                          importPreviewError != null) ...[
                        const SizedBox(height: 12),
                        if (syncImportPreview != null) ...[
                          _SyncEnvelopePanel(
                            copy: copy,
                            preview: syncImportPreview!,
                          ),
                          const SizedBox(height: 12),
                        ],
                        _ImportArchivePreview(
                          copy: copy,
                          preview: importPreview,
                          error: importPreviewError,
                        ),
                      ],
                      const SizedBox(height: 12),
                      _ActionHelp(
                        message: copy.t('helpImportProject'),
                        child: FilledButton.icon(
                          onPressed:
                              importPreview == null ? null : onImportArchive,
                          icon: const Icon(Icons.upload_file_outlined),
                          label: Text(copy.t('importProject')),
                        ),
                      ),
                    ],
                  ),
                ),
                const VerticalDivider(width: 1),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: SelectableText(
                      preview.isEmpty ? copy.t('nothingToExport') : preview,
                      style: const TextStyle(fontFamily: 'monospace'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

final class _SelfPublishingCenter extends StatelessWidget {
  const _SelfPublishingCenter({
    required this.copy,
    required this.project,
    required this.chapters,
    required this.scenes,
    required this.notes,
    required this.catalogItems,
    required this.relationships,
    required this.format,
    required this.publishingStyle,
    required this.includeSceneTitles,
    required this.includeMetadata,
    required this.exporter,
    required this.onFormatChanged,
    required this.onPublishingStyleChanged,
    required this.onIncludeSceneTitlesChanged,
    required this.onIncludeMetadataChanged,
    required this.onSavePublishingMetadata,
    required this.onDownload,
  });

  final WritellerCopy copy;
  final Project? project;
  final List<Chapter> chapters;
  final List<Scene> scenes;
  final List<ProjectNote> notes;
  final List<CatalogItem> catalogItems;
  final List<Relationship> relationships;
  final ExportFormat format;
  final PublishingStyle publishingStyle;
  final bool includeSceneTitles;
  final bool includeMetadata;
  final ProjectExporter exporter;
  final ValueChanged<ExportFormat> onFormatChanged;
  final ValueChanged<PublishingStyle> onPublishingStyleChanged;
  final ValueChanged<bool> onIncludeSceneTitlesChanged;
  final ValueChanged<bool> onIncludeMetadataChanged;
  final ValueChanged<Map<String, String>> onSavePublishingMetadata;
  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context) {
    final project = this.project;
    final preview = project == null
        ? ''
        : exporter.exportProject(
            project: project,
            chapters: chapters,
            scenes: scenes,
            catalogItems: catalogItems,
            relationships: relationships,
            notes: notes,
            profile: ExportProfile(
              id: 'publishing-preview',
              projectId: project.id,
              name: copy.t('selfPublishing'),
              format: format,
              publishingStyle: publishingStyle,
              includeMetadata: includeMetadata,
              includeSceneTitles: includeSceneTitles,
            ),
          );

    return Column(
      children: [
        const Divider(height: 1),
        Expanded(
          child: Row(
            children: [
              SizedBox(
                width: 300,
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Text(
                      copy.t('selfPublishingBody'),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<ExportFormat>(
                      initialValue: format,
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded),
                      decoration: InputDecoration(
                        labelText: copy.t('publishingFormat'),
                        suffixIcon: Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _HelpTooltip(
                            message: copy.t('helpPublishingFormat'),
                          ),
                        ),
                        suffixIconConstraints:
                            const BoxConstraints(minWidth: 42),
                        border: const OutlineInputBorder(),
                      ),
                      items: [
                        for (final item in _publishingFormats)
                          DropdownMenuItem(
                            value: item,
                            child: Text(
                                _exportFormatLabel(item, copy.languageCode)),
                          ),
                      ],
                      onChanged: (value) {
                        if (value != null) onFormatChanged(value);
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<PublishingStyle>(
                      initialValue: publishingStyle,
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded),
                      decoration: InputDecoration(
                        labelText: copy.t('publishingStyle'),
                        suffixIcon: Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _HelpTooltip(
                            message: copy.t('helpPublishingStyle'),
                          ),
                        ),
                        suffixIconConstraints:
                            const BoxConstraints(minWidth: 42),
                        border: const OutlineInputBorder(),
                      ),
                      items: [
                        for (final item in PublishingStyle.values)
                          DropdownMenuItem(
                            value: item,
                            child: Text(
                                _publishingStyleLabel(item, copy.languageCode)),
                          ),
                      ],
                      onChanged: (value) {
                        if (value != null) onPublishingStyleChanged(value);
                      },
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      value: includeSceneTitles,
                      title: _HelpedLabel(
                        label: copy.t('includeSceneTitles'),
                        help: copy.t('helpIncludeSceneTitles'),
                      ),
                      onChanged: onIncludeSceneTitlesChanged,
                    ),
                    SwitchListTile(
                      value: includeMetadata,
                      title: _HelpedLabel(
                        label: copy.t('includePublishingMetadata'),
                        help: copy.t('helpIncludePublishingMetadata'),
                      ),
                      onChanged: onIncludeMetadataChanged,
                    ),
                    const SizedBox(height: 12),
                    _PublishingMetadataForm(
                      copy: copy,
                      project: project,
                      onSave: onSavePublishingMetadata,
                    ),
                    const SizedBox(height: 12),
                    _ActionHelp(
                      message: copy.t('helpDownloadManuscript'),
                      child: FilledButton.icon(
                        onPressed: project == null ? null : onDownload,
                        icon: const Icon(Icons.download_outlined),
                        label: Text(copy.t('downloadManuscript')),
                      ),
                    ),
                  ],
                ),
              ),
              const VerticalDivider(width: 1),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: _PublishingPreview(
                    copy: copy,
                    project: project,
                    scenes: scenes,
                    publishingStyle: publishingStyle,
                    format: format,
                    preview: preview,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

final class _PublishingMetadataForm extends StatefulWidget {
  const _PublishingMetadataForm({
    required this.copy,
    required this.project,
    required this.onSave,
  });

  final WritellerCopy copy;
  final Project? project;
  final ValueChanged<Map<String, String>> onSave;

  @override
  State<_PublishingMetadataForm> createState() =>
      _PublishingMetadataFormState();
}

final class _PublishingMetadataFormState
    extends State<_PublishingMetadataForm> {
  late final TextEditingController _subtitleController =
      TextEditingController();
  late final TextEditingController _authorController = TextEditingController();
  late final TextEditingController _imprintController = TextEditingController();
  late final TextEditingController _isbnController = TextEditingController();
  late final TextEditingController _copyrightController =
      TextEditingController();
  late final TextEditingController _coverCreditController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _syncControllers();
  }

  @override
  void didUpdateWidget(covariant _PublishingMetadataForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.project?.id != widget.project?.id) {
      _syncControllers();
    }
  }

  @override
  void dispose() {
    _subtitleController.dispose();
    _authorController.dispose();
    _imprintController.dispose();
    _isbnController.dispose();
    _copyrightController.dispose();
    _coverCreditController.dispose();
    super.dispose();
  }

  void _syncControllers() {
    final project = widget.project;
    _subtitleController.text = _metadataText(project, 'publishingSubtitle');
    _authorController.text = _metadataText(
      project,
      'publishingAuthor',
      fallback: _metadataText(project, 'authorName'),
    );
    _imprintController.text = _metadataText(project, 'publishingImprint');
    _isbnController.text = _metadataText(project, 'publishingIsbn');
    _copyrightController.text = _metadataText(project, 'publishingCopyright');
    _coverCreditController.text =
        _metadataText(project, 'publishingCoverCredit');
  }

  @override
  Widget build(BuildContext context) {
    if (widget.project == null) {
      return _EmptyInlineMessage(message: widget.copy.t('selectProject'));
    }
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HelpedLabel(
              label: widget.copy.t('publishingMetadata'),
              help: widget.copy.t('helpPublishingMetadata'),
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 10),
            _metadataField(_subtitleController, 'publishingSubtitle'),
            const SizedBox(height: 10),
            _metadataField(_authorController, 'publishingAuthor'),
            const SizedBox(height: 10),
            _metadataField(_imprintController, 'publishingImprint'),
            const SizedBox(height: 10),
            _metadataField(_isbnController, 'publishingIsbn'),
            const SizedBox(height: 10),
            _metadataField(_copyrightController, 'publishingCopyright'),
            const SizedBox(height: 10),
            _metadataField(_coverCreditController, 'publishingCoverCredit'),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.badge_outlined),
                label: Text(widget.copy.t('savePublishingMetadata')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _metadataField(TextEditingController controller, String key) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: widget.copy.t(key),
        border: const OutlineInputBorder(),
        isDense: true,
      ),
      textInputAction: TextInputAction.next,
    );
  }

  void _save() {
    widget.onSave({
      'publishingSubtitle': _subtitleController.text,
      'publishingAuthor': _authorController.text,
      'publishingImprint': _imprintController.text,
      'publishingIsbn': _isbnController.text,
      'publishingCopyright': _copyrightController.text,
      'publishingCoverCredit': _coverCreditController.text,
    });
  }
}

final class _PublishingPreview extends StatelessWidget {
  const _PublishingPreview({
    required this.copy,
    required this.project,
    required this.scenes,
    required this.publishingStyle,
    required this.format,
    required this.preview,
  });

  final WritellerCopy copy;
  final Project? project;
  final List<Scene> scenes;
  final PublishingStyle publishingStyle;
  final ExportFormat format;
  final String preview;

  @override
  Widget build(BuildContext context) {
    final project = this.project;
    if (project == null || preview.isEmpty) {
      return SelectableText(copy.t('nothingToExport'));
    }
    final color = Theme.of(context).colorScheme;
    final layout = PublishingLayoutProfile.forStyle(publishingStyle);
    final words =
        scenes.fold<int>(0, (sum, scene) => sum + scene.actualWordCount);
    final firstParagraph = scenes
        .expand((scene) => scene.manuscriptText.split(RegExp(r'\n\s*\n')))
        .map((paragraph) => paragraph.trim())
        .firstWhere((paragraph) => paragraph.isNotEmpty, orElse: () => '');
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 880;
        final overview = _PublishingProfileCard(
          copy: copy,
          layout: layout,
          format: format,
          words: words,
        );
        final page = _PublishingPageMockup(
          project: project,
          layout: layout,
          firstParagraph: firstParagraph,
        );
        return ListView(
          children: [
            if (compact)
              Column(
                children: [
                  overview,
                  const SizedBox(height: 14),
                  page,
                ],
              )
            else
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 310, child: overview),
                  const SizedBox(width: 18),
                  Expanded(child: page),
                ],
              ),
            const SizedBox(height: 18),
            Text(
              copy.t('technicalPreview'),
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            DecoratedBox(
              decoration: BoxDecoration(
                color: color.surfaceContainerLow,
                border: Border.all(color: color.outlineVariant),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: SelectableText(
                  preview,
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

final class _PublishingProfileCard extends StatelessWidget {
  const _PublishingProfileCard({
    required this.copy,
    required this.layout,
    required this.format,
    required this.words,
  });

  final WritellerCopy copy;
  final PublishingLayoutProfile layout;
  final ExportFormat format;
  final int words;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.surfaceContainerLow,
        border: Border.all(color: color.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_stories_outlined, color: color.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    layout.label,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              layout.description,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 14),
            _PublishingSpecRow(
              label: copy.t('publishingFormat'),
              value: _exportFormatLabel(format, copy.languageCode),
            ),
            _PublishingSpecRow(
              label: copy.t('pageFormat'),
              value: '${layout.pageFormat} · ${layout.trimSize}',
            ),
            _PublishingSpecRow(
              label: copy.t('typeSpec'),
              value:
                  '${layout.fontFamily}, ${layout.bodySizePt.toStringAsFixed(1)} pt',
            ),
            _PublishingSpecRow(
              label: copy.t('lineSpacing'),
              value: '${layout.lineHeightPt.toStringAsFixed(1)} pt',
            ),
            _PublishingSpecRow(
              label: copy.t('estimatedPages'),
              value: '${layout.estimatedPagesForWords(words)}',
            ),
          ],
        ),
      ),
    );
  }
}

final class _PublishingSpecRow extends StatelessWidget {
  const _PublishingSpecRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 7),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

final class _PublishingPageMockup extends StatelessWidget {
  const _PublishingPageMockup({
    required this.project,
    required this.layout,
    required this.firstParagraph,
  });

  final Project project;
  final PublishingLayoutProfile layout;
  final String firstParagraph;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final author = _metadataText(
      project,
      'publishingAuthor',
      fallback: _metadataText(project, 'authorName'),
    );
    final subtitle = _metadataText(project, 'publishingSubtitle');
    final paragraph = firstParagraph.isEmpty
        ? 'Der Manuskripttext erscheint hier als Satzvorschau, sobald Szenen Text enthalten.'
        : firstParagraph;
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 460),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: color.surface,
          border: Border.all(color: color.outlineVariant),
          boxShadow: [
            BoxShadow(
              color: color.shadow.withValues(alpha: 0.10),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: AspectRatio(
          aspectRatio: layout.style == PublishingStyle.paperback ? 0.64 : 0.70,
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(color: color.outlineVariant),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 34, 28, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    project.title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontFamily: layout.fontFamily,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: color.onSurfaceVariant,
                          ),
                    ),
                  ],
                  if (author.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      author,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ],
                  const SizedBox(height: 22),
                  Expanded(
                    child: Text(
                      paragraph,
                      maxLines:
                          layout.style == PublishingStyle.largePrint ? 8 : 11,
                      overflow: TextOverflow.fade,
                      style: TextStyle(
                        fontFamily: layout.fontFamily,
                        fontSize: layout.bodySizePt,
                        height: layout.lineHeightPt / layout.bodySizePt,
                      ),
                    ),
                  ),
                  Text(
                    layout.label,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: color.onSurfaceVariant,
                        ),
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

String _metadataText(Project? project, String key, {String fallback = ''}) {
  final value = (project?.metadata[key] as String? ?? '').trim();
  return value.isEmpty ? fallback : value;
}

const _publishingFormats = [
  ExportFormat.pdf,
  ExportFormat.docx,
  ExportFormat.epub,
  ExportFormat.plainText,
  ExportFormat.markdown,
  ExportFormat.html,
  ExportFormat.outline,
];

const _migrationExportFormats = [
  ExportFormat.json,
  ExportFormat.yWriter,
  ExportFormat.scrivener,
  ExportFormat.markdown,
  ExportFormat.plainText,
  ExportFormat.outline,
  ExportFormat.html,
];

final class _SyncStatusPanel extends StatelessWidget {
  const _SyncStatusPanel({
    required this.copy,
    required this.checkpoint,
  });

  final WritellerCopy copy;
  final SyncCheckpoint checkpoint;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              copy.t('lastSyncCheckpoint'),
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 6),
            Text(
              '${copy.t('syncFingerprint')}: ${checkpoint.fingerprint}\n'
              '${copy.t('syncAdapter')}: ${checkpoint.adapterName}\n'
              '${copy.t('syncPayloadSize')}: ${checkpoint.byteLength} B',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

final class _SyncEnvelopePanel extends StatelessWidget {
  const _SyncEnvelopePanel({
    required this.copy,
    required this.preview,
  });

  final WritellerCopy copy;
  final SyncEnvelopePreview preview;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.tertiaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.verified_outlined,
                color: color.onTertiaryContainer, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${copy.t('syncPayloadDetected')}\n'
                '${copy.t('syncFingerprint')}: ${preview.fingerprint}\n'
                '${copy.t('syncAdapter')}: ${preview.adapterName}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: color.onTertiaryContainer,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final class _ImportDropZone extends StatelessWidget {
  const _ImportDropZone({
    required this.copy,
    required this.sourceName,
    required this.preview,
    required this.isDragging,
    required this.onPickFile,
  });

  final WritellerCopy copy;
  final String? sourceName;
  final ProjectArchivePreview? preview;
  final bool isDragging;
  final VoidCallback onPickFile;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final borderColor = isDragging ? color.primary : color.outlineVariant;
    final background = isDragging
        ? color.primaryContainer.withValues(alpha: 0.45)
        : color.surfaceContainerHighest;
    final sourceName = this.sourceName;
    final preview = this.preview;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 140),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.file_upload_outlined, color: color.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      copy.t('dropImportFile'),
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      copy.t('dropImportFileBody'),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: color.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onPickFile,
            icon: const Icon(Icons.folder_open_outlined),
            label: Text(copy.t('chooseImportFile')),
          ),
          const SizedBox(height: 8),
          _HelpedLabel(
            label: copy.t('importSourceType'),
            help: copy.t('helpImportFile'),
            style: Theme.of(context).textTheme.labelSmall,
          ),
          if (sourceName != null || preview != null) ...[
            const SizedBox(height: 10),
            Text(
              [
                if (sourceName != null)
                  '${copy.t('selectedImportFile')}: $sourceName',
                if (preview != null)
                  '${copy.t('importSourceType')}: ${preview.sourceFormat}',
              ].join('\n'),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color.onSurfaceVariant,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}

final class _ImportArchivePreview extends StatelessWidget {
  const _ImportArchivePreview({
    required this.copy,
    required this.preview,
    required this.error,
  });

  final WritellerCopy copy;
  final ProjectArchivePreview? preview;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final preview = this.preview;
    final hasError = error != null && error!.isNotEmpty;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: hasError ? color.errorContainer : color.secondaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: preview == null
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.error_outline,
                      color: color.onErrorContainer, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      error ?? copy.t('archivePreviewInvalid'),
                      style: TextStyle(color: color.onErrorContainer),
                    ),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    preview.projectTitle,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: color.onSecondaryContainer,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    [
                      '${copy.t('importSourceType')}: ${preview.sourceFormat}',
                      if (preview.sourceName != null)
                        '${copy.t('selectedImportFile')}: ${preview.sourceName}',
                      '${copy.t('archiveSchema')}: ${preview.schema}',
                      '${copy.t('chapters')}: ${preview.chapterCount} - '
                          '${copy.t('scenes')}: ${preview.sceneCount}',
                      '${copy.t('catalog')}: ${preview.catalogItemCount} - '
                          '${copy.t('relationships')}: ${preview.relationshipCount}',
                      '${copy.t('notes')}: ${preview.noteCount}',
                    ].join('\n'),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: color.onSecondaryContainer,
                        ),
                  ),
                ],
              ),
      ),
    );
  }
}

final class _SettingsWorkspace extends StatelessWidget {
  const _SettingsWorkspace({
    required this.copy,
    required this.project,
    required this.aiEnabled,
    required this.cloudSyncEnabled,
    required this.noAiNoCloud,
    required this.providerNameController,
    required this.modelNameController,
    required this.baseUrlController,
    required this.apiKeyRefController,
    required this.providerKind,
    required this.providerEnabled,
    required this.providerHasStoredApiKey,
    required this.activeProviderConfig,
    required this.designTheme,
    required this.onDesignThemeChanged,
    required this.onProviderKindChanged,
    required this.onProviderEnabledChanged,
    required this.onSaveProviderConfig,
    required this.onDeleteProviderApiKey,
    required this.onSaveProjectMetadata,
    required this.onCreateLocalBackup,
    required this.onSaveProfileSettings,
    required this.spellCheckSettings,
    required this.onSpellCheckSettingsChanged,
    required this.syncAdapterName,
  });

  final WritellerCopy copy;
  final Project? project;
  final bool aiEnabled;
  final bool cloudSyncEnabled;
  final bool noAiNoCloud;
  final TextEditingController providerNameController;
  final TextEditingController modelNameController;
  final TextEditingController baseUrlController;
  final TextEditingController apiKeyRefController;
  final AIProviderKind providerKind;
  final bool providerEnabled;
  final bool providerHasStoredApiKey;
  final AIProviderConfig? activeProviderConfig;
  final WritellerDesignTheme designTheme;
  final ValueChanged<WritellerDesignTheme> onDesignThemeChanged;
  final ValueChanged<AIProviderKind> onProviderKindChanged;
  final ValueChanged<bool> onProviderEnabledChanged;
  final VoidCallback onSaveProviderConfig;
  final VoidCallback onDeleteProviderApiKey;
  final FutureOr<void> Function(_ProjectMetadataUpdate) onSaveProjectMetadata;
  final Future<void> Function() onCreateLocalBackup;
  final SpellCheckSettings spellCheckSettings;
  final ValueChanged<SpellCheckSettings> onSpellCheckSettingsChanged;
  final String syncAdapterName;
  final FutureOr<void> Function({
    required bool aiEnabled,
    required bool cloudSyncEnabled,
    required bool noAiNoCloud,
  }) onSaveProfileSettings;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final tabs = [
      _SettingsTabSpec(
        icon: Icons.assignment_outlined,
        label: copy.t('projectMetadata'),
        child: _SettingsSection(
          title: copy.t('projectMetadata'),
          help: copy.t('helpProjectMetadata'),
          body: copy.t('projectMetadataBody'),
          child: _ProjectMetadataSettings(
            copy: copy,
            project: project,
            onSave: onSaveProjectMetadata,
            onCreateLocalBackup: onCreateLocalBackup,
          ),
        ),
      ),
      _SettingsTabSpec(
        icon: Icons.key_outlined,
        label: copy.t('providerConfig'),
        child: _SettingsSection(
          title: copy.t('providerConfig'),
          help: copy.t('helpProviderKind'),
          body: copy.t('providerSettingsBody'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ProviderContextPrivacyNotice(copy: copy),
              const SizedBox(height: 14),
              DropdownButtonFormField<AIProviderKind>(
                initialValue: providerKind,
                icon: const Icon(Icons.keyboard_arrow_down_rounded),
                decoration: InputDecoration(
                  labelText: copy.t('providerKind'),
                  suffixIcon: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _HelpTooltip(message: copy.t('helpProviderKind')),
                  ),
                  suffixIconConstraints: const BoxConstraints(minWidth: 42),
                  border: const OutlineInputBorder(),
                ),
                items: [
                  for (final kind in AIProviderKind.values)
                    DropdownMenuItem(
                      value: kind,
                      child: Text(_providerKindLabel(kind, copy.languageCode)),
                    ),
                ],
                onChanged: (kind) {
                  if (kind != null) onProviderKindChanged(kind);
                },
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                value: providerEnabled,
                title: _HelpedLabel(
                  label: copy.t('providerEnabled'),
                  help: copy.t('helpProviderEnabled'),
                ),
                onChanged: onProviderEnabledChanged,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: providerNameController,
                decoration: InputDecoration(
                  labelText: copy.t('providerName'),
                  suffixIcon: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _HelpTooltip(message: copy.t('helpProviderName')),
                  ),
                  suffixIconConstraints: const BoxConstraints(minWidth: 42),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: modelNameController,
                decoration: InputDecoration(
                  labelText: copy.t('modelName'),
                  suffixIcon: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _HelpTooltip(message: copy.t('helpModelName')),
                  ),
                  suffixIconConstraints: const BoxConstraints(minWidth: 42),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: baseUrlController,
                decoration: InputDecoration(
                  labelText: copy.t('baseUrl'),
                  suffixIcon: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _HelpTooltip(message: copy.t('helpBaseUrl')),
                  ),
                  suffixIconConstraints: const BoxConstraints(minWidth: 42),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: apiKeyRefController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: copy.t('apiKeyRef'),
                  suffixIcon: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _HelpTooltip(message: copy.t('helpApiKey')),
                  ),
                  suffixIconConstraints: const BoxConstraints(minWidth: 42),
                  helperText: providerHasStoredApiKey
                      ? copy.t('apiKeyStoredHint')
                      : copy.t('apiKeyWebWarning'),
                  border: const OutlineInputBorder(),
                ),
              ),
              if (providerHasStoredApiKey) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: _ActionHelp(
                    message: copy.t('helpDeleteApiKey'),
                    child: OutlinedButton.icon(
                      onPressed: onDeleteProviderApiKey,
                      icon: const Icon(Icons.delete_outline),
                      label: Text(copy.t('deleteApiKey')),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: _ActionHelp(
                  message: copy.t('helpSaveProviderConfig'),
                  child: FilledButton.icon(
                    onPressed: onSaveProviderConfig,
                    icon: const Icon(Icons.save_outlined),
                    label: Text(copy.t('saveProviderConfig')),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '${copy.t('activeProvider')}: '
                '${activeProviderConfig?.displayName ?? providerNameController.text} - '
                '${activeProviderConfig?.modelName ?? modelNameController.text}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
      _SettingsTabSpec(
        icon: Icons.palette_outlined,
        label: copy.t('designSettings'),
        child: _SettingsSection(
          title: copy.t('designSettings'),
          help: copy.t('helpDesignSettings'),
          body: copy.t('designSettingsBody'),
          child: _DesignThemeSelector(
            copy: copy,
            value: designTheme,
            onChanged: onDesignThemeChanged,
          ),
        ),
      ),
      _SettingsTabSpec(
        icon: Icons.tune_outlined,
        label: copy.t('globalProfileSettings'),
        child: _SettingsSection(
          title: copy.t('globalProfileSettings'),
          help: copy.t('helpGlobalProfileSettings'),
          body: copy.t('globalProfileSettingsBody'),
          child: Column(
            children: [
              SwitchListTile(
                value: aiEnabled,
                title: _HelpedLabel(
                  label: copy.t('aiEnabled'),
                  help: copy.t('helpAiEnabled'),
                ),
                subtitle: Text(copy.t('globalAiEnabledHint')),
                onChanged: (value) => onSaveProfileSettings(
                  aiEnabled: value,
                  cloudSyncEnabled: cloudSyncEnabled,
                  noAiNoCloud: value ? false : noAiNoCloud,
                ),
              ),
              SwitchListTile(
                value: cloudSyncEnabled,
                title: _HelpedLabel(
                  label: copy.t('cloudSyncEnabled'),
                  help: copy.t('helpCloudSyncEnabled'),
                ),
                subtitle: Text(copy.t('globalCloudSyncHint')),
                onChanged: noAiNoCloud
                    ? null
                    : (value) => onSaveProfileSettings(
                          aiEnabled: aiEnabled,
                          cloudSyncEnabled: value,
                          noAiNoCloud: noAiNoCloud,
                        ),
              ),
              SwitchListTile(
                value: noAiNoCloud,
                title: _HelpedLabel(
                  label: copy.t('noAiNoCloud'),
                  help: copy.t('helpNoAiNoCloud'),
                ),
                subtitle: Text(copy.t('globalNoAiNoCloudHint')),
                onChanged: (value) => onSaveProfileSettings(
                  aiEnabled: value ? false : aiEnabled,
                  cloudSyncEnabled: value ? false : cloudSyncEnabled,
                  noAiNoCloud: value,
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Text(
                    '${copy.t('syncAdapter')}: $syncAdapterName. ${copy.t('syncAdapterHint')}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      _SettingsTabSpec(
        icon: Icons.spellcheck_outlined,
        label: copy.t('spellCheckSettings'),
        child: _SettingsSection(
          title: copy.t('spellCheckSettings'),
          help: copy.t('helpSpellCheckSettings'),
          body: copy.t('spellCheckSettingsBody'),
          child: _SpellCheckSettingsPanel(
            copy: copy,
            settings: spellCheckSettings,
            onlineBlocked: noAiNoCloud,
            onChanged: onSpellCheckSettingsChanged,
          ),
        ),
      ),
    ];

    return DefaultTabController(
      length: tabs.length,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 14),
            child: Text(
              copy.t('settings'),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              color: color.surfaceContainerLow,
              border: Border(
                top: BorderSide(color: color.outlineVariant),
                bottom: BorderSide(color: color.outlineVariant),
              ),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final scrollable = constraints.maxWidth < 980;
                final showIcons = constraints.maxWidth >= 760;
                return TabBar(
                  isScrollable: scrollable,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  labelPadding: const EdgeInsets.symmetric(horizontal: 10),
                  indicatorSize: TabBarIndicatorSize.label,
                  tabs: [
                    for (final tab in tabs)
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize:
                              scrollable ? MainAxisSize.min : MainAxisSize.max,
                          children: [
                            if (showIcons) ...[
                              Icon(tab.icon, size: 18),
                              const SizedBox(width: 8),
                            ],
                            Flexible(
                              child: Text(
                                tab.label,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                for (final tab in tabs) _SettingsTabPage(child: tab.child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

final class _SettingsTabSpec {
  const _SettingsTabSpec({
    required this.icon,
    required this.label,
    required this.child,
  });

  final IconData icon;
  final String label;
  final Widget child;
}

final class _SettingsTabPage extends StatelessWidget {
  const _SettingsTabPage({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        children: [child],
      ),
    );
  }
}

final class _ProviderContextPrivacyNotice extends StatelessWidget {
  const _ProviderContextPrivacyNotice({required this.copy});

  final WritellerCopy copy;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.tertiaryContainer.withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.tertiary.withValues(alpha: 0.34)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.privacy_tip_outlined,
              color: color.onTertiaryContainer,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    copy.t('aiProviderPrivacyTitle'),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: color.onTertiaryContainer,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    copy.t('aiProviderPrivacyBody'),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: color.onTertiaryContainer,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.title,
    required this.body,
    required this.child,
    this.help,
  });

  final String title;
  final String body;
  final Widget child;
  final String? help;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: color.outlineVariant),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              help == null
                  ? Text(title, style: Theme.of(context).textTheme.titleMedium)
                  : _HelpedLabel(
                      label: title,
                      help: help!,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
              const SizedBox(height: 4),
              Text(
                body,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: color.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 14),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

final class _ProjectMetadataUpdate {
  const _ProjectMetadataUpdate({
    required this.authorName,
    required this.projectType,
    required this.targetUnit,
    required this.targetValue,
    required this.localBackupDirectory,
    required this.autoBackupDisabled,
  });

  final String authorName;
  final String projectType;
  final _ProjectTargetUnit targetUnit;
  final int? targetValue;
  final String localBackupDirectory;
  final bool autoBackupDisabled;
}

final class _ProjectMetadataSettings extends StatefulWidget {
  const _ProjectMetadataSettings({
    required this.copy,
    required this.project,
    required this.onSave,
    required this.onCreateLocalBackup,
  });

  final WritellerCopy copy;
  final Project? project;
  final FutureOr<void> Function(_ProjectMetadataUpdate) onSave;
  final Future<void> Function() onCreateLocalBackup;

  @override
  State<_ProjectMetadataSettings> createState() =>
      _ProjectMetadataSettingsState();
}

final class _ProjectMetadataSettingsState
    extends State<_ProjectMetadataSettings> {
  late final TextEditingController _authorController = TextEditingController(
    text: _authorName,
  );
  late final TextEditingController _targetController = TextEditingController(
    text: _targetText,
  );
  late var _projectType = widget.project?.projectType ?? 'novel';
  late var _targetUnit = _initialTargetUnit;
  late var _localBackupDirectory = _initialLocalBackupDirectory;
  late var _autoBackupDisabled = _initialAutoBackupDisabled;

  String get _authorName =>
      widget.project?.metadata['authorName'] as String? ?? '';

  String get _initialLocalBackupDirectory =>
      widget.project?.metadata[_localBackupDirectoryKey] as String? ?? '';

  bool get _initialAutoBackupDisabled =>
      widget.project?.metadata[_autoBackupDisabledKey] == true;

  _ProjectTargetUnit get _initialTargetUnit {
    return widget.project?.metadata['targetUnit'] == 'pages'
        ? _ProjectTargetUnit.pages
        : _ProjectTargetUnit.words;
  }

  String get _targetText {
    final project = widget.project;
    if (project == null || project.wordTarget == null) return '';
    if (_initialTargetUnit == _ProjectTargetUnit.pages) {
      final pageTarget = _metadataInt(project.metadata['pageTarget']) ??
          (project.wordTarget! / _estimatedWordsPerPage).round();
      return '$pageTarget';
    }
    return '${project.wordTarget}';
  }

  @override
  void didUpdateWidget(covariant _ProjectMetadataSettings oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.project?.id != widget.project?.id) {
      _authorController.text = _authorName;
      _targetController.text = _targetText;
      _projectType = widget.project?.projectType ?? 'novel';
      _targetUnit = _initialTargetUnit;
      _localBackupDirectory = _initialLocalBackupDirectory;
      _autoBackupDisabled = _initialAutoBackupDisabled;
    }
  }

  @override
  void dispose() {
    _authorController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final project = widget.project;
    if (project == null) {
      return _EmptyInlineMessage(
          message: widget.copy.t('selectProjectForMetadata'));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _authorController,
          decoration: InputDecoration(
            labelText: widget.copy.t('authorName'),
            border: const OutlineInputBorder(),
          ),
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => unawaited(_save()),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: _projectType,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          decoration: InputDecoration(
            labelText: widget.copy.t('projectType'),
            border: const OutlineInputBorder(),
          ),
          items: [
            for (final option in _projectTypeOptions)
              DropdownMenuItem(
                value: option.value,
                child: Text(widget.copy.t(option.labelKey)),
              ),
          ],
          onChanged: (value) {
            if (value != null) setState(() => _projectType = value);
          },
        ),
        const SizedBox(height: 12),
        SegmentedButton<_ProjectTargetUnit>(
          segments: [
            ButtonSegment(
              value: _ProjectTargetUnit.words,
              icon: const Icon(Icons.notes_outlined),
              label: Text(widget.copy.t('targetUnitWords')),
            ),
            ButtonSegment(
              value: _ProjectTargetUnit.pages,
              icon: const Icon(Icons.description_outlined),
              label: Text(widget.copy.t('targetUnitPages')),
            ),
          ],
          selected: {_targetUnit},
          onSelectionChanged: (selection) {
            _changeTargetUnit(selection.single);
          },
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _targetController,
          decoration: InputDecoration(
            labelText: _targetUnit == _ProjectTargetUnit.pages
                ? widget.copy.t('pageTarget')
                : widget.copy.t('wordTarget'),
            helperText: _targetUnit == _ProjectTargetUnit.pages
                ? widget.copy.t('pageTargetHelper')
                : null,
            border: const OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => unawaited(_save()),
        ),
        const SizedBox(height: 12),
        Divider(color: Theme.of(context).colorScheme.outlineVariant),
        const SizedBox(height: 12),
        Text(
          widget.copy.t('localBackups'),
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 4),
        Text(
          widget.copy.t('localBackupSettingsBody'),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 12),
        _BackupDirectoryPicker(
          copy: widget.copy,
          directoryPath: _localBackupDirectory,
          onChoose: () async {
            final path = await FilePicker.getDirectoryPath(
              dialogTitle: widget.copy.t('chooseBackupFolder'),
              lockParentWindow: true,
            );
            if (path == null || !mounted) return;
            setState(() => _localBackupDirectory = path);
          },
          onClear: _localBackupDirectory.trim().isEmpty
              ? null
              : () => setState(() => _localBackupDirectory = ''),
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          value: _autoBackupDisabled,
          contentPadding: EdgeInsets.zero,
          title: Text(widget.copy.t('disableAutoBackup')),
          subtitle: Text(widget.copy.t('disableAutoBackupHint')),
          onChanged: (value) => setState(() => _autoBackupDisabled = value),
        ),
        if (_lastBackupText(project).isNotEmpty) ...[
          const SizedBox(height: 4),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.history_outlined),
            title: Text(widget.copy.t('lastLocalBackup')),
            subtitle: SelectableText(_lastBackupText(project)),
          ),
        ],
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton.icon(
              onPressed: () => unawaited(_save()),
              icon: const Icon(Icons.save_outlined),
              label: Text(widget.copy.t('saveProjectMetadata')),
            ),
            OutlinedButton.icon(
              onPressed:
                  _localBackupDirectory.trim().isEmpty || _autoBackupDisabled
                      ? null
                      : () => unawaited(_saveAndCreateBackup()),
              icon: const Icon(Icons.backup_outlined),
              label: Text(widget.copy.t('createBackupNow')),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _save() async {
    final targetText = _targetController.text.trim();
    await widget.onSave(
      _ProjectMetadataUpdate(
        authorName: _authorController.text,
        projectType: _projectType,
        targetUnit: _targetUnit,
        targetValue: targetText.isEmpty ? null : int.tryParse(targetText),
        localBackupDirectory: _localBackupDirectory,
        autoBackupDisabled: _autoBackupDisabled,
      ),
    );
  }

  Future<void> _saveAndCreateBackup() async {
    await _save();
    await widget.onCreateLocalBackup();
  }

  String _lastBackupText(Project project) {
    final path = project.metadata[_lastLocalBackupPathKey] as String? ?? '';
    final rawCreatedAt =
        project.metadata[_lastLocalBackupAtKey] as String? ?? '';
    final createdAt = DateTime.tryParse(rawCreatedAt)?.toLocal();
    if (path.isEmpty && createdAt == null) return '';
    final dateText = createdAt == null
        ? ''
        : MaterialLocalizations.of(context).formatShortDate(createdAt);
    final timeText = createdAt == null
        ? ''
        : TimeOfDay.fromDateTime(createdAt).format(context);
    final timestamp = [dateText, timeText].where((value) => value.isNotEmpty);
    return [
      if (timestamp.isNotEmpty) timestamp.join(', '),
      if (path.isNotEmpty) path,
    ].join('\n');
  }

  void _changeTargetUnit(_ProjectTargetUnit unit) {
    final converted = _convertedProjectTargetText(
      _targetController.text,
      from: _targetUnit,
      to: unit,
    );
    setState(() {
      _targetUnit = unit;
      if (converted != null) {
        _targetController.text = converted;
        _targetController.selection = TextSelection.collapsed(
          offset: converted.length,
        );
      }
    });
  }
}

final class _SpellCheckSettingsPanel extends StatelessWidget {
  const _SpellCheckSettingsPanel({
    required this.copy,
    required this.settings,
    required this.onlineBlocked,
    required this.onChanged,
  });

  final WritellerCopy copy;
  final SpellCheckSettings settings;
  final bool onlineBlocked;
  final ValueChanged<SpellCheckSettings> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SwitchListTile(
          value: onlineBlocked ? false : settings.enabled,
          title: _HelpedLabel(
            label: copy.t('spellCheckEnabled'),
            help: copy.t('helpSpellCheckEnabled'),
          ),
          subtitle: Text(
            onlineBlocked
                ? copy.t('spellCheckBlockedByLocalMode')
                : copy.t('spellCheckPrivacyHint'),
          ),
          onChanged: onlineBlocked
              ? null
              : (value) => onChanged(settings.copyWith(enabled: value)),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
          child: DropdownButtonFormField<String>(
            initialValue: settings.languageCode,
            icon: const Icon(Icons.keyboard_arrow_down_rounded),
            decoration: InputDecoration(
              labelText: copy.t('spellCheckLanguage'),
              border: const OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'de-DE', child: Text('Deutsch')),
              DropdownMenuItem(value: 'en-US', child: Text('English (US)')),
              DropdownMenuItem(value: 'en-GB', child: Text('English (UK)')),
            ],
            onChanged: (value) {
              if (value == null) return;
              onChanged(settings.copyWith(languageCode: value));
            },
          ),
        ),
        ListTile(
          leading: const Icon(Icons.cloud_queue_outlined),
          title: Text(copy.t('spellCheckProviderLanguageTool')),
          subtitle: Text(copy.t('spellCheckProviderHint')),
        ),
        ListTile(
          leading: const Icon(Icons.download_for_offline_outlined),
          title: Text(copy.t('spellCheckOfflineDictionaries')),
          subtitle: Text(copy.t('spellCheckOfflineDictionariesHint')),
          enabled: false,
        ),
      ],
    );
  }
}

final class _DesignThemeSelector extends StatelessWidget {
  const _DesignThemeSelector({
    required this.copy,
    required this.value,
    required this.onChanged,
  });

  final WritellerCopy copy;
  final WritellerDesignTheme value;
  final ValueChanged<WritellerDesignTheme> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final theme in WritellerDesignTheme.values)
          _DesignThemeSwatch(
            copy: copy,
            theme: theme,
            selected: theme == value,
            onTap: () => onChanged(theme),
          ),
      ],
    );
  }
}

final class _DesignThemeSwatch extends StatelessWidget {
  const _DesignThemeSwatch({
    required this.copy,
    required this.theme,
    required this.selected,
    required this.onTap,
  });

  final WritellerCopy copy;
  final WritellerDesignTheme theme;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = _tokensFor(theme);
    final color = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      selected: selected,
      label: _designThemeLabel(theme, copy),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          width: 150,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: selected
                ? color.primary.withValues(alpha: 0.10)
                : color.surfaceContainerLow,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected ? color.primary : color.outlineVariant,
              width: selected ? 1.6 : 1,
            ),
          ),
          child: Row(
            children: [
              _ThemeMiniature(tokens: tokens),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _designThemeLabel(theme, copy),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight:
                            selected ? FontWeight.w800 : FontWeight.w600,
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

final class _ThemeMiniature extends StatelessWidget {
  const _ThemeMiniature({required this.tokens});

  final _WritellerThemeTokens tokens;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 34,
      height: 30,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: tokens.surface,
          borderRadius: BorderRadius.circular(7),
          border: Border.all(color: tokens.outlineVariant),
        ),
        child: Align(
          alignment: Alignment.bottomRight,
          child: Container(
            width: 17,
            height: 17,
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: tokens.primary,
              borderRadius: BorderRadius.circular(5),
            ),
          ),
        ),
      ),
    );
  }
}
