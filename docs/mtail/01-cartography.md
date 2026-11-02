---
subject: google/mtail
measured_at: 4c7e0e1174ac1ead032efe28d86428bbbe0ae145
status: final
---




# Cartography




Cartography of [google/mtail](https://github.com/google/mtail) (branch
`main`) at the measurement commit
`4c7e0e1174ac1ead032efe28d86428bbbe0ae145` (2026-02-26 09:59:36 -0800,
"Merge pull request #999 from google/lsc-1771431274.9704435"). All numbers
below were measured on a clone of exactly that commit, fetched by SHA; the
working tree equals the pin. Every claim carries the command or `file:line`
anchor it came from.




## License gate




```
$ ls LICENSE*
LICENSE
$ wc -c LICENSE
11358 LICENSE
```


LICENSE is the Apache License 2.0 (header lines "Apache License / Version
2.0, January 2004"). The subject passes the license gate for extraction and
documentation.




## Manifests




- `go.mod:1` — `module github.com/google/mtail` (exactly one module);
  `go.mod:3` — `go 1.21.1`. Direct requires include
  `github.com/prometheus/client_golang v1.20.4`,
  `github.com/prometheus/common v0.60.0`, `github.com/golang/glog v1.2.2`,
  `github.com/pkg/errors v0.9.1`, `github.com/google/go-cmp v0.6.0`,
  `github.com/golang/groupcache`, and
  `contrib.go.opencensus.io/exporter/jaeger v0.2.1`. `go.sum` is 35,470
  bytes; there is no `vendor/` directory.
- `Makefile` (326 lines): `Makefile:6` — `TARGETS = mtail mgen mdot mfmt`;
  test targets `test` (:173-176), `testrace` (:177-180), `smoke`
  (:181-184), `regtest` (:185-188), `testall` (:213-214); the golangci-lint
  version is read directly from the GitHub Actions workflow
  (`Makefile:105-106`).




## Entry points




`cmd/` holds exactly four single-file CLIs (one `package main` file each,
ls-verified):




| binary | path | LOC | role |
|---|---|---|---|
| mtail | `cmd/mtail` | 278 | the log-tailing metrics server; 32 flags (main.go:41-85), signal handling (:156-163), `-one_shot` debug dump (:245-277) |
| mdot | `cmd/mdot` | 206 | renders an `.mtail` program as a graphviz dot graph / SVG |
| mgen | `cmd/mgen` | 152 | generates random mtail programs for fuzz testing from the language grammar table |
| mfmt | `cmd/mfmt` | 59 | formats (parse + type-check + unparse) an `.mtail` program |




`Makefile:6` (`TARGETS`) matches these four binaries exactly.




## Top-level directories




```
$ find . -maxdepth 1 -type d -not -name '.' -not -path './.git*' | sort
./cmd
./docs
./examples
./hooks
./internal
```


The repo root also carries ops/packaging files: `Dockerfile`,
`Dockerfile.goreleaser`, `mtail.service` (systemd unit), `.golangci.yml`,
`.goreleaser.yml`, `mtail-mode.el` (emacs mode), `log_rewriter.awk`,
`benchmark_results.csv`, `TODO`, `logo.png`, git `hooks/`
(build/post_checkout/post_push), 12 GitHub Actions workflows under
`.github/workflows/`, and a parallel `.gitlab-ci.yml` (28 lines).




## Source census




Census counted per extension, then summed (whole tree, `.git` excluded):




```
$ for ext in go md mtail y output mod; do
    n=$(find . -type f -name "*.$ext" -not -path './.git/*' | wc -l)
    l=$(find . -type f -name "*.$ext" -not -path './.git/*' -print0 | xargs -0 cat | wc -l)
    echo "EXT .$ext files=$n lines=$l"
  done
EXT .go files=141 lines=26896
EXT .md files=21 lines=2548
EXT .mtail files=35 lines=1018
EXT .y files=1 lines=751
EXT .output files=1 lines=1840
EXT .mod files=1 lines=32
```


Go dominates: 141 files / 26,896 LOC. The `.y`/`.output` pair is the goyacc
grammar of the mtail language (`parser/parser.y` plus its generated LR
table, committed beside the generated `parser.go` — see `05-folders.md`).
Of the 35 `.mtail` files, 17 are the canonical example programs in
`examples/` (968 LOC); the rest are fuzz and testdata corpora.




Go test/non-test split (same census method on file-name predicates):




```
NONTEST files=80 lines=15689
TEST   files=61 lines=11207
```




Zone census of the two code trees (all Go code lives under `cmd/` or
`internal/`):




```
ZONE cmd      files=4   lines=695
ZONE internal files=137 lines=26201
```




## Module mapping




`go.mod` declares exactly one module, so every one of the 141 `.go` files
has import path `github.com/google/mtail/<path>` mapping 1:1 onto its
directory. The module map ([`02-module-map.md`](02-module-map.md))
normalizes directories into 18 package items at depth ≤ 3 (the nine
subpackages of `internal/runtime/compiler` fold into the compiler item);
the 18 items sum exactly to the whole Go tree — 141 files / 26,896 LOC.
The invariant was cross-checked at measurement time with two independent
census methods plus the `git ls-files '*.go'` oracle (141 files, no untracked
or vendored Go code).




## Documentation and examples




- `docs/` — 15 top-level `.md` files, 2,300 lines measured recursively
  (`find docs -name '*.md' -exec cat {} +`): Programming-Guide, Language,
  Metrics, Deploying, Building, Testing, Troubleshooting, style, faq,
  debugging, reading-y-output, … plus `docs/designs/poll.md`.
- `examples/` — 17 real `.mtail` programs (apache_*, dhcpd, postfix, rails,
  mysql_slowqueries, …) that double as the integration-test corpus
  (`internal/mtail/examples_integration_test.go` iterates them —
  examples_integration_test.go:32, :37, :42).
