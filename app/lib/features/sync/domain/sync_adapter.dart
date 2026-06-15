import '../../export/application/project_archive_codec.dart';
import 'sync_checkpoint.dart';

abstract interface class SyncAdapter {
  String get adapterName;

  SyncCheckpoint createCheckpoint(ProjectArchive archive);

  SyncPayloadInspection inspectPayload(String source);
}
