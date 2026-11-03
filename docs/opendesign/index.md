---
subject: nexu-io/open-design
measured_at: 5a0c47777975ddb91d09c1c16b423a3ef74bf572
status: final
---


# open-design — reading order


Start with [`matrix/matrix.csv`](../../matrix/matrix.csv) (the index: 27
TypeScript pnpm workspace packages with ratings and locations), then read
the docs in this order:


1. `01-cartography.md` — repository census: manifests and toolchain, measured
   zone sizes, top-level directories, build/test evidence, license.
2. `02-module-map.md` — the module map: responsibility, dependencies in both
   directions, measured size, and star rating for each of the 27 workspace
   packages.
3. `03-c4/` — architecture source: `workspace.dsl` (Structurizr DSL,
   machine-validated: structurizr-cli validate exit 0, all 5 views exported),
   covering 40 elements and 50 relationships across the system-context,
   container and component views, with an evidence comment on every element
   and relationship.
4. `04-overview.md` — the narrative overview of how the system works, with
   real install/build evidence taken at the pin (`pnpm install
   --frozen-lockfile` and `pnpm -r build` both exit 0).
5. `05-folders.md` — directory zones, the `apps/web` deep dive, naming
   conventions, and deviations from strict TypeScript conventions.
6. `06-flows.md` — the three most churn-heavy runtime flows on the pinned
   tree, with per-step call-site evidence.
7. `07-usage.md` — hands-on recipes: 24 use cases across the 8 highest-rated
   packages, each with API evidence.


## Extracts


All 27 workspace packages are extracted verbatim under
`modules/opendesign/@open-design/` (5,228 `.ts`/`.tsx` files, 1,836,056
lines by the per-file census convention), each with a `PROVENANCE.md`
recording the upstream commit (`5a0c4777`), path, license (Apache-2.0), and
measured size. Extracts are byte-identical to upstream at the pin —
verified per-file by hash/diff. The harvest record and re-sync rule live in
[`tracking/opendesign.md`](../../tracking/opendesign.md).


## Measurement note


Every number in this documentation set was measured on the pinned tree
`5a0c47777975ddb91d09c1c16b423a3ef74bf572` (branch `main`, commit
"fix(web): hide Labs settings when no experiments are available (#9076)",
2026-11-02). The pin was still upstream `main` HEAD at publish time, so the
tracking badge is FRESH. Ratings in `matrix.csv` and `02-module-map.md`
come from an oracle-based star ranking (5 mechanical signals S1–S5 with
fixed thresholds and a hard cap of three 5-star items per repository): the
three 5-star packages are `@open-design/contracts`, `@open-design/sidecar`
and `@open-design/sidecar-proto`.
