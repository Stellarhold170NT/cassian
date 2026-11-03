---
subject: deepseek-ai/dsh-superagent-prototype
measured_at: 8c32a9dc5d72c033816c6a8110b37f40cf94fba4
status: final
---

# Usage — 21 use cases across all 7 modules

Hands-on recipes mined from real code at pin `8c32a9dc5d72c033816c6a8110b37f40cf94fba4`.
Every use case carries a verbatim API example plus an anti-fabrication
evidence block (`File | Line | Content`) quoted from the pinned clone —
every API referenced in an example was located by grep on that clone.
Stars and `deps_out` mirror the module map exactly.

- 7 items × 3 use cases = 21 use cases, ordered by rating (5★ → 3★).
- Build note, honestly: all build commands below are **SKIPPED** — the
  mining sandbox is git-only (no node/pnpm/npm); no build/test output is
  fabricated anywhere in this document. The commands quoted are the
  repository's real `package.json` scripts.

## 1. When to use each item (summary)

| item | module | ★ | when to use | deps_out |
|---|---|---|---|---|
| s03 | dsh-superagent/src/core | 5 | The standalone domain engine (model + ports Trigger/Ticket/Assignment, Policy/Assessor/Executor/Outbox/Repositories; transactional Engine; Tickets lifecycle) — use when embedding the trigger→eval→ticket→assignment lifecycle into another test or product without SQLite/DSH (plug MemoryRepositories + fake ports) | — (0 boundary deps) |
| s06 | dsh-superagent/src/sources | 5 | The pluggable Source-kind layer: githubKind/feishuKind Cordis plugin entries running polling loops; SourceKind/SourceRegistry connect kinds into Engine intake — use when teaching the agent to listen to another system (write a new kind, register(), validate config, plug the registry as the Engine's scope) | core, infra, root |
| s01 | dsh-superagent/src/app | 4 | The server-side orchestration tier: Runtime composition root, DB migration, state-dir lock, HTTP loopback — use when mounting the orchestrator into a DSH host, consuming the `orchestrator` service (SourceHost) to ingest triggers / read tickets / report health, and running 2-instance/restart safely | core, executor, infra, sources, root |
| s05 | dsh-superagent/src/infra | 4 | Shared process infrastructure: Commands wraps gh/git/lark-cli with normalized CliError, worker environment shim, single-writer HealthBoard — use when calling repository-scoped GitHub API (schema validate/paginate), classifying CLI errors (410/404), claim/set/release health entries | sources, root |
| s07 | dsh-superagent/src (root modules) | 4 | The DSH plugin host shell: index.ts apply(ctx, config) mounts Runtime + restart callback, deployment.ts Config + CLI/push/bot verification, policy.ts settings + policyVersion/allowedSender — use when installing the plugin into a DSH host, configuring settings, controlling authorization, verifying startup | app, core, infra, sources |
| s02 | dsh-superagent/src/client | 3 | The browser-side React management panel: mounts panel/sidebar/config view via slots, 5 tab views + Settings/Prompts/Deployment, same-origin REST client, route memory — use when an admin opens the Superagent panel in the DSH web client to watch tickets, edit settings, navigate worker sessions | app, core, sources, root |
| s04 | dsh-superagent/src/executor | 3 | Runs each Assignment in a persistent `worker-<ticketId>` DSH worker session with its own workspace: DshExecutor effect queue, WorkerSlots concurrency, retry backoff — use when mapping tickets↔sessions, classifying transient errors, bounding worker slots, controlling launch/deliver lifecycle | app, core, infra, root |

Machine-readable summary:

```json
[
{"s_id":"s03","module":"dsh-superagent/src/core","stars":5,"summary":"Standalone domain engine of the proactive agent (model + ports, transactional Engine, Tickets lifecycle) — embed the trigger→eval→ticket→assignment lifecycle into another test/product without SQLite/DSH (plug MemoryRepositories + fake ports).","deps_out":[],"use_cases":3,"build":"SKIPPED — sandbox has no node/pnpm"},
{"s_id":"s06","module":"dsh-superagent/src/sources","stars":5,"summary":"Pluggable Source-kind layer (githubKind/feishuKind plugin entries + SourceKind/SourceRegistry connecting into Engine intake) — teach the agent to listen to another system: write a new kind, register(), validate config, plug the registry as the Engine's scope.","deps_out":["dsh-superagent/src/core","dsh-superagent/src/infra","dsh-superagent/src (root modules)"],"use_cases":3,"build":"SKIPPED — sandbox has no node/pnpm"},
{"s_id":"s01","module":"dsh-superagent/src/app","stars":4,"summary":"Server-side orchestration tier (Runtime composition root, DB migration, state-dir lock, HTTP loopback) — mount the orchestrator into a DSH host, consume the orchestrator service (SourceHost) to ingest triggers/read tickets/report health, run 2-instance/restart safely.","deps_out":["dsh-superagent/src/core","dsh-superagent/src/executor","dsh-superagent/src/infra","dsh-superagent/src/sources","dsh-superagent/src (root modules)"],"use_cases":3,"build":"SKIPPED — sandbox has no node/pnpm"},
{"s_id":"s05","module":"dsh-superagent/src/infra","stars":4,"summary":"Shared process infrastructure (Commands wraps gh/git/lark-cli + CliError, worker environment shim, single-writer HealthBoard) — repository-scoped GitHub API calls (schema validate/paginate), CLI error classification (410 gone/404 retry), claim/set/release health entries.","deps_out":["dsh-superagent/src/sources","dsh-superagent/src (root modules)"],"use_cases":3,"build":"SKIPPED — sandbox has no node/pnpm"},
{"s_id":"s07","module":"dsh-superagent/src (root modules)","stars":4,"summary":"DSH plugin host shell (index.ts apply(ctx) mounts Runtime, deployment.ts Config + CLI/push/bot verification, policy.ts settings + policyVersion/allowedSender) — install the plugin into a DSH host, configure machine settings, control authorization, verify startup.","deps_out":["dsh-superagent/src/app","dsh-superagent/src/core","dsh-superagent/src/infra","dsh-superagent/src/sources"],"use_cases":3,"build":"SKIPPED — sandbox has no node/pnpm"},
{"s_id":"s02","module":"dsh-superagent/src/client","stars":3,"summary":"Browser-side React management panel (mounts panel/sidebar/config view via slots, 5 tab views, same-origin REST client, sessionStorage route memory) — admins open the Superagent panel in the DSH web client to watch tickets, edit settings, navigate worker sessions.","deps_out":["dsh-superagent/src/app","dsh-superagent/src/core","dsh-superagent/src/sources","dsh-superagent/src (root modules)"],"use_cases":3,"build":"SKIPPED — sandbox has no node/pnpm"},
{"s_id":"s04","module":"dsh-superagent/src/executor","stars":3,"summary":"Runs each Assignment in a persistent worker-<ticketId> DSH worker session with its own workspace (DshExecutor effect queue, WorkerSlots concurrency, retry backoff) — map tickets↔sessions, classify transient errors, bound worker slots, control launch/deliver lifecycle.","deps_out":["dsh-superagent/src/app","dsh-superagent/src/core","dsh-superagent/src/infra","dsh-superagent/src (root modules)"],"use_cases":3,"build":"SKIPPED — sandbox has no node/pnpm"}
]
```

---

## 2. s03 — dsh-superagent/src/core (5★, 15 files / 2,088 LOC)

### What this item solves

Core is the **standalone domain engine** of the proactive agent: it
defines the model (Trigger/Thread/Ticket/Assignment) and five ports
(Policy/Assessor/Executor/Outbox/Repositories) separated from every
concrete source/policy/executor (File: src/core/ports.ts | Line: 1 |
Content: "Ports the core depends on. Sources, policies, assessors,
executors, and channels are project-specific."). `Engine` is the **single
transactional entry point** coordinating intake → evals → assignments →
replies — every mutation runs inside `repo.atomic(...)` (File:
src/core/engine.ts | Line: 19-22 | Content: "Single transactional entry
point for mutating Triggers, Threads, Decisions, Tickets, and
Assignments."), and `Tickets` (tickets.ts) manages the ticket lifecycle
from accept to end. A consumer never touches SQLite/DSH: plug
MemoryRepositories + fake ports and the full lifecycle runs inside a test
or another product.

### Use case 1 — Wire a standalone Engine with in-memory repositories; run a trigger end-to-end (eval → accept → assignment)

Scenario: a developer wants the proactive-agent domain lifecycle inside
their test suite without SQLite/DSH: build `MemoryRepositories`, plug
four fake ports, `receive()` one Trigger, run the eval pass, decide
`accept`, then observe the executor launch — exactly the harness pattern
the repository's own tests use.

```ts
import { Engine, MemoryRepositories, key,
  type Assessor, type Assignment, type Executor, type OutboundMessage,
  type Policy, type Ticket, type Trigger } from 'dsh-superagent' // re-export of src/core/index.ts:1-10

const trigger: Trigger = {
  id: 'm1', source: 'chat', threads: [{ source: 'chat', id: 't1' }],
  actor: { source: 'chat', id: 'alice' }, human: true, addressed: 'mention',
  at: '2026-09-23T00:00:00Z', text: 'Please fix the flaky test',
  channel: { source: 'chat', thread: 't1', address: { message: 'm1' } }, meta: {},
}

const outboxMessages: OutboundMessage[] = []
let launched: [Ticket, Assignment] | undefined
const repo = new MemoryRepositories()
const engine = new Engine({
  repo,
  policy: (): Policy => ({
    version: 'v1', paused: false, evalTimeoutMs: 60_000,
    gate: t => t.actor.id === 'alice'
      ? { admissible: true, strength: 'explicit', basis: { via: 'listed' } }
      : { admissible: false, reason: 'not a member' },
    revalidate: () => true, admitsInferred: rules => rules.length > 0,
  }),
  scope: { scope: () => ({ listened: true, observed: false }) },
  assessor: { request: () => {} } satisfies Assessor,
  executor: {
    start: (ticket, assignment) => { launched = [ticket, assignment] },
    deliver: () => {}, stop: () => {},
  } satisfies Executor,
  outbox: {
    send: message => { if (!outboxMessages.some(m => m.id === message.id)) outboxMessages.push(message) },
    status: id => outboxMessages.some(m => m.id === id) ? 'pending' : undefined,
    withdraw: () => {},
  },
  now: () => '2026-09-23T00:00:00Z',
})

const received: 'stored' | 'duplicate' | 'filtered' = engine.receive(trigger)
engine.evaluateDue()                     // eval pass for thread t1 runs; the assessor received the candidate
engine.decide(trigger.id, {              // an operator (or a real assessor) settles on accept
  kind: 'accept', title: 'Fix the flaky test', scope: 'repo',
  reason: 'member alice asked', acknowledgement: 'On it — opening a ticket.',
})
const [ticket, assignment] = launched!   // Executor.start was already queued for the first assignment
engine.assignmentStarted(ticket.id, assignment.id)          // the worker session took the work
engine.inputsDelivered(ticket.id, assignment.id, ticket.undelivered)
// outboxMessages now holds the acknowledgement 'On it — opening a ticket.' for channel chat/t1
const id = key('audit', trigger.id)      // content-derived stable id, used to mark the trigger as processed
```

Evidence:

- File: src/core/index.ts | Line: 2-10 | Content: "export * from './model.ts' / export * from './ports.ts' / export { Engine, … } from './engine.ts' / … / export { MemoryRepositories } from './memory.ts' / export { canRetry, ticketStage … } / export { key } from './ids.ts'"
- File: src/core/engine.ts | Line: 48 | Content: "receive(trigger: Trigger): ReceiveResult { return this.repo.atomic(() => this.intake.receive(trigger)) }"
- File: src/core/engine.ts | Line: 75 | Content: "evaluateDue(): void {"
- File: src/core/engine.ts | Line: 100 | Content: "decide(triggerId: string, outcome: Outcome): Decision { return this.repo.atomic(() => this.evals.decide(triggerId, outcome)) }"
- File: src/core/engine.ts | Line: 174 | Content: "assignmentStarted(ticketId: string, assignmentId: string): void {"
- File: src/core/engine.ts | Line: 181 | Content: "inputsDelivered(ticketId: string, assignmentId: string, inputIds: string[]): void {"
- File: src/core/intake.ts | Line: 8 | Content: "export type ReceiveResult = 'stored' | 'duplicate' | 'filtered'"
- File: src/core/part.ts | Line: 7-14 | Content: "export interface EngineOptions { repo: Repositories; policy: () => Policy; scope: SourceScope; assessor: Assessor; executor: Executor; outbox: Outbox; …"
- File: src/core/ports.ts | Line: 44-45 | Content: "| { kind: 'accept'; title: string; scope: string; reason: string | Reason; acknowledgement?: string; …"
- File: src/core/memory.ts | Line: 10 | Content: "export class MemoryRepositories implements Repositories {"
- File: src/core/ids.ts | Line: 3-4 | Content: "export function key(...values: string[]): string { return createHash('sha256').update(JSON.stringify(values)).digest('hex').slice(0, 32) }"
- File: src/core/model.ts | Line: 23-38 | Content: "export interface Trigger { id: string; source: string; threads: ThreadRef[]; actor: ActorRef; human: boolean; addressed?: 'mention' | 'direct'; at: string; text: string; channel?: ChannelRef; … meta: Record<string, unknown> }"
- Reference pattern (the repository's own harness, same fake-ports shape): File: tests/core-engine.spec.ts | Line: 43-44 | Content: "const engine = new Engine({ repo, scope, policy: () => policy, assessor, executor, outbox: queued, … now: () => new Date(…).toISOString() })" and Lines 46-57 (`settle()` calls `engine.assignmentStarted(next[0].id, next[1].id)` then `engine.inputsDelivered(ticketId, assignment.id, [inputId])`).

### Use case 2 — Ticket status badge on a panel via `ticketStage` + `canRetry` (pure functions, no Engine needed)

Scenario: the Execution tab of the management panel needs a status badge
per ticket and a Retry button enabled only when retrying is valid. Two
pure helpers in stage.ts classify according to the docs/003 table — pass
any `Ticket` read from Store (SQLite) or MemoryRepositories and the
result is identical.

```ts
import { canRetry, ticketStage } from 'dsh-superagent'   // src/core/index.ts:9
import type { Ticket } from 'dsh-superagent'

function badge(ticket: Ticket): { label: string; retryable: boolean } {
  const stage = ticketStage(ticket)          // 'person' | 'working' | 'idle' | 'ended'
  const label =
    stage.stage === 'person' ? `Waiting for person: ${stage.action}` :   // delivery/answer/review/blocked/failed
    stage.stage === 'working' ? (stage.action === 'queued' ? 'Queued' : 'Working') :
    stage.stage === 'idle' ? 'Idle' : 'Ended'
  // Retry is valid only while the ticket is open and waits for a person (blocked/failed without a newer follow-up)
  // or has a failed delivery in flight — docs/003 (stage.ts:23-25).
  return { label, retryable: canRetry(ticket) }
}

const ticket: Ticket = repo.tickets.get('tkt-42')!   // repo = MemoryRepositories or the Store port
const view = badge(ticket)
if (view.retryable) renderRetryButton(view.label)
```

Evidence:

- File: src/core/stage.ts | Line: 9 | Content: "export function ticketStage(ticket: Ticket): TicketStage {"
- File: src/core/stage.ts | Line: 10-20 | Content: "if (ticket.ended) return { stage: 'ended' } / if (ticket.delivery) return { stage: 'person', action: 'delivery' } / if (ticket.attention) return { stage: 'person', action: 'answer' } / … if (report === 'ready') return { stage: 'person', action: 'review' } / …"
- File: src/core/stage.ts | Line: 24-25 | Content: "export function canRetry(ticket: Ticket): boolean { return !ticket.ended && (waitsForPerson(ticket) || !!ticket.delivery) }"
- File: src/core/index.ts | Line: 9 | Content: "export { canRetry, ticketStage, type TicketStage } from './stage.ts'"
- File: src/core/memory.ts | Line: 38-39 | Content: "readonly tickets = { get: (id: string) => clone(this.ticketRows.get(id)), save: (ticket: Ticket) => { this.ticketRows.set(ticket.id, clone(ticket)) },"

### Use case 3 — Person commands from the panel: Stop / Note / Retry through the Engine (transactional, safe from a tool handler)

Scenario: a main-session tool handler (or a panel HTTP route) receives a
user command — "stop the work", "attach a note for the worker", "retry a
stalled ticket". All three commands go through `repo.atomic(...)` — they
roll back automatically when a UserError is thrown, so the handler only
needs to catch.

```ts
import { UserError } from 'dsh-superagent'   // src/core/index.ts:6
// engine from the composition root (runtime.engine) — see the s01 use case

function onPanelCommand(cmd: { op: 'stop' | 'note' | 'retry'; ticketId: string; text?: string }): unknown {
  try {
    switch (cmd.op) {
      case 'stop':  return engine.stopTicket(cmd.ticketId, cmd.text ?? 'Stopped from the panel')  // ends the ticket + cancels assignments
      case 'note':  return engine.note(cmd.ticketId, cmd.text ?? '')     // note the worker reads on its next turn
      case 'retry': return engine.retryTicket(cmd.ticketId)              // re-run a stalled ticket
    }
  } catch (error) {
    if (error instanceof UserError) return { error: error.message }      // e.g. unknownTicket
    throw error
  }
}
```

Evidence:

- File: src/core/engine.ts | Line: 160 | Content: "stopTicket(ticketId: string, reason?: string): Ticket { return this.repo.atomic(() => this.tickets.stop(ticketId, reason)) }"
- File: src/core/engine.ts | Line: 221 | Content: "note(ticketId: string, text: string): Ticket { return this.repo.atomic(() => this.tickets.note(ticketId, text)) }"
- File: src/core/engine.ts | Line: 166 | Content: "retryTicket(ticketId: string): Ticket { return this.repo.atomic(() => this.tickets.retry(ticketId)) }"
- File: src/core/index.ts | Line: 6 | Content: "export { UserError, USER_ERRORS, type UserErrorCode } from './errors.ts'"

### Dependencies

`deps_out` = **[] — zero boundary deps**. Core's only external import is
the stdlib `node:crypto` (File: src/core/ids.ts | Line: 2 | Content:
"import { createHash } from 'node:crypto'"), available in any Node
runtime — nothing to install. The examples above import from core only.

### Build

- Command (from package.json scripts — File: package.json | Line: 47-52 |
  Content: "scripts": { "build": "tsdown", "typecheck": "tsc --noEmit",
  "test": "vitest run", "check": "pnpm typecheck && pnpm test && pnpm
  build" }): `pnpm install --frozen-lockfile && pnpm typecheck && pnpm
  test` (vitest, script "test").
- **SKIPPED** — the mining sandbox has no node/pnpm/npm. No build/test
  output is fabricated.

---

## 3. s06 — dsh-superagent/src/sources (5★, 16 files / 2,059 LOC)

### What this item solves

Sources is the **pluggable Source-kind layer**: each kind (github,
feishu) is a Cordis plugin entry that registers a `SourceKind` and runs a
polling loop (File: src/sources/github.ts | Line: 1 | Content: "GitHub
source kind definition, notification and repository polling loops, and
Cordis plugin entry."), plus the shared contract layer — `SourceKind`
(kind.ts:85), `SourceContext`/`SourceHost` (host.ts) that connect kinds
into Engine intake, KV state and health. The `github-*/feishu-*`
satellites normalize upstream events into domain Triggers, send outbound
replies, read thread context for assessments and inspect repo/CI
read-only. To teach the agent to listen to a new system, write one more
`SourceKind`.

### Use case 1 — Write and register a custom SourceKind (internal tracker) with the SourceRegistry

Scenario: a team wants the agent to listen to an internal tracker
(webhook text). They define a `SourceKind<Config>` — zod schema, form
fields for the settings card, their own health entry — then `register()`
it with the SourceRegistry; the returned disposer unregisters and frees
the health entry (the exact mechanism Runtime uses for githubKind,
runtime.ts:137-138 wires this registry into the Engine as its scope).

```ts
// internal bundle paths: src/sources/kind.ts, src/sources/registry.ts (not at the export root — package.json:13-19)
import { z } from 'zod'
import type { SourceKind } from '../sources/kind.ts'
import type { SourceRegistry } from '../sources/registry.ts'

const TrackerConfigSchema = z.object({ project: z.string().min(1) }).strict()
type TrackerConfig = z.infer<typeof TrackerConfigSchema>

export const trackerKind: SourceKind<TrackerConfig> = {
  kind: 'tracker',
  title: { zh: '内部工单', en: 'Tracker' },
  description: { zh: '监听内部工单系统的通知。', en: 'Listens to the internal tracker.' },
  schema: TrackerConfigSchema,                     // validates saved config + fills defaults
  fields: [{ key: 'project', type: 'text', label: { zh: '项目', en: 'Project' } }],
  health: ['tracker'],                             // health entries owned by this kind (other kinds must not claim them)
  // no `scope` declared ⇒ the kind listens to every Trigger it produces and observes none (kind.ts:97)
}

function install(sources: SourceRegistry): () => void {
  const unregister = sources.register(trackerKind) // duplicate kind → throw; disposer unregisters + releases health
  return unregister
}
```

Evidence:

- File: src/sources/kind.ts | Line: 85-113 | Content: "export interface SourceKind<C extends Record<string, unknown> = Record<string, unknown>> { kind: string; title: Localized; description: Localized; facts?(…); schema: z.ZodType<C>; fields: FieldSpec[]; health: string[]; scope?(…); channel?(…); threadContext?(…); … }"
- File: src/sources/kind.ts | Line: 97 | Content: "/** Listening rule for a trigger (or recorded Mandate basis) of this kind; kinds without `scope` listen to everything they produce and observe none of it. */"
- File: src/sources/registry.ts | Line: 20 | Content: "register<C extends Record<string, unknown>>(kind: SourceKind<C>): () => void {"
- File: src/sources/registry.ts | Line: 21 | Content: "if (this.kinds.has(kind.kind)) throw new Error(`Source kind already registered: ${kind.kind}`)"
- File: src/sources/github.ts | Line: 14 | Content: "ctx.effect(() => ctx.orchestrator.sources.register(githubKind), 'github: source kind')" (the real registration pattern)
- File: src/sources/kind.ts | Line: 11 | Content: "interface FieldBase { key: string; label: Localized; hint?: Localized; advanced?: true }"
- File: src/sources/github.ts | Line: 17 | Content: "import { z } from 'zod'" (zod is a real dependency of this module)

### Use case 2 — Use SourceRegistry standalone: validate instance config and plug it as the Engine's SourceScope

Scenario: a test/integration harness builds its own SourceRegistry (no
Runtime), registers a kind, validates the config a user submits before
saving, then passes the registry itself into `new Engine({ scope:
sources, ... })` — the registry `implements SourceScope`, so it plugs
straight into the Engine's scope port.

```ts
import { Engine } from '../core/index.ts'
import { SourceRegistry } from '../sources/registry.ts'
// settings: () => Settings — the config source; board: HealthBoard; in the real Runtime these are store.settings() + board (runtime.ts:136)
const sources = new SourceRegistry(() => settings, board)

const disposeTracker = sources.register(trackerKind)          // use case 1

// Validate submitted settings before saving — parsed through the kind's schema; invalid → zod throws:
const clean = sources.validate('tracker', { enabled: true, config: { project: 'infra' } })
saveSettings({ ...settings.sources, tracker: clean })          // { enabled, config } normalized

// The registry IS the Engine.SourceScope — the same way Runtime wires it (runtime.ts:137: scope: sources):
const engine = new Engine({
  repo, scope: sources, policy: () => settingsPolicy(settings, sources),
  assessor, executor, outbox,
})

// instance() returns the config resolved against the current settings:
const inst = sources.instance<{ project: string }>('tracker')
if (inst?.enabled) startPolling(inst.config.project)
```

Evidence:

- File: src/sources/registry.ts | Line: 13 | Content: "export class SourceRegistry implements SourceScope {"
- File: src/sources/registry.ts | Line: 16-17 | Content: "constructor(private readonly settings: () => Settings, private readonly board: Pick<HealthBoard, 'claim'> = new HealthBoard(), private readonly registered: (kind: SourceKind) => () => void = () => () => {}) {}"
- File: src/sources/registry.ts | Line: 54 | Content: "validate(id: string, value: { enabled: boolean; config: unknown }): { enabled: boolean; config: Record<string, unknown> } {"
- File: src/sources/registry.ts | Line: 57 | Content: "return { enabled: value.enabled, config: kind.schema.parse(value.config) }"
- File: src/sources/registry.ts | Line: 50-52 | Content: "instance<C extends Record<string, unknown>>(id: string, settings = this.settings()): SourceInstance<C> | undefined { const kind = this.kinds.get(id); return kind ? this.resolve(kind, settings.sources[id]) as SourceInstance<C> : undefined }"
- File: src/app/runtime.ts | Line: 137-138 | Content: "const engine = this.engine = new Engine({ repo: store, scope: sources, policy, assessor, executor, / outbox, prepareTicket: (ticket, outcome) => executor.prepare(ticket, outcome), emit: event => {"
- File: src/core/ports.ts | Line: 12-14 | Content: "export interface SourceScope { scope(input: { source: string; meta: Record<string, unknown> }): ScopeResult }"

### Use case 3 — Reuse the built-in githubKind: config-driven scope rule + the watcher plugin lifecycle

Scenario: instead of writing a new kind, reuse `githubKind`: read the
resolved config to learn what the kind listens to (observeIssues/Pulls/
Comments/Ci, default false), and install the `dsh-superagent/github-watch`
watcher plugin into the host Cordis — its `apply` entry registers the
kind, runs the polling loop and aborts cleanly when the fiber disposes.

```ts
// 1) Read githubKind's scope rule for an event meta before building a Trigger:
const config = sources.instance<GithubConfig>('github')!.config
const verdict = githubKind.scope!({ meta: { kind: 'issue', number: 12 } }, config)
if (!verdict.listened) skipEvent(verdict.reason)          // scope rejected the event
else if (!verdict.observed) ingestAsAddressed(trigger)     // listened but not observed ⇒ the addressed path

// 2) Plugin lifecycle (bundle export './github-watch' → lib/github-watch.js — package.json:15):
//    the host Cordis loads the entry below; `inject: ['orchestrator']` requires the dsh-superagent core first:
export const name = 'dsh-superagent-github'
export const inject = ['orchestrator']
export function apply(ctx: Context): void {
  ctx.effect(() => ctx.orchestrator.sources.register(githubKind), 'github: source kind')
  ctx.effect(() => {
    const source = sourceContext(ctx.orchestrator, githubKind)
    const controller = new AbortController()
    const running = watch(source, controller.signal)
      .catch((error: unknown) => { source.report('github', { state: 'error', detail: String(error) }) })
    return async () => { controller.abort(); await running }
  })
}
```

Evidence (block 2 is a verbatim quote of the plugin entry to show the
installation contract):

- File: src/sources/github.ts | Line: 38 | Content: "export const githubKind: SourceKind<GithubConfig> = {"
- File: src/sources/github.ts | Line: 25-28 | Content: "const GithubConfigSchema = GithubAccountsSchema.extend({ pollSeconds: z.number().int().min(60).max(3600).default(60), failuresBeforeError: …, observeIssues: z.boolean().default(false), observePulls: …, observeComments: …, observeCi: z.boolean().default(false) }).strict()"
- File: src/sources/github.ts | Line: 59-60 | Content: "scope: ({ meta }, config) => { const row = scopeOf(meta)"
- File: src/sources/github.ts | Line: 110-112 | Content: "export const name = 'dsh-superagent-github' / export const inject = ['orchestrator'] / export function apply(ctx: Context): void {"
- File: src/sources/github.ts | Line: 14-21 | Content: "ctx.effect(() => ctx.orchestrator.sources.register(githubKind), 'github: source kind') / ctx.effect(() => { const source = sourceContext(ctx.orchestrator, githubKind) … return async () => { controller.abort(); await running } })"
- File: package.json | Line: 15 | Content: "\"./github-watch\": \"./lib/github-watch.js\","

### Dependencies

`deps_out` = core, infra, root. In the examples: `zod` (github.ts:17;
kind.ts:3 `import type { z } from 'zod'`), core via `../core/index.ts`
(kind.ts:4 | Content: "import type { OutboundMessage, ScopeResult,
Trigger } from '../core/index.ts'"), infra/commands via kind.ts:6
("import type { Commands } from '../infra/commands.ts'"), deployment via
kind.ts:5 ("import type { Deployment } from '../deployment.ts'"),
`@deepseek-ai/cordis` (github.ts:2 | Content: "import type { Context }
from '@deepseek-ai/cordis'"), `@deepseek-ai/dsh-agent` (kind.ts:2). The
peer DSH bundle of github-watch is listed in package.json
`dsh.client.inject`.

### Build

- Command (File: package.json | Line: 48-51): `pnpm typecheck`
  (tsc --noEmit) + `pnpm test` (vitest run); a standalone watcher build
  via `pnpm build` (tsdown, entry `github-watch` → lib/github-watch.js).
- **SKIPPED** — the mining sandbox has no node/pnpm (as s03). No output
  fabricated.

---

## 4. s01 — dsh-superagent/src/app (4★, 38 files / 5,292 LOC)

### What this item solves

App is the **server-side orchestration tier**: `Runtime` (runtime.ts:59)
is the composition root that connects the SQLite Store, Setup, Engine,
SourceRegistry, Effects, Outbox, Passes, Sessions, Settings, Prompts,
DshExecutor and MasterAssessor (File: src/app/runtime.ts | Line: 54-57 |
Content: "Composition root of dsh-superagent that connects `Store`,
`Setup`, `Engine`, `SourceRegistry`, `Effects`, `Outbox`, `Passes`,
`Sessions`, `Settings`, `Prompts`, `DshExecutor`, and `MasterAssessor`.
Exposes the `SourceHost` service … coordinates startup, setup checks,
HTTP route registration, and graceful shutdown."). It also runs the DB
migration 10→11, locks the state directory against concurrent writers,
and serves the loopback HTTP for the web panel. Consumers plug in through
the plugin entry `apply(ctx, config)` or the `orchestrator` service
(SourceHost).

### Use case 1 — Mount the orchestrator into a DSH host through the plugin entry `apply(ctx, config)`

Scenario: to make the agent proactive for one GitHub repository, an admin
declares the `dsh-superagent` plugin in dsh.yaml with a DeploymentConfig
(repository + the agent's CLI account). The DSH Cordis loader reads
`name`/`inject`/`Config` and calls `apply` — the entry builds `Runtime`,
awaits `runtime.ready` (setup + migration done) and logs the state.

```yaml
# dsh.yaml (DSH host) — DeploymentConfig-shaped configuration; schema & CLI/repo/bot verification live in deployment.ts (root, s07):
plugins:
  - resolve: dsh-superagent
    config:
      repository: owner/name
      github: { cli: /usr/local/bin/gh-agent }
```

```ts
// Entry contract (verbatim — this is what the DSH host calls; package export '.' → lib/index.js):
export const name = 'dsh-superagent'
export const inject = ['agents', 'sessionController', 'sessionPersistence', 'workspaceRegistry', 'permissionPresets', 'tools', 'systemPrompt', 'skills', 'webServer', 'llm', 'subprocess']
export { Config }
export async function apply(ctx: Context, config: DeploymentConfig): Promise<void> {
  const machine = machineOf(config)
  const restart = (): void => {
    ctx.fiber.restart().then(() => { ctx.get('settings')?.describe() }).catch((error: unknown) => { ctx.logger.error('dsh-superagent restart failed: %s', String(error)) })
  }
  const runtime = new Runtime(ctx, machine, restart)
  ctx.effect(() => async () => { await runtime.stop() })
  await runtime.ready
  ctx.logger.info(runtime.configured() ? 'dsh-superagent ready; the Superagent sidebar entry opens the management panel' : `dsh-superagent is waiting for setup: ${runtime.setupProblem?.detail ?? ''}`)
}
```

Evidence (the TS block is a verbatim quote of src/index.ts to show the
mounting contract):

- File: src/index.ts | Line: 7-10 | Content: "export const name = 'dsh-superagent' / export const inject = ['agents', …, 'subprocess'] / export { Config } / export async function apply(ctx: Context, config: DeploymentConfig): Promise<void> {"
- File: src/index.ts | Line: 11 | Content: "const machine = machineOf(config)"
- File: src/index.ts | Line: 18-20 | Content: "const restart = (): void => { ctx.fiber.restart().then(() => { ctx.get('settings')?.describe() }).catch(…) }"
- File: src/index.ts | Line: 21-23 | Content: "const runtime = new Runtime(ctx, machine, restart) / ctx.effect(() => async () => { await runtime.stop() }) / await runtime.ready"
- File: src/app/runtime.ts | Line: 59 | Content: "export class Runtime extends Service implements SourceHost {"
- File: package.json | Line: 13 | Content: "\".\" : { \"types\": \"./lib/index.d.ts\", \"default\": \"./lib/index.js\" },"

### Use case 2 — A source plugin next door consumes the `orchestrator` service (SourceHost): ingest a trigger, read tickets, report health

Scenario: a custom kind plugin (use case 1 of s06) needs to feed Triggers
into the Engine and update health. It declares `inject: ['orchestrator']`,
receives the `SourceHost`, and takes its kind's `SourceContext` via
`host.context({ kind, health })` — the context bundles exactly `receive`
(ingest + schedule a pass), `tickets.open()`, `threads.subscribed()`,
health `report()` and nothing else (a least-privilege surface).

```ts
import type { Trigger } from '../core/index.ts'
// your kind is registered (s06 use case 1) with health: ['tracker']
export const inject = ['orchestrator']
export function apply(ctx: Context): void {
  const host = ctx.orchestrator                                   // SourceHost (host.ts:23-27)
  const source = host.context({ kind: 'tracker', health: ['tracker'] })
  void source.ready.then(() => {
    if (!source.configured()) { source.report('tracker', { state: 'paused', detail: 'waiting for setup' }); return }
    const trigger: Trigger = toDomainTrigger(fetchUpstreamEvent()) // normalize the upstream event → Trigger (model.ts:23)
    const result = source.receive(trigger)                         // 'stored' | 'duplicate' | 'filtered' — next pass scheduled
    if (result === 'stored') source.state.set(cursorKey, event.id) // per-source KV read cursor
    for (const open of source.tickets.open()) track(open.id)       // open tickets, newest first
  })
}
```

Evidence:

- File: src/sources/host.ts | Line: 23-27 | Content: "export interface SourceHost { readonly sources: SourceRegistry / context(kind: { kind: string; health: readonly string[] }): SourceContext }"
- File: src/sources/host.ts | Line: 31 | Content: "export interface SourceContext {"
- File: src/sources/host.ts | Line: 42 | Content: "receive(trigger: Trigger): ReceiveResult | Promise<ReceiveResult>" (+ line 41: "Ingests a trigger into the Engine and schedules the next evaluation pass; callers should await completion before advancing read cursors.")
- File: src/sources/host.ts | Line: 44 | Content: "state: { get<V>(key: Key<V>): V | undefined; set<V>(key: Key<V>, value: V | undefined): void; keys<V>(family: Family<V, never>): Key<V>[] }"
- File: src/sources/host.ts | Line: 51-54 | Content: "tickets: { get(id: string): Ticket | undefined / /** Open tickets, newest first. */ / open(): Ticket[]"
- File: src/sources/host.ts | Line: 65 | Content: "report(entry: string, health: Health): void" (+ line 64: "Reports the state of one of this kind's declared health entries; throws for undeclared entry names.")
- File: src/sources/host.ts | Line: 67 | Content: "export const sourceContext = (host: SourceHost, kind: { kind: string; health: readonly string[] }): SourceContext => host.context(kind)"
- File: src/app/runtime.ts | Line: 51 | Content: "declare module '@deepseek-ai/cordis' { interface Context { orchestrator: SourceHost } }"

### Use case 3 — Operating two instances / restarting safely: the state directory is locked before SQLite opens

Scenario: ops accidentally starts a second dsh-superagent process on the
same state directory. Runtime locks `machine.stateDir` with
proper-lockfile BEFORE opening SQLite — the second process cannot
migrate/overwrite anything and fails clearly; the `stale: 30s` lock
auto-releases when the holder dies, and `onCompromised` moves the runtime
to error + abort if the lock is lost mid-run.

```ts
// The lock inside the Runtime constructor (verbatim runtime.ts:90-94) — operational meaning:
//   mkdirSync(machine.stateDir, { recursive: true, mode: 0o700 })
//   const compromised = (error: Error) => { this.runtimeHealth.set({ state: 'error', detail: error.message }); this.stopped.abort() }
//   const release = lockSync(machine.stateDir, { stale: 30_000, onCompromised: compromised })
//   this.releaseLock = async () => { release() }
// Run scenario: process B starts on the same stateDir → lockSync(B) fails → B never opens orchestrator.sqlite.
// Process A holds the lock; when A is kill -9'd, the stale lock expires after 30s → the next instance can start.
// runtimeHealth already claimed the 'runtime' entry (runtime.ts:75) — the error shows up on the panel Overview immediately.
```

Evidence:

- File: src/app/runtime.ts | Line: 57 | Content: "Locks the state directory before opening SQLite so concurrent processes cannot corrupt or double-migrate state."
- File: src/app/runtime.ts | Line: 90-91 | Content: "// Lock the state directory before opening the database so another process cannot migrate or write concurrently. / mkdirSync(machine.stateDir, { recursive: true, mode: 0o700 })"
- File: src/app/runtime.ts | Line: 92-94 | Content: "const compromised = (error: Error) => { this.runtimeHealth.set({ state: 'error', detail: error.message }); this.stopped.abort() } / const release = lockSync(machine.stateDir, { stale: 30_000, onCompromised: compromised }) / this.releaseLock = async () => { release() }"
- File: src/app/runtime.ts | Line: 75 | Content: "private readonly runtimeHealth = this.board.claim('runtime', { state: 'starting', detail: '' })"
- File: src/app/runtime.ts | Line: 15 | Content: "import { lockSync } from 'proper-lockfile'"

### Dependencies

`deps_out` = core, executor, infra, sources, root. Use case 2 pulls
`../core/index.ts` (Trigger); the real runtime additionally pulls
`proper-lockfile` (runtime.ts:15), `node:fs`/`node:path`
(runtime.ts:13-14) and 10 `@deepseek-ai/dsh-*` peers + `@deepseek-ai/cordis`
(runtime.ts:2-12).

### Build

- Command (File: package.json | Line: 48-51): `pnpm typecheck && pnpm
  test` (vitest) — app has no standalone build entry; the common bundle
  via `pnpm build` (tsdown → lib/index.js).
- **SKIPPED** — the mining sandbox has no node/pnpm. No output fabricated.

---

## 5. s05 — dsh-superagent/src/infra (4★, 5 files / 347 LOC)

### What this item solves

Infra is the **shared process infrastructure**: `Commands` wraps `gh`/
`git`/`lark-cli` subprocesses under the deployment account with
timeout/abort and normalizes CLI failures into `CliError` (File:
src/infra/commands.ts | Line: 55-58 | Content: "Executes gh, lark-cli,
and git subprocesses with deployment account credentials, timeouts, and
abort signals. Restricts GitHub API calls to the configured repository
and translates CLI failures into CliError instances for Sources,
MasterAssessor, Outbox, and Settings."); `environment.ts` writes
worker-bin/gitconfig shims + a safe worker environment; `health.ts` is
the single-writer health registry for the panel.

### Use case 1 — Repository-scoped GitHub API calls with schema validation (Commands.api / pages)

Scenario: a satellite (an assessment reading an issue, a panel listing
issues) calls GitHub through the agent account's CLI. `Commands.api`
prefixes `repos/<repository>/...`, rejects absolute paths/schemes/
traversal, and parses through a zod schema; `pages` wraps
`--paginate --slurp` and drops items failing the schema (counted in
tally.skipped).

```ts
import { z } from 'zod'
import type { Commands } from '../infra/commands.ts'   // obtained from SourceContext.commands (host.ts:33) — never new'd directly

const Issue = z.object({ number: z.number(), title: z.string(), state: z.enum(['open', 'closed']) })
const Tally: { skipped: number } = { skipped: 0 }

async function audit(tally: { skipped: number }): Promise<void> {
  const issue = await commands.api(Issue, 'issues/12')        // → GET repos/<repository>/issues/12, schema.parsed
  // invalid paths throw before any network call:
  //   commands.api(Issue, '/issues/12')   → Error('GitHub calls are restricted to the configured repository')
  //   commands.api(Issue, '../../other')  → same
  const all = await commands.pages(Issue, 'issues', tally)    // every page, schema-invalid items dropped + tally.skipped++
  const raw = await commands.api('issues/12/comments', '--paginate')   // string overload → raw stdout (no schema)
  report(`${issue.title}: ${all.length} issues audited, raw ${raw.length} bytes, skipped ${tally.skipped}`)
}
```

Evidence:

- File: src/infra/commands.ts | Line: 59 | Content: "export class Commands {"
- File: src/infra/commands.ts | Line: 64 | Content: "constructor(private readonly resolved: () => Deployment, private readonly environment: Record<string, string | undefined>, private readonly signal: AbortSignal) {}"
- File: src/infra/commands.ts | Line: 82-84 | Content: "async api<T>(schema: z.ZodType<T>, path: string, ...flags: string[]): Promise<T> / async api(path: string, ...flags: string[]): Promise<string>"
- File: src/infra/commands.ts | Line: 90 | Content: "async pages<T>(item: z.ZodType<T>, path: string, tally?: Tally): Promise<T[]> {"
- File: src/infra/commands.ts | Line: 94-97 | Content: "const outside = /^\\/|^[a-z]+:|(^|\\/)\\.\\.?(\\/|\\?|$)/i.test(path) / if (outside) throw new Error('GitHub calls are restricted to the configured repository') / return path ? `repos/${this.repository}/${path}` : `repos/${this.repository}`"
- File: src/infra/commands.ts | Line: 42-44 | Content: "export interface Tally { skipped: number } / /** Parses array elements against a schema, skipping invalid items and incrementing `tally.skipped`. */ / export function validItems<T>(…)"
- File: src/sources/host.ts | Line: 33 | Content: "readonly commands: Commands"

### Use case 2 — Classify CLI errors: stop tracking on HTTP 410, retry on 404 (CliError code)

Scenario: a poller reads a PR/issue on GitHub. A 410 (Gone) means the
upstream was deleted — stop tracking forever; a 404 may just be
temporarily revoked access — retry on the next poll. The repository
itself uses this pattern in github.ts (`deleted`); the code below reuses
it for a Commands consumer.

```ts
import { CliError } from '../infra/commands.ts'

async function readThread(commands: Commands, number: number): Promise<'ok' | 'gone' | 'retry'> {
  try {
    await commands.api('issues/' + number)
    return 'ok'
  } catch (error) {
    if (error instanceof CliError && error.code === 410) return 'gone'   // HTTP 410 — upstream deleted, stop tracking
    if (error instanceof CliError && error.code === 404) return 'retry'  // 404 — possibly revoked access, poll again
    throw error                                                          // other errors go to pollFailure counting (github.ts:124)
  }
}
```

Evidence:

- File: src/infra/commands.ts | Line: 14-15 | Content: "export class CliError extends Error { / constructor(message: string, readonly code?: number, readonly exitCode?: number) { super(message) }"
- File: src/infra/commands.ts | Line: 29 | Content: "if (stderr) return new CliError(stderr.slice(0, 2000), Number(/\\bHTTP (\\d{3})\\b/.exec(stderr)?.[1]) || undefined, exitCode)"
- File: src/sources/github.ts | Line: 157-158 | Content: "/** True when GitHub returns HTTP 410 (Gone); HTTP 404 is retried because it can indicate revoked access to a private repository. */ / const deleted = (error: unknown): boolean => error instanceof CliError && error.code === 410"
- File: src/sources/github.ts | Line: 124 | Content: "export function pollFailure(failures: number, threshold: number, error: unknown): Health | undefined {"
- File: src/infra/commands.ts | Line: 49-51 | Content: "/** Rewrites Feishu error 232011 (bot not in chat) with remediation instructions. */ / function membership(error: unknown): unknown { / if (!(error instanceof CliError) || error.code !== 232011) return error"

### Use case 3 — Single-writer health entries: claim / set / release on the HealthBoard

Scenario: a source kind reports its own health to the panel. The
HealthBoard refuses a second claim on the same entry (Runtime claims
'runtime' @runtime.ts:75, the Executor claims 'worker', the registry
claims the kinds' entries) — preventing two components from overwriting
each other's health; `release()` on unregister turns later `set()` calls
into no-ops.

```ts
import { HealthBoard } from '../infra/health.ts'
import type { Health } from '../sources/host.ts'

const board = new HealthBoard()
const entry = board.claim('tracker', { state: 'starting', detail: '' })   // second claim → throw (health.ts:19)
entry.set({ state: 'ready', detail: 'polling project infra every 60s' })
board.all['tracker']                                                      // { state: 'ready', … } — the panel reads from here
entry.set({ state: 'error', detail: 'tracker unreachable' })
entry.release()                                                           // unregister (kind removed from the registry)
entry.set({ state: 'ready', detail: 'stale write' })                      // no-op — a released entry is never revived
try { board.claim('tracker', { state: 'starting', detail: '' }) }         // claimable again now (left the claimed set)
catch { /* does not happen after release */ }
```

Evidence:

- File: src/infra/health.ts | Line: 15 | Content: "export class HealthBoard {"
- File: src/infra/health.ts | Line: 18-19 | Content: "claim(name: string, initial?: Health): HealthEntry { / if (this.claimed.has(name)) throw new Error(`The health entry ${name} is reported by another part`)"
- File: src/infra/health.ts | Line: 23-29 | Content: "return { / get: () => this.entries[name], / set: health => { if (held) this.entries[name] = health }, / release: () => { / if (!held) return / held = false / this.claimed.delete(name) / delete this.entries[name] / },"
- File: src/infra/health.ts | Line: 34 | Content: "get all(): Readonly<Record<string, Health>> { return this.entries }"
- File: src/infra/health.ts | Line: 13 | Content: "Claimed by Runtime, Effects, Sessions, DshExecutor, Settings, and SourceRegistry, and read by management HTTP routes."
- File: src/app/runtime.ts | Line: 75 | Content: "private readonly runtimeHealth = this.board.claim('runtime', { state: 'starting', detail: '' })"

### Dependencies

`deps_out` = sources, root. Example imports: `Health` type from
`../sources/host.ts` (health.ts:2), `zod` (commands.ts:5) and the
`Deployment` type from root `../deployment.ts` (commands.ts:6). Runtime
provides Commands through `SourceContext.commands` — consumers never
`new Commands`.

### Build

- Command (File: package.json | Line: 48-51): `pnpm typecheck && pnpm
  test` (vitest); no standalone build entry — into the common `pnpm
  build` bundle (tsdown).
- **SKIPPED** — the mining sandbox has no node/pnpm. No output fabricated.

---

## 6. s07 — dsh-superagent/src (root modules) — 4★

### What this item solves

This is the host shell of the DSH plugin: `index.ts` mounts the Runtime
into the host Cordis via `apply(ctx, config)` with a restart callback for
deployment account changes, `deployment.ts` declares the Config schema
and verifies CLI/repository/Feishu-bot at startup, `policy.ts` defines
the zod settings schema and the authorization port (gate/revalidate
mandate) (File: module map, item m07 | Content: "The host-plugin shell of
the DSH bundle — 8 .ts files directly in src/: index.ts mounts Runtime
through apply(ctx) (index.ts:10-25), deployment.ts declares the Config
schema and verifies CLI/repository/Feishu-bot at startup
(deployment.ts:87-106,114-131), policy.ts defines the zod settings schema
(policy.ts:99-105) and the authorization gate/mandate revalidation port
(policy.ts:167-242)"). In short: whoever installs dsh-superagent into a
DSH host uses this item to attach the plugin, configure machine settings,
and control who may hand over work.

### Use case 1 — Install the plugin into a DSH host via `apply(ctx, config)` with a restart callback

Scenario: a team installs dsh-superagent as a DSH bundle plugin. The host
reads the package entry to learn the plugin name, the services to inject,
and the config schema; when it calls `apply()`, the module derives
machine settings from the config (rejecting unknown keys), builds the
Runtime, and registers a cleanup effect for stop. A deployment-account
change makes the host call the module-provided `restart` callback.

```ts
// Host side: what DSH reads from the package entry (src/index.ts).
import { name, inject, Config, apply } from 'dsh-superagent'
console.log(name)    // 'dsh-superagent'
console.log(inject)  // ['agents', 'sessionController', 'sessionPersistence', 'workspaceRegistry',
                     //  'permissionPresets', 'tools', 'systemPrompt', 'skills', 'webServer', 'llm', 'subprocess']

// Inside apply(ctx, config): derive machine settings (rejects unknown keys, names moved ones),
// mount the Runtime with the host-provided restart callback, and clean up on stop.
export async function apply(ctx: Context, config: DeploymentConfig): Promise<void> {
  const machine = machineOf(config)
  const restart = (): void => { ctx.fiber.restart().then(() => { ctx.get('settings')?.describe() })
    .catch((error: unknown) => { ctx.logger.error('dsh-superagent restart failed: %s', String(error)) }) }
  const runtime = new Runtime(ctx, machine, restart)
  ctx.effect(() => async () => { await runtime.stop() })
  await runtime.ready
}
```

Evidence (clone at the pin):

- File: src/index.ts | Line: 7 | Content: `export const name = 'dsh-superagent'`
- File: src/index.ts | Line: 8 | Content: `export const inject = ['agents', 'sessionController', 'sessionPersistence', 'workspaceRegistry', 'permissionPresets', 'tools', 'systemPrompt', 'skills', 'webServer', 'llm', 'subprocess']`
- File: src/index.ts | Line: 9 | Content: `export { Config }`
- File: src/index.ts | Line: 10 | Content: `export async function apply(ctx: Context, config: DeploymentConfig): Promise<void> {`
- File: src/index.ts | Line: 11 | Content: `  const machine = machineOf(config)`
- File: src/index.ts | Line: 18-20 | Content: `  const restart = (): void => {` … `ctx.fiber.restart().then(() => { ctx.get('settings')?.describe() }).catch((error: unknown) => { ctx.logger.error('dsh-superagent restart failed: %s', String(error)) })` … `  }`
- File: src/index.ts | Line: 21-23 | Content: `  const runtime = new Runtime(ctx, machine, restart)` / `  ctx.effect(() => async () => { await runtime.stop() })` / `  await runtime.ready`
- File: src/deployment.ts | Line: 38 | Content: `export function machineOf(config: DeploymentConfig): Machine {`

### Use case 2 — Parse settings, compute the authorization version hash, check a sender against the allowed list

Scenario: an operator edits settings through the management panel. After
each save the host needs to (1) parse/validate the whole settings object
through the zod schema, (2) compute `policyVersion` to know which
mandates need revalidation — the version covers only rules/eval-mode/
sources, flipping `paused` does not invalidate existing decisions, (3)
look up whether a sender is on a Source's allowed list.

```ts
import { SettingsSchema, policyVersion, allowedSender } from './policy.ts'
import type { ActorRef } from './core/index.ts'

const settings = SettingsSchema.parse({
  policy: {
    rules: [{ id: 'copy', name: 'Copy fixes', enabled: true, instruction: 'Explicit requests to correct a typo, wording or punctuation.' }],
    sources: { github: { allowed: [{ id: 'octocat', name: 'The Octocat' }] } },
  },
  eval: { mode: 'observe' },
})

// Version covers only authorization-affecting fields (rules, eval mode, per-source policy);
// pausing the engine does not invalidate existing mandates.
const before = policyVersion(settings)
const after = policyVersion({ ...settings, paused: !settings.paused })
console.log(before === after)                       // true

const actor: ActorRef = { source: 'github', id: 'octocat' }
console.log(allowedSender(settings, actor)?.name)   // 'The Octocat'
```

Evidence:

- File: src/policy.ts | Line: 99 | Content: `export const SettingsSchema = z.object({`
- File: src/policy.ts | Line: 116 | Content: `export function policyVersion(settings: Settings): string {`
- File: src/policy.ts | Line: 117 | Content: `  return key(POLICY_REVISION, JSON.stringify({ rules: settings.policy.rules, mode: settings.eval.mode, sources: settings.policy.sources }))`
- File: src/policy.ts | Line: 112-115 | Content: `/** Compute a version hash for settings that affect work authorization. Changes to models, concurrency, pause state, or polling intervals do not invalidate existing decisions. */` (the JSDoc block directly above policyVersion)
- File: src/policy.ts | Line: 119 | Content: `export function allowedSender(settings: Settings, actor: ActorRef): z.infer<typeof AllowedSchema> | undefined {`
- File: src/core/model.ts | Line: 5 | Content: `export interface ActorRef { source: string; id: string }`

### Use case 3 — Startup verification: GitHub CLI identity + push access via `resolveDeployment`

Scenario: when the plugin starts (Runtime setup), the system must verify
that the `gh` CLI exists outside the worker-shim PATH, is signed in, and
the account can push to the configured repository — otherwise workers
could never deliver a PR. Failures raise a `SetupError` with a structured
code the panel localizes. This is the Runtime's real call path:
`resolveDeployment(machine, settings.sources.github?.config, this.probe())`.

```ts
import { machineOf, workerProbe, resolveDeployment } from './deployment.ts'
import { SetupError } from './setup.ts'

// Runtime setup (app/setup.ts:74,79): probe = worker subprocess with the worker shim dir removed from PATH.
const machine = machineOf(config)
const probe = workerProbe(context.subprocess, machine.stateDir, machine.stateDir, lifetime)

try {
  const deployment = await resolveDeployment(machine, settings.sources.github?.config, probe)
  console.log(deployment.github.login, deployment.repository)  // 'octocat acme/widget'
} catch (error) {
  if (error instanceof SetupError) console.error('setup:', error.code, error.problem.detail)
  // e.g. code 'repositoryReadOnly' when the account cannot push to the repository.
}
```

Evidence:

- File: src/deployment.ts | Line: 73 | Content: `export function workerProbe(subprocess: SubprocessRuntime, stateDir: string, cwd: string, signal: AbortSignal): Probe {`
- File: src/deployment.ts | Line: 87 | Content: `export async function resolveDeployment(machine: Machine, github: unknown, probe: Probe, path = process.env.PATH ?? ''): Promise<Deployment> {`
- File: src/deployment.ts | Line: 104 | Content: `  if (access.push !== true) throw new SetupError('repositoryReadOnly', { account: agent.login, repository })`
- File: src/app/setup.ts | Line: 79 | Content: `      const deployment = await resolveDeployment(machine, settings.sources.github?.config, probe)` (the Runtime's real call site)
- File: src/app/setup.ts | Line: 74 | Content: `    return workerProbe(context.subprocess, machine.stateDir, machine.stateDir, lifetime)`
- File: src/setup.ts | Line: 30-33 | Content: `export class SetupError extends Error {` / `  readonly place: SetupPlace` / `  constructor(readonly code: SetupCode, readonly values: Record<string, string> = {}) {` (error.code + .problem)
- File: src/deployment.ts | Line: 53 | Content: `export interface Deployment extends Machine {` (deployment.github.login/.repository)

### Dependencies

deps_out (checklist): app, core, infra, sources. Concrete imports in the
three examples: `./app/runtime.ts` (Runtime — index.ts:4),
`./core/index.ts` (ActorRef, domain types — re-exported at index.ts:27
`export * from './core/index.ts'`), `./setup.ts` (SetupError),
`./infra/environment.ts` + `./infra/text.ts` (pulled by
policy.ts/deployment.ts: policy.ts:7-8, deployment.ts:10); external
packages `zod` (policy.ts:3), `@deepseek-ai/schemastery`
(deployment.ts:8), `@deepseek-ai/cordis` (Context — index.ts:2),
`@deepseek-ai/dsh-subprocess` (SubprocessRuntime — deployment.ts:9).

### Build

SKIPPED — the mining sandbox has no node/pnpm (see the header). The
commands that would run (real repository scripts): `pnpm install
--frozen-lockfile && pnpm typecheck && pnpm test` (vitest) (File:
package.json | Line: 48-50).

---

## 7. s02 — dsh-superagent/src/client — 3★

### What this item solves

The browser-side React management panel: `index.tsx` mounts the main
panel/sidebar icon/config view into the DSH web client through slots and
registers zh/en dictionaries; the remaining files implement 5 tab views
(Overview/Source/Trigger/Eval/Execution) + Settings/Prompts/Deployment, a
same-origin REST client and route memory (module map, item m02). In
short: an administrator opens the Superagent panel in the DSH web client
to watch tickets, edit settings, and navigate worker sessions.

### Use case 1 — Mount the panel, sidebar icon and config view into the web client via `apply(ctx)`

Scenario: the browser bundle `lib/client.js` is loaded by the DSH web
client, which then calls `apply(ctx)`. The module registers the zh/en
locale dictionaries, the main panel under the `main` slot, the hammer
icon under `sidebar.panellist` (order 10), and the config view for the
Plugin Manager — all three via `ctx.slots.inject`, so the host cannot
learn the plugin's positions unless the plugin registers them.

```tsx
// Browser entry (lib/client.js) loaded by the DSH web client.
import { inject, apply } from 'dsh-superagent/client'
console.log(inject)  // ['slots', 'locale', 'sessions', 'uiWorkspace']

// Inside apply(ctx): three slot registrations + locale dictionaries.
export function apply(ctx: ClientContext): void {
  ctx.effect(() => ctx.locale.register('dshSuperagent', { zh, en }), 'dsh-superagent: dictionaries')
  const t = ctx.locale.bind('dshSuperagent')
  ctx.slots.inject('main', () => ctx.slots.register(
    { name: 'main', key: 'dsh-superagent', locale: 'dshSuperagent', inject: () => ({}) },
    (props: { t: T }) => <Mounted ctx={ctx} t={props.t} />))
  ctx.slots.inject('sidebar.panellist', () => ctx.slots.register(
    { name: 'sidebar.panellist', id: 'dsh-superagent', order: 10, label: () => t('panel'), locale: 'dshSuperagent' }, HammerIcon))
  ctx.slots.inject('plugins.row.config', () => ctx.slots.register(
    { name: 'plugins.row.config', key: 'dsh-superagent#dsh-superagent', locale: 'dshSuperagent' },
    (props: PluginConfigViewProps & { t: T }) => <PluginConfig t={props.t} view={props.view} form={props.form} />))
}
```

Evidence:

- File: src/client/index.tsx | Line: 48 | Content: `export const inject = ['slots', 'locale', 'sessions', 'uiWorkspace']`
- File: src/client/index.tsx | Line: 50 | Content: `export function apply(ctx: ClientContext): void {`
- File: src/client/index.tsx | Line: 51 | Content: `  ctx.effect(() => ctx.locale.register(NS, { zh, en }), 'dsh-superagent: dictionaries')`
- File: src/client/index.tsx | Line: 53-54 | Content: `  ctx.slots.inject('main', () => ctx.slots.register({ name: 'main', key: PANEL_ID, locale: NS, inject: () => ({}) },` / `    (props: { t: T }) => <Mounted ctx={ctx} t={props.t} />))`
- File: src/client/index.tsx | Line: 55 | Content: `  ctx.slots.inject('sidebar.panellist', () => ctx.slots.register({ name: 'sidebar.panellist', id: PANEL_ID, order: 10, label: () => t('panel'), locale: NS }, HammerIcon))`
- File: src/client/index.tsx | Line: 56-58 | Content: `  ctx.slots.inject('plugins.row.config', () => ctx.slots.register({ name: 'plugins.row.config', key: \`${ENTRY}#${ENTRY}\`, locale: NS },` / `    (props: PluginConfigViewProps & { t: T }) => <PluginConfig t={props.t} view={props.view} form={props.form} />))`
- File: src/client/index.tsx | Line: 20-21 | Content: `const NS = 'dshSuperagent'` / `const PANEL_ID = 'dsh-superagent' as MainPanelId`
- File: src/client/locales.ts | Line: 752 | Content: `export const zh = language(0), en = language(1)`

### Use case 2 — Poll management data and handle structured API errors (`usePoll`, `caller`, `ApiError`)

Scenario: a tab view (e.g. the list of open tickets) needs fresh data
without writing its own polling: the view calls `caller()` for a
same-origin REST client that attaches the `x-orchestrator-request`
header, then `usePoll()` polls every 5s (self-widening while the tab is
hidden). Errors come back as `ApiError` with distinctions: a 404 with an
empty body = routes not mounted (host restarting) → `missing === false`,
while a 404 with a body = the record genuinely does not exist.

```tsx
import { usePoll, ApiError, caller, type TicketRow } from './api.ts'

const messages = () => ({ offline: 'offline', notRunning: 'starting…', serverError: s => `server ${s}`,
  requestFailed: s => `request failed (${s})`, setup: p => p.detail, user: f => f.code })
const call = caller(messages)

function OpenTickets() {
  const { data, error, reload } = usePoll(() => call('GET tickets', { filter: 'open' }), [], 5000)
  if (error instanceof ApiError) {
    if (error.missing) return <p>Ticket not found (host confirmed 404 with a body).</p>
    if (error.issues.length) return <p>{error.issues[0].message}</p>  // validation issues from the host
    return <p>{error.message}</p>
  }
  return <ul>{data?.items.map((row: TicketRow) => <li key={row.id}>{row.title}</li>)}
    <li><button onClick={reload}>refresh</button></li></ul>
}
```

Evidence:

- File: src/client/api.ts | Line: 108 | Content: `export function caller(messages: () => ApiMessages): Call {`
- File: src/client/api.ts | Line: 67 | Content: `export function usePoll<T>(load: () => Promise<T>, deps: readonly unknown[], intervalMs = 5000) {`
- File: src/client/api.ts | Line: 97 | Content: `  return { data: state.data, error: state.error, reload }` (the usePoll return shape)
- File: src/client/api.ts | Line: 16 | Content: `export class ApiError extends Error {`
- File: src/client/api.ts | Line: 21 | Content: `  get issues() { return this.details.issues ?? [] }`
- File: src/client/api.ts | Line: 23 | Content: `  get missing() { return this.status === 404 && !this.details.unreachable }`
- File: src/app/api.ts | Line: 12 | Content: `export const TICKET_FILTERS = ['open', 'person', 'working', 'idle', 'ended'] as const` (the 'open' filter value is valid)
- File: src/client/api.ts | Line: 37 | Content: `    response = await fetch(\`/orchestrator/api/${path}\`, { method, ...json, headers: { 'x-orchestrator-request': '1', ...json.headers } })` (same-origin + the request marker header)

### Use case 3 — Route memory: read/write the panel position via `parseRoute`/`remember`/`initialLocation`

Scenario: a user reopens the browser tab a day later; the panel must open
on the previous tab/destination rather than Overview. The route is stored
in `sessionStorage` under key `dsh-superagent/route`; when read back,
`parseRoute` validates and drops unknown query filters/removed tabs (e.g.
a legacy `policy` tab), and unreadable values safely fall back to HOME.

```ts
import { parseRoute, remember, initialLocation, settingsRoute, type Location } from './route.ts'

// On mount: read + validate the stored location; unreadable values fall back to HOME.
const location: Location = initialLocation()
console.log(location.route)  // e.g. { page: 'execution', id: 't-8f3a2b' }

// Writing a new location on navigation: typed Route, stack of previous routes.
console.log(parseRoute({ page: 'settings', query: { group: 'prompts' } }))  // typed Route object
console.log(parseRoute({ page: 'legacy-tab' }))                             // undefined → dropped
remember({ route: settingsRoute('eval'), stack: [location.route], group: 'execution' })
```

Evidence:

- File: src/client/route.ts | Line: 32 | Content: `export function parseRoute(value: unknown): Route | undefined {` (doc above it: "Validate and normalize a stored route, dropping unrecognized query filters or removed tabs")
- File: src/client/route.ts | Line: 53 | Content: `export function initialLocation(): Location {`
- File: src/client/route.ts | Line: 65 | Content: `export function remember(location: Location): void {`
- File: src/client/route.ts | Line: 19 | Content: `export const settingsRoute = (group: SettingsGroup, query: { source?: string; version?: string } = {}): Route =>`
- File: src/client/route.ts | Line: 50 | Content: `export interface Location { route: Route; stack: Route[]; group?: SettingsGroup | undefined }`
- File: src/client/route.ts | Line: 49 | Content: `const ROUTE_KEY = 'dsh-superagent/route'`

### Dependencies

deps_out (checklist): app, core, sources, root. Concrete imports in the
three examples: `../app/api.ts` (Api/ApiRequest/ApiResponse +
TICKET_FILTERS — api.ts:3), `../core/errors.ts` (USER_ERRORS —
locales.ts:4, the module-map edge m02→m03), `../navigation.ts`
(openKnownSession/SessionNavigationError — index.tsx:13, root s07),
`../setup.ts` (SetupProblem — api.ts:5, root s07), `../sources/host.ts`
(HEALTH_TEXT — the module-map edge m02→m06); external packages: `react`
(api.ts:2, index.tsx:2), the DSH web-client services
`@deepseek-ai/dsh-client-*` (index.tsx:4-15).

### Build

SKIPPED — the mining sandbox has no node/pnpm (header). Real scripts:
`pnpm typecheck && pnpm test` (vitest) (File: package.json | Line: 49-50);
the client bundle via the tsdown `client` entry → `lib/client.js` (File:
package.json | Line: 16 | Content: `"./client": "./lib/client.js",`).

---

## 8. s04 — dsh-superagent/src/executor — 3★

### What this item solves

The module runs each Assignment of a ticket in a persistent
`worker-<ticketId>` DSH worker session with its own workspace directory:
`DshExecutor` prepares the workspace, queues launch/deliver through the
effect queue with concurrency capped by `WorkerSlots`, listens to
agent/session events to report transitions back to the Engine, and
retries transient failures with backoff; `background.ts` manages shell
jobs and subagents left behind by worker turns (module map, item m04).
In short: this is the layer that turns an accepted ticket into a real
agent working session.

### Use case 1 — Map tickets ↔ worker sessions and classify transient errors

Scenario: a view/route wants to jump from a ticket to its worker session
(open `worker-<ticketId>`), and conversely, when receiving a
`session/event` from an arbitrary session, needs to know which ticket it
belongs to. Meanwhile, when a launch/delivery fails, only transient
network/model errors (429/5xx/ECONNRESET…) may be retried — anything
else must fail immediately so a slot is never wedged.

```ts
import { workerSessionId, ticketOfSession, transient } from '../executor/dsh.ts'

// One persistent worker session per ticket, named after the ticket.
const sessionId = workerSessionId('t-8f3a2b')   // 'worker-t-8f3a2b'
console.log(ticketOfSession(sessionId))         // 't-8f3a2b'
console.log(ticketOfSession('main'))            // undefined — not a worker session

// Transient classification: HTTP 408/429/5xx by `status`, or known network/text patterns.
console.log(transient({ status: 429 }))                                   // true  → retried with backoff
console.log(transient(Object.assign(new Error('fetch failed'), { code: 'ECONNRESET' })))  // true
console.log(transient(new Error('The prepare command failed: git checkout exited 1')))    // false → fails fast
```

Evidence:

- File: src/executor/dsh.ts | Line: 24 | Content: `export const workerSessionId = (ticketId: string): string => \`worker-${ticketId}\``
- File: src/executor/dsh.ts | Line: 26 | Content: `export const ticketOfSession = (sessionId: string): string | undefined => sessionId.startsWith('worker-') ? sessionId.slice('worker-'.length) : undefined`
- File: src/executor/dsh.ts | Line: 50 | Content: `export function transient(error: unknown): boolean {`
- File: src/executor/dsh.ts | Line: 44-45 | Content: `const PASSING = new RegExp(['ECONNRESET', 'ECONNREFUSED', 'ETIMEDOUT', 'EAI_AGAIN', 'ENOTFOUND', 'EPIPE', 'UND_ERR', 'socket hang up', 'fetch failed',` / `  'network error', 'overloaded', 'rate limit', '\\b(?:408|429|50[0-4])\\b'].join('|'), 'i')`
- File: src/executor/dsh.ts | Line: 51-52 | Content: `  const status = (error as { status?: unknown } | undefined)?.status` / `  if (typeof status === 'number') return status === 408 || status === 429 || status >= 500`

### Use case 2 — Bound concurrency with `WorkerSlots` (reserve/free, the spare person slot)

Scenario: the operator sets `maxWorkers = 2`; while two tickets run, a
third ticket asking for a launch must be queued (throwing `Later` so the
effect queue retries later) instead of multiplying sessions. Conversely,
a person's follow-up typed directly into a worker session must wake it
IMMEDIATELY even when all slots are taken — `by: 'person'` may take
exactly one slot beyond the cap.

```ts
import { WorkerSlots } from '../executor/dsh.ts'
import { Later } from '../app/effects.ts'

const running: string[] = ['ticket-a']
// max comes from ExecutorConfigSchema `maxWorkers` (default 3, range 1..16); 2 here for the demo.
const slots = new WorkerSlots(() => running, () => 2)

slots.reserve('ticket-b', 'launch')        // idempotent while `ticket-b` already holds a starting slot
try {
  slots.reserve('ticket-c', 'launch')      // used() === 2 === max → no free slot
} catch (error) {
  if (error instanceof Later) console.log('no worker slot is free — queued for a later retry')
}
// A wake carrying a person's message may take ONE extra slot beyond max() so it never queues behind launches.
slots.reserve('ticket-d', 'person')
console.log(slots.used(), slots.launches())   // 3 1
slots.free('ticket-b')                        // release once the worker turn is running (or the attempt ended)
```

Evidence:

- File: src/executor/dsh.ts | Line: 171 | Content: `export class WorkerSlots {`
- File: src/executor/dsh.ts | Line: 178 | Content: `  constructor(private readonly running: () => string[], private readonly max: () => number) {}`
- File: src/executor/dsh.ts | Line: 180 | Content: `  used(): number { return new Set([...this.running(), ...this.starting.keys()]).size }`
- File: src/executor/dsh.ts | Line: 182 | Content: `  launches(): number {`
- File: src/executor/dsh.ts | Line: 192 | Content: `  reserve(ticketId: string, by: 'launch' | 'wake' | 'person'): void {`
- File: src/executor/dsh.ts | Line: 194 | Content: `    if (this.used() >= this.max() + (by === 'person' ? 1 : 0)) throw new Later('No worker slot is free')`
- File: src/executor/dsh.ts | Line: 198 | Content: `  free(ticketId: string): void { this.starting.delete(ticketId) }`
- File: src/app/effects.ts | Line: 5 | Content: `export class Later extends Error {}`
- File: src/policy.ts | Line: 93 | Content: `  maxWorkers: z.number().int().min(LIMITS.maxWorkers.min).max(LIMITS.maxWorkers.max).default(3),`

### Use case 3 — The launch/deliver lifecycle through the effect queue with `DshExecutor`

Scenario: the Runtime constructs the executor once with host services;
the constructor registers handlers for the `launch` effect (limit =
free slots, 0 while paused) and `delivery` (limit 4, quiet). When the
Engine accepts a ticket it calls `prepare()` to fill execution
attributes, then `start()` queues the launch; each new input is `deliver()`ed
into the delivery queue; ops needs to know how many workers hold slots
and to resume after un-pausing.

```ts
import { DshExecutor, type ExecutorHost } from '../executor/dsh.ts'

// Runtime constructs the executor once; the constructor registers the effect handlers:
//   'launch'   → limit: () => host.paused() ? 0 : this.slots.launches(), retry [5000, 300_000]
//   'delivery' → limit: () => host.paused() ? 0 : 4, quiet: true
const executor = new DshExecutor(host as ExecutorHost)
executor.install()   // subscribes agent/status, agent/inbox/claimed, session/event, agent/error

// Engine flow for an accepted ticket:
const staged = executor.prepare(ticket, outcome)  // fills execution: worktree name, directory, assignment
executor.start(staged, assignment)                // enqueues the launch effect
executor.deliver(staged, assignment)              // enqueues delivery of new inputs to worker-<ticketId>

// Introspection and pause/resume (settings service):
console.log(executor.activeCount())               // open tickets whose worker holds a slot
executor.resume()                                 // release held handlers after unpausing
```

Evidence:

- File: src/executor/dsh.ts | Line: 207 | Content: `export class DshExecutor implements Executor {`
- File: src/executor/dsh.ts | Line: 228 | Content: `  constructor(private readonly host: ExecutorHost) {`
- File: src/executor/dsh.ts | Line: 232 | Content: `    host.effects.handle('launch', payload => this.launchQueued(payload), { limit: () => host.paused() ? 0 : this.slots.launches(),`
- File: src/executor/dsh.ts | Line: 235 | Content: `    host.effects.handle('delivery', payload => this.deliverQueued(payload.ticketId), { limit: () => host.paused() ? 0 : 4, quiet: true })`
- File: src/executor/dsh.ts | Line: 238 | Content: `  prepare(ticket: Ticket, outcome: Extract<AssessmentOutcome, { kind: 'accept' }>): Ticket {`
- File: src/executor/dsh.ts | Line: 264 | Content: `  start(ticket: Ticket, assignment: Assignment): void {`
- File: src/executor/dsh.ts | Line: 268 | Content: `  deliver(ticket: Ticket, _assignment: Assignment): void { this.host.effects.enqueue('delivery', ticket.id, { ticketId: ticket.id }) }`
- File: src/executor/dsh.ts | Line: 404 | Content: `  activeCount(): number { return this.host.store.tickets.open().filter(ticket => this.running(ticket)).length }`
- File: src/executor/dsh.ts | Line: 477 | Content: `  install(): void {`
- File: src/executor/dsh.ts | Line: 524 | Content: `  resume(): void {`
- File: src/executor/dsh.ts | Line: 59 | Content: `export interface ExecutorHost {`

### Dependencies

deps_out (checklist): app, core, infra, root. Concrete imports in the
three examples: `../app/effects.ts` (Later — dsh.ts:15),
`../core/index.ts` (key, Ticket/Assignment/AssessmentOutcome types —
dsh.ts:7-9), `../deployment.ts` (Machine — dsh.ts:10, root s07),
`../policy.ts` (Settings — dsh.ts:12, root s07), `../app/store.ts`
(Store — dsh.ts:13), `../infra/environment.ts` (runAsWorker/
verifyDirectory — dsh.ts:11); external packages: `@deepseek-ai/cordis`
(Context — dsh.ts:2), `@deepseek-ai/dsh-agent` (Agent — dsh.ts:4),
`node:fs/promises` + `node:path` (dsh.ts:5-6).

### Build

SKIPPED — the mining sandbox has no node/pnpm (header). Real scripts:
`pnpm typecheck && pnpm test` (vitest) (File: package.json | Line: 49-50).

---

## Coverage and honesty notes

- 21/21 use cases carry code examples that use only real APIs — each API
  in each example was located by grep on the pinned clone before being
  referenced (0 unlocatable APIs).
- Evidence blocks are verbatim from the clone at pin `8c32a9dc…`; each
  evidence line backs exactly one API used in the example above it.
- All build commands are SKIPPED honestly — the mining sandbox is
  git-only; the commands quoted are the repository's real
  `package.json` scripts, and no build/test output is fabricated.
