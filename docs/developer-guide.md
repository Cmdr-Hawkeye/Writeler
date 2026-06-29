# Developer Guide

## Module Layout

- `core`: shared domain primitives.
- `features/projects`: project model and repository contract.
- `features/structure`: chapters, scenes, and scene use cases.
- `features/catalog`: generic entities and relationships.
- `features/ai_harness`: AI policy, provider contract, suggestions.
- `features/export`: export profiles and export service.
- `features/metrics`: local metric events.
- `features/settings`: provider configuration.

## Adding Persistence

Implement repository contracts in infrastructure modules. Do not import Drift or platform storage into domain or application files.

Current persisted adapters:

- `DriftProjectRepository`
- `DriftSceneRepository`
- `DriftChapterRepository`
- `DriftCatalogItemRepository`
- `DriftRelationshipRepository`
- `DriftAISuggestionRepository`
- `DriftAIProviderConfigRepository`
- `DriftMetricRepository`

The database is defined in `core/infrastructure/database/app_database.dart` and generated with:

```powershell
dart run build_runner build
```

Web persistence also requires `web/sqlite3.wasm` and a compiled `web/drift_worker.js`. Rebuild the worker with:

```powershell
.\scripts\build_web_assets.ps1
```

## Adding AI Providers

Create an adapter that implements `LanguageModelProvider`. Provider settings belong in configuration objects and secure storage, never hard-coded in domain logic.

Implemented adapters:

- `MockLanguageModelProvider`
- `OpenAICompatibleLanguageModelProvider`
- `AnthropicLanguageModelProvider`
- `GeminiLanguageModelProvider`
- `OllamaLanguageModelProvider`

Provider presets live in `features/settings/domain/ai_provider_preset.dart`. API keys are written through `SecretVault` and should never be stored directly in provider configuration rows.

HTTP providers use `HttpModelHttpTransport`, which centralizes JSON POST requests, timeout handling, and retry behavior for temporary provider failures.

## Coding Rules

- Domain code stays platform independent.
- UI copy must be localized.
- AI features must save suggestions instead of mutating manuscript text.
- Every schema migration needs tests.
- Export/import changes should preserve backward compatibility for `writeller.project.v3` and legacy `writeler.project.v1`, `writeler.project.v2`, and `writeler.project.v3` archives.
- New local data should have repository contracts, in-memory test adapters, and Drift-backed adapters where persistence is required.

## Local Toolchain Notes

Validated locally:

- `dart pub get`
- `flutter analyze --no-pub`
- `flutter test --no-pub`
- `flutter build web --no-pub --no-web-resources-cdn --pwa-strategy=none`

For manual web QA, use the repository starter from the root directory:

```powershell
.\start_writeller_web.cmd
```

The starter builds missing web assets, serves `app/build/web` on the next free local port starting at `8090`, disables the Flutter service worker for fresh local QA, and starts the local OpenRouter proxy used by the web build. Use `scripts\start_web_server.ps1 -CheckOnly` to inspect the resolved URL without opening a browser, or `-NoBrowser` when another tool controls the browser.

Pending local setup:

- Windows native builds require Visual Studio with the "Desktop development with C++" workload.
- Android native builds require Android SDK 36, compatible BuildTools, and accepted Android licenses.
