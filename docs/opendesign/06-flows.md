# Flows (nexu-io/open-design) — the most churn-heavy streams

- Subject: `nexu-io/open-design` · PIN: `5a0c47777975ddb91d09c1c16b423a3ef74bf572` (branch `main`, "fix(web): hide Labs settings when no experiments are available (#9076)") — **the measuring clone's HEAD exactly matched the PIN, drift = 0** (verified with `git rev-parse HEAD` at measurement time; same tree as the cartography and the module map).
- INPUT: `01-cartography.md` + `02-module-map.md` (JSON for 27 items, 60 dependency edges cross-checked in both directions).
- Run: **1** (no prior flows document existed for this subject).
- Measured in a `bitnami/git:latest` container, clone command exactly as specified:
  `git clone --depth 1 --single-branch --filter=blob:limit=1m https://github.com/nexu-io/open-design /workspace/opendesign` (exit 0, 9,955 files after sparse-checkout) + `git -C /workspace/opendesign sparse-checkout set --no-cone apps packages tools shells e2e clipper figma-plugin '*.md' '*.json' '*.yaml' '*.toml'` (exit 0).
- **Declared churn window:** the `--depth 1` clone sees only 1 commit → an extra `git fetch --deepen=99 --filter=blob:limit=1m origin main` was run (NOT a full clone, sparse-checkout kept; still a partial clone with the 1MB filter) so the churn window reaches the declared level: **the 100 most recent commits — exactly 100 measured** (`git rev-list --count HEAD` = 100). Every file:line in this document was measured on the PIN tree `5a0c4777`.

---

## 1. How the TOP-3 was chosen — by numbers

### 1a. Churn with the standard command (command + output verbatim)

Command: `git log --format= --name-only | sort | uniq -c | sort -rn | head -20`

```text
     23 apps/daemon/src/server.ts
     19 apps/web/src/i18n/locales/zh-TW.ts
     19 apps/web/src/i18n/locales/uk.ts
     19 apps/web/src/i18n/locales/tr.ts
     19 apps/web/src/i18n/locales/th.ts
     19 apps/web/src/i18n/locales/ru.ts
     19 apps/web/src/i18n/locales/pt-BR.ts
     19 apps/web/src/i18n/locales/pl.ts
     19 apps/web/src/i18n/locales/ko.ts
     19 apps/web/src/i18n/locales/ja.ts
     19 apps/web/src/i18n/locales/it.ts
     19 apps/web/src/i18n/locales/id.ts
     19 apps/web/src/i18n/locales/hu.ts
     19 apps/web/src/i18n/locales/fr.ts
     19 apps/web/src/i18n/locales/fa.ts
     19 apps/web/src/i18n/locales/es-ES.ts
     19 apps/web/src/i18n/locales/de.ts
     19 apps/web/src/i18n/locales/ar.ts
     17 apps/web/src/i18n/locales/zh-CN.ts
     17 apps/web/src/i18n/locales/en.ts
```

Total file-change events in the 100-commit window: **16,479** (`git log --format= --name-only | grep -v '^$' | wc -l`).

### 1b. Churn aggregated over the 27-item universe (same window)

| item | churn | item | churn | item | churn |
|---|---:|---|---:|---|---:|
| apps/web | **3676** | tools/pack | 187 | packages/host | 21 |
| apps/daemon | **2485** | tools/release | 110 | packages/platform | 19 |
| e2e | 492 | apps/packaged | 75 | tools/serve | 19 |
| packages/contracts | **381** | packages/sidecar | 47 | packages/diagnostics | 18 |
| shells/terminal | 44 | packages/standalone | 24 | packages/sidecar-proto | 11 |
| tools/dev | 34 | packages/download | 24 | packages/registry-protocol | 10 |
| packages/plugin-runtime | 34 | packages/dsh-runtime | 14 | packages/agui-adapter | 10 |
| packages/components | 26 | packages/release | 9 | packages/launcher-proto | 9 |
| apps/closure | 9 | packages/metatool | 8 | — | — |

Honest noise note: `apps/web` 3676 includes **357 i18n/locales events** (machine translations, mechanical churn) → the "real" part is **3319**; the scoring table uses the raw 3676 (declared, unfiltered — affects the ranking by <1% because every top flow contains web). Daemon churn by subsystem: `src/collab/` **160**, `src/runtimes/` **118**, `src/routes/` 94, `src/plugins/` **70**, `src/strategies/` 64, `src/registry/` 4, `src/routes/collab*` 12, `src/routes/plugins/` 7.

### 1c. Fan-in/out from the module map's dependency JSON (module weight)

**DECLARATION:** the task definition did not define "fan-in/out" → the module map's dependency data is used: `fan_out(m) = |depends on[m]|` (number of `@open-design/*` packages m imports) and `fan_in(m) = |imported by[m]|` (number of packages importing m); `weight(m) = fan_in + fan_out` (60 edges cross-checked in both directions 60/60).

| module | fan_out (depends on) | fan_in (imported by) | weight | module | fan_out | fan_in | weight |
|---|---:|---:|---:|---|---:|---:|---:|
| release | 0 | 11 | **11** | tools-pack | 7 | 0 | 7 |
| daemon | 10 | 0 | **10** | platform | 0 | 6 | 6 |
| web | 5 | 0 | 5 | e2e | 4 | 0 | 4 |
| contracts | 1 | 8 | **9** | standalone/tools-dev/download/host | 1 | 2 | 3 |
| desktop | 8 | 1 | **9** | plugin-runtime/agui-adapter/diagnostics/terminal | 1–2 | 0–1 | 2 |
| sidecar | 1 | 8 | **9** | components/registry-protocol/closure | 0–1 | 0–1 | 1 |
| sidecar-proto | 1 | 8 | **9** | dsh-runtime/metatool | 0 | 0 | 0 |
| packaged | 7 | 1 | **8** | launcher-proto | 2 | 5 | **7** |

### 1d. Combined formula (DECLARED — not defined upstream) + scoring table

```
Score(flow) = Σ_{m ∈ modules the flow traverses} weight(m)  +  Σ_{m ∈ modules} churn(m)
```

7 candidate flows (chosen to cover every production subsystem of the repo):

| # | Flow | Module set (really traversed, code-verified) | Σ weight | Σ churn | **Score** |
|---|---|---|---:|---:|---:|
| **C4** | **Plugin install (SSE): web → daemon installOrUpgradePlugin → marketplaces resolve → installer → plugin-runtime parse/adapt/merge/validate → upsert SQLite** | web, contracts, daemon, plugin-runtime | 5+9+10+2 = **26** | 3676+381+2485+34 = **6576** | **6602** |
| **C1** | **Agent run streaming + AGUI: web POST /api/runs → daemon spawn agent CLI → stream events → SQLite → GET /api/runs/:id/agui** | web, contracts, daemon, agui-adapter | 5+9+10+2 = **26** | 3676+381+2485+10 = **6552** | **6578** |
| **C2** | **Collab sync/presence: web collab ↔ daemon /api/workspace/* + collab routes → cloud service/relay** | web, contracts, daemon | 5+9+10 = **24** | 3676+381+2485 = **6542** | **6566** |
| C3 | Packaged sidecar launch chain: desktop → packaged supervisor → platform spawn → daemon/web sidecars | desktop, packaged, launcher-proto, platform, sidecar, sidecar-proto, daemon | 58 | 133+75+9+19+47+11+2485 = 2779 | 2837 |
| C5 | Diagnostics export (daemon+desktop → redaction → zip) | daemon, desktop, diagnostics | 21 | 2485+133+18 = 2636 | 2657 |
| C7 | Desktop updater (host bridge → release → download) | desktop, host, release, download, launcher-proto | 33 | 133+21+9+24+9 = 196 | 229 |
| C6 | Terminal shell sidecar host (shells/terminal → sidecar → standalone) | terminal, sidecar, standalone, sidecar-proto | 23 | 44+47+24+11 = 126 | 149 |

**TOP-3 = C4 (6602) > C1 (6578) > C2 (6566).** *(Round-1 correction after review: C4 6613→6602 — registry-protocol removed from the actual install chain; ranking unchanged.)*

### 1e. Reading the result (transparent declarations)

- **The web↔daemon spine is the most expensive structure:** all 3 top flows traverse (web + contracts + daemon) = **6542/16,479 = 39.7%** of all churn events in the window. The order among the 3 top flows is decided by their own "add-on" (C4 +plugin-runtime; C1 +agui-adapter) — module-level scoring cannot separate two flows riding the same spine; the 3 diagrams below use completely distinct code steps (different route trees, different subsystems). **[Round-1 correction]:** registry-protocol was removed from C4's module set — the RegistryBackends (static/database/github) are only consumed by `apps/daemon/src/plugins/marketplace-doctor.ts` (the doctor flow), not the install chain (grep over daemon+e2e: `GithubRegistryBackend` has no call site outside its own definition `registry/github-backend.ts:24,33,40,54,63`).
- **Secondary lake-splitting measure (declared, not used for the main ranking):** subsystem-specific churn per flow — C2: collab 160 + routes/collab 12 = 172; C1: runtimes 118 + routes/runs.ts 9 = 127; C4: plugins 70 + routes/plugins 7 = 77 (registry/ 4 excluded after the round-1 correction — registry backends belong to the doctor flow). Under the secondary measure C2 > C1 > C4 — the top-3 set is unchanged, only the order within it differs; the declared main formula's ranking is kept.
- **C3 ranks 4th** (2837): the most expensive flow NOT riding the web↔daemon spine — its wire path (desktop→packaged→platform→spawn) contains neither web nor contracts; excluded from the top-3 purely by the numbers, kept in the table with an explanation for reviewers (precedent: the 4th-ranked produce/fetch flow of the kafka run).

---

## 2. The three TOP-3 flows

Every step was traced by reading/grepping real code on the PIN tree (no inferred sequencing); line numbers are exact at PIN `5a0c4777`.

### Flow C4 — Plugin install (web → daemon installOrUpgradePlugin → marketplaces → installer → plugin-runtime → SQLite)

**Why it is expensive (numbers):** Score **6602** = weight 26 (web 5, contracts 9, daemon 10, plugin-runtime 2 — plugin-runtime: the daemon is its only importer (9 non-test daemon files import plugin-runtime — module map m02; plugin-runtime has 12 main files — m13)) + churn 6576 (web 3676 + daemon 2485 + contracts 381 + plugin-runtime 34 = 39.91% of the window). The flow returns results as a **multi-phase SSE stream** (`text/event-stream` server.ts:10088, writeEvent :10092): resolving → copying/extracting → persisting, one event per phase; install touches both marketplace catalog resolution (SQLite) and archive download/extract (github/https/local) before parsing the manifest.

> **Round-1 correction (review changes_requested):** 2 old links were REMOVED because the code at the PIN does not support them — (1) `GithubRegistryBackend` (`registry/github-backend.ts:33`) is not called by any step of the install flow: grep over daemon+e2e finds only its own definition file; the RegistryBackends are consumed only by `plugins/marketplace-doctor.ts` (the doctor flow). (2) `plugins.applyPlugin` (`routes/plugins/index.ts:441`) lives in the helper `applyResolvedPlugin` serving the routes `POST /api/plugins/:id/apply-local` (:633) and `POST /api/plugins/:id/apply` (:668) — the web calls neither (grep over web finds only comments at `utils/pluginRequiredInputs.ts:7,75`). C4's module set drops registry-protocol → score 6613 → **6602** (top-1 unchanged, ranking unchanged). `resolvePluginFolder` (registry.ts:99) REMAINS in the flow — called by `installer.ts:762` (probe) and `:821` (parse after extract); the plugin-runtime parse/adapt/merge/validate steps remain via `registry.ts:121/133/139/152/153` *(line numbers corrected in round 2: :133/:139/:152/:153 — grep-verified)*.

```mermaid
sequenceDiagram
    participant UI as web PluginsView
    participant API as daemon routes/plugins
    participant SRV as daemon server.ts installOrUpgradePlugin
    participant MKT as daemon plugins/marketplaces
    participant INST as daemon plugins/installer
    participant PR as plugin-runtime (via plugins/registry)
    participant DB as SQLite installed_plugins

    UI->>API: 1. fetch POST /api/plugins/install [state/projects.ts:2126]
    API->>SRV: 2. app.post install → helpers.installOrUpgradePlugin [routes/plugins/index.ts:560,563; deps :154]
    SRV->>MKT: 3. source is a marketplace name → resolvePluginInMarketplaces(db, lookupName) [server.ts:10077-10082; def marketplaces.ts:490]
    SRV->>INST: 4. SSE headers [server.ts:10088] + writeEvent [:10092] + for await (ev of installPlugin(db,{source,roots})) [:10101]
    INST->>INST: 5. dispatcher by source: installFromGithub [installer.ts:209; def :220; contents :241, def :352] / https archive [:213] / local folder [:216]
    INST->>PR: 6. resolvePluginFolder: probe [installer.ts:762] + parse after extract [:821] → parseManifest(rawSidecar) [registry.ts:121 → parsers/manifest.ts:25]
    PR->>PR: 7. adaptAgentSkill / adaptClaudePlugin [registry.ts:133,139 → adapters/agent-skill.ts:36] → mergeManifests [registry.ts:152 → merge.ts:17] → validateSafe [registry.ts:153 → validate.ts:43]
    INST->>DB: 8. yield phase persisting "Writing installed_plugins row" + upsertInstalledPlugin(db, parsed.record) [installer.ts:834-835]
    SRV->>DB: 9. ev success → ensureWorkspaceResource personal binding + SSE success to web [server.ts:10119]
    UI->>API: 10. refresh GET /api/plugins [routes/plugins/index.ts:502; rowToInstalledPlugin plugins/registry.ts:205]
```

**Step → evidence map (read for real at the PIN, after the round-1 correction):**

| Step | File:line | Quoted content / paraphrase |
|---|---|---|
| 1 | `apps/web/src/state/projects.ts:2126` | `const resp = await fetch('/api/plugins/install', { method: 'POST', ...` |
| 2 | `apps/daemon/src/routes/plugins/index.ts:560,563` | `app.post('/api/plugins/install', async (req, res) => {` … `return helpers.installOrUpgradePlugin(req, res, 'install', authority);` (deps contract `:154`) |
| 3 | `apps/daemon/src/server.ts:10077-10082` | `const { resolvePluginInMarketplaces } = await import('./plugins/marketplaces.js');` … `const resolved = resolvePluginInMarketplaces(db, lookupName);` (def `plugins/marketplaces.ts:490`) |
| 4 | `apps/daemon/src/server.ts:10088,10092,10101` | `res.setHeader('Content-Type', 'text/event-stream');` / `const writeEvent = (event, data) => res.write(...)` / `for await (const ev of installPlugin(db, { source, roots: PLUGIN_REGISTRY_ROOTS, ...` |
| 5 | `apps/daemon/src/plugins/installer.ts:196,209,220` | `export async function* installPlugin(` — "// Top-level dispatcher. Picks the backend off the source string" `:194` → `yield* ... installFromGithub(db, normalizedOpts)` `:209` (def `:220`; `installFromGithubContents` call `:241`, def `:352`); https `:213`; local `:216` |
| 6 | `apps/daemon/src/plugins/installer.ts:762,821` | `const probe = await resolvePluginFolder(probeOptions);` / `const parsed = await resolvePluginFolder(parsedOptions);` (def `plugins/registry.ts:99`) |
| 7 | `apps/daemon/src/plugins/registry.ts:121,133,139,152,153` | `const parsed: ManifestParseResult = parseManifest(rawSidecar);` [→ `packages/plugin-runtime/src/parsers/manifest.ts:25`] / `adaptAgentSkill(raw, ...)` `:133` / `adaptClaudePlugin(raw, ...)` `:139` [→ `adapters/agent-skill.ts:36`] / `mergeManifests({ sidecar, adapters })` `:152` [→ `merge.ts:17`] / `validateSafe(manifest)` `:153` [→ `validate.ts:43`] |
| 8 | `apps/daemon/src/plugins/installer.ts:834-835` | `yield { kind: 'progress', phase: 'persisting', message: 'Writing installed_plugins row' };` / `upsertInstalledPlugin(db, parsed.record);` |
| 9 | `apps/daemon/src/server.ts:10119` | `ensureWorkspaceResource(db, 'plugin', installWorkspaceContext.workspaceId, ev.plugin.id, { visibility: 'personal', ...` — personal binding when `ev.kind === 'success'` |
| 10 | `apps/daemon/src/routes/plugins/index.ts:502` | `app.get('/api/plugins', ...)` — UI refresh; `rowToInstalledPlugin(row)` `plugins/registry.ts:205` |

### Flow C1 — Agent run streaming + AGUI (web → daemon spawn CLI agent → events → AG-UI SSE)

**Why it is expensive (numbers):** Score **6578** = weight 26 (web 5, contracts 9, daemon 10, agui-adapter 2 — contracts is the central node with 8 importers, agui-adapter is imported by exactly 1 daemon file `routes/runs.ts`) + churn 6552 (39.78% of the window; `runtimes/` alone has 118 events — the hottest agent-execution subsystem in the daemon). The flow touches 3 complex mechanisms in sequence: spawning an external CLI process, parsing streamed JSON deltas, and SSE-encoding into the AG-UI standard.

```mermaid
sequenceDiagram
    participant UI as web providers/daemon
    participant RUNS as daemon routes/runs
    participant PROC as daemon runtimes/agent-process
    participant STREAM as daemon runtimes/claude-stream
    participant DB as SQLite run records
    participant AGUI as @open-design/agui-adapter

    UI->>RUNS: 1. streamViaDaemon({...}) [providers/daemon.ts:981]
    UI->>RUNS: 2. fetch POST /api/runs (retry loop attempt) [providers/daemon.ts:1071-1072]
    RUNS->>RUNS: 3. app.post('/api/runs', ...) creates run [routes/runs.ts:952]
    RUNS->>PROC: 4. spawnAgentProcess → child = spawn(command, args) [runtimes/agent-process.ts:276,285; prompt stdin :94; caller server.ts:15404]
    PROC-->>STREAM: 5. agent stdout → createClaudeStreamHandler(onEvent) [runtimes/claude-stream.ts:117; caller server.ts:16311]
    STREAM->>DB: 6. events into run records — recordRunEventStorageShape [runtimes/chat-run-messages.ts:275, def :163; ring buffer runtimes/runs.ts:396]
    UI->>RUNS: 7. fetchChatRunStatus → fetch /api/runs/:id [providers/daemon.ts:1182-1187]
    UI->>RUNS: 8. GET /api/runs/:id/agui + authorizeRunProject [routes/runs.ts:3285-3293]
    RUNS->>AGUI: 9. await import('@open-design/agui-adapter') + createSseResponse [routes/runs.ts:3296-3297] → encodeOdEventForAgui [encode.ts:87; called :3302,:3327; filters kind AGUI_NATIVE_EVENT_KINDS :758]
    AGUI-->>UI: 10. SSE AG-UI events → run finished: publishDaemonRunFinishedEvent [providers/daemon.ts:613; event constant :601-602; failure classification runtime/chat-events.ts:27]
```

**Step → evidence map:**

| Step | File:line | Quoted content / paraphrase |
|---|---|---|
| 1 | `apps/web/src/providers/daemon.ts:981` | `export async function streamViaDaemon({` |
| 2 | `apps/web/src/providers/daemon.ts:1071-1072` | `for (let attempt = 0; ; attempt += 1) { createResp = await fetch('/api/runs', { method: 'POST', ...` (reconnect limit `DAEMON_STREAM_RECONNECT_LIMIT = 5` `:374`) |
| 3 | `apps/daemon/src/routes/runs.ts:952` | `app.post('/api/runs', async (req: ApiRequest, res: ApiResponse) => {` |
| 4 | `apps/daemon/src/runtimes/agent-process.ts:276,285` | `export function spawnAgentProcess(request: SpawnAgentProcessRequest)` → `child = spawn(request.command, [...request.args], {` ; prompt stdin `openCompletePromptAsStdin` `:94`; call-site `apps/daemon/src/server.ts:15404` |
| 5 | `apps/daemon/src/runtimes/claude-stream.ts:117` | `export function createClaudeStreamHandler( onEvent: EventSink, ...)` (buffer per content-block `:134`); call-site `apps/daemon/src/server.ts:16311` |
| 6 | `apps/daemon/src/runtimes/chat-run-messages.ts:275` | `recordRunEventStorageShape(run, persisted, eventChars);` (def `:163`); ring-buffer guard `apps/daemon/src/runtimes/runs.ts:396` `'run_event_ring_buffer_truncated'` |
| 7 | `apps/web/src/providers/daemon.ts:1182-1187` | `export async function fetchChatRunStatus(` → `fetch(`/api/runs/${encodeURIComponent(runId)}`, {` |
| 8 | `apps/daemon/src/routes/runs.ts:3285-3293` | `app.get('/api/runs/:id/agui', ...)` + `authorizeRunProject(req, res, run, { mode: 'read', ...})` |
| 9 | `apps/daemon/src/routes/runs.ts:3296-3297,3302,3327` | `const { encodeOdEventForAgui } = await import('@open-design/agui-adapter');` + `createSseResponse(res)`; def `packages/agui-adapter/src/encode.ts:87` `export function encodeOdEventForAgui(`; filter `:758` `AGUI_NATIVE_EVENT_KINDS` (`message_chunk`, `tool_call`, …) |
| 10 | `apps/web/src/providers/daemon.ts:601-602,613` | `RUNS_CHANGED_EVENT = 'open-design:runs-changed'` / `DAEMON_RUN_FINISHED_EVENT` / `export function publishDaemonRunFinishedEvent(`; failure card `apps/web/src/runtime/chat-events.ts:27` `runFailureFieldsFromError` |

### Flow C2 — Collab sync/presence (web collab ↔ daemon ↔ cloud service)

**Why it is expensive (numbers):** Score **6566** = weight 24 (web 5, contracts 9, daemon 10) + churn 6542 (39.72% of the window). The largest subsystem-specific churn in the repo: `daemon/src/collab/` **160 events** (118 routes + tests) over **2,962 lines** of `routes/collab-sync.ts` + **1,742 lines** of `collab-cloud-service.ts`; web `src/collab/` 53. The workspace-identity boundary contract (contracts) is re-verified on every connection (`server.ts:1597`).

```mermaid
sequenceDiagram
    participant WEB as web collab stores
    participant CTX as daemon routes/collab-context
    participant SYNC as daemon routes/collab-sync
    participant WATCH as daemon collab publish watcher
    participant CLOUD as daemon collab-cloud-service
    participant PRES as daemon routes/collab-presence

    WEB->>CTX: 1. fetch('/api/workspace/context') [web/collab/useWorkspaceContext.ts:796; directory :255]
    CTX-->>WEB: 2. GET /api/workspace/events (invalidation stream) [routes/collab-context.ts:512; re-verified per connection server.ts:1597]
    WEB->>WEB: 3. workspaceEventsUrl + useWorkspaceInvalidation [web/collab/workspace-events.ts:20-22,51]
    WEB->>SYNC: 4. POST /api/projects/:id/collab/publish [routes/collab-sync.ts:1294]
    SYNC->>WATCH: 5. scheduler.notifyChanged(projectId,'run') + scheduler.runBoundary [collab-sync.ts:1304-1305; watcher createCollabPublishWatcher collab-publish-watcher.ts:57, deps.notifyChanged :23, fire :100-118]
    SYNC->>CLOUD: 6. sync to cloud — createCollabCloudService [collab/collab-cloud-service.ts:443; previewCommentToCloud :276; retry backoff memberPageRetryDelayMs :242]
    SYNC->>SYNC: 7. POST /collab/changed → notifyChanged(projectId,'change') [collab-sync.ts:1280,1290]; intent state POST /collab/sync-intent [collab-sync.ts:1911]
    SYNC->>SYNC: 8. comment relay outbox — createCommentRelayOutboxStore(db) [collab/comment-relay-outbox.ts:316; migrate :164]
    WEB->>PRES: 9. GET /api/projects/:id/presence + POST /presence/heartbeat (readHeartbeat, verifiedContext) [routes/collab-presence.ts:775,830-833]
    PRES-->>WEB: 10. invalidation poller emits thin events → web refetches [collab/workspace-invalidation-poller.ts:2; back to step 1]
```

**Step → evidence map:**

| Step | File:line | Quoted content / paraphrase |
|---|---|---|
| 1 | `apps/web/src/collab/useWorkspaceContext.ts:796` | `const res = await fetch('/api/workspace/context', {` (also `:255` `fetch('/api/workspace/directory', { cache: 'no-store' })`) |
| 2 | `apps/daemon/src/routes/collab-context.ts:512` | `app.get('/api/workspace/events', async (req, res) => {` (design `:222`; connection verification `apps/daemon/src/server.ts:1597`) |
| 3 | `apps/web/src/collab/workspace-events.ts:20-22,51` | `const WORKSPACE_EVENTS_PATH = '/api/workspace/events';` / `export function workspaceEventsUrl(` / `export function useWorkspaceInvalidation(` |
| 4 | `apps/daemon/src/routes/collab-sync.ts:1294` | `app.post('/api/projects/:id/collab/publish', async (req, res) => {` |
| 5 | `apps/daemon/src/routes/collab-sync.ts:1304-1305` | `scheduler.notifyChanged(projectId, 'run', authorization.principal);` + `scheduler.runBoundary(projectId, authorization.principal);` (scheduler = CollabPublishWatcher, `apps/daemon/src/collab/collab-publish-watcher.ts:57` `createCollabPublishWatcher(deps)`, dep `notifyChanged` `:23`, fires on publish `:100-118`) |
| 6 | `apps/daemon/src/collab/collab-cloud-service.ts:443,276,242` | `export function createCollabCloudService(` / `export function previewCommentToCloud(` / `export function memberPageRetryDelayMs(failures: number)` |
| 7 | `apps/daemon/src/routes/collab-sync.ts:1280,1290,1911` | `app.post('.../collab/changed')` → `scheduler.notifyChanged(projectId, 'change', ...)`; `app.post('.../collab/sync-intent')` returns `syncState` |
| 8 | `apps/daemon/src/collab/comment-relay-outbox.ts:316,164` | `export function createCommentRelayOutboxStore(` / `export function migrateCommentRelayOutbox(db: SqliteDb): void` |
| 9 | `apps/daemon/src/routes/collab-presence.ts:775,830-833` | `app.get('/api/projects/:id/presence', ...)` / `app.post('.../presence/heartbeat')` → `readHeartbeat(req.body)` + `verifiedContext(req, req.params.id, 'heartbeat')` |
| 10 | `apps/daemon/src/collab/workspace-invalidation-poller.ts:2` | "// thin invalidation events (`/api/workspace/events`)" — the invalidation loop closes back to steps 1-3 |

---

## 3. Machine-readable output

```json
{
  "subject": "nexu-io/open-design",
  "pin": "5a0c47777975ddb91d09c1c16b423a3ef74bf572",
  "churn_window": {"commits": 100, "changed_file_events": 16479, "method": "git clone --depth 1 --filter=blob:limit=1m + sparse-checkout + git fetch --deepen=99", "disclosure": "shallow window only (<=100 commits)"},
  "formula": "Score(flow) = sum(weight(m)) + sum(churn(m)) over modules traversed; weight(m)=|deps_in|+|deps_out| from the module map JSON",
  "spine": {"modules": ["web", "contracts", "daemon"], "churn_events": 6542, "pct_of_window": 39.7},
  "top3": [
    {"id": "C4", "name": "plugin-install-sse", "score": 6602, "modules": ["web", "contracts", "daemon", "plugin-runtime"], "entry": "apps/web/src/state/projects.ts:2126", "route": "apps/daemon/src/routes/plugins/index.ts:560", "core": ["apps/daemon/src/server.ts:10053", "apps/daemon/src/plugins/marketplaces.ts:490", "apps/daemon/src/plugins/installer.ts:196", "apps/daemon/src/plugins/installer.ts:821", "apps/daemon/src/plugins/registry.ts:121", "apps/daemon/src/plugins/registry.ts:152", "apps/daemon/src/plugins/installer.ts:835", "apps/daemon/src/server.ts:10119"], "v1_fix": "review round 1: registry-protocol + plugins/apply.ts:108 removed from chain (registry backends only used by marketplace-doctor.ts; applyPlugin only reachable via /apply routes which web does not call) — score 6613→6602, ranking unchanged"},
    {"id": "C1", "name": "agent-run-streaming-agui", "score": 6578, "entry": "apps/web/src/providers/daemon.ts:981", "route": "apps/daemon/src/routes/runs.ts:952", "core": ["apps/daemon/src/runtimes/agent-process.ts:276", "apps/daemon/src/runtimes/claude-stream.ts:117", "apps/daemon/src/routes/runs.ts:3285", "packages/agui-adapter/src/encode.ts:87"]},
    {"id": "C2", "name": "collab-sync-presence", "score": 6566, "entry": "apps/web/src/collab/useWorkspaceContext.ts:796", "route": "apps/daemon/src/routes/collab-context.ts:512", "core": ["apps/daemon/src/routes/collab-sync.ts:1294", "apps/daemon/src/collab/collab-publish-watcher.ts:57", "apps/daemon/src/collab/collab-cloud-service.ts:443", "apps/daemon/src/routes/collab-presence.ts:830"]}
  ],
  "runner_up": {"id": "C3", "name": "packaged-sidecar-launch-chain", "score": 2837, "note": "most expensive flow NOT riding the web-daemon spine; desktop+packaged+platform+sidecar chain"}
}
```

## 4. Disclosed limitations (transparency)

1. **Churn window = 100 commits** (shallow deepen from the specified `--depth 1`) — not the whole history; i18n churn (357 web events) is mechanical noise, unfiltered from the tables (affects the ranking by <1%).
2. **Line numbers are exact at PIN `5a0c4777`** — upstream will move them as it advances.
3. Module-level scoring cannot separate the 2 flows riding the same web↔daemon spine — a secondary subsystem-churn measure was declared (1e); the top-3 set is unchanged under both measures, only the order within the top-3 differs.
4. The sequence in the diagrams is the natural request-lifecycle order; each arrow is a call site verified by grep/sed (no internal daemon sequencing inferred — steps 7-8 of C2 are parallel route surfaces of the same subsystem, not an asserted internal order between them).
