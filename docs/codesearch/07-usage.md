---
subject: google/codesearch
measured_at: 74a12a911a79b901d1158c48d011b2da1b090fc9
status: final
---


# Usage


Hands-on guidance for all 7 packages of google/codesearch: what each solves,
runnable-style code sketches with evidence, the dependencies each needs, and
how to build it standalone.


**How the code and evidence were verified.** Every evidence line below was
grepped against the tree at the measurement pin
(`74a12a911a79b901d1158c48d011b2da1b090fc9`); all cited files are extracted
verbatim under `modules/codesearch/`, so the references resolve identically
there. Build the permalink as
`https://github.com/google/codesearch/blob/74a12a911a79b901d1158c48d011b2da1b090fc9/<path>#L<line>`.
The snippets are usage sketches for the verified APIs (not executed
end-to-end in this study; the full-tree build and `go test ./...` evidence
lives in [`04-overview.md`](04-overview.md)). Dependency edges and sizes are
in [`matrix/matrix.csv`](../../matrix/matrix.csv) and are not repeated here.


## Use-when index (all 7 packages)


| package | use it when | depends_on |
|---|---|---|
| `index` | Building an index corpus from code (`IndexWriter.Create/AddFile/Flush`); filtering candidate files by trigram query before running the real regex (`RegexpQuery → PostingQuery → Name`); merging daily indexes into a master + integrity check / statistics (`Merge`/`Check`/`PrintStats`) | sparse |
| `regexp` | Embedding a line-oriented grep driver into your own tool (`Grep.File`/`Grep.Reader` with -l/-c/-n/-h/-v flags, early-stop `Limit`, HTML output) or matching a single line with `Compile` + `MatchString` (cached-DFA matcher) | sparse |
| `cmd/cgrep` | Index-free grep-style search over stdin or individual files (-i/-l/-n/-c/-v flags) with exit code 0/1 as a CI gate — right when the corpus is too small to deserve an index or a stream must be filtered in place | regexp |
| `cmd/cindex` | Building/updating the trigram index at `$CSEARCHINDEX`: first time (`-reset`) or incremental and safe (merge via the `~` file, then rename over the master); modes `-list`/`-check`/`-stats`/`-zip` | index |
| `cmd/csearch` | Daily code lookup over a built index (posting query filters files before grep); CI gate that blocks banned patterns via the exit code; diagnosing trigram-filter tightness with `-verbose`/`-brute` | index; regexp |
| `cmd/csweb` | A team-local code search web UI: HTTP server on localhost:2473 taking query `q` + filename filter `f`, HTML-highlighted results; `/show/` renders files with line numbers + `#L42` anchor highlight; searches inside `.zip` archives too | index; regexp |
| `sparse` | uint32 sparse set via the dense/sparse two-array trick: the 24-bit trigram set for an indexer (O(1) `Reset` between files), order-preserving ID dedup — O(1) membership | — |


## index (5★)


The whole trigram-index engine of codesearch: reads/writes the on-disk format
(prefix-compressed file names, γ-coded posting lists), writes indexes with an
external-memory strategy (temp files + k-way merge), and lowers regexps into
conservative trigram queries that filter files before the real regex runs. It
is the heavy half of the system: `cindex` builds indexes through it, while
`csearch`/`csweb` query through it.


### UC1 — build an index for a corpus from code (embed cindex's write half)


Scenario: an internal service wants to rebuild the index for a document
corpus nightly on a schedule, without calling the CLI. Use
`IndexWriter.Create` to open a new index file, `AddFile` per file (each file
gets its 24-bit trigrams extracted), `Flush` to push pending posting lists to
disk and k-way merge the temp files.

```go
// nightly.go — rebuild the index for the document corpus every night.
package main

import (
	"log"

	"github.com/google/codesearch/index"
)

func main() {
	ix := index.Create("/var/lib/docs/corpus.idx") // open a new index file for writing
	ix.Verbose = true                              // log status via the log package
	for _, f := range []string{"corpus/2024.txt", "corpus/2025.txt", "corpus/faq.md"} {
		if err := ix.AddFile(f); err != nil { // read the file, extract 24-bit trigrams
			log.Printf("%s: %v", f, err)
		}
	}
	ix.Flush() // flush pending posting lists to disk + k-way merge the temp files
}
```

Evidence: `index/write.go:70` — `func Create(file string) *IndexWriter {`;
`index/write.go:41` — `Verbose bool // log status using package log`;
`index/write.go:144` — `func (ix *IndexWriter) AddFile(name string) error {`;
`index/write.go:215-226` — `func (ix *IndexWriter) add(name string, f io.Reader)
error {` … `tv = (tv << 8) & (1<<24 - 1)` (24-bit trigram extraction while
AddFile reads the file); `index/write.go:298` — `func (ix *IndexWriter)
Flush() {`. Real call site: `cmd/cindex/cindex.go:136-166` —
`ix := index.Create(file)` … `if err := ix.AddFile(path); err != nil {` …
`ix.Flush()`.


### UC2 — filter candidate files by trigram BEFORE running the real regex


Scenario: you need to find an expensive pattern (it would run across
thousands of files). Before scanning anything, ask the index which files
*could* contain the pattern: `syntax.Parse` → `index.RegexpQuery` lowers the
regexp into a conservative trigram query → `ix.PostingQuery(q)` returns the
candidate fileids → print them via `ix.Name`. This is exactly the API chain
`csearch` runs (RegexpQuery → PostingQuery → Name).

```go
// filter.go — filter candidate files by trigram before running the real regex.
package main

import (
	"fmt"
	"regexp/syntax"

	"github.com/google/codesearch/index"
)

func main() {
	re, err := syntax.Parse("(?m)ErrDiskFull", syntax.Perl)
	if err != nil {
		panic(err)
	}
	q := index.RegexpQuery(re)       // regexp -> conservative trigram query
	ix := index.Open(index.File())   // open the master index ($CSEARCHINDEX or $HOME/.csearchindex)
	for _, fileid := range ix.PostingQuery(q) { // fileids that contain all query trigrams
		fmt.Println(ix.Name(fileid).String())
	}
}
```

Evidence: `index/regexp.go:333` — `func RegexpQuery(re *syntax.Regexp) *Query
{`; `index/read.go:196` — `func Open(file string) *Index {`;
`index/read.go:665-666` — `// File returns the name of the index file to
use.` / `// It is either $CSEARCHINDEX or $HOME/.csearchindex.`;
`index/read.go:561` — `func (ix *Index) PostingQuery(q *Query) []int {`;
`index/read.go:283` — `func (ix *Index) Name(fileid int) Path {`. Real call
site: `cmd/csearch/csearch.go:107,118,148` —
`q := index.RegexpQuery(re.Syntax)` / `post = ix.PostingQuery(q)` /
`name := ix.Name(fileid).String()`. Building the `*syntax.Regexp`:
`index/regexp_test.go:85-89` — `re, err := syntax.Parse(tt.re, syntax.Perl)`
… `q := RegexpQuery(re).String()`.

Lower-level API (grepped, kept out of the example): the raw posting list of a
single 24-bit trigram is public too — `index/read.go:501`
`func (ix *Index) PostingList(trigram uint32) []int {`; intersecting two
lists — `index/read.go:515` `func (ix *Index) PostingAnd(list []int, trigram
uint32) []int {`. A 24-bit trigram is the last 3 bytes of the packed string:
`tv = (tv << 8) & (1<<24 - 1)` then `tv |= uint32(c)` —
`index/write.go:226,243`.


### UC3 — index maintenance: merge a daily index into the master + check + stats


Scenario: the daily index (`daily.idx`) is built; merge it into `master`
without rebuilding from scratch, then self-check the merged index and print
size statistics. `index.Merge` takes **dst first** (dst, src1, src2) — the
same order `cindex` uses.

```go
// rotate.go — merge the daily index into the master, check the format, print stats.
package main

import (
	"log"

	"github.com/google/codesearch/index"
)

func main() {
	// dst comes FIRST: merge master + daily into master~ (the order cindex uses).
	index.Merge("/var/lib/docs/corpus.idx~", "/var/lib/docs/corpus.idx", "/var/lib/docs/daily.idx")
	ix := index.Open("/var/lib/docs/corpus.idx~")
	if err := ix.Check(); err != nil { // verify the index is well-formatted
		log.Fatal(err)
	}
	ix.PrintStats() // file/name/posting size statistics
}
```

Evidence: `index/merge.go:51` — `func Merge(dst, src1, src2 string) {`. Real
call site: `cmd/cindex/cindex.go:170` — `index.Merge(file+"~", master,
file)`. Check + stats after merge: `index/check.go:14` —
`func (ix *Index) Check() error {`; `index/read.go:188` —
`func (ix *Index) PrintStats() {`; `cmd/cindex/cindex.go:171-176,190-193` —
`ix := index.Open(file + "~")` … `if err := ix.Check(); err != nil {` /
`ix := index.Open(master)` … `ix.PrintStats()`.

Dependencies: `deps_out = [sparse]` — pulled in automatically when importing
`github.com/google/codesearch/index` inside the `github.com/google/codesearch`
module (single module, nothing to `go get`). Example imports:
`github.com/google/codesearch/index` + stdlib `log`, `fmt`, `regexp/syntax`.


## regexp (4★)


A regex engine optimized for grep-style programs: `Compile` parses via
`regexp/syntax` into a byte program, and a cached-DFA matcher runs it per
line/byte. `Grep` is the shared line-oriented driver of cgrep/csearch/csweb
with the -l/-c/-n/-h/-v flags, pre/post context, and HTML output.


### UC1 — embed the grep driver in your own tool (scan files, list matches only)


Scenario: an internal devtool scans a few Go files for `func main` and lists
only the matching files (like `-l`). Build a `regexp.Grep` with a `Compile`d
`Regexp`, set `Stdout`/`Stderr`, enable `L`, call `g.File(name)` per file;
use `g.Match` for the exit code exactly like cgrep.

```go
// patscan.go — embed the codesearch grep driver into your own tool.
package main

import (
	"log"
	"os"

	"github.com/google/codesearch/regexp"
)

func main() {
	re, err := regexp.Compile("(?m)func main") // (?m): per-line matching, like cgrep
	if err != nil {
		log.Fatal(err)
	}
	g := regexp.Grep{
		Regexp: re,
		Stdout: os.Stdout,
		Stderr: os.Stderr,
		L:      true, // -l: print matching file names only
	}
	for _, f := range []string{"cmd/cgrep/cgrep.go", "cmd/cindex/cindex.go"} {
		g.File(f) // open the file, scan per line with the cached-DFA matcher
	}
	if !g.Match {
		os.Exit(1) // same contract as cgrep: exit 1 when nothing matched
	}
}
```

Evidence: `regexp/regexp.go:30` — `func Compile(expr string) (*Regexp, error)
{`; `regexp/match.go:355-373` — `type Grep struct {` …
`Regexp *Regexp   // regexp to search for` / `Stdout io.Writer // output
target` / `Stderr io.Writer // error target` / `L bool // L flag - print file
names only`; `regexp/match.go:367` — `Match   bool // were any matches
found?`; `regexp/match.go:407-415` — `func (g *Grep) File(name string) {` …
`g.Reader(f, name)`. Real call site: `cmd/cgrep/cgrep.go:38-78` —
`var g regexp.Grep` … `g.Regexp = re` … `g.File(arg)` …
`if !g.Match { os.Exit(1) }`.


### UC2 — count matches on a log stream with an early-stop Limit


Scenario: pipe a log stream into the tool without a temp file; you only need
the NUMBER of matching lines (like `-c`) and want the tool to stop after 100
matches to save CPU. `Grep` reads straight from an `io.Reader` via
`g.Reader(r, name)`, prints to `Stdout`, and respects `Limit`.

```go
// tailgate.go — count matches on a log stream, stop early to save CPU.
package main

import (
	"os"

	"github.com/google/codesearch/regexp"
)

func main() {
	re, err := regexp.Compile("(?i)timeout|refused")
	if err != nil {
		panic(err)
	}
	g := regexp.Grep{
		Regexp: re,
		Stdout: os.Stdout,
		Stderr: os.Stderr,
		C:      true, // -c: print the match count
		Limit:  100,  // stop after 100 matches
	}
	g.Reader(os.Stdin, "<stdin>") // stream: no intermediate file needed
}
```

Evidence: `regexp/match.go:361` — `C bool // C flag - print count of
matches`; `regexp/match.go:369` — `Limit   int  // stop after this many
matches`; `regexp/match.go:432` — `func (g *Grep) Reader(r io.Reader, name
string) {`. Stdin pattern with the name "<standard input>":
`cmd/cgrep/cgrep.go:69-70` — `if len(args) == 1 {` /
`g.Reader(os.Stdin, "<standard input>")`.


### UC3 — match a single line directly (no Grep driver)


Scenario: a watcher processes log lines one by one and only needs to know
whether a line matches a pattern (plus where the match ends). Use `Compile`
+ `Regexp.MatchString` directly; it returns the match END position (≥ 0), **-1
when there is no match**; `re.String()` gives back the source pattern.

```go
// linewatch.go — check whether one log line matches a pattern (no Grep driver).
package main

import (
	"fmt"

	"github.com/google/codesearch/regexp"
)

func main() {
	re, err := regexp.Compile(`^ERROR [0-9]{3} `)
	if err != nil {
		panic(err)
	}
	line := "ERROR 503 backend timeout"
	// MatchString returns the match END position (>= 0); -1 when there is no match.
	if end := re.MatchString(line, true, true); end >= 0 {
		fmt.Printf("match ends at column %d\n", end)
	}
	fmt.Println("source pattern:", re.String())
}
```

Evidence: `regexp/regexp.go:57-59` —
`func (r *Regexp) MatchString(s string, beginText, endText bool) (end int) {`
/ `return r.m.matchString(s, beginText, endText)`; `regexp/regexp.go:24-26` —
`func (re *Regexp) String() string {` / `return re.expr`;
`regexp/match.go:312,339` — `return -1` (the matcher returns -1 on no match;
`matchString` at :315); `regexp/regexp.go:17-22` —
`type Regexp struct {` … `Syntax *syntax.Regexp` …
`expr   string // original expression`.

Dependencies: `deps_out = [sparse]` (the matcher uses the sparse set; pulled
in automatically within the same module). Example imports:
`github.com/google/codesearch/regexp` + stdlib `log`, `os`, `fmt`.


## cmd/cgrep (1★)


The `cgrep` CLI greps stdin or named files directly, without any index: it
builds a `regexp.Grep` from flags, compiles the pattern with a `(?m)` prefix
(and `(?i)` with `-i`), matches, and exits 1 when nothing matched. Useful when
the corpus is too small to deserve an index, or a stream must be filtered in
place.


### UC1 — quick search in a source tree, no index

```sh
# Find every RegexpQuery declaration in the index package, with line numbers:
$ cgrep -n 'RegexpQuery' index/*.go          # -n: print line numbers, prefix "file:"
index/regexp.go:333:func RegexpQuery(re *syntax.Regexp) *Query {
$ echo $?
0                                            # 0 = matched (exit code follows g.Match)
$ cgrep -l 'LogSkip' index/*.go              # -l: print matching file names only
index/write.go
$ cgrep -i 'LOGSKIP' index/write.go          # -i: case-insensitive
# (prints nothing — write.go has no matching string) → exit 1
$ echo $?
1
```

Evidence: `cmd/cgrep/cgrep.go:36` — `func main() {`; `:60-64` —
`pat := "(?m)" + args[0]` / `if *iflag {` / `pat = "(?i)" + pat` …
`re, err := regexp.Compile(pat)`; `:72-75` —
`for _, arg := range args[1:] {` / `g.File(arg)`; `:76-78` —
`if !g.Match {` / `os.Exit(1)` / `}`; `:32` —
`iflag = flag.Bool("i", false, "case-insensitive match")`;
`regexp/match.go:378-384` — `func (g *Grep) AddFlags() {` …
`flag.BoolVar(&g.L, "l", false, "list matching files only")` /
`flag.BoolVar(&g.N, "n", false, "show line numbers")`. The output line
`index/regexp.go:333:...` is a real line grepped on the tree; the
`name + ":"` prefix comes from `regexp/match.go:445-447` — `if !g.H {` /
`prefix = name + ":"` / `}`.


### UC2 — filter a stdin stream (pipeline, no temp file)

```sh
# Filter the last 5000 log lines by pattern, case-insensitive:
$ tail -n 5000 /var/log/app.log | cgrep -i 'timeout|refused'   # no file arg → reads stdin
2025-06-01T10:12:03Z ERROR 503 upstream timeout                # matching lines are printed verbatim
...
# Only the NUMBER of matching lines in the stream:
$ dmesg | cgrep -c 'usb'                                       # -c: print count of matches
7
$ echo $?
0
```

(The sample log lines are scenario data — stdin content is
environment-specific. The print-matching-lines-verbatim behavior belongs to
the driver: `regexp/match.go:432` — `func (g *Grep) Reader(r io.Reader, name
string) {`; the `-c` flag at `:361` — `C bool // C flag - print count of
matches`; the `-v` flag at `:364` — `V bool // V flag - print non-matching
lines (only for cgrep, not csearch)`; stdin handling at
`cmd/cgrep/cgrep.go:69-70`.)


### UC3 — exit code as a CI gate + flag syntax rules

```sh
# CI gate: fail when a file contains 'panic(' (no match → exit 1 → CI fails).
$ cgrep -l 'panic(' cmd/csearch/csearch.go
# → on match: prints "cmd/csearch/csearch.go", exit 0; on no match: exit 1
$ echo $?
1
# Go-style flag syntax: do NOT combine — write -i -n, not -in
$ cgrep -in 'todo' cmd/cgrep/cgrep.go
# → flag.Parse rejects it ("flag provided but not defined: -in"), prints usage, exit 2
```

Evidence: `cmd/cgrep/cgrep.go:21-23` — `The -c, -h, -i, -l, -n, and -v flags
are as in grep, although note that as per Go's` / `flag parsing convention,
they cannot be combined: the option pair -i -n` / `cannot be abbreviated to
-in.`; `:26-29` — `func usage() {` /
`fmt.Fprintf(os.Stderr, usageMessage)` / `os.Exit(2)`; `:76-78` —
`if !g.Match {` / `os.Exit(1)` / `}`; `:43-44` — `flag.Usage = usage` /
`flag.Parse()`.

Dependencies: `deps_out = [regexp]` (real import at
`cmd/cgrep/cgrep.go:14`). Build the `cgrep` binary from `cmd/cgrep` inside
the `github.com/google/codesearch` module; the package has no `_test.go`
files.


## cmd/cindex (1★)


The `cindex` CLI builds/updates the trigram index at `$CSEARCHINDEX` or
`$HOME/.csearchindex`: converts roots to absolute paths, `filepath.Walk`s
skipping hidden/temporary files into `ix.AddFile`, `ix.Flush`, and — unless
`-reset` — `index.Merge`s the new index with the master and renames it over;
auxiliary modes `-list` (with `-check`), `-reset`, `-stats`, `-zip`,
`-cpuprofile`.


### UC1 — index a source tree for the first time + verify

```sh
# Index a source tree for the first time.
$ export CSEARCHINDEX=$HOME/.csearchindex        # index location (default $HOME/.csearchindex)
$ cindex -verbose -stats /home/me/src/myproj     # build + print statistics at the end
cindex: index /home/me/src/myproj                # logs each root (cindex.go:141)
cindex: flush index                              # (cindex.go:165)
cindex: done                                     # (cindex.go:188)
$ cindex -list -check                            # print stored roots; -check self-verifies the format
/home/me/src/myproj
# During the Walk: hidden/temp files are skipped (.foo, #foo, foo~, foo#) — cindex.go:143-151
```

Evidence: `cmd/cindex/cindex.go:61-68` —
`listFlag = flag.Bool("list", false, "list indexed paths and exit")` …
`checkFlag = flag.Bool("check", false, "check index is well-formatted")` …
`statsFlag = flag.Bool("stats", false, "print index size statistics")`;
`:141` — `log.Printf("index %s", root)`; `:165` —
`log.Printf("flush index")`; `:188` — `log.Printf("done")`; `:75-86` —
`if *listFlag {` … `for p := range ix.Roots().All() {` …
`fmt.Printf("%s\n", p)`; `:143-151` —
`if _, elem := filepath.Split(path); elem != "" {` …
`if elem[0] == '.' || elem[0] == '#' || elem[0] == '~' || elem[len(elem)-1] == '~' {`;
`index/read.go:665-666` — `// File returns the name of the index file to
use.` / `// It is either $CSEARCHINDEX or $HOME/.csearchindex.`


### UC2 — incremental update (no -reset): reuse roots, merge safely via rename

```sh
# Run with NO arguments: reuses exactly the roots stored in the existing index.
$ cindex                                          # NArg()==0 → open the old index, read roots (cindex.go:102-105)
cindex: index /home/me/src/myproj
cindex: flush index
cindex: merge /home/me/.csearchindex /home/me/.csearchindex~   # (cindex.go:169)
cindex: done
# Safety: the merged result is written to the "~" temp file, then os.Rename over the master (cindex.go:177-178)
# → if the process dies midway, the old master stays intact.
```

Evidence: `cmd/cindex/cindex.go:102-105` — `if flag.NArg() == 0 {` /
`ix := index.Open(index.File())` / `roots = slices.Collect(ix.Roots().All())`;
`:125-127` — `file := master` / `if !*resetFlag {` / `file += "~"`;
`:169-170` — `log.Printf("merge %s %s", master, file)` /
`index.Merge(file+"~", master, file)`; `:177-178` — `os.Remove(file)` /
`os.Rename(file+"~", master)`; `:121-124` —
`if _, err := os.Stat(master); err != nil {` / `// Does not exist.` /
`*resetFlag = true` (missing master → automatically switches to reset).


### UC3 — special modes: -reset (rebuild/delete), -zip (index zip contents), -check

```sh
# Rebuild from scratch for exactly the given roots (-reset skips the merge step):
$ cindex -reset -check /home/me/src/myproj
cindex: index /home/me/src/myproj
cindex: flush index
cindex: done
# Index the CONTENTS of .zip files too (by default only the zip name is added):
$ cindex -zip /home/me/dist
# -reset with no arguments: just DELETE the index and exit:
$ cindex -reset
```

Evidence: `cmd/cindex/cindex.go:62` —
`resetFlag = flag.Bool("reset", false, "discard existing index")`; `:66` —
`zipFlag = flag.Bool("zip", false, "index content in zip files")`; `:98-101` —
`if *resetFlag && flag.NArg() == 0 {` / `os.Remove(index.File())` /
`return`; `:137-138` — `ix.Verbose = *verboseFlag` / `ix.Zip = *zipFlag`;
`index/write.go:165` —
`if strings.HasSuffix(name, ".zip") && ix.Zip {`.

Dependencies: `deps_out = [index]` (real import at
`cmd/cindex/cindex.go:16`). Environment: `$CSEARCHINDEX` (optional) points at
the index location; default `$HOME/.csearchindex`. No `_test.go` files in the
package.


## cmd/csearch (1★)


The `csearch` CLI greps over a pre-built trigram index instead of scanning a
raw tree: it parses flags, compiles the regexp `(?m)`/`(?i)`, lowers it into
a posting query that filters files first, then iterates every candidate file
(including `.zip` archive members) running `regexp.Grep.Reader` to print
results; exit 1 when nothing matched.


### UC1 — daily code lookup from the terminal

Scenario: the index was built once; now find every call site of
`RegexpQuery` in Go files with line numbers, then search case-insensitively
listing file names only, then count matching lines per file.

```sh
# 1. Build the index once — csearch only reads the index, it never scans the tree
#    (csearch's own usage message says: "To build or rebuild the index
#    that csearch uses, run: cindex path...")
cindex /home/dev/src

# 2. Find RegexpQuery call sites in .go files, with line numbers (-n),
#    restricted by file name (-f)
csearch -n -f '\.go$' 'RegexpQuery\('

# 3. Case-insensitive, print matching file names only (-i -l)
csearch -i -l 'postingquery'

# 4. Count matching lines per file (-c)
csearch -c 'dstate'
```

Evidence: `cmd/csearch/csearch.go:21` — `var usageMessage = `usage: csearch
[-c] [-f fileregexp] [-h] [-i] [-l] [-n] regexp``; `:52` —
`fFlag = flag.String("f", "", "search only files with names matching this
regexp")`; `:53` — `iFlag = flag.Bool("i", false, "case-insensitive search")`;
`regexp/match.go:378-382` — `func (g *Grep) AddFlags() { flag.BoolVar(&g.L,
"l", false, "list matching files only"); flag.BoolVar(&g.C, "c", ...);
flag.BoolVar(&g.N, "n", "show line numbers"); flag.BoolVar(&g.H, "h", ...) }`
— called from `csearch.go:68` (`g.AddFlags()`).


### UC2 — CI gate blocking banned patterns via the exit code

Scenario: the CI pipeline must fail if a banned pattern (e.g.
`unsafe.Pointer`) appears in indexed code. `csearch` exits 0 on a match and 1
on no match; the CI script maps the exit code to pass/fail and points at a
dedicated index through `$CSEARCHINDEX` instead of the default `$HOME` one.

```sh
#!/bin/sh
set -u
# CI points at its index through the environment — index.File() reads $CSEARCHINDEX first
export CSEARCHINDEX=/var/cache/ci.csearchindex

# csearch: exit 0 = match found, exit 1 = no match, 2 = usage error
if csearch -f '\.go$' 'unsafe\.Pointer' >/dev/null 2>&1; then
    echo "CI FAIL: unsafe.Pointer found in indexed sources"
    exit 1
fi
echo "CI OK: no unsafe.Pointer"
```

Evidence: `cmd/csearch/csearch.go:112` — `ix := index.Open(index.File())`;
`index/read.go:667-673` — `// File returns the name of the index file to
use. … func File() string { f := os.Getenv("CSEARCHINDEX"); if f != "" {
return f } … }`; `cmd/csearch/csearch.go:191` — `matches = g.Match`;
`:194-200` — `func main() { Main(); if !matches { os.Exit(1) }; os.Exit(0) }`.


### UC3 — diagnose trigram-filter tightness (`-verbose`, `-brute`)

Scenario: an engineer wants to know how many files survive the trigram filter
before the real regex runs: `-verbose` prints the query and the candidate
count after the posting query; `-brute` skips the trigram filter entirely and
runs `PostingQuery(&Query{Op: QAll})` over every file in the index. The gap
between the two numbers is the value of the trigram filter.

```sh
# How many files does the trigram filter leave?
csearch -verbose 'dstate' 2>&1 | grep 'post query identified'

# Compare: -brute bypasses the trigram filter, scanning EVERY file in the index
csearch -verbose -brute 'dstate' 2>&1 | grep 'post query identified'
```

Evidence: `cmd/csearch/csearch.go:55` —
`verboseFlag = flag.Bool("verbose", false, "print extra information")`;
`:56` —
`bruteFlag = flag.Bool("brute", false, "brute force - search all files in index")`;
`:107-110` — `q := index.RegexpQuery(re.Syntax); if *verboseFlag {
log.Printf("query: %s\n", q) }`; `:115-118` — `if *bruteFlag { post =
ix.PostingQuery(&index.Query{Op: index.QAll}) } else { post =
ix.PostingQuery(q) }`; `:120-122` — `if *verboseFlag { log.Printf("post
query identified %d possible files\n", len(post)) }`.

Dependencies: `index`, `regexp` (real imports at
`cmd/csearch/csearch.go:17-18`); stdlib `flag`, `log`, `os`
(csearch.go:9-16). The binary needs an index built by `cindex` first, or
`$CSEARCHINDEX` pre-pointed. No `_test.go` files in the package.


## cmd/csweb (1★)


The `csweb` web UI: an HTTP server on `localhost:2473` taking query `q` plus
filename filter `f`, running the posting query on the index and emitting
grep results as HTML through `regexp.Grep`; the `/show/` handler renders
files/directories as line-numbered HTML; static assets are embedded with
`go:embed`.


### UC1 — stand up a team-local code search web UI

Scenario: a lead stands up an internal search server: build `csweb`, run the
server reading the same index as `csearch`, the team queries from the form
(params `q`, `f`) and gets HTML-highlighted results with a match-count/timing
footer.

```sh
# 1. Build the web server from the repo root
go build -o csweb ./cmd/csweb

# 2. Index the sources, then run the server (it reads the same index via index.File())
cindex /home/dev/src
./csweb &        # ListenAndServe on localhost:2473

# 3. Query as if submitting the form: q = pattern, f = filename filter
curl -s 'http://localhost:2473/?q=RegexpQuery&f=\.go$' | head -40
# … footer: "<N> matches in <T>s" printed from g.Matches
```

Evidence: `cmd/csweb/web.go:32-36` — `func main() {
http.HandleFunc("/", home); http.Handle("/_static/",
http.FileServer(http.FS(static))); http.HandleFunc("/show/", show);
log.Fatal(http.ListenAndServe("localhost:2473", nil)) }`; `:43` —
`qarg := r.FormValue("q")`; `:49-53` — `g := regexp.Grep{ HTML: true, Limit:
100000, Stdout: w, Stderr: w }`; `:56-57` — `pat := "(?m)" + qarg` …
`re, err := regexp.Compile(pat)`; `:62` — `g.Regexp = re`; `:64` —
`farg := r.FormValue("f")`; `:72` — `q := index.RegexpQuery(re.Syntax)`;
`:77-80` — `start := time.Now()` … `ix := index.Open(index.File())` …
`post := ix.PostingQuery(q)`; `:151` —
`fmt.Fprintf(w, "\n%d matches in %.3fs\n", g.Matches, time.Since(start).Seconds())`.


### UC2 — line-numbered file viewer with anchor highlight

Scenario: from a search result, open `/show/<path>` to see the file rendered
as HTML where every line is wrapped in `<span id="L<number>">`; sharing a
link with `#L42` makes `viewer.js`'s `highlight()` add the `sel` class
(yellow `#ffff88` per `viewer.css`) to exactly that line — enough to paste a
"read this line" link into a review.

```sh
# 1. Open /show/ for one file: every line becomes <span id="L42">
curl -s 'http://localhost:2473/show/home/dev/src/index/read.go' \
  | grep -o 'id="L[0-9]*"' | head -3

# 2. In the browser: /show/home/dev/src/index/read.go#L42
#    → viewer.js highlight() adds the "sel" class to the span id=L42
#    (background #ffff88 per viewer.css)
```

Evidence: `cmd/csweb/web.go:173` —
`func show(w http.ResponseWriter, r *http.Request) {`; `:235` —
`func serveFile(file string, data []byte) []byte {`; `:250` —
`fmt.Fprintf(&buf, "<span id=\"L%d\">%*d  %s\n</span>", n, wid, n,
e(string(line)))`; `:205-210` —
`func printHeader(buf *bytes.Buffer, file string) { …
buf.WriteString("<link rel=\"stylesheet\" href=\"/_static/viewer.css\">\n");
buf.WriteString("<script src=\"/_static/viewer.js\"></script>\n") … }`;
`:39-40` — `//go:embed _static` / `var static embed.FS` (served at web.go:34
`http.Handle("/_static/", http.FileServer(http.FS(static)))`);
`cmd/csweb/_static/viewer.js:1-8` — `function highlight() {
if(window.location.hash) { var span =
document.getElementById(window.location.hash.substr(1)); if(span) {
span.classList.add("sel"); } } }`; `cmd/csweb/_static/viewer.css:1-3` —
`.sel { background-color: #ffff88; }`.


### UC3 — search inside `.zip` archives (module cache)

Scenario: the code you need lives in Go module caches stored as zips; run
`cindex -zip` so archive members get indexed — indexed file names take the
form `path/archive.zip\x01member.go`; the home handler opens the zip and
greps each member without unpacking anything.

```sh
# 1. Index the contents of .zip files (e.g. the Go module cache)
cindex -zip /root/go/pkg/mod

# 2. The server now serves zip members too
./csweb &

# 3. Find a pattern inside a zip member (filter file names by domain)
curl -s 'http://localhost:2473/?q=PostingsList&f=k8s\.io' | tail -3
```

Evidence: `cmd/cindex/cindex.go:66` —
`zipFlag = flag.Bool("zip", false, "index content in zip files")` and `:138`
`ix.Zip = *zipFlag`; `index/write.go:165` —
`if strings.HasSuffix(name, ".zip") && ix.Zip {` and `:177`
`r, err := zip.NewReader(f, info.Size())`; `cmd/csweb/web.go:115` —
`if i := strings.Index(name, ".zip\x01"); i >= 0 {`; `:123` —
`zipReader, err = zip.OpenReader(zfile)`; `:130,134` —
`zipMap[file.Name] = file` … `file := zipMap[zname]`.

Dependencies: `index`, `regexp` (real imports at
`cmd/csweb/web.go:24-25`); stdlib `net/http`, `embed`, `archive/zip`, `fmt`,
`log`, `os`, `time` (web.go:9-27). The index must be built first (`cindex`,
or `cindex -zip` for UC3). No `_test.go` files in the package.


## sparse (1★)


The `sparse` package implements a sparse set of `uint32` via the
dense/sparse two-array technique (Russ Cox's uninitialized-memory trick):
`Add`/`Has`/`Init`/`NewSet`/`Reset`/`Dense`/`Len` with O(1) membership and
O(1) reset — the high-performance trigram set used inside `index` and
`regexp` (real call sites: `index/write.go:44,72`; `regexp/match.go:34`).


### UC1 — a 24-bit trigram set for the file being indexed (the way `index` uses it)

Scenario: an indexer author needs to hold the 24-bit trigram set of the file
being processed before handing it to the posting list — exactly how
`index/write.go` declares and initializes it (`trigram *sparse.Set`,
`sparse.NewSet(1 << 24)`). API used: `NewSet`, `Add`, `Has`, `Len`.

```go
package main

import (
	"fmt"

	"github.com/google/codesearch/sparse"
)

// 24-bit trigram set for the file being indexed — the same shape used in
// index/write.go:44 (trigram *sparse.Set) and :72 (sparse.NewSet(1 << 24)).
func main() {
	trigram := sparse.NewSet(1 << 24)

	data := []byte("abcabc")
	for i := 0; i+2 < len(data); i++ {
		v := uint32(data[i])<<16 | uint32(data[i+1])<<8 | uint32(data[i+2])
		trigram.Add(v) // Add dedups: no-op if the value is already present
	}

	fmt.Println("has 'abc':", trigram.Has(0x616263)) // true
	fmt.Println("unique trigrams:", trigram.Len())   // 3
}
```

Evidence: `sparse/set.go:21-26` — `func NewSet(max uint32) *Set { return
&Set{ sparse: make([]uint32, max) } }`; `:39-48` — `func (s *Set) Add(x
uint32) { v := s.sparse[x]; if v < uint32(len(s.dense)) && s.dense[v] == x {
return }; n := len(s.dense); s.sparse[x] = uint32(n); s.dense =
append(s.dense, x) }`; `:50-54` — `func (s *Set) Has(x uint32) bool { v :=
s.sparse[x]; return v < uint32(len(s.dense)) && s.dense[v] == x }`; `:63-65`
— `func (s *Set) Len() int { return len(s.dense) }`. Real call site:
`index/write.go:44` — `trigram *sparse.Set // trigrams for the current file`
and `:72` `trigram:   sparse.NewSet(1 << 24),`.


### UC2 — O(1) reset between files (why not a bitmap)

Scenario: an indexer processes hundreds of thousands of files and reuses the
SAME Set for each one; `Reset()` only truncates `dense` to length 0 — O(1) —
while a bitmap must be cleared across the whole space between files. The
source comment records the measured comparison: 11s vs 25s on the Linux 2.6
kernel. API used: `NewSet`, `Reset`, `Add`, `Dense`, `Len`.

```go
package main

import (
	"fmt"

	"github.com/google/codesearch/sparse"
)

// Index many files reusing the SAME Set: Reset() only does dense = dense[:0] — O(1);
// a bitmap would have to clear the whole space between files (set.go:8-11:
// cindex on Linux 2.6 = 11s with the sparse set, 25s with a bitmap).
func main() {
	files := [][]uint32{
		{0x616263, 0x626364},
		{0x636465},
	}
	s := sparse.NewSet(1 << 24)
	for _, f := range files {
		s.Reset()
		for _, v := range f {
			s.Add(v)
		}
		fmt.Println("file trigrams:", s.Dense(), "len:", s.Len())
	}
}
```

Evidence: `sparse/set.go:8-11` — `// For comparison: running cindex over the
Linux 2.6 kernel with this implementation of trigram sets takes 11 seconds.
If I change it to a bitmap (which must be cleared between files) it takes 25
seconds.`; `:34-36` — `func (s *Set) Reset() { s.dense = s.dense[:0] }`;
`:56-61` — `// Dense returns the values in the set. // The values are listed
in the order in which they // were inserted. func (s *Set) Dense() []uint32 {
return s.dense }`; `:29-32` — `func (s *Set) Init(max uint32) { s.sparse =
make([]uint32, max) }` (the NewSet variant for a reused Set).


### UC3 — dedup a stream of IDs preserving first-seen order

Scenario: beyond trigrams, the Set works as a uint32 dedup structure (event
IDs, fileids) that preserves first-seen order because `Dense()` returns the
dense slice in insertion order; `Has` gives O(1) membership. API used:
`NewSet`, `Has`, `Add`, `Dense`.

```go
package main

import (
	"fmt"

	"github.com/google/codesearch/sparse"
)

// Dedup event IDs but keep first-seen order: Dense() returns the dense slice
// in insertion order (set.go:56-61).
func main() {
	ids := []uint32{7, 3, 7, 9, 3, 1}
	seen := sparse.NewSet(1000)
	out := []uint32{}
	for _, id := range ids {
		if !seen.Has(id) {
			seen.Add(id)
			out = append(out, id)
		}
	}
	fmt.Println(out, seen.Dense()) // [7 3 9 1] [7 3 9 1]
}
```

Evidence: `sparse/set.go:50-54` — `func (s *Set) Has(x uint32) bool { v :=
s.sparse[x]; return v < uint32(len(s.dense)) && s.dense[v] == x }`; `:39-48`
— `func (s *Set) Add(x uint32) { … n := len(s.dense); s.sparse[x] =
uint32(n); s.dense = append(s.dense, x) }`; `:56-61` — `func (s *Set)
Dense() []uint32 { return s.dense }` (insertion order preserved).

Dependencies: none — `deps_out = ∅` (the file imports no package at all);
library consumers only need `github.com/google/codesearch/sparse`. No
`_test.go` files in the package.


## Build note


Every example builds from the repo root of `github.com/google/codesearch`
(`go build ./...` builds all four binaries plus the libraries; `go test ./...`
runs the `index` and `regexp` test suites — real exit-0 evidence in
[`04-overview.md`](04-overview.md)). The tree has zero third-party
dependencies (`go.mod` has no `require` block; no `go.sum` exists), so no
proxy or vendoring step is needed.
