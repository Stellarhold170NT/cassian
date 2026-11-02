---
subject: google/pprof
measured_at: dbd0ed30aa888a30e21ba83b9831ac0e80d41022
status: final
---

# Cartography

Cartography of [google/pprof](https://github.com/google/pprof) (branch
`main`) at the measurement commit
`dbd0ed30aa888a30e21ba83b9831ac0e80d41022` (2026-10-26 19:23:09 +0000,
"Record the selected sample type as default_sample_type in -proto output.
(#1055)"). All numbers below were measured on a clone of exactly that
commit; the working tree equals the pin. Every claim carries the command
or `file:line` anchor it came from. The commit-count observation is bounded
by a shallow window of 100 commits and is marked as such.

## License gate

```
$ ls LICENSE*
LICENSE
```

LICENSE is the Apache License 2.0. The subject passes the license gate for
extraction and republication.

## Manifests

`go.mod`, verbatim:

```
module github.com/google/pprof


go 1.26.0


require (
	github.com/chzyer/readline v1.5.1
	github.com/ianlancetaylor/demangle v0.0.0-20250417193237-f615e6bd150b
)


require golang.org/x/sys v0.32.0 // indirect
```

One module (`github.com/google/pprof`), Go 1.26.0, two direct dependencies
(readline, demangle) plus one indirect (x/sys). This manifest is the
universe reference for the whole documentation set.

## Entry points

The binary entry point is **`pprof.go:29 func main()`** at the repository
root, not inside `driver/` or `fuzz/` as a first-time reader might expect:

```
$ grep -rn 'func main' --include='*.go' . --exclude-dir=.git
./pprof.go:29:func main() {
./internal/report/testdata/sample/sample.go:30:func main() {
./internal/binutils/testdata/build_binaries.go:32:func main()
```

- `pprof.go:29` — the real binary entry: `main()` calls
  `driver.PProf(&driver.Options{UI: newUI()})` (`pprof.go:30`).
- `fuzz/main.go` is **not** a binary main: it is a go-fuzz harness —
  `package pprof`, `func Fuzz(data []byte) int` (`fuzz/main.go:24`)
  feeding `profile.ParseData(data)`.
- The two remaining `func main` matches are testdata helpers used to
  regenerate committed test binaries.

## Top-level directories

```
$ find . -maxdepth 2 -type d -not -path './.git*' | sort
.
./browsertests
./browsertests/testdata
./doc
./doc/images
./driver
./fuzz
./fuzz/corpus
./fuzz/testdata
./internal
./internal/binutils
./internal/driver
./internal/elfexec
./internal/graph
./internal/measurement
./internal/plugin
./internal/proftest
./internal/report
./internal/symbolizer
./internal/symbolz
./internal/transport
./profile
./profile/testdata
./proto
./third_party
./third_party/svgpan
```

A flat, typical Go layout: the main machinery lives in `internal/*`
(eleven subpackages), with `driver/` as the public API shim, `profile/` as
the data-model library, and `fuzz/`, `browsertests/` as test
infrastructure. `proto/` holds no `.go` files (the wire codec is
hand-written inside the `profile` package — see `05-folders.md`).

## Source census

Census formula: per extension, count files with
`find . -type f -name "*.$ext" -not -path './.git/*' | wc -l` and lines by
concatenating all matching files (`-print0 | xargs -0 cat | wc -l`), then
sum across extensions. Measured result:

```
EXT .go files=86 lines=30683
```

**86 `.go` files, 30,683 lines** (tests included). This is the invariant
every other document in this set reconciles against.

Go package directories (directories holding at least one `.go` file,
excluding `.git`):

| dir | files |
|---|---|
| `.` (root, package main) | 1 |
| `browsertests` | 2 |
| `driver` | 1 |
| `fuzz` | 2 |
| `internal/binutils` | 7 |
| `internal/binutils/testdata` | 1 |
| `internal/driver` | 24 |
| `internal/elfexec` | 2 |
| `internal/graph` | 4 |
| `internal/measurement` | 2 |
| `internal/plugin` | 1 |
| `internal/proftest` | 2 |
| `internal/report` | 13 |
| `internal/report/testdata/sample` | 1 |
| `internal/symbolizer` | 2 |
| `internal/symbolz` | 2 |
| `internal/transport` | 2 |
| `profile` | 16 |
| `third_party/svgpan` | 1 |

19 package directories, 86 files in total — matches the census exactly.

## Module mapping

The 19 raw directories normalize to **17 items** in the module map
(`02-module-map.md`): `third_party/svgpan` (11 LOC) folds into the root
item under the sub-50-LOC rule, and `internal/report/testdata/sample` is
test infrastructure rather than a shipped package. The item universe is
`m01`–`m17` with Σ files = 86 and Σ LOC = 30,683, identical to the census
above.

## Documentation and examples

- `doc/README.md` — the full user manual (usage modes, fetching profiles,
  symbolization, web interface).
- `doc/images/` — callgraph example plus eight web-UI screenshots.
- `proto/README.md` — the profile.proto format description; the wire
  definition itself is `proto/profile.proto`.
- `.github/workflows/ci.yaml` — the single CI workflow (Go matrix
  `['1.26', '1.27']`).
