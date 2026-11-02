---
subject: google/pprof
measured_at: dbd0ed30aa888a30e21ba83b9831ac0e80d41022
status: final
---

# Usage — hands-on recipes

23 use cases across the 8 reusable packages, each with API evidence
grep-verified on the pin. Honest build note: the recipes were verified by
reading the source at the pin (every `file:line` anchor below), not by
compiling — the measurement environment had no Go toolchain. Build
commands are stated per item as facts from `go.mod` (root module
`github.com/google/pprof`, `go 1.26.0`).

> **Visibility note:** the `internal/*` packages are Go internal packages
> — recipes that import `internal/report`, `internal/binutils`,
> `internal/graph`, `internal/elfexec`, `internal/symbolizer` or
> `internal/measurement` compile **only inside the module
> `github.com/google/pprof`** (go.mod:1) or inside a fork that renames the
> module. Only `profile` (s01) is a public package importable from
> anywhere, and `browsertests` (s08) is its own Go module (separate
> go.mod + `replace ../`).

## Summary — what to reach for

| item | module | use it when | imported by (non-test) |
|---|---|---|---|
| s01 | profile | The central library — in-memory representation of profile.proto: decode `Parse`/`ParseData` (with validation), encode `Write`, merge `Merge`, normalize `Aggregate`, snapshot `Copy`; use it to read/write/merge/serialize pprof files from Go code (the go-fuzz harness does nothing but feed bytes into `ParseData`). | browsertests, driver, fuzz, graph, internal/driver, measurement, plugin, report, symbolizer, symbolz |
| s03 | report | Turn a `*profile.Profile` into a reader-facing report — `Generate` with the 12 output formats (Callgrind/Comments/Dis/Dot/List/Proto/Raw/Tags/Text/TopProto/Traces/Tree/WebList) + annotated source `printSource`; use it to render top/list/proto/dot… inside the pprof module. | internal/driver |
| s04 | binutils | Implements `plugin.ObjTool` — locates external tools (llvm-symbolizer/addr2line/nm/objdump), opens ELF/Mach-O(fat)/PE by magic number, maps runtime addresses → symbol/file:line, `Disasm` via objdump; use it to resolve binary addresses to functions/lines or disassemble inside the symbolization pipeline. | internal/driver, symbolizer |
| s05 | graph | Build a directed graph from a profile (`New` per `Options.SampleValue`), prune it (`TrimTree`, `DiscardLowFrequencyNodes`, `RemoveRedundantEdges`), export DOT (`ComposeDot`); use it to rank heavy functions yourself, clean the graph, or feed Graphviz. | internal/driver, report |
| s06 | elfexec | ELF utilities for the binutils layer — `GetBase`/`GetBuildID`/`FindTextProgHeader`/`ProgramHeadersForMapping`/`HeaderForFileOffset`; reach it through `binutils`, its only consumer. | binutils |
| s07 | symbolizer | Fill symbols into the profile over two paths (local binutils / HTTP symbolz) plus `Demangle`; wire it as the `plugin.Symbolize` implementation of a driver `Options`. | internal/driver |
| s08 | browsertests | A separate Go module running the web-UI integration tests — use it as the template for adding your own browser test. | — (nobody imports the test module) |
| s09 | measurement | Scale/format sample values: `ScaleProfiles` before merging, `Scale`/`ScaledLabel` for UI labels, `Percentage` for share-of-total columns. | graph, internal/driver, report |

## s01 — profile (★4) · `profile`

The central library: `Profile` (profile.go:35) holds Sample/Mapping/
Location/Function; decode via `Parse`/`ParseData` (profile.go:172/182),
encode via `Write` (profile.go:345), with validate/aggregate/copy
(`CheckValid` :364, `Aggregate` :445, `Copy` :867) and multi-profile
merge via `Merge` (merge.go:44). Every other consumer in the repository
(10 items — see the module map) starts from a `*profile.Profile` produced
by this item; the go-fuzz harness likewise only feeds arbitrary bytes
into `ParseData` (fuzz/main.go:25).

### UC-1.1 — Read a pprof file and summarize it

Scenario: you received `cpu.prof` from a Go service (`go tool pprof` or
`/debug/pprof/profile`) and want to process it in your own code: decode
the file (validity is checked inside `Parse`/`ParseData`), then print a
summary (sample types, samples, mappings/locations/functions, the total
of the first sample column) before feeding it to your own analysis
pipeline.

```go
package main

import (
	"fmt"
	"os"

	"github.com/google/pprof/profile"
)

func main() {
	f, err := os.Open("cpu.prof")
	if err != nil {
		panic(err)
	}
	defer f.Close()

	p, err := profile.Parse(f) // reads + validates (ParseData underneath)
	if err != nil {
		panic(err)
	}

	fmt.Printf("sample types: %d\n", len(p.SampleType))
	fmt.Printf("samples: %d\n", len(p.Sample))
	fmt.Printf("mappings: %d, locations: %d, functions: %d\n",
		len(p.Mapping), len(p.Location), len(p.Function))

	var total int64
	for _, s := range p.Sample {
		if len(s.Value) > 0 {
			total += s.Value[0]
		}
	}
	fmt.Printf("total value (sample type 0): %d\n", total)
}
```

Evidence (grep on the pin):
- profile/profile.go:172 — `func Parse(r io.Reader) (*Profile, error) {`
- profile/profile.go:182 — `func ParseData(data []byte) (*Profile, error) {` (doc :181: "parses a profile from a buffer and checks for its validity")
- profile/profile.go:35-49 — `Profile` struct fields: `SampleType []*ValueType`, `Sample []*Sample`, `Mapping []*Mapping`, `Location []*Location`, `Function []*Function`, `Comments []string`, `TimeNanos`, `DurationNanos`, `PeriodType`, `Period`
- profile/profile.go:75-77 — `type Sample struct { Location []*Location; Value []int64; ... }`

### UC-1.2 — Merge profiles from several nodes and write one pprof file

Scenario: a collector ran on 3 nodes and stored 3 pprof files; you want a
single merged file for the big picture — `Merge` unifies samples sharing
mapping/function, `Copy` takes an independent snapshot before another
writer mutates it, and `Write` re-encodes (gzip) to disk in exactly the
format `go tool pprof` reads back.

```go
package main

import (
	"fmt"
	"os"

	"github.com/google/pprof/profile"
)

func main() {
	var srcs []*profile.Profile
	for _, name := range []string{"node1.pprof", "node2.pprof", "node3.pprof"} {
		f, err := os.Open(name)
		if err != nil {
			panic(err)
		}
		p, err := profile.Parse(f)
		f.Close()
		if err != nil {
			panic(err)
		}
		srcs = append(srcs, p)
	}

	merged, err := profile.Merge(srcs)
	if err != nil {
		panic(err)
	}

	snapshot := merged.Copy() // independent copy, safe to share
	out, err := os.Create("merged.prof")
	if err != nil {
		panic(err)
	}
	defer out.Close()
	if err := snapshot.Write(out); err != nil {
		panic(err)
	}
	fmt.Println("merged samples:", len(snapshot.Sample))
}
```

Evidence (grep on the pin):
- profile/merge.go:44 — `func Merge(srcs []*Profile) (*Profile, error) {`
- profile/profile.go:867 — `func (p *Profile) Copy() *Profile {`
- profile/profile.go:345 — `func (p *Profile) Write(w io.Writer) error {`

### UC-1.3 — Normalize detail level (Aggregate), then re-encode to compare builds

Scenario: two profiles generated by two different builds (different
inline-frame counts) cannot be compared directly; you collapse
line/inline information to function/file level with
`Aggregate(true, true, true, false, false, false)`, then `Write` to a
buffer for storage/diff. This is also the data the go-fuzz harness feeds
arbitrary bytes into `ParseData` with, to test parser robustness
(fuzz/main.go:25).

```go
package main

import (
	"bytes"
	"fmt"
	"os"

	"github.com/google/pprof/profile"
)

func main() {
	raw, err := os.ReadFile("heap.prof")
	if err != nil {
		panic(err)
	}
	p, err := profile.ParseData(raw)
	if err != nil {
		panic(err)
	}

	// Collapse inline frames + lines to function/file level so the two
	// builds can be compared like-for-like.
	if err := p.Aggregate(true, true, true, false, false, false); err != nil {
		panic(err)
	}

	var buf bytes.Buffer
	if err := p.Write(&buf); err != nil {
		panic(err)
	}
	fmt.Printf("normalized %d samples, re-encoded %d bytes\n", len(p.Sample), buf.Len())
}
```

Evidence (grep on the pin):
- profile/profile.go:182 — `func ParseData(data []byte) (*Profile, error) {`
- profile/profile.go:445 — `func (p *Profile) Aggregate(inlineFrame, function, filename, linenumber, columnnumber, address bool) error {`
- profile/profile.go:345 — `func (p *Profile) Write(w io.Writer) error {`
- fuzz/main.go:25 — `profile.ParseData(data)` (go-fuzz harness)

Dependencies: the examples import stdlib + the item itself
(`github.com/google/pprof/profile`) — a public package that pulls no
internal dependency. Build: `go build ./...` and `go test ./profile/...`
from the root module (go.mod:1).

## s03 — report (★3) · `internal/report`

report turns a fetched `*profile.Profile` into a reader-facing output:
`Generate` (report.go:88) is the central entry — it builds a trimmed
graph via `newTrimmedGraph` (report.go:124) and renders the output format
declared in the const block report.go:38-52 (Callgrind/Comments/Dis/Dot/
List/Proto/Raw/Tags/Text/TopProto/Traces/Tree/WebList); annotated source
listings are handled by `printSource` (source.go:43). This is the layer
`internal/driver` calls after fetch+symbolize (driver.go:100/127).

### UC-3.1 — Render a text top report from a parsed profile (like `-top`)

Scenario: inside the repository (or a fork), you have a
`*profile.Profile` from s01 and want to print a top table like
`pprof -top -nodecount=25`: build the `Report` with `NewDefault` (indexes
the last sample value available, per its doc comment), choose format
`Text`, then `Generate` to stdout.

```go
package main

import (
	"os"

	"github.com/google/pprof/internal/report"
	"github.com/google/pprof/profile"
)

// Use INSIDE the pprof module (internal/): same pattern as internal/driver.
func topReport(p *profile.Profile) error {
	rpt := report.NewDefault(p, report.Options{
		OutputFormat: report.Text,
		NodeCount:    25,
		OutputUnit:   "seconds",
	})
	return report.Generate(os.Stdout, rpt, nil)
}
```

Evidence (grep on the pin):
- internal/report/report.go:1305 — `func NewDefault(prof *profile.Profile, options Options) *Report {` (doc :1304: "NewDefault builds a new report indexing the last sample value available")
- internal/report/report.go:88 — `func Generate(w io.Writer, rpt *Report, obj plugin.ObjTool) error {`
- internal/report/report.go:98 — `case Text:` (const `Text` at report.go:47 in the const block :38-52)
- internal/report/report.go:56-85 — `type Options struct`: `OutputFormat` (:57), `NodeCount` (:69), `OutputUnit` (:78)
- Passing `nil` for `obj` is safe for text formats: `obj` in report.go is used only in the signature (:88) and the assembly path (`case Dis` :112 → `printAssembly` :398 → `obj.Disasm` :475) — Text never touches it. Real callers: `internal/driver/driver.go:100` `rpt := report.New(p, ropt)` and `driver.go:127` `err = report.Generate(dst, rpt, o.Obj)`.

### UC-3.2 — Re-encode a profile through the report pipeline to proto format

Scenario: you want to normalize a collector's output into strict
profile.proto (so the whole pprof ecosystem can read it) while still
going through pprof's report pipeline: build the `Report` with `New` and
`Options{OutputFormat: report.Proto}`, write to a buffer — the
`case Proto` (:107) path of `Generate`.

```go
package main

import (
	"bytes"

	"github.com/google/pprof/internal/report"
	"github.com/google/pprof/profile"
)

func protoBytes(p *profile.Profile) ([]byte, error) {
	rpt := report.New(p, &report.Options{OutputFormat: report.Proto})
	var buf bytes.Buffer
	if err := report.Generate(&buf, rpt, nil); err != nil {
		return nil, err
	}
	return buf.Bytes(), nil
}
```

Evidence (grep on the pin):
- internal/report/report.go:1291 — `func New(prof *profile.Profile, o *Options) *Report {`
- internal/report/report.go:107 — `case Proto:` (const `Proto` at report.go:44)
- internal/report/report.go:88 — `func Generate(w io.Writer, rpt *Report, obj plugin.ObjTool) error {`
- internal/report/report.go:1352 — `type Report struct {` (the value returned by New)

### UC-3.3 — Annotated source listing for a function (like `-list`)

Scenario: you want to see, line by line, how many samples
`main.handle` consumes with assembly context — use the `List` format
with `Symbol` (a regex selecting the function) and `SourcePath` (source
directory) exactly as the driver does; the `case List` (:113-114) path
calls `printSource` (source.go:43) directly.

```go
package main

import (
	"os"
	"regexp"

	"github.com/google/pprof/internal/report"
	"github.com/google/pprof/profile"
)

func listFunc(p *profile.Profile) error {
	rpt := report.NewDefault(p, report.Options{
		OutputFormat: report.List,
		Symbol:       regexp.MustCompile(`^main\.handle$`),
		SourcePath:   "/home/me/src/myapp",
	})
	return report.Generate(os.Stdout, rpt, nil)
}
```

Evidence (grep on the pin):
- internal/report/report.go:113-114 — `case List:` → `return printSource(w, rpt)`
- internal/report/source.go:43 — `func printSource(w io.Writer, rpt *Report) error {`
- internal/report/report.go:56-85 — Options fields `Symbol *regexp.Regexp` (:80), `SourcePath string` (:81)
- internal/report/report.go:47 — consts `Text`/`List` in the const block :38-52 (`List` at :43, `Text` at :47)

Dependencies: the examples import `internal/report` + `profile` (+ stdlib);
`internal/report` itself pulls `graph`, `measurement`, `plugin`,
`profile`. Consumers: `internal/driver`. Build: `go build ./...` and
`go test ./internal/report/...` from the root module (go.mod:1).

## s04 — binutils (★3) · `internal/binutils`

binutils implements `plugin.ObjTool` — the `Binutils` struct
(binutils.go:40) locates external tools (llvm-symbolizer, addr2line, nm,
objdump via `SetTools`/`initTools` :130/:159), opens ELF/Mach-O(fat)/PE
binaries by magic number (`Open` :304) and returns `ObjFile` objects
mapping runtime addresses → symbol/file:line (`SourceLine`
plugin.go:147), plus `Disasm` through objdump (binutils.go:276). When
pprof needs to resolve addresses in a profile to real functions/lines on
a binary, this is the default implementation of the plugin contract.

### UC-4.1 — Open a binary and resolve a runtime address to function/file:line frames

Scenario: your profile contains address `0x4012a0` in the mapping
`/usr/local/bin/myserver`; you want to resolve it to a stack of frames
(leaf first) to attach to your own alerting tool. Note: the symbolize
path shells out to external tools (addr2line/llvm-symbolizer) — the
machine must have them; the zero value `&binutils.Binutils{}` lazy-inits
the default tools via `get()` (:72-81).

```go
package main

import (
	"fmt"

	"github.com/google/pprof/internal/binutils"
)

func main() {
	bu := &binutils.Binutils{}
	bu.SetFastSymbolization(true)

	obj, err := bu.Open("/usr/local/bin/myserver", 0, 0, 0, "")
	if err != nil {
		panic(err)
	}
	defer obj.Close()

	frames, err := obj.SourceLine(0x4012a0)
	if err != nil {
		panic(err)
	}
	for _, fr := range frames {
		fmt.Printf("%s %s:%d\n", fr.Func, fr.File, fr.Line)
	}
}
```

Evidence (grep on the pin):
- internal/binutils/binutils.go:40 — `type Binutils struct {`
- internal/binutils/binutils.go:121 — `func (bu *Binutils) SetFastSymbolization(fast bool) {`
- internal/binutils/binutils.go:304 — `func (bu *Binutils) Open(name string, start, limit, offset uint64, relocationSymbol string) (plugin.ObjFile, error) {`
- internal/binutils/binutils.go:72-81 — `func (bu *Binutils) get() *binrep` lazy-init (`r == nil → initTools(r, "")`)
- internal/plugin/plugin.go:147 — `SourceLine(addr uint64) ([]Frame, error)` (in the `ObjFile` interface :132)
- internal/plugin/plugin.go:161-167 — `type Frame struct { Func string; File string; Line int; Column int; StartLine int }`
- The zero-value pattern is real: internal/report/report_test.go:80 — `Generate(&b, tc.rpt, &binutils.Binutils{})`

### UC-4.2 — List the symbols of a binary matching a regex

Scenario: before analyzing a profile, verify which `gc`-prefixed
functions the binary actually exports (e.g. to confirm the profiling
runtime was linked in) — `Symbols` (plugin.go:154) filters by regex and
returns each symbol's `[Start, End]` address range.

```go
package main

import (
	"fmt"
	"regexp"

	"github.com/google/pprof/internal/binutils"
)

func main() {
	bu := &binutils.Binutils{}
	obj, err := bu.Open("/usr/local/bin/myserver", 0, 0, 0, "")
	if err != nil {
		panic(err)
	}
	defer obj.Close()

	syms, err := obj.Symbols(regexp.MustCompile(`^gc`), 0)
	if err != nil {
		panic(err)
	}
	for _, s := range syms {
		fmt.Printf("%s [%x, %x]\n", s.Name, s.Start, s.End)
	}
}
```

Evidence (grep on the pin):
- internal/plugin/plugin.go:154 — `Symbols(r *regexp.Regexp, addr uint64) ([]*Sym, error)` (in the `ObjFile` interface :132)
- internal/plugin/plugin.go:171-176 — `type Sym struct { Name []string; File string; Start uint64; End uint64 }`
- internal/binutils/binutils.go:304 — `func (bu *Binutils) Open(...) (plugin.ObjFile, error) {`

### UC-4.3 — Disassemble an address range (the `-disasm` path)

Scenario: you need the assembly of a hot function with Intel syntax (e.g.
to check inlining/branches); `Disasm` (binutils.go:276) runs objdump —
the same path the report package uses for the `Dis` format via
`obj.Disasm` (report.go:475). If the toolchain is not on the default
PATH, `SetTools` (:130) points to a custom one (`objdump=/path`).

```go
package main

import (
	"fmt"

	"github.com/google/pprof/internal/binutils"
)

func main() {
	bu := &binutils.Binutils{}
	// Point at a hermetic toolchain objdump instead of the default PATH:
	bu.SetTools("objdump=/opt/toolchain/bin/objdump")

	insts, err := bu.Disasm("/usr/local/bin/myserver", 0x401000, 0x401100, true)
	if err != nil {
		panic(err)
	}
	for _, in := range insts {
		fmt.Printf("%x: %s\n", in.Addr, in.Text)
	}
}
```

Evidence (grep on the pin):
- internal/binutils/binutils.go:276 — `func (bu *Binutils) Disasm(file string, start, end uint64, intelSyntax bool) ([]plugin.Inst, error) {`
- internal/binutils/binutils.go:130 — `func (bu *Binutils) SetTools(config string) {`
- internal/binutils/binutils.go:147 — `func toolPaths(config string) map[string][]string {` (parses the `name=path` config)
- internal/plugin/plugin.go:123-129 — `type Inst struct { Addr uint64; Text string; Function string; File string; Line int }`
- The report `-disasm` path: internal/report/report.go:475 — `insts, err := obj.Disasm(s.sym.File, s.sym.Start, end, o.IntelSyntax)`

Dependencies: the examples import `internal/binutils` (+ stdlib); the
item itself imports `elfexec`, `plugin`. There is also a non-Go
environment dependency: `objdump`, `addr2line`/`llvm-symbolizer`, `nm`
(initTools :159, findObjdump :180). Without the tools, `Open` still works
(magic number) but `SourceLine`/`Symbols`/`Disasm` fail with
tool-not-found. Consumers: `internal/driver`, `symbolizer`. Build:
`go build ./...` and `go test ./internal/binutils/...` from the root
module (go.mod:1).

## s05 — graph (★3) · `internal/graph`

graph collects a profile's samples into a directed graph: `New`
(graph.go:330) builds the `Graph` (graph.go:50) from a
`*profile.Profile` per `Options` (SampleValue :56, CallTree :62,
KeptNodes :65); prunes/balances via `TrimTree` (:479),
`DiscardLowFrequencyNodes` (:752), `RemoveRedundantEdges` (:899); and
exports DOT through `ComposeDot` (dotgraph.go:57) for Graphviz. report
(m03) and internal/driver (m02) are the consumers.

### UC-5.1 — Build the call graph from a profile and find the heaviest nodes

Scenario: you want to rank the costliest functions from a profile
yourself instead of using the built-in top table: `New` builds the graph
with a `SampleValue` function selecting the sample column (the CLI
standard is the last one), then sort nodes by `Flat` (the node's
exclusive value) — printing `Cum` (the value accumulated through
descendants) alongside.

```go
package main

import (
	"fmt"
	"os"
	"sort"

	"github.com/google/pprof/internal/graph"
	"github.com/google/pprof/profile"
)

func main() {
	f, err := os.Open("cpu.prof")
	if err != nil {
		panic(err)
	}
	p, err := profile.Parse(f)
	f.Close()
	if err != nil {
		panic(err)
	}

	g := graph.New(p, &graph.Options{
		SampleValue: func(s []int64) int64 {
			if len(s) == 0 {
				return 0
			}
			return s[len(s)-1]
		},
	})

	nodes := append([]*graph.Node(nil), g.Nodes...)
	sort.Slice(nodes, func(i, j int) bool { return nodes[i].Flat > nodes[j].Flat })
	for i, n := range nodes {
		if i == 10 {
			break
		}
		fmt.Printf("%2d. %-40s flat=%d cum=%d\n", i+1, n.Info.PrintableName(), n.Flat, n.Cum)
	}
}
```

Evidence (grep on the pin):
- internal/graph/graph.go:330 — `func New(prof *profile.Profile, o *Options) *Graph {`
- internal/graph/graph.go:55-66 — `type Options struct`: `SampleValue func(s []int64) int64` (:56), `CallTree` (:62), `KeptNodes` (:65)
- internal/graph/graph.go:50-51 — `type Graph struct { Nodes Nodes }`
- internal/graph/graph.go:86 — `Flat, FlatDiv, Cum, CumDiv int64` (in `type Node struct` :73)
- internal/graph/graph.go:152 — `Name string` (in `type NodeInfo struct` :151) · :162 — `func (i *NodeInfo) PrintableName() string {`

### UC-5.2 — Prune the graph before analysis: drop redundant edges + low-frequency nodes

Scenario: the raw graph contains edges caused by overloaded wrapper
functions and noisy low-frequency nodes; before ranking/drawing, clean
it: `RemoveRedundantEdges` (:899) drops edges that add no information,
then `DiscardLowFrequencyNodes(10000)` (:752) drops nodes under 10k
samples and returns the dropped set (`NodeSet` = `map[NodeInfo]bool` —
graph.go:219) so you can log what was removed.

```go
package main

import (
	"fmt"
	"os"

	"github.com/google/pprof/internal/graph"
	"github.com/google/pprof/profile"
)

func main() {
	f, err := os.Open("cpu.prof")
	if err != nil {
		panic(err)
	}
	p, err := profile.Parse(f)
	f.Close()
	if err != nil {
		panic(err)
	}

	g := graph.New(p, &graph.Options{
		SampleValue: func(s []int64) int64 { return s[len(s)-1] },
	})

	g.RemoveRedundantEdges()
	dropped := g.DiscardLowFrequencyNodes(10000)
	fmt.Printf("nodes=%d, dropped=%d\n", len(g.Nodes), len(dropped))
}
```

Evidence (grep on the pin):
- internal/graph/graph.go:899 — `func (g *Graph) RemoveRedundantEdges() {`
- internal/graph/graph.go:752 — `func (g *Graph) DiscardLowFrequencyNodes(nodeCutoff int64) NodeSet {`
- internal/graph/graph.go:219 — `type NodeSet map[NodeInfo]bool` (`NodePtrSet map[*Node]bool` :229 — used by `TrimTree` :479)
- internal/graph/graph.go:330 — `func New(prof *profile.Profile, o *Options) *Graph {`

### UC-5.3 — Export DOT for Graphviz (the `Dot` format path)

Scenario: you want to save the call graph as a `.dot` file and draw it
with `dot -Tsvg`; `ComposeDot` (dotgraph.go:57) writes DOT to a writer
with a `DotConfig` (title/total/value formatter). Mandatory caveat from
the source: `ComposeDot` dereferences `b.config.Labels` even for an
empty graph (addLegend dotgraph.go:123-124) → **the config must be
non-nil**; the test suite's canonical pattern uses
`&DotAttributes{Nodes: make(...)}` + `&DotConfig{Title, Labels, Total,
FormatValue}` (dotgraph_test.go:200-210).

```go
package main

import (
	"os"
	"strconv"

	"github.com/google/pprof/internal/graph"
	"github.com/google/pprof/profile"
)

func main() {
	f, err := os.Open("cpu.prof")
	if err != nil {
		panic(err)
	}
	p, err := profile.Parse(f)
	f.Close()
	if err != nil {
		panic(err)
	}

	g := graph.New(p, &graph.Options{
		SampleValue: func(s []int64) int64 {
			if len(s) == 0 {
				return 0
			}
			return s[len(s)-1]
		},
	})
	g.RemoveRedundantEdges()

	var total int64
	for _, s := range p.Sample {
		if len(s.Value) > 0 {
			total += s.Value[len(s.Value)-1]
		}
	}

	a := &graph.DotAttributes{Nodes: make(map[*graph.Node]*graph.DotNodeAttributes)}
	c := &graph.DotConfig{
		Title:       "cpu profile",
		Total:       total,
		FormatValue: func(v int64) string { return strconv.FormatInt(v, 10) },
	}
	out, err := os.Create("cpu.dot")
	if err != nil {
		panic(err)
	}
	defer out.Close()
	graph.ComposeDot(out, g, a, c)
}
```

Evidence (grep on the pin):
- internal/graph/dotgraph.go:57 — `func ComposeDot(w io.Writer, g *Graph, a *DotAttributes, c *DotConfig) {`
- internal/graph/dotgraph.go:29-31 — `type DotAttributes struct { Nodes map[*Node]*DotNodeAttributes }`
- internal/graph/dotgraph.go:44-50 — `type DotConfig struct { Title string; LegendURL string; Labels []string; FormatValue func(int64) string; Total int64 ... }`
- internal/graph/dotgraph.go:123-124 — `func (b *builder) addLegend() { labels := b.config.Labels` (config dereferenced directly → must be non-nil)
- internal/graph/dotgraph_test.go:200-210 — `a := &DotAttributes{Nodes: make(map[*Node]*DotNodeAttributes)}`; `c := &DotConfig{Title: "testtitle", Labels: ..., Total: 100, FormatValue: ...}`
- profile/profile.go:75-77 — `type Sample struct { Location []*Location; Value []int64; ... }` (the Total loop above)

Dependencies: the examples import `internal/graph` + `profile` (+ stdlib);
the item itself imports `measurement`, `profile`. Consumers:
`internal/driver`, `report`; the real integration is feeding the trimmed
graph/`ComposeDot` output into report's render pipeline. Build:
`go build ./...` and `go test ./internal/graph/...` from the root module
(go.mod:1).

## s06 — elfexec (★2) · `internal/elfexec`

ELF binary parsing utilities for the binutils layer — computes kernel and
PIE load/base addresses (`GetBase` 216, `kernelBase` 167), reads the GNU
build-id from note sections/segments (`GetBuildID` 121, `parseNotes` 39),
finds the text program header and matches program headers against memory
mappings by file offset (`FindTextProgHeader` 287,
`ProgramHeadersForMapping` 310, `HeaderForFileOffset` 358). This item's
only consumer is `binutils` — every integration goes through it.

### UC-6.1 — Compute the base address of a PIE/shared-library mapping to turn runtime addresses into symbol addresses

Scenario: the profiler recorded the runtime address of code in a shared
library mapped at `[start, limit)` with file offset `offset`. To look up
symbols you must subtract the correct base; `GetBase` computes it,
handling both the fake whole-address-space mapping and the kernel case
(via `stextOffset`). The example below lives inside the pprof module,
shaped exactly like binutils' real call site.

```go
// File: internal/pproftool/base.go — consumer inside module github.com/google/pprof
package pproftool

import (
	"debug/elf"

	"github.com/google/pprof/internal/elfexec"
)

// resolveBase computes the base address to subtract from virtual
// addresses of a mapped ELF image before looking up symbols.
// stextOffset is non-nil only for kernel images (address of _stext).
func resolveBase(path string, start, limit, offset uint64, stextOffset *uint64) (uint64, error) {
	ef, err := elf.Open(path)
	if err != nil {
		return 0, err
	}
	defer ef.Close()
	return elfexec.GetBase(&ef.FileHeader, elfexec.FindTextProgHeader(ef),
		stextOffset, start, limit, offset)
}
```

Evidence (grep on the pin):
- internal/elfexec/elfexec.go:216 — `func GetBase(fh *elf.FileHeader, loadSegment *elf.ProgHeader, stextOffset *uint64, start, limit, offset uint64) (uint64, error) {`
- internal/elfexec/elfexec.go:210-215 — "// GetBase determines the base address to subtract from virtual address to get symbol table address. For an executable, the base is 0. … The kernel needs special handling."
- internal/elfexec/elfexec.go:287 — `func FindTextProgHeader(f *elf.File) *elf.ProgHeader {`
- internal/binutils/binutils.go:495 — `if _, err := elfexec.GetBase(&ef.FileHeader, elfexec.FindTextProgHeader(ef), kernelOffset, start, limit, offset); err != nil {` (the real call site — same shape as the example)

### UC-6.2 — Read the GNU build-id to match a binary against a profile mapping

Scenario: when symbolizing a profile collected on another machine, you
must be sure the binary at the local path is exactly the binary that
produced the mapping (same build-id). `GetBuildID` reads the
`GNU`/`NT_GNU_BUILD_ID` note; per its documented contract, a binary that
reads fine but carries no build-id returns `(nil, nil)` — the example
honors that contract instead of inferring an error.

```go
// File: internal/pproftool/buildid.go — consumer inside module github.com/google/pprof
package pproftool

import (
	"debug/elf"
	"encoding/hex"

	"github.com/google/pprof/internal/elfexec"
)

// buildIDOf returns the hex GNU build-id of an ELF binary, or the
// empty string when the binary carries no build-id note.
func buildIDOf(path string) (string, error) {
	ef, err := elf.Open(path)
	if err != nil {
		return "", err
	}
	defer ef.Close()
	id, err := elfexec.GetBuildID(ef)
	if err != nil || id == nil {
		// nil,nil per contract: binary read OK but has no GNU build-id.
		return "", err
	}
	return hex.EncodeToString(id), nil
}
```

Evidence (grep on the pin):
- internal/elfexec/elfexec.go:115-121 — "// GetBuildID returns the GNU build-ID for an ELF binary. // If no build-ID was found but the binary was read without error, it returns (nil, nil). … func GetBuildID(f *elf.File) ([]byte, error) {"
- internal/elfexec/elfexec.go:128-130 — `if note.Name == "GNU" && note.Type == noteTypeGNUBuildID {` (the GNU build-id note selection logic)
- internal/binutils/binutils.go:453 — `if id, err := elfexec.GetBuildID(ef); err == nil {` (the real consumer stores the ObjFile's build-id this way)

### UC-6.3 — Match program headers against a memory mapping and find the header containing a file offset

Scenario: a runtime mapping covers only part of the ELF file; to avoid
matching a small segment on the same page, first filter the program
headers with the mapping's `mapOff`/`mapSz`, then find the header
containing the file offset derived from the runtime address.
`HeaderForFileOffset` returns an explicit error when ≥2 headers match
(stripped binary / segment with uninitialized data) — the example
propagates that error instead of guessing.

```go
// File: internal/pproftool/mapmatch.go — consumer inside module github.com/google/pprof
package pproftool

import (
	"debug/elf"

	"github.com/google/pprof/internal/elfexec"
)

// headerForRuntimeAddr finds the ELF program header backing a runtime
// address inside a memory mapping [mStart, mLimit) loaded from file
// offset mOffset.
func headerForRuntimeAddr(path string, mStart, mLimit, mOffset, addr uint64) (*elf.ProgHeader, error) {
	ef, err := elf.Open(path)
	if err != nil {
		return nil, err
	}
	defer ef.Close()
	headers := elfexec.ProgramHeadersForMapping(ef.Progs, mOffset, mLimit-mStart)
	return elfexec.HeaderForFileOffset(headers, addr-mStart+mOffset)
}
```

Evidence (grep on the pin):
- internal/elfexec/elfexec.go:310 — `func ProgramHeadersForMapping(phdrs []elf.ProgHeader, mapOff, mapSz uint64) []*elf.ProgHeader {`
- internal/elfexec/elfexec.go:352-358 — "// HeaderForFileOffset attempts to identify a unique program header that includes the given file offset. It returns an error if it cannot identify a unique header. … func HeaderForFileOffset(headers []*elf.ProgHeader, fileOffset uint64) (*elf.ProgHeader, error) {"
- internal/binutils/binutils.go:579 — `headers := elfexec.ProgramHeadersForMapping(phdrs, m.offset, m.limit-m.start)` (the real call site)
- internal/binutils/binutils.go:589 — `return elfexec.HeaderForFileOffset(headers, addr-m.start+m.offset)` (the real call site — same subtraction as the example)

Dependencies: only stdlib `debug/elf`; the package belongs to the root
module (go.mod:1,3) — no separate go.mod, no external dependency. Real
integration goes through `internal/binutils` (its only consumer; call
sites binutils.go:453/495/579/589 quoted above). Build: `go build ./...`
and `go test ./...` from the root module.

## s07 — symbolizer (★2) · `internal/symbolizer`

Fills symbol/file/line into the profile — the `Symbolizer` struct
(symbolizer.go:36) implements `plugin.Symbolize` via `Symbolize`
(symbolizer.go:50) along two paths: local through binutils
(`doLocalSymbolize` 129) and HTTP symbolz (`postURL` 101), plus the
`Demangle` entry (symbolizer.go:249) using the external
ianlancetaylor/demangle library.

### UC-7.1 — Wire the Symbolizer as the driver's plugin.Symbolize (like the real options.go)

Scenario: an in-module consumer wants to wire internal/driver's
symbolizer into `Options` exactly the way the driver does: the default
binutils ObjTool, a `plugin.UI`, and a RoundTripper for the HTTP path.
The example returns the `plugin.Symbolizer` interface to demonstrate that
`Symbolizer` satisfies the plugin contract; the UI is `TestUI` (the
repo's official test double from proftest).

```go
// File: internal/pproftool/symwire_test.go — consumer inside module github.com/google/pprof
package pproftool

import (
	"net/http"
	"testing"

	"github.com/google/pprof/internal/binutils"
	"github.com/google/pprof/internal/plugin"
	"github.com/google/pprof/internal/proftest"
	"github.com/google/pprof/internal/symbolizer"
)

// newTestSymbolizer wires the default ObjTool with a test UI,
// mirroring the driver's own wiring in internal/driver/options.go.
func newTestSymbolizer(t testing.TB) plugin.Symbolizer {
	return &symbolizer.Symbolizer{
		Obj:       &binutils.Binutils{},
		UI:        &proftest.TestUI{T: t},
		Transport: http.DefaultTransport,
	}
}
```

Evidence (grep on the pin):
- internal/symbolizer/symbolizer.go:36-40 — `type Symbolizer struct {` + fields `Obj plugin.ObjTool` / `UI plugin.UI` / `Transport http.RoundTripper`
- internal/plugin/plugin.go:96-99 — "// A Symbolizer introduces symbol information into a profile. type Symbolizer interface { Symbolize(mode string, srcs MappingSources, prof *profile.Profile) error }"
- internal/driver/options.go:53 — `d.Sym = &symbolizer.Symbolizer{Obj: d.Obj, UI: d.UI, Transport: d.HTTPTransport}` (the real call site of exactly this shape)
- internal/driver/options.go:43-44 — `if d.Obj == nil { d.Obj = &binutils.Binutils{}` (how the default ObjTool is built, as in the example)
- internal/proftest/proftest.go:87-95 — `type TestUI struct { T testing.TB; Ignore int; AllowRx string; NumAllowRxMatches int; Input []string; index int }` (field `T` is why the example takes `t testing.TB`)

### UC-7.2 — Local-only symbolization of a parsed profile (mode "fastlocal:force")

Scenario: the profile was collected from a service on the same machine;
you want to fill symbols only from local binaries, skip the HTTP symbolz
round trip entirely, and overwrite mappings that already have function
names (force). The mode string is parsed by `Symbolize`: `fastlocal`
disables remote and enables fast, `force` enables force; the example
builds `plugin.MappingSources` keyed by `BuildID`/`File` exactly like
production's `collectMappingSources`.

```go
// File: internal/pproftool/localsym.go — consumer inside module github.com/google/pprof
package pproftool

import (
	"github.com/google/pprof/internal/binutils"
	"github.com/google/pprof/internal/plugin"
	"github.com/google/pprof/internal/proftest"
	"github.com/google/pprof/internal/symbolizer"
	"github.com/google/pprof/profile"
)

// symbolizeLocal fills function/file/line of a parsed profile using
// only local binaries, skipping the HTTP symbolz round trip.
func symbolizeLocal(prof *profile.Profile, source string, ui *proftest.TestUI) error {
	sym := &symbolizer.Symbolizer{Obj: &binutils.Binutils{}, UI: ui}
	// Key = Mapping.BuildID or Mapping.File, like collectMappingSources.
	srcs := plugin.MappingSources{}
	for _, m := range prof.Mapping {
		key := m.BuildID
		if key == "" {
			key = m.File
		}
		srcs[key] = append(srcs[key], struct {
			Source string
			Start  uint64
		}{Source: source, Start: m.Start})
	}
	return sym.Symbolize("fastlocal:force", srcs, prof)
}
```

Evidence (grep on the pin):
- internal/symbolizer/symbolizer.go:50 — `func (s *Symbolizer) Symbolize(mode string, sources plugin.MappingSources, p *profile.Profile) error {`
- internal/symbolizer/symbolizer.go:52-77 — the mode parser — `case "none", "no": return nil` / `case "local": remote, local = false, true` / `case "fastlocal": remote, local, fast = false, true, true` / `case "force": force = true`
- internal/symbolizer/symbolizer.go:129 — `func doLocalSymbolize(prof *profile.Profile, fast, force bool, obj plugin.ObjTool, ui plugin.UI) error {` (the local path called by Symbolize at :82-86)
- internal/plugin/plugin.go:101-107 — "type MappingSources map[string][]struct { Source string // URL of the source…; Start uint64 // delta applied to addresses… }" + "// The key is either Mapping.File or Mapping.BuildId."
- internal/driver/fetch.go:370-390 — `func collectMappingSources(p *profile.Profile, source string) plugin.MappingSources {` — the loop `key := m.BuildID; if key == "" { key = m.File }` with entries `{source, m.Start}` (the example mirrors the production pattern)
- profile/profile.go:111-120 — `type Mapping struct { ID uint64; Start uint64; Limit uint64; Offset uint64; File string; BuildID string; … }` (the fields the example reads — `type Mapping struct` at :111)
- internal/driver/fetch.go:86 — `if err := o.Sym.Symbolize(s.Symbolize, m, p); err != nil {` (the driver calls Symbolize after fetch/merge — the real context of this use case)

### UC-7.3 — Demangle C++ names in an already-symbolized profile

Scenario: after symbolization the function names are still mangled
(encrypted `std::…` templates); you want to print the demangled names in
`templates` mode and force re-demangling of names already processed
(force=true). `Demangle` is the exported entry for exactly this.

```go
// File: internal/pproftool/demangle.go — consumer inside module github.com/google/pprof
package pproftool

import (
	"fmt"

	"github.com/google/pprof/internal/symbolizer"
	"github.com/google/pprof/profile"
)

// printDemangled lists every function name of the profile after
// forcing re-demangling in "templates" mode.
func printDemangled(prof *profile.Profile) {
	symbolizer.Demangle(prof, true, "templates")
	for _, fn := range prof.Function {
		fmt.Println(fn.Name)
	}
}
```

Evidence (grep on the pin):
- internal/symbolizer/symbolizer.go:249 — `func Demangle(prof *profile.Profile, force bool, demanglerMode string) {`
- internal/symbolizer/symbolizer.go:269 — `func demanglerModeToOptions(demanglerMode string) []demangle.Option {` (mode → options of the external library)
- internal/symbolizer/symbolizer.go:66-72 — `case "full", "none", "templates": demanglerMode = d; force = true` (the valid modes in the Symbolize parser)
- profile/profile.go:157-162 — `type Function struct { ID uint64; Name string; SystemName string; Filename string; StartLine int64; … }` (the `Name` field the example prints — `type Function struct` at :157)
- go.mod:7 — `github.com/ianlancetaylor/demangle v0.0.0-20250417193237-f615e6bd150b` (the external demangle dependency)

Dependencies: `internal/binutils` (the local path), `internal/plugin`
(the MappingSources/Symbolizer contract), `internal/proftest` (the UI
test double), `internal/profile`; indirectly `internal/symbolz` (the
remote path — wired at symbolizer.go:45 `var symbolzSymbolize =
symbolz.Symbolize`) and the external `ianlancetaylor/demangle` (go.mod:7).
Build: `go build ./...` and `go test ./...` from the root module.

## s08 — browsertests (★2) · `browsertests` (separate module)

A separate Go module (`go.mod`: module
github.com/google/pprof/browsertests, `replace github.com/google/pprof =>
../`) running the web interface's integration tests — it builds a real
server through `driver.PProf` with fake plumbing (`makeTestServer`
testutils.go:17), then drives Chrome via chromedp to verify the Top page
(browser_test.go:50), the flame graph (74) and the source page,
self-skipping when Chrome is unavailable (`maybeSkipBrowserTest`
browser_test.go:32). The practical use case of this item is: "add a new
browser test inside this very module".

### UC-8.1 — New integration test for the /top page: sort by cumulative and verify row order

Scenario: after changing the Top table's sort logic you need an
end-to-end test: build a real server with `makeTestServer` (fake profile
from `makeFakeProfile`), open headless Chrome through chromedp (the
`newContext` helper enables NoSandbox and a 90 s deadline), click the
cumulative column header, and verify 3 functions appear in order with
`matchInOrder`.

```go
// File: browsertests/top_extra_test.go — module github.com/google/pprof/browsertests
package browsertests

import (
	"context"
	"testing"

	"github.com/chromedp/chromedp"
)

func TestTopTableCumulativeSort(t *testing.T) {
	maybeSkipBrowserTest(t)

	server := makeTestServer(t, makeFakeProfile())
	ctx := newContext(context.Background(), t)

	err := chromedp.Do(ctx,
		chromedp.Navigate(server.URL+"/top"),
		chromedp.WaitVisible(chromedp.ID(`#toptable`)),
		chromedp.Click(chromedp.ID(`#cumhdr1`)),
		matchInOrder(t, "#toptable", "F1", "F2", "F3"),
	)
	if err != nil {
		t.Fatal(err)
	}
}
```

Evidence (grep on the pin):
- browsertests/testutils.go:17 — `func makeTestServer(t testing.TB, prof *profile.Profile) *httptest.Server {`
- browsertests/testutils.go:105 — `func makeFakeProfile() *profile.Profile {`
- browsertests/browser_test.go:32 — `func maybeSkipBrowserTest(t *testing.T) {` (skips on non-linux/amd64 or without Chrome — :36-48)
- browsertests/browser_test.go:113-133 — `func newContext(ctx context.Context, t *testing.T) context.Context {` — `chromedp.NoSandbox` + `const browserDeadline = time.Second * 90`
- browsertests/browser_test.go:57-66 — the real pattern `err := chromedp.Do(ctx, chromedp.Navigate(server.URL+"/top"), chromedp.WaitVisible(chromedp.ID(`#toptable`)), …, chromedp.Click(chromedp.ID(`#cumhdr1`)), matchInOrder(t, "#toptable", "F1", "F2", "F3"),)` (inside TestTopTable — the example is a variant verifying the same behavior)
- browsertests/browser_test.go:158 — `func matchInOrder(t *testing.T, query string, sequence ...string) chromedp.Action[chromedp.Void] {`
- browsertests/go.mod:1-11 — "module github.com/google/pprof/browsertests" + "replace github.com/google/pprof => ../" + "github.com/chromedp/chromedp v0.20.1"

### UC-8.2 — New integration test for the /source page: annotated source rendering

Scenario: you want a regression test for the annotated-source page after
changing the renderer: open `/source?f=F3` (filter by function), wait for
`#content` to display and assert that function F3 appears in the content —
the same shape as the existing TestSource, but as a dedicated test for
the filter query.

```go
// File: browsertests/source_extra_test.go — module github.com/google/pprof/browsertests
package browsertests

import (
	"context"
	"testing"

	"github.com/chromedp/chromedp"
)

func TestSourceFilteredByFunction(t *testing.T) {
	maybeSkipBrowserTest(t)

	server := makeTestServer(t, makeFakeProfile())
	ctx := newContext(context.Background(), t)

	err := chromedp.Do(ctx,
		chromedp.Navigate(server.URL+"/source?f=F3"),
		chromedp.WaitVisible(chromedp.ID(`#content`)),
		matchRegexp(t, "#content", `F3`),
	)
	if err != nil {
		t.Fatal(err)
	}
}
```

Evidence (grep on the pin):
- browsertests/browser_test.go:94-107 — TestSource — `server := makeTestServer(t, prof)` :98, `chromedp.Navigate(server.URL+"/source?f=F3")` :102, `chromedp.WaitVisible(chromedp.ID(`#content`))` :103 (the original pattern of the example)
- browsertests/browser_test.go:137 — `func matchRegexp(t *testing.T, query, re string) chromedp.Action[chromedp.Void] {`
- browsertests/testutils.go:17 — `func makeTestServer(t testing.TB, prof *profile.Profile) *httptest.Server {`

Dependencies: the separate module `github.com/google/pprof/browsertests`
with `replace github.com/google/pprof => ../` (browsertests/go.mod:1-7);
external dependency `github.com/chromedp/chromedp v0.20.1` (go.mod:11);
a Chrome binary on the test machine (`maybeSkipBrowserTest` checks for
`google-chrome`/`chrome` — browser_test.go:40-47). Nothing imports this
test module. Build: `go test ./...` inside `browsertests/` (tests self-skip
without Chrome: browser_test.go:36-48).

## s09 — measurement (★2) · `internal/measurement`

Utilities to transform/format profile sample values — `ScaleProfiles`
(measurement.go:32) scales the units of a set of profiles down to the
smallest common unit for merge compatibility; `Scale`/`ScaledLabel`/
`Percentage` (measurement.go:129/156/167) convert and format value labels
for the UI.

### UC-9.1 — Scale several profiles to one common unit before merging

Scenario: merging N profiles collected at different times (one counted in
`samples`, another in `time`/`bytes` at a different scale); so that
`profile.Merge` does not add up two different units, run `ScaleProfiles`
first — the exact order the production fetch pipeline uses.

```go
// File: internal/pproftool/normalize.go — consumer inside module github.com/google/pprof
package pproftool

import (
	"os"

	"github.com/google/pprof/internal/measurement"
	"github.com/google/pprof/profile"
)

// loadAndNormalize reads gzipped profile files and rescales every
// sample to one common unit so the set can be merged.
func loadAndNormalize(paths ...string) ([]*profile.Profile, error) {
	var profiles []*profile.Profile
	for _, path := range paths {
		data, err := os.ReadFile(path)
		if err != nil {
			return nil, err
		}
		prof, err := profile.ParseData(data)
		if err != nil {
			return nil, err
		}
		profiles = append(profiles, prof)
	}
	if err := measurement.ScaleProfiles(profiles); err != nil {
		return nil, err
	}
	return profiles, nil
}
```

Evidence (grep on the pin):
- internal/measurement/measurement.go:32 — `func ScaleProfiles(profiles []*profile.Profile) error {`
- internal/driver/fetch.go:260 — `if err := measurement.ScaleProfiles(profiles); err != nil {` (called before merge in the production pipeline)
- internal/measurement/measurement.go:89 — `func CommonValueType(ts []*profile.ValueType) (*profile.ValueType, error) {` (the common-unit API ScaleProfiles uses)
- profile/profile.go:182 — `func ParseData(data []byte) (*Profile, error) {`
- profile/merge.go:44 — `func Merge(srcs []*Profile) (*Profile, error) {` (the next step after ScaleProfiles)

### UC-9.2 — Convert a sample value's unit and print it like the UI does

Scenario: print each sample of a profile in the reader-chosen unit (e.g.
from `nanoseconds` to `milliseconds`); `Scale` returns the converted
value plus the new unit, and `ScaledLabel` formats it straight into a UI
label without string assembly on your side.

```go
// File: internal/pproftool/samples.go — consumer inside module github.com/google/pprof
package pproftool

import (
	"fmt"

	"github.com/google/pprof/internal/measurement"
	"github.com/google/pprof/profile"
)

// printSamples prints every sample value converted to outUnit, using
// the same label formatting pprof's UI uses.
func printSamples(prof *profile.Profile, outUnit string) {
	if len(prof.SampleType) == 0 {
		return
	}
	unit := prof.SampleType[0].Unit
	for i, s := range prof.Sample {
		if len(s.Value) == 0 {
			continue
		}
		scaled, scaledUnit := measurement.Scale(s.Value[0], unit, outUnit)
		fmt.Printf("#%d %v %s (%s)\n", i, scaled, scaledUnit,
			measurement.ScaledLabel(s.Value[0], unit, outUnit))
	}
}
```

Evidence (grep on the pin):
- internal/measurement/measurement.go:129 — `func Scale(value int64, fromUnit, toUnit string) (float64, string) {`
- internal/measurement/measurement.go:156 — `func ScaledLabel(value int64, fromUnit, toUnit string) string {`
- internal/driver/driver_focus.go:177 — `scaledValue, unit := measurement.Scale(v, ranges[0][2], ranges[0][2])` (a real Scale call site)
- internal/driver/tagroot.go:126 — `value = measurement.ScaledLabel(numLabel, numUnits[i], outputUnit)` (a real ScaledLabel call site for UI labels)
- profile/profile.go:66-68 — `type ValueType struct { … Unit string // seconds, nanoseconds, bytes, etc` (where the example's `unit` comes from)
- profile/profile.go:75-77 — `type Sample struct { … Value []int64` (the value type passed to Scale/ScaledLabel)

### UC-9.3 — Compute each sample's percentage share of the total

Scenario: pprof's Top table prints flat/cumulative percentage columns; a
custom consumer (e.g. a metrics exporter) needs the same computation.
`Percentage` takes an int64 value and the total and returns the formatted
percentage string — the same helper report.go uses for its % columns.

```go
// File: internal/pproftool/share.go — consumer inside module github.com/google/pprof
package pproftool

import (
	"fmt"

	"github.com/google/pprof/internal/measurement"
	"github.com/google/pprof/profile"
)

// printSampleShare prints each sample's share of the profile total,
// the same percentage the Top report prints per row.
func printSampleShare(prof *profile.Profile) {
	var total int64
	for _, s := range prof.Sample {
		total += s.Value[0]
	}
	for i, s := range prof.Sample {
		fmt.Printf("#%d: %s of total\n", i, measurement.Percentage(s.Value[0], total))
	}
}
```

Evidence (grep on the pin):
- internal/measurement/measurement.go:167 — `func Percentage(value, total int64) string {`
- internal/report/report.go:488 — `measurement.Percentage(cumSum, rpt.total))` (the real call site — the report's % column)
- internal/report/report.go:864-865 — `item.FlatFormat, measurement.Percentage(item.Flat, rpt.total),` + `measurement.Percentage(flatSum, rpt.total),` (the flat % columns in the Top table)

Dependencies: `profile` (the input); through real integration also
`internal/graph`, `internal/report`, `internal/driver` — the recipes
above stop at measurement's own API level and pull nothing else. No
external dependency (root module, go.mod:1,3). Build: `go build ./...`
and `go test ./...` from the root module.

## Coverage note

This set covers all 8 reusable items (s01, s03–s09; s02 internal/driver
is the orchestrator that consumes them all and has no reusable surface of
its own). 23 use cases total: 3 per package except browsertests (2).
Builds were not executed in the measurement environment (no Go
toolchain); every behavioral claim above is anchored to a verbatim
`file:line` quote from the pinned tree instead, and `04-overview.md`
records the real `go build ./... && go test ./...` run (12/12 packages
with tests pass, with binutils + llvm installed) as the build evidence
for the repository as a whole.



