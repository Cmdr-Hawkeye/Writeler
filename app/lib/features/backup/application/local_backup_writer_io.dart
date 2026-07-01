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
  required Uint8List bytes,
  required DateTime now,
}) async {
  try {
    final directory = Directory(directoryPath);
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    final existingBackups = <File>[];
    await for (final entity in directory.list(followLinks: false)) {
      if (entity is! File) continue;
      final name = Uri.decodeComponent(entity.uri.pathSegments.last);
      if (_backupFilePattern.hasMatch(name)) {
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

    final fileName = 'backup_${_timestamp(now)}.writeller.json';
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

final _backupFilePattern = RegExp(r'^backup_\d{8}_\d{6}\.writeller\.json$');

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
