![upstream](https://img.shields.io/badge/upstream-FRESH-brightgreen)

| project | pinned_sha | head_now | state | last-check (UTC) |
|---|---|---|---|---|
| dshsa | 8c32a9dc5d72c033816c6a8110b37f40cf94fba4 | 8c32a9dc5d72c033816c6a8110b37f40cf94fba4 | FRESH | 2026-11-03T17:47:11Z |

- Source of the pin: `docs/dshsa/index.md` front matter (`measured_at`) — the
  commit of upstream `main` the subject was frozen against: "feat: add the
  dsh-superagent research prototype" (2026-10-31 20:06:31 +0800).
- Check command: `git ls-remote https://github.com/deepseek-ai/dsh-superagent-prototype HEAD`.
  FRESH when it equals the pin; STALE otherwise (sha comparison only, no
  commit resolution). Current head equals the pin `8c32a9dc…` → FRESH as of
  the last-check timestamp above.
- STALE policy: do not re-measure automatically — the pin stays, a re-sync
  cycle decides when to re-certify against a new commit. Because the
  repository is single-commit, any HEAD different from the pin means the
  repository was replaced — re-run the measurement battery before reusing
  any number in this documentation set.

## Harvest (extracted modules)

- Pin: `8c32a9dc5d72c033816c6a8110b37f40cf94fba4` (upstream `main` at
  extraction time).
- The 7 modules of the module map were extracted verbatim under
  `modules/dshsa/` (m01 `src/app`, m02 `src/client`, m03 `src/core`,
  m04 `src/executor`, m05 `src/infra`, m06 `src/sources`, m07 the 8 root
  `src/*.ts` modules) — 111 files, 15,587 measured lines over all
  extensions (110 ts/tsx files / 15,205 lines by the TypeScript census;
  the difference is `client.css`, 382 lines).
- Each module directory carries a `PROVENANCE.md` (upstream sha, path,
  license MIT, measured size, re-sync rule) — 7/7 present.
- Extracts are byte-identical to upstream at the pin (verified per-item
  by tree-hash comparison after an initial checksum mismatch was
  resolved by switching to sha1 comparison — 7/7 OK); re-verify with
  `diff -r modules/dshsa/<module> <upstream clone>/<path>`.
- Known labeling note: the recorded `upstream_path` in some
  PROVENANCE.md files carries a `dsh-superagent/` prefix that the
  upstream tree does not have at the top level (the module label follows
  the extraction manifest; byte identity is unaffected) — the real path
  is the prefix-stripped one.

## Documentation set

- `docs/dshsa/01…07` + `docs/dshsa/index.md` + `matrix/matrix.csv`
  + `specs/dshsa/src-core.plan.md` form the documentation set for this
  subject; reading order in
  [`docs/dshsa/index.md`](../docs/dshsa/index.md).
- All measurements (census, module sizes, ratings, flow traces, C4
  evidence, use cases) were taken at the pin itself; per-file measurement
  provenance lives in each document's own note and front matter.
