---
subject: google/mantis
measured_at: 1e15346c2ca2d6e7db57ced59615bb9d1685992f
status: final
---


# mantis — reading order

Start with [`matrix/matrix.csv`](../../matrix/matrix.csv) (26 items with
ratings and locations), then read the docs in this order:

1. `01-cartography.md` — repository census: skills suite + ADK reference
   harness, toolchain (python3, pytest), source layout, license.
2. `02-module-map.md` — the 26-item module map: 20 `mantis-*` skills plus
   6 harness zones (reference-core/evals/scripts/tools/root, action,
   schema-contract), responsibility, dependency edges, measured size, and
   star rating per item.
3. `03-c4/workspace.dsl` + `03-c4/diagrams.mmd` — architecture model
   (Structurizr DSL).
4. `04-overview.md` — narrative overview of how Mantis works end to end,
   with build/test evidence on the pin.
5. `05-folders.md` — directory zones, deep dives, verified deviations.
6. `06-flows.md` — the most churn-heavy data flows on the pinned tree.
7. `07-usage.md` — use cases (3 per item) with code evidence.

## Extracts

All 26 items are extracted verbatim under `modules/mantis/<item>/`
(142 substantive files, 69,730 LOC measured at the pin) with per-item
`PROVENANCE.md` recording the upstream commit (`1e15346c`), path, and
measured size. The harvest commit and re-sync rule live in
[`tracking/mantis.md`](../../tracking/mantis.md).

## Measurement note

All statistics were measured on the upstream tree at the pin itself:
`1e15346c2ca2d6e7db57ced59615bb9d1685992f` (branch `main`, 2026-11-02
merge on AUTO_UPDATE fix). Every cited path and line resolves at that
commit. Rating: ★5 = `mantis-reproduce`, `reference-evals`,
`schema-contract`; slot A extraction target = `mantis-architecture` (★4),
slot B = `mantis-calibrate` (★4).
