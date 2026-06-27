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

  final WritelerCopy copy;
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
    required this.onDownload,
  });

  final WritelerCopy copy;
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
                  child: SelectableText(
                    preview.isEmpty ? copy.t('nothingToExport') : preview,
                    style: const TextStyle(fontFamily: 'monospace'),
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

  final WritelerCopy copy;
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

  final WritelerCopy copy;
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

  final WritelerCopy copy;
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

  final WritelerCopy copy;
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
    required this.onSaveProfileSettings,
    required this.spellCheckSettings,
    required this.onSpellCheckSettingsChanged,
    required this.syncAdapterName,
  });

  final WritelerCopy copy;
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
  final WritelerDesignTheme designTheme;
  final ValueChanged<WritelerDesignTheme> onDesignThemeChanged;
  final ValueChanged<AIProviderKind> onProviderKindChanged;
  final ValueChanged<bool> onProviderEnabledChanged;
  final VoidCallback onSaveProviderConfig;
  final VoidCallback onDeleteProviderApiKey;
  final ValueChanged<_ProjectMetadataUpdate> onSaveProjectMetadata;
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
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(copy.t('settings'),
            style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        _SettingsSection(
          title: copy.t('designSettings'),
          help: copy.t('helpDesignSettings'),
          body: copy.t('designSettingsBody'),
          child: _DesignThemeSelector(
            copy: copy,
            value: designTheme,
            onChanged: onDesignThemeChanged,
          ),
        ),
        _SettingsSection(
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
        _SettingsSection(
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
        _SettingsSection(
          title: copy.t('projectMetadata'),
          help: copy.t('helpProjectMetadata'),
          body: copy.t('projectMetadataBody'),
          child: _ProjectMetadataSettings(
            copy: copy,
            project: project,
            onSave: onSaveProjectMetadata,
          ),
        ),
        _SettingsSection(
          title: copy.t('providerConfig'),
          help: copy.t('helpProviderKind'),
          body: copy.t('providerSettingsBody'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
      ],
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
  });

  final String authorName;
  final String projectType;
  final _ProjectTargetUnit targetUnit;
  final int? targetValue;
}

final class _ProjectMetadataSettings extends StatefulWidget {
  const _ProjectMetadataSettings({
    required this.copy,
    required this.project,
    required this.onSave,
  });

  final WritelerCopy copy;
  final Project? project;
  final ValueChanged<_ProjectMetadataUpdate> onSave;

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

  String get _authorName =>
      widget.project?.metadata['authorName'] as String? ?? '';

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
          onSubmitted: (_) => _save(),
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
            setState(() => _targetUnit = selection.single);
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
          onSubmitted: (_) => _save(),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: _save,
          icon: const Icon(Icons.save_outlined),
          label: Text(widget.copy.t('saveProjectMetadata')),
        ),
      ],
    );
  }

  void _save() {
    final targetText = _targetController.text.trim();
    widget.onSave(
      _ProjectMetadataUpdate(
        authorName: _authorController.text,
        projectType: _projectType,
        targetUnit: _targetUnit,
        targetValue: targetText.isEmpty ? null : int.tryParse(targetText),
      ),
    );
  }
}

final class _SpellCheckSettingsPanel extends StatelessWidget {
  const _SpellCheckSettingsPanel({
    required this.copy,
    required this.settings,
    required this.onlineBlocked,
    required this.onChanged,
  });

  final WritelerCopy copy;
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

  final WritelerCopy copy;
  final WritelerDesignTheme value;
  final ValueChanged<WritelerDesignTheme> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final theme in WritelerDesignTheme.values)
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

  final WritelerCopy copy;
  final WritelerDesignTheme theme;
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

  final _WritelerThemeTokens tokens;

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
