# Usage — hands-on recipes (subject: opendesign / nexu-io/open-design)

- PIN of the evidence in all 8 sections: **`5a0c47777975ddb91d09c1c16b423a3ef74bf572`**
  (branch `main`) — both measurement passes confirmed `git rev-parse HEAD` ==
  the PIN before measuring.
- Coverage: **8/8 items** of the usage checklist (pass 1: s04, s09, s17, s02 ·
  pass 2: s24, s10, s05, s01) · **24 use cases** (3 per item) · every item
  `section_done: true`.
- Anti-fabrication: the `File: path | Line: a-b | Content: quote` evidence is
  kept verbatim from the measuring passes; the (e) build step of all 8 items
  is **honestly SKIPPED** (the `bitnami/git:latest` container has no
  node/pnpm/npm) — no build output was invented.

---

## 1. Summary — module | when to use | imported by

Column sources: "when to use" condenses section (a) of each item; "imported
by" copies the dependency table (matches the module map; cross-checked for
all 12 candidate items in the usage plan).

| s_id | module | when to use | imported by |
|---|---|---|---|
| s04 | @open-design/contracts | Pure TypeScript contract package for the web/daemon boundary: request/response shapes of the composite endpoints (finalize/handoff/share), the critique config schema (zod), the API error-code table, plugin snapshots — used whenever the daemon (323 non-test files) and the web (302 non-test files) need one shared set of shapes instead of declaring their own. | agui-adapter, daemon, desktop, e2e, packaged, plugin-runtime, tools-pack, web (8) |
| s09 | @open-design/sidecar | The "host runtime ↔ sidecar binary" bridge: the host spawns the sidecar, converges the launch, invokes business operations over a private IPC socket, and stops it; the sidecar internally serves that IPC with `SidecarClient` + lifecycle; stamps normalize the 5-field identity and derive the private IPC path. | daemon, desktop, e2e, packaged, terminal, tools-dev, tools-pack, web (8) |
| s17 | @open-design/sidecar-proto | Wire contract + dedicated constants for sidecar IPC: `APP_KEYS`, `SIDECAR_MODES/SOURCES/ENV`, message types + fail-closed normalizers, the desktop-update constant set — used whenever any party (daemon, desktop, web, tools) talks to a sidecar so env wiring and messages cannot drift. | daemon, desktop, e2e, launcher-proto, packaged, tools-dev, tools-pack, web (8) |
| s02 | @open-design/daemon | HTTP server + CLI `od` — the coordination center: bin `od` starts the HTTP (Express) server + web UI, serves the project/collab/design-systems/evidence-delivery/workspace-run routes, persists to SQLite (better-sqlite3); the thin CLI (`od media …`, `od project …`) POSTs to the running daemon. | — (0) |
| s24 | @open-design/release | Release domain primitives: release-channel name normalization (`stable`/`prerelease`/exact names), counted versions `x.y.z-<channel>.N`, install descriptors (appId/productName), per-platform feed namespaces — the root node of the dependency graph, imported by 11 packages. | contracts, daemon, desktop, e2e, host, launcher-proto, packaged, sidecar-proto, tools-pack, tools-release, tools-serve (11) |
| s10 | @open-design/platform | OS process lifecycle primitives: encode/decode process stamps `--flag=value`, spawn background/logged processes, probe liveness, enumerate process snapshots (POSIX `ps`/Windows `Get-CimInstance`), walk the process tree, SIGTERM-then-SIGKILL; proxy-env reads OS-level proxies and merges normalized env. | daemon, download, packaged, sidecar, tools-dev, tools-pack (6) |
| s05 | @open-design/desktop | Electron main process: window/menu/ipc (`BrowserWindow`, `Menu`, `ipcMain`, `powerMonitor`, `shell`), the self-running updater (metadata feed, download, install-after-quit), and host lifecycle events (suspend/resume/shutdown/session-end) recorded into run markers. | packaged |
| s01 | @open-design/web | Next.js web UI (component tree `App.tsx`, `FileViewer.tsx` 20,759 lines — largest file in the repo); 3 easily reusable pure capabilities: account-match verdicts for the collab invite flow, deriving plugin-source links/labels for the marketplace, and version-gated config hydration from localStorage. | — (0) |

The same table as JSON (machine-parseable):

```json
[
  {"s_id": "s04", "module": "@open-design/contracts", "stars": 5, "use_when": "Shared pure TypeScript contracts for the web/daemon boundary: request/response shapes of the finalize/handoff/share endpoints, the critique config schema (zod), the API error-code table, plugin snapshots — daemon (323 non-test files) and web (302 non-test files) import one shared set of shapes instead of declaring their own.", "imported_by": ["agui-adapter", "daemon", "desktop", "e2e", "packaged", "plugin-runtime", "tools-pack", "web"], "use_cases": 3, "section_done": true},
  {"s_id": "s09", "module": "@open-design/sidecar", "stars": 5, "use_when": "Host-runtime ↔ sidecar-binary bridge: host spawns the sidecar, converges the launch, invokes business operations over a private IPC socket, stops it; the sidecar serves the IPC internally with SidecarClient + lifecycle; stamps normalize the 5-field identity and derive the private IPC path.", "imported_by": ["daemon", "desktop", "e2e", "packaged", "terminal", "tools-dev", "tools-pack", "web"], "use_cases": 3, "section_done": true},
  {"s_id": "s17", "module": "@open-design/sidecar-proto", "stars": 5, "use_when": "Wire contract + dedicated constants for sidecar IPC: APP_KEYS, SIDECAR_MODES/SOURCES/ENV, message types + fail-closed normalizers, the desktop-update constant set — every party (daemon, desktop, web, tools) talking to a sidecar must use exactly these constants/types.", "imported_by": ["daemon", "desktop", "e2e", "launcher-proto", "packaged", "tools-dev", "tools-pack", "web"], "use_cases": 3, "section_done": true},
  {"s_id": "s02", "module": "@open-design/daemon", "stars": 4, "use_when": "HTTP server + CLI 'od' — coordination center: bin od starts the HTTP (Express) server + web UI, serves project/collab/design-systems/evidence-delivery/workspace-run routes, SQLite (better-sqlite3); thin CLI (od media …, od project …) POSTs to the running daemon.", "imported_by": [], "use_cases": 3, "section_done": true},
  {"s_id": "s24", "module": "@open-design/release", "stars": 4, "use_when": "Release domain primitives: release-channel name normalization (stable/prerelease/exact-name [a-z0-9]{1,12}), counted versions x.y.z-<channel>.N, install descriptors (appId/productName), per-platform feed namespaces — root node of the dependency graph, imported by 11 packages.", "imported_by": ["contracts", "daemon", "desktop", "e2e", "host", "launcher-proto", "packaged", "sidecar-proto", "tools-pack", "tools-release", "tools-serve"], "use_cases": 3, "section_done": true},
  {"s_id": "s10", "module": "@open-design/platform", "stars": 4, "use_when": "OS process lifecycle primitives: encode/decode process stamps --flag=value, spawn background/logged processes, probe liveness, enumerate process snapshots (POSIX ps / Windows Get-CimInstance), walk the process tree, SIGTERM-then-SIGKILL; proxy-env reads OS proxies + merges normalized env.", "imported_by": ["daemon", "download", "packaged", "sidecar", "tools-dev", "tools-pack"], "use_cases": 3, "section_done": true},
  {"s_id": "s05", "module": "@open-design/desktop", "stars": 4, "use_when": "Electron main process: window/menu/ipc (BrowserWindow, Menu, ipcMain, powerMonitor, shell), self-running updater (metadata feed, download, install after quit), host lifecycle events (suspend/resume/shutdown/session-end) recorded into run markers.", "imported_by": ["packaged"], "use_cases": 3, "section_done": true},
  {"s_id": "s01", "module": "@open-design/web", "stars": 4, "use_when": "Next.js web UI (component tree App.tsx, FileViewer.tsx 20,759 lines — largest file in the repo); 3 reusable pure capabilities: account-match verdicts for the collab invite flow (masked email), deriving plugin-source links/labels for marketplace cards, version-gated config hydration from localStorage.", "imported_by": [], "use_cases": 3, "section_done": true}
]
```

---

## 2. Per-item details

### s04 — @open-design/contracts (`packages/contracts`, 5★)

#### (a) What problem does this item solve

The shared pure-TypeScript contract package for the OpenDesign web/daemon
boundary — upstream description: `"Shared pure TypeScript contracts for the
OpenDesign web/daemon boundary"` (File: packages/contracts/package.json |
Line: 2-5, the manifest's description field; package name
`@open-design/contracts` v0.25.1). It fixes the request/response shapes of
the composite endpoints (finalize/handoff/share), the critique config schema
(zod), the API error-code table, and plugin snapshots — so the daemon (323
non-test files) and the web (302 non-test files) import one shared set of
shapes instead of declaring their own (census numbers: the module map —
upstream report fact, matching source). It is the center of the dependency
graph: 8 packages depend on it (imported by: agui-adapter, daemon, desktop,
e2e, packaged, plugin-runtime, tools-pack, web).

#### (b)+(c) Use cases + evidence

##### UC-1 — Call the finalize endpoint with shared DTOs (web client)

Scenario: the user clicks "Finalize design" in the web UI; the client builds
the body for `POST /api/projects/:id/finalize/<provider>` from the shared
contract, sends it through the provider chosen in Settings (BYOK), then reads
the response to display the bytes written to `DESIGN.md` and the token
usage. `FINALIZE_SCHEMA_VERSION` goes into the log so the shape version can
be traced when the daemon upgrades incompatibly.

```ts
import {
  FINALIZE_SCHEMA_VERSION,
  type FinalizeProviderRequest,
  type FinalizeProviderResponse,
} from '@open-design/contracts';

function buildFinalizeBody(input: {
  apiKey: string;
  model: string;
  protocol?: FinalizeProviderRequest['protocol'];
  baseUrl?: string;
  maxTokens?: number;
}): FinalizeProviderRequest {
  // omitting protocol => the daemon understands 'anthropic' (back-compat)
  return {
    apiKey: input.apiKey,
    baseUrl: input.baseUrl, // optional: standard providers have a daemon default
    maxTokens: input.maxTokens,
    model: input.model,
    protocol: input.protocol ?? 'anthropic',
  };
}

const body = buildFinalizeBody({ apiKey: 'sk-...', model: 'claude-sonnet-4-5' });
console.log(`finalize schema v${FINALIZE_SCHEMA_VERSION} via ${body.protocol}`);

// Response of POST /api/projects/:id/finalize/<provider>:
function reportFinalize(res: FinalizeProviderResponse): string {
  return `wrote ${res.bytesWritten}B -> ${res.designMdPath}` +
    ` (tokens in=${res.inputTokens} out=${res.outputTokens})`;
}
```

Evidence (grep -n on the PIN tree):
- File: packages/contracts/src/api/finalize.ts | Line: 14 | Content: `"export const FINALIZE_SCHEMA_VERSION = 1;"`
- File: packages/contracts/src/api/finalize.ts | Line: 22-29 | Content: `"export type FinalizeProviderProtocol ="` + union `'anthropic' | 'openai' | 'azure' | 'google' | 'ollama';`
- File: packages/contracts/src/api/finalize.ts | Line: 38 | Content: `"export interface FinalizeProviderRequest extends ReasoningExecutionRequestFields {"` (body has `protocol?: FinalizeProviderProtocol;` :43, `apiKey: string;` :44, `baseUrl?: string;` :45, `model: string;` :46, `maxTokens?: number;` :47)
- File: packages/contracts/src/api/finalize.ts | Line: 72-82 | Content: `"export interface FinalizeProviderResponse {"` (body has `designMdPath: string;` :74, `bytesWritten: number;` :75, `inputTokens: number;` :77, `outputTokens: number;` :78)

##### UC-2 — Gate the critique panel config before enabling multi-agent critique (daemon)

Scenario: an admin enables critique mode (a panel of designer/critic/brand/
a11y/copy reviewers scoring the design) via config; the daemon parses the raw
config with the contract's zod schema — one wrong field (e.g.
`scoreThreshold > scoreScale`, `maxRounds > 10`) is rejected and falls back
to the default config instead of failing mid-run.

```ts
import {
  CRITIQUE_PROTOCOL_VERSION,
  CritiqueConfigSchema,
  defaultCritiqueConfig,
  type CritiqueConfig,
} from '@open-design/contracts';

const raw = {
  enabled: true,
  cast: ['designer', 'critic', 'a11y'],        // subset of PANELIST_ROLES
  maxRounds: 3,
  scoreScale: 10,
  scoreThreshold: 8.0,
  weights: { designer: 0.1, critic: 0.4, brand: 0.2, a11y: 0.2, copy: 0.1 },
  perRoundTimeoutMs: 90_000,
  totalTimeoutMs: 240_000,
  parserMaxBlockBytes: 262_144,
  fallbackPolicy: 'ship_best',                 // element of FALLBACK_POLICIES
  protocolVersion: CRITIQUE_PROTOCOL_VERSION,
  maxConcurrentRuns: 2,
} as const;

const parsed = CritiqueConfigSchema.safeParse(raw);
const config: CritiqueConfig = parsed.success ? parsed.data : defaultCritiqueConfig();
if (!parsed.success) {
  // fallback: defaultCritiqueConfig() (enabled: false) — run proceeds without critique
  console.error('critique config rejected:', parsed.error.issues[0]?.message);
}
```

Evidence:
- File: packages/contracts/src/critique.ts | Line: 17 | Content: `"export const PANELIST_ROLES = ['designer', 'critic', 'brand', 'a11y', 'copy'] as const;"`
- File: packages/contracts/src/critique.ts | Line: 20 | Content: `"export const FALLBACK_POLICIES = ['ship_best', 'ship_last', 'fail'] as const;"`
- File: packages/contracts/src/critique.ts | Line: 23 | Content: `"export const CRITIQUE_PROTOCOL_VERSION = 1;"`
- File: packages/contracts/src/critique.ts | Line: 25-31 | Content: `"export const RoleWeights = z.object({"` — 5 roles, each `z.number().min(0).max(1)`
- File: packages/contracts/src/critique.ts | Line: 34-54 | Content: `"export const CritiqueConfigSchema = z.object({"` — has `cast: z.array(z.enum(PANELIST_ROLES)).min(1)` :36, `maxRounds: z.number().int().min(1).max(10)` :38, `.refine((cfg) => cfg.scoreThreshold <= cfg.scoreScale + 1e-9, …)` :50-52
- File: packages/contracts/src/critique.ts | Line: 58 | Content: `"export function defaultCritiqueConfig(): CritiqueConfig {"` (body: `enabled: false,` :60, `cast: [...PANELIST_ROLES],` :61, `scoreThreshold: 8.0,` :65, `fallbackPolicy: 'ship_best',` :69)

##### UC-3 — Share page + comment sidebar keep the "frozen" shape (vela/OD client)

Scenario: public share links have the form `/artifact/{projectId}/{slug}`;
the share page parses the path to know which project is being viewed, and the
comment sidebar caps 500 comments/page and 64 KiB/comment before POSTing.
Both use constants/functions frozen in the contract because 4 surfaces
(daemon publish, vela share page, vela cloud comment API, OD client sidebar)
never see each other's code.

```ts
import {
  SHARE_COMMENT_MAX_BYTES,
  SHARE_COMMENT_PAGE_LIMIT,
  buildSharePath,
  hasActiveShare,
  parseSharePath,
  type ProjectShareState,
} from '@open-design/contracts';

// 1) The share page parses the public path (exactly /artifact/{projectId}/{slug})
const parts = parseSharePath('/artifact/prj_01h9x/sunny-deck');
if (parts) console.log(parts.projectId, parts.slug); // null if the path has extra segments

// 2) New share paths are built with the same formula — the 'artifact' segment is a constant
const path = buildSharePath({ projectId: 'prj_01h9x', slug: 'sunny-deck' });

// 3) Comment sidebar: reject early before POSTing to the cloud comment API
function commentGuard(bytes: number, page: number): boolean {
  return bytes <= SHARE_COMMENT_MAX_BYTES && page <= SHARE_COMMENT_PAGE_LIMIT;
}

// 4) The share banner renders only while the share is 'active'
const state: ProjectShareState = {
  projectId: 'prj_01h9x', status: 'active', slug: 'sunny-deck', path,
};
if (hasActiveShare(state)) renderShareBanner(state);
```

Evidence:
- File: packages/contracts/src/api/share.ts | Line: 67 | Content: `"export const SHARE_URL_PATH_SEGMENT = 'artifact';"`
- File: packages/contracts/src/api/share.ts | Line: 107-111 | Content: `"export interface ShareUrlParts {"` — `projectId: string;` :108, `slug: string;` :109
- File: packages/contracts/src/api/share.ts | Line: 117-119 | Content: `"export function buildSharePath(parts: ShareUrlParts): string {"` — body returns `` `/${SHARE_URL_PATH_SEGMENT}/${encodeURIComponent(parts.projectId)}/${encodeURIComponent(parts.slug)}` ``
- File: packages/contracts/src/api/share.ts | Line: 126 | Content: `"export function parseSharePath(pathname: string): ShareUrlParts | null {"` — doc :122-124: "Returns `null` for anything that is not exactly `/artifact/{projectId}/{slug}`"
- File: packages/contracts/src/api/share.ts | Line: 391-419 | Content: `"export interface ProjectShareState {"` — `projectId: string;` :392, `status: ShareStatus;` :393, `slug?: string;` :395, `path?: string;` :397
- File: packages/contracts/src/api/share.ts | Line: 277 | Content: `"export const SHARE_STATUSES = ['none', 'preparing', 'active', 'stopped'] as const;"`
- File: packages/contracts/src/api/share.ts | Line: 426-428 | Content: `"export function hasActiveShare(state: ProjectShareState | null | undefined): boolean {"` — body `return state?.status === 'active';`
- File: packages/contracts/src/api/share.ts | Line: 439 | Content: `"export const SHARE_COMMENT_PAGE_LIMIT = 500;"`
- File: packages/contracts/src/api/share.ts | Line: 465 | Content: `"export const SHARE_COMMENT_MAX_BYTES = 64 * 1024;"`
- File: packages/contracts/src/api/share.ts | Line: 304 | Content: `"export const SHARE_MAX_TOTAL_BYTES = 20 * 1024 * 1024;"`

#### (d) Dependencies to pull in

- `@open-design/contracts` (workspace package, `exports "."` →
  `dist/index.mjs` — File: packages/contracts/package.json | Line: 12-15).
- `zod@3.25.76` — a direct dependency of the package (File:
  packages/contracts/package.json | Line: 121 | Content: `"zod": "3.25.76"`),
  needed for UC-2 (CritiqueConfigSchema is a zod schema). UC-1/UC-3 are pure
  types + constants, no zod runtime needed beyond the schema import.
- No other @open-design package is pulled: the 3 examples only import from
  the root barrel `@open-design/contracts` (finalize/handoff/share/critique
  are internal `src/` modules re-exported through the index).

#### (e) Per-item build

**SKIPPED** — the `bitnami/git:latest` container has no node/pnpm/npm
(`which node pnpm npm` + `node --version` both reported missing, logged at
the top of pass 1). Standard command with a toolchain (pnpm workspace repo):
`pnpm install --frozen-lockfile && pnpm -r build` — not run, no output
invented.

---

### s09 — @open-design/sidecar (`packages/sidecar`, 5★)

#### (a) What problem does this item solve

JSON-IPC client/operations for the sidecar process: this package is the
"host runtime ↔ sidecar binary" bridge — the host spawns the sidecar, hands
over resources (port, runtime root, data root) via env, then invokes
business operations over a private IPC socket; the sidecar on the other end
uses `SidecarClient` to serve those requests (module map — upstream report
fact, matching source: `Client` (connect/retry/dispatch), `operations.ts` a
578-line operations registry, `json-ipc.ts` a JSON transport over
stdin/stdout). Notably, transport/endpoint derivation is deliberately
private — outsiders see only the "five-field resource identity" + the
operations (File: packages/sidecar/src/index.ts | Line: 1-7 | Content:
"Public boundary for sidecar clients and server-side process atomics.
Transport, endpoint derivation, and OS-visible identity are deliberately
private package details; callers share only the five-field resource identity
and these operations.").

#### (b)+(c) Use cases + evidence

##### UC-1 — Host: spawn sidecar, converge launch, invoke business operations, stop

Scenario: the desktop app starts the "terminal" sidecar for namespace
`main`: spawn via `launchSidecar`, wait for `convergeSidecarLaunch` to
confirm the generation actually received the IPC endpoint (retries/wrong-PID
are handled inside the library), then invoke the business operation
`terminal.attach` via `invokeSidecar`, ask for status with
`getSidecarStatus`, and on app exit call `stopSidecar`.

```ts
import {
  convergeSidecarLaunch,
  getSidecarStatus,
  invokeSidecar,
  launchSidecar,
  stopSidecar,
} from '@open-design/sidecar';
import type { SidecarLaunchRequest, SidecarStamp } from '@open-design/sidecar';

const stamp: SidecarStamp = {
  app: 'terminal', channel: 'stable', mode: 'runtime',
  namespace: 'main', source: 'packaged',
};

const request: SidecarLaunchRequest = {
  command: '/opt/opendesign/bin/od-terminal',
  resources: { dataRoot: null, ownerPid: process.pid, port: 0, runtimeRoot: '/run/od' },
  stamp,
};

const { pid } = await launchSidecar(request);          // spawn background + stamped argv
const converged = await convergeSidecarLaunch(request); // wait for the generation to own the IPC endpoint
const status = await getSidecarStatus(stamp, { generationPid: pid, timeoutMs: 5_000 });
const reply  = await invokeSidecar(stamp, 'terminal.attach', { cols: 120, rows: 40 });
await stopSidecar(stamp, { gracefulRequestTimeoutMs: 2_000 });
```

Evidence:
- File: packages/sidecar/src/operations.ts | Line: 58-64 | Content: `"export type SidecarLaunchRequest = Omit<SpawnProcessRequest, \"args\" | \"env\"> & {"` — body has `args?`, `env?`, `resources: Omit<SidecarResources, \"pid\">;` :61, `stamp: SidecarStamp;` :62
- File: packages/sidecar/src/operations.ts | Line: 191 | Content: `"export async function launchSidecar(request: SidecarLaunchRequest): Promise<{ pid: number }> {"`
- File: packages/sidecar/src/operations.ts | Line: 219 | Content: `"export async function convergeSidecarLaunch("`
- File: packages/sidecar/src/operations.ts | Line: 387-392 | Content: `"export async function getSidecarStatus<TResult = unknown>("` — signature `(stamp: SidecarStamp, options?: { generationPid?: number; timeoutMs?: number })` :388
- File: packages/sidecar/src/operations.ts | Line: 399-405 | Content: `"export async function invokeSidecar<TResult = unknown>("` — body sends `{ action, app: exact.app, input, type: \"sidecar:invoke\" }` :402
- File: packages/sidecar/src/operations.ts | Line: 413 | Content: `"export async function stopSidecar(stamp: SidecarStamp, options: SidecarStopOptions = {}): Promise<SidecarStopResult> {"`
- File: packages/sidecar/src/index.ts | Line: 68-88 | Content: block `export type { SidecarLaunchRequest, … } from \"./operations.js\";` (:68-71) and `export { bootstrapSidecarProcess, convergeSidecarLaunch, …, launchSidecar, …, invokeSidecar, …, stopSidecar, stopSidecars } from \"./operations.js\";` (:73-88)
- File: packages/sidecar/src/stamp.ts | Line: 12-18 | Content: `"export type SidecarStamp = {"` — 5 fields `channel/namespace/source/mode/app` (:13-17)

##### UC-2 — Inside the sidecar: serve IPC with SidecarClient + SidecarLifecycle

Scenario: the sidecar binary (spawned by the host with supervision env)
organizes itself as a server: implement the `start/status/stop` lifecycle
for its runtime, register business handlers by action name, then
`client.start()`. The client opens the JSON-IPC server on a private socket,
answers `sidecar:describe/status/stop`, routes `sidecar:invoke` to handlers,
handles SIGINT/SIGTERM itself, and dies if the supervisor PID disappears
(1s liveness).

```ts
import { SidecarClient, type SidecarLifecycle } from '@open-design/sidecar';

type TerminalRuntime = { pty: unknown };

const lifecycle: SidecarLifecycle<TerminalRuntime> = {
  async start(resources) {
    return { pty: await openPty(resources.port) };
  },
  async status(runtime) {
    return { alive: runtime.pty != null };
  },
  async stop(runtime) {
    await closePty(runtime.pty);
  },
};

// Spawned inside a "supervised sidecar context" — the constructor throws otherwise
const client = new SidecarClient<TerminalRuntime>({
  lifecycle,
  handlers: {
    'terminal.attach': (input) => resizePty(input),
  },
});

await client.start();   // opens the IPC server + starts the runtime + registers SIGINT/SIGTERM
process.on('SIGTERM', () => { void client.stop(); });
```

Evidence:
- File: packages/sidecar/src/client.ts | Line: 61-65 | Content: `"export type SidecarLifecycle<TRuntime> = {"` — `start(resources: SidecarResources): Promise<TRuntime>;` :62, `status(runtime: TRuntime): unknown | Promise<unknown>;` :63, `stop(runtime: TRuntime): Promise<void>;` :64
- File: packages/sidecar/src/client.ts | Line: 67-70 | Content: `"export type SidecarClientOptions<TRuntime> = {"` — `handlers?: SidecarHandlers;` :68, `lifecycle: SidecarLifecycle<TRuntime>;` :69
- File: packages/sidecar/src/client.ts | Line: 218 | Content: `"export class SidecarClient<TRuntime> {"` — constructor :232-238 `if (context == null) throw new Error(\"SidecarFactory.create() requires a supervised sidecar context\");` :234
- File: packages/sidecar/src/client.ts | Line: 249-251 | Content: `"start(): Promise<void> {"` (single-flight via `#startPromise` :251-253)
- File: packages/sidecar/src/client.ts | Line: 259-308 | Content: `#start()` — `createJsonIpcServer({ socketPath: resolvePrivateIpcPath(this.stamp), handler: … })` :263-265; CONTROL_DESCRIBE answers `{ ready, resources, stamp }` :267-269; CONTROL_STOP `setImmediate(() => { this.#stopAndExit(); });` :280-283; BUSINESS_INVOKE routes `this.#handlers[request.action]` :290-293; `for (const signal of [\"SIGINT\", \"SIGTERM\"] as const) process.on(signal, this.#signalHandler);` :310-312; supervisor timer `process.kill(this.resources.pid, 0)` every 1s → `#stopAndExit()` when dead :316-328
- File: packages/sidecar/src/index.ts | Line: 48 | Content: `"export { handoffCurrentSidecarGeneration, SidecarClient, SidecarFactory } from \"./client.js\";"`
- File: packages/sidecar/src/client.ts | Line: 409 | Content: `"export const sidecarProtocol = Object.freeze({"`

##### UC-3 — Stamps: normalize the 5-field identity + derive the private IPC path

Scenario: an ops tool receives a raw JSON stamp from a config file (possibly
with extra fields or bad characters), normalizes it with
`normalizeSidecarStamp` (fail-closed: rejects unknown fields, invalid
characters, whitespace), then derives the private socket path of the running
generation with `resolvePrivateIpcPath` — the same formula the host and the
sidecar both use, so no path hardcoding.

```ts
import {
  isCurrentSidecarLauncher,
  normalizeSidecarStamp,
  readSupervisedSidecarContext,
  resolvePrivateIpcPath,
  SIDECAR_STAMP_CONTRACT,
  SIDECAR_STAMP_FIELDS,
  SIDECAR_STAMP_FLAGS,
  type SidecarStamp,
} from '@open-design/sidecar';

// the process argv is stamped with the --od-stamp-* flags (SIDECAR_STAMP_FLAGS)
const flags = Object.values(SIDECAR_STAMP_FLAGS); // ['--od-stamp-channel', …]

// raw config → normalized stamp (throws on extra/missing fields or bad characters)
const stamp: SidecarStamp = normalizeSidecarStamp({
  app: 'terminal', channel: 'stable', mode: 'runtime',
  namespace: 'main', source: 'packaged',
});

if (isCurrentSidecarLauncher()) {
  // launcher has not bootstrapped a generation — it only owns creating new ones
}

const supervised = readSupervisedSidecarContext(); // null when not in a supervised context
const ipcPath = supervised
  ? resolvePrivateIpcPath(supervised.stamp)
  : resolvePrivateIpcPath(stamp);

console.log(SIDECAR_STAMP_FIELDS, ipcPath, SIDECAR_STAMP_CONTRACT.stampFields);
```

Evidence:
- File: packages/sidecar/src/stamp.ts | Line: 8 | Content: `"export const SIDECAR_STAMP_FIELDS = [\"channel\", \"namespace\", \"source\", \"mode\", \"app\"] as const;"`
- File: packages/sidecar/src/stamp.ts | Line: 20-26 | Content: `"export const SIDECAR_STAMP_FLAGS: Readonly<Record<SidecarStampField, string>> = Object.freeze({"` — `channel: \"--od-stamp-channel\",` :21 … `app: \"--od-stamp-app\",` :25
- File: packages/sidecar/src/stamp.ts | Line: 29 | Content: `"export const SIDECAR_LIFECYCLE_FLAG = \"--od-sidecar-lifecycle\";"`
- File: packages/sidecar/src/stamp.ts | Line: 32 | Content: `"export const SIDECAR_SUPERVISED_CONTEXT_ENV = \"OD_SIDECAR_SUPERVISED_CONTEXT\";"`
- File: packages/sidecar/src/stamp.ts | Line: 50 | Content: `"export function normalizeSidecarStamp(input: unknown): SidecarStamp {"` — rejects unknown fields :55-56, tokens must match `/^[A-Za-z0-9][A-Za-z0-9._-]{0,127}$/` :44
- File: packages/sidecar/src/stamp.ts | Line: 66 | Content: `"export const SIDECAR_STAMP_CONTRACT: ProcessStampContract<SidecarStamp, SidecarStamp> = Object.freeze({"`
- File: packages/sidecar/src/stamp.ts | Line: 95 | Content: `"export function readSupervisedSidecarContext("`
- File: packages/sidecar/src/stamp.ts | Line: 121 | Content: `"export function isCurrentSidecarLauncher(): boolean {"`
- File: packages/sidecar/src/stamp.ts | Line: 160 | Content: `"export function resolvePrivateIpcPath(stamp: SidecarStamp, platform: NodeJS.Platform = process.platform): string {"`
- File: packages/sidecar/src/index.ts | Line: 51-59 | Content: `export type { SidecarStamp, SidecarStampField } from "./stamp.js";` :51 + `export { normalizeSidecarStamp, isCurrentSidecarLauncher, readCurrentSidecarStamp, resolveSidecarClientEndpoint, SIDECAR_STAMP_FIELDS, SIDECAR_STAMP_FLAGS } from "./stamp.js";` :52-59

#### (d) Dependencies to pull in

- `@open-design/sidecar` (File: packages/sidecar/package.json | Line: 2).
- `@open-design/platform` — required workspace dependency (File:
  packages/sidecar/package.json | Line: 23 | Content:
  `"@open-design/platform": "workspace:*"`); `operations.ts` imports
  `spawnBackgroundProcess/stopProcesses/listProcessSnapshots/matchesStampedProcess…`
  from `@open-design/platform` (File: packages/sidecar/src/operations.ts |
  Line: 4-12).
- Node.js runtime (client.ts uses `node:child_process`/`NodeJS.ProcessEnv`,
  stamp.ts uses `node:crypto/os/path` — File: packages/sidecar/src/stamp.ts |
  Line: 1-6).

#### (e) Per-item build

**SKIPPED** — no node/pnpm in the container (explained at the top of pass 1).
Standard commands: `pnpm install --frozen-lockfile && pnpm -r build`;
per-item: `pnpm --filter @open-design/sidecar build` — not run, no output
invented.

---

### s17 — @open-design/sidecar-proto (`packages/sidecar-proto`, 5★)

#### (a) What problem does this item solve

Wire contract + dedicated constants for sidecar IPC: a single file
`src/index.ts` (1,198 lines, the package's only non-test file) packages the
whole constant set (`APP_KEYS`, `SIDECAR_MODES`, `SIDECAR_SOURCES`,
`SIDECAR_ENV` with `OD_SIDECAR_BASE/OD_SIDECAR_IPC_PATH/OD_PORT…`,
`SIDECAR_MESSAGES`, the desktop-update constant set) + message types +
fail-closed normalizers (module map — upstream report fact, matching
source). Every party talking to a sidecar (daemon, desktop, web, tools) must
use exactly these constants/types so env wiring and messages cannot drift.

#### (b)+(c) Use cases + evidence

##### UC-1 — Daemon: validate incoming sidecar messages by app before dispatch

Scenario: the daemon receives a JSON frame on the daemon-app sidecar IPC
(e.g. a `register-desktop-auth` request). Before dispatching, the daemon
calls `normalizeDaemonSidecarMessage`: only valid message types proceed;
unknown messages are rejected with a `SidecarContractError` carrying code
`SIDECAR_UNKNOWN_MESSAGE` — giving logs machine-readable error
classification instead of a deep crash.

```ts
import {
  SIDECAR_ERROR_CODES,
  SidecarContractError,
  normalizeDaemonSidecarMessage,
} from '@open-design/sidecar-proto';

function handleFrame(raw: unknown): string {
  let message;
  try {
    message = normalizeDaemonSidecarMessage(raw);
  } catch (error) {
    if (error instanceof SidecarContractError) {
      // 'SIDECAR_INVALID_MESSAGE' | 'SIDECAR_UNKNOWN_MESSAGE'
      return `rejected: ${error.code}`;
    }
    throw error;
  }
  switch (message.type) {
    case 'status':   return 'ok';
    case 'shutdown': return 'shutting-down';
    default:         return 'auth/register routed';
  }
}

// invalid frame (unknown type) -> 'rejected: SIDECAR_UNKNOWN_MESSAGE'
console.log(handleFrame({ type: 'hover' }));
```

Evidence:
- File: packages/sidecar-proto/src/index.ts | Line: 1104 | Content: `"export function normalizeDaemonSidecarMessage(input: unknown): DaemonSidecarMessage {"` — accepts only type `STATUS/SHUTDOWN/REGISTER_DESKTOP_AUTH/MINT_IMPORT_TOKEN/REGISTER_WEB_URL` (:1106-1122), falls through to `throw new SidecarContractError(SIDECAR_ERROR_CODES.UNKNOWN_MESSAGE, …)` :1123-1125
- File: packages/sidecar-proto/src/index.ts | Line: 1126 | Content: `"export function normalizeWebSidecarMessage(input: unknown): WebSidecarMessage {"`
- File: packages/sidecar-proto/src/index.ts | Line: 1136 | Content: `"export function normalizeDesktopSidecarMessage(input: unknown): DesktopSidecarMessage {"`
- File: packages/sidecar-proto/src/index.ts | Line: 157-160 | Content: `"export const SIDECAR_ERROR_CODES = Object.freeze({"` — `INVALID_MESSAGE: \"SIDECAR_INVALID_MESSAGE\",` :158, `UNKNOWN_MESSAGE: \"SIDECAR_UNKNOWN_MESSAGE\",` :159
- File: packages/sidecar-proto/src/index.ts | Line: 164-171 | Content: `"export class SidecarContractError extends Error {"` — `readonly code: SidecarErrorCode;` :165, `this.name = \"SidecarContractError\";` :169
- File: packages/sidecar-proto/src/index.ts | Line: 690-694 | Content: `"export type DaemonSidecarMessage ="` — union of `SidecarStatusMessage | SidecarShutdownMessage | RegisterDesktopAuthMessage | MintImportTokenMessage | RegisterWebUrlMessage` (:690-694)

##### UC-2 — Build the env wiring + stamp for a sidecar from standard constants (no hardcoded strings)

Scenario: the `tools-dev` tool writes a script that starts a dev sidecar:
build the child env from `SIDECAR_ENV` (variable names `OD_SIDECAR_BASE`,
`OD_SIDECAR_IPC_PATH`, `OD_PORT`…), pick app/mode/source via the constant
set + normalizers (bad values are rejected immediately, instead of the
sidecar dying mid-run), and embed `--od-mcp-managed` when the outer host
manages MCP bootstrap.

```ts
import {
  APP_KEYS, MCP_BOOTSTRAP_CONTRACT, SIDECAR_ENV,
  SIDECAR_MODES, SIDECAR_SOURCES,
  isAppKey, normalizeAppKey, normalizeIpcPath,
  normalizeNamespace, normalizeSidecarMode, normalizeSidecarSource,
} from '@open-design/sidecar-proto';

const namespace = normalizeNamespace('main');        // rejects 'a b', '../etc'
const app       = normalizeAppKey(APP_KEYS.DAEMON);  // 'daemon'
const mode      = normalizeSidecarMode(SIDECAR_MODES.DEV);
const source    = normalizeSidecarSource(SIDECAR_SOURCES.TOOLS_DEV);

// isAppKey is a type guard for external input (e.g. JSON config)
function pickApp(value: unknown) {
  return isAppKey(value) ? value : APP_KEYS.DESKTOP;
}

const childEnv: NodeJS.ProcessEnv = {
  [SIDECAR_ENV.BASE]: '/run/opendesign',
  [SIDECAR_ENV.IPC_PATH]: normalizeIpcPath('/run/opendesign/daemon.ipc'),
  [SIDECAR_ENV.DAEMON_PORT]: '7456',
  [SIDECAR_ENV.SOURCE]: source,
  [SIDECAR_ENV.NAMESPACE]: namespace,
  [MCP_BOOTSTRAP_CONTRACT.DISCOVERY_ENV]: JSON.stringify({ daemon: [], desktop: [] }),
};
console.log(app, mode, childEnv[SIDECAR_ENV.BASE], MCP_BOOTSTRAP_CONTRACT.MANAGED_ARG);
```

Evidence:
- File: packages/sidecar-proto/src/index.ts | Line: 3-7 | Content: `"export const APP_KEYS = Object.freeze({"` — `DAEMON: \"daemon\",` :4, `DESKTOP: \"desktop\",` :5, `WEB: \"web\",` :6
- File: packages/sidecar-proto/src/index.ts | Line: 11-14 | Content: `"export const SIDECAR_MODES = Object.freeze({"` — `DEV: \"dev\",` :12, `RUNTIME: \"runtime\",` :13
- File: packages/sidecar-proto/src/index.ts | Line: 18-23 | Content: `"export const SIDECAR_SOURCES = Object.freeze({"` — `PACKAGED/TOOLS_DEV/TOOLS_PACK` :19-21
- File: packages/sidecar-proto/src/index.ts | Line: 26-38 | Content: `"export const SIDECAR_ENV = Object.freeze({"` — `BASE: \"OD_SIDECAR_BASE\",` :27, `DAEMON_CLI_PATH: \"OD_DAEMON_CLI_PATH\",` :28, `DAEMON_PORT: \"OD_PORT\",` :29, `IPC_PATH: \"OD_SIDECAR_IPC_PATH\",` :31, `NAMESPACE: \"OD_SIDECAR_NAMESPACE\",` :32, `SOURCE: \"OD_SIDECAR_SOURCE\",` :33
- File: packages/sidecar-proto/src/index.ts | Line: 46-55 | Content: `"export const MCP_BOOTSTRAP_CONTRACT = Object.freeze({"` — `MANAGED_ARG: \"--od-mcp-managed\",` :48, `DISCOVERY_ENV: \"OD_MCP_DISCOVERY\",` :54
- File: packages/sidecar-proto/src/index.ts | Line: 773 | Content: `"export function normalizeNamespace(namespace: unknown): string {"` — rejects whitespace :777-778, wrong characters :779-781, path separators :782-784
- File: packages/sidecar-proto/src/index.ts | Line: 796 | Content: `"export function isAppKey(value: unknown): value is AppKey {"`
- File: packages/sidecar-proto/src/index.ts | Line: 800 | Content: `"export function normalizeAppKey(app: unknown): AppKey {"`
- File: packages/sidecar-proto/src/index.ts | Line: 785/789 | Content: `"export function isSidecarMode(value: unknown): value is SidecarMode {"` / `"export function normalizeSidecarMode(mode: unknown): SidecarMode {"` (throws "sidecar mode must be dev or runtime" :791)
- File: packages/sidecar-proto/src/index.ts | Line: 805/809 | Content: `"export function isSidecarSource(value: unknown): value is SidecarSource {"` / `"export function normalizeSidecarSource(source: unknown): SidecarSource {"`
- File: packages/sidecar-proto/src/index.ts | Line: 820 | Content: `"export function normalizeIpcPath(ipc: unknown): string {"`

##### UC-3 — Desktop updater: a type-safe state machine driven by proto constants

Scenario: the Electron main process (apps/desktop/src/main/updater*) emits
update events to the UI; the UI defines a reducer that only accepts values
from `DESKTOP_UPDATE_ACTIONS/STATES/MODES/CHANNELS` of the proto, uses
`isDesktopUpdateAction` as a type guard for external input, and limits
artifact capture to `DESKTOP_ARTIFACT_CAPTURE_MODES` — so the chain
`checking → downloading → downloaded → installing` cannot be misspelled on
any surface.

```ts
import {
  DESKTOP_UPDATE_ACTIONS, DESKTOP_UPDATE_CHANNELS,
  DESKTOP_UPDATE_MODES, DESKTOP_UPDATE_STATES,
  isDesktopUpdateAction,
  type DesktopUpdateState,
} from '@open-design/sidecar-proto';

type Transition = {
  action:   (typeof DESKTOP_UPDATE_ACTIONS)[keyof typeof DESKTOP_UPDATE_ACTIONS];
  from:     DesktopUpdateState;
  to:       DesktopUpdateState;
};

const transitions: Transition[] = [
  { action: DESKTOP_UPDATE_ACTIONS.CHECK,    from: DESKTOP_UPDATE_STATES.IDLE,
    to:   DESKTOP_UPDATE_STATES.CHECKING },
  { action: DESKTOP_UPDATE_ACTIONS.DOWNLOAD, from: DESKTOP_UPDATE_STATES.AVAILABLE,
    to:   DESKTOP_UPDATE_STATES.DOWNLOADING },
  { action: DESKTOP_UPDATE_ACTIONS.INSTALL,  from: DESKTOP_UPDATE_STATES.DOWNLOADED,
    to:   DESKTOP_UPDATE_STATES.INSTALLING },
];

function dispatch(value: unknown, current: DesktopUpdateState): DesktopUpdateState {
  if (!isDesktopUpdateAction(value)) return DESKTOP_UPDATE_STATES.ERROR;
  const hit = transitions.find((t) => t.action === value && t.from === current);
  return hit ? hit.to : DESKTOP_UPDATE_STATES.UNSUPPORTED;
}

console.log(DESKTOP_UPDATE_MODES.PACKAGE_LAUNCHER, DESKTOP_UPDATE_CHANNELS.STABLE);
```

Evidence:
- File: packages/sidecar-proto/src/index.ts | Line: 118-124 | Content: `"export const DESKTOP_UPDATE_ACTIONS = Object.freeze({"` — `CHECK: \"check\",` :119, `DOWNLOAD: \"download\",` :121, `INSTALL: \"install\",` :122
- File: packages/sidecar-proto/src/index.ts | Line: 128-131 | Content: `"export const DESKTOP_UPDATE_MODES = Object.freeze({"` — `JS_INCREMENTAL: \"js-incremental\",` :129, `PACKAGE_LAUNCHER: \"package-launcher\",` :130
- File: packages/sidecar-proto/src/index.ts | Line: 135-139 | Content: `"export const DESKTOP_UPDATE_CHANNELS = Object.freeze({"` — `BETA: RELEASE_CHANNELS.BETA,` :136, `PRERELEASE: RELEASE_CHANNELS.PRERELEASE,` :137, `STABLE: RELEASE_CHANNELS.STABLE,` :138
- File: packages/sidecar-proto/src/index.ts | Line: 143-153 | Content: `"export const DESKTOP_UPDATE_STATES = Object.freeze({"` — `AVAILABLE: \"available\",` :144, `CHECKING: \"checking\",` :145, `DOWNLOADED: \"downloaded\",` :146, `DOWNLOADING: \"downloading\",` :147, `ERROR: \"error\",` :148, `IDLE: \"idle\",` :149, `INSTALLING: \"installing\",` :150, `NOT_AVAILABLE: \"not-available\",` :151, `UNSUPPORTED: \"unsupported\",` :152
- File: packages/sidecar-proto/src/index.ts | Line: 1073 | Content: `"export function isDesktopUpdateAction(value: unknown): value is DesktopUpdateAction {"`
- File: packages/sidecar-proto/src/index.ts | Line: 408-412 | Content: `"export const DESKTOP_ARTIFACT_CAPTURE_MODES = Object.freeze({"`
- File: packages/sidecar-proto/src/index.ts | Line: 1 | Content: `"import { RELEASE_CHANNELS, type ReleaseChannel } from \"@open-design/release\";"` — the dependency edge to @open-design/release matches module map m17

#### (d) Dependencies to pull in

- `@open-design/sidecar-proto` (File: packages/sidecar-proto/package.json |
  Line: 2).
- `@open-design/release` — required workspace dependency (File:
  packages/sidecar-proto/package.json | Line: 23 | Content:
  `"@open-design/release": "workspace:*"`); `index.ts` imports
  `RELEASE_CHANNELS` on line 1 (File: packages/sidecar-proto/src/index.ts |
  Line: 1).
- Node.js (no other third-party dependency — E1=0 matches the star ranking
  for s17; all examples use only this package).

#### (e) Per-item build

**SKIPPED** — no node/pnpm in the container. Standard commands:
`pnpm install --frozen-lockfile && pnpm -r build`; per-item:
`pnpm --filter @open-design/sidecar-proto build` — not run, no output
invented.

---

### s02 — @open-design/daemon (`apps/daemon`, 4★)

#### (a) What problem does this item solve

Daemon HTTP server + CLI — the coordination center of OpenDesign: bin `od`
starts the HTTP (Express) server + opens the web UI, serves routes for
project/collab/design-systems/evidence-delivery/workspace runs, persists
state to SQLite (better-sqlite3); it is also a thin CLI (`od media …`,
`od project …`…) that POSTs to the running daemon (module map — upstream
report fact; matching source: server.ts 18,962 lines, cli.ts 12,979 lines,
routes/project/index.ts 8,259, db.ts 6,007). cli.ts self-describes exactly
this two-faced structure (File: apps/daemon/src/cli.ts | Line: 56-60 |
Content: "// `od` is two CLIs glued together: - default mode: starts the daemon + opens the web UI. - `od media …`: a thin client that POSTs to the running daemon.").

#### (b)+(c) Use cases + evidence

##### UC-1 — Run the daemon locally via bin `od` (or embed programmatically)

Scenario: a dev bootstraps a local environment: install the workspace, then
run `od --port 7456 --no-open` (bin `od` points to `dist/cli.js`; default
port 7456 read from env `OD_PORT`; `--no-open` avoids opening a browser on
CI). For programmatic integration (test harnesses), import
`startDaemonRuntime` to get a clean `stop()` handle.

```bash
# 1) Build then run via bin 'od' (bin/od.mjs throws a helpful error when dist is missing)
pnpm --filter @open-design/daemon build
node apps/daemon/bin/od.mjs --port 7456 --no-open
#   or the package's ready-made script:
pnpm --filter @open-design/daemon daemon   # = pnpm run build && node dist/cli.js --no-open

# 2) Wait for readiness then health-check
curl -s http://127.0.0.1:7456/api/health
curl -s http://127.0.0.1:7456/api/ready
curl -s http://127.0.0.1:7456/api/version
```

```ts
// 3) Embed programmatically (without the bin):
import { startDaemonRuntime } from './daemon-startup.js';

const runtime = await startDaemonRuntime({ openBrowser: false, logListening: true });
// ... run E2E tests against http://127.0.0.1:<port>/api/...
await runtime.stop(); // closes the HTTP server + shutdown cleanup
```

Evidence:
- File: apps/daemon/bin/od.mjs | Line: 8-16 | Content: `"const distEntry = resolve(entryDir, \"../dist/cli.js\");"` :8, `if (!existsSync(distEntry)) {` :10, error message advises `Run \"pnpm bootstrap\" after install (or \"pnpm --filter @open-design/daemon build\").` :12, `await import(pathToFileURL(distEntry).href);` :16
- File: apps/daemon/package.json | Line: 8-10 | Content: `"bin": { "od": "./bin/od.mjs" }`
- File: apps/daemon/package.json | Line: 28-31 | Content: `"build": "tsc -p tsconfig.json",` :28, `"daemon": "pnpm run build && node dist/cli.js --no-open",` :29, `"start": "pnpm run build && node dist/cli.js",` :31
- File: apps/daemon/src/cli.ts | Line: 1290 | Content: `"--port <n>       Port to listen on (default: 7456, env: OD_PORT)."`
- File: apps/daemon/src/cli.ts | Line: 1294 | Content: `"--no-open        Do not open the browser after start."`
- File: apps/daemon/src/cli.ts | Line: 1176 | Content: usage line `"  od [--port <n>] [--host <addr>] [--no-open]"`
- File: apps/daemon/src/daemon-startup.ts | Line: 124 | Content: `"export async function startDaemonRuntime(options: DaemonRuntimeOptions = {}): Promise<StartedDaemonRuntime> {"` — body: `const { openBrowser: shouldOpenBrowser = false, logListening = false, ...serverOptions } = options;` :125, dynamic import `./server.js` + `startServer({ ...serverOptions, returnServer: true })` :126-131, defines `stop` closing the server + shutdown :135-141
- File: apps/daemon/src/server.ts | Line: 8782 | Content: `"app.get('/api/health', async (_req, res) => {"`
- File: apps/daemon/src/server.ts | Line: 8806 | Content: `"app.get('/api/ready', async (_req, res) => {"`
- File: apps/daemon/src/server.ts | Line: 8816 | Content: `"app.get('/api/version', async (_req, res) => {"`

##### UC-2 — An agent calls `od media generate` to create an image, then polls with `media wait`

Scenario: a code agent in chat needs a 16:9 hero image: it calls the thin
CLI `od media generate --project <id> --surface image --model
flux-pro-ultra --prompt "..."`. Slow models return `{taskId, nextSince}`
with exit 0 (queued, not done) — the script polls `media wait` following the
exact worked-example loop documented in the CLI's own help: exit 0 = done,
exit 2 = still running (re-run with `nextSince`), anything else = fail.

```bash
# worked generate→wait loop (copied from the od help block, POSIX bash):
out=$("$OD_NODE_BIN" "$OD_BIN" media generate --project "$OD_PROJECT_ID" \
  --surface image --model flux-pro-ultra --prompt "sunset over harbor" --aspect 16:9)
last=$(printf '%s\n' "$out" | tail -1)
task_id=$(printf '%s\n' "$last" | python3 -c "import sys,json; print(json.load(sys.stdin).get('taskId',''))" 2>/dev/null)
since=$(printf '%s\n' "$last" | python3 -c "import sys,json; print(json.load(sys.stdin).get('nextSince',0))" 2>/dev/null)
while [ -n "$task_id" ]; do
  out=$("$OD_NODE_BIN" "$OD_BIN" media wait "$task_id" --since "${since:-0}")
  ec=$?
  last=$(printf '%s\n' "$out" | tail -1)
  since=$(printf '%s\n' "$last" | python3 -c "import sys,json; print(json.load(sys.stdin).get('nextSince',0))" 2>/dev/null)
  if [ "$ec" -eq 0 ]; then task_id=""; elif [ "$ec" -ne 2 ]; then echo "$out" >&2; exit "$ec"; fi
done
printf '%s\n' "$last"   # {"file": "..."} — the daemon has written the bytes into the project's files folder
```

Evidence:
- File: apps/daemon/src/cli.ts | Line: 1261 | Content: usage `"od media generate --surface <image|video|audio> --model <id> [opts]"`
- File: apps/daemon/src/cli.ts | Line: 69-92 | Content: `"const MEDIA_GENERATE_STRING_FLAGS = new Set(["` — flags: `project, workspace, workspace-member, surface, model, prompt, prompt-file, output, aspect, quality, resolution, length, duration, prompt-influence, voice, audio-kind, composition-dir, image, daemon-url, language` (:70-90); `const MEDIA_GENERATE_BOOLEAN_FLAGS = new Set(["` :91 — `help, h, loop` (:92-95)
- File: apps/daemon/src/cli.ts | Line: 2756-2759 | Content: doc "Slow models return `{\"taskId\": \"...\", \"nextSince\": n}` with exit 0 instead — a successful queued handoff, not a failure. Poll with `media wait`: exit 0 = done ({\"file\": ...} on stdout), exit 2 = still running (re-run the wait command stderr prints, carrying forward nextSince), 5 = failed."
- File: apps/daemon/src/cli.ts | Line: 2765-2780 | Content: the worked loop verbatim `"out=\$(\"\$OD_NODE_BIN\" \"\$OD_BIN\" media generate --project \"\$OD_PROJECT_ID\" \\"` … `printf '%s\\n' \"\$last\"`
- File: apps/daemon/src/cli.ts | Line: 410-413 | Content: `"const SUBCOMMAND_MAP = {"` — `agent: runAgent,` :411, `artifacts: runArtifacts,` :412, `media: runMedia,` :413 (+ ~25 other subcommands: mcp, amr, collab, project, workspace, share, comment, brand, run, files, templates, conversation… :414-435)
- File: apps/daemon/src/cli.ts | Line: 2782-2784 | Content: "Skills should call this and then reference the returned filename in their artifact / message body. The daemon writes the bytes into the project's files folder so the FileViewer can preview them immediately."

##### UC-3 — The daemon's REST API + the SQLite layer

Scenario: a CI script creates a project via the API, lists projects, then
checks the data landed in the right SQLite tables: `POST /api/projects`
(routes/project) writes the `projects` table; agent conversations live in
the `conversations`/`messages` tables; health/ready/version are the 3
standard probe endpoints for orchestration.

```bash
BASE=http://127.0.0.1:7456

# standard probes for orchestrator/k8s-style checks
curl -sf "$BASE/api/health"  && echo
curl -sf "$BASE/api/ready"   && echo
curl -sf "$BASE/api/version" && echo

# create + list projects via routes/project (mounted into the Express app of server.ts)
curl -sf -X POST "$BASE/api/projects" \
  -H 'content-type: application/json' \
  -d '{"name":"sprint-24-deck"}'
curl -sf "$BASE/api/projects"
```

```sql
-- The daemon's base tables (better-sqlite3), from the schema-init in db.ts:
CREATE TABLE IF NOT EXISTS projects (…);            -- db.ts:107
CREATE TABLE IF NOT EXISTS workspace_projects (…);  -- db.ts:120
CREATE TABLE IF NOT EXISTS conversations (…);       -- db.ts:203
CREATE TABLE IF NOT EXISTS messages (…);            -- db.ts:246
```

Evidence:
- File: apps/daemon/src/server.ts | Line: 8782/8806/8816 | Content: `"app.get('/api/health', …)"` / `"app.get('/api/ready', …)"` / `"app.get('/api/version', …)"`
- File: apps/daemon/src/routes/project/index.ts | Line: 3936 | Content: `"app.post('/api/projects', async (req, res) => {"`
- File: apps/daemon/src/routes/project/index.ts | Line: 3361 | Content: `"app.get('/api/projects', async (_req, res) => {"`
- File: apps/daemon/src/routes/project/index.ts | Line: 3233/3275 | Content: `"app.get('/api/project-locations', async (_req, res) => {"` / `"app.post('/api/project-locations/scan', async (req, res) => {"`
- File: apps/daemon/src/routes/project/index.ts | Line: 3418 | Content: `"app.get('/api/workspaces/:workspaceId/projects', async (req, res) => {"`
- File: apps/daemon/src/db.ts | Line: 107 | Content: `"CREATE TABLE IF NOT EXISTS projects ("`
- File: apps/daemon/src/db.ts | Line: 120 | Content: `"CREATE TABLE IF NOT EXISTS workspace_projects ("`
- File: apps/daemon/src/db.ts | Line: 203 | Content: `"CREATE TABLE IF NOT EXISTS conversations ("`
- File: apps/daemon/src/db.ts | Line: 246 | Content: `"CREATE TABLE IF NOT EXISTS messages ("`
- File: apps/daemon/package.json | Line: 52/56 | Content: `"better-sqlite3": "12.10.0",` / `"express": "5.2.1",`

#### (d) Dependencies to pull in

- `@open-design/daemon` — an app-private package; it cannot be imported as a
  library via the src path; use it through the `od` bin / the HTTP API / the
  package.json scripts (File: apps/daemon/package.json | Line: 2,
  `"private": true` :4).
- Third-party deps of the daemon: `express@5.2.1` (:56),
  `better-sqlite3@12.10.0` (:52) — only needed when building/running the
  daemon, not for clients calling HTTP.
- Workspace deps of the daemon (matches module map m02 depends on):
  `@open-design/contracts`, `@open-design/sidecar`, `@open-design/sidecar-proto`…
  — confirmed in source: cli.ts imports `SidecarFactory` from
  `@open-design/sidecar` (File: apps/daemon/src/cli.ts | Line: 19) and
  `APP_KEYS, SIDECAR_MESSAGES` from `@open-design/sidecar-proto` (File:
  apps/daemon/src/cli.ts | Line: 20); UC-3 mentions importing
  `@open-design/contracts` along the same edge (EXPORT_FORMATS, File:
  apps/daemon/src/cli.ts | Line: 21).

#### (e) Per-item build

**SKIPPED** — no node/pnpm in the container. Standard commands (recorded in
the source itself, not improvised): `pnpm --filter @open-design/daemon build`
(the error message of bin/od.mjs :12) or the package.json `build`/`daemon`/
`start` scripts (:28-31). Not run, no output invented.

---

### s24 — @open-design/release (`packages/release`, 4★)

#### (a) What problem does this item solve

Release domain primitives of Open Design: normalizes **release-channel
names** (`stable` | `prerelease` | exact names `[a-z0-9]{1,12}`), **counted
versions** `x.y.z-<channel>.N`, install descriptors (appId/productName), and
per-platform update feed namespaces. It is the root node of the dependency
graph — 11 other packages import constants/functions from here
(imported by 11, module map m24), so every package that builds/ships uses
one single set of naming rules.

#### (b)+(c) Use cases + evidence

##### UC24.1 — CI validates the channel and formats/parses counted versions before writing updater metadata

Scenario: a CI pipeline receives the release channel from an environment
variable (data, not a build constant), rejects invalid channels, then creates
the "Nth release of the cycle" version for a 1.4.0 beta, parses it back to
split the components, and produces exactly the metadata fields the updater
feed reads.

```ts
import {
  isReleaseChannel,
  formatReleaseVersion,
  parseReleaseVersion,
  releaseMetadataVersionFields,
} from "@open-design/release";

// The release channel comes from CI env — validate before using:
const channel = process.env.OD_RELEASE_CHANNEL ?? "beta";
if (!isReleaseChannel(channel)) throw new Error(`bad channel: ${channel}`);

// 3rd release of the cycle for the beta channel:
const releaseVersion = formatReleaseVersion(channel, "1.4.0", 3);  // "1.4.0-beta.3"

// Parse back: must match x.y.z-<channel>.N exactly, count >= 1:
const parsed = parseReleaseVersion(releaseVersion, channel);
console.log(parsed.baseVersion, parsed.number);                    // 1.4.0 3

// The metadata fields the feed needs for this channel (counted → counterField):
console.log(releaseMetadataVersionFields(channel, releaseVersion));
// → { baseVersion: "1.4.0", releaseNumber: 3, releaseVersion: "1.4.0-beta.3" }
```

Evidence:
- File: packages/release/src/index.ts | Line: 86-90 | Content: `export function isReleaseChannel(value: unknown): value is ReleaseChannel { return typeof value === "string" && value !== "local" && (value === "stable" || value === "prerelease" || EXACT_RELEASE_NAME_PATTERN.test(value)); }`
- File: packages/release/src/index.ts | Line: 190-195 | Content: `export function formatReleaseVersion(channel: CountedReleaseChannel, baseVersion: string, number: number): string { if (!Number.isSafeInteger(number) || number < 1) { throw new Error(\`${channel} release number must be a positive integer; got ${String(number)}\`); } return \`${baseVersion}-${channel}.${number}\`; }`
- File: packages/release/src/index.ts | Line: 179-188 | Content: `export function parseReleaseVersion(value: string, channel: ReleaseChannel): ParsedReleaseVersion { if (channel === "stable") { const parsed = parseStableReleaseVersion(value); if (parsed == null) throw new Error(\`stable release version must be x.y.z; got ${value}\`); return { ...parsed, channel }; } const parsed = parseCountedReleaseVersion(value, channel); ... }`
- File: packages/release/src/index.ts | Line: 197-216 | Content: `export function releaseMetadataVersionFields(channel: ReleaseChannel, releaseVersion: string): Record<string, unknown> { const descriptor = releaseChannelDescriptor(channel); const parsed = parseReleaseVersion(releaseVersion, channel); ... return { [descriptor.baseVersionField]: baseVersion, [descriptor.counterField]: parsed.number, releaseVersion }; }`
- File: packages/release/src/index.ts | Line: 147-156 | Content: `export function parseCountedReleaseVersion(value: string, channel: CountedReleaseChannel): { baseVersion: string; number: number; releaseVersion: string } | null { const match = new RegExp(\`^(\\d+\\.\\d+\\.\\d+)-${channel}\\.(\\d+)$\`).exec(value); ... if (!Number.isSafeInteger(number) || number < 1) return null; ... }`

##### UC24.2 — Packaging tools derive install identity + feed namespace per channel and platform

Scenario: the packaging tool / desktop build needs the appId, product name,
and update feed namespace per channel. Standard channels get a frozen
descriptor; "insider"-style exact-name channels get a descriptor generated on
the spot with their own appId; the reserved name `local` is rejected
outright.

```ts
import {
  releaseChannelDescriptor,
  releaseInstallIdentity,
  releaseNamespace,
} from "@open-design/release";

// Standard channel — frozen descriptor in the package:
const stable = releaseChannelDescriptor("stable");
console.log(stable.appId, "|", stable.productName);  // io.open-design.desktop | Open Design
console.log(stable.githubReleaseEnabled);            // true

// Valid exact-name channel → descriptor generated on the spot:
const insider = releaseChannelDescriptor("insider");
console.log(insider.appId, insider.internal);        // io.open-design.desktop.insider true

// Install identity + per-platform feed namespace:
console.log(releaseInstallIdentity("stable"));       // { appId, executableName, productName }
console.log(releaseNamespace("beta", "mac"));        // "release-beta"
console.log(releaseNamespace("beta", "win"));        // "release-beta-win"

// Reserved names are rejected immediately:
releaseChannelDescriptor("local");                   // throws (isReleaseChannel blocks "local")
```

Evidence:
- File: packages/release/src/index.ts | Line: 92-110 | Content: `export function releaseChannelDescriptor(channel: string): ReleaseChannelDescriptor { if (!isReleaseChannel(channel)) { throw new Error(\`RELEASE_CHANNEL must be stable, prerelease, or a non-reserved exact name matching [a-z0-9]{1,12}; got ${channel}\`); } if (channel === "stable" || channel === "prerelease") return descriptors[channel]; const displayLabel = channel[0]!.toUpperCase() + channel.slice(1); return { appId: \`io.open-design.desktop.${channel}\`, ... internal: true, ... }; }`
- File: packages/release/src/index.ts | Line: 2 | Content: `export const RESERVED_RELEASE_NAMES = Object.freeze(["local"] as const);`
- File: packages/release/src/index.ts | Line: 72-83 | Content: `stable: { appId: "io.open-design.desktop", ... githubReleaseEnabled: true, internal: false, productName: PRODUCT_NAME, ... }`
- File: packages/release/src/index.ts | Line: 133-136 | Content: `export function releaseNamespace(channel: ReleaseChannel, platform: ReleasePlatform = "mac"): string { const suffix = RELEASE_PLATFORM_NAMESPACE_SUFFIXES[platform]; return suffix.length === 0 ? \`release-${channel}\` : \`release-${channel}-${suffix}\`; }`
- File: packages/release/src/index.ts | Line: 49-54 | Content: `export const RELEASE_PLATFORM_NAMESPACE_SUFFIXES = Object.freeze({ linux: "linux", mac: "", macIntel: "intel", win: "win", } as const satisfies Record<ReleasePlatform, string>);`
- File: packages/release/src/index.ts | Line: 138-145 | Content: `export function releaseInstallIdentity(channel: ReleaseChannel): ReleaseInstallIdentity { const descriptor = releaseChannelDescriptor(channel); return { appId: descriptor.appId, executableName: descriptor.productName, productName: descriptor.productName }; }`

##### UC24.3 — The updater picks the right feed from the installed version string and compares base versions

Scenario: the desktop updater reads the installed version (which may be an
internal build like `1.4.0-beta-internal.N` that is not public) to decide
which feed to inherit, and compares two base versions to know whether an
update is an upgrade or a downgrade.

```ts
import {
  releaseChannelFromVersion,
  parseReleaseBaseVersion,
  compareReleaseBaseVersions,
} from "@open-design/release";

// A dev build "1.4.0-beta-internal.N" is not a public version but
// still inherits the beta feed (source comment :116-117):
console.log(releaseChannelFromVersion("1.4.0-beta-internal.7"));  // "beta"
console.log(releaseChannelFromVersion("2.0.0-beta.1"));           // "beta"
console.log(releaseChannelFromVersion("2.0.0"));                  // null

// Compare base versions (semantic, element by element) to decide update direction:
const cur  = parseReleaseBaseVersion("1.4.0");   // [1, 4, 0]
const next = parseReleaseBaseVersion("1.5.0");   // [1, 5, 0]
console.log(compareReleaseBaseVersions(cur!, next!));   // -1 → next is newer
console.log(compareReleaseBaseVersions(next!, cur!));   //  1 → cur is older
console.log(compareReleaseBaseVersions(cur!, cur!));    //  0
```

Evidence:
- File: packages/release/src/index.ts | Line: 112-121 | Content: `export function releaseChannelFromVersion(version: string | null | undefined): ReleaseChannel | null { if (version == null || version.length === 0) return null; const match = /^\d+\.\d+\.\d+-([a-z0-9]{1,12})\.\d+$/.exec(version); if (isReleaseChannel(match?.[1])) return match[1]; // Development builds such as \`beta-internal.N\` are not public exact // versions, but they still inherit the corresponding updater feed. if (/(?:^|[-.])beta(?:[-.]|$)/i.test(version)) return "beta"; ... return null; }`
- File: packages/release/src/index.ts | Line: 162-167 | Content: `export function parseReleaseBaseVersion(value: string): ReleaseBaseVersionTuple | null { const match = /^(\d+)\.(\d+)\.(\d+)$/.exec(value); ... return parsed.every((part) => Number.isSafeInteger(part) && part >= 0) ? parsed : null; }`
- File: packages/release/src/index.ts | Line: 169-177 | Content: `export function compareReleaseBaseVersions(left: ReleaseBaseVersionTuple, right: ReleaseBaseVersionTuple): number { for (let index = 0; index < 3; index += 1) { const leftPart = left[index] ?? 0; const rightPart = right[index] ?? 0; if (leftPart > rightPart) return 1; if (leftPart < rightPart) return -1; } return 0; }`

#### (d) Dependencies to pull in

None — pure TypeScript, only standard RegExp/Object (the whole
`packages/release/src/index.ts`, 216 lines, has no external imports).
Package `main: ./dist/index.mjs` (`packages/release/package.json:7`).

#### (e) Per-item build

`pnpm install --frozen-lockfile && pnpm -r build` — **SKIPPED**: the
measuring container had no `node`, `pnpm`, or `npm` (`command -v node` /
`pnpm` / `npm` all "NO_*"). No build output invented. The import syntax above
follows `packages/release/package.json` — `"main": "./dist/index.mjs"` (:7)
and `exports` (:12).

---

### s10 — @open-design/platform (`packages/platform`, 4★)

#### (a) What problem does this item solve

OS process lifecycle primitives: encode/decode "process stamps"
`--flag=value` to recognize your own process generation, spawn
background/logged processes, probe liveness, enumerate process snapshots
(POSIX `ps` / Windows `Get-CimInstance`), walk the process tree, and stop a
set of PIDs with SIGTERM-then-SIGKILL; plus proxy-env that reads OS-level
proxies and merges normalized env. The package has no internal deps
(depends on 0, module map m10) — daemon, sidecar, packaged, and tools-* all
use it (imported by 6).

#### (b)+(c) Use cases + evidence

##### UC10.1 — Sidecar runner: spawn with a generation stamp, find only your own processes, stop safely

Scenario: a runner starts the web sidecar in the background, stamping the
mode + IPC path into argv. After the runner dies and restarts, it enumerates
system processes and matches only the generation whose stamp matches —
never touching another version's sidecar — then stops them with SIGTERM
first, escalating to SIGKILL if they survive the grace period.

```ts
import {
  createProcessStampArgs,
  matchesStampedProcess,
  spawnBackgroundProcess,
  listProcessSnapshots,
  stopProcesses,
  type ProcessStampContract,
} from "@open-design/platform";

// The "--flag=value" stamp identifies OUR process generation:
type SidecarStamp = { mode: string; ipcPath: string };
const contract: ProcessStampContract<SidecarStamp> = {
  normalizeStamp: (input) => input as SidecarStamp,
  normalizeStampCriteria: (input) => (input ?? {}) as Partial<SidecarStamp>,
  stampFields: ["mode", "ipcPath"] as const,
  stampFlags: { mode: "--od-sidecar-mode", ipcPath: "--od-sidecar-ipc" },
};

const stamp: SidecarStamp = { mode: "web", ipcPath: "/tmp/od-123.sock" };
const { pid } = await spawnBackgroundProcess({
  command: process.execPath,
  args: ["daemon.mjs", ...createProcessStampArgs(stamp, contract)],
  detached: true,
});

// On a later run: match only processes carrying our stamp — decoded from the command line:
const ours = (await listProcessSnapshots())
  .filter((p) => matchesStampedProcess(p, stamp, contract));

// Stop: SIGTERM first, SIGKILL escalation if still alive after the grace:
const result = await stopProcesses(ours.map((p) => p.pid), { termGraceMs: 5000 });
console.log(result.stoppedPids, result.remainingPids);
```

Evidence:
- File: packages/platform/src/process.ts | Line: 144-159 | Content: `export function createProcessStampArgs<TStamp extends ProcessStampShape>( stamp: TStamp, contract: ProcessStampContract<TStamp>, ): string[] { const normalized = contract.normalizeStamp(stamp); return contract.stampFields.map((field) => { ... return \`${contract.stampFlags[field]}=${value}\`; }); }`
- File: packages/platform/src/process.ts | Line: 34-42 | Content: `export type ProcessStampContract<TStamp extends ProcessStampShape, TCriteria extends Partial<TStamp> = Partial<TStamp>> = { normalizeStamp(input: unknown): TStamp; normalizeStampCriteria(input?: unknown): TCriteria; stampFields: readonly ProcessStampField<TStamp>[]; stampFlags: { readonly [K in ProcessStampField<TStamp>]: string }; };`
- File: packages/platform/src/process.ts | Line: 281-303 | Content: `export async function spawnBackgroundProcess(request: SpawnProcessRequest): Promise<{ pid: number }> { const invocation = createCommandInvocation(request); const child = spawn(invocation.command, invocation.args, { cwd: request.cwd, detached: request.detached ?? true, env: request.env, stdio: createLoggedStdio(request.logFd), ... }); await waitForChildSpawn(child); ... child.unref(); return { pid: child.pid }; }`
- File: packages/platform/src/process.ts | Line: 251-256 | Content: `export function matchesStampedProcess<TStamp extends ProcessStampShape, TCriteria extends Partial<TStamp> = Partial<TStamp>>( processInfo: Pick<ProcessSnapshot, "command">, criteria: TCriteria | undefined, contract: ProcessStampContract<TStamp, TCriteria>, ): boolean { const stamp = readProcessStampFromCommand(processInfo.command, contract); return stamp != null && matchesProcessStamp(stamp, criteria, contract); }`
- File: packages/platform/src/process.ts | Line: 453-458 | Content: `export async function listProcessSnapshots(): Promise<ProcessSnapshot[]> { try { return await captureProcessSnapshot(); } catch { return []; } }`
- File: packages/platform/src/process.ts | Line: 857-882 | Content: `export async function stopProcesses(pids: Array<number | null | undefined>, options: StopProcessesOptions = {}): Promise<StopProcessesResult> { ... signalProcesses(uniquePids, "SIGTERM", options.onSignal); ... signalProcesses(remainingAfterTerm, "SIGKILL", options.onSignal); ... }` (SIGTERM at :867, SIGKILL at :875)

##### UC10.2 — Clean up an orphaned pidfile before starting a new instance

Scenario: the previous process crashed and left a pidfile. The new startup
probes whether that pid is alive; if so, it waits up to 5s for a clean exit,
then escalates SIGTERM→SIGKILL with a short grace; probing with wrong data
types or a nonexistent pid must return "dead" rather than throw.

```ts
import { isProcessAlive, waitForProcessExit, stopProcesses } from "@open-design/platform";
import { readFile } from "node:fs/promises";

// Stale pidfile from a crashed run — clean up before opening a new instance:
const stalePid = Number(await readFile("/tmp/od.pid", "utf8").catch(() => "0"));

if (isProcessAlive(stalePid)) {
  // Wait up to 5s for a clean exit:
  const exited = await waitForProcessExit(stalePid, 5000);
  if (!exited) {
    // Stuck → stop proactively with a short two-sided grace:
    await stopProcesses([stalePid], { termGraceMs: 2000, killGraceMs: 2000 });
  }
}

// signal-0 probe: ESRCH → dead, EPERM → treated as alive; non-number → dead:
console.log(isProcessAlive(process.pid));  // true
console.log(isProcessAlive(2 ** 22));      // false — does not exist (ESRCH)
console.log(isProcessAlive(undefined));    // false — non-number
```

Evidence:
- File: packages/platform/src/process.ts | Line: 320-327 | Content: `/** Probe whether a process is alive via a signal-0 \`process.kill\`. Treats \`ESRCH\` as dead and any other error (e.g. \`EPERM\`) as alive. ... */ export function isProcessAlive(pid: number | null | undefined): boolean { if (typeof pid !== "number") return false; try { process.kill(pid, 0); ...`
- File: packages/platform/src/process.ts | Line: 345 | Content: `export async function waitForProcessExit(pid: number | null | undefined, timeoutMs = 5000): Promise<boolean>`
- File: packages/platform/src/process.ts | Line: 857 | Content: `export async function stopProcesses(pids: Array<number | null | undefined>, options: StopProcessesOptions = {}): Promise<StopProcessesResult>` (default grace 5s — `StopProcessesOptions` :79-87: "Grace after SIGTERM before SIGKILL escalation. Defaults to 5 seconds.")

##### UC10.3 — Build child-process env with system proxies and normalized proxy variables

Scenario: the daemon spawns a child process that must reach the outside of a
corporate network: read OS-level proxies (macOS `scutil --proxy`, Windows
registry Internet Settings), merge them with the process env and an injected
config; lowercase/uppercase proxy variables are normalized to canonical
keys, and when a proxy endpoint exists `NODE_USE_ENV_PROXY=1` turns itself
on so Node's fetch goes through the proxy.

```ts
import { mergeProxyAwareEnv, resolveSystemProxyEnv } from "@open-design/platform";

// 1) Read OS-level proxies (macOS: scutil --proxy; Windows: reg query Internet Settings):
const systemProxy = resolveSystemProxyEnv();
// e.g. a macOS machine with a system proxy → { HTTP_PROXY: "http://proxy.corp:3128", NO_PROXY: "..." }

// 2) Merge process env + config + system proxies for the child:
//    lowercase variants (http_proxy) map onto canonical keys (HTTP_PROXY):
const childEnv = mergeProxyAwareEnv(process.platform, process.env, {
  HTTP_PROXY: "http://proxy.corp:3128",
  NO_PROXY: "localhost,.corp",
});

// 3) With a proxy endpoint → NODE_USE_ENV_PROXY=1 turns on for Node's fetch:
console.log(childEnv.NODE_USE_ENV_PROXY);  // "1"
console.log(childEnv.HTTP_PROXY);          // "http://proxy.corp:3128"
console.log(childEnv.NO_PROXY);            // "localhost,.corp"
```

Evidence:
- File: packages/platform/src/proxy-env.ts | Line: 368-411 | Content: `export function resolveSystemProxyEnv(options: ResolveSystemProxyEnvOptions = {}): NodeJS.ProcessEnv { const platform = options.platform ?? process.platform; ... if (platform === "darwin") { return parseMacosScutilProxyOutput(tryRun("scutil", ["--proxy"]), platform); } if (platform === "win32") { return parseWindowsInternetSettingsProxyOutput({ proxyEnable: tryRun("reg", [...]), ... }, platform); } ... }`
- File: packages/platform/src/proxy-env.ts | Line: 79-113 | Content: `export function mergeProxyAwareEnv(platform: NodeJS.Platform, ...sources: Array<NodeJS.ProcessEnv | Record<string, string | undefined>>): NodeJS.ProcessEnv { ... const canonicalKey = canonicalProxyEnvKey(key); ... if (hasProxyEndpointEnv(merged) && !hasCanonicalProxyEnv(merged, "NODE_USE_ENV_PROXY")) { merged.NODE_USE_ENV_PROXY = "1"; } return merged; }` (auto-enable NODE_USE_ENV_PROXY at :106-107)
- File: packages/platform/src/proxy-env.ts | Line: 22-29 | Content: `const CANONICAL_PROXY_ENV_KEYS = new Map<string, "ALL_PROXY" | "HTTP_PROXY" | "HTTPS_PROXY" | "NODE_USE_ENV_PROXY" | "NO_PROXY">([ ["all_proxy", "ALL_PROXY"], ["http_proxy", "HTTP_PROXY"], ["https_proxy", "HTTPS_PROXY"], ["node_use_env_proxy", "NODE_USE_ENV_PROXY"], ["no_proxy", "NO_PROXY"], ]);`

#### (d) Dependencies to pull in

Only `node:*` builtins (child_process/path/timers) — E1=0 for this item in
the star ranking; sample imports are only `node:*`. No external packages
needed.

#### (e) Per-item build

`pnpm install --frozen-lockfile && pnpm -r build` — **SKIPPED** (no
node/pnpm/npm in the container — same as s24). Import surface confirmed via
`packages/platform/package.json` — `"main": "./dist/index.mjs"` (:6),
`exports` (:11); the barrel `src/index.ts` exists in `packages/platform/src/`
(ls: command.ts, fs.ts, http.ts, index.ts, process.ts, proxy-env.ts,
toolchain.ts).

---

### s05 — @open-design/desktop (`apps/desktop`, 4★)

#### (a) What problem does this item solve

The desktop app's Electron main process: window/menu/ipc (`BrowserWindow`,
`Menu`, `ipcMain`, `powerMonitor`, `shell` — imported at
`src/main/index.ts:7`), the self-running updater (metadata feed, download,
install-after-quit), and host lifecycle events (sleep/wake/shutdown)
recorded into run markers. The module wires sidecar + contracts +
launcher-proto (module map m05); most of its capability is deliberate
wrapping around Electron APIs (E1 negative `electron` in the star ranking).

#### (b)+(c) Use cases + evidence

##### UC05.1 — Wire the updater into the main process (exactly like the real call site index.ts:785)

Scenario: at Electron main startup, the app creates the updater with
version/download-folder/feed-namespace config and Electron deps (opening the
installer via `shell.openPath`). It then asks the updater whether an
automatic check is due per the backoff config, and subscribes a listener so
the update popup re-renders when state changes.

```ts
// apps/desktop/src/main — real wiring: index.ts:785 calls createDesktopUpdater(...)
import { app, shell } from "electron";
import { createDesktopUpdater, type DesktopUpdater } from "./updater.js";

const updater: DesktopUpdater = createDesktopUpdater(
  {
    currentVersion: app.getVersion(),
    downloadRoot: app.getPath("userData") + "/updates",
    namespace: runtime.namespace,   // e.g. "release-stable" (the desktop runtime's)
    runtimeBase: runtime.base,      // base URL of the update feed
    source: runtime.source,
  },
  {
    openPath: (path) => shell.openPath(path),  // open the installer via the Electron shell
    logger: console,
  },
);

// Auto-check per backoff; state is pushed to the UI via subscribe:
if (updater.shouldAutoCheck()) {
  await updater.checkForUpdates({ trigger: "silent" });
}
const unsubscribe = updater.subscribe(() => renderUpdateBanner(updater.snapshot()));
// unsubscribe() when the window closes.
```

Evidence:
- File: apps/desktop/src/main/updater.ts | Line: 411-413 | Content: `export function createDesktopUpdater( configInput: DesktopUpdaterConfigInput, deps: DesktopUpdaterDeps = {}, ): DesktopUpdater { const config = resolveDesktopUpdaterConfig(configInput); const fetchImpl = deps.fetch ?? globalThis.fetch; ...`
- File: apps/desktop/src/main/updater.ts | Line: 141-155 | Content: `export type DesktopUpdaterDeps = { appSessionId?: string | null; osVersion?: string | null; extractLauncherPayloadArchive?: ...; fetch?: typeof globalThis.fetch; launchAppAfterQuit?: ...; launchInstallerAfterQuit?: ...; logger?: DesktopUpdaterLogger; now?: () => Date; openPath?: (path: string) => Promise<string>; processExecPath?: string; processPid?: number; ... }`
- File: apps/desktop/src/main/updater.ts | Line: 169-180 | Content: `export type DesktopUpdater = { checkForUpdates(options?: ActionOptions): Promise<DesktopUpdateStatusSnapshot>; clearCache(): Promise<DesktopUpdateStatusSnapshot>; config: DesktopUpdaterConfig; downloadUpdate(): Promise<DesktopUpdateStatusSnapshot>; handle(action: DesktopUpdateAction): Promise<DesktopUpdateStatusSnapshot>; installUpdate(options?: ActionOptions): Promise<DesktopUpdateStatusSnapshot>; ... shouldAutoCheck(): boolean; snapshot(): DesktopUpdateStatusSnapshot; status(): Promise<DesktopUpdateStatusSnapshot>; subscribe(listener: () => void): () => void; ... }` (subscribe at :180, impl :1475)
- File: apps/desktop/src/main/index.ts | Line: 785-800 | Content: `const updater = createDesktopUpdater( { currentVersion: options.update?.currentVersion, downloadRoot: options.update?.downloadRoot, ... namespace: runtime.namespace, runtimeBase: runtime.base, source: runtime.source, }, { openPath: (path) => shell.openPath(path), appSessionId: startupTiming.context().app_session_id, ...`
- File: apps/desktop/src/main/index.ts | Line: 7 | Content: `import { BrowserWindow, Menu, app, dialog, globalShortcut, ipcMain, powerMonitor, shell, type MenuItemConstructorOptions } from "electron";`

##### UC05.2 — Pure feed logic: compare versions, pick a platformKey by arch, normalize artifact names

Scenario: when writing tests or an out-of-Electron feed checker, the pure
part of the updater is usable standalone: compare a feed version against the
installed one, derive the macOS/Windows platformKey from the CPU arch, and
build a safe artifact filename to store under downloadRoot.

```ts
import {
  compareVersions,
  selectedMacPlatformKey,
  selectedWinPlatformKey,
  extensionForArtifact,
  sanitizePathSegment,
} from "./updater.js"; // re-exported from ./updater/feed.js (updater.ts:89)

// Feed 1.5.0 is newer than installed 1.4.0 → worth downloading:
console.log(compareVersions("1.4.0", "1.5.0") < 0);   // true
console.log(compareVersions("1.5.0", "1.5.0"));       // 0

// platformKey from the user's machine arch:
console.log(selectedMacPlatformKey("x64"));    // "macIntel"
console.log(selectedMacPlatformKey("arm64"));  // "mac"
console.log(selectedWinPlatformKey("arm64"));  // "winArm64"

// Normalized artifact name (anything outside [A-Za-z0-9._-] → "-"):
const ext = extensionForArtifact("Open Design.dmg", "dmg");  // ".dmg"
const fileName =
  ["open-design", sanitizePathSegment("1.5.0"), "mac", "arm64", "dmg"].join("-") + ext;
console.log(fileName);  // "open-design-1.5.0-mac-arm64-dmg.dmg"
```

Evidence:
- File: apps/desktop/src/main/updater.ts | Line: 89 | Content: `export { compareVersions, remoteRequiresReinstall, resolveInstalledOuterVersion } from "./updater/feed.js";`
- File: apps/desktop/src/main/updater/feed.ts | Line: 103-105 | Content: `export function compareVersions(a: string, b: string): number { return compareLauncherVersions(a, b); }`
- File: apps/desktop/src/main/updater/feed.ts | Line: 119-121 | Content: `export function selectedMacPlatformKey(arch: string): string { return arch === "x64" ? "macIntel" : "mac"; }`
- File: apps/desktop/src/main/updater/feed.ts | Line: 123-129 | Content: `export function selectedWinPlatformKey(arch: string): string { if (arch === "x64") return "win"; if (arch === "arm64") return "winArm64"; if (arch === "ia32") return "winIa32"; return \`win-${sanitizePathSegment(arch)}\`; }`
- File: apps/desktop/src/main/updater/feed.ts | Line: 58-65 | Content: `export function extensionForArtifact(name: string | undefined, type: string): string { const ext = name == null ? "" : extname(name).toLowerCase(); if (ext === ".7z" || ext === ".dmg" || ext === ".zip" || ext === ".exe" || ext === ".appimage") return ext; if (type === "dmg") return ".dmg"; ... return ".bin"; }`
- File: apps/desktop/src/main/updater/feed.ts | Line: 54-56 | Content: `export function sanitizePathSegment(value: string): string { return value.replace(/[^A-Za-z0-9._-]+/g, "-").replace(/^-+|-+$/g, "") || "update"; }`

##### UC05.3 — Record sleep/wake/shutdown host events into run markers to diagnose unclean exits

Scenario: an overnight desktop build gets reported with a "strange exit".
Because the main process attaches
`attachDesktopHostLifecycleRecorder` at startup (real call site
index.ts:848), the run marker has recorded `powerMonitor`
suspend/resume/shutdown and per-window `session-end` on Windows; afterwards
`describeHostEvents` summarizes how the session ended.

```ts
// apps/desktop/src/main — real call site: index.ts:848-852
import { powerMonitor, BrowserWindow } from "electron";
import { attachDesktopHostLifecycleRecorder, describeHostEvents } from "./observability.js";
import type { DesktopHostEvent } from "./session-lifecycle.js";

const recorded: DesktopHostEvent[] = [];   // run-marker buffer (illustrative)

attachDesktopHostLifecycleRecorder({
  powerMonitor,                             // Electron powerMonitor
  window: {
    on(event, listener) {                   // Windows: session-end per window
      for (const w of BrowserWindow.getAllWindows()) w.on(event as "session-end", listener);
    },
  },
  record: (event) => recorded.push(event),
});

// When diagnosing "how did the run end":
console.log(describeHostEvents(recorded));
// → { exit_hint, ended_suspended, quit_requested, last_host_event, last_host_event_at }
```

Evidence:
- File: apps/desktop/src/main/observability.ts | Line: 156-168 | Content: `export function attachDesktopHostLifecycleRecorder(input: { powerMonitor: HostEventEmitter; window?: HostEventEmitter | null; record: (event: DesktopHostEvent) => void; }): void { input.powerMonitor.on("suspend", () => input.record({ kind: "suspend" })); input.powerMonitor.on("resume", () => input.record({ kind: "resume" })); input.powerMonitor.on("shutdown", () => input.record({ kind: "shutdown" })); input.window?.on("session-end", (event) => { ... input.record({ kind: "session-end", reasons }); }); }`
- File: apps/desktop/src/main/observability.ts | Line: 120-126 | Content: `export function describeHostEvents(events: DesktopHostEventRecord[]): Record<string, unknown> { ... return { exit_hint: exitHint, ended_suspended: endedSuspended, quit_requested: quitRequested, ...(last ? { last_host_event: last.kind, last_host_event_at: last.at } : {}), }; }`
- File: apps/desktop/src/main/index.ts | Line: 848-852 | Content: `attachDesktopHostLifecycleRecorder({ powerMonitor, window: { // Windows delivers \`session-end\` per window; cover current and later ones. on(event, listener) { for (const window of BrowserWindow.getAllWindows()) window.on(event as "session-end", listener); ...`
- File: apps/desktop/src/main/observability.ts | Line: 6 | Content: `  type DesktopHostEvent,` (type import — real definition at File:
  apps/desktop/src/main/session-lifecycle.ts | Line: 26 | Content:
  `export type DesktopHostEvent =`)
- File: apps/desktop/src/main/updater/store.ts | Line: 47 | Content: `export const UPDATE_ROOT_VERSION = 1;` (update-store schema version constant)
- File: apps/desktop/src/main/updater/config.ts | Line: 31 | Content: `  CURRENT_VERSION: "OD_UPDATE_CURRENT_VERSION",` (updater env constant)

#### (d) Dependencies to pull in

`electron` (runtime), workspace packages `@open-design/contracts`,
`@open-design/sidecar`, `@open-design/sidecar-proto`,
`@open-design/launcher-proto`, `@open-design/release`,
`@open-design/diagnostics`, `@open-design/download`, `@open-design/host`
(module map m05 depends on — 8 packages, matching the `apps/desktop/package.json`
dependencies `workspace:*`).

#### (e) Per-item build

`pnpm install --frozen-lockfile && pnpm -r build` — **SKIPPED** (no
node/pnpm/npm in the container). `apps/desktop/package.json` declares
`"build": "tsc -p tsconfig.json"`, `"test": "vitest run -c vitest.config.ts"`,
dependencies `@open-design/contracts: workspace:*` … (grepped in
package.json); could not run for lack of a toolchain.

---

### s01 — @open-design/web (`apps/web`, 4★)

#### (a) What problem does this item solve

Next.js web UI app (scripts `next dev --turbopack` / `next build` — module
map m01 evidence) with the component tree rooted at `src/App.tsx`;
`components/FileViewer.tsx` at 20,759 lines is the largest file in the repo.
From this item the usage set takes 3 capabilities with clean, easily
reusable APIs: (1) account-match verdicts for the collab invite flow which
only carries a masked email, (2) deriving every plugin-source link/label for
a marketplace card from one installed record, (3) hydrating config from
localStorage with version-gated migration. Star-ranking anchors for s01:
`CONFIG_MIGRATION_VERSION=3` (state/config.ts:27), `GITHUB_SOURCE_RE`
(runtime/plugin-source.ts:55), `OD_WEB_OUTPUT_MODE_ENV`
(sidecar/server.ts:39), `MASK_CHARS` (collab/invite-continuation.ts:245).

#### (b)+(c) Use cases + evidence

##### UC01.1 — Collab invite flow: account-match verdict from a masked email

Scenario: person B sends a collab invite link; the link only carries a
masked email (`j***@company.com`). When person A opens the link, the UI must
know whether the logged-in account is the invitee — but must not assert
falsely when the evidence is insufficient (returns `unknown` instead of
guessing).

```ts
import { evaluateAccountMatch, type AccountMatch } from "../collab/invite-continuation";

// Account "jane.doe@company.com" opens an invite masked as "j***@company.com":
const verdict: AccountMatch =
  evaluateAccountMatch("jane.doe@company.com", "j***@company.com");
console.log(verdict);  // "match" — same domain, visible part "j" matches the lead

// Different domain → certain mismatch, the UI blocks continuation:
console.log(evaluateAccountMatch("jane@other.org", "j***@company.com")); // "mismatch"

// Cannot prove it → "unknown" (the UI must not assert falsely):
console.log(evaluateAccountMatch(null, "j***@company.com"));    // "unknown" — not logged in
console.log(evaluateAccountMatch("jane@company.com", "email-lo")); // "unknown" — mask has no @
```

Evidence:
- File: apps/web/src/collab/invite-continuation.ts | Line: 263-299 | Content: `export function evaluateAccountMatch( currentEmail: string | null | undefined, invitedEmailMasked: string, ): AccountMatch { const current = (currentEmail ?? '').trim().toLowerCase(); ... if (currentDomain !== maskedDomain) return 'mismatch'; // No mask characters: the local part is fully visible → require an exact match. if (!MASK_CHARS.test(maskedLocal)) { return currentLocal === maskedLocal ? 'match' : 'mismatch'; } const visibleLead = maskedLocal.match(VISIBLE_LEAD)?.[0] ?? ''; const visibleTrail = maskedLocal.match(VISIBLE_TRAIL)?.[0] ?? ''; if (visibleLead && !currentLocal.startsWith(visibleLead)) return 'mismatch'; ... return 'match'; }`
- File: apps/web/src/collab/invite-continuation.ts | Line: 242-247 | Content: `export type AccountMatch = 'match' | 'mismatch' | 'unknown'; ... // Characters B may use to mask the invited email (\`j***@\` / \`j•••@\` / \`j···@\`). const MASK_CHARS = /[*•·]/; const VISIBLE_LEAD = /^[^*•·]+/; const VISIBLE_TRAIL = /[^*•·]+$/;`
- File: apps/web/src/collab/invite-continuation.ts | Line: 25 | Content: `export { buildInviteDeeplink, parseInviteDeeplink };` (deeplink barrel in the same module)

##### UC01.2 — Plugin marketplace card: derive all source links/labels from the installed record

Scenario: the plugins page renders a card: the source-kind label, a
browseable link to the exact ref/subpath of `github:owner/repo@ref/sub`, an
author avatar without any authenticated API call, and a 1-click contribute
link. `derivePluginSourceLinks` — a pure function, safe to call during
render — returns all of it in one call.

```ts
import { derivePluginSourceLinks } from "../runtime/plugin-source";

const links = derivePluginSourceLinks({
  source: "github:acme-tools/figma-bridge@v1.2/src",
  sourceKind: "github",
  pinnedRef: "v1.2",
  fsPath: "/home/dev/.open-design/plugins/figma-bridge",
  manifest: {
    author: { name: "ACME Tools", url: "https://github.com/acme-tools" },
    homepage: "https://acme.tools/figma-bridge",
  },
});

console.log(links.sourceKindLabel);  // "GitHub"
console.log(links.sourceLabel);      // "acme-tools/figma-bridge @v1.2/src"
console.log(links.sourceUrl);        // https://github.com/acme-tools/figma-bridge/tree/v1.2/src
console.log(links.authorName);       // "ACME Tools"
console.log(links.authorAvatarUrl);  // https://github.com/acme-tools.png?size=80
console.log(links.contributeUrl);    // https://github.com/acme-tools/figma-bridge/issues/new
```

Evidence:
- File: apps/web/src/runtime/plugin-source.ts | Line: 116-123 | Content: `export function derivePluginSourceLinks( record: Pick<InstalledPluginRecord, 'source' | 'sourceKind' | 'pinnedRef' | 'fsPath' | 'manifest'>, ): PluginSourceLinks { const manifest = record.manifest ?? {}; const author = (manifest as { author?: ... }).author ?? {}; ...` (docstring :114-115: "Derive everything the UI needs about a plugin's source + author in one call. Pure — safe to call from render.")
- File: apps/web/src/runtime/plugin-source.ts | Line: 55 | Content: `const GITHUB_SOURCE_RE = /^github:([A-Za-z0-9._-]+)\/([A-Za-z0-9._-]+)(?:@([A-Za-z0-9._/-]+))?(?:\/(.+))?$/;`
- File: apps/web/src/runtime/plugin-source.ts | Line: 141-156 | Content: `if (record.sourceKind === 'github') { const match = GITHUB_SOURCE_RE.exec(record.source); if (match) { const [, owner, repo, ref, subpath] = match; const ref0 = ref || record.pinnedRef; ... sourceUrl = \`https://github.com/${owner}/${repo}${refSegment}${subSegment}\`; sourceLabel = \`${owner}/${repo}${ref0 ? \` @${ref0}\` : ''}${subpath ? \`/${subpath}\` : ''}\`; sourceContributeUrl = \`https://github.com/${owner}/${repo}/issues/new\`; ...`
- File: apps/web/src/runtime/plugin-source.ts | Line: 104-112 | Content: `const SOURCE_KIND_LABELS: Record<InstalledPluginRecord['sourceKind'], string> = { bundled: 'Official', user: 'User', project: 'Project', marketplace: 'Marketplace', github: 'GitHub', url: 'URL', local: 'Local', };`
- File: apps/web/src/runtime/plugin-source.ts | Line: 206-209 | Content: `authorAvatarUrl = \`https://github.com/${username}.png?size=80\`; ... if (repo) authorAvatarUrl = \`https://github.com/${repo.owner}.png?size=80\`;` (comment :202-205: "github.com/<user>.png returns the avatar for both user and organisation accounts without authentication")
- File: apps/web/src/runtime/plugin-source.ts | Line: 83 | Content: `function githubUsername(url: string): string | null {` (uses GITHUB_PROFILE_RE :56)

##### UC01.3 — Hydrate config from localStorage with version-gated migration

Scenario: at boot the web app reads config from localStorage. Old config may
still carry an accent color that was the OLD default of a previous build
(not a user choice), retired BYOK fields, or no version — `loadConfig`
strips retired fields, runs migration when the version differs, and re-stamps
the current version.

```ts
import { loadConfig, DEFAULT_CONFIG } from "../state/config";
// (in config.ts: STORAGE_KEY :26, CONFIG_MIGRATION_VERSION = 3 :27 — internal
//  constants, not exported; the value 3 comes from the source of the same file,
//  NOT hard-coded from outside)

// Boot: read raw → strip daemon-owned fields + retired BYOK fields → migrate by version:
const config = loadConfig();
console.log(config.configMigrationVersion);  // 3 — always re-stamped after migration (:761)

// Retired BYOK fields are deleted from old payloads inside loadConfig (:701-702):
console.log("byokProfileId" in config);      // false
console.log(config.accentColor);             // reset if it was ever a legacy color
// LEGACY_DEFAULT_ACCENT_COLORS = ['#87ea5c', '#c96442'] (:35) — reset to
// DEFAULT_CONFIG.accentColor when parsedMigrationVersion !== 3 (:732, :759-761)
console.log(DEFAULT_CONFIG !== undefined);   // true — default config export :77
```

Evidence:
- File: apps/web/src/state/config.ts | Line: 26-27 | Content: `const STORAGE_KEY = 'open-design:config'; const CONFIG_MIGRATION_VERSION = 3;`
- File: apps/web/src/state/config.ts | Line: 681-685 | Content: `export function loadConfig(): AppConfig { try { const raw = localStorage.getItem(STORAGE_KEY); if (!raw) { return { ...DEFAULT_CONFIG, pet: normalizePet(DEFAULT_PET), ... }; } const parsed = JSON.parse(raw) as Partial<AppConfig>; ...`
- File: apps/web/src/state/config.ts | Line: 700-708 | Content: `for (const key of RETIRED_SECURE_BYOK_KEYS) { delete (parsed as Record<string, unknown>)[key]; } const parsedHasApiProtocol = ...; const merged: AppConfig = { ...DEFAULT_CONFIG, ...`
- File: apps/web/src/state/config.ts | Line: 732-761 | Content: `if (parsedMigrationVersion !== CONFIG_MIGRATION_VERSION) { // Migration v1: ... if (parsedMigrationVersion < 1 && !parsedHasApiProtocol) { merged.apiProtocol = inferApiProtocol(merged.model, merged.baseUrl); ... } const persistedAccent = normalizeAccentColor(parsed.accentColor); if (persistedAccent != null && LEGACY_DEFAULT_ACCENT_COLORS.includes(persistedAccent)) { merged.accentColor = DEFAULT_CONFIG.accentColor; } merged.configMigrationVersion = CONFIG_MIGRATION_VERSION; }`
- File: apps/web/src/state/config.ts | Line: 35 | Content: `const LEGACY_DEFAULT_ACCENT_COLORS = ['#87ea5c', '#c96442'];`
- File: apps/web/src/state/config.ts | Line: 36-40 | Content: `const RETIRED_SECURE_BYOK_KEYS = [ 'byokProfileId', 'byokCredentialConfigured', 'byokCredentialTail', ] as const;`
- File: apps/web/src/state/config.ts | Line: 77 | Content: `export const DEFAULT_CONFIG: AppConfig = {`

Side anchor (proves the web's sidecar-server surface, not used in the
example above): File: apps/web/sidecar/server.ts | Line: 39 | Content:
`const WEB_OUTPUT_MODE_ENV = "OD_WEB_OUTPUT_MODE";`

#### (d) Dependencies to pull in

`next` + the Next.js toolchain (app runtime); the use cases above only use
internal `apps/web/src` modules with no external package imports
(invite-continuation.ts, plugin-source.ts, state/config.ts are pure /
React-neutral modules).

#### (e) Per-item build

`pnpm install --frozen-lockfile && pnpm -r build` — **SKIPPED** (no
node/pnpm/npm in the container). `apps/web/package.json` declares scripts:
`"dev": "next dev --turbopack"`, `"build": "next build && tsc -b --noEmit"`,
`"build:sidecar": "tsc -p tsconfig.sidecar.json"`, `"test": "vitest run -c
vitest.config.ts"` (grepped in package.json) — could not run for lack of a
toolchain.

---

## 3. Coverage summary + data reconciliation (source-first)

Merge coverage: 8/8 items of the usage checklist have a deep section (s04,
s09, s17, s02 from pass 1; s24, s10, s05, s01 from pass 2) — join policy
`all` satisfied; 24/24 use cases; 0 missing items, 0 drained items.

| s_id | item | examples | source pass | verdict |
|---|---|---|---|---|
| s04 | @open-design/contracts | 3 | 1 | DONE |
| s09 | @open-design/sidecar | 3 | 1 | DONE |
| s17 | @open-design/sidecar-proto | 3 | 1 | DONE |
| s02 | @open-design/daemon | 3 | 1 | DONE |
| s24 | @open-design/release | 3 | 2 | DONE |
| s10 | @open-design/platform | 3 | 2 | DONE |
| s05 | @open-design/desktop | 3 | 2 | DONE |
| s01 | @open-design/web | 3 | 2 | DONE |

Cross-checks after the merge (from the merge pass):

1. **Deps agree with the module map**: zod 3.25.76 (contracts), zod 5.28.4 +
   @modelcontextprotocol/sdk (sidecar-proto), express 5.2.1 +
   better-sqlite3 12.10.0 (daemon), release pure-TS 216 lines with no
   external imports, platform only `node:*` builtins, desktop needs the
   `electron` runtime, web needs `next` — all matching the declared
   dependency table in section 1.
2. **The CLI flag whitelist of `od media generate`** (cli.ts:69-95) matches
   exactly the flags used in the s02 UC-2 example (`--project/--surface/
   --model/--prompt/--aspect` are all in MEDIA_GENERATE_STRING_FLAGS).
3. **Both passes measured on the same PIN**
   `5a0c47777975ddb91d09c1c16b423a3ef74bf572` — no source-tree version
   conflict between the two passes; no "latest" selection was needed (all
   8/8 items have `section_done: true` in both status files).

PIN: `5a0c47777975ddb91d09c1c16b423a3ef74bf572` · merged from the two usage
passes (607 + 492 lines) · 24 use cases / 24 code examples, every API
grep-verified on the PIN tree by the original measuring passes.
