---
subject: google/codesearch
measured_at: 74a12a911a79b901d1158c48d011b2da1b090fc9
status: final
---


# Cartography


Cartography of [google/codesearch](https://github.com/google/codesearch)
(branch `master`) at the measurement commit
`74a12a911a79b901d1158c48d011b2da1b090fc9` (2026-08-30, "index: slight
performance optimization"). All numbers below were measured on a clone of that
commit; 43 commits were visible in the shallow window used for the census.


## License gate


```
$ ls LICENSE*
LICENSE
```

LICENSE is present (BSD 3-Clause, "Copyright (c) 2011 The Go Authors") — the
subject passes the license gate for extraction and documentation.


## Source census


Census counted per extension, then summed (whole tree, `.git` excluded):

```
$ for ext in go template mod js css; do
    n=$(find . -type f -name "*.$ext" -not -path './.git/*' | wc -l)
    l=$(find . -type f -name "*.$ext" -not -path './.git/*' -print0 | xargs -0 cat | wc -l)
    echo "EXT .$ext files=$n lines=$l"
  done
EXT .go files=26 lines=6596
EXT .template files=1 lines=15
EXT .mod files=1 lines=3
EXT .js files=1 lines=8
EXT .css files=1 lines=4
$ TOTAL files=30 lines=6626
```

Go dominates: 26 files / 6596 LOC ≈ 99.5% of all lines. The remaining files
are `README`, `LICENSE`, `AUTHORS`, `CONTRIBUTORS`, `go.mod`, one
`README.template`, and four extension-less `lib/` shell scripts.


## Build manifests


`go.mod`, verbatim:

```
module github.com/google/codesearch


go 1.23
```

`lib/buildall` is a legacy release script that cross-builds `cgrep`,
`cindex`, and `csearch` for a matrix of GOOS/GOARCH pairs. Two stale details
inside it (informational only — `go.mod` is authoritative for Go tooling):

- it still installs the pre-GitHub import path
  `code.google.com/p/codesearch/cmd/{cgrep,cindex,csearch}`;
- it does not know about the fourth entry point, `cmd/csweb`.


## Entry points


```
$ grep -rn 'func main' --include='*.go' cmd | head -20
cmd/cindex/cindex.go:70:func main() {
cmd/cgrep/cgrep.go:36:func main() {
cmd/csearch/csearch.go:194:func main() {
cmd/csweb/web.go:32:func main() {
```

Four CLI/web entry points: `cindex` (index builder), `cgrep` (index-free
line-oriented grep), `csearch` (indexed grep-style search), `csweb` (web UI).


## Top-level layout


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

Four top-level code directories matter: `cmd/` (4 commands), `index/` (the
core trigram-index engine), `regexp/` (the grep-tuned regex engine), and
`sparse/` (the uint32 set primitive); `lib/` holds release shell scripts. The
Go package list — directories containing at least one `.go` file — is the
universe for the module map:

```
./cmd/cgrep (go files=1)
./cmd/cindex (go files=1)
./cmd/csearch (go files=1)
./cmd/csweb (go files=1)
./index (go files=16)
./regexp (go files=5)
./sparse (go files=1)
```


## Totals for the subject


- Upstream: https://github.com/google/codesearch, branch `master`.
- Pin: `74a12a911a79b901d1158c48d011b2da1b090fc9`.
- License: BSD 3-Clause (The Go Authors, 2011).
- Tree census: 30 files / 6626 LOC; 26 `.go` files / 6596 LOC.
- Go packages (item universe): 7 — `cmd/cgrep`, `cmd/cindex`, `cmd/csearch`,
  `cmd/csweb`, `index`, `regexp`, `sparse` (28 files / 6608 LOC inside
  packages; see [`02-module-map.md`](02-module-map.md)).
