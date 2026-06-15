enum DraftStatus {
  idea,
  planned,
  outlined,
  drafting,
  needsRevision,
  revised,
  reviewed,
  locked,
  archived,
}

extension DraftStatusWire on DraftStatus {
  String get wireName => name;

  static DraftStatus parse(String value) {
    return DraftStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () =>
          throw ArgumentError.value(value, 'value', 'Unknown draft status'),
    );
  }
}
