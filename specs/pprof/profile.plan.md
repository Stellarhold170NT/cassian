---
subject: google/pprof
measured_at: dbd0ed30aa888a30e21ba83b9831ac0e80d41022
status: final
---

# Extraction plan — slot A: module `profile`

This is a PLAN document: it specifies what a standalone extraction of the
`profile` package would copy, prune and verify. It was dry-run for real on
the pinned tree before publication; the cut itself lives in
`modules/pprof/` (the full 17-item harvest).

## 1. Slot selection and item definition

- Star distribution at the pin: 0 items at 5 stars, exactly **1 item at
  4 stars** — `profile` (m01, ★4: dependency-free with fan-out to 10 of
  the 16 other items, test ratio 46.7%, 8,627 LOC). The first (and only)
  item ≥4 stars is therefore slot A; slot B is N/A by rule.
- Item definition: the Go package `profile` — 16 `.go` files
  (9 source + 7 `*_test.go`), `Σ LOC` = 8,627; test LOC 4,026 → test
  ratio 46.66%.
- Re-measured against the star oracle on the pinned clone — exact match:

| Quantity | Measured on the pin | Oracle | Match |
|---|---|---|---|
| files `profile/*.go` | 16 (9 source + 7 `*_test.go`) | — | — |
| Σ LOC `profile/*.go` | 8627 | s5_loc = 8627 | ✅ |
| test LOC | 4026 (7 `*_test.go`); 4026/8627 = 46.66% | s3_testratio 0.467 | ✅ |
| deps_in (in-universe imports) | 0 — `grep 'github.com\|golang.org'` over `profile/*.go` hits 4 lines, all in `*_test.go` pointing at `internal/proftest` | s1_deps = 0 | ✅ |
| LOC `internal/proftest` | proftest.go 170 + proftest_test.go 59 = 229 | s12 loc = 229 | ✅ |

Key evidence (verbatim from the clone):

- `profile/profile.go:19-32` — the import block (bytes, compress/gzip,
  fmt, io, math, path/filepath, regexp, slices, sort, strings, sync,
  time) — not a single import outside the standard library.
- `profile/profile_test.go:30` — `"github.com/google/pprof/internal/proftest"`
  (likewise filter_test.go:23, merge_test.go:23, proto_test.go:21).
- `internal/proftest/proftest.go:169` — `//go:embed testdata/large.cpu` —
  compile-time embed, the fixture must travel with the file.
- `go.mod:1-10` — module github.com/google/pprof / go 1.26.0 / require
  (github.com/chzyer/readline v1.5.1, github.com/ianlancetaylor/demangle
  v0.0.0-20250417193237-f615e6bd150b) / require golang.org/x/sys v0.32.0
  // indirect.
- proftest symbols used by the profile tests (grep `proftest\.[A-Za-z]*`
  over `profile/*_test.go`): `Diff` ×7, `EncodeJSON` ×2, `LargeProfile`
  ×3 — proftest.go:38/74/155.

## 2. COPY (copy-then-prune — copy the whole set, identify files)

All byte-identical with the pin, relative paths preserved:

| # | File/dir | Note |
|---|---|---|
| C1 | `profile/` — all 16 `.go` files (encode.go, filter.go, index.go, legacy_java_profile.go, legacy_profile.go, merge.go, profile.go, proto.go, prune.go + 7 `*_test.go`) | The target item itself; no file excluded. |
| C2 | `profile/testdata/` — 28 golden fixtures (`cppbench.*`, `go.*`, `gobench.*`, `java.*`, ~150 KB) | Tests read them by relative path — `profile/profile_test.go:36`: `const path = "testdata/"`. (Note: an earlier raw measurement note said 27; the verified count on the extracted tree is **28**.) |
| C3 | `internal/proftest/proftest.go` | The only in-repo dependency of the profile tests (stdlib-only). |
| C4 | `internal/proftest/proftest_test.go` | The dependency's own test (TestDiff, 59 LOC) — kept so the dep stays tested. |
| C5 | `internal/proftest/testdata/large.cpu` (1,201,687 bytes) | Required by `//go:embed` (proftest.go:169); `LargeProfile` is used 3× by the profile tests. |
| C6 | `go.mod` | Copied whole, then pruned per §3. |
| C7 | `go.sum` (11 lines) | Copied whole, then pruned per §3. |
| C8 | `LICENSE` (+ `AUTHORS`, `CONTRIBUTORS`) | License compliance for harvesting upstream code. |

## 3. PRUNE — KEEP / VENDOR / CUT (one-line reason per decision)

- **KEEP** `profile/` + `profile/testdata/` — the target item and the
  golden fixtures its tests read by relative path (C1/C2).
- **KEEP** `internal/proftest/` (C3-C5) — the only dependency of the
  tests (4 `*_test.go` files import it), itself stdlib-only, using
  `Diff`/`EncodeJSON`/`LargeProfile`.
- **KEEP** `module github.com/google/pprof` + `go 1.26.0` (go.mod:1,3) —
  keeping the module path means changing zero import lines; `slices`
  needs Go ≥1.21, go.mod anchors 1.26.0.
- **CUT** the go.mod require `github.com/chzyer/readline v1.5.1` — the
  only user in the whole repo is `pprof.go` (grep `chzyer/readline
  --include='*.go'` → 1 file); profile/proftest do not import it.
- **CUT** the go.mod require `github.com/ianlancetaylor/demangle` — the
  only users are `internal/symbolizer/symbolizer.go` and
  `internal/binutils/disasm.go` (grep → exactly 2 files); profile does
  not demangle.
- **CUT** the go.mod require `golang.org/x/sys v0.32.0 // indirect` —
  pulled in transitively by the two modules above only; cutting both
  makes it redundant.
- **CUT** `go.sum` (11 lines) — all 11 lines belong to the 3 cut modules;
  the remaining scope is stdlib-only.
- **CUT** `internal/proftest/BUILD` — Bazel metadata, ignored by the Go
  toolchain, not part of the Go build config.
- **CUT** everything else in the upstream tree (`driver/`, `report/`,
  `internal/*` except proftest, `proto/`, `fuzz/`, `browsertests/`,
  `third_party/`, `doc/`, `pprof.go`, `test.sh`, `README.md`…) —
  s1_deps=0: profile imports no in-universe item; the closure was proven
  by grep (§1) and by the standalone compile of exactly this copy-set
  (§4).
- **VENDOR**: not needed — zero third-party imports in scope; proven
  empirically: `GOPROXY=off go test` PASSES (§4) → no module network, no
  `vendor/` needed.

## 4. Standalone build+test commands + real dry-run (verbatim output)

Expected commands for the extracted repo (after prune):
`go build ./... && go test ./...`.

The dry-run was executed FOR REAL on the pinned tree (go1.26.0
linux/amd64), scope = exactly the copy-set:

```
$ export PATH=$PATH:/usr/local/go/bin && go version
go version go1.26.0 linux/amd64
$ cd /workspace/pprof && go build ./profile/... ./internal/proftest/... && echo BUILD_OK
BUILD_OK
$ go test ./profile/... ./internal/proftest/... 2>&1 | tail -5
ok  	github.com/google/pprof/profile	0.126s
ok  	github.com/google/pprof/internal/proftest	0.027s
$ GOPROXY=off go test -count=1 ./profile/... ./internal/proftest/...
ok  	github.com/google/pprof/profile	0.146s
ok  	github.com/google/pprof/internal/proftest	0.023s
```

Nothing skipped — Go 1.26.0 was installed in the measurement sandbox
(66.7 MB tarball), both build and test ran for real and passed, including
with `GOPROXY=off` (proving the scope needs no network/external
modules). Expected after the cut: the same two commands at the extracted
repo root produce equivalent `ok` results (module path unchanged,
requires = 0).

## 5. Cut risks + post-cut checks

| # | Risk | Post-cut check |
|---|---|---|
| R1 | `//go:embed testdata/large.cpu` is compile-time — a wrong `internal/proftest/testdata/` path breaks the build immediately | `go build ./...` exit 0 |
| R2 | `go 1.26.0` rejects older toolchains (distro Go ~1.22 is not enough) | `go version` ≥ 1.26.0 before building |
| R3 | The golden tests carry an `-update` flag (`flag.Bool("update", false, "Update the golden files")` in profile/*_test.go) — accidentally running with `-update` would overwrite fixtures | Run tests WITHOUT `-update`; after tests, `git status --porcelain` must be empty |
| R4 | Tests read fixtures by package CWD — missing 1 of the 28 fixtures fails the run | `ls profile/testdata | wc -l` = 28; `go test ./...` green |
| R5 | Byte parity after the cut (extra/missing files vs the pin) | Σ LOC = 8627 (profile) + 229 (proftest) exact; file count: 16 + 3 (.go) + 2 config; `diff -r` per file against the pin if needed |
| R6 | A future upstream re-sync adds a require that profile starts using → the pruned go.mod goes stale | After every re-sync, re-run `GOPROXY=off go build ./...` — a failure means drift; re-check §3 |

## 6. Scope statement

**This is a PLAN only.** The actual extraction is a separate operation;
this document does not cut anything. All numbers above were measured on a
clone of the pin, and the published extract under `modules/pprof/` covers
all 17 items (not only this slot) with per-module `PROVENANCE.md` files.

## 7. Conclusion

SLOT A = `profile` (★4, the first and only item ≥4 stars). Copy-set of 8
entries (C1-C8), 0 requires after prune, a real offline-capable
build+test dry-run pass on the pin (including `GOPROXY=off`). Plan
complete → **DONE**. Slot B: N/A (no second item ≥4 stars exists in the
universe).
