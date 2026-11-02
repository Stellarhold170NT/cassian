![upstream](https://img.shields.io/badge/upstream-FRESH-brightgreen)

| project | pinned_sha | head_now | state | last-check (UTC) |
|---|---|---|---|---|
| mtail | 4c7e0e1174ac1ead032efe28d86428bbbe0ae145 | 4c7e0e1174ac1ead032efe28d86428bbbe0ae145 | FRESH | 2026-11-02T00:59:12Z |

- Source of the pin: `docs/mtail/index.md` front matter (`measured_at`) — the
  commit of upstream `main` the subject was frozen against: "Merge pull request
  #999 from google/lsc-1771431274.9704435" (2026-02-26).
- Check command: `git ls-remote https://github.com/google/mtail refs/heads/main`.
  FRESH when it equals the pin; STALE otherwise (sha comparison only, no commit
  resolution). Current head equals the pin → FRESH.
- STALE policy: do not re-measure automatically — the pin stays, a re-sync
  cycle decides when to re-certify against a new commit.
- Measurement note: documentation statistics (census, module sizes, ratings,
  flow traces, use cases) were all taken at the pin itself, so every cited
  path and line resolves at `4c7e0e11` exactly.
