import 'dart:io';
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
  try {
    final directory = Directory(directoryPath);
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    final projectSlug = _fileSlug(projectTitle);
    final backupFilePattern = RegExp(
      '^backup_${RegExp.escape(projectSlug)}_\\d{8}_\\d{6}\\.writeller\\.json\$',
    );
    final existingBackups = <File>[];
    await for (final entity in directory.list(followLinks: false)) {
      if (entity is! File) continue;
      final name = Uri.decodeComponent(entity.uri.pathSegments.last);
      if (backupFilePattern.hasMatch(name)) {
        existingBackups.add(entity);
      }
    }
    existingBackups.sort((left, right) => left.path.compareTo(right.path));
    while (existingBackups.length >= 3) {
      final oldest = existingBackups.removeAt(0);
      if (await oldest.exists()) {
        await oldest.delete();
      }
    }

    final fileName = 'backup_${projectSlug}_${_timestamp(now)}.writeller.json';
    final target = File('${directory.path}${Platform.pathSeparator}$fileName');
    await target.writeAsBytes(bytes, flush: true);
    return LocalBackupWriteResult(
      supported: true,
      filePath: target.path,
    );
  } catch (error) {
    return LocalBackupWriteResult(supported: true, error: error);
  }
}

String _fileSlug(String value) {
  final normalized = value
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');
  return normalized.isEmpty ? 'project' : normalized;
}

String _timestamp(DateTime value) {
  final local = value.toLocal();
  String two(int number) => number.toString().padLeft(2, '0');
  return '${local.year}'
      '${two(local.month)}'
      '${two(local.day)}_'
      '${two(local.hour)}'
      '${two(local.minute)}'
      '${two(local.second)}';
}
