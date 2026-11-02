---
subject: google/mtail
measured_at: 4c7e0e1174ac1ead032efe28d86428bbbe0ae145
status: final
---


# Folders

## (1) Bản đồ vùng chính

Cây depth-2 đo lại trên clone; 18/18 item của gm-02 đều tìm thấy ở đúng path (4 item `cmd/*`
ở depth-2, 14 item còn lại ở depth-3/4 dưới `internal/`):

```
$ find . -maxdepth 2 -type d -not -path './.git*' | sort
.
./cmd
./cmd/mdot
./cmd/mfmt
./cmd/mgen
./cmd/mtail
./docs
./docs/designs
./examples
./hooks
./internal
./internal/exporter
./internal/logline
./internal/metrics
./internal/mtail
./internal/runtime
./internal/tailer
./internal/testutil
./internal/waker
```
(item depth-3/4 nằm dưới các vùng trên: `internal/metrics/datum`, `internal/mtail/golden`,
`internal/runtime/{code,compiler,vm}`, `internal/tailer/logstream`.)

Bản đồ vùng — mỗi vùng 1 vai trò, kèm path thật:

| Vùng | Path | Vai trò |
|---|---|---|
| Binary CLI | `cmd/` | 4 chương trình, mỗi cái 1 package `main` đúng 1 file: `cmd/mtail` (278 LOC), `cmd/mgen` (152), `cmd/mdot` (206), `cmd/mfmt` (59) — khớp `File: Makefile \| Dòng: 6 \| Nội dung: TARGETS = mtail mgen mdot mfmt`. |
| Wiring chính | `internal/mtail/` | `Server` điều phối store + tailer + runtime + exporter + HTTP (`mtail.go:31`, `:176`); kèm 18 file integration test external-package, helper `testing.go`, và package con `golden/` (m13). Item lớn thứ 2: 25 files / 4,463 LOC (gm-02 m02). |
| Ngôn ngữ & runtime | `internal/runtime/` | 4 item: `compiler/` (m01 — front-end `.mtail` → bytecode), `vm/` (m04 — máy ảo), `code/` (m14 — định nghĩa bytecode), gốc `runtime/` (m05 — loader vòng đời chương trình). |
| Log ingestion | `internal/tailer/` | `Tailer` poll glob pattern → tạo `LogStream` (`tail.go:30`); package con `logstream/` (m03) biến pathname thành dòng `LogLine` (rotation/truncation/reopen, `logstream.go:35`). |
| Kho metric | `internal/metrics/` | `Store` trung tâm (`store.go:19`) + package con `datum/` (m09 — value types Counter/Gauge/Timer/Text/Histogram). |
| Export | `internal/exporter/` | Đọc `Store`, xuất Prometheus/varz/json + push targets (`export.go:32`). |
| Kiểu dùng chung | `internal/logline/`, `internal/waker/` | `LogLine` (19 LOC, m18 — struct trao đổi tailer→VM) và interface `Waker` (10 dòng, m11 — đánh thức goroutine poll). |
| Hỗ trợ test | `internal/testutil/` | Helper dùng chung cho test suite (m10: expvar/timeout/fs/port/race…, 15 files / 504 LOC). |
| Tài liệu | `docs/` | 15 file `.md` cho người dùng (Programming-Guide, Language, Metrics, Testing…) + thư mục `designs/` chứa `poll.md`. |
| Chương trình mẫu | `examples/` | 17 chương trình `.mtail` thật (apache, dhcpd, postfix, rails…) — đồng thời là fixture test (`File: internal/mtail/examples_integration_test.go \| Dòng: 32,37,42 \| Nội dung: "examples/rsyncd.mtail" / "examples/sftp.mtail" / "examples/dhcpd.mtail"`). |
| Git hooks | `hooks/` | 3 script git: `build`, `post_checkout`, `post_push`. |
| CI/CD | `.github/` + `.gitlab-ci.yml` | 12 workflow GitHub Actions (ci.yml, golangci-lint.yml, codeql-analysis.yml, oss-fuzz.yml, release.yml, automerge.yml…) SONG SONG 1 `.gitlab-ci.yml` 28 dòng (`:1 image: golang:latest`, `:3 stages:`) — xem §4 lệch 5. |
| Root files | `.` | `go.mod:1 module github.com/google/mtail` + `:3 go 1.21.1`; `go.sum` (35,470 bytes); `Makefile` (326 dòng: build/test/lint/fuzz/coverage); `Dockerfile` + `Dockerfile.goreleaser`; `.golangci.yml`; `.goreleaser.yml`; `LICENSE` Apache-2.0 (11,358 bytes); `README.md`; `TODO`; `benchmark_results.csv`; `logo.png`; `mtail-mode.el` (emacs mode); `mtail.service` (systemd unit); `log_rewriter.awk`; `subject_summarizer.mtail`. |

Hình dạng phụ thuộc (từ gm-02, các cạnh đã được gate verify vòng 2 — File:
reports/gate-map--r2--7c62dead.md | Dòng: 52): `cmd/mtail → {mtail, exporter, metrics, waker}`;
`mtail → {runtime, tailer, exporter, metrics, logline, waker, testutil, datum}`;
`runtime → {compiler, vm, code, metrics, datum, logline}`; `tailer → {logstream, logline, waker}`;
`vm → {code, metrics, datum, logline}`; `exporter → {metrics, datum}`;
`cmd/{mdot,mgen,mfmt} → compiler`. Tổng 41 cạnh 2 chiều (File: reports/mtail/gm-02-module-map.md | Dòng: 15).

## (2) Cấu trúc bên trong đại diện: item m01 `internal/runtime/compiler`

Đại diện = package Go lớn nhất theo gm-02 (m01 compiler, 28 files / 10,116 LOC — File:
reports/mtail/gm-checklist.json | Dòng: 2). Khác codesearch (package phẳng), compiler là
**1 package gốc + 9 subpackage**. Đo lại trên clone, khớp tuyệt đối checklist:

| Thành phần | Files (.go) | Main LOC | Test LOC | Tổng LOC | Vai trò |
|---|---|---|---|---|---|
| root `compiler/` | 2 (1+1) | 138 | 51 | 189 | Entry: `type Compiler struct` (:19), `New` (:27), `SetOption` (:35), pipeline `Compile` (:89) |
| `ast/` | 3 (2+1) | 543 | 83 | 626 | AST nodes + `Walk` visitor |
| `checker/` | 2 | 970 | 668 | 1,638 | Type-check: `Check` (`checker.go:45`) |
| `codegen/` | 2 | 632 | 1,138 | 1,770 | Sinh bytecode: `CodeGen` (`codegen.go:36`) — **test > main** |
| `errors/` | 2 | 56 | 20 | 76 | `compileError`/`ErrorList` (xem §4 lệch 2) |
| `opt/` | 2 | 170 | 502 | 672 | Optimise chạy 2 lượt trong pipeline (`opt.go:17`) |
| `parser/` | 9 | 2,828 | 1,004 | 3,832 | lexer + goyacc parser + unparser + sexp; `Parse` (`driver.go:34`) |
| `position/` | 1 | 52 | 0 | 52 | `Position` — subpackage duy nhất không có test |
| `symbol/` | 2 | 130 | 78 | 208 | Bảng ký hiệu: `Kind` (:15), `Symbol` (:42), `Scope` (:59) trong `symtab.go` |
| `types/` | 3 | 649 | 404 | 1,053 | Hệ thống type + `ErrTypeMismatch` |

Cộng: **28 files / main 6,168 + test 3,948 = 10,116** — khớp tuyệt đối checklist (File:
reports/mtail/gm-checklist.json | Dòng: 2). Tỷ lệ test ≈ 39%.

Layout đáng chú ý:

- Root mỏng (138 LOC main) — chỉ giữ struct + pipeline; trọng lượng nằm ở `parser/` (3,832)
  và `codegen/` (1,770). Pipeline (anchor đo lại nguyên văn: `compiler.go:89
  func (c *Compiler) Compile(name string, input io.Reader) (obj *code.Object, err error)`;
  các dòng gọi `:94 parser.Parse` / `:104,:125 opt.Optimise` / `:114 checker.Check` /
  `:136 codegen.CodeGen` — File: reports/mtail/gm-02-module-map.md | Dòng: 56-57, đã gate
  verify vòng 2 — File: reports/gate-map--r2--7c62dead.md | Dòng: 48).
- `parser/` là subpackage duy nhất chứa artifact NON-Go trong tree .go: `parser.y` (nguồn
  grammar, 16,279 bytes) và `y.output` (bảng LR sinh ra, 33,238 bytes) nằm cạnh `parser.go`
  (1,504 dòng, dòng 1 nguyên văn: `// Code generated by goyacc -v y.output -o parser.go -p
  mtail parser.y. DO NOT EDIT.`).
- Test nằm xen kẽ cùng thư mục với code (chuẩn Go); duy nhất `position/` không có test;
  2 subpackage có test nhiều hơn main: `codegen/` (1,138 vs 632) và `opt/` (502 vs 170).

## (3) Quy ước đặt tên từ code (7 ví dụ ≥ 3)

1. **Package == tên thư mục** với 102/141 file `.go`; 39 file "lệch" đều thuộc 2 dạng chuẩn
   Go: 4 `package main` trong `cmd/*` và 35 external test package `<pkg>_test` (18
   `mtail_test`, 7 `logstream_test`, 2 `waker_test`, 8 `<pkg>_test` đơn). Evidence: loop so
   `grep -m1 '^package '` vs `basename(dirname)` trên cả 141 file → đúng 39 mismatch, không
   có lệch nào ngoài 2 dạng trên.
2. **Functional Option pattern 3 lớp**: `type Option interface { apply(*Server) error }`
   (File: internal/mtail/options.go | Dòng: 22) + option là **named type** (`type ProgramPath
   string` — options.go:27; `type logPathPatterns []string` — :42) + hàm constructor trả
   Option (`func LogPathPatterns(patterns ...string) Option` — :38). Pattern lặp lại ở mọi
   layer: tailer (`func (opt LogPatterns) apply(t *Tailer)` — File: internal/tailer/tail.go |
   Dòng: 73; kèm :63 `niladicOption`, :81 `IgnoreRegex`, :94 `logPatternPollWaker`) và
   compiler (`func (c *Compiler) SetOption(options ...Option) error` — compiler.go:35).
3. **File đặt theo type trung tâm của nó**: `waker.go` ↔ `type Waker` (:7), `logline.go` ↔
   `type LogLine` (:9), `store.go` ↔ `type Store` (:19), `vm.go` ↔ `type VM` (:56), `tail.go`
   ↔ `type Tailer` (:30 — đặt theo động từ `tail`). File hiện thực đặt theo type hiện thực:
   `testwaker.go:18 type testWaker`, `timedwaker.go:13 type timedWaker`,
   `filestream.go:34 type fileStream`.
4. **Sentinel error `ErrXxx = errors.New(...)`** khai ở file option/entry của package:
   `ErrNilOption` (File: internal/tailer/tail.go | Dòng: 168), `ErrUnsupportedURLScheme`
   (tail.go:183), `ErrDuplicateHTTPBindAddress` (File: internal/mtail/options.go | Dòng: 66),
   `ErrNeedsStore` (File: internal/exporter/export.go | Dòng: 88).
5. **Test: `_test.go` + external package + hậu tố OS + `.golden`**: 61 file `*_test.go`;
   hậu tố `_unix`/`_windows` luôn đi kèm `//go:build` tương ứng (`tail_unix_test.go:4
   //go:build unix`, `tail_windows_test.go:4 //go:build windows` — đủ 15 file constraint, xem
   mục "không lệch" ở §4); dữ liệu test trong `internal/mtail/testdata/` (24 entries) theo
   cặp `<name>.log` + `<name>.golden` (vd `apache-combined.log` + `apache-combined.golden`),
   parse bởi `golden.ReadTestData` (File: internal/mtail/golden/reader.go | Dòng: 23).
6. **Receiver ngắn, thống nhất theo type**: `r *Runtime` (File: internal/runtime/runtime.go |
   Dòng: 49 | Nội dung: `func (r *Runtime) LoadAllPrograms() error {`), `c *Compiler`
   (compiler.go:35, :89), `opt`/`n` cho option types (tail.go:63,73,81,94).
7. **File nhiều chủ đề đặt theo chủ đề, không ép theo 1 type**: `symbol/symtab.go` chứa
   `Kind` (:15) + `Symbol` (:42) + `Scope` (:59) — tên file mô tả nội dung (symbol table),
   không trùng tên type nào cả.

## (4) Chỗ lệch chuẩn Go (mỗi chỗ ≥2 ví dụ, đều grep-verified trên clone PIN)

**Lệch 1 — 2 file .go SINH TỰ ĐỘNG được commit vào tree; 1 trong 2 thiếu banner chuẩn;
asset nhúng bằng generated source thay vì go:embed.**

- Ví dụ 1: `internal/runtime/compiler/parser/parser.go` — 1,504 dòng, dòng 1 nguyên văn
  `// Code generated by goyacc -v y.output -o parser.go -p mtail parser.y. DO NOT EDIT.`;
  Makefile liệt kê trong `GOGENFILES` (File: Makefile | Dòng: 51-52) và có rule tái sinh
  `parser.go: parser.y | $(GOYACC)` (Makefile:141-142).
- Ví dụ 2: `internal/mtail/logo.ico.go` — 2,008 dòng byte-array favicon: `:3 var logoFavicon
  = []byte{`, `:4 // 32038 bytes from internal/mtail/logo.ico` — sinh bởi công cụ `togo`
  (Makefile:147-148: `togo -pkg mtail -name logoFavicon -input internal/mtail/logo.ico`),
  NHƯNG `grep -rn "Code generated" --include='*.go' .` trên toàn repo trả đúng **1 hit**
  (parser.go:1) → file generated này **thiếu** dòng `// Code generated … DO NOT EDIT.`
  chuẩn (go.dev/s/generatedcode).
- Ví dụ 3: `internal/runtime/compiler/parser/y.output` (33,238 bytes — bảng LR debug) được
  commit dù Makefile xếp vào `CLEANFILES` (Makefile:55-59). Kèm: repo khai `go 1.21.1`
  (go.mod:3) — `go:embed` có sẵn từ 1.16 — nhưng `grep -rn "go:embed" --include='*.go' .`
  → **0 hit**: pattern nhúng asset ở đây là generated `.go`, không phải embed.

**Lệch 2 — Package `errors` trùng tên stdlib, chồng thêm `pkg/errors` → 3 "errors" khác
nhau trong cùng subtree compiler.**

- Ví dụ 1: `internal/runtime/compiler/errors/errors.go:4 package errors` — và ngay trong
  file đó `:11 "github.com/pkg/errors"` (thư viện thứ 3 cùng tên) → 2 "errors" khác nghĩa
  trong 1 file.
- Ví dụ 2: `checker.go:7 goerrors "errors"` — caller buộc alias stdlib để phân biệt; alias
  dùng thật 7 lần (`:368, :420, :452, :471, :545, :645, :792` đều `goerrors.Is(...)`), trong
  khi `:15` import package errors nội bộ bằng full path
  `github.com/google/mtail/internal/runtime/compiler/errors`.
- Ví dụ 3: trong cùng subtree, `types/types.go:7` và `parser/lexer.go:8` import stdlib
  `"errors"` nguyên dạng (không alias) — người đọc gặp cả 3 dạng `errors` / `goerrors` /
  `<full-path>/errors`; 3 file import errors nội bộ: `codegen.go:17`, `opt.go:11`,
  `driver.go:28`.

**Lệch 3 — `docs/` trộn hoa/thường không nhất quán.**

- Ví dụ 1: `docs/Building.md` (hoa) đối trực tiếp `docs/debugging.md` (thường) — cùng loại
  tài liệu hướng dẫn vận hành.
- Ví dụ 2: `docs/Programming-Guide.md` (hoa + kebab) đối `docs/style.md`, `docs/faq.md`,
  `docs/reading-y-output.md` (thường). Đếm: `ls docs/*.md | wc -l` = 15, trong đó 8 file
  viết-hoa-đầu và 7 file viết-thường; thư mục `designs/` (thường) chứa `poll.md`.

**Lệch 4 — file hỗ trợ test nằm trong package production (không `_test.go`, không package riêng).**

- Ví dụ 1: `internal/mtail/testing.go` — file thường của `package mtail` (:4), import
  `"testing"` (:12) và `"github.com/google/mtail/internal/testutil"` (:18), định nghĩa
  `type TestServer struct` (:24) → helper test biên dịch cùng production package.
- Ví dụ 2: hậu quả link: `cmd/mtail/main.go:20` import
  `"github.com/google/mtail/internal/mtail"` → binary `mtail` link cả file này (kèm dep
  `testutil` — đúng 1 consumer non-test của testutil, khớp deps_out m10 trong gm-02). Cách
  bố trí "chuẩn Go" cho helper test đa-package là package riêng (như `httptest`) hoặc
  `export_test.go`; mtail chọn helper in-package — là lựa chọn chủ ý (TestServer dùng chung
  cho integration test nhiều package), nhưng vẫn là chỗ lệch với nguyên tắc "testing import
  chỉ nằm trong test".

**Lệch 5 — hai hệ CI song song (GitHub Actions + GitLab CI).**

- Ví dụ 1: `.github/workflows/` có 12 workflow (ci.yml, golangci-lint.yml, codeql-analysis.yml,
  oss-fuzz.yml, release.yml, automerge.yml, …) và Makefile đọc version golangci-lint TRỰC
  TIẾP từ workflow: File: Makefile | Dòng: 105-106 | Nội dung: `# This version should match
  the one in .github/workflows/golangci-lint.yml` + `GOLANGCILINT_VERSION=$(shell grep
  'version: v' .github/workflows/golangci-lint.yml | cut -f2 -d: | tr -d ' ')`.
- Ví dụ 2: `.gitlab-ci.yml` (28 dòng; `:1 image: golang:latest`, `:3 stages:`) tồn tại song
  song ở root — 2 pipeline cho cùng repo, tự chịu rủi ro trôi cấu hình.

**Những chỗ KIỂM TRA và xác nhận KHÔNG lệch** (tránh bịa lệch):

- package == thư mục: 102/141 file; 39 lệch còn lại đều là 2 dạng chuẩn Go (package main,
  external test package) — xem §3.1.
- Build constraint: toàn bộ 15 file dùng `//go:build` hiện đại (11 `unix`, 1 `windows`,
  1 `gofuzz` — `internal/runtime/fuzz.go:4`, cặp `race`/`!race` — `testutil/race.go:3` +
  `testutil/norace.go:3`); `grep -rn "+build"` → **0 hit** (không còn dạng legacy).
- `fuzz.go` là file non-test trong `internal/runtime` nhưng có tag riêng `gofuzz` (fuzz.go:4)
  và Makefile:231 chạy `gosec -tags fuzz ./...` — pattern OSS-Fuzz chủ ý, không phải quên lint.
- `testdata/` chuẩn Go: duy nhất `internal/mtail/testdata/` (24 entries, gồm các `.golden`).
- `go.mod` chuẩn: module `github.com/google/mtail` (:1), `go 1.21.1` (:3), deps khai minh
  bạch (2 khối require direct/indirect) + `go.sum` 35,470 bytes; không có `vendor/`.

## (5) Gợi ý đọc hiểu — đọc theo thứ tự nào, vì sao

1. **`README.md:3`** — nạp mental model 1 câu: "# mtail - extract internal monitoring data
   from application logs…"; `README.md:20` trỏ thẳng `docs/Programming-Guide.md`.
2. **`docs/Programming-Guide.md` + `docs/Language.md`** — ngôn ngữ `.mtail` người dùng viết:
   mọi cấu trúc trong `internal/runtime/compiler` tồn tại để biên dịch ngôn ngữ này; hiểu
   ngôn ngữ trước giúp đọc parser/checker/codegen không lạc.
3. **`examples/*.mtail`** (17 chương trình) — nhìn chương trình thật (apache_combined, dhcpd,
   postfix…); chúng đồng thời là fixture test (examples_integration_test.go:32,37,42).
4. **`cmd/mtail/main.go`** — entry binary: cờ CLI → `[]mtail.Option` (main.go:169-226) →
   `mtail.New` (:232) → `Run` (:238) (gm-02 m12, gate verify vòng 1); đây là bản đồ
   "chương trình được điều khiển bằng gì".
5. **`internal/mtail/mtail.go`** (`:31` Server struct, `:176` New) — điểm nối 4 mảnh:
   store + tailer + runtime + exporter; đọc tiếp `options.go:22` (Option interface) để biết
   mỗi Option tác động vào mảnh nào.
6. **`internal/runtime/runtime.go`** (`:215` Runtime struct, `:250` New, `:141`
   CompileAndRun) — vòng đời chương trình `.mtail`: nạp → biên dịch → chạy VM → unload.
7. **`internal/runtime/compiler/compiler.go:89`** rồi đi theo pipeline: `parser/driver.go:34`
   → `checker/checker.go:45` → `codegen/codegen.go:36`; hợp đồng đầu ra là
   `internal/runtime/code/object.go:13` (`type Object` — bytecode + regexps + metrics; gm-02 m14).
8. **`internal/runtime/vm/vm.go`** (`:56` VM struct, `:993` New, `:962-991` ProcessLogLine —
   gm-02 m04) — điểm hội tụ: dòng log (từ tailer) gặp bytecode (từ compiler) tại đây.
9. **Đường dữ liệu log**: `internal/tailer/tail.go:30` → `internal/tailer/logstream/logstream.go:35`
   (rotation/truncation/reopen) → `internal/logline/logline.go:9` → vào VM ở bước 8; metric
   sinh ra chảy vào `internal/metrics/store.go:19` rồi `internal/exporter/export.go:32`
   (Prometheus/varz).
10. **Cuối cùng**: `internal/waker/waker.go:7` (interface 10 dòng, giải thích mọi vòng poll),
    `internal/testutil/` + `internal/mtail/golden/reader.go:23` (hỗ trợ test), `docs/style.md`
    (quy ước đóng góp: table test dạng `t.Run`) — và `Makefile` khi cần build/test/lint/fuzz.

Lý do thứ tự: đi theo dòng giá trị **cấu hình (main.go) → wiring (Server) → chương trình
(runtime → compiler → code) → thực thi (vm) ← dữ liệu vào (tailer → logline) → dữ liệu ra
(metrics → exporter)**; mỗi bước chỉ dùng khái niệm của các bước trước, không cần quay lại.

---

## Machine block

```json
{
  "subject": "mtail",
  "pin": "4c7e0e1174ac1ead032efe28d86428bbbe0ae145",
  "pin_source": "sandbox_shell git rev-parse HEAD sau clone --depth 100 --single-branch main; khớp tuyệt đối PIN gm-02 (reports/mtail/gm-02-module-map.md:4)",
  "inputs": ["reports/mtail/gm-02-module-map.md", "reports/mtail/gm-checklist.json"],
  "input_gap": "reports/mtail/gm-01-cartography.md khong ton tai (gap ke khai san: reports/mm_scan--7c62dead.md:14, reports/gate-map--r1--7c62dead.md:37) — top_dirs do truc tiep tren clone PIN, doi chieu go.mod + Makefile + universe gm-02",
  "regions": [
    {"path": "cmd/", "role": "4 CLI binary (mtail 278, mgen 152, mdot 206, mfmt 59) — Makefile:6 TARGETS"},
    {"path": "internal/mtail/", "role": "Server wiring + options + testing.go helper + golden/ (m02, m13)"},
    {"path": "internal/runtime/", "role": "loader runtime (m05) + compiler/ (m01) + vm/ (m04) + code/ (m14)"},
    {"path": "internal/tailer/", "role": "Tailer poll pattern (m08) + logstream/ (m03)"},
    {"path": "internal/metrics/", "role": "Store trung tam (m07) + datum/ (m09)"},
    {"path": "internal/exporter/", "role": "xuat metric Prometheus/varz/json/push (m06)"},
    {"path": "internal/logline/", "role": "struct LogLine trao doi tailer->VM (m18, 19 LOC)"},
    {"path": "internal/waker/", "role": "interface Waker + 2 hien thuc (m11)"},
    {"path": "internal/testutil/", "role": "helper test dung chung (m10)"},
    {"path": "docs/", "role": "15 .md nguoi dung + designs/poll.md"},
    {"path": "examples/", "role": "17 chuong trinh .mtail mau, dong thoi la fixture test (examples_integration_test.go:32,37,42)"},
    {"path": "hooks/", "role": "3 git hooks (build, post_checkout, post_push)"},
    {"path": ".github/ + .gitlab-ci.yml", "role": "12 GitHub Actions workflows song song 1 GitLab CI 28 dong"},
    {"path": ".", "role": "root manifests: go.mod (go 1.21.1), go.sum 35470 B, Makefile 326 dong, Dockerfile x2, .golangci.yml, .goreleaser.yml, LICENSE Apache-2.0 11358 B, README, TODO, logo.png, mtail-mode.el, mtail.service, log_rewriter.awk, subject_summarizer.mtail"}
  ],
  "representative": {
    "item": "m01 compiler",
    "path": "internal/runtime/compiler",
    "files": 28, "loc_total": 10116, "loc_main": 6168, "loc_test": 3948,
    "subpackages": ["root", "ast", "checker", "codegen", "errors", "opt", "parser", "position", "symbol", "types"],
    "per_dir_loc": {"root": 189, "ast": 626, "checker": 1638, "codegen": 1770, "errors": 76, "opt": 672, "parser": 3832, "position": 52, "symbol": 208, "types": 1053},
    "pipeline_anchors": {"compile": "compiler.go:89", "parse": "parser/driver.go:34", "optimise": "opt/opt.go:17", "check": "checker/checker.go:45", "codegen": "codegen/codegen.go:36"},
    "non_go_artifacts_in_parser": ["parser.y (16279 B)", "y.output (33238 B)"]
  },
  "naming_examples": 7,
  "deviations": [
    {"id": "D1", "place": "generated .go committed (2 file GOGENFILES) + y.output; logo.ico.go thieu banner Code generated; khong dung go:embed", "examples": ["parser/parser.go:1 banner goyacc + Makefile:51-52,141-142", "internal/mtail/logo.ico.go:3-4 togo-generated 2008 dong, grep 'Code generated' toan repo = 1 hit", "parser/y.output 33238 B commit du trong khi nam trong CLEANFILES (Makefile:55-59); grep go:embed = 0 hit"]},
    {"id": "D2", "place": "package errors trung ten stdlib + pkg/errors (3 'errors' trong 1 subtree)", "examples": ["compiler/errors/errors.go:4 package errors + :11 github.com/pkg/errors", "checker/checker.go:7 goerrors \"errors\" alias (dung 7 lan :368..:792) + :15 import local errors full-path", "types/types.go:7 + parser/lexer.go:8 stdlib errors nguyen dang; importers codegen.go:17, opt.go:11, driver.go:28"]},
    {"id": "D3", "place": "docs/ tron hoa/thuong", "examples": ["docs/Building.md vs docs/debugging.md", "docs/Programming-Guide.md vs docs/style.md (8 hoa / 7 thuong / 15 .md)"]},
    {"id": "D4", "place": "helper test trong package production", "examples": ["internal/mtail/testing.go:4 package mtail, :12 import testing, :18 testutil, :24 TestServer", "cmd/mtail/main.go:20 import internal/mtail -> binary link testing.go; testutil chi co 1 consumer non-test"]},
    {"id": "D5", "place": "hai he CI song song", "examples": [".github/workflows/ 12 file; Makefile:105-106 doc version lint tu golangci-lint.yml", ".gitlab-ci.yml 28 dong (:1 image golang:latest, :3 stages:)"]}
  ],
  "checked_not_deviating": ["package==dir 102/141; 39 lech = 4 package main + 35 external test (2 dang chuan Go)", "15 file //go:build hien dai (11 unix, 1 windows, 1 gofuzz, race/!race), 0 legacy +build", "fuzz.go:4 tag gofuzz chu y (Makefile:231 gosec -tags fuzz)", "testdata/ chuan Go (internal/mtail/testdata, 24 entries)", "go.mod/go.sum chuan, khong vendor/"],
  "reading_order": ["README.md:3,20", "docs/Programming-Guide.md + docs/Language.md", "examples/*.mtail (17)", "cmd/mtail/main.go", "internal/mtail/mtail.go:31,176 + options.go:22", "internal/runtime/runtime.go:215,250,141", "internal/runtime/compiler/compiler.go:89 + parser/driver.go:34 + checker/checker.go:45 + codegen/codegen.go:36 + code/object.go:13", "internal/runtime/vm/vm.go:56,962,993", "internal/tailer/tail.go:30 -> logstream/logstream.go:35 -> logline/logline.go:9 -> metrics/store.go:19 -> exporter/export.go:32", "waker/waker.go:7 + testutil/ + golden/reader.go:23 + docs/style.md + Makefile"]
}
```
