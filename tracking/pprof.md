![upstream](https://img.shields.io/badge/upstream-FRESH-brightgreen)




| project | pinned_sha | head_now | state | last-check (UTC) |
|---|---|---|---|---|
| pprof | dbd0ed30aa888a30e21ba83b9831ac0e80d41022 | dbd0ed30aa888a30e21ba83b9831ac0e80d41022 | FRESH | 2026-11-02T07:10:00Z |




- Source of the pin: `docs/pprof/index.md` front matter (`measured_at`) — the
  commit of upstream `main` the subject was frozen against: "Record the
  selected sample type as default_sample_type in -proto output. (#1055)"
  (2026-10-26 19:23:09 +0000).
- Check command: `git ls-remote https://github.com/google/pprof HEAD`.
  FRESH when it equals the pin; STALE otherwise (sha comparison only, no
  commit resolution). Current head equals the pin `dbd0ed30…` → FRESH as of
  the last-check timestamp above.
- STALE policy: do not re-measure automatically — the pin stays, a re-sync
  cycle decides when to re-certify against a new commit.




## Harvest (extracted modules)




- Pin: `dbd0ed30aa888a30e21ba83b9831ac0e80d41022` (upstream `main` at
  extraction time).
- The 17 Go packages of the module map were extracted verbatim under
  `modules/pprof/` — 86 `.go` files, 30,683 measured lines (per-extension
  census), plus each module's committed non-Go artifacts (testdata
  fixtures, embedded web assets, the vendored svgpan JS).
- Each module directory carries `PROVENANCE.md` (upstream sha, path,
  license, measured size, re-sync rule).
- Extracts are byte-identical to upstream at the pin; re-verify with
  `diff -r modules/pprof/<module> <upstream clone>/<module>`.




## Documentation set




- `docs/pprof/01…07` + `docs/pprof/index.md` + `matrix/matrix.csv` +
  `specs/pprof/profile.plan.md` form the documentation set for this
  subject; reading order in [`docs/pprof/index.md`](../docs/pprof/index.md).
- All measurements (census, module sizes, ratings, flow traces, build/test
  evidence) were taken at the pin itself; per-file measurement provenance
  lives in each document's own note and front matter.
