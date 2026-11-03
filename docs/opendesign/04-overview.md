---
subject: nexu-io/open-design
measured_at: 5a0c47777975ddb91d09c1c16b423a3ef74bf572
status: final
---

# Overview — open-design (nexu-io)

All `file:line` references were verified on a shallow sparse clone of the pinned
tree `5a0c47777975ddb91d09c1c16b423a3ef74bf572` (branch `main`,
`--filter=blob:limit=1m`, sparse subset `apps packages tools shells e2e
clipper figma-plugin` + `*.md *.json *.yaml *.toml`; `scripts/` materialized
additionally for the build verification in section 8). Census numbers for
workspace items come from [`02-module-map.md`](02-module-map.md) (27 items,
5,228 ts/tsx files, 1,836,056 loc, measured on the same PIN).

## 1. What open-design is

1. **open-design** (nexu-io) is a TypeScript pnpm monorepo shipping
   "the 1st collaborative AI design agent workspace" (`README.md:1,28`) — a
   local-first design product that "detects your installed code-agent CLI,
   runs design skills + design systems, streams artifacts into a sandboxed
   preview" (`package.json:7`).
2. Its runtime center is an Express daemon (`apps/daemon`) that owns the
   `/api/*` surface, persists state in SQLite, streams agent events over SSE,
   and spawns installed coding-agent CLIs (Claude Code, Codex, OpenCode,
   Cursor Agent, Copilot, DeepSeek, DeepSeek Harness, …) as local runtimes
   (`apps/daemon/src/server.ts:29`, `apps/daemon/src/db.ts:8`,
   `apps/daemon/src/runtimes/registry.ts:2-6,42-54`).
3. The primary UI is a Next.js 16 web app (`apps/web`, Next `16.2.6` /
   React `18.3.1` at `apps/web/package.json:52,56`) consumed from a browser,
   from the Electron desktop shell (`apps/desktop`), or from a container where
   the daemon serves the static export from one origin
   (`docs/architecture.md:44-53,81-95`; `vercel.json:4-7`).
4. The repository also carries the content layer — 171 skill entries, 116
   design templates, 154 design systems, official plugins, craft rules — plus
   a Chrome "clipper" extension and a Figma plugin as ingestion satellites
   (`ls skills | wc -l` = 171, `ls design-templates | wc -l` = 116,
   `ls design-systems | wc -l` = 154; `clipper/manifest.json`;
   `figma-plugin/manifest.json`).
5. Version 0.25.1, Apache-2.0, Node `~24` + pnpm `10.33.2`, 27 workspace
   packages totalling ~1.84M lines of ts/tsx (`package.json:3,8,42-45`;
   `mise.toml:2-3`; invariants in `02-module-map.md`).

## 2. OpenDesign in 5 minutes

- **Monorepo shape**: pnpm workspaces `packages/*`, `apps/*`, `tools/*`,
  `shells/*`, `e2e` (`pnpm-workspace.yaml:1-6`) — 27 workspace items in the
  census, from `@open-design/web` (877,858 loc) down to `@open-design/closure`
  (172 loc) (`02-module-map.md` table).
- **One CLI entry**: root `bin` maps `od` → `apps/daemon/bin/od.mjs`, which
  imports the daemon dist bundle and tells you to run `pnpm bootstrap` (or
  `pnpm --filter @open-design/daemon build`) when it is missing
  (`package.json:9-11`; `apps/daemon/bin/od.mjs:12-16`).
- **Dev loop**: `corepack enable && pnpm install && pnpm tools-dev run web`
  from the repo root (`README.md:318-327`); `tools-dev` allocates free daemon
  and web ports dynamically and rewrites `/api/*`, `/artifacts/*`, `/frames/*`
  to the sibling Express process (`docs/architecture.md:20-31`).
- **Daemon = authority**: Express app composed in `server.ts` (18,962 lines)
  with focused route modules under `apps/daemon/src/routes/` (chat, collab-*,
  design-system-tool, automation, deploy, …); default port 7456, env
  `OD_PORT` (`apps/daemon/src/cli.ts:10091,1290`).
- **Persistence**: synchronous better-sqlite3 database opened in
  `apps/daemon/src/db.ts` (6,007 lines), rooted at a single `OD_DATA_DIR`
  resolved once at startup (`docs/architecture.md:148-150`).
- **Agent runtimes**: one `RuntimeAgentDef` per CLI plus user-defined
  profiles, probed concurrently on each detection pass; the executable probed
  is the same one a run will spawn (`docs/architecture.md:112-124`).
- **Content registries**: functional skills (`skills/` → `/api/skills`),
  design templates (`design-templates/`), design systems (`design-systems/`),
  plugins (`plugins/_official/` + configured registries), craft rules
  (`craft/`) — user-writable roots shadow bundled entries by id
  (`docs/architecture.md:126-145`).
- **Sidecar IPC**: helper processes talk JSON over stdin/stdout; the wire
  contract lives in `@open-design/sidecar-proto` (`APP_KEYS`, `SIDECAR_MODES`,
  `SIDECAR_SOURCES`, `SIDECAR_ENV` env names)
  (`packages/sidecar-proto/src/index.ts:3-35`).
- **Packaging chain**: `apps/packaged` bootstraps packaged daemon/web sidecars
  with channel/namespace-scoped identity; `tools/pack` bundles installers
  (Linux AppImage/deb/rpm in `tools/pack/src/linux.ts`, 1,369 lines)
  (`docs/architecture.md:33-43`; `02-module-map.md` m06/m08).
- **Verified from this clone**: `pnpm install --frozen-lockfile` finished
  clean in 2m25s and `pnpm -r build` exited 0 (web compiled by Next.js
  16.2.6/Turbopack in 2.9min) — full transcript in section 8.

## 3. C4 level 1 — system context

OpenDesign is one software system ("open-design") used by design-oriented
humans and by coding agents. Context diagram as a table (all rows evidence-backed):

| Actor / external system | Interaction with open-design | Evidence |
|---|---|---|
| Designer / PM (person) | Uses the web UI or the desktop app to start from a brief, review prototypes, comment, and share for feedback | `README.md:28-32` ("start with a brief … share it with your team"); `docs/architecture.md:56-58` (browser or Electron renderer at the top of the topology) |
| Engineer (person) | Receives the artifact — real HTML/CSS — and keeps building in Cursor/Codex/Claude Code; or exports PPTX/PDF/MP4 | `README.md:333-341` (workflow step 4) |
| Coding agent CLI (26 shipped third-party adapters + the native AMR runtime, e.g. DeepSeek Harness, Claude Code, Codex, OpenCode, Cursor Agent, Copilot) | Spawned by the daemon as a local runtime process inside the project workspace; streams events back over SSE; the registry also supports BYOK runtimes | `README.md:122` (26 CLIs banner); `apps/daemon/src/runtimes/registry.ts:2-21,42-61`; `QUICKSTART.md:14-16`; `docs/architecture.md:177-189` |
| Model provider APIs (BYOK) | Daemon-side BYOK proxy forwards model traffic; `@anthropic-ai/sdk` is a web dependency | `docs/architecture.md:13-17` (HTTP/SSE, SQLite, BYOK proxy are current reality); `apps/web/package.json:31` |
| OpenDesign Cloud / model router ("AMR Cloud") | Optional cloud runtime and account; also the hosted download/update surface | `README.md:12` (OpenDesign Cloud button); `CONTEXT.md` ("AMR Cloud — user-facing cloud runtime option … official model router") |
| Plugin registries | Plugin sources resolved through a backend protocol (github/http/local/db kinds) | `packages/registry-protocol/src/backend.ts:15,30`; `packages/registry-protocol/src/schemas.ts` (zod kinds) |
| MCP clients | MCP tools operate on the active project; the daemon ships MCP-related modules | `CONTEXT.md` ("MCP tools may use when no project is specified"); `apps/daemon/src/mcp-agent-install.ts` |
| External media services (e.g. ElevenLabs voices) | Audio workflows call configured providers with a fallback voice | `CONTEXT.md` ("ElevenLabs Fallback Voice — default voice option … when Home Audio composer cannot load configured ElevenLabs voices") |

Boundary summary: everything stateful (projects, artifacts, conversations,
files, credentials, registries) lives inside the daemon; agents and model
APIs are external processes/services the daemon orchestrates; the web and
desktop apps are views onto the daemon's HTTP API.

## 4. C4 level 2 — containers

Containers inside the open-design boundary (diagram adapted, evidence cited):

```
browser or Electron renderer
        │ same-origin HTTP + SSE
        ▼
Next.js web app (apps/web) ──────────────┐ (static UI / preview state)
        │ /api/* rewrites                │
        ▼                                │
Express daemon (apps/daemon) ◄───────────┘
   │        │           │
   │        │           └─ skills / design templates / design systems / plugins
   │        └─ SQLite state + daemon-owned project files (better-sqlite3)
   └─ runtime registry → spawned agent CLI / BYOK process
                              └─ structured events, file writes, text output
```
(`docs/architecture.md:56-78`; each edge re-verified below.)

| Container | Path | Role | Key evidence |
|---|---|---|---|
| Web app (Next.js SPA shell) | `apps/web` | UI for projects, chat, file workspace, preview, settings, marketplace; routes every URL through one optional catch-all into the client router | `apps/web/app/[[...slug]]/page.tsx:1-22` ("The whole product is a client-driven SPA … single optional catch-all"); `docs/architecture.md:81-95` |
| Express daemon | `apps/daemon` | Product authority for `/api/*`: projects, conversations, files, agent run bookkeeping, SSE, prompt composition, plugin/MCP/media/automation services; also serves the static export in production | `docs/architecture.md:96-110,44-53`; `apps/daemon/src/server.ts:29` (`import express`), `:18838` (`app.listen`) |
| `od` CLI | `apps/daemon/bin/od.mjs` | Machine-readable surface over the same daemon HTTP APIs — not a second business-logic implementation | `package.json:9-11`; `docs/architecture.md:80` |
| Electron desktop main | `apps/desktop` | Desktop shell (BrowserWindow/Menu/ipcMain), startup timing, updater; discovers the web URL through sidecar IPC instead of assuming a port | `apps/desktop/src/main/index.ts:8-20`; `docs/architecture.md:33-43` |
| Packaged runtime | `apps/packaged` | Bootstraps packaged daemon + web sidecars for installed builds; consumed by `tools/pack` | `docs/architecture.md:33-43`; `02-module-map.md` m08 |
| Sidecar process | spawned helper | JSON-IPC over stdin/stdout; client library `@open-design/sidecar`, wire contract `@open-design/sidecar-proto` | `packages/sidecar-proto/src/index.ts:3-35`; `02-module-map.md` m09 |
| Terminal shell | `shells/terminal` | `.mjs` shell runtime that hosts a sidecar (`standalone.request.v1` action via env `OD_TERMINAL_SIDECAR_CONFIG_V1`) | `shells/terminal/runtime/sidecar-host.mjs` (410 lines, `02-module-map.md` m16) |
| SQLite database | daemon-owned file | Synchronous better-sqlite3 store for projects/conversations/state | `apps/daemon/src/db.ts:8` (`import Database from 'better-sqlite3'`) |
| e2e suite | `e2e` | Playwright functional + visual regression, plus import-guard scripts | `e2e/playwright.config.ts:1-3`; `02-module-map.md` m03 |

External containers (outside the boundary): agent CLIs, model APIs, cloud
services, plugin registries (section 3). The container set above matches the
27-item workspace census: 5 apps, 16 packages, 4 tools, 1 shell, e2e
(`ls apps packages tools shells`; `02-module-map.md`).

## 5. C4 level 3 — key components

Daemon (`apps/daemon`) internals:

- **Composition root**: `apps/daemon/src/server.ts` (18,962 lines) wires
  strategies, collab, design systems, evidence delivery, and HTTP middleware
  (`server.ts:1-29` imports; `docs/architecture.md:107-108` "server.ts still
  composes the application, while route modules under `apps/daemon/src/routes/`
  own increasingly focused HTTP boundaries").
- **Route modules**: `apps/daemon/src/routes/` — `chat.ts`, `collab-context.ts`,
  `collab-presence.ts`, `collab-sync.ts`, `automation.ts`, `browser-sessions.ts`,
  `design-system-tool.ts`, `deploy.ts`, `daemon.ts`, … (`ls apps/daemon/src/routes`).
- **Runtime registry**: `apps/daemon/src/runtimes/registry.ts` (91 lines)
  aggregates exactly **27 shipped `RuntimeAgentDef`s** (`SHIPPED_AGENT_DEFS`,
  `registry.ts:40-68` — amr, claude, codex, devin, opencode, byok-opencode,
  hermes, trae-cli, grok-build, kimi, cursor, qwen, qoder, copilot, amp, pi,
  kiro, kilo, vibe, deepseek, deepseek-harness, aider, antigravity, reasonix,
  codebuddy, mimo, atomcode) plus user-defined local profiles
  (`readLocalAgentProfileDefs`, `registry.ts:70+`).
- **Persistence**: `apps/daemon/src/db.ts` (6,007 lines) over better-sqlite3
  (`db.ts:8`); data root from `OD_DATA_DIR` resolved once at startup
  (`docs/architecture.md:148-150`).
- **Plugins & MCP**: `apps/daemon/src/plugins/{apply,persistence,snapshot-diff}.ts`,
  `apps/daemon/src/mcp-agent-install.ts` (grep hits for mcp).

Web app (`apps/web`) internals:

- **App shell**: `apps/web/src/App.tsx` (6,414 lines) — top-level component
  tree with onboarding, analytics, workspace removal boundary, concurrency
  dialogs (`App.tsx:1-25`).
- **Routing**: `apps/web/app/[[...slug]]/page.tsx:1-22` — one optional
  catch-all delegates to the client router `src/router.ts` which reads
  `window.location` at runtime; `output: 'export'` emits one shell HTML at
  `out/index.html`, and the daemon's SPA fallback serves unknown non-API paths.
- **Feature zones**: `components/` (incl. `FileViewer.tsx`, 20,759 lines —
  the largest file in the repo), `features/`, `edit-mode/`, `collab/`,
  `comments/`, `campaigns/`, `analytics/`, `artifacts/`
  (`02-module-map.md` m01; `wc -l` re-verified).
- **Preview renderer**: sandboxed iframes; the URL-vs-srcDoc decision lives in
  `apps/web/src/components/file-viewer-render-mode.ts`
  (`docs/architecture.md:164-173`).

Shared boundary packages (the vocabulary between containers):

- `@open-design/contracts` — "Shared pure TypeScript contracts for the
  OpenDesign web/daemon boundary" (`packages/contracts/package.json:6`);
  imported by 8 workspace packages; execution profiles map runtime stream
  formats to handoff profiles (`packages/contracts/src/execution-profile.ts`,
  `docs/architecture.md:191-199`).
- `@open-design/sidecar-proto` — wire constants and env names for sidecar IPC
  (`packages/sidecar-proto/src/index.ts:3-35`).
- `@open-design/host` — renderer host-bridge request/result types
  (`packages/host/src/protocol.ts`, 449 lines; m18 in the module map).
- `@open-design/launcher-proto` — launcher flags/args contract
  (`--od-launcher-*`; m20 in the module map).

## 6. Folder map and zone roles

Top-level zones (counts re-verified with `ls | wc -l` on the PIN clone):

| Zone | Entries | Role |
|---|---|---|
| `apps/` | 5 (+ AGENTS.md) | Shippable runtimes: `web` (Next.js UI), `daemon` (Express + CLI), `desktop` (Electron main), `packaged` (packaged bootstrap), `closure` (independently distributable content app) |
| `packages/` | 16 (+ AGENTS.md) | Shared libraries — contracts, sidecar, sidecar-proto, host, launcher-proto, platform, download, standalone, plugin-runtime, registry-protocol, diagnostics, components, agui-adapter, release, dsh-runtime, metatool |
| `tools/` | 4 (+ AGENTS.md) | Developer/release CLIs — `dev` (local env + process supervision), `pack` (installers), `release` (catalog/metadata/notifications/report/storage), `serve` (local fixture servers) |
| `shells/` | 1 (+ AGENTS.md) | `terminal` — terminal shell runtime (`.mjs` sidecar host) |
| `e2e/` | 1 workspace | Playwright functional + visual suites, page objects, import-guard scripts |
| `docs/` | 22 dirs | Architecture (`architecture.md`), ADRs, deployment, CI, i18n, screenshots |
| `skills/` | 171 | Functional skills an agent invokes (bundled registry root) |
| `design-templates/` | 116 | Renderable starting points for creation workflows |
| `design-systems/` | 154 | Brand tokens/rules/fixtures (airbnb, apple, ant, …) |
| `plugins/` | 7 | `_official` bundles, `community`, `registry`, `spec`, plugin docs |
| `clipper/` | Chrome extension | Web capture satellite (`manifest.json`, `background.js`, `capture.js`) |
| `figma-plugin/` | Figma plugin | `manifest.json`, `code.js`, `ui.html`, `IR.md` |
| `craft/`, `prompt-templates/`, `templates/`, `story/` | — | Composition inputs the daemon uses when building prompts |
| `specs/` | 4 | Living specs (`2026-04-29-live-artifacts`, `change`, `current`, `od-clipper.md`) |
| `deploy/`, `charts/`, `vercel.json` | — | Docker Compose, Azure ACI (bicep), AWS (template.yaml), Helm, Vercel |
| `mocks/`, `data/`, `assets/`, `ui-audit/`, `scripts/` | — | Fixtures, seed data, static assets, audits, repo scripts |

Each workspace zone carries its own `AGENTS.md` layer contract (root
`AGENTS.md:39,71` — daemon data directory contract is the only path authority).

## 7. High-value flows

The deep-dive into expensive runtime flows (brief → plugin → direction →
design system → artifact → handoff; agent run lifecycle; sidecar handoff)
lives in **[`06-flows.md`](06-flows.md)** — the companion flows document.
It was produced after this overview; treat it as the authoritative flow
reference and do not duplicate its content here.

Teaser from the README's own workflow summary: the product pipeline is
`brief → plugin → direction → design system → artifact → handoff → memory`,
and the two daemon execution profiles are **filesystem execution** (agent
CLIs with tool access write canonical project files; file events drive the
workspace/preview) and **text-artifact execution** (plain-stream/BYOK
runtimes emit one `<artifact>` block that the host materializes into the same
workspace) — mapped by
`packages/contracts/src/execution-profile.ts`
(`README.md:333-341`; `docs/architecture.md:175-199`).

## 8. Build and harness — verified commands

Environment actually used (a `bitnami/git:latest` container, 2 CPU /
4 GiB, x86_64): the image ships **no node/pnpm**, so Node was installed from
the official dist (`node-v24.22.2-linux-x64`, satisfies `engines.node ~24`)
and pnpm was resolved through the repo's `packageManager` pin
(`pnpm@10.33.2`).

Commands and real outputs on the PIN clone:

1. **Install**
   ```
   pnpm install --frozen-lockfile
   ```
   → `Done in 2m 25s using pnpm v10.33.2`, exit 0. Native deps in
   `onlyBuiltDependencies` all built (electron, sharp, core-js,
   electron-winstaller, …). One warning to know about:
   `Ignored build scripts: @ffmpeg-installer/linux-x64@4.1.0,
   @ffprobe-installer/linux-x64@5.2.0, @google/genai@1.52.0, node-pty@1.1.0`
   (pnpm 10 only runs approved build scripts — these four are not in
   `onlyBuiltDependencies`, so their postinstall code did not run here).
2. **Build**
   ```
   pnpm -r build
   ```
   → exit 0. Highlights from the real output: `apps/web build: ▲ Next.js
   16.2.6 (Turbopack)` … `✓ Compiled successfully in 2.9min`, static pages
   `4/4`, routes `/_not-found`, `/[[...slug]]`, `/desktop-pet`;
   `apps/daemon build: Done` (tsc); `apps/desktop`, `apps/packaged`,
   `apps/closure`, `packages/plugin-runtime`, `packages/standalone`: Done;
   `tools/dev`, `tools/pack`, `tools/release`: Done, each emitting a
   metatool build-metadata hash (e.g.
   `"hash":"d20b381d…","metadataPath":"…/tools/pack/dist/metadata.json"`).
3. **Run (documented, not executed here)**: `pnpm tools-dev run web`
   (`README.md:322-327`) or the containerized path `cd deploy && cp
   .env.example .env` → set `OD_API_TOKEN` → `docker compose up -d` →
   `http://127.0.0.1:7456` (`QUICKSTART.md:57-88`).

Honest caveats from this run:

- First `pnpm install` attempt failed with `MODULE_NOT_FOUND:
  /workspace/opendesign/scripts/postinstall.mjs` — the root postinstall hook
  (`package.json:12`) needs `scripts/`, which the prescribed sparse-checkout
  glob set (`*.md *.json *.yaml *.toml`) does not materialize. Materializing
  `scripts/` (`git sparse-checkout add scripts`) fixed it. Any sandbox that
  clones with the same sparse subset must add `scripts/` before install.
- pnpm/corepack needed two transient retries ("Error: fetch failed" from the
  registry fetch); after retry both install and build completed clean. On a
  restricted network, budget for corepack fetch retries.
- Typechecking during web build reported `Skipping validation of types`
  (Next build config) — the repo's dedicated check is
  `pnpm typecheck` (`package.json:39`), not executed here.

## 9. High-value extension points

From the module map (`02-module-map.md`) — the seams where third-party code
plugs in with the least friction:

- **`@open-design/contracts`** (m04) — the dependency-graph hub (8 importer
  packages); new web/daemon features should extend shared types here first.
- **Agent runtime adapters** — add a CLI runtime by contributing a
  `RuntimeAgentDef` to `apps/daemon/src/runtimes/registry.ts` (launch, prompt
  delivery, stream format, capability probes) instead of touching the daemon
  engine (`docs/architecture.md:112-124`).
- **`@open-design/plugin-runtime`** (m13) — pure-TS manifest parsing/merging
  with **no `node:fs` imports**; loaders are injected by daemon/web/CI
  (`packages/plugin-runtime/package.json:6`) — safe to reuse in any host.
- **`@open-design/registry-protocol`** (m25) — implement
  `RegistryBackend`/`RegistryBackendFactory`
  (`packages/registry-protocol/src/backend.ts:15,30`) to add a plugin source
  backend (zod-validated kinds: github/http/local/db).
- **`@open-design/agui-adapter`** (m23) — AG-UI ↔ OpenDesign event bridge
  (`packages/agui-adapter/src/index.ts:1`) for standards-based agent UIs.
- **`@open-design/sidecar` + `sidecar-proto`** (m09/m17) — the JSON-IPC
  contract any helper process can speak (8 importer packages each).
- **`@open-design/dsh-runtime`** (m21) — a working example of embedding
  OpenDesign as a harness plugin (`RUNTIME_NAME = 'open-design'`,
  `packages/dsh-runtime/src/protocol.ts:2`).
- **Content registries** — skills/design templates/design systems are data
  dirs with user-shadowing semantics (`docs/architecture.md:126-145`); new
  content needs no code.

## 10. Risks when reusing

1. **Monorepo-only packages**: root is `private: true` and all cross-refs use
   `workspace:*` (`package.json:4`; devDependencies block) — `@open-design/*`
   packages are not published artifacts; reusing one package means vendoring
   it and its dependency fan-out (e.g. `contracts` is imported by 8 packages).
2. **God files**: `apps/web/src/components/FileViewer.tsx` = 20,759 lines and
   `apps/daemon/src/server.ts` = 18,962 lines **starting with `// @ts-nocheck`**
   (`wc -l`; `server.ts:1`) — type safety is disabled on the daemon's core
   composition file, so pull targeted pieces, not wholesale copies.
3. **Duplicate, drifting override pins**: `package.json` (pnpm.overrides
   block, 13 entries incl. `fast-uri 3.1.5`, `hono 4.12.34`,
   `brace-expansion 5.0.9`, `tar`, `undici`) vs `pnpm-workspace.yaml:8-18`
   (10 entries with `fast-uri 3.1.2`, `hono 4.12.19`,
   `brace-expansion 5.0.6`, no tar/undici). Both exist at the PIN; which one
   wins is pnpm-version-dependent [to be verified]. Forks must reconcile them.
4. **Native dependency surface**: electron, better-sqlite3,
   onnxruntime-node, sharp (plus electron-winstaller, esbuild, protobufjs,
   core-js) are in `onlyBuiltDependencies` (`pnpm-workspace.yaml:20-29`) —
   installs download platform binaries and need approved build scripts; four
   other packages' scripts were silently ignored in our run (section 8).
5. **Toolchain pin**: `engines: node ~24, pnpm >=10.33.2 <11`
   (`package.json:42-45`) + corepack fetch at setup (`QUICKSTART.md:9-10,30-34`)
   — older Node or an air-gapped network breaks bootstrap (we hit registry
   fetch flakiness ourselves).
6. **Data-path contract**: daemon-owned data paths are governed by root
   `AGENTS.md:71` ("Daemon data directory contract"); reimplementations must
   not improvise paths (`docs/architecture.md:148-162` — `OD_DATA_DIR`
   resolved once; folder import is the single external-workspace exception).
7. **Deployment shape coupling**: production assumes the daemon serves the
   static web export from one origin (`vercel.json:4-7` outputDirectory
   `apps/web/out`; `docs/architecture.md:44-53`) — hosting the web app
   standalone requires re-wiring `/api/*`, `/artifacts/*`, `/frames/*`.
8. **Platform gaps**: no prebuilt Linux desktop artifact; Linux users run
   from source (`README.md:254`); Windows native has known setup gotchas
   (`QUICKSTART.md:11`, `docs/windows-troubleshooting.md`).
9. **Scale**: ~1.84M ts/tsx lines across 27 items with heavy test mass
   (3,067 test files vs 2,161 main files, `02-module-map.md`) — wholesale
   forks are expensive; extract along the package boundaries of section 9
   instead.

## 11. Provenance

- **Upstream**: https://github.com/nexu-io/open-design
- **Pin (measured tree)**: `5a0c47777975ddb91d09c1c16b423a3ef74bf572`
  (branch `main`; `git rev-parse HEAD` + `git branch --show-current` re-run
  in the verification container). Commit subject per the module map:
  "fix(web): hide Labs settings when no experiments are available (#9076)"
  (2026-11-02 03:25:06 +0000).
- **License**: **Apache-2.0** — declared at `package.json:8`
  (`"license": "Apache-2.0"`), `LICENSE` exists in the full git tree
  (`git ls-tree -r HEAD` → `LICENSE`; `git show HEAD:LICENSE` begins
  "Apache License / Version 2.0, January 2004"), and the README badge links
  it. Note for harvest tooling: `LICENSE` (no extension) is NOT matched by
  the sparse-checkout glob set used here — fetch it via `git show` if needed.
- **Clone method**: `git clone --depth 1 --single-branch
  --filter=blob:limit=1m` + `sparse-checkout set --no-cone apps packages
  tools shells e2e clipper figma-plugin '*.md' '*.json' '*.yaml' '*.toml'`
  (+ `scripts/` added for the build verification in section 8). Full repo is
  ~3.6 GB — full clones are unnecessary and wasteful.
- **Verification date**: 2026-11-03 (container clock; PIN commit dated
  2026-11-02).

## 12. Open questions

1. **Override precedence**: `package.json` `pnpm.overrides` and
   `pnpm-workspace.yaml` `overrides` disagree on four pins (section 10.3).
   Which block pnpm 10.33.2 applies at install time, and is one of them dead
   config? [to be verified]
2. **Ignored build scripts**: are `@ffmpeg-installer`, `@ffprobe-installer`,
   `@google/genai`, `node-pty` intentionally excluded from
   `onlyBuiltDependencies` (security posture), or an oversight that degrades
   media/PTY features in fresh installs? Their postinstall code did not run
   in our verification.
3. **Test suite cost**: this run verified `install` + `build` only. Per
   package test commands exist (e.g. `apps/web/package.json:28` vitest) and
   `pnpm typecheck` (`package.json:39`) — a full `pnpm -r test` pass was out
   of sandbox budget; runtime behavior claims beyond compile-level rest on
   `docs/architecture.md` + code reading.
4. **Shipped CLI count**: the registry exports exactly 27 shipped defs
   (`SHIPPED_AGENT_DEFS`, `registry.ts:40-68`, incl. the OpenDesign-native
   `amrAgentDef` at `registry.ts:41`), while the README banner advertises 26
   third-party coding-agent CLIs (`README.md:122`) — the 1-def gap is AMR.
   The number of CLIs a given user sees is still runtime-dependent
   (detection probes installed executables; BYOK profiles are user-defined).
5. **Flow cross-check**: section 7 defers to `06-flows.md`; its flow list was
   verified against the two execution profiles in
   `docs/architecture.md:175-199` (no drift found).
