---
subject: google/codesearch
measured_at: 74a12a911a79b901d1158c48d011b2da1b090fc9
status: final
---


# Flows


The three most expensive data flows of google/codesearch, ranked by numbers
on the pinned tree `74a12a911a79b901d1158c48d011b2da1b090fc9`. Every sequence
step below was traced by reading the actual code (`nl -ba`, `grep -n`) on a
clone of the pin — no step is inferred.

**Declared limit:** the churn window is the **43 most recent commits** only
(the depth-100 clone returned exactly 43 commits; not the full upstream
history).


## 1. Method and raw numbers


### 1a. Fan-in / fan-out (static import graph, 7 packages)


fan-in = number of packages importing it; fan-out = number of packages it
imports. Import edges re-verified by grep on the clone (matches the module
map):

```
$ grep -n 'codesearch/' cmd/cgrep/cgrep.go cmd/cindex/cindex.go cmd/csearch/csearch.go cmd/csweb/web.go index/write.go index/merge.go index/regexp.go index/read.go regexp/match.go | grep -v '_test'
cmd/cgrep/cgrep.go:14   → regexp
cmd/cindex/cindex.go:16 → index
cmd/csearch/csearch.go:17 → index
cmd/csearch/csearch.go:18 → regexp
cmd/csweb/web.go:24     → index
cmd/csweb/web.go:25     → regexp
index/write.go:19       → sparse
regexp/match.go:20      → sparse
```

| item | package | fan-in | fan-out | LOC |
|---|---|---|---|---|
| m01 | cmd/cgrep | 0 | 1 | 79 |
| m02 | cmd/cindex | 0 | 1 | 195 |
| m03 | cmd/csearch | 0 | 2 | 200 |
| m04 | cmd/csweb | 0 | 2 | 286 |
| m05 | index | **3** (cindex, csearch, csweb) | 1 | 4366 (66% of 6608) |
| m06 | regexp | **3** (cgrep, csearch, csweb) | 1 | 1417 (21%) |
| m07 | sparse | 2 (index, regexp) | 0 | 65 |


### 1b. Churn (43-commit window, raw output)

```
$ git log --format= --name-only | sort | uniq -c | sort -rn | head -20
     16 index/write.go
     13 index/read.go
     10 cmd/csearch/csearch.go
      9 regexp/match.go
      9 index/write_test.go
      9 index/merge.go
      8 cmd/cindex/cindex.go
      6 index/merge_test.go
      6 cmd/cgrep/cgrep.go
      4 regexp/regexp_test.go
      4 index/read_test.go
      4 index/mmap_windows.go
      4 index/mmap_bsd.go
      4 README
      3 index/regexp.go
      3 index/mmap_linux.go
      2 regexp/utf.go
      2 regexp/regexp.go
      2 regexp/copy.go
      2 lib/buildall
```

Churn per package (same command, `.go` filter): index 80, regexp 19,
cmd/csearch 10, cmd/cindex 8, cmd/cgrep 6, sparse 1, cmd/csweb 1 (file×commit
events; a commit touching several files counts once per file, so the total
exceeds 43).


### 1c. TOP-3 selection


**churn_flow** = Σ churn of exactly the files cited as steps in the flow's
sequence diagram below; **fan_support** = Σ fan-in of the library packages
the flow crosses. Ranking: churn_flow is the primary key, fan_support the
secondary. The 4 candidate flows = the 4 entry points.

| # | flow (entry point) | files on the path (per-file churn) | churn_flow | fan_support | rank |
|---|---|---|---|---|---|
| F1 | csearch — grep over the index | csearch.go 10 + index/read.go 13 + index/regexp.go 3 + regexp/match.go 9 + regexp/regexp.go 2 + sparse/set.go 1 | **38** | index 3 + regexp 3 + sparse 2 = **8** | **1** |
| F2 | cindex — build/merge the index | cindex.go 8 + index/write.go 16 + index/merge.go 9 + sparse/set.go 1 | **34** | index 3 + sparse 2 = **5** | **2** |
| F3 | csweb — web search | web.go 1 + index/read.go 13 + index/regexp.go 3 + regexp/match.go 9 + regexp/regexp.go 2 + sparse/set.go 1 | **29** | index 3 + regexp 3 + sparse 2 = **8** | **3** |
| F4 | cgrep — index-free grep | cgrep.go 6 + regexp/match.go 9 + regexp/regexp.go 2 + regexp/utf.go 2 + sparse/set.go 1 | 20 | regexp 3 + sparse 2 = 5 | excluded (loses on both keys) |

**TOP-3 = F1 (csearch), F2 (cindex), F3 (csweb).** F4 is excluded because
churn 20 < 29 and fan_support 5 < 8 — it loses on both keys, no tiebreak
needed.


## 2. Flow F1 — csearch: query → trigram posting query → DFA grep (rank 1)


### Why it is expensive (numbers)

- churn_flow **38/43** — the highest: it crosses 3 of the top-4 churn files
  (index/read.go 13 — #2; cmd/csearch/csearch.go 10 — #3; regexp/match.go 9 —
  #4).
- It runs through **all 3 highest fan-in library packages**: index (fan-in 3,
  4366 LOC = 66% of the codebase) + regexp (fan-in 3, 1417 LOC = 21%) +
  sparse (fan-in 2) — any change in those three packages forces a re-check of
  csearch (fan-out 2).
- Recent commits touching path files (traceable on the clone):
  `d481e2c csearch: add -html flag`, `e53428b csearch, cgrep: add -A, -B, -C, -V flags`,
  `fad9cf8 index: compact 64-bit index format`, `fde726f index: fix merge bug
  by sharing more code between write and merge` — this flow changed both UI
  flags and the index format within the same 43-commit window.

### Sequence (10 steps, every step pinned to file:line on the tree)

```mermaid
sequenceDiagram
    participant U as User/Shell
    participant C as csearch main (cmd/csearch/csearch.go)
    participant RE as regexp.Compile (regexp/regexp.go)
    participant Q as index.RegexpQuery (index/regexp.go)
    participant IX as Index (index/read.go)
    participant G as Grep (regexp/match.go)

    U->>C: csearch [-flags] pattern
    Note over C: flag.Parse, pattern = (?m)+arg, (?i) with -i (csearch.go:91-94)
    C->>RE: regexp.Compile(pat) (csearch.go:95)
    Note over RE: syntax.Parse:31, Simplify:35, Compile:36, toByteProg:40, m.init:47 (regexp.go:30-49, match.go:131)
    C->>Q: index.RegexpQuery(re.Syntax) (csearch.go:107)
    Note over Q: analyze+simplify+addExact produce the conservative trigram Query (index/regexp.go:333-338), ops QAll/QNone/QAnd/QOr (index/regexp.go:31-34)
    C->>IX: ix = index.Open(index.File()) (csearch.go:112)
    Note over IX: mmap the file (read.go:196-198); index file from $CSEARCHINDEX or $HOME/.csearchindex (read.go:667-678); parse trailer offsets (read.go:203-235)
    C->>IX: post = ix.PostingQuery(q) (csearch.go:118; -brute forces QAll, csearch.go:115-116)
    Note over IX: postingQuery switch QAnd: postingList per trigram then postingAnd (read.go:565-615, 501-535); QOr mergeOr (read.go:600-612, 617-636)
    C->>IX: -f filter: ix.Name(fileid) + fre.MatchString (csearch.go:124-139, 147-148)
    Note over IX: Name → NamesAt → PathReader prefix-compressed (read.go:283-308)
    C->>G: g.Reader(file, name) per fileid (csearch.go:187; regular file via os.Open csearch.go:153; .zip member via zipMap csearch.go:155-184)
    Note over G: 1MB buffer (match.go:433-434); each chunk calls g.Regexp.Match (match.go:450-465) → matcher.match DFA (match.go:283-313), dstate cache (match.go:269-281)
    G-->>U: print matching lines per -l/-c/-n/-html (match.go:476-516, HTML at match.go:510-511); matches → exit code (csearch.go:191-200)
```


## 3. Flow F2 — cindex: walk → trigram add → flush → k-way merge (rank 2)


### Why it is expensive (numbers)

- churn_flow **34**: contains **2 of the top-3 churn files** —
  `index/write.go` 16 (churn #1: 16/43 ≈ 37% of the window's commits touch
  it) and `index/merge.go` 9 (tied #3); plus `cmd/cindex/cindex.go` 8.
- write.go is the repo's largest file (902 LOC) and the focal point of recent
  commits: `74a12a9 index: slight performance optimization` (the pin HEAD
  itself), `8aad6cc index: move non-merge-specific code into write.go`,
  `fde726f index: fix merge bug by sharing more code between write and merge`
  — one merge bugfix had to change write+merge+read together (3 files on the
  same flow).
- The only TOP-3 flow that **writes on-disk state** (temp buffers → merge →
  atomic rename) — an interrupted run risks a corrupted index, which is why
  the external-memory merge logic concentrates here.

### Sequence (9 steps)

```mermaid
sequenceDiagram
    participant U as User/Shell
    participant C as cindex main (cmd/cindex/cindex.go)
    participant W as IndexWriter (index/write.go)
    participant S as sparse.Set (sparse/set.go)
    participant M as index.Merge (index/merge.go)

    U->>C: cindex path... (no args = reindex; -reset = delete index)
    Note over C: roots from args (filepath.Abs + sort, cindex.go:102-118) or re-read from the old index (cindex.go:103-105); -reset with no args removes the index (cindex.go:98-101)
    C->>C: master = index.File(); missing → enable -reset (cindex.go:120-124); file = master+"~" when merging (cindex.go:125-134)
    C->>W: ix = index.Create(file) (cindex.go:136)
    Note over W: sparse.NewSet(1<<24) (write.go:72), 4 temp buffers nameData/nameIndex/postFile/postIndex (write.go:73-76), post cap npost = 64MB/8 (write.go:67,78), PathWriter (write.go:81)
    C->>W: ix.AddRoots(roots) (cindex.go:139 → write.go:138)
    C->>W: filepath.Walk skipping hidden/temp files (cindex.go:142-151) → ix.AddFile(path) (cindex.go:157 → write.go:144-155)
    W->>S: add(): slide the 24-bit trigram window, trigram.Add (write.go:215-246 → set.go:38-47)
    Note over W: skip files with NUL (write.go:247-252) / invalid UTF-8 (write.go:253-258); -zip: sorted zip members added as name+"\x01"+member (write.go:177-207)
    C->>W: ix.Flush() (cindex.go:166)
    Note over W: magic (write.go:305-308) → path list (310-318) → name list (320-324) → mergePost posting lists (326-330, write.go:428) → name index (332-335) → posting index (337-339) → trailer + temp cleanup (341-358) → main.Flush (362)
    C->>M: index.Merge(file+"~", master, file) unless -reset (cindex.go:170)
    Note over M: open both indexes (merge.go:51-53); fileid-range map A,B → C (merge.go:39-42, 55-80); merge name + posting lists per the algorithm in merge.go:9-31
    C->>C: os.Remove(file); os.Rename(file+"~", master) — atomic completion (cindex.go:177-178); -stats prints PrintStats (cindex.go:190-193)
```


## 4. Flow F3 — csweb: HTTP query → posting query → HTML grep (rank 3)


### Why it is expensive (numbers)

- churn_flow **29**: almost entirely in the shared core (read.go 13 +
  match.go 9 + index/regexp.go 3 + regexp/regexp.go 2 + sparse/set.go 1) —
  `web.go` itself churns only 1. The maintenance cost of this flow **lives in
  the shared engine**, not the web layer.
- fan_support **8** — equal to F1: index (3), regexp (3), sparse (2) all at
  maximum fan-in; csweb is one of the three consumers that make index and
  regexp fan-in 3 (grep-verified: web.go:24-25).
- Additional cost not measured by churn: Grep runs with `Stdout: w` directly
  on the HTTP response and `Limit: 100000` (web.go:49-54) — a bad query can
  push the entire HTML output through one synchronous handler on
  localhost:2473 (web.go:36).

### Sequence (9 steps)

```mermaid
sequenceDiagram
    participant B as Browser
    participant H as home handler (cmd/csweb/web.go)
    participant RE as regexp.Compile (regexp/regexp.go)
    participant Q as index.RegexpQuery (index/regexp.go)
    participant IX as Index (index/read.go)
    participant G as Grep HTML (regexp/match.go)

    B->>H: GET localhost:2473/?q=...&f=... (route web.go:33-36; read q at web.go:42-47)
    H->>H: uses Grep{HTML:true, Limit:100000, Stdout:w} (web.go:49-54)
    H->>RE: re = regexp.Compile("(?m)"+q) (web.go:56-57; error returns "Bad query" web.go:58-61)
    H->>RE: -f filter: fre = Compile(farg) (web.go:63-71)
    H->>Q: q = index.RegexpQuery(re.Syntax) (web.go:72 → index/regexp.go:333-338)
    H->>IX: ix = index.Open(index.File()); post = ix.PostingQuery(q) (web.go:77-80; timer start=time.Now() web.go:77)
    H->>IX: -f filter: ix.Name(fileid) + fre.MatchString (web.go:85-100 → read.go:283-285)
    H->>G: loop over post: os.Open / zip member → g.Reader(file, name) (web.go:108-148; stops when g.Limited breaks web.go:109-111)
    G-->>B: HTML links with #L<lineno> anchors (match.go:510-511, -l at match.go:477-478); footer N matches in T s (web.go:151-154)
```


## 5. The excluded flow — F4 cgrep (by numbers, not taste)


cgrep searches stdin/files directly, never the index (module map m01;
cgrep.go does not import index — see the import grep in §1a). churn_flow 20 =
cgrep.go 6 + match.go 9 + regexp.go 2 + utf.go 2 + set.go 1; fan_support 5.
It loses to F3 on both churn (20 < 29) and fan_support (5 < 8) → not in the
TOP-3.


## 6. Traceability note


Every `file:line` inside the three sequence diagrams above was read directly
from the pin clone in the modeling session (`nl -ba` on cindex.go, csearch.go,
web.go, read.go, regexp.go ×2, match.go, write.go, merge.go, set.go —
function frames extracted, order never guessed). Churn counts and the recent
commit lists come from the same clone (`git log --oneline -3 -- <file>` for
the six highest-churn files). No conflicts with the module map: the
`regexp.Compile` citation uses regexp.go:30-49 and `sparse/set.go` is the
package's real file name.
