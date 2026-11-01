![upstream](https://img.shields.io/badge/upstream-FRESH-brightgreen)


| project | pinned_sha | head_now | state | last-check (UTC) |
|---|---|---|---|---|
| jimfs | 8fa098e0715aa492914285312c07e151d2aace4d | 8fa098e0715aa492914285312c07e151d2aace4d | FRESH | 2026-11-01T19:52:47Z |


- Source of the pin: `docs/jimfs/index.md` front matter (`measured_at`) — the
  commit of upstream `master` the subject was frozen against: "Bump
  org.sonatype.central:central-publishing-maven-plugin from 0.11.0 to 0.12.0
  in the dependencies group" (2026-10-22).
- Check command: `git ls-remote https://github.com/google/jimfs refs/heads/master`.
  FRESH when it equals the pin; STALE otherwise (sha comparison only, no commit
  resolution). Current head equals the pin → FRESH.
- STALE policy: do not re-measure automatically — the pin stays, a re-sync
  cycle decides when to re-certify against a new commit.
- Measurement note: documentation statistics (census, module sizes, ratings,
  flow traces, use cases) were all taken at the pin itself, so every cited
  path and line resolves at `8fa098e0` exactly.
