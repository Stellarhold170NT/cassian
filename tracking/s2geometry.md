![upstream](https://img.shields.io/badge/upstream-FRESH-brightgreen)

| project | pinned_sha | head_now | state | last-check (UTC) |
|---|---|---|---|---|
| s2geometry | 677c8cebcff11ba11accc0b02005bc214e06e9fd | 677c8cebcff11ba11accc0b02005bc214e06e9fd | FRESH | 2026-11-03T01:12:06Z |

- Source of the pin: `docs/s2geometry/index.md` front matter (`measured_at`) —
  the commit of upstream `master` the subject was frozen against.
- Check command: `git ls-remote https://github.com/google/s2geometry refs/heads/master`.
  FRESH when it equals the pin; STALE otherwise. Current head equals the pin →
  FRESH.
- STALE policy: do not re-measure automatically — the pin stays, a re-sync
  cycle decides when to re-certify against a new commit.
- Measurement note: all statistics were taken at the pin itself, so every
  cited path and line resolves at `677c8ceb` exactly.
