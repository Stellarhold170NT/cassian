![upstream](https://img.shields.io/badge/upstream-FRESH-brightgreen)

| project | pinned_sha | head_now | state | last-check (UTC) |
|---|---|---|---|---|
| mantis | 1e15346c2ca2d6e7db57ced59615bb9d1685992f | 1e15346c2ca2d6e7db57ced59615bb9d1685992f | FRESH | 2026-11-04T01:45:00Z |

- Source of the pin: `docs/mantis/index.md` front matter (`measured_at`) —
  the commit of upstream `main` the subject was frozen against (2026-11-02
  merge "AUTO_UPDATE FIX").
- Check command: `git ls-remote https://github.com/google/mantis refs/heads/main`.
  FRESH when it equals the pin; STALE otherwise. Current head equals the pin
  → FRESH.
- STALE policy: do not re-measure automatically — the pin stays, a re-sync
  cycle decides when to re-certify against a new commit.
- Measurement note: all statistics were taken at the pin itself, so every
  cited path and line resolves at `1e15346c` exactly.
