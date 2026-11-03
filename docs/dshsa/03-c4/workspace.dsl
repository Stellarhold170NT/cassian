// workspace.dsl — Structurizr DSL, C4 L1/L2/L3 for the dsh-superagent subject
// Repo: deepseek-ai/dsh-superagent-prototype @ pin 8c32a9dc5d72c033816c6a8110b37f40cf94fba4 (branch main)
// validate: SKIPPED — no structurizr-cli/java in the mining sandbox; hand-checked against the DSL grammar. Mermaid fallback: diagrams.mmd (same directory)
// Every element and relationship carries a `// evidence:` line with a path verified on the clone at the pin.

workspace {
  model {

    // ───────────────────────── L1 — SYSTEM CONTEXT ─────────────────────────

    operator = person "Operator" "Team member who deploys the bundle, reviews what needs a person, and edits settings/policy in the web panel"
    // evidence: README.md:7 — "A web panel shows what needs a person."
    // evidence: README.md:9 — "acts only when asked or when a rule the team wrote allows it"
    // evidence: docs/006-deployment.md (listed README.md:29) — deployment/configuration owned by the operator

    requester = person "Requester" "GitHub or Feishu user allowed by policy who asks the agent for work by mentioning it (issues, comments, chat messages)"
    // evidence: src/sources/github.ts:74 — "GitHub accounts that may originate work"
    // evidence: src/sources/github.ts:79 — "An account on the list mentions the agent's account in an Issue or a comment."
    // evidence: src/sources/feishu.ts:35 — "Receives messages to the bot in these chats and direct messages"

    dsh = softwareSystem "dsh-superagent" "Proactive coding agent for one GitHub repository, packaged as a DSH bundle: listens to GitHub (optionally Feishu), evaluates requests under a Policy, turns authorized ones into Tickets, executes each in its own DSH Session"
    // evidence: package.json:7 — description (verbatim above); name "dsh-superagent", version 0.1.0 name `package.json:2`, version `package.json:5`
    // evidence: README.md:3 — "Research prototype for reference only, not an official DeepSeek product."

    github = softwareSystem "GitHub" "External code-hosting platform: repository notifications, issues/PR discussions, CI status; reached through the agent's `gh` CLI account"
    // evidence: src/sources/github.ts:41 — "The agent's GitHub accounts; receives notifications to it in the repository, discussion on subscribed Issues and PRs, CI changes, and PR merge or close."
    // evidence: src/deployment.ts:99 — probe([cli, 'api', 'repos/<remote>', ...]) verifies repo + push access
    // evidence: src/infra/commands.ts:76 — async gh<T>(args) runs the agent's GitHub CLI

    feishu = softwareSystem "Feishu" "External messaging platform: bot chats and direct messages; reached through the bot's `lark-cli` configuration"
    // evidence: src/sources/feishu.ts:35 — "Receives messages to the bot in these chats and direct messages, recovers chat history and polls subscribed Threads."
    // evidence: src/sources/feishu.ts:120 — "The Feishu bot; lark-cli acts as it"
    // evidence: src/deployment.ts:111-126 — resolveFeishuBot verifies the CLI is a strict-mode bot

    dshPlatform = softwareSystem "DSH platform (DeepSeek Harness)" "Host runtime the bundle plugs into: Cordis context, orchestrator/worker agent sessions, web client, LLM service, subprocess service"
    // evidence: src/index.ts:8 — inject = ['agents','sessionController','sessionPersistence','workspaceRegistry','permissionPresets','tools','systemPrompt','skills','webServer','llm','subprocess']
    // evidence: src/index.ts:10 — export async function apply(ctx, config) mounts the Runtime
    // evidence: package.json:53 — engines: { node: "^22.19.0 || >=24.0.0", dsh: "^0.2.1-alpha.2" }

    operator -> dsh "Reviews what needs a person, edits settings/policy/prompts through the management panel" "HTTPS (same-origin panel)"
    // evidence: src/client/api.ts:33-37 — fetch(`/orchestrator/api/${path}`) with x-orchestrator-request header
    // evidence: src/app/http.ts:1 — "Loopback-only management HTTP routes with same-origin enforcement for the web panel."

    requester -> dsh "Sends work requests that arrive as GitHub issues/comments/CI events or Feishu messages (relayed by the platforms)"
    // evidence: src/sources/github.ts:38-41 — githubKind observes issues, pulls, comments, CI
    // evidence: src/sources/feishu.ts:35 — messages to the bot in chats and direct messages

    dsh -> github "Reads notifications, subscribed discussions and CI; replies with comments and pull requests via gh"
    // evidence: src/sources/github.ts:41 (received events), src/infra/commands.ts:76 (gh wrapper)
    // evidence: src/sources/github.ts:95 — DSH_SUPERAGENT_GITHUB_ACCOUNT: "gh is signed in to it; use gh for every GitHub operation except auto-merge"

    dsh -> feishu "Reads bot messages and thread history; sends replies via lark-cli"
    // evidence: src/sources/feishu.ts:35, src/sources/feishu.ts:120
    // evidence: src/infra/commands.ts:1 — "Subprocess wrapper for running gh, lark-cli, and git commands under the deployment's configured accounts."

    dsh -> dshPlatform "Runs as a plugin inside the DSH host; orchestrator + worker agent sessions; model calls through the llm service"
    // evidence: src/index.ts:8-10 (inject + apply)
    // evidence: src/executor/dsh.ts:23-24 — worker session id is `worker-<ticketId>`
    // evidence: src/app/sessions.ts:88-93 — "Creates and decorates orchestrator and worker DSH `Agent` sessions..."
    // evidence: src/app/role-models.ts:9 — ctx.llm.resolveCallConfig(...)

    // ───────────────────────── L2 — CONTAINERS ─────────────────────────
    // Container set = the module map (m01–m07) + the SQLite state store. LOC from the fresh census at the pin.

    hostShell = dsh.container "Host plugin shell" "Plugin entry that mounts Runtime, verifies deployment (gh CLI, repo, Feishu bot), and owns policy/settings schema + shared utilities (admission, LIMITS, KV, navigation, SetupError) [m07, 8 files / 544 LOC]" "TypeScript (Node, Cordis plugin)"
    // evidence: src/index.ts:10 — apply(ctx, config) mounts Runtime (via `new Runtime(ctx, machine, restart)` at src/index.ts:21)
    // evidence: src/deployment.ts:87 — resolveDeployment: "Verify the agent's GitHub CLI identity and push access to the configured repository."
    // evidence: src/deployment.ts:114 — resolveFeishuBot
    // evidence: src/policy.ts:99-105 — SettingsSchema (zod); src/policy.ts:167 — settingsPolicy builds the active Policy
    // stats: 8 files / 544 LOC — module map, item m07 (census at the pin)

    app = dsh.container "Orchestration app (Runtime)" "Server-side composition root: Store, Sessions, MasterAssessor, Outbox/Effects, prompts/settings, loopback HTTP + view projections for the panel [m01, 38 files / 5292 LOC]" "TypeScript (Node, SQLite via node:sqlite)"
    // evidence: src/app/runtime.ts:59 — "export class Runtime extends Service implements SourceHost"
    // evidence: src/app/runtime.ts:55 — "Composition root of dsh-superagent that connects Store, Setup, Engine, SourceRegistry, Effects, Outbox, Passes, Sessions, Settings, Prompts, DshExecutor, and MasterAssessor."
    // evidence: src/app/http.ts:1 — loopback-only management HTTP routes
    // stats: 38 files / 5292 LOC — module map, item m01

    core = dsh.container "Domain core (Engine)" "Standalone domain engine: model + ports (Policy/Assessor/Executor/Outbox/Repositories) and the Engine as the single transactional entry point coordinating intake → evals → assignments → replies [m03, 15 files / 2088 LOC]" "TypeScript (pure domain, no runtime deps beyond node:crypto)"
    // evidence: src/core/engine.ts:20-24 — "Single transactional entry point for mutating Triggers, Threads, Decisions, Tickets, and Assignments."
    // evidence: src/core/ports.ts:1 — "Ports the core depends on. Sources, policies, assessors, executors, and channels are project-specific."
    // evidence: src/core/ports.ts:17,49,59 — interfaces Policy, Assessor, Executor
    // stats: 15 files / 2088 LOC — module map, item m03; sole external dep node:crypto (src/core/ids.ts:2)

    sources = dsh.container "Source plugins (GitHub/Feishu watchers)" "Two pluggable SourceKind plugins with polling loops + contract layer (SourceKind, SourceRegistry, SourceHost); normalize platform events into Triggers and deliver replies [m06, 16 files / 2059 LOC]" "TypeScript (Cordis plugin entries, polling loops)"
    // evidence: src/sources/github.ts:38 — "export const githubKind: SourceKind<GithubConfig> = {"
    // evidence: src/sources/github.ts:110-122 — plugin entry name 'dsh-superagent-github', apply registers githubKind and starts watch(source, signal)
    // evidence: src/sources/feishu.ts:31 — "export const feishuKind: SourceKind<FeishuConfig> = {"
    // evidence: src/sources/feishu.ts:130-139 — plugin entry name 'dsh-superagent-feishu', apply registers feishuKind and starts runFeishu(...)
    // evidence: src/sources/kind.ts:85 — "export interface SourceKind<C extends Record<string, unknown> ...>"
    // evidence: src/sources/registry.ts:13 — "export class SourceRegistry implements SourceScope"
    // stats: 16 files / 2059 LOC — module map, item m06

    executor = dsh.container "DSH executor" "Runs each ticket Assignment in a persistent per-ticket DSH worker session (`worker-<ticketId>`) with an isolated workspace; WorkerSlots caps concurrency; reports transitions back to the Engine [m04, 2 files / 838 LOC]" "TypeScript (Node, DSH agent sessions)"
    // evidence: src/executor/dsh.ts:207 — "export class DshExecutor implements Executor"
    // evidence: src/executor/dsh.ts:171 — "export class WorkerSlots"
    // evidence: src/executor/dsh.ts:23-24 — workerSessionId = `worker-<ticketId>`
    // stats: 2 files / 838 LOC — module map, item m04

    infra = dsh.container "Process infrastructure" "Shared process infrastructure: Commands subprocess wrapper (gh/lark-cli/git + CliError), worker environment shim (worker-bin/gitconfig), HealthBoard registry [m05, 5 files / 347 LOC]" "TypeScript (Node child_process)"
    // evidence: src/infra/commands.ts:1 — "Subprocess wrapper for running gh, lark-cli, and git commands under the deployment's configured accounts."
    // evidence: src/infra/commands.ts:59 — "export class Commands"
    // evidence: src/executor/dsh.ts:11 — runAsWorker, verifyDirectory imported from ../infra/environment.ts
    // stats: 5 files / 347 LOC — module map, item m05

    panel = dsh.container "Web management panel" "Browser-side React panel injected into the DSH web client (main slot + sidebar icon): 5 tab views, settings/prompts/deployment forms, same-origin REST client, zh/en dictionaries [m02, 26 ts/tsx files / 4037 LOC + client.css 382 lines]" "TypeScript / React 18 (browser bundle via tsdown, cjs)"
    // evidence: src/client/index.tsx:50-57 — apply registers dictionaries, panel slot 'main', 'sidebar.panellist', 'plugins.row.config'
    // evidence: src/client/index.tsx:48 — inject = ['slots','locale','sessions','uiWorkspace']
    // evidence: src/client/api.ts:33-37 — same-origin fetch to /orchestrator/api/
    // stats: 26 files / 4037 LOC (client.css excluded from ts census) — module map, item m02

    db = dsh.container "State database (SQLite)" "Single SQLite file in the state directory: domain aggregates, KV state, settings history, channel outbox; generated columns + partial indexes for active working sets" "SQLite (node:sqlite DatabaseSync)"
    // evidence: src/app/store.ts:1 — "SQLite persistence for domain aggregates, key-value state, settings history, and the channel outbox."
    // evidence: src/app/store.ts:2 — import { DatabaseSync } from 'node:sqlite'
    // evidence: src/app/store.ts:51 — "export class Store implements Repositories {"
    // evidence: src/app/runtime.ts:57 — "Locks the state directory before opening SQLite so concurrent processes cannot corrupt or double-migrate state."

    hostShell -> app "Mounts Runtime on plugin activation and passes DeploymentConfig + restart callback"
    // evidence: src/index.ts:4 — import { Runtime } from './app/runtime.ts'
    // evidence: src/index.ts:21 — const runtime = new Runtime(ctx, machine, restart)

    hostShell -> core "Re-exports the core API as the package surface (index entry)"
    // evidence: src/index.ts:27 — export * from './core/index.ts'

    app -> core "Drives the Engine and implements its ports (Repositories via Store, Assessor via MasterAssessor)"
    // evidence: src/app/runtime.ts:16 — import { Engine, ... } from '../core/index.ts'
    // evidence: src/app/store.ts:51 — class Store implements Repositories
    // evidence: src/app/assessment.ts:89 — class MasterAssessor implements Assessor

    app -> sources "Creates the SourceRegistry and exposes the SourceHost service to source plugins"
    // evidence: src/app/runtime.ts:18 — import { SourceRegistry } from '../sources/registry.ts'
    // evidence: src/app/runtime.ts:51 — declare module '@deepseek-ai/cordis' { interface Context { orchestrator: SourceHost } }
    // evidence: src/app/runtime.ts:59 — class Runtime extends Service implements SourceHost

    app -> executor "Constructs DshExecutor as the Engine's Executor implementation"
    // evidence: src/app/runtime.ts:23 — import { DshExecutor, ... } from '../executor/dsh.ts'
    // evidence: src/executor/dsh.ts:207 — class DshExecutor implements Executor

    app -> infra "Constructs Commands and the HealthBoard"
    // evidence: src/app/runtime.ts:19 — import { Commands } from '../infra/commands.ts'
    // evidence: src/app/runtime.ts:37 — import { HealthBoard } from '../infra/health.ts'

    app -> db "Reads/writes domain aggregates, KV state, settings history and the outbox through Store; migrates schema on open"
    // evidence: src/app/store.ts:1,51
    // evidence: src/app/store.ts:9 — OLDEST_SCHEMA, SCHEMA_VERSION, migrateTo11 from ./migration.ts

    executor -> core "Implements the Executor port and reports assignment transitions back to the Engine"
    // evidence: src/executor/dsh.ts:7-9 — imports from '../core/index.ts' (EngineForExecutor, Executor, ... types)
    // evidence: src/executor/dsh.ts:207 — class DshExecutor implements Executor

    executor -> infra "Prepares the worker environment (worker-bin shim, verified directories) for worker sessions"
    // evidence: src/executor/dsh.ts:11 — import { runAsWorker, verifyDirectory } from '../infra/environment.ts'

    executor -> dshPlatform "Runs assignments in persistent per-ticket worker sessions `worker-<ticketId>` in the DSH host"
    // evidence: src/executor/dsh.ts:23-24 — workerSessionId = `worker-${ticketId}`
    // evidence: src/executor/dsh.ts:202-204 — "Executes ticket assignments in persistent per-ticket DSH worker sessions and isolated workspace directories."

    sources -> core "Feeds normalized Triggers into Engine intake and answers SourceScope for admission"
    // evidence: src/sources/registry.ts:2 — import type { ChannelRef, OutboundMessage, ScopeResult, SourceScope, Trigger } from '../core/index.ts'
    // evidence: src/sources/registry.ts:13 — class SourceRegistry implements SourceScope

    sources -> infra "Calls gh / lark-cli / git through Commands with sanitized CliError handling"
    // evidence: src/sources/github.ts:6 — import { CliError, validItems, type Tally } from '../infra/commands.ts' (cross-checked in both directions)

    // evidence: src/infra/commands.ts:1,59 — Commands wrapper

    sources -> github "Polls repository notifications, subscribed issues/PR discussions and CI; sends comments/PRs via gh"
    // evidence: src/sources/github.ts:38-41 (kind), src/sources/github.ts:118 — watch(source, controller.signal) polling loop
    // evidence: src/sources/github.ts:44-48 — repository + cli + pollSeconds config fields

    sources -> feishu "Polls bot chats/direct messages and thread history; sends replies via lark-cli"
    // evidence: src/sources/feishu.ts:31-38 (kind), src/sources/feishu.ts:136 — runFeishu(sourceContext(...), controller.signal)

    panel -> app "Same-origin REST against the loopback management API (overview, sources, threads, tickets, settings, prompts, deployment)"
    // evidence: src/client/api.ts:3 — import type { Api, ApiRequest, ApiResponse } from '../app/api.ts'
    // evidence: src/client/api.ts:37 — fetch(`/orchestrator/api/${path}`)
    // evidence: src/app/http.ts:1 — loopback-only management routes with same-origin enforcement

    panel -> core "Renders localized user errors from core error codes and ticket stages"
    // evidence: src/client/api.ts:4 — import { USER_ERRORS, type UserErrorCode } from '../core/errors.ts'
    // evidence: src/client/api.ts:5 — import type { TicketStage } from '../core/stage.ts'

    panel -> sources "Renders source health text in the overview"
    // evidence: src/client/locales.ts:6 — import { HEALTH_TEXT } from '../sources/host.ts' (cross-checked in both directions)

    panel -> hostShell "Session navigation and read-only deployment facts from the root modules"
    // evidence: src/client/index.tsx:13 — import { openKnownSession, SessionNavigationError } from '../navigation.ts' (cross-checked in both directions)

    operator -> panel "Uses the panel (sidebar entry) inside the DSH web client"
    // evidence: src/client/index.tsx:53-55 — panel registered in slot 'main' + sidebar.panellist entry

    // ───────────────────────── L3 — COMPONENTS (deep dive: app, core, sources) ─────────────────────────

    // — Container: Orchestration app (Runtime) —
    runtime = app.component "Runtime" "Composition root and lifecycle manager; wires Store, Setup, Engine, SourceRegistry, Effects, Outbox, Passes, Sessions, Settings, Prompts, DshExecutor, MasterAssessor; exposes SourceHost" "TypeScript class extends Service"
    // evidence: src/app/runtime.ts:55-59 — doc + "export class Runtime extends Service implements SourceHost"
    // evidence: src/app/runtime.ts:60-72 — readonly fields store/setup/prompts/effects/sources/commands/sessions/settings/executor/assessor/outbox/engine/passes

    store = app.component "Store" "SQLite persistence for domain aggregates, KV state, settings history and the channel outbox; implements the Repositories port; schema migration on open" "TypeScript + node:sqlite"
    // evidence: src/app/store.ts:1 — module doc
    // evidence: src/app/store.ts:51 — "export class Store implements Repositories {"

    sessions = app.component "Sessions" "Creates and decorates orchestrator + worker DSH Agent sessions (role models, prompt sections, skills, restricted tools); delivers deduplicated relay/notice messages; tracks model-budget retries" "TypeScript"
    // evidence: src/app/sessions.ts:88-93 — class doc + "export class Sessions {"
    // evidence: src/app/sessions.ts:104-105 — effects.handle('relay'/'notice', ..., { ordered: true })

    assessor = app.component "MasterAssessor" "Semantic judgement hub implementing the Assessor port: queues evaluations per evalId, returns accept/ignore/stop decisions to the Engine" "TypeScript"
    // evidence: src/app/assessment.ts:89 — "export class MasterAssessor implements Assessor {"
    // evidence: src/core/ports.ts:48-53 — Assessor port contract ("Semantic judgement. `request` queues the assessment, idempotently per `evalId`")

    outbox = app.component "Outbox" "Outbound-message queue implementing the OutboxPort: receipts tracked pending/sent/dropped with channel-gone and channel-ignored drop reasons" "TypeScript"
    // evidence: src/app/outbox.ts:22 — "export class Outbox implements OutboxPort {"
    // evidence: src/app/store.ts:17-18 — "Outbound message receipt tracked in the outbox from the moment it is queued (`pending`, `sent`, or `dropped`)"

    effects = app.component "Effects" "Queued side-effect dispatcher (launch, deliver, relay, notice, policy-changed, resumed, note) with ordered handlers and Later-based deferral" "TypeScript"
    // evidence: src/app/effects.ts:46 — "export class Effects {"
    // evidence: src/app/effects.ts:11 — "export interface EffectPayloads {"
    // evidence: src/executor/dsh.ts:14 — import { Later, type Effects } from '../app/effects.ts'
    // evidence: src/executor/dsh.ts:160-163 — effect kinds policy-changed / resumed / note / text

    http = app.component "HttpRoutes" "Loopback-only management HTTP routes with same-origin enforcement; serves the panel API and view projections" "TypeScript (node:http, zod-validated)"
    // evidence: src/app/http.ts:1 — module doc
    // evidence: src/app/http.ts:31-40 — HttpHost interface (store, sources, prompts, sessions, settings, engine, executor...)
    // evidence: src/app/runtime.ts:32 — import { registerHttp, type HttpHost } from './http.ts'

    views = app.component "Views" "Read projections for the panel: overview, settings, sources status, thread list/detail + search, ticket list/detail + executor load" "TypeScript"
    // evidence: src/app/http.ts:25-29 — imports of views/overview, views/settings, views/sources, views/threads, views/tickets

    runtime -> store "Wires and owns the SQLite Store"
    // evidence: src/app/runtime.ts:27 — import { Store } from './store.ts'; src/app/runtime.ts:60 — readonly store: Store
    runtime -> sessions "Wires Sessions; ordered relay/notice delivery reaches the main Session through it"
    // evidence: src/app/runtime.ts:43 — import { Sessions } from './sessions.ts'; src/app/sessions.ts:104-105
    runtime -> assessor "Wires MasterAssessor as the Engine's Assessor"
    // evidence: src/app/runtime.ts:25 — import { MasterAssessor } from './assessment.ts'; src/app/runtime.ts:69 — readonly assessor: MasterAssessor
    runtime -> outbox "Wires the Outbox for queued outbound replies"
    // evidence: src/app/runtime.ts:38 — import { Outbox } from './outbox.ts'; src/app/runtime.ts:70 — readonly outbox: Outbox
    runtime -> effects "Wires the Effects dispatcher used by executor and sessions"
    // evidence: src/app/runtime.ts:30 — import { Effects } from './effects.ts'; src/app/runtime.ts:63 — readonly effects: Effects
    runtime -> http "Registers the loopback management routes at startup"
    // evidence: src/app/runtime.ts:32 — import { registerHttp, type HttpHost } from './http.ts'; src/app/runtime.ts:56 — "coordinates startup, setup checks, HTTP route registration, and graceful shutdown"
    runtime -> views "Supplies view projections to the HTTP routes"
    // evidence: src/app/runtime.ts:28 — import { evalsHealth } from './views/overview.ts'
    // evidence: src/app/http.ts:25-29 — views imported by the routes
    http -> store "Reads store-backed views and state for panel queries"
    // evidence: src/app/http.ts:20 — import type { Store } from './store.ts'; src/app/http.ts:32 — HttpHost.store
    http -> sessions "Uses Sessions.status/notify/delivery for panel operations"
    // evidence: src/app/http.ts:37 — readonly sessions: Pick<Sessions, 'status' | 'notify' | 'delivery'>
    effects -> sessions "Ordered relay/notice effects deliver into the main Session"
    // evidence: src/app/sessions.ts:99-105 — constructor registers ordered handlers for 'relay' and 'notice'

    // — Container: Domain core (Engine) —
    engine = core.component "Engine" "Single transactional entry point for mutating Triggers, Threads, Decisions, Tickets, Assignments; coordinates the parts inside repository transactions and queues side effects through ports" "TypeScript class"
    // evidence: src/core/engine.ts:19-24 — class doc + "export class Engine {"
    // evidence: src/core/engine.ts:31-38 — constructor wires repo, Replies, Tickets, Assignments, Evals, Intake

    intake = core.component "Intake" "Receives Triggers from Sources, checks Policy gate + scope, creates or follows threads" "TypeScript extends EnginePart"
    // evidence: src/core/intake.ts:16 — "export class Intake extends EnginePart {"

    evals = core.component "Evals" "Records assessments (accept/ignore/unavailable/stop) returned by the Assessor" "TypeScript extends EnginePart"
    // evidence: src/core/evals.ts:27 — "export class Evals extends EnginePart {"

    tickets = core.component "Tickets" "Ticket lifecycle from accept to end, subscription/thread binding, mandate revalidation" "TypeScript extends EnginePart"
    // evidence: src/core/tickets.ts:29 — "export class Tickets extends EnginePart {"

    assignments = core.component "Assignments" "Tracks worker assignments and WorkerReport transitions reported by the Executor" "TypeScript extends EnginePart"
    // evidence: src/core/assignments.ts:30 — "export class Assignments extends EnginePart {"
    // evidence: src/core/assignments.ts:11 — "export interface WorkerReport {"

    replies = core.component "Replies" "Outbound replies to the originating conversation; status tracked in the outbox" "TypeScript extends EnginePart"
    // evidence: src/core/replies.ts:26 — "export class Replies extends EnginePart {"
    // evidence: src/core/replies.ts:18 — "export interface Reply { id: string; status: ReplyStatus; reused: boolean }"

    modelPorts = core.component "Model + Ports" "Domain model (Trigger, Thread, Ticket, Assignment, Mandate, Decision...) and role interfaces the outside implements (Policy, Assessor, Executor, Repositories, OutboxPort)" "TypeScript types/interfaces"
    // evidence: src/core/model.ts:23 — "export interface Trigger {"
    // evidence: src/core/model.ts:277 — "export interface Ticket {"
    // evidence: src/core/ports.ts:17 — "export interface Policy {"
    // evidence: src/core/ports.ts:49 — "export interface Assessor {"
    // evidence: src/core/ports.ts:59 — "export interface Executor {"

    engine -> intake "Coordinates intake of incoming triggers"
    // evidence: src/core/engine.ts:37 — this.intake = new Intake(options, this.tickets)
    engine -> evals "Coordinates assessment outcomes"
    // evidence: src/core/engine.ts:36 — this.evals = new Evals(options, this.tickets)
    engine -> tickets "Coordinates ticket lifecycle"
    // evidence: src/core/engine.ts:34 — this.tickets = new Tickets(options, this.replies)
    engine -> assignments "Coordinates assignment execution"
    // evidence: src/core/engine.ts:35 — this.assignments = new Assignments(options, this.tickets, this.replies)
    engine -> replies "Coordinates replies"
    // evidence: src/core/engine.ts:33 — this.replies = new Replies(options)
    intake -> modelPorts "Typed on the shared domain model (Trigger/Thread)"
    // evidence: src/core/model.ts:23 — Trigger; src/core/engine.ts:4 — imports Trigger/ThreadRef from './model.ts'
    tickets -> modelPorts "Typed on Ticket/Mandate"
    // evidence: src/core/model.ts:126 — Mandate; src/core/model.ts:277 — Ticket

    // — Container: Source plugins (GitHub/Feishu watchers) —
    kindContract = sources.component "SourceKind contract" "Pluggable kind descriptor: schema, fields, scope(), channel send/link, threadContext, health entries, policy rows" "TypeScript interface"
    // evidence: src/sources/kind.ts:85 — "export interface SourceKind<C extends Record<string, unknown> = Record<string, unknown>> {"
    // evidence: src/sources/kind.ts:1-4 — image() contract doc above it

    registry = sources.component "SourceRegistry" "Registers SourceKind plugins + configured instances, implements the Engine's SourceScope, claims health entries, mediates channels/links/env/thread-context" "TypeScript class"
    // evidence: src/sources/registry.ts:1,13 — module doc + "export class SourceRegistry implements SourceScope"
    // evidence: src/sources/registry.ts:20 — register<C>(kind): disposer

    githubPlugin = sources.component "GitHub source plugin" "Cordis plugin entry 'dsh-superagent-github': registers githubKind, runs the polling watch loop, observes issues/PRs/comments/CI, sends replies via gh" "TypeScript (Cordis plugin entry)"
    // evidence: src/sources/github.ts:38 — "export const githubKind: SourceKind<GithubConfig> = {"
    // evidence: src/sources/github.ts:110-113 — export const name = 'dsh-superagent-github'; apply registers githubKind
    // evidence: src/sources/github.ts:118 — const running = watch(source, controller.signal)

    feishuPlugin = sources.component "Feishu source plugin" "Cordis plugin entry 'dsh-superagent-feishu': registers feishuKind, runs the Feishu loop over chats/direct messages, sends replies via lark-cli" "TypeScript (Cordis plugin entry)"
    // evidence: src/sources/feishu.ts:31 — "export const feishuKind: SourceKind<FeishuConfig> = {"
    // evidence: src/sources/feishu.ts:130-133 — export const name = 'dsh-superagent-feishu'; apply registers feishuKind
    // evidence: src/sources/feishu.ts:136 — const running = runFeishu(sourceContext(ctx.orchestrator, feishuKind), controller.signal)

    githubPlugin -> registry "Registers githubKind with the SourceRegistry via the orchestrator SourceHost"
    // evidence: src/sources/github.ts:113 — ctx.effect(() => ctx.orchestrator.sources.register(githubKind), 'github: source kind')
    feishuPlugin -> registry "Registers feishuKind with the SourceRegistry via the orchestrator SourceHost"
    // evidence: src/sources/feishu.ts:133 — ctx.effect(() => ctx.orchestrator.sources.register(feishuKind), 'feishu: source kind')
    registry -> kindContract "Manages registered SourceKind instances"
    // evidence: src/sources/registry.ts:6 — import type { ... SourceKind ... } from './kind.ts'
    // evidence: src/sources/registry.ts:20 — register<C extends Record<string, unknown>>(kind: SourceKind<C>)
    githubPlugin -> kindContract "Implements the SourceKind descriptor"
    // evidence: src/sources/github.ts:38 — githubKind: SourceKind<GithubConfig>
    feishuPlugin -> kindContract "Implements the SourceKind descriptor"
    // evidence: src/sources/feishu.ts:31 — feishuKind: SourceKind<FeishuConfig>

  }

  views {

    systemContext dsh "L1-SystemContext" "dsh-superagent system context" {
      include *
      autolayout lr
    }

    container dsh "L2-Containers" "dsh-superagent containers (module map + SQLite store)" {
      include *
      autolayout tb
    }

    component app "L3-App" "Components of the Orchestration app (Runtime)" {
      include *
      autolayout tb
    }

    component core "L3-Core" "Components of the Domain core (Engine)" {
      include *
      autolayout tb
    }

    component sources "L3-Sources" "Components of the Source plugins container" {
      include *
      autolayout tb
    }

    styles {
      element "Person" {
        shape Person
      }
      element "Software System" {
        background #438dd5
        color #ffffff
      }
      element "Container" {
        background #438dd5
        color #ffffff
      }
      element "Component" {
        background #85bbf0
        color #000000
      }
    }

  }
}
