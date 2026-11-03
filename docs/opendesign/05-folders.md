# Folder structure (nexu-io/open-design)

- Subject: `nexu-io/open-design` · TypeScript pnpm monorepo · PIN
  `5a0c47777975ddb91d09c1c16b423a3ef74bf572` (branch `main` — `git rev-parse
  HEAD` on the measuring clone equals the PIN).
- Inputs: the cartography census (`01-cartography.md`, top-level dirs) + the
  module map (`02-module-map.md`, 27 items).
- Measurement basis: shallow clone `--depth 1 --filter=blob:limit=1m` +
  sparse-checkout `--no-cone apps packages tools shells e2e clipper
  figma-plugin '*.md' '*.json' '*.yaml' '*.toml'`; every `find`/`grep`/`wc`
  ran on the PIN tree. "files" counts in section 1 count every file type
  (not only ts) — same basis as the cartography top-dir columns.
- Evidence notation: `File: <path> | Line: n | Content: <quote>` for
  line-level claims; `Measured: <command>` for reproducible counts.

## 1. Main zone map (from the cartography top-dirs, re-verified on the PIN)

Two layers of zones: **workspace packages** (the 5 globs in
`pnpm-workspace.yaml`) and **corpus/data + docs** (outside the workspace,
not built).

`File: pnpm-workspace.yaml | Line: 1-6 | Content: "packages:\n  - packages/*\n  - apps/*\n  - tools/*\n  - shells/*\n  - e2e"`

### 1a. Workspace zones (27 items — matches the module map 27/27)

| Zone | Real path | Files (measured) | Role (one sentence) | Members |
|---|---|---:|---|---|
| apps | `apps/` | 4,576 | Five runnable application packages: web UI, daemon server, desktop Electron, packaging runtime, content distributable. | `apps/web` (m01), `apps/daemon` (m02), `apps/desktop` (m05), `apps/packaged` (m08), `apps/closure` (m27) |
| packages | `packages/` | 488 | Sixteen shared TS libraries typed `@open-design/*` (contracts, IPC, process primitives…) — where the "pure-TS" part of the platform lives. | m04, m09, m10, m11, m13, m15, m17, m18, m19, m20, m21, m22, m23, m24, m25, m26 |
| tools | `tools/` | 296 | Four build/release/dev/serve CLIs (`tools-pack`, `tools-release`, `tools-dev`, `tools-serve`). | m06, m07, m12, m14 |
| shells | `shells/` | 44 | Alternative GUI-less shell runtime — currently terminal only, plain `.mjs` plus hand-written `.d.mts`. | `shells/terminal` (m16) |
| e2e | `e2e/` | 388 | Playwright E2E (ui/, specs/) plus architecture-guard tests (scripts/). | m03 |

Measured: `for d in apps packages tools shells e2e; do find $d -type f | wc -l; done` → 4576 / 488 / 296 / 44 / 388 (matches the cartography numbers one-for-one). Members measured with `ls apps packages tools shells` → apps: closure, daemon, desktop, packaged, web; packages: 16 dirs matching the checklist; tools: dev, pack, release, serve; shells: terminal. **Cross-check: 5 apps + 16 packages + 4 tools + 1 shells + 1 e2e = 27 = universe size, exact match.**

### 1b. Corpus / data / docs zones (outside the workspace)

| Zone | Real path | Files | Role (one sentence) |
|---|---|---:|---|
| design-systems | `design-systems/` | 1,750 | Corpus of 151 portable design-system packages (airbnb, ant, apple, airtable… + `_schema/`), composed into agent prompts. |
| plugins | `plugins/` | 1,296 | Plugin corpus: `_official/` (daemon scans + registers at startup), `community/`, `registry/`, `spec/`. |
| skills | `skills/` | 301 | Agent skill corpus (one directory per skill: `agent-browser`, `ad-creative`, `algorithmic-art`…). |
| design-templates | `design-templates/` | 271 | Design template corpus (one directory per template: `dashboard`, `blog-post`…). |
| prompt-templates | `prompt-templates/` | 106 | Prompt templates for image/video. |
| specs | `specs/` | 107 | Internal design specs (`current/`, `change/`, date directories `2026-04-29-live-artifacts`). |
| docs | `docs/` | 182 | Project documentation. |
| clipper | `clipper/` | 48 | Browser extension ("clipper": manifest-style `background.js`, `content.js`, `_locales/`, `capture.js`). |
| figma-plugin | `figma-plugin/` | 5 | Figma plugin (`manifest.json`, `code.js`, `ui.html`, `IR.md`). |
| mocks | `mocks/` | 6 | Golden mocks + `manifest.json`. |
| charts | `charts/` | 11 | Helm chart deployment. |
| deploy | `deploy/` | 4 | Deployment configuration. |
| craft | `craft/` | 13 | "Craft" guides (color.md, laws-of-ux.md, anti-ai-slop.md…). |
| story | `story/` | 2 | Overall story (`STORY.md` + `zh-CN` variant). |
| templates | `templates/` | 5 | `live-artifacts` template. |
| ui-audit | `ui-audit/` | 1 | UI audit (goal66). |
| assets | `assets/` | 9 | Static assets (community-pets, frames). |
| data | `data/` | 2 | Static data (`contributors.json`, `plugin-previews`). |
| scripts | `scripts/` | 47* | Root scripts: guard, check-*, bake-*, postinstall (only visible via `git ls-tree` — see the reconciliation note in 1c). |

Corpus role evidence: `File: plugins/README.md | Content: "_official/ - first-party plugins bundled with OpenDesign. The daemon scans this tree at startup and registers these plugins as official."`; `File: design-systems/README.md | Content: "Each subfolder is a portable design-system package. … The bundled catalog currently contains **151 packages**."`

### 1c. Reconciliation note vs the cartography (transparency)

- The cartography lists `scripts/ — 1 files`: that is an artifact of the
  sparse basis (the `*.ts` glob is not in the sparse set). The real PIN tree
  holds **47 files** — `Measured: git ls-tree --name-only HEAD scripts/ | wc
  -l` → 47 (including `scripts/check-ts-nocheck-imports.ts`, confirmed to
  exist via `git ls-tree --name-only HEAD scripts/check-ts-nocheck-imports.ts`).
- The cartography census table reads "apps 4 / packages 9 / tools 5 / shells
  ≥2 / total 26": that 26-item table does not match the real directories;
  the source of truth is the 27-item checklist and the real directory
  listings (5/16/4/1/1 = 27, matching 27/27 as in 1a). This does not affect
  the cartography's overall conclusion (a pnpm monorepo).

## 2. Representative inner structure: `apps/web` (m01 `@open-design/web` — the largest item: 2,205 files / 877,858 LOC)

`apps/web` splits **entry → source → tests → sidecar** into 4 separate zones, each with its own config:

```
apps/web/
├── app/                  # Next.js App Router entry — THIN SHELL
│   ├── layout.tsx
│   └── [[...slug]]/{page.tsx, client-app.tsx}   # mounts ClientApp
├── src/                  # MAIN CODE — component tree, NOT the app router
│   ├── App.tsx           # root component tree
│   ├── components/ (521) # UI components + *.module.css
│   ├── runtime/ (108)    # web runtime (chat, runs…)
│   ├── collab/ (36), analytics/ (25), i18n/ (40), styles/ (47),
│   │   observability/ (23), lib/ (23), utils/ (19), state/ (17),
│   │   providers/ (17), artifacts/ (14), hooks/ (13), onboarding/ (7)…
│   └── router.ts         # client router reads window.location
├── tests/                # 1,434 files — CENTRALIZED TESTS, mirrors src/
│   ├── App.test.ts, analytics/, artifacts/, campaigns/, collab/, runtime/…
│   └── setup/, fixtures/ # helpers/fixtures (29 files not matching *.test.*)
├── sidecar/              # web-side sidecar ({index,server}.ts)
├── public/               # static
├── tsconfig.json         # strict + noUncheckedIndexedAccess, moduleResolution bundler
├── tsconfig.build.json / tsconfig.sidecar.json   # 2 separate build configs
├── vitest.config.ts / next.config.ts / postcss.config.mjs
└── package.json          # "@open-design/web", next dev --turbopack
```

**Main code vs tests — measured on the PIN:**
- `src/` + `app/` + `sidecar/`: zero co-located test files — `Measured: find apps/web/src -name '*.test.*' -o -name '*.spec.*' | wc -l` → **0**; stories also 0.
- `tests/`: 1,434 files, of which 1,405 match `*.test.*` and 29 are helpers/fixtures (`Measured: find apps/web/tests -name '*.test.*' | wc -l` → 1405; `! -name '*.test.*'` → 29). The module map counts m01 `tests=1421` under the basis "ts/tsx in tests/ OR *.test.*" — the delta is a basis difference, not a contradiction (the 29 others include both .ts helpers and .json/.html fixtures).
- 1-1 name mirroring: `File: apps/web/src/analytics/agent-detect.ts` ↔ `File: apps/web/tests/analytics/agent-detect.test.ts` (same basename + `.test`); likewise `amr-attribution.ts` ↔ `amr-attribution.test.ts`.
- The role of `app/` is a thin shell, not logic — `File: apps/web/app/[[...slug]]/page.tsx | Line: 1,3-6 | Content: "import { ClientApp } from './client-app';\n\n// The whole product is a client-driven SPA: project IDs and file paths are\n// unbounded user input, so we route every URL through this single optional\n// catch-all and let the existing client router (src/router.ts, which reads\n// window.location at runtime) decide what to render."`
- Largest file: `File: apps/web/src/components/FileViewer.tsx | Measured: wc -l → 20759` (matches the module map: "20,759 lines — largest file in the repo").
- Toolchain: `File: apps/web/package.json | Content: "name": "@open-design/web", "dev": "next dev --turbopack", "build": "next build && tsc -b --noEmit", "test": "vitest run -c vitest.config.ts --maxWorkers=2"` — matches the module map note 7 (Next.js toolchain but an App.tsx component tree, no app-router product logic).

## 3. Naming conventions readable from the code (6 examples, each with ≥2 real samples)

1. **React component = PascalCase `.tsx` + same-named CSS module**: `apps/web/src/components/` contains the pairs `AgentDiagnosticRow.tsx` + `AgentDiagnosticRow.module.css`, `AmrBalanceDialog.tsx` + `AmrBalanceDialog.module.css`, `BrandEnrichmentBanner.tsx` + `BrandEnrichmentBanner.module.css` (`Measured: ls apps/web/src/components`).
2. **Hook = `use*.ts` camelCase**: `apps/web/src/hooks/`: `useAnchoredPopover.ts`, `useCoalescedCallback.ts`, `useDismissOnOutsideInteraction.ts`, `useProjectDetail.ts` (same pattern in `src/collab/`: `useCollab.ts`, `useProjectCollab.ts`).
3. **Ordinary module = kebab-case `.ts`**: `apps/daemon/src/`: `agent-session-resume.ts`, `api-token-auth.ts`, `amr-stderr-filter.ts`; `packages/contracts/src/`: `amr-endpoint-binding.ts`, `comment-target-title.ts`, `execution-profile.ts`.
4. **Test = `<module>.test.ts(x)`, placed in the mirrored `tests/` tree, with behavior sub-suffixes**: `tests/collab-client.test.ts`, `tests/collab-client.content-update.test.ts`, `tests/collab-client.heartbeat-backoff.test.ts` (ls apps/web/tests) — tests are NOT co-located with source (count is 0, section 2).
5. **Barrel `index.ts` in every package**: `packages/contracts/src/index.ts`, `packages/sidecar/src/index.ts` (barrel types — m09), `tools/pack/src/index.ts` (ls).
6. **Package name = directory name, prefixed `@open-design/`**: `File: packages/contracts/package.json | Content: "name": "@open-design/contracts"` (dir `packages/contracts`); all 27/27 checklist items follow this pattern.
7. (Structure bonus) **Every zone has its own `AGENTS.md` describing the zone**: `apps/AGENTS.md`, `packages/AGENTS.md`, `tools/AGENTS.md`, `shells/AGENTS.md`, `e2e/AGENTS.md`; outside the workspace also `skills/AGENTS.md`, `plugins/AGENTS.md`, `design-templates/AGENTS.md` (ls of each dir).

## 4. Deviations from strict TypeScript conventions (each with ≥2 real examples — nothing invented)

### 4.1 `@ts-nocheck` in production code (the largest deviation, concentrated in the daemon)

- Config stays maximally strict: `File: apps/daemon/tsconfig.json | Line: 6-9 | Content: "moduleResolution": "NodeNext", "strict": true, "noUncheckedIndexedAccess": true, "exactOptionalPropertyTypes": true` — but **30 files in `apps/daemon/src`** (production) and 11 test files begin with `// @ts-nocheck`, disabling all type checking for that file: `Measured: grep -rl '@ts-nocheck' apps/daemon/src --include='*.ts' | wc -l` → 30; `…/tests` → 11.
- Examples (≥2): `File: apps/daemon/src/server.ts | Line: 1 | Content: "// @ts-nocheck"` (18,962 lines — the daemon's largest file, m02); `File: apps/daemon/src/cli.ts | Line: 2 | Content: "// @ts-nocheck"` (12,979 lines); plus `apps/daemon/src/projects.ts:1`, `apps/daemon/src/agents.ts:1`, and the whole `apps/daemon/src/brands/engine/**` cluster (17 files — `Measured: grep -rl '@ts-nocheck' apps/daemon/src/brands/engine --include='*.ts' | wc -l` → 17).
- The repo SELF-DECLARED this deviation and ships a dedicated guard: `File: scripts/check-ts-nocheck-imports.ts | Line: 9-17 | Content (via git show HEAD): "// `// @ts-nocheck` disables *all* type checking for a file, including TS2307 … That is convenient for large legacy modules mid-refactor, but it silently hides broken relative imports … (A combined-barrel integration once shipped 51 such dead imports across server.ts / cli.ts / start-chat-run.ts, all masked by @ts-nocheck.)"` — the guard forces every relative import inside a nocheck file to resolve to a real module; the guard's test: `File: e2e/tests/scripts/check-ts-nocheck-imports.test.ts | Line: 8-15 | Content: import … } from "../../../scripts/check-ts-nocheck-imports.ts"; test("hasLeadingTsNocheck detects a leading pragma…")`.
- Internal contrast: web (m01) and the 16 packages have **0** nocheck files; e2e has 3 (`e2e/tests/server-identifier-scope.test.ts`, `e2e/tests/scripts/check-ts-nocheck-imports.test.ts`, `e2e/resources/fake-acp-handshake-cli.ts`). → the deviation is **per-app**, not a repo-wide standard.

### 4.2 Two module/ESM schools inside one monorepo

- daemon: NodeNext — relative imports **must carry the `.js` extension**: `File: apps/daemon/src/app-config.ts | Line: 26-27 | Content: "import { amrSettingsBindingConflict } from './integrations/amr-endpoint-binding.js'; import { expandHomePrefix } from './home-expansion.js';"`; measured globally: `grep -rE "from '\./.*\.js'" apps/daemon/src --include='*.ts' | wc -l` → **1418/1418** relative imports all have `.js`.
- web: bundler — relative imports **without extension**: `File: apps/web/src/router.ts | Line: 7 | Content: "import { navigationTiming, navigationPage, observeNavigation } from './observability/navigation-timing';"`; web `tsconfig.json` `"moduleResolution": "bundler"` (Line 11) vs daemon `"NodeNext"` (Line 6).
- Plain JS inside a TS repo: `shells/terminal/runtime/` is `.mjs` + hand-written declarations: `fossil.mjs`, `sidecar-host.mjs`, `fixture-shell-updater.mjs`, `fixture-lifecycle.mjs`, `sidecar-bootstrap.mjs` + `fixture-lifecycle.d.mts`, `fixture-shell-updater.d.mts` (ls shells/terminal/runtime) — matches m16 (10 .ts files, 9 of them tests; the actual running code is .mjs). Root `scripts/` also mixes `.mjs` (`scripts/bake-plugin-previews.mjs` in git ls-tree).

### 4.3 Mixed kebab-case vs camelCase file names in the SAME directory

- `packages/contracts/src/api/`: `ls … | xargs -n1 basename | grep -cE '^[a-z0-9-]+\.ts$'` → **55 kebab** vs `grep -cE '^[a-z]+[A-Z].*\.ts$'` → **7 camel** in the same directory. Camel examples: `amrWallet.ts`, `providerModels.ts`, `touchpointOffline.ts`, `touchpointTestRuntime.ts`, `reasoningExecution.ts`, `commentPreparation.ts`, `connectionTest.ts`; alongside kebab: `agent-sessions.ts`, `amr-auth.ts`, `app-config.ts`, `artifacts.ts`.
- The daemon repeats the pattern: `apps/daemon/src/connectionTest.ts` (camel) sits next to `apps/daemon/src/api-token-auth.ts` (kebab).
- Honest classification note: 111 `.ts` files contain uppercase in their names (find packages/*/src apps/*/src) — most are hooks `use*.ts` (convention 2, intentional) and locale files `content.es-ES.ts`; the genuine deviation is the `contracts/src/api/*` group + `connectionTest.ts` above.
- `@ts-expect-error` is rare: **7 files repo-wide** — web 3 (`apps/web/tests/components/touchpoint-lifecycle.test.ts`, `MemorySection.test.tsx`, `MemorySection.extraction-state-honesty.test.tsx`), daemon 1 (`apps/daemon/tests/runtimes/claude-stream-per-request-usage.test.ts`), packages 2 (`packages/contracts/tests/deck-protocol.test.ts`, `share-publish-link.test.ts`), packaged 1 (`apps/packaged/src/protocol.ts`) — `Measured: grep -rl '@ts-expect-error' apps packages tools e2e shells clipper figma-plugin scripts --include='*.ts' --include='*.tsx'`. All but `apps/packaged/src/protocol.ts` are test files; not a systemic deviation, just recorded.

### 4.4 No root `tsconfig.json` — strictness distributed per package

- No tsconfig at the root (`Measured: ls tsconfig*` at root → empty). `File: package.json (root) | Content: "typecheck": "pnpm -r --workspace-concurrency=4 --if-present run typecheck && tsc -p scripts/tsconfig.json --noEmit"` → typecheck aggregates N package configs.
- Visible consequences: web enables `strict` + `noUncheckedIndexedAccess` but NOT `exactOptionalPropertyTypes` (`apps/web/tsconfig.json:11-14`), daemon enables all three (`apps/daemon/tsconfig.json:6-9`); web adds `paths: {"@/*": ["./*"]}`, daemon has no paths. Each app has its own micro-standard (quoted in 4.1/4.2).
- The daemon also splits prod/test typecheck: `File: apps/daemon/package.json | Content: "typecheck": "pnpm --filter @open-design/contracts build && pnpm --filter @open-design/registry-protocol build && tsc -p tsconfig.json --noEmit && tsc -p tsconfig.tests.json --noEmit"` (2 tsconfigs: `tsconfig.json`, `tsconfig.tests.json` — ls apps/daemon).

## 5. Suggested reading order — what to read first, and why

1. **`pnpm-workspace.yaml` + root `package.json`** — establishes the boundary: only 5 globs are workspaces; every other directory (design-systems, skills, plugins…) is **data** for the agent, not code to build.
2. **`<zone>/AGENTS.md` (apps, packages, tools, shells, e2e)** — the repo writes its own orientation docs per zone; reading these 5 files is far cheaper than exploring 27 packages blind.
3. **`packages/contracts/src/index.ts`** — the web/daemon boundary contract is the dependency-graph hub (m04: 8 packages import contracts); understanding contracts first keeps you from getting lost in types when reading web/daemon.
4. **`apps/daemon/src/server.ts` + `src/routes/`** — the "brain" (HTTP routes, collab, runs); know in advance that it is `@ts-nocheck` (4.1) so un-checked types don't surprise you; navigate by the route map, don't read 18,962 lines linearly.
5. **`apps/web/src/App.tsx` + `src/router.ts`, then `app/[[...slug]]/page.tsx`** — understand that the real entry is the SPA component tree; `app/` is only the Next shell (quoted in section 2). Find components in `src/components/` (521 files, incl. `FileViewer.tsx`, 20,759 lines).
6. **Spine runtime: `packages/platform` → `packages/sidecar` → `packages/sidecar-proto` → `packages/launcher-proto`** — the process/IPC foundation for daemon + desktop + packaged; read in dependency order (m09 depends on m10; m17 is a single 1,198-line `src/index.ts`, quick to read).
7. **`e2e/tests/scripts/check-*` guard tests** — the "executable architecture rules": whatever convention the repo takes seriously has a guard test (nocheck-imports, cross-app-imports); use them as a checklist when changing code.
8. **Corpus (`design-systems/`, `skills/`, `plugins/`, `design-templates/`)** — read only each corpus's `README.md` + `_schema`/manifest; do not walk the files (1,750/301/1,296/271 files are data, not code).

The order above follows dependencies (contracts before apps) plus "rules
before code" (AGENTS.md, guard tests), optimized for a newcomer approaching
a 27-package repo.
