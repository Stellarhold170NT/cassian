---
subject: deepseek-ai/dsh-superagent-prototype
measured_at: 8c32a9dc5d72c033816c6a8110b37f40cf94fba4
status: final
---

# Flows — top-3 runtime flows by score

- PIN: `8c32a9dc5d72c033816c6a8110b37f40cf94fba4` — a shallow clone in the
  mining sandbox matched the pin exactly (`git rev-list --count HEAD` → 1;
  216 files in the tree). Every `file:line` below was measured on this
  pinned tree.
- **Churn-window disclosure (required by the method):** the churn command
  runs on a `--depth 100` clone, but the repository has exactly **1
  commit** (a research prototype pushed once) → the effective churn window
  is 1 commit, every file has count = 1, and churn cannot distinguish
  "hot" modules. The churn numbers below are still taken from the method's
  command (aggregated per module); their only meaning is "files touched
  in the window" = the module's file count.
- Inputs: `01-cartography.md` (pin + census), `02-module-map.md`
  (7-item JSON, 22-edge dependency matrix).

## 1. How the top-3 were computed (numbers, verbatim method)

### 1a. Churn command + real output

Command:

```
git log --format= --name-only | sort | uniq -c | sort -rn | head -20
```

Output (every line count=1 — 216 files, window of 1 commit):

```
      1 vitest.config.ts
      1 tsdown.config.ts
      1 tsconfig.json
      1 tests/views.spec.ts
      1 tests/tools.spec.ts
      ... (every line count=1 — 216 files, 1-commit window)
```

Cross-check: `git log --format= --name-only | sort -u | wc -l` → **216**;
`git rev-list --count HEAD` → **1**.

Churn per module (`git log --format= --name-only | grep '^src/' | cut -d/ -f1-2 | sort | uniq -c | sort -rn`):

```
     38 src/app        5 src/infra       1 src/setup.ts
     27 src/client     2 src/executor    1 src/policy.ts
     16 src/sources    1 src/setup.ts    1 src/navigation.ts
     15 src/core       1 src/policy.ts   1 src/limits.ts
                       1 src/kv.ts       1 src/index.ts
                       1 src/deployment.ts  1 src/admission.ts
```

(= the 8 root `src` files: setup, policy, navigation, limits, kv, index,
deployment, admission — matching m07's 8-file census. `src/client` counts
27 because it includes `client.css`, which is not ts/tsx — the m02 census
is 26 ts/tsx files.)

### 1b. Fan-in/out from the module map (22-edge matrix)

Fan per module = total **boundary import lines** incident (in + out),
computed from the 22 cross-checked edges:

| module | in-lines | out-lines | FAN (in+out) |
|---|---|---|---|
| m01 src/app | 15 (6+6+3) | 128 (25+9+18+38+38) | **143** |
| m02 src/client | 0 | 26 (6+4+6+10) | **26** |
| m03 src/core | 46 (25+4+1+13+3) | 0 | **46** |
| m04 src/executor | 9 | 11 (6+1+2+2) | **20** |
| m05 src/infra | 42 (18+2+18+4) | 4 (1+3) | **46** |
| m06 src/sources | 46 (38+6+1+1) | 42 (13+18+11) | **88** |
| m07 src root | 64 (38+10+2+3+11) | 11 (3+3+4+1) | **75** |

Total check: Σ edge-weights = 222 lines; Σ fan = 444 = 2 × 222 ✓ (each
edge counted at both ends; the executor→core edge is 1 file, weighted 1).

### 1c. Merged score formula (disclosed — the method does not prescribe one; this matches the convention used for earlier subjects)

`Score(flow) = Σ FAN(module) + Σ churn_files(module)` over the set of
modules the flow passes through. Churn files = files touched in the churn
window (1 commit → equals the module's file count, from output 1a).

### 1d. Scoring of 6 candidate flows → top-3

| # | Flow | Module set | Σ FAN | Σ churn | **Score** |
|---|---|---|---|---|---|
| F1 | External trigger (GitHub/Feishu) → Engine intake/evals → ticket → DSH worker session → reply | m06, m03, m01, m04, m07, m05 | 88+46+143+20+75+46 = **418** | 16+15+38+2+8+5 = **84** | **502** |
| F4* | Boot/mount Runtime (apply → Runtime → store/migration/sources/executor) | {m07, m01, m03, m04, m05, m06} — same set as F1 | 418 | 84 | **502** (tie with F1) |
| F5* | Feishu trigger → reply (sibling of GitHub) | {m06, m05, m03, m01, m04, m07} — same set as F1 | 418 | 84 | **502** (tie with F1) |
| F2 | Web panel browser ↔ loopback API ↔ Store/views | m02, m01, m03, m07 | 26+143+46+75 = **290** | 27+38+15+8 = **88** | **378** |
| F3 | Worker-session turn lifecycle (executor ↔ sessions ↔ events ↔ retry) | m04, m01, m03, m05 | 20+143+46+46 = **255** | 2+38+15+5 = **60** | **315** |
| F6 | Background jobs/subagents teardown after a turn | m04, m03, m01 | 20+46+143 = **209** | 2+15+38 = **55** | **264** |

\* F4/F5 tie F1 exactly because they pass the same module set at module
resolution — the resolution limit of the dependency data. **F1** is
chosen as the representative (the continuously repeated runtime path —
hot path; F4 is the one-time setup variant; F5 is a sibling instance of
the same flow frame, noted in the F1 diagram).

**Top-3 by score: F1 (502) > F2 (378) > F3 (315).**

## 2. Flow F1 — External trigger → Engine → ticket → worker session → reply (score 502)

**Why it is expensive (numbers)**: passes through 6/7 modules (all but
m02); touches 418 boundary import lines (≈ 94% of the system's total 444
fan lines) + 84 churn files; it is the runtime path executed **for every
trigger** (poll every 60s per source — `pollSeconds` default 60,
github.ts:25) and the only end-to-end value flow (a GitHub user sees a
real reply).

```mermaid
sequenceDiagram
    autonumber
    participant GH as GitHub API
    participant GS as github.ts (m06)
    participant EN as Engine (m03)
    participant PS as Passes (m01)
    participant MA as MasterAssessor (m01)
    participant TK as Tickets (m03)
    participant EX as DshExecutor (m04)
    participant SS as Sessions (m01)
    participant OB as Outbox (m01)
    participant GC as github-channel (m06)

    GH->>GS: 1. poll issues/PR/CI (github.ts:179,283-285,430)
    GS->>EN: 2. ctx.receive(trigger) → engine.receive (github.ts:232,241; engine.ts:48)
    PS->>EN: 3. pump → evaluateDue() (passes.ts:67; engine.ts:75-89)
    EN->>MA: 4. evals.due/start → candidate tới assessor (evals.ts:35; assessment.ts:89)
    MA->>EN: 5. decide(triggerId, accept) (engine.ts:100)
    EN->>TK: 6. Tickets.create(mandate, assignment đầu) (tickets.ts:38)
    TK->>EX: 7. executor.start(ticket, assignment) (tickets.ts:54)
    EX->>EX: 8. effect 'launch' + WorkerSlots.reserve (dsh.ts:232,171,192)
    EX->>SS: 9. sessions.ensure(worker-<ticketId>) (dsh.ts:441,24; environment.ts:18-20)
    SS-->>EX: 10. events agent/status, session/event, agent/error (dsh.ts:479-505)
    EX->>EN: 11. assignmentStarted/turnEnded (engine.ts:174-194)
    EN->>OB: 12. reply → Outbox 'reply' effect → sendGithub POST (outbox.ts:24,27,39,48; github-channel.ts:18)
```

**Step → file:line map (traced by reading the real code; each line
grep/sed-verified in the measuring session):**

| Step | File:line | Verbatim content |
|---|---|---|
| 1 | src/sources/github.ts:112-115 | `export function apply(ctx: Context): void { ctx.effect(() => ctx.orchestrator.sources.register(githubKind), 'github: source kind') ... const running = watch(source, controller.signal)` |
| 1 | src/sources/github.ts:283-285 | `await pollRepository(ctx, round)` / `await pollThreads(ctx, signal, round)`; pollRepository @179, pollThreads @430 |
| 2 | src/sources/github.ts:232,241 | `await ctx.receive(pr ? pullTrigger(issue.data, login) : issueTrigger(issue.data, login))`; `if (trigger.text) await ctx.receive(trigger)` |
| 2 | src/sources/host.ts:41-42 | `/** Ingests a trigger into the Engine and schedules the next evaluation pass; callers should await completion before advancing read cursors. */ receive(trigger: Trigger): ReceiveResult \| Promise<ReceiveResult>` |
| 3 | src/app/passes.ts:67 | `this.host.engine.evaluateDue()` (inside `pumpOnce`; the pump is kicked every pass) |
| 3 | src/core/engine.ts:75-89 | `evaluateDue(): void { const policy = this.options.policy() ... this.evals.due(thread, policy) ... this.evals.start(thread.key, policy) }` |
| 4 | src/core/evals.ts:35 | `due(thread: Thread, policy: Policy): void {` — Eval holds the candidate, deadline counted from delivery to the assessor (:47-53) |
| 4 | src/app/assessment.ts:89 | `export class MasterAssessor implements Assessor {` |
| 5 | src/core/engine.ts:100 | `decide(triggerId: string, outcome: Outcome): Decision { return this.repo.atomic(() => this.evals.decide(triggerId, outcome)) }` |
| 6 | src/core/tickets.ts:38 | `create(id: string, decisionId: string, mandate: Mandate, evaluation: ..., outcome: Extract<AssessmentOutcome, { kind: 'accept' }>, at: string): void {` |
| 7 | src/core/tickets.ts:54 | `this.options.executor.start(this.require(id), assignment)` |
| 8 | src/executor/dsh.ts:232 | `host.effects.handle('launch', payload => this.launchQueued(payload), { limit: () => host.paused() ? 0 : this.slots.launches(),` |
| 8 | src/executor/dsh.ts:171,192 | `export class WorkerSlots {` / `reserve(ticketId: string, by: 'launch' \| 'wake' \| 'person'): void {` |
| 9 | src/executor/dsh.ts:24,441 | `export const workerSessionId = (ticketId: string): string => \`worker-${ticketId}\`` / `const agent = await this.host.sessions.ensure(sessionId, workspace, ticket.title, 'worker')` |
| 9 | src/infra/environment.ts:18-20 | `export const WORKER_COMMANDS: readonly string[] = ['gh', 'git', 'lark-cli']` / `workerBin` / `workerGitConfig` |
| 10 | src/executor/dsh.ts:479-505 | `ctx.on('agent/status', ...)` / `ctx.on('agent/inbox/claimed', ...)` / `ctx.on('session/event', ...)` / `ctx.on('agent/error', ...)` |
| 11 | src/core/engine.ts:174-194 | `assignmentStarted(ticketId, assignmentId)` / `inputsDelivered(...)` / `turnEnded(ticketId, assignmentId)` — each wrapped in `this.repo.atomic(...)` |
| 12 | src/app/outbox.ts:22-48 | `export class Outbox implements OutboxPort {` / `host.effects.handle('reply', (_payload, id) => this.deliver(id), { limit: ... retry: [5000, 300_000] })` / `send(message: OutboundMessage): void` / `const result = await sources.send(receipt, commands)` |
| 12 | src/sources/github-channel.ts:18 | `export async function sendGithub(host: Pick<SourceContext, 'commands'>, message: OutboundMessage): Promise<'sent' \| 'gone'> {` — POST comment with an HTML marker against duplicates |

## 3. Flow F2 — Web panel ↔ loopback API ↔ Store (score 378)

**Why it is expensive (numbers)**: touches 290 fan lines (m01 143 + m07
75 + m03 46 + m02 26) + 88 churn files (the most among the top-3, since
m02 27 + m01 38); it is the operator's contact surface — the browser
**polls every 5 seconds** (api.ts:67), and every poll re-runs the whole
read path; every panel write operation (retry/dismiss/requeue/
unsubscribe) also takes exactly this path.

```mermaid
sequenceDiagram
    autonumber
    participant UX as App shell (client/app.tsx, m02)
    participant API as client/api.ts (m02)
    participant HT as app/http.ts loopback (m01)
    participant VW as stateView/views (m01)
    participant ST as Store SQLite (m01)
    participant EN as Engine repos (m03)

    UX->>API: 1. tab route → Pages({route}) (app.tsx:141; route.ts)
    API->>HT: 2. usePoll 5s → fetch /orchestrator/api/... (api.ts:67,37)
    HT->>HT: 3. registerHttp: same-origin + prefix check (http.ts:230,236,75)
    HT->>HT: 4. match route table GET state / GET tickets/:id (http.ts:240,151,156,192)
    HT->>VW: 5. stateView(runtime) / ticketPage (http.ts:105,116)
    VW->>ST: 6. đọc aggregates từ Store (store.ts:51-52)
    HT-->>API: 7. JSON response (StateView)
    API-->>UX: 8. setState → re-render widgets (app.tsx:103-105)
    UX->>HT: 9. POST retry/dismiss → engine.retryTicket/dismiss (http.ts:187,193)
```

**Step → file:line map:**

| Step | File:line | Verbatim content |
|---|---|---|
| 1 | src/client/index.tsx:48-53 | `export function apply(ctx: ClientContext): void { ctx.effect(() => ctx.locale.register(NS, { zh, en }), ...)` ... `ctx.slots.inject('main', () => ctx.slots.register({ name: 'main', key: PANEL_ID, ... }, (props: { t: T }) => <Mounted ctx={ctx} t={props.t} />))` |
| 1 | src/client/app.tsx:141 | `function Pages({ route, openTab, deploymentForm }: { route: Route; openTab: (tab: Tab) => void; deploymentForm: DeploymentForm }) {` |
| 2 | src/client/api.ts:67 | `export function usePoll<T>(load: () => Promise<T>, deps: readonly unknown[], intervalMs = 5000) {` |
| 2 | src/client/api.ts:37 | `response = await fetch(\`/orchestrator/api/${path}\`, { method, ...json, headers: { 'x-orchestrator-request': '1', ...json.headers } })` |
| 3 | src/app/http.ts:230,236 | `export function registerHttp(ctx: Context, runtime: HttpHost): () => void {` ... `if (!url.pathname.startsWith('/orchestrator/api/')) { res.writeHead(404); res.end(); return }` |
| 3 | src/app/http.ts:75 | `export function sameOrigin(req: Pick<IncomingMessage, 'headers'>, port: number): boolean {` (loopback-only + same-origin enforcement — header comment at line 1 of the file) |
| 4 | src/app/http.ts:240 | `const route = match(table, req.method ?? 'GET', url.pathname.slice('/orchestrator/api/'.length).split('/'))` |
| 4 | src/app/http.ts:151,156,192 | `function routes(runtime: HttpHost): Routes {` / `'GET state': () => stateView(runtime),` / `'GET tickets/:id': ({ params }) => ticketPage(runtime, params.id),` |
| 5 | src/app/http.ts:105,116 | `export function stateView(runtime: HttpHost) {` / `function ticketPage(runtime: HttpHost, id: string) {` |
| 6 | src/app/store.ts:51-52 | `export class Store implements Repositories {` / `readonly db: DatabaseSync` (node:sqlite @ :2); the Engine mutates inside `atomic`, views/Outbox read outside (:49 comment) |
| 8 | src/client/app.tsx:103-105 | `const [glossary, setGlossary] = useState(false)` / `const [query, setQuery] = useState('')` / `const [result, setResult] = useState<{ query: string; value: SearchView }>()` |
| 9 | src/app/http.ts:187,193 | `'POST decisions/:id/dismiss': ({ params }) => { runtime.engine.dismiss(params.id); return { dismissed: true } },` / `'POST tickets/:id/retry': ({ params }) => { const id = ticket(params.id); runtime.engine.retryTicket(id); return { retried: true } },` |

## 4. Flow F3 — Worker-session turn lifecycle (score 315)

**Why it is expensive (numbers)**: 255 fan lines + 60 churn files; it is
the inner loop of F1 but measured separately because it runs **many times
per ticket** (every turn + every input delivery + every retry), and it is
where all concurrency risks concentrate (slot limits, paused, retry
backoff, background jobs left after a turn).

```mermaid
sequenceDiagram
    autonumber
    participant TK as Tickets (m03)
    participant EF as Effects queue (m01)
    participant EX as DshExecutor (m04)
    participant WS as WorkerSlots (m04)
    participant SS as Sessions (m01)
    participant AG as DSH worker session
    participant BG as background.ts (m04)
    participant EN as Engine (m03)

    TK->>EF: 1. wake/pending → executor.start (tickets.ts:244,268)
    EF->>EX: 2. handle 'launch'/'delivery', paused→limit 0 (dsh.ts:232-234; effects.ts:46,61)
    EX->>WS: 3. WorkerSlots.reserve (dsh.ts:171,192)
    EX->>EX: 4. launchQueued → prepare workspace (dsh.ts:270)
    EX->>SS: 5. sessions.ensure worker-<ticketId> (dsh.ts:441; sessions.ts:93)
    EX->>SS: 6. sessions.prompt queue/steer input (dsh.ts:342,466)
    AG-->>EX: 7. events agent/status, session/event, agent/error (dsh.ts:479-505)
    EX->>SS: 8. retry transient: 3 lần, backoff 15s (dsh.ts:29-30,571)
    AG->>BG: 9. turn xong → untilQuiet/stopBackground jobs+subagents (background.ts:96,159)
    EX->>EN: 10. turnEnded → assignments.turnEnded → pass kế (engine.ts:193-194; passes.ts:67)
```

**Step → file:line map:**

| Step | File:line | Verbatim content |
|---|---|---|
| 1 | src/core/tickets.ts:244 | `else if (latest?.state === 'pending' && !waitsForPerson(ticket)) this.options.executor.start(ticket, latest)` (same pattern @178, @268, @326) |
| 2 | src/executor/dsh.ts:232-234 | `host.effects.handle('launch', payload => this.launchQueued(payload), { limit: () => host.paused() ? 0 : this.slots.launches(),` ... `// Failed input deliveries are recorded on the ticket itself rather than reported through the 'delivery' effect health entry (quiet: true).` |
| 2 | src/app/effects.ts:46,61 | `export class Effects {` / `enqueue<K extends EffectKind>(kind: K, key: string, payload: EffectPayloads[K]): void {` |
| 3 | src/executor/dsh.ts:171-192 | `export class WorkerSlots {` ... `reserve(ticketId: string, by: 'launch' \| 'wake' \| 'person'): void {` — comment :168-169: "DshExecutor reserves slots synchronously before awaiting launch or wake work so two starts cannot take the last slot, and allows one extra slot beyond the limit for human follow-ups" |
| 4 | src/executor/dsh.ts:270 | `private async launchQueued({ ticketId, assignmentId }: { ticketId: string; assignmentId: string }): Promise<void> {` |
| 5 | src/executor/dsh.ts:441 | `const agent = await this.host.sessions.ensure(sessionId, workspace, ticket.title, 'worker')` |
| 5 | src/app/sessions.ts:93 | `export class Sessions {` |
| 6 | src/executor/dsh.ts:342,466 | `await this.host.sessions.prompt(workerSessionId(ticket.id), input.id, text, 'steer', live)` / `await this.host.sessions.prompt(sessionId, requestId, text, 'queue',` |
| 7 | src/executor/dsh.ts:479-505 | `this.disposers.push(ctx.on('agent/status', ({ agent, status }) => {` ... `ctx.on('session/event', (session, event) => {` ... `ctx.on('agent/error', ({ agent, error }) => {` |
| 8 | src/executor/dsh.ts:29-30 | `/** Maximum transient retry attempts for a launch or worker turn, and the initial backoff before resuming a turn. */ const TRANSIENT_TRIES = 3, TRANSIENT_BACKOFF_MS = 15_000` |
| 8 | src/executor/dsh.ts:571 | `const sent = this.host.sessions.prompt(sessionId, \`retry:${assignmentId}:${tries}\`, text, 'queue')` |
| 9 | src/executor/background.ts:96,159 | `export async function untilQuiet(ctx: Context, agent: Agent, signal: AbortSignal, except?: ReadonlySet<string>): Promise<boolean> {` / `export async function stopBackground(ctx: Context, sessionId: string, reason: string, keepInbox = false): Promise<void> {` |
| 10 | src/core/engine.ts:193-194 | `turnEnded(ticketId: string, assignmentId: string): void { this.repo.atomic(() => { this.assignments.turnEnded(ticketId, assignmentId) })` → the next pass pumps again (`passes.ts:67`) |

## 5. Disclosed limitations (transparency)

1. **Degenerate churn**: the repository has 1 commit → churn cannot
   discriminate; the score is effectively driven by FAN (the structural
   dependency data) + file counts. Disclosed up front instead of
   pretending churn signal.
2. **Three-way tie F1/F4/F5 (502)**: an artifact of module resolution;
   F1 (the runtime hot path) is the representative, F4/F5 are variants
   over the same module set.
3. Line numbers are exact at pin `8c32a9dc`; as the repository advances,
   lines shift.
4. The score formula is this document's decision (the method does not
   prescribe one) — disclosed in §1c.

## 6. Machine-readable output

```json
{
  "subject": "dshsa",
  "pin": "8c32a9dc5d72c033816c6a8110b37f40cf94fba4",
  "churn_window_commits": 1,
  "churn_window_note": "shallow clone depth 100 but the repository has only 1 commit — churn degenerate, every file count=1",
  "formula": "Score = sum(FAN in+out dep-lines of modules in flow) + sum(churn files of modules in flow)",
  "candidates": [
    {"id":"F1","flow":"external trigger -> engine intake/evals -> ticket -> DSH worker session -> reply","modules":["m06","m03","m01","m04","m07","m05"],"fan":418,"churn":84,"score":502,"rank":1},
    {"id":"F4","flow":"boot/mount Runtime","modules":["m07","m01","m03","m04","m05","m06"],"fan":418,"churn":84,"score":502,"rank":null,"note":"tie F1 - same module set, one-time setup variant"},
    {"id":"F5","flow":"feishu trigger -> reply","modules":["m06","m05","m03","m01","m04","m07"],"fan":418,"churn":84,"score":502,"rank":null,"note":"tie F1 - sibling instance of same frame"},
    {"id":"F2","flow":"web panel <-> loopback API <-> Store","modules":["m02","m01","m03","m07"],"fan":290,"churn":88,"score":378,"rank":2},
    {"id":"F3","flow":"worker-session turn loop (executor/sessions/retry/background)","modules":["m04","m01","m03","m05"],"fan":255,"churn":60,"score":315,"rank":3},
    {"id":"F6","flow":"background jobs/subagents teardown","modules":["m04","m03","m01"],"fan":209,"churn":55,"score":264,"rank":null}
  ],
  "top3": ["F1","F2","F3"]
}
```
