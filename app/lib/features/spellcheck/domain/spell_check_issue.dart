final class SpellCheckIssue {
  const SpellCheckIssue({
    required this.message,
    required this.context,
    required this.offset,
    required this.length,
    required this.replacements,
    required this.ruleId,
  });

  final String message;
  final String context;
  final int offset;
  final int length;
  final List<String> replacements;
  final String ruleId;
}
