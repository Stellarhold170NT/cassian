# Usage


Hands-on use cases for the eight star-rated modules of
sandbox-quantum/switch, measured at pin
`39a722c5eeecf8479422351fc7ac2a61fe559a66`. Three use cases per module,
ordered by module rank (deploy → core-flat → db → gateway-core → delivery →
management → connections → core-misc): **24 use cases, 105 cited evidence
lines**. Every signature in every example was read verbatim from the pinned
clone and is re-cited below; line numbers refer to that tree.


> Build note. The examples are contract-level: they were verified by reading
> the pinned sources (imports, signatures, call sites), not by executing the
> project's toolchain in the measurement environment (no `uv`/`pnpm`/`docker`
> available; installing tools was out of scope). The core test suite that
> covers these modules is `core/tests/` (757 test files), run upstream by
> `pr-ci.yml:233` (`uv run --project core pytest -c core/pyproject.toml
> core/tests/`).


## 1. deploy — `deploy/` (★3)


The deployment layer: local compose, Helm chart, Terraform, hosted controller,
machine boot enrollment, container images.


### UC-15.1 — Bring up the full local stack


`justfile:51` runs `docker compose -f deploy/local/docker-compose.yml up`;
the compose file defines the core service, Postgres, and the collaboration
platforms. The standalone all-in-one variant adds `--profile collab --profile
gateway` (`justfile:240`).

```bash
just up          # justfile:51 — compose -f deploy/local/docker-compose.yml up
# or the standalone stack:
docker compose -f deploy/standalone/docker-compose.yml \
  --profile collab --profile gateway up
```


Evidence: `justfile:51`, `justfile:240`;
`deploy/local/docker-compose.yml` (core + postgres + platform services).


### UC-15.2 — Understand what the core image contains


`Dockerfile.switch` builds one image from two stages: the `gateway-ui` stage
builds the operator dashboard, then the final stage copies `core/switch_core/`
and the built gateway — which is why the deploy module's build edges reach
every core subpackage plus gateway-web.

```dockerfile
# deploy/shared_resources/images/Dockerfile.switch
FROM node:24-slim AS gateway-ui          # :6 — builds gateway/
# ...
COPY gateway/ /build/gateway             # :11
# ...
COPY core/switch_core/ switch_core/      # :36 — the whole core package
COPY --from=gateway-ui /build/out /srv/gateway   # :50 — inline the dashboard
```


Evidence: `deploy/shared_resources/images/Dockerfile.switch:6,:11,:36,:50`;
`deploy/shared_resources/images/Dockerfile.gateway:6` (`COPY gateway/`).


### UC-15.3 — Enroll a cloud machine (one controller per seat)


`switch_machine_boot.py` boots a machine and enrolls exactly one
`switch-agent-controller` per workspace seat; the hosted controller image
provisions the machines (Helm values wire the seat count).

```bash
python3 deploy/hosted/machine/switch_machine_boot.py   # enroll per-seat controller
```


Evidence: `deploy/hosted/machine/switch_machine_boot.py:2,:8` ("one agent
controller per workspace; enrolls a switch-agent-controller");
`deploy/remote/helm/switch/values.yaml:437`.


## 2. core-flat — `core/switch_core` top-level (★1)


The composition root plus 46 cross-cutting flat modules.


### UC-01.1 — Configure the service from the environment


`SwitchConfig` is a pydantic-settings object; every startup decision (DB URL,
secrets, feature flags, platform credentials) reads from it.

```python
from switch_core.config import SwitchConfig   # config.py:145
# class SwitchConfig(BaseSettings) — env-driven:
config = SwitchConfig()
config.database_url; config.agent_management_enabled; config.controller_token_secret
```


Evidence: `core/switch_core/config.py:145`
(`class SwitchConfig(BaseSettings)`); `main.py:561` (threaded into
`_prepare_database`).


### UC-01.2 — Run the migration entrypoint


`switch-migrate` is a console script wrapping `main.migrate()` — the same
path the runtime runs at boot.

```bash
uv run switch-migrate          # pyproject.toml:56 → switch_core.main:migrate
```


Evidence: `core/pyproject.toml:56` (`switch-migrate =
"switch_core.main:migrate"`); `main.py:2338` (`def migrate`); `main.py:2295`
(`alembic_command.upgrade`).


### UC-01.3 — Wire a background sweep


The lifespan starts three sweep loops; a new periodic job follows the same
pattern — an async loop registered in the app lifespan.

```python
# core/switch_core/main.py — lifespan (:303-310) starts the sweeps:
#   :318 room sweep · :355 session sweep · :369 telemetry sweeps
with lifespan(app):
    ...   # sweeps run until shutdown
```


Evidence: `core/switch_core/main.py:303-310` (lifespan), `:318/:355/:369`
(sweep starts).


## 3. db — `core/switch_core/db` (★1)


The PostgreSQL persistence layer: 97 ORM classes, RLS, async sessions, stores.


### UC-03.1 — Open the async session factory


The engine factory stamps the bound tenant onto every transaction it creates;
process wiring calls it once and shares the factory.

```python
from switch_core.db.engine import create_session_factory   # engine.py:208

session_factory = create_session_factory(engine)   # engine.py:208
async with session_factory() as session:           # AsyncSession, tenant-stamped
    ...
```


Evidence: `core/switch_core/db/engine.py:208`
(`create_session_factory`); `main.py:736` pattern (`room_store = RoomStore()`).


### UC-03.2 — Read a room through its store inside tenant scope


Stores are stateless classes; the session must open inside `tenant_scope` so
RLS and the tenant check have context — the same pattern the gateway uses.

```python
from switch_core.db.stores import RoomStore            # stores/__init__.py:16
from switch_core.tenant_context import tenant_scope    # tenant_context.py:107

rooms = RoomStore()                                    # main.py:736

async with tenant_scope(tenant_id):                    # tenant for the whole block
    async with session_factory() as session:
        room = await rooms.get(session, room_id)       # Room | None
```


Evidence: `core/switch_core/db/stores/room_store.py:70,:76`
(`class RoomStore`, `async def get(session, room_id) -> Room | None`);
`stores/__init__.py:16` (store exports); `gateway/auth.py:978` (real
tenant-scoped pattern: `with tenant_scope(tenant_id), log_context(...)`).


### UC-03.3 — Audit the tenant-scoped schema and its RLS


For schema review or migration prep: list models under row-level security and
confirm the metadata attachment point.

```python
from switch_core.db.models import Base, TenantScoped   # models.py:285/:4825

tenant_scoped = [m.class_.__name__ for m in Base.registry.mappers
                 if issubclass(m.class_, TenantScoped)]
# 97 model classes total; RLS DDL attached once at import: models.py:4825
```


Evidence: `core/switch_core/db/models.py:285` (`class TenantScoped`),
`:175` (`Tenant`), `:840` (`Agent(TenantScoped, Base)`), `:1098`
(`Room(TenantScoped, Base)`), `:4825` (`attach_row_level_security(Base.metadata)`),
`:4820-4822` (comment pointing at `db/rls_ddl.py` for the DDL).


## 4. gateway-core — `core/switch_core/gateway` (★1)


The HTTP API: one FastAPI app assembled from 35 routers.


### UC-04.1 — Assemble the app in a test harness


The repo's own route-mounting test builds the app with mocks and a real
config, then inspects `app.routes` — the pattern for smoke tests.

```python
from unittest.mock import MagicMock
from switch_core.config import SwitchConfig               # real config (per test comment)
from switch_core.gateway.app import create_gateway_app    # app.py:96

app = create_gateway_app(
    agent_store=MagicMock(), room_store=MagicMock(), chat_service=MagicMock(),
    session_factory=MagicMock(), user_store=MagicMock(),  # … every service dep
    config=SwitchConfig(),
)
paths = {route.path for route in app.routes}
assert "/rooms" in paths
```


Evidence: `core/tests/switch_core/gateway/test_app_route_mounting.py:20-52`
(the repo's real harness; comment :23-25 "A real config rather than a mock"),
`:57-59` (paths assertion); `gateway/app.py:96` (`create_gateway_app`),
`:222` (`include_router(rooms_router, prefix="/rooms")`); `main.py:1240`
(production call site).


### UC-04.2 — Create a room over HTTP (POST /rooms → 201)


Clients speak pure HTTP: a `RoomCreateRequest` body in, a `RoomDetail` out.

```python
import httpx

resp = httpx.post(
    "https://<gateway-host>/rooms",          # prefix from app.py:222
    json={"name": "incident-42",
          "description": "War room for incident 42",
          "instructions": "Summarize every 30 minutes.",
          "agent_ids": ["agent-oncall", "agent-scribe"],
          "internal_only": True},             # RoomCreateRequest — schemas.py:122-141
)                                            # dependency get_current_user (rooms.py:412)
assert resp.status_code == 201               # declared at rooms.py:406
room = resp.json()                           # RoomDetail (handler return type)
```


Evidence: `core/switch_core/gateway/schemas.py:122-141`
(`RoomCreateRequest`: name, description, instructions, agent_ids,
internal_only, read_visibility); `gateway/rooms.py:406-413`
(`@router.post("", status_code=201)`, handler `create_room`); `app.py:222`.


### UC-04.3 — Poll rooms and open one


List and detail share the `/rooms` prefix.

```python
rooms = httpx.get("https://<gateway-host>/rooms").json()
room  = httpx.get(f"https://<gateway-host>/rooms/{room_id}").json()
```


Evidence: `core/switch_core/gateway/rooms.py` (list + detail routes under
prefix `/rooms`, mounted at `app.py:222`).

## 5. delivery — `core/switch_core/delivery` (★1)


Per-row agent addressing and post-commit replies.


### UC-05.1 — Address a message to agents (`@mention` + `MENTIONS_KEY`)


`AddressingResolver` reads a room row's mentions and content and decides which
agent members it is for; naming a human never wakes an agent.

```python
from switch_core.delivery import AddressingResolver, IncomingMessage  # __init__.py:14

resolver = AddressingResolver(
    session_factory=..., room_store=..., room_role_store=...,
    agent_store=..., external_user_store=..., client_store=...,
)
decision = resolver.decide(IncomingMessage(...))   # AddressingDecision per row
```


Evidence: `core/switch_core/delivery/__init__.py:14` (exports);
`delivery/addressing.py` (`AddressingResolver`, 541 lines);
`chats/service.py:1706-1718` (`mention_user_ids` "address no agent
(`MENTIONS_KEY`)").


### UC-05.2 — Store + route a room row atomically (`MessageRouter.store`)


The router decides every row as it is written — per-agent `agent_events` land
inside the caller's transaction; replay with `unless_stored=True` is a no-op.

```python
from switch_core.delivery.router import MessageRouter, Routed   # router.py:793

router = MessageRouter(services=recipient_services, message_store=...,
                       client_store=..., budget_store=..., conversation=...)

async with session.begin():                       # the CALLER's transaction
    routed = await router.store(
        session, tenant_id=..., room_id=..., transport_room_id=...,
        message=message, attachments=attachments,  # -> Routed | None
    )
if routed is not None:
    routed.committed()                            # router.py:566 — post-commit fanout

dup = await router.store(session, ..., unless_stored=True)
assert dup is None                                # replay-safe
```


Evidence: `core/switch_core/delivery/router.py:793-813` (constructor,
"Decides every room row as it is written. One per process."), `:859-877`
(`store` docstring: "all in the caller's transaction. The caller commits,
then calls `Routed.committed()`"), `:534-566` (`Routed.committed`);
`delivery/recipient.py:186-207` (`RecipientServices` fields).


### UC-05.3 — Post-commit replies and `!commands` (`AgentRecipient`)


One recipient per agent member (built by the router at :1340); it answers
commands, refuses politely, and posts unavailable/offline notices.

```python
from switch_core.delivery.recipient import AgentRecipient   # :480

recipient = AgentRecipient(services=..., member=member, tenant_id=...,
                           actor=..., addressing=..., notices=...)  # call site router.py:1340
await recipient.handle_command(event)            # recipient.py:1111 — "!deploy …"
```


Evidence: `core/switch_core/delivery/recipient.py:480` (`AgentRecipient`),
`:1111` (`handle_command`), `:127` (`RoomMember`), `:208-215`
(`SwitchNotices.switch_notice`); `router.py:1340-1354` (real construction).


## 6. management — `core/switch_core/management` (★1)


Flag-gated managed-agent control plane with two doors.


### UC-06.1 — Enable the control plane (`create_management` + `install`)


When the flag is off nothing is mounted; when on, the controller door mounts
on the bridge app and owner routes on the gateway.

```python
from switch_core.management.wiring import create_management   # wiring.py:229

management = create_management(config, session_factory, presence,
                               signal_bus, lease, user_changes)  # Management | None
if management is not None:
    management.install(agent_bridge_app=..., gateway_app=..., protocol=agent_core)
    await management.load_bindings()        # wiring.py:123 — which controller runs which agent
```


Evidence: `core/switch_core/management/wiring.py:229-241` (returns None when
`agent_management_enabled` is false; RuntimeError when the flag is on without
`CONTROLLER_TOKEN_SECRET`), `:72-91` (`install`: include controller router,
`mount_gateway_routes`, `enable_agent_management`), `:123` (`load_bindings`);
`main.py:1055`, `:1324-1325` (real call sites).


### UC-06.2 — Enroll a controller (credential + enrollment code)


`create_controller` commits and returns the credential exactly once (hash-only
after that); enrollment codes are short-lived.

```python
from switch_core.management.service import ManagementService   # service.py:145

controller, credential = await management.create_controller(
    session, owner_id=owner.id, description=..., public_key=...)  # :206-212
code, expires_at = await management.issue_enrollment_code(
    session, owner_id=owner.id)                                   # :244-258
```


Evidence: `core/switch_core/management/service.py:206-212` (docstring
"Create a controller and its credential, and commit. Returns both."),
`:244-258` (`ENROLLMENT_CODE_LIFETIME`, commit, returns code + expiry);
`controller_routes.py:162` (`enroll_controller` route).


### UC-06.3 — Protocol-gate the controller door (HTTP 426)


Old controllers are refused with a standard error and told which versions are
accepted, on every response.

```python
# Contract of the controller door (controller_routes.py:83-114):
#   client sends:  Switch-Controller-Protocol: <v>          (:83)
#   server always: Switch-Controller-Protocol-Accepts: ...   (:111)
if response.status_code == 426:              # :107 — unsupported version
    upgrade_then_retry(accepts=response.headers["Switch-Controller-Protocol-Accepts"])
```


Evidence: `core/switch_core/management/controller_routes.py:83-84` (header
constants), `:89-114` (`ControllerRoute.versioned` → 426), `:111`
(accepts-header on every response); `router = APIRouter(route_class=ControllerRoute)`
at `:117`.


## 7. connections — `core/switch_core/connections` (★1)


The service-credential broker and its import-validated catalog.


### UC-07.1 — Issue a vendor token for an agent (`ServiceBroker.issue`)


Tokens live at most an hour, are issued under the connection's lock, and every
attempt is metered by outcome.

```python
from switch_core.connections.broker import Principal, ServiceError  # :278/:253

try:
    token = await broker.issue(session, agent_id=agent.id,
                               principal=Principal.agent_key(),   # :286
                               service="github")                  # catalog slug
except ServiceError as err:
    return err.body                        # standard error dict (:267)
# every attempt: metrics().increment(SERVICE_TOKEN_REQUESTS, {connector, outcome})
```


Evidence: `core/switch_core/connections/broker.py:805-833` (`issue` —
"for at most an hour", "Ends `session`'s transaction before calling the
vendor, and commits the issuance record"), `:278-287` (`Principal.agent_key`),
`:253-267` (`ServiceError.body`), `:310` (`ServiceToken`), `:821-828`
(metric increment in `finally`); `main.py:1381` (`service_broker =
ServiceBroker(`).


### UC-07.2 — Start a generic OAuth sign-in (`sign_in` + `OAuthAdapter`)


The broker resolves the catalog entry and adapter; the adapter discovers the
vendor's authorization/token endpoints.

```python
definition, adapter = await broker.sign_in(session, "github")   # broker.py:510-533
endpoints = await adapter.endpoints()       # oauth.py:237 → AuthorizationEndpoints
# endpoints.authorization / .token / .registration / .revocation (:61-75)
```


Evidence: `core/switch_core/connections/broker.py:510-533` (guard: non-OAuth
adapter → `ServiceError(404, …)`); `adapters/oauth.py:162` (`OAuthAdapter`),
`:237` (`endpoints`), `:61-75` (`AuthorizationEndpoints` fields);
`loader.py:544` (`ConnectionDefinition`).


### UC-07.3 — Trust the catalog (validated at import)


A malformed `connection.yaml` cannot boot the process — the catalog is
validated once at import, before any user action.

```python
import switch_core.connections.loader as loader    # loader.py:838
sorted(loader.CATALOG)   # 16 entries: airtable, asana, atlassian, bitbucket, box,
                         # canva, datadog, github, gitlab, google-workspace, linear,
                         # microsoft-365, new-relic, notion, salesforce, vercel
loader.CATALOG["github"].adapter   # "github" (broker.py:518 reads this field)
```


Evidence: `core/switch_core/connections/loader.py:33` (`CATALOG_ROOT`),
`:838` (`CATALOG = load_catalog(CATALOG_ROOT)`), `:1-6` (docstring: "The
catalog is validated once, at import, so a malformed …");
`connections/catalog/` — 16 vendor directories (sandbox listing);
`catalog/github/connection.yaml:1-8` (slug/name/adapter/auth/token fields).


## 8. core-misc — 13 domain subpackages (★1)


Chats, transport, telemetry/observability, clients, and friends.


### UC-08.1 — Post a message straight onto the bus (`PostgresTransport.send_message`)


Internal processes skip HTTP: "sending" a message is writing the room row; the
Postgres NOTIFY trigger and the core's sweep deliver it.

```python
from switch_core.transport.postgres import PostgresTransport   # :254

result = await transport.send_message(
    room_id, "Deploy 1.42 finished — no blocking findings",
    sender_name="ci-bot",
    metered=False,                        # system message, not budgeted
    format="text",                        # MessageFormat default
    mentions=["@alice:example.org"],      # addressed by delivery after the write
)
# same family: send_event (:1156), send_media (:1166)
```


Evidence: `core/switch_core/transport/postgres.py:254` (`PostgresTransport`),
`:1132-1152` (`send_message` full signature), `:1156` (`send_event`),
`:1166` (`send_media`); `clients/client_factory.py:145` (production
construction); docstring `:1-6` ("The write is the send.").


### UC-08.2 — Send a chat message with agent mentions in one transaction (`ChatService.send`)


Every part of the message and its operation marks commit together; retry
before commit posts exactly once; only `mention_agent_ids` wake agents.

```python
from switch_core.chats.service import ChatService    # :161 (main.py:1189 call site)

room, messages = await chat.send(
    tenant_id, user, room_id,
    request_id=str(uuid4()),
    body="Review the new findings",
    thread_root_id=None, upload_ids=[],
    mention_agent_id=None,                 # legacy single-agent form
    mention_agent_ids=["agent-helper"],    # agents woken by this message
    mention_user_ids=[],                   # real people — wake no agent
    mention_spans=[],                      # UTF-16 offsets of each mention
)                                          # -> tuple[Room, list[Message]] (:1705)
```


Evidence: `core/switch_core/chats/service.py:1692-1705` (full signature),
`:1706-1718` (docstring: "Post the user's message, every part of it in one
transaction … The people it names, `mention_user_ids`, address no agent
(`MENTIONS_KEY`) … UTF-16 offsets, as the Console's strings count");
`main.py:1189`; `service.py:1023,:1358` (membership API).


### UC-08.3 — Tenant lifecycle + declared-only metrics


`ClientLifecycleService` creates tenants, ensures system clients, starts every
client actor; all metrics go through the declared catalogue.

```python
from switch_core.clients.client_lifecycle_service import ClientLifecycleService  # :89

lifecycle = ClientLifecycleService(...)                 # main.py:942
tenant = await lifecycle.create_tenant(name="Acme Robotics", slug="acme",
                                       organization_id=org_id)   # :256
await lifecycle.ensure_system_client(client_type)      # :204
await lifecycle.start_all()                            # :317 — start every client actor

# metrics: only declared specs, only via the catalogue
# observability/catalogue.py:34 class MetricSpec · metrics.py:126 def increment
```


Evidence: `core/switch_core/clients/client_lifecycle_service.py:89`
(`ClientLifecycleService`), `:256` (`create_tenant`), `:204`
(`ensure_system_client`), `:317` (`start_all`); `main.py:942`;
`observability/catalogue.py:34` (`MetricSpec`); `observability/metrics.py:126`
(`increment`, used by `broker.py:821-828`).


---


Use-case counts per module: deploy 3 · core-flat 3 · db 3 · gateway-core 3 ·
delivery 3 · management 3 · connections 3 · core-misc 3 — **24 use cases,
105 cited evidence lines**, all re-verified against the pin
`39a722c5eeecf8479422351fc7ac2a61fe559a66`. Module context:
[`02-module-map.md`](02-module-map.md); flow context:
[`06-flows.md`](06-flows.md).
