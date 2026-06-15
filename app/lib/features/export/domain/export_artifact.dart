import 'dart:convert';
import 'dart:typed_data';

final class ExportArtifact {
  const ExportArtifact({
    required this.fileName,
    required this.mimeType,
    required this.bytes,
    required this.previewText,
    this.isText = false,
  });

  final String fileName;
  final String mimeType;
  final Uint8List bytes;
  final String previewText;
  final bool isText;

  String get clipboardText {
    if (isText) return utf8.decode(bytes);
    return 'data:$mimeType;base64,${base64Encode(bytes)}';
  }
}
