import '../domain/export_artifact.dart';
import 'download_export_stub.dart'
    if (dart.library.html) 'download_export_web.dart' as platform;

Future<bool> downloadExportArtifact(ExportArtifact artifact) {
  return platform.downloadExportArtifact(artifact);
}
