![upstream](https://img.shields.io/badge/upstream-FRESH-brightgreen)








| project | pinned_sha | head_now | state | last-check (UTC) |
|---|---|---|---|---|
| opendesign | 5a0c47777975ddb91d09c1c16b423a3ef74bf572 | 5a0c47777975ddb91d09c1c16b423a3ef74bf572 | FRESH | 2026-11-03T09:31:22Z |








- Source of the pin: `docs/opendesign/index.md` front matter (`measured_at`) — the
  commit of upstream `main` the subject was frozen against: "fix(web): hide Labs
  settings when no experiments are available (#9076)" (2026-11-02 03:25:06 +0000).
- Check command: `git ls-remote https://github.com/nexu-io/open-design HEAD`.
  FRESH when it equals the pin; STALE otherwise (sha comparison only, no
  commit resolution). Current head equals the pin `5a0c4777…` → FRESH as of
  the last-check timestamp above.
- STALE policy: do not re-measure automatically — the pin stays, a re-sync
  cycle decides when to re-certify against a new commit.








## Harvest (extracted modules)








- Pin: `5a0c47777975ddb91d09c1c16b423a3ef74bf572` (upstream `main` at
  extraction time).
- The 27 pnpm workspace packages of the module map were extracted verbatim
  under `modules/opendesign/@open-design/` — 5,228 `.ts`/`.tsx` files,
  1,836,056 measured lines (per-file census convention; largest items:
  web 877,858 / daemon 669,678 / e2e 117,057 / contracts 52,859), plus each
  module's committed non-TypeScript artifacts (5,788 upstream files copied
  in total).
- Each module directory carries `PROVENANCE.md` (upstream sha, path,
  license Apache-2.0, measured size, re-sync rule) — 27/27 present.
- Extracts are byte-identical to upstream at the pin (verified per-file by
  md5-list / `diff -r`, 0 mismatches, 0 LOC drift); re-verify with
  `diff -r modules/opendesign/@open-design/<module> <upstream clone>/<path>`.








## Documentation set








- `docs/opendesign/01…07` + `docs/opendesign/index.md` + `matrix/matrix.csv`
  + `specs/opendesign/contracts.plan.md` +
  `specs/opendesign/sidecar.plan.md` form the documentation set for this
  subject; reading order in
  [`docs/opendesign/index.md`](../docs/opendesign/index.md).
- All measurements (census, module sizes, ratings, flow traces, install/build
  evidence, use cases) were taken at the pin itself; per-file measurement
  provenance lives in each document's own note and front matter.
