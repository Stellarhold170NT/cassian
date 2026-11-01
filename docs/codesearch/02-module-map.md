---
subject: google/codesearch
measured_at: 74a12a911a79b901d1158c48d011b2da1b090fc9
status: final
---


# Module map


One entry per Go package of google/codesearch — 7 packages in total. This is
the human-readable companion to the machine index
[`matrix/matrix.csv`](../../matrix/matrix.csv), which carries the same rows in
full (dependencies, sizes, ratings, extract locations). Architecture views are
in [`04-overview.md`](04-overview.md) and [`03-c4/`](03-c4/); hot data flows
in [`06-flows.md`](06-flows.md); hands-on recipes in
[`07-usage.md`](07-usage.md).


**How to read the columns.** `depends_on` lists the packages this package
imports code from (its external needs); `depended_by` lists the packages that
import it (who stands on it). `loc` is the measured source size (all `.go`
files under the package path, tests included). `rating` is the reuse-readiness
score from the measured rubric (5 = library-grade with tests; 1 = thin
untested wrapper). `key files` names the public entry point and the largest
source file, as paths relative to the upstream repository root — browse any of
them at
`https://github.com/google/codesearch/tree/74a12a911a79b901d1158c48d011b2da1b090fc9/<path>`.


**Measurement note.** Sizes and dependency edges were measured directly on the
upstream tree at the pin `74a12a911a79b901d1158c48d011b2da1b090fc9`; every
import edge below was re-verified by grep on that tree. Totals: 7 items,
28 files, 6608 LOC (79 + 195 + 200 + 286 + 4366 + 1417 + 65 = 6608;
1 + 1 + 1 + 3 + 16 + 5 + 1 = 28 files).


## Commands (`cmd/*`)


| id | module | responsibility | depends_on | depended_by | loc | rating | key files |
|---|---|---|---|---|---|---|---|
| <a id="m01-cmd-cgrep"></a>m01 | cmd/cgrep | Grep-style CLI that searches stdin or named files directly without the index: builds a `regexp.Grep` from flags, compiles the pattern with a `(?m)` prefix (plus `(?i)` with `-i`), matches, and exits 1 when nothing matches. | regexp | — | 79 | 1 | `cmd/cgrep/cgrep.go` (entry, L36; only file) |
| <a id="m02-cmd-cindex"></a>m02 | cmd/cindex | Index builder/updater CLI: absolute roots, `filepath.Walk` skipping hidden/temporary files → `AddFile` → `Flush`, then `index.Merge` with the master index and an atomic rename over it unless `-reset`; modes `-list`/`-check`/`-reset`/`-stats`/`-zip`. | index | — | 195 | 1 | `cmd/cindex/cindex.go` (entry, L70; only file) |
| <a id="m03-cmd-csearch"></a>m03 | cmd/csearch | Indexed search CLI: parses flags, compiles the regexp, lowers it to a trigram posting query, then greps every candidate file — including `.zip` archive members — through `regexp.Grep.Reader`; exit 1 on no match. | index; regexp | — | 200 | 1 | `cmd/csearch/csearch.go` (entry, L194; only file) |
| <a id="m04-cmd-csweb"></a>m04 | cmd/csweb | Local web UI: HTTP server on `localhost:2473` taking query `q` plus filename filter `f`, HTML-highlighted results through `regexp.Grep`; `/show/` renders files/directories as line-numbered HTML; static assets embedded with `go:embed`. | index; regexp | — | 286 | 1 | `cmd/csweb/web.go` (entry, L32; 274, largest); `cmd/csweb/_static/viewer.js` (8); `viewer.css` (4) |


## Libraries


| id | module | responsibility | depends_on | depended_by | loc | rating | key files |
|---|---|---|---|---|---|---|---|
| <a id="m05-index"></a>m05 | index | The trigram-index engine: on-disk format read/write ("csearch index 2" — prefix-compressed names, γ-coded posting lists), external-memory writer with temp files and k-way merge, `RegexpQuery` lowering a regexp to a conservative trigram `Query`, two-index merge, path prefix compression, delta γ-coding, integrity check, per-OS mmap. | sparse | cmd/cindex; cmd/csearch; cmd/csweb | 4366 | 5 | `index/write.go` (`IndexWriter.Create`, L70; 902, largest); `index/regexp.go` (`RegexpQuery`, L333); `index/read.go` (`Open`, L196) |
| <a id="m06-regexp"></a>m06 | regexp | Grep-tuned regex engine: `Compile` parses via `regexp/syntax` into a byte program; a cached-DFA matcher runs per line/byte; `Grep` is the shared line-oriented driver (flags `-l/-c/-n/-h/-v`, pre/post context, HTML output) reused by cgrep/csearch/csweb. | sparse | cmd/cgrep; cmd/csearch; cmd/csweb | 1417 | 4 | `regexp/match.go` (DFA + `Grep`, 648, largest); `regexp/regexp.go` (`Compile`, L30–49) |
| <a id="m07-sparse"></a>m07 | sparse | Sparse set of `uint32` via the dense/sparse two-array trick (uninitialized-memory technique): `NewSet`/`Init`/`Reset`/`Add`/`Has`/`Dense`/`Len` with O(1) membership and O(1) reset — the high-performance trigram set backing `index` and `regexp`. | — | index; regexp | 65 | 1 | `sparse/set.go` (whole API; only file) |


## Dependency edges (grep-verified on the pin)


Every edge below is a Go import; the line numbers are the import statements
themselves:

```
cmd/cgrep/cgrep.go:14    → regexp
cmd/cindex/cindex.go:16  → index
cmd/csearch/csearch.go:17 → index
cmd/csearch/csearch.go:18 → regexp
cmd/csweb/web.go:24      → index
cmd/csweb/web.go:25      → regexp
index/write.go:19        → sparse
regexp/match.go:20       → sparse
```

Cross-checked in both directions (`deps_out` of each importer equals the
`depended_by` set of the target). Shape: the four `cmd/*` packages are leaves
(`package main`, nothing imports them); `sparse` is the only library-level
leaf; `index` and `regexp` both depend on `sparse`; `cmd/cgrep` never imports
`index`. Outside these edges, every remaining import is stdlib — `go.mod`
declares zero third-party requirements and no `go.sum` exists.


## Coverage note


Only 2 of the 7 packages have tests: `index` (6 `*_test.go` files,
992 LOC of the 4366) and `regexp` (1 file, 219 LOC of the 1417). The four
`cmd/*` packages and `sparse` have none, so CLI behavior guarantees rest on
reading the code, not on tests (see `04-overview.md`, risks).
