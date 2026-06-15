import 'dart:convert';
import 'dart:typed_data';

final class StoredZipArchive {
  StoredZipArchive();

  final List<_ZipEntry> _entries = [];

  void addText(String path, String content) {
    addBytes(path, Uint8List.fromList(utf8.encode(content)));
  }

  void addBytes(String path, Uint8List bytes) {
    _entries.add(_ZipEntry(path: path, bytes: bytes, crc32: _crc32(bytes)));
  }

  Uint8List encode() {
    final output = BytesBuilder(copy: false);
    final centralDirectory = BytesBuilder(copy: false);
    var offset = 0;

    for (final entry in _entries) {
      final fileName = utf8.encode(entry.path);
      _writeUint32(output, 0x04034b50);
      _writeUint16(output, 20);
      _writeUint16(output, 0);
      _writeUint16(output, 0);
      _writeUint16(output, 0);
      _writeUint16(output, 0);
      _writeUint32(output, entry.crc32);
      _writeUint32(output, entry.bytes.length);
      _writeUint32(output, entry.bytes.length);
      _writeUint16(output, fileName.length);
      _writeUint16(output, 0);
      output.add(fileName);
      output.add(entry.bytes);

      _writeUint32(centralDirectory, 0x02014b50);
      _writeUint16(centralDirectory, 20);
      _writeUint16(centralDirectory, 20);
      _writeUint16(centralDirectory, 0);
      _writeUint16(centralDirectory, 0);
      _writeUint16(centralDirectory, 0);
      _writeUint16(centralDirectory, 0);
      _writeUint32(centralDirectory, entry.crc32);
      _writeUint32(centralDirectory, entry.bytes.length);
      _writeUint32(centralDirectory, entry.bytes.length);
      _writeUint16(centralDirectory, fileName.length);
      _writeUint16(centralDirectory, 0);
      _writeUint16(centralDirectory, 0);
      _writeUint16(centralDirectory, 0);
      _writeUint16(centralDirectory, 0);
      _writeUint32(centralDirectory, 0);
      _writeUint32(centralDirectory, offset);
      centralDirectory.add(fileName);

      offset += 30 + fileName.length + entry.bytes.length;
    }

    final directoryBytes = centralDirectory.toBytes();
    output.add(directoryBytes);
    _writeUint32(output, 0x06054b50);
    _writeUint16(output, 0);
    _writeUint16(output, 0);
    _writeUint16(output, _entries.length);
    _writeUint16(output, _entries.length);
    _writeUint32(output, directoryBytes.length);
    _writeUint32(output, offset);
    _writeUint16(output, 0);
    return output.toBytes();
  }

  int _crc32(Uint8List bytes) {
    var crc = 0xffffffff;
    for (final byte in bytes) {
      crc ^= byte;
      for (var i = 0; i < 8; i++) {
        final mask = -(crc & 1);
        crc = (crc >> 1) ^ (0xedb88320 & mask);
      }
    }
    return (crc ^ 0xffffffff).toUnsigned(32);
  }

  void _writeUint16(BytesBuilder output, int value) {
    output.add([value & 0xff, (value >> 8) & 0xff]);
  }

  void _writeUint32(BytesBuilder output, int value) {
    output.add([
      value & 0xff,
      (value >> 8) & 0xff,
      (value >> 16) & 0xff,
      (value >> 24) & 0xff,
    ]);
  }
}

final class _ZipEntry {
  const _ZipEntry({
    required this.path,
    required this.bytes,
    required this.crc32,
  });

  final String path;
  final Uint8List bytes;
  final int crc32;
}
