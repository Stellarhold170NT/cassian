// workspace.dsl — Structurizr DSL: C4 model of google/codesearch
// Upstream tree: github.com/google/codesearch @ 74a12a911a79b901d1158c48d011b2da1b090fc9 (master)
// Every element and relationship below carries an `// evidence:` line pointing at a
// grep-verified file:line in the pinned tree. Elements without evidence are not modeled.
// NOTE: not machine-validated with structurizr-cli (no java available at modeling time);
// the DSL was hand-checked (identifier balance, quoted strings, view blocks) and
// diagrams.mmd carries the same model 1:1 as the renderable Mermaid fallback.

workspace {

    name "Code Search"
    description "Trigram-based code search toolkit (cindex, csearch, cgrep, csweb) from google/codesearch"

    model {

        // ================= L1 — System Context =================

        developer = person "Developer" "Programmer who builds/updates the trigram index and searches source code from a terminal (cindex, csearch, cgrep)"
            // evidence: cmd/cindex/cindex.go:19; cmd/csearch/csearch.go:21; cmd/cgrep/cgrep.go:17 (usage messages addressed to the CLI user)

        webUser = person "Web User" "Developer who searches code and views files through the local web UI served by csweb at http://localhost:2473"
            // evidence: cmd/csweb/web.go:36 (http.ListenAndServe on localhost:2473)

        codeSearch = softwareSystem "Code Search" "Trigram index + grep-style search toolkit: cindex, csearch, cgrep, csweb over the index/regexp/sparse libraries"
            // evidence: go.mod:1 (module github.com/google/codesearch); cmd/cindex/cindex.go:16; cmd/csearch/csearch.go:17-18

        fileSystem = softwareSystem "Local File System" "Source trees on disk: walked when indexing, opened and grepped when searching" {
            tags "External System"
        }
            // evidence: cmd/cindex/cindex.go:142 (filepath.Walk); cmd/csearch/csearch.go:153 (os.Open); cmd/csweb/web.go:113 (os.Open)

        indexFile = softwareSystem "Trigram Index File" "On-disk index database named by $CSEARCHINDEX or $HOME/.csearchindex; written by cindex, read by csearch/csweb" {
            tags "External System,Data Store"
        }
            // evidence: index/read.go:666-668 (index.File() reads $CSEARCHINDEX); cmd/cindex/cindex.go:22 (usage names $CSEARCHINDEX/$HOME/.csearchindex)

        zipArchives = softwareSystem "Zip Archives" ".zip archives whose members are searched like ordinary files" {
            tags "External System"
        }
            // evidence: cmd/csearch/csearch.go:163 (zip.OpenReader); cmd/csweb/web.go:123 (zip.OpenReader)

        developer -> codeSearch "Builds and updates the index, then searches code from the CLI (cindex / csearch / cgrep)" "CLI"
            // evidence: cmd/cindex/cindex.go:19; cmd/csearch/csearch.go:21; cmd/cgrep/cgrep.go:17

        webUser -> codeSearch "Queries code search and browses matching files in a browser" "HTTP"
            // evidence: cmd/csweb/web.go:33-36

        codeSearch -> fileSystem "Reads source files to index and to grep (cindex walks trees; csearch/csweb open matched files; cgrep reads stdin/files)" "File I/O"
            // evidence: cmd/cindex/cindex.go:142; cmd/csearch/csearch.go:153; cmd/csweb/web.go:113; cmd/cgrep/cgrep.go:70

        codeSearch -> indexFile "Writes/merges the index file (cindex) and opens/queries it (csearch, csweb)" "File I/O"
            // evidence: cmd/cindex/cindex.go:166,170; cmd/csearch/csearch.go:112; cmd/csweb/web.go:78; index/read.go:667

        codeSearch -> zipArchives "Searches members of .zip archives (csearch, csweb)" "archive/zip"
            // evidence: cmd/csearch/csearch.go:163; cmd/csweb/web.go:123

        // ================= L2 — Containers =================

        cindex = container codeSearch "cindex" "CLI that builds and updates the on-disk trigram index: AddRoots, filepath.Walk, AddFile, Flush, Merge with master unless -reset; modes -list/-check/-reset/-stats" "Go CLI"
            // evidence: cmd/cindex/cindex.go:19 (usage), 61-67 (flags), 139 (AddRoots), 142 (Walk), 157 (AddFile), 166 (Flush), 170 (Merge)

        csearch = container codeSearch "csearch" "CLI that greps the built index: RegexpQuery posting query, then line-oriented grep of matching files including .zip members; exit 1 on no match" "Go CLI"
            // evidence: cmd/csearch/csearch.go:21 (usage), 107 (RegexpQuery), 112 (Open), 116-118 (PostingQuery), 153 (os.Open), 163 (zip.OpenReader), 197 (os.Exit(1))

        cgrep = container codeSearch "cgrep" "Standalone grep-style CLI that searches stdin or named files directly without the index" "Go CLI"
            // evidence: cmd/cgrep/cgrep.go:17 (usage), 70 (g.Reader(os.Stdin, ...)); imports only regexp (cmd/cgrep/cgrep.go:14)

        csweb = container codeSearch "csweb" "Local web UI on http://localhost:2473: search box (q + filename filter f), HTML results, /show/ line-numbered file/dir viewer, embedded static assets" "Go + net/http + go:embed"
            // evidence: cmd/csweb/web.go:33 (route /), 34 (/_static/), 35 (/show/), 36 (listen localhost:2473), 39 (go:embed)

        indexEngine = container codeSearch "index engine" "Trigram index engine: external-memory writer with k-way merge, mmap reader with posting queries, RegexpQuery planner, path prefix-compression, gamma-coded deltas, index checker, OS mmap wrappers" "Go library"
            // evidence: index/write.go:70 (Create); index/read.go:196 (Open), 561 (PostingQuery); index/regexp.go:333 (RegexpQuery); index/merge.go:51 (Merge); index/path.go:71 (NewPathWriter); index/delta.go:19 (deltaReader); index/check.go:14 (Check)

        regexpEngine = container codeSearch "regexp engine" "Grep-oriented regex engine: compile to byte program, DFA matcher with dstate cache, line-oriented Grep driver shared by cgrep/csearch/csweb" "Go library"
            // evidence: regexp/regexp.go:30 (Compile); regexp/utf.go:21 (toByteProg); regexp/match.go:51 (dstate), 213 (computeNext), 283 (match), 355 (Grep), 432 (Grep.Reader)

        sparseSet = container codeSearch "sparse set" "Sparse set of uint32 via dense/sparse arrays: O(1) Add/Has membership and O(1) Reset; used as the trigram set" "Go library"
            // evidence: sparse/set.go:21 (NewSet), 39 (Add), 50 (Has), 58 (Dense)

        developer -> cindex "Runs to build/update the index" "CLI"
            // evidence: cmd/cindex/cindex.go:19
        developer -> csearch "Runs to search the index" "CLI"
            // evidence: cmd/csearch/csearch.go:21
        developer -> cgrep "Runs for index-free grep over stdin/files" "CLI"
            // evidence: cmd/cgrep/cgrep.go:17
        webUser -> csweb "Opens http://localhost:2473 in a browser" "HTTP"
            // evidence: cmd/csweb/web.go:36

        cindex -> indexEngine "Create + AddRoots + AddFile + Flush + Merge" "Go import"
            // evidence: cmd/cindex/cindex.go:16 (import), 139, 157, 166, 170
        cindex -> fileSystem "filepath.Walk over the given roots, skipping hidden/temp files" "File I/O"
            // evidence: cmd/cindex/cindex.go:142
        cindex -> indexFile "Passes the $CSEARCHINDEX path; merged index is renamed over the master" "File I/O"
            // evidence: cmd/cindex/cindex.go:170; index/read.go:666-668

        csearch -> indexEngine "index.Open + index.RegexpQuery + ix.PostingQuery" "Go import"
            // evidence: cmd/csearch/csearch.go:17 (import), 107, 112, 116-118
        csearch -> regexpEngine "regexp.Grep over candidate files (g.Reader per file)" "Go import"
            // evidence: cmd/csearch/csearch.go:18 (import), 64 (g := regexp.Grep{...}), 150/180/187 (g.Reader)
        csearch -> fileSystem "os.Open of each matched file" "File I/O"
            // evidence: cmd/csearch/csearch.go:153
        csearch -> zipArchives "zip.OpenReader on the .zip part of an index name" "archive/zip"
            // evidence: cmd/csearch/csearch.go:163

        csweb -> indexEngine "index.RegexpQuery + index.Open + ix.PostingQuery" "Go import"
            // evidence: cmd/csweb/web.go:24 (import), 72, 78, 80
        csweb -> regexpEngine "regexp.Grep with HTML:true renders results" "Go import"
            // evidence: cmd/csweb/web.go:25 (import), 49
        csweb -> fileSystem "os.Open while iterating matches and rendering files" "File I/O"
            // evidence: cmd/csweb/web.go:113
        csweb -> zipArchives "zip.OpenReader for .zip members" "archive/zip"
            // evidence: cmd/csweb/web.go:123

        cgrep -> regexpEngine "regexp.Grep over stdin or named files" "Go import"
            // evidence: cmd/cgrep/cgrep.go:14 (import), 70 (g.Reader(os.Stdin, ...))

        indexEngine -> sparseSet "sparse.NewSet(1<<24) trigram set inside IndexWriter" "Go import"
            // evidence: index/write.go:19 (import), 72 (sparse.NewSet)
        regexpEngine -> sparseSet "sparse.Set instruction queues inside the matcher" "Go import"
            // evidence: regexp/match.go:20 (import), 34 (q sparse.Set), 151, 161, 191
        indexEngine -> indexFile "Reads/writes the on-disk index: buffered writer, mmap reader, merge into a third file" "File I/O"
            // evidence: index/read.go:197 (mmap); index/write.go:70 (Create); index/merge.go:51 (Merge)

        // ================= L3 — Components =================
        // Deep dive into the three most substantive containers (LOC + centrality):
        // index engine (4366), regexp engine (1417), csweb (286).
        // The three CLIs are thin entry points; their behavior is already visible at L2.

        indexWriter = component indexEngine "IndexWriter" "External-memory index builder: Create(file) opens temp buffers, add() extracts 24-bit trigrams, flush at 64MB of posting entries" "Go"
            // evidence: index/write.go:70 (Create), 67 (npost = 64 << 20 / 8), 215-226 (add trigram loop), 72 (sparse.NewSet(1<<24))

        indexReader = component indexEngine "Index reader" "Opens the index via mmap and answers posting queries over gamma-coded lists" "Go"
            // evidence: index/read.go:196-197 (Open + mmap), 501 (PostingList), 515 (PostingAnd), 537 (PostingOr), 561 (PostingQuery), 667 (File())

        regexpQueryPlanner = component indexEngine "RegexpQuery planner" "Converts a parsed regexp (syntax.Regexp) into a conservative trigram Query (QAll/QNone/QAnd/QOr) that over-approximates matches" "Go"
            // evidence: index/regexp.go:333 (func RegexpQuery(re *syntax.Regexp) *Query)

        indexMerger = component indexEngine "Index merger" "Merges two on-disk indexes into a third file (Merge(dst, src1, src2))" "Go"
            // evidence: index/merge.go:51 (func Merge), 60-61 (names1.Path()/names2.Path())

        pathCodec = component indexEngine "Path codec" "Prefix-compressed file-name lists: NewPathWriter + Path write/read" "Go"
            // evidence: index/path.go:71 (NewPathWriter), 84 (Write)

        deltaCodec = component indexEngine "Delta codec" "Gamma-coded delta reader/writer for posting lists" "Go"
            // evidence: index/delta.go:19 (deltaReader.init)

        indexChecker = component indexEngine "Index checker" "Integrity check of an open index" "Go"
            // evidence: index/check.go:14 (func (ix *Index) Check() error)

        mmapWrapper = component indexEngine "mmap wrapper" "OS-specific memory mapping of the index file (mmap_linux/bsd/windows)" "Go"
            // evidence: index/mmap_linux.go:13 (func mmapFile); index/mmap_bsd.go; index/mmap_windows.go

        indexWriter -> pathCodec "Writes file names through NewPathWriter/Path.Write" "Go"
            // evidence: index/write.go:49 (names *PathWriter), 81 (NewPathWriter), 287 (MakePath), 388 (names.Write(Path(name)))
        indexWriter -> deltaCodec "Posting data passes through deltaWriter" "Go"
            // evidence: index/write.go:832 (delta deltaWriter)
        indexWriter -> sparseSet "Trigram set is sparse.NewSet(1<<24)" "Go"
            // evidence: index/write.go:72
        indexMerger -> pathCodec "Reads name lists of both sources via Path()" "Go"
            // evidence: index/merge.go:60-61
        indexReader -> mmapWrapper "Open maps the index file into memory" "Go"
            // evidence: index/read.go:197
        indexReader -> regexpQueryPlanner "PostingQuery interprets the Query built by RegexpQuery" "Go"
            // evidence: index/read.go:561 (PostingQuery(q *Query)); index/regexp.go:333

        regexpApi = component regexpEngine "Regexp API" "Compile(expr): syntax.Parse (Perl flags), Simplify, syntax.Compile, toByteProg, matcher init" "Go"
            // evidence: regexp/regexp.go:30-49 (func Compile)

        byteProgCompiler = component regexpEngine "Byte-program compiler" "toByteProg converts rune instructions into byte-range instructions for UTF-8 matching" "Go"
            // evidence: regexp/utf.go:21 (func toByteProg(prog *syntax.Prog) error)

        dfaMatcher = component regexpEngine "DFA matcher" "match/matchString run the byte program with a dstate cache; sparse.Set queues hold candidate instructions" "Go"
            // evidence: regexp/match.go:51 (type dstate), 213 (computeNext), 283 (match), 315 (matchString), 34 (q sparse.Set)

        grepDriver = component regexpEngine "Grep driver" "Line-oriented grep (flags L/C/N/H/V, HTML output, pre/post context, limit) shared by cgrep/csearch/csweb; Reader drives a stream" "Go"
            // evidence: regexp/match.go:355-373 (type Grep), 432 (func (g *Grep) Reader)

        syntaxUtils = component regexpEngine "Syntax utilities" "cleanClass/appendRange/appendFoldedRange and progString/dumpProg copied from Go's regexp/syntax" "Go"
            // evidence: regexp/copy.go:5 (copied from Go's regexp/syntax), 21 (cleanClass), 52 (appendRange), 144 (progString)

        regexpApi -> byteProgCompiler "Compile calls toByteProg on the compiled program" "Go"
            // evidence: regexp/regexp.go:40
        regexpApi -> dfaMatcher "Compile initializes the matcher with the program (r.m.init)" "Go"
            // evidence: regexp/regexp.go:47
        dfaMatcher -> sparseSet "Instruction queues are sparse.Set" "Go"
            // evidence: regexp/match.go:34, 151, 161, 191
        grepDriver -> dfaMatcher "Grep holds a Regexp whose matcher does the per-line matching" "Go"
            // evidence: regexp/match.go:356 (Regexp *Regexp field); regexp/regexp.go:47

        httpServer = component csweb "HTTP server bootstrap" "Routes /, /_static/, /show/ and listens on localhost:2473" "Go"
            // evidence: cmd/csweb/web.go:32-36 (func main)

        homeHandler = component csweb "home handler (search)" "Reads q and f form values, runs the index posting query, greps matched files and .zip members, emits HTML" "Go"
            // evidence: cmd/csweb/web.go:42 (func home), 49 (regexp.Grep{HTML:true}), 72 (RegexpQuery), 78 (Open), 80 (PostingQuery), 113 (os.Open), 123 (zip.OpenReader), 140/147 (g.Reader)

        showHandler = component csweb "show handler (file viewer)" "Renders a file or directory under /show/ as line-numbered HTML; serveDir/serveFile/isText helpers" "Go"
            // evidence: cmd/csweb/web.go:173 (func show), 221 (serveDir), 235 (serveFile), 258 (isText)

        staticAssets = component csweb "static assets" "go:embed _static (viewer.js, viewer.css) served at /_static/" "Go embed"
            // evidence: cmd/csweb/web.go:34 (http.FileServer(http.FS(static))), 39 (//go:embed _static)

        homeHandler -> indexEngine "RegexpQuery + Open + PostingQuery" "Go"
            // evidence: cmd/csweb/web.go:72, 78, 80
        homeHandler -> regexpEngine "regexp.Grep{HTML:true} renders result lines" "Go"
            // evidence: cmd/csweb/web.go:49
        homeHandler -> fileSystem "os.Open of matched files during iteration" "File I/O"
            // evidence: cmd/csweb/web.go:113
        homeHandler -> zipArchives "zip.OpenReader for archive members" "archive/zip"
            // evidence: cmd/csweb/web.go:123
        httpServer -> staticAssets "Serves /_static/ from the embedded FS" "Go"
            // evidence: cmd/csweb/web.go:34, 39

    }

    views {

        systemContext codeSearch "L1_Context" "Code Search - system context (users and external systems)" {
            include *
            autolayout lr
        }

        container codeSearch "L2_Containers" "Code Search - containers (4 CLIs/web + 3 Go libraries)" {
            include *
            autolayout tb
        }

        component indexEngine "L3_index" "index engine - components" {
            include *
            autolayout tb
        }

        component regexpEngine "L3_regexp" "regexp engine - components" {
            include *
            autolayout tb
        }

        component csweb "L3_csweb" "csweb - components" {
            include *
            autolayout tb
        }

    }

}
