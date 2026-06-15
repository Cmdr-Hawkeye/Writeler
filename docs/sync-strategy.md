# Sync Strategy

Writeler is offline-first. Local use must work without an account, backend, or network.

## Principles

- Local writes are authoritative on the device.
- Sync is opt-in per workspace or project.
- "No AI / No Cloud" projects cannot sync.
- Conflict resolution must be visible and reversible.

## Candidate Backends

- Supabase/Postgres for structured multi-device sync.
- WebDAV for user-controlled file sync.
- CRDT-capable backend for collaborative future modes.

## First Milestone

The first local milestone should persist to SQLite/IndexedDB and export complete project archives. Sync adapters should be added after the archive format and migration rules are stable.
