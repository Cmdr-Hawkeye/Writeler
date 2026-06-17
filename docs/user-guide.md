# User Guide

## Project Library

Create a project for a novel, series, nonfiction book, screenplay, or other writing work. Projects are local by default. You can rename, open, and delete projects from the library.

## Structure

Break the work into chapters and scenes. Scenes can track summary, goal, conflict, outcome, point of view, status, timeline placement, and target word count. The scene board supports reordering scenes and moving them between chapters.

Use the structure cockpit to inspect weak spots across the draft, such as scenes without goals, conflicts, outcomes, or manuscript progress.

## Catalog

Use the catalog for characters, locations, and objects. Catalog entries can be linked to scenes so context remains visible while writing and exporting.

## Notes

Project notes can belong to the whole project, a scene, or a catalog entry. AI suggestions can also be turned into notes. Notes are stored locally and included in project-oriented exports such as Writeler JSON archives, outline, Markdown or HTML with metadata, and DOCX with metadata.

## Editor

The manuscript editor is for author text. It includes scene planning fields, live word and character counts, find/replace, focus mode, and optional scene context. AI output appears separately as suggestions and requires an explicit decision before it becomes a note or accepted planning change.

## AI Workshop

Configure a provider in settings, choose a scene context, and request help with scene ideas, goal/conflict/outcome, structure, consistency, alternatives, or a custom prompt. The prompt preview shows the exact request sent to the model for transparency.

Suggestions can be accepted, rejected, or turned into notes. Accepted structure suggestions can update scene planning fields. Manuscript text remains under author control.

## Export

Export manuscript and project data to Markdown, HTML, TXT manuscript, outline, Writeler JSON archive, PDF, EPUB, or DOCX. Manuscript-only formats stay focused on the text. Project-oriented formats can include metadata, structure, relationships, and notes.

## Local Web Preview

Run `start_writeler_web.cmd` from the repository root to build and serve the web app locally. The starter chooses a local port, opens the browser, disables stale service-worker caching, and starts the local OpenRouter proxy used by the web build.
