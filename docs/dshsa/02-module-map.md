---
subject: deepseek-ai/dsh-superagent-prototype
measured_at: 8c32a9dc5d72c033816c6a8110b37f40cf94fba4
status: final
---

# Module map

- Subject: `deepseek-ai/dsh-superagent-prototype` · TypeScript single-package
  bundle · universe **7 items** (unit = functional zone of `src/`; cap of
  200 items). Short names used in dependency columns: `app`, `client`,
  `core`, `executor`, `infra`, `sources`, and `root` = the 8 root modules
  of `src/` (m07).
- PIN: `8c32a9dc5d72c033816c6a8110b37f40cf94fba4` (branch `main`,
  2026-10-31 20:06:31 +0800, "feat: add the dsh-superagent research
  prototype") — every number below was measured on the PIN tree by
  independently cloned measurement passes that all re-verified
  `git rev-parse HEAD == 8c32a9dc`.
- Census basis: `files` counts `.ts` + `.tsx` per extension then sums
  (v9 formula); tests are **not owned by any item** — the 59 spec files
  (48 `*.spec.ts` + 11 `*.spec.tsx`) count toward the test-density signal
  in the ratings instead.
- Dependencies: "depends on" = sibling items THIS item imports across
  item boundaries (relative imports reaching outside the item's directory;
  same-item imports and external packages such as `zod`, `node:crypto`,
  `@deepseek-ai/*` are excluded). 22 directed edges, cross-checked in both
  directions by independent measurement passes (Σ out-lines = Σ in-lines
  per edge).
- Invariants recomputed from the 7 items and matching the cert exactly:
  files **110/110**, loc **15,205/15,205** (TypeScript census).
- Ratings (★) come from the oracle-based star ranking over this map
  (signals: reusability = few outbound deps, centrality = fan,
  test density, distinctiveness probes, non-test substance; hard cap of
  three ★5 per repository).

Distribution: ★5 = 2 (cap 3 not reached) · ★4 = 3 · ★3 = 2 ·
total score 51/70.

## Index

| id | module | path | loc | ★ |
|----|--------|------|----:|---|
| m01 | dsh-superagent/src/app | src/app | 5,292 | 4 |
| m02 | dsh-superagent/src/client | src/client | 4,037 | 3 |
| m03 | dsh-superagent/src/core | src/core | 2,088 | 5 |
| m04 | dsh-superagent/src/executor | src/executor | 838 | 3 |
| m05 | dsh-superagent/src/infra | src/infra | 347 | 4 |
| m06 | dsh-superagent/src/sources | src/sources | 2,059 | 5 |
| m07 | dsh-superagent/src (root modules) | src/*.ts | 544 | 4 |

## m01 dsh-superagent/src/app

Server-side orchestration layer of the orchestrator: `Runtime`
(`runtime.ts:59`, composition root) wires the SQLite `Store`, `Sessions`
(`sessions.ts:93` — lifecycle/prompt/tool/skill/delivery/budget-retry for
orchestrator and worker sessions), DB schema migration 10→11
(`migration.ts:20`), Passes/Outbox/Effects/Notices (trigger → ticket →
delivery), `MasterAssessor` + main-session tools, loopback HTTP + view
projections for the web panel.

- main files: `src/app/runtime.ts:59` (entry, 254 lines);
  `src/app/migration.ts` (616 lines, largest)
- depends on: core (25 import lines), executor (9), infra (18),
  sources (38), root (38) — 128 boundary import lines from 32/38 files
- imported by: client (6 lines), executor (6), root (3) — 15 lines
- loc: 5,292 (38 files) · rating ★★★★ (8/10)

## m02 dsh-superagent/src/client

Browser-side React management panel: `index.tsx` mounts the panel,
sidebar icon and Plugin-Manager config view into the DSH web client
(`index.tsx:48,53`), `app.tsx` renders the root shell (`app.tsx:173`),
five tab views (Overview/Source/Trigger/Eval/Execution) + Settings /
Prompts / Deployment, same-origin REST client (`api.ts:1`), shared
widgets, bilingual zh/en dictionaries (`locales.ts:8,752`).

- main files: `src/client/index.tsx:48,53` (entry, 58 lines);
  `src/client/locales.ts` (770 lines, largest)
- depends on: app (6), core (4), sources (6), root (10) — 26 lines from 13 files
- imported by: nothing (leaf — browser bundle entry)
- loc: 4,037 (26 ts/tsx files; `client.css`, 382 lines, exists in the
  directory but is excluded from the ts census) · rating ★★★ (5/10)

## m03 dsh-superagent/src/core

The standalone domain engine of the proactive agent: model + ports define
Trigger/Thread/Ticket/Assignment and the Policy/Assessor/Executor/Outbox/
Repositories ports, `Engine` (`engine.ts:20-22`) is the single
transactional entry point coordinating intake → evals → assignments →
replies, and `Tickets` (`tickets.ts:29`) manages the ticket lifecycle
from accept to end with subscription/thread binding.

- main files: `src/core/index.ts:1` (entry, 10 lines);
  `src/core/tickets.ts` (423 lines, largest)
- depends on: nothing outward (sole external import is stdlib
  `node:crypto`, `ids.ts:2`)
- imported by: app (25 files), sources (13), root (3), client (3),
  executor (1) — 45 files
- loc: 2,088 (15 files) · rating ★★★★★ (9/10)

## m04 dsh-superagent/src/executor

Runs each Assignment of a ticket in a persistent DSH worker session
`worker-<ticketId>` with its own workspace: `DshExecutor` (`dsh.ts:207`)
prepares the workspace, queues launch/deliver through the effect queue
with concurrency limited by `WorkerSlots` (`dsh.ts:171`), listens to
`agent/status`, `agent/inbox/claimed`, `session/event`, `agent/error` to
report transitions back to the Engine, and retries transient failures
with exponential backoff; `background.ts` manages shell jobs and
subagents left behind by worker turns (`dsh.ts:202-204`).

- main files: `src/executor/dsh.ts:207` (entry, 673 lines);
  `src/executor/background.ts` (165 lines)
- depends on: app (6 lines), core (1 file), infra (2), root (2) — 11 files
- imported by: app (9 files/9 lines)
- loc: 838 (2 files) · rating ★★★ (6/10)

## m05 dsh-superagent/src/infra

Shared process infrastructure: `Commands` (`commands.ts:59`) wraps
`gh`/`git`/`lark-cli` subprocesses under the deployment account with
normalized `CliError` errors (`commands.ts:14`), `environment.ts`
(`environment.ts:79`, 157 lines, largest) writes worker-bin/gitconfig
shims and safe worker environment variables (`WORKER_COMMANDS` @18),
`health.ts` is the component-health registry used by the panel
overview/sources views (`health.ts:1`).

- main files: `src/infra/environment.ts:79` (157 lines, largest);
  `src/infra/commands.ts:59` (115 lines)
- depends on: root (2 files/3 lines), sources (1/1)
- imported by: app (15 files/18 lines), executor (1/2), sources (13/18),
  root (3/4) — 32 files/42 lines
- loc: 347 (5 files) · rating ★★★★ (7/10)

## m06 dsh-superagent/src/sources

Two pluggable Source kinds — `github.ts` (`githubKind` @38, plugin entry
@112) and `feishu.ts` (`feishuKind` @31, entry @132), each a Cordis
plugin entry that registers a `SourceKind` and runs polling loops — plus
the shared contract layer (`kind.ts:85` SourceKind interface; `host.ts`,
`registry.ts:13` connecting sources into Engine intake); per-kind
satellites (`github-*`/`feishu-*`) normalize upstream events into domain
Triggers, send outbound replies, read thread context for assessments,
and expose read-only repository/CI inspection.

- main files: `src/sources/github.ts:38,112` (459 lines, largest, kind +
  plugin entry); `src/sources/kind.ts:85` (115 lines, SourceKind contract)
- depends on: core (13 files/13 lines), infra (13/18), root (7/11) —
  42 lines; 16/16 files have at least one boundary import
- imported by: app (18 files/38 lines), client (5/6), infra (1/1),
  root (1/1) — 25 files/46 lines
- loc: 2,059 (16 files) · rating ★★★★★ (9/10)

## m07 dsh-superagent/src (root modules)

The host-plugin shell of the DSH bundle — 8 `.ts` files directly in
`src/`: `index.ts` mounts the Runtime through `apply(ctx)`
(`index.ts:10-25`), `deployment.ts` declares the Config schema and
verifies CLI/repository/Feishu-bot at startup
(`deployment.ts:87-106,114-131`), `policy.ts` defines the zod settings
schema (`policy.ts:99-105`) and the authorization gate/mandate
revalidation port (`policy.ts:167-242`), plus small shared utilities
(admission matrix, LIMITS, KV keys, session navigation, SetupError).

- main files: `src/index.ts:10` (entry, 27 lines);
  `src/policy.ts` (242 lines, largest)
- depends on: core (3 lines), app (2 files/3), infra (3 files/4),
  sources (1/1) — 11 lines
- imported by: app (19 files/38 lines), client (9/10), executor (1/2),
  infra (2/3), sources (7/11) — 38 files/64 lines
- loc: 544 (8 files) · rating ★★★★ (7/10)

## Dependency edge matrix (22 edges, cross-checked in both directions)

Each edge was counted independently from the source item's outbound side
and the target item's inbound side by different measurement passes;
"match" = the merge cross-check verdict.

| Edge | Files/Lines | Representative evidence | Match |
|---|---|---|---|
| client→app | 6F/6L | `src/client/api.ts:3` "import type { Api, ApiRequest, ApiResponse } from '../app/api.ts'" | ✓ |
| executor→app | 1F/6L | `dsh.ts:13-18` → app/store, effects, execution-environment, sessions, assessment, notices | ✓ |
| root→app | 2F/3L | `src/index.ts:4` "import { Runtime } from './app/runtime.ts'"; `kv.ts:5-6` | ✓ |
| app→core | 25F/25L | `src/app/runtime.ts:16` "import { Engine, key, reasonText, … } from '../core/index.ts'" | ✓ |
| client→core | 3F/4L | `src/client/locales.ts:4` "import { USER_ERRORS } from '../core/errors.ts'" | ✓ |
| executor→core | 1F | `dsh.ts:7` value import + `:8-9` type import | ✓ |
| sources→core | 13F/13L | `src/sources/registry.ts:2` "import type { ChannelRef, OutboundMessage, ScopeResult, SourceScope, Trigger } from '../core/index.ts'" | ✓ |
| root→core | 3F/3L | `admission.ts:5`, `index.ts:27` (`export * from './core/index.ts'`), `policy.ts:9` | ✓ |
| app→executor | 9F/9L | `src/app/runtime.ts:23` from '../executor/dsh.ts' (cards, http, links, notices, resources, runtime, sessions, views/records, views/tickets) | ✓ |
| app→infra | 15F/18L | `src/app/runtime.ts:19` from '../infra/commands.ts' | ✓ |
| executor→infra | 1F/2L | `dsh.ts:11` environment, `dsh.ts:19` health | ✓ |
| sources→infra | 13F/18L | `src/sources/github.ts:6` "import { CliError, validItems, type Tally } from '../infra/commands.ts'" | ✓ |
| root→infra | 3F/4L | `deployment.ts:9`, `policy.ts:10`, `policy.ts:11`, `setup.ts:2` | ✓ |
| app→sources | 18F/38L | `src/app/runtime.ts:18` from '../sources/registry.ts' | ✓ |
| client→sources | 5F/6L | `src/client/locales.ts:6` "import { HEALTH_TEXT } from '../sources/host.ts'" | ✓ |
| infra→sources | 1F/1L | `src/infra/health.ts:2` "import type { Health } from '../sources/host.ts'" | ✓ |
| root→sources | 1F/1L | `src/kv.ts:8` "import type { Retry } from './sources/github.ts'" | ✓ |
| app→root | 19F/38L | `src/app/views/settings.ts:4` "import { policyVersion } from '../../policy.ts'" (policy 14, kv 10, deployment 8, setup 6 lines) | ✓ |
| client→root | 9F/10L | `src/client/index.tsx:13` "import { openKnownSession, SessionNavigationError } from '../navigation.ts'" | ✓ |
| executor→root | 1F/2L | `dsh.ts:10` ../deployment.ts, `dsh.ts:12` ../policy.ts | ✓ |
| infra→root | 2F/3L | `src/infra/commands.ts:6` "import type { Deployment } from '../deployment.ts'" + `environment.ts:10,11` | ✓ |
| sources→root | 7F/11L | `src/sources/host.ts:6` "import type { SetupProblem } from '../setup.ts'" (host 3, github 2, feishu-loops 2, feishu 1, github-pull 1, kind 1, registry 1) | ✓ |

Totals re-checked: app out 25+38+38+18+9 = 128 lines ✓; client out
6+4+6+10 = 26 ✓; infra out 1+3 = 4 ✓; sources out 13+18+11 = 42 ✓;
root out 3+3+4+1 = 11 ✓; app in 6+6+3 = 15 ✓; core in 45 files ✓;
infra in 18+18+4+2 = 42 ✓; sources in 38+6+1+1 = 46 ✓; root in
38+10+11+3+2 = 64 ✓. Two header/enumeration mismatches inside one
measurement pass were corrected at merge time (app→infra header said 15
lines, its own enumeration counted 18; root→infra header said 6 lines,
enumeration 4 = 3 files) — totals unchanged and symmetric.

## Machine-readable block

```json
[
{"id":"m01","module":"dsh-superagent/src/app","path":"src/app","responsibility":"Server-side orchestration layer of the orchestrator: Runtime composition root (runtime.ts:59) wiring SQLite Store, Sessions, DB migration 10-11, Passes/Outbox/Effects/Notices, main-session tools, loopback HTTP + view projections for the web panel.","main_files":"src/app/runtime.ts:59 (entry, 254 lines); src/app/migration.ts (616 lines, largest)","deps_in":["client","executor","root"],"deps_out":["core","executor","infra","sources","root"],"loc":5292,"tests":"0 — the tests/ tree is not owned by any item (59 spec files count toward the test-density rating signal)","status":"final"},
{"id":"m02","module":"dsh-superagent/src/client","path":"src/client","responsibility":"Browser-side React management panel: index.tsx mounts panel/sidebar icon/locale dictionaries/Plugin-Manager config view into the DSH web client, app.tsx root shell, 5 tab views + Settings/Prompts/Deployment, same-origin REST client, shared widgets, bilingual zh/en dictionaries.","main_files":"src/client/index.tsx:48,53 (entry, 58 lines); src/client/locales.ts (770 lines, largest)","deps_in":[],"deps_out":["app","core","sources","root"],"loc":4037,"tests":"0 — the tests/ tree is not owned by any item (59 spec files count toward the test-density rating signal)","status":"final"},
{"id":"m03","module":"dsh-superagent/src/core","path":"src/core","responsibility":"Standalone domain engine of the proactive agent: model + ports (Trigger/Thread/Ticket/Assignment; Policy/Assessor/Executor/Outbox/Repositories), Engine as the single transactional entry point (intake → evals → assignments → replies), Tickets lifecycle.","main_files":"src/core/index.ts:1 (entry, 10 lines); src/core/tickets.ts (423 lines, largest)","deps_in":["app","client","executor","sources","root"],"deps_out":[],"loc":2088,"tests":"0 — the tests/ tree is not owned by any item (59 spec files count toward the test-density rating signal)","status":"final"},
{"id":"m04","module":"dsh-superagent/src/executor","path":"src/executor","responsibility":"Runs each Assignment in a persistent DSH worker session worker-<ticketId> with its own workspace: DshExecutor prepare/launch/deliver via the effect queue, WorkerSlots concurrency cap, event listeners reporting transitions back to the Engine, transient retry with backoff; background.ts manages shell jobs and leftover subagents.","main_files":"src/executor/dsh.ts:207 (entry, 673 lines); src/executor/background.ts (165 lines)","deps_in":["app"],"deps_out":["app","core","infra","root"],"loc":838,"tests":"0 — the tests/ tree is not owned by any item (59 spec files count toward the test-density rating signal)","status":"final"},
{"id":"m05","module":"dsh-superagent/src/infra","path":"src/infra","responsibility":"Shared process infrastructure: Commands subprocess wrapper for gh/git/lark-cli with normalized CliError, environment.ts worker-bin/gitconfig shims + safe worker env, health.ts component-health registry.","main_files":"src/infra/environment.ts:79 (157 lines, largest); src/infra/commands.ts:59 (115 lines)","deps_in":["app","executor","sources","root"],"deps_out":["sources","root"],"loc":347,"tests":"0 — the tests/ tree is not owned by any item (59 spec files count toward the test-density rating signal)","status":"final"},
{"id":"m06","module":"dsh-superagent/src/sources","path":"src/sources","responsibility":"Two pluggable Source kinds (github, feishu) as Cordis plugin entries running polling loops, plus the contract layer (SourceKind, SourceRegistry, SourceHost connecting into Engine intake); per-kind satellites normalize upstream events into Triggers, send replies, read thread context, inspect repo/CI read-only.","main_files":"src/sources/github.ts:38,112 (459 lines, largest, kind + plugin entry); src/sources/kind.ts:85 (115 lines, SourceKind contract)","deps_in":["app","client","infra","root"],"deps_out":["core","infra","root"],"loc":2059,"tests":"0 — the tests/ tree is not owned by any item (59 spec files count toward the test-density rating signal)","status":"final"},
{"id":"m07","module":"dsh-superagent/src (root modules)","path":"src/*.ts","responsibility":"Host-plugin shell of the DSH bundle (8 .ts files in src/): index.ts mounts Runtime via apply(ctx), deployment.ts Config schema + CLI/repository/Feishu-bot verification, policy.ts zod settings schema + authorization gate, shared utilities (admission, LIMITS, KV, navigation, SetupError).","main_files":"src/index.ts:10 (entry, 27 lines); src/policy.ts (242 lines, largest)","deps_in":["app","client","executor","infra","sources"],"deps_out":["app","core","infra","sources"],"loc":544,"tests":"0 — the tests/ tree is not owned by any item (59 spec files count toward the test-density rating signal)","status":"final"}
]
```

## Measurement notes

1. The `client.css` file (382 lines) is counted in the directory's file
   total (27) but excluded from the ts census (26 ts/tsx = 4,037 loc);
   its client→app inbound emptiness is proven by a zero-result grep over
   `src` excluding `src/client/`.
2. `core`'s only external import is stdlib `node:crypto` (`ids.ts:2`) —
   not a boundary dep, hence `deps_out: []`.
3. All 16 `sources` files carry at least one boundary import — the
   contract layer is genuinely coupled to the rest of the bundle.
4. LOC figures are the census at the pin; the repository is
   single-commit, so any future upstream `HEAD ≠ 8c32a9dc` means the
   repository was replaced — re-run the measurement battery before
   reusing these numbers (approximate for planning until re-measured).
