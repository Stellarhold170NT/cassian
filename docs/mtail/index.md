---
subject: google/mtail
measured_at: 4c7e0e1174ac1ead032efe28d86428bbbe0ae145
status: final
---


# mtail — reading order

Start with [`matrix/matrix.csv`](../../matrix/matrix.csv) (the index: 18 Go
packages with ratings and locations), then read the docs in this order:

1. `01-cartography.md` — repository census: manifests, entry points,
   directories, measured sizes, license, build/test evidence.
2. `02-module-map.md` — the 18-item module map: responsibility, dependencies,
   measured size, and star rating per package.
3. `03-c4/` — architecture source: `workspace.dsl` (Structurizr) and
   `diagrams.mmd` covering context, container, and component views.
4. `04-overview.md` — the narrative overview of how mtail works, with real
   build/test evidence on the pin.
5. `05-folders.md` — directory zones, package deep dives, naming conventions.
6. `06-flows.md` — the three most churn-heavy data flows on the pinned tree.
7. `07-usage.md` — 24 use cases (3 per item) with API evidence.

## Extracts

All 18 packages are extracted verbatim under `modules/mtail/<package>/`
(193 files, 26,304 LOC total), with per-item `PROVENANCE.md` recording the
upstream commit (`4c7e0e11`), path, license (Apache-2.0), and measured size.
Extracts are byte-identical to upstream at the pin — verified per-file by
hash (18/18 diff_clean). The harvest commit and re-sync rule live in
[`tracking/mtail.md`](../../tracking/mtail.md).

## Measurement note

Documentation statistics (census, module sizes, ratings, flow traces, use
cases) were measured on the upstream tree at the pin itself:
`4c7e0e1174ac1ead032efe28d86428bbbe0ae145` (2026-02-26, "Merge pull request
#999 from google/lsc-1771431274.9704435"). Every cited path and line resolves
at that commit. Real build/test evidence on the pin: `go build ./...` and
`go test ./...` (655/663, single environment-sensitive socket-timing case) —
see `04-overview.md`.
