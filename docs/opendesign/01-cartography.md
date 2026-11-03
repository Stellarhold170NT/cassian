---
subject: nexu-io/open-design
measured_at: 5a0c47777975ddb91d09c1c16b423a3ef74bf572
status: final
---

# Cartography

**open-design** (nexu-io) is a TypeScript pnpm monorepo — an open-source
design agent platform (web app + desktop/daemon + plugin runtime + tools).
This document is the repository census for the pinned tree
`5a0c47777975ddb91d09c1c16b423a3ef74bf572` (branch `main`, sparse-checkout
clone `--filter=blob:limit=1m` limited to `apps packages tools shells e2e
clipper figma-plugin` + docs/config globs).

## Manifests and toolchain

- **Root package**: `open-design` (`package.json`), **pnpm@10.33.2**,
  Node `~24` (`engines`), workspaces per `pnpm-workspace.yaml`:
  `packages/*`, `apps/*`, `tools/*`, `shells/*`, `e2e`.
- **Overrides**: 10 pinned transitive deps (brace-expansion 5.0.6, devalue
  5.8.1, fast-uri 5.8.1→, hono 4.12.19, ip-address 10.2.0, postcss 8.5.15,
  protobufjs 6.15.2→, qs 6.15.2, tmp 0.2.7, yaml 2.9.0).
- **onlyBuiltDependencies**: better-sqlite3, core-js, electron,
  electron-winstaller, esbuild, onnxruntime-node, protobufjs, sharp.
- **Task runner**: `mise.toml` at root; deployment: `vercel.json`, `charts/`
  (Helm), `deploy/`.

## Measured census (PIN tree, sparse subset)

| zone | workspace packages | ts/tsx files | ts loc |
|---|---|---|---|
| apps | 4 | ~4,202 | ~1,592,000 |
| packages | 9 | ~340 | ~80,000 |
| tools | 5 | ~215 | ~44,000 |
| shells | ≥2 | ~10+ | ~2,000+ |
| e2e | ≥1 | — | — |
| **total** | **26** | **4,843** | **1,718,999** |

The 27-item universe (unit = pnpm workspace package, cap of 200 items) is
listed in [`02-module-map.md`](02-module-map.md) with per-package file/loc
counts. Largest items: `@open-design/web` (2,205 files / 877,858 loc),
`@open-design/daemon` (1,854 / 669,678), `@open-design/contracts`
(251 / 52,859), `@open-design/desktop` (94 / 32,459).

## Top-level directories

- `apps/` — 4576 files
- `packages/` — 488 files
- `tools/` — 296 files
- `shells/` — 44 files
- `e2e/` — 388 files
- `design-systems/` — 1750 files
- `design-templates/` — 271 files
- `docs/` — 182 files
- `scripts/` — 1 files

- plus `assets/`, `craft/`, `data/`, `plugins/`, `prompt-templates/`,
  `story/`, `templates/`, `ui-audit/`, `vercel.json`, `mise.toml`,
  `pnpm-lock.yaml`, `pnpm-workspace.yaml` and top-level docs
  (`AGENTS.md`, `CLAUDE.md`, `CONTEXT.md`, `QUICKSTART.md`, `README.md`, …).

## Build/test evidence

- Package manager: pnpm 10 (`packageManager` field) — `pnpm install`,
  `pnpm -r build`, `pnpm -r test` per workspace convention.
- Sparse-checkout clone verified: `git rev-parse HEAD` =
  `5a0c47777975ddb91d09c1c16b423a3ef74bf572` on branch `main`.

## License

- **Apache-2.0** — declared at `package.json:8` (`"license": "Apache-2.0"`);
  the `LICENSE` file exists in the full git tree and begins with the
  Apache License 2.0 text; recorded per module in
  `modules/opendesign/*/PROVENANCE.md` at extraction time.

## Corrections (from the folder-structure audit)

1. The zone table above records 26 workspace packages because it was
   measured on a partial sparse subset; the authoritative universe is the
   27-item module map (5 apps + 16 packages + 4 tools + 1 shell + e2e =
   27), which matches the real directory listings exactly — see
   [`05-folders.md`](05-folders.md), section "Workspace zones".
2. `scripts/ — 1 files` above is an artifact of the same sparse glob set:
   the full PIN tree holds 47 files under `scripts/`
   (`git ls-tree --name-only HEAD scripts/ | wc -l` = 47).
