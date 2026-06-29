# Writeller App

Flutter client for Writeller, an offline-first writing project harness.

## Platforms

Generated Flutter runners are present for:

- Web
- Android
- iOS
- Windows
- macOS

## Commands

```powershell
dart pub get
flutter analyze --no-pub
flutter test --no-pub
flutter build web --no-pub --no-web-resources-cdn
flutter run -d windows
flutter run -d chrome
```

If this project lives in OneDrive, prefer `dart pub get` plus Flutter commands with `--no-pub`; Flutter's native runner cache refresh can otherwise fail on generated `ephemeral` folders.

The domain and application layers are intentionally independent from Flutter UI and persistence adapters.

## Main Workspaces

- Projects: local project selection and metrics overview.
- Editor: manuscript, planning fields, scene context, focus mode, and find/replace.
- Scenes: chapter-oriented structure board with reorder and chapter reassignment actions.
- Catalog: characters, locations, and objects.
- AI Workshop: provider-backed suggestions that never mutate manuscript text directly.
- Export: Markdown, HTML, TXT, outline, and JSON archive copy/import flow.
- Settings: privacy toggles and AI provider configuration with secure key storage.
