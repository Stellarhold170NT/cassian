---
subject: google/pprof
measured_at: dbd0ed30aa888a30e21ba83b9831ac0e80d41022
status: final
---

# Module map

- Subject: `google/pprof`, language Go. The module universe is the **Go
  package**: a directory holding at least one `.go` file, kept at depth ≤ 3
  from the repo root. Measured on the pinned tree (see
  [`01-cartography.md`](01-cartography.md)): 19 raw Go directories
  normalize to **17 items** — `third_party/svgpan` (11 LOC) folds into the
  root `pprof` item under the sub-50-LOC rule, and the testdata helper
  packages are kept as their own items where the census counts them
  (`internal/report/testdata/sample` is test infrastructure only).
- Census: **86 files / 30,683 LOC** (`.go`, tests included) — the 17 items
  sum exactly to the repository total (files 16+24+14+7+4+2+2+2+2+2+1+2+1+
  2+2+1+2 = 86; LOC 8627+8056+4467+2750+2628+887+856+416+416+366+300+229+
  219+181+120+94+71 = 30,683).
- Dependency convention: **depends on** lists the items a package imports
  from the universe (non-test imports, grep-verified on the pin); **imported
  by** lists the items that import it. The graph has **33 directed edges**;
  every edge appears exactly once in each direction's column. Test-only
  imports are not counted (e.g. 13 `*_test.go` files import `proftest`,
  but its non-test edge count is 0).
- The `rating` column is the 1–5 reusability score from the measurement
  (see [`07-usage.md`](07-usage.md) and
  [`tracking/pprof.md`](../../tracking/pprof.md) for the extraction
  candidate).

## Index

| id | module | path | files | loc | rating | extracted |
|---|---|---|---|---|---|---|
| m01 | profile | `profile` | 16 | 8,627 | 4 | yes |
| m02 | internal/driver | `internal/driver` | 24 | 8,056 | 1 | yes |
| m03 | report | `internal/report` | 14 | 4,467 | 3 | yes |
| m04 | binutils | `internal/binutils` | 7 | 2,750 | 3 | yes |
| m05 | graph | `internal/graph` | 4 | 2,628 | 3 | yes |
| m06 | elfexec | `internal/elfexec` | 2 | 887 | 2 | yes |
| m07 | symbolizer | `internal/symbolizer` | 2 | 856 | 2 | yes |
| m08 | browsertests | `browsertests` | 2 | 416 | 2 | yes |
| m09 | measurement | `internal/measurement` | 2 | 416 | 2 | yes |
| m10 | symbolz | `internal/symbolz` | 2 | 366 | 1 | yes |
| m11 | driver | `driver` | 1 | 300 | 1 | yes |
| m12 | proftest | `internal/proftest` | 2 | 229 | 1 | yes |
| m13 | plugin | `internal/plugin` | 1 | 219 | 1 | yes |
| m14 | transport | `internal/transport` | 2 | 181 | 2 | yes |
| m15 | pprof | `.` (root) | 2 | 120 | 1 | yes |
| m16 | binutils/testdata | `internal/binutils/testdata` | 1 | 94 | 1 | yes |
| m17 | fuzz | `fuzz` | 2 | 71 | 1 | yes |

## Items

### m01 profile

Central library of the repository — the in-memory representation of
profile.proto (`type Profile struct` profile.go:35) with decode
`Parse`/`ParseData` (profile.go:172/182), encode `Write` (profile.go:345),
validate/aggregate/copy (`CheckValid` 364, `Aggregate` 445, `Copy` 867),
and the legacy Go heap/contention + Java format parsers
(`legacy_profile.go`, `legacy_java_profile.go`).

- Main files: legacy_profile.go (1,228), profile.go (877),
  legacy_java_profile.go; tests: profile_test.go (2,038), filter_test.go,
  merge_test.go, proto_test.go.
- Depends on: — (the only central item with zero in-universe imports).
- Imported by: browsertests, driver, fuzz, graph, internal/driver,
  measurement, plugin, report, symbolizer, symbolz (10 of the other 16
  items).
- Extracted to `modules/pprof/profile` (byte-identical at the pin, see
  `PROVENANCE.md`).

### m02 internal/driver

The orchestrator of pprof — `PProf()` (driver.go:37) is the entry called
by main (pprof.go:29-31): parses flags and commands, fetches and
symbolizes profiles from files/URLs (fetch.go), generates reports through
internal/report, then runs either the interactive (readline) shell or the
web UI (webui.go + webhtml.go).

- Main files: fetch.go (633), webui.go (480), commands.go (469),
  interactive.go (422), driver.go (403); tests: driver_test.go (1,772),
  fetch_test.go (840), interactive_test.go, tagroot_test.go,
  webui_test.go.
- Depends on: binutils, graph, measurement, plugin, pprof (root, via the
  third_party/svgpan import at internal/driver/svg.go:21), profile,
  report, symbolizer, transport.
- Imported by: driver.
- Extracted to `modules/pprof/internal/driver`.

### m03 report

Turns a fetched `*profile.Profile` into reader-facing output — `Generate`
(report.go:88) is the central entry; it builds a trimmed graph
(`newTrimmedGraph` report.go:124) and renders the output format declared
in the const block report.go:38 (Callgrind/Comments/Dis/Dot/List/Proto/
Raw/Tags/Text/TopProto/Traces/Tree/WebList). Annotated source listings
are handled by source.go (`printSource` source.go:43, `MakeWebList`
source.go:243 for the web UI); the flame/stack data path lives in
stacks.go (`Stacks` stacks.go:83).

- Main files: report.go (1,386), source.go (1,124), stacks.go (220),
  source_html.go (71); tests: report_test.go (768), source_test.go (340),
  stacks_test.go (240).
- Depends on: graph, measurement, plugin, profile.
- Imported by: internal/driver.
- Extracted to `modules/pprof/report`.

### m04 binutils

Implements `plugin.ObjTool` — the `Binutils` struct (binutils.go:40)
locates external tools (llvm-symbolizer, addr2line, nm, objdump via
`SetTools`/`initTools` binutils.go:130/159), opens ELF/Mach-O(fat)/PE
binaries by magic number (`Open` binutils.go:304) and returns `ObjFile`
objects mapping runtime addresses → symbol/file:line (fileNM uses nm,
fileAddr2Line uses llvm-symbolizer/addr2line), plus `Disasm` through
objdump (binutils.go:276).

- Main files: binutils.go (764), addr2liner.go (241), addr2liner_llvm.go
  (184), disasm.go (180), addr2liner_nm.go (144); tests: binutils_test.go
  (1,077), disasm_test.go (160).
- Depends on: elfexec, plugin.
- Imported by: internal/driver, symbolizer.
- Extracted to `modules/pprof/binutils` (its committed testdata binaries
  form the separate item m16).

### m05 graph

Collects a profile's samples into a directed call graph — `New`
(graph.go:330) builds the `Graph` (graph.go:50) from a profile; handles
pruning/balancing (`TrimTree` 479, `DiscardLowFrequencyNodes` 752,
`RemoveRedundantEdges` 899) and exports DOT via `ComposeDot`
(dotgraph.go:57).

- Main files: graph.go (1,187), dotgraph.go; tests: graph_test.go (547),
  dotgraph_test.go.
- Depends on: measurement, profile.
- Imported by: internal/driver, report.
- Extracted to `modules/pprof/graph`.

### m06 elfexec

ELF binary parsing utilities for the binutils layer — computes kernel and
PIE load/base addresses (`GetBase` 216, `kernelBase` 167), reads the GNU
build-id from note sections/segments (`GetBuildID` 121, `parseNotes` 39),
finds the text program header and matches program headers against memory
mappings by file offset (`FindTextProgHeader` 287,
`ProgramHeadersForMapping` 310, `HeaderForFileOffset` 358).

- Main files: elfexec.go (377); tests: elfexec_test.go (510).
- Depends on: —.
- Imported by: binutils.
- Extracted to `modules/pprof/elfexec`.

### m07 symbolizer

Fills symbols/files/lines into the profile — the `Symbolizer` struct
(symbolizer.go:36) implements `plugin.Symbolize` via `Symbolize`
(symbolizer.go:50) along two paths: local through binutils
(`doLocalSymbolize` 129) and HTTP symbolz (`postURL` 101), plus the
`Demangle` entry (symbolizer.go:249) using the external
ianlancetaylor/demangle library.

- Main files: symbolizer.go (357); tests: symbolizer_test.go (499).
- Depends on: binutils, plugin, profile, symbolz.
- Imported by: internal/driver.
- Extracted to `modules/pprof/symbolizer`.

### m08 browsertests

A separate Go module (`go.mod`: module github.com/google/pprof/
browsertests, `replace github.com/google/pprof => ../`) running
integration tests for pprof's web interface — builds a real server
through `driver.PProf` with fake plumbing (`makeTestServer`
testutils.go:17) and drives Chrome via chromedp to verify the Top page
(browser_test.go:50), flame graph (74) and source page; self-skips when
Chrome is unavailable (`maybeSkipBrowserTest` browser_test.go:32).

- Main files: testutils.go (216); tests: browser_test.go (200).
- Depends on: driver, profile.
- Imported by: — (nobody imports the test module).
- Extracted to `modules/pprof/browsertests`.

### m09 measurement

Utilities to transform/format profile sample values — `ScaleProfiles`
(measurement.go:32) scales the units of a set of profiles down to the
smallest common unit for merge compatibility; `Scale`/`ScaledLabel`/
`Percentage` (measurement.go:129/156/167) convert and format value labels
for the UI.

- Main files: measurement.go (296); tests: measurement_test.go (120).
- Depends on: profile.
- Imported by: graph, internal/driver, report.
- Extracted to `modules/pprof/measurement`.

### m10 symbolz

Symbolizes a profile using symbolz service output — `Symbolize`
(symbolz.go:43) iterates mappings, collects sources by file/build-id from
`plugin.MappingSources`, sends the hex-address queries through the `syms`
callback and assigns function names to locations (symbolzRE regex, address
adjustment), skipping mappings that already `HasFunctions` when
`force=false`.

- Main files: symbolz.go (196); tests: symbolz_test.go (170).
- Depends on: plugin, profile.
- Imported by: symbolizer.
- Extracted to `modules/pprof/symbolz`.

### m11 driver

The external entry point at the repository root — `PProf` (driver.go:33)
delegates straight to `internaldriver.PProf` with `Options` converted
through `internalOptions()` (driver.go:37), and re-declares the
plugin-agnostic interface set (`Options` driver.go:69, `Writer` 82,
`FlagSet` 88, `Fetcher` 121, `Symbolizer` 126, `ObjTool` 138, `UI` 207) so
the main binary never has to import internal packages.

- Main files: driver.go (300); no test files.
- Depends on: internal/driver, plugin, profile.
- Imported by: browsertests, pprof (root).
- Extracted to `modules/pprof/driver`.

### m12 proftest

Helper package for the tests of other packages (package doc proftest.go:15)
— `Diff` compares two byte buffers using the system diff tool
(proftest.go:38), `EncodeJSON` marshals indented JSON for expected output
(74), `TestUI` is a test double of `plugin.UI` that fails the test on
unexpected `PrintErr` (87), and `LargeProfile` returns an embedded ~1.2 MB
profile for benchmarks (155, `go:embed testdata/large.cpu`).

- Main files: proftest.go (170); tests: proftest_test.go (59).
- Depends on: — (test-only consumers: 13 `*_test.go` files of 6 packages).
- Imported by: — (non-test).
- Extracted to `modules/pprof/proftest`.

### m13 plugin

Defines the plugin interface set the pprof driver requires — `Options`
(plugin.go:28) gathers `Writer`/`FlagSet`/`Fetcher`/`Symbolizer`/
`ObjTool`/`UI` (plugin.go:50/56/92/97/109/179) and `HTTPServer`; the
inversion contract between internal/driver (consumer) and the
implementations (binutils, transport, symbolizer).

- Main files: plugin.go (219); no test files.
- Depends on: profile.
- Imported by: binutils, driver, internal/driver, report, symbolizer,
  symbolz, transport.
- Extracted to `modules/pprof/plugin`.

### m14 transport

Provides an `http.RoundTripper` for fetching profiles/symbols over HTTPS
with client cert/key/CA — `New` (transport.go:49) registers the
tls_cert/tls_key/tls_ca flags on `plugin.FlagSet` (nil flagset → default
round tripper); the transport struct lazy-initializes its TLS config
through `sync.Once` (`initialize` 63) inside `RoundTrip` (102) and
supports the `https+insecure` scheme that skips certificate verification.

- Main files: transport.go (132); tests: transport_test.go (49).
- Depends on: plugin.
- Imported by: internal/driver.
- Extracted to `modules/pprof/transport`.

### m15 pprof

The root package main is the real pprof binary — `main()` (pprof.go:29)
calls `driver.PProf(&driver.Options{UI: newUI()})` (pprof.go:30) and
provides `readlineUI` (pprof.go:41-103, using
github.com/chzyer/readline; kept in pprof.go so the pprof copy vendored
into the Go distribution does not pull the readline dependency). The
second file is third_party/svgpan/svgpan.go (11 LOC, a `go:embed` wrapper
for svgpan.js), folded into the root item under the sub-50-LOC rule.

- Main files: pprof.go (109), third_party/svgpan/svgpan.go (11); no test
  files.
- Depends on: internal/driver (through the post-merge third_party/svgpan
  import at internal/driver/svg.go:21).
- Imported by: driver (m11 declares the types), internal/driver imports
  the svgpan wrapper.
- Extracted to `modules/pprof/pprof`.

### m16 binutils/testdata

Testdata helper package main — the build_binaries.go script (`func main`
build_binaries.go:32) regenerates the committed test binaries in the
directory (exe_linux_64, exe_mac_64, lib_mac_64, exe_windows_64.exe from
hello.c/lib.c) with cc/clang/gcc per GOOS, with a comment reminding
authors to update the hardcoded addresses in TestObjFile/TestMachoFiles/
TestPEFile of binutils_test.go (build_binaries.go:23-24).

- Main files: build_binaries.go (94); no test files.
- Depends on: — (testdata directories are not importable by Go rules).
- Imported by: —.
- Extracted to `modules/pprof/binutils/testdata`.

### m17 fuzz

go-fuzz harness (package pprof, not a binary main) — `Fuzz(data []byte)
int` (main.go:24) feeds arbitrary bytes into `profile.ParseData` to test
parser robustness; fuzz_test.go does the same over the committed corpus
testdata.

- Main files: main.go (27); tests: fuzz_test.go (44).
- Depends on: profile.
- Imported by: —.
- Extracted to `modules/pprof/fuzz`.

## Dependency edges (grep-verified on the pin)

33 directed edges; each listed once as `A → B` meaning A imports B
(non-test imports only):

```
browsertests → driver
browsertests → profile
binutils → elfexec
binutils → plugin
driver → internal/driver
driver → plugin
driver → profile
driver(internal/driver) → binutils        # internal/driver → binutils
driver(internal/driver) → graph           # internal/driver → graph
driver(internal/driver) → measurement     # internal/driver → measurement
driver(internal/driver) → plugin          # internal/driver → plugin
driver(internal/driver) → profile         # internal/driver → profile
driver(internal/driver) → report          # internal/driver → report
driver(internal/driver) → symbolizer      # internal/driver → symbolizer
driver(internal/driver) → transport       # internal/driver → transport
driver(internal/driver) → pprof(root)     # internal/driver → third_party/svgpan (svg.go:21)
fuzz → profile
graph → measurement
graph → profile
measurement → profile
plugin → profile
report → graph
report → measurement
report → plugin
report → profile
symbolizer → binutils
symbolizer → plugin
symbolizer → profile
symbolizer → symbolz
symbolz → plugin
symbolz → profile
transport → plugin
```

Note: `internal/driver` is the only item importing the root `pprof` item,
and the edge goes through the vendored `third_party/svgpan` wrapper
(`internal/driver/svg.go:21`), not through package main.

## Coverage note

Σ files = 86 and Σ LOC = 30,683 — identical to the repository census in
[`01-cartography.md`](01-cartography.md). The item list covers every Go
package directory found at depth ≤ 3 (19 raw directories, 17 items after
folding); nothing in the repository falls outside the universe.
