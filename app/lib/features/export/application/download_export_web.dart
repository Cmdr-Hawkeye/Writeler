import 'dart:js_interop';

import 'package:web/web.dart' as web;

import '../domain/export_artifact.dart';

Future<bool> downloadExportArtifact(ExportArtifact artifact) async {
  final blob = web.Blob(
    [artifact.bytes.toJS].toJS,
    web.BlobPropertyBag(type: artifact.mimeType),
  );
  final url = web.URL.createObjectURL(blob);
  final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
  try {
    anchor
      ..href = url
      ..download = artifact.fileName;
    anchor.style.display = 'none';
    web.document.body?.append(anchor);
    anchor.click();
    return true;
  } finally {
    anchor.remove();
    web.URL.revokeObjectURL(url);
  }
}
