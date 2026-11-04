# Folders


The directory map of sandbox-quantum/switch at pin
`39a722c5eeecf8479422351fc7ac2a61fe559a66`, annotated with measured sizes
(census per extension then summed). Only the load-bearing paths are listed;
sizes are (files, lines) of code, not raw directory entries.


```
switch/                                4,613 files in checkout
├── core/                              the backend monorepo (self-contained Python project)
│   ├── switch_core/                   618 .py files — the runtime package
│   │   ├── main.py                    composition root (2,399 lines)
│   │   ├── config.py, authz.py, keys.py, feature_flags.py, …   46 flat cross-cutting modules
│   │   ├── bridges/                   platform + agent-protocol adapters (112 files / 69,668 loc)
│   │   │   ├── collaboration/         adapter.py (PlatformAdapter ABC), teams/, slack/, discord/, mattermost/, telegram/
│   │   │   └── agent/                 protocol/ (agent_core.py, agent_management.py), commands.py, auth.py, mcp/
│   │   ├── db/                        SQLAlchemy ORM + stores (73 files / 21,079 loc)
│   │   │   ├── models.py              97 model classes; RLS attach at :4825
│   │   │   ├── stores/                47 per-entity store modules (room_store.py, user_store.py, …)
│   │   │   └── engine.py              async session factory with tenant stamping
│   │   ├── gateway/                   FastAPI HTTP API (47 files / 21,147 loc)
│   │   │   ├── app.py                 create_gateway_app + 35 include_router
│   │   │   ├── schemas.py             163 Pydantic request/response classes
│   │   │   └── rooms.py, tenants.py, organizations.py, auth.py, …
│   │   ├── migrations/                201 Alembic revisions (202 files / 14,305 loc)
│   │   │   ├── env.py                 binds SwitchConfig + db engine
│   │   │   └── versions/              ordered revision chain
│   │   ├── management/                managed-agent control plane (21 files / 6,990 loc)
│   │   │   ├── wiring.py              flag gate (returns None when off)
│   │   │   ├── service.py             controller enrollment + credentials
│   │   │   └── controller_routes.py   versioned controller door (426 on old protocol)
│   │   ├── connections/               service-credential broker (18 files / 6,935 loc)
│   │   │   ├── broker.py              issue/refresh/revoke under lock
│   │   │   ├── loader.py              import-validated connection catalog
│   │   │   ├── catalog/               16 vendor entries (connection.yaml + SKILL.md)
│   │   │   └── adapters/              github.py, oauth.py, api_key.py
│   │   ├── delivery/                  per-row agent addressing (5 files / 4,855 loc)
│   │   │   ├── router.py              MessageRouter.store in the row's transaction
│   │   │   └── recipient.py           post-commit replies, commands, notices
│   │   ├── transport/                 Postgres message transport ("the write is the send")
│   │   ├── chats/, clients/, sessions/, session_activity/, telemetry/,
│   │   │   observability/, providers/, provisioning/, messages/,
│   │   │   official_templates/, accounts/, trust/            13 domain subpackages (24,693 loc total)
│   │   └── tests/ → ../tests          core/tests carries 757 test files (not an item)
│   ├── tests/                         757 test .py files (pytest suite)
│   ├── pyproject.toml                 switch-core 0.31.0 manifest + console scripts
│   ├── alembic.ini                    migration CLI config
│   └── uv.lock                        locked dependency set
├── console/                           Switch Console (Electron desktop app)
│   ├── apps/switch-console-desktop/
│   │   ├── src/main/                  Electron main process (743 files / 130,033 loc incl. tests)
│   │   │   └── core/switch-servers/gateway-client.ts   4,589-line gateway client
│   │   ├── src/renderer/              React UI (986 files / 140,969 loc incl. tests)
│   │   │   ├── main.tsx               entry: view registry + rpc bootstrap
│   │   │   └── features/              templates/, switch-servers/, switch-rooms/, onboarding/, …
│   │   ├── src/shared/ + src/preload/ + src/types/           @shared logic + electronAPI bridges
│   │   ├── electron.vite.config.ts    three-process build topology
│   │   └── package.json               @switch-console/desktop 0.40.1
│   ├── packages/                      six pnpm workspace libraries (41,352 loc core code)
│   │   ├── switch-agent-runtime/      agent-protocol SSE client
│   │   ├── agent-providers/           claude/, codex/, cursor/, opencode/, acp/, antigravity/
│   │   ├── agent-controller/          hosted controller binary
│   │   └── core/, plugins/, shared/
│   ├── tooling-e2e/                   Playwright end-to-end harness
│   └── AGENTS.md, docs/               console engineering guides
├── gateway/                           operator dashboard SPA (148 files / 30,241 loc)
│   ├── src/data/api.ts                /gateway JSON client (2,621 lines)
│   ├── src/pages/                     rooms/, machines/, organizations/, usage/, …
│   └── package.json                   switch-gateway (private, React 19 + MUI 7)
├── deploy/                            deployment layer (75 files / 13,337 loc)
│   ├── local/docker-compose.yml       local stack (core + postgres + platforms)
│   ├── shared_resources/images/       Dockerfile.switch (:36 COPY core/switch_core/), Dockerfile.gateway
│   ├── remote/helm/switch/            Helm chart (values.yaml 1,092 lines, _helpers.tpl 1,131)
│   ├── hosted/                        EC2 hosted controller + machine boot (Terraform, Python)
│   │   └── machine/switch_machine_boot.py   per-seat controller enrollment
│   └── standalone/                    all-in-one Docker stack
├── docs/                              written docs (two tiers; no code imports)
│   ├── README.md                      index: official/ (synced, generated) + old/
│   ├── official/                      synced from the upstream docs repo (do not edit)
│   └── old/                           internal architecture/protocol/bridge references
├── examples/                          5 packaged example templates (agent + room)
├── scripts/                           maintainer tooling (gen_artifacts.py, pin_chart_images.py,
│                                      check_migration_heads_for_open_prs.py, e2e_surface.py, …)
├── switch-expert/                     bundled expert agent template (AGENT.md, template.yaml, knowledge/)
├── signatures/                        CLA data (version1/cla.json)
├── assets/                            branding + README imagery
├── .github/                           9 CI/CD workflows
├── artifacts.yaml                     artifact + contract registry (10 artifacts, 5 contracts)
├── justfile                           task runner (compose up, gen_artifacts, sync-docs, e2e, …)
└── LICENSE                            Apache-2.0 with modified Commons Clause (12,714 bytes)
```


Notes:


- `core/tests/` is intentionally outside every module item; the item censuses
  in [`02-module-map.md`](02-module-map.md) cover production code only.
- `console/apps/switch-console-desktop/src/{main,renderer}` censuses include
  their colocated test files; the pure-code split is documented in the module
  map's per-item rows.
- `docs/official/` is generated (synced from the upstream docs repo by
  `just sync-docs`, `docs/README.md:9,:14`); the editable knowledge lives in
  `docs/old/` and the per-package engineering guides.
- Root files (`README.md`, `CHANGELOG.md`, `CONTRIBUTING.md`, `RELEASING.md`,
  `SECURITY.md`, `artifacts.yaml`, `justfile`, `ruff.toml`, `renovate.json5`)
  belong to the docs/tooling items, not to any runtime module.
