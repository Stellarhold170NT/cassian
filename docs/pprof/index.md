---
subject: google/pprof
measured_at: dbd0ed30aa888a30e21ba83b9831ac0e80d41022
status: final
---

# pprof — reading order

Start with [`matrix/matrix.csv`](../../matrix/matrix.csv) (the index: 17
Go packages with ratings and locations), then read the docs in this
order:

1. `01-cartography.md` — repository census: license gate, manifests, entry
   points, top-level directories, measured sizes.
2. `02-module-map.md` — the module map: responsibility, dependencies, and
   measured size for each of the 17 Go packages.
3. `03-c4/` — architecture source: `workspace.dsl` (Structurizr DSL,
   machine-validated: structurizr-cli validate exit 0, all 5 views
   exported), covering the context, container and component views with an
   evidence comment on every element and relationship.
4. `04-overview.md` — the narrative overview of how the system works, with
   real build/test evidence.
5. `05-folders.md` — directory zones, the `profile` package deep dive,
   naming conventions, and deviations from Go conventions.
6. `06-flows.md` — the three most churn-heavy data flows on the pinned
   tree, with per-step call evidence.
7. `07-usage.md` — hands-on recipes: 23 use cases across the 8 reusable
   packages, each with API evidence.

## Extracts

All 17 packages are extracted verbatim under `modules/pprof/` (86 files,
30,683 lines of Go), each with a `PROVENANCE.md` recording the upstream
commit (`dbd0ed30`), path, license (Apache-2.0), and measured size.
Extracts are byte-identical to upstream at the pin — verified per-file by
hash. The harvest record and re-sync rule live in
[`tracking/pprof.md`](../../tracking/pprof.md).

## Measurement note

Documentation statistics (census, module sizes, ratings, flow traces, use
cases) were measured on the upstream tree at the pin itself:
`dbd0ed30aa888a30e21ba83b9831ac0e80d41022` (2026-10-26 19:23:09 +0000,
"Record the selected sample type as default_sample_type in -proto output.
(#1055)"). Every cited path and line resolves at that commit. Real
build/test evidence on the pin: `go build ./...` exits 0, and `go test
./...` passes 12/12 packages with tests under Go 1.27.3 / linux/amd64
with `binutils` and `llvm` installed (the binutils package needs
nm/addr2line/objdump/llvm-symbolizer; see `04-overview.md` for the full
run log).

The `rating` column in `matrix/matrix.csv` is a 1–5 reusability score
assigned during measurement (dependency position, centrality, test
coverage, exported API surface, and size considered together under a
min-aggregation rule). The single 4-star package `profile` is the
extraction candidate documented in [`specs/pprof/`](../../specs/pprof/).
