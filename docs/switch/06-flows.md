# Flows


The five expensive paths of sandbox-quantum/switch at pin
`39a722c5eeecf8479422351fc7ac2a61fe559a66`. Each step cites `file:line`
evidence from the pinned tree; the module ids refer to
[`02-module-map.md`](02-module-map.md).


## 1. Platform channel event → room row → agent reply


The "expensive" path Switch exists for: a Slack/Teams/Discord message becomes
a room row, delivery decides which agents hear it, and the agent's reply is
posted back to the platform.


| # | step | evidence |
|---|---|---|
| 1 | Platform delivers the event to the bridge adapter registered for that platform | `bridges/collaboration/adapter.py:433` (`PlatformAdapter` ABC); `main.py:56-80` (per-platform adapters); `main.py:74` (`register_platforms`) |
| 2 | The adapter resolves the channel to a room and calls the chat service; the message row is written in one transaction with every part | `chats/service.py:1692-1705` (`ChatService.send`, "Post the user's message, every part of it in one transaction"); `main.py:1189` (call site) |
| 3 | The same transaction routes the row: `MessageRouter.store` decides, per agent member, whether the row is for them and writes their `agent_events` | `delivery/router.py:859-877` (`store`, "all in the caller's transaction"); `router.py:793-813` (constructor); `router.py:1-8` (docstring) |
| 4 | The caller commits, then calls `Routed.committed()` — only then do post-commit effects fire | `delivery/router.py:534-566` (`Routed.committed`); `router.py:492-494` usage pattern |
| 5 | Post-commit, each agent's `AgentRecipient` handles the addressed event: replies, refusals, offline notices, `!command` answers | `delivery/recipient.py:480` (`AgentRecipient`); `recipient.py:1111` (`handle_command`); `router.py:1340-1354` (one recipient per member) |
| 6 | Mentions are addressed by `MENTIONS_KEY` — naming a human never wakes an agent | `chats/service.py:1706-1718` (docstring); `delivery/addressing.py` (`AddressingResolver`) |
| 7 | The reply is posted to the platform through the same adapter; client actors fan the row out over Postgres NOTIFY | `transport/postgres.py:254` (`PostgresTransport`), `:1132-1152` (`send_message`); `bridges/collaboration/adapter.py` |


Fan-in/out at this seam (measured, module map m08): 17 files outside
`delivery` feed the router (m01 wiring, m09 transport/chats, m02 bridge
commands, m04 collaborations); delivery in turn depends on m09, m03, m02,
m04 and m01-flat.


## 2. Agent session → tool call → vendor token


An agent run in a room needs a vendor API (e.g. GitHub). The token path is
isolated from chat-platform credentials.


| # | step | evidence |
|---|---|---|
| 1 | The agent process holds one agent-protocol SSE connection (heartbeat + resume cursor) to the bridge | `console/packages/switch-agent-runtime/src/index.ts:1-12`; `artifacts.yaml:152-155` |
| 2 | The agent calls a tool; the bridge command surface dispatches | `bridges/agent/commands.py:51-56` (stores/events/transport imports) |
| 3 | The service broker picks a connection, refreshes it under the connection's lock if stale, mints a token and records the issuance — the session's transaction ends before the vendor call | `connections/broker.py:805-833` (`issue` docstring: "Ends `session`'s transaction before calling the vendor, and commits the issuance record"); `broker.py:310` (`ServiceToken`, "for at most an hour") |
| 4 | Every issue attempt counts into the declared metric catalogue | `broker.py:821-828` (`metrics().increment(SERVICE_TOKEN_REQUESTS, …)`); `observability/catalogue.py:34` (`MetricSpec`); `observability/metrics.py:126` (`increment`) |
| 5 | Business errors return a standard error body instead of raising | `broker.py:253-267` (`ServiceError.body`) |
| 6 | Sign-in flows for humans go through the generic OAuth adapter discovered from vendor metadata | `broker.py:510-533` (`sign_in`); `adapters/oauth.py:237` (`endpoints`), `:61-75` (`AuthorizationEndpoints`) |


## 3. Boot: migrate → prepare → sweep → serve


| # | step | evidence |
|---|---|---|
| 1 | `main()` builds the uvicorn app and enters lifespan | `main.py:2376` (`def main`); `:303-310` (lifespan) |
| 2 | Alembic upgrades the schema head, then `_prepare_database` grants runtime privileges and seeds the admin | `main.py:2295-2296` (`alembic_command.upgrade`); `:561` (`_prepare_database`); `main.py:2338` (`def migrate`, also the `switch-migrate` script, `pyproject.toml:56`) |
| 3 | Three sweep loops start with the lifespan | `main.py:318, :355, :369` |
| 4 | The gateway app (35 routers) and the agent bridge app are assembled and mounted | `main.py:1240` (`create_gateway_app`); `gateway/app.py:96` + 35 `include_router`; `main.py:31-80` (bridge app + adapters) |
| 5 | Management is created only when the `agent_management` flag is on (and `CONTROLLER_TOKEN_SECRET` present), then installed on both apps; controller bindings load before the bridge serves | `management/wiring.py:229-241` (`create_management` flag/secret gate); `wiring.py:72-91` (`install`); `wiring.py:123` (`load_bindings`); `main.py:1055, :1324-1325` |


## 4. Cloud machine enrollment (deploy → controller)


| # | step | evidence |
|---|---|---|
| 1 | The hosted controller provisions a cloud machine per the Helm/Terraform config | `artifacts.yaml:131` ("provisions Switch cloud machines for switch-core"); `deploy/remote/helm/switch/values.yaml:437` |
| 2 | The machine boot script enrolls exactly one `switch-agent-controller` per workspace seat | `deploy/hosted/machine/switch_machine_boot.py:2,:8` |
| 3 | The controller connects over the agent-protocol to the bridge's management door; operations are refused with a typed error when out of policy | `bridges/agent/protocol/agent_management.py:24,:37` (`AgentManagementRefused`, `NewManagedAgent`); `management/wiring.py:31` (`enable_agent_management`) |
| 4 | The controller door version-gates every request: unsupported `Switch-Controller-Protocol` gets HTTP 426 plus the accepted versions header | `management/controller_routes.py:83-84` (header constants), `:89-114` (`ControllerRoute.versioned`, 426), `:111` (`PROTOCOL_ACCEPTS_HEADER` on every response) |
| 5 | Enrollment codes are short-lived, credentials hash-only | `management/service.py:244-258` (`issue_enrollment_code`, `ENROLLMENT_CODE_LIFETIME`); `:206-212` (`create_controller`, "Returns both") |


## 5. Operator dashboard request


| # | step | evidence |
|---|---|---|
| 1 | The SPA calls `/gateway/<resource>` with cookie credentials | `gateway/src/data/api.ts:1` (`BASE = "/gateway"`), `:5` (`credentials: "include"`) |
| 2 | The FastAPI dependency chain authenticates the user | `gateway/auth.py:77,:139`; `gateway/rooms.py:412` (`Depends(get_current_user)`) |
| 3 | The router resolves stores/services and returns Pydantic schemas | `gateway/rooms.py:23-24` (model/store imports); `gateway/schemas.py` (163 classes) |
| 4 | Telemetry is emitted through the declared catalogue only | `gateway/rooms.py:77` (`emit_safely`); `observability/catalogue.py` |


## Flow shape summary


Every expensive path funnels through two choke points: the **database
transaction** (rows are written once, delivery rides the same transaction)
and the **module-map edges** (m08 delivery ← m09 transport/m02 bridges/m04
gateway; m07 connections ← m04 gateway/m02 bridges; m06 management ← m02
bridge door + m01 wiring). That is why the deploy layer needs only Postgres,
the core image and the UIs — no broker or queue exists outside Postgres
(`transport/postgres.py:1-6`).
