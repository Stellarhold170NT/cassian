---
subject: google/mtail
measured_at: 4c7e0e1174ac1ead032efe28d86428bbbe0ae145
status: final
---




# Folder structure




All measurements were taken on the pinned tree
`4c7e0e1174ac1ead032efe28d86428bbbe0ae145` (see
[`01-cartography.md`](01-cartography.md)); 18/18 module-map items resolve at
their documented paths (4 `cmd/*` items at depth 2, the other 14 at depth
3-4 under `internal/`).




## (1) Top-level zones




```
$ find . -maxdepth 2 -type d -not -path './.git*' | sort
.
./cmd
./cmd/mdot
./cmd/mfmt
./cmd/mgen
./cmd/mtail
./docs
./docs/designs
./examples
./hooks
./internal
./internal/exporter
./internal/logline
./internal/metrics
./internal/mtail
./internal/runtime
./internal/tailer
./internal/testutil
./internal/waker
```
(depth-3/4 items live below these zones: `internal/metrics/datum`,
`internal/mtail/golden`, `internal/runtime/{code,compiler,vm}`,
`internal/tailer/logstream`.)




| Zone | Path | Role |
|---|---|---|
| Binary CLIs | `cmd/` | 4 programs, each one `package main` in a single file: `cmd/mtail` (278 LOC), `cmd/mgen` (152), `cmd/mdot` (206), `cmd/mfmt` (59) — matches `Makefile:6` `TARGETS = mtail mgen mdot mfmt`. |
| Main wiring | `internal/mtail/` | `Server` orchestrates store + tailer + runtime + exporter + HTTP (`mtail.go:31`, `:176`); plus 13 external-package integration tests, the `testing.go` harness, and the `golden/` subpackage (m13). Second-largest item: 25 files / 4,463 LOC. |
| Language & runtime | `internal/runtime/` | 4 items: `compiler/` (m01 — `.mtail` front-end), `vm/` (m04 — the interpreter), `code/` (m14 — bytecode definitions), and the `runtime/` root (m05 — program loader/lifecycle). |
| Log ingestion | `internal/tailer/` | `Tailer` polls glob patterns → spawns `LogStream`s (`tail.go:30`); the `logstream/` subpackage (m03) turns a pathname into `LogLine` lines (rotation/truncation/reopen, `logstream.go:35`). |
| Metric store | `internal/metrics/` | central `Store` (`store.go:19`) + the `datum/` subpackage (m09 — value types Counter/Gauge/Timer/Text/Histogram). |
| Export | `internal/exporter/` | reads the `Store`, exports Prometheus/varz/json + push targets (`export.go:32`). |
| Shared types | `internal/logline/`, `internal/waker/` | `LogLine` (19 LOC, m18 — the tailer→VM exchange struct) and the `Waker` interface (10 lines, m11 — waking idle poll loops). |
| Test support | `internal/testutil/` | shared test helpers (m10: expvar/timeout/fs/port/race…, 15 files / 504 LOC). |
| Docs | `docs/` | 15 user-facing `.md` pages (Programming-Guide, Language, Metrics, Testing…) + `designs/poll.md`. |
| Example programs | `examples/` | 17 real `.mtail` programs (apache, dhcpd, postfix, rails…) that are also test fixtures (`internal/mtail/examples_integration_test.go:32,37,42`). |
| Git hooks | `hooks/` | 3 scripts: `build`, `post_checkout`, `post_push`. |
| CI/CD | `.github/` + `.gitlab-ci.yml` | 12 GitHub Actions workflows (ci.yml, golangci-lint.yml, codeql-analysis.yml, oss-fuzz.yml, release.yml, automerge.yml…) in parallel with one 28-line `.gitlab-ci.yml` (`:1 image: golang:latest`, `:3 stages:`) — see deviation 5. |
| Root files | `.` | `go.mod:1 module github.com/google/mtail`, `:3 go 1.21.1`; `go.sum` (35,470 bytes); `Makefile` (326 lines: build/test/lint/fuzz/coverage); `Dockerfile` + `Dockerfile.goreleaser`; `.golangci.yml`; `.goreleaser.yml`; `LICENSE` Apache-2.0 (11,358 bytes); `README.md`; `TODO`; `benchmark_results.csv`; `logo.png`; `mtail-mode.el`; `mtail.service`; `log_rewriter.awk`; `subject_summarizer.mtail`. |




Dependency shape across zones (41 grep-verified import edges, see
[`02-module-map.md`](02-module-map.md)): `cmd/mtail → {mtail, exporter,
metrics, waker}`; `mtail → {runtime, tailer, exporter, metrics, logline,
waker, testutil, datum}`; `runtime → {compiler, vm, code, metrics, datum,
logline}`; `tailer → {logstream, logline, waker}`; `vm → {code, metrics,
datum, logline}`; `exporter → {metrics, datum}`; `cmd/{mdot,mgen,mfmt} →
compiler`.




## (2) Representative internal structure: `internal/runtime/compiler`




The largest item (m01, 28 files / 10,116 LOC) is a package root plus nine
subpackages (unlike codesearch-style flat packages):




| Unit | Files (.go) | Main LOC | Test LOC | Total | Role |
|---|---|---|---|---|---|
| root `compiler/` | 2 | 138 | 51 | 189 | Entry: `type Compiler struct` (:19), `New` (:27), `SetOption` (:35), pipeline `Compile` (:89) |
| `ast/` | 3 | 543 | 83 | 626 | AST nodes + `Walk` visitor |
| `checker/` | 2 | 970 | 668 | 1,638 | Type-check: `Check` (`checker.go:45`) |
| `codegen/` | 2 | 632 | 1,138 | 1,770 | Bytecode generation: `CodeGen` (`codegen.go:36`) — **tests > main** |
| `errors/` | 2 | 56 | 20 | 76 | `compileError`/`ErrorList` (see deviation 2) |
| `opt/` | 2 | 170 | 502 | 672 | `Optimise` runs twice in the pipeline (`opt.go:17`) |
| `parser/` | 9 | 2,828 | 1,004 | 3,832 | lexer + goyacc parser + unparser + sexp; `Parse` (`driver.go:34`) |
| `position/` | 1 | 52 | 0 | 52 | `Position` — the only subpackage without tests |
| `symbol/` | 2 | 130 | 78 | 208 | Symbol table: `Kind` (:15), `Symbol` (:42), `Scope` (:59) in `symtab.go` |
| `types/` | 3 | 649 | 404 | 1,053 | Type system + `ErrTypeMismatch` |




Sum: **28 files / 6,168 main + 3,948 test = 10,116** — exact. Test ratio ≈
39%. Notable layout facts: the root is thin (138 LOC of logic — just the
struct + pipeline); `parser/` is the only subpackage holding non-Go
artifacts next to code (`parser.y`, 16,279 bytes, and the generated `y.output`
LR table, 33,238 bytes, beside the 1,504-line generated `parser.go`); tests
sit beside code (standard Go); two subpackages have more test than main code
(`codegen/` 1,138 vs 632, `opt/` 502 vs 170).




## (3) Naming conventions observed in code




1. **Package == directory name** for 102/141 `.go` files; the 39
   "mismatches" are all two standard Go forms: 4 `package main` files in
   `cmd/*` and 35 external test packages (`<pkg>_test` — 18 `mtail_test`,
   7 `logstream_test`, 2 `waker_test`, 8 other `<pkg>_test`). Verified by
   comparing `grep -m1 '^package '` against the parent directory name for
   all 141 files.
2. **Three-layer functional-option pattern**: `type Option interface {
   apply(*Server) error }` (internal/mtail/options.go:22) + options as
   named types (`type ProgramPath string` — options.go:27;
   `type logPathPatterns []string` — :42) + constructor functions returning
   `Option` (`func LogPathPatterns(patterns ...string) Option` — :38). The
   pattern repeats at every layer: tailer (`func (opt LogPatterns)
   apply(t *Tailer)` — tail.go:73; plus :63 `niladicOption`, :81
   `IgnoreRegex`, :94 `logPatternPollWaker`) and compiler
   (`func (c *Compiler) SetOption(options ...Option) error` —
   compiler.go:35).
3. **Files named after their central type**: `waker.go` ↔ `type Waker`
   (:7), `logline.go` ↔ `type LogLine` (:9), `store.go` ↔ `type Store`
   (:19), `vm.go` ↔ `type VM` (:56), `tail.go` ↔ `type Tailer` (:30 —
   named after the verb). Implementation files are named after the
   implementation type: `testwaker.go:18 type testWaker`,
   `timedwaker.go:13 type timedWaker`, `filestream.go:34 type fileStream`.
4. **Sentinel errors `ErrXxx = errors.New(...)`** declared in the option /
   entry file of each package: `ErrNilOption` (tail.go:168),
   `ErrUnsupportedURLScheme` (tail.go:183),
   `ErrDuplicateHTTPBindAddress` (options.go:66), `ErrNeedsStore`
   (export.go:88).
5. **Tests: `_test.go` + external package + OS suffix + `.golden`**: 61
   `*_test.go` files; the `_unix`/`_windows` suffixes always come with the
   matching `//go:build` constraint (`tail_unix_test.go:4 //go:build unix`,
   `tail_windows_test.go:4 //go:build windows` — all 15 constrained files,
   see below); test data lives in `internal/mtail/testdata/` (24 entries)
   as `<name>.log` + `<name>.golden` pairs (e.g. `apache-combined.log` +
   `apache-combined.golden`), parsed by `golden.ReadTestData`
   (internal/mtail/golden/reader.go:23).
6. **Short, type-consistent receivers**: `r *Runtime` (runtime.go:49 `func
   (r *Runtime) LoadAllPrograms() error`), `c *Compiler` (compiler.go:35,
   :89), `opt`/`n` for option types (tail.go:63,73,81,94).
7. **Multi-topic files named after the topic, not a type**:
   `symbol/symtab.go` holds `Kind` (:15) + `Symbol` (:42) + `Scope` (:59) —
   the file name describes the content (symbol table), matching no single
   type.




## (4) Deviations from Go conventions (grep-verified on the pin)




**Deviation 1 — two generated `.go` files committed; one lacks the standard
banner; assets embedded as generated source instead of `go:embed`.**



- `internal/runtime/compiler/parser/parser.go` — 1,504 lines, line 1 is
  `// Code generated by goyacc -v y.output -o parser.go -p mtail parser.y.
  DO NOT EDIT.`; listed in the Makefile `GOGENFILES` (Makefile:51-52) with
  a regeneration rule (`parser.go: parser.y | $(GOYACC)`, Makefile:141-142).
- `internal/mtail/logo.ico.go` — 2,008 lines of byte-array favicon
  (`:3 var logoFavicon = []byte{`, `:4 // 32038 bytes from
  internal/mtail/logo.ico`), produced by the `togo` tool
  (Makefile:147-148) — but `grep -rn "Code generated" --include='*.go' .`
  over the whole repo returns exactly **1 hit** (parser.go:1), so this
  generated file is missing the standard
  `// Code generated … DO NOT EDIT.` banner.
- `internal/runtime/compiler/parser/y.output` (33,238 bytes — the LR debug
  table) is committed although the Makefile lists it in `CLEANFILES`
  (Makefile:55-59). The repo declares `go 1.21.1` (go.mod:3) — `go:embed`
  has existed since 1.16 — yet `grep -rn "go:embed" --include='*.go' .`
  returns **0 hits**: the asset-embedding pattern here is generated `.go`
  source, not embed.



**Deviation 2 — a local `errors` package shadowing stdlib, plus
`pkg/errors`: three different "errors" in one subtree.**



- `internal/runtime/compiler/errors/errors.go:4 package errors` — and the
  same file imports `:11 "github.com/pkg/errors"` (a third library with
  the same name) → two different "errors" in one file.
- `checker/checker.go:7 goerrors "errors"` — the caller must alias stdlib
  to distinguish it; the alias is used 7 times (:368, :420, :452, :471,
  :545, :645, :792, all `goerrors.Is(...)`), while `:15` imports the local
  errors package by full path
  `github.com/google/mtail/internal/runtime/compiler/errors`.
- Elsewhere in the same subtree, `types/types.go:7` and `parser/lexer.go:8`
  import stdlib `"errors"` unaliased — a reader meets all three forms
  (`errors` / `goerrors` / full-path `errors`); local-errors importers:
  `codegen.go:17`, `opt.go:11`, `driver.go:28`.



**Deviation 3 — `docs/` mixes capitalization.**



- `docs/Building.md` (capitalized) sits next to `docs/debugging.md`
  (lowercase) — same kind of ops documentation.
- `docs/Programming-Guide.md` (capitalized kebab) vs `docs/style.md`,
  `docs/faq.md`, `docs/reading-y-output.md` (lowercase). Count:
  `ls docs/*.md | wc -l` = 15 — 8 start uppercase, 7 lowercase; the
  `designs/` directory (lowercase) holds `poll.md`.



**Deviation 4 — test-support code inside the production package** (no
`_test.go`, no separate package).



- `internal/mtail/testing.go` is a regular file of `package mtail` (:4)
  that imports `"testing"` (:12) and `internal/testutil` (:18) and defines
  `type TestServer struct` (:24) — the test harness compiles into the
  production package.
- Link consequence: `cmd/mtail/main.go:20` imports
  `github.com/google/mtail/internal/mtail`, so the `mtail` binary links
  this file (plus its `testutil` dependency — the one non-test consumer of
  testutil, matching the module map). The "standard Go" arrangement for
  multi-package test helpers is a separate package (like `httptest`) or an
  `export_test.go`; mtail deliberately chose in-package helpers
  (`TestServer` is shared by many integration tests), but it does deviate
  from "the testing import lives only in tests".



**Deviation 5 — two parallel CI systems** (GitHub Actions + GitLab CI).



- `.github/workflows/` holds 12 workflows (ci.yml, golangci-lint.yml,
  codeql-analysis.yml, oss-fuzz.yml, release.yml, automerge.yml, …) and
  the Makefile reads the golangci-lint version straight from the workflow:
  `Makefile:105-106` — `# This version should match the one in
  .github/workflows/golangci-lint.yml` +
  `GOLANGCILINT_VERSION=$(shell grep 'version: v'
  .github/workflows/golangci-lint.yml | cut -f2 -d: | tr -d ' ')`.
- `.gitlab-ci.yml` (28 lines; `:1 image: golang:latest`, `:3 stages:`)
  exists in parallel at the root — two pipelines for one repo, with the
  configuration-drift risk that implies.



**Checked and NOT deviating** (to avoid inventing deviations):



- package == directory for 102/141 files; all 39 remaining files fall into
  the 2 standard Go forms (package main, external test package) — see §3.1.
- Build constraints: all 15 constrained files use the modern `//go:build`
  syntax (11 `unix`, 1 `windows`, 1 `gofuzz` — `internal/runtime/fuzz.go:4`,
  the `race`/`!race` pair — `testutil/race.go:3` + `testutil/norace.go:3`);
  `grep -rn "+build"` → **0 hits** (no legacy syntax).
- `fuzz.go` is a non-test file in `internal/runtime` but carries its own
  `gofuzz` tag (fuzz.go:4) and Makefile:231 runs `gosec -tags fuzz ./...`
  — a deliberate OSS-Fuzz pattern, not a lint oversight.
- `testdata/` is standard Go: a single `internal/mtail/testdata/` (24
  entries, including the `.golden` files).
- `go.mod` is standard: module `github.com/google/mtail` (:1),
  `go 1.21.1` (:3), direct/indirect requires split into two blocks +
  `go.sum` 35,470 bytes; no `vendor/`.




## (5) Suggested reading order (and why)




1. **`README.md:3`** — one-sentence mental model: "# mtail - extract
   internal monitoring data from application logs…"; `README.md:20` points
   straight at `docs/Programming-Guide.md`.
2. **`docs/Programming-Guide.md` + `docs/Language.md`** — the `.mtail`
   language users write: everything in `internal/runtime/compiler` exists
   to compile this language; knowing it first keeps parser/checker/codegen
   readable.
3. **`examples/*.mtail`** (17 programs) — real programs (apache_combined,
   dhcpd, postfix…); they are also the test fixtures
   (examples_integration_test.go:32,37,42).
4. **`cmd/mtail/main.go`** — the entry binary: CLI flags → `[]mtail.Option`
   (main.go:169-226) → `mtail.New` (:232) → `Run` (:238) — the map of "what
   controls the program".
5. **`internal/mtail/mtail.go`** (`:31` Server struct, `:176` New) — the
   joint where 4 parts meet: store + tailer + runtime + exporter; continue
   with `options.go:22` (Option interface) to see what each Option touches.
6. **`internal/runtime/runtime.go`** (`:215` Runtime struct, `:250` New,
   `:141` CompileAndRun) — the `.mtail` program lifecycle: load → compile →
   run VM → unload.
7. **`internal/runtime/compiler/compiler.go:89`** then follow the pipeline:
   `parser/driver.go:34` → `checker/checker.go:45` →
   `codegen/codegen.go:36`; the output contract is
   `internal/runtime/code/object.go:13` (`type Object` — bytecode +
   regexps + metrics).
8. **`internal/runtime/vm/vm.go`** (`:56` VM struct, `:993` New, `:962-991`
   ProcessLogLine) — the convergence point: a log line (from the tailer)
   meets bytecode (from the compiler) here.
9. **The log data path**: `internal/tailer/tail.go:30` →
   `internal/tailer/logstream/logstream.go:35` (rotation/truncation/reopen)
   → `internal/logline/logline.go:9` → into the VM at step 8; metrics then
   flow into `internal/metrics/store.go:19` and out via
   `internal/exporter/export.go:32` (Prometheus/varz).
10. **Finally**: `internal/waker/waker.go:7` (the 10-line interface behind
    every poll loop), `internal/testutil/` +
    `internal/mtail/golden/reader.go:23` (test support), `docs/style.md`
    (contribution conventions: table tests with `t.Run`) — and the
    `Makefile` for build/test/lint/fuzz.




The order follows the value path **configuration (main.go) → wiring
(Server) → programs (runtime → compiler → code) → execution (vm) ← data in
(tailer → logline) → data out (metrics → exporter)**; each step only uses
concepts from earlier steps, so no backtracking is needed.
