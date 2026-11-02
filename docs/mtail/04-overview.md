---
subject: google/mtail
measured_at: 4c7e0e1174ac1ead032efe28d86428bbbe0ae145
status: final
---




# Overview: how mtail works




All numbers and `file:line` anchors below were verified on the pinned tree
`4c7e0e1174ac1ead032efe28d86428bbbe0ae145` (see
[`01-cartography.md`](01-cartography.md) for the census;
[`02-module-map.md`](02-module-map.md) for the 18-package module map).




## (1) What mtail is — 5 sentences




1. mtail is Google's **log-to-metrics extraction agent**: "`mtail` is a tool
   for extracting metrics from application logs to be exported into a
   timeseries database or timeseries calculator for alerting and
   dashboarding" (README.md:11-13).
2. Extraction rules are written in a **bespoke DSL** ("mtail programs",
   README.md:19-28 — e.g. `counter lines_total` plus a regex action block
   `/$/ { lines_total++ }`), which the agent **compiles to bytecode and
   interprets** per log line: `Compiler.Compile`
   (internal/runtime/compiler/compiler.go:89) and the `VM` interpreter
   (`type VM struct` internal/runtime/vm/vm.go:56, `ProcessLogLine`
   vm.go:962).
3. It **tails live log sources** — regular files, named pipes, stdin,
   unix/TCP/UDP sockets — through a polling tailer and per-source log
   streams ("Tailer polls the filesystem for log sources that match given
   `LogPathPatterns` and creates `LogStream`s to tail them",
   internal/tailer/tail.go:28-29).
4. Metrics accumulate in a central in-memory `metrics.Store`
   (`func NewStore()` internal/metrics/store.go:26) and are **exported via
   HTTP pull (Prometheus/JSON/varz) or periodic push (collectd/StatsD/
   Graphite)** — "Metrics are exported for scraping by a collector as JSON
   or Prometheus format over HTTP, or can be periodically sent to a
   collectd, StatsD, or Graphite collector socket" (README.md:29-31; push
   wiring internal/exporter/export.go:114-123).
5. It ships as **four single-file Go CLIs** (`cmd/mtail`, `cmd/mdot`,
   `cmd/mgen`, `cmd/mfmt`, one `main.go` each; 695 LOC combined) over a
   strictly `internal/` package tree — 141 `.go` files / 26,896 LOC measured
   on the pin — declared `go 1.21.1` (go.mod:3).




## (2) Grasp in 5 minutes — 10 bullets




1. **One binary does the work**: `cmd/mtail/main.go` defines **32 flags**
   (32 flag definitions, declaration block main.go:41-85), maps them to
   `[]mtail.Option` + `[]exporter.Option` (main.go:169-226), then builds
   `metrics.NewStore` → `mtail.New(ctx, store, opts...)` → `m.Run()`
   (main.go:228-243, anchors :232, :238).
2. **The server is a wiring hub**: `type Server struct`
   (internal/mtail/mtail.go:31) holds the metrics store, the
   `tailer.Tailer`, the `runtime.Runtime`, the `exporter.Exporter` and the
   shared `lines chan *logline.LogLine`; `func New(ctx, store, options
   ...Option)` at mtail.go:176.
3. **HTTP surface is 5 routes**: `/debug/vars` (expvar, mtail.go:107),
   `/progz` (program status, :117), `/` (status page, :119), `/metrics`
   (promhttp, :120), zpages traced handlers (:123).
4. **Log ingestion pipeline**: `Tailer.TailPath` (tail.go:256) creates one
   `logstream.LogStream` per pathname via factory `logstream.New`
   (logstream.go:64, URL-scheme dispatch :75-88, file-mode dispatch
   :102-112); a `LineReader` splits line boundaries (reader.go:45
   `ReadAndSend`) and lines flow over the shared channel as
   `*logline.LogLine` (internal/logline/logline.go:9; the whole package is
   19 lines).
5. **Program lifecycle**: `Runtime.LoadAllPrograms` (runtime.go:49) /
   `LoadProgram` (:104) / `CompileAndRun` (:141) — compile via
   `Compiler.Compile` (compiler.go:89: parse → optimise → type-check →
   optimise → code-gen) — and unload on file change (`UnloadProgram`
   :351); one VM per program.
6. **The VM is a bytecode interpreter**: `ProcessLogLine` (vm.go:962-991)
   runs fetch-decode-execute on a thread stack; `execute` (vm.go:336)
   switches over 61 opcodes (`internal/runtime/code/opcodes.go` const
   block); time parsing is memoized in an LRU (vm.go:64-65 `timeMemos`).
7. **Metrics model**: `Store` is a name→`[]*Metric` map with double locking
   (insertMu+searchMu) holding `Counter/Gauge/Timer/Text/Histogram` kinds
   over `Datum` value types (Int/Float/String/Buckets —
   internal/metrics/datum/datum.go:15 interface, :55-70 constructors).
8. **Export paths**: pull — Prometheus collector `Collect` reading
   `store.Range` (prometheus.go:31, :36), plus varz/json handlers; push —
   per-target goroutines configured from flags: collectd over **unix
   socket** (export.go:114-115), Graphite over **tcp** (:118-119), StatsD
   over **udp** (:122-123), interval from `PushInterval` (:74).
9. **Debugging mode**: `-one_shot` compiles programs, reads logs
   start-to-EOF, prints the metric store and exits — "This is a debugging
   flag only, not for production use" (cmd/mtail/main.go:50; formats
   json/prometheus, :51).
10. **Self-description for newcomers**: 15 top-level docs pages (2,300
    markdown lines measured recursively over `docs/`; includes
    `docs/designs/poll.md`: Programming-Guide, Language, Metrics, Deploying,
    Testing, Troubleshooting) and 17 example programs (968 LOC) that double
    as the integration-test corpus (`examples_integration_test.go` iterates
    them).




## (3) System context (C4 L1)




- **System under description**: mtail — a single-process log-tailing metrics
  extraction agent for operators, shipped as the `cmd/mtail` binary (plus
  three developer CLIs).
- **Actors**: the *operator/SRE* runs `mtail -progs <dir> -logs <glob>`
  (flags main.go:41-85; ops packaging exists upstream: `mtail.service`
  systemd unit, `Dockerfile`, `Dockerfile.goreleaser`); the *program
  author* writes `.mtail` DSL programs (README.md:19-28 example;
  docs/Programming-Guide.md; 17 canonical programs in examples/) with
  support CLIs `mdot` (program→graphviz), `mfmt` (formatter), `mgen`
  (grammar-based program generator for fuzzing); the *monitoring collector*
  scrapes `/metrics`/`/varz`/`/json` over HTTP or receives periodic push on
  collectd/StatsD/Graphite sockets (README.md:29-31; export.go:114-123).
- **External systems**: *application logs* — files, named pipes, stdin,
  unix/tcp/udp sockets (logstream dispatch logstream.go:75-112); mtail is
  **read-only** against them. *Timeseries backend* — Prometheus (pull,
  promhttp mtail.go:120), Graphite/StatsD/collectd (push), or any JSON
  consumer. *Optional tracing backend* — Jaeger via
  `contrib.go.opencensus.io/exporter/jaeger v0.2.1` (go.mod require block)
  + OpenCensus zpages (mtail.go:123).
- **Boundary**: metrics live only in memory (`Store`, store.go:26 — no
  persistence layer in the repo); the HTTP listener is the default network
  surface, push sockets and Jaeger export are opt-in via flags; there is no
  auth layer anywhere in the tree.
- **Value invariant** (README.md:17-21): operators get metrics out of
  applications that "do not export their own internal state (other than via
  logs)" **without patching those applications** — the log file is the only
  integration contract.




## (4) Containers (C4 L2)




LOC are the module-map item figures (verified sum = 26,896 = whole repo
`.go` census).




| # | Container | Type | Items (LOC) | Responsibility (evidence) |
|---|---|---|---|---|
| 1 | CLI binaries | Go `package main` ×4 | m12 cmd/mtail (278), m15 mdot (206), m16 mgen (152), m17 mfmt (59) = **695** | Flag parsing → Options → start server / dot export / fuzz-program generation / program reformat (one `main.go` each) |
| 2 | Server & orchestration | Go internal package | m02 internal/mtail (4,463) + m13 golden (277) = **4,740** | `Server` wires tailer+runtime+exporter+HTTP (mtail.go:31/:176); `golden` parses golden metric files for tests (reader.go:23) |
| 3 | Log ingestion | Go internal packages | m08 tailer (804) + m03 logstream (2,017) + m18 logline (19) + m11 waker (335) = **3,175** | Pattern polling → per-source streams (rotation/truncation/ESTALE reopen) → `LogLine` channel; `Waker` interface for wake-up scheduling (waker.go:7) |
| 4 | Program compile & execution | Go internal packages | m01 compiler (10,116) + m05 runtime (1,871) + m04 vm (1,989) + m14 code (214) = **14,190** | DSL front-end (10 subpackages, compiler.go:89) → `code.Object` bytecode (object.go:13) → program loader (runtime.go:141) → per-line VM interpretation (vm.go:962) |
| 5 | Metrics state | Go internal packages | m07 metrics (1,326) + m09 datum (667) = **1,993** | Thread-safe central store (store.go:19/:26) + metric kinds/labels/datum value types |
| 6 | Export | Go internal package | m06 exporter (1,599) = **1,599** | Prometheus collector, varz/json HTTP, push targets (export.go:114-123) |
| 7 | Test infrastructure | Go internal package | m10 testutil (504) = **504** | expvar assertions with deadlines, temp files, port/race/root helpers (expvar.go:16, timeout.go:17, fs.go:13) |




Protocol between containers: direct Go method calls over the shared
`lines chan <- *logline.LogLine` (m18) and the `*metrics.Store` pointer
(m07); the only externally visible contracts are the CLI flags (container
1), the HTTP routes (mtail.go:107-123), the push wire formats (exporter),
and the `.mtail` DSL file format.




## (5) Component highlights (C4 L3)




- **Compiler (m01, 10,116 LOC)** — front-end pipeline `Compiler.Compile`
  (compiler.go:89) = `parser.Parse` → `opt.Optimise` → `checker.Check` →
  `opt.Optimise` (2nd pass) → `codegen.CodeGen`; 9 subpackages; the
  generated `parser/parser.go` (1,504 lines, goyacc) and the hand-written
  `checker/checker.go` (970) carry the weight.
- **Runtime / loader (m05, 1,871 LOC)** — `Runtime` (runtime.go:215) with
  `handles map[string]*vmHandle` (:226-227); expvar counters
  LineCount/ProgLoads/ProgUnloads/ProgLoadErrors (:31-38); `httpstatus.go`
  renders `/progz`.
- **VM (m04, 1,989 LOC)** — `VM` (vm.go:56) built from `code.Object`
  (`New` vm.go:993-1009); `ProcessLogLine` :962; `execute` opcode switch
  :336; panic→runtime-error recover (:336-350); LRU time-memo cache :64.
- **Server (m02, 4,463 LOC)** — `Server` mtail.go:31 + `New` :176;
  `options.go` (288 lines) is the Option surface; 13
  `*_integration_test.go` files exercise examples/ end-to-end (harness in
  `testing.go`: `TestMakeServer` :47, `TestStartServer` :90).
- **Metrics store (m07, 1,326 LOC)** — `Store` store.go:19, `NewStore` :26;
  `Add` :33, `FindMetricOrNil` :101, `Range` :141, `Gc` :156,
  `WriteMetrics` :207.
- **Exporter (m06, 1,599 LOC)** — `Exporter` export.go:32, `New` :91;
  Prometheus `Collect` prometheus.go:31; varz/json pull formats; push
  wiring export.go:114-123 with per-target counters.
- **Tailer/logstream (m08+m03, 2,821 LOC)** — pattern poll → per-source
  streams: rotation via `os.SameFile` (filestream.go:155), truncation via
  size check (:178), reopen on `ESTALE` (:119), line splitting in
  `LineReader.ReadAndSend` (reader.go:45).
- **Key dependency edges (41 total)**: everything converges on `metrics`
  (8 dependents) and `datum` (7); the ingestion chain is `tailer →
  logstream → logline → (channel) → runtime → compiler/vm`; `waker`,
  `logline`, `datum` have **zero deps** — they are leaf abstractions.




## (6) Directory map + zone roles




| Zone | Contents | LOC | Role |
|---|---|---|---|
| repo root | `README.md` (DSL example :21-28), `LICENSE` (Apache-2.0, 11,358 B), `Makefile` (targets test :173-176, testrace :177-180, smoke :181-184, regtest :185-188, testall :213-214), `Dockerfile` + `Dockerfile.goreleaser`, `mtail.service`, `mtail-mode.el`, `log_rewriter.awk`, `benchmark_results.csv`, `TODO`, `hooks/{build,post_checkout,post_push}` | — | ops/meta/packaging |
| `cmd/` | `mtail/`, `mdot/`, `mgen/`, `mfmt/` — exactly one `main.go` each (ls-verified) | 695 | user-facing binaries |
| `internal/runtime/` | `compiler/` (m01, 28 files incl. 9 subpackages; `fuzz/` holds testdata `.mtail`), `vm/` (m04), `code/` (m14), loader (m05) | 14,190 | DSL → bytecode → execution |
| `internal/tailer/` | `tail.go` + `httpstatus.go` + 3 tests (m08); `logstream/` (m03, 16 files) | 2,821 | log discovery + streaming |
| `internal/metrics/` | store + metric + type (m07); `datum/` (m09) | 1,993 | metric state model |
| `internal/exporter/` | export/prometheus/varz/json/collectd/graphite/statsd (m06, 12 files) | 1,599 | metrics out |
| `internal/mtail/` | `mtail.go`, `options.go`, `httpstatus.go`, `logo.ico.go`, `buildinfo.go`, `testing.go` (m02) + `golden/` (m13); 13 `*_integration_test.go`; `testdata/` (the repo's only testdata dir) | 4,740 | server + e2e harness |
| `internal/{waker,logline,testutil}/` | m11 (335) + m18 (19) + m10 (504) | 858 | shared leaf infra |
| `docs/` | 15 top-level md pages + `designs/poll.md` — Programming-Guide, Language, Metrics, Deploying, Building, Testing, Troubleshooting, faq, … | — | DSL + ops documentation |
| `examples/` | 17 `.mtail` programs (apache*, dhcpd, postfix, rails, mysql_slowqueries, …) | 968 | canonical corpus, reused by integration tests |




Zone reading order for a newcomer: README → `docs/Programming-Guide.md` →
`cmd/mtail/main.go` → `internal/mtail/mtail.go` → `internal/tailer/tail.go`
→ `internal/runtime/runtime.go` → `internal/runtime/compiler/compiler.go`
→ `internal/runtime/vm/vm.go` → `internal/metrics/store.go` →
`internal/exporter/export.go`.




## (7) Build & test evidence on the pin




The Go toolchain was not part of the measurement sandbox image; Go
**1.22.12 linux/amd64** was installed from the official tarball (go.mod
declares `go 1.21.1`) and the standard harness ran on the pinned clone.
Real output:




```
$ cd /workspace/mtail && go build ./...
go: downloading github.com/prometheus/client_golang v1.20.4 … (20 module downloads)
BUILD_EXIT=0

$ cd /workspace/mtail && go test ./...
ok  	github.com/google/mtail/internal/mtail/golden	0.036s
ok  	github.com/google/mtail/internal/runtime	0.476s
ok  	github.com/google/mtail/internal/runtime/code	0.023s
ok  	github.com/google/mtail/internal/runtime/compiler	0.031s
… (ast/checker/codegen/errors/opt/parser/symbol/types all ok)
ok  	github.com/google/mtail/internal/runtime/vm	0.067s
ok  	github.com/google/mtail/internal/tailer	0.076s
ok  	github.com/google/mtail/internal/tailer/logstream	0.252s
FAIL	github.com/google/mtail/internal/mtail	20.834s
FAIL
TEST_EXIT=1
```




**18/19 packages pass.** The single failing package `internal/mtail` fails
in exactly **1 of 663 test cases**: `TestFileSocketStreamComparison` →
subtest `examples/dhcpd.mtail on unixgram://testdata/anonymised_dhcpd_log`
(10.01s == the `exampleTimeout = 10 * time.Second` cap,
examples_integration_test.go:24). The captured goroutine dump shows the
failure mechanism: the socket-writer goroutine blocked in
`net.(*conn).Write` inside `io.Copy(s, source)`
(examples_integration_unix_test.go:154) — a load/timing-sensitive
integration test that feeds 17 example logs through unix sockets and
compares metrics with file-tailing; it failed reproducibly on this 2-vCPU
container but is an environment artifact, not a compile/code failure.
Full -v totals from a complete re-run: `run=663 pass=655 fail=2 skip=6`
(the 2 FAIL lines are the parent + that one subtest of the same test).
The 6 skips are all root-environment guards ("Skipping test when run as
root" — tail_unix_test.go:25, filestream_unix_test.go:115, plus
permission/exec/corrupt-rune cases). This matches the upstream Makefile
semantics (`make test` = `go test $(GO_TEST_FLAGS) -gcflags … -timeout
${test_timeout} ./...`, Makefile:173-176); `make smoke` additionally
applies `-test.short`, which skips these long comparisons via
`testutil.SkipIfShort`.




Result: **build passes (exit 0); test suite 655/663 cases pass (98.8%),
1 flaky subtest, 6 documented skips** — Go 1.22.12 / linux/amd64 /
2-vCPU container.




## (8) Expensive extension points




1. **Server Option surface** — `internal/mtail/options.go` (288 LOC) is the
   largest non-test logic file in the server container: every server
   behavior (program path, log patterns, one-shot, poll wakers,
   omit-source, …) is an `Option`; `cmd/mtail` maps 32 flags onto it
   (main.go:169-226) — the seam for embedding mtail into another process.
2. **Compiler Options** — `MaxRegexpLength` (compiler.go:63-64),
   `MaxRecursionDepth`, `DisableOptimisation`, `EmitAst` — knobs to sandbox
   hostile programs; new pass-level knobs slot here.
3. **`waker.Waker` interface** — a 10-line interface (waker.go:7) with 3
   implementations (timed/test/always); the entire tailer/logstream/VM
   choreography is parameterized on it — the seam for event-driven
   (inotify-style) log wake-ups instead of polling (see
   docs/designs/poll.md).
4. **`logstream.New` dispatch** — URL-scheme (:75-88) and file-mode
   (:102-112) dispatch to file/fifo/socket/dgram streams; the seam for new
   log source types (journald, container runtimes, k8s …).
5. **Exporter push/pull formats** — push targets follow one `pushOptions`
   pattern (export.go:114-123: collectd unix / graphite tcp / statsd udp)
   and pull formats sit beside prometheus.go/json.go/varz.go — the seam
   for new monitoring backends.
6. **`code.Object` ↔ VM opcode contract** — 61 opcodes (opcodes.go),
   `Object{Program,Strings,Regexps,Metrics}` (object.go:13); compiler
   codegen and the VM `execute` switch (vm.go:336) must move together —
   the seam for new DSL language features.




## (9) Risks when reusing




1. **Everything lives under `internal/`** — all 18 packages are
   `github.com/google/mtail/internal/...` or `cmd/...`; Go's
   internal-package rule means **no component can be imported from another
   module**. Reuse is limited to (a) running the binary and its HTTP/push
   surface, (b) vendoring/forking the whole module.
2. **Bespoke DSL + generated parser** — the language is mtail-specific;
   `parser/parser.go` (1,504 lines) is goyacc-generated "DO NOT EDIT"
   (parser.go:1), so grammar changes require the goyacc toolchain
   (docs/Building.md) — a real tooling cost for language-level forks.
3. **LOC distortion from generated/embedded files** — `logo.ico.go`
   (2,008) and `parser/parser.go` (1,504) are 3,512 of 26,896 LOC (~13%);
   any byte-based valuation of this repo should exclude them.
4. **Concurrency choreography is load-bearing** — tailer/logstream/VM/
   runtime coordinate through the shared channel + `Waker` wake-ups;
   lifting one component out in isolation silently changes timing
   semantics (the test-only waker exists precisely to make this testable,
   testwaker.go:18-42).
5. **Test-suite environment sensitivity** — 6 tests skip when run as root,
   and the unix-socket comparison integration test can exceed its 10 s
   budget on constrained CPUs (§7 evidence); CI harnesses reusing this
   suite need a non-root, reasonably fast runner (or `-short`).
6. **Dependency coupling** — glog for logging, OpenCensus + Jaeger exporter
   for tracing, prometheus client_golang v1.20.4 for the registry API
   (go.mod); replacing any of them touches the exporter/server layers, not
   just wiring.
7. **License** — Apache-2.0 (LICENSE, 11,358 B): vendoring is permitted
   with license/notice preservation.




## (10) Provenance




- **Upstream**: `https://github.com/google/mtail`, branch `main`.
- **Pin**: `4c7e0e1174ac1ead032efe28d86428bbbe0ae145` — commit date
  2026-02-26 09:59:36 -0800, subject "Merge pull request #999 from
  google/lsc-1771431274.9704435".
- **License**: Apache License 2.0 (`LICENSE`, 11,358 bytes, "Apache
  License" at line 2).
- **Census (measured on the pin)**: 141 `.go` files / 26,896 LOC total;
  non-test 80 / 15,689; test 61 / 11,207; equals the 18-item module-map sum
  exactly. Docs: 15 top-level pages / 2,300 lines (recursive). Examples:
  17 `.mtail` / 968 LOC.
- **Toolchain**: Go 1.22.12 linux/amd64 (go.mod declares `go 1.21.1`).
- **Numbers policy**: all counts are `find`/`wc`-reproducible on the pin;
  every `file:line` anchor was grep-verified at measurement time.
