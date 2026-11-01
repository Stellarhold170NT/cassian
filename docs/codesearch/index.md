---
subject: google/codesearch
measured_at: 74a12a911a79b901d1158c48d011b2da1b090fc9
status: final
---


# codesearch — reading order


Start with [`matrix/matrix.csv`](../../matrix/matrix.csv) (the index: 7 Go
packages with ratings and locations), then read the docs in this order:


1. `01-cartography.md` — repository census: license gate, manifests, entry
   points, top-level directories, measured sizes.
2. `02-module-map.md` — the module map: responsibility, dependencies, measured
   size, and rating for each of the 7 Go packages.
3. `03-c4/` — architecture sources: `diagrams.mmd` (Mermaid) and
   `workspace.dsl` (Structurizr DSL) covering the context, container, and
   component views.
4. `04-overview.md` — the narrative overview of how the system works, with
   real build/test evidence.
5. `05-folders.md` — directory zones, the `index` package deep dive, naming
   conventions, and deviations from Go conventions.
6. `06-flows.md` — the three most churn-heavy data flows on the pinned tree.
7. `07-usage.md` — hands-on recipes: three use cases per package with API
   evidence.


## Extracts


All 7 packages are extracted verbatim under `modules/codesearch/<module>/`,
each with a `PROVENANCE.md` recording the upstream commit (`74a12a91`), path,
license (BSD 3-Clause), and measured size. Extracts are byte-identical to
upstream at the pin — verified per-file by hash. The harvest record and
re-sync rule live in [`tracking/codesearch.md`](../../tracking/codesearch.md).


## Measurement note


Documentation statistics (census, module sizes, ratings, flow traces, use
cases) were measured on the upstream tree at the pin itself:
`74a12a911a79b901d1158c48d011b2da1b090fc9` (2026-08-30, "index: slight
performance optimization"). Every cited path and line resolves at that commit.
Real build/test evidence on the pin: `go build ./...` and `go test ./...`
both exit 0 under go1.23.4 (see `04-overview.md`).
