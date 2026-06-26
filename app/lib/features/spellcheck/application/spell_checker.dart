import '../domain/spell_check_issue.dart';
import '../domain/spell_check_settings.dart';

abstract interface class SpellChecker {
  Future<List<SpellCheckIssue>> check({
    required String text,
    required SpellCheckSettings settings,
  });
}
