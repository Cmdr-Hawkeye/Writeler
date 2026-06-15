# Testing

## Test Types

- Unit tests for domain policies and value logic.
- Repository tests for persistence adapters.
- Migration tests with realistic project data.
- Export/import roundtrip tests.
- Widget tests for navigation, localization, and AI boundary UI.
- End-to-end tests for project creation, writing, export, and provider configuration.

## Current Tests

- project and scene validation
- scene word count derivation
- AI suggestion boundary
- AI disabled project behavior
- Drift schema version and table creation
- persisted project repository roundtrip
- persisted scene repository ordering and manuscript text roundtrip
- Markdown and JSON export
- widget smoke test for project creation

Run from `app`:

```powershell
dart pub get
flutter analyze --no-pub
flutter test --no-pub
flutter build web --no-pub --no-web-resources-cdn
```

In OneDrive workspaces, `flutter pub get` may fail while refreshing generated iOS/macOS runner caches. `dart pub get` is the stable dependency command for this local setup.
