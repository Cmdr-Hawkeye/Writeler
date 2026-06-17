# Project Status

Last updated: 2026-06-17

## Implemented

- Flutter app shell with German and English UI copy.
- Local-first Drift/SQLite persistence for projects, chapters, scenes, catalog items, relationships, project notes, AI suggestions, provider configuration, and metrics.
- Web SQLite support through `sqlite3.wasm` and `drift_worker.js`.
- Editor workspace with scene planning, manuscript editing, word target progress, focus mode, and find/replace.
- Chapter-oriented scene board with scene ordering, chapter reassignment, and a structure inspector for weak spots.
- Catalog workspaces for characters, locations, and objects.
- Scene context links between scenes and catalog entities.
- Project notes workspace with project, scene, and catalog-targeted notes.
- AI workshop with persisted suggestions, prompt transparency, custom prompts, and explicit accept/reject/note decisions.
- Accepted structure suggestions can update scene planning fields while manuscript text stays under author control.
- Provider settings with secure API key storage.
- Provider adapters for mock, OpenAI-compatible APIs, OpenRouter, Anthropic, Gemini, and Ollama.
- Import/export for Markdown, HTML, TXT manuscript, outline, Writeler JSON archives, PDF, EPUB, and DOCX, including readable notes in project-oriented formats.
- Manual sync checkpoints with envelope metadata, fingerprint validation, clipboard handoff, import support, and local sync metrics.
- Native app identity metadata, app icons, web manifest, platform bundle IDs, release scripts, and release checklist.
- Local metrics for project, scene, chapter, catalog, relationship, AI, import, and export events.

## Verified Locally

```powershell
dart pub get
flutter analyze --no-pub
flutter test --no-pub
flutter build web --no-pub --no-web-resources-cdn --pwa-strategy=none
flutter build apk --no-pub --release
flutter build appbundle --no-pub --release
```

Current test count: 29 passing tests.

Current local native build note: Android APK and AAB builds succeed on the Windows workstation. Windows desktop release build is blocked until Visual Studio with the "Desktop development with C++" workload is installed.

## Known Gaps

- Cloud-backed sync providers such as WebDAV, Supabase/Postgres, or CRDT services are not connected yet.
- Store signing, notarization, and installer packaging remain environment-specific release tasks.
- `flutter_secure_storage_web` works for regular web builds but is not compatible with Flutter's current WASM dry run.
- Higher-fidelity PDF/DOCX layout controls and render verification are still pending.

## Source Brief

The original product prompt is archived at `docs/spec/writeler_prompt.html` for traceability.
