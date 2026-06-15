# Project Status

Last updated: 2026-06-15

## Implemented

- Flutter app shell with German and English UI copy.
- Local-first Drift/SQLite persistence for projects, chapters, scenes, catalog items, relationships, AI suggestions, provider configuration, and metrics.
- Web SQLite support through `sqlite3.wasm` and `drift_worker.js`.
- Editor workspace with scene planning, manuscript editing, word target progress, focus mode, and find/replace.
- Chapter-oriented scene board with scene ordering and chapter reassignment.
- Catalog workspaces for characters, locations, and objects.
- Scene context links between scenes and catalog entities.
- AI workshop with persisted suggestions and explicit accept/reject/note decisions.
- Provider settings with secure API key storage.
- Provider adapters for mock, OpenAI-compatible APIs, OpenRouter, Anthropic, Gemini, and Ollama.
- Import/export for Markdown, HTML, TXT manuscript, outline, and Writeler JSON archives.
- Local metrics for project, scene, chapter, catalog, relationship, AI, import, and export events.

## Verified Locally

```powershell
dart pub get
flutter analyze --no-pub
flutter test --no-pub
flutter build web --no-pub --no-web-resources-cdn
```

Current test count: 22 passing tests.

## Known Gaps

- Sync is still a design-level feature and needs a concrete adapter implementation.
- Native platform release polish is pending for Windows, Android, iOS, and macOS.
- `flutter_secure_storage_web` works for regular web builds but is not compatible with Flutter's current WASM dry run.
- DOCX, PDF, and EPUB export adapters are planned but not implemented.

## Source Brief

The original product prompt is archived at `docs/spec/writeler_prompt.html` for traceability.
