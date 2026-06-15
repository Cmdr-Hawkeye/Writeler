import '../../../core/domain/json_map.dart';

final class SyncCheckpoint {
  const SyncCheckpoint({
    required this.adapterName,
    required this.projectId,
    required this.projectTitle,
    required this.createdAt,
    required this.fingerprint,
    required this.byteLength,
    required this.archiveSource,
    required this.payload,
    required this.chapterCount,
    required this.sceneCount,
    required this.catalogItemCount,
    required this.relationshipCount,
  });

  final String adapterName;
  final String projectId;
  final String projectTitle;
  final DateTime createdAt;
  final String fingerprint;
  final int byteLength;
  final String archiveSource;
  final String payload;
  final int chapterCount;
  final int sceneCount;
  final int catalogItemCount;
  final int relationshipCount;
}

final class SyncPayloadInspection {
  const SyncPayloadInspection({
    required this.archiveSource,
    this.envelope,
  });

  final String archiveSource;
  final SyncEnvelopePreview? envelope;

  bool get isEnvelope => envelope != null;
}

final class SyncEnvelopePreview {
  const SyncEnvelopePreview({
    required this.adapterName,
    required this.createdAt,
    required this.fingerprint,
    required this.byteLength,
  });

  final String adapterName;
  final DateTime createdAt;
  final String fingerprint;
  final int byteLength;

  JsonMap toJson() => {
        'adapterName': adapterName,
        'createdAt': createdAt.toIso8601String(),
        'fingerprint': fingerprint,
        'byteLength': byteLength,
      };
}
