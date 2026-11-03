# PROVENANCE — @open-design/tools-serve

- upstream: nexu-io/open-design (branch `main`)
- upstream_sha: 5a0c47777975ddb91d09c1c16b423a3ef74bf572
- upstream_path: `tools/serve`
- manifest_id: m14
- extracted_at: 2026-11-03T08:34:48Z
- license: Apache-2.0 — the root `LICENSE` at upstream_sha is the Apache License, Version 2.0 text, and `package.json` declares `"license": "Apache-2.0"`.
- generator: goldmine v16 opendesign p7_cut
- re-sync: per `tracking/opendesign.md` — FRESH while upstream `main` HEAD == upstream_sha; STALE ("HEAD moved") otherwise; re-sync is an explicit decision, not automatic.

## Measured census (copied tree, md5 byte-identical to upstream_sha)

| metric | manifest expected | measured |
|---|---|---|
| files (census basis `.ts`+`.tsx`, directory-name prune `node_modules`/dist/build/.next/coverage) | 11 | 11 |
| LOC (`wc -l`, per-extension then summed) | 2394 (checklist, +1/file convention) | 2383 |
| files copied (all extensions, full `tools/serve` tree) | — | 18 |

Note: measured LOC counts newline characters (`cat | wc -l`); the checklist census adds one per file, so `measured + files = expected` (2383 + 11 = 2394). All 18 copied files are md5-identical to the upstream tree at upstream_sha (0 mismatches).
