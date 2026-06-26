enum SpellCheckProvider {
  languagetoolPublic,
}

final class SpellCheckSettings {
  const SpellCheckSettings({
    required this.enabled,
    required this.languageCode,
    required this.provider,
  });

  static const fallback = SpellCheckSettings(
    enabled: false,
    languageCode: 'de-DE',
    provider: SpellCheckProvider.languagetoolPublic,
  );

  final bool enabled;
  final String languageCode;
  final SpellCheckProvider provider;

  SpellCheckSettings copyWith({
    bool? enabled,
    String? languageCode,
    SpellCheckProvider? provider,
  }) {
    return SpellCheckSettings(
      enabled: enabled ?? this.enabled,
      languageCode: languageCode ?? this.languageCode,
      provider: provider ?? this.provider,
    );
  }
}

extension SpellCheckProviderWire on SpellCheckProvider {
  String get wireName {
    return switch (this) {
      SpellCheckProvider.languagetoolPublic => 'languagetoolPublic',
    };
  }

  static SpellCheckProvider parse(String? value) {
    return switch (value) {
      'languagetoolPublic' => SpellCheckProvider.languagetoolPublic,
      _ => SpellCheckProvider.languagetoolPublic,
    };
  }
}
