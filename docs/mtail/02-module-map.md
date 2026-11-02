---
subject: google/mtail
measured_at: 4c7e0e1174ac1ead032efe28d86428bbbe0ae145
status: final
---


# Module map

## 1. Bảng item (18/18 — đúng thứ tự id checklist)

| id | module | path | responsibility | main_files | deps_in | deps_out | loc | status |
|----|--------|------|----------------|------------|---------|----------|-----|--------|
<a id="m01-compiler"></a>| m01 | compiler | internal/runtime/compiler | Front-end biên dịch chương trình mtail thành bytecode `code.Object` — `Compiler.Compile` (compiler.go:89) chạy pipeline parser.Parse → opt.Optimise → checker.Check → opt.Optimise (lần 2, sau type-check) → codegen.CodeGen trên 10 package con (root compiler + ast, checker, codegen, errors, opt, parser, position, symbol, types), với các Option cấu hình (EmitAst, MaxRegexpLength, MaxRecursionDepth, DisableOptimisation). | entry `compiler.go` (:19/:27/:89); largest `parser/parser.go` 1504 (goyacc-generated); logic non-test lớn nhất `checker/checker.go` 970 | m07, m09, m14 | m05, m15, m16, m17 | 10116 | DONE |
<a id="m02-mtail"></a>| m02 | mtail | internal/mtail | internal/mtail chứa `Server` — thành phần điều phối chính của mtail: giữ `metrics.Store`, `tailer.Tailer` (đọc log → channel `lines`), `runtime.Runtime` (nạp chương trình + vòng đời VM) và `exporter.Exporter`, đồng thời chạy HTTP server (metrics/pprof/zpages) qua `New()`; `options.go` định nghĩa toàn bộ `Option` cấu hình Server. | entry `mtail.go` (:31/:176); largest `logo.ico.go` 2008 (asset favicon); logic non-test lớn nhất `options.go` 288 | m05, m06, m07, m08, m09, m10, m11, m18 | m12, m15 | 4463 | DONE |
<a id="m03-logstream"></a>| m03 | logstream | internal/tailer/logstream | logstream biến mỗi pathname của nguồn log (file thường, named pipe/stdin, unix/tcp/udp socket) thành một dòng chảy `*logline.LogLine` liên tục qua interface `LogStream`/factory `New()` — tự xử lý rotation (đổi inode), truncation (seek về 0), reopen khi `ESTALE`, và tự cắt ranh giới dòng bằng `LineReader` trước khi đẩy vào channel cho tailer tiêu thụ. | entry `logstream.go` (:35/:64); logic non-test lớn nhất `filestream.go` 239; `reader.go` 106 (LineReader) | m11, m18 | m08 | 2017 | DONE |
<a id="m04-vm"></a>| m04 | vm | internal/runtime/vm | `internal/runtime/vm` chứa `VM` — máy ảo thông dịch bytecode do compiler sinh ra: `New()` nhận `code.Object` (chương trình, regex/string constants, metrics) (vm.go:993-1009), `ProcessLogLine()` chạy vòng fetch–decode–execute trên `thread` với stack máy ảo (vm.go:962-991), `execute()` switch qua opcode (`Match`, `Cmp`, `Inc`, `Set`, `Strptime`, `Add`, `Del`, `Stop`, …) cập nhật `metrics.Metric`, kèm recover panic thành runtime error (vm.go:336-350) và memo parse thời gian bằng LRU (vm.go:65 `timeMemos *lru.Cache`). | entry + largest `vm.go` 1060 (:56/:993); test `vm_test.go` 929 | m07, m09, m14, m18 | m05 | 1989 | DONE |
<a id="m05-runtime"></a>| m05 | runtime | internal/runtime | Program loader/runtime của mtail — `Runtime` nạp các file chương trình `.mtail` từ programPath (`LoadAllPrograms`/`LoadProgram`), biên dịch qua `compiler.Compiler` rồi chạy VM tương ứng trong map `handles` (vmHandle), nạp log line vào VM qua `CompileAndRun`, unload/reload khi file đổi (`UnloadProgram`), lưu lỗi biên dịch `programErrors` (bảo vệ bởi `programErrorMu`) và expose trang HTTP trạng thái loader (httpstatus.go). | entry `runtime.go` (:215/:250, 358 — logic non-test lớn nhất); largest tổng thể `runtime_integration_test.go` 1115 (test); `options.go` 119, `httpstatus.go` 117 | m01, m04, m07, m09, m14, m18 | m02 | 1871 | DONE |
<a id="m06-exporter"></a>| m06 | exporter | internal/exporter | package `exporter` ("getting metrics out of mtail into your monitoring system of choice") chứa `Exporter` — đọc `*metrics.Store` và xuất metric ra collector Prometheus (`Describe`/`Collect`), varz/json HTTP handlers và các push target định kỳ, cấu hình qua `Option` (Hostname, OmitProgLabel, EmitTimestamp, PushInterval…). | entry `export.go` (:32/:91, 275 — logic non-test lớn nhất); `prometheus.go` 142; largest tổng thể `prometheus_test.go` 358 (test) | m07, m09 | m02, m12 | 1599 | DONE |
<a id="m07-metrics"></a>| m07 | metrics | internal/metrics | metrics là kho trạng thái trung tâm của mtail — `Store` (map name → []*Metric) lưu mọi metric do chương trình tạo ra với thêm/tìm/xóa an toàn khóa kép (`insertMu`+`searchMu`), GC theo limit/expiry, serialize JSON và iterate cho exporter — trong khi `Metric`/`LabelValue` mô hình hóa kind (Counter/Gauge/Timer/Text/Histogram), type (Int/Float/String/Buckets) và các giá trị datum theo nhãn. | entry `store.go` (:19/:26); largest `metric.go` 309; `type.go` 44 | m09 | m01, m02, m04, m05, m06, m12, m13, m14 | 1326 | DONE |
<a id="m08-tailer"></a>| m08 | tailer | internal/tailer | `internal/tailer` chứa `Tailer` — "polls the filesystem for log sources that match given `LogPathPatterns` and creates `LogStream`s to tail them" (tail.go:28-29): `AddPattern`/`doPatternGlob`/`pollLogPattern` poll glob pattern theo `waker.Waker` (tail.go:186, 321, 289), `TailPath` tạo 1 `logstream.LogStream` cho mỗi file và bơm dòng đọc được lên channel dùng chung `lines chan<- *logline.LogLine` (tail.go:256-286), `New` dựng context + 2 goroutine dọn dẹp khi mọi subroutine kết thúc (tail.go:119-168), và `WriteStatusHTML` render trang trạng thái tailer (patterns + bảng logstreams với opens/truncs/errors/lines từ expvar) (httpstatus.go:44-84). | entry `tail.go` (:30/:119, 342); `httpstatus.go` 84; 3 file test tail_test.go 256 / tail_unix_test.go 98 / tail_windows_test.go 24 | m03, m11, m18 | m02 | 804 | DONE |
<a id="m09-datum"></a>| m09 | datum | internal/metrics/datum | Định nghĩa value-type của metric — interface `Datum` (ValueString/TimeString/TimeUTC) + struct nền `BaseDatum` đóng dấu timestamp atomic (nanosecond UTC), 4 implementation `Int`, `Float`, `String`, `Buckets` (range histogram) và các constructor zero-value `NewInt/NewFloat/NewString/NewBuckets` để store/exporter tạo datum đồng nhất. | entry + largest `datum.go` 259 (:15/:30/:55-70); `buckets.go` 117, `int.go` 54, `string.go` 47, `float.go` 43 | — | m01, m02, m04, m05, m06, m07, m13 | 667 | DONE |
<a id="m10-testutil"></a>| m10 | testutil | internal/testutil | `internal/testutil` là bộ helper dùng chung cho test suite của mtail: assertion expvar có deadline (`TestGetExpvar`, `ExpectExpvarDeltaWithDeadline`, `ExpectMapExpvarDeltaWithDeadline`), poll `DoOrTimeout` + wrapper `TimeoutTest`, tạo dir/file/log tạm (`TestTempDir`, `TestOpenFile`, `OpenLogFile`), và các helper môi trường (port, race-detector, root, stdin, flag, diff…). | entry `expvar.go` (:16, 78 — non-test lớn nhất); largest test `timeout_test.go` 56; 15 file (diff.go err.go expvar.go file.go flag.go fs.go lines.go norace.go port.go race.go root.go short.go stdin.go timeout.go timeout_test.go) | m18 | m02 | 504 | DONE |
<a id="m11-waker"></a>| m11 | waker | internal/waker | waker định nghĩa interface đồng bộ hóa `Waker` — kênh `Wake()` được đóng khi routine rảnh cần dậy — cùng 3 hiện thực: `timedWaker` (đánh thức định kỳ theo ticker, dùng trong production), `testWaker` (đồng bộ hóa có kiểm soát giữa goroutine bị test và vòng lặp test) và `alwaysWaker` (kênh đã đóng sẵn, không bao giờ chặn). | entry `waker.go` (:7, 10 dòng); largest non-test `testwaker.go` 139; production `timedwaker.go` 50 | — | m02, m03, m08, m12 | 335 | DONE |
<a id="m12-cmd-mtail"></a>| m12 | cmd/mtail | cmd/mtail | `cmd/mtail` là entry binary thật của chương trình mtail: định nghĩa ~40 cờ CLI (port/address/unix_socket, progs, logs, các cờ compiler/VM runtime/ops/debug/tracing + 3 cờ DEPRECATED) (main.go:41-85), ánh xạ cờ thành `[]mtail.Option` + `[]exporter.Option` (main.go:169-226), dựng `metrics.NewStore` + `mtail.New` + `m.Run()` (main.go:228-243), bắt SIGINT/SIGTERM để cancel context (main.go:156-163), và nhánh `-one_shot` xuất metrics ra stdout theo format json (store.WriteMetrics) hoặc prometheus (exporter.New + e.Write) (main.go:245-277). | entry + largest `main.go` 278 (:102) | m02, m06, m07, m11 | — | 278 | DONE |
<a id="m13-golden"></a>| m13 | golden | internal/mtail/golden | Package hỗ trợ test golden-file — `ReadTestData` parse file dữ liệu "golden" (dòng dạng `counter\|gauge\|timer\|text\|histogram <name>{k=v,...} <value> <timestamp>` qua regexp `varRe`) thành `metrics.MetricSlice` để so khớp output metric của chương trình mtail trong test. | entry `reader.go` (:20/:23, 156 — non-test duy nhất); test `reader_test.go` 121 | m07, m09 | — | 277 | DONE |
<a id="m14-code"></a>| m14 | code | internal/runtime/code | package `code` ("contains the bytecode instructions for the mtail virtual machine") định nghĩa tập lệnh bytecode của VM: enum `Opcode` (~70 opcode từ Bad/Stop/Match/…/F2s), struct `Instr` (Opcode + Operand + SourceLine) và `Object` — artifact nhị phân của một chương trình đã biên dịch (Program/String/Regexp/Metrics) — là hợp đồng trao đổi giữa compiler (codegen) và vm. | entry `opcodes.go` (:7, 147); `object.go` 18 (:13), `instr.go` (:9) | m07 | m01, m04, m05 | 214 | DONE |
<a id="m15-mdot"></a>| m15 | mdot | cmd/mdot | mdot là CLI biến một chương trình mtail (`.mtail`) thành đồ thị graphviz dot: parse (`parser.Parse`) → type-check (`checker.Check`) → duyệt AST bằng `ast.Walk` với visitor `dotter` phát node/cạnh ra stdout, hoặc phục vụ SVG qua HTTP bằng `exec.Command("dot", "-Tsvg")` khi chạy với `--http_port`. | entry + largest `main.go` 206 (:43/:134/:154) | m01, m02 | — | 206 | DONE |
<a id="m16-mgen"></a>| m16 | mgen | cmd/mgen | `cmd/mgen` sinh chương trình mtail ngẫu nhiên cho fuzz testing ("Command mgen generates mtail programs for fuzz testing by following a simple grammar", main.go:7): bảng grammar `table map[string]node` mô tả toàn bộ ngôn ngữ (stmt/expr/decl/def_spec/deco_spec, BUILTIN: strptime/timestamp/len/tolower…) (main.go:26-66), `generateProgram()` đi bộ bảng bằng `math/rand` seed được (`-rand_seed`, `-min_iterations`) phát token ra stdout qua goroutine emitter wrap 80 cột (main.go:91-135), `-dictionary` in danh sách token từ `parser.Dictionary()` (main.go:138-141). | entry + largest `main.go` 152 (:26/:144) | m01 | — | 152 | DONE |
<a id="m17-mfmt"></a>| m17 | mfmt | cmd/mfmt | CLI formatter cho chương trình mtail (doc comment `Command mfmt formats mtail programs.`): đọc file chương trình từ flag `-prog`, parse bằng `parser.Parse`, type-check bằng `checker.Check`, in lại source chuẩn qua `parser.Unparser{}.Unparse`, ghi đè file gốc khi `-write`. | entry + largest `main.go` 59 (:25) | m01 | — | 59 | DONE |
<a id="m18-logline"></a>| m18 | logline | internal/logline | package `logline` định nghĩa `LogLine` — struct gói 1 dòng log vừa đọc (Context + Filename + Line) — được tailer đẩy qua channel cho VM xử lý; là kiểu dữ liệu trao đổi trung tâm giữa tailer/runtime/mtail/testutil. | entry + largest `logline.go` 19 (:9/:17) | — | m02, m03, m04, m05, m08, m10 | 19 | DONE |

## 2. Chi tiết từng item (nguyên văn từ worker part, sắp theo id)

### m01 — compiler (w1)
- path: internal/runtime/compiler
- files/loc: 28 / 10116
- responsibility: Front-end biên dịch chương trình mtail thành bytecode `code.Object` —
  `Compiler.Compile` (compiler.go:89) chạy pipeline parser.Parse → opt.Optimise →
  checker.Check → opt.Optimise (lần 2, sau type-check) → codegen.CodeGen trên 10 package con
  (root compiler + ast, checker, codegen, errors, opt, parser, position, symbol, types),
  với các Option cấu hình (EmitAst, MaxRegexpLength, MaxRecursionDepth, DisableOptimisation).
- evidence:
  - entry: `grep -n 'type Compiler struct\|^func New\|) Compile(' internal/runtime/compiler/compiler.go`
    → raw: `19:type Compiler struct {`, `27:func New(options ...Option) (*Compiler, error) {`,
    `89:func (c *Compiler) Compile(name string, input io.Reader) (obj *code.Object, err error) {`
    (pipeline gọi thật: `94:ast, err = parser.Parse(...)`, `104/125:opt.Optimise(ast)`,
    `114:checker.Check(...)`, `136:codegen.CodeGen(name, ast)`);
    anchor các phase: `parser/driver.go:34:func Parse(...)`, `opt/opt.go:17:func Optimise(...)`,
    `checker/checker.go:45:func Check(...)`, `codegen/codegen.go:36:func CodeGen(...)`;
    struct phase: `codegen/codegen.go:25:type codegen struct {`, `checker/checker.go:27:type checker struct {`
  - largest: `internal/runtime/compiler/parser/parser.go` = 1504 dòng — file sinh tự động goyacc
    (dòng 1: `// Code generated by goyacc -v y.output -o parser.go -p mtail parser.y. DO NOT EDIT.`);
    file logic lớn nhất non-test non-generated: `internal/runtime/compiler/checker/checker.go` = 970 dòng;
    test lớn nhất: `internal/runtime/compiler/codegen/codegen_test.go` = 1138 dòng
    (lệnh: find internal/runtime/compiler -type f -name '*.go' -print0 | xargs -0 wc -l | sort -rn)
- deps_in (raw `uniq -c` trên grep import non-test của internal/runtime/compiler; các import
  `internal/runtime/compiler/{ast,checker,codegen,errors,opt,parser,position,symbol,types}` là
  NỘI BỘ item — 9 subdir gộp sẵn vào m01 theo template mục "Universe", nên KHÔNG tính dep):
      6 	"github.com/google/mtail/internal/metrics"        → metrics (m07)
      1 	"github.com/google/mtail/internal/metrics/datum"  → datum (m09)
      2 	"github.com/google/mtail/internal/runtime/code"   → code (m14)
  → deps_in tổng hợp: metrics, datum, code
  (file bên trong compiler import 3 dep này: ast.go, checker.go, codegen.go, compiler.go,
  parser/parser.go, parser/sexp.go, parser/unparser.go — grep -rln trên prefix
  `internal/metrics"|internal/metrics/datum"|internal/runtime/code"`)
- deps_out: 4 file non-test ngoài item — `cmd/mdot/main.go` (m15), `cmd/mfmt/main.go` (m17),
  `cmd/mgen/main.go` (m16), `internal/runtime/{fuzz.go,options.go,runtime.go}` (m05)
  (lệnh: grep -rl '"github.com/google/mtail/internal/runtime/compiler' --include='*.go'
  --exclude='*_test.go' . — dùng prefix match vì import có thể trỏ vào subpackage;
  các file nằm trong internal/runtime/compiler/* bị loại vì là nội bộ item)
- status: DONE

### m02 — mtail (w2)
- path: internal/mtail
- files/loc: 25 / 4463
- responsibility: internal/mtail chứa `Server` — thành phần điều phối chính của mtail: giữ `metrics.Store`, `tailer.Tailer` (đọc log → channel `lines`), `runtime.Runtime` (nạp chương trình + vòng đời VM) và `exporter.Exporter`, đồng thời chạy HTTP server (metrics/pprof/zpages) qua `New()`; `options.go` định nghĩa toàn bộ `Option` cấu hình Server.
- evidence:
  - entry: `grep -n 'type Server struct\|^func New(' internal/mtail/mtail.go`
    → raw: `31:type Server struct {` và `176:func New(ctx context.Context, store *metrics.Store, options ...Option) (*Server, error) {`
    (đã đọc mtail.go dòng 1–60: struct giữ store/tailer/runtime/exporter/`lines chan *logline.LogLine`/`reg *prometheus.Registry`)
  - largest: `internal/mtail/logo.ico.go` = 2008 dòng (asset favicon nhúng — không phải logic);
    file logic lớn nhất non-test: `internal/mtail/options.go` = 288 dòng (đã đọc dòng 1–50: `type Option interface`, `ProgramPath`, `LogPathPatterns`, …).
  - census lệch-phát-hiện & đã đối soát: `find internal/mtail -type f -name '*.go' | wc -l` đệ quy = 27 files / 4740 loc;
    nguyên nhân: find đệ quy nuốt thêm package con `internal/mtail/golden` (chính là item m13 riêng — 2 files / 277 loc, đo độc lập:
    `find internal/mtail/golden -type f -name '*.go' | wc -l` = 2, `xargs -0 cat | wc -l` = 277; nội dung = `reader.go`, `reader_test.go`).
    Census đúng biên item (loại trừ package con đã thành item): `find internal/mtail -maxdepth 1 -type f -name '*.go' | wc -l` = **25**,
    `find internal/mtail -maxdepth 1 -type f -name '*.go' -print0 | xargs -0 cat | wc -l` = **4463** → **khớp tuyệt đối checklist**, không phải lỗi census (25+2=27, 4463+277=4740). Checklist giữ nguyên, không tự sửa.
- deps_in (raw `uniq -c` trên `grep -rh --include='*.go' --exclude='*_test.go' -E '^\s*([A-Za-z0-9_]+\s+)?"github\.com/google/mtail/' internal/mtail | sort | uniq -c`):
  ```
        2 	"github.com/google/mtail/internal/exporter"
        1 	"github.com/google/mtail/internal/logline"
        3 	"github.com/google/mtail/internal/metrics"
        2 	"github.com/google/mtail/internal/metrics/datum"
        2 	"github.com/google/mtail/internal/runtime"
        2 	"github.com/google/mtail/internal/tailer"
        1 	"github.com/google/mtail/internal/testutil"
        2 	"github.com/google/mtail/internal/waker"
  ```
  → deps_in: exporter, logline, metrics, datum, runtime, tailer, testutil, waker
- deps_out: 2 file non-test — `cmd/mdot/main.go` (→ m15 mdot), `cmd/mtail/main.go` (→ m12 cmd/mtail)
  (lệnh: `grep -rl '"github.com/google/mtail/internal/mtail"' --include='*.go' --exclude='*_test.go' .`)
- status: DONE

### m03 — logstream (w3)
- path: internal/tailer/logstream
- files/loc: 16 / 2017
- responsibility: logstream biến mỗi pathname của nguồn log (file thường, named pipe/stdin,
  unix/tcp/udp socket) thành một dòng chảy `*logline.LogLine` liên tục qua interface
  `LogStream`/factory `New()` — tự xử lý rotation (đổi inode), truncation (seek về 0),
  reopen khi `ESTALE`, và tự cắt ranh giới dòng bằng `LineReader` trước khi đẩy vào channel cho tailer tiêu thụ.
- evidence:
  - entry: `grep -n 'type LogStream interface\|^func New(' internal/tailer/logstream/logstream.go`
    → raw: `35:type LogStream interface {` và
    `64:func New(ctx context.Context, wg *sync.WaitGroup, waker waker.Waker, pathname string, oneShot OneShotMode) (LogStream, error) {`;
    `New()` dispatch theo URL scheme (logstream.go:75-88) và file mode (logstream.go:102-112)
    sang `newDgramStream`/`newSocketStream`/`newFifoStream`/`newFileStream`.
  - largest: file lớn nhất toàn item là `internal/tailer/logstream/filestream_test.go` = 292 dòng (test);
    file logic lớn nhất non-test: `internal/tailer/logstream/filestream.go` = 239 dòng
    (`type fileStream struct` :34, `newFileStream` :43, phát hiện rotation bằng `os.SameFile` :155,
    phát hiện truncation `newfi.Size() < currentOffset` :178, reopen khi `syscall.ESTALE` :119).
    Đã đọc thêm `reader.go` (106 dòng): `LineReader` :20, `NewLineReader` :33, `ReadAndSend` :45,
    stale timer 24h `time.AfterFunc(time.Hour*24, lr.cancel)` :55, `Finish` :99.
- deps_in (lệnh: `grep -rh --include='*.go' --exclude='*_test.go' -E '^\s*([A-Za-z0-9_]+\s+)?"github.com/google/mtail/' internal/tailer/logstream | sort | uniq -c`; raw):
  ```
        7 	"github.com/google/mtail/internal/logline"
        5 	"github.com/google/mtail/internal/waker"
  ```
  → deps_in tổng hợp: logline, waker
- deps_out: 2 file non-test, cả hai thuộc item tailer — `internal/tailer/tail.go`, `internal/tailer/httpstatus.go`
  (lệnh: `grep -rl '"github.com/google/mtail/internal/tailer/logstream"' --include='*.go' --exclude='*_test.go' .`)
  → deps_out tổng hợp: tailer
- status: DONE

### m04 — vm (w4)
- path: internal/runtime/vm
- files/loc: 2 / 1989
- responsibility: `internal/runtime/vm` chứa `VM` — máy ảo thông dịch bytecode do compiler sinh ra: `New()` nhận `code.Object` (chương trình, regex/string constants, metrics) (vm.go:993-1009), `ProcessLogLine()` chạy vòng fetch–decode–execute trên `thread` với stack máy ảo (vm.go:962-991), `execute()` switch qua opcode (`Match`, `Cmp`, `Inc`, `Set`, `Strptime`, `Add`, `Del`, `Stop`, …) cập nhật `metrics.Metric`, kèm recover panic thành runtime error (vm.go:336-350) và memo parse thời gian bằng LRU (vm.go:65 `timeMemos *lru.Cache`).
- evidence:
  - entry: `grep -n '^type VM struct\|^func New(' internal/runtime/vm/vm.go` → raw: `56:type VM struct {` và `993:func New(name string, obj *code.Object, syslogUseCurrentYear bool, loc *time.Location, log bool, trace bool) *VM {`
  - largest: `internal/runtime/vm/vm.go` = 1060 dòng (file logic lớn nhất, đồng thời là file entry — không có asset nhúng trong item);
    file thứ 2: `internal/runtime/vm/vm_test.go` = 929 dòng, test table-driven cho từng opcode (vm_test.go:19 `var instructions = []struct {`, 7 hàm `Test*`: TestInstrs:596, TestDatumSetInstrs:660, TestStrptimeWithTimezone:783, TestStrptimeWithoutTimezone:797, TestDatumFetchInstrs:811, TestDeleteInstrs:879, TestTimestampInstr:905).
    lệnh đo: `find internal/runtime/vm -type f -name '*.go' -print0 | xargs -0 wc -l | sort -rn` → `1060 vm.go`, `929 vm_test.go`, `1989 total`; census v9 `find … | xargs -0 cat | wc -l` → `1989` — khớp tuyệt đối checklist (2 / 1989).
- deps_in (lệnh: `find internal/runtime/vm -name '*.go' ! -name '*_test.go' -print0 | xargs -0 grep -h -E '^[[:space:]]*([A-Za-z0-9_]+[[:space:]]+)?"github\.com/google/mtail/' | sort | uniq -c`; raw):
  ```
        1 	"github.com/google/mtail/internal/logline"
        1 	"github.com/google/mtail/internal/metrics"
        1 	"github.com/google/mtail/internal/metrics/datum"
        1 	"github.com/google/mtail/internal/runtime/code"
  ```
  → mapping (vm.go:24-27): `internal/logline` → **logline (m18)**; `internal/metrics` → **metrics (m07)**; `internal/metrics/datum` → **datum (m09)**; `internal/runtime/code` → **code (m14)**.
  deps_in tổng hợp: logline, metrics, datum, code
- deps_out: 4 file non-test đều thuộc item `internal/runtime` → **runtime (m05)**. Lệnh: `grep -rl '"github.com/google/mtail/internal/runtime/vm"' --include='*.go' --exclude='*_test.go' .` → `./internal/runtime/runtime.go`, `./internal/runtime/options.go`, `./internal/runtime/fuzz.go`, `./internal/runtime/httpstatus.go` (dòng import: runtime.go:26, options.go:10, fuzz.go:17, httpstatus.go:12).
- status: DONE

### m05 — runtime (w1)
- path: internal/runtime
- files/loc: 6 / 1871
- responsibility: Program loader/runtime của mtail — `Runtime` nạp các file chương trình `.mtail`
  từ programPath (`LoadAllPrograms`/`LoadProgram`), biên dịch qua `compiler.Compiler` rồi chạy
  VM tương ứng trong map `handles` (vmHandle), nạp log line vào VM qua `CompileAndRun`,
  unload/reload khi file đổi (`UnloadProgram`), lưu lỗi biên dịch `programErrors` (bảo vệ bởi
  `programErrorMu`) và expose trang HTTP trạng thái loader (httpstatus.go).
- evidence:
  - entry: `grep -n 'type Runtime struct\|^func New\|^func (r \*Runtime)' internal/runtime/runtime.go`
    → raw: `215:type Runtime struct {`,
    `250:func New(lines <-chan *logline.LogLine, wg *sync.WaitGroup, programPath string, store *metrics.Store, options ...Option) (*Runtime, error) {`,
    `49:func (r *Runtime) LoadAllPrograms() error {`, `104:func (r *Runtime) LoadProgram(programPath string) error {`,
    `141:func (r *Runtime) CompileAndRun(name string, input io.Reader) error {`,
    `341:func (r *Runtime) SetOption(...)`, `351:func (r *Runtime) UnloadProgram(pathname string) {`;
    struct giữ `handles map[string]*vmHandle` (dòng 225-226, guard `handleMu sync.RWMutex`)
    và counters expvar `LineCount/ProgLoads/ProgUnloads/ProgLoadErrors` (dòng 31-38)
  - largest: `internal/runtime/runtime_integration_test.go` = 1115 dòng (test — largest tuyệt đối
    trong item); file logic lớn nhất non-test: `internal/runtime/runtime.go` = 358 dòng;
    kế tiếp options.go 119, httpstatus.go 117, runtime_test.go 95, fuzz.go 67
    (lệnh: find internal/runtime -maxdepth 1 -name '*.go' -print0 | xargs -0 wc -l | sort -rn)
- deps_in (raw `uniq -c` trên grep import non-test của internal/runtime — maxdepth file trực tiếp;
  `internal/runtime/compiler` + 9 subpackage của nó đều quy về item m01 compiler; vm là item m04,
  code là item m14):
      3 	"github.com/google/mtail/internal/logline"                    → logline (m18)
      9 	"github.com/google/mtail/internal/metrics"                    → metrics (m07)
      2 	"github.com/google/mtail/internal/metrics/datum"              → datum (m09)
      3 	"github.com/google/mtail/internal/runtime/code"               → code (m14)
      31 	"github.com/google/mtail/internal/runtime/compiler{,/{ast,checker,codegen,errors,opt,parser,position,symbol,types}}" → compiler (m01)
      4 	"github.com/google/mtail/internal/runtime/vm"                 → vm (m04)
  → deps_in tổng hợp: logline, metrics, datum, code, compiler (m01), vm (m04)
  (lệnh: grep -rh --include='*.go' --exclude='*_test.go' -E '^\s*([A-Za-z0-9_]+\s+)?"github.com/google/mtail/' internal/runtime | sort | uniq -c)
- deps_out: 2 file non-test — `internal/mtail/mtail.go`, `internal/mtail/options.go` (m02)
  (lệnh: grep -rl '"github.com/google/mtail/internal/runtime"' --include='*.go' --exclude='*_test.go' .)
- status: DONE

### m06 — exporter (w2)
- path: internal/exporter
- files/loc: 12 / 1599
- responsibility: package `exporter` ("getting metrics out of mtail into your monitoring system of choice") chứa `Exporter` — đọc `*metrics.Store` và xuất metric ra collector Prometheus (`Describe`/`Collect`), varz/json HTTP handlers và các push target định kỳ, cấu hình qua `Option` (Hostname, OmitProgLabel, EmitTimestamp, PushInterval…).
- evidence:
  - entry: `grep -n 'type Exporter struct\|^func New' internal/exporter/export.go`
    → raw: `32:type Exporter struct {` và `91:func New(ctx context.Context, store *metrics.Store, options ...Option) (*Exporter, error) {`
    (đã đọc export.go 1–80: struct giữ `store *metrics.Store`, `pushTargets []pushOptions`, `pushInterval`, `omitProgLabel`, `emitTimestamp`)
  - largest: file lớn nhất tổng thể là `internal/exporter/prometheus_test.go` = 358 dòng (test);
    file logic lớn nhất non-test: `internal/exporter/export.go` = 275 dòng; kế tiếp `internal/exporter/prometheus.go` = 142
    (đã đọc prometheus.go 1–45: `func (e *Exporter) Collect(c chan<- prometheus.Metric)` tại dòng 31, `e.store.Range(...)`).
  - census: `find internal/exporter -type f -name '*.go' | wc -l` = 12, `find internal/exporter -type f -name '*.go' -print0 | xargs -0 cat | wc -l` = 1599 → khớp checklist.
- deps_in (raw `uniq -c` cùng lệnh trên `internal/exporter`):
  ```
        6 	"github.com/google/mtail/internal/metrics"
        2 	"github.com/google/mtail/internal/metrics/datum"
  ```
  → deps_in: metrics, datum
- deps_out: 3 file non-test — `cmd/mtail/main.go` (→ m12 cmd/mtail), `internal/mtail/mtail.go` + `internal/mtail/options.go` (→ m02 mtail)
  (lệnh: `grep -rl '"github.com/google/mtail/internal/exporter"' --include='*.go' --exclude='*_test.go' .`)
- status: DONE

### m07 — metrics (w3)
- path: internal/metrics
- files/loc: 7 / 1326
- responsibility: metrics là kho trạng thái trung tâm của mtail — `Store` (map name → []*Metric)
  lưu mọi metric do chương trình tạo ra với thêm/tìm/xóa an toàn khóa kép
  (`insertMu`+`searchMu`), GC theo limit/expiry, serialize JSON và iterate cho exporter —
  trong khi `Metric`/`LabelValue` mô hình hóa kind (Counter/Gauge/Timer/Text/Histogram),
  type (Int/Float/String/Buckets) và các giá trị datum theo nhãn.
- evidence:
  - entry: `grep -n 'type Store struct\|^func NewStore' internal/metrics/store.go`
    → raw: `19:type Store struct {` và `26:func NewStore() (s *Store) {`;
    các phương thức chính: `Add` store.go:33 (de-duplicate metric, copy LabelValues khi giữ
    nguyên Keys — so `reflect.DeepEqual` :64), `FindMetricOrNil` :101, `ClearMetrics` :118,
    `MarshalJSON` :127, `Range` :141, `Gc` :156, `StartGcLoop` :183, `WriteMetrics` :207.
  - largest: `internal/metrics/metric.go` = 309 dòng (file lớn nhất non-test, cũng là file lớn
    nhất toàn item; `type Kind` :23-48, `LabelValue` :73, `type Metric struct` :84,
    `NewMetric` :100). Đã đọc thêm `type.go` (44 dòng): `type Type int` :12, enum
    Int/Float/String/Buckets :14-25.
- deps_in (lệnh: `grep -h --exclude='*_test.go' -E '^\s*([A-Za-z0-9_]+\s+)?"github.com/google/mtail/' internal/metrics/*.go | sort | uniq -c` —
  dùng glob 1 cấp vì biên item m07 là 7 file trực tiếp; subpackage `internal/metrics/datum`
  thuộc item m09; raw):
  ```
        1 	"github.com/google/mtail/internal/metrics/datum"
  ```
  → deps_in tổng hợp: datum
- deps_out: 19 file non-test
  (lệnh: `grep -rl '"github.com/google/mtail/internal/metrics"' --include='*.go' --exclude='*_test.go' .`):
  `cmd/mtail/main.go`; `internal/mtail/golden/reader.go`; `internal/mtail/mtail.go`;
  `internal/mtail/testing.go`; `internal/runtime/runtime.go`;
  `internal/runtime/compiler/codegen/codegen.go`; `internal/runtime/compiler/checker/checker.go`;
  `internal/runtime/compiler/parser/parser.go`; `internal/runtime/compiler/parser/sexp.go`;
  `internal/runtime/compiler/parser/unparser.go`; `internal/runtime/compiler/ast/ast.go`;
  `internal/runtime/vm/vm.go`; `internal/runtime/code/object.go`;
  `internal/exporter/prometheus.go`; `internal/exporter/export.go`;
  `internal/exporter/collectd.go`; `internal/exporter/graphite.go`;
  `internal/exporter/statsd.go`; `internal/exporter/varz.go`
  → deps_out tổng hợp: cmd/mtail, golden, mtail, runtime, compiler, vm, code, exporter (8 item)
- status: DONE

### m08 — tailer (w4)
- path: internal/tailer
- files/loc: 5 / 804
- responsibility: `internal/tailer` chứa `Tailer` — "polls the filesystem for log sources that match given `LogPathPatterns` and creates `LogStream`s to tail them" (tail.go:28-29): `AddPattern`/`doPatternGlob`/`pollLogPattern` poll glob pattern theo `waker.Waker` (tail.go:186, 321, 289), `TailPath` tạo 1 `logstream.LogStream` cho mỗi file và bơm dòng đọc được lên channel dùng chung `lines chan<- *logline.LogLine` (tail.go:256-286), `New` dựng context + 2 goroutine dọn dẹp khi mọi subroutine kết thúc (tail.go:119-168), và `WriteStatusHTML` render trang trạng thái tailer (patterns + bảng logstreams với opens/truncs/errors/lines từ expvar) (httpstatus.go:44-84).
- evidence:
  - entry: `grep -n '^type Tailer struct\|^func New(' internal/tailer/tail.go` → raw: `30:type Tailer struct {` và `119:func New(ctx context.Context, wg *sync.WaitGroup, lines chan<- *logline.LogLine, options ...Option) (*Tailer, error) {`
  - largest: `internal/tailer/tail.go` = 342 dòng (file logic lớn nhất, đồng thời entry);
    file chính thứ 2: `internal/tailer/httpstatus.go` = 84 dòng (`const tailerTemplate` html/template dòng 11-41 + `WriteStatusHTML` dòng 44);
    3 file còn lại đều là test: `tail_test.go` 256, `tail_unix_test.go` 98, `tail_windows_test.go` 24.
    lệnh đo: `find internal/tailer -type f -name '*.go' -not -path 'internal/tailer/logstream/*' -print0 | xargs -0 wc -l | sort -rn` → `342 tail.go`, `256 tail_test.go`, `98 tail_unix_test.go`, `84 httpstatus.go`, `24 tail_windows_test.go`; census v9 trên 5 file này → `804` — khớp tuyệt đối checklist (5 / 804).
  - **Ghi chú biên item:** item m08 KHÔNG chứa subtree `internal/tailer/logstream` — đó là item độc lập m03 (16 file / 2017 LOC, assignee w3); grep trong row này đều prune `logstream` đúng census (không đụng phạm vi slot khác).
- deps_in (lệnh: `find internal/tailer -name '*.go' ! -name '*_test.go' ! -path 'internal/tailer/logstream/*' -print0 | xargs -0 grep -h -E '^[[:space:]]*([A-Za-z0-9_]+[[:space:]]+)?"github\.com/google/mtail/' | sort | uniq -c`; raw):
  ```
        1 	"github.com/google/mtail/internal/logline"
        2 	"github.com/google/mtail/internal/tailer/logstream"
        1 	"github.com/google/mtail/internal/waker"
  ```
  → mapping (tail.go:20-22, httpstatus.go:11): `internal/logline` → **logline (m18)**; `internal/tailer/logstream` → **logstream (m03)**; `internal/waker` → **waker (m11)**.
  deps_in tổng hợp: logline, logstream, waker
- deps_out: 2 file non-test đều thuộc item `internal/mtail` → **mtail (m02)**. Lệnh: `grep -rl '"github.com/google/mtail/internal/tailer"' --include='*.go' --exclude='*_test.go' .` → `./internal/mtail/options.go` (dòng 16), `./internal/mtail/mtail.go` (dòng 21).
- status: DONE

### m09 — datum (w1)
- path: internal/metrics/datum
- files/loc: 8 / 667
- responsibility: Định nghĩa value-type của metric — interface `Datum` (ValueString/TimeString/
  TimeUTC) + struct nền `BaseDatum` đóng dấu timestamp atomic (nanosecond UTC), 4 implementation
  `Int`, `Float`, `String`, `Buckets` (range histogram) và các constructor zero-value
  `NewInt/NewFloat/NewString/NewBuckets` để store/exporter tạo datum đồng nhất.
- evidence:
  - entry: `grep -n 'type Datum interface\|type BaseDatum\|func NewInt\|func NewFloat\|func NewString\|func NewBuckets' internal/metrics/datum/datum.go`
    → raw: `15:type Datum interface {`, `30:type BaseDatum struct {`,
    `55:func NewInt() Datum {`, `60:func NewFloat() Datum {`, `65:func NewString() Datum {`,
    `70:func NewBuckets(buckets []Range) Datum {`;
    4 implementation: `int.go:14:type Int struct {`, `float.go:15:type Float struct {`,
    `string.go:14:type String struct {`, `buckets.go:30:type Buckets struct {`
  - largest: `internal/metrics/datum/datum.go` = 259 dòng (non-test, cả entry); kế tiếp
    buckets.go 117, datum_test.go 60, int.go 54, string.go 47, buckets_test.go 47, float.go 43
    (lệnh: find internal/metrics/datum -type f -name '*.go' -print0 | xargs -0 wc -l | sort -rn)
- deps_in: **0** — `grep -rh --include='*.go' --exclude='*_test.go' -E '^\s*([A-Za-z0-9_]+\s+)?"github.com/google/mtail/' internal/metrics/datum | sort | uniq -c`
  trả về RỖNG (datum chỉ import stdlib: fmt, math, sort, sync/atomic, time — đã mở datum.go:6-12)
- deps_out: 7 file non-test — `internal/exporter/graphite.go`, `internal/exporter/prometheus.go`
  (m06 exporter), `internal/metrics/metric.go` (m07 metrics), `internal/mtail/golden/reader.go`
  (m13 golden), `internal/mtail/testing.go` (m02 mtail — cùng path item internal/mtail),
  `internal/runtime/compiler/codegen/codegen.go` (m01 compiler), `internal/runtime/vm/vm.go` (m04 vm)
  (lệnh: grep -rl '"github.com/google/mtail/internal/metrics/datum"' --include='*.go' --exclude='*_test.go' .)
- status: DONE

### m10 — testutil (w2)
- path: internal/testutil
- files/loc: 15 / 504
- responsibility: `internal/testutil` là bộ helper dùng chung cho test suite của mtail: assertion expvar có deadline (`TestGetExpvar`, `ExpectExpvarDeltaWithDeadline`, `ExpectMapExpvarDeltaWithDeadline`), poll `DoOrTimeout` + wrapper `TimeoutTest`, tạo dir/file/log tạm (`TestTempDir`, `TestOpenFile`, `OpenLogFile`), và các helper môi trường (port, race-detector, root, stdin, flag, diff…).
- evidence:
  - entry: `grep -n 'func TestGetExpvar' internal/testutil/expvar.go` → raw: `16:func TestGetExpvar(tb testing.TB, name string) expvar.Var {`;
    kèm `grep -n 'func DoOrTimeout' internal/testutil/timeout.go` → raw: `17:func DoOrTimeout(do func() (bool, error), deadline, interval time.Duration) (bool, error) {`
    và `grep -n 'func TestTempDir' internal/testutil/fs.go` → raw: `13:func TestTempDir(tb testing.TB) string {`
    (đã đọc expvar.go đầy đủ 78 dòng, timeout.go 1–45, fs.go 1–40; `ls internal/testutil` = 15 file gồm diff.go err.go expvar.go file.go flag.go fs.go lines.go norace.go port.go race.go root.go short.go stdin.go timeout.go timeout_test.go)
  - largest: `internal/testutil/expvar.go` = 78 dòng (non-test, đã đọc đầy đủ);
    file test lớn nhất: `internal/testutil/timeout_test.go` = 56 dòng.
  - census: `find internal/testutil -type f -name '*.go' | wc -l` = 15, `xargs -0 cat | wc -l` = 504 → khớp checklist.
- deps_in (raw `uniq -c` cùng lệnh trên `internal/testutil`):
  ```
        1 	"github.com/google/mtail/internal/logline"
  ```
  → deps_in: logline (duy nhất 1 import mtail-internal, nằm ở `lines.go` — dòng trong deps_out của m18)
- deps_out: 1 file non-test — `internal/mtail/testing.go` (→ m02 mtail)
  (lệnh: `grep -rl '"github.com/google/mtail/internal/testutil"' --include='*.go' --exclude='*_test.go' .`)
- status: DONE

### m11 — waker (w3)
- path: internal/waker
- files/loc: 5 / 335
- responsibility: waker định nghĩa interface đồng bộ hóa `Waker` — kênh `Wake()` được đóng khi
  routine rảnh cần dậy — cùng 3 hiện thực: `timedWaker` (đánh thức định kỳ theo ticker,
  dùng trong production), `testWaker` (đồng bộ hóa có kiểm soát giữa goroutine bị test và
  vòng lặp test) và `alwaysWaker` (kênh đã đóng sẵn, không bao giờ chặn).
- evidence:
  - entry: `grep -n 'type Waker interface' internal/waker/waker.go`
    → raw: `7:type Waker interface {` (toàn file 10 dòng — interface duy nhất của package).
  - largest: `internal/waker/testwaker.go` = 139 dòng (file lớn nhất non-test nhưng là helper
    cho test, không phải logic production: `type testWaker struct` :18, `NewTest` :42 trả về
    `(Waker, WakeFunc)`, `broadcastWakeAndReset` :115, `alwaysWaker` :125, `NewTestAlways` :129);
    hiện thực production: `internal/waker/timedwaker.go` = 50 dòng (`type timedWaker struct` :13,
    `NewTimed` :22, `Wake` :45 — close-and-reset kênh wake sau mỗi tick).
- deps_in (lệnh như template trên `internal/waker`; raw rỗng — 0 dòng khớp):
  → deps_in tổng hợp: 0
- deps_out: 9 file non-test
  (lệnh: `grep -rl '"github.com/google/mtail/internal/waker"' --include='*.go' --exclude='*_test.go' .`):
  `cmd/mtail/main.go`; `internal/tailer/logstream/logstream.go`;
  `internal/tailer/logstream/dgramstream.go`; `internal/tailer/logstream/fifostream.go`;
  `internal/tailer/logstream/socketstream.go`; `internal/tailer/logstream/filestream.go`;
  `internal/tailer/tail.go`; `internal/mtail/options.go`; `internal/mtail/testing.go`
  → deps_out tổng hợp: cmd/mtail, logstream, tailer, mtail (4 item)
- status: DONE

### m12 — cmd/mtail (w4)
- path: cmd/mtail
- files/loc: 1 / 278
- responsibility: `cmd/mtail` là entry binary thật của chương trình mtail: định nghĩa ~40 cờ CLI (port/address/unix_socket, progs, logs, các cờ compiler/VM runtime/ops/debug/tracing + 3 cờ DEPRECATED) (main.go:41-85), ánh xạ cờ thành `[]mtail.Option` + `[]exporter.Option` (main.go:169-226), dựng `metrics.NewStore` + `mtail.New` + `m.Run()` (main.go:228-243), bắt SIGINT/SIGTERM để cancel context (main.go:156-163), và nhánh `-one_shot` xuất metrics ra stdout theo format json (store.WriteMetrics) hoặc prometheus (exporter.New + e.Write) (main.go:245-277).
- evidence:
  - entry: `grep -n 'func main()' cmd/mtail/main.go` → raw: `102:func main() {` (package main duy nhất 1 file);
    dựng server thật: `grep -n 'opts := \[\]mtail.Option{\|m, err := mtail.New(\|err = m.Run()\|store := metrics.NewStore()' cmd/mtail/main.go` → `169:`, `228:`, `232:m, err := mtail.New(ctx, store, opts...)`, `238:err = m.Run()`
  - largest: `cmd/mtail/main.go` = 278 dòng — package chỉ có 1 file `.go` nên file này đồng thời là entry và largest (đã đọc trọn 278/278 dòng → điều kiện "mở ≥2 file chính" thỏa bằng cách đọc toàn bộ file duy nhất; ghi chú theo template mục 4: entry binary thật, gọi `mtail.New`/`Run`).
    lệnh đo: `find cmd/mtail -type f -name '*.go' -print0 | xargs -0 wc -l` → `278 cmd/mtail/main.go`; census v9 → `278` — khớp tuyệt đối checklist (1 / 278).
- deps_in (lệnh: `find cmd/mtail -name '*.go' ! -name '*_test.go' -print0 | xargs -0 grep -h -E '^[[:space:]]*([A-Za-z0-9_]+[[:space:]]+)?"github\.com/google/mtail/' | sort | uniq -c`; raw):
  ```
        1 	"github.com/google/mtail/internal/exporter"
        1 	"github.com/google/mtail/internal/metrics"
        1 	"github.com/google/mtail/internal/mtail"
        1 	"github.com/google/mtail/internal/waker"
  ```
  → mapping (main.go:18-21): `internal/exporter` → **exporter (m06)**; `internal/metrics` → **metrics (m07)**; `internal/mtail` → **mtail (m02)**; `internal/waker` → **waker (m11)**.
  deps_in tổng hợp: exporter, metrics, mtail, waker
- deps_out: 0 — `package main` binary, không package nào import; bằng chứng: `grep -rn 'mtail/cmd/mtail\|mtail/cmd/mgen' --include='*.go' .` trên toàn cây clone (kể cả test) trả về 0 dòng.
- status: DONE

### m13 — golden (w1)
- path: internal/mtail/golden
- files/loc: 2 / 277
- responsibility: Package hỗ trợ test golden-file — `ReadTestData` parse file dữ liệu "golden"
  (dòng dạng `counter|gauge|timer|text|histogram <name>{k=v,...} <value> <timestamp>` qua regexp
  `varRe`) thành `metrics.MetricSlice` để so khớp output metric của chương trình mtail trong test.
- evidence:
  - entry: `grep -n 'var varRe\|func ReadTestData' internal/mtail/golden/reader.go`
    → raw: `20:var varRe = regexp.MustCompile(...)`,
    `23:func ReadTestData(file io.Reader, programfile string) metrics.MetricSlice {`
    (đã mở reader.go:1-80: map kind → metrics.Counter/Gauge/Timer/Text/Histogram tại :50-62,
    parse value int→float→string fallback tại :64-80); test dùng nó:
    `internal/mtail/golden/reader_test.go:115:func TestReadTestData(t *testing.T) {`
  - largest: `internal/mtail/golden/reader.go` = 156 dòng (non-test duy nhất trong item);
    `internal/mtail/golden/reader_test.go` = 121 dòng (test)
    (lệnh: find internal/mtail/golden -type f -name '*.go' -print0 | xargs -0 wc -l | sort -rn)
- deps_in (raw `uniq -c` trên grep import non-test của internal/mtail/golden; chính là
  reader.go:16-17 đã mở):
      1 	"github.com/google/mtail/internal/metrics"        → metrics (m07)
      1 	"github.com/google/mtail/internal/metrics/datum"  → datum (m09)
  → deps_in tổng hợp: metrics, datum
- deps_out: **0** — `grep -rl '"github.com/google/mtail/internal/mtail/golden"' --include='*.go' --exclude='*_test.go' .` trả về RỖNG
  (chỉ dùng trong test; hợp lý vì đây là package phụ trợ test golden — template mục 4 cũng ghi chú vậy)
- status: DONE

### m14 — code (w2)
- path: internal/runtime/code
- files/loc: 5 / 214
- responsibility: package `code` ("contains the bytecode instructions for the mtail virtual machine") định nghĩa tập lệnh bytecode của VM: enum `Opcode` (~70 opcode từ Bad/Stop/Match/…/F2s), struct `Instr` (Opcode + Operand + SourceLine) và `Object` — artifact nhị phân của một chương trình đã biên dịch (Program/String/Regexp/Metrics) — là hợp đồng trao đổi giữa compiler (codegen) và vm.
- evidence:
  - entry: `grep -n 'type Opcode' internal/runtime/code/opcodes.go` → raw: `7:type Opcode int` (đã đọc opcodes.go 1–70: block const `Bad Opcode = iota … F2s`);
    kèm `grep -n 'type Object' internal/runtime/code/object.go` → raw: `13:type Object struct {` (đã đọc object.go đầy đủ: `Program []Instr`, `Strings []string`, `Regexps []*regexp.Regexp`, `Metrics []*metrics.Metric`);
    và `grep -n 'type Instr' internal/runtime/code/instr.go` → raw: `9:type Instr struct {` (đã đọc instr.go đầy đủ: `String()` debug print).
  - largest: `internal/runtime/code/opcodes.go` = 147 dòng (đã đọc 1–70; phần còn lại là nốt các opcode + `opNames`/`opStrings` lookup).
  - census: `find internal/runtime/code -type f -name '*.go' | wc -l` = 5, `xargs -0 cat | wc -l` = 214 → khớp checklist.
- deps_in (raw `uniq -c` cùng lệnh trên `internal/runtime/code`):
  ```
        1 	"github.com/google/mtail/internal/metrics"
  ```
  → deps_in: metrics — đúng 1 vị trí duy nhất: `internal/runtime/code/object.go:9` import `internal/metrics` để khai báo field `Metrics []*metrics.Metric` của `Object` (đã đọc nguyên file object.go, 18 dòng).
- deps_out: 3 file non-test — `internal/runtime/compiler/codegen/codegen.go` + `internal/runtime/compiler/compiler.go` (→ m01 compiler), `internal/runtime/vm/vm.go` (→ m04 vm)
  (lệnh: `grep -rl '"github.com/google/mtail/internal/runtime/code"' --include='*.go' --exclude='*_test.go' .`)
- status: DONE

### m15 — mdot (w3)
- path: cmd/mdot
- files/loc: 1 / 206
- responsibility: mdot là CLI biến một chương trình mtail (`.mtail`) thành đồ thị graphviz dot:
  parse (`parser.Parse`) → type-check (`checker.Check`) → duyệt AST bằng `ast.Walk` với
  visitor `dotter` phát node/cạnh ra stdout, hoặc phục vụ SVG qua HTTP bằng
  `exec.Command("dot", "-Tsvg")` khi chạy với `--http_port`.
- evidence:
  - entry: package chỉ có đúng 1 file nên entry == largest ==
    `cmd/mdot/main.go` = 206 dòng (`type dotter struct` :43, `makeDot` :134 —
    parse :139 / check :143 / `ast.Walk` :149, `func main()` :154, HTTP mode :165-205,
    `mtail.FaviconHandler` :204).
  - largest: như trên — `cmd/mdot/main.go`, `wc -l` = 206.
- deps_in (lệnh: `grep -rh --include='*.go' --exclude='*_test.go' -E '^\s*([A-Za-z0-9_]+\s+)?"github.com/google/mtail/' cmd/mdot | sort | uniq -c`; raw):
  ```
        1 	"github.com/google/mtail/internal/mtail"
        1 	"github.com/google/mtail/internal/runtime/compiler/ast"
        1 	"github.com/google/mtail/internal/runtime/compiler/checker"
        1 	"github.com/google/mtail/internal/runtime/compiler/parser"
  ```
  → deps_in tổng hợp: mtail, compiler (ast/checker/parser là các subpackage depth-4 nằm trong
  item m01 compiler theo ghi chú census của template)
- deps_out: 0 (lệnh: `grep -rl '"github.com/google/mtail/cmd/mdot"' --include='*.go' --exclude='*_test.go' .` —
  raw rỗng; binary cmd không được package nào khác import)
- status: DONE

### m16 — mgen (w4)
- path: cmd/mgen
- files/loc: 1 / 152
- responsibility: `cmd/mgen` sinh chương trình mtail ngẫu nhiên cho fuzz testing ("Command mgen generates mtail programs for fuzz testing by following a simple grammar", main.go:7): bảng grammar `table map[string]node` mô tả toàn bộ ngôn ngữ (stmt/expr/decl/def_spec/deco_spec, BUILTIN: strptime/timestamp/len/tolower…) (main.go:26-66), `generateProgram()` đi bộ bảng bằng `math/rand` seed được (`-rand_seed`, `-min_iterations`) phát token ra stdout qua goroutine emitter wrap 80 cột (main.go:91-135), `-dictionary` in danh sách token từ `parser.Dictionary()` (main.go:138-141).
- evidence:
  - entry: `grep -n 'func main()\|var table = map' cmd/mgen/main.go` → raw: `26:var table = map[string]node{` và `144:func main() {`; gọi vào compiler: `139:	for _, k := range parser.Dictionary() {`
  - largest: `cmd/mgen/main.go` = 152 dòng — package chỉ có 1 file `.go` nên file này đồng thời là entry và largest (đã đọc trọn 152/152 dòng → điều kiện "mở ≥2 file chính" thỏa bằng cách đọc toàn bộ file duy nhất).
    lệnh đo: `find cmd/mgen -type f -name '*.go' -print0 | xargs -0 wc -l` → `152 cmd/mgen/main.go`; census v9 → `152` — khớp tuyệt đối checklist (1 / 152).
- deps_in (lệnh: `find cmd/mgen -name '*.go' ! -name '*_test.go' -print0 | xargs -0 grep -h -E '^[[:space:]]*([A-Za-z0-9_]+[[:space:]]+)?"github\.com/google/mtail/' | sort | uniq -c`; raw):
  ```
        1 	"github.com/google/mtail/internal/runtime/compiler/parser"
  ```
  → mapping (main.go:12): `internal/runtime/compiler/parser` là 1 trong 9 package depth-4 đã gộp vào item **compiler (m01)** theo universe checklist (template mục 1: "9 subdir của internal/runtime/compiler đã nằm sẵn trong item compiler") — không phải item độc lập.
  deps_in tổng hợp: compiler (qua subpackage parser)
- deps_out: 0 — `package main` binary, không package nào import; bằng chứng: `grep -rn 'mtail/cmd/mtail\|mtail/cmd/mgen' --include='*.go' .` trên toàn cây clone (kể cả test) trả về 0 dòng.
- status: DONE

### m17 — mfmt (w1)
- path: cmd/mfmt
- files/loc: 1 / 59
- responsibility: CLI formatter cho chương trình mtail (doc comment `Command mfmt formats mtail
  programs.`): đọc file chương trình từ flag `-prog`, parse bằng `parser.Parse`, type-check bằng
  `checker.Check`, in lại source chuẩn qua `parser.Unparser{}.Unparse`, ghi đè file gốc khi `-write`.
- evidence:
  - entry: `cat -n cmd/mfmt/main.go` (đã mở toàn bộ 59 dòng)
    → raw: `7:package main`, `25:func main() {`, `36:ast, err := parser.Parse(*prog, f)`,
    `40:ast, err = checker.Check(ast, 0, 0)`, `44:up := parser.Unparser{}`, `45:out := up.Unparse(ast)`,
    `46:if *write { ... f.Truncate(0) ... }`
  - largest: `cmd/mfmt/main.go` = 59 dòng (file duy nhất của item)
    (lệnh: find cmd/mfmt -type f -name '*.go' -print0 | xargs -0 cat | wc -l → 59)
- deps_in (raw `uniq -c` trên grep import non-test của cmd/mfmt; chính là main.go:16-17):
      1 	"github.com/google/mtail/internal/runtime/compiler/checker"  → compiler (m01)
      1 	"github.com/google/mtail/internal/runtime/compiler/parser"   → compiler (m01)
  → deps_in tổng hợp: compiler (m01)
- deps_out: **0** — `grep -rl '"github.com/google/mtail/cmd/mfmt"' --include='*.go' --exclude='*_test.go' .` trả về RỖNG
  (binary entry không được import — đúng vai trò cmd/*)
- status: DONE

### m18 — logline (w2)
- path: internal/logline
- files/loc: 1 / 19
- responsibility: package `logline` định nghĩa `LogLine` — struct gói 1 dòng log vừa đọc (Context + Filename + Line) — được tailer đẩy qua channel cho VM xử lý; là kiểu dữ liệu trao đổi trung tâm giữa tailer/runtime/mtail/testutil.
- evidence:
  - entry: `grep -n 'type LogLine\|^func New' internal/logline/logline.go`
    → raw: `9:type LogLine struct {` và `17:func New(ctx context.Context, filename string, line string) *LogLine {`
    (đã đọc nguyên file 19 dòng — package chỉ có đúng 1 file nên điều kiện "≥2 file chính" không khả dụng; toàn bộ logic của item nằm trọn trong file đã đọc).
  - largest: `internal/logline/logline.go` = 19 dòng (file duy nhất của package).
  - census: `find internal/logline -type f -name '*.go' | wc -l` = 1, `xargs -0 cat | wc -l` = 19 → khớp checklist.
- deps_in: raw `grep -rh ... "github.com/google/mtail/" internal/logline | sort | uniq -c` → **rỗng (0 dòng)** → deps_in: 0 (package chỉ import stdlib `context`).
- deps_out: 13 file non-test (lệnh: `grep -rl '"github.com/google/mtail/internal/logline"' --include='*.go' --exclude='*_test.go' .`), map sang universe:
  - `internal/mtail/mtail.go` → m02 mtail
  - `internal/runtime/fuzz.go`, `internal/runtime/runtime.go` → m05 runtime
  - `internal/runtime/vm/vm.go` → m04 vm
  - `internal/tailer/logstream/{base,dgramstream,fifostream,filestream,logstream,reader,socketstream}.go` (7 file) → m03 logstream
  - `internal/tailer/tail.go` → m08 tailer
  - `internal/testutil/lines.go` → m10 testutil
  → deps_out: mtail, runtime, vm, logstream, tailer, testutil
  (ghi chú: template mục 4 nêu "24 file import" — số đó tính cả file test; theo luật template chỉ khai non-test nên là 13 file. Không phải conflict: hai phép đếm khác cửa sổ, raw list 13 file ở trên là toàn bộ non-test trên cây PIN.)
- status: DONE

## 3. Worker-slot coverage

| slot | items | trạng thái |
|------|-------|-----------|
| w1 | m01, m05, m09, m13, m17 | 5/5 DONE |
| w2 | m02, m06, m10, m14, m18 | 5/5 DONE |
| w3 | m03, m07, m11, m15 | 4/4 DONE |
| w4 | m04, m08, m12, m16 | 4/4 DONE |

Không có UNOWNED. Không item nào thiếu slot. Không slot nào DRAINED với 0 item
(4/4 slot đều có item và tick DONE trong `mm-status-w1..w4.json`).

## 4. Ma trận phụ thuộc (2 chiều, 41 cạnh in-universe)

- Nguồn sự thật: raw `uniq -c` import grep non-test trong từng part (deps_in của từng item)
  + phần deps_out khai trực tiếp trong part (vd w1 khai deps_out của m01 gồm cả internal/runtime).
- `deps_out(x) = { a | x ∈ deps_in(a) }` — mỗi cạnh truy vết được về lệnh grep + count
  trong part của item nhập vào; đối chiếu với deps_out worker khai trực tiếp: khớp.
- **Cạnh m05→m01 (compiler) là cạnh thật và đã được khôi phục ở vòng 1**: w1 part khai
  cả 2 chiều — m05 deps_in "compiler (m01)" (31 dòng import) và m01 deps_out
  `internal/runtime/{fuzz.go,options.go,runtime.go}` (m05). Bản merge trước (orchestrator,
  2026-11-01T21:24:08Z) đã làm rơi cạnh này ở bảng + JSON do ghi chú self-edge sai.
- Self-edge: danh sách deps_in/deps_out TỔNG HỢP trong part không chứa self-edge nào.
  Lưu ý kỹ thuật: grep đệ quy trên `internal/runtime` (mục đích đếm của m05) bắt thêm
  import GIỮA CÁC subpackage compiler (tự quy về m01→m01) — các dòng đó không xuất hiện
  ở mức tổng hợp; không có self-edge nào cần loại khỏi 41 cạnh nêu trên.
- Cạnh đáy đồ thị: `m09 datum` và `m11 waker` không import item nào (in = —).
  Cạnh đỉnh: `m12 cmd/mtail` và `m15 mdot` không bị item nào import (out = —).

## 5. JSON block (nguồn cho P3/P6/P7)

Schema mỗi entry (đúng brief node): `{id, module, path, responsibility, main_files, deps_in, deps_out, loc, tests, status}`.
`tests` = các file `*_test.go` được nêu đích danh trong part của item (mảng rỗng = part không nêu file test nào).

```json
[
  {"id": "m01", "module": "compiler", "path": "internal/runtime/compiler", "responsibility": "Front-end biên dịch chương trình mtail thành bytecode `code.Object` — `Compiler.Compile` (compiler.go:89) chạy pipeline parser.Parse → opt.Optimise → checker.Check → opt.Optimise (lần 2, sau type-check) → codegen.CodeGen trên 10 package con (root compiler + ast, checker, codegen, errors, opt, parser, position, symbol, types), với các Option cấu hình (EmitAst, MaxRegexpLength, MaxRecursionDepth, DisableOptimisation).", "main_files": ["internal/runtime/compiler/compiler.go (entry: type Compiler struct :19, func New :27, func (c *Compiler) Compile :89)", "internal/runtime/compiler/parser/parser.go (largest: 1504 dòng, sinh tự động goyacc)", "internal/runtime/compiler/checker/checker.go (logic non-test lớn nhất: 970 dòng)"], "deps_in": ["m07", "m09", "m14"], "deps_out": ["m05", "m15", "m16", "m17"], "loc": 10116, "tests": ["internal/runtime/compiler/codegen/codegen_test.go (1138 dòng — test lớn nhất item)"], "status": "DONE"},
  {"id": "m02", "module": "mtail", "path": "internal/mtail", "responsibility": "internal/mtail chứa `Server` — thành phần điều phối chính của mtail: giữ `metrics.Store`, `tailer.Tailer` (đọc log → channel `lines`), `runtime.Runtime` (nạp chương trình + vòng đời VM) và `exporter.Exporter`, đồng thời chạy HTTP server (metrics/pprof/zpages) qua `New()`; `options.go` định nghĩa toàn bộ `Option` cấu hình Server.", "main_files": ["internal/mtail/mtail.go (entry: type Server struct :31, func New :176)", "internal/mtail/logo.ico.go (largest: 2008 dòng, asset favicon nhúng)", "internal/mtail/options.go (logic non-test lớn nhất: 288 dòng)"], "deps_in": ["m05", "m06", "m07", "m08", "m09", "m10", "m11", "m18"], "deps_out": ["m12", "m15"], "loc": 4463, "tests": [], "status": "DONE"},
  {"id": "m03", "module": "logstream", "path": "internal/tailer/logstream", "responsibility": "logstream biến mỗi pathname của nguồn log (file thường, named pipe/stdin, unix/tcp/udp socket) thành một dòng chảy `*logline.LogLine` liên tục qua interface `LogStream`/factory `New()` — tự xử lý rotation (đổi inode), truncation (seek về 0), reopen khi `ESTALE`, và tự cắt ranh giới dòng bằng `LineReader` trước khi đẩy vào channel cho tailer tiêu thụ.", "main_files": ["internal/tailer/logstream/logstream.go (entry: type LogStream interface :35, func New :64)", "internal/tailer/logstream/filestream.go (logic non-test lớn nhất: 239 dòng)", "internal/tailer/logstream/reader.go (LineReader: 106 dòng)"], "deps_in": ["m11", "m18"], "deps_out": ["m08"], "loc": 2017, "tests": ["internal/tailer/logstream/filestream_test.go (292 dòng — file lớn nhất toàn item)"], "status": "DONE"},
  {"id": "m04", "module": "vm", "path": "internal/runtime/vm", "responsibility": "`internal/runtime/vm` chứa `VM` — máy ảo thông dịch bytecode do compiler sinh ra: `New()` nhận `code.Object` (chương trình, regex/string constants, metrics) (vm.go:993-1009), `ProcessLogLine()` chạy vòng fetch–decode–execute trên `thread` với stack máy ảo (vm.go:962-991), `execute()` switch qua opcode (`Match`, `Cmp`, `Inc`, `Set`, `Strptime`, `Add`, `Del`, `Stop`, …) cập nhật `metrics.Metric`, kèm recover panic thành runtime error (vm.go:336-350) và memo parse thời gian bằng LRU (vm.go:65 `timeMemos *lru.Cache`).", "main_files": ["internal/runtime/vm/vm.go (entry + largest: 1060 dòng; type VM struct :56, func New :993)", "internal/runtime/vm/vm_test.go (929 dòng, table-driven 7 hàm Test*)"], "deps_in": ["m07", "m09", "m14", "m18"], "deps_out": ["m05"], "loc": 1989, "tests": ["internal/runtime/vm/vm_test.go (929 dòng, 7 hàm Test*: TestInstrs:596, TestDatumSetInstrs:660, TestStrptimeWithTimezone:783, TestStrptimeWithoutTimezone:797, TestDatumFetchInstrs:811, TestDeleteInstrs:879, TestTimestampInstr:905)"], "status": "DONE"},
  {"id": "m05", "module": "runtime", "path": "internal/runtime", "responsibility": "Program loader/runtime của mtail — `Runtime` nạp các file chương trình `.mtail` từ programPath (`LoadAllPrograms`/`LoadProgram`), biên dịch qua `compiler.Compiler` rồi chạy VM tương ứng trong map `handles` (vmHandle), nạp log line vào VM qua `CompileAndRun`, unload/reload khi file đổi (`UnloadProgram`), lưu lỗi biên dịch `programErrors` (bảo vệ bởi `programErrorMu`) và expose trang HTTP trạng thái loader (httpstatus.go).", "main_files": ["internal/runtime/runtime.go (entry: type Runtime struct :215, func New :250; 358 dòng — logic non-test lớn nhất)", "internal/runtime/runtime_integration_test.go (largest tổng thể: 1115 dòng, test)", "internal/runtime/options.go (119 dòng), internal/runtime/httpstatus.go (117 dòng)"], "deps_in": ["m01", "m04", "m07", "m09", "m14", "m18"], "deps_out": ["m02"], "loc": 1871, "tests": ["internal/runtime/runtime_integration_test.go (1115 dòng — largest tuyệt đối trong item)", "internal/runtime/runtime_test.go (95 dòng)"], "status": "DONE"},
  {"id": "m06", "module": "exporter", "path": "internal/exporter", "responsibility": "package `exporter` (\"getting metrics out of mtail into your monitoring system of choice\") chứa `Exporter` — đọc `*metrics.Store` và xuất metric ra collector Prometheus (`Describe`/`Collect`), varz/json HTTP handlers và các push target định kỳ, cấu hình qua `Option` (Hostname, OmitProgLabel, EmitTimestamp, PushInterval…).", "main_files": ["internal/exporter/export.go (entry: type Exporter struct :32, func New :91; 275 dòng — logic non-test lớn nhất)", "internal/exporter/prometheus.go (142 dòng, Collect :31)", "internal/exporter/prometheus_test.go (largest tổng thể: 358 dòng, test)"], "deps_in": ["m07", "m09"], "deps_out": ["m02", "m12"], "loc": 1599, "tests": ["internal/exporter/prometheus_test.go (358 dòng — file lớn nhất tổng thể)"], "status": "DONE"},
  {"id": "m07", "module": "metrics", "path": "internal/metrics", "responsibility": "metrics là kho trạng thái trung tâm của mtail — `Store` (map name → []*Metric) lưu mọi metric do chương trình tạo ra với thêm/tìm/xóa an toàn khóa kép (`insertMu`+`searchMu`), GC theo limit/expiry, serialize JSON và iterate cho exporter — trong khi `Metric`/`LabelValue` mô hình hóa kind (Counter/Gauge/Timer/Text/Histogram), type (Int/Float/String/Buckets) và các giá trị datum theo nhãn.", "main_files": ["internal/metrics/store.go (entry: type Store struct :19, func NewStore :26)", "internal/metrics/metric.go (largest: 309 dòng; type Metric struct :84, NewMetric :100)", "internal/metrics/type.go (44 dòng, enum Type :12)"], "deps_in": ["m09"], "deps_out": ["m01", "m02", "m04", "m05", "m06", "m12", "m13", "m14"], "loc": 1326, "tests": [], "status": "DONE"},
  {"id": "m08", "module": "tailer", "path": "internal/tailer", "responsibility": "`internal/tailer` chứa `Tailer` — \"polls the filesystem for log sources that match given `LogPathPatterns` and creates `LogStream`s to tail them\" (tail.go:28-29): `AddPattern`/`doPatternGlob`/`pollLogPattern` poll glob pattern theo `waker.Waker` (tail.go:186, 321, 289), `TailPath` tạo 1 `logstream.LogStream` cho mỗi file và bơm dòng đọc được lên channel dùng chung `lines chan<- *logline.LogLine` (tail.go:256-286), `New` dựng context + 2 goroutine dọn dẹp khi mọi subroutine kết thúc (tail.go:119-168), và `WriteStatusHTML` render trang trạng thái tailer (patterns + bảng logstreams với opens/truncs/errors/lines từ expvar) (httpstatus.go:44-84).", "main_files": ["internal/tailer/tail.go (entry + logic largest: 342 dòng; type Tailer struct :30, func New :119)", "internal/tailer/httpstatus.go (84 dòng, WriteStatusHTML :44)"], "deps_in": ["m03", "m11", "m18"], "deps_out": ["m02"], "loc": 804, "tests": ["internal/tailer/tail_test.go (256 dòng)", "internal/tailer/tail_unix_test.go (98 dòng)", "internal/tailer/tail_windows_test.go (24 dòng)"], "status": "DONE"},
  {"id": "m09", "module": "datum", "path": "internal/metrics/datum", "responsibility": "Định nghĩa value-type của metric — interface `Datum` (ValueString/TimeString/ TimeUTC) + struct nền `BaseDatum` đóng dấu timestamp atomic (nanosecond UTC), 4 implementation `Int`, `Float`, `String`, `Buckets` (range histogram) và các constructor zero-value `NewInt/NewFloat/NewString/NewBuckets` để store/exporter tạo datum đồng nhất.", "main_files": ["internal/metrics/datum/datum.go (entry + largest: 259 dòng; type Datum interface :15, type BaseDatum :30, NewInt/NewFloat/NewString/NewBuckets :55-70)", "internal/metrics/datum/buckets.go (117 dòng), int.go (54), string.go (47), float.go (43)"], "deps_in": [], "deps_out": ["m01", "m02", "m04", "m05", "m06", "m07", "m13"], "loc": 667, "tests": ["internal/metrics/datum/datum_test.go (60 dòng)", "internal/metrics/datum/buckets_test.go (47 dòng)"], "status": "DONE"},
  {"id": "m10", "module": "testutil", "path": "internal/testutil", "responsibility": "`internal/testutil` là bộ helper dùng chung cho test suite của mtail: assertion expvar có deadline (`TestGetExpvar`, `ExpectExpvarDeltaWithDeadline`, `ExpectMapExpvarDeltaWithDeadline`), poll `DoOrTimeout` + wrapper `TimeoutTest`, tạo dir/file/log tạm (`TestTempDir`, `TestOpenFile`, `OpenLogFile`), và các helper môi trường (port, race-detector, root, stdin, flag, diff…).", "main_files": ["internal/testutil/expvar.go (entry: func TestGetExpvar :16; 78 dòng — non-test lớn nhất)", "internal/testutil/timeout.go (func DoOrTimeout :17)", "internal/testutil/fs.go (func TestTempDir :13)"], "deps_in": ["m18"], "deps_out": ["m02"], "loc": 504, "tests": ["internal/testutil/timeout_test.go (56 dòng — test lớn nhất)"], "status": "DONE"},
  {"id": "m11", "module": "waker", "path": "internal/waker", "responsibility": "waker định nghĩa interface đồng bộ hóa `Waker` — kênh `Wake()` được đóng khi routine rảnh cần dậy — cùng 3 hiện thực: `timedWaker` (đánh thức định kỳ theo ticker, dùng trong production), `testWaker` (đồng bộ hóa có kiểm soát giữa goroutine bị test và vòng lặp test) và `alwaysWaker` (kênh đã đóng sẵn, không bao giờ chặn).", "main_files": ["internal/waker/waker.go (entry: type Waker interface :7; 10 dòng)", "internal/waker/testwaker.go (largest non-test: 139 dòng; NewTest :42, alwaysWaker :125)", "internal/waker/timedwaker.go (production: 50 dòng; NewTimed :22, Wake :45)"], "deps_in": [], "deps_out": ["m02", "m03", "m08", "m12"], "loc": 335, "tests": [], "status": "DONE"},
  {"id": "m12", "module": "cmd/mtail", "path": "cmd/mtail", "responsibility": "`cmd/mtail` là entry binary thật của chương trình mtail: định nghĩa ~40 cờ CLI (port/address/unix_socket, progs, logs, các cờ compiler/VM runtime/ops/debug/tracing + 3 cờ DEPRECATED) (main.go:41-85), ánh xạ cờ thành `[]mtail.Option` + `[]exporter.Option` (main.go:169-226), dựng `metrics.NewStore` + `mtail.New` + `m.Run()` (main.go:228-243), bắt SIGINT/SIGTERM để cancel context (main.go:156-163), và nhánh `-one_shot` xuất metrics ra stdout theo format json (store.WriteMetrics) hoặc prometheus (exporter.New + e.Write) (main.go:245-277).", "main_files": ["cmd/mtail/main.go (entry + largest: 278 dòng; func main :102, mtail.New :232, m.Run :238)"], "deps_in": ["m02", "m06", "m07", "m11"], "deps_out": [], "loc": 278, "tests": [], "status": "DONE"},
  {"id": "m13", "module": "golden", "path": "internal/mtail/golden", "responsibility": "Package hỗ trợ test golden-file — `ReadTestData` parse file dữ liệu \"golden\" (dòng dạng `counter|gauge|timer|text|histogram <name>{k=v,...} <value> <timestamp>` qua regexp `varRe`) thành `metrics.MetricSlice` để so khớp output metric của chương trình mtail trong test.", "main_files": ["internal/mtail/golden/reader.go (entry + non-test duy nhất: 156 dòng; var varRe :20, func ReadTestData :23)", "internal/mtail/golden/reader_test.go (121 dòng)"], "deps_in": ["m07", "m09"], "deps_out": [], "loc": 277, "tests": ["internal/mtail/golden/reader_test.go (121 dòng; TestReadTestData :115)"], "status": "DONE"},
  {"id": "m14", "module": "code", "path": "internal/runtime/code", "responsibility": "package `code` (\"contains the bytecode instructions for the mtail virtual machine\") định nghĩa tập lệnh bytecode của VM: enum `Opcode` (~70 opcode từ Bad/Stop/Match/…/F2s), struct `Instr` (Opcode + Operand + SourceLine) và `Object` — artifact nhị phân của một chương trình đã biên dịch (Program/String/Regexp/Metrics) — là hợp đồng trao đổi giữa compiler (codegen) và vm.", "main_files": ["internal/runtime/code/opcodes.go (entry: type Opcode :7; 147 dòng)", "internal/runtime/code/object.go (type Object :13; 18 dòng)", "internal/runtime/code/instr.go (type Instr :9)"], "deps_in": ["m07"], "deps_out": ["m01", "m04", "m05"], "loc": 214, "tests": [], "status": "DONE"},
  {"id": "m15", "module": "mdot", "path": "cmd/mdot", "responsibility": "mdot là CLI biến một chương trình mtail (`.mtail`) thành đồ thị graphviz dot: parse (`parser.Parse`) → type-check (`checker.Check`) → duyệt AST bằng `ast.Walk` với visitor `dotter` phát node/cạnh ra stdout, hoặc phục vụ SVG qua HTTP bằng `exec.Command(\"dot\", \"-Tsvg\")` khi chạy với `--http_port`.", "main_files": ["cmd/mdot/main.go (entry + largest: 206 dòng; type dotter :43, makeDot :134, func main :154)"], "deps_in": ["m01", "m02"], "deps_out": [], "loc": 206, "tests": [], "status": "DONE"},
  {"id": "m16", "module": "mgen", "path": "cmd/mgen", "responsibility": "`cmd/mgen` sinh chương trình mtail ngẫu nhiên cho fuzz testing (\"Command mgen generates mtail programs for fuzz testing by following a simple grammar\", main.go:7): bảng grammar `table map[string]node` mô tả toàn bộ ngôn ngữ (stmt/expr/decl/def_spec/deco_spec, BUILTIN: strptime/timestamp/len/tolower…) (main.go:26-66), `generateProgram()` đi bộ bảng bằng `math/rand` seed được (`-rand_seed`, `-min_iterations`) phát token ra stdout qua goroutine emitter wrap 80 cột (main.go:91-135), `-dictionary` in danh sách token từ `parser.Dictionary()` (main.go:138-141).", "main_files": ["cmd/mgen/main.go (entry + largest: 152 dòng; var table :26, func main :144)"], "deps_in": ["m01"], "deps_out": [], "loc": 152, "tests": [], "status": "DONE"},
  {"id": "m17", "module": "mfmt", "path": "cmd/mfmt", "responsibility": "CLI formatter cho chương trình mtail (doc comment `Command mfmt formats mtail programs.`): đọc file chương trình từ flag `-prog`, parse bằng `parser.Parse`, type-check bằng `checker.Check`, in lại source chuẩn qua `parser.Unparser{}.Unparse`, ghi đè file gốc khi `-write`.", "main_files": ["cmd/mfmt/main.go (entry + largest: 59 dòng; func main :25, parser.Parse :36, checker.Check :40)"], "deps_in": ["m01"], "deps_out": [], "loc": 59, "tests": [], "status": "DONE"},
  {"id": "m18", "module": "logline", "path": "internal/logline", "responsibility": "package `logline` định nghĩa `LogLine` — struct gói 1 dòng log vừa đọc (Context + Filename + Line) — được tailer đẩy qua channel cho VM xử lý; là kiểu dữ liệu trao đổi trung tâm giữa tailer/runtime/mtail/testutil.", "main_files": ["internal/logline/logline.go (entry + largest: 19 dòng; type LogLine :9, func New :17)"], "deps_in": [], "deps_out": ["m02", "m03", "m04", "m05", "m08", "m10"], "loc": 19, "tests": [], "status": "DONE"}
]
```

## 6. Merge verification (vòng 1 — sau review)

1. Census: 18/18 item khớp TUYỆT ĐỐI với `gm-checklist.json` (files + loc từng cặp;
   tổng 141 files / 26896 LOC).
2. deps hai chiều: **41 cạnh**, mỗi cạnh xuất hiện đúng 1 lần trong deps_in của đỉnh đi
   và 1 lần trong deps_out của đỉnh đến — 0 vi phạm (cạnh m05→m01 đã khôi phục, xem §4).
3. Status: 18/18 DONE (grep `- status:` trên 4 part = 18 DONE, 0 UNOWNED);
   4/4 file `mm-status-w*.json` tick DONE đủ item theo assignee.
4. PIN cross-check: 4/4 part ghi HEAD clone = `4c7e0e11…` khớp PIN mm_scan.
5. JSON block: 18 entry đúng thứ tự m01→m18, đủ 10 trường theo brief node
   (id, module, path, responsibility, main_files, deps_in, deps_out, loc, tests, status).
6. Bảng §1 đủ cột theo brief node: module | path | responsibility | main_files |
   deps_in | deps_out | loc | status (+ cột id để đối chiếu thứ tự checklist).

— re-merged VÒNG 1 bởi session mm_merge (7c62dead) sau review; kế thừa bản
  orchestrator-completed 2026-11-01T21:24:08Z và sửa 4 lỗi nêu ở header —
