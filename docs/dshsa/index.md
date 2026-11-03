---
subject: deepseek-ai/dsh-superagent-prototype
measured_at: 8c32a9dc5d72c033816c6a8110b37f40cf94fba4
status: final
---

# dsh-superagent — reading order

**dsh-superagent** is a research prototype of a proactive coding agent for one
GitHub repository, packaged as a DSH (DeepSeek Harness) bundle. Start with
[`matrix/matrix.csv`](../../matrix/matrix.csv) (the index: 7 TypeScript modules
with ratings and locations), then read the docs in this order:

1. `01-cartography.md` — repository census: manifests and toolchain, measured
   census by extension, entrypoints, top-level directories, license.
2. `02-module-map.md` — the module map: responsibility, dependencies in both
   directions (22 cross-checked edges), measured size, and star rating for
   each of the 7 modules.
3. `03-c4/` — architecture source: `workspace.dsl` (Structurizr DSL covering
   6 L1 elements, 8 containers, 19 components and 46 relationships, with an
   evidence comment on every element and relationship) plus `diagrams.mmd`
   (Mermaid fallback rendering L1, L2 and three L3 views). The DSL was
   hand-checked against the Structurizr grammar; running structurizr-cli
   validation was not possible in the mining sandbox (no Java) — disclosed
   instead of claimed.
4. `04-overview.md` — the narrative overview of how the system works, with an
   honest build/run note (the mining sandbox had no Node toolchain; commands
   and prerequisites are documented from the repository itself).
5. `05-folders.md` — directory zones, the `src/app` deep dive, naming
   conventions, and the two deliberate deviations from common TypeScript style.
6. `06-flows.md` — the three highest-scoring runtime flows (trigger → engine →
   worker → reply; panel ↔ loopback API ↔ store; worker-session turn loop),
   with per-step call-site evidence.
7. `07-usage.md` — hands-on recipes: 21 use cases across all 7 modules (3 per
   module), each with verbatim `File | Line | Content` API evidence.

## Extracts

All 7 modules are extracted verbatim under `modules/dshsa/m01..m07` — 111
files / 15,587 measured lines over all extensions (110 ts/tsx files /
15,205 lines by the TypeScript census; the difference is `client.css`),
each with a `PROVENANCE.md` recording the upstream commit (`8c32a9dc`),
path, license (MIT) and measured size. Extracts are byte-identical to
upstream at the pin — verified per-item by tree-hash comparison. The
harvest record and re-sync rule live in
[`tracking/dshsa.md`](../../tracking/dshsa.md).

## Measurement note

Every number in this documentation set was measured on the pinned tree
`8c32a9dc5d72c033816c6a8110b37f40cf94fba4` (branch `main`, single commit
"feat: add the dsh-superagent research prototype", 2026-10-31). The pin was
still upstream `main` HEAD at publish time, so the tracking badge is FRESH.
Ratings in `matrix.csv` and `02-module-map.md` come from an oracle-based
star ranking (5 mechanical signals S1–S5 with fixed thresholds and a hard
cap of three 5-star items per repository): the two 5-star modules are
`src/core` and `src/sources`. Because the repository has exactly one
commit, any future upstream `HEAD ≠ 8c32a9dc` means the repository was
replaced — re-run the measurement battery before reusing these numbers.
