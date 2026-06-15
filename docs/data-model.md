# Data Model

## Core Entities

- Workspace: settings, provider configs, themes, languages, local metrics.
- Project: book, series, nonfiction work, screenplay, or other writing project.
- ProjectPart: flexible structural level such as volume, part, act, or section.
- Chapter: logical container.
- Scene: smallest narrative work unit with manuscript text and planning metadata.
- CatalogItem: generic character, location, object, organization, symbol, or custom entity.
- Relationship: generic typed link between any two entity references.
- AISuggestion: stored AI output that requires explicit user decision.
- MetricEvent: local event for writing progress and system diagnostics.
- ExportProfile: reusable export configuration.

## Current Code Coverage

Implemented:

- `Project`
- `Chapter`
- `Scene`
- `CatalogItem`
- `Relationship`
- `AISuggestion`
- `MetricEvent`
- `ExportProfile`

Persisted with Drift schema version 1:

- `projects`
- `scenes`

## Relationship Model

Relationships use entity references rather than fixed foreign-key pairs in the domain layer. The persistence adapter should index:

- `projectId`
- `source.type + source.id`
- `target.type + target.id`
- `relationshipType`

## Migration Strategy

Persistence uses Drift with `AppDatabase.schemaVersion == 1`. Every future migration must include:

- forward migration
- sample project fixture
- repository test after migration
- export/import roundtrip test for migrated data

## Local Storage Target

Native platforms should use SQLite through Drift. Web should use an IndexedDB or SQLite-WASM adapter behind the same repository contracts.

The first implementation uses `drift_flutter.driftDatabase(name: 'writeler')` for runtime database opening. Tests use `NativeDatabase.memory()` to keep repository tests fast and deterministic.
