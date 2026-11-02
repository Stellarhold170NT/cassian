![upstream](https://img.shields.io/badge/upstream-FRESH-brightgreen)


| project | pinned_sha | head_now | state | last-check (UTC) |
|---|---|---|---|---|
| mtail | 4c7e0e1174ac1ead032efe28d86428bbbe0ae145 | 4c7e0e1174ac1ead032efe28d86428bbbe0ae145 | FRESH | 2026-11-02T01:14:20Z |


- Source of the pin: `docs/mtail/index.md` front matter (`measured_at`) — the
  commit of upstream `main` the subject was frozen against: "Merge pull
  request #999 from google/lsc-1771431274.9704435" (2026-02-26 09:59:36
  -0800).
- Check command: `git ls-remote https://github.com/google/mtail HEAD`.
  FRESH when it equals the pin; STALE otherwise (sha comparison only, no
  commit resolution). Current head equals the pin `4c7e0e11…` → FRESH as of
  the last-check timestamp above.
- STALE policy: do not re-measure automatically — the pin stays, a re-sync
  cycle decides when to re-certify against a new commit.


## Harvest (extracted modules)


- Pin: `4c7e0e1174ac1ead032efe28d86428bbbe0ae145` (upstream `main` at
  extraction time).
- The 18 Go packages of the module map were extracted verbatim under
  `modules/mtail/` — 141 `.go` files, 26,896 measured lines (per-extension
  census, non-test 15,689 + test 11,207), plus each module's committed
  non-Go artifacts.
- Each module directory carries `PROVENANCE.md` (upstream sha, path,
  license, measured size, re-sync rule).
- Extracts are byte-identical to upstream at the pin; re-verify with
  `diff -r modules/mtail/<module> <upstream clone>/<module>`.


## Documentation set


- `docs/mtail/01…07` + `docs/mtail/index.md` + `matrix/matrix.csv` +
  `specs/mtail/compiler.plan.md` + `specs/mtail/metrics.plan.md` form the
  documentation set for this subject; reading order in
  [`docs/mtail/index.md`](../docs/mtail/index.md).
- All measurements (census, module sizes, ratings, flow traces, build/test
  evidence) were taken at the pin itself; per-file measurement provenance
  lives in each document's own note and front matter.
