# EXTRACTION PLAN — SLOT B: `regexp` (google/codesearch @ 74a12a91)

Selected item: **s06 `github.com/google/codesearch/regexp` — 4★**, the second
of the two ≥4★ items of the subject (the first, `index` 5★, is covered by
[index.plan.md](index.plan.md) in this directory; measured sizes and ratings
in [`docs/codesearch/02-module-map.md`](../../docs/codesearch/02-module-map.md)).

**This document is a plan.** The actual cut is a separate, out-of-band step.
The plan does not cut, does not create repositories, and does not copy
upstream code into itself — it only specifies files.

- Pin: `74a12a911a79b901d1158c48d011b2da1b090fc9` — verified twice for this
  plan: shallow clone HEAD == pin, and
  `git ls-remote refs/heads/master` returns the same sha. Pin commit:
  `74a12a9 index: slight performance optimization`.
- Upstream: https://github.com/google/codesearch — default branch **`master`**.
  (Declared correction: the companion slot A plan drafted "branch default
  `main`"; the tree proves `master` — source truth wins, and both plans of
  this subject use `master`.)
- Method: copy-then-prune — copy the listed files byte-identically, then prune
  per the table below; rewriting code is forbidden. Same method as slot A so
  the two plans can be compared side by side.

Status: the cut described here was executed; the result sits verbatim under
`modules/codesearch/regexp/` + `modules/codesearch/sparse/` (see
[`tracking/codesearch.md`](../../tracking/codesearch.md)).

## 1. Dependency boundaries (grep-verified on the pinned tree)

| Claim | Evidence |
|---|---|
| `regexp` depends on exactly one sibling package, `sparse` | `regexp/match.go:20` — `"github.com/google/codesearch/sparse"`; grep `codesearch/` over `regexp/*.go` returns this single import hit (the 2 other matches are panic strings: regexp.go:12, utf.go:260) |
| `sparse` imports nothing (including no reverse import of `regexp`) | grep of import statements over `sparse/set.go` = 0 hits → one-way dependency, safe to cut |
| `regexp` is unrelated to `index` | grep `codesearch/index` over `regexp/` = 0 hits — slot A confirms the same from the index side |
| `lib/` is not Go | `ls lib/` = `README.template buildall setup uploadall version` — release shell scripts |
| go.mod has zero external dependencies | `go.mod:1-3` — `module github.com/google/codesearch` + blank + `go 1.23`; no `require` block; `go.sum` does not exist (`ls go.sum` → No such file) |
| All remaining imports are stdlib | `regexp/*.go` import blocks: bytes, encoding/binary, flag, fmt, html, io, os, reflect, regexp/syntax, sort, strconv, strings, unicode, unicode/utf8 (+ `testing` in regexp_test.go) |

## 2. Files copied verbatim (all related tests + minimal config)

Target tree after the cut (module path kept unchanged so internal imports
resolve):

```
codesearch-extract/
├── go.mod            # copy verbatim (3 lines, unmodified)
├── LICENSE           # copy verbatim (BSD 3-clause, The Go Authors / Google Inc.)
├── regexp/           # copy ALL 5 .go files verbatim — 1417 LOC
│   ├── copy.go        (223)     # cleanClass/appendRange/appendFoldedRange + progString/dumpProg
│   ├── match.go       (648)     # DFA matcher (nstate/dstate) + type Grep :355-373 + Grep.Reader :432
│   ├── regexp.go      (59)      # public API: type Regexp :17-22, Compile :30-49
│   ├── utf.go         (268)     # toByteProg :21 — rune instructions → byte ranges
│   └── regexp_test.go (219)     # 3 Test functions — copied intact
└── sparse/
    └── set.go        # copy verbatim — 65 LOC
```

- LOC census measured per file, then summed: 59+223+648+268+219 = **1417**
  (regexp) — matches the module map's measured size. Adding the `sparse/set.go`
  dependency (65) gives a target tree of **1482** Go LOC across 6 `.go` files.
- Test LOC: **219** → ratio 219/1417 = **0.1546**.
- Related tests = **3 Test functions** copied intact in `regexp_test.go`:
  TestNstateEnc (:24), TestMatch (:150), TestGrep (:202). Tests provision
  their own data: no external fixtures — no `testdata/` directory (grep
  `testdata` over `regexp/` = 0 hits); the only `os.Open` (match.go:408) is
  `Grep.File` reading input at RUNTIME, not testdata.
- `copy.go` is NOT dead code despite the name: `appendFoldedRange` (copy.go)
  is called from utf.go:43,46 — cutting copy.go breaks the utf.go build.
- Keep every per-file BSD header (match.go:1-3: `// Copyright 2011 The Go
  Authors. … found in the LICENSE file.`) — the headers point at LICENSE, so
  LICENSE must travel with the tree.

## 3. Prune decisions — keep / vendor / cut

| Target | Decision | Reason |
|---|---|---|
| `go.mod` | KEEP verbatim | Declares the module path so the internal import `github.com/google/codesearch/sparse` (match.go:20) resolves; zero external deps → no go.sum needed |
| `regexp/*.go` (5 files) | KEEP verbatim | The extracted item is the package itself — copy-then-prune forbids splitting files out |
| `sparse/set.go` | KEEP | The only non-stdlib dependency of regexp (match.go:20); 65 LOC, imports no package itself |
| `LICENSE` | KEEP | BSD 3-clause (The Go Authors / Google Inc.) — the per-file headers (match.go:1-3) point at this file |
| `cmd/` (cgrep, cindex, csearch, csweb) | CUT | The deps_in direction — three commands import regexp, regexp imports none of them (grep = 0 hits) |
| `index/` | CUT | regexp does not import index (grep `codesearch/index` over `regexp/` = 0); index is slot A's scope |
| `lib/` | CUT | Release shell scripts, not part of the Go build/test |
| `README`, `AUTHORS`, `CONTRIBUTORS` | CUT | Not part of build/test (LICENSE is kept per above) |
| VENDOR | N/A | go.mod has no `require` and no go.sum exists → nothing to vendor |

**Declared intentional duplication:** `sparse/set.go` + `go.mod` + `LICENSE`
also appear in slot A's cut tree (because `index` needs `sparse` too). The
two cut trees are **independent and self-contained** — not a scope conflict:
`sparse` itself belongs to no slot, and the two slots never touch each
other's main module (grep `codesearch/index` ↔ `codesearch/regexp` = 0 both
ways).

## 4. Independent build+test commands + DRY-RUN (real output)

```bash
cd codesearch-extract          # the 4-entry tree from section 2
go version                     # must be >= go1.23
go build ./...                 # expected: clean, exit 0
go vet ./...                   # optional extra check
go test ./... -v               # expected: 3 tests PASS (regexp) + sparse [no test files]
```

- Toolchain constraint: `go.mod:3` declares `go 1.23` → older toolchains fail
  to compile.
- **DRY-RUN: EXECUTED, real output** (the modeling environment for this plan
  installed go1.23.12 linux/amd64 from the official tarball after finding no
  preinstalled Go):
  - Toolchain: `go version go1.23.12 linux/amd64`.
  - Baseline on the pristine clone (whole repo):

    ```
    $ go build ./...            → BASE_BUILD_EXIT=0
    $ go test ./regexp/ ./sparse/
    ?   	github.com/google/codesearch/sparse	[no test files]
    ok  	github.com/google/codesearch/regexp	0.015s
    BASE_TEST_EXIT=0
    ```

  - **Simulation of exactly the section-2 inventory** in a scratch directory
    (a dry-run equivalent serving the plan — not the real cut, nothing pushed;
    tree = go.mod + LICENSE + README copy + regexp/ + sparse/):

    ```
    $ ls                         → LICENSE README go.mod regexp sparse
    $ find . -name '*.go' -print0 | xargs -0 cat | wc -l   → 1482   (= 1417 + 65, matches section 2)
    $ go build ./...             → CUT_BUILD_EXIT=0
    $ go test ./...
    ?   	github.com/google/codesearch/sparse	[no test files]
    ok  	github.com/google/codesearch/regexp	0.019s
    CUT_TEST_EXIT=0
    $ go vet ./...               → VET_EXIT=0
    ```

  - The commands in section 4 are the ones the real cut re-runs on the
    official cut tree.

## 5. Cut risks + post-cut checks

| # | Risk | Post-cut check |
|---|---|---|
| R1 | Forgetting `sparse/set.go` → build breaks at the match.go:20 import | `go build ./...` must be clean; the target tree must contain exactly 6 .go files (5 regexp + 1 sparse) plus go.mod and LICENSE |
| R2 | Older toolchain (<1.23) → compile errors | `go version` prints ≥ go1.23 BEFORE building |
| R3 | Pruning a `regexp/` file by mistake (e.g. assuming `copy.go` is dead code) | copy.go is used by utf.go:43,46 (appendFoldedRange); after the cut `ls regexp/*.go \| wc -l` must equal 5; diff each file against the pin tree (byte-identical) — no file may be dropped beyond the CUT table |
| R4 | Shortening the go.mod module path → internal imports break | `grep '^module' go.mod` must return exactly `module github.com/google/codesearch` |
| R5 | Tests losing external data | Not applicable — the 3 tests self-provision, no testdata (section 2); only a writable /tmp is needed |
| R6 | Running `go mod tidy` by hand creates a go.sum | Do not run tidy — zero external deps; go.sum must NOT exist after the cut |
| R7 | Guessing the upstream default branch (the slot A draft said `main`) | ls-remote/clone confirm the default branch is `master`; the real cut clones single-branch by default, then `git checkout $PIN`, done when `git rev-parse HEAD` == pin |

## 6. Provenance

- Ratings source: the subject's measured rubric results
  (`docs/codesearch/02-module-map.md` — regexp is the 4★ item after index 5★).
- Pin re-verified for this plan: `git ls-remote refs/heads/master` ==
  `git rev-parse HEAD` == `74a12a911a79b901d1158c48d011b2da1b090fc9`; every
  file:line claim in this plan was grep-verified on that tree.
- Reproduced measurements on the pin: regexp 1417 LOC / 5 files, sparse 65
  LOC / 1 file, tests 219 LOC, ratio 0.1546 — all match the module map ±0.
- Harvest record: the executed cut is byte-identical (per-file hash verified)
  and lives under `modules/codesearch/`; re-sync policy in
  [`tracking/codesearch.md`](../../tracking/codesearch.md).
