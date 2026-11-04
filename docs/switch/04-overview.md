# Overview


Architecture narrative of sandbox-quantum/switch at pin
`39a722c5eeecf8479422351fc7ac2a61fe559a66`. The measured facts (census,
manifests, module edges) live in [`01-cartography.md`](01-cartography.md) and
[`02-module-map.md`](02-module-map.md); this page explains how the pieces fit
together and why. Every claim carries a `file:line` reference into the pinned
tree.


## What Switch is


Switch ("Agent Switch") is an open-source AI agent orchestration and
governance platform: it turns chat channels into rooms where humans and coding
agents work together (`README.md:9` — "Open-source AI teammates, working
alongside your team in Slack, Teams, Discord, Telegram and Mattermost.
Self-host it, with any agent and any model."). The self-description in
`core/pyproject.toml:4` is "Switch — AI agent orchestration and governance
platform"; the console app is "A cross-platform Electron app that orchestrates
multiple coding agents in parallel"
(`console/apps/switch-console-desktop/package.json:4`).


Three runtime surfaces exist, plus a deployment layer:


- **switch-core** — the Python 3.12/FastAPI service (`core/switch_core/`):
  persistence, bridges to chat platforms, the agent-facing API, delivery, and
  the admin HTTP surface. One process, one Postgres database.
- **Switch Console** — the Electron desktop app
  (`console/apps/switch-console-desktop/`), built from a main process, a React
  renderer, and shared/preload code, plus six pnpm workspace libraries
  (`console/packages/`).
- **gateway** — the operator dashboard SPA (`gateway/`), a standalone
  React 19 + MUI 7 web app that consumes switch-core's JSON API.
- **deploy** — compose stacks, the Helm chart, Terraform, the hosted
  controller, and the machine boot enrollment script (`deploy/`).


## The core: one composition root over subpackage zones


`main.py` (2,399 lines) is the composition root: `main()` builds the uvicorn
app (:2376), runs the lifespan sweep loops (:318/:355/:369), prepares and
migrates the database (`_prepare_database` :561, `migrate()` :2338), mounts
the gateway app (:1240) and the agent bridge app, and wires every subpackage.
Around it sit 46 sibling flat modules — configuration (`config.py:145`,
`class SwitchConfig(BaseSettings)`), room lifecycle (`room_service.py:72-83`),
authz (`authz.py:44/:68/:89`), keys, feature flags, templating — that every
subpackage builds on.


The heavy lifting lives in four zones (module map m02–m05): **bridges**
(adapters that map Teams/Slack/Discord/Mattermost/Telegram events into rooms
and expose the agent-facing protocol surface; `collaboration/adapter.py:433`
defines the `PlatformAdapter` ABC, `agent/protocol/agent_core.py:332` defines
`AgentCore`), **db** (SQLAlchemy 2.0 ORM with 97 model classes and
`attach_row_level_security(Base.metadata)` at `models.py:4825`),
**gateway-core** (the FastAPI app `create_gateway_app` assembles at
`app.py:96`), and **migrations** (201 Alembic revisions applied before the
runtime opens; `main.py:2295`).


Two smaller zones complete the core picture. **delivery** decides, at the
moment a room row is written, which agent members the row is for:
`MessageRouter.store` runs inside the row's transaction
(`delivery/router.py:1-8` — "Every row written to a room goes through
MessageRouter.store, in the transaction that writes it"). **management** is
the managed-agent control plane (enrollment, credentials, operations) served
over two doors — controller routes on the agent bridge and owner routes on the
gateway — and compiled off unless the `agent_management` feature flag is on
(`management/wiring.py:237-238`).


## Multi-tenancy is enforced twice


Every tenant-scoped ORM model inherits `TenantScoped`
(`db/models.py:285`), and the database enforces row-level security through DDL
attached at import time (`models.py:4825`). Application-side, every read/write
runs inside `tenant_scope(tenant_id)`
(`tenant_context.py:107`), which stamps the tenant onto the async session
created by the engine factory (`db/engine.py:208`,
`create_session_factory`); the migrations split DDL privileges between a
database owner role and the runtime role. A background script that forgets the
scope fails closed at the database, not silently.


## The message bus is the database


The transport subpackage implements "the write is the send"
(`transport/postgres.py:1-6` docstring): posting a message means inserting a
room row; a Postgres `NOTIFY` trigger plus per-process LISTEN sweep fan the
row out to clients. Delivery decisions ride the same transaction
(`delivery/router.py`), and per-agent events land as `agent_events` rows
written by the router before the caller commits. There is no separate queue
service to operate — the deployment layer only provisions Postgres, the core
image, and the UIs.


## Credentials and agent control planes are isolated


Service credentials never touch chat-platform tokens: the connections
subpackage brokers vendor tokens (issue/refresh/revoke under the connection's
lock, `broker.py:1955`), validates its built-in catalog once at import
(`loader.py:6`), and exposes per-vendor adapters (`adapters/github.py`,
`oauth.py`, `api_key.py`). Managed-agent enrollment is a separate concern:
the console's agent-controller binary enrolls one controller per workspace
seat (`deploy/hosted/machine/switch_machine_boot.py:2,:8`), and the core's
management plane answers over versioned controller routes that reject old
protocol versions with HTTP 426
(`management/controller_routes.py:83-114`).


## Observability is declared, not discovered


Metrics cannot be recorded ad hoc: the observability package defines a
metric catalogue (`observability/catalogue.py`, 693 lines — "nothing
undeclared can be recorded") and telemetry snapshots; session activity is
published through a dedicated publisher
(`session_activity/publisher.py`). The gateway and console render from these
declared surfaces.


## The console is three processes and a protocol client


The desktop app's topology is defined by its build config
(`electron.vite.config.ts:19/:28/:52` — the `@shared` aliases shared by
main/preload/renderer; preload entries :36-40). The renderer never imports
main-process code at runtime: its 14 `@main` imports are all `import type`
(e.g. `renderer/lib/ipc.ts:1`), and it reaches services through the RPC router
(`main/index.ts:186`). Agent sessions are driven through the
`switch-agent-runtime` package — "One connection to Switch: an SSE stream
carrying events, a heartbeat... a cursor so a reconnect resumes"
(`console/packages/switch-agent-runtime/src/index.ts:1-12`) — with provider
adapters for Claude Code, Codex, Cursor, OpenCode, ACP and Antigravity
(`agent-providers/src/`).


## Contracts


`artifacts.yaml` declares the versioned contracts the surfaces speak
(:152-155 agent-protocol, :237-245 gateway-api). The console speaks both: its
gateway client (`main/core/switch-servers/gateway-client.ts`, 4,589 lines)
manages local and remote switch-servers, while its agent runtime connects to
the agent bridge. The operator dashboard speaks only gateway-api
(`gateway/src/data/api.ts:1`, `BASE = "/gateway"`, cookie-authenticated).


## Reading path


[`02-module-map.md`](02-module-map.md) itemizes the 17 modules and their
edges; [`03-c4/`](03-c4/) holds the C4 model with per-edge evidence;
[`06-flows.md`](06-flows.md) walks the expensive end-to-end paths (channel
event → room row → agent reply, and agent session → tool call); and
[`07-usage.md`](07-usage.md) shows working code for 24 use cases across the 8
star-rated modules.
