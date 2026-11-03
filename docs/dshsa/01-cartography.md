---
subject: deepseek-ai/dsh-superagent-prototype
measured_at: 8c32a9dc5d72c033816c6a8110b37f40cf94fba4
status: final
---

# Cartography

**dsh-superagent** (deepseek-ai) is a TypeScript research prototype —
"a proactive coding agent for one GitHub repository, as a DSH (DeepSeek
Harness) bundle: it listens to GitHub and optionally Feishu, evaluates
requests under a Policy, turns authorized ones into Tickets, and executes
each in its own DSH Session" (`package.json` description, verbatim). The
README labels it "Research prototype for reference only, not an official
DeepSeek product" (`README.md:3`). This document is the repository census
for the pinned tree `8c32a9dc5d72c033816c6a8110b37f40cf94fba4` (branch
`main`).

## Clone

Shallow clone (`--depth 100 --single-branch`) resolves to exactly one
commit: `8c32a9dc…` "feat: add the dsh-superagent research prototype"
(2026-10-31 20:06:31 +0800), `git rev-list --count HEAD` = 1. The tree
holds 216 files.

## Manifests and toolchain

- **Root package**: `dsh-superagent` 0.1.0, `private: true`, `type: module`,
  **MIT** (`package.json`); main `lib/index.js`; exports `.` (lib/index.js),
  `./client` (browser panel bundle), `./github-watch`, `./feishu-watch`
  (standalone watcher plugins) and `./locale/*.json`.
- **Task scripts**: `build` = tsdown, `typecheck` = `tsc --noEmit`,
  `test` = `vitest run`, `check` = typecheck + test + build.
- **Toolchain**: `packageManager` pnpm@11.7.0; `engines` node
  `^22.19.0 || >=24.0.0` and `dsh ^0.2.1-alpha.2`; TypeScript 6.0.3
  (target ES2024, NodeNext, `strict`, `noUncheckedIndexedAccess`,
  `verbatimModuleSyntax`, `allowImportingTsExtensions`), tsdown 0.22.14,
  vitest 4.1.8, react 18.3.1.
- **Runtime dependencies**: only `proper-lockfile@4.1.2` and `zod@4.4.3`.
- **Peer dependencies**: 23 entries on `@deepseek-ai/*` platform packages,
  nearly all pinned to the `0.2.1-alpha.2` alpha line (plus
  `@deepseek-ai/cordis@4.0.5-alpha.1`, `@deepseek-ai/schemastery@3.18.5-alpha.1`).
  Registry reachability outside DeepSeek's toolchain is an open question —
  see `04-overview.md`, "Run and harness".
- **Bundle layer**: `cordis.patch.yml` inserts three Cordis plugins
  (`dsh-superagent`, `dsh-superagent-github`, `dsh-superagent-feishu`)
  into a DSH profile; the client bundle is a CJS browser build loaded
  through the DSH module loader; `scripts/dsh-superagent` is a Python 3
  tmux service manager.

## Measured census (per-extension then sum)

Census formula: count files and lines per extension, then add —
never a single `wc -l` over the union.

| extension | files | lines |
|---|---:|---:|
| `.ts` | 147 | 25,388 |
| `.tsx` | 30 | 4,794 |
| **ts+tsx total** | **177** | **30,182** |

Supplementary extension histogram (informational): 28 `.md`, 4 `.json`,
2 `.yml`, 1 `.yaml`, 1 `.css`, 1 `.gitignore`, `LICENSE`, 1 extensionless
script. TypeScript is 100% of code LOC; tests live under `tests/` and are
counted in the same census.

## Entrypoints

- **Host plugin** — `src/index.ts`: exports `name`/`inject`/`Config` and
  `apply(ctx, config)`, which mounts the `Runtime` composition root and
  provides the host a restart callback for deployment account changes.
- **Client** — `src/client/index.tsx` → `lib/client.js` (CJS browser
  bundle), registering the panel into DSH web-client slots.
- **Watchers** — `src/sources/github.ts` → `lib/github-watch.js`;
  `src/sources/feishu.ts` → `lib/feishu-watch.js` (per tsdown entries;
  no `src/github-watch.ts` file exists — the exports mapping is resolved
  by the build config).
- **Build** — `tsdown.config.ts` (two config objects: node ESM entries +
  browser CJS client).

## Top-level directories

`docs/` (numbered reading path 000–008), `examples/`, `locale/`,
`prompts/` (incl. `team/`), `scripts/`, `skills/`
(`dsh-superagent-github`, `dsh-superagent-feishu`), `src/`, `tests/`
(incl. `fixtures/`), plus root manifests and docs.

`src/` zone file counts: `app/` 38, `client/` 27, `core/` 15,
`executor/` 2, `infra/` 5, `sources/` 16, and 8 root `.ts` files
(`index.ts`, `admission.ts`, `deployment.ts`, `kv.ts`, `limits.ts`,
`navigation.ts`, `policy.ts`, `setup.ts`) — see
[`05-folders.md`](05-folders.md) for the full zone breakdown.

## Build/test evidence

- `pnpm install --frozen-lockfile && pnpm typecheck && pnpm test` is the
  repository's own check path (`package.json` scripts; vitest include
  `tests/**/*.spec.{ts,tsx}`).
- **Executed in the mining sandbox: SKIPPED — honestly.** The sandbox
  image is git-only (no node/pnpm/npm); no build or test output is
  fabricated anywhere in this documentation set. Prerequisites and the
  operational harness are documented in [`04-overview.md`](04-overview.md).
- Statically verified on the clone at the pin: 59 spec files counted
  (48 `*.spec.ts` + 11 `*.spec.tsx`), matching the module map exactly.

## License

**MIT** — `LICENSE:1` "MIT License", `LICENSE:3` "Copyright (c) 2026
DeepSeek Harness Team"; `package.json` declares `"license": "MIT"`.
Recorded per module in `modules/dshsa/*/PROVENANCE.md` at extraction time.

## Verification note

- The documentation destination (this repository) was verified read-only
  before publishing: a `git ls-remote` of the target succeeded from the
  census clone; no push was performed by the mining nodes.
- Credential hygiene at census time: no credential-shaped strings in the
  clone; the remote URL is clean of credentials.
