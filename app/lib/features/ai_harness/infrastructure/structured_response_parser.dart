import 'dart:convert';

import '../../../core/domain/json_map.dart';

JsonMap? extractStructuredJson(String content) {
  final candidates = <String>[
    for (final match in RegExp(
      r'```(?:json)?\s*([\s\S]*?)```',
      caseSensitive: false,
    ).allMatches(content))
      if (match.group(1) != null) match.group(1)!,
    content,
    ..._balancedJsonObjects(content),
  ];

  for (final candidate in candidates) {
    try {
      final decoded = jsonDecode(candidate.trim());
      if (decoded is Map) return Map<String, Object?>.from(decoded);
    } on FormatException {
      continue;
    }
  }
  return null;
}

Iterable<String> _balancedJsonObjects(String content) sync* {
  for (var start = content.indexOf('{');
      start >= 0 && start < content.length;
      start = content.indexOf('{', start + 1)) {
    var depth = 0;
    var inString = false;
    var escaping = false;
    for (var index = start; index < content.length; index += 1) {
      final char = content[index];
      if (escaping) {
        escaping = false;
        continue;
      }
      if (char == '\\') {
        escaping = inString;
        continue;
      }
      if (char == '"') {
        inString = !inString;
        continue;
      }
      if (inString) continue;
      if (char == '{') depth += 1;
      if (char == '}') depth -= 1;
      if (depth == 0) {
        yield content.substring(start, index + 1);
        break;
      }
    }
  }
}
