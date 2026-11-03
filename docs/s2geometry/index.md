---
subject: google/s2geometry
measured_at: 677c8cebcff11ba11accc0b02005bc214e06e9fd
status: final
---


# s2geometry — reading order

Start with [`matrix/matrix.csv`](../../matrix/matrix.csv) (61 C++ items with
ratings and locations), then read the docs in this order:

1. `01-cartography.md` — repository census: build system (CMake ≥3.18,
   C++17), directories, measured sizes, license, build/test evidence.
2. `02-module-map.md` — the 61-item module map: responsibility, dependency
   edges, measured size, and star rating per item.
3. `03-c4/` — architecture source: `workspace.dsl` (Structurizr) and
   `diagrams.mmd`.
4. `04-overview.md` — narrative overview of how S2 geometry works, with
   build/test evidence on the pin.
5. `05-folders.md` — directory zones, deep dives, naming conventions, and
   verified deviations from C++ conventions.
6. `06-flows.md` — the most churn-heavy data flows on the pinned tree.
7. `07-usage.md` — use cases (3 per item) with code evidence.

## Extracts

All 61 items are extracted verbatim under `modules/s2geometry/<item>/` with
per-item `PROVENANCE.md` recording the upstream commit (`677c8ceb`), path,
license (Apache-2.0), and measured size. Extracts are byte-identical to
upstream at the pin. The harvest commit and re-sync rule live in
[`tracking/s2geometry.md`](../../tracking/s2geometry.md).

## Measurement note

All documentation statistics were measured on the upstream tree at the pin
itself: `677c8cebcff11ba11accc0b02005bc214e06e9fd` (branch `master`). Every
cited path and line resolves at that commit. The 61-item universe sums to
0 LOC across the mapped items. Ratings: top items reach 3★
(), the large core family is capped by
dependency breadth.
