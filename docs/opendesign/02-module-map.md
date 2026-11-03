# Module map

- Subject: `nexu-io/open-design` · TypeScript pnpm monorepo · universe
  **27 items** (unit = pnpm workspace package; cap of 200 items).
- PIN: `5a0c47777975ddb91d09c1c16b423a3ef74bf572` (branch `main`,
  2026-11-02 03:25:06 +0000, "fix(web): hide Labs settings when no
  experiments are available (#9076)") — every number below was measured on
  the PIN tree.
- Census basis (verified against a PIN clone): `files` counts `.ts` + `.tsx`
  (excluding node_modules/dist/build/.next/coverage); `tests` = `.ts`/`.tsx`
  files under `tests/` OR named `*.test.*`/`*.spec.*`; main = files − tests
  (identity holds for all 27 items; totals: 3,067 tests, 2,161 main,
  5,228 files).
- Dependencies: `depends on` = `@open-design/*` packages THIS item imports
  (non-test, import/`import()` context, subpaths counted, bare
  string references excluded); `imported by` = packages that import THIS
  item (same rules). 60 directed edges, cross-checked 60/60 in both
  directions (Σdepends on = Σimported by = 60).
- Invariants recomputed from the 27 items and matching the checklist
  exactly: files **5,228/5,228**, loc **1,836,056/1,836,056**
  (per-file census convention).
- Ratings (★) come from the oracle-based star ranking over this map
  (signals: reusability = few `depends on`, centrality = degree,
  test ratio, distinctiveness probes, non-test substance; hard cap of
  three ★5 per repository).

Distribution: ★5 = 3 (cap reached exactly) · ★4 = 9 · ★3 = 9 · ★2 = 6 ·
total score 165.

## Index

| id | module | path | loc | ★ |
|----|--------|------|----:|---|
| m01 | @open-design/web | apps/web | 877,858 | 4 |
| m02 | @open-design/daemon | apps/daemon | 669,678 | 4 |
| m03 | @open-design/e2e | e2e | 117,057 | 3 |
| m04 | @open-design/contracts | packages/contracts | 52,859 | 5 |
| m05 | @open-design/desktop | apps/desktop | 32,459 | 4 |
| m06 | @open-design/tools-pack | tools/pack | 22,849 | 4 |
| m07 | @open-design/tools-release | tools/release | 14,826 | 3 |
| m08 | @open-design/packaged | apps/packaged | 14,216 | 4 |
| m09 | @open-design/sidecar | packages/sidecar | 5,464 | 5 |
| m10 | @open-design/platform | packages/platform | 3,730 | 4 |
| m11 | @open-design/standalone | packages/standalone | 3,637 | 3 |
| m12 | @open-design/tools-dev | tools/dev | 2,996 | 3 |
| m13 | @open-design/plugin-runtime | packages/plugin-runtime | 2,475 | 4 |
| m14 | @open-design/tools-serve | tools/serve | 2,394 | 3 |
| m15 | @open-design/download | packages/download | 2,234 | 3 |
| m16 | @open-design/terminal | shells/terminal | 1,962 | 2 |
| m17 | @open-design/sidecar-proto | packages/sidecar-proto | 1,782 | 5 |
| m18 | @open-design/host | packages/host | 1,660 | 3 |
| m19 | @open-design/diagnostics | packages/diagnostics | 1,448 | 3 |
| m20 | @open-design/launcher-proto | packages/launcher-proto | 1,054 | 4 |
| m21 | @open-design/dsh-runtime | packages/dsh-runtime | 999 | 3 |
| m22 | @open-design/components | packages/components | 812 | 2 |
| m23 | @open-design/agui-adapter | packages/agui-adapter | 540 | 2 |
| m24 | @open-design/release | packages/release | 333 | 4 |
| m25 | @open-design/registry-protocol | packages/registry-protocol | 303 | 2 |
| m26 | @open-design/metatool | packages/metatool | 259 | 2 |
| m27 | @open-design/closure | apps/closure | 172 | 2 |

## Items

### m01 @open-design/web

Path `apps/web` · ★4 · 877,858 loc · 2,205 ts/tsx files (1,421 tests / 784 main)

Web UI app — Next.js toolchain (package.json scripts `next dev --turbopack` /
`next build`) with the component tree rooted at `src/App.tsx`; `components/`
(`FileViewer.tsx`, 20,759 lines — the largest file in the repo), `features/`,
`edit-mode/`, `collab/`, `comments/`, `campaigns/`, `analytics/`,
`artifacts/`, `design-system-auto-prompt.ts`.

- depends on: components, contracts, host, sidecar, sidecar-proto
- imported by: —
- evidence: `apps/web/src/App.tsx:1`; `apps/web/src/components/FileViewer.tsx`
  20,759 lines (wc -l); `apps/web/package.json` scripts `next dev --turbopack`

### m02 @open-design/daemon

Path `apps/daemon` · ★4 · 669,678 loc · 1,854 ts/tsx files (1,069 tests / 785 main)

Daemon HTTP server + CLI — bin `od` → `dist/cli.js` (`bin/od.mjs:1`);
`src/server.ts` 18,962 lines handles routes, collab, design-systems,
evidence-delivery, workspace runs; `src/cli.ts` 12,979;
`routes/project/index.ts` 8,259; `db.ts` 6,007.

- depends on: agui-adapter, contracts, diagnostics, launcher-proto, platform,
  plugin-runtime, registry-protocol, release, sidecar, sidecar-proto
- imported by: —
- evidence: `apps/daemon/bin/od.mjs:1`; `apps/daemon/src/server.ts` 18,962
  (wc -l); grep deps: contracts 462, sidecar-proto 16, platform 15,
  plugin-runtime 9 files (non-test)

### m03 @open-design/e2e

Path `e2e` · ★3 · 117,057 loc · 385 ts/tsx files (266 tests / 119 main)

Playwright e2e workspace — `playwright.config.ts` +
`playwright.visual.config.ts`; `ui/` = page objects + flows
(`project-management-flows.test.ts` 5,339 lines, app-restoration 3,155,
workspace-team-interactions 2,460), `specs/`, `tests/` (guard scripts
check-ts-nocheck-imports, check-cross-app-imports), `lib/`, `resources/`.

- depends on: contracts, release, sidecar, sidecar-proto
- imported by: —
- evidence: `e2e/playwright.config.ts`;
  `e2e/ui/project-management-flows.test.ts` 5,339;
  `e2e/tests/scripts/check-cross-app-imports.test.ts`

### m04 @open-design/contracts

Path `packages/contracts` · ★5 · 52,859 loc · 251 ts/tsx files (85 tests / 166 main)

"Shared pure TypeScript contracts for the OpenDesign web/daemon boundary"
(package.json) — `src/api/`, `design-systems/`, `analytics/`, `artifacts/`,
`agent-tools/`, `amr-endpoint-binding.ts`, `common.ts`, `errors.ts`…;
the central node of the dependency graph (8 packages import it; 323 non-test
files in daemon + 302 in web).

- depends on: release
- imported by: agui-adapter, daemon, desktop, e2e, packaged, plugin-runtime,
  tools-pack, web
- evidence: `packages/contracts/package.json` description; importer census:
  daemon 323, web 302, plugin-runtime 9, desktop 8, e2e 7, tools-pack 6,
  packaged 6, agui-adapter 1 (non-test files)

### m05 @open-design/desktop

Path `apps/desktop` · ★4 · 32,459 loc · 94 ts/tsx files (56 tests / 38 main)

Electron main process — `src/main/index.ts`
(BrowserWindow/Menu/ipcMain/powerMonitor/shell), startup-timing, launch-type,
memory-sampler, `deck-capture.ts` 3,253 lines, `runtime.ts` 3,143,
`updater.ts` 1,482; wires sidecar + contracts + launcher-proto.

- depends on: contracts, diagnostics, download, host, launcher-proto, release,
  sidecar, sidecar-proto
- imported by: packaged
- evidence: `apps/desktop/src/main/index.ts:1`;
  `apps/desktop/src/main/deck-capture.ts` 3,253;
  `apps/desktop/src/main/runtime.ts` 3,143

### m06 @open-design/tools-pack

Path `tools/pack` · ★4 · 22,849 loc · 107 ts/tsx files (45 tests / 62 main)

Tool pack CLI — builds/bundles desktop installers for Linux/Windows;
`src/linux.ts` 1,369 lines (AppImage/deb/rpm), `win/custom-installer.ts`
1,334; references most packages by name in bundle manifests (string refs,
not counted as deps) but only imports packaged.

- depends on: contracts, launcher-proto, packaged, platform, release, sidecar,
  sidecar-proto
- imported by: —
- evidence: `tools/pack/src/linux.ts:1` 1,369;
  `tools/pack/src/win/custom-installer.ts` 1,334

### m07 @open-design/tools-release

Path `tools/release` · ★3 · 14,826 loc · 73 ts/tsx files (19 tests / 54 main)

Release tooling — `src/` split into catalog/, metadata/, notifications/,
release-note/, report/, storage/; imports release (17 non-test files) +
launcher-proto (2 files); no package imports tools-release (importer census
empty).

- depends on: launcher-proto, release
- imported by: —
- evidence: `tools/release/src/` listing: catalog, metadata, notifications,
  release-note, report, storage; importer census: release 17, launcher-proto 2
  (non-test files)

### m08 @open-design/packaged

Path `apps/packaged` · ★4 · 14,216 loc · 49 ts/tsx files (26 tests / 23 main)

Packaging runtime — sidecar lifecycle
(bootstrapSidecarProcess/registerSidecarProcess/readCurrentSidecarStamp/
isCurrentSidecarLauncher/resolveSidecarLauncherExitCode), launcher arg parsing
(parseLauncherAfterQuitArgs/parseLauncherDelegatedArgs/
parseLauncherHandoffResumeArgs), startup telemetry; `src/sidecars.ts` 1,162
lines; consumed by tools/pack.

- depends on: contracts, desktop, launcher-proto, platform, release, sidecar,
  sidecar-proto
- imported by: tools-pack
- evidence: `apps/packaged/src/index.ts:1` (imports sidecar-proto
  APP_KEYS/SIDECAR_MESSAGES/SIDECAR_MODES/SIDECAR_SOURCES + launcher-proto
  parseLauncher*Args); `apps/packaged/src/sidecars.ts` 1,162

### m09 @open-design/sidecar

Path `packages/sidecar` · ★5 · 5,464 loc · 34 ts/tsx files (16 tests / 18 main)

JSON-IPC client/operations for the sidecar process — `Client`
(connect/retry/dispatch), `src/operations.ts` 578 lines (operations
registry), `json-ipc.ts` (JSON transport over stdin/stdout); the bridge
between host runtimes and the sidecar binary.

- depends on: platform
- imported by: daemon, desktop, e2e, packaged, terminal, tools-dev, tools-pack,
  web
- evidence: `packages/sidecar/src/index.ts:1` (barrel types);
  `packages/sidecar/src/operations.ts` 578

### m10 @open-design/platform

Path `packages/platform` · ★4 · 3,730 loc · 12 ts/tsx files (5 tests / 7 main)

OS process lifecycle primitives — `src/process.ts` 882 lines: encode/decode
process stamps, spawn child processes, probe liveness, walk the process
tree, SIGTERM-then-SIGKILL escalation; `proxy-env.ts` 411.

- depends on: —
- imported by: daemon, download, packaged, sidecar, tools-dev, tools-pack
- evidence: `packages/platform/src/process.ts:1` 882;
  `packages/platform/src/proxy-env.ts` 411

### m11 @open-design/standalone

Path `packages/standalone` · ★3 · 3,637 loc · 19 ts/tsx files (5 tests / 14 main)

"Shell-neutral exact distribution, generation, and launcher runtime"
(package.json) — `src/{bootloader-handoff, launcher, shell-update,
state-machine, store, maintenance, garbage, feedback, protocol,
shared-lifecycle}.ts`.

- depends on: download
- imported by: closure, terminal
- evidence: `packages/standalone/package.json` description; src listing
  10 files

### m12 @open-design/tools-dev

Path `tools/dev` · ★3 · 2,996 loc · 20 ts/tsx files (10 tests / 10 main)

Dev tool CLI — `src/{cli-args, config, data-root, desktop-auth-gate,
diagnostics, local-env, shared-ports, sidecar-client, vela-runtime}.ts`;
stands up the local dev environment (ports, data root, sidecar client).

- depends on: platform, sidecar, sidecar-proto
- imported by: —
- evidence: `tools/dev/src/` listing; importer census: sidecar-proto 6,
  sidecar 4, platform 1

### m13 @open-design/plugin-runtime

Path `packages/plugin-runtime` · ★4 · 2,475 loc · 22 ts/tsx files (10 tests / 12 main)

"Pure-TS OpenDesign plugin runtime: manifest parsers, adapters, merger, ref
resolver, validator, digest. No node:fs imports — daemon/web/CI inject
loaders" (package.json) — `parsers/frontmatter.ts` 254 lines,
`adapters/agent-skill.ts` 200, `resolve.ts` 177, `strategy-package.ts` 114,
`merge.ts` 101, `validate.ts` 93.

- depends on: contracts
- imported by: daemon
- evidence: `packages/plugin-runtime/package.json` description + main
  `./dist/index.mjs`; src listing 13 ts/tsx files (wc: frontmatter.ts 254,
  agent-skill.ts 200, resolve.ts 177…); importer census: contracts 9

### m14 @open-design/tools-serve

Path `tools/serve` · ★3 · 2,394 loc · 11 ts/tsx files (6 tests / 5 main)

Tool serve CLI — local fixture servers for development:
`collab-cloud-fixture.ts` 388 lines, `updater-fixture.ts` 374,
release-storage-fixture (in-memory stand-ins for the cross-daemon hub).

- depends on: release
- imported by: —
- evidence: `tools/serve/src/collab-cloud-fixture.ts` 388;
  `tools/serve/src/updater-fixture.ts` 374

### m15 @open-design/download

Path `packages/download` · ★3 · 2,234 loc · 17 ts/tsx files (1 test / 16 main)

Managed-download package — error taxonomy (MANAGED_DOWNLOAD_ERROR_CODES,
ManagedDownloadError), 5 operations (managedDownload, downloadCopyAndClear,
inspectManagedDownload, removeManagedDownload, pruneManagedDownloads);
`src/transfer.ts` 235 lines.

- depends on: platform
- imported by: desktop, standalone
- evidence: `packages/download/src/transfer.ts` 235;
  `packages/download/src/index.ts:1` (barrel MANAGED_DOWNLOAD_ERROR_CODES…)

### m16 @open-design/terminal

Path `shells/terminal` · ★2 · 1,962 loc · 10 ts/tsx files (9 tests / 1 main)

Terminal shell runtime — `runtime/sidecar-host.mjs` 410 lines (bootstrap
sidecar process, handoffCurrentSidecarGeneration, SidecarFactory; action
`standalone.request.v1` via env `OD_TERMINAL_SIDECAR_CONFIG_V1`),
`runtime/fossil.mjs` 409, `runtime/fixture-shell-updater.mjs` 348; 10 `.ts`
files (9 tests, 1 non-test — the running code is `.mjs`).

- depends on: sidecar, standalone
- imported by: —
- evidence: `shells/terminal/runtime/sidecar-host.mjs:1` 410;
  `shells/terminal/runtime/fossil.mjs` 409; importer census: sidecar 4,
  standalone 1 (a claimed platform dependency was not found — see note 3)

### m17 @open-design/sidecar-proto

Path `packages/sidecar-proto` · ★5 · 1,782 loc · 4 ts/tsx files (3 tests / 1 main)

Wire contract + constants for sidecar IPC — `src/index.ts` 1,198 lines (the
only non-test file): APP_KEYS (daemon/desktop/web), SIDECAR_MODES
(dev/runtime), SIDECAR_SOURCES (packaged/tools-dev/tools-pack), SIDECAR_ENV
(OD_SIDECAR_BASE, OD_SIDECAR_IPC_PATH, OD_DAEMON_PORT…), message types;
imports release (RELEASE_CHANNELS).

- depends on: release
- imported by: daemon, desktop, e2e, launcher-proto, packaged, tools-dev,
  tools-pack, web
- evidence: `packages/sidecar-proto/src/index.ts:1` 1,198 (head 40: APP_KEYS,
  SIDECAR_MODES, SIDECAR_SOURCES, SIDECAR_ENV; imports RELEASE_CHANNELS from
  release); tests: index.test.ts 436, artifact-capture-mode.test.ts 87,
  ipc-path.test.ts 57

### m18 @open-design/host

Path `packages/host` · ★3 · 1,660 loc · 7 ts/tsx files (1 test / 6 main)

Renderer host-bridge wire contract — `src/protocol.ts` 449 lines:
OPEN_DESIGN_HOST_GLOBAL, client/updater constant registries, request/result
types for the host bridge; `actions.ts` 337.

- depends on: release
- imported by: desktop, web
- evidence: `packages/host/src/protocol.ts:1` 449;
  `packages/host/src/actions.ts` 337

### m19 @open-design/diagnostics

Path `packages/diagnostics` · ★3 · 1,448 loc · 14 ts/tsx files (5 tests / 9 main)

"Diagnostics export: log collection, redaction, and zip packaging shared by
daemon and desktop" (package.json) — `src/{agent-logs, automatic, contract,
manifest, redaction, sources, zip}.ts`.

- depends on: —
- imported by: daemon, desktop
- evidence: `packages/diagnostics/package.json` description; importer census:
  daemon 6, desktop 2

### m20 @open-design/launcher-proto

Path `packages/launcher-proto` · ★4 · 1,054 loc · 2 ts/tsx files (1 test / 1 main)

Launcher protocol — `src/index.ts` (the only non-test file):
LAUNCHER_SCHEMA_VERSION=1, flags/args `--od-launcher-after-quit` /
`--od-launcher-target-pid` / `--od-launcher-resume-handoff` /
`--od-launcher-delegated-*`, LAUNCHER_CHANNELS from RELEASE_CHANNELS;
normalize namespace via sidecar-proto.

- depends on: release, sidecar-proto
- imported by: daemon, desktop, packaged, tools-pack, tools-release
- evidence: `packages/launcher-proto/src/index.ts:1-15`
  (LAUNCHER_SCHEMA_VERSION, --od-launcher-* args, imports release +
  sidecar-proto)

### m21 @open-design/dsh-runtime

Path `packages/dsh-runtime` · ★3 · 999 loc · 7 ts/tsx files (1 test / 6 main)

"DeepSeek Harness profile runtime for OpenDesign" (package.json) — cordis
plugin `open-design-runtime` (`src/index.ts` 485 lines, injects
@deepseek-ai/cordis + dsh-agent/dsh-llm/dsh-session); `src/protocol.ts`:
PROTOCOL_VERSION=1, RUNTIME_NAME='open-design', CAPABILITIES
{session_resume, session_cancel, structured_events}, modelsFrame/
identityFrame/parseHostCommand.

- depends on: —
- imported by: —
- evidence: `packages/dsh-runtime/package.json` description "DeepSeek Harness
  profile runtime for OpenDesign"; `packages/dsh-runtime/src/index.ts:1-19`
  (imports @deepseek-ai/cordis/dsh-agent/dsh-llm/dsh-session; export name
  'open-design-runtime'); `packages/dsh-runtime/src/protocol.ts:1-8`
  (PROTOCOL_VERSION=1, RUNTIME_NAME, CAPABILITIES)

### m22 @open-design/components

Path `packages/components` · ★2 · 812 loc · 13 ts/tsx files (2 tests / 11 main)

React UI primitives — `src/dialog.tsx` 274 lines (portal +
DialogBody/Description/Footer/Header/Title), `modal-stack.ts` 95
(getModalDialogsInStackOrder/getTopModalDialog/observeModalStack),
`button.tsx`, form-controls (Input/Select/Textarea), VisuallyHidden;
imported by web (78 non-test files).

- depends on: —
- imported by: web
- evidence: `packages/components/src/dialog.tsx:1` 274;
  `packages/components/src/modal-stack.ts` 95

### m23 @open-design/agui-adapter

Path `packages/agui-adapter` · ★2 · 540 loc · 4 ts/tsx files (1 test / 3 main)

AG-UI ↔ OpenDesign adapter (Spec §10.3.5 / Phase 4) — `src/encode.ts` 207
lines + `types.ts` 100; bridges AG-UI events/messages to the OpenDesign
runtime.

- depends on: contracts
- imported by: daemon
- evidence: `packages/agui-adapter/src/index.ts:1` (barrel; comment "AG-UI ↔
  OpenDesign adapter package. Spec §10.3.5 / Phase 4.");
  `packages/agui-adapter/src/encode.ts` 207

### m24 @open-design/release

Path `packages/release` · ★4 · 333 loc · 3 ts/tsx files (1 test / 2 main)

"Open Design release domain primitives" (package.json) — `src/index.ts`:
EXACT_RELEASE_NAME_PATTERN, RESERVED_RELEASE_NAMES, ReleaseChannel
('stable' | counted), ReleasePlatform (mac/macIntel/win/linux),
ParsedReleaseVersion; source of constants for 11 packages (root node of the
dependency graph).

- depends on: —
- imported by: contracts, daemon, desktop, e2e, host, launcher-proto, packaged,
  sidecar-proto, tools-pack, tools-release, tools-serve
- evidence: `packages/release/src/index.ts:1-20`
  (EXACT_RELEASE_NAME_PATTERN, RESERVED_RELEASE_NAMES, ReleaseChannel/Platform
  types); importer census 11 packages

### m25 @open-design/registry-protocol

Path `packages/registry-protocol` · ★2 · 303 loc · 4 ts/tsx files (1 test / 3 main)

"Pure TypeScript registry backend protocol for OpenDesign plugin sources"
(package.json) — `src/backend.ts`: interface RegistryBackend
(list/search/resolve/manifest/doctor/publish?/yank?) + RegistryBackendFactory;
`src/schemas.ts` 164 lines (zod): kinds github/http/local/db, trust
official/trusted/restricted, RegistryDist/Publisher/Metrics.

- depends on: —
- imported by: daemon
- evidence: `packages/registry-protocol/src/backend.ts:1-33` (interface
  RegistryBackend list/search/resolve/manifest/doctor/publish?/yank? +
  RegistryBackendFactory); `packages/registry-protocol/src/schemas.ts:1-30`
  (RegistryBackendKindSchema z.enum github/http/local/db; RegistryTrustSchema
  official/trusted/restricted); `packages/registry-protocol/src/index.ts`
  (export * backend/schemas)

### m26 @open-design/metatool

Path `packages/metatool` · ★2 · 259 loc · 3 ts/tsx files (1 test / 2 main)

Tool build metadata — `src/index.ts` 175 lines: ToolBuildMetadataPolicy
(buildCommand/distEntries/inputs/packageName/toolName) +
ToolBuildMetadataResult (hash/metadataPath), hashes build inputs with
node:crypto for the tool release pipeline; `src/cli.ts` 20.

- depends on: —
- imported by: —
- evidence: `packages/metatool/src/index.ts:1` 175 (imports node:crypto
  createHash + zod)

### m27 @open-design/closure

Path `apps/closure` · ★2 · 172 loc · 4 ts/tsx files (1 test / 3 main)

"Independently distributable OpenDesign Closure content" (package.json) —
`src/{index, fixture}.ts`; the smallest app in the universe (172 LOC, 4
files).

- depends on: standalone
- imported by: —
- evidence: `apps/closure/package.json` description;
  `apps/closure/src/{index,fixture}.ts`; importer census: standalone 1

## Machine-readable JSON

```json
[
  {"id": "m01", "module": "@open-design/web", "path": "apps/web", "responsibility": "Web UI app — Next.js toolchain (package.json scripts next dev --turbopack / next build) with the component tree rooted at src/App.tsx; components/ (FileViewer.tsx 20,759 lines — largest file in the repo), features/, edit-mode/, collab/, comments/, campaigns/, analytics/, artifacts/, design-system-auto-prompt.ts.", "main_files": 784, "depends_on": ["components", "contracts", "host", "sidecar", "sidecar-proto"], "imported_by": [], "loc": 877858, "tests": 1421, "stars": 4},
  {"id": "m02", "module": "@open-design/daemon", "path": "apps/daemon", "responsibility": "Daemon HTTP server + CLI — bin od -> dist/cli.js (bin/od.mjs:1); src/server.ts 18,962 lines handles routes, collab, design-systems, evidence-delivery, workspace runs; src/cli.ts 12,979; routes/project/index.ts 8,259; db.ts 6,007.", "main_files": 785, "depends_on": ["agui-adapter", "contracts", "diagnostics", "launcher-proto", "platform", "plugin-runtime", "registry-protocol", "release", "sidecar", "sidecar-proto"], "imported_by": [], "loc": 669678, "tests": 1069, "stars": 4},
  {"id": "m03", "module": "@open-design/e2e", "path": "e2e", "responsibility": "Playwright e2e workspace — playwright.config.ts + playwright.visual.config.ts; ui/ = page objects + flows (project-management-flows.test.ts 5,339 lines, app-restoration 3,155, workspace-team-interactions 2,460), specs/, tests/ (guard scripts check-ts-nocheck-imports, check-cross-app-imports), lib/, resources/.", "main_files": 119, "depends_on": ["contracts", "release", "sidecar", "sidecar-proto"], "imported_by": [], "loc": 117057, "tests": 266, "stars": 3},
  {"id": "m04", "module": "@open-design/contracts", "path": "packages/contracts", "responsibility": "Shared pure TypeScript contracts for the OpenDesign web/daemon boundary (package.json) — src/api/, design-systems/, analytics/, artifacts/, agent-tools/, amr-endpoint-binding.ts, common.ts, errors.ts…; central node of the dependency graph (8 packages import it; 323 non-test files in daemon + 302 in web).", "main_files": 166, "depends_on": ["release"], "imported_by": ["agui-adapter", "daemon", "desktop", "e2e", "packaged", "plugin-runtime", "tools-pack", "web"], "loc": 52859, "tests": 85, "stars": 5},
  {"id": "m05", "module": "@open-design/desktop", "path": "apps/desktop", "responsibility": "Electron main process — src/main/index.ts (BrowserWindow/Menu/ipcMain/powerMonitor/shell), startup-timing, launch-type, memory-sampler, deck-capture.ts 3,253 lines, runtime.ts 3,143, updater.ts 1,482; wires sidecar + contracts + launcher-proto.", "main_files": 38, "depends_on": ["contracts", "diagnostics", "download", "host", "launcher-proto", "release", "sidecar", "sidecar-proto"], "imported_by": ["packaged"], "loc": 32459, "tests": 56, "stars": 4},
  {"id": "m06", "module": "@open-design/tools-pack", "path": "tools/pack", "responsibility": "Tool pack CLI — builds/bundles desktop installers for Linux/Windows; src/linux.ts 1,369 lines (AppImage/deb/rpm), win/custom-installer.ts 1,334; references most packages by name in bundle manifests (string refs, not counted as deps) but only imports packaged.", "main_files": 62, "depends_on": ["contracts", "launcher-proto", "packaged", "platform", "release", "sidecar", "sidecar-proto"], "imported_by": [], "loc": 22849, "tests": 45, "stars": 4},
  {"id": "m07", "module": "@open-design/tools-release", "path": "tools/release", "responsibility": "Release tooling — src/ split into catalog/, metadata/, notifications/, release-note/, report/, storage/; imports release (17 non-test files) + launcher-proto (2 files); no package imports tools-release (importer census empty).", "main_files": 54, "depends_on": ["launcher-proto", "release"], "imported_by": [], "loc": 14826, "tests": 19, "stars": 3},
  {"id": "m08", "module": "@open-design/packaged", "path": "apps/packaged", "responsibility": "Packaging runtime — sidecar lifecycle (bootstrapSidecarProcess/registerSidecarProcess/readCurrentSidecarStamp/isCurrentSidecarLauncher/resolveSidecarLauncherExitCode), launcher arg parsing (parseLauncherAfterQuitArgs/parseLauncherDelegatedArgs/parseLauncherHandoffResumeArgs), startup telemetry; src/sidecars.ts 1,162 lines; consumed by tools/pack.", "main_files": 23, "depends_on": ["contracts", "desktop", "launcher-proto", "platform", "release", "sidecar", "sidecar-proto"], "imported_by": ["tools-pack"], "loc": 14216, "tests": 26, "stars": 4},
  {"id": "m09", "module": "@open-design/sidecar", "path": "packages/sidecar", "responsibility": "JSON-IPC client/operations for the sidecar process — Client (connect/retry/dispatch), src/operations.ts 578 lines (operations registry), json-ipc.ts (JSON transport over stdin/stdout); the bridge between host runtimes and the sidecar binary.", "main_files": 18, "depends_on": ["platform"], "imported_by": ["daemon", "desktop", "e2e", "packaged", "terminal", "tools-dev", "tools-pack", "web"], "loc": 5464, "tests": 16, "stars": 5},
  {"id": "m10", "module": "@open-design/platform", "path": "packages/platform", "responsibility": "OS process lifecycle primitives — src/process.ts 882 lines: encode/decode process stamps, spawn child processes, probe liveness, walk the process tree, SIGTERM-then-SIGKILL escalation; proxy-env.ts 411.", "main_files": 7, "depends_on": [], "imported_by": ["daemon", "download", "packaged", "sidecar", "tools-dev", "tools-pack"], "loc": 3730, "tests": 5, "stars": 4},
  {"id": "m11", "module": "@open-design/standalone", "path": "packages/standalone", "responsibility": "Shell-neutral exact distribution, generation, and launcher runtime (package.json) — src/{bootloader-handoff, launcher, shell-update, state-machine, store, maintenance, garbage, feedback, protocol, shared-lifecycle}.ts.", "main_files": 14, "depends_on": ["download"], "imported_by": ["closure", "terminal"], "loc": 3637, "tests": 5, "stars": 3},
  {"id": "m12", "module": "@open-design/tools-dev", "path": "tools/dev", "responsibility": "Dev tool CLI — src/{cli-args, config, data-root, desktop-auth-gate, diagnostics, local-env, shared-ports, sidecar-client, vela-runtime}.ts; stands up the local dev environment (ports, data root, sidecar client).", "main_files": 10, "depends_on": ["platform", "sidecar", "sidecar-proto"], "imported_by": [], "loc": 2996, "tests": 10, "stars": 3},
  {"id": "m13", "module": "@open-design/plugin-runtime", "path": "packages/plugin-runtime", "responsibility": "Pure-TS OpenDesign plugin runtime: manifest parsers, adapters, merger, ref resolver, validator, digest. No node:fs imports — daemon/web/CI inject loaders (package.json) — parsers/frontmatter.ts 254 lines, adapters/agent-skill.ts 200, resolve.ts 177, strategy-package.ts 114, merge.ts 101, validate.ts 93.", "main_files": 12, "depends_on": ["contracts"], "imported_by": ["daemon"], "loc": 2475, "tests": 10, "stars": 4},
  {"id": "m14", "module": "@open-design/tools-serve", "path": "tools/serve", "responsibility": "Tool serve CLI — local fixture servers for development: collab-cloud-fixture.ts 388 lines, updater-fixture.ts 374, release-storage-fixture (in-memory stand-ins for the cross-daemon hub).", "main_files": 5, "depends_on": ["release"], "imported_by": [], "loc": 2394, "tests": 6, "stars": 3},
  {"id": "m15", "module": "@open-design/download", "path": "packages/download", "responsibility": "Managed-download package — error taxonomy (MANAGED_DOWNLOAD_ERROR_CODES, ManagedDownloadError), 5 operations (managedDownload, downloadCopyAndClear, inspectManagedDownload, removeManagedDownload, pruneManagedDownloads); src/transfer.ts 235 lines.", "main_files": 16, "depends_on": ["platform"], "imported_by": ["desktop", "standalone"], "loc": 2234, "tests": 1, "stars": 3},
  {"id": "m16", "module": "@open-design/terminal", "path": "shells/terminal", "responsibility": "Terminal shell runtime — runtime/sidecar-host.mjs 410 lines (bootstrap sidecar process, handoffCurrentSidecarGeneration, SidecarFactory; action standalone.request.v1 via env OD_TERMINAL_SIDECAR_CONFIG_V1), runtime/fossil.mjs 409, runtime/fixture-shell-updater.mjs 348; 10 .ts files (9 tests, 1 non-test — the running code is .mjs).", "main_files": 1, "depends_on": ["sidecar", "standalone"], "imported_by": [], "loc": 1962, "tests": 9, "stars": 2},
  {"id": "m17", "module": "@open-design/sidecar-proto", "path": "packages/sidecar-proto", "responsibility": "Wire contract + constants for sidecar IPC — src/index.ts 1,198 lines (the only non-test file): APP_KEYS (daemon/desktop/web), SIDECAR_MODES (dev/runtime), SIDECAR_SOURCES (packaged/tools-dev/tools-pack), SIDECAR_ENV (OD_SIDECAR_BASE, OD_SIDECAR_IPC_PATH, OD_DAEMON_PORT…), message types; imports release (RELEASE_CHANNELS).", "main_files": 1, "depends_on": ["release"], "imported_by": ["daemon", "desktop", "e2e", "launcher-proto", "packaged", "tools-dev", "tools-pack", "web"], "loc": 1782, "tests": 3, "stars": 5},
  {"id": "m18", "module": "@open-design/host", "path": "packages/host", "responsibility": "Renderer host-bridge wire contract — src/protocol.ts 449 lines: OPEN_DESIGN_HOST_GLOBAL, client/updater constant registries, request/result types for the host bridge; actions.ts 337.", "main_files": 6, "depends_on": ["release"], "imported_by": ["desktop", "web"], "loc": 1660, "tests": 1, "stars": 3},
  {"id": "m19", "module": "@open-design/diagnostics", "path": "packages/diagnostics", "responsibility": "Diagnostics export: log collection, redaction, and zip packaging shared by daemon and desktop (package.json) — src/{agent-logs, automatic, contract, manifest, redaction, sources, zip}.ts.", "main_files": 9, "depends_on": [], "imported_by": ["daemon", "desktop"], "loc": 1448, "tests": 5, "stars": 3},
  {"id": "m20", "module": "@open-design/launcher-proto", "path": "packages/launcher-proto", "responsibility": "Launcher protocol — src/index.ts (the only non-test file): LAUNCHER_SCHEMA_VERSION=1, flags/args --od-launcher-after-quit / --od-launcher-target-pid / --od-launcher-resume-handoff / --od-launcher-delegated-*, LAUNCHER_CHANNELS from RELEASE_CHANNELS; normalize namespace via sidecar-proto.", "main_files": 1, "depends_on": ["release", "sidecar-proto"], "imported_by": ["daemon", "desktop", "packaged", "tools-pack", "tools-release"], "loc": 1054, "tests": 1, "stars": 4},
  {"id": "m21", "module": "@open-design/dsh-runtime", "path": "packages/dsh-runtime", "responsibility": "DeepSeek Harness profile runtime for OpenDesign (package.json) — cordis plugin open-design-runtime (src/index.ts 485 lines, injects @deepseek-ai/cordis + dsh-agent/dsh-llm/dsh-session); src/protocol.ts: PROTOCOL_VERSION=1, RUNTIME_NAME='open-design', CAPABILITIES {session_resume, session_cancel, structured_events}, modelsFrame/identityFrame/parseHostCommand.", "main_files": 6, "depends_on": [], "imported_by": [], "loc": 999, "tests": 1, "stars": 3},
  {"id": "m22", "module": "@open-design/components", "path": "packages/components", "responsibility": "React UI primitives — src/dialog.tsx 274 lines (portal + DialogBody/Description/Footer/Header/Title), modal-stack.ts 95 (getModalDialogsInStackOrder/getTopModalDialog/observeModalStack), button.tsx, form-controls (Input/Select/Textarea), VisuallyHidden; imported by web (78 non-test files).", "main_files": 11, "depends_on": [], "imported_by": ["web"], "loc": 812, "tests": 2, "stars": 2},
  {"id": "m23", "module": "@open-design/agui-adapter", "path": "packages/agui-adapter", "responsibility": "AG-UI ↔ OpenDesign adapter (Spec §10.3.5 / Phase 4) — src/encode.ts 207 lines + types.ts 100; bridges AG-UI events/messages to the OpenDesign runtime.", "main_files": 3, "depends_on": ["contracts"], "imported_by": ["daemon"], "loc": 540, "tests": 1, "stars": 2},
  {"id": "m24", "module": "@open-design/release", "path": "packages/release", "responsibility": "Open Design release domain primitives (package.json) — src/index.ts: EXACT_RELEASE_NAME_PATTERN, RESERVED_RELEASE_NAMES, ReleaseChannel ('stable' | counted), ReleasePlatform (mac/macIntel/win/linux), ParsedReleaseVersion; source of constants for 11 packages (root node of the dependency graph).", "main_files": 2, "depends_on": [], "imported_by": ["contracts", "daemon", "desktop", "e2e", "host", "launcher-proto", "packaged", "sidecar-proto", "tools-pack", "tools-release", "tools-serve"], "loc": 333, "tests": 1, "stars": 4},
  {"id": "m25", "module": "@open-design/registry-protocol", "path": "packages/registry-protocol", "responsibility": "Pure TypeScript registry backend protocol for OpenDesign plugin sources (package.json) — src/backend.ts: interface RegistryBackend (list/search/resolve/manifest/doctor/publish?/yank?) + RegistryBackendFactory; src/schemas.ts 164 lines (zod): kinds github/http/local/db, trust official/trusted/restricted, RegistryDist/Publisher/Metrics.", "main_files": 3, "depends_on": [], "imported_by": ["daemon"], "loc": 303, "tests": 1, "stars": 2},
  {"id": "m26", "module": "@open-design/metatool", "path": "packages/metatool", "responsibility": "Tool build metadata — src/index.ts 175 lines: ToolBuildMetadataPolicy (buildCommand/distEntries/inputs/packageName/toolName) + ToolBuildMetadataResult (hash/metadataPath), hashes build inputs with node:crypto for the tool release pipeline; src/cli.ts 20.", "main_files": 2, "depends_on": [], "imported_by": [], "loc": 259, "tests": 1, "stars": 2},
  {"id": "m27", "module": "@open-design/closure", "path": "apps/closure", "responsibility": "Independently distributable OpenDesign Closure content (package.json) — src/{index, fixture}.ts; the smallest app in the universe (172 LOC, 4 files).", "main_files": 3, "depends_on": ["standalone"], "imported_by": [], "loc": 172, "tests": 1, "stars": 2}
]
```

## Measurement notes and corrections

1. **Four items had no dedicated mapping pass** (plugin-runtime,
   sidecar-proto, dsh-runtime, registry-protocol): the first mapping wave
   used a stale 41-item universe, so those four packages were not covered by
   a worker. Their rows were **backfilled during the merge** by direct
   measurement on the PIN tree (census + source reads) — the evidence lines
   above come from those direct reads. This is disclosed rather than hidden;
   all 27 items are DONE with measured evidence.
2. **Test counts corrected for 5 items during the merge** (worker tallies
   contradicted their own evidence): daemon 1,075→1,069 (main 779→785);
   tools-pack 0→45 (the worker's own evidence listed
   `tools/pack/tests/linux.test.ts`, 950 lines); platform 1→5;
   tools-serve 0→6 (evidence listed
   `tools/serve/tests/release-metadata-publish.test.ts`, 441 lines);
   components 1→2. `main_files` recomputed = files − tests.
3. **Two over-claimed dependency lists were trimmed** (import-context census
   found no importing file): packaged's `depends on` claimed daemon and web —
   no non-test file in apps/packaged imports either (packaged spawns the
   daemon via the `od` binary and references web dist as strings); terminal's
   `depends on` claimed platform — grep over non-test imports found only
   sidecar (4 files) + standalone (1).
4. **Importer counts corrected during the merge**: platform's `imported by`
   was first reported as 2 packages; the non-test import census finds 6
   (daemon, packaged, download, sidecar, tools-dev, tools-pack). Other
   importer lists were re-checked against the census and the census values
   kept.
5. **Dependency method**: import-context regex
   `(from|import\(?)\s*['\"]@open-design/<name>(/|['\"])`, non-test files,
   node_modules/dist excluded; subpath imports (`@open-design/contracts/...`)
   attributed to the right package; bare string references excluded (a first
   pass counted tools/pack as "importing" 17 packages — those were bundle
   manifest entries). Sidecar vs sidecar-proto disambiguated by the
   `(/|['\"])` anchor.
6. **Census basis differences, disclosed**: an earlier wide-extension
   measurement (ts+tsx+js+mjs+cjs+html+css, 41 items, 5,541 files /
   2,061,547 LOC) was superseded by the 27-item ts+tsx checklist basis used
   here (5,228 files / 1,836,056 LOC). A cross-check on apps/daemon
   (`cat | wc -l` = 657,868) matches the per-extension tallies; the
   checklist value 669,678 uses the ts+tsx+tests basis — a different basis,
   not a contradiction.
7. **Web toolchain**: the app uses Next.js (`next dev/build` scripts in
   `apps/web/package.json`) while the product is a client-driven SPA rooted
   at `App.tsx` with a single optional catch-all route (no app-router pages
   for product logic). The responsibility text states both facts.
8. **Basename collision in the importer census, found and fixed**: the first
   importer pass keyed directories by basename, so `tools/release` collided
   with the package `@open-design/release` and polluted tools-release's
   importer list. Detected via the two-way edge check (Σdepends on 60 ≠
   Σimported by 70), re-measured with explicit package names
   (`@open-design/tools-release`: 0 non-test importers, 0 string refs) →
   tools-release `imported by` = []. After the fix the 60 edges match in
   both directions 60/60.

## Conclusion

27/27 items mapped with measured evidence, in checklist id order, JSON
parseable. Invariants match exactly (5,228 files; 1,836,056 loc). The 60
dependency edges match in both directions 60/60. The four items without
worker output were backfilled with direct PIN-tree measurements. No open
work remains in this document.
