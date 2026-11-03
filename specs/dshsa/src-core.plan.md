---
subject: deepseek-ai/dsh-superagent-prototype
measured_at: 8c32a9dc5d72c033816c6a8110b37f40cf94fba4
status: plan
---

# Extraction plan — slot: `src/core` (dsh-superagent-core)

- Upstream: `https://github.com/deepseek-ai/dsh-superagent-prototype`
  (branch `main`), pin `8c32a9dc5d72c033816c6a8110b37f40cf94fba4` —
  verified on the clone at plan time (`git rev-parse HEAD` == pin;
  `git ls-remote` == pin).
- **PLAN ONLY.** This document specifies files and commands for a cut
  performed in its own session outside the mining run; it performs no cut
  and creates no repository.
- Method: **copy-then-prune** — copy the whole unit, then prune; no code
  is rewritten by the cut.
- Stars/oracles source: the module map + star ranking for this subject
  (item m03/s03 = 5★, 9/10; oracle numbers `loc: 2088`, `deps_out: 0`).

## 0. Slot selection (declared, with a disclosed reading conflict)

The ≥4★ set has 5 items (app 4★, core 5★, infra 4★, sources 5★,
root 4★). Both extraction slots of this subject were planned against the
**same item, `src/core`**:

- **Slot A** picks `src/core` as the first ≥4★ item in ranking-table
  order (s01, s03, s05, s06, s07 by id). Structural tie-break: core is
  the only item with `deps_out = 0` — the only unit extractable without
  dragging sibling items along.
- **Slot B** also picked `src/core`, applying the same table-order
  reading (#1 = s01 → slot A, #2 = s03 → slot B). An alternative reading
  ("star grade first", as one earlier subject used) would give #1 = s03
  (5★) → slot A = core and #2 = s06 → slot B = `src/sources`.
- **Disclosed conflict and re-plan condition:** the two plans disagree
  on the reading order because the subject's ranking rubric defines a
  tie-break only for the 5★ cap (5★ = {core, sources} = 2 ≤ cap 3, so
  the cap never fires). This document therefore records BOTH readings
  and declares: **slot A = `src/core` (this plan, Option A below) is the
  plan of record**; if the controller standardizes on the star-grade
  reading, slot B must be **re-planned to `src/sources`** (16 files /
  2,059 LOC, deps_out = core, infra, root — a materially different cut
  with vendor'd zod and gh/lark-cli wrappers).
- A pre-cut battery re-measured the plan inputs against the clone at the
  pin (census 15/2088, 21 specs, deps_out 0, single `node:crypto`
  import): **0 mismatches** between the two slot readings' data.
- N/A check: ≥4★ set has 5 items ≥ 2 required → the N/A branch does not
  apply.

## 1. Verbatim copy set (byte-identical to the pin tree)

### 1.1 Source: `src/core/` — 15 files, 2,088 LOC

| File | LOC | | File | LOC |
|---|---:|---|---|---:|
| src/core/tickets.ts | 423 | | src/core/ports.ts | 134 |
| src/core/model.ts | 353 | | src/core/assignments.ts | 140 |
| src/core/evals.ts | 340 | | src/core/intake.ts | 63 |
| src/core/engine.ts | 270 | | src/core/memory.ts | 50 |
| src/core/replies.ts | 95 | | src/core/errors.ts | 61 |
| src/core/part.ts | 80 | | src/core/index.ts | 10 |
| src/core/reasons.ts | 38 | | src/core/ids.ts | 5 |
| src/core/stage.ts | 26 | | **TOTAL** | **2,088** |

- Census invariant: 15 files / 2,088 LOC, measured by `wc -l` per file
  then summed (never a batched-tail count); the total matches the oracle
  exactly (`"loc": 2088`).
- Copy all 15 files verbatim (not a single byte changed), preserving the
  `src/core/` layout so the tests' relative import
  `../src/core/index.ts` keeps working.

### 1.2 Tests copied verbatim: `tests/core-engine.spec.ts` (1,621 lines) + `tests/stage.spec.ts` (61 lines)

These are the only 2 of the 21 specs referencing `src/core` that import
nothing outside core:

- File: tests/core-engine.spec.ts | Line: 1-4 | Content: `import { describe, expect, it, vi } from 'vitest'` / `import { Engine, MemoryRepositories, UserError, ... } from '../src/core/index.ts'` / `import type { Assessor, ... } from '../src/core/index.ts'` — vitest + core only.
- File: tests/stage.spec.ts | Line: 1-2 | Content: `import { describe, expect, it } from 'vitest'` / `import { canRetry, ticketStage, ... } from '../src/core/index.ts'` — vitest + core only.
- The other 19 specs referencing `src/core` are app/sources/infra/
  executor-level tests — each imports beyond core (per-file import scan).
- Oracle reconciliation: 21 specs (test-density oracle: "21 spec / 2088
  LOC × 1000 = 10.1 spec/kLOC") = 22 files grepping `src/core` minus 1
  fixture (`tests/fixtures/host.ts`) — no contradiction; the plan picks
  the 2 core-only specs as the verbatim test set of the standalone unit.
- No fixtures needed: `ls tests/fixtures/` → async.ts, deployment.ts,
  git.ts, host.ts, panel-server.ts, panel.tsx — the 2 copied specs import
  none of them.
- No hidden module mocks: `grep -n "import(\|vi.mock"` on the 2 specs →
  only `vi.mocked(h.executor.start/deliver)` at core-engine.spec.ts:709,1003
  (instance mocks on a port defined by core itself — the tests still
  verify real Engine behavior).

### 1.3 Minimal config (3 files, written fresh in the extracted module — spec only, no code copied)

1. `package.json` (new, reduced from the root package.json):
   - `name`: `dsh-superagent-core` (explicit descriptive name),
     `private: true`, `type: "module"`.
   - `scripts`: only `typecheck` = `tsc --noEmit` and `test` =
     `vitest run` (root: package.json:49-50).
   - `engines`: keep `"node": "^22.19.0 || >=24.0.0"` (root:53-54) —
     core does not use node:sqlite but the floor still blocks old Node.
   - `devDependencies` (pinned to the root's exact versions):
     `typescript@6.0.3`, `vitest@4.1.8`, `@types/node@22.20.0`
     (required by `types: ["node"]` because core uses `node:crypto`).
   - `packageManager: pnpm@11.7.0` kept (toolchain lock, zero cost).
2. `tsconfig.json` — copy the root `compilerOptions` block, prune 3
   points:
   - `include` → `["src/**/*.ts", "tests/**/*.ts"]` (the root's include
     also lists `src/**/*.tsx`, `tests/**/*.tsx`, `tsdown.config.ts` —
     none of these files exist in the copy set).
   - drop `"jsx": "react-jsx"` — no `.tsx` is copied.
   - drop `"declaration": true` — only needed for release builds; this
     module typechecks with `--noEmit`.
   - keep: target ES2024, module/moduleResolution NodeNext, `strict`,
     `skipLibCheck`, `noUncheckedIndexedAccess`, `verbatimModuleSyntax`,
     `allowImportingTsExtensions`, `rewriteRelativeImportExtensions`,
     `lib [ES2024, DOM]` (DOM kept to avoid hidden DOM-type surprises,
     zero cost), `types ["node"]`.
   - Rationale for keeping both extension flags: both specs import with
     an explicit `.ts` suffix (`'../src/core/index.ts'`); dropping either
     flag breaks typecheck immediately.
3. `vitest.config.ts` — copy the root config line, prune the react
   `resolve.dedupe`: keep `test.include = ['tests/**/*.spec.{ts,tsx}']`
   (vitest.config.ts:3); the react dedupe existed for the panel — no
   react remains in the extracted module.

### 1.4 NOT copied (structural prune)

- `src/app`, `src/client`, `src/sources`, `src/executor`, `src/infra`
  and the 8 root modules — other items; core imports none of them
  (evidence in §2).
- The 19 non-core-only specs and the whole `tests/fixtures/` tree.
- The root `pnpm-lock.yaml`, `tsdown.config.ts`, `locale/`, `prompts/`,
  `skills/`, `docs/`, `examples/`, `scripts/`, `cordis.patch.yml` —
  unrelated to the core unit.

## 2. Dependency decisions (one reason per row)

| Dependency | Decision | Reason |
|---|---|---|
| `node:crypto` | **KEEP** | Node stdlib; the ONLY non-relative import of core (src/core/ids.ts:2 `import { createHash } from 'node:crypto'`); typed by `@types/node`. |
| `typescript@6.0.3` | **KEEP** (dev) | the `typecheck` script needs the compiler. |
| `vitest@4.1.8` | **KEEP** (dev) | runner of the 2 copied specs; pinned to the root version to avoid behavior drift. |
| `@types/node@22.20.0` | **KEEP** (dev) | tsconfig `types: ["node"]` + `node:crypto` need Node typings. |
| `zod@4.4.3` | **CUT** | 0 references inside src/core (the from-clause scan of all 15 files returns only node:crypto); zod serves policy/sources. |
| `proper-lockfile@4.1.2` | **CUT** | runtime dep of the app/infra tier (system file lock); core does not use it. |
| `tsdown@0.22.14` + `build` script | **CUT** | bundles the whole app (`lib/` exports) — the extracted module only needs typecheck+test. |
| all `@deepseek-ai/*` (peer + dev, 25 packages) | **CUT** | only app/client/executor/runtime import them (e.g. runtime.spec imports `@deepseek-ai/cordis`, `@deepseek-ai/dsh-scope`); the src/core from-clause scan = 0 hits. |
| `react`/`react-dom`/`jsdom`/`@types/react*` | **CUT** | panel client + panel specs only; the vitest config's react dedupe is pruned accordingly. |
| root `pnpm-lock.yaml` | **REGENERATE** | the root lock pins the whole `@deepseek-ai/*` tree (partly alphas that may need a private registry); after writing the reduced package.json run `pnpm install` (not frozen) to produce a fresh lockfile, then use `--frozen-lockfile` in later runs. |

- VENDOR: nothing to vendor — core has no npm dependency beyond the
  stdlib; this structural fact is why core is the cleanest
  copy-then-prune candidate.

## 3. Independent build+test commands (expected dry-run)

- Standard command, run inside the extracted module after the cut:
  `pnpm install --frozen-lockfile && pnpm typecheck && pnpm test` (vitest).
- Cut + verify sequence (for the real cut, outside the run): clone the
  pin → create the tree preserving `src/core/` + `tests/` layout → copy
  17 files verbatim (§1.1-1.2) → write the 3 configs (§1.3) →
  `pnpm install` (fresh lockfile) → `pnpm typecheck` → `pnpm test` →
  §4 checklist.
- **DRY-RUN: SKIPPED (honestly)** — the planning sandbox used a git-only
  image without a JS toolchain:

  ```
  $ which node pnpm npm
  which: no node in (/opt/bitnami/common/bin:/opt/bitnami/git/bin:...)
  which: no pnpm in (/opt/bitnami/common/bin:/opt/bitnami/git/bin:...)
  which: no npm in (/opt/bitnami/common/bin:/opt/bitnami/git/bin:...)
  ```

  No toolchain was installed and no output was fabricated. Installing
  Node 22 + pnpm would exceed the dry-run budget of a git-only sandbox.
- Expected note: on the **root repository** `pnpm install
  --frozen-lockfile` pulls the full `@deepseek-ai/*` peer/dev tree
  (0.2.1-alpha.2 alphas, possibly a private registry) — not this plan's
  target; the extracted module needs only 3 public devDeps (typescript,
  vitest, @types/node), so its install is light and touches no private
  registry.

## 4. Prune risks + post-cut verification

| # | Risk | Mitigation / post-cut check |
|---|---|---|
| R1 | core-engine.spec.ts (1,621 lines) is an integration-lite Engine test; a hidden non-core dependency would break the module | Full `^import` scan done: only vitest + `../src/core/index.ts` (lines 1-4). Post-cut: `pnpm test` passes 2 files; on an import error, audit symbols missing from `src/core/index.ts` — never patch test files; record the deviation and escalate. |
| R2 | the root tsconfig `include` pulls the whole repo → typecheck errors on uncopied files | Prune include to `src/**/*.ts` + `tests/**/*.ts` (§1.3). Check: `tsc --noEmit` exit 0 on the new tree. |
| R3 | losing `allowImportingTsExtensions`/`rewriteRelativeImportExtensions` in the new config | Keep both flags at root values (§1.3). Check: no TS5097 (`.ts` import extension) errors. |
| R4 | vitest include keeps the `{ts,tsx}` pattern although no `.tsx` remains | Harmless (no file matches); keeps the config diff minimal. Check: `pnpm test` runs exactly 2 files (core-engine.spec.ts, stage.spec.ts). |
| R5 | `node:crypto` untyped if `@types/node` is forgotten | `@types/node@22.20.0` is a mandatory devDep (§1.3). Check: typecheck exit 0, no "Cannot find module 'node:crypto'". |
| R6 | running `--frozen-lockfile` immediately on the new package.json FAILS (no matching lock) | §3 sequence mandates `pnpm install` (not frozen) first to produce the lockfile; frozen only in later runs. Stated in the real-cut commands. |
| R7 | copy not byte-identical / pin drift | Check: `diff -r` each file against the pin tree + re-census `wc -l` per file: 15 files = 2,088 LOC, 2 specs = 1,621 + 61 = 1,682 LOC (module total 3,770 LOC); any number mismatch = stop, never hand-patch. |
| R8 | an out-of-core import slipped through | Automated post-cut check: `grep -rn "from '" src/core | grep -v "\./" | grep -v "node:"` must return 0 lines; `grep -rn "\.\./" src/core/*.ts` must return 0 lines (both measured pre-cut: 0 and 0). |

## 5. Pre-cut verification battery (command → result, on the pin clone)

| Command (git-only sandbox) | Result |
|---|---|
| `git rev-parse HEAD` | `8c32a9dc5d72c033816c6a8110b37f40cf94fba4` == pin |
| `wc -l src/core/*.ts` | 15 files, total 2,088 (matches oracle loc 2088) |
| `grep -rn "from '" src/core/*.ts \| grep -v "from '\./"` | exactly `src/core/ids.ts:2: import { createHash } from 'node:crypto'` |
| `grep -rn "\.\./" src/core/*.ts` | empty (no sibling imports — matches deps_out = 0) |
| `grep -rl "src/core" tests --include='*.ts' --include='*.tsx' \| wc -l` | 22 (21 specs + tests/fixtures/host.ts) |
| `^import` scan of the 21 specs | only core-engine.spec.ts + stage.spec.ts are core-only; the other 19 import beyond core |
| `grep -n "^import" tests/core-engine.spec.ts` | lines 1,2,4: vitest + `../src/core/index.ts` |
| `grep -n "^import" tests/stage.spec.ts` | lines 1-2: vitest + `../src/core/index.ts` |
| `cat tsconfig.json` / `grep -n` | line 5 NodeNext, 14 allowImportingTsExtensions, 15 rewriteRelativeImportExtensions, 20 jsx, 22 include |
| `grep -n … package.json` | line 4 license MIT; 49 typecheck; 50 test; 54 node ^22.19.0; 59-60 proper-lockfile/zod; 110 @types/node; 116 typescript; 117 vitest |
| `cat vitest.config.ts` | line 3: dedupe react + `include: ['tests/**/*.spec.{ts,tsx}']` |
| `ls tests/fixtures/` | async, deployment, git, host, panel-server, panel.tsx — the 2 copied specs use none |
| `which node pnpm npm` | none present → dry-run SKIPPED |
| `grep -n "license" package.json` | MIT — used for the PROVENANCE of the real cut |

- Source consistency: the 4 measured values reconcile directly between
  the pin tree and the star-ranking record — loc 2088 ✓, 21 specs ✓
  (22 minus 1 fixture), deps_out 0 ✓, `node:crypto` uniquely at
  ids.ts:2 ✓. No source/brief/upstream mismatch found.

## 6. Acceptance gates for the real cut (fail-closed)

| Gate | Command | Pass criterion |
|---|---|---|
| G1 | census re-run | 15 files = 2,088 LOC, per-file `wc -l` then summed |
| G2 | `diff -r` copy set vs pin tree | 0 differences (17 files: 15 src + 2 specs) |
| G3 | out-of-core import grep (§4 R8) | 0 lines |
| G4 | `pnpm install` | exit 0, fresh lockfile (not frozen on first run) |
| G5 | `pnpm typecheck` | exit 0 |
| G6 | `pnpm test` (Option A cut, outside run) | exit 0 ∧ vitest runs 2 spec files |
| G7 | license | `head -1 LICENSE` = "MIT License" ∧ cut package.json `"license": "MIT"` |
| G8 | provenance | PROVENANCE.md: upstream_sha == pin ∧ census 15/2,088 |

Fail-closed: ANY gate FAIL → no push, report BLOCKED with raw output.

## 7. Options considered for slot B (declared, not executed)

- **Option A (recommended, plan of record):** both slots realize
  `src/core` as planned above; the second slot is intentionally the same
  unit (the conflict is §0's disclosure, not a duplicated cut).
- **Option B (fallback if the controller standardizes the star-grade
  reading):** re-plan slot B to `src/sources` (m06/s06, 5★, 9/10;
  16 files / 2,059 LOC; deps_out = core, infra, root). That cut vendors
  `zod`, keeps the `Commands` wrapper (gh/lark-cli), and requires
  re-running this plan's battery against `src/sources` (the github/
  feishu plugin entries additionally need `@deepseek-ai/cordis` — a
  materially heavier extraction).
