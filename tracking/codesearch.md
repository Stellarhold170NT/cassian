![upstream](https://img.shields.io/badge/upstream-FRESH-brightgreen)


| project | pinned_sha | head_now | state | last-check (UTC) |
|---|---|---|---|---|
| codesearch | 74a12a911a79b901d1158c48d011b2da1b090fc9 | 74a12a911a79b901d1158c48d011b2da1b090fc9 | FRESH | 2026-11-01T15:29:49Z |


- Source of the pin: `docs/codesearch/index.md` front matter (`measured_at`) — the
  commit of upstream `master` the subject was frozen against: "index: slight
  performance optimization" (2026-08-30).
- Check command: `git ls-remote https://github.com/google/codesearch refs/heads/master`.
  FRESH when it equals the pin; STALE otherwise (sha comparison only, no commit
  resolution). Current head equals the pin → FRESH.
- STALE policy: do not re-measure automatically — the pin stays, a re-sync
  cycle decides when to re-certify against a new commit.
- Measurement note: documentation statistics (census, module sizes, ratings,
  flow traces, use cases) were all taken at the pin itself, so every cited
  path and line resolves at `74a12a91` exactly.


## Harvest (extracted modules)


- Pin: `74a12a911a79b901d1158c48d011b2da1b090fc9` (upstream master at
  extraction time).
- 7 of 7 Go packages extracted verbatim under `modules/codesearch/` — 28
  files, 6608 measured lines (package `.go` files, tests included).
- Each package directory carries `PROVENANCE.md` (upstream sha, path,
  license, measured size, re-sync rule).
- Extracts are byte-identical to upstream at the pin — verified per file by
  content hash before publish; re-verify with
  `diff -r modules/codesearch/<module> <upstream clone>/<module>`.


## Documentation set


- `docs/codesearch/01…07` + `matrix/matrix.csv` +
  `specs/codesearch/index.plan.md` + `specs/codesearch/regexp.plan.md` form
  the documentation set for this subject; reading order in
  [`docs/codesearch/index.md`](../docs/codesearch/index.md).
- The set was measured against the upstream tree at the pin itself; per-file
  measurement provenance lives in each document's own note and front matter.
