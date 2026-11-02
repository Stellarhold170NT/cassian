---
subject: google/pprof
measured_at: dbd0ed30aa888a30e21ba83b9831ac0e80d41022
status: final
---

# Folder structure

All measurements below were taken on the pinned tree (see
[`01-cartography.md`](01-cartography.md)): 86 `.go` files / 30,683 LOC
(53 non-test + 33 `*_test.go`), matching the census exactly.

## (1) Top-level zones

The depth-2 directory tree (identical 1-1 to the top-level list in
`01-cartography.md`, minus `.git*`), with each zone's role and the LOC it
contains (per the module map):

| Zone | Path | Role |
|---|---|---|
| Binary entry | `pprof.go` (root, package main) | `func main()` (pprof.go:29) calls `driver.PProf(&driver.Options{UI: newUI()})` (pprof.go:30) and defines `readlineUI` (m15, 120 LOC including the folded third_party/svgpan). |
| Public API | `driver/` | 1 file `driver.go` (300 LOC): `func PProf(o *Options) error` (driver/driver.go:33) plus the plugin-agnostic interface set (Options/Writer/FlagSet/Fetcher/Symbolizer/ObjTool/UI) so the main binary never imports internal/* (m11). |
| Core engine | `internal/` | 11 unexported Go subpackages (m02..m07, m09, m10, m12..m14): `internal/driver` orchestrates at 8,056 LOC / 24 files; `internal/report` 4,467; `internal/binutils` 2,750; `internal/graph` 2,628; `internal/elfexec` 887; `internal/symbolizer` 856; `internal/measurement` 416; `internal/symbolz` 366; `internal/proftest` 229 (test helper); `internal/plugin` 219 (interface contract); `internal/transport` 181. |
| Data model | `profile/` | The central library (m01, 8,627 LOC / 16 files — the largest item in the repo): in-memory profile.proto representation + parse/encode/merge/filter/prune + legacy parsers. Detailed in (2). |
| Format spec | `proto/` | The format specification: only 2 non-Go files — `profile.proto` (10,017 B) + `README.md` (7,954 B); **0 .go files** (see deviation 3 below). |
| Fuzz | `fuzz/` | go-fuzz harness (m17, 71 LOC): `package pprof`, `func Fuzz` (fuzz/main.go:24); with `corpus/` (5 entries: `cppbench.cpu.pb` 23,631 B, `gobench.cpu.pb` 8,248 B, `go.crc32.cpu.pb` 5,032 B, `java.cpu.pb` 3,537 B, `empty` 0 B) + `testdata/` + README. |
| Integration test | `browsertests/` | A SEPARATE Go module (m08, 416 LOC): `browsertests/go.mod:1 module github.com/google/pprof/browsertests` + `:6 replace github.com/google/pprof => ../`; drives Chrome via chromedp; 5 files (browser_test.go, testutils.go, go.mod, go.sum, README.md) + testdata. |
| Documentation | `doc/` | `doc/README.md` ("pprof is a tool for visualization and analysis of profiling data") + `doc/images/` (callgraph.png + a `webui/` set of 8 screenshots: graph, flame, flame-multi, flame-menu, source, source-expanded, top, disasm). |
| Vendored asset | `third_party/svgpan/` | SVG pan/zoom wrapper: `svgpan.go` 11 LOC with `//go:embed svgpan.js` (:10); imported in exactly one place — internal/driver/svg.go:21. |
| CI | `.github/workflows/` | Exactly ONE workflow, `ci.yaml` — this repository is far more minimal than typical multi-workflow setups. |

Overall shape: a flat, google-style Go layout — a thin public API at
`driver/`, all machinery under `internal/` (11 of 17 items), an
independent data model in `profile/`, and the remainder (~1/3 of the
items) is test infrastructure (fuzz, browsertests, proftest).

## (2) Representative internal structure: item m01 `profile`

The representative is the largest Go package (m01 profile, 8,627 LOC /
16 files). Unlike multi-subpackage repositories, `profile` is **one flat
package with no subpackages**. Re-measured on the clone, exact:

| File | LOC | Kind | Role (grep-verified anchor) |
|---|---|---|---|
| profile/legacy_profile.go | 1,228 | main | Parser for the legacy Go pprof formats (heap/contention text). |
| profile/profile.go | 877 | main | The central type `Profile` (:35 — `type Profile struct {`) + package doc :15-16 "Package profile provides a representation of profile.proto and methods to encode/decode profiles in this format."; Parse/ParseData/Write/CheckValid/Aggregate/Copy. |
| profile/merge.go | 673 | main | Merging multiple profiles: `func Merge(srcs []*Profile) (*Profile, error)` (merge.go:44). |
| profile/encode.go | 596 | main | Per-message codec implementation: `(p *Profile) decoder()` (:23), `preEncode` (:30), `encode` (:133), `postDecode` (:249), plus ValueType/Sample/... (:405, :422, ...). |
| profile/proto.go | 384 | main | The HAND-WRITTEN protobuf wire codec — comment :15 "This file is a simple protocol buffer encoder and decoder." + :27-28 "The two methods are simple enough to be implemented by hand rather than by using a protocol compiler." (see deviation 3). |
| profile/legacy_java_profile.go | 315 | main | Parser for legacy Java profiles. |
| profile/filter.go | 275 | main | Filter by name/tag: `FilterSamplesByName` (:21), `FilterTagsByName` (:146), `FilterSamplesByTag` (:254). |
| profile/prune.go | 189 | main | Call-tree pruning: `func (p *Profile) Prune(dropRx, keepRx *regexp.Regexp)` (:56), `PruneFrom` (:150). |
| profile/index.go | 64 | main | Sample type lookup: `func (p *Profile) SampleIndexByName(sampleIndex string) (int, error)` (:26), `sampleTypes` (:58). |
| profile/profile_test.go | 2,038 | test | The largest test file in the package — larger than every main file except legacy_profile.go. |
| profile/filter_test.go | 604 | test | |
| profile/merge_test.go | 538 | test | |
| profile/legacy_profile_test.go | 321 | test | |
| profile/prune_test.go | 230 | test | |
| profile/proto_test.go | 181 | test | |
| profile/index_test.go | 114 | test | |

Sum: **main 4,601 + test 4,026 = 8,627 LOC** — matches the module map
item exactly; the 30,683 census is the repository total. Test ratio ≈
46.7% (4,026/8,627).

Layout notes:

- Tests sit side-by-side with the code (standard Go), in 1-1 functional
  pairs: `filter.go` ↔ `filter_test.go`, `merge.go` ↔ `merge_test.go`,
  `prune.go` ↔ `prune_test.go`, `index.go` ↔ `index_test.go`,
  `proto.go` ↔ `proto_test.go`, `legacy_profile.go` ↔
  `legacy_profile_test.go`; uniquely, `legacy_java_profile.go` has no
  dedicated test file (it is covered structurally through
  profile_test.go / proto_test.go — a structural assertion, not a
  coverage claim).
- Test data is separated in `profile/testdata/` — 28 entries in 4 fixture
  families, named `<binary-family>.<profile-kind>[.string]`
  (`ls profile/testdata | wc -l` = 28): `cppbench.*` 14 (cpu, heap,
  growth, contention, thread + `.string`, `.all`, `.none` variants),
  `java.*` 6 (cpu, heap, contention), `go.*` 4 (go.crc32.cpu,
  go.godoc.thread), `gobench.*` 4 (cpu, heap).
- No generated files, no non-Go assets in the package: all 16 files are
  hand-written `.go`.
- The weight skews toward legacy parsers: the 2 legacy files account for
  1,543/4,601 main LOC (33.5%) — when learning the code, skip them at
  first (see (5)).

## (3) Naming conventions observed in code (7 patterns)

1. **Package == directory name** for 81/86 `.go` files; exactly 5 files
   deviate, all in the two shapes analyzed in (4) (2 `fuzz/` files →
   `package pprof`, 3 `package main` outside cmd/). Evidence: a loop
   comparing `grep -m1 '^package '` against the directory basename across
   all 86 files yields exactly 5 MISMATCH lines and nothing else.
2. **The package's anchor file is named after its central type**:
   `profile/profile.go` ↔ `type Profile` (:35), `internal/plugin/plugin.go`
   ↔ `type Options struct` (:28), `internal/graph/graph.go` ↔
   `type Graph` (graph.go:50), `internal/symbolizer/symbolizer.go` ↔
   `type Symbolizer` (symbolizer.go:36). The pattern repeats in every
   one-file package: `elfexec.go`, `transport.go`, `measurement.go`,
   `symbolz.go`, `binutils.go` — file name equals package name.
3. **Suffixes named after the external tool in `internal/binutils`**: one
   file per wrapper — `addr2liner.go`, `addr2liner_llvm.go`,
   `addr2liner_nm.go`, `disasm.go`. The reader immediately knows which
   file talks to which binary (llvm-symbolizer, addr2line, nm, objdump).
4. **`legacy_` prefix for old-format parsers**: `profile/legacy_profile.go`
   (Go pprof legacy) and `profile/legacy_java_profile.go` (Java legacy) —
   cleanly separating live code (profile.go/merge.go/...) from
   backward-compatibility code.
5. **The web-UI cluster in `internal/driver`**: `webui.go` (HTTP server),
   `webhtml.go` (templates — `//go:embed html` at webhtml.go:43), `html/`
   (11 assets: common.css, common.js, graph.css, graph.html, header.html,
   plaintext.html, source.html, stacks.css, stacks.html, stacks.js,
   top.html), `svg.go` (svgpan import :21); parallel in report:
   `source_html.go`. Names `*html*`/`web*` = presentation layer.
6. **The CLI-layer cluster in `internal/driver`**: `cli.go`, `commands.go`,
   `flags.go`, `options.go`, `config.go`, `settings.go`, `interactive.go`,
   `tempfile.go`, `driver_focus.go` — each file name is one command-line
   concern, separated from `driver.go` (orchestration) and `fetch.go`
   (profile I/O).
7. **Fixtures travel with the package in `testdata/`**: 8 testdata
   directories — fuzz/testdata, profile/testdata (28 entries — 4
   families), browsertests/testdata, internal/report/testdata,
   internal/proftest/testdata, internal/graph/testdata,
   internal/driver/testdata, internal/binutils/testdata — standard Go
   (the go tool ignores testdata); fuzz additionally has `fuzz/corpus/`
   (5 entries) following the go-fuzz convention.

## (4) Deviations from Go conventions (each with ≥2 examples, grep-verified on the pin)

**Deviation 1 — the binary entry `func main` sits at the ROOT; there is
no `cmd/` directory.**

- Example 1: `pprof.go:29 func main() {` — the only file of package main
  is at the root (compare the common `cmd/<name>/main.go` convention; the
  root listing has no `cmd/`). Call site: `pprof.go:30 if err :=
  driver.PProf(&driver.Options{UI: newUI()}); err != nil {`.
- Example 2: `internal/binutils/testdata/build_binaries.go:32 func main()`
  — a package-main helper that regenerates test binaries (inside testdata
  so the go tool ignores it, but still a `func main` outside cmd/; see
  m16).
- Example 3: `internal/report/testdata/sample/sample.go:30 func main()` —
  the second package-main helper (grep 'func main' over the whole repo
  returns exactly 3 hits).
- Re-measured root files: `ls -p | grep -v /` = AUTHORS, CONTRIBUTING.md,
  CONTRIBUTORS, LICENSE, README.md, go.mod, go.sum, pprof.go, test.sh —
  no cmd/, no Makefile (build/test/lint live in the 71-line `test.sh`
  which directly calls staticcheck/go test/vet/golangci-lint/gofmt).

**Deviation 2 — the `fuzz/` directory contains `package pprof` (package
name ≠ directory name).**

- Example 1: `fuzz/main.go:17 package pprof` — verbatim with the comment
  :15-16 "// Package pprof is used in conjunction with
  github.com/dvyukov/go-fuzz/go-fuzz // to fuzz ParseData function.";
  `func Fuzz(data []byte) int` (:24).
- Example 2: `fuzz/fuzz_test.go:15 package pprof` — the test file also
  uses package name `pprof` inside dir `fuzz` (not `fuzz_test`).
- Honest note: both examples live in one directory (the whole package);
  this is deliberate upstream (the harness mimics the package being
  fuzzed), not a bug — but for a Go reader, the import path
  `github.com/google/pprof/fuzz` resolving to package name `pprof` is the
  single surprise in the repository.

**Deviation 3 — NO protoc-gen-go: the protobuf codec is hand-written and
`proto/` contains no Go.**

- Example 1: `ls -la proto/` = only `README.md` (7,954 B) + `profile.proto`
  (10,017 B) — **0 .go files**; the `proto` directory appears in the tree
  but is not a Go package.
- Example 2: `profile/proto.go:15` "This file is a simple protocol buffer
  encoder and decoder." + `:27-28` "The two methods are simple enough to
  be implemented by hand rather than by using a protocol compiler." — the
  wire-format codec is hand-written inside package `profile`, not
  generated from the .proto.
- Example 3: `grep -rn 'Code generated' --include='*.go' .` over the whole
  repo = **0 hits** — not a single generated file in the tree.
  Consequence: the messages implement the `decoder()/encode(*buffer)`
  interfaces themselves (encode.go:23, :30, :133, :249, :405, :422, ...).

**Deviation 4 — two packages at different paths share the SAME name
`driver` (driver/ and internal/driver/).**

- Example 1: `driver/driver.go` — `package driver` (dir `driver`, import
  path `github.com/google/pprof/driver` — imported at pprof.go:26 and
  browsertests/testutils.go:13).
- Example 2: `internal/driver/driver.go` — also `package driver` (verbatim
  header internal/driver/svg.go:15 `package driver`); counting non-test
  package decls: **17 files declaring `package driver` = 1 (driver/) + 16
  (internal/driver/)**.
- Consequence: when reading the code you must distinguish by import path,
  not package name (grep `pprof/driver"` over the repo shows only 2
  importers of the public one — pprof.go:26, browsertests/testutils.go:13;
  the rest of the repo uses the internal one).

**Deviation 5 — a multi-module repository: `browsertests/` is a separate
Go module with a replace directive.**

- Example 1: `browsertests/go.mod:1 module
  github.com/google/pprof/browsertests` — the SECOND go.mod in the tree
  (root: go.mod:1 `module github.com/google/pprof`), go 1.26.0 (:3).
- Example 2: `browsertests/go.mod:6 replace github.com/google/pprof => ../`
  (comment :5 "Use the version of pprof in this directory tree.") — pinned
  to the in-tree copy.
- Example 3 (operational consequence): `test.sh:23-24` verbatim comment
  "# Note: browsertests is in a separate module and is therefore not
  covered by a local ./... pattern." — every quality step must repeat
  `(cd browsertests && ...)`: :28 (staticcheck), :46-47 (go test + -race
  with retry), :59 (go vet), :62 (golangci-lint), :71 (gofmt).

**Places CHECKED and confirmed NOT deviating** (to avoid inventing
deviations):

- `testdata/` is standard Go: 8 directories, exactly per the go-tool
  convention; fixtures named `<family>.<kind>[.string]` across 4 binary
  families (see (3.7)).
- `go:embed` is modern-standard: exactly 5 sites
  (browsertests/browser_test.go:91, :199; internal/proftest/proftest.go:169;
  internal/driver/webhtml.go:43; third_party/svgpan/svgpan.go:10) — no
  alternative generated-asset pattern.
- Build constraints: `grep -rn '+build'` = 0 hits; `grep -rl 'go:build'` =
  0 files — the repository has NO OS/arch-specific files (it does not
  need any).
- No `vendor/` (`ls -d vendor` → No such file or directory); the root
  go.mod is standard: module github.com/google/pprof (:1), go 1.26.0 (:3),
  2 direct + 1 indirect dep (see `01-cartography.md`).
- `third_party/svgpan`: a pre-modules vendoring convention (instead of a
  module dependency) — noted but NOT counted as a deviation because it is
  a single instance with a single import site (svg.go:21); the file itself
  is transparent (`//go:embed svgpan.js` :10, 11 LOC).

## (5) Suggested reading order (and why)

1. **`doc/README.md:1-5`** — the one-sentence mental model: "pprof is a
   tool for visualization and analysis of profiling data." + "pprof reads
   a collection of profiling samples in profile.proto format and
   generates reports to visualize and help analyze the data."
2. **`proto/README.md` + `proto/profile.proto`** — the central data
   format: every structure in `profile/` mirrors these messages
   (Profile/Sample/Location/Mapping/Function); understanding the format
   first keeps the parser reading on track.
3. **`profile/profile.go`** (package doc :15-16, :35 `type Profile
   struct`) — the data model + Parse/ParseData/Write; then `proto.go` +
   `encode.go` (the wire codec), then `merge.go:44`, `filter.go`,
   `prune.go:56`, `index.go:26` (the transformations). READ LAST:
   `legacy_profile.go` + `legacy_java_profile.go` (1,543 LOC of
   backward-compatibility code, not needed for the main flow).
4. **`internal/plugin/plugin.go:28`** (`type Options struct`) — the
   interface contract (UI/FlagSet/Fetcher/Symbolizer/ObjTool/Writer/
   HTTPServer) connecting the driver to its implementations; this is the
   map of the architecture's plug points.
5. **`driver/driver.go:33`** (`func PProf(o *Options) error`) — the
   public API + plugin-agnostic interface set (m11): the outermost shell
   a consumer embedding pprof sees.
6. **`pprof.go:29-30`** — the binary entry: `main()` →
   `driver.PProf(&driver.Options{UI: newUI()})`; the only place wiring
   readlineUI (same file) into the engine.
7. **`internal/driver/driver.go:37`** (`func PProf(eo *plugin.Options)
   error`) — the real orchestrator (m02, 8,056 LOC): read in the order
   fetch.go (acquire the profile) → report (generate output) →
   interactive.go/webui.go (the two presentation modes).
8. **`internal/report/report.go:88`** (`func Generate(...)`) +
   **`internal/graph/graph.go:330`** (`func New(prof *profile.Profile,
   o *Options) *Graph`) — the processing heart: profile → graph → output
   formats (report.go:38 const block).
9. **The auxiliary symbolize tier**: `internal/symbolizer/symbolizer.go`
   (m07), `internal/symbolz/` (m10), `internal/binutils/binutils.go`
   (m04 — the nm/addr2line/llvm-symbolizer/objdump wrapper),
   `internal/elfexec/` (m06), `internal/transport/` (m14) — read after
   plugin.go since they are implementations of the contract from step 4.
10. **Finally — test infrastructure**: `internal/proftest/proftest.go`
    (shared test helper, go:embed large.cpu :169), `browsertests/`
    (separate module, chromedp), `fuzz/` (go-fuzz harness),
    `third_party/svgpan/` (asset) — plus `test.sh` when you want to run
    the whole verification suite (staticcheck → go test → race → vet →
    golangci-lint → gofmt).

Rationale for the order: it follows the value line **format (proto) →
data model (profile) → contracts (plugin/driver) → entry (pprof.go) →
orchestration (internal/driver) → transformations (report/graph) →
auxiliaries (symbolize) → test infrastructure**; each step only uses
concepts from the previous ones, so you never have to double back.
