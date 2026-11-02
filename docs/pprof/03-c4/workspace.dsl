// Structurizr DSL - C4 model of google/pprof.
// Upstream PIN: dbd0ed30aa888a30e21ba83b9831ac0e80d41022 (branch main).
// Evidence tree: google/pprof @ dbd0ed30aa888a30e21ba83b9831ac0e80d41022 (branch main).
// Reproduce with: git clone --depth 100 --single-branch https://github.com/google/pprof && git checkout dbd0ed30aa888a30e21ba83b9831ac0e80d41022
// Every element and relationship carries a "// evidence:" comment pointing at the
// upstream source file (paths relative to the repository root) that justifies it.
// Elements or relationships without verified evidence are not modeled.
// Derived from the repository census and the 17-item module map in docs/pprof/.

workspace {

    model {

        dev = person "Developer" "Engineer analyzing CPU, heap, contention or other performance profiles of Go, Java or C++ programs."
        // evidence: README.md:10 (pprof is a tool for visualization and analysis of profiling data)

        pprof = softwareSystem "pprof" "Single-binary tool that reads profile.proto samples, symbolizes them and renders text, graph and web reports." {
            // evidence: README.md:12-14 (reads profiling samples in profile.proto format and generates reports); pprof.go:29-30

            cliMain = container "pprof binary" "Package main at the repository root: func main() calls driver.PProf and ships the readline-based interactive UI." "Go command-line binary" {
                // evidence: pprof.go:26 (import driver); pprof.go:29-31 (func main -> driver.PProf(&driver.Options{UI: newUI()})); pprof.go:41-103 (readlineUI); third_party/svgpan wrapper merged into the root module
            }

            driverApi = container "driver (public API)" "Repo-root package that re-declares plugin-agnostic interfaces and forwards PProf to internal/driver so external consumers never import internal packages." "Go package" {
                // evidence: driver/driver.go:25-27 (imports internal/driver, internal/plugin, profile); driver/driver.go:33-35 (PProf delegates to internaldriver.PProf)
            }

            orchestrator = container "internal/driver (orchestrator)" "Core coordinator: parses flags and commands, fetches and symbolizes profiles, generates reports, runs the interactive shell or the web UI." "Go package" {
                // evidence: internal/driver/driver.go:37-60 (PProf -> parseFlags -> fetchProfiles -> generateReport | serveWebInterface | interactive)

                cmpCore = component "PProf orchestrator" "PProf() entry point: cleans temp files, applies defaults, then dispatches to CLI parsing, profile fetching, report generation, web UI or interactive shell." "Go" {
                    // evidence: internal/driver/driver.go:37-60; driver.go:114 (generateReport); driver.go:127 (report.Generate call)
                }

                cmpCli = component "CLI front-end (flags and commands)" "parseFlags reads flags and the profile source; pprofCommands defines the report command table, including dot post-processors for image formats." "Go" {
                    // evidence: internal/driver/cli.go:46 (parseFlags); internal/driver/commands.go:33 (commands map), commands.go:39 (command struct), commands.go:85-109 (report format commands), commands.go:393-397 (invokeDot)
                }

                cmpFetch = component "Profile fetcher" "fetchProfiles loads one or more profiles from local files or HTTP URLs, merges them, collects mapping sources and locates binaries for symbolization." "Go" {
                    // evidence: internal/driver/fetch.go:41 (fetchProfiles), fetch.go:332 (grabProfile), fetch.go:411 (locateBinaries), fetch.go:503 (fetch), fetch.go:532-541 (fetchURL via http.Client)
                }

                cmpInteractive = component "Interactive shell" "Read-eval-print loop over plugin.UI with shortcuts, command parsing and completion." "Go" {
                    // evidence: internal/driver/interactive.go:34 (interactive), interactive.go:146 (shortcuts.expand), interactive.go:345 (newCompleter)
                }

                cmpWeb = component "Web UI server" "Serves the browser interface over HTTP: report endpoints, annotated weblist source and flame graphs; optionally opens the system browser." "Go" {
                    // evidence: internal/driver/webui.go:49 (makeWebInterface), webui.go:98 (serveWebInterface), webui.go:261 (makeReport), webui.go:416 + webui.go:440 (MakeWebList + Generate), webui.go:152-153 + 235 (openBrowser); internal/driver/webhtml.go; internal/driver/svg.go:21 (svgpan embed)
                }
            }

            profileLib = container "profile (profile.proto library)" "Central in-memory representation of profile.proto plus decode (Parse/ParseData), encode (Write), validation, aggregation and legacy format parsers." "Go package" {
                // evidence: profile/profile.go:35 (type Profile struct); profile.go:172/182 (Parse/ParseData); profile.go:345 (Write)

                pModel = component "Profile data model" "In-memory object graph for profile.proto: Profile, Sample, Location, Function, Mapping with validation, aggregation and copying." "Go" {
                    // evidence: profile/profile.go:35 (type Profile struct), profile.go:364 (CheckValid), profile.go:445 (Aggregate), profile.go:867 (Copy)
                }

                pCodec = component "profile.proto codec" "Decodes and encodes profiles in compressed and uncompressed protobuf form." "Go" {
                    // evidence: profile/profile.go:172 (Parse), profile.go:182 (ParseData), profile.go:237 (ParseUncompressed), profile.go:345 (Write), profile.go:355 (WriteUncompressed); proto/profile.proto (format definition per README.md:21)
                }

                pLegacy = component "Legacy format parsers" "parseLegacy converts legacy Go heap/contention formats; parseJavaProfile converts Java format profiles into the Profile model." "Go" {
                    // evidence: profile/profile.go:195 (legacy fallback in ParseData), profile.go:213 (parseLegacy); profile/legacy_java_profile.go:68 (parseJavaProfile); profile/legacy_profile.go
                }
            }

            reportGen = container "internal/report (report generation)" "Turns a fetched profile into reader-facing output: text top, tree, DOT graphs, Callgrind, annotated source and flame/stack data." "Go package" {
                // evidence: internal/report/report.go:88-114 (Generate format switch)

                rGen = component "Report generator" "Generate() dispatches the selected output format and builds the trimmed call graph most formats are rendered from." "Go" {
                    // evidence: internal/report/report.go:88 (Generate), report.go:92-114 (format switch), report.go:124 (newTrimmedGraph)
                }

                rSource = component "Annotated source printer" "printSource renders symbolized, sample-annotated source listings; MakeWebList produces the data behind the web UI source view." "Go" {
                    // evidence: internal/report/source.go:43 (printSource), source.go:243 (MakeWebList), source.go:260 (newSourcePrinter); internal/report/source_html.go (HTML rendering)
                }

                rStacks = component "Stack/flame view data" "Stacks() converts the profile into a StackSet consumed by the driver flame graph view." "Go" {
                    // evidence: internal/report/stacks.go:83 (Stacks), stacks.go:106 (makeInitialStacks); internal/driver/stacks.go:40 (rpt.Stacks())
                }
            }

            graphPkg = container "internal/graph (call graph)" "Builds a directed call graph from profile samples, trims and balances it, and composes DOT output." "Go package" {
                // evidence: internal/graph/graph.go:50 (type Graph struct), graph.go:330 (New), internal/graph/dotgraph.go:57 (ComposeDot)
            }

            measurementPkg = container "internal/measurement (sample scaling)" "Scales and formats sample values and units for reports and UI labels." "Go package" {
                // evidence: internal/measurement/measurement.go:32 (ScaleProfiles), measurement.go:129 (Scale), measurement.go:156 (ScaledLabel), measurement.go:167 (Percentage)
            }

            pluginApi = container "internal/plugin (plugin interfaces)" "Defines the interface contracts (Writer, FlagSet, Fetcher, Symbolizer, ObjTool, UI, HTTPServer) between the driver and its implementations." "Go package" {
                // evidence: internal/plugin/plugin.go:28 (type Options struct), plugin.go:29/34/44/50 (Writer, UI, HTTPServer, Writer interface)
            }

            binutilsPkg = container "internal/binutils (binary inspection)" "ObjTool implementation: opens ELF/Mach-O/PE binaries and drives external nm, addr2line, llvm-symbolizer and objdump to map addresses to symbols." "Go package" {
                // evidence: internal/binutils/binutils.go:40 (struct Binutils), binutils.go:56-63 (external tool fields), binutils.go:304 (Open)
            }

            elfexecPkg = container "internal/elfexec (ELF parsing)" "ELF helpers used by binutils: base-address computation, GNU build-id extraction, program header matching." "Go package" {
                // evidence: internal/elfexec/elfexec.go:121 (GetBuildID), elfexec.go:216 (GetBase), elfexec.go:287 (FindTextProgHeader)
            }

            symbolizerPkg = container "internal/symbolizer (symbolization)" "Fills symbols into the profile: local path via binutils, remote path by POSTing addresses to a symbolz HTTP service." "Go package" {
                // evidence: internal/symbolizer/symbolizer.go:47-89 (Symbolize modes local|fastlocal|remote|none), symbolizer.go:100-101 (postURL)
            }

            symbolzPkg = container "internal/symbolz (symbolz client)" "Client for the symbolz HTTP protocol: batches hex addresses per mapping and assigns returned function names to locations." "Go package" {
                // evidence: internal/symbolz/symbolz.go:43 (Symbolize), symbolz.go:126 (addresses joined by + through syms callback)
            }

            transportPkg = container "internal/transport (TLS transport)" "http.RoundTripper with optional client certificates for fetching profiles and symbols over HTTPS." "Go package" {
                // evidence: internal/transport/transport.go:49 (New), transport.go:102 (RoundTrip with lazy TLS init)
            }
        }

        targetApp = softwareSystem "Profiled target application" "External program or file that exposes profiling data over an HTTP endpoint (e.g. net/http/pprof) or as a local profile file." {
            // evidence: README.md:22 (Profiles can be read from a local file, or over http); internal/driver/fetch.go:503 (fetch), fetch.go:532-541 (fetchURL http.Client)
        }

        progBins = softwareSystem "Local program binaries" "Executables and shared libraries on disk (ELF, Mach-O, PE) used to map runtime addresses back to symbols." {
            // evidence: internal/driver/fetch.go:411 (locateBinaries); internal/binutils/binutils.go:304 (Open by magic number)
        }

        symTools = softwareSystem "Native binutils tools" "External symbolizer utilities (nm, addr2line, llvm-symbolizer, objdump) executed as child processes." {
            // evidence: internal/binutils/binutils.go:56-63 (tool fields); README.md:26 (symbolize through the use of the native binutils tools)
        }

        symzSvc = softwareSystem "Remote symbolizer service (symbolz)" "HTTP service that resolves batches of hex addresses to function names." {
            // evidence: internal/symbolizer/symbolizer.go:89 (postURL call), symbolizer.go:100-101; internal/symbolz/symbolz.go:43-126
        }

        graphviz = softwareSystem "Graphviz (dot)" "Optional external renderer invoked to turn DOT output into GIF, PDF, PNG, PS or SVG images." {
            // evidence: internal/driver/commands.go:103-109 (gif/pdf/png/ps/svg commands), commands.go:393-397 (invokeDot -> exec.Command dot); README.md:38-39 (Graphviz bullet URL + Optional note)
        }

        browser = softwareSystem "Web browser" "Browser used to explore the interactive web UI served by pprof on localhost." {
            // evidence: internal/driver/webui.go:98 (serveWebInterface), webui.go:152-153 + 235 (openBrowser), webui.go:215 (http.Server)
        }

        // ---- L1 relationships (system context) ----
        dev -> cliMain "Runs pprof with flags, a profile source (file or URL) and a report command"
        // evidence: README.md:22; pprof.go:29-31

        cliMain -> dev "Returns reports as text, DOT, Callgrind, proto or the interactive web UI"
        // evidence: README.md:12-14; internal/report/report.go:88 (Generate to io.Writer); internal/driver/commands.go:85-109

        orchestrator -> targetApp "Fetches profile data over HTTP or reads local profile files"
        // evidence: internal/driver/fetch.go:503 (fetch), fetch.go:532-541 (fetchURL)

        orchestrator -> progBins "Locates and opens binaries for profile mappings before symbolization"
        // evidence: internal/driver/fetch.go:411 (locateBinaries); internal/driver/options.go:44 (d.Obj = &binutils.Binutils{})

        binutilsPkg -> symTools "Executes nm, addr2line, llvm-symbolizer and objdump as child processes"
        // evidence: internal/binutils/binutils.go:56-63; README.md:26

        symbolizerPkg -> symzSvc "POSTs hex addresses to a symbolz service for remote symbolization"
        // evidence: internal/symbolizer/symbolizer.go:89,100-101 (postURL); internal/symbolz/symbolz.go:126

        orchestrator -> graphviz "Pipes DOT output into dot -Tformat for gif, pdf, png, ps and svg commands"
        // evidence: internal/driver/commands.go:103-109, commands.go:393-397 (exec.Command dot)

        orchestrator -> browser "Serves the interactive web UI over HTTP and opens the system browser"
        // evidence: internal/driver/webui.go:98,152-153,215,235

        // ---- L2 relationships (compile-time imports across non-test files, grep-verified at PIN) ----
        cliMain -> driverApi "Calls driver.PProf with plugin options"
        // evidence: pprof.go:26 (import driver), pprof.go:30 (call)

        driverApi -> orchestrator "Delegates PProf(o.internalOptions()) to the internal implementation"
        // evidence: driver/driver.go:25 (import), driver/driver.go:33-35

        driverApi -> pluginApi "Re-declares plugin-agnostic interfaces over internal/plugin types"
        // evidence: driver/driver.go:26 (import), driver/driver.go:37-40 (internalOptions wraps plugin.ObjTool/Symbolizer)

        driverApi -> profileLib "References profile types in its public options"
        // evidence: driver/driver.go:27 (import)

        orchestrator -> profileLib "Consumes and produces profile.Profile objects"
        // evidence: internal/driver/driver.go:31, fetch.go:34, interactive.go:27, webui.go:37, driver_focus.go:26, tagroot.go:7 (imports)

        orchestrator -> pluginApi "Implements and consumes plugin interfaces (Options, UI, ObjTool...)"
        // evidence: internal/driver/driver.go:29, options.go:25, interactive.go:25, commands.go:28, fetch.go:33, webui.go:35, cli.go:23, driver_focus.go:25 (imports)

        orchestrator -> reportGen "generateReport calls report.Generate; web UI uses MakeWebList"
        // evidence: internal/driver/driver.go:30 (import), driver.go:54 (generateReport), driver.go:127 (report.Generate), webui.go:36 + webui.go:440, webhtml.go:24, commands.go:29, interactive.go:26 (imports)

        orchestrator -> graphPkg "Web UI composes graph views"
        // evidence: internal/driver/webui.go:33 (import)

        orchestrator -> measurementPkg "Scales and formats sample values"
        // evidence: internal/driver/fetch.go:32, driver_focus.go:24, webui.go:34, stacks.go:22, tagroot.go:6 (imports)

        orchestrator -> binutilsPkg "setDefaults constructs the default ObjTool"
        // evidence: internal/driver/options.go:24 (import), options.go:44 (d.Obj = &binutils.Binutils{}), cli.go:22 (import), cli.go:163-164 (SetTools guard + call bu.SetTools(*flagTools))

        orchestrator -> symbolizerPkg "setDefaults constructs the default Symbolizer"
        // evidence: internal/driver/options.go:26 (import), options.go:53 (&symbolizer.Symbolizer{...})

        orchestrator -> transportPkg "setDefaults installs the HTTP round tripper"
        // evidence: internal/driver/options.go:27 (import), options.go:50 (transport.New(d.Flagset))

        orchestrator -> cliMain "Embeds the panning wrapper from third_party/svgpan (merged into the root module)"
        // evidence: internal/driver/svg.go:21 (import third_party/svgpan)

        reportGen -> profileLib "Reads samples, locations and functions from the profile"
        // evidence: internal/report/report.go:34, source.go:36, stacks.go:24, synth.go:4 (imports)

        reportGen -> graphPkg "Renders trimmed graphs and shortens names"
        // evidence: internal/report/report.go:31, source.go:33, shortnames.go:21 (imports)

        reportGen -> measurementPkg "Scales and formats sample values"
        // evidence: internal/report/report.go:32, stacks.go:23, source.go:34 (imports)

        reportGen -> pluginApi "Uses ObjTool and Frame interfaces for source listing"
        // evidence: internal/report/report.go:33, source.go:35 (imports)

        graphPkg -> profileLib "Builds the graph from profile samples"
        // evidence: internal/graph/graph.go:27 (import)

        graphPkg -> measurementPkg "Scales node and edge weights for DOT output"
        // evidence: internal/graph/dotgraph.go:24 (import)

        measurementPkg -> profileLib "Operates on profile sample values and units"
        // evidence: internal/measurement/measurement.go:26 (import)

        pluginApi -> profileLib "Interfaces reference profile types (e.g. Fetcher, Symbolizer)"
        // evidence: internal/plugin/plugin.go:24 (import)

        binutilsPkg -> elfexecPkg "Computes load bases and build ids for opened binaries"
        // evidence: internal/binutils/binutils.go:35 (import)

        binutilsPkg -> pluginApi "Implements plugin.ObjTool and returns plugin.ObjFile"
        // evidence: internal/binutils/binutils.go:36, addr2liner.go:26, addr2liner_llvm.go:27, addr2liner_nm.go:25, disasm.go:24 (imports)

        symbolizerPkg -> profileLib "Fills functions and lines into profile locations"
        // evidence: internal/symbolizer/symbolizer.go:31 (import)

        symbolizerPkg -> binutilsPkg "Local symbolization path opens binaries through binutils"
        // evidence: internal/symbolizer/symbolizer.go:28 (import)

        symbolizerPkg -> symbolzPkg "Remote symbolization path delegates mapping queries to symbolz"
        // evidence: internal/symbolizer/symbolizer.go:30 (import)

        symbolizerPkg -> pluginApi "Consumes MappingSources, UI and Transport interfaces"
        // evidence: internal/symbolizer/symbolizer.go:29 (import)

        symbolzPkg -> profileLib "Assigns function names to profile locations"
        // evidence: internal/symbolz/symbolz.go:30 (import)

        symbolzPkg -> pluginApi "Consumes MappingSources and UI interfaces"
        // evidence: internal/symbolz/symbolz.go:29 (import)

        transportPkg -> pluginApi "Registers TLS flags on plugin.FlagSet"
        // evidence: internal/transport/transport.go:27 (import)

        // ---- L3 relationships (component level; call sites verified at PIN) ----
        cmpCore -> cmpCli "Parses flags and selects the report command"
        // evidence: internal/driver/driver.go:43 (parseFlags(o)); internal/driver/cli.go:46 (func parseFlags)

        cmpCore -> cmpFetch "Obtains the profile via fetchProfiles"
        // evidence: internal/driver/driver.go:48 (fetchProfiles(src, o)); internal/driver/fetch.go:41 (func fetchProfiles)

        cmpCore -> cmpWeb "Starts the web UI for the web command"
        // evidence: internal/driver/driver.go:58 (serveWebInterface(src.HTTPHostport, p, o, src.HTTPDisableBrowser))

        cmpCore -> cmpInteractive "Falls back to the interactive shell otherwise"
        // evidence: internal/driver/driver.go:60 (interactive(p, o)); internal/driver/interactive.go:34 (func interactive)

        cmpCore -> reportGen "generateReport renders the selected report format"
        // evidence: internal/driver/driver.go:54 (generateReport), driver.go:114 (func generateReport), driver.go:127 (report.Generate)

        cmpWeb -> reportGen "makeReport builds and renders reports for HTTP endpoints"
        // evidence: internal/driver/webui.go:440 (report.Generate), webui.go:416 (report.MakeWebList)

        cmpWeb -> rSource "Weblist view requests annotated source data"
        // evidence: internal/driver/webui.go:416 (report.MakeWebList)

        cmpWeb -> rStacks "Flamegraph endpoint converts the report into a StackSet"
        // evidence: internal/driver/webui.go:134 (/flamegraph -> ui.stackView), internal/driver/stacks.go:26 (func stackView), stacks.go:40 (rpt.Stacks())

        cmpFetch -> progBins "Locates binaries for profile mappings before symbolization"
        // evidence: internal/driver/fetch.go:411 (locateBinaries)

        cmpCli -> graphviz "invokeDot executes dot -Tformat as a child process for image commands"
        // evidence: internal/driver/commands.go:103-109 (gif/pdf/png/ps/svg), commands.go:393-397 (exec.Command dot)

        cmpWeb -> browser "Serves HTTP endpoints and opens the system browser"
        // evidence: internal/driver/webui.go:98 (serveWebInterface), webui.go:152-153 + 235 (openBrowser), webui.go:215 (http.Server)

        rGen -> rSource "List and WebList formats render annotated source"
        // evidence: internal/report/report.go:114 (printSource), internal/report/source.go:43 (func printSource), source.go:243 (func MakeWebList)

        rGen -> graphPkg "Builds the trimmed graph that most formats render from"
        // evidence: internal/report/report.go:31 (import), report.go:124 (newTrimmedGraph), report.go:328 (use in printTopProto)

        pCodec -> pModel "Decodes into and encodes from the Profile object graph"
        // evidence: profile/profile.go:172 (Parse), profile.go:182 (ParseData), profile.go:345 (Write)

        pLegacy -> pModel "Converts legacy formats into the Profile model"
        // evidence: profile/profile.go:213 (parseLegacy returns *Profile), profile/legacy_java_profile.go:68 (parseJavaProfile)
    }

    views {

        systemContext pprof "pprof-L1-Context" "System context: the developer and the external systems pprof connects to." {
            include *
            autolayout lr
        }

        container pprof "pprof-L2-Containers" "Container view: the pillar Go packages of pprof." {
            include *
            autolayout tb
        }

        component orchestrator "pprof-L3-internal-driver" "Component view of the internal/driver orchestrator." {
            include *
            autolayout tb
        }

        component reportGen "pprof-L3-report" "Component view of the internal/report container." {
            include *
            autolayout tb
        }

        component profileLib "pprof-L3-profile" "Component view of the profile container." {
            include *
            autolayout tb
        }

        styles {
            element "Person" {
                background #08427b
                color #ffffff
            }
            element "Software System" {
                background #1168bd
                color #ffffff
            }
            element "External Software System" {
                background #999999
                color #ffffff
            }
            element "Container" {
                background #438dd5
                color #ffffff
            }
            element "Component" {
                background #85bbf0
                color #000000
            }
        }
    }
}
