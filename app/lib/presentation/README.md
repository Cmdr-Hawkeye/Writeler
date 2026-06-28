# Writeler Presentation Layer

The presentation layer is split by responsibility while still sharing one Dart
library through `part` files. This keeps the refactor behavior-neutral: private
widgets and helpers remain private to `main.dart`, but the code is no longer
held in one monolithic file.

## File Map

- `app_root.dart`: app root, theme persistence, and theme token definitions.
- `ai_provider_runtime.dart`: AI provider defaults, secret migration, and runtime provider creation.
- `app_shell.dart`: stateful orchestration, repositories, commands, and routing.
- `shell_dialogs.dart`: create/edit/delete dialogs used by the shell.
- `navigation_chrome.dart`: navigation, brand mark, and top bar.
- `dashboard_workspace.dart`: project dashboard and project overview surfaces.
- `structure_workspace.dart`: structure cockpit and author-inspection widgets.
- `catalog_analysis_notes.dart`: catalog, analysis, notes, and shared analysis UI.
- `ai_workshop.dart`: AI prompt workflow, suggestion review, and AI status UI.
- `export_settings_workspace.dart`: export, sync, import, provider, and settings UI.
- `shared_workspace_widgets.dart`: small shared workspace primitives.
- `editor_workspace.dart`: manuscript editor, scene navigation, autosave, and planning UI.
- `presentation_helpers.dart`: labels, counters, formatting, and UI-domain adapters.

## Navigation Model

The sidebar is organized by author workflow, not by implementation module:

- Writing: daily writing surfaces and structural scene movement.
- World & Research: context, catalog entities, relationships, timeline, and sources.
- Review & AI: analysis, style, smart collections, notes, and AI review queues.
- Output & Settings: logs, transfer, publishing, and app/project configuration.

Secondary surfaces such as detailed statistics may stay out of the permanent
sidebar, but must remain reachable through an explicit workspace action or the
command palette.

## Refactoring Rule

New presentation code should live with the workspace it belongs to. Shared
widgets should only move into `shared_workspace_widgets.dart` when at least two
workspaces use them. Pure formatting or label helpers belong in
`presentation_helpers.dart`.
