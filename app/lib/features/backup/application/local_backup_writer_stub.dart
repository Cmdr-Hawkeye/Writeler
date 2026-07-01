import 'dart:typed_data';

final class LocalBackupWriteResult {
  const LocalBackupWriteResult({
    required this.supported,
    this.filePath,
    this.error,
  });

  final bool supported;
  final String? filePath;
  final Object? error;

  bool get succeeded => supported && filePath != null && error == null;
}

Future<LocalBackupWriteResult> writeRollingLocalBackup({
  required String directoryPath,
  required String projectTitle,
  required Uint8List bytes,
  required DateTime now,
}) async {
  return const LocalBackupWriteResult(supported: false);
}
