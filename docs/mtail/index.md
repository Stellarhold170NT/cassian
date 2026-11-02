---
subject: google/mtail
measured_at: 4c7e0e1174ac1ead032efe28d86428bbbe0ae145
status: final
---




# mtail — reading order




Start with [`matrix/matrix.csv`](../../matrix/matrix.csv) (the index: 18 Go
packages with ratings and locations), then read the docs in this order:




1. `01-cartography.md` — repository census: license gate, manifests, entry
   points, top-level directories, measured sizes.
2. `02-module-map.md` — the module map: responsibility, dependencies, and
   measured size for each of the 18 Go packages.
3. `03-c4/` — architecture source: `workspace.dsl` (Structurizr DSL,
   hand-checked, not machine-validated) plus `diagrams.mmd`, the renderable
   Mermaid fallback covering the context, container, and component views.
4. `04-overview.md` — the narrative overview of how the system works, with
   real build/test evidence.
5. `05-folders.md` — directory zones, the compiler package deep dive, naming
   conventions, and deviations from Go conventions.
6. `06-flows.md` — the three most churn-heavy data flows on the pinned tree,
   with per-step call evidence.
7. `07-usage.md` — hands-on recipes: 24 use cases across the 8 reusable
   packages, each with API evidence.




## Extracts




All 18 packages are extracted verbatim under `modules/mtail/` (141 files,
26,896 lines of Go), each with a `PROVENANCE.md` recording the upstream
commit (`4c7e0e11`), path, license (Apache-2.0), and measured size. Extracts
are byte-identical to upstream at the pin — verified per-file by hash. The
harvest record and re-sync rule live in
[`tracking/mtail.md`](../../tracking/mtail.md).




## Measurement note




Documentation statistics (census, module sizes, ratings, flow traces, use
cases) were measured on the upstream tree at the pin itself:
`4c7e0e1174ac1ead032efe28d86428bbbe0ae145` (2026-02-26 09:59:36 -0800,
"Merge pull request #999 from google/lsc-1771431274.9704435"). Every cited
path and line resolves at that commit. Real build/test evidence on the pin:
`go build ./...` exits 0, and the test suite passes 655 of 663 cases under
Go 1.22.12 / linux/amd64 — the single failure is one load-sensitive
unix-socket integration subtest that exceeds its own 10 s budget in a
2-vCPU container, and 6 tests skip by design when run as root (see
`04-overview.md`).




The `rating` column in `matrix/matrix.csv` is a 1–5 reusability score
assigned during measurement (complexity, dependency position, test coverage,
API surface, and independence considered together). The two 4-star packages
`compiler` and `metrics` are the extraction candidates documented in
[`specs/mtail/`](../../specs/mtail/).
