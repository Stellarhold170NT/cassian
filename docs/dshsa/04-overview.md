---
subject: deepseek-ai/dsh-superagent-prototype
measured_at: 8c32a9dc5d72c033816c6a8110b37f40cf94fba4
status: final
---

# Overview

- PIN (HEAD at generation): `8c32a9dc5d72c033816c6a8110b37f40cf94fba4`
  (`git ls-remote` at generation returned the same SHA → upstream `main`
  was still at the pin).
- License gate: PASS — `LICENSE:1` "MIT License", `LICENSE:3` "Copyright
  (c) 2026 DeepSeek Harness Team"; `package.json:4` `"license": "MIT"`.
- Method: shallow clone on a git-only sandbox, 216 files ingested; every
  `file:line` below was read from that clone at the pin. The C4 sections
  are derived from code at the pin plus the cartography and module map
  only (kept independent from the dedicated C4 document on purpose).

## 1. What dsh-superagent is (5 sentences)

1. `dsh-superagent` is a **research prototype of a proactive coding agent
   for one GitHub repository, packaged as a DSH (DeepSeek Harness) bundle**
   — a Cordis plugin (`src/index.ts:7` `export const name =
   'dsh-superagent'`, `src/index.ts:10` `apply(ctx, config)`) with
   `package.json:30` declaring a `dsh.bundle` patch (`cordis.patch.yml`)
   and a web client; the README calls it "Research prototype for reference
   only, not an official DeepSeek product" (`README.md:3`).
2. It **listens to GitHub and optionally Feishu**, and when an allowed
   person asks for work it opens a work item, works on it in its own agent
   session and directory, and answers in the original conversation, e.g.
   with a pull request (`README.md:7`).
3. Its **core is a framework-free domain engine** (`src/core/index.ts:1`
   "Reusable proactive-agent core: model, ports, engine and in-memory
   repositories") where `Engine` is the single transactional entry point
   coordinating Intake → Evals → Tickets → Assignments → Replies
   (`src/core/engine.ts:19-24,48`), and everything project-specific hangs
   off ports (`src/core/ports.ts:1` "Sources, policies, assessors,
   executors, and channels are project-specific").
4. Authorization is a first-class, versioned concern: a Policy gate decides
   who may originate work (`src/core/ports.ts:17`), built from settings at
   `src/policy.ts:167` (`settingsPolicy`), and executed tickets run in
   **persistent per-ticket DSH worker sessions with isolated workspaces**
   (`src/executor/dsh.ts:202-207` `DshExecutor implements Executor`).
5. It ships as pnpm-managed TypeScript only (177 ts/tsx files, 30,182 LOC —
   census in `01-cartography.md`), with a React management panel for the
   DSH web client (`src/client/index.tsx:50-58`) and an ops wrapper
   (`scripts/dsh-superagent:1-6`), under MIT (`LICENSE:1`).

## 2. The 5-minute version (10 bullets)

- **One plugin, many services.** The host entry injects 11 DSH services
  (`agents`, `sessionController`, `sessionPersistence`, `workspaceRegistry`,
  `permissionPresets`, `tools`, `systemPrompt`, `skills`, `webServer`,
  `llm`, `subprocess`) and mounts a `Runtime` that stops on fiber teardown
  (`src/index.ts:8,21-22`).
- **Pipeline: Source → Trigger → Eval → Ticket → Assignment → Reply.**
  Sources call `Engine.receive(trigger)` which fans a stored trigger out
  to subscribed tickets and queues it for Eval (`src/core/engine.ts:42-48`);
  assessors judge candidates, accepted work becomes Tickets
  (`src/core/engine.ts:19-24`).
- **Admission is a table, not a gut feeling.** `machineGate` only passes
  listed bots (as inferred candidates) and senderless system/CI events;
  humans go through the admission matrix; mandates are revalidated against
  the current policy before resumes (`src/policy.ts:170-185,230-241`).
- **Everything is a ticket with a mandate.** Tickets follow threads
  (`Engine.bindThread`, `src/core/engine.ts:49-56`) and end when the
  threads they follow are done (`threadClosed`, `src/core/engine.ts:57-65`);
  stages and retry rules live in `src/core/stage.ts` (exported at
  `src/core/index.ts:9`).
- **Execution is DSH-native.** `DshExecutor` queues launches/deliveries
  through an effect queue, listens to `agent/status`,
  `agent/inbox/claimed`, `session/event`, `agent/error`, and reports
  transitions back to the Engine (`src/executor/dsh.ts:201-206`);
  `WorkerSlots` caps concurrency and reserves one extra slot for person
  follow-ups so humans never wait behind launches (`src/executor/dsh.ts:165-198`).
- **Side effects are transactional.** Engine commands run inside
  `repo.atomic(...)` and queue outbound messages in an idempotent Outbox
  (`pending|sent|dropped`) (`src/core/engine.ts:48`; `src/core/ports.ts:72-80`).
- **Sources are pluggable kinds.** A `SourceKind` descriptor carries
  schema, panel fields, health names, scope, channel, thread context,
  find, repliesTo, policy part, labels and environment variables
  (`src/sources/kind.ts:84-113`); GitHub and Feishu ship in-tree and
  register through `SourceRegistry` (`src/sources/github.ts:110-122`).
- **State is one SQLite file behind a lock.** `Runtime` locks the state
  directory with `proper-lockfile` before opening SQLite "so concurrent
  processes cannot corrupt or double-migrate state"
  (`src/app/runtime.ts:55-59`); `Store` uses `node:sqlite`
  (`src/app/store.ts:2`), and the schema migrates 10→11
  (`src/app/migration.ts`, 616 lines — largest file in `src/app`).
- **The panel is a DSH web-client slot.** The client bundle registers into
  `main`, `sidebar.panellist` and `plugins.row.config` slots and bilingual
  zh/en dictionaries (`src/client/index.tsx:48-58`), talking to a
  same-origin REST API (`src/client/api.ts:1`).
- **Ops and tests are wired for agents.** `pnpm check` = typecheck +
  vitest + build (`package.json:49-51`); 59 spec files (48 `.spec.ts` +
  11 `.spec.tsx`, counted on the clone); `scripts/dsh-superagent` is a
  Python tmux service manager whose exit codes distinguish
  healthy/stopped/error/waiting-for-setup (`scripts/dsh-superagent:1-6`);
  setup itself is agent-driven from `SETUP.md` (`SETUP.md:1-15`).

## 3. C4 level 1 — system context

Actors and external systems around **dsh-superagent** (the system under
consideration, running inside a DSH host process):

| Actor / system | Relationship | Evidence |
|---|---|---|
| Repo collaborators (persons) | Ask the agent for work by addressing it in Issues/PRs/comments; receive acknowledgements, replies and notices | `README.md:7`; `src/policy.ts:170` "Gate non-human triggers: only listed bots … may pass" implies humans are the primary admitted senders |
| Team operators (persons) | Configure sources, admission/policy, executor limits through the web panel; perform one-time setup | `src/client/index.tsx:49` "Registers the panel, sidebar icon, and Plugin Manager config view"; `SETUP.md:1-3` |
| DSH host platform | The bundle runs as Cordis plugins inside DSH; DSH provides agent sessions, workspace, permissions, tools, LLM, subprocess | `src/index.ts:8` inject list; `package.json:53-55` `"engines": { "dsh": "^0.2.1-alpha.2" }` |
| GitHub | The watched repository: issues, PRs, review threads, CI status; the agent acts through a dedicated `gh` CLI account with verified push access | `src/sources/github.ts:38-48` (kind, repository + cli fields); `src/deployment.ts:86-105` `resolveDeployment` verifies `gh api user` identity and `.permissions.push` |
| Feishu / Lark (optional) | Chat source via `lark-cli`; bot identity verified and locked to strict `bot` mode so workers can never act as a user | `src/deployment.ts:110-130` `resolveFeishuBot`; `cordis.patch.yml:9-12` (feishu-watch disabled by default) |
| LLM provider | Behind the DSH host (`llm` service); the engine itself never calls a model directly | `src/index.ts:8` (`llm` injected); `src/core/ports.ts:29` assessor receives "bounded facts, never authority" — judgement is queued to the assessor component, not the domain core |

Boundary rule worth noting: **the domain core (`src/core`) has zero
outbound dependencies** except `node:crypto` (module map, item m03) —
every network/CLI/system touch lives in sources/executor/infra.

## 4. C4 level 2 — containers

Eight containers (the 7 code items of the module map + the asset layer),
with cross-container edges as measured by the two-sided dependency matrix
in the module map (22 cross-checked edges):

| # | Container | Path | Role | Talks to |
|---|---|---|---|---|
| 1 | Host plugin shell | `src/*.ts` (8 files, 544 LOC) | Cordis entry, Config schema + deployment/Feishu-bot verification, policy schema, admission matrix, LIMITS, KV keys, navigation, SetupError | mounts #2; imported by #2,#3,#4,#5,#6 (root deps_in 38F/64L) |
| 2 | Runtime / app tier | `src/app` (38 files, 5,292 LOC) | Composition root `Runtime` (runtime.ts:59), SQLite Store + migration, Sessions, Effects, Outbox, Passes, HTTP loopback + REST views, MasterAssessor, Prompts, main/executor tools | wires #3,#4,#5,#6; serves #7 |
| 3 | Domain engine | `src/core` (15 files, 2,088 LOC) | Trigger/Thread/Ticket/Assignment model, ports, transactional Engine, ticket lifecycle | depended on by all; depends on nothing outward (`deps_out: []`) |
| 4 | Sources | `src/sources` (16 files, 2,059 LOC) | `githubKind`/`feishuKind` descriptors + polling loops + satellites (trigger translation, replies, thread context, read-only repo/CI inspection) | feeds #3 intake; uses #6 commands; registered via #2's `SourceHost` (`src/app/runtime.ts:50-51`) |
| 5 | Executor | `src/executor` (2 files, 838 LOC) | `DshExecutor` per-ticket worker sessions + `background.ts` shell jobs/subagents | driven by #2, reports back via #3 role interface (`EngineForExecutor`, `src/core/engine.ts:269`) |
| 6 | Infra | `src/infra` (5 files, 347 LOC) | `Commands` subprocess wrapper for `gh`/`git`/`lark-cli` with `CliError`, worker environment shims, health registry | used by #2,#4,#5 |
| 7 | Web panel (client) | `src/client` (26 ts/tsx + client.css, 4,037 LOC) | React management panel mounted into DSH web client slots; same-origin REST client | consumes #2 HTTP; leaf container (`deps_in: []`) |
| 8 | Asset layer | `prompts/` (15 md incl. `team/`), `skills/dsh-superagent-{github,feishu}`, `locale/{en,zh}.json`, `cordis.patch.yml`, `scripts/dsh-superagent` | System prompts, worker skills, i18n, bundle plugin insert, service manager | loaded by #1/#2/#5 at runtime (`cordis.patch.yml:4-12` inserts all three plugins) |

Deployment shape: one DSH profile patch inserts `dsh-superagent`,
`dsh-superagent-github` (github-watch) and `dsh-superagent-feishu`
(feishu-watch, disabled until configured) — `cordis.patch.yml:4-12`,
matching the three tsdown entries `index` / `github-watch` /
`feishu-watch` plus the browser `client` bundle (`tsdown.config.ts:10-13`).

## 5. C4 level 3 — key components (inside the important containers)

**Runtime (`src/app/runtime.ts:59-76`)** — the composition root holds
exactly the collaborating parts its doc comment names: `Store`, `Setup`,
`Prompts`, `Effects`, `SourceRegistry`, `Commands`, `Sessions`,
`Settings`, `DshExecutor`, `MasterAssessor`, `Outbox`, `Engine`, `Passes`
(`runtime.ts:55-76`); it exposes `SourceHost` on the Cordis context so
source plugins never touch the engine directly (`runtime.ts:50-51`).

**Engine (`src/core/engine.ts:24-38`)** — composes `Replies`, `Tickets`,
`Assignments`, `Evals`, `Intake` over a `Repositories` port; callers get
role-scoped `Pick` faces, never the whole engine: `EngineForSources`
(`receive|bindThread|threadClosed`, engine.ts:261),
`EngineForMainSession` (candidate/decide/reply…, :263), `EngineForPeople`
(stop/retry/reevaluate…, :265), `EngineForSettings` (policyChanged,
:267), `EngineForExecutor` (assignmentStarted/inputsDelivered/turnEnded…,
:269).

**SourceKind contract (`src/sources/kind.ts:85-113`)** — one descriptor
must provide: stable `kind` id, localized title/description, zod `schema`
+ panel `fields`, owned `health` entry names, optional `scope` (receiving
rule), `channel` (outbound replies), `threadContext` (bounded reader for
assessments), `find`, `repliesTo`, `policy` (sender identity list),
`refreshLabels`, and `environment` (worker variables).

**DshExecutor (`src/executor/dsh.ts:207-230`)** — per-ticket worker
sessions `worker-<ticketId>`; `WorkerSlots.reserve()` is synchronous "so
two starts cannot take the last slot", with `by === 'person'` allowed one
slot beyond `max()` (`dsh.ts:167-196`); transient failures get counted
backoff retries (`dsh.ts:210-213`); launches/deliveries are effect
handlers that are held (concurrency 0) while processing is paused
(`dsh.ts:227`).

**Policy (`src/policy.ts:99-111`)** — `SettingsSchema` (paused / sources
/ policy / eval / executor, strict) with `ExecutorConfigSchema.maxWorkers`
default 3 bounded 1..16 (`policy.ts:93`; `src/limits.ts:6`);
`POLICY_REVISION = 'mandate-v3'` and a version hash that "changes to
models, concurrency, pause state, or polling intervals do not invalidate
existing decisions" (`policy.ts:111-115`).

**Panel mounting (`src/client/index.tsx:48-58`)** — `inject = ['slots',
'locale', 'sessions', 'uiWorkspace']`; registers the main slot view, the
sidebar icon (order 10), and the Plugin-Manager config view; zh/en
dictionaries registered under one namespace.

## 6. Directory map and zone roles

```
dsh-superagent/
├── src/                      # 6 zones + 8 root modules (177 ts/tsx, 30,182 LOC total)
│   ├── index.ts              # HOST ENTRY — name/inject/Config/apply, mounts Runtime (src/index.ts:7-25)
│   ├── deployment.ts         # Config schema + gh/feishu-bot verification (deployment.ts:87,114)
│   ├── policy.ts             # settings schema + admission matrix + Policy port impl (policy.ts:99,167)
│   ├── admission.ts kv.ts limits.ts navigation.ts setup.ts   # shared small utilities
│   ├── app/      (38 f)      # server orchestration: runtime, store+migration, sessions, effects,
│   │                         #   outbox, passes, http+views, assessor, prompts, tools/
│   ├── core/     (15 f)      # framework-free domain engine (model, ports, engine, intake,
│   │                         #   evals, tickets, assignments, replies, stage, errors, reasons)
│   ├── sources/  (16 f)      # pluggable kinds: github*, feishu*, kind/registry/host/poll
│   ├── executor/ (2 f)       # dsh.ts (DshExecutor, WorkerSlots), background.ts
│   ├── infra/    (5 f)       # commands.ts (gh/git/lark-cli), environment.ts, health.ts, paths, text
│   └── client/   (26 f)      # React panel: index.tsx mount, app.tsx, 5 tab views, api.ts, locales.ts
├── prompts/                  # system prompts incl. team/ communication/delivery/scope
├── skills/dsh-superagent-{github,feishu}/SKILL.md   # worker skills for read/ack/report patterns
├── locale/{en,zh}.json       # host-side locale entries
├── docs/000..008             # philosophy → domain → authorization → execution → prompts →
│                             #   panel → deployment → architecture → cookbook(adding a Source)
├── tests/        (59 spec)   # 48 .spec.ts + 11 .spec.tsx, vitest; fixtures/ (6 files)
├── cordis.patch.yml          # bundle layer: inserts the 3 plugins into a DSH profile
├── examples/profile.cordis.patch.yml   # operator-facing profile example (stateDir, port 3082)
├── scripts/dsh-superagent    # Python tmux service manager (status/start/restart exit codes)
├── SETUP.md                  # agent-driven setup script the operator's coding agent follows
└── package.json / tsdown.config.ts / vitest.config.ts / tsconfig.json
```

Zone roles in one line each: `src/` root = plugin shell & config; `app/`
= state + orchestration + HTTP; `core/` = the reusable domain (the only
zone another product could lift verbatim); `sources/` = event
translation & per-platform APIs; `executor/` = DSH session lifecycle;
`infra/` = subprocess/CLI plumbing; `client/` = human supervision UI.

## 7. Expensive flows

The full flow dissection — scoring and per-step call-site evidence —
lives in [`06-flows.md`](06-flows.md). From this document's independent
reading, the flows that deserve that treatment are:

1. **Explicit request → ticket → worker → reply**: person addresses the
   agent on GitHub → `Engine.receive` stores the Trigger and fans it out
   (`engine.ts:42-48`) → policy gate + assessor decide → ticket opens
   with a mandate → `DshExecutor` launches `worker-<ticketId>` → worker
   reports → reply/PR posted back through the Outbox → thread closes →
   ticket ends (`engine.ts:57-65`).
2. **Observed (unaddressed) trigger path**: `observeIssues/Pulls/
   Comments/CI` switches (`src/sources/github.ts:50-55`) feed the
   admission table's unlisted/unaddressed cell; inferred mandates only
   survive while eval mode stays `auto` and their rules stay enabled
   (`policy.ts:237-238`).
3. **Setup/restart path**: deployment verification (gh identity + push,
   feishu bot strict mode) → `Runtime` ready or waiting-for-setup
   (`src/index.ts:24`); account changes restart the plugin
   (`src/index.ts:14-20`).

## 8. Run and harness (real commands, real result)

**Toolchain commands from the repository itself:**

```sh
pnpm install --frozen-lockfile   # packageManager pnpm@11.7.0 (package.json:57); pnpm-lock.yaml present (172 KB)
pnpm typecheck                   # tsc --noEmit (package.json:49)
pnpm test                        # vitest run (package.json:50) — include tests/**/*.spec.{ts,tsx} (vitest.config.ts:3)
pnpm check                       # typecheck && test && build (package.json:51); build = tsdown (tsdown.config.ts:9-14)
```

**Execution attempt in the mining sandbox: SKIPPED — honestly.**

- The sandbox image is git-only (git 2.56.0, **no node, no pnpm, no npm,
  no corepack** — `which node pnpm npm corepack` all absent).
- Even with a Node install, `package.json:53-54` requires
  `"node": "^22.19.0 || >=24.0.0"`, and 20+ peer dependencies are
  `@deepseek-ai/*` packages pinned to the `0.2.1-alpha.2` line
  (`package.json` peerDependencies, verbatim in `01-cartography.md`)
  whose registry reachability outside DeepSeek's toolchain is unknown
  (see §12). No install/typecheck/test output is fabricated; the
  commands were **not executed**.
- What WAS verified statically on the clone at the pin: 59 test files
  counted (`ls tests/*.spec.ts | wc -l` → 48; `ls tests/*.spec.tsx | wc -l`
  → 11), matching the module map exactly; vitest include pattern
  `tests/**/*.spec.{ts,tsx}` (`vitest.config.ts:3`).
- **Prerequisites for a real run** (from `SETUP.md:27`): Node.js
  22.19+/24+, pnpm, git 2.32+, tmux, Python 3.8+, GitHub CLI 2.48+, and
  DSH within `engines.dsh` (`package.json:53-55`).
- **Operational harness** (how it actually runs in production shape):
  a DSH profile patch inserts the three plugins and the profile supplies
  `stateDir` — "the plugin refuses to start without stateDir"
  (`cordis.patch.yml:1-3`); `examples/profile.cordis.patch.yml:3-9`
  shows webserver on `127.0.0.1:3082` + `dsh-superagent.stateDir`;
  `scripts/dsh-superagent` manages the tmux service with exit codes
  0/1/2/3 (healthy / stopped-or-unreachable / a component reports error
  / waiting for setup) (`scripts/dsh-superagent:1-6`).

## 9. Expensive extension points (per the module map + code)

- **Add a Source kind** — the flagship extension, documented as a full
  cookbook recipe (`docs/008-cookbook.md:5-17`: four responsibilities —
  translate events, define receiving/authorization rules, provide replies
  and context, maintain a polling loop; the recipe even pins
  id/thread/actor persistence cautions at `008-cookbook.md:21`).
  Implementation cost is one descriptor + one Cordis entry following
  `src/sources/github.ts:110-122`.
- **Swap authorization** — the entire admission regime is data + one
  `Policy` port implementation (`src/core/ports.ts:17-27`);
  `settingsPolicy` (`policy.ts:167`) is the shipped policy, and
  `POLICY_REVISION` guards mandate invalidation (`policy.ts:111`).
- **Swap execution** — `Executor` is a 3-method port (`start|deliver|stop`,
  `ports.ts:59-69`) where "concurrency and workspace management are its
  own concern"; `DshExecutor` is one implementation, a non-DSH executor
  is conceivable for ports-clean reuse.
- **Role-scoped engine faces** — five `EngineFor*` Pick types
  (`engine.ts:261-269`) mean integrators extend by implementing narrow
  interfaces, not by touching the engine.
- **Behavior via prompt text, not code** — "Behaviour that a team
  describes in words is prompt text, not a setting"
  (`docs/000-philosophy.md:20`); prompts/ and skills/ are editable
  assets shipped in the bundle (`package.json` `files` includes
  `prompts`, `skills`).
- **Panel views** — client registers into DSH UI slots (`main`,
  `sidebar.panellist`, `plugins.row.config`, `src/client/index.tsx:53-57`),
  so additional tabs follow the same slot pattern with zh/en dictionaries.

## 10. Risks when reusing

1. **Research-grade code, explicitly** — README warns it "may still
   contain bugs", has "inconsistent" style, and is "not identical to our
   internal version or the implementation described in *Exploring
   Super-agent Design*" (`README.md:3-5`); several paper designs are
   future work, not implemented here.
2. **Platform coupling** — 20+ `@deepseek-ai/*` peer deps pinned to one
   alpha line (`0.2.1-alpha.2`) plus `engines.dsh` (`package.json:53-55`):
   lifting `src/core` out is clean (zero outward deps), lifting
   `src/app`/`executor` is not — they consume DSH services by name
   (`src/index.ts:8`).
3. **Alpha-API churn** — a DSH upgrade can break the bundle without
   compile errors at pin time; the code itself carries TODO markers tied
   to platform behavior (e.g. settings re-read workaround,
   `src/index.ts:14-17`).
4. **Single-process state** — one SQLite file + one advisory file lock
   per stateDir (`runtime.ts:55-59`); horizontal scaling or concurrent
   processes against the same state are designed away, not supported.
5. **gh/lark CLI trust assumptions** — the whole authorization story
   rests on the agent CLI being *only* the agent account and the Feishu
   CLI being strict-bot ("a CLI that also permits a user identity would
   let workers act as that user", `deployment.ts:111-112`); reusing
   without reproducing these wrappers silently voids the security model.
6. **Attention-budget philosophy is load-bearing** — the design ships
   with an admission matrix that starts proactive behavior in
   record-only mode (`docs/000-philosophy.md:11`); teams that strip the
   policy layer will get an agent that "can waste a whole team's
   attention" (`README.md:9`).
7. **Census size note** — LOC figures (30,182) are the census at the
   pin; treat as approximate for planning, see `01-cartography.md` for
   the reproducible formula.

## 11. Provenance

| Field | Value |
|---|---|
| Upstream | `https://github.com/deepseek-ai/dsh-superagent-prototype` |
| Branch | `main` |
| PIN (HEAD at census & generation) | `8c32a9dc5d72c033816c6a8110b37f40cf94fba4` |
| Head commit | `2026-10-31 20:06:31 +0800` "feat: add the dsh-superagent research prototype"; shallow commit count 1 (≤ depth 100) |
| Freshness at generation | `git ls-remote <upstream> HEAD` → `8c32a9dc5d72c033816c6a8110b37f40cf94fba4` == PIN → **FRESH** (re-sync is a separate decision, see `tracking/dshsa.md`) |
| License | MIT — `LICENSE:1-3`; `package.json:4` |
| Languages / size | TypeScript only: ts 147 files / 25,388 lines + tsx 30 / 4,794 = 177 files / 30,182 LOC (per-extension-then-sum formula) |
| Extraction target | this overview → `docs/dshsa/04-overview`; module numbers cross-referenced from the module map (m01–m07) |

## 12. Open questions

1. **Registry reachability of `@deepseek-ai/*` packages** — can a third
   party actually `pnpm install --frozen-lockfile` this outside DeepSeek's
   environment, or are the peer deps only resolvable internally?
   [unverified — could not be resolved in the offline-capable mining sandbox.]
2. **Worker-slot fairness details** — `maxWorkers` default is 3
   (`policy.ts:93`), the person-follow-up extra slot is one
   (`dsh.ts:194`), but starvation behavior under sustained bot traffic
   deserves a flow-level look (`06-flows.md`, flow F3).
3. **Migration longevity** — `migration.ts` is 616 lines covering 10→11;
   is pre-10 state still migratable, and does the prototype expect fresh
   stateDirs only? [unverified — needs confirmation.]
4. **Paper-vs-code delta** — which parts of *Exploring Super-agent
   Design* map onto which modules, and which are explicitly unimplemented
   (`README.md:5` says some are future work)? A mapping table would help
   reuse.
5. **Flows cross-link** — reconcile §7 teasers above against the scored
   flows in [`06-flows.md`](06-flows.md).

---

*All `file:line` citations were verified on a fresh clone at pin
`8c32a9dc…` during generation. The cartography and module map were used
as inputs; the dedicated C4 document (`03-c4/`) was not.*
