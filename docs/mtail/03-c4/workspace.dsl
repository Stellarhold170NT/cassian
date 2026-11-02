// workspace.dsl — Structurizr DSL: C4 model of google/mtail
// Subject: mtail | PIN: 4c7e0e1174ac1ead032efe28d86428bbbe0ae145 (branch main)
// Inputs: reports/mtail/gm-02-module-map.md (18-item universe, gate-APPROVED).
// reports/mtail/gm-01-cartography.md was not present when this node ran; the L1 cut is
// grounded directly on this pinned clone instead (see gm-03-c4.md, "Modeling decisions").
// Every element and relationship below carries an `// evidence:` line pointing at a
// grep-verified file:line in the pinned clone. Elements without evidence are not modeled.
// NOTE: not validated with structurizr-cli (no java/structurizr-cli in sandbox) —
// validate: SKIPPED (tool missing); Mermaid fallback in diagrams.mmd.

workspace {

    name "mtail"
    description "Extract internal monitoring data (metrics) from application logs for collection into a time-series database"

    model {

        // ================= L1 — System Context =================

        operator = person "Operator" "Runs the mtail binary from a terminal with -progs/-logs/-port flags; watches the HTTP status pages"
            // evidence: cmd/mtail/main.go:41 (port), :44 (progs), :89 (logs), :102 (func main), :232 (mtail.New), :238 (m.Run)

        scraper = softwareSystem "Prometheus-compatible scraper" "Pulls metrics from mtail's /metrics endpoint (Prometheus exposition) and the debug pages" {
            tags "External System"
        }
            // evidence: internal/mtail/mtail.go:120 (/metrics via promhttp.HandlerFor); README.md:29 (exported as JSON or Prometheus format)

        pushTargets = softwareSystem "Push TSDB targets" "Time-series backends mtail pushes metrics to on an interval: Graphite over TCP, StatsD over UDP, CollectD over a unix socket" {
            tags "External System"
        }
            // evidence: internal/exporter/export.go:119 (graphite tcp), :123 (statsd udp), :115 (collectd unix), :234 (StartMetricPush)

        mtailSystem = softwareSystem "mtail" "Tails application logs, runs mtail programs (.mtail) that transform log lines into metrics, and exports those metrics"
            // evidence: README.md:11 ("a tool for extracting metrics from application logs to be exported"); go.mod:1 (module github.com/google/mtail)

        logSources = softwareSystem "Log Sources" "Log files, named pipes, unix/tcp/udp sockets and stdin that mtail tails; rotation and truncation are followed" {
            tags "External System"
        }
            // evidence: internal/tailer/tail.go:29 (LogPathPatterns); internal/tailer/logstream/logstream.go:78-84 (unixgram/unix/tcp/udp schemes), :89-90 (stdin)

        programFiles = softwareSystem "Program Files" "Directory of .mtail program sources loaded by the runtime; reloaded on SIGHUP" {
            tags "External System,Data Store"
        }
            // evidence: cmd/mtail/main.go:44 (-progs directory flag); internal/runtime/runtime.go:49 (LoadAllPrograms), :319-331 (SIGHUP reload goroutine)

        operator -> mtailSystem "Runs the mtail binary with CLI flags" "CLI"
            // evidence: cmd/mtail/main.go:41,44,89,102

        scraper -> mtailSystem "Scrapes /metrics and the debug endpoints (/, /debug/vars, /progz, zpages)" "HTTP pull"
            // evidence: internal/mtail/mtail.go:107,117,119,120,123

        mtailSystem -> logSources "Tails files, fifos, sockets and stdin; follows rotation/truncation" "File/socket I/O"
            // evidence: internal/tailer/tail.go:186,289; internal/tailer/logstream/logstream.go:75-112

        mtailSystem -> programFiles "Loads .mtail programs at startup; reloads all on SIGHUP" "File I/O"
            // evidence: internal/runtime/runtime.go:49,104,319-331,334

        mtailSystem -> pushTargets "Pushes metrics to Graphite/StatsD/CollectD each push interval" "TCP/UDP/unix push"
            // evidence: internal/exporter/export.go:115-123,212-216,234

        // ================= L2 — Containers =================
        // 18 containers = the 18 gm-02 items (4 CLIs + 14 Go libraries). The 39 item-level
        // import edges were re-verified on this clone (grep of non-test imports over each
        // package's own files); see gm-03-c4.md for the m05 datum/code drift note vs gm-02.

        mtailCli = container mtailSystem "mtail (cmd/mtail)" "Entry binary: ~40 CLI flags, maps flags to server options, builds metrics.NewStore + mtail.New + m.Run, traps SIGINT/SIGTERM, -one_shot stdout dump" "Go CLI"
            // evidence: cmd/mtail/main.go:41-51 (flags), :102 (main), :162 (signal.Notify), :232 (mtail.New), :238 (m.Run)

        mdot = container mtailSystem "mdot (cmd/mdot)" "CLI that renders a .mtail program as a graphviz dot graph (parse, check, ast.Walk); optional HTTP SVG mode" "Go CLI"
            // evidence: cmd/mdot/main.go:134 (makeDot), :139 (parser.Parse), :143 (checker.Check), :149 (ast.Walk), :154 (main)

        mgen = container mtailSystem "mgen (cmd/mgen)" "Generates random mtail programs from a grammar table for fuzz testing" "Go CLI"
            // evidence: cmd/mgen/main.go:4 (doc comment), :26 (grammar table), :144 (main)

        mfmt = container mtailSystem "mfmt (cmd/mfmt)" "Formats mtail programs: parse, type-check, re-print via parser.Unparser" "Go CLI"
            // evidence: cmd/mfmt/main.go:25 (main), :36 (parser.Parse), :40 (checker.Check), :44 (parser.Unparser)

        server = container mtailSystem "mtail server (internal/mtail)" "Server: the orchestration hub — wires tailer, runtime, exporter and the HTTP status server around a shared lines channel and metrics.Store" "Go library"
            // evidence: internal/mtail/mtail.go:31 (Server struct), :176 (New), :238 (Run)

        runtimeC = container mtailSystem "program runtime (internal/runtime)" "Loads .mtail program files, compiles them via the compiler, starts one VM per program, feeds log lines in, unloads/reloads programs" "Go library"
            // evidence: internal/runtime/runtime.go:215 (Runtime struct), :250 (New), :141 (CompileAndRun), :351 (UnloadProgram)

        compiler = container mtailSystem "compiler (internal/runtime/compiler)" "Front-end compiling mtail programs to bytecode: parser, checker, codegen, optimiser plus ast/symbol/types/position/errors support packages" "Go library"
            // evidence: internal/runtime/compiler/compiler.go:89 (Compile pipeline), :94,104,114,125,136 (phases)

        vm = container mtailSystem "bytecode VM (internal/runtime/vm)" "Interprets compiled code.Object programs: ProcessLogLine fetch-decode-execute loop updating metrics" "Go library"
            // evidence: internal/runtime/vm/vm.go:962 (ProcessLogLine), :993 (New), :336 (execute)

        bytecode = container mtailSystem "bytecode (internal/runtime/code)" "Opcode set, Instr and code.Object — the compiler/VM contract artifact" "Go library"
            // evidence: internal/runtime/code/opcodes.go:7 (Opcode), object.go:13 (Object)

        tailer = container mtailSystem "tailer (internal/tailer)" "Polls filesystem glob patterns for log sources and spawns a LogStream per matched path, pumping lines into the shared channel" "Go library"
            // evidence: internal/tailer/tail.go:30 (Tailer struct), :119 (New), :186 (AddPattern), :289 (pollLogPattern)

        logstream = container mtailSystem "logstream (internal/tailer/logstream)" "Turns one pathname (file, fifo, unix/tcp/udp socket, stdin) into a stream of LogLine with rotation/truncation handling" "Go library"
            // evidence: internal/tailer/logstream/logstream.go:35 (LogStream interface), :64 (New), :78-84 (scheme dispatch)

        exporter = container mtailSystem "exporter (internal/exporter)" "Reads the metrics.Store and exposes metrics: Prometheus collector, varz JSON, and periodic push to Graphite/StatsD/CollectD" "Go library"
            // evidence: internal/exporter/export.go:32 (Exporter struct), :91 (New), :234 (StartMetricPush)

        metricsStore = container mtailSystem "metrics store (internal/metrics)" "Central Store (name → metrics) with thread-safe add/find/delete, GC and JSON serialization; Metric models kind/type/labels" "Go library"
            // evidence: internal/metrics/store.go:19 (Store struct), :26 (NewStore)

        datum = container mtailSystem "metric datum (internal/metrics/datum)" "Datum value interface + Int/Float/String/Buckets implementations stamped with atomic timestamps" "Go library"
            // evidence: internal/metrics/datum/datum.go:15 (Datum interface), :55 (NewInt), :70 (NewBuckets)

        logline = container mtailSystem "logline (internal/logline)" "LogLine struct — one log line (context, filename, text) exchanged between tailer/runtime/VM" "Go library"
            // evidence: internal/logline/logline.go:9 (LogLine struct), :17 (New)

        waker = container mtailSystem "waker (internal/waker)" "Waker wake-up channel interface; timed (production) and test implementations" "Go library"
            // evidence: internal/waker/waker.go:7 (Waker interface), timedwaker.go:22 (NewTimed)

        testutil = container mtailSystem "testutil (internal/testutil)" "Shared test helpers: expvar assertions with deadline, polling, temp files/dirs" "Go test library"
            // evidence: internal/testutil/expvar.go:16 (TestGetExpvar), timeout.go:17 (DoOrTimeout)

        golden = container mtailSystem "golden (internal/mtail/golden)" "Golden-file reader that parses expected metric output into metrics.MetricSlice for tests" "Go test library"
            // evidence: internal/mtail/golden/reader.go:20 (varRe), :23 (ReadTestData)

        operator -> mtailCli "Runs mtail" "CLI"
            // evidence: cmd/mtail/main.go:102
        operator -> mdot "Renders a program graph" "CLI"
            // evidence: cmd/mdot/main.go:134,154
        operator -> mgen "Generates fuzz programs" "CLI"
            // evidence: cmd/mgen/main.go:4,144
        operator -> mfmt "Formats programs" "CLI"
            // evidence: cmd/mfmt/main.go:25
        scraper -> server "Scrapes /metrics, /, /debug/vars, /progz, zpages" "HTTP"
            // evidence: internal/mtail/mtail.go:107,117,119,120,123

        mtailCli -> server "mtail.New(ctx, store, opts...) + m.Run()" "Go import"
            // evidence: cmd/mtail/main.go:20 (import), :232, :238
        mtailCli -> exporter "exporter.Option mapping; -one_shot prometheus write" "Go import"
            // evidence: cmd/mtail/main.go:18 (import), :50-51 (one_shot flags)
        mtailCli -> metricsStore "store := metrics.NewStore()" "Go import"
            // evidence: cmd/mtail/main.go:19 (import)
        mtailCli -> waker "waker.Option mapping" "Go import"
            // evidence: cmd/mtail/main.go:21 (import)

        mdot -> server "mtail.FaviconHandler for the HTTP SVG mode" "Go import"
            // evidence: cmd/mdot/main.go:32 (import)
        mdot -> compiler "parser.Parse + checker.Check + ast.Walk" "Go import"
            // evidence: cmd/mdot/main.go:33-35 (imports), :139, :143, :149
        mgen -> compiler "parser.Dictionary() grammar tokens" "Go import"
            // evidence: cmd/mgen/main.go:12 (import), :139
        mfmt -> compiler "parser.Parse + checker.Check + Unparser" "Go import"
            // evidence: cmd/mfmt/main.go:16-17 (imports), :36, :40, :44

        server -> runtimeC "initRuntime: runtime.New(m.lines, &m.wg, m.programPath, m.store, ...)" "Go import"
            // evidence: internal/mtail/mtail.go:20 (import), :65-66
        server -> exporter "initExporter: exporter.New(m.ctx, m.store, ...)" "Go import"
            // evidence: internal/mtail/mtail.go:17 (import), :71-72
        server -> tailer "initTailer: tailer.New(m.ctx, &m.wg, m.lines, ...)" "Go import"
            // evidence: internal/mtail/mtail.go:21 (import), :90-91
        server -> metricsStore "Server holds the *metrics.Store passed to New" "Go import"
            // evidence: internal/mtail/mtail.go:19 (import), :178 (store: store)
        server -> logline "lines chan *logline.LogLine shared by tailer/runtime" "Go import"
            // evidence: internal/mtail/mtail.go:18 (import), :179 (lines: make(chan *logline.LogLine))
        server -> datum "test helpers construct datum values" "Go import (test)"
            // evidence: internal/mtail/testing.go:17 (import)
        server -> testutil "TestServer helpers use testutil" "Go import (test)"
            // evidence: internal/mtail/testing.go:18 (import)
        server -> waker "logPatternPollWaker option; test waker" "Go import"
            // evidence: internal/mtail/options.go:17 (import), testing.go:19

        runtimeC -> compiler "r.c built with compiler.New(r.cOpts...)" "Go import"
            // evidence: internal/runtime/runtime.go:25 (import), :270 (compiler.New)
        runtimeC -> vm "v := vm.New(name, obj, ...)" "Go import"
            // evidence: internal/runtime/runtime.go:26 (import), :167 (vm.New)
        runtimeC -> metricsStore "New takes store *metrics.Store" "Go import"
            // evidence: internal/runtime/runtime.go:24 (import), :250
        runtimeC -> logline "New takes lines <-chan *logline.LogLine" "Go import"
            // evidence: internal/runtime/runtime.go:23 (import), :250

        compiler -> metricsStore "metrics.NewMetric calls in codegen/checker/parser/ast" "Go import"
            // evidence: internal/runtime/compiler/codegen/codegen.go:13, checker/checker.go:13, parser/parser.go:15, parser/sexp.go:11, parser/unparser.go:11, ast/ast.go:10 (imports)
        compiler -> datum "datum constructors for metric values" "Go import"
            // evidence: internal/runtime/compiler/codegen/codegen.go:14 (import)
        compiler -> bytecode "produces *code.Object" "Go import"
            // evidence: internal/runtime/compiler/compiler.go:11 (import), codegen/codegen.go:15

        vm -> logline "ProcessLogLine(_ context.Context, line *logline.LogLine)" "Go import"
            // evidence: internal/runtime/vm/vm.go:24 (import), :962
        vm -> metricsStore "execute() updates *metrics.Metric per opcode" "Go import"
            // evidence: internal/runtime/vm/vm.go:25 (import)
        vm -> datum "datum values updated by Set/Inc/Next opcodes" "Go import"
            // evidence: internal/runtime/vm/vm.go:26 (import)
        vm -> bytecode "fetch-decode-execute over code.Object" "Go import"
            // evidence: internal/runtime/vm/vm.go:27 (import), :993

        bytecode -> metricsStore "Object.Metrics []*metrics.Metric" "Go import"
            // evidence: internal/runtime/code/object.go:9 (import), :13

        tailer -> logstream "TailPath creates one logstream.LogStream per matched file" "Go import"
            // evidence: internal/tailer/tail.go:21 (import), :256-286 (TailPath)
        tailer -> logline "lines chan<- *logline.LogLine" "Go import"
            // evidence: internal/tailer/tail.go:20 (import)
        tailer -> waker "pattern poll driven by waker.Waker" "Go import"
            // evidence: internal/tailer/tail.go:22 (import)
        tailer -> logSources "AddPattern + pollLogPattern glob polling" "File I/O"
            // evidence: internal/tailer/tail.go:186, :289

        logstream -> logline "emits *logline.LogLine to the tailer channel" "Go import"
            // evidence: internal/tailer/logstream/logstream.go:21 (import; also reader.go:13, filestream.go:16)
        logstream -> waker "Wake() when the stream is idle" "Go import"
            // evidence: internal/tailer/logstream/logstream.go:22 (import)
        logstream -> logSources "file/fifo/unix/tcp/udp/stdin stream readers" "File/socket I/O"
            // evidence: internal/tailer/logstream/logstream.go:75-112

        exporter -> metricsStore "reads *metrics.Store (Collect: e.store.Range)" "Go import"
            // evidence: internal/exporter/export.go:22 (import), :91; prometheus.go:31, :36
        exporter -> datum "formats datum values for graphite" "Go import"
            // evidence: internal/exporter/prometheus.go:14, graphite.go:16 (imports)
        exporter -> pushTargets "metric push to graphite/statsd/collectd targets" "TCP/UDP/unix push"
            // evidence: internal/exporter/export.go:115-123, :234

        metricsStore -> datum "Metric values are datum.Datum" "Go import"
            // evidence: internal/metrics/metric.go:18 (import)
        testutil -> logline "OpenLogFile test helper produces LogLines" "Go import (test)"
            // evidence: internal/testutil/lines.go:10 (import)
        golden -> metricsStore "parses golden files into metrics.MetricSlice" "Go import (test)"
            // evidence: internal/mtail/golden/reader.go:16 (import)
        golden -> datum "kind → datum constructors" "Go import (test)"
            // evidence: internal/mtail/golden/reader.go:17 (import)

        runtimeC -> programFiles "LoadAllPrograms/LoadProgram read .mtail sources; SIGHUP reload" "File I/O"
            // evidence: internal/runtime/runtime.go:49, :104, :319-331

        // ================= L3 — Components =================
        // Deep dives into the three most substantive containers (LOC + centrality):
        // compiler (10116 LOC, 10 subpackages), mtail server (4463, the hub imported by
        // cmd/mtail and importing 8 items), runtime (1871, binds compiler+vm to the log flow).
        // vm/tailer/logstream/exporter behavior is already fully expressed at L2.

        compPipeline = component compiler "Compiler pipeline" "Compile(name, input): parser.Parse → opt.Optimise → checker.Check → opt.Optimise → codegen.CodeGen" "Go"
            // evidence: internal/runtime/compiler/compiler.go:89, :94, :104, :114, :125, :136

        compParser = component compiler "Parser" "Parse(name, input) → ast.Node; goyacc-generated parser + lexer, sexp reader, unparser" "Go"
            // evidence: internal/runtime/compiler/parser/driver.go:34 (func Parse), lexer.go:16 (position), parser.go:15 (metrics)

        compAst = component compiler "AST" "Program node tree with the ast.Walk visitor" "Go"
            // evidence: internal/runtime/compiler/ast/walk.go:30 (func Walk)

        compChecker = component compiler "Type checker" "Check(node, maxRegexpLength, maxRecursionDepth) → typed AST" "Go"
            // evidence: internal/runtime/compiler/checker/checker.go:45 (func Check)

        compCodegen = component compiler "Code generator" "CodeGen(name, ast) → *code.Object" "Go"
            // evidence: internal/runtime/compiler/codegen/codegen.go:36 (func CodeGen)

        compOpt = component compiler "Optimiser" "Optimise(n ast.Node) → rewritten ast.Node (run twice in the pipeline)" "Go"
            // evidence: internal/runtime/compiler/opt/opt.go:17 (func Optimise)

        compSymbol = component compiler "Symbol table" "Symbol entries for program variables" "Go"
            // evidence: internal/runtime/compiler/symbol/symtab.go:42 (type Symbol)

        compTypes = component compiler "Type algebra" "Type interface for mtail language types" "Go"
            // evidence: internal/runtime/compiler/types/types.go:17 (type Type interface)

        compPosition = component compiler "Positions" "Position struct locating tokens in the source" "Go"
            // evidence: internal/runtime/compiler/position/position.go:12 (type Position)

        compErrors = component compiler "Compile errors" "ErrorList of compileError with positions" "Go"
            // evidence: internal/runtime/compiler/errors/errors.go:24 (type ErrorList)

        compPipeline -> compParser "parser.Parse" "Go"
            // evidence: internal/runtime/compiler/compiler.go:94
        compPipeline -> compOpt "opt.Optimise (before and after type-check)" "Go"
            // evidence: internal/runtime/compiler/compiler.go:104, :125
        compPipeline -> compChecker "checker.Check" "Go"
            // evidence: internal/runtime/compiler/compiler.go:114
        compPipeline -> compCodegen "codegen.CodeGen" "Go"
            // evidence: internal/runtime/compiler/compiler.go:136
        compParser -> compAst "returns ast.Node" "Go"
            // evidence: internal/runtime/compiler/parser/driver.go:27, :34
        compParser -> compPosition "token positions" "Go"
            // evidence: internal/runtime/compiler/parser/lexer.go:16, tokens.go:9
        compParser -> compErrors "error accumulation" "Go"
            // evidence: internal/runtime/compiler/parser/driver.go:28
        compChecker -> compAst "walks the AST" "Go"
            // evidence: internal/runtime/compiler/checker/checker.go:14
        compChecker -> compSymbol "symbol resolution" "Go"
            // evidence: internal/runtime/compiler/checker/checker.go:17
        compChecker -> compTypes "type assignment" "Go"
            // evidence: internal/runtime/compiler/checker/checker.go:18
        compCodegen -> compSymbol "reads symbol table" "Go"
            // evidence: internal/runtime/compiler/codegen/codegen.go:20
        compCodegen -> compTypes "reads inferred types" "Go"
            // evidence: internal/runtime/compiler/codegen/codegen.go:21
        compCodegen -> compPosition "source line attribution" "Go"
            // evidence: internal/runtime/compiler/codegen/codegen.go:19
        compOpt -> compAst "rewrites nodes" "Go"
            // evidence: internal/runtime/compiler/opt/opt.go:10
        compAst -> compSymbol "node symbols" "Go"
            // evidence: internal/runtime/compiler/ast/ast.go:12
        compAst -> compTypes "node types" "Go"
            // evidence: internal/runtime/compiler/ast/ast.go:13
        compAst -> compPosition "node positions" "Go"
            // evidence: internal/runtime/compiler/ast/ast.go:11
        compSymbol -> compTypes "symbols carry types" "Go"
            // evidence: internal/runtime/compiler/symbol/symtab.go:11
        compErrors -> compPosition "errors reference positions" "Go"
            // evidence: internal/runtime/compiler/errors/errors.go:10

        srvCore = component server "Server core" "Server struct, New() building the shared lines channel + prometheus registry, Run() awaiting termination" "Go"
            // evidence: internal/mtail/mtail.go:31 (struct), :176 (New), :179 (lines channel), :182 (registry), :238 (Run)

        srvWiring = component server "Sub-system init" "initRuntime/initExporter/initTailer/initHTTPServer called by New in order" "Go"
            // evidence: internal/mtail/mtail.go:65, :71, :90, :96 (defs); :209, :213, :216, :220 (call sites)

        srvOptions = component server "Option layer" "Option interface + ProgramPath, LogPathPatterns, BindAddress, ... applied via SetOption" "Go"
            // evidence: internal/mtail/options.go:22 (interface), :29 (ProgramPath), :38 (LogPathPatterns), :58 (BindAddress); mtail.go:227 (SetOption)

        srvHttp = component server "HTTP status server" "mux routes: /, /metrics (promhttp), /debug/vars (expvar), /progz, zpages" "Go net/http"
            // evidence: internal/mtail/mtail.go:105 (mux), :107, :117, :119, :120, :123

        srvTest = component server "TestServer harness" "TestServer wrapping Server for integration tests with a test waker" "Go test"
            // evidence: internal/mtail/testing.go:24 (type TestServer), :67 (streamWaker)

        srvCore -> srvWiring "New calls the four init steps" "Go"
            // evidence: internal/mtail/mtail.go:209, :213, :216, :220
        srvWiring -> runtimeC "runtime.New" "Go"
            // evidence: internal/mtail/mtail.go:66
        srvWiring -> exporter "exporter.New" "Go"
            // evidence: internal/mtail/mtail.go:72
        srvWiring -> tailer "tailer.New" "Go"
            // evidence: internal/mtail/mtail.go:91
        srvOptions -> srvCore "SetOption applies options to the Server" "Go"
            // evidence: internal/mtail/mtail.go:227; options.go:22

        rtLoader = component runtimeC "Program loader" "LoadAllPrograms/LoadProgram walk the -progs directory and read .mtail files" "Go"
            // evidence: internal/runtime/runtime.go:49 (LoadAllPrograms), :104 (LoadProgram)

        rtBridge = component runtimeC "Compile-and-run bridge" "CompileAndRun: hash-check → r.c.Compile → vm.New → register vmHandle; feeds lines to the VM" "Go"
            // evidence: internal/runtime/runtime.go:141 (CompileAndRun), :158 (r.c.Compile), :167 (vm.New), :200 (handles[name] = &vmHandle{...})

        rtHandles = component runtimeC "VM handle registry" "handles map (program name → vmHandle) guarded by handleMu; UnloadProgram closes a program's VM" "Go"
            // evidence: internal/runtime/runtime.go:226 (handleMu), :227 (handles map), :351 (UnloadProgram), :355 (close)

        rtReload = component runtimeC "Reload controller" "SIGHUP goroutine reloads all programs; initial LoadAllPrograms before New returns" "Go"
            // evidence: internal/runtime/runtime.go:319-331 (signal.Notify + loop), :327 (LoadAllPrograms), :334 (initial load)

        rtStatus = component runtimeC "Prog status page" "ProgzHandler renders per-program load/runtime state" "Go"
            // evidence: internal/runtime/httpstatus.go:95 (ProgzHandler)

        rtOptions = component runtimeC "Runtime options" "CompileOnly, ErrorsAbort, DumpAst/DumpAstTypes/DumpBytecode, SyslogUseCurrentYear, MaxRegexpLength..." "Go"
            // evidence: internal/runtime/options.go:18 (OverrideLocation), :26 (CompileOnly), :34 (ErrorsAbort), :42 (DumpAst), :58 (DumpBytecode)

        rtLoader -> rtBridge "LoadProgram calls CompileAndRun" "Go"
            // evidence: internal/runtime/runtime.go:126
        rtReload -> rtLoader "SIGHUP → LoadAllPrograms; initial load" "Go"
            // evidence: internal/runtime/runtime.go:327, :334
        rtBridge -> compiler "r.c.Compile(name, &buf)" "Go"
            // evidence: internal/runtime/runtime.go:158
        rtBridge -> vm "v := vm.New(name, obj, ...)" "Go"
            // evidence: internal/runtime/runtime.go:167
        rtBridge -> rtHandles "registers r.handles[name] = &vmHandle{...}" "Go"
            // evidence: internal/runtime/runtime.go:200
        rtOptions -> rtBridge "dumpBytecode option read in CompileAndRun" "Go"
            // evidence: internal/runtime/runtime.go:172 (r.dumpBytecode); options.go:58 (DumpBytecode)

    }

    views {

        systemContext mtailSystem "L1_Context" "mtail - system context (operator and external systems)" {
            include *
            autolayout lr
        }

        container mtailSystem "L2_Containers" "mtail - containers (4 CLIs + 14 Go libraries)" {
            include *
            autolayout tb
        }

        component compiler "L3_compiler" "compiler - components" {
            include *
            autolayout tb
        }

        component server "L3_server" "mtail server - components" {
            include *
            autolayout tb
        }

        component runtimeC "L3_runtime" "program runtime - components" {
            include *
            autolayout tb
        }

    }

}
