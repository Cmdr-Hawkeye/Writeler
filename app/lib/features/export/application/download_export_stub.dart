import 'package:file_picker/file_picker.dart';

import '../domain/export_artifact.dart';

Future<bool> downloadExportArtifact(ExportArtifact artifact) async {
  final extension = artifact.fileName.contains('.')
      ? artifact.fileName.split('.').last
      : null;
  final path = await FilePicker.saveFile(
    dialogTitle: artifact.fileName,
    fileName: artifact.fileName,
    type: extension == null ? FileType.any : FileType.custom,
    allowedExtensions: extension == null ? null : [extension],
    bytes: artifact.bytes,
    lockParentWindow: true,
  );
  return path != null;
}
