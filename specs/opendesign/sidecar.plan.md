# Extraction plan — slot B: @open-design/sidecar (nexu-io/open-design @ PIN `5a0c4777`) — item **s09 `@open-design/sidecar`** ★5

- Run: **1** — at pass start, no extraction plan for this subject existed
  (glob found only `01`–`08`-series artifacts + the checklist; nothing
  inherited, no fix-list, fresh production).
- **Verdict: NOT N/A** — the ≥4★ set has **12 items** (3 ★5 + 9 ★4) → a
  second element exists and the cut is producible.
- **Declared decision (contract gap):** the task definition requires "same
  process as slot A" but the slot-A plan did not exist yet at the time this
  plan was written (checked twice — at pass start and mid-pass). The process
  was therefore taken from the slot-A brief's own 4 mandatory components
  (verbatim copy / per-dep prune / build+test commands / risks) plus the
  6-section shape of the earlier subjects' slot-B plans. Cross-checked
  against slot A once it appeared (§9).
- **PLAN ONLY** — no real cut, no repository creation, no push. The real cut
  is a separate command outside the run.

## 1. Slot-B selection — ranking the ≥4★ set

Sources: the star-ranking report (distribution table + per-item table + JSON)
and its oracle data. Ranking rule = the rubric's CAP sort key:
**`(T, S2, logic_loc, id)`** descending.

The ≥4★ set = 12 items: ★5 {s04, s09, s17} (T=9) + ★4 {s02, s10, s24 (T=8);
s01, s05, s06, s08, s13, s20 (T=7)}.

| Rank | id | module | T | S2 | logic_loc | Role |
|-----|----|--------|---|----|-----------|-----|
| #1 | s04 | @open-design/contracts | 9 | 2 | 41,242 | **SLOT A** (first) |
| **#2** | **s09** | **@open-design/sidecar** | **9** | **2** | **3,276** | **SLOT B (this plan)** |
| #3 | s17 | @open-design/sidecar-proto | 9 | 2 | 1,198 | out of scope |

- The three ★5 items tie on `(T=9, S2=2)` → decided by `logic_loc`
  descending: 41,242 > 3,276 > 1,198 (oracle values in the ranking's JSON).
  This order **coincides** with the distribution table's ★5 row
  ("s04 contracts, s09 sidecar, s17 sidecar-proto") — both criteria give the
  same order → no subjective decision (precedent: the kafka run).
- s09's stars (per-item table): sidecar ★5, 5/5 signals, T=9, "JSON-IPC
  client/transport written 100% in-house: E1=0 … S2=2 (C=9 — 8 packages
  import it: daemon, desktop, e2e, packaged, terminal, tools-dev, tools-pack,
  web — the mandatory bridge between host runtime and the sidecar binary)".
- Slot boundaries: slot A = `packages/contracts`, slot B =
  `packages/sidecar` — two completely disjoint cut trees, no shared files.

## 2. Fresh measurement on the PIN tree

- Clone: `git clone --depth 100 --single-branch --branch main
  https://github.com/nexu-io/open-design /workspace/opendesign` — exit 0,
  14,199 files.
- **G1 PIN**: `git rev-parse HEAD` = `5a0c47777975ddb91d09c1c16b423a3ef74bf572`
  == the PIN of the ranking — EXACT MATCH. Commit: `2026-11-02 fix(web):
  hide Labs settings when no experiments are available (#9076)`.
- **FRESH check**: `git ls-remote origin` → HEAD and `refs/heads/main` both
  = the PIN → upstream has not drifted (tracking will read FRESH).
- Census of item s09 on the PIN tree (rubric oracles):

| Quantity | Fresh measure | Oracle (module map / ranking) | Match |
|-----------|-------------|------------------------------|-------|
| files (ts+tsx) | 34 | 34 | ✓ |
| tests | 16 | 16 | ✓ |
| main (non-test) | 18 | 18 | ✓ |
| logic_loc (non-test) | **3,276** | 3,276 (s5_loc) | ✓ exact |
| pub_funcs | 72 | 72 | ✓ |
| R = 100×16/34 | 47.058→47.1 | 47.1 | ✓ |
| total .ts LOC | 5,430 | — | — |
| .tsx LOC | 0 | — | — |

- **Reconciled drift (declared transparently):** the fresh census total
  `.ts` LOC = 5,430 while the module map records `loc=5464`. Delta = **34 ==
  exactly the line count of `packages/sidecar/package.json`** (`wc -l` = 34)
  → the module map's package-level census includes the package.json file;
  5,430 + 34 = 5,464 exact. No star signal is affected: S5 uses
  `logic_loc`=3,276 (exact match), files/tests match exactly. Reproduction
  identity: `3,276 + (5,430−3,276 test LOC) + 34`.
- Stars re-derived independently from the fresh numbers: S1=2 (D=1), S2=2
  (C=9), S3=2 (R=47.1), S4=2 (E1=0 ∧ E2=2 files — §3), S5=1 (logic_loc 3,276
  < 5,000 so the AND branch fails; pub_funcs 72 ≥ 10 → the OR branch) →
  **T=9 ∧ S4=2 → ★5** — matches the ranking's per-item row.

## 3. Dependency boundary (grep-verified on the PIN tree)

- **depends on (non-test)**: exactly one package —
  `@open-design/platform` — 10 non-test import lines, 0 other packages (the
  rubric's S1 oracle). Oracle: depends on=[platform] (module map m09) —
  **MATCH**.
- **Test closure**: test files also import only `platform` (once —
  `packages/sidecar/tests/convergence.test.ts:9:import {
  captureProcessSnapshot, collectProcessTreePids, isProcessAlive,
  waitForProcessExit } from "@open-design/platform";`), everything else is
  relative in-package imports. → the cut tree needs NO additional package
  for tests (unlike an earlier subject's precedent which had to drag in
  test utilities).
- **imported by (who imports sidecar)** — the S2 oracle reversed: exactly
  **8 items** = daemon, desktop, e2e, packaged, terminal, tools-dev,
  tools-pack, web (directory groups measured: apps/daemon/src(+sidecar),
  apps/desktop/src/main(+updater), apps/packaged/src, apps/web/sidecar,
  e2e/lib/desktop, shells/terminal/tests, tools/dev/src,
  tools/pack/src(+config,mac,win)) — matches the oracle's 8-element list
  (module map m09). Note: terminal's only importer sits under
  `shells/terminal/tests/` (a file without the `*.test.*` suffix, so it
  enters the census — the declared census mechanism of the module map).
- **S4 probes re-measured** (rubric commands): E1 (third-party non-test) =
  **0** → positive; E2 (protocol constants) = **2 files** → positive; E3
  (zod/regex) = **0** → negative. S4 = 2/3 probes positive → 2 points —
  matches the ranking. Verbatim E2 evidence:
  - File: packages/sidecar/src/stamp.ts | Line: 32 |
    `export const SIDECAR_SUPERVISED_CONTEXT_ENV = "OD_SIDECAR_SUPERVISED_CONTEXT";`
    (with Line: 29 `SIDECAR_LIFECYCLE_FLAG = "--od-sidecar-lifecycle"`)
  - File: packages/sidecar/src/client.ts | Line: 12, 17, 20 | three env-var
    constants: `OD_SIDECAR_RESOURCES` (:12), `OD_SIDECAR_CLIENT_ENDPOINT`
    (:17), and the exported `OD_SIDECAR_SUPERVISOR_TARGET` target env (:20)
- **Anchors matching the module map**: `packages/sidecar/src/operations.ts`
  = 578 lines (wc -l) — exact match; `src/index.ts` = 87 lines (barrel).

## 4. Verbatim file copy (copy-then-prune — iron rule: copy the whole tree, do not re-type code into the plan)

| # | Source (verbatim @ PIN) | Content | Files |
|---|------------------------|----------|------:|
| C1 | `packages/sidecar/` ENTIRE | src/ 18 .ts files (bootstrap, client, generation, index, ipc-path, json-file, json-ipc, lifecycle-lock, net, operations, paths, port, process-retirement, process-tree, stamp, supervisor-exit, supervisor, types) + tests/ 16 files (5 tests + 12 fixtures) + `package.json` + `tsconfig.json` + `tsconfig.tests.json` + `esbuild.config.mjs` | **37** |
| C2 | `packages/platform/` ENTIRE | the only runtime dependency — src/ 7 + tests/ 5 (12 .ts files) + `package.json` + `tsconfig.json` + `tsconfig.tests.json` | **15** |
| C3 | `pnpm-workspace.yaml` root | workspace globs + overrides + onlyBuiltDependencies (needed by esbuild's binary postinstall) | 1 |
| C4 | `.node-version` | content `24` (matches `engines.node ~24` of both manifests) | 1 |
| C5 | `LICENSE` | Apache-2.0 (root package.json `"license": "Apache-2.0"`) | 1 |
| C6 | root `package.json` | NEW minimal manifest (see below) — NOT copied from upstream | 1 (new) |

New root `package.json` fields (declared, not copied — the upstream root
fails for the same three reasons as slot A: postinstall→scripts/, devDeps
pointing at 6 cut packages, bin pointing at the cut apps/daemon):

- `name: "opendesign-sidecar-extract"`, `private: true`, `type: "module"`
- `packageManager: "pnpm@10.33.2"`, `engines: {node: "~24", pnpm:
  ">=10.33.2 <11"}`
- no scripts, no dependencies (both package manifests are verbatim), no
  `pnpm` field (config already verbatim in pnpm-workspace.yaml)

## 5. Prune table

| Target | Decision | Reason |
|---|---|---|
| `packages/sidecar/**` 37 files | KEEP verbatim | the extracted item itself |
| `packages/platform/**` 15 files | KEEP verbatim | sidecar's only workspace dependency (`"@open-design/platform": "workspace:*"` — 10 non-test imports; also 1 test import) |
| `pnpm-workspace.yaml` | KEEP verbatim | workspace + overrides + onlyBuiltDependencies (esbuild) |
| `.node-version`, `LICENSE` | KEEP | engine pin + license notice |
| upstream root `package.json` | CUT → NEW manifest (§4) | postinstall + devDeps + bin break the 2-package tree |
| `pnpm-lock.yaml` | CUT | covers 26 importers; `--frozen-lockfile` impossible on 2 packages → `--no-frozen-lockfile`; guard = exact direct-dep pins (@open-design/platform workspace:*, esbuild 0.28.0, vitest 4.1.6, typescript@7.0.2, tsx 4.22.3, @types/node 24.12.2) + `pnpm ls` after install |
| the other 24 workspace packages | CUT | sidecar imports only platform; `imported by` (8) is the inbound direction |
| docs, design-systems/, skills/, plugins/, scripts/, apps/*, tools/*, shells/*, e2e | CUT | not part of the 2 packages' build/test |

## 6. Expected standalone build+test commands + dry-run

```bash
cd opendesign-sidecar-extract
corepack enable && corepack prepare pnpm@10.33.2 --activate   # (or npm i -g pnpm@10.33.2 on Node 24)
pnpm install --no-frozen-lockfile
pnpm -r build          # topo: platform → sidecar (esbuild bundling, packages external)
pnpm -r test           # vitest run: platform 5 test files, sidecar 5 test files + 12 fixtures
pnpm -r typecheck      # tsc -p tsconfig.json + tsconfig.tests.json per package
```

- Expected: both packages build and all 10 test files pass; the sidecar
  tests spawn real child processes (stamp/supervisor/convergence) — they
  need a POSIX-ish shell; on Windows use WSL.
- **DRY-RUN: SKIPPED (honest).** The measuring container
  (`bitnami/git:latest`, the prescribed image) has no node/npm/pnpm:
  `which node npm pnpm corepack` → all four empty; `/etc/os-release:
  VMware Photon OS 5.0` → dry-run skipped. No output invented.

## 7. Risks + 6-step gate

| # | Risk | Check |
|---|---|---|
| R1 | Forgetting `packages/platform` → sidecar build fails on 10 non-test imports | `pnpm -r build` clean; tree count = 49 ts files (34 sidecar + 15 platform) + 4 json + 1 mjs |
| R2 | Tests spawning child processes under a restricted CI sandbox | sidecar tests use platform's spawn/stop primitives — need process-spawn rights; run on a normal dev host/CI runner |
| R3 | `--frozen-lockfile` fails (lockfile cut) | install with `--no-frozen-lockfile`; verify `pnpm ls` pins per manifest |
| R4 | Verbatim `pnpm-workspace.yaml` references missing glob dirs | `pnpm ls -r --depth -1` prints exactly 2 packages |
| R5 | Upstream root package.json accidentally kept | `grep -n postinstall package.json` = 0 hits |
| R6 | Node < 24 | `node --version` ≥ 24 before install |

6-step gate for the real cut: G1 PIN == `5a0c4777…` → G2 copy
byte-identical (`diff -r` per file) → G3 prune = exactly the §5 table → G4
build (2/2 packages) → G5 test (10/10 files pass) → G6 PROVENANCE.md per
package + commit `harvest: opendesign 2 modules @<PIN>`.

## 8. Raw measurement output (verbatim)

```
# census (rubric oracles, run on the PIN tree)
files(ts+tsx)=34  tests=16  main=18  logic_loc=3276  pub_funcs=72  R=47.1
LOC .ts total=5430  .tsx=0

# importers of @open-design/sidecar (non-test), by directory group
5 ./apps/daemon/src | 2 ./apps/daemon/src/sidecar | 1 ./apps/desktop/src/main
1 ./apps/desktop/src/main/updater | 7 ./apps/packaged/src | 1 ./apps/web/sidecar
1 ./e2e/lib/desktop | 1 ./shells/terminal/tests | 4 ./tools/dev/src
1 ./tools/pack/src | 2 ./tools/pack/src/config | 1 ./tools/pack/src/mac | 1 ./tools/pack/src/win

# anchors
578 packages/sidecar/src/operations.ts | 87 packages/sidecar/src/index.ts | 882 packages/platform/src/process.ts
34 packages/sidecar/package.json | 21 tsconfig.json | 9 tsconfig.tests.json | 14 esbuild.config.mjs

# toolchain check
which node npm pnpm corepack → (all four empty); /etc/os-release: VMware Photon OS 5.0 → dry-run SKIPPED
```

## 9. Run disclosure + slot-A cross-check + deviations

- **First run** — nothing inherited (no prior plan files for this subject at
  pass start); dispatched without a fix-list.
- **Cross-check vs slot A** (performed once the slot-A plan appeared): same
  PIN `5a0c4777…` ✓; same ranking rule (#1 s04 / #2 s09 by `(T, S2,
  logic_loc, id)`) ✓; disjoint boundaries A=`packages/contracts` ⊥
  B=`packages/sidecar` ✓; slot A's independent census of contracts matches
  its oracle (s04: files=251, tests=85, s5_loc=41,242 — the ranking's JSON)
  ✓.
- **Declared drifts**: (a) fresh total LOC 5,430 vs the module map's 5,464 —
  decoded as the 34-line package.json, no star impact (§2); (b) dry-run
  build SKIPPED — honest; (c) sidecar's `imported by` includes 1 terminal
  importer located under `shells/terminal/tests/` — the declared census
  mechanism of the module map, not an error.
- Deliverable of this pass: this plan document. No git commit was made here;
  the real cut performs copy + commit per the PROVENANCE standard.
