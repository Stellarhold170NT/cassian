---
subject: google/jimfs
measured_at: 8fa098e0715aa492914285312c07e151d2aace4d
status: final
---


# jimfs — reading order


Start with [`matrix/matrix.csv`](../../matrix/matrix.csv) (the index: 1 Java
package with rating and location), then read the docs in this order:


1. `01-cartography.md` — repository census: license gate, manifests, entry
   points, top-level directories, measured sizes.
2. `02-module-map.md` — the module map: responsibility, dependencies, measured
   size, and rating for the single Java package `com.google.common.jimfs`.
3. `03-c4/` — architecture source: `workspace.dsl` (Structurizr DSL) covering
   the context, container, and component views — validated with
   structurizr-cli 2025.11.09 (no Mermaid fallback needed).
4. `04-overview.md` — the narrative overview of how the system works, with
   real build/test evidence.
5. `05-folders.md` — directory zones, the `com.google.common.jimfs` package
   deep dive, naming conventions, and deviations from Java conventions.
6. `06-flows.md` — the three most churn-heavy data flows on the pinned tree.
7. `07-usage.md` — hands-on recipes: use cases with API evidence.


## Extracts


The single package is extracted verbatim under
`modules/jimfs/com.google.common.jimfs/` (62 files, 12468 LOC), with a
`PROVENANCE.md` recording the upstream commit (`8fa098e0`), path, license
(Apache-2.0), and measured size. Extracts are byte-identical to upstream at
the pin — verified per-file by hash. The harvest record and re-sync rule
live in [`tracking/jimfs.md`](../../tracking/jimfs.md).


## Measurement note


Documentation statistics (census, module sizes, ratings, flow traces, use
cases) were measured on the upstream tree at the pin itself:
`8fa098e0715aa492914285312c07e151d2aace4d` (2026-10-22, "Bump
org.sonatype.central:central-publishing-maven-plugin from 0.11.0 to 0.12.0
in the dependencies group"). Every cited path and line resolves at that
commit. Real build/test evidence on the pin: `mvn -DskipTests compile` and
`mvn test` both exit 0 under Temurin JDK 17.0.21 + Maven 3.9.9 — 5906 tests,
0 failures, 0 errors, 1 skipped (see `04-overview.md`).
