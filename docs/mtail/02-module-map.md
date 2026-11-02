---
subject: google/mtail
measured_at: 4c7e0e1174ac1ead032efe28d86428bbbe0ae145
status: final
---




# Module map




- Subject: `google/mtail`, language Go. The module universe is the **Go
  package**: a directory holding at least one `.go` file, kept at depth ≤ 3
  from the repo root (deeper packages fold into their nearest depth-3
  parent). Measured on the pinned tree (see
  [`01-cartography.md`](01-cartography.md)): 27 raw Go directories normalize
  to **18 items** — the nine subpackages of `internal/runtime/compiler`
  (`ast`, `checker`, `codegen`, `errors`, `opt`, `parser`, `position`,
  `symbol`, `types`) fold into the compiler item.
- Census: **141 files / 26,896 LOC** (`.go`, tests included) — the 18 items
  sum exactly to the repository total (files 28+25+16+2+6+12+7+5+8+15+5+1+2+
  5+1+1+1+1 = 141; LOC 10116+4463+2017+1989+1871+1599+1326+804+667+504+335+
  278+277+214+206+152+59+19 = 26,896).
- Dependency convention: **depends on** lists the items a package imports
  from the universe (non-test imports, grep-verified on the pin); **imported
  by** lists the items that import it. The graph has **41 directed edges**;
  every edge appears exactly once in each direction's column. Self-edges
  within a folded item (compiler subpackage imports) are not counted.




## Index




| id | module | path | files | loc | rating | extracted |
|---|---|---|---|---|---|---|
| m01 | compiler | `internal/runtime/compiler` | 28 | 10,116 | 4 | yes |
| m02 | mtail | `internal/mtail` | 25 | 4,463 | 3 | yes |
| m03 | logstream | `internal/tailer/logstream` | 16 | 2,017 | 2 | yes |
| m04 | vm | `internal/runtime/vm` | 2 | 1,989 | 3 | yes |
| m05 | runtime | `internal/runtime` | 6 | 1,871 | 2 | yes |
| m06 | exporter | `internal/exporter` | 12 | 1,599 | 3 | yes |
| m07 | metrics | `internal/metrics` | 7 | 1,326 | 4 | yes |
| m08 | tailer | `internal/tailer` | 5 | 804 | 3 | yes |
| m09 | datum | `internal/metrics/datum` | 8 | 667 | 3 | yes |
| m10 | testutil | `internal/testutil` | 15 | 504 | 2 | yes |
| m11 | waker | `internal/waker` | 5 | 335 | 3 | yes |
| m12 | cmd/mtail | `cmd/mtail` | 1 | 278 | 1 | yes |
| m13 | golden | `internal/mtail/golden` | 2 | 277 | 2 | yes |
| m14 | code | `internal/runtime/code` | 5 | 214 | 2 | yes |
| m15 | mdot | `cmd/mdot` | 1 | 206 | 1 | yes |
| m16 | mgen | `cmd/mgen` | 1 | 152 | 2 | yes |
| m17 | mfmt | `cmd/mfmt` | 1 | 59 | 1 | yes |
| m18 | logline | `internal/logline` | 1 | 19 | 2 | yes |




Per-item ratings with dependency columns live in
[`matrix/matrix.csv`](../../matrix/matrix.csv).




## Items




### m01 compiler

- **Path**: `internal/runtime/compiler` · 28 files / 10,116 LOC.
- **Depends on**: metrics, datum, code. **Imported by**: runtime, mdot, mgen, mfmt.
- Front-end that compiles mtail source programs into `code.Object` bytecode.
  `Compiler.Compile` (compiler.go:89) runs the pipeline
  `parser.Parse` → `opt.Optimise` → `checker.Check` → `opt.Optimise` (second
  pass, after type-checking) → `codegen.CodeGen` across ten subpackages
  (root compiler plus ast, checker, codegen, errors, opt, parser, position,
  symbol, types), with safety Options `EmitAst`, `MaxRegexpLength`
  (compiler.go:63-64), `MaxRecursionDepth`, `DisableOptimisation`.
- Main files: entry `compiler.go` (type :19, `New` :27, `Compile` :89);
  largest `parser/parser.go` 1,504 lines (goyacc-generated); largest
  hand-written logic `checker/checker.go` 970 lines.

### m02 mtail

- **Path**: `internal/mtail` · 25 files / 4,463 LOC.
- **Depends on**: runtime, exporter, metrics, tailer, datum, testutil,
  waker, logline. **Imported by**: cmd/mtail, mdot.
- Holds `Server` — the orchestration hub (mtail.go:31, `New` :176): it owns
  the `metrics.Store`, the `tailer.Tailer` (log reading → the shared `lines`
  channel), the `runtime.Runtime` (program loading + VM lifecycle) and the
  `exporter.Exporter`, and runs the HTTP server (metrics / pprof / zpages).
  `options.go` (288 lines) defines the whole server `Option` surface;
  `logo.ico.go` (2,008 lines) is an embedded favicon asset, not logic. 13
  `*_integration_test.go` files exercise the `examples/` programs
  end-to-end.

### m03 logstream

- **Path**: `internal/tailer/logstream` · 16 files / 2,017 LOC.
- **Depends on**: waker, logline. **Imported by**: tailer.
- Turns each log-source pathname (regular file, named pipe/stdin, unix /
  tcp / udp socket) into a continuous stream of `*logline.LogLine` via the
  `LogStream` interface and the `New()` factory (logstream.go:35, :64) —
  URL-scheme dispatch :75-88, file-mode dispatch :102-112. It handles
  rotation (inode change), truncation (seek to 0), reopen on `ESTALE`, and
  cuts line boundaries itself in `LineReader` (reader.go:45) before pushing
  into the channel for the tailer.

### m04 vm

- **Path**: `internal/runtime/vm` · 2 files / 1,989 LOC.
- **Depends on**: metrics, datum, code, logline. **Imported by**: runtime.
- The bytecode interpreter. `New()` takes a `code.Object` (program, regex /
  string constants, metrics — vm.go:993-1009); `ProcessLogLine()`
  (vm.go:962-991) runs the fetch–decode–execute loop on a thread with a VM
  stack; `execute()` switches over the opcodes (`Match`, `Cmp`, `Inc`,
  `Set`, `Strptime`, `Add`, `Del`, `Stop`, …) updating `metrics.Metric`
  values. Panics in opcodes are recovered into runtime errors
  (vm.go:336-350, recover at :339); time parsing is memoized in an LRU
  (vm.go:64-65 `timeMemos`). `vm_test.go` (929 lines) is table-driven over
  hand-built instruction sequences.

### m05 runtime

- **Path**: `internal/runtime` · 6 files / 1,871 LOC.
- **Depends on**: compiler, vm, metrics, datum, code, logline. **Imported by**: mtail.
- The program loader / runtime: `Runtime` (runtime.go:215) loads `.mtail`
  program files from the program path (`LoadAllPrograms` :49,
  `LoadProgram` :104), compiles them through `compiler.Compiler` and runs
  one VM per program in the `handles` map (:226-227); `CompileAndRun` :141
  feeds log lines into a program's VM; changed files are unloaded
  (`UnloadProgram` :351). Compile errors are kept in `programErrors`
  (mutex-protected) and exposed on the loader status page
  (`httpstatus.go`, 117 lines, renders `/progz`).

### m06 exporter

- **Path**: `internal/exporter` · 12 files / 1,599 LOC.
- **Depends on**: metrics, datum. **Imported by**: mtail, cmd/mtail.
- "Getting metrics out of mtail into your monitoring system of choice"
  (export.go): the `Exporter` (export.go:32, `New` :91) reads the
  `*metrics.Store` and serves metrics as a Prometheus collector
  (`Describe`/`Collect`, prometheus.go:26/:31), as HTTP handlers (`/varz`
  varz.go:21, `/json` json.go:17, `/graphite` graphite.go:29), and pushes
  periodically to collectd (unix socket), Graphite (tcp) and StatsD (udp)
  targets (export.go:114-123, interval from `PushInterval` :74). Options:
  `Hostname` :51, `OmitProgLabel` :59, `EmitTimestamp` :67, `DisableExport`
  :81.

### m07 metrics

- **Path**: `internal/metrics` · 7 files / 1,326 LOC.
- **Depends on**: datum. **Imported by**: compiler, mtail, vm, runtime,
  exporter, cmd/mtail, golden, code.
- The central metric state store. `Store` (store.go:19, `NewStore` :26) is a
  name → `[]*Metric` map with double locking (`insertMu` + `searchMu`) for
  add/find/remove (`Add` :33, `FindMetricOrNil` :101), JSON serialization
  (`MarshalJSON` :127, `WriteMetrics` :207), iteration for the exporter
  (`Range` :141), and GC by limit/expiry (`Gc` :156, `StartGcLoop` :183).
  `Metric`/`LabelValue` (metric.go) model kind (Counter / Gauge / Timer /
  Text / Histogram), type (Int / Float / String / Buckets) and per-label
  datum values.

### m08 tailer

- **Path**: `internal/tailer` · 5 files / 804 LOC.
- **Depends on**: logstream, waker, logline. **Imported by**: mtail.
- The log-discovery front of the pipeline: `Tailer` (tail.go:30, `New`
  :119) "polls the filesystem for log sources that match given
  `LogPathPatterns` and creates `LogStream`s to tail them" (tail.go:28-29).
  `AddPattern` :186 / `pollLogPattern` :289 / `doPatternGlob` :321 poll
  globs on a `waker.Waker`; `TailPath` :256 tails one pathname and pumps
  lines into the shared `lines chan<- *logline.LogLine` (:273-274). Ignore
  regexes keep rotated (e.g. `.gz`) files out of globbing (`Ignore` :222,
  `SetIgnorePattern` :240); `httpstatus.go` renders the tailer status page
  (:44-84).

### m09 datum

- **Path**: `internal/metrics/datum` · 8 files / 667 LOC.
- **Depends on**: — (stdlib only). **Imported by**: compiler, mtail, vm,
  runtime, exporter, metrics, golden.
- The metric value types: interface `Datum` (`ValueString` / `TimeString` /
  `TimeUTC` — datum.go:15), base struct `BaseDatum` that stamps timestamps
  atomically (nanoseconds UTC — :30, stamp :36-40), and four
  implementations `Int` (int.go:14), `Float` (float.go:15), `String`
  (string.go:14), `Buckets` range histogram (buckets.go:30) with
  zero-value constructors `NewInt/NewFloat/NewString/NewBuckets`
  (datum.go:55-70). Bottom of the dependency graph.

### m10 testutil

- **Path**: `internal/testutil` · 15 files / 504 LOC.
- **Depends on**: logline. **Imported by**: mtail.
- Shared test-suite helpers: expvar assertions with deadlines
  (`TestGetExpvar` expvar.go:16, `ExpectExpvarDeltaWithDeadline`),
  `DoOrTimeout` polling (timeout.go:17) plus `TimeoutTest`, temp
  dir/file/log creation (`TestTempDir` fs.go:13, `OpenLogFile`), and
  environment helpers (port, race detector, root, stdin, flag, diff —
  one file each).

### m11 waker

- **Path**: `internal/waker` · 5 files / 335 LOC.
- **Depends on**: — (stdlib + glog). **Imported by**: mtail, logstream,
  tailer, cmd/mtail.
- The idle-loop synchronization seam: interface `Waker` (waker.go:7, a
  10-line interface — `Wake() <-chan struct{}` returns a channel closed
  when the idle routine should wake) with three implementations:
  `timedWaker` (production ticker — timedwaker.go:13, `NewTimed` :22),
  `testWaker` (controlled test wake-ups — testwaker.go:18, `NewTest` :42,
  `WakeFunc` :37) and `alwaysWaker` (pre-closed channel, never blocks —
  testwaker.go:124-139, `NewTestAlways` :129).

### m12 cmd/mtail

- **Path**: `cmd/mtail` · 1 file / 278 LOC.
- **Depends on**: mtail, exporter, metrics, waker. **Imported by**: — (nobody; it is the production entry binary).
- The real mtail binary: defines 32 CLI flags (main.go:41-85 — port /
  address / unix socket, progs, logs, compiler / VM runtime / ops / debug /
  tracing flags plus 3 DEPRECATED ones), maps them onto `[]mtail.Option` +
  `[]exporter.Option` (main.go:169-226), builds
  `metrics.NewStore` → `mtail.New` (:232) → `m.Run()` (:238), catches
  SIGINT/SIGTERM to cancel the context (:156-163), and implements the
  `-one_shot` debug branch that dumps metrics to stdout as JSON
  (`store.WriteMetrics`) or Prometheus exposition (`exporter.New` +
  `e.Write`) (:245-277).

### m13 golden

- **Path**: `internal/mtail/golden` · 2 files / 277 LOC.
- **Depends on**: metrics, datum. **Imported by**: — (test-only consumer wiring).
- Golden-file test oracle: `ReadTestData` (reader.go:20, :23) parses lines
  like `counter|gauge|timer|text|histogram <name>{k=v,...} <value>
  <timestamp>` (regexp `varRe`) into `metrics.MetricSlice` so tests can
  compare a program's metric output against `testdata/*.golden` files.

### m14 code

- **Path**: `internal/runtime/code` · 5 files / 214 LOC.
- **Depends on**: metrics. **Imported by**: compiler, vm, runtime.
- "Contains the bytecode instructions for the mtail virtual machine": the
  `Opcode` enum (61 opcodes, opcodes.go:7 — `Stop` :11, `Match` :12, `Inc`
  :18, `Mload` :41, `Dload` :42, … `F2s`), `Instr` (opcode + operand +
  source line — instr.go:9) and `Object{Program, Strings, Regexps, Metrics}`
  (object.go:13) — the binary artifact of a compiled program and the
  exchange contract between compiler codegen and the VM.

### m15 mdot

- **Path**: `cmd/mdot` · 1 file / 206 LOC.
- **Depends on**: compiler, mtail. **Imported by**: — (CLI).
- Program visualizer: parses an `.mtail` file (`parser.Parse`), type-checks
  it (`checker.Check`), walks the AST with a `dotter` visitor (:139-149)
  emitting graphviz nodes/edges to stdout — or serves SVG over HTTP via
  `exec.Command("dot", "-Tsvg")` when `--http_port` is set (:165-205).

### m16 mgen

- **Path**: `cmd/mgen` · 1 file / 152 LOC.
- **Depends on**: compiler. **Imported by**: — (CLI).
- Random program generator for fuzz testing ("Command mgen generates mtail
  programs for fuzz testing by following a simple grammar", main.go:4): a
  grammar table `map[string]node` describes the language (main.go:26-66,
  builtins `strptime`/`timestamp`/`len`/`tolower`…), `generateProgram()`
  walks it with a seeded `math/rand` (`-rand_seed`, `-min_iterations`)
  emitting tokens to stdout (main.go:91-135), and `-dictionary` prints
  `parser.Dictionary()` (:138-141).

### m17 mfmt

- **Path**: `cmd/mfmt` · 1 file / 59 LOC.
- **Depends on**: compiler. **Imported by**: — (CLI).
- Program formatter ("Command mfmt formats mtail programs."): reads the
  program from `-prog`, `parser.Parse` (:36), `checker.Check` (:40),
  re-prints normalized source via `parser.Unparser{}.Unparse` (:44-45) and
  overwrites the file in place with `-write`.

### m18 logline

- **Path**: `internal/logline` · 1 file / 19 LOC.
- **Depends on**: — (stdlib only). **Imported by**: mtail, logstream, vm,
  runtime, tailer, testutil.
- Defines `LogLine` (logline.go:9) — the struct wrapping one log line just
  read (Context + Filename + Line) — pushed by the tailer through a channel
  for the VM to process; the single in-flight data type exchanged between
  tailer, runtime, vm, mtail and testutil.




## Dependency edges (grep-verified on the pin)




- Everything converges on the state layer: `metrics` (m07) is imported by 8
  items and `datum` (m09) by 7 — every producer writes into the store and
  every consumer reads it.
- The ingestion chain runs `tailer → logstream → logline → (shared channel)
  → runtime → vm`, with the compiler feeding bytecode into the runtime.
- `cmd/mtail` depends on mtail, exporter, metrics and waker
  (main.go:18-21); the three tool CLIs (`mdot`, `mgen`, `mfmt`) each depend
  only on the compiler front-end.
- Leaf abstractions with zero **depends on**: `datum` (m09), `waker` (m11),
  `logline` (m18) — they are pure contracts used by everyone and importing
  nobody.
- Edge count: 41 directed edges (in-universe, non-test imports); the sum of
  the "depends on" columns equals the sum of the "imported by" columns (41).




## Coverage note




1. Census: the 18 items sum to 141 files / 26,896 LOC — equal to the whole
   `.go` census of the pinned tree; no file outside the universe, none
   counted twice.
2. Dependencies: 41 edges; each edge appears exactly once as a
   depends-on entry and once as an imported-by entry; no self-edges.
3. `go.mod` declares a single module (`github.com/google/mtail`), so import
   paths map 1:1 onto item paths; `Makefile:6` `TARGETS = mtail mgen mdot
   mfmt` matches the four `cmd/*` items exactly.
4. All measurements were taken on the tree at
   `4c7e0e1174ac1ead032efe28d86428bbbe0ae145` (see
   [`01-cartography.md`](01-cartography.md)); line numbers resolve at that
   commit and may drift as upstream moves.
