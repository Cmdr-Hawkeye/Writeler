import 'dart:convert';

import '../../../core/domain/domain_failure.dart';
import '../../../core/domain/json_map.dart';
import '../../export/application/project_archive_codec.dart';
import '../domain/sync_adapter.dart';
import '../domain/sync_checkpoint.dart';

final class ManualSyncAdapter implements SyncAdapter {
  const ManualSyncAdapter({
    this.archiveCodec = const ProjectArchiveCodec(),
  });

  static const syncSchema = 'writeller.sync.v1';
  static const legacySyncSchema = 'writeler.sync.v1';

  final ProjectArchiveCodec archiveCodec;

  @override
  String get adapterName => 'manual-archive';

  @override
  SyncCheckpoint createCheckpoint(ProjectArchive archive) {
    final archiveSource = archiveCodec.encode(archive);
    final fingerprint = _fingerprint(archiveSource);
    final byteLength = utf8.encode(archiveSource).length;
    final createdAt = DateTime.now().toUtc();
    final payload = const JsonEncoder.withIndent('  ').convert({
      'schema': syncSchema,
      'adapter': adapterName,
      'createdAt': createdAt.toIso8601String(),
      'fingerprint': fingerprint,
      'byteLength': byteLength,
      'archive': jsonDecode(archiveSource),
    });

    return SyncCheckpoint(
      adapterName: adapterName,
      projectId: archive.project.id,
      projectTitle: archive.project.title,
      createdAt: createdAt,
      fingerprint: fingerprint,
      byteLength: byteLength,
      archiveSource: archiveSource,
      payload: payload,
      chapterCount: archive.chapters.length,
      sceneCount: archive.scenes.length,
      catalogItemCount: archive.catalogItems.length,
      relationshipCount: archive.relationships.length,
    );
  }

  @override
  SyncPayloadInspection inspectPayload(String source) {
    final decoded = jsonDecode(source);
    if (decoded is! Map) {
      throw const DomainFailure('Sync payload must be a JSON object.');
    }

    final json = Map<String, Object?>.from(decoded);
    if (json['schema'] != syncSchema && json['schema'] != legacySyncSchema) {
      return SyncPayloadInspection(archiveSource: source);
    }

    final archiveJson = _object(json['archive'], 'archive');
    final archiveSource =
        const JsonEncoder.withIndent('  ').convert(archiveJson);
    final expectedFingerprint = json['fingerprint'] as String?;
    final actualFingerprint = _fingerprint(archiveSource);
    if (expectedFingerprint != null &&
        expectedFingerprint != actualFingerprint) {
      throw DomainFailure(
        'Sync checkpoint fingerprint mismatch: expected $expectedFingerprint, got $actualFingerprint.',
      );
    }

    final byteLength =
        json['byteLength'] as int? ?? utf8.encode(archiveSource).length;
    final createdAtRaw = json['createdAt'] as String?;
    final createdAt = createdAtRaw == null
        ? DateTime.now().toUtc()
        : DateTime.parse(createdAtRaw);
    return SyncPayloadInspection(
      archiveSource: archiveSource,
      envelope: SyncEnvelopePreview(
        adapterName: json['adapter'] as String? ?? adapterName,
        createdAt: createdAt,
        fingerprint: actualFingerprint,
        byteLength: byteLength,
      ),
    );
  }

  JsonMap _object(Object? value, String fieldName) {
    if (value is! Map) {
      throw DomainFailure('Sync payload field "$fieldName" must be an object.');
    }
    return Map<String, Object?>.from(value);
  }

  String _fingerprint(String source) {
    var hash = 0x811c9dc5;
    for (final byte in utf8.encode(source)) {
      hash ^= byte;
      hash = (hash * 0x01000193).toUnsigned(32);
    }
    return hash.toRadixString(16).padLeft(8, '0');
  }
}
