---
subject: apache/kafka
measured_at: aa62a433553c14866521bd40ff446b6920d4d67e
status: final
---

# kafka — reading order

Start with `matrix/matrix.csv` (the index: 66 gradle modules with ratings and
locations), then read the docs in this order:

1. `01-cartography.md` — repository census: manifests, entry points, top-level
   directories, measured sizes.
2. `02-module-map.md` — the module map: responsibility, public entry points,
   dependencies (`depends_on` / `depended_by`), measured size for each of the
   66 modules.
3. `03-c4/` — architecture sources: `diagrams.mmd` (mermaid) and
   `workspace.puml` (PlantUML) covering context, container, and component views.
4. `04-overview.md` — the narrative overview of how the system works.
5. `05-stars.md` — module ratings from the measured rubric.
6. `06-flows.md` — the high-value data flows on the pinned tree.

## Extracts

All 66 modules are extracted verbatim under `modules/kafka/<module>/`, each
with a `PROVENANCE.md` recording the upstream commit (`aa62a433`), path,
license, and measured size. Extracts are byte-identical to upstream at the
pin — verified with a full `diff -r` sweep. The harvest record and re-sync
rule live in `tracking/kafka.md`.

## Language note

Subject documentation is currently written in Vietnamese; an English revision
is in progress.
