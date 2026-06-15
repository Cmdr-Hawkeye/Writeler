# Export Formats

Writeler separates manuscript handoff formats from full project archives.

## Implemented Formats

- `Markdown`: project title, optional metadata, chapter headings, scene headings, manuscript text.
- `HTML`: standalone semantic HTML with project title, optional metadata, chapter/scene headings, and paragraph markup.
- `TXT / manuscript`: plain manuscript text with optional scene headings.
- `Outline / structure`: chapter and scene structure including summary, goal, conflict, outcome, status, and word counts.
- `Writeler archive JSON`: complete local-first project archive for round-trip import/export.

The UI can copy all formats to the clipboard. JSON archive import includes a preview step before the archive is persisted.

## JSON Archive

The current archive schema is:

```json
{
  "schema": "writeler.project.v2",
  "project": {},
  "chapters": [],
  "scenes": [],
  "catalogItems": [],
  "relationships": []
}
```

The importer accepts `writeler.project.v1` and `writeler.project.v2`. Future versions should keep the top-level `schema` field stable and add new arrays or objects in a backward-compatible way.

## Planned Adapters

- DOCX using a document generation library and render verification.
- PDF through a print/layout adapter.
- EPUB draft package.
- YAML or TOML for technical users who want hand-editable archives.
