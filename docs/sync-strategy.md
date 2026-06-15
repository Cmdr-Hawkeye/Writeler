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

## Implemented Baseline

Writeler includes a manual archive sync adapter:

- It wraps the complete Writeler project archive in a `writeler.sync.v1` envelope.
- The envelope records adapter name, creation timestamp, byte length, and a stable fingerprint.
- Users can copy the checkpoint from the Export workspace and paste it back into the import field.
- The import flow accepts both raw `writeler.project.v2` archives and sync envelopes.
- Sync events are recorded in local metrics.

This baseline is intentionally cloud-free. WebDAV, Supabase/Postgres, or CRDT-capable backends can implement the same adapter boundary later without making local writing depend on network availability.
