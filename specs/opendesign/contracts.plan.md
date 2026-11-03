# Extraction plan — slot A: @open-design/contracts (nexu-io/open-design @ PIN 5a0c4777)

Selected item: **s04 `@open-design/contracts` (packages/contracts) — ★5, T=9,
5/5 signals** — the first ≥4-star item in the star-ranking report
(distribution table: the ★5 row lists `s04 contracts, s09 sidecar, s17
sidecar-proto`; s04 ranks first). Score source: the ranking's per-item table
(s04 ★5, T=9) — 27/27 items DONE, none UNOWNED. Slot B (a separate plan)
takes **s09 sidecar** ★5.

**EXPLICIT MANDATORY NOTE: this is a PLAN only.** The actual cut is a
separate command outside this run. The plan does not cut, does not create a
repository, does not copy upstream code into itself — it only SPECIFIES
files.

- PIN: `5a0c47777975ddb91d09c1c16b423a3ef74bf572` (branch `main`). The fresh
  shallow clone of this pass had `git rev-parse HEAD` == the PIN, checked
  twice (start and end of the pass) — see §6.
- Upstream: https://github.com/nexu-io/open-design (default branch `main`).
- Copy-then-prune: copy the whole tree BYTE-IDENTICAL first, then prune per
  the table in §3; rewriting code is forbidden.
- N/A check: the ≥4-star set has **12 items** (3 ★5 + 9 ★4) ≥ 2 → NOT N/A.

## 0. Selection basis (unambiguous)

| Claim | Evidence |
|---|---|
| s04 is the first ★5 | File: the star-ranking report, distribution table | Content: "\| ★5 \| s04 contracts, s09 sidecar, s17 sidecar-proto \| **3** \|" |
| All three ★5 share T=9 ∧ S4=2 | File: the star-ranking report, per-item rows | Content: s04/s09/s17 all "T=9 ∧ S4=2 → ★5" |
| Tie-break ranks s04 first | File: the star-ranking report | Content: "no tie-break needed on `(T, S2, logic_loc, id)`" — applying the formula: T 9=9=9, S2 (C=9) 2=2=2, logic_loc **41,242** > 3,276 (s09) > 1,198 (s17), id s04 < s09 < s17 → s04 first |
| logic_loc 41,242 re-measured EXACTLY | This pass: non-test `.ts` = 52,608 − 11,366 = **41,242** (§2 census) — matches the ranking's oracle |
| 12 items ≥4★ → not N/A | File: the star-ranking report | Content: ★5 = 3 items, ★4 = 9 items |

The "first" decision reads by **star tier** (the distribution table), not by
the ranking's item-table order (checklist order — s01 ★4 appears before s04
★5 there but is not the highest tier): the purpose of the node is to extract
the most valuable item; for the two earlier subjects both orders coincided,
for opendesign they differ — declared as deviation 1 in §6.

## 1. Dependency boundary (grep-verified on the PIN tree)

| Claim | Evidence |
|---|---|
| `contracts` depends on exactly 1 sibling package: `release` | File: packages/contracts/src/analytics/client-metrics.ts \| Line: 6 \| Content: `import { releaseChannelFromVersion } from '@open-design/release';` |
| The second `release` import is type-only | File: packages/contracts/src/analytics/events/result-events.ts \| Line: 16 \| Content: `import type { ReleaseChannel } from '@open-design/release';` |
| No other workspace package imported in src | Grep `@open-design/[a-z-]+` over `packages/contracts/src` + `tests`: only `@open-design/contracts` (11 hits) + `@open-design/release` (2 hits) — 0 hits of any other package |
| `release` imports nothing back | File: packages/release/src/index.ts \| Content: `grep -cE "^(import|export .* from)"` = **0** — a 216-line primitives file, 0 import statements |
| `release` has 0 runtime deps | File: packages/release/package.json \| Line: `devDependencies` block \| Content: NO `dependencies` field — only devDeps (@typescript/native→typescript@7.0.2, @types/node 24.12.2, esbuild 0.28.0, tsx 4.22.3, vitest 4.1.6) |
| contracts' only third-party runtime = zod | 14 `zod` imports in non-test src (sample: File: packages/contracts/src/touchpoint-component-v2.ts \| Line: 1 \| Content: `import { z } from "zod";`); hard pin `"zod": "3.25.76"` (packages/contracts/package.json) |
| Exactly 1 test needs a built dist | File: packages/contracts/tests/package-runtime.test.ts \| Line: 70-77 \| Content: 8 dynamic imports `await import('@open-design/contracts…')` (index + 7 subpaths) — the "package runtime shape" test resolves via `exports` → `./dist/*.mjs` (packages/contracts/package.json) → must build before testing |
| tsconfig self-contained | File: packages/contracts/tsconfig.json \| Line: 1-19 \| Content: NO `extends` field (no root tsconfig dependency); tsconfig.tests.json extends `./tsconfig.json` (same package) |
| Build config lives inside the package | File: packages/contracts/esbuild.config.mjs \| Line: 1-40 \| Content: only `import { build } from "esbuild"`, `packages: "external"` (release+zod not bundled), platform node24 — self-contained |
| No dedicated vitest config | `find packages/contracts -name 'vitest*' -o -name 'vite.config*'` = **0** — `test: vitest run` runs with defaults, tests live in `tests/*.test.ts` |

## 2. Verbatim file copy (all relevant tests + minimal config)

Target tree after the cut (every package file copied byte-identical, paths
preserved so `workspace:*` + self-imports + snapshots resolve):

```
opendesign-contracts-extract/
├── package.json          # NEW — minimal scaffolding, fields declared in §2.1 (NOT an upstream file)
├── pnpm-workspace.yaml   # copied VERBATIM — workspace globs + overrides + onlyBuiltDependencies
├── .node-version         # copied VERBATIM (content: 24)
├── LICENSE               # copied VERBATIM (Apache-2.0 — root package.json field "license": "Apache-2.0")
├── packages/contracts/   # copied VERBATIM, all 256 files — 52,975 LOC
│   ├── package.json      (128 lines — deps: @open-design/release workspace:* + zod 3.25.76)
│   ├── esbuild.config.mjs(40)  +  tsconfig.json (19)  +  tsconfig.tests.json (9)
│   ├── src/              # 166 .ts files — 41,242 LOC; 10 subdirs (agent-tools, analytics,
│   │                     #   analytics/events, api, artifacts, design-systems, observability,
│   │                     #   plugins, prompts, runtime, sse) + 11 root files (index.ts, critique.ts,
│   │                     #   common.ts, errors.ts, examples.ts, execution-profile.ts, tasks.ts,
│   │                     #   amr-endpoint-binding.ts, comment-target-title.ts, settings-nav.ts,
│   │                     #   touchpoint-component-v2.ts)
│   └── tests/            # 85 .test.ts files — 11,366 LOC (incl. tests/runtime/ 4 files) +
│                         #   tests/__snapshots__/system-prompt-metadata-block.test.ts.snap (171 lines)
└── packages/release/     # copied VERBATIM, all 6 files
    ├── package.json            (0 runtime deps)
    ├── esbuild.config.ts (28)  +  tsconfig.json  +  tsconfig.tests.json
    ├── src/index.ts      (216 — 0 imports, graph root)
    └── tests/index.test.ts (86 — release's only test file)
```

- **LOC census** (per extension then summed, `wc -l` per file): ts **52,608**
  + json **156** (128+19+9) + mjs **40** + snap **171** = **52,975** (256
  files). Non-test ts = 52,608 − 11,366 = **41,242** — EXACTLY matches the
  ranking oracle (logic_loc 41,242, pub_funcs 298); test ts = **11,366**;
  main_files **166** / tests **85** — matches the module map JSON (m04:
  "main_files": 166, "tests": 85).
- Declared census drift (see §6 deviation 2): the checklist/module map record
  `loc 52,859` (files 251 = .ts count); fresh re-measure: ts-only 52,608,
  whole tree 52,975.
- ~**716** `it(`/`test(` cases (grep count — **approximate**, some hits may
  sit in strings/comments).
- No external `testdata/`/fixture dirs — test data lives inside the test
  files and `tests/__snapshots__/` (already inside the verbatim copy).

### 2.1 Root package.json — NEW scaffolding (fields declared, not copied)

The upstream root `package.json` cannot be copied verbatim because: (a)
`"postinstall": "node ./scripts/postinstall.mjs"` — the `scripts/` directory
is not in the copy tree → `pnpm install` dies; (b) devDeps reference 6 cut
workspace packages (`@open-design/components`, `daemon`, `tools-dev`,
`tools-pack`, `tools-release`, `tools-serve`) → pnpm cannot resolve them;
(c) `bin.od` points at the cut `./apps/daemon/bin/od.mjs`. Fields of the NEW
manifest:

- `name`: `opendesign-contracts-extract` · `private`: true · `type`: `module`
- `packageManager`: `pnpm@10.33.2` (matches the upstream root)
- `engines`: `{ "node": "~24", "pnpm": ">=10.33.2 <11" }` (matches the
  upstream root)
- NO `scripts`, NO `dependencies`/`devDependencies` (deps live in the two
  verbatim package manifests), NO `pnpm` field (overrides +
  `onlyBuiltDependencies` already live verbatim in `pnpm-workspace.yaml` —
  pnpm 10 reads that config from the workspace yaml).

## 3. Prune — keep / vendor / cut (one-line reason each)

| Target | Decision | Reason |
|---|---|---|
| `packages/contracts/**` 256 files | KEEP verbatim | The extracted item is itself — copy-then-prune forbids splitting; a missing `.snap` breaks snapshot tests |
| `packages/release/**` 6 files | KEEP verbatim | contracts' ONLY workspace dependency (`workspace:*` — 2 imports in §1); 330 ts LOC, 0 runtime deps |
| `pnpm-workspace.yaml` | KEEP verbatim | Workspace config + overrides + `onlyBuiltDependencies` (esbuild needs it) — the `packages/*` glob matches exactly the 2 remaining packages |
| `.node-version` (24) | KEEP | `engines.node "~24"` in all 3 manifests; the toolchain of the real cut |
| `LICENSE` | KEEP | Apache-2.0 — the notice must be preserved when extracting |
| upstream root `package.json` | CUT — replaced by NEW scaffolding (§2.1) | postinstall + workspace devDeps + bin point into the cut tree → keeping it verbatim makes `pnpm install` fail |
| `pnpm-lock.yaml` (13,137 lines / 440,023 bytes) | CUT | The lockfile covers importers of 26 workspace packages; on a 2-package tree `--frozen-lockfile` surely fails → install with `--no-frozen-lockfile`; drift is guarded by every direct dep of the 2 packages being exactly pinned (zod 3.25.76, esbuild 0.28.0, vitest 4.1.6, typescript@7.0.2, tsx 4.22.3, @types/node 24.12.2) |
| the 24 remaining workspace packages (apps/*, tools/*, shells/*, e2e, 9 other packages/*) | CUT | contracts/release do not import them — contracts' `imported by` (8 packages) is the INBOUND direction (consumers), not outbound |
| docs, design-systems/, design-templates/, skills/, specs/, scripts/, charts/, deploy/, vercel.json, mise.toml, README*, AGENTS.md, CHANGELOG.md… | CUT | Not part of the 2 packages' build/test (minimal config = §2) |
| VENDOR zod | DO NOT vendor — keep as a hard-pinned npm dep | `zod 3.25.76` is exactly pinned in the verbatim manifest; vendoring means rewriting the tree — forbidden by copy-then-prune |

## 4. Expected standalone build+test commands + dry-run

```bash
cd opendesign-contracts-extract
# Toolchain: Node ~24 (.node-version=24) + pnpm 10.33.2 (packageManager)
corepack enable && corepack prepare pnpm@10.33.2 --activate
# (Node 24 does not bundle corepack by default → alternative: npm i -g pnpm@10.33.2)
pnpm install --no-frozen-lockfile        # lockfile was CUT — regenerate for the 2-package workspace (R3)
pnpm -r build                            # topo: release (tsx esbuild.config.ts + tsc emitDeclarationOnly)
                                         #       then contracts (node esbuild.config.mjs + tsc emitDeclarationOnly)
pnpm -r test                             # vitest run: release 1 test file; contracts 85 files (~716 cases)
                                         #   — package-runtime.test.ts needs dist (R2: build BEFORE test)
pnpm -r typecheck                        # optional: tsc --noEmit over both tsconfig and tsconfig.tests
```

- Expected: `pnpm -r test` PASSES for both packages;
  `packages/contracts/dist/index.mjs` exists after build (a precondition for
  package-runtime.test.ts).
- Toolchain notes: `@typescript/native` is the npm alias
  `npm:typescript@7.0.2` (TS 7 native preview); the `tsc` bin is exposed
  from the typescript package under the alias. vitest 4.1.6 + esbuild 0.28.0
  need a modern Node; `engines` blocks Node <24 and pnpm outside
  [10.33.2, 11).
- **DRY-RUN: SKIPPED (honest).** The container of this pass is
  `bitnami/git:latest` (the prescribed image) and has NO node/npm/pnpm — the
  real probe output was:
  ```
  $ which node npm pnpm; node --version
  which: no node in (/opt/bitnami/common/bin:/opt/bitnami/git/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin)
  which: no npm in (/opt/bitnami/common/bin:/opt/bitnami/git/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin)
  which: no pnpm in (/opt/bitnami/common/bin:/opt/bitnami/git/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin)
  bash: line 1: node: command not found
  ```
  No build/test output was invented. The commands above (§4) belong to the
  real cut, run outside this documentation pass with Node ≥ 24.

## 5. Prune risks + post-cut checks

| # | Risk | Post-cut check |
|---|---|---|
| R1 | Forgetting `packages/release` → build breaks at the 2 `@open-design/release` imports (src/analytics/client-metrics.ts:6, src/analytics/events/result-events.ts:16) | Clean `pnpm -r build`; count the target tree: exactly 254 `.ts` files (251 contracts + 3 release) + 3 json + 1 mjs + 1 snap |
| R2 | Running tests before build → package-runtime.test.ts dies on 8 dynamic imports (dist missing) | Mandatory order build → test; `ls packages/contracts/dist/index.mjs` must exist before testing |
| R3 | `pnpm install --frozen-lockfile` fails (lockfile was cut) | Use `--no-frozen-lockfile`; after install run `pnpm ls --depth 0` in both packages — versions match the manifest pins (zod 3.25.76, esbuild 0.28.0, vitest 4.1.6, typescript 7.0.2) |
| R4 | Verbatim `pnpm-workspace.yaml` lists literal `e2e` + globs `apps/* tools/* shells/*` that do not exist in the cut tree | `pnpm ls -r --depth -1` must print EXACTLY 2 packages (`@open-design/contracts`, `@open-design/release`); pnpm 10 skips missing dirs (warn) — if the install errors on the literal, prune the extra glob lines and keep only `packages/*` |
| R5 | Accidentally keeping the upstream root `package.json` → postinstall dies on install | `grep -n postinstall package.json` (root of the copy tree) = 0 hits |
| R6 | Missing `tests/__snapshots__/*.snap` → snapshot mismatch/silent re-snapshot | `diff -r` per file against the PIN tree — byte-identical; no file other than `*.test.ts` may change |
| R7 | Node < 24 → `engines` blocks; TS7-native/esbuild node24 mismatch | `node --version` ≥ 24 BEFORE install; `cat .node-version` = 24 |
| R8 | Editing the contracts manifest (rename / drop `workspace:*`) → loses workspace semantics | `grep -c '"@open-design/release": "workspace:\*"' packages/contracts/package.json` = 1; `grep '"name"' packages/contracts/package.json` yields `@open-design/contracts` |

## 6. Source disclosure, census drift, cross-plan checks

- **Input:** the star-ranking report (27/27 items, all-join merge, 2 parts
  matching the checklist 1-1) — the first ≥4★ item = s04 contracts ★5, the
  second = s09 sidecar ★5 → SLOT B.
- **PIN re-verified in this pass:** shallow clone `--depth 100
  --single-branch --filter=blob:limit=1m --sparse` + `sparse-checkout set
  packages/contracts packages/release` (the cartography's method) → `git
  rev-parse HEAD` = `5a0c47777975ddb91d09c1c16b423a3ef74bf572`, checked at
  the START of the pass (after clone) and at the END (after all
  measurements) — same value, matching the ranking's PIN. Every `file:line`
  claim in this plan was grep-verified on that PIN tree (a dedicated
  `bitnami/git:latest` container; no repo file was written through
  file-sync tooling).
- **First run:** no prior extraction plan for this subject existed before
  the pass (glob-checked; only other subjects' plans were present,
  namespaced, unrelated) → first run, nothing inherited, no fix-list.
- **Declared deviations:**
  1. "First" is read by **star tier** (★5 before ★4), not by the ranking
     table's row order (checklist order — s01 ★4 appears before s04 ★5):
     reasoning in §0; if a reviewer normalizes by table order, slot A would
     be s01 web (★4, 877,858 LOC — a huge Next.js app, poorly suited for
     extraction) and this plan would need re-planning.
  2. **Legacy census drift:** the checklist/module map record contracts
     `loc 52,859` / release `loc 333`; fresh re-measure on the PIN:
     contracts ts-only 52,608 (whole tree, 4 extensions: 52,975), release
     ts-only 330. The two deltas (251 and 3) EXACTLY equal the `.ts` file
     counts of each package → the legacy census most likely counted
     `wc -l` +1 per file (the old counter added a line per file even for
     files without a trailing newline); the old counting recipe could not
     be reproduced, so the drift is declared; the key ranking oracles
     (logic_loc 41,242, main_files 166, tests 85) match EXACTLY. Every
     number in this plan was freshly measured, commands stated in §2.
  3. The root `package.json`: the plan declares NEW scaffolding instead of
     copying verbatim (reasons in §2.1) — the rejected alternative was
     keeping it verbatim (install dies) or copying `scripts/` too (pulls a
     forest of repo-wide scripts, violating "minimal config").
  4. `pnpm-lock.yaml` CUT + install with `--no-frozen-lockfile`: a frozen
     install is impossible for 2/26 importers; version drift is guarded by
     hard direct-dep pins + a `pnpm ls` check after install (R3).
  5. DRY-RUN build/test SKIPPED — the sandbox is git-only without
     node/pnpm (real output in §4), per the fallback the brief prescribes;
     no output invented.
- **No git commits in this pass:** the deliverable is this report in the
  documentation workspace (not a git repo); the real cut happens in a
  separate run which performs the copy + commit per the PROVENANCE standard.
