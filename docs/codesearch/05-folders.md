---
subject: google/codesearch
measured_at: 74a12a911a79b901d1158c48d011b2da1b090fc9
status: final
---


# Folders


Directory structure of google/codesearch at the pin
`74a12a911a79b901d1158c48d011b2da1b090fc9`: zone map, a deep dive into the
largest package (`index`), naming conventions read out of the code, and
deviations from Go conventions — each with grep-verified evidence.


## 1. Zone map


```
$ find . -maxdepth 2 -type d -not -path './.git*' | sort
.
./cmd
./cmd/cgrep
./cmd/cindex
./cmd/csearch
./cmd/csweb
./index
./lib
./regexp
./sparse
```

| Zone | Path | Role |
|---|---|---|
| Entry points | `cmd/` | 4 CLI programs, each a single `package main` (cindex, csearch, cgrep, csweb) — exactly 4 entry points (see `01-cartography.md`). |
| Index builder CLI | `cmd/cindex/` | Builds/updates the trigram index: `filepath.Walk` per root → `AddFile` → `Flush` → `Merge` (`cmd/cindex/cindex.go:142`). |
| Search CLI | `cmd/csearch/` | Grep-style search over the built index: posting query → iterate matched files → `regexp.Grep.Reader`. |
| Direct grep CLI | `cmd/cgrep/` | Greps stdin/named files directly, without the index (smallest, 79 LOC). |
| Web UI | `cmd/csweb/` | HTTP server `localhost:2473` (search + `/show/` viewer), static assets embedded with `go:embed`. |
| Core engine | `index/` | The whole trigram-index engine: on-disk format, external-memory write + merge, regexp→trigram query, mmap. Largest package: 16 files / 4366 LOC. |
| Regex engine | `regexp/` | Grep-tuned regex: `Compile` → byte program, cached-DFA matcher, shared line-oriented `Grep` driver. |
| Support set | `sparse/` | uint32 sparse set (dense/sparse two-array trick) — the trigram set for both `index` and `regexp`. |
| Release scripts | `lib/` | 5 non-Go files: `buildall`, `setup`, `uploadall`, `version` (4 extension-less shell scripts) + `README.template` — no Go package. |

Evidence:

- `go.mod:1-3` — `module github.com/google/codesearch` / (blank) / `go 1.23`
- `cmd/csearch/csearch.go:17-18` — imports `"github.com/google/codesearch/index"`
  and `"github.com/google/codesearch/regexp"` (commands depend on the two engines)
- `cmd/csweb/web.go:24-25` — same two imports from the web UI
- `sparse/set.go:5-6` — `// Package sparse implements sparse sets.` /
  `package sparse`; the file has no `import` block at all (matches the module
  map: `sparse` depends on nothing)

Dependency shape (from the module map, re-confirmed by import grep on the
tree): `cmd/{cindex,csearch,csweb} → index → sparse`,
`cmd/{cgrep,csearch,csweb} → regexp → sparse`; `cmd/cgrep` does not depend on
`index`.


## 2. Inside the largest package: `index`


Representative package = the largest by LOC (16 files / 4366 LOC). Measured
with `wc -l index/*.go`:

```
   77 index/check.go
  154 index/delta.go
  210 index/delta2_test.go
  129 index/delta_test.go
  383 index/merge.go
   94 index/merge_test.go
   39 index/mmap_bsd.go
   31 index/mmap_linux.go
   37 index/mmap_windows.go
  201 index/path.go
  678 index/read.go
   53 index/read_test.go
  872 index/regexp.go
   94 index/regexp_test.go
  902 index/write.go
  412 index/write_test.go
 4366 total
```

Layout: **one flat package, no subdirectories** — 10 main files and 6 test
files side by side in the same directory (standard Go). Main vs test split:
3374 main LOC / 992 test LOC (210+129+94+53+94+412 = 992; 4366 − 992 = 3374).

| Group | File (LOC) | Role |
|---|---|---|
| Data spec | `index/read.go` (678) | Reader + the on-disk format specification written as the file-top doc comment: `// Index Format` (:7), magic `// "csearch index 2\n"` (:11), spec runs to :145 (link to Elias gamma coding). |
| Index writer | `index/write.go` (902) | `IndexWriter` external-memory writer: `const npost = 64 << 20 / 8 // 64 MB worth of post entries` (:67), k-way merge via `postHeap` (:467). |
| Query | `index/regexp.go` (872) | `type Query` (:22) + op constants `QAll/QNone/QAnd/QOr` (:31-34) + `func RegexpQuery(re *syntax.Regexp) *Query` (:333) — lowers a regex to a conservative trigram query. |
| Merge | `index/merge.go` (383) | Doc `// Merging indexes.` (:7) — merges two indexes A+B into C. |
| Path compression | `index/path.go` (201) | `Path` (:20) + the `PathWriter` (:61) / `PathReader` (:123) pair. |
| Delta γ-coding | `index/delta.go` (154) | The `deltaReader` (:12) / `deltaWriter` (:85) pair. |
| Checker | `index/check.go` (77) | `func (ix *Index) Check() error` (:14). |
| OS mmap | `index/mmap_linux.go` (31), `index/mmap_bsd.go` (39), `index/mmap_windows.go` (37) | Same `mmapFile(f *os.File) mmapData` function split by GOOS (see deviations, D3). |
| Tests | 6 `*_test.go` files (992) | `write_test.go` (412) > `delta2_test.go` (210) > `delta_test.go` (129) > `regexp_test.go` (94) = `merge_test.go` (94) > `read_test.go` (53). |

Layout comment: the largest files are the writer (902), then the query file
(872) and the reader (678) — the "write / query / read" trio accounts for
2452/4366 LOC (≈56%); the rest are small single-responsibility files (merge,
path, delta, check, mmap). Tests sit next to their code (standard Go); there
is no `index/testdata` directory and no subpackage.


## 3. Naming conventions read from the code


1. **Package name == directory name**, 26/26 `.go` files. `sparse/set.go:6`
   — `package sparse`; `index/read.go:5` — `package index`; the four `cmd/*`
   directories are all `package main` (`cmd/cgrep/cgrep.go:5`,
   `cmd/cindex/cindex.go:5`, `cmd/csearch/csearch.go:5`, `cmd/csweb/web.go:5`).
2. **Main file named after the binary** — `cmd/cgrep/cgrep.go`,
   `cmd/cindex/cindex.go`, `cmd/csearch/csearch.go` (one `.go` file per
   directory); the sole exception is `cmd/csweb/web.go` (see D1 below).
3. **Short 1–2 letter receivers, consistent per type**: `ix` for both `Index`
   and `IndexWriter` — `index/read.go:278` `func (ix *Index) Roots() *PathReader`,
   `index/write.go:144` `func (ix *IndexWriter) AddFile(name string) error`;
   `re` for `Regexp` (`regexp/regexp.go:24`), `s` for `Set`
   (`sparse/set.go:29`), `p postEntry` (`index/write.go:105`),
   `h *postHeap` (`index/write.go:471`).
4. **Reader/Writer pairs suffixed by I/O role**: `PathWriter`/`PathReader`
   both live in `index/path.go` (:61/:123) and `deltaReader`/`deltaWriter`
   both in `index/delta.go` (:12/:85); the post* pair is the exception —
   **split across two files**: `postReader` in `index/read.go:405` (used by
   `PostingList/PostingAnd/PostingOr` at :506/:520/:542) while
   `postDataWriter` lives in `index/write.go:823` (used at :401) — the
   I/O-role suffix survives, but "both sides in one file" does not hold here.
5. **Behavior-named interface implementations**: `postHeap` implements
   `heap.Interface` (`index/write.go:467`); `byPrefix`/`bySuffix` implement
   `sort.Interface` (`index/regexp.go:748,754`).
6. **`_test.go` suffix, with numbered variants**: `index/delta_test.go` and
   `index/delta2_test.go` — the second test file for the same `delta.go`.
7. **`Q`-prefixed query op constants**: `index/regexp.go:31-34` —
   `QAll  QueryOp = iota // Everything matches`, `QNone // Nothing matches`,
   `QAnd // All in Sub and Trigram must match`,
   `QOr // At least one in Sub or Trigram must match`.


## 4. Deviations from Go conventions


**D1 — `cmd/csweb` deviates from the other three commands (assets + file
name).** `cmd/cgrep`, `cmd/cindex`, `cmd/csearch` each hold exactly one
`.go` file named after the binary; `cmd/csweb`'s main file is `web.go` (not
`csweb.go`) and it carries an asset directory `cmd/csweb/_static/` with
`viewer.js` (173 bytes) and `viewer.css` (72 bytes). Evidence:
`cmd/csweb/web.go:39` `//go:embed _static` and `:34`
`http.Handle("/_static/", http.FileServer(http.FS(static)))` — the whole
`_static` directory is embedded into the binary and mounted under a matching
URL; no other command has assets.

**D2 — tests cover only 2 of 7 Go packages.** `find . -name '*_test.go'
-not -path './.git/*'` returns exactly 7 files, all in `index/` (6) and
`regexp/` (1). The five remaining packages — the four commands
(`cmd/cindex/cindex.go` 195 LOC, `cmd/csearch/csearch.go` 200,
`cmd/cgrep/cgrep.go` 79, `cmd/csweb/web.go` 274) and `sparse/set.go` (65) —
have no tests at all; `cindex` in particular contains the skip-hidden-files
Walk logic with no regression protection.

**D3 — release tooling and some name strings are frozen in the pre-GitHub /
Google Code era.** Evidence: `lib/buildall:17`
`go install -a code.google.com/p/codesearch/cmd/{cgrep,cindex,csearch}` — a
dead import path contradicting `go.mod`; panic messages use the old
domain-less root (`regexp/regexp.go:12`
`panic("codesearch/regexp: internal error")`, `regexp/utf.go:260`
`panic("codesearch/regexp: bad utf-8 math")`); `lib/uploadall:5-7` reads
upload credentials from the Mercurial config `~/.hgrc` and pushes binaries to
Google Code via `gcodeup` (`lib/uploadall:3`); `lib/buildall:7-9` runs
`go tool dist install cmd/$i` over the removed 5c/6c/8c toolchain; and
`index/mmap_bsd.go:5` carries only the legacy `// +build darwin freebsd
openbsd netbsd` constraint without a `//go:build` line (Go ≥ 1.17 style) —
the only `+build` hit in `index/*.go`, while `mmap_linux.go`/`mmap_windows.go`
use standard filename constraints.

**D4 — the local package `regexp` shadows stdlib `regexp` and contains copied
stdlib code.** `regexp/copy.go:5` — `// Copied from Go's regexp/syntax.` (a
declared copy of stdlib code inside a same-named local package); and
`regexp/regexp.go:9` — `import "regexp/syntax"` *inside* `package regexp`, so
a reader must keep `github.com/google/codesearch/regexp` and `regexp/syntax`
apart on every line (`index/regexp.go:8` does the same inside
`package index`).

**Checked and confirmed NOT deviations** (to avoid inventing problems):
package name == directory name in all 26 files (§3.1); standard `_test.go`
suffix; filename build constraints for linux/windows are standard; `go.mod`
is minimal and well-formed; no `go.sum` because the tree has zero external
dependencies — `grep -rh '"github.com/google/codesearch/' --include='*.go' .`
returns exactly the 3 internal paths (`index` ×3 imports, `regexp` ×3,
`sparse` ×2); a flat package layout is a reasonable choice for a 6.6k-LOC
repo. Also noted (observation, not a deviation): no `doc.go`, no `Makefile`,
no CI config (`*.yml`/`*.yaml`), no `.golangci*`.


## 5. Suggested reading order


1. **`README` first** — `README:1-3` ("Code Search is a tool for indexing and
   then performing regular expression searches over large bodies of source
   code..."), `README:8-10` (`go get github.com/google/codesearch/cmd/...`) —
   anchors the two main commands and the index-then-search mental model.
2. **`cmd/cindex/cindex.go`** — the write side: what the system consumes
   (root dirs, walk, AddFile, Flush, Merge) in 195 LOC, no engine knowledge
   needed.
3. **`index/read.go` from line 7** — the `// Index Format` doc (:7-145) is
   the source of truth for the data model (magic `"csearch index 2\n"` :11,
   prefix-compressed names, γ-coded posting lists); every other file is
   written around this format.
4. **`index/write.go`** — the format's producer side: `IndexWriter` (:39),
   the 64 MB `npost` flush threshold (:67), k-way merge `postHeap` (:467).
   Read after `read.go` because the external-memory algorithm only makes
   sense once the target format is known.
5. **`index/regexp.go`** — the regex→index bridge: `RegexpQuery` (:333)
   converts a regex into a conservative trigram query; the core idea that
   makes csearch fast (filter files before running the real regex).
6. **`regexp/match.go`** — the DFA matcher + the `Grep` driver shared by the
   three search commands; read after `index/regexp.go` to see "filter by
   trigram, match for real with the DFA".
7. **`sparse/set.go`** — 65 LOC, a quick read to understand the O(1) trigram
   set; `sparse/set.go:13` links Russ Cox's uninitialized-memory article.
8. **`cmd/csearch/csearch.go` then `cmd/csweb/web.go`** — reassembles the
   whole picture: the query pipeline (csearch) and the thin UI layer over the
   same pipeline (csweb, port 2473, `web.go:36`). `lib/` comes last (Google
   Code-era release scripts, see D3).

Rationale: the order follows the data — **write (cindex) → format (read.go)
→ query (regexp.go/match.go) → read (csearch)**; each step only uses concepts
introduced by the previous ones.
