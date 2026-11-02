---
subject: google/mtail
measured_at: 4c7e0e1174ac1ead032efe28d86428bbbe0ae145
status: final
---


# Cartography

Google **mtail** is a web server that extracts white-box monitoring metrics from
application logs (regular-expression programs compiled to bytecode and executed
by an embedded VM). This document is the repository census for the pinned tree
`4c7e0e1174ac1ead032efe28d86428bbbe0ae145` (branch `main`, commit dated 2026-02-26, 301 commits deep clone) —
every number below was measured on that tree and re-verified by the map gate.

## Manifests and entry points

- **Go module**: `github.com/google/mtail` (`go.mod`) — Go module with
  `cmd/mtail` as the single server binary; `Makefile` drives
  `test` (:173-176), `testrace` (:177-180), `smoke` (:181-184), `regtest`
  (:185-188), `testall` (:213-214).
- **Entry point**: `cmd/mtail/main.go` — 32 flag definitions
  (main.go:41-85), mapping to `[]mtail.Option` + `[]exporter.Option`
  (:169-226), `mtail.New(ctx, store, opts...)` → `m.Run()`
  (:228-243), SIGINT/SIGTERM handling (:156-163), one-shot metric dump
  (:245-277).
- **Support CLIs**: `cmd/mdot` (program → graphviz), `cmd/mfmt` (formatter),
  `cmd/mgen` (grammar-based program generator for fuzzing).

## Measured census (PIN tree)

| zone | files | loc | notes |
|---|---|---|---|
| Go total | 141 | 26,896 | `find -name '*.go'` census v9 |
| non-test logic | 80 | 15,689 | 6/25 files in the server container are non-test |
| Go tests | 61 | 11,207 | 13 integration tests live in `internal/mtail` |
| docs | 16 | 2,300 | recursive; 2,240 = 15 top-level (designs/poll.md +1 level) |
| example programs | 17 `.mtail` | 968 | canonical corpus reused by integration tests |

The 18-item universe (Java-package analogue for Go: import-rooted packages)
sums exactly to the total above — see `02-module-map.md` for the item table.

## Top-level directories

| dir | contents | role |
|---|---|---|
| `cmd/` | mtail, mdot, mgen, mfmt | binaries |
| `internal/` | mtail, tailer, runtime (vm, compiler, code), metrics, exporter, waker, logline, testutil | all logic |
| `docs/` | Programming-Guide, Language, Metrics, Deploying, Testing, Troubleshooting, faq, designs/poll.md | DSL + ops documentation |
| `examples/` | 17 `.mtail` programs (apache*, dhcpd, postfix, rails, …) | canonical corpus |
| `testdata/` | anonymised logs (only testdata dir, find-verified) | test fixtures |
| repo root | `README.md`, `LICENSE` (Apache-2.0, 11,358 B), `Makefile`, `Dockerfile` + `Dockerfile.goreleaser`, `mtail.service`, `benchmark_results.csv`, `TODO` | ops/meta/packaging |

## License and build evidence

- **License**: Apache License 2.0 (`LICENSE`, 11,358 bytes, "Apache License"
  at line 2) — vendoring permitted with license/notice preservation.
- **Build evidence** (on the PIN tree): `go build ./...` exit 0;
  `go test ./...` → 18/19 packages pass, `run=663 pass=655 fail=2 skip=6`.
  The single failing package `internal/mtail` fails exactly 1 of 663 cases
  (`TestFileSocketStreamComparison`, subtest `examples/dhcpd.mtail on
  unixgram://…`) — a load/timing-sensitive socket comparison that hits its
  10 s cap on a 2-vCPU container; environment artifact, not a code failure
  (goroutine dump captured in `04-overview.md`). The 6 skips are
  root-environment guards ("Skipping test when run as root").
