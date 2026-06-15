enum EntityType {
  workspace,
  project,
  projectPart,
  chapter,
  scene,
  character,
  location,
  object,
  timelineEvent,
  arc,
  relationship,
  note,
  researchItem,
  promptTemplate,
  aiInteraction,
  aiSuggestion,
  metricEvent,
  exportProfile,
  tag,
  customFieldDefinition,
  entityRevision,
}

extension EntityTypeWire on EntityType {
  String get wireName => name;

  static EntityType parse(String value) {
    return EntityType.values.firstWhere(
      (type) => type.name == value,
      orElse: () => throw ArgumentError.value(value, 'value', 'Unknown entity type'),
    );
  }
}
