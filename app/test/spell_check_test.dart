import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:writeler/features/spellcheck/domain/spell_check_settings.dart';
import 'package:writeler/features/spellcheck/infrastructure/language_tool_spell_checker.dart';

void main() {
  test('LanguageTool spell checker parses matches and replacements', () async {
    final checker = LanguageToolSpellChecker(
      client: MockClient((request) async {
        expect(request.url.path, '/v2/check');
        expect(request.bodyFields['language'], 'de-DE');
        return http.Response(
          '''
{
  "matches": [
    {
      "message": "Möglicher Tippfehler gefunden.",
      "offset": 4,
      "length": 5,
      "replacements": [{"value": "Haus"}],
      "context": {"text": "Das Haus ist alt."},
      "rule": {"id": "MORFOLOGIK_RULE_DE_DE"}
    }
  ]
}
''',
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      }),
    );

    final issues = await checker.check(
      text: 'Das Hauz ist alt.',
      settings: SpellCheckSettings.fallback.copyWith(enabled: true),
    );

    expect(issues, hasLength(1));
    expect(issues.single.offset, 4);
    expect(issues.single.replacements, ['Haus']);
    expect(issues.single.ruleId, 'MORFOLOGIK_RULE_DE_DE');
  });
}
