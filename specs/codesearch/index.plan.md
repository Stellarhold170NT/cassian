# EXTRACTION PLAN — SLOT A: `index` (google/codesearch @ 74a12a91)

Selected item: **s05 `github.com/google/codesearch/index` — 5★**, the
highest-rated item of the subject (ratings in
[`docs/codesearch/02-module-map.md`](../../docs/codesearch/02-module-map.md);
the regexp plan in this directory covers the second ≥4★ item).

**This document is a plan.** The actual cut is a separate, out-of-band step.
The plan does not cut, does not create repositories, and does not copy
upstream code into itself — it only specifies files.

- Pin: `74a12a911a79b901d1158c48d011b2da1b090fc9` (clone HEAD verified == pin).
- Upstream: https://github.com/google/codesearch (default branch `master`).
- Method: copy-then-prune — copy the listed files byte-identically, then prune
  per the table below; rewriting code is forbidden.

Status: the cut described here was executed; the result sits verbatim under
`modules/codesearch/index/` + `modules/codesearch/sparse/` (see
[`tracking/codesearch.md`](../../tracking/codesearch.md)).

## 1. Dependency boundaries (grep-verified on the pinned tree)

| Claim | Evidence |
|---|---|
| `index` depends on exactly one sibling package, `sparse` | `index/write.go:19` — `"github.com/google/codesearch/sparse"`; grep `codesearch/` over `index/*.go` returns this single hit |
| `sparse` never imports `index` back | grep `codesearch/index` over `sparse/` = 0 hits → one-way dependency, safe to cut |
| `regexp` is unrelated to `index` | grep `codesearch/index` over `regexp/` = 0 hits |
| `lib/` is not Go | `ls lib/` = `README.template buildall setup uploadall version` — release shell scripts |
| go.mod has zero external dependencies | `go.mod:1-3` — `module github.com/google/codesearch` + blank + `go 1.23`; no `require` block; no `go.sum` exists |
| All remaining imports are stdlib | `index/*.go` import blocks: encoding/binary, encoding/hex, fmt, os, math/bits, math/rand/v2, testing, log, syscall, unsafe, bytes, iter, strings, regexp/syntax, sort, strconv, unicode, archive/zip, cmp, io, path/filepath, runtime, slices, time |

## 2. Files copied verbatim (all related tests + minimal config)

Target tree after the cut (module path kept unchanged so internal imports
resolve):

```
codesearch-extract/
├── go.mod            # copy verbatim (3 lines, unmodified)
├── LICENSE           # copy verbatim (BSD 3-clause, The Go Authors)
├── index/            # copy ALL 16 .go files verbatim — 4366 LOC
│   ├── check.go      (77)      ├── delta.go       (154)
│   ├── delta2_test.go(210)     ├── delta_test.go  (129)
│   ├── merge.go      (383)     ├── merge_test.go  (94)
│   ├── mmap_bsd.go   (39)      ├── mmap_linux.go  (31)
│   ├── mmap_windows.go(37)     ├── path.go        (201)
│   ├── read.go       (678)     ├── read_test.go   (53)
│   ├── regexp.go     (872)     ├── regexp_test.go (94)
│   └── write.go      (902)     └── write_test.go  (412)
└── sparse/
    └── set.go        # copy verbatim — 65 LOC
```

- LOC census measured per file, then summed: 77+154+210+129+383+94+39+31+37+
  201+678+53+872+94+902+412 = **4366** (matches the module map's measured
  size for `index`).
- Test LOC: 210+129+94+53+94+412 = **992** → ratio 992/4366 = **0.2272**.
- Related tests = **12 Test functions** copied intact with the 6 `*_test.go`
  files: TestPostGamma (delta2_test.go:186),
  TestDelta/TestFileList64/TestGammaWriter/TestGammaWriterRand
  (delta_test.go:18/53/78/98), TestMerge (merge_test.go:40),
  TestTrivialPosting (read_test.go:24), TestQuery (regexp_test.go:83),
  TestTrivialWrite/TestTrivialWriteDisk/TestHeap/TestZip
  (write_test.go:342/346/350/366).
- Keep all 3 `mmap_*.go` files: build constraints hide them by file name
  (`_linux`, `_windows`) and by the legacy tag
  `// +build darwin freebsd openbsd netbsd` (mmap_bsd.go:6) — dropping any
  one breaks the corresponding GOOS build.
- Tests provision their own data: no external fixtures — `read_test.go:25,29`
  and `write_test.go:316,321` read files the tests themselves create via
  `os.CreateTemp` (read_test.go:25). There is no `testdata/` directory
  (grep `testdata` over `*_test.go` = 0 hits).

## 3. Prune decisions — keep / vendor / cut

| Target | Decision | Reason |
|---|---|---|
| `go.mod` | KEEP verbatim | Declares the module path so the internal import `github.com/google/codesearch/sparse` (write.go:19) resolves; zero external deps → no go.sum needed |
| `index/*.go` (16 files) | KEEP verbatim | The extracted item is the package itself — copy-then-prune forbids splitting files out |
| `sparse/set.go` | KEEP | The only non-stdlib Go dependency of index; 65 LOC, imports no package itself |
| `LICENSE` | KEEP | BSD 3-clause Go Authors — the license notice must stay with the extracted code |
| `cmd/` (cgrep, cindex, csearch, csweb) | CUT | The deps_in direction — commands import index, never the reverse (grep `codesearch/` over `index/*.go` hits only sparse) |
| `regexp/` | CUT | index does not import regexp (grep `codesearch/index` over `regexp/` = 0 hits) |
| `lib/` | CUT | Release shell scripts (buildall/setup/uploadall/version), not part of the Go build/test |
| `README`, `AUTHORS`, `CONTRIBUTORS` | CUT | Not part of build/test (LICENSE is kept per above) |
| VENDOR | N/A | go.mod has no `require` and no go.sum exists → nothing to vendor |

## 4. Independent build+test commands

```bash
cd codesearch-extract          # the 3-entry tree from section 2
go version                     # must be >= go1.23
go build ./...                 # expected: clean, no output
go vet ./...                   # optional extra check
go test ./... -v               # expected: 12 tests PASS across 6 test files
```

- Expected result: `ok  github.com/google/codesearch/index` (12 tests) and
  `?   github.com/google/codesearch/sparse  [no test files]`.
- Toolchain constraint: `go.mod:3` declares `go 1.23`; `iter.Seq`
  (path.go:117, read.go:310) needs Go ≥ 1.23 and `math/rand/v2`
  (delta_test.go:9) needs Go ≥ 1.22 → an older toolchain fails to compile
  (a build failure, not a test failure).
- Dry-run status: **SKIPPED** — the modeling environment for this plan had no
  Go toolchain (checked with `which go` → not found). No build output is
  fabricated. The full-tree build/test evidence at the pin exists separately
  (go1.23.4, `go build ./...` + `go test ./...` exit 0 — see
  [`docs/codesearch/04-overview.md`](../../docs/codesearch/04-overview.md));
  the regexp plan in this directory additionally ran a dry-run of its own cut
  tree.

## 5. Cut risks + post-cut checks

| # | Risk | Post-cut check |
|---|---|---|
| R1 | Forgetting `sparse/set.go` → build breaks at the write.go:19 import | `go build ./...` must be clean; the target tree must contain exactly 17 .go files (16 index + 1 sparse) plus go.mod and LICENSE |
| R2 | Older toolchain (<1.23) → `iter.Seq`/`math/rand/v2` compile errors | `go version` prints ≥ go1.23 BEFORE building |
| R3 | Pruning an `index/` file by mistake (e.g. assuming platform-specific mmap files are droppable) | After the cut `ls index/*.go | wc -l` must equal 16; diff each file against the pin tree (byte-identical) — no file may be dropped beyond the CUT table |
| R4 | Shortening the go.mod module path → internal imports break | `grep '^module' go.mod` must return exactly `module github.com/google/codesearch` |
| R5 | Wrong cut makes tests lose external data | Not applicable — tests self-provision with CreateTemp (read_test.go:25); only a writable /tmp is needed |
| R6 | Running `go mod tidy` by hand creates an empty go.sum | Do not run tidy — zero external deps; go.sum must NOT exist after the cut |

## 6. Provenance

- Ratings source: the subject's measured rubric results
  (`docs/codesearch/02-module-map.md` — index is the 5★ item, regexp 4★).
- Pin re-verified for this plan: shallow clone HEAD = 
  `74a12a911a79b901d1158c48d011b2da1b090fc9`; every file:line claim in this
  plan was grep-verified on that tree.
- Harvest record: the executed cut is byte-identical (per-file hash verified)
  and lives under `modules/codesearch/`; re-sync policy in
  [`tracking/codesearch.md`](../../tracking/codesearch.md).
