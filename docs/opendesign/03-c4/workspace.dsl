workspace "OpenDesign" "C4 model of nexu-io/open-design - collaborative AI design agent workspace (TypeScript pnpm monorepo). Evidence is pinned to tree 5a0c47777975ddb91d09c1c16b423a3ef74bf572 (branch main); every element and relationship carries a '// evidence:' comment pointing into that tree." {

model {

  // ---------------------------------------------------------------------------
  // L1 - SYSTEM CONTEXT (actors)
  // ---------------------------------------------------------------------------

  designer = person "Designer" "Human user who starts from a brief, lets coding agents generate design prototypes in a project, reviews previews and shares results for team feedback."
  // evidence: README.md:9-11 (What is OpenDesign); docs/architecture.md section 2 (browser or Electron renderer); CONTEXT.md:3-4

  cliuser = person "CLI user / automation" "Operates OpenDesign through the od command-line client - the machine-readable surface over the same daemon HTTP APIs as the web UI."
  // evidence: docs/architecture.md section 2 (The web UI and the od CLI call the same daemon HTTP APIs); apps/daemon/bin/od.mjs:1; apps/daemon/src/cli.ts (12,979 lines, wc -l)

  // ---------------------------------------------------------------------------
  // L1 - SOFTWARE SYSTEM IN SCOPE, L2 CONTAINERS, L3 COMPONENTS
  // (containers = the pillar pnpm workspace packages + daemon-owned store;
  //  components = deep dives of the three main containers)
  // ---------------------------------------------------------------------------

  opendesign = softwareSystem "OpenDesign" "Collaborative AI design agent workspace: Next.js web app, Express daemon, Electron desktop shell, packaged launchers, sidecar IPC, plugin runtime and tooling in one TypeScript pnpm monorepo." {
    // evidence: README.md:1 (OpenDesign: The 1st Collaborative AI Design Agent Workspace); CONTEXT.md:3-4; pnpm-workspace.yaml (workspaces: packages/*, apps/*, tools/*, shells/*, e2e)

    web = container "Web App" "Next.js 16 / React 18 UI: project, chat, file workspace, preview, settings, marketplace and creation workflows; renders streamed runtime events and inline artifacts." "Next.js 16, React 18" {
      // evidence: docs/architecture.md section 3.1; apps/web/package.json:2 (@open-design/web) + scripts (next dev --turbopack / next build); apps/web/src/App.tsx (6,414 lines, wc -l)

      // L3 - COMPONENTS: WEB APP (deep dive 1/3)

      webShell = component "App shell and router" "Top-level React application shell composing project, chat, settings, marketplace and creation workflows; roots the component tree." "React 18"
      // evidence: apps/web/src/App.tsx (6,414 lines, wc -l); apps/web/src/router.ts; docs/architecture.md section 3.1

      webFileUi = component "File workspace UI" "Project file listing, viewing and editing surfaces including the FileViewer." "React 18"
      // evidence: apps/web/src/components/FileViewer.tsx (20,759 lines, wc -l); apps/web/src/components/ (319 entries)

      webPreview = component "Preview renderer" "Chooses srcDoc versus URL rendering for project file previews; bridges inspection and comment selection from sandboxed iframes." "TypeScript"
      // evidence: apps/web/src/components/file-viewer-render-mode.ts (317 lines, wc -l); docs/architecture.md section 3.6

      webTransport = component "Daemon transport" "Providers calling daemon /api/* over HTTP + SSE and subscribing to project/runtime events." "TypeScript"
      // evidence: apps/web/src/providers/daemon.ts; apps/web/src/providers/sse.ts; apps/web/src/providers/project-events.ts; docs/architecture.md sections 3.1, 5

      webByok = component "BYOK transports" "Direct user-keyed provider transports for anthropic/openai/azure/google/ollama/aihubmix protocols." "TypeScript"
      // evidence: apps/web/src/providers/anthropic.ts, openai-compatible.ts, azure-compatible.ts, google-compatible.ts, ollama-compatible.ts, aihubmix-compatible.ts (ls apps/web/src/providers/)

      webCollab = component "Collab and comments UI" "Team collaboration surfaces: workspace presence, shares and comment threads." "React 18"
      // evidence: apps/web/src/collab/ (36 entries, ls); apps/web/src/comments/ (7 entries, ls); apps/daemon/src/routes/collab-presence.ts (server counterpart)
    }

    daemon = container "Daemon" "Express HTTP server plus od CLI - product authority for /api/*: projects, chat/runs over SSE, files, plugins, MCP, media, design systems, collab; owns the SQLite state." "Node.js 24, Express" {
      // evidence: docs/architecture.md section 3.2; apps/daemon/src/server.ts (18,962 lines, wc -l); apps/daemon/bin/od.mjs:1

      // L3 - COMPONENTS: DAEMON (deep dive 2/3)

      daemonServer = component "Server composition" "Composes the Express application, resolves OD_DATA_DIR once into RUNTIME_DATA_DIR, owns loopback and security policy." "Node.js"
      // evidence: apps/daemon/src/server.ts (18,962 lines, wc -l); server.ts:1431 (RUNTIME_DATA_DIR = resolveDataDir(process.env.OD_DATA_DIR, ...)); docs/architecture.md sections 3.2, 3.5, 7

      daemonRoutes = component "HTTP route modules" "Focused /api/* boundaries: chat, project, plugins, design-systems, runs, media, memory, terminal, collab-sync, team resources, automation, deploy and more." "Express"
      // evidence: apps/daemon/src/routes/ (39 modules - chat.ts, project/, plugins/, runs.ts, design-systems.ts, media.ts, memory.ts, terminal.ts, collab-sync.ts, team-resources.ts; ls apps/daemon/src/routes/); docs/architecture.md section 3.2

      daemonDb = component "SQLite persistence" "better-sqlite3 data access for projects, conversations, comments, plugin and automation state." "better-sqlite3"
      // evidence: apps/daemon/src/db.ts:8 (import Database from 'better-sqlite3'); db.ts:85 (app.sqlite); db.ts:428 (sqlite_master queries)

      daemonRuntimes = component "Runtime registry and agent processes" "Detects, launches and streams shipped coding-agent runtimes plus user local profiles; includes the BYOK CLI runtime and ACP handshake handling." "Node.js child processes"
      // evidence: apps/daemon/src/runtimes/registry.ts:20-58 (SHIPPED_AGENT_DEFS); apps/daemon/src/runtimes/defs/ (26 defs); apps/daemon/src/runtimes/agent-process.ts; apps/daemon/src/runtimes/byok-cli.ts

      daemonCollab = component "Collab-cloud service" "Ties the collab-cloud client to the workspace context: member registration, comment push, pull+merge poller; degrades to no-op off-team." "Node.js"
      // evidence: apps/daemon/src/collab/collab-cloud-service.ts:1-9; apps/daemon/src/collab/ (60+ modules, ls)

      daemonCli = component "od CLI" "Machine-readable command surface for the same daemon capabilities." "Node.js"
      // evidence: apps/daemon/src/cli.ts (12,979 lines, wc -l); apps/daemon/bin/od.mjs:1 (bin od -> dist/cli.js)

      daemonMcp = component "od mcp stdio server" "Proxies project tool calls to the running daemon HTTP API for external MCP clients." "Node.js + @modelcontextprotocol/sdk"
      // evidence: apps/daemon/src/mcp.ts:1-10 (proxy contract), mcp.ts:16-22 (imports @modelcontextprotocol/sdk Server/StdioServerTransport)
    }

    desktop = container "Desktop Shell" "Electron main process: window/menu/ipc lifecycle, launch types, updater, captures and exports; wires sidecar IPC, contracts and launcher-proto." "Electron" {
      // evidence: docs/architecture.md sections 1, 2; apps/desktop/src/main/index.ts:1 (BrowserWindow/Menu/ipcMain/powerMonitor/shell); apps/desktop/src/main/runtime.ts (3,143 lines, wc -l)

      // L3 - COMPONENTS: DESKTOP SHELL (deep dive 3/3)

      desktopMain = component "Electron main lifecycle" "Creates BrowserWindow/Menu, registers ipcMain handlers and integrates powerMonitor and shell." "Electron"
      // evidence: apps/desktop/src/main/index.ts:1 (BrowserWindow/Menu/ipcMain/powerMonitor/shell imports)

      desktopRuntime = component "Desktop runtime" "Wires the renderer session: splash and webview loadURL flows, launch types, sidecar and daemon wiring." "Electron"
      // evidence: apps/desktop/src/main/runtime.ts (3,143 lines, wc -l; loadURL flows at 284, 1443, 1542-1546); apps/desktop/src/main/launch-type.ts

      desktopUpdater = component "Updater" "Polls the configured metadata URL for update candidates, verifies checksums and applies package-launcher updates." "TypeScript"
      // evidence: apps/desktop/src/main/updater.ts:816-817 (fetchJson on config.metadataUrl), 1001-1015 (checksum + artifact), 519 (DESKTOP_UPDATE_MODES.PACKAGE_LAUNCHER)

      desktopCapture = component "Captures and exports" "Deck and frame capture plus artifact and PDF export flows." "Electron"
      // evidence: apps/desktop/src/main/deck-capture.ts (3,253 lines, wc -l); apps/desktop/src/main/frame-capture.ts; apps/desktop/src/main/artifact-export.ts; apps/desktop/src/main/pdf-export.ts (ls apps/desktop/src/main/)

      desktopHostBridge = component "Host bridge (preload)" "Exposes the OPEN_DESIGN_HOST_GLOBAL host-bridge contract to the renderer via the preload script." "Electron preload (cts)"
      // evidence: apps/desktop/src/main/preload.cts; packages/host/src/protocol.ts:1-8 (renderer host-bridge wire contract, OpenDesignHostBridge); apps/web/src/lib/updater.ts imports @open-design/host
    }

    packaged = container "Packaged Launcher" "Packaging runtime that starts the packaged daemon and web sidecars with channel/namespace-scoped identities and parses launcher handoff args." "Node.js"
    // evidence: docs/architecture.md section 1 (apps/packaged starts the packaged daemon and web sidecars); apps/packaged/src/sidecars.ts (1,162 lines); apps/packaged/src/index.ts:1 (imports sidecar-proto APP_KEYS + launcher-proto parseLauncher*Args)

    sidecar = container "Sidecar IPC Client" "JSON-IPC client and operations registry bridging host runtimes and sidecar processes over stdin/stdout (connect/retry/dispatch)." "TypeScript library"
    // evidence: packages/sidecar/src/json-ipc.ts (418 lines, JSON transport over stdin/stdout); packages/sidecar/src/operations.ts (578 lines); docs/architecture.md section 1 (the desktop discovers the web URL through sidecar IPC)

    terminal = container "Terminal Shell" "Terminal shell runtime that bootstraps and hands off sidecar generations (standalone.request.v1) for the CLI workspace." "Node.js .mjs"
    // evidence: shells/terminal/runtime/sidecar-host.mjs:1-6 (410 lines; bootstrapSidecarProcess, handoffCurrentSidecarGeneration, SidecarFactory; OD_TERMINAL_SIDECAR_CONFIG_V1); shells/terminal/runtime/fossil.mjs (409 lines)

    contracts = container "Shared Contracts" "Pure TypeScript DTO and prompt contracts for the web/daemon boundary; imported by 8 workspace packages (daemon 323 + web 302 non-test files)." "TypeScript library"
    // evidence: packages/contracts/package.json (description: shared pure TypeScript contracts for the OpenDesign web/daemon boundary); module-map dependency census (daemon 323, web 302 non-test importers)

    pluginruntime = container "Plugin Runtime" "Pure-TS plugin runtime: manifest parsers, adapters, merger, ref resolver, validator, digest; loaders injected by daemon/web/CI (no node:fs imports)." "TypeScript library"
    // evidence: packages/plugin-runtime/package.json (description); packages/plugin-runtime/src/ (frontmatter.ts 254, agent-skill.ts 200, resolve.ts 177, merge.ts 101, validate.ts 93 lines)

    registryproto = container "Registry Protocol" "Registry backend protocol: backend interface plus zod schemas for github/http/local/db sources with trust levels." "TypeScript library"
    // evidence: packages/registry-protocol/src/backend.ts:15-31 (RegistryBackend, RegistryBackendFactory); packages/registry-protocol/src/schemas.ts:1-30 (RegistryBackendKindSchema, RegistryTrustSchema)

    dshr = container "DSH Runtime" "Cordis plugin exposing OpenDesign as a DeepSeek Harness runtime profile (session resume/cancel, structured events)." "TypeScript library"
    // evidence: packages/dsh-runtime/package.json (description); packages/dsh-runtime/src/index.ts:1-19 (injects @deepseek-ai/cordis + dsh-agent/dsh-llm/dsh-session)

    db = container "SQLite Database" "Daemon-owned relational state: projects, conversations, messages, comments, plugin, automation and credential state under OD_DATA_DIR (app.sqlite)." "SQLite (better-sqlite3)" "Database"
    // evidence: apps/daemon/src/db.ts:8 (import Database from 'better-sqlite3'); db.ts:85 (app.sqlite); apps/daemon/src/server.ts:1431 (RUNTIME_DATA_DIR = resolveDataDir(process.env.OD_DATA_DIR, ...)); docs/architecture.md section 3.5
  }

  // ---------------------------------------------------------------------------
  // L1 - EXTERNAL SYSTEMS
  // ---------------------------------------------------------------------------

  agents = softwareSystem "Coding agent CLIs" "Local coding agents (Claude Code, Codex, OpenCode, Cursor Agent, Qwen, Qoder, Copilot CLI, DeepSeek, DeepSeek Harness, ...) that the daemon detects and spawns per project run." "External"
  // evidence: apps/daemon/src/runtimes/registry.ts:20-58 (SHIPPED_AGENT_DEFS imports 26 defs); apps/daemon/src/runtimes/defs/ (claude.ts, codex.ts, opencode.ts, deepseek-harness.ts, ...); QUICKSTART.md (registry of local runtimes); docs/architecture.md sections 2, 3.3

  byok = softwareSystem "BYOK model providers" "User-keyed chat-model APIs (anthropic, openai-compatible, azure, google, ollama, aihubmix, senseaudio protocols) configured in Settings." "External"
  // evidence: apps/web/src/providers/ (anthropic.ts, openai-compatible.ts, azure-compatible.ts, google-compatible.ts, ollama-compatible.ts, aihubmix-compatible.ts, senseaudio-compatible.ts); apps/daemon/src/runtimes/byok-cli.ts:1-27 (protocol/baseUrl/keyEnv); QUICKSTART.md (BYOK runtime configured in Settings)

  collabcloud = softwareSystem "OpenDesign Collab Cloud" "Team collaboration hub for member registration, workspace publish/pull and comment sync; used only when OD_COLLAB_CLOUD_URL is configured." "External"
  // evidence: apps/daemon/src/collab/collab-cloud-service.ts:1-9 (client constructed only when OD_COLLAB_CLOUD_URL is set; member registration, comment push, pull+merge poller); apps/daemon/src/integrations/collab-cloud.ts (CollabCloudClient); tools/serve/src/collab-cloud-fixture.ts (dev fixture)

  releasesrv = softwareSystem "Release/update server" "Serves desktop update metadata and channel artifacts (checksum-verified) consumed by the desktop updater; a fixture server stands in during local dev." "External"
  // evidence: apps/desktop/src/main/updater.ts:816-817 (fetchJson(fetchImpl, config.metadataUrl)); updater.ts:1001-1015 (checksum + artifact url); tools/serve/src/index.ts:46-54 (release-storage fixture service)

  pluginregistries = softwareSystem "Plugin registries" "Configured plugin sources with github/http/local/db backends used to list, search, resolve and publish installable plugin bundles." "External"
  // evidence: packages/registry-protocol/src/backend.ts:15-31 (RegistryBackend list/search/resolve/manifest/publish?/yank?); packages/registry-protocol/src/schemas.ts (kinds github/http/local/db, trust official/trusted/restricted); docs/architecture.md section 3.4 (plugins/_official/ plus configured registries via /api/plugins)

  figma = softwareSystem "Figma" "External design tool; designs enter OpenDesign through the bundled OD Figma Import plugin." "External"
  // evidence: figma-plugin/manifest.json (name 'OD Figma Import', id 'open-design-figma-import'); figma-plugin/code.js; figma-plugin/ui.html

  mcpclients = softwareSystem "MCP clients" "Coding agents running in other repos (Claude Code, Cursor, Zed) that attach to the od mcp stdio server to read project files and create project-scoped artifacts." "External"
  // evidence: apps/daemon/src/mcp.ts:1-10 (od mcp - stdio MCP server that proxies project tool calls to the running daemon HTTP API; lets a coding agent in a different repo pull files)

  dshhost = softwareSystem "DSH / DeepSeek Harness host" "Cordis-based agent harness that embeds and steers OpenDesign as a runtime profile through @open-design/dsh-runtime." "External"
  // evidence: packages/dsh-runtime/package.json (DeepSeek Harness profile runtime for OpenDesign); packages/dsh-runtime/src/index.ts:1-19 (imports @deepseek-ai/cordis, dsh-agent, dsh-llm, dsh-session); packages/dsh-runtime/src/protocol.ts:1-8 (PROTOCOL_VERSION=1, RUNTIME_NAME 'open-design', CAPABILITIES)

  // ---------------------------------------------------------------------------
  // L1 - SYSTEM CONTEXT RELATIONSHIPS
  // ---------------------------------------------------------------------------

  designer -> opendesign "Creates projects, prompts agents, reviews prototypes and comments using"
  // evidence: docs/architecture.md sections 2, 3.1; README.md product tour (home composer, all projects, design systems, plugins)

  cliuser -> opendesign "Creates and inspects projects and agent runs via the od CLI of"
  // evidence: docs/architecture.md section 2 (The web UI and the od CLI call the same daemon HTTP APIs); apps/daemon/bin/od.mjs:1

  opendesign -> agents "Detects on PATH, spawns per run with the project workspace as cwd, streams normalized run events"
  // evidence: docs/architecture.md sections 3.3 and 4 (step 4); apps/daemon/src/runtimes/registry.ts:20-58; apps/daemon/src/runtimes/agent-process.ts

  opendesign -> byok "Calls chat model APIs with user-supplied keys (BYOK execution profile)"
  // evidence: apps/daemon/src/runtimes/byok-cli.ts:1-27; apps/daemon/src/byok-tools.ts; docs/architecture.md sections 3.1 (BYOK transport providers) and 4 (text-artifact profile)

  opendesign -> collabcloud "Publishes workspaces, pushes/pulls comments and syncs team resources over HTTPS"
  // evidence: apps/daemon/src/collab/collab-cloud-service.ts:1-9; apps/daemon/src/collab/publish-scheduler.ts; apps/daemon/src/collab/team-resource-share.ts

  opendesign -> releasesrv "Checks update metadata and downloads checksum-verified release artifacts"
  // evidence: apps/desktop/src/main/updater.ts:816-817, 1001-1015; tools/serve/src/index.ts:46-54

  opendesign -> pluginregistries "Lists, searches, resolves, installs and publishes plugin bundles"
  // evidence: packages/registry-protocol/src/backend.ts:15-31; docs/architecture.md section 3.4; apps/daemon/src/routes/plugins/

  figma -> opendesign "Exports designs for import via the OD Figma Import plugin of"
  // evidence: figma-plugin/manifest.json; figma-plugin/README.md

  mcpclients -> opendesign "Lists and invokes project tools through the od mcp stdio server of"
  // evidence: apps/daemon/src/mcp.ts:1-10

  dshhost -> opendesign "Hosts and steers design-agent sessions as an OpenDesign runtime profile of"
  // evidence: packages/dsh-runtime/src/index.ts:1-19; packages/dsh-runtime/src/protocol.ts:1-8

  // ---------------------------------------------------------------------------
  // L2 - CONTAINER RELATIONSHIPS
  // ---------------------------------------------------------------------------

  designer -> web "Drives the product UI in a browser or Electron renderer"
  // evidence: docs/architecture.md section 2 (browser or Electron renderer -> Next.js web app)

  designer -> desktop "Runs the installed desktop app"
  // evidence: docs/architecture.md section 1 (the Electron entry also starts the desktop shell); apps/desktop/src/main/index.ts:1

  cliuser -> daemon "Invokes project and run capabilities over the same HTTP APIs via od"
  // evidence: docs/architecture.md section 2; apps/daemon/bin/od.mjs:1; apps/daemon/src/cli.ts

  web -> daemon "Calls product APIs (/api/*, /artifacts/*, /frames/*) over HTTP + SSE"
  // evidence: docs/architecture.md sections 1 and 5 (web sidecar rewrites /api/* to the sibling Express process; POST /api/chat -> text/event-stream); apps/web/src/providers/daemon.ts

  daemon -> db "Persists projects, conversations, messages, comments and plugin state"
  // evidence: apps/daemon/src/db.ts:8,85; docs/architecture.md sections 3.2, 3.5

  daemon -> agents "Spawns and streams coding-agent runtimes per project run"
  // evidence: apps/daemon/src/runtimes/registry.ts:20-58; apps/daemon/src/runtimes/agent-process.ts; docs/architecture.md sections 3.3, 4

  daemon -> collabcloud "Publishes/pulls team workspaces and syncs comments"
  // evidence: apps/daemon/src/collab/collab-cloud-service.ts:1-9

  daemon -> pluginregistries "Resolves plugin entries through registry backends"
  // evidence: packages/registry-protocol/src/backend.ts:15-31; apps/daemon/src/routes/plugins/

  web -> byok "Calls user-keyed model APIs directly from browser transports"
  // evidence: apps/web/src/providers/anthropic.ts, openai-compatible.ts, azure-compatible.ts, google-compatible.ts, ollama-compatible.ts; docs/architecture.md section 3.1 (daemon and BYOK transport providers)

  desktop -> releasesrv "Fetches update metadata and checksum-verified artifacts"
  // evidence: apps/desktop/src/main/updater.ts:816-817, 1001-1015

  mcpclients -> daemon "Invokes project tools via od mcp (stdio proxied to OD_DAEMON_URL)"
  // evidence: apps/daemon/src/mcp.ts:1-10

  packaged -> daemon "Spawns the packaged daemon with channel/namespace-scoped runtime identity"
  // evidence: docs/architecture.md section 1; apps/packaged/src/sidecars.ts (1,162 lines; bootstrapSidecarProcess/registerSidecarProcess)

  packaged -> web "Starts the packaged web sidecar"
  // evidence: docs/architecture.md section 1 (apps/packaged starts the packaged daemon and web sidecars); apps/packaged/src/headless-runtime.ts

  desktop -> web "Loads the web UI in the Electron renderer after discovering the web URL"
  // evidence: docs/architecture.md section 1 (the desktop discovers the web URL through sidecar IPC rather than assuming a port); apps/desktop/src/main/runtime.ts (loadURL flows at lines 284, 1443, 1542-1546)

  desktop -> sidecar "Discovers the web URL and controls sidecars via JSON-IPC"
  // evidence: apps/desktop/src/main/index.ts (imports @open-design/sidecar - grep apps/desktop/src/main/index.ts); docs/architecture.md section 1

  packaged -> sidecar "Registers and supervises sidecar processes through the IPC client"
  // evidence: apps/packaged/src/sidecars.ts (imports @open-design/sidecar - grep apps/packaged/src); apps/packaged/src/index.ts

  terminal -> sidecar "Bootstraps and hands off sidecar generations"
  // evidence: shells/terminal/runtime/sidecar-host.mjs:6 (import bootstrapSidecarProcess, handoffCurrentSidecarGeneration, SidecarFactory from @open-design/sidecar)

  web -> sidecar "Runs as a spawned web sidecar using the IPC client"
  // evidence: apps/web/sidecar/index.ts:1-5 (SidecarFactory.create, APP_KEYS.WEB guard); apps/web/package.json:40 (@open-design/sidecar workspace dep)

  daemon -> sidecar "Uses the sidecar IPC client for diagnostics export and managed MCP registration"
  // evidence: apps/daemon/src/cli.ts, apps/daemon/src/diagnostics-export.ts, apps/daemon/src/mcp-managed-registration.ts (grep from '@open-design/sidecar' in apps/daemon/src)

  web -> contracts "Types all daemon request/response DTOs"
  // evidence: module-map census (web: 302 non-test importing files); packages/contracts/package.json description

  daemon -> contracts "Types all HTTP boundaries and prompt contracts"
  // evidence: docs/architecture.md section 3.2 (Shared request/response shapes live in packages/contracts); module-map census (daemon: 323 non-test importing files)

  daemon -> pluginruntime "Parses and validates plugin manifests with injected loaders"
  // evidence: packages/plugin-runtime/package.json description (daemon/web/CI inject loaders); module-map census (imported by daemon)

  daemon -> registryproto "Speaks the registry backend protocol"
  // evidence: packages/registry-protocol/src/backend.ts:15-31; module-map census (imported by daemon)

  dshhost -> dshr "Embeds as the cordis plugin open-design-runtime"
  // evidence: packages/dsh-runtime/src/index.ts:1-19 (imports @deepseek-ai/cordis, dsh-agent, dsh-llm, dsh-session; export open-design-runtime)

  // ---------------------------------------------------------------------------
  // L3 - COMPONENT RELATIONSHIPS
  // ---------------------------------------------------------------------------

  webShell -> webFileUi "Composes file workspace and preview surfaces into the app tree"
  // evidence: apps/web/src/App.tsx (6,414 lines); apps/web/src/components/ (319 entries)

  webTransport -> daemon "Streams run events and syncs project state over HTTP + SSE"
  // evidence: apps/web/src/providers/daemon.ts; docs/architecture.md sections 3.1, 5

  webPreview -> daemon "Loads previewable files from daemon URLs or srcDoc"
  // evidence: docs/architecture.md section 3.6 (HTML can load from a daemon URL or through srcDoc); apps/web/src/components/file-viewer-render-mode.ts

  webByok -> byok "Calls model APIs with user-supplied keys"
  // evidence: apps/web/src/providers/openai-compatible.ts; apps/daemon/src/runtimes/byok-cli.ts:1-27 (protocol switch)

  webCollab -> daemon "Syncs comments and presence via daemon APIs"
  // evidence: apps/daemon/src/routes/collab-presence.ts; apps/daemon/src/routes/collab-sync.ts; apps/daemon/src/collab/comment-sync-state.ts

  daemonRoutes -> daemonDb "Reads and writes project, conversation and comment state"
  // evidence: apps/daemon/src/db.ts (used by routes - e.g. db.ts:428 project_user_submissions check); docs/architecture.md section 3.2

  daemonServer -> daemonDb "Opens the SQLite database under the resolved data root"
  // evidence: apps/daemon/src/server.ts:1431 (OD_DATA_DIR resolution); apps/daemon/src/db.ts:85 (app.sqlite)

  daemonRoutes -> daemonRuntimes "Detects and launches agent runtimes for chat runs"
  // evidence: apps/daemon/src/routes/chat.ts; apps/daemon/src/runtimes/registry.ts:20-58; docs/architecture.md sections 3.3, 4

  daemonCli -> daemonServer "Calls the same daemon HTTP APIs over loopback"
  // evidence: docs/architecture.md section 2 (The CLI is not a second business-logic implementation); apps/daemon/src/cli.ts

  daemonMcp -> daemonServer "Proxies tool calls to OD_DAEMON_URL"
  // evidence: apps/daemon/src/mcp.ts:1-10 (every tool resolves to a fetch() against OD_DAEMON_URL)

  daemonCollab -> collabcloud "Registers members, pushes comments and polls pull+merge"
  // evidence: apps/daemon/src/collab/collab-cloud-service.ts:1-9

  daemonRuntimes -> agents "Spawns agent CLIs with the project workspace as cwd"
  // evidence: apps/daemon/src/runtimes/agent-process.ts; docs/architecture.md section 4 (step 4)

  desktopMain -> desktopRuntime "Boots the renderer session and launch-type flow"
  // evidence: apps/desktop/src/main/index.ts:1; apps/desktop/src/main/launch-type.ts

  desktopRuntime -> sidecar "Discovers the web URL and controls sidecar processes via JSON-IPC"
  // evidence: apps/desktop/src/main/index.ts (imports @open-design/sidecar); docs/architecture.md section 1

  desktopUpdater -> releasesrv "Fetches update metadata and checksum-verified artifacts"
  // evidence: apps/desktop/src/main/updater.ts:816-817, 1001-1015

  desktopHostBridge -> web "Serves OPEN_DESIGN_HOST_GLOBAL bridge actions consumed by the renderer"
  // evidence: packages/host/src/protocol.ts:1-8 (every request/result type that crosses the host bridge); apps/web/src/i18n/index.tsx and apps/web/src/lib/updater.ts import @open-design/host

}

views {

  systemContext opendesign "OpenDesign-SystemContext" "System context: designers, CLI users and the external systems OpenDesign connects to." {
    include *
    autolayout tb
  }

  container opendesign "OpenDesign-Containers" "Containers: the pillar pnpm workspace packages plus the daemon-owned SQLite store." {
    include *
    autolayout tb
  }

  component web "OpenDesign-WebComponents" "Web App internals: shell, file workspace, preview, transports, collab." {
    include *
    autolayout tb
  }

  component daemon "OpenDesign-DaemonComponents" "Daemon internals: server composition, routes, SQLite, runtimes, collab, CLI, MCP." {
    include *
    autolayout tb
  }

  component desktop "OpenDesign-DesktopComponents" "Desktop Shell internals: main lifecycle, runtime, updater, captures, host bridge." {
    include *
    autolayout tb
  }

  styles {
    element "External" {
      shape RoundedBox
      background "#dddddd"
      color "#000000"
    }
    element "Database" {
      shape Cylinder
    }
  }

}

}
