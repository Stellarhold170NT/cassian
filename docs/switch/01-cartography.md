---
subject: sandbox-quantum/switch
measured_at: 39a722c5eeecf8479422351fc7ac2a61fe559a66
status: final
---

# Cartography


Repository census of sandbox-quantum/switch ("Agent Switch") — license gate,
source census, build manifests, entry points, and top-level layout. This is the
orientation document for the subject; the module-by-module breakdown follows in
[`02-module-map.md`](02-module-map.md), the architecture sources in
[`03-c4/`](03-c4/), the narrative overview in [`04-overview.md`](04-overview.md),
the folder map in [`05-folders.md`](05-folders.md), the expensive flows in
[`06-flows.md`](06-flows.md), and the hands-on use cases in
[`07-usage.md`](07-usage.md).


**Measurement note.** Everything on this page was measured on a shallow
checkout of upstream `main` at commit
`39a722c5eeecf8479422351fc7ac2a61fe559a66` ("@pintu544 has signed the CLA in
sandbox-quantum/switch#1423", 2026-11-03 23:27:31 UTC) — the same pin the
module map, the C4 model, and the harvest in `modules/switch/` are frozen
against. The clone used `--depth 100 --single-branch`; `git rev-list --count
HEAD` reports 513 commits in that cut DAG (larger than the depth parameter
because merge topology pulls side-branch ancestors in). Every `file:line`
reference in the subject docs resolves against this tree.


## License gate


The subject passes the reuse gate before any measurement: `LICENSE` exists at
the pin (12,714 bytes) — "Software: Agent Switch / Copyright (c) 2026 SB
Technology, Inc. dba SandboxAQ / This software is licensed to you under the
Apache 2.0 License as limited by the 'Commons Clause' license condition". The
declared identifiers agree: `core/pyproject.toml:11` declares
`license = "LicenseRef-Apache-2.0-with-Commons-Clause"`, and the console
package declares `"license": "SEE LICENSE IN LICENSE"`
(`console/apps/switch-console-desktop/package.json:13`).


## Source census


Counted with the census formula — per extension,
`find … -print0 | xargs -0 cat | wc -l`, then summed (never a single
`xargs wc -l | tail -1`, which only captures the last batch):


| extension | files | lines |
|---|---|---|
| .py | 1,407 | 436,178 |
| .ts | 1,857 | 304,875 |
| .tsx | 645 | 115,142 |
| **total** | **3,909** | **856,195** |


The checkout contains 4,613 files in total; the difference against the census
is non-code content (markdown, YAML/TOML config, images, lockfiles, signatures).


## Build manifests


The repo builds as three independent trees glued by one artifact registry:


- **`core/pyproject.toml`** (108 lines) — `switch-core` 0.31.0, Python ≥ 3.12,
  hatchling backend, wheel package `switch_core`. Runtime deps are the whole
  platform surface in one service: `sqlalchemy[asyncio]`, `asyncpg`,
  `pydantic`/`pydantic-settings`, `alembic`, `fastapi`, `uvicorn`, `httpx`,
  `fastmcp`, plus one SDK per collaboration platform (`slack-sdk`,
  `mattermostdriver`, `discord-py`, `python-telegram-bot`) and the auth stack
  (`cryptography`, `PyJWT`, `authlib`). Console scripts:
  `switch-core = "switch_core.main:main"`, `switch-migrate =
  "switch_core.main:migrate"`.
- **`console/apps/switch-console-desktop/package.json`** (159 lines) —
  `@switch-console/desktop` 0.40.1, "A cross-platform Electron app that
  orchestrates multiple coding agents in parallel"; five `workspace:*`
  dependencies into `console/packages/*`, Electron tooling
  (`electron-vite` build, `vitest` test, `electron-builder` package), engines
  `node >= 24`, `pnpm >= 10.28.0`.
- **`gateway/package.json`** (40 lines, private) — `switch-gateway`, the
  operator dashboard SPA: React 19 + MUI 7 on Vite (`vite`/`vitest`), with
  `react-router` and CodeMirror editors.
- **`artifacts.yaml`** (269 lines) — the registry tying it together: 10
  artifacts (`switch-core` 0.31.0, `switch-console` 0.40.1 pinning
  `switch-core: 0.31.0`, `agent-runtime` 0.8.0, `sidecar` 1.9.12, and the
  version-following `gateway`, `setup`, `helm-chart`, `hosted-controller`,
  `hosted-controller-chart`, `compose`) and 5 contracts (`agent-protocol`,
  `gateway-api`, `stack-compose`, `sidecar-control`, `db-schema`).


## Entrypoints


- **switch-core** — `core/switch_core/main.py` (2,399 lines): `main()` builds
  the uvicorn app, runs the lifespan sweep loops, prepares/migrates the
  database and seeds the admin (`_prepare_database` :561, `migrate()` :2338).
  The package carries **47 top-level modules** (maxdepth 1) — config, room
  lifecycle, authz, keys, feature flags, templating — that every subpackage
  builds on.
- **Switch Console** — `console/apps/switch-console-desktop`, entry
  `./out/main/index.js` built from `src/main`; source dirs `assets main
  preload renderer shared types`.
- **gateway** — Vite SPA served by switch-core under `/gateway`
  (`gateway/src/data/api.ts:1` `BASE = "/gateway"`).


## Top-level directories


11 first-level directories (matching `CONTRIBUTING.md:62-66`):


| directory | role |
|---|---|
| `core/` | Backend tree — self-contained Python project: `switch_core` (618 `.py` files) + 757 test files under `core/tests` + `pyproject.toml`/`alembic.ini` |
| `console/` | Switch Console desktop app: `apps/switch-console-desktop` + six workspace packages + e2e harness + engineering guides |
| `gateway/` | Operator dashboard SPA (React 19 + MUI, Vite), standalone |
| `deploy/` | Local compose, Helm chart, Terraform, hosted controller, machine boot, container images |
| `docs/` | Two-tier docs: `official/` (generated, do not edit) + `old/` (internal/historical) + topic folders |
| `examples/` | Packaged example templates (4 agent + 1 room) |
| `scripts/` | Maintainer scripts (artifacts generator/verifier, chart pinning, migration-head guard, docs sync) |
| `switch-expert/` | Bundled `switch-expert` agent template (persona + v2 template + knowledge) |
| `signatures/` | CLA signature data (`version1/cla.json`) |
| `assets/` | Branding and README imagery |
| `.github/` | CI/CD and repo administration (9 workflows) |


Root glue outside the eleven: `artifacts.yaml`, `justfile`, `ruff.toml`,
`renovate.json5`, `socket.yml`, and the administration files (`LICENSE`,
`README.md`, `CHANGELOG.md`, `CONTRIBUTING.md`, `RELEASING.md`, `SECURITY.md`,
`CODE_OF_CONDUCT.md`, `CLAUDE.md`, `NOTICE`, `CLA.md`, `CCLA.pdf`).
