# Architecture

## Decision

Writeler uses Flutter as the primary client technology and Clean Architecture with feature-first modules.

The first code slice implements domain and application logic without tying it to Drift, Supabase, WebDAV, or a concrete AI vendor. Those integrations must be adapters behind repository or provider interfaces.

## Alternatives Considered

| Option | Strength | Risk | Decision |
| --- | --- | --- | --- |
| Flutter | One codebase for mobile, desktop, and web; strong UI control | Web persistence needs special handling | Primary choice |
| Tauri | Small desktop bundles, Rust system integration | Separate mobile strategy required | Secondary desktop option |
| React Native | Good mobile ecosystem | Desktop and web need additional layers | Not primary |
| Kotlin Multiplatform | Strong native sharing | Slower path to polished web and desktop UI | Not primary |
| PWA | Fast web delivery | Mobile and desktop packaging weaker for local-first power users | Supporting target only |

## Layers

- Domain: entities, value objects, policies, repository contracts.
- Application: use cases and orchestration.
- Infrastructure: Drift, IndexedDB, encrypted key storage, sync, and AI provider adapters.
- Presentation: Flutter screens, state, navigation, and localization.

## Dependency Rule

Domain code has no dependency on Flutter, databases, sync, or AI SDKs. Application code depends on domain contracts. Infrastructure depends inward. Presentation depends on application services.

`main.dart` is the current composition root. It wires `ProjectRepository` to `DriftProjectRepository(AppDatabase())`; widget tests inject `InMemoryProjectRepository` through the same interface.

## UI Thesis

The interface should feel like a calm professional writing desk: dense enough for long projects, quiet enough for long sessions, and explicit about what belongs to the author versus AI suggestions.

## Initial Assumptions

- The first robust milestone is a local-first single-user app with import/export and mock AI.
- Cloud sync is optional and must never be required for local work.
- AI adapters can be added incrementally after the suggestion boundary is stable.
- DOCX/PDF/EPUB exports require dedicated adapters and visual verification.
