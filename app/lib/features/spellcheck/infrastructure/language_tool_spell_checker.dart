import 'dart:convert';

import 'package:http/http.dart' as http;

import '../application/spell_checker.dart';
import '../domain/spell_check_issue.dart';
import '../domain/spell_check_settings.dart';

final class LanguageToolSpellChecker implements SpellChecker {
  LanguageToolSpellChecker({
    http.Client? client,
    Uri? endpoint,
  })  : _client = client ?? http.Client(),
        _endpoint =
            endpoint ?? Uri.parse('https://api.languagetool.org/v2/check');

  final http.Client _client;
  final Uri _endpoint;

  @override
  Future<List<SpellCheckIssue>> check({
    required String text,
    required SpellCheckSettings settings,
  }) async {
    if (text.trim().isEmpty) return const [];

    final response = await _client.post(
      _endpoint,
      headers: const {
        'Content-Type': 'application/x-www-form-urlencoded; charset=utf-8',
      },
      body: {
        'text': text,
        'language': settings.languageCode,
        'enabledOnly': 'false',
      },
    ).timeout(const Duration(seconds: 18));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError(
        'LanguageTool returned HTTP ${response.statusCode}: ${response.body}',
      );
    }

    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    final matches = decoded is Map<String, Object?> ? decoded['matches'] : null;
    if (matches is! List) return const [];

    return [
      for (final match in matches)
        if (match is Map)
          SpellCheckIssue(
            message: match['message'] as String? ?? '',
            context: _contextText(match),
            offset: (match['offset'] as num?)?.toInt() ?? 0,
            length: (match['length'] as num?)?.toInt() ?? 0,
            replacements: _replacementTexts(match['replacements']),
            ruleId: _ruleId(match),
          ),
    ];
  }

  static String _contextText(Map<dynamic, dynamic> match) {
    final context = match['context'];
    if (context is Map) return context['text'] as String? ?? '';
    return '';
  }

  static List<String> _replacementTexts(Object? value) {
    if (value is! List) return const [];
    return [
      for (final replacement in value.take(5))
        if (replacement is Map && replacement['value'] is String)
          replacement['value'] as String,
    ];
  }

  static String _ruleId(Map<dynamic, dynamic> match) {
    final rule = match['rule'];
    if (rule is Map) return rule['id'] as String? ?? '';
    return '';
  }
}
