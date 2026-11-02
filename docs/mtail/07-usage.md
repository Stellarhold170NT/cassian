---
subject: google/mtail
measured_at: 4c7e0e1174ac1ead032efe28d86428bbbe0ae145
status: final
---




# Usage — hands-on recipes




24 use cases across the 8 packages that make useful standalone building
blocks (`compiler`, `metrics`, `mtail`, `vm`, `exporter`, `tailer`,
`datum`, `waker`), each with API evidence. Everything was verified by
grepping the pinned tree `4c7e0e1174ac1ead032efe28d86428bbbe0ae145` —
every `file:line` below resolves at that commit (see
[`01-cartography.md`](01-cartography.md)).




Conventions:




- **Import-path caveat**: every package lives under
  `github.com/google/mtail/internal/...` (or `cmd/...`). Go's
  internal-package rule means these imports resolve **only inside the
  mtail module itself** — recipes here assume you run them inside the
  module (or vendored/forked as a whole). The binary's HTTP/push surface
  is the only out-of-module contract.
- Evidence lines are quoted from the pinned source; per-package
  `go build`/`go test` was not run in the measurement environment (no Go
  toolchain there). Whole-module build/test evidence with a real
  toolchain is in [`04-overview.md`](04-overview.md) §7.
- **Imported by** = which other module-map items consume the package
  (non-test imports; see [`02-module-map.md`](02-module-map.md)).




## Summary — what to reach for




| item | module | use it when | imported by |
|---|---|---|---|
| s01 | compiler (m01) | front-end turning `.mtail` source into `code.Object` bytecode (parse → optimise → check → codegen); compile/lint/validate programs from Go code (the mtail binary, mdot/mfmt/mgen tools, CI). | runtime, mdot, mgen, mfmt |
| s07 | metrics (m07) | the central `Store` holding every metric programs create (thread-safe add/find, limit/expiry GC, JSON, `Range` for exporters); register/lookup/dump/GC metrics. | compiler, mtail, vm, runtime, exporter, cmd/mtail, golden, code |
| s02 | mtail (m02) | the `Server` orchestrator owning Store + tailer + runtime + exporter and running the HTTP server; embed the whole log→metric pipeline in a Go process (long-running, compile-only CI, one-shot snapshots). | cmd/mtail, mdot |
| s04 | vm (m04) | the bytecode interpreter: `New(code.Object)` + `ProcessLogLine` fetch–decode–execute updating metrics; build/test/debug bytecode by hand, or run the VM as a channel consumer. | runtime |
| s06 | exporter (m06) | the metrics-out port: Prometheus collector for a registry, HTTP handlers `/varz` `/json` `/graphite`, periodic push; move values out of a `metrics.Store` into Prometheus or other formats. | mtail, cmd/mtail |
| s08 | tailer (m08) | the pipeline input: poll the filesystem per `LogPathPatterns`, spawn a `LogStream` per path or glob, pump lines into the `lines` channel; read real log files (ignores `.gz`, HTML status page). | mtail |
| s09 | datum (m09) | metric value types: the `Datum` interface + `Int`/`Float`/`String`/`Buckets` (histogram) with atomic timestamps; a uniform value+timestamp mechanism — bottom of the graph, imports nothing. | compiler, mtail, vm, runtime, exporter, metrics, golden |
| s11 | waker (m11) | the `Waker` synchronization interface (a channel closed when an idle routine should wake) + `timedWaker`/`testWaker`/`alwaysWaker`; wake idle loops on a schedule or synchronize tests instead of hard sleeps. | mtail, logstream, tailer, cmd/mtail |






## s01 — compiler (`internal/runtime/compiler`)




**What this item solves.** The front-end that turns mtail source programs
into `code.Object` bytecode: `Compiler.Compile` (compiler.go:89) runs
parse → optimise → check → optimise (second pass) → code-gen across ten
subpackages, with safety Options (`EmitAst`, `MaxRegexpLength`,
`MaxRecursionDepth`, `DisableOptimisation`). Anyone compiling mtail
programs from Go code (the binary, the mdot/mfmt/mgen tools, the runtime
loader) goes through this item.




### UC-1.1 — Compile an `.mtail` program to bytecode from Go code




Scenario: your deploy tooling wants to compile an `.mtail` file before
shipping to catch errors early. Build a `Compiler` with safety limits
(regexp ≤ 64 chars, recursion ≤ 64) and call `Compile` — compile errors
come back with positions in the source. The `*code.Object` result is the
artifact you feed straight into `vm.New()` (UC-4.1) or the runtime loader.




```go
package main

import (
	"os"

	"github.com/google/mtail/internal/runtime/compiler"
)

func main() {
	f, err := os.Open("requests.mtail")
	if err != nil {
		panic(err)
	}
	defer f.Close()

	c, err := compiler.New(compiler.MaxRegexpLength(64), compiler.MaxRecursionDepth(64))
	if err != nil {
		panic(err)
	}
	obj, err := c.Compile("requests.mtail", f)
	if err != nil {
		panic(err) // compile error, with position in the .mtail source
	}
	// obj *code.Object — feed into vm.New() or runtime.Runtime.CompileAndRun()
	_ = obj
}
```




Evidence:
- `internal/runtime/compiler/compiler.go:27` — `func New(options ...Option) (*Compiler, error) {`
- `internal/runtime/compiler/compiler.go:89` — `func (c *Compiler) Compile(name string, input io.Reader) (obj *code.Object, err error) {`
- `internal/runtime/compiler/compiler.go:64` — `func MaxRegexpLength(maxRegexpLength int) Option {` · `compiler.go:72` — `func MaxRecursionDepth(maxRecursionDepth int) Option {`
- `internal/runtime/code/object.go:13-18` — `type Object struct { Program []Instr; Strings []string; Regexps []*regexp.Regexp; Metrics []*metrics.Metric }`




### UC-1.2 — Lint/validate + canonicalize an `.mtail` program in CI (the mfmt pipeline)




Scenario: CI runs a check over every `.mtail` program: `Parse` catches
syntax errors, `Check` catches type/semantic errors, and
`Unparser{}.Unparse` re-prints canonical source for diffing. This is
exactly the pipeline the `mfmt` CLI calls (cmd/mfmt/main.go:36/40/44).




```go
package main

import (
	"io"

	"github.com/google/mtail/internal/runtime/compiler/checker"
	"github.com/google/mtail/internal/runtime/compiler/parser"
)

// lint: return canonical source, or the syntax/type error of an .mtail program.
func lint(src io.Reader) (string, error) {
	ast, err := parser.Parse("prog.mtail", src)
	if err != nil {
		return "", err // syntax error
	}
	ast, err = checker.Check(ast, 0, 0)
	if err != nil {
		return "", err // type / semantic error
	}
	up := parser.Unparser{}
	return up.Unparse(ast), nil
}
```




Evidence:
- `internal/runtime/compiler/parser/driver.go:34` — `func Parse(name string, input io.Reader) (ast.Node, error) {`
- `internal/runtime/compiler/checker/checker.go:45` — `func Check(node ast.Node, maxRegexpLength int, maxRecursionDepth int) (ast.Node, error) {`
- `internal/runtime/compiler/parser/unparser.go:16` — `type Unparser struct {` · `unparser.go:288` — `func (u *Unparser) Unparse(n ast.Node) string {`
- `cmd/mfmt/main.go:36` — `ast, err := parser.Parse(*prog, f)` · `:40` — `ast, err = checker.Check(ast, 0, 0)` · `:44` — `up := parser.Unparser{}`




### UC-1.3 — Get the `.mtail` token dictionary for an editor/linter




Scenario: you are writing a syntax-highlighting plugin or linter for
`.mtail` and need the full token list (keywords + builtins such as
`strptime`, `timestamp`, `len`, `tolower`) — `parser.Dictionary()` returns
a `[]string`. The `mgen` CLI calls the same API for its `-dictionary`
flag.




```go
package main

import (
	"fmt"

	"github.com/google/mtail/internal/runtime/compiler/parser"
)

func main() {
	tokens := parser.Dictionary() // keywords + builtins of the .mtail language
	fmt.Printf("the .mtail language has %d tokens\n", len(tokens))
	for i, t := range tokens {
		if i >= 10 {
			break
		}
		fmt.Println(t)
	}
}
```




Evidence:
- `internal/runtime/compiler/parser/lexer.go:58` — `func Dictionary() (r []string) {`
- `cmd/mgen/main.go:139` — `for _, k := range parser.Dictionary() {`




**Pulls in**: stdlib + the item's own subpackages (`parser`, `checker`);
the `Compile` result is a `*code.Object`, so consumers sit on top of the
`code` item (compiler's own imports: metrics, datum, code).





## s07 — metrics (`internal/metrics`)




**What this item solves.** The central metric state store: `Store` (a
name → `[]*Metric` map, double-locked) holds every metric programs create,
with thread-safe add/find/remove, JSON serialization, limit/expiry GC and a
`Range` iterator for exporters. Register, look up, dump, or GC metrics
here.




### UC-2.1 — Register a counter, create values per label, read it back through the Store




Scenario: you embed mtail's metric library in your own program: create a
`Store`, register a `requests_total` counter with a `status` label, create
the datum for label set `"200"` and increment it, then look the metric up
in the store by (name, prog) and print it as a string.




```go
package main

import (
	"fmt"
	"time"

	"github.com/google/mtail/internal/metrics"
	"github.com/google/mtail/internal/metrics/datum"
)

func main() {
	store := metrics.NewStore()
	m := metrics.NewMetric("requests_total", "demo_prog", metrics.Counter, metrics.Int, "status")
	if err := store.Add(m); err != nil {
		panic(err)
	}
	d, err := m.GetDatum("200") // registers LabelValue{status="200"} if absent
	if err != nil {
		panic(err)
	}
	d.(*datum.Int).IncBy(1, time.Now()) // Type=Int → dynamic type *datum.Int
	found := store.FindMetricOrNil("requests_total", "demo_prog")
	fmt.Println(found.String())
}
```




Evidence:
- `internal/metrics/store.go:26` — `func NewStore() (s *Store) {` · `store.go:33` — `func (s *Store) Add(m *Metric) error {` · `store.go:101` — `func (s *Store) FindMetricOrNil(name, prog string) *Metric {`
- `internal/metrics/metric.go:100` — `func NewMetric(name string, prog string, kind Kind, typ Type, keys ...string) *Metric {`
- `internal/metrics/metric.go:151` — `func (m *Metric) GetDatum(labelvalues ...string) (d datum.Datum, err error) {` (body :162-180 creates `datum.NewInt()` + `AppendLabelValue` when absent)
- `internal/metrics/datum/datum.go:55` — `func NewInt() Datum {` → body calls `MakeInt(0, zeroTime)`; `datum.go:75` — `func MakeInt(v int64, ts time.Time) Datum {` with body `d := &Int{}` → dynamic type is `*datum.Int`
- `internal/metrics/datum/int.go:26` — `func (d *Int) IncBy(delta int64, timestamp time.Time) {`
- `internal/metrics/metric.go:298` — `func (m *Metric) String() string {`




### UC-2.2 — Dump the store: `Range` for exporters + `WriteMetrics` JSON




Scenario: you want to dump metric state periodically to stdout (like the
`-one_shot -one_shot_format json` branch of `cmd/mtail`), or feed the
store into your own monitoring system by walking every metric — `Range` is
exactly the loop the Prometheus exporter's `Collect` uses
(prometheus.go:36).




```go
package main

import (
	"bytes"
	"fmt"
	"os"

	"github.com/google/mtail/internal/metrics"
)

func dump(store *metrics.Store) error {
	err := store.Range(func(m *metrics.Metric) error {
		fmt.Printf("%s (prog=%s, kind=%v)\n", m.Name, m.Program, m.Kind)
		return nil // return an error to stop Range early
	})
	if err != nil {
		return err
	}
	var buf bytes.Buffer
	if err := store.WriteMetrics(&buf); err != nil {
		return err
	}
	_, err = buf.WriteTo(os.Stdout)
	return err
}
```




Evidence:
- `internal/metrics/store.go:141` — `func (s *Store) Range(f func(*Metric) error) error {`
- `internal/metrics/store.go:207` — `func (s *Store) WriteMetrics(w io.Writer) error {` (body: `json.MarshalIndent(s.Metrics, "", "  ")`)
- `internal/exporter/prometheus.go:36` — `e.store.Range(func(m *metrics.Metric) error {`




### UC-2.3 — Metric lifecycle: label-set limits, expiry, and the GC loop




Scenario: labels with free-form values (e.g. client ids) can make a metric
grow without bound. Set a `Limit` on the metric, mark a label set
(`"stale"`) to expire after 30 minutes (`ExpireDatum` records
`lv.Expiry`), force a `Gc()` pass now, and start `StartGcLoop` to GC
periodically until the context is cancelled — the lifecycle `cmd/mtail`
enables via `-expired_metric_gc_tick_interval` (cmd/mtail/main.go:229-231).




```go
package main

import (
	"context"
	"time"

	"github.com/google/mtail/internal/metrics"
)

func main() {
	store := metrics.NewStore()
	m := metrics.NewMetric("latency_ms", "demo_prog", metrics.Timer, metrics.Int, "client")
	if err := store.Add(m); err != nil { panic(err) }
	m.Limit = 1000 // Gc trims label sets beyond the limit
	if _, err := m.GetDatum("stale"); err != nil { panic(err) }
	// "stale" expires after 30 minutes without updates (sets lv.Expiry).
	if err := m.ExpireDatum(30*time.Minute, "stale"); err != nil { panic(err) }
	if err := store.Gc(); err != nil { panic(err) } // clean now: expired / over limit
	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()
	store.StartGcLoop(ctx, time.Minute) // periodic GC until ctx is cancelled
}
```




Evidence:
- `internal/metrics/metric.go:94` — field `Limit int` of `type Metric struct` (:84-97)
- `internal/metrics/store.go:156` — `func (s *Store) Gc() error {` (body :160-178: `m.Limit > 0 && len(m.LabelValues) >= m.Limit` → `RemoveOldestDatum`; `now.Sub(lv.Value.TimeUTC()) > lv.Expiry` → `RemoveDatum`)
- `internal/metrics/metric.go:223` — `func (m *Metric) ExpireDatum(expiry time.Duration, labelvalues ...string) error {` (body :227-235: `lv.Expiry = expiry`)
- `internal/metrics/metric.go:78` — field `Expiry time.Duration` of `type LabelValue struct` (:73-80)
- `internal/metrics/store.go:183` — `func (s *Store) StartGcLoop(ctx context.Context, duration time.Duration) {`
- `cmd/mtail/main.go:229` — `store.StartGcLoop(ctx, *expiredMetricGcTickInterval)` (grep inside the 228-231 block)




**Pulls in**: `internal/metrics` itself + `internal/metrics/datum` (the
item's only in-universe dependency) + stdlib. No other mtail package is
needed for the three use cases above.





## s02 — mtail (`internal/mtail`)




**What this item solves.** `Server` — the orchestration hub (mtail.go:31,
`New` :176): it owns the `metrics.Store`, the `tailer.Tailer` (log reading
→ the `lines` channel), the `runtime.Runtime` (program loading + VM
lifecycle) and the `exporter.Exporter`, and runs the HTTP server
(metrics/pprof/zpages). `options.go` defines the whole server `Option`
surface. Use it to embed the whole log→metric pipeline in your own Go
process — the way `cmd/mtail` does.




### UC-3.1 — Embed the mtail Server in a Go program with graceful shutdown




Scenario: your Go service needs to read logs itself and expose Prometheus
metrics. Instead of running a separate `mtail` binary, build the `Server`
in-process: `New(ctx, store, options...)` with `ProgramPath`,
`LogPathPatterns`, `BindAddress`, then `Run()` blocks until every
subroutine finishes; Ctrl-C/SIGTERM cancels the context for a clean
shutdown — the exact model of `cmd/mtail/main.go` (:159-165 signal
handling, :232 `mtail.New`, :238 `m.Run()`).




```go
package main

import (
	"context"
	"os"
	"os/signal"
	"syscall"

	"github.com/google/mtail/internal/metrics"
	"github.com/google/mtail/internal/mtail"
)

func main() {
	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()
	sigint := make(chan os.Signal, 1)
	signal.Notify(sigint, os.Interrupt, syscall.SIGTERM)
	go func() { <-sigint; cancel() }()
	store := metrics.NewStore()
	m, err := mtail.New(ctx, store,
		mtail.ProgramPath("/etc/mtail"),
		mtail.LogPathPatterns("/var/log/app/*.log"),
		mtail.BindAddress("127.0.0.1", "3903"),
	)
	if err != nil { panic(err) }
	if err := m.Run(); err != nil { panic(err) } // blocks until all subroutines finish
}
```




Evidence:
- `internal/mtail/mtail.go:176` — `func New(ctx context.Context, store *metrics.Store, options ...Option) (*Server, error) {`
- `internal/mtail/mtail.go:238` — `func (m *Server) Run() error {` (body :238-247: `m.wg.Wait(); m.cancel()`, early exit when compileOnly)
- `internal/mtail/options.go:27` — `type ProgramPath string` (apply :29 `func (opt ProgramPath) apply(m *Server) error`)
- `internal/mtail/options.go:38` — `func LogPathPatterns(patterns ...string) Option {` · `options.go:58` — `func BindAddress(address, port string) Option {`
- `cmd/mtail/main.go:169-175` — `opts := []mtail.Option{ mtail.ProgramPath(*progs), mtail.LogPathPatterns(logs...), ... }` · `main.go:232` — `m, err := mtail.New(ctx, store, opts...)` · `main.go:238` — `err = m.Run()` · `main.go:159-165` — `signal.Notify(sigint, os.Interrupt, syscall.SIGTERM)` + cancel goroutine




### UC-3.2 — CI validator: compile + dump bytecode for every program, nothing else




Scenario: the team's CI pipeline wants to block PRs that break `.mtail`
programs: build the Server with `CompileOnly` (no log tailing — `Run()`
returns right after every program compiles, mtail.go:241-244) and
`DumpBytecode` to print post-codegen bytecode into the CI log; `New`
returns an error on bad configuration, while per-file compile errors are
recorded by the runtime. The niladic options `CompileOnly`/`DumpBytecode`
are package-level variables (options.go:159-162, 185-188) — appended to
opts by `cmd/mtail` when `-compile_only`/`-dump_bytecode` are set.




```go
package main

import (
	"context"

	"github.com/google/mtail/internal/metrics"
	"github.com/google/mtail/internal/mtail"
)

// CI check: compile every .mtail in ./progs; a compile error → non-zero exit.
func main() {
	ctx := context.Background()
	m, err := mtail.New(ctx, metrics.NewStore(),
		mtail.ProgramPath("./progs"),
		mtail.CompileOnly,  // compile then exit (mtail.go:241-244)
		mtail.DumpBytecode, // print post-codegen bytecode for CI diffing
	)
	if err != nil {
		panic(err)
	}
	if err := m.Run(); err != nil {
		panic(err)
	}
}
```




Evidence:
- `internal/mtail/options.go:159-162` — `// CompileOnly sets compile-only mode in the Server.` + `var CompileOnly = &niladicOption{ ... m.rOpts = append(m.rOpts, runtime.CompileOnly())`
- `internal/mtail/options.go:185-188` — `// DumpBytecode instructs the Server's compiler to print the program bytecode after code generation.` + `var DumpBytecode = &niladicOption{ ... runtime.DumpBytecode()`
- `internal/mtail/mtail.go:241-244` — `if m.compileOnly { glog.Info("compile-only is set, exiting"); return nil }`
- `cmd/mtail/main.go:196-204` — `if *compileOnly { opts = append(opts, mtail.CompileOnly) }` … `if *dumpBytecode { opts = append(opts, mtail.DumpBytecode) }`
- `internal/mtail/options.go:141-144` — `type niladicOption struct { applyfunc func(m *Server) error ... }` (the parameterless-option mechanism)




### UC-3.3 — Process one log snapshot then exit (OneShot) for cron/CI




Scenario: you need metrics from a static log file (a fixture, an archive)
without keeping a Server running: `OneShot` makes the tailer read to EOF
and finish, `Run()` blocks only until every subroutine is done, and the
store then holds the run's metrics — dump them as JSON with
`WriteMetrics` (the `-one_shot` model of `cmd/mtail`, main.go:245-249).




```go
package main

import (
	"context"
	"os"

	"github.com/google/mtail/internal/metrics"
	"github.com/google/mtail/internal/mtail"
)

// Snapshot: process everything currently in the log, then exit — for cron/CI.
func main() {
	ctx := context.Background()
	store := metrics.NewStore()
	m, err := mtail.New(ctx, store,
		mtail.ProgramPath("./progs"),
		mtail.LogPathPatterns("./fixtures/access.log"),
		mtail.OneShot, // tailer reads to EOF then finishes (options.go:148-152)
	)
	if err != nil { panic(err) }
	if err := m.Run(); err != nil { panic(err) } // blocks until the tailer is done (wg.Wait)
	store.WriteMetrics(os.Stdout) // this snapshot's metrics, JSON format
}
```




Evidence:
- `internal/mtail/options.go:148-152` — `// OneShot sets one-shot mode in the Server.` + `var OneShot = &niladicOption{ ... m.tOpts = append(m.tOpts, tailer.OneShot)`
- `internal/mtail/mtail.go:238-239` — `func (m *Server) Run() error { m.wg.Wait() ...` (Run blocks until all subroutines finish)
- `internal/metrics/store.go:207` — `func (s *Store) WriteMetrics(w io.Writer) error {`
- `cmd/mtail/main.go:245-246` — `if *oneShot {` (the post-Run metric-export branch, grep inside the 225-245 block)




**Pulls in**: `internal/mtail` itself + `internal/metrics` (the mandatory
`mtail.New` parameter). The other components (tailer/runtime/exporter/
waker) are constructed inside `New` through option application — you do
not import them directly.





## s04 — vm (`internal/runtime/vm`)




**What this item solves.** The bytecode interpreter: `New(code.Object)`
builds a VM from a compiled program (regex/string constants, metrics),
`ProcessLogLine` runs the fetch–decode–execute loop updating metric
values. Build, test or debug bytecode by hand, or run the VM as a channel
consumer — the role the runtime gives it in the real pipeline.




### UC-4.1 — Hand-build bytecode and run it: match a log line, bump a counter




Scenario: build a 6-instruction program without any `.mtail` file:
`Match` the regex `level=error` (pushes a bool), `Jnm` jumps to `Stop` on
no match, `Mload` pushes the zero-key metric onto the stack, `Dload`
fetches the datum, `Inc` increments, `Stop` ends the turn. Run one log
line through `ProcessLogLine` and read the counter from the metric — the
opcodes and stack semantics are readable straight from the source (vm.go:732
`Mload` pushes `v.Metrics[operand]`; :736 `Dload` pops metric + keys →
`m.GetDatum(keys...)`; :473 `Inc` pops the datum then `datum.IncIntBy`).




```go
package main

import ("context"; "regexp"; "time"
	"github.com/google/mtail/internal/logline"
	"github.com/google/mtail/internal/metrics"
	"github.com/google/mtail/internal/runtime/code"
	"github.com/google/mtail/internal/runtime/vm")

func main() {
	ctx := context.Background()
	m := metrics.NewMetric("error_lines_total", "hand_prog", metrics.Counter, metrics.Int)
	obj := &code.Object{
		Regexps: []*regexp.Regexp{regexp.MustCompile(`level=error`)},
		Metrics: []*metrics.Metric{m},
		Program: []code.Instr{
			{Opcode: code.Match, Operand: 0}, // match Regexps[0], push bool
			{Opcode: code.Jnm, Operand: 5},   // no match → pc 5 (Stop)
			{Opcode: code.Mload, Operand: 0}, // push Metrics[0]
			{Opcode: code.Dload, Operand: 0}, // push zero-key datum
			{Opcode: code.Inc, Operand: nil}, // datum++
			{Opcode: code.Stop, Operand: nil},
		},
	}
	v := vm.New("hand_prog", obj, false, time.UTC, false, false)
	v.ProcessLogLine(ctx, logline.New(ctx, "app.log", `level=error msg="boom"`))
	println(obj.Metrics[0].String())
}
```




Evidence:
- `internal/runtime/code/object.go:13-18` — `type Object struct { Program []Instr; Strings []string; Regexps []*regexp.Regexp; Metrics []*metrics.Metric }`
- `internal/runtime/code/instr.go:9-13` — `type Instr struct { Opcode Opcode; Operand interface{}; SourceLine int }`
- `internal/runtime/code/opcodes.go:11-42` — `Stop` :11, `Match` :12, `Inc` :18, `Mload` :41 ("Load metric at operand onto top of stack"), `Dload` :42 ("Pop `operand` keys and metric off stack, and push datum at metric[key,...] onto stack")
- `internal/runtime/vm/vm.go:732-733` — `case code.Mload:` → `t.Push(v.Metrics[i.Operand.(int)])` · `vm.go:736-760` — `case code.Dload:` → pops metric + keys then `m.GetDatum(keys...)` pushes the datum
- `internal/runtime/vm/vm.go:444-450` — `case code.Jnm:` → `if !match { t.pc = i.Operand.(int) }` (jumps when match=false)
- `internal/runtime/vm/vm.go:473-488` — `case code.Inc:` → pops `datum.Datum` then `datum.IncIntBy(n, delta, t.time)`
- `internal/runtime/vm/vm.go:993` — `func New(name string, obj *code.Object, syslogUseCurrentYear bool, loc *time.Location, log bool, trace bool) *VM {` (body 994-1009: `re: obj.Regexps, str: obj.Strings, Metrics: obj.Metrics, prog: obj.Program`)
- `internal/runtime/vm/vm.go:962` — `func (v *VM) ProcessLogLine(_ context.Context, line *logline.LogLine) {` (body: new thread, `for { if t.pc >= len(v.prog) { return } ... v.execute(t, i); if v.terminate { ... return } }`)
- `internal/logline/logline.go:17` — `func New(ctx context.Context, filename string, line string) *LogLine {`
- `internal/metrics/metric.go:100` — `func NewMetric(name string, prog string, kind Kind, typ Type, keys ...string) *Metric {`
- The canonical test building programs the same way: `internal/runtime/vm/vm_test.go:19` `var instructions = []struct { ... i code.Instr ...}` (table-driven, 7 Test* functions; the largest test file is 929 lines).




### UC-4.2 — Debug bytecode: `DumpByteCode`, PC tracing, and the runtime error string




Scenario: the program compiles but behaves wrong: set `trace=true` so the
VM records each PC step, print `DumpByteCode()` (the program
disassembly + constants) to compare, and after processing a log line read
`RuntimeErrorString()` — panics inside `execute()` are recovered into a
runtime error instead of crashing the process (vm.go:336-350, recover at
:339).




```go
package main

import (
	"context"
	"fmt"
	"time"

	"github.com/google/mtail/internal/logline"
	"github.com/google/mtail/internal/runtime/code"
	"github.com/google/mtail/internal/runtime/vm"
)

// obj: the code.Object from UC 4.1 (or from compiler.Compile).
func debug(obj *code.Object) {
	ctx := context.Background()
	// log=true prints runtime errors; trace=true records each PC step.
	v := vm.New("prog", obj, false, time.UTC, true, true)
	fmt.Println(v.DumpByteCode()) // disassembly + constants for diffing
	v.ProcessLogLine(ctx, logline.New(ctx, "app.log", `level=error`))
	if s := v.RuntimeErrorString(); s != "" {
		fmt.Println("runtime error:", s) // a panic in execute, recovered
	}
}
```




Evidence:
- `internal/runtime/vm/vm.go:993` — `func New(..., log bool, trace bool) *VM {` (body :1005-1008: `if trace { v.trace = make([]int, 0, len(v.prog)) }`)
- `internal/runtime/vm/vm.go:1012` — `func (v *VM) DumpByteCode() string {`
- `internal/runtime/vm/vm.go:1043` — `func (v *VM) RuntimeErrorString() string {`
- `internal/runtime/vm/vm.go:339` — `if r := recover(); r != nil {` (inside `execute`, :336-350 — the panic→runtime-error recover block)
- `internal/runtime/vm/vm.go:973-974` — inside `ProcessLogLine`: `if v.trace != nil { v.trace = append(v.trace, t.pc) }`




### UC-4.3 — Run the VM as a channel consumer (the real pipeline wiring)




Scenario: instead of calling `ProcessLogLine` per line, run
`VM.Run(lines, &wg)` in its own goroutine: the VM ranges over the channel
until it is closed, then `wg.Done` — exactly how `internal/runtime` wires
VMs into the tailer's log-line pipeline; you close the channel to shut the
VM down cleanly.




```go
package main

import (
	"context"
	"sync"

	"github.com/google/mtail/internal/logline"
	"github.com/google/mtail/internal/runtime/vm"
)

// v: a *vm.VM from UC 4.1/4.2 — running as a channel consumer.
func feed(v *vm.VM, lines []string) {
	ch := make(chan *logline.LogLine, 8)
	var wg sync.WaitGroup
	wg.Add(1)
	go v.Run(ch, &wg) // Run exits when ch closes (defer wg.Done)
	ctx := context.Background()
	for _, l := range lines {
		ch <- logline.New(ctx, "app.log", l)
	}
	close(ch)
	wg.Wait()
}
```




Evidence:
- `internal/runtime/vm/vm.go:1052-1060` — `func (v *VM) Run(lines <-chan *logline.LogLine, wg *sync.WaitGroup) { defer wg.Done() ... for line := range lines { v.ProcessLogLine(ctx, line) } }`
- `internal/logline/logline.go:9-14` — `type LogLine struct { Context context.Context; Filename string; Line string }` · `logline.go:17` — `func New(...)`




**Pulls in**: `internal/runtime/vm` itself + `internal/runtime/code` (m14),
`internal/metrics` (m07), `internal/logline` (m18) — exactly the vm item's
imports (datum arrives via metrics).





## s06 — exporter (`internal/exporter`)




**What this item solves.** "Getting metrics out of mtail into your
monitoring system of choice": the `Exporter` reads a `*metrics.Store` and
ships metrics in three shapes — (1) a Prometheus collector
(`Describe`/`Collect`) you register with a `prometheus.Registry` for
scraping, (2) HTTP handlers in other formats (`/varz`, `/json`,
`/graphite`), (3) periodic push to collectd/graphite/statsd targets.
Configured via `Option` (`Hostname`, `OmitProgLabel`, `EmitTimestamp`,
`PushInterval`, `DisableExport`) — give it any filled `metrics.Store` and
it moves the numbers out, with no compile/tail machinery involved.




### UC-06.1 — Plug a Store into a Prometheus scrape endpoint




Scenario: you embedded mtail's runtime in your own Go service; the VM has
been filling a `metrics.Store`. To let Prometheus scrape it: build an
`Exporter` on the store, register it as a `prometheus.Collector` on your
own registry, mount `/metrics` with `promhttp` — the exact model
`internal/mtail/mtail.go` uses internally.




```go
package main

import (
	"context"
	"net/http"

	"github.com/google/mtail/internal/exporter"
	"github.com/google/mtail/internal/metrics"
	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promhttp"
)

func main() {
	ctx := context.Background()
	store := metrics.NewStore() // the VM/runtime fills this store

	e, err := exporter.New(ctx, store)
	if err != nil {
		panic(err) // nil store → ErrNeedsStore
	}

	reg := prometheus.NewRegistry() // a non-pedantic registry, like mtail's
	reg.MustRegister(e)             // Exporter implements prometheus.Collector

	http.Handle("/metrics", promhttp.HandlerFor(reg, promhttp.HandlerOpts{}))
	panic(http.ListenAndServe(":3903", nil))
}
```




Evidence:
- `internal/exporter/export.go:91` — `func New(ctx context.Context, store *metrics.Store, options ...Option) (*Exporter, error) {`; `:92-94` nil store → `ErrNeedsStore`.
- `internal/exporter/export.go:32` — `type Exporter struct {`.
- `internal/exporter/prometheus.go:26` — `func (e *Exporter) Describe(c chan<- *prometheus.Desc) {`; `:31` — `func (e *Exporter) Collect(c chan<- prometheus.Metric) {`; `:36` — `e.store.Range(func(m *metrics.Metric) error {` (Collect walks the store via Range).
- Canonical real wiring: `internal/mtail/mtail.go:72` `m.e, err = exporter.New(m.ctx, m.store, m.eOpts...)`; `:76` `m.reg.MustRegister(m.e)`; `mtail.go:176-186` `New` builds `m := &Server{ ... reg: prometheus.NewRegistry() ...}` (the "non-pedantic registry" comment); `mtail.go:120` `mux.Handle("/metrics", promhttp.HandlerFor(m.reg, promhttp.HandlerOpts{}))`.
- `internal/metrics/store.go:26` — `func NewStore() (s *Store) {`.




### UC-06.2 — One-shot dump of the whole Store to stdout




Scenario: run a one-off log-processing job (debug/batch); after the VM is
done you want every current metric value printed to stdout in Prometheus
exposition format, then exit — the `-one_shot -one_shot_format prometheus`
path of `cmd/mtail`.




```go
func oneShotDump(ctx context.Context, store *metrics.Store) error {
	e, err := exporter.New(ctx, store)
	if err != nil {
		return err
	}
	defer e.Stop() // wait for the export goroutines to finish

	// VM/runtime has processed the logs; dump the store state to stdout
	// in Prometheus exposition format.
	return e.Write(os.Stdout)
}
```




Evidence:
- `internal/exporter/prometheus.go:102` — `func (e *Exporter) Write(w io.Writer) error {`.
- `internal/exporter/export.go` — `func (e *Exporter) Stop(...)` stops the push goroutines started by `New` (the `-one_shot` branch of `cmd/mtail` calls `New` → process logs → `Write` → `Stop`; cmd/mtail/main.go:245-277).




### UC-06.3 — Mount the varz/json/graphite handlers on your own mux + tune Options




Scenario: your service already has an HTTP mux and you want mtail only as
the "exporter": serve `/varz` (expvar text), `/json` (a JSON store
snapshot), `/graphite` (graphite format) on that mux; fix the metric
hostname, drop the `prog` label, and emit timestamps — all via the
package's `Option` constructors.




```go
func mountExporter(ctx context.Context, store *metrics.Store) error {
	e, err := exporter.New(ctx, store,
		exporter.Hostname("logsrv-01"),
		exporter.OmitProgLabel(),
		exporter.EmitTimestamp())
	if err != nil {
		return err
	}

	mux := http.NewServeMux()
	mux.HandleFunc("/varz", http.HandlerFunc(e.HandleVarz))
	mux.HandleFunc("/json", http.HandlerFunc(e.HandleJSON))
	mux.HandleFunc("/graphite", http.HandlerFunc(e.HandleGraphite))
	return http.ListenAndServe(":3903", mux)
}
```




Evidence:
- `internal/exporter/export.go:51` — `func Hostname(hostname string) Option {`; `:59` — `func OmitProgLabel() Option {`; `:67` — `func EmitTimestamp() Option {`.
- `internal/exporter/varz.go:21` — `func (e *Exporter) HandleVarz(w http.ResponseWriter, r *http.Request) {`; `internal/exporter/json.go:17` — `func (e *Exporter) HandleJSON(w http.ResponseWriter, _ *http.Request) {`; `internal/exporter/graphite.go:29` — `func (e *Exporter) HandleGraphite(w http.ResponseWriter, r *http.Request) {`.
- Canonical real wiring: `internal/mtail/mtail.go:116` `mux.HandleFunc("/varz", http.HandlerFunc(m.e.HandleVarz))`; `:121` `/json` → `m.e.HandleJSON`; `:122` `/graphite` → `m.e.HandleGraphite`.
- Other ready-made Options (not used in the example, listed for
  reference): `export.go:74` `func PushInterval(opt time.Duration) Option`;
  `export.go:81` `func DisableExport() Option`.




**Pulls in**: `internal/metrics` (m07) — mandatory, the `New` parameter
(export.go:91; nil → `ErrNeedsStore` export.go:92-94); `internal/metrics/datum`
(m09) — indirectly via `metrics.Metric`; external
`github.com/prometheus/client_golang` (registry / promhttp, as
mtail.go:120 and mtail.go:76 use); stdlib `context`, `net/http`, `os`, `io`.





## s08 — tailer (`internal/tailer`)




**What this item solves.** The pipeline's input side: `Tailer` "polls the
filesystem for log sources that match given `LogPathPatterns` and creates
`LogStream`s to tail them" (tail.go:28-29) — tail one exact pathname
(`TailPath`) or watch a glob pattern to auto-tail new files (`AddPattern`
→ `pollLogPattern`); every line read is pumped onto a shared
`lines chan<- *logline.LogLine` for the consumer side (VM/runtime). Poll
frequency is controlled through `waker.Waker` options, plus an HTML status
page (`WriteStatusHTML`) and regex-based ignore filtering for globbing.




### UC-08.1 — Tail exactly one file and consume its lines




Scenario: a Go process wants to follow `/var/log/myapp.log` and handle
each line itself (e.g. push to its own queue) — no `.mtail` programs
involved. Build a channel + WaitGroup + a timed waker, call `TailPath`,
then `range` over the channel; each element is a `*logline.LogLine` with
`Filename`/`Line`.




```go
func tailOne(ctx context.Context) error {
	lines := make(chan *logline.LogLine, 1024)
	var wg sync.WaitGroup
	ctx, cancel := context.WithCancel(ctx)
	defer cancel()

	wk := waker.NewTimed(ctx, 250*time.Millisecond)
	t, err := tailer.New(ctx, &wg, lines,
		tailer.LogstreamPollWaker(wk),
		tailer.LogPatternPollWaker(wk))
	if err != nil {
		return err
	}
	if err := t.TailPath("/var/log/myapp.log"); err != nil {
		return err
	}
	for line := range lines {
		glog.Infof("%s: %s", line.Filename, line.Line)
	}
	return nil
}
```




Evidence:
- `internal/tailer/tail.go:30` — `type Tailer struct {`; `:119` — `func New(ctx context.Context, wg *sync.WaitGroup, lines chan<- *logline.LogLine, options ...Option) (*Tailer, error) {`; `:120-122` nil channel → `ErrNoLinesChannel`; `:123-125` nil wg → `ErrNeedsWaitgroup`.
- `internal/tailer/tail.go:86` — `func LogPatternPollWaker(w waker.Waker) Option {`; `:100` — `func LogstreamPollWaker(w waker.Waker) Option {`.
- `internal/tailer/tail.go:256` — `func (t *Tailer) TailPath(pathname string) error {`; `:263` calls `logstream.New(...)`; `:273-274` `for line := range l.Lines() { t.lines <- line }` (lines flow into the `lines` channel).
- `internal/logline/logline.go:9-14` — `type LogLine struct { Context context.Context; Filename string; Line string }`; `:17` — `func New(ctx, filename, line)`.
- `internal/waker/timedwaker.go:22` — `func NewTimed(ctx context.Context, interval time.Duration) Waker`.
- Canonical real wiring: `internal/mtail/mtail.go:91` `m.t, err = tailer.New(m.ctx, &m.wg, m.lines, m.tOpts...)`.




### UC-08.2 — Watch a glob pattern: new files are tailed automatically + the status page




Scenario: your application rotates logs (`app-2026-02-26.log`,
`app-2026-02-27.log`, …). Instead of tailing each file, register one glob
pattern — `pollLogPattern` is a permanent goroutine polling on the waker,
and new matching files get tailed automatically; at the same time you want
the status page (patterns + the logstream table) periodically in your log
to watch opens/truncs/errors/lines.




```go
func watchDir(ctx context.Context, pattern string) error {
	lines := make(chan *logline.LogLine, 1024)
	var wg sync.WaitGroup
	ctx, cancel := context.WithCancel(ctx)
	defer cancel()

	wk := waker.NewTimed(ctx, time.Second)
	t, err := tailer.New(ctx, &wg, lines,
		tailer.LogPatternPollWaker(wk),
		tailer.LogstreamPollWaker(wk))
	if err != nil {
		return err
	}
	if err := t.AddPattern(pattern); err != nil {
		return err
	}
	var sb strings.Builder
	if err := t.WriteStatusHTML(&sb); err != nil {
		return err
	}
	glog.Info(sb.String())
	for line := range lines {
		_ = line // handle the log line here
	}
	return nil
}
```




Evidence:
- `internal/tailer/tail.go:186` — `func (t *Tailer) AddPattern(pattern string) error {`.
- `internal/tailer/tail.go:288-289` — comment "pollLogPattern runs a permanent goroutine to poll for new log files" + `func (t *Tailer) pollLogPattern(pattern string) {`; `:321` — `func (t *Tailer) doPatternGlob(pattern string) error {`.
- `internal/tailer/httpstatus.go:44` — `func (t *Tailer) WriteStatusHTML(w io.Writer) error {`.




### UC-08.3 — Keep rotated (compressed .gz) files out of globbing




Scenario: the `*.log` pattern's directory also holds compressed
`app.log.gz` files; tailing them would replay old data. `SetIgnorePattern`
takes a regex applied to the **file name**, and `doPatternGlob` calls
`t.Ignore(pathname)` to skip every matching path before creating a
logstream.




```go
func tailIgnoringRotated(ctx context.Context, pattern string) error {
	lines := make(chan *logline.LogLine, 1024)
	var wg sync.WaitGroup
	wk := waker.NewTimed(ctx, time.Second)
	t, err := tailer.New(ctx, &wg, lines,
		tailer.LogPatternPollWaker(wk),
		tailer.LogstreamPollWaker(wk))
	if err != nil {
		return err
	}
	// Skip rotated compressed files: doPatternGlob calls t.Ignore(pathname)
	if err := t.SetIgnorePattern(`\.gz$`); err != nil {
		return err
	}
	return t.AddPattern(pattern)
}
```




Evidence:
- `internal/tailer/tail.go:240` — `func (t *Tailer) SetIgnorePattern(pattern string) error {` (compiles the regex into `t.ignoreRegexPattern`).
- `internal/tailer/tail.go:222` — `func (t *Tailer) Ignore(pathname string) bool {`; `:239` — `return t.ignoreRegexPattern != nil && t.ignoreRegexPattern.MatchString(fi.Name())` (matches on the file name).
- `internal/tailer/tail.go:328` — `if t.Ignore(pathname) {` — the call site inside `doPatternGlob`.




**Pulls in**: `internal/logline` (m18) — mandatory, the `lines` channel
type (tail.go:119; logline.go:9-14); `internal/tailer/logstream` (m03) —
pulled in when `TailPath` runs (tail.go:263 `logstream.New`); no direct
import needed in the examples; `internal/waker` (m11) — mandatory via the
two `LogPatternPollWaker`/`LogstreamPollWaker` options (tail.go:86/:100);
stdlib `context`, `sync`, `time`, `strings`.





## s09 — datum (`internal/metrics/datum`)




**What this item solves.** The metric value types: interface `Datum`
(`ValueString`/`TimeString`/`TimeUTC` — datum.go:15) + implementations
`Int`, `Float`, `String`, `Buckets` (histogram), all stamped with atomic
nanosecond-UTC timestamps (`BaseDatum.stamp`, :36-40). Use it when you
want a uniform value+timestamp mechanism — it imports nothing from the
rest of the module (bottom of the dependency graph).




### UC-09.1 — Create and update int/float datums with timestamps




Scenario: you are building a small exporter of your own (outside mtail)
and want to reuse mtail's "value + timestamp" mechanism for counters:
create a zero datum via the constructor, increment/assign (a zero
timestamp auto-stamps "now" via `BaseDatum.stamp`), then read back both
the raw value and the value string for rendering.




```go
func typedDatums(ts time.Time) {
	di := datum.NewInt().(*datum.Int) // zero int datum
	di.IncBy(3, time.Time{})          // zero ts => stamped "now"
	glog.Infof("int: get=%d value=%q", di.Get(), di.ValueString())

	df := datum.NewFloat().(*datum.Float)
	df.Set(2.5, ts)
	glog.Infof("float: get=%v value=%q", df.Get(), df.ValueString())

	// Or build a datum directly with a value+timestamp:
	dm := datum.MakeInt(7, ts)
	glog.Infof("made int: get=%d", dm.(*datum.Int).Get())
}
```




Evidence:
- `internal/metrics/datum/datum.go:55` — `func NewInt() Datum {`; `:60` — `func NewFloat() Datum {`; `:65` — `func NewString() Datum {`; `:70` — `func NewBuckets(buckets []Range) Datum {`.
- `internal/metrics/datum/datum.go:36-40` — `func (d *BaseDatum) stamp(timestamp time.Time)`: `timestamp.IsZero()` → `atomic.StoreInt64(&d.Time, time.Now().UTC().UnixNano())`, otherwise stamps the given ts.
- `internal/metrics/datum/int.go:14` — `type Int struct {`; `:26` — `func (d *Int) IncBy(delta int64, timestamp time.Time) {`; `:38` — `func (d *Int) Get() int64`; `:43` — `func (d *Int) ValueString() string`.
- `internal/metrics/datum/float.go:15` — `type Float struct {`; `:26` — `func (d *Float) Set(v float64, ts time.Time) {`; `:32` — `func (d *Float) Get() float64`; `:21` — `func (d *Float) ValueString() string`.
- `internal/metrics/datum/datum.go:75` — `func MakeInt(v int64, ts time.Time) Datum {`.




### UC-09.2 — Histograms via Buckets + Range




Scenario: measure the latency of an operation with coarse binning: create
`Buckets` from a list of `Range{Min, Max}`, feed observations with
`Observe` (binning is automatic via `Range.Contains`), then read the
summary — observation count, sum, and the bin→count map — to render
yourself or feed into another metrics system.




```go
func latencyHistogram(ts time.Time) {
	d := datum.NewBuckets([]datum.Range{
		{Min: 0, Max: 10},
		{Min: 10, Max: 100},
		{Min: 100, Max: 1000},
	})
	b := d.(*datum.Buckets)

	b.Observe(42, ts)   // lands in bin [10,100]
	b.Observe(1234, ts) // lands in bin [100,1000]

	glog.Infof("count=%d sum=%v value=%q", b.GetCount(), b.GetSum(), b.ValueString())
	for r, count := range b.GetBuckets() {
		glog.Infof("bin (%v,%v]: %d", r.Min, r.Max, count)
	}
}
```




Evidence:
- `internal/metrics/datum/datum.go:70` — `func NewBuckets(buckets []Range) Datum {`.
- `internal/metrics/datum/buckets.go:15` — `type Range struct { Min float64; Max float64 }` (2 fields, sed-verified); `:25` — `func (r *Range) Contains(v float64) bool { return r.Min < v && v <= r.Max }`.
- `internal/metrics/datum/buckets.go:30` — `type Buckets struct {`; `:42` — `func (d *Buckets) Observe(v float64, ts time.Time) {`; `:59` — `func (d *Buckets) GetCount() uint64`; `:65` — `func (d *Buckets) GetSum() float64`; `:79` — `func (d *Buckets) GetBuckets() map[Range]uint64`.




### UC-09.3 — String datum (free-text metric) + uniform timestamp reading through the interface




Scenario: you need a "latest text value" metric (e.g. the upstream
currently in use) and want every datum kind to expose its timestamp the
same way: keep the `Datum` in a shared map, fill a `String` datum, then
read `ValueString()`/`TimeString()`/`TimeUTC()` — exactly the interface
triple `Datum` declares.




```go
func stringDatumDemo(ts time.Time) {
	d := datum.NewString()            // keep the Datum interface type
	ds := d.(*datum.String)           // type-assert to Set
	ds.Set("upstream=A", ts)

	// Read through the Datum interface (ValueString/TimeString/TimeUTC):
	var as datum.Datum = ds
	glog.Infof("value=%q ts=%s utc=%v",
		as.ValueString(), as.TimeString(), as.TimeUTC())
}
```




Evidence:
- `internal/metrics/datum/datum.go:15` — `type Datum interface {`; `:20` — `ValueString() string`; `:23` — `TimeString() string`; `:26` — `TimeUTC() time.Time`.
- `internal/metrics/datum/datum.go:30` — `type BaseDatum struct {`; `:31` — `Time int64 // nanoseconds since unix epoch`; `:45` — `func (d *BaseDatum) TimeString() string`; `:49` — `func (d *BaseDatum) TimeUTC() time.Time`.
- `internal/metrics/datum/string.go:14` — `type String struct {`; `:21` — `func (d *String) Set(value string, timestamp time.Time) {`; `:29` — `func (d *String) Get() string`; `:36` — `func (d *String) ValueString() string`.




**Pulls in**: nothing from the module (imports are stdlib only — `fmt`,
`math`, `sort`, `sync/atomic`, `time`, datum.go:6-12) — fully independent.
Consumers: `metrics` (m07) holds datums inside `Metric`; exporter, vm,
compiler and golden all import it — e.g. UC-06.1's `Collect` walks the
store via `Range` and renders `Datum` values. Stdlib: `time`.





## s11 — waker (`internal/waker`)




**What this item solves.** The `Waker` synchronization interface
(waker.go:7) — a `Wake()` channel that is closed when an idle routine
should wake — with three implementations: `timedWaker` (periodic ticker
wake-ups, for production), `testWaker` (controlled test synchronization
with a `WakeFunc`) and `alwaysWaker` (a pre-closed channel, never blocks).
It is the "idle loop ↔ waker" seam: mtail's tailer/logstream block on
`<-w.Wake()` instead of hard-sleeping, so the same loop runs in production
(ticker) and in tests (controlled wake-ups).




### UC-11.1 — Idle worker loop woken periodically (timedWaker)




Scenario: a background goroutine of yours is idle most of the time but
must re-check state (fs, deadlines, caches) on a schedule. Instead of a
hard `time.Sleep`, block on `<-w.Wake()`: `timedWaker` closes the wake
channel after each tick; cancelling the context exits the whole loop (the
waker stops its ticker when ctx is cancelled).




```go
func pollLoop(ctx context.Context) {
	ctx, cancel := context.WithCancel(ctx)
	defer cancel()

	w := waker.NewTimed(ctx, 250*time.Millisecond)
	for {
		select {
		case <-ctx.Done():
			return
		case <-w.Wake(): // the channel is closed once per tick
			refreshState() // the pending work: re-read fs, re-check deadlines…
		}
	}
}
```




Evidence:
- `internal/waker/waker.go:7` — `type Waker interface {`; `:9` — `Wake() <-chan struct{}` (comment ":8 // Wake returns a channel that's closed when the idle routine should wake up.").
- `internal/waker/timedwaker.go:22` — `func NewTimed(ctx context.Context, interval time.Duration) Waker` (the goroutine stops when ctx is cancelled, `defer t.t.Stop()` :27-28); `:45-49` — `func (t *timedWaker) Wake() (w <-chan struct{})`.
- Canonical consumption pattern: `internal/tailer/logstream/filestream.go:230-231` — `case <-waker.Wake():` / comment `// sleep until next Wake()`; `internal/tailer/tail.go:310` — `case <-t.logPatternPollWaker.Wake():`.




### UC-11.2 — A waker that never blocks, for one-shot/test loops




Scenario: you are writing a drain-once loop or a simple test that needs no
synchronization: use `NewTestAlways` — `alwaysWaker` returns a channel
already `close`d in its constructor, so `select` never blocks and every
loop iteration runs immediately, with no tick wait.




```go
func busyDrain() {
	w := waker.NewTestAlways()
	// alwaysWaker "never blocks the wakee": the wake channel is
	// pre-closed, so the select below always takes the Wake() branch.
	for i := 0; i < 3; i++ {
		select {
		case <-w.Wake():
			processOne()
		default:
			// never reached with alwaysWaker
		}
	}
}
```




Evidence:
- `internal/waker/testwaker.go:124` — comment `// alwaysWaker never blocks the wakee.`; `:125` — `type alwaysWaker struct { wake chan struct{} }`.
- `internal/waker/testwaker.go:129-134` — `func NewTestAlways() Waker { … close(w.wake); return w }` (closed right in the constructor); `:137-139` — `func (w *alwaysWaker) Wake() <-chan struct{} { return w.wake }`.




### UC-11.3 — Implement your own Waker (close-and-reset) + testWaker for synchronized tests




Scenario: one of your components wants mtail's exact waker model but the
signal comes from your own event (not a ticker): implement the `Waker`
interface following `timedWaker`'s close-and-reset pattern —
`close(wake)` wakes everyone blocked, then a fresh channel serves the next
cycle. In tests, use the ready-made `NewTest` to synchronize precisely
when the goroutine under test calls `Wake()`.




```go
type signalWaker struct {
	mu   sync.Mutex
	wake chan struct{}
}

func newSignalWaker() *signalWaker { return &signalWaker{wake: make(chan struct{})} }

func (s *signalWaker) Wake() <-chan struct{} {
	s.mu.Lock()
	defer s.mu.Unlock()
	return s.wake
}

func (s *signalWaker) Signal() {
	s.mu.Lock()
	close(s.wake)
	s.wake = make(chan struct{}) // close-and-reset like timedWaker
	s.mu.Unlock()
}
```




Evidence:
- `internal/waker/waker.go:7-10` — the interface to implement: `type Waker interface { Wake() <-chan struct{} }`.
- The original close-and-reset pattern: `internal/waker/timedwaker.go:34-38` — `t.mu.Lock(); close(t.wake); t.wake = make(chan struct{}); t.mu.Unlock()`; the same pattern in tests: `internal/waker/testwaker.go:115-122` — `func (t *testWaker) broadcastWakeAndReset() { … close(t.wake); t.wake = make(chan struct{}) … }`.
- testWaker for tests: `internal/waker/testwaker.go:37` — `type WakeFunc func(int, int)` (parameters: how many wakees to wake, how many wakees are waiting to call Wake); `:42` — `func NewTest(ctx context.Context, wait int, name string) (Waker, WakeFunc)`.




**Pulls in**: nothing from the module (only stdlib `context`, `sync`,
`time` + `github.com/golang/glog`) — fully independent. Consumers:
logstream (m03), tailer (m08), mtail (m02), cmd/mtail (m12) — see UC-08.1
(the tailer's two waker Options) and UC-11.1 (the `<-w.Wake()` pattern in
filestream.go:230).
