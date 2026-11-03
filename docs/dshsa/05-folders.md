---
subject: deepseek-ai/dsh-superagent-prototype
measured_at: 8c32a9dc5d72c033816c6a8110b37f40cf94fba4
status: final
---

# Folders

- PIN (verified in clone): `8c32a9dc5d72c033816c6a8110b37f40cf94fba4` —
  `git rev-parse HEAD` in the fresh clone returned exactly the census pin.
- Inputs: `01-cartography.md` (top-level directories, manifests, census),
  `02-module-map.md` (7-module map, m01 largest).
- Method: dedicated git-only sandbox; shallow clone; every measurement
  re-run on the clone (no number copied without re-measurement).
- Evidence rule: every `File:`/`Line:` below refers to the clone at the
  pin. Every count is reproducible with the command quoted alongside it.

## 1. Region map (from the cartography's directory list, sizes re-measured)

The cartography's top-level list has 18 entries. Sizes below were
re-measured with:

```
for d in <dir>; do n=$(find $d -type f | wc -l); l=$(find $d -type f -print0 | xargs -0 cat | wc -l); echo "$d files=$n loc=$l"; done
```

| Region | Size (files / LOC) | Role (one sentence) |
|---|---|---|
| `src/` | 111 / 15,587 (incl. 382-line `client.css`) | All TypeScript source of the single-plugin bundle; six functional zones plus 8 root files (breakdown below). |
| `src/app/` | 38 / 5,292 | Server-side orchestration layer: Runtime composition root, SQLite Store, Sessions, migration, Passes/Outbox/Effects/Notices, master tools, loopback HTTP + views (module map item m01, the largest module). |
| `src/client/` | 27 / 4,419 | Browser-side React management panel mounted into the DSH web client (item m02; 26 ts/tsx = 4,037 LOC + `client.css` 382). |
| `src/core/` | 15 / 2,088 | Self-contained domain engine (Trigger→Ticket→Assignment→Reply) with ports; only outgoing dependency is `node:crypto` (item m03). |
| `src/executor/` | 2 / 838 | Runs each Assignment in a persistent DSH worker session (`worker-<ticketId>`) with its own workspace (item m04). |
| `src/infra/` | 5 / 347 | Shared process infrastructure: `commands.ts` wraps gh/git/lark-cli subprocesses, `environment.ts` prepares worker env shims, `health.ts` is the component-health registry (item m05). |
| `src/sources/` | 16 / 2,059 | Two pluggable Source kinds (github, feishu) as Cordis plugin entries plus contract/registry layer and per-kind satellites (item m06). |
| `src/*.ts` (8 root files) | 8 / 544 | Host-plugin shell: `index.ts` plugin entry (`apply(ctx)`), `deployment.ts` config schema, `policy.ts` zod settings + admission gate, plus shared small utilities (item m07). |
| `tests/` | 65 / 14,960 | Vitest suite: 48 `*.spec.ts` + 11 `*.spec.tsx` + 6 `fixtures/` files; mirrors source units (see §2.3). |
| `docs/` | 9 / 1,973 | Numbered reading path `000-philosophy.md` … `008-cookbook.md` — philosophy, domain, authorization, execution, prompts, panel, deployment, architecture, cookbook. |
| `prompts/` | 15 / 438 | System prompts per role/stage (`orchestrator.md`, `worker.md`, `dispatch.md`, `handoff*.md`, `replies.md`, `admission.md`, `shared.md`, `subscriptions.md`, `work.md`, `cli.md`) + `team/` (communication, delivery, scope). |
| `skills/` | 2 / 26 | One `SKILL.md` per Source kind (`dsh-superagent-github`, `dsh-superagent-feishu`), read-only context manual for workers. |
| `locale/` | 2 / 12 | UI dictionaries `en.json` / `zh.json` (title "Superagent"), exported via package `./locale/*.json`. |
| `scripts/` | 1 / 250 | `dsh-superagent` — a Python 3 service manager (status/start/restart of the local service in tmux). |
| `examples/` | 1 / 12 | `profile.cordis.patch.yml` — example profile configuration with placeholders, referenced by docs/006. |
| Root manifests & docs | 10 files | `package.json`, `tsconfig.json`, `tsdown.config.ts`, `vitest.config.ts`, `cordis.patch.yml` (bundle layer inserting the plugins), `README.md`, `SETUP.md`, `LICENSE` (MIT), `pnpm-lock.yaml`, `.gitignore`. |

Role sentences are cross-checked against the module map's responsibilities —
no conflict found.

## 2. Representative structure: `src/` and its largest module `src/app/`

The six `src/` zones are the module-map items; m01 `src/app` is the
largest (5,292 LOC / 38 files). So the representative structure is `src/`
overall with `src/app/` opened up.

### 2.1 `src/` layout — six zones + 8 root files

```
src/
├── index.ts … setup.ts          8 root files  (544 LOC)  host-plugin shell
├── app/        38 files (5,292)  server orchestration + HTTP + views
├── client/     27 files (4,419)  React panel (tsx + css)
├── core/       15 files (2,088)  domain engine + ports
├── executor/    2 files (  838)  DSH worker-session runner
├── infra/       5 files (  347)  subprocess/env/health utilities
└── sources/    16 files (2,059)  github/feishu source kinds
```

Every root file opens with a one-line JSDoc role statement — all 8
verified verbatim:

- `src/index.ts:1` — `/** Main plugin entry: mounts the Runtime and provides its restart callback for deployment account changes. */`
- `src/deployment.ts:1` — `/** Plugin configuration and startup verification for repository access and agent CLI identities. */`
- `src/policy.ts:1`, `src/admission.ts:1`, `src/kv.ts:1` — multi-line `/** … */` blocks (opening line `/**`)
- `src/limits.ts:1` — `/** Validation bounds shared between host schemas and management panel forms. */`
- `src/navigation.ts:1` — `/** Open a DSH Session in the workspace after ensuring the session catalog is loaded. */`
- `src/setup.ts:1` — `/** Structured startup and configuration errors with the settings location where the operator can fix them. */`

Dependency direction (from the module map's 22-edge matrix): everything
may import `core` (m03 `deps_out: []` — core imports nothing above
`node:crypto`), while `core` imports no sibling — the clean layering an
entry-point reader should expect.

### 2.2 Inside `src/app/` (m01) — flat files + 2 subdirectories

Layout: **28 flat `.ts` files + `tools/` (3 files) + `views/` (7 files)
= 38**. Subdirectories are used only where a family of >2 same-role files
exists; there is no deeper nesting anywhere in `src/` (max depth:
`src/app/views/…`, `src/app/tools/…` — verified from the full file
listing).

Largest files (LOC, `cat $f | wc -l` per file):

| File | LOC | First-line role statement (verbatim) |
|---|---|---|
| `src/app/migration.ts` | 616 | `/**` … `* Migrates a schema 10 database to schema 11 in a single transaction so runtime readers never convert legacy shapes.` (`migration.ts:2`; largest file in the module, matching the module map's `main_files`) |
| `src/app/sessions.ts` | 352 | `/** Lifecycle, prompt/tool/skill decoration, message delivery, and budget retry tracking for orchestrator and worker DSH sessions. */` |
| `src/app/resources.ts` | 308 | `/** Serves paginated context resources to orchestrator_read so large bodies stay out of model prompts until requested. */` |
| `src/app/tools/main.ts` | 301 | `/** Main Session tools for routing triggers, assessing candidates, sending replies, and updating settings and prompts. */` |
| `src/app/store.ts` | 291 | `/** SQLite persistence for domain aggregates, key-value state, settings history, and the channel outbox. */` |
| `src/app/assessment.ts` | 282 | `/** Proactive candidate assessment for the main Session: relays candidate cards, serves bounded context reads, and records outcomes. */` |
| `src/app/settings.ts` | 267 | `/** Block-scoped settings validation, optimistic concurrency saves, processing pause control, and source policy synchronization. */` |
| `src/app/runtime.ts` | 254 | `/** Application composition root and lifecycle manager for dsh-superagent. */` (`runtime.ts:1`; `export class Runtime extends Service implements SourceHost` at line 59) |
| `src/app/http.ts` | 247 | `/** Loopback-only management HTTP routes with same-origin enforcement for the web panel. */` |
| `src/app/views/overview.ts` | 80 | `/** Overview view: active system problems, tickets awaiting human action, executor load, and 24-hour trigger flow. */` |

`views/` (7 files: overview, records, settings, sources, text, threads,
tickets) are HTTP-side projections rendered for the web panel — one per
panel area; `tools/` (tool.ts, main.ts, executor.ts) define the
agent-facing Session tools. Stateful services are classes, one per file,
named after the domain role and implementing a core port:

- `src/app/store.ts:51` — `export class Store implements Repositories`
- `src/app/assessment.ts:89` — `export class MasterAssessor implements Assessor`
- `src/app/outbox.ts:22` — `export class Outbox implements OutboxPort`
- `src/app/sessions.ts:93` — `export class Sessions`
- `src/app/effects.ts:46` — `export class Effects`
- ports themselves live in `src/core/ports.ts` (`/** Ports the core depends on. … */`, line 1).

### 2.3 Main code vs tests

Tests are **not** colocated: a separate top-level `tests/` tree mirrors
the source tree by naming, plus a `fixtures/` family.

- Runner scope: `vitest.config.ts:3` — `test: { include: ['tests/**/*.spec.{ts,tsx}'] }` (3-line config file).
- Counts: 48 `*.spec.ts` + 11 `*.spec.tsx` + 6 fixtures (`find tests -name '*.spec.ts' | wc -l` etc.); totals 65 files / 14,960 LOC — the largest non-source region by LOC after `src/` itself.
- Host/server tests import the real modules: `tests/runtime.spec.ts:1-4` imports `@deepseek-ai/cordis` and uses `mkdtempSync` temp dirs; `tests/core-engine.spec.ts:4` — `waitsForPerson } from '../src/core/index.ts'`.
- Panel (tsx) tests mount through shared fixtures: `tests/panel-overview.spec.tsx:4-6` — `import { en, zh } from '../src/client/locales.ts'`, `import { usePanel, mount, … } from './fixtures/panel.tsx'`, `import { server, … } from './fixtures/panel-server.ts'`.
- Fixtures (`tests/fixtures/`): `async.ts`, `deployment.ts`, `git.ts`, `host.ts`, `panel-server.ts`, `panel.tsx` — a fake host, a fake git, and a fake panel server, so tests run without GitHub/Feishu.
- Two specs enforce documentation conventions instead of behavior: `tests/class-docs.spec.ts:1` — `/** Verifies that every class in src has a preceding JSDoc block. */` (regex at line 13 scans every `class` declaration for a preceding `/** … */`); `tests/docs.spec.ts:7` — `const NUMBERED = /^(\d{3})-[a-z0-9-]+\.md$/` (numbered-doc naming) plus markdown link-integrity checks over `README.md`, `SETUP.md`, `docs/`.

## 3. Naming conventions (from code, ≥3 required)

1. **kebab-case file names everywhere** (no snake_case, no PascalCase files): `src/app/execution-environment.ts`, `src/app/retry-health.ts`, `src/app/settings-history.ts`, `src/sources/admission-context.ts`, `tests/runtime-concurrency.spec.ts` (full file listing, command `find . -path ./.git -prune -o -type f -print | sort`).
2. **Spec-per-unit mirroring**: a test file is named after the unit it tests — `src/app/runtime.ts` ↔ `tests/runtime.spec.ts`, `src/app/store.ts` ↔ `tests/store.spec.ts`, `src/policy.ts` ↔ `tests/policy.spec.ts`; client tab views get `panel-<tab>.spec.tsx` (e.g. `tests/panel-overview.spec.tsx` imports `../src/client/locales.ts` and mounts via `./fixtures/panel.tsx`, lines 4-6).
3. **Numbered docs `NNN-kebab.md`**: `docs/000-philosophy.md` … `docs/008-cookbook.md`; the pattern is machine-enforced — `tests/docs.spec.ts:7` `const NUMBERED = /^(\d{3})-[a-z0-9-]+\.md$/`.
4. **Mandatory JSDoc headers**: every module file opens with a one-line `/** … */` role statement (8/8 root files quoted in §2.1; all sampled `src/app` files too), and every `class` must have a preceding JSDoc block — enforced by `tests/class-docs.spec.ts`.
5. **PascalCase types/classes, camelCase functions; services implement core ports**: `export function isoTime(value: string): string` (`src/core/model.ts:17`), `export function directionAllowed(value: unknown): value is AdmissionDirection` (`src/policy.ts:26`); classes `Engine` (`src/core/engine.ts:24`), `Store implements Repositories` (`store.ts:51`), `DshExecutor implements Executor` (`src/executor/dsh.ts:207`), `SourceRegistry implements SourceScope` (`src/sources/registry.ts:13`). Port interfaces are role names without `I`-prefix: `SourceScope` (`src/core/ports.ts:12`), `Policy` (`ports.ts:17`).
6. **Kind-prefixed satellites + runtime name patterns**: per-source files share the kind prefix — `github-channel.ts`, `github-pull.ts`, `github-read.ts`, `github-trigger.ts` (4) and `feishu-channel.ts`, `feishu-image.ts`, `feishu-loops.ts`, `feishu-read.ts`, `feishu-trigger.ts` (5), beside one kind entry each (`github.ts`, `feishu.ts`); worker sessions are named `worker-<ticketId>` — `src/executor/dsh.ts:23-24`: `/** Returns the worker session ID (`worker-<ticketId>`) for a ticket. */ export const workerSessionId = (ticketId: string): string => `worker-${ticketId}``.

## 4. Deviations from common TypeScript style

Two deviations from mainstream TypeScript conventions were found; each is
a deliberate, repo-wide convention, not an accident. No other significant
deviation was detected (negative findings listed in §4.3 with evidence).

### 4.1 Every relative import carries an explicit `.ts` extension

Mainstream TS style omits extensions on relative imports; here they are
mandatory (enabled by `allowImportingTsExtensions` +
`rewriteRelativeImportExtensions` in `tsconfig.json`, verbatim in
`01-cartography.md`).

- Count: **822** occurrences of `from './…`/`from '../…` ending in `.ts'` across `src/` + `tests/` (`grep -rn "from '\.\.\?/" src tests --include='*.ts' --include='*.tsx' | grep -c "\.ts'"`).
- Examples (all grep-verified):
  - `src/index.ts:4` — `import { Runtime } from './app/runtime.ts'`
  - `src/core/assignments.ts:2` — `import { key } from './ids.ts'`
  - `src/app/http.ts:6` — `… } from './api.ts'`
  - `tests/core-engine.spec.ts:4` — `… } from '../src/core/index.ts'`

### 4.2 Semicolon-free statements, single-quote-only strings

The statement style is semicolon-free (Standard-JS-like), which differs
from the semicolon-terminating style common in TS codebases;
strings/imports are single-quote only.

- Line-end semicolons: **0** in `src/app/runtime.ts`, `src/app/sessions.ts`, `src/core/engine.ts`, `src/client/app.tsx`, `tests/runtime.spec.ts` (`grep -c ';$' <file>` per file). The only `;$` hits in `src/` are non-TypeScript text:
  - `src/app/store.ts:72-76` — SQL DDL inside a template literal, e.g. line 72: `CREATE TABLE IF NOT EXISTS trigger (id TEXT PRIMARY KEY, value TEXT NOT NULL, at TEXT NOT NULL);`
  - comment prose, e.g. `src/core/model.ts:14` — `… so stored timestamps compare lexicographically in memory and SQL;` (inside a `/** */` block).
- Quotes: **0** double-quoted imports in `src/` + `tests/` (`grep -rn 'from "' src tests --include='*.ts' --include='*.tsx' | wc -l` → 0).

### 4.3 Checked and found standard-compliant (no further significant deviation)

- `strict: true`, `noUncheckedIndexedAccess: true`, `verbatimModuleSyntax: true`, `jsx: react-jsx`, target ES2024 / NodeNext (`tsconfig.json`, verbatim in `01-cartography.md`).
- Type-only imports consistently use `import type` — e.g. `src/index.ts:5` (`import { Config, machineOf, type DeploymentConfig } from './deployment.ts'`), `src/app/store.ts:5-6` (10-item `type …` import from `../core/index.ts`), `src/core/assignments.ts:5`.
- **Zero `enum`** declarations in `src/` (`grep -rn ' enum ' src --include='*.ts' | wc -l` → 0).
- **Zero `any` in type positions**: `grep -rnE ':\s*any\b|as any\b|<any>|any\[\]' src` → 3 matches, all inside comment prose, none is an annotation or cast: `src/core/tickets.ts:119` ("… wakes an ended ticket as any attached message does."), `src/core/evals.ts:178` ("… the gate judges it as any message on its …"), `src/executor/dsh.ts:621` ("… which goes on in the background as any turn's does.").
- Named exports only: exactly **1** `export default` in `src/`, and it is the ambient CSS module declaration `src/client/css.d.ts:4` (`export default text`).
- `type` aliases (191) outnumber `interface` (124) (`grep -rn '^export type \|^type ' src | wc -l` / `'^export interface \|^interface '`): union-object types model data (`export type GateResult = { admissible: false; reason: string } | { … }`, `src/core/ports.ts:7`), `interface` models service ports (`export interface SourceScope`, `ports.ts:12`; `export interface Policy`, `ports.ts:17`). Mixed usage is a tendency, not a deviation — recorded as observation only.

## 5. Reading guide (what to read first, and why)

1. **`README.md`, then `docs/` in numbered order 000 → 008.** The README mandates this: "Read the numbered documents in order; each builds only on the ones before it." (README.md, Documentation section), and the numbers encode the dependency order — 000 philosophy → 001 domain → 002 authorization → 003 execution → 004 prompts → 005 panel → 006 deployment → 007 architecture → 008 cookbook.
2. **`docs/007-architecture.md` as the bridge into code.** Its opening line says exactly how to proceed: "Start with the runtime and Engine, then use the module and test tables as a code index" (`docs/007-architecture.md:3`), and its mermaid graph shows the plugin → Engine → Store/Policy/SourceRegistry/MasterAssessor/DshExecutor/Outbox wiring.
3. **`src/index.ts` (27 lines) — the plugin entry.** Smallest useful map of the whole system: `name`/`inject`/`Config` + `apply(ctx)` mounting `Runtime` (`src/index.ts:4,10`), and `export * from './core/index.ts'` (line 27) advertising the domain barrel.
4. **`src/core/` before anything else in `src/`.** It is the only zone with no outgoing dependencies (m03 `deps_out: []`; sole external import is `node:crypto`, `src/core/ids.ts:2`), so it reads standalone: `model.ts` (domain vocabulary) → `ports.ts` (the six ports the rest of the repo implements) → `engine.ts` (`export class Engine`, line 24) → `tickets.ts`/`assignments.ts`.
5. **Then `src/app/runtime.ts:59` (`class Runtime extends Service implements SourceHost`)** as the composition root — from there every other zone is one hop (`sources/` for GitHub/Feishu entry, `executor/` for worker sessions, `app/views/` + `src/client/` for the panel).
6. **Use `tests/` as the executable index, not documentation.** Spec names mirror units (§3.2), and `tests/class-docs.spec.ts` / `tests/docs.spec.ts` document the conventions themselves — reading a spec is the fastest way to see the intended behavior of its unit.

## 6. Verification

- Clone pin equals the census pin: `git rev-parse HEAD` →
  `8c32a9dc5d72c033816c6a8110b37f40cf94fba4` (single-commit shallow
  clone, `git log -1` same hash).
- Census reconciliation (all numbers re-measured, none copied):
  - `src/` 111 files / 15,587 LOC − `src/client/client.css` (382 LOC, only non-TS file) = **110 files / 15,205 LOC** = exactly the module-map total.
  - `tests/` 65 files / 14,960 LOC; `tsdown.config.ts` 14 LOC; `vitest.config.ts` 3 LOC.
  - Files: 110 + 65 + 2 = **177** = census (147 `.ts` + 30 `.tsx`). LOC: 15,205 + 14,960 + 17 = **30,182** = census (25,388 + 4,794). Exact match, no drift.
- Zone sizes re-measured in §1 match the cartography and module map on
  every zone (app 38/5292, client 27 (26 ts/tsx = 4037 + css 382),
  core 15/2088, executor 2/838, infra 5/347, sources 16/2059).
