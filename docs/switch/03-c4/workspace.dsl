// workspace.dsl — Structurizr DSL: C4 model of sandbox-quantum/switch ("Agent Switch")
// Subject: switch | pin: 39a722c5eeecf8479422351fc7ac2a61fe559a66 (branch main)
// Inputs: docs/switch/01-cartography.md (manifests/entrypoints) +
//         docs/switch/02-module-map.md (17-item universe).
// Every element and relationship below carries an `// evidence:` line pointing at a
// grep-verified file:line (or file path) in the pinned clone. Elements without
// evidence are not modeled.
// NOTE: not validated with structurizr-cli (no java runtime available at
// measurement time); Mermaid fallback in diagrams.mmd.
// Two corrections applied while modeling (see 06-flows.md): (1) no
// gatewayCore -> delivery import edge exists at this pin — grep over
// gateway/*.py finds zero switch_core.delivery imports; (2) deploy build
// lines are Dockerfile.switch:36 (core) and :11/:50 + Dockerfile.gateway:6
// (gateway).

workspace {

    name "Agent Switch"
    description "Switch — AI agent orchestration and governance platform"

    model {

        // ================= L1 — System Context =================

        developer = person "Developer (agent owner)" "Installs Switch Console, adds agent templates and works with AI teammates in chat rooms (Slack/Teams/Discord/Telegram/Mattermost)"
            // evidence: README.md:38 ("Install Switch Console, the desktop app, for your platform"), :30 ("Each channel becomes a room for people and agents"), :31 ("Any agent, any model, any provider"); console/apps/switch-console-desktop/package.json:4 ("orchestrates multiple coding agents in parallel")

        operator = person "Platform operator (admin)" "Administers workspaces, machines, organizations and usage through the operator dashboard"
            // evidence: artifacts.yaml:109 ("The operator dashboard image."); gateway/src/pages/operator/OperatorWorkspacesPage.tsx; gateway/src/pages/machines/MachinesPage.tsx

        switchSystem = softwareSystem "Agent Switch" "AI agent orchestration and governance platform: turns chat channels into rooms where humans and coding agents work together; self-hosted core (Python/FastAPI) + desktop console (Electron) + operator dashboard"
            // evidence: core/pyproject.toml:4 ("Switch — AI agent orchestration and governance platform"); README.md:9 ("Open-source AI teammates, working alongside your team in Slack, Teams, Discord, Telegram and Mattermost. Self-host it, with any agent and any model.")

        codingAgents = softwareSystem "Coding agents (Claude Code, Codex, Cursor, OpenCode, ACP, Antigravity)" "External coding-agent runtimes/sessions Switch orchestrates; anything that speaks the agent-protocol can join" {
            tags "External System"
        }
            // evidence: README.md:31 ("If it speaks the protocol, it can join"); console/packages/agent-providers/src (claude/, codex/, cursor/, opencode/, acp/, antigravity/ directories); artifacts.yaml:152-155 (agent-protocol: "The wire protocol between switch-core's agent bridge and an agent runtime")

        collabPlatforms = softwareSystem "Collaboration platforms (Slack, Teams, Discord, Telegram, Mattermost)" "External messaging platforms whose channels become Switch rooms; deliver platform events in and receive agent replies" {
            tags "External System"
        }
            // evidence: README.md:9, :30; core/pyproject.toml:31-32 (slack-sdk, mattermostdriver), :42-43 (discord-py, python-telegram-bot); core/switch_core/bridges/collaboration/adapter.py:433 (class PlatformAdapter(ABC))

        vendorApis = softwareSystem "Vendor service APIs (GitHub, OAuth providers, Google Workspace, Jira)" "External services an agent's tool use needs; Switch brokers and refreshes their credentials" {
            tags "External System"
        }
            // evidence: README.md:32 ("tools (Google Workspace, Jira, GitHub)"); core/switch_core/connections/adapters/ (github.py, oauth.py, api_key.py); core/switch_core/connections/broker.py:1955 (revoke_grant)

        agentHosts = softwareSystem "Agent hosts (Switch cloud machines)" "Cloud machines provisioned by the hosted controller; each workspace seat runs one switch-agent-controller" {
            tags "External System"
        }
            // evidence: artifacts.yaml:131 ("The hosted controller image, which provisions Switch cloud machines for switch-core"); deploy/hosted/machine/switch_machine_boot.py:2,8 (one agent controller per workspace; enrolls a switch-agent-controller); deploy/remote/helm/switch/values.yaml:437

        developer -> switchSystem "Installs Switch Console and works with AI teammates in rooms" "Desktop app"
            // evidence: README.md:30, :38
        operator -> switchSystem "Administers workspaces/machines/usage via the operator dashboard" "HTTPS UI"
            // evidence: artifacts.yaml:109; gateway/src/pages/operator/OperatorWorkspacesPage.tsx
        switchSystem -> codingAgents "Orchestrates agent sessions over the agent-protocol (SSE event stream, heartbeat, resume cursor, tool-call channel)" "agent-protocol"
            // evidence: artifacts.yaml:152-155; console/packages/switch-agent-runtime/src/index.ts:1-8
        collabPlatforms -> switchSystem "Channel events in; agent replies, refusals and notifications out (bridge adapters)" "Platform webhooks/APIs"
            // evidence: README.md:30; core/switch_core/bridges/collaboration/adapter.py:433 (PlatformAdapter ABC); core/switch_core/bridges/collaboration/platforms.py (register_platforms, imported at core/switch_core/main.py:74)
        switchSystem -> vendorApis "Issues, refreshes and revokes vendor credentials for agent tool use" "OAuth/HTTPS"
            // evidence: core/switch_core/connections/adapters/ (github.py, oauth.py, api_key.py); core/switch_core/connections/broker.py:1955
        switchSystem -> agentHosts "Provisions cloud machines; enrolls one switch-agent-controller per workspace seat" "Provisioning/SSH"
            // evidence: artifacts.yaml:131; deploy/hosted/machine/switch_machine_boot.py:2,8

        // ================= L2 — Containers =================
        // 17 containers = the 17 module-map items (m01..m17), mapped 1:1. LOC values
        // are the module-map numbers; m01/m02/m04 were re-measured on the pin clone
        // with the census formula and matched exactly (47/17,522 · 112/69,668 ·
        // 47/21,147). Import edges follow the module map's dep table; each carries a
        // grep-verified example line.

        coreFlat = container switchSystem "core service kernel (core/switch_core top-level)" "switch-core service process: main.py entrypoint builds the uvicorn app + lifespan sweeps, prepares/migrates the DB, seeds the admin; 46 sibling flat modules are the cross-cutting services (config, room lifecycle, authz, keys, flags, templating) every subpackage builds on" "Python 3.12"
            // evidence: core/switch_core/main.py (2,399 lines; def main :2376, _prepare_database :561, sweeps :318/:355/:369); core/switch_core/config.py:145 (class SwitchConfig(BaseSettings)); census 47 files / 17,522 loc (census formula, pin clone)

        bridges = container switchSystem "bridges (core/switch_core/bridges)" "Adapters connecting external collaboration platforms (Teams/Slack/Discord/Mattermost/Telegram) and the agent-protocol/agent bridge to switch-core's room/session model, incl. the agent-facing API surface (auth, commands, MCP, protocol)" "Python 3.12"
            // evidence: core/switch_core/bridges/agent/protocol/agent_core.py:332 (class AgentCore); core/switch_core/bridges/collaboration/adapter.py:433 (class PlatformAdapter(ABC)); census 112 files / 69,668 loc (census formula, pin clone)

        db = container switchSystem "database layer (core/switch_core/db)" "PostgreSQL persistence: SQLAlchemy 2.0 async ORM schema (tenant-scoped, row-level security + NOTIFY trigger DDL), engine/session factory stamping the bound tenant, per-entity stores" "Python / SQLAlchemy 2.0 on PostgreSQL"
            // evidence: core/switch_core/db/models.py:4825 (attach_row_level_security(Base.metadata)), 97 top-level classes (grep -c '^class '); core/switch_core/db/engine.py:208 (create_session_factory)

        gatewayCore = container switchSystem "gateway API (core/switch_core/gateway)" "The HTTP API layer of switch-core: one FastAPI app ('Switch Gateway API') assembled from 34 include_router calls (rooms, chats, agents, tenants, organizations, auth/OIDC, service connections, templates, feature flags, hosted controller...)" "Python / FastAPI"
            // evidence: core/switch_core/gateway/app.py:96 (def create_gateway_app), 34 include_router calls (grep -c); census 47 files / 21,147 loc (census formula, pin clone)

        migrations = container switchSystem "schema migrations (core/switch_core/migrations)" "The Alembic schema-evolution record of switch-core's Postgres database: 201 ordered revisions applied before the runtime opens, with env.py binding the live SwitchConfig/db engine and an owner-vs-runtime DDL privilege split" "Alembic / Python"
            // evidence: core/switch_core/migrations/env.py:12-14 (imports db.base/db.engine/db.schema_version), :15 (logging_config); core/switch_core/main.py:2295 (alembic_command.upgrade), :2338 (def migrate)

        management = container switchSystem "agent management (core/switch_core/management)" "Managed-agent control plane — agent definitions, controller enrollment/credentials, placement and operations — served over two doors (controller routes on the agent bridge, owner routes on the gateway); compiled off unless the agent_management flag is on" "Python 3.12"
            // evidence: core/switch_core/management/wiring.py:3 (docstring: returns None when the flag is off), :237-238 (if not config.agent_management_enabled: return None)

        connections = container switchSystem "service connections (core/switch_core/connections)" "Credential broker: decrypts, refreshes under the connection's lock, issues, revokes and records every vendor token an agent's service use needs; import-time-validated connection catalog; per-vendor adapters (github / oauth / pasted api_key)" "Python 3.12"
            // evidence: core/switch_core/connections/broker.py:1955 (revoke_grant); core/switch_core/connections/loader.py:6 ("The catalog is validated once, at import"); core/switch_core/connections/adapters/ (github.py, oauth.py, api_key.py)

        delivery = container switchSystem "delivery (core/switch_core/delivery)" "Decides, as a room row is written, which agent members the row is for and what Switch posts on their behalf: MessageRouter.store runs inside the row's transaction; AgentRecipient supplies the post-commit replies" "Python 3.12"
            // evidence: core/switch_core/delivery/router.py:1-8 (docstring: "Every row written to a room goes through MessageRouter.store, in the transaction that writes it")

        coreMisc = container switchSystem "core domain subpackages (accounts, chats, clients, messages, observability, official_templates, providers, provisioning, session_activity, sessions, telemetry, transport, trust)" "The thirteen small domain subpackages outside the big zones: per-client actors, room chat/membership, the Postgres message transport that is the bus ('the write is the send'), metric catalogue + telemetry snapshots, session-activity publishing, provider integrations, provisioning, templates, trust" "Python 3.12"
            // evidence: core/switch_core/transport/postgres.py:1-6 (docstring: "The write is the send."); core/switch_core/observability/catalogue.py (metric catalogue, 693 lines)

        consoleRenderer = container switchSystem "console renderer (console/apps/switch-console-desktop/src/renderer)" "The Electron console's React UI: view registry, feature views (templates, switch-servers, switch-rooms, onboarding...), stores and the RPC/IPC client layer driving the desktop app through the shared/preload bridge" "TypeScript / React (Electron renderer)"
            // evidence: console/apps/switch-console-desktop/src/renderer/main.tsx:2 (view-registry import), :27 (rpc.providers.catalogue); console/apps/switch-console-desktop/src/preload/index.ts:4 (contextBridge.exposeInMainWorld('electronAPI'))

        consoleMain = container switchSystem "console main process (console/apps/switch-console-desktop/src/main)" "Electron main process: boots the window and the in-main service layer (local/remote switch-server management with its gateway client, agent runtimes, storage migration, terminals/SSH, local drizzle/SQLite DB) exposed to the renderer via the RPC router" "TypeScript (Electron main)"
            // evidence: console/apps/switch-console-desktop/src/main/index.ts:126 (createMainWindow), :135 (initializeDatabase), :161 (appService.initialize), :178 (controlService.initialize), :186 (rpcRouter); package.json:18 ("main": "./out/main/index.js")

        consoleShared = container switchSystem "console shared + preload + tooling (src/shared, src/preload, src/types, tooling-e2e, build configs)" "The process-agnostic half of the Electron app: types/schemas/logic shared via @shared, the preload bridges exposing window.electronAPI, and the tooling-e2e harness driving Switch end-to-end over plain HTTP" "TypeScript"
            // evidence: console/apps/switch-console-desktop/src/preload/index.ts:4 (exposeInMainWorld electronAPI); console/tooling-e2e/src/clients/switch-client.ts:1-6 (node http/https client)

        consolePackages = container switchSystem "console packages (console/packages: agent-runtime, agent-providers, agent-controller, core, plugins, shared)" "The six pnpm workspace libraries: the agent-protocol client (one SSE connection with heartbeat and resume cursor), the coding-agent provider adapters + session host, the agent-controller binary deployed to agent hosts, plus core/plugins/shared" "TypeScript (pnpm workspace)"
            // evidence: console/packages/switch-agent-runtime/src/index.ts:1-12 ("The Switch agent protocol client... One connection to Switch: an SSE stream carrying events, a heartbeat... a cursor so a reconnect resumes"); console/packages/agent-providers/src (claude/, codex/, cursor/, opencode/, acp/, antigravity/); console/packages/agent-controller/package.json:27-34

        gatewayWeb = container switchSystem "operator dashboard (gateway)" "Standalone React 19 + MUI 7 web SPA: rooms, agents, machines, resources, organizations, usage pages consuming switch-core's /gateway JSON API over cookie-authenticated fetch" "TypeScript / React 19 + MUI 7"
            // evidence: gateway/src/data/api.ts:1 (const BASE = "/gateway"), :5 (fetch ... credentials: "include"); gateway/package.json:2-3 (switch-gateway, private)

        deploy = container switchSystem "deployment layer (deploy)" "Local docker-compose + standalone all-in-one Docker stacks, Kubernetes Helm chart, Terraform, the EC2 hosted-controller reconciling cloud machines, the per-seat machine boot script, and the built container images (switch core + gateway UI, gateway UI only, Mattermost-bridge setup job)" "Docker / Helm / Terraform / Python"
            // evidence: justfile:51 (docker compose -f deploy/local/docker-compose.yml up), :240 (standalone compose with --profile collab --profile gateway); deploy/shared_resources/images/Dockerfile.switch:36 (COPY core/switch_core/), :11 + :50 (gateway-ui stage); deploy/hosted/machine/switch_machine_boot.py:2

        docs = container switchSystem "documentation (docs, README-class files, console guides)" "The written knowledge surface: product README + CHANGELOG, docs/official (synced, generated) + docs/old (internal architecture/protocol references), console engineering guides. No code boundary crosses this container; relationships are cross-references only" "Markdown"
            // evidence: README.md:217 ([docs/TELEMETRY.md]), :226 ([docs/old/telemetry-events.md]); docs/README.md:9,14 (official/old index, just sync-docs)

        expertTemplates = container switchSystem "expert templates + repo scripts (switch-expert, examples, scripts)" "Repo-level tooling and packaged expertise outside every runtime zone: the switch-expert agent template, five example templates, and maintainer scripts generating/verifying artifacts.yaml, pinning chart images, guarding migration heads" "YAML / Python / Markdown"
            // evidence: switch-expert/template.yaml (templates-language v2); scripts/gen_artifacts.py (gen/verify artifacts.yaml); justfile:124,131 (gen_artifacts.py / --check)

        // ---- actor/external interactions at container level ----

        developer -> consoleRenderer "Drives the desktop UI (view registry, feature views)" "Electron UI"
            // evidence: README.md:38; console/apps/switch-console-desktop/src/renderer/main.tsx:2, :27
        operator -> gatewayWeb "Uses the operator dashboard" "HTTPS UI"
            // evidence: artifacts.yaml:109; gateway/src/pages/operator/OperatorWorkspacesPage.tsx
        gatewayWeb -> gatewayCore "Room/agent/machine/usage JSON over /gateway, cookie-authenticated" "HTTP/JSON (gateway-api contract)"
            // evidence: gateway/src/data/api.ts:1, :5; artifacts.yaml:237-245 (gateway-api: switch-core speaks 1 / switch-console speaks 1)
        consoleMain -> gatewayCore "Local and remote switch-server management via the gateway client" "HTTP/JSON (gateway-api contract)"
            // evidence: console/apps/switch-console-desktop/src/main/core/switch-servers/gateway-client.ts (4,589 lines); artifacts.yaml:237-245
        consolePackages -> bridges "Connects agent processes to switch-core's agent bridge over the agent-protocol (SSE, heartbeat, resume cursor)" "agent-protocol"
            // evidence: console/packages/switch-agent-runtime/src/index.ts:1-12; artifacts.yaml:152-155
        consolePackages -> codingAgents "Drives coding-agent SDKs/CLIs (claude-agent-sdk, MCP SDK, opencode-ai/sdk) through provider adapters" "SDK/CLI"
            // evidence: console/packages/agent-providers/package.json:38-41; console/packages/agent-providers/src (claude/, codex/, cursor/, opencode/, acp/, antigravity/)
        bridges -> collabPlatforms "Ingests channel events; posts agent replies via per-platform adapters" "Platform APIs"
            // evidence: core/switch_core/bridges/collaboration/adapter.py:433 (PlatformAdapter ABC); core/switch_core/main.py:56-80 (per-platform adapter imports)
        connections -> vendorApis "Token issue/refresh/revoke against vendor APIs" "OAuth/HTTPS"
            // evidence: core/switch_core/connections/adapters/ (github.py, oauth.py, api_key.py); core/switch_core/connections/broker.py:1955
        deploy -> agentHosts "Boots machines and enrolls one controller per workspace seat" "Provisioning"
            // evidence: deploy/hosted/machine/switch_machine_boot.py:2, :8; deploy/remote/helm/switch/values.yaml:437
        consolePackages -> management "Enrolls and operates managed agents over the agent-bridge controller routes" "agent-protocol (controller routes)"
            // evidence: deploy/hosted/machine/switch_machine_boot.py:8 (enrolls switch-agent-controller); core/switch_core/management/wiring.py:237-238 (flag gate); core/switch_core/bridges/agent/protocol/agent_management.py:24, :37 (AgentManagementRefused, NewManagedAgent)
        deploy -> coreFlat "Builds the switch-core image (copies switch_core incl. every core subpackage m01-m09)" "Docker build"
            // evidence: deploy/shared_resources/images/Dockerfile.switch:36 (COPY core/switch_core/ switch_core/)
        deploy -> gatewayWeb "Builds the gateway image and inlines the built dashboard into the core image" "Docker build"
            // evidence: deploy/shared_resources/images/Dockerfile.switch:11, :50 (COPY gateway/; COPY --from=gateway-ui); deploy/shared_resources/images/Dockerfile.gateway:6 (COPY gateway/)
        expertTemplates -> consoleRenderer "Template documents bundled into the Templates page via raw imports" "Build-time import"
            // evidence: console/apps/switch-console-desktop/src/renderer/features/templates/bundled-templates.ts:2-4 (@root/../../../switch-expert/AGENT.md?raw, template.console.yaml?raw, template.yaml?raw)
        expertTemplates -> gatewayCore "Maintainer scripts exercise the gateway API surface end-to-end" "HTTP"
            // evidence: scripts/e2e_surface.py (grep hit for switch_core.gateway)

        // ---- core-internal import edges (module-map dep table; example lines verified) ----

        coreFlat -> bridges "main.py wires the agent bridge app + collaboration adapters at startup" "Python import"
            // evidence: core/switch_core/main.py:31-80 (create_agent_bridge_app, AgentCore, per-platform adapters, installers)
        coreFlat -> db "Flat modules persist through the db layer" "Python import"
            // evidence: core/switch_core/main.py (imports switch_core.db; 67 import lines), core/switch_core/agent_runs.py, core/switch_core/budgets.py (grep 'switch_core.db')
        coreFlat -> gatewayCore "main.py imports create_gateway_app and mounts the gateway app" "Python import"
            // evidence: core/switch_core/main.py:183-186 (import), :1240 (gateway_app = create_gateway_app(...))
        coreFlat -> management "main.py creates management when the flag is on and installs it on both apps" "Python import"
            // evidence: core/switch_core/main.py:188 (import), :1055 (create_management(...)), :1324-1325 (management.install(agent_bridge_app=..., gateway_app=...))
        coreFlat -> delivery "main.py wires MessageRouter + RecipientServices into the write path" "Python import"
            // evidence: core/switch_core/main.py:179-181
        coreFlat -> coreMisc "Flat modules drive per-client actors, telemetry and session activity" "Python import"
            // evidence: core/switch_core/main.py:96-98 (clients.actor, clients.agent_admin, clients.client_factory)

        bridges -> db "Agent bridge persists through room/user stores" "Python import"
            // evidence: core/switch_core/bridges/agent/commands.py:51 (from switch_core.db.stores.user_store import UserStore)
        bridges -> coreFlat "Bridge logic uses flat services (events, platform access)" "Python import"
            // evidence: core/switch_core/bridges/agent/commands.py:53 (switch_core.events), :55 (switch_core.platform_access)
        bridges -> coreMisc "Bridge commands reference the transport bus" "Python import"
            // evidence: core/switch_core/bridges/agent/commands.py:56 (from switch_core.transport import RoomRef)

        db -> coreFlat "Persistence layer uses flat services (keyring, tenant context)" "Python import"
            // evidence: core/switch_core/db/encrypted_json.py:33 (from switch_core.keys import Keyring); core/switch_core/db/stores/hosted_machine_store.py:18 (from switch_core.tenant_context import tenant_scope)

        gatewayCore -> db "Routers read/write tenant-scoped models and stores" "Python import"
            // evidence: core/switch_core/gateway/rooms.py:23-24 (from switch_core.db.models import Room, RoomGroup...; from switch_core.db.stores.collaboration_bridge_store import ...)
        gatewayCore -> bridges "Gateway resolves known agents and workspace access through the agent bridge" "Python import"
            // evidence: core/switch_core/gateway/known_agents.py:8; core/switch_core/gateway/workspace_access.py:18 (from switch_core.bridges.agent.protocol.agent_core import AgentCore)
        gatewayCore -> connections "Organization services call the service-connection broker/catalog" "Python import"
            // evidence: core/switch_core/gateway/organization_services.py:43-44 (ServiceBroker/get_service_broker; CATALOG)
        gatewayCore -> coreFlat "Routers authorize through flat authz/config" "Python import"
            // evidence: core/switch_core/gateway/messaging_installs.py:32 (from switch_core.authz import Action, Principal, can); core/switch_core/gateway/ecosystem.py:8 (from switch_core.config import SwitchConfig)
        gatewayCore -> coreMisc "Routers emit telemetry and drive client lifecycle" "Python import"
            // evidence: core/switch_core/gateway/rooms.py:77 (from switch_core.telemetry import emit_safely); core/switch_core/gateway/organizations.py:30 (from switch_core.clients.client_lifecycle_service import ClientLifecycleService)

        management -> db "Management persists agent definitions and controller credentials" "Python import"
            // evidence: core/switch_core/management/service.py:52, :61 (from switch_core.db.models import ...)
        management -> bridges "Management enables agent operations on the agent bridge" "Python import"
            // evidence: core/switch_core/management/wiring.py:31 (from switch_core.bridges.agent.operations.agent_management import enable_agent_management)
        management -> gatewayCore "Owner-side management routes mount on the gateway app" "Python import"
            // evidence: core/switch_core/management/gateway_routes.py:21-22 (from switch_core.gateway.auth import get_current_user; from switch_core.gateway.dependencies import get_protocol, get_session)

        connections -> db "Broker records/audits connection state" "Python import"
            // evidence: core/switch_core/connections/broker.py:73-74 (db.audit, db.models), :83-84 (db.session_scope, db.standing)
        connections -> coreFlat "Broker decrypts through the flat keyring" "Python import"
            // evidence: core/switch_core/connections/broker.py:90 (from switch_core.keys import Keyring)
        connections -> coreMisc "App credentials resolve GitHub provider integrations" "Python import"
            // evidence: core/switch_core/connections/app_credentials.py:62-63 (from switch_core.providers.github import GitHubConnections; github_installation)

        delivery -> db "Router stores rows and agent_events in the row's transaction" "Python import"
            // evidence: core/switch_core/delivery/router.py:80-84 (db.agent_event_notify_ddl, db.models)
        delivery -> bridges "Recipient replies use agent commands and protocol message events" "Python import"
            // evidence: core/switch_core/delivery/recipient.py:34, :40 (switch_core.bridges.agent.commands; bridges.agent.protocol.message_events)
        delivery -> coreMisc "Recipients post through the clients actors" "Python import"
            // evidence: core/switch_core/delivery/recipient.py:54, :60 (switch_core.clients.admin_messages; clients.mentions)
        delivery -> coreFlat "Delivery respects budgets and attachment groups" "Python import"
            // evidence: core/switch_core/delivery/recipient.py:32 (switch_core.attachments), :53 (switch_core.budgets); router.py:73

        migrations -> db "env.py binds the db Base metadata and engine connect args" "Python import"
            // evidence: core/switch_core/migrations/env.py:12-14 (from switch_core.db.base import Base; db.engine import migration_connect_args; db.schema_version import record_expand_only)
        migrations -> coreFlat "env.py reuses flat logging configuration" "Python import"
            // evidence: core/switch_core/migrations/env.py:15 (from switch_core.logging_config import logging_is_configured)

        coreMisc -> db "Transport and stores persist through the db layer" "Python import"
            // evidence: core/switch_core/transport/postgres.py:108-109 (db.stores.room_store; db.stores.usage_store)
        coreMisc -> delivery "The transport reads what the router decided per row" "Python import"
            // evidence: core/switch_core/transport/postgres.py:110 (from switch_core.delivery.router import MessageRouter)
        coreMisc -> bridges "Client actors dispatch bridge commands and watch connection registries" "Python import"
            // evidence: core/switch_core/clients/command_consumer.py:7 (from switch_core.bridges.agent.commands import dispatch_admin_command); clients/mention_warnings.py:18
        coreMisc -> coreFlat "Subpackages use flat logging/tenant context" "Python import"
            // evidence: core/switch_core/transport/postgres.py:59 (switch_core.logging_context), :77 (switch_core.tenant_context)

        // ---- console-internal edges ----

        consoleRenderer -> consoleShared "Renderer logic imports @shared types/schemas/logic" "TypeScript import"
            // evidence: console/apps/switch-console-desktop/src/renderer/lib/errors/describe-failure.ts:1-2 (from '@shared/core/remote-hosts/reachability'; '@shared/lib/ipc/rpc-error')
        consoleRenderer -> consoleMain "Type-only @main imports; runtime reaches main through IPC/RPC, not imports" "TypeScript import (type-only)"
            // evidence: console/apps/switch-console-desktop/src/renderer/lib/ipc.ts:1 (import type { RpcRouter } from '@main/rpc'); renderer/features/switch-rooms/AddAgentsToRoomModal.tsx:4
        consoleRenderer -> consolePackages "Renderer consumes workspace libraries (@switch-console/shared, core)" "TypeScript import"
            // evidence: console/apps/switch-console-desktop/src/renderer/lib/stores/live/optimistic-model.ts:1 (@switch-console/shared); model-mirror.ts:1 (@switch-console/core/lib)

        consoleMain -> consoleShared "Main-process services import @shared" "TypeScript import"
            // evidence: console/apps/switch-console-desktop/src/main/lib/log-context.ts:3 ('@shared/logger'); main/lib/events.ts:3 ('@shared/lib/ipc/events')
        consoleMain -> consolePackages "Main process drives provider adapters and workspace libs" "TypeScript import"
            // evidence: console/apps/switch-console-desktop/src/main/lib/lifecycle-map.ts:1 (@switch-console/shared); main/core/agent-runtime/types.ts:1 (@switch-console/agent-providers)

        consoleShared -> consolePackages "Shared layer consumes workspace libraries (type-level)" "TypeScript import (type-only)"
            // evidence: console/apps/switch-console-desktop/src/shared/core/managed-agents/managed-agents.ts:1-2 (@switch-console/core/agents/plugins; @switch-console/plugins/agents); shared/core/agents/onboarding.ts:1

        // ---- console/packages internal workspace edges ----

        consolePackages -> consolePackages "agent-controller -> agent-providers" "pnpm workspace:*"
            // evidence: console/packages/agent-controller/package.json:28; agent-controller/src/main.ts:13
        consolePackages -> consolePackages "agent-controller -> plugins" "pnpm workspace:*"
            // evidence: console/packages/agent-controller/package.json:29
        consolePackages -> consolePackages "agent-controller -> agent-runtime (devDependency)" "pnpm workspace:*"
            // evidence: console/packages/agent-controller/package.json:34
        consolePackages -> consolePackages "agent-providers -> agent-runtime" "pnpm workspace:*"
            // evidence: console/packages/agent-providers/package.json:41
        consolePackages -> consolePackages "agent-providers -> shared" "pnpm workspace:*"
            // evidence: console/packages/agent-providers/package.json:42; agent-providers/src/adapter.ts:1
        consolePackages -> consolePackages "core -> shared" "pnpm workspace:*"
            // evidence: console/packages/core/src/lib/live-model.ts:1; resource-map.ts:1
        consolePackages -> consolePackages "plugins -> core" "pnpm workspace:*"
            // evidence: console/packages/plugins/src/agents/session-launch.ts:8; plugin-registry.ts:5

        // ================= L3 — Components =================
        // Deep dives into the three most central containers (LOC + wiring centrality):
        // core service kernel (17,522; composition root wiring every zone),
        // gateway API (21,147; the HTTP contract surface both UIs consume),
        // bridges (69,668; the largest core subpackage and the external-platform boundary).
        // Console containers are process plumbing already fully described at L2.

        compEntry = component coreFlat "Entrypoint & app assembly" "main(): builds the uvicorn app, mounts gateway + agent bridge apps" "Python"
            // evidence: core/switch_core/main.py:2376 (def main), :1240 (gateway_app mount); core/pyproject.toml:55 (switch-core script)
        compSweeps = component coreFlat "Lifespan sweep loops" "Background maintenance sweeps started in the app lifespan (room sweep, session sweep, telemetry sweeps)" "Python"
            // evidence: core/switch_core/main.py:318, :355, :369 (sweep starts); :303-310 (lifespan)
        compDbPrep = component coreFlat "DB preparation & migration runner" "_prepare_database + migrate(): upgrades the Alembic head, grants runtime privileges, seeds the admin" "Python"
            // evidence: core/switch_core/main.py:561 (_prepare_database), :2295-2296 (upgrade + grant), :2338 (def migrate)
        compConfig = component coreFlat "Configuration (SwitchConfig)" "The pydantic-settings object threaded through startup: DB URL, secrets, feature flags, platform credentials" "Python"
            // evidence: core/switch_core/config.py:145 (class SwitchConfig(BaseSettings)); main.py:561
        compRooms = component coreFlat "Room lifecycle services" "RoomService + rooms_yaml: create/retire rooms, channel↔room binding, YAML import/export" "Python"
            // evidence: core/switch_core/room_service.py:72-83 (class RoomService); room census 1,831 lines
        compAuthz = component coreFlat "Identity, authz & tenancy" "Action/Principal/can authz model, user/tenant context, API keys, OIDC config" "Python"
            // evidence: core/switch_core/authz.py:44, :68, :89 (Action, Principal, can)
        compTemplates = component coreFlat "Agent templating" "v2 template reader/linter/installer: template_v2, template_installs, template_runs, agent_template_ops" "Python"
            // evidence: core/switch_core/agent_templates.py (964 lines); template_v2.py, template_installs.py, template_runs.py, template_lint.py, agent_template_ops.py
        compAgentDomain = component coreFlat "Agent session domain" "Agent runs, refusals + breaker, per-row addressing, budgets, attachment groups" "Python"
            // evidence: core/switch_core/agent_runs.py, agent_refusals.py, refusal_breaker.py, addressing.py, budgets.py, attachments.py

        compEntry --> compSweeps "lifespan starts the sweeps" "Python call"
            // evidence: core/switch_core/main.py:318, :355, :369
        compEntry --> compDbPrep "upgrade head, then _prepare_database" "Python call"
            // evidence: core/switch_core/main.py:2295-2296
        compEntry --> compConfig "SwitchConfig threaded through startup" "Python object"
            // evidence: core/switch_core/main.py:561
        compAgentDomain --> db "agent-domain modules persist through db stores" "Python import"
            // evidence: core/switch_core/agent_runs.py (grep switch_core.db)
        compTemplates --> db "templating persists through db stores" "Python import"
            // evidence: core/switch_core/agent_template_ops.py (grep switch_core.db)

        gwAssembly = component gatewayCore "App assembly (create_gateway_app)" "Assembles the FastAPI app from 35 routers with keyword-only service deps" "Python / FastAPI"
            // evidence: core/switch_core/gateway/app.py:96 (def create_gateway_app), 35 include_router calls
        gwRouters = component gatewayCore "Domain routers" "rooms, chats, agents, tenants, organizations, collaborations, service connections, templates, feature flags, hosted controller..." "Python / FastAPI"
            // evidence: core/switch_core/gateway/app.py:167-243; rooms.py:23-24
        gwAuth = component gatewayCore "Auth & OIDC" "get_current_user dependency + OIDC login/callback routers" "Python / FastAPI"
            // evidence: core/switch_core/gateway/auth.py:77, :139; app.py:218-219
        gwSchemas = component gatewayCore "Request/response schemas" "163 Pydantic classes: RoomCreateRequest, RoomDetail, AgentCreateRequest..." "Python / Pydantic"
            // evidence: core/switch_core/gateway/schemas.py (grep -c '^class ' = 163)
        gwDeps = component gatewayCore "Shared dependencies" "get_current_user/get_protocol/get_session used by routers and by management's owner routes" "Python / FastAPI"
            // evidence: core/switch_core/gateway/dependencies.py (imported by management/gateway_routes.py:22)

        gwAssembly --> gwRouters "include_router x35" "FastAPI"
            // evidence: core/switch_core/gateway/app.py:222-226, :167-187
        gwAssembly --> gwAuth "auth + oidc routers" "FastAPI"
            // evidence: core/switch_core/gateway/app.py:218-219
        gwRouters --> db "routers read/write models + stores" "Python import"
            // evidence: core/switch_core/gateway/rooms.py:23-24
        gwRouters --> bridges "workspace access resolves AgentCore" "Python import"
            // evidence: core/switch_core/gateway/workspace_access.py:18
        gwRouters --> coreMisc "telemetry + client lifecycle" "Python import"
            // evidence: core/switch_core/gateway/rooms.py:77; gateway/organizations.py:30

        brAgentCore = component bridges "Agent bridge core (AgentCore)" "The in-process agent-facing API: rooms, messages, sessions, tools" "Python"
            // evidence: core/switch_core/bridges/agent/protocol/agent_core.py:332 (class AgentCore); main.py:36
        brProtocol = component bridges "Agent protocol surface" "Connection-layer protocol types: events, heartbeat, resume cursor" "Python"
            // evidence: core/switch_core/main.py:32-53 (protocol imports); bridges/agent/protocol/
        brCommands = component bridges "Agent commands & tools" "dispatch_admin_command + tool surface the agent runtime calls" "Python"
            // evidence: core/switch_core/bridges/agent/commands.py:51-56
        brAdapterFw = component bridges "Collaboration adapter framework (PlatformAdapter ABC)" "register_platforms + the adapter contract every platform implements" "Python"
            // evidence: core/switch_core/bridges/collaboration/adapter.py:433 (class PlatformAdapter(ABC)); platforms.py (imported at main.py:74)
        brPlatformAdapters = component bridges "Platform adapters (Teams/Slack/Discord/Mattermost/Telegram)" "Per-platform event ingestion + reply posting" "Python"
            // evidence: core/switch_core/bridges/collaboration/teams/adapter.py:259-279; main.py:56-62
        brInstall = component bridges "Install & lifecycle services" "Per-platform installers wired in main.py" "Python"
            // evidence: core/switch_core/main.py:70, :61-62, :75, :79, :71
        brMgmtDoor = component bridges "Management door (agent side)" "agent_management protocol surface: enable_agent_management, AgentManagementRefused, NewManagedAgent" "Python"
            // evidence: core/switch_core/bridges/agent/protocol/agent_management.py:24, :37, :60; wiring.py:31

        brAgentCore --> brProtocol "protocol connection layer" "Python import"
            // evidence: core/switch_core/main.py:32-40
        brCommands --> db "user store" "Python import"
            // evidence: core/switch_core/bridges/agent/commands.py:51
        brCommands --> delivery "AddressingResolver" "Python import"
            // evidence: core/switch_core/bridges/agent/commands.py:52
        brCommands --> coreMisc "RoomRef transport" "Python import"
            // evidence: core/switch_core/bridges/agent/commands.py:56
        brAdapterFw --> brPlatformAdapters "register_platforms" "Python call"
            // evidence: core/switch_core/main.py:74 + :56-62
        brInstall --> brPlatformAdapters "per-platform installers" "Python call"
            // evidence: core/switch_core/main.py:61-62, :75, :79
        brMgmtDoor --> management "enable_agent_management / install" "Python call"
            // evidence: core/switch_core/management/wiring.py:31; main.py:1324-1325

    }

    views {

        systemContext switchSystem "L1_Context" "Agent Switch - system context (developers, operators, external systems)" {
            include *
            autolayout lr
        }

        container switchSystem "L2_Containers" "Agent Switch - containers (17 module-map items: core subpackages, console zones, auxiliary pillars)" {
            include *
            autolayout tb
        }

        component coreFlat "L3_coreFlat" "core service kernel - components (composition root + cross-cutting services)" {
            include *
            autolayout tb
        }

        component gatewayCore "L3_gatewayCore" "gateway API - components" {
            include *
            autolayout tb
        }

        component bridges "L3_bridges" "bridges - components" {
            include *
            autolayout tb
        }

    }

}
