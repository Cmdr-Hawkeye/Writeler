# Writeler

Writeler is an offline-first writing project harness for authors. It models books as connected projects made of parts, chapters, scenes, characters, locations, objects, arcs, notes, research items, AI suggestions, metrics, and export profiles.

The first implementation target is Flutter with a Clean Architecture layout so one codebase can support Web, Android, iOS, Windows, and macOS. Local storage is the default. Cloud sync and AI providers are adapter-based and optional.

## Current State

This repository contains a working Flutter implementation of the local-first Writeler foundation:

- persisted projects, chapters, scenes, catalog items, relationships, AI suggestions, provider settings, and local metrics
- a manuscript editor with planning fields, scene context links, live word/character counts, focus mode, and find/replace
- a chapter-oriented scene board with scene reordering and chapter reassignment
- AI provider adapters for OpenAI-compatible APIs, OpenRouter, Anthropic, Gemini, Ollama, and a local mock provider
- secure API key storage through a vault abstraction backed by `flutter_secure_storage`
- import/export for Markdown, HTML, TXT manuscript, outline, full Writeler JSON archives, PDF, EPUB, and DOCX
- manual sync checkpoints that wrap full project archives with adapter metadata and fingerprint validation
- German and English UI copy
- Drift/SQLite local persistence for native and web, including SQLite WASM assets
- architecture, privacy, sync, export, testing, user, and developer documentation

Flutter web builds and the local test suite pass. Native Windows, Android, iOS, and macOS folders are present and ready for platform-specific finishing.

## Setup

1. Install Flutter stable from https://docs.flutter.dev/get-started/install.
2. Confirm the toolchain:

```powershell
flutter doctor
dart --version
```

3. Install dependencies:

```powershell
cd app
dart pub get
```

4. Run tests:

```powershell
flutter analyze --no-pub
flutter test --no-pub
```

5. Run the app:

```powershell
flutter run -d windows
flutter run -d chrome
```

6. Build web without external CDN resources:

```powershell
.\scripts\build_web_assets.ps1
cd app
flutter build web --no-pub --no-web-resources-cdn
```

7. Serve the web build locally:

```powershell
python -m http.server 8090 --directory app/build/web
```

Then open `http://127.0.0.1:8090`.

On this OneDrive workspace, `flutter pub get` can trip over generated iOS/macOS `ephemeral` cache folders. `dart pub get` followed by Flutter commands with `--no-pub` avoids that local filesystem issue.

Native build prerequisites from the current machine:

- Windows builds need Visual Studio with the "Desktop development with C++" workload.
- Android builds need Android SDK 36, BuildTools 28.0.3 or newer, and accepted Android licenses.

## Architecture

The code is split into four layers:

- `domain`: entities, value objects, policies, repository contracts
- `application`: use cases and orchestration
- `infrastructure`: provider and persistence adapters
- `presentation`: Flutter UI and localized copy

The AI harness is intentionally separated from manuscript text. AI responses are stored as suggestions and cannot overwrite author text without an explicit user decision.

## Documentation

See:

- [Architecture](docs/architecture.md)
- [Data Model](docs/data-model.md)
- [AI Boundaries](docs/ai-boundaries.md)
- [Sync Strategy](docs/sync-strategy.md)
- [Privacy and Security](docs/privacy-security.md)
- [User Guide](docs/user-guide.md)
- [Developer Guide](docs/developer-guide.md)
- [Export Formats](docs/export-formats.md)
- [Testing](docs/testing.md)
- [Original Product Prompt](docs/spec/writeler_prompt.html)
