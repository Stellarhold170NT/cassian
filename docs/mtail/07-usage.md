---
subject: google/mtail
measured_at: 4c7e0e1174ac1ead032efe28d86428bbbe0ae145
status: final
---


# Usage

## Bảng tổng hợp 8/8 item (module | dùng khi nào | deps_out)

| s_id | module (m-id) | Dùng khi nào | deps_out — ai tiêu thụ item |
|---|---|---|---|
| s01 | compiler (m01) | Front-end biến chương trình nguồn `.mtail` thành bytecode `code.Object` (parser→opt→checker→codegen); dùng khi cần biên dịch/lint/validate `.mtail` từ code Go (binary mtail, tool mdot/mfmt/mgen, CI). | m05 runtime, m15 mdot, m16 mgen, m17 mfmt |
| s07 | metrics (m07) | Kho trạng thái trung tâm `Store` lưu mọi metric do chương trình tạo (thêm/tìm an toàn khóa kép, GC theo limit/expiry, JSON, `Range` cho exporter); dùng khi đăng ký/tra cứu/dump/GC metric. | m01 compiler, m02 mtail, m04 vm, m05 runtime, m06 exporter, m12 cmd/mtail, m13 golden, m14 code |
| s02 | mtail (m02) | `Server` điều phối chính giữ Store + tailer + runtime + exporter và chạy HTTP server; dùng khi nhúng toàn bộ pipeline log→metric vào chương trình Go (chạy dài, CompileOnly CI, OneShot snapshot). | m12 cmd/mtail, m15 mdot |
| s04 | vm (m04) | Máy ảo thông dịch bytecode: `New(code.Object)` + `ProcessLogLine` fetch–decode–execute cập nhật metric; dùng khi tự dựng/test/debug bytecode hoặc chạy VM như consumer của channel. | m05 runtime |
| s06 | exporter (m06) | Cổng xuất metric ra hệ giám sát: collector Prometheus cắm registry, HTTP handler `/varz` `/json` `/graphite`, push định kỳ; dùng khi đưa số liệu từ `metrics.Store` ra Prometheus/format khác. | m02 mtail, m12 cmd/mtail |
| s08 | tailer (m08) | Đầu vào pipeline: poll filesystem theo `LogPathPatterns`, tạo `LogStream` tail 1 path hoặc glob, bơm dòng vào channel `lines`; dùng khi đọc log file thật (ignore `.gz`, trang trạng thái HTML). | m02 mtail |
| s09 | datum (m09) | Value-type của metric: interface `Datum` + `Int`/`Float`/`String`/`Buckets` (histogram) kèm timestamp atomic; dùng khi cần cơ chế giá trị+timestamp thống nhất — đáy đồ thị, deps_in = 0. | m01 compiler, m02 mtail, m04 vm, m05 runtime, m06 exporter, m07 metrics, m13 golden |
| s11 | waker (m11) | Interface đồng bộ hóa `Waker` (kênh `Wake()` đóng khi cần dậy) + `timedWaker`/`testWaker`/`alwaysWaker`; dùng khi vòng lặp idle cần đánh thức định kỳ hoặc đồng bộ hóa test thay sleep cứng. | m02 mtail, m03 logstream, m08 tailer, m12 cmd/mtail |

### Block JSON máy-đọc (cùng nội dung bảng trên; deps_out nguyên văn u-checklist.json)

```json
[
  {"s_id": "s01", "m_id": "m01", "module": "compiler", "dung_khi_nao": "Front-end biến chương trình nguồn `.mtail` thành bytecode `code.Object` (parser→opt→checker→codegen); dùng khi cần biên dịch/lint/validate `.mtail` từ code Go (binary mtail, tool mdot/mfmt/mgen, CI).", "deps_out": ["m05", "m15", "m16", "m17"]},
  {"s_id": "s07", "m_id": "m07", "module": "metrics", "dung_khi_nao": "Kho trạng thái trung tâm `Store` lưu mọi metric do chương trình tạo (thêm/tìm an toàn khóa kép, GC theo limit/expiry, JSON, `Range` cho exporter); dùng khi đăng ký/tra cứu/dump/GC metric.", "deps_out": ["m01", "m02", "m04", "m05", "m06", "m12", "m13", "m14"]},
  {"s_id": "s02", "m_id": "m02", "module": "mtail", "dung_khi_nao": "`Server` điều phối chính giữ Store + tailer + runtime + exporter và chạy HTTP server; dùng khi nhúng toàn bộ pipeline log→metric vào chương trình Go (chạy dài, CompileOnly CI, OneShot snapshot).", "deps_out": ["m12", "m15"]},
  {"s_id": "s04", "m_id": "m04", "module": "vm", "dung_khi_nao": "Máy ảo thông dịch bytecode: `New(code.Object)` + `ProcessLogLine` fetch–decode–execute cập nhật metric; dùng khi tự dựng/test/debug bytecode hoặc chạy VM như consumer của channel.", "deps_out": ["m05"]},
  {"s_id": "s06", "m_id": "m06", "module": "exporter", "dung_khi_nao": "Cổng xuất metric ra hệ giám sát: collector Prometheus cắm registry, HTTP handler `/varz` `/json` `/graphite`, push định kỳ; dùng khi đưa số liệu từ `metrics.Store` ra Prometheus/format khác.", "deps_out": ["m02", "m12"]},
  {"s_id": "s08", "m_id": "m08", "module": "tailer", "dung_khi_nao": "Đầu vào pipeline: poll filesystem theo `LogPathPatterns`, tạo `LogStream` tail 1 path hoặc glob, bơm dòng vào channel `lines`; dùng khi đọc log file thật (ignore `.gz`, trang trạng thái HTML).", "deps_out": ["m02"]},
  {"s_id": "s09", "m_id": "m09", "module": "datum", "dung_khi_nao": "Value-type của metric: interface `Datum` + `Int`/`Float`/`String`/`Buckets` (histogram) kèm timestamp atomic; dùng khi cần cơ chế giá trị+timestamp thống nhất — đáy đồ thị, deps_in = 0.", "deps_out": ["m01", "m02", "m04", "m05", "m06", "m07", "m13"]},
  {"s_id": "s11", "m_id": "m11", "module": "waker", "dung_khi_nao": "Interface đồng bộ hóa `Waker` (kênh `Wake()` đóng khi cần dậy) + `timedWaker`/`testWaker`/`alwaysWaker`; dùng khi vòng lặp idle cần đánh thức định kỳ hoặc đồng bộ hóa test thay sleep cứng.", "deps_out": ["m02", "m03", "m08", "m12"]}
]
```

## Phần sâu theo item (thứ tự u-checklist — nội dung INHERITED nguyên văn từ worker)

---

## s01 — compiler · internal/runtime/compiler

### (a) Item này giải quyết vấn đề gì

compiler là front-end biến chương trình nguồn `.mtail` thành bytecode `code.Object` — `Compiler.Compile`
(compiler.go:89) chạy pipeline parser.Parse → opt.Optimise → checker.Check → opt.Optimise (lần 2) →
codegen.CodeGen trên 10 package con, với các Option cấu hình (EmitAst, MaxRegexpLength, MaxRecursionDepth,
DisableOptimisation) (fact từ brief/gm-02 m01, evidence grep lại trong node này bên dưới). Ai cần biên dịch
chương trình mtail từ code Go (binary `mtail`, tool `mdot`/`mfmt`/`mgen`, runtime loader) đều đi qua item này
— deps_out của m01 gồm m05 runtime, m15 mdot, m16 mgen, m17 mfmt (fact từ brief/gm-02).

### (b)+(c) Use case 1.1 — Biên dịch một chương trình `.mtail` thành bytecode từ code Go

Kịch bản: tool deploy của bạn muốn biên dịch file `.mtail` trước khi ship để bắt lỗi sớm; bạn dựng một
`Compiler` với giới hạn an toàn (regexp ≤ 64 ký tự, recursion ≤ 64) rồi gọi `Compile` — lỗi biên dịch trả về
kèm vị trí trong nguồn. Kết quả `*code.Object` là artifact nạp thẳng vào `vm.New()` (s04) hoặc loader runtime.

```go
package main

import (
	"os"

	"github.com/google/mtail/internal/runtime/compiler"
)

func main() {
	f, err := os.Open("requests.mtail")
	if err != nil {
		panic(err)
	}
	defer f.Close()

	c, err := compiler.New(compiler.MaxRegexpLength(64), compiler.MaxRecursionDepth(64))
	if err != nil {
		panic(err)
	}
	obj, err := c.Compile("requests.mtail", f)
	if err != nil {
		panic(err) // lỗi biên dịch, kèm vị trí trong source .mtail
	}
	// obj *code.Object — nạp vào vm.New() hoặc runtime.Runtime.CompileAndRun()
	_ = obj
}
```

Evidence (grep trên cây PIN):
- `internal/runtime/compiler/compiler.go:27` — `func New(options ...Option) (*Compiler, error) {`
- `internal/runtime/compiler/compiler.go:89` — `func (c *Compiler) Compile(name string, input io.Reader) (obj *code.Object, err error) {`
- `internal/runtime/compiler/compiler.go:64` — `func MaxRegexpLength(maxRegexpLength int) Option {` · `compiler.go:72` — `func MaxRecursionDepth(maxRecursionDepth int) Option {`
- `internal/runtime/code/object.go:13-18` — `type Object struct { Program []Instr; Strings []string; Regexps []*regexp.Regexp; Metrics []*metrics.Metric }`

### (b)+(c) Use case 1.2 — Lint/validate + chuẩn hóa chương trình `.mtail` trong CI (pipeline mfmt)

Kịch bản: CI chạy một bước kiểm tra mọi chương trình `.mtail`: `Parse` bắt lỗi cú pháp, `Check` bắt lỗi
type/ngữ nghĩa, và `Unparser{}.Unparse` in lại source chuẩn hóa để diff. Đây đúng là pipeline mà CLI `mfmt`
gọi (cmd/mfmt/main.go:36/40/44, grep thấy trên cây PIN).

```go
package main

import (
	"io"

	"github.com/google/mtail/internal/runtime/compiler/checker"
	"github.com/google/mtail/internal/runtime/compiler/parser"
)

// lint: trả về source chuẩn hóa, hoặc lỗi cú pháp/type của chương trình .mtail.
func lint(src io.Reader) (string, error) {
	ast, err := parser.Parse("prog.mtail", src)
	if err != nil {
		return "", err // lỗi cú pháp
	}
	ast, err = checker.Check(ast, 0, 0)
	if err != nil {
		return "", err // lỗi type / ngữ nghĩa
	}
	up := parser.Unparser{}
	return up.Unparse(ast), nil
}
```

Evidence (grep trên cây PIN):
- `internal/runtime/compiler/parser/driver.go:34` — `func Parse(name string, input io.Reader) (ast.Node, error) {`
- `internal/runtime/compiler/checker/checker.go:45` — `func Check(node ast.Node, maxRegexpLength int, maxRecursionDepth int) (ast.Node, error) {`
- `internal/runtime/compiler/parser/unparser.go:16` — `type Unparser struct {` · `unparser.go:288` — `func (u *Unparser) Unparse(n ast.Node) string {`
- `cmd/mfmt/main.go:36` — `ast, err := parser.Parse(*prog, f)` · `:40` — `ast, err = checker.Check(ast, 0, 0)` · `:44` — `up := parser.Unparser{}`

### (b)+(c) Use case 1.3 — Lấy từ điển token của ngôn ngữ `.mtail` cho editor/linter

Kịch bản: bạn viết plugin syntax-highlighting hoặc linter cho `.mtail` và cần danh sách toàn bộ token
(keyword + builtin như `strptime`, `timestamp`, `len`, `tolower`) — `parser.Dictionary()` trả về `[]string`.
CLI `mgen` cũng gọi API này để in danh sách token với cờ `-dictionary`.

```go
package main

import (
	"fmt"

	"github.com/google/mtail/internal/runtime/compiler/parser"
)

func main() {
	tokens := parser.Dictionary() // từ khóa + builtin của ngôn ngữ .mtail
	fmt.Printf("ngôn ngữ .mtail có %d token\n", len(tokens))
	for i, t := range tokens {
		if i >= 10 {
			break
		}
		fmt.Println(t)
	}
}
```

Evidence (grep trên cây PIN):
- `internal/runtime/compiler/parser/lexer.go:58` — `func Dictionary() (r []string) {`
- `cmd/mgen/main.go:139` — `for _, k := range parser.Dictionary() {`

### (d) Deps cần kéo theo (s01)

- Ví dụ import stdlib + các subpackage của chính item (`parser`, `checker` — nội bộ m01); kết quả `Compile`
  là `*code.Object` → runtime phụ thuộc **m14 code** (deps_in của m01: m07 metrics, m09 datum, m14 code — fact từ brief/gm-02).
- Build: `go build ./...` từ root module `github.com/google/mtail` (go.mod:1); chưa chạy được trong sandbox này (SKIPPED — không toolchain).

### (e) Build riêng item (s01)

`go build ./... && go test ./...` — **SKIPPED**: sandbox `bitnami/git:latest` không có Go toolchain
(`which go` không thấy); entry build grep được: `go.mod:1`, `Makefile:15` `all: $(TARGETS)` (Makefile:6).

---

## s07 — metrics · internal/metrics

### (a) Item này giải quyết vấn đề gì

metrics là kho trạng thái trung tâm của mtail — `Store` (map name → []*Metric) lưu mọi metric do chương trình
tạo ra với thêm/tìm/xóa an toàn khóa kép (`insertMu`+`searchMu`), GC theo limit/expiry, serialize JSON và
iterate cho exporter; `Metric`/`LabelValue` mô hình hóa kind (Counter/Gauge/Timer/Text/Histogram), type
(Int/Float/String/Buckets) và giá trị datum theo nhãn (fact từ brief/gm-02 m07). Đây là điểm gặp nhau của
compiler (tạo metric), VM (cập nhật), exporter (đọc) — deps_out của m07 gồm 8 item khác (fact từ brief/gm-02).

### (b)+(c) Use case 2.1 — Đăng ký counter, tạo giá trị theo nhãn và đọc lại qua Store

Kịch bản: bạn nhúng thư viện metric của mtail vào chương trình riêng: tạo `Store`, đăng ký một counter
`requests_total` có nhãn `status`, tạo datum cho label set `"200"` và tăng giá trị, rồi tra cứu lại metric
từ store theo (name, prog) và in dạng chuỗi.

```go
package main

import (
	"fmt"
	"time"

	"github.com/google/mtail/internal/metrics"
	"github.com/google/mtail/internal/metrics/datum"
)

func main() {
	store := metrics.NewStore()
	m := metrics.NewMetric("requests_total", "demo_prog", metrics.Counter, metrics.Int, "status")
	if err := store.Add(m); err != nil {
		panic(err)
	}
	d, err := m.GetDatum("200") // tự đăng ký LabelValue{status="200"} nếu chưa có
	if err != nil {
		panic(err)
	}
	d.(*datum.Int).IncBy(1, time.Now()) // Type=Int → dynamic type *datum.Int
	found := store.FindMetricOrNil("requests_total", "demo_prog")
	fmt.Println(found.String())
}
```

Evidence (grep trên cây PIN):
- `internal/metrics/store.go:26` — `func NewStore() (s *Store) {` · `store.go:33` — `func (s *Store) Add(m *Metric) error {` · `store.go:101` — `func (s *Store) FindMetricOrNil(name, prog string) *Metric {`
- `internal/metrics/metric.go:100` — `func NewMetric(name string, prog string, kind Kind, typ Type, keys ...string) *Metric {`
- `internal/metrics/metric.go:151` — `func (m *Metric) GetDatum(labelvalues ...string) (d datum.Datum, err error) {` (body :162-180 tự tạo `datum.NewInt()` + `AppendLabelValue` khi chưa có)
- `internal/metrics/datum/datum.go:55` — `func NewInt() Datum {` → body gọi `MakeInt(0, zeroTime)`; `datum.go:75` — `func MakeInt(v int64, ts time.Time) Datum {` với body `d := &Int{}` → dynamic type là `*datum.Int`
- `internal/metrics/datum/int.go:26` — `func (d *Int) IncBy(delta int64, timestamp time.Time) {`
- `internal/metrics/metric.go:298` — `func (m *Metric) String() string {`

### (b)+(c) Use case 2.2 — Xuất trạng thái store: `Range` cho exporter + `WriteMetrics` JSON

Kịch bản: bạn muốn dump trạng thái metric định kỳ ra stdout (giống nhánh `-one_shot -one_shot_format json`
của `cmd/mtail`), hoặc cắm store vào hệ giám sát riêng bằng cách duyệt từng metric — `Range` chính là vòng
lặp mà exporter Prometheus dùng trong `Collect` (prometheus.go:36, grep thấy trên cây PIN).

```go
package main

import (
	"bytes"
	"fmt"
	"os"

	"github.com/google/mtail/internal/metrics"
)

func dump(store *metrics.Store) error {
	err := store.Range(func(m *metrics.Metric) error {
		fmt.Printf("%s (prog=%s, kind=%v)\n", m.Name, m.Program, m.Kind)
		return nil // trả error để dừng Range sớm
	})
	if err != nil {
		return err
	}
	var buf bytes.Buffer
	if err := store.WriteMetrics(&buf); err != nil {
		return err
	}
	_, err = buf.WriteTo(os.Stdout)
	return err
}
```

Evidence (grep trên cây PIN):
- `internal/metrics/store.go:141` — `func (s *Store) Range(f func(*Metric) error) error {`
- `internal/metrics/store.go:207` — `func (s *Store) WriteMetrics(w io.Writer) error {` (body: `json.MarshalIndent(s.Metrics, "", "  ")`)
- `internal/exporter/prometheus.go:36` — `e.store.Range(func(m *metrics.Metric) error {`

### (b)+(c) Use case 2.3 — Quản lý vòng đời metric: hạn mức label set, expiry và GC loop

Kịch bản: log có nhãn giá trị tự do (vd. client id) khiến metric phình vô hạn. Bạn đặt `Limit` cho metric,
đánh dấu label set `"stale"` hết hạn sau 30 phút (`ExpireDatum` ghi `lv.Expiry`), ép `Gc()` dọn ngay, và
khởi động `StartGcLoop` chạy GC định kỳ tới khi context hủy — đúng vòng đời mà `cmd/mtail` bật qua cờ
`-expired_metric_gc_tick_interval` (cmd/mtail/main.go:229-231, grep thấy trên cây PIN).

```go
package main

import (
	"context"
	"time"

	"github.com/google/mtail/internal/metrics"
)

func main() {
	store := metrics.NewStore()
	m := metrics.NewMetric("latency_ms", "demo_prog", metrics.Timer, metrics.Int, "client")
	if err := store.Add(m); err != nil { panic(err) }
	m.Limit = 1000 // Gc cắt bớt label set khi vượt hạn mức
	if _, err := m.GetDatum("stale"); err != nil { panic(err) }
	// "stale" hết hạn sau 30 phút không cập nhật (set lv.Expiry).
	if err := m.ExpireDatum(30*time.Minute, "stale"); err != nil { panic(err) }
	if err := store.Gc(); err != nil { panic(err) } // dọn ngay: quá hạn / vượt hạn mức
	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()
	store.StartGcLoop(ctx, time.Minute) // GC định kỳ tới khi ctx hủy
}
```

Evidence (grep trên cây PIN):
- `internal/metrics/metric.go:94` — field `Limit int` của `type Metric struct` (:84-97)
- `internal/metrics/store.go:156` — `func (s *Store) Gc() error {` (body :160-178: `m.Limit > 0 && len(m.LabelValues) >= m.Limit` → `RemoveOldestDatum`; `now.Sub(lv.Value.TimeUTC()) > lv.Expiry` → `RemoveDatum`)
- `internal/metrics/metric.go:223` — `func (m *Metric) ExpireDatum(expiry time.Duration, labelvalues ...string) error {` (body :227-235: `lv.Expiry = expiry`)
- `internal/metrics/metric.go:78` — field `Expiry time.Duration` của `type LabelValue struct` (:73-80)
- `internal/metrics/store.go:183` — `func (s *Store) StartGcLoop(ctx context.Context, duration time.Duration) {`
- `cmd/mtail/main.go:229` — `store.StartGcLoop(ctx, *expiredMetricGcTickInterval)` (trong khối 228-231 grep thấy)

### (d) Deps cần kéo theo (s07)

- Ví dụ import `internal/metrics` (chính item) + `internal/metrics/datum` (**m09** — deps_in duy nhất của
  m07, fact từ brief/gm-02) + stdlib. Không cần thêm package mtail nào khác cho 3 use case trên.

### (e) Build riêng item (s07)

`go build ./... && go test ./...` — **SKIPPED** (không Go toolchain trong sandbox; entry build: `go.mod:1`, `Makefile:15`).

---

## s02 — mtail · internal/mtail

### (a) Item này giải quyết vấn đề gì

`internal/mtail` chứa `Server` — thành phần điều phối chính: giữ `metrics.Store`, `tailer.Tailer` (đọc log →
channel `lines`), `runtime.Runtime` (nạp chương trình + vòng đời VM) và `exporter.Exporter`, đồng thời chạy
HTTP server (metrics/pprof/zpages) qua `New()`; `options.go` định nghĩa toàn bộ `Option` cấu hình Server
(fact từ brief/gm-02 m02). Ai muốn nhúng toàn bộ pipeline log→metric của mtail vào chương trình Go riêng
(như binary `cmd/mtail` đã làm) thì dùng item này.

### (b)+(c) Use case 3.1 — Nhúng mtail Server vào chương trình Go với graceful shutdown

Kịch bản: dịch vụ Go của bạn cần tự đọc log và expose metric Prometheus; thay vì chạy binary `mtail` riêng,
bạn dựng `Server` in-process: `New(ctx, store, options...)` với `ProgramPath`, `LogPathPatterns`,
`BindAddress`, rồi `Run()` block tới khi mọi subroutine kết thúc; Ctrl-C/SIGTERM hủy context để tắt sạch —
mô hình y như `cmd/mtail/main.go` (dòng 159-165 bắt signal, 232 `mtail.New`, 238 `m.Run()`).

```go
package main

import (
	"context"
	"os"
	"os/signal"
	"syscall"

	"github.com/google/mtail/internal/metrics"
	"github.com/google/mtail/internal/mtail"
)

func main() {
	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()
	sigint := make(chan os.Signal, 1)
	signal.Notify(sigint, os.Interrupt, syscall.SIGTERM)
	go func() { <-sigint; cancel() }()
	store := metrics.NewStore()
	m, err := mtail.New(ctx, store,
		mtail.ProgramPath("/etc/mtail"),
		mtail.LogPathPatterns("/var/log/app/*.log"),
		mtail.BindAddress("127.0.0.1", "3903"),
	)
	if err != nil { panic(err) }
	if err := m.Run(); err != nil { panic(err) } // block tới khi mọi subroutine xong
}
```

Evidence (grep trên cây PIN):
- `internal/mtail/mtail.go:176` — `func New(ctx context.Context, store *metrics.Store, options ...Option) (*Server, error) {`
- `internal/mtail/mtail.go:238` — `func (m *Server) Run() error {` (body :238-247: `m.wg.Wait(); m.cancel()`, thoát sớm nếu compileOnly)
- `internal/mtail/options.go:27` — `type ProgramPath string` (apply :29 `func (opt ProgramPath) apply(m *Server) error`)
- `internal/mtail/options.go:38` — `func LogPathPatterns(patterns ...string) Option {` · `options.go:58` — `func BindAddress(address, port string) Option {`
- `cmd/mtail/main.go:169-175` — `opts := []mtail.Option{ mtail.ProgramPath(*progs), mtail.LogPathPatterns(logs...), ... }` · `main.go:232` — `m, err := mtail.New(ctx, store, opts...)` · `main.go:238` — `err = m.Run()` · `main.go:159-165` — `signal.Notify(sigint, os.Interrupt, syscall.SIGTERM)` + goroutine `cancel()`

### (b)+(c) Use case 3.2 — CI validator: chỉ biên dịch + dump bytecode cho mọi chương trình

Kịch bản: pipeline CI của team muốn chặn PR làm hỏng chương trình `.mtail`: dựng Server với `CompileOnly`
(không tail log — `Run()` thoát ngay sau khi mọi chương trình biên dịch xong, mtail.go:241-244) và
`DumpBytecode` để in bytecode sau codegen ra log CI; `New` trả lỗi nếu cấu hình sai, còn lỗi biên dịch từng
file được runtime ghi nhận. Niladic option `CompileOnly`/`DumpBytecode` là biến public của package
(options.go:159-162, 185-188) — cùng cách `cmd/mtail` append vào opts khi cờ `-compile_only`/`-dump_bytecode` bật.

```go
package main

import (
	"context"

	"github.com/google/mtail/internal/metrics"
	"github.com/google/mtail/internal/mtail"
)

// CI check: biên dịch mọi .mtail trong ./progs; lỗi compile → exit non-zero.
func main() {
	ctx := context.Background()
	m, err := mtail.New(ctx, metrics.NewStore(),
		mtail.ProgramPath("./progs"),
		mtail.CompileOnly,  // chỉ biên dịch rồi thoát (mtail.go:241-244)
		mtail.DumpBytecode, // in bytecode sau codegen để diff trong CI
	)
	if err != nil {
		panic(err)
	}
	if err := m.Run(); err != nil {
		panic(err)
	}
}
```

Evidence (grep trên cây PIN):
- `internal/mtail/options.go:159-162` — `// CompileOnly sets compile-only mode in the Server.` + `var CompileOnly = &niladicOption{ ... m.rOpts = append(m.rOpts, runtime.CompileOnly())`
- `internal/mtail/options.go:185-188` — `// DumpBytecode instructs the Server's compiuler to print the program bytecode after code generation.` + `var DumpBytecode = &niladicOption{ ... runtime.DumpBytecode()`
- `internal/mtail/mtail.go:241-244` — `if m.compileOnly { glog.Info("compile-only is set, exiting"); return nil }`
- `cmd/mtail/main.go:196-204` — `if *compileOnly { opts = append(opts, mtail.CompileOnly) }` … `if *dumpBytecode { opts = append(opts, mtail.DumpBytecode) }`
- `internal/mtail/options.go:141-144` — `type niladicOption struct { applyfunc func(m *Server) error ... }` (cơ chế option không tham số)

### (b)+(c) Use case 3.3 — Xử lý một snapshot log rồi thoát (OneShot) cho cron/CI

Kịch bản: bạn cần tính metric từ một file log tĩnh (fixture, bản archive) mà không giữ Server chạy nền:
`OneShot` bảo tailer đọc tới EOF rồi kết thúc, `Run()` chỉ block tới khi mọi subroutine xong, sau đó store
chứa metric của lần chạy — dump JSON bằng `WriteMetrics` (đúng mô hình `-one_shot` của `cmd/mtail`,
main.go:245-249 grep thấy nhánh `if *oneShot`).

```go
package main

import (
	"context"
	"os"

	"github.com/google/mtail/internal/metrics"
	"github.com/google/mtail/internal/mtail"
)

// Snapshot: xử lý toàn bộ nội dung log hiện có rồi thoát — cho cron/CI.
func main() {
	ctx := context.Background()
	store := metrics.NewStore()
	m, err := mtail.New(ctx, store,
		mtail.ProgramPath("./progs"),
		mtail.LogPathPatterns("./fixtures/access.log"),
		mtail.OneShot, // tailer đọc tới EOF rồi kết thúc (options.go:148-152)
	)
	if err != nil { panic(err) }
	if err := m.Run(); err != nil { panic(err) } // block tới khi tailer xong (wg.Wait)
	store.WriteMetrics(os.Stdout) // metric của lần chạy snapshot, format JSON
}
```

Evidence (grep trên cây PIN):
- `internal/mtail/options.go:148-152` — `// OneShot sets one-shot mode in the Server.` + `var OneShot = &niladicOption{ ... m.tOpts = append(m.tOpts, tailer.OneShot)`
- `internal/mtail/mtail.go:238-239` — `func (m *Server) Run() error { m.wg.Wait() ...` (Run block tới khi mọi subroutine kết thúc)
- `internal/metrics/store.go:207` — `func (s *Store) WriteMetrics(w io.Writer) error {`
- `cmd/mtail/main.go:245-246` — `if *oneShot {` (nhánh xuất metric sau Run, grep thấy trong khối 225-245)

### (d) Deps cần kéo theo (s02)

- Ví dụ import `internal/mtail` (item) + `internal/metrics` (**m07** — tham số bắt buộc của `mtail.New`,
  thuộc deps_in của m02, fact từ brief/gm-02) + stdlib. Các thành phần khác (tailer/runtime/exporter/waker)
  được Server tự dựng bên trong `New` qua option apply, ví dụ không phải import trực tiếp.

### (e) Build riêng item (s02)

`go build ./... && go test ./...` — **SKIPPED** (không Go toolchain trong sandbox; entry build: `go.mod:1`, `Makefile:15`).

---

## s04 — vm · internal/runtime/vm

### (a) Item này giải quyết vấn đề gì

`internal/runtime/vm` chứa `VM` — máy ảo thông dịch bytecode do compiler sinh ra: `New()` nhận `code.Object`
(chương trình, regex/string constants, metrics) (vm.go:993-1009), `ProcessLogLine()` chạy vòng fetch–decode–
execute trên thread với stack máy ảo (vm.go:962-991), `execute()` switch qua opcode (`Match`, `Cmp`, `Inc`,
`Set`, `Strptime`, `Add`, `Del`, `Stop`, …) cập nhật `metrics.Metric`, kèm recover panic thành runtime error
(vm.go:336-350) và memo parse thời gian bằng LRU (vm.go:65) (fact từ brief/gm-02 m04). Đây là tầng chạy thật
mỗi dòng log — ai muốn test bytecode, dựng chương trình thủ công, hoặc nhúng interpreter vào pipeline riêng
thì dùng item này.

### (b)+(c) Use case 4.1 — Tự dựng bytecode và chạy trên VM: match log rồi tăng counter

Kịch bản: bạn dựng một chương trình 6 lệnh không cần file `.mtail`: `Match` regex `level=error` (push bool),
`Jnm` nhảy tới `Stop` nếu không match, `Mload` đẩy metric zero-key lên stack, `Dload` lấy datum, `Inc` tăng,
`Stop` kết thúc lượt. Chạy một dòng log qua `ProcessLogLine` và đọc counter từ metric — các opcode và ngữ
nghĩa stack đều đọc được từ source (vm.go:732 `Mload` push `v.Metrics[operand]`; :736 `Dload` pop metric + keys
→ `m.GetDatum(keys...)`; :473 `Inc` pop datum rồi `datum.IncIntBy`).

```go
package main

import ("context"; "regexp"; "time"
	"github.com/google/mtail/internal/logline"
	"github.com/google/mtail/internal/metrics"
	"github.com/google/mtail/internal/runtime/code"
	"github.com/google/mtail/internal/runtime/vm")

func main() {
	ctx := context.Background()
	m := metrics.NewMetric("error_lines_total", "hand_prog", metrics.Counter, metrics.Int)
	obj := &code.Object{
		Regexps: []*regexp.Regexp{regexp.MustCompile(`level=error`)},
		Metrics: []*metrics.Metric{m},
		Program: []code.Instr{
			{Opcode: code.Match, Operand: 0}, // match Regexps[0], push bool
			{Opcode: code.Jnm, Operand: 5},   // không match → pc 5 (Stop)
			{Opcode: code.Mload, Operand: 0}, // push Metrics[0]
			{Opcode: code.Dload, Operand: 0}, // push datum zero-key
			{Opcode: code.Inc, Operand: nil}, // datum++
			{Opcode: code.Stop, Operand: nil},
		},
	}
	v := vm.New("hand_prog", obj, false, time.UTC, false, false)
	v.ProcessLogLine(ctx, logline.New(ctx, "app.log", `level=error msg="boom"`))
	println(obj.Metrics[0].String())
}
```

Evidence (grep trên cây PIN):
- `internal/runtime/code/object.go:13-18` — `type Object struct { Program []Instr; Strings []string; Regexps []*regexp.Regexp; Metrics []*metrics.Metric }`
- `internal/runtime/code/instr.go:9-13` — `type Instr struct { Opcode Opcode; Operand interface{}; SourceLine int }`
- `internal/runtime/code/opcodes.go:11-42` — `Stop :11`, `Match :12`, `Inc :18`, `Mload :41` ("Load metric at operand onto top of stack"), `Dload :42` ("Pop `operand` keys and metric off stack, and push datum at metric[key,...] onto stack")
- `internal/runtime/vm/vm.go:732-733` — `case code.Mload:` → `t.Push(v.Metrics[i.Operand.(int)])` · `vm.go:736-760` — `case code.Dload:` → pop metric + keys rồi `m.GetDatum(keys...)` push datum
- `internal/runtime/vm/vm.go:444-450` — `case code.Jnm:` → `if !match { t.pc = i.Operand.(int) }` (nhảy khi match=false)
- `internal/runtime/vm/vm.go:473-488` — `case code.Inc:` → pop `datum.Datum` rồi `datum.IncIntBy(n, delta, t.time)`
- `internal/runtime/vm/vm.go:993` — `func New(name string, obj *code.Object, syslogUseCurrentYear bool, loc *time.Location, log bool, trace bool) *VM {` (body 994-1009: `re: obj.Regexps, str: obj.Strings, Metrics: obj.Metrics, prog: obj.Program`)
- `internal/runtime/vm/vm.go:962` — `func (v *VM) ProcessLogLine(_ context.Context, line *logline.LogLine) {` (body: tạo thread mới, `for { if t.pc >= len(v.prog) { return } ... v.execute(t, i); if v.terminate { ... return } }`)
- `internal/logline/logline.go:17` — `func New(ctx context.Context, filename string, line string) *LogLine {`
- `internal/metrics/metric.go:100` — `func NewMetric(name string, prog string, kind Kind, typ Type, keys ...string) *Metric {`
- Test chuẩn cùng kiểu dựng chương trình: `internal/runtime/vm/vm_test.go:19` `var instructions = []struct { ... i code.Instr ...}` (table-driven 7 hàm Test*, test lớn nhất 929 dòng — fact từ brief/gm-02).

### (b)+(c) Use case 4.2 — Debug bytecode: `DumpByteCode`, trace PC và runtime error string

Kịch bản: chương trình biên dịch được nhưng hành xử sai: bật `trace=true` để VM ghi lại đường pc từng bước,
in `DumpByteCode()` (disassembly của chương trình + constants) để đối chiếu, và sau khi xử lý log đọc
`RuntimeErrorString()` — panic trong `execute()` được recover thành runtime error thay vì làm sập tiến trình
(vm.go:336-350, recover tại :339).

```go
package main

import (
	"context"
	"fmt"
	"time"

	"github.com/google/mtail/internal/logline"
	"github.com/google/mtail/internal/runtime/code"
	"github.com/google/mtail/internal/runtime/vm"
)

// obj: code.Object từ UC 4.1 (hoặc từ compiler.Compile).
func debug(obj *code.Object) {
	ctx := context.Background()
	// log=true in runtime error; trace=true ghi lại đường pc từng bước.
	v := vm.New("prog", obj, false, time.UTC, true, true)
	fmt.Println(v.DumpByteCode()) // disassembly + constants để diff
	v.ProcessLogLine(ctx, logline.New(ctx, "app.log", `level=error`))
	if s := v.RuntimeErrorString(); s != "" {
		fmt.Println("runtime error:", s) // panic trong execute được recover
	}
}
```

Evidence (grep trên cây PIN):
- `internal/runtime/vm/vm.go:993` — `func New(..., log bool, trace bool) *VM {` (body :1005-1008: `if trace { v.trace = make([]int, 0, len(v.prog)) }`)
- `internal/runtime/vm/vm.go:1012` — `func (v *VM) DumpByteCode() string {`
- `internal/runtime/vm/vm.go:1043` — `func (v *VM) RuntimeErrorString() string {`
- `internal/runtime/vm/vm.go:339` — `if r := recover(); r != nil {` (trong `execute`, :336-350 — khối recover panic thành runtime error)
- `internal/runtime/vm/vm.go:973-974` — trong `ProcessLogLine`: `if v.trace != nil { v.trace = append(v.trace, t.pc) }`

### (b)+(c) Use case 4.3 — Chạy VM như consumer của channel (mô hình nối pipeline của runtime thật)

Kịch bản: thay vì gọi `ProcessLogLine` từng dòng, bạn chạy `VM.Run(lines, &wg)` trong goroutine riêng: VM
range trên channel cho tới khi channel đóng rồi `wg.Done` — đây chính là cách `internal/runtime` (m05) nối
VM vào pipeline dòng log của tailer; bạn đóng channel để tắt VM sạch.

```go
package main

import (
	"context"
	"sync"

	"github.com/google/mtail/internal/logline"
	"github.com/google/mtail/internal/runtime/vm"
)

// v: *vm.VM từ UC 4.1/4.2 — chạy như consumer của channel.
func feed(v *vm.VM, lines []string) {
	ch := make(chan *logline.LogLine, 8)
	var wg sync.WaitGroup
	wg.Add(1)
	go v.Run(ch, &wg) // Run thoát khi ch đóng (defer wg.Done)
	ctx := context.Background()
	for _, l := range lines {
		ch <- logline.New(ctx, "app.log", l)
	}
	close(ch)
	wg.Wait()
}
```

Evidence (grep trên cây PIN):
- `internal/runtime/vm/vm.go:1052-1060` — `func (v *VM) Run(lines <-chan *logline.LogLine, wg *sync.WaitGroup) { defer wg.Done() ... for line := range lines { v.ProcessLogLine(ctx, line) } }`
- `internal/logline/logline.go:9-14` — `type LogLine struct { Context context.Context; Filename string; Line string }` · `logline.go:17` — `func New(...)`

### (d) Deps cần kéo theo (s04)

- Ví dụ import `internal/runtime/vm` (item) + `internal/runtime/code` (**m14**), `internal/metrics` (**m07**),
  `internal/logline` (**m18**) — đúng bộ deps_in của m04: logline, metrics, datum, code (datum kéo theo
  qua metrics, fact từ brief/gm-02 m04).

### (e) Build riêng item (s04)

`go build ./... && go test ./...` — **SKIPPED** (không Go toolchain trong sandbox; entry build: `go.mod:1`, `Makefile:15`).

---

## s06 — exporter (`internal/exporter`, ★3, 12 files / 1599 LOC)

### (a) Item này giải quyết vấn đề gì

Package `exporter` là cổng xuất metric của mtail — "getting metrics out of mtail into your monitoring system of choice" (gm-02 m06): nó đọc `*metrics.Store` và phân phát metric đi nơi khác dưới 3 hình thức — (1) collector Prometheus (`Describe`/`Collect`) cắm vào `prometheus.Registry` để hệ thống scrape, (2) các HTTP handler format khác (`/varz`, `/json`, `/graphite`), (3) push định kỳ ra push target (collectd/graphite/statsd). Cấu hình qua `Option` (`Hostname`, `OmitProgLabel`, `EmitTimestamp`, `PushInterval`, `DisableExport`) — tức ai cầm một `metrics.Store` filled đều dùng item này để đưa số liệu ra hệ thống giám sát mà không đụng vào phần biên dịch/tail.

### (b) Use cases

#### UC-06.1 — Cắm Store vào Prometheus scrape endpoint

Kịch bản: bạn nhúng bộ runtime của mtail vào service Go của riêng mình; VM đã điền metric vào `metrics.Store`. Bạn cần Prometheus scrape được số liệu đó: dựng `Exporter` trên store, đăng ký nó như một `prometheus.Collector` vào registry riêng, rồi mount `/metrics` bằng `promhttp` — đúng mô hình mà `internal/mtail/mtail.go` dùng nội bộ.

```go
package main

import (
	"context"
	"net/http"

	"github.com/google/mtail/internal/exporter"
	"github.com/google/mtail/internal/metrics"
	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promhttp"
)

func main() {
	ctx := context.Background()
	store := metrics.NewStore() // VM/runtime điền metric vào store này

	e, err := exporter.New(ctx, store)
	if err != nil {
		panic(err) // store nil → ErrNeedsStore
	}

	reg := prometheus.NewRegistry() // registry non-pedantic như mtail dùng
	reg.MustRegister(e)             // Exporter hiện thực prometheus.Collector

	http.Handle("/metrics", promhttp.HandlerFor(reg, promhttp.HandlerOpts{}))
	panic(http.ListenAndServe(":3903", nil))
}
```

Evidence (grep trên cây PIN):
- `internal/exporter/export.go:91` — `func New(ctx context.Context, store *metrics.Store, options ...Option) (*Exporter, error) {`; `:92–94` nil store → `ErrNeedsStore`.
- `internal/exporter/export.go:32` — `type Exporter struct {`.
- `internal/exporter/prometheus.go:26` — `func (e *Exporter) Describe(c chan<- *prometheus.Desc) {`; `:31` — `func (e *Exporter) Collect(c chan<- prometheus.Metric) {`; `:36` — `e.store.Range(func(m *metrics.Metric) error {` (Collect đi qua Range của store).
- Canonical dùng thật: `internal/mtail/mtail.go:72` `m.e, err = exporter.New(m.ctx, m.store, m.eOpts...)`; `:76` `m.reg.MustRegister(m.e)`; `mtail.go:176–186` `New` dựng `m := &Server{ … reg: prometheus.NewRegistry() …}` (comment "non-pedantic registry"); `mtail.go:120` `mux.Handle("/metrics", promhttp.HandlerFor(m.reg, promhttp.HandlerOpts{}))`.
- `internal/metrics/store.go:26` — `func NewStore() (s *Store) {`.

#### UC-06.2 — One-shot dump toàn bộ Store ra stdout

Kịch bản: chạy tác vụ xử lý log một lần (debug/batch), sau khi VM xử lý xong bạn muốn in toàn bộ giá trị metric hiện có ra stdout theo định dạng exposition Prometheus rồi thoát — đây chính là đường `-one_shot -one_shot_format prometheus` của binary `cmd/mtail`.

```go
func oneShotDump(ctx context.Context, store *metrics.Store) error {
	e, err := exporter.New(ctx, store)
	if err != nil {
		return err
	}
	defer e.Stop() // chờ các goroutine export con tắt hẳn

	// VM/runtime đã xử lý log xong; dump trạng thái store ra stdout
	// theo format exposition Prometheus.
	return e.Write(os.Stdout)
}
```

Evidence:
- `internal/exporter/prometheus.go:102` — `func (e *Exporter) Write(w io.Writer) error {`.
- `internal/exporter/export.go:142` — `func (e *Exporter) Stop() {`.
- Canonical dùng thật: `cmd/mtail/main.go:247` `e, err := exporter.New(ctx, store, eOpts...)` trong nhánh `-one_shot`; `main.go:254` `err = e.Write(os.Stdout)`.

#### UC-06.3 — Gắn các HTTP handler varz/json/graphite vào mux riêng + tuỳ biến Option

Kịch bản: service của bạn đã có HTTP mux riêng và bạn muốn mtail chỉ đóng vai "bộ xuất": nhả `/varz` (expvar text), `/json` (snapshot store dạng JSON), `/graphite` (format graphite) trên mux đó; đồng thời gắn hostname cố định cho metric, bỏ nhãn `prog` và phát kèm timestamp — tất cả qua các `Option` constructor của package.

```go
func mountExporter(ctx context.Context, store *metrics.Store) error {
	e, err := exporter.New(ctx, store,
		exporter.Hostname("logsrv-01"),
		exporter.OmitProgLabel(),
		exporter.EmitTimestamp())
	if err != nil {
		return err
	}

	mux := http.NewServeMux()
	mux.HandleFunc("/varz", http.HandlerFunc(e.HandleVarz))
	mux.HandleFunc("/json", http.HandlerFunc(e.HandleJSON))
	mux.HandleFunc("/graphite", http.HandlerFunc(e.HandleGraphite))
	return http.ListenAndServe(":3903", mux)
}
```

Evidence:
- `internal/exporter/export.go:51` — `func Hostname(hostname string) Option {`; `:59` — `func OmitProgLabel() Option {`; `:67` — `func EmitTimestamp() Option {`.
- `internal/exporter/varz.go:21` — `func (e *Exporter) HandleVarz(w http.ResponseWriter, r *http.Request) {`; `internal/exporter/json.go:17` — `func (e *Exporter) HandleJSON(w http.ResponseWriter, _ *http.Request) {`; `internal/exporter/graphite.go:29` — `func (e *Exporter) HandleGraphite(w http.ResponseWriter, r *http.Request) {`.
- Canonical wiring mux thật: `internal/mtail/mtail.go:116` `mux.HandleFunc("/varz", http.HandlerFunc(m.e.HandleVarz))`; `:121` `/json` → `m.e.HandleJSON`; `:122` `/graphite` → `m.e.HandleGraphite`.
- Các Option khác có sẵn (không dùng trong ví dụ, liệt kê để tham chiếu): `export.go:74` `func PushInterval(opt time.Duration) Option`; `export.go:81` `func DisableExport() Option`.

### (c) Deps cần kéo theo

- `internal/metrics` (m07) — bắt buộc: tham số `*metrics.Store` của `New` (export.go:91); nil store → `ErrNeedsStore` (export.go:92–94). Ví dụ dùng `metrics.NewStore()` (store.go:26).
- `internal/metrics/datum` (m09) — gián tiếp qua `metrics.Metric` (Collect đi `e.store.Range` trên `*metrics.Metric`, prometheus.go:36).
- External: `github.com/prometheus/client_golang` (prometheus.Registry / promhttp — như mtail.go:120, mtail.go:76 dùng); stdlib `context`, `net/http`, `os`, `io`.

### (d) Build riêng item

`go build ./... && go test ./internal/exporter/...` — **SKIPPED**: sandbox `bitnami/git:latest` không có Go toolchain (`which go` → `no go in (…)`, log đầy đủ ở report task). Không bịa output; grep các API trên đã thực hiện trực tiếp trên cây PIN.

---

## s08 — tailer (`internal/tailer`, ★3, 5 files / 804 LOC)

### (a) Item này giải quyết vấn đề gì

`Tailer` là phần "đầu vào" của pipeline mtail — nó "polls the filesystem for log sources that match given `LogPathPatterns` and creates `LogStream`s to tail them" (tail.go:28–29, nguyên văn trong gm-02 m08): có thể yêu cầu tail đúng một pathname (`TailPath`) hoặc theo dõi một glob pattern để tự tail file mới xuất hiện (`AddPattern` → `pollLogPattern`), và mọi dòng đọc được được bơm lên một channel dùng chung `lines chan<- *logline.LogLine` cho phía tiêu thụ (VM/runtime). Tần suất poll điều khiển qua `waker.Waker` (2 Option), kèm trang trạng thái HTML (`WriteStatusHTML`) và khả năng loại file khỏi globbing bằng regex ignore.

### (b) Use cases

#### UC-08.1 — Tail đúng một file và tiêu thụ dòng log

Kịch bản: một process Go muốn "nằm theo" `/var/log/myapp.log` và tự xử lý từng dòng (ví dụ đẩy sang hàng đợi riêng) — không cần chương trình `.mtail`. Dựng channel + WaitGroup + waker định kỳ, gọi `TailPath`, rồi `range` trên channel; mỗi phần tử là `*logline.LogLine` có `Filename`/`Line`.

```go
func tailOne(ctx context.Context) error {
	lines := make(chan *logline.LogLine, 1024)
	var wg sync.WaitGroup
	ctx, cancel := context.WithCancel(ctx)
	defer cancel()

	wk := waker.NewTimed(ctx, 250*time.Millisecond)
	t, err := tailer.New(ctx, &wg, lines,
		tailer.LogstreamPollWaker(wk),
		tailer.LogPatternPollWaker(wk))
	if err != nil {
		return err
	}
	if err := t.TailPath("/var/log/myapp.log"); err != nil {
		return err
	}
	for line := range lines {
		glog.Infof("%s: %s", line.Filename, line.Line)
	}
	return nil
}
```

Evidence:
- `internal/tailer/tail.go:30` — `type Tailer struct {`; `:119` — `func New(ctx context.Context, wg *sync.WaitGroup, lines chan<- *logline.LogLine, options ...Option) (*Tailer, error) {`; `:120–122` nil channel → `ErrNoLinesChannel`; `:123–125` nil wg → `ErrNeedsWaitgroup`.
- `internal/tailer/tail.go:86` — `func LogPatternPollWaker(w waker.Waker) Option {`; `:100` — `func LogstreamPollWaker(w waker.Waker) Option {`.
- `internal/tailer/tail.go:256` — `func (t *Tailer) TailPath(pathname string) error {`; `:263` gọi `logstream.New(…)`; `:273–274` `for line := range l.Lines() { t.lines <- line }` (dòng log chảy vào channel `lines`).
- `internal/logline/logline.go:9–14` — `type LogLine struct { Context context.Context; Filename string; Line string }`; `:17` — `func New(ctx, filename, line)`.
- `internal/waker/timedwaker.go:22` — `func NewTimed(ctx context.Context, interval time.Duration) Waker`.
- Canonical dùng thật: `internal/mtail/mtail.go:91` `m.t, err = tailer.New(m.ctx, &m.wg, m.lines, m.tOpts...)`.

#### UC-08.2 — Theo dõi một glob pattern: file mới tự được tail + xem trang trạng thái

Kịch bản: thư viện app ghi log xoay vòng (`app-2026-02-26.log`, `app-2026-02-27.log`, …). Thay vì tail từng file, bạn nạp một pattern glob — `pollLogPattern` là goroutine vĩnh viễn poll theo waker, file mới khớp sẽ được tail tự động; đồng thời bạn muốn nhét nội dung trang trạng thái (patterns + bảng logstream) vào log định kỳ để theo dõi opens/truncs/errors/lines.

```go
func watchDir(ctx context.Context, pattern string) error {
	lines := make(chan *logline.LogLine, 1024)
	var wg sync.WaitGroup
	ctx, cancel := context.WithCancel(ctx)
	defer cancel()

	wk := waker.NewTimed(ctx, time.Second)
	t, err := tailer.New(ctx, &wg, lines,
		tailer.LogPatternPollWaker(wk),
		tailer.LogstreamPollWaker(wk))
	if err != nil {
		return err
	}
	if err := t.AddPattern(pattern); err != nil {
		return err
	}
	var sb strings.Builder
	if err := t.WriteStatusHTML(&sb); err != nil {
		return err
	}
	glog.Info(sb.String())
	for line := range lines {
		_ = line // xử lý dòng log tại đây
	}
	return nil
}
```

Evidence:
- `internal/tailer/tail.go:186` — `func (t *Tailer) AddPattern(pattern string) error {`.
- `internal/tailer/tail.go:288–289` — comment "pollLogPattern runs a permanent goroutine to poll for new log files" + `func (t *Tailer) pollLogPattern(pattern string) {`; `:321` — `func (t *Tailer) doPatternGlob(pattern string) error {`.
- `internal/tailer/httpstatus.go:44` — `func (t *Tailer) WriteStatusHTML(w io.Writer) error {`.

#### UC-08.3 — Loại file đã rotate (nén .gz) khỏi globbing

Kịch bản: pattern `*.log` trên một thư mục có cả file đã nén `app.log.gz`; nếu để tail sẽ nghe trùng dữ liệu cũ. `SetIgnorePattern` nhận một regex áp lên **tên file**, và `doPatternGlob` gọi `t.Ignore(pathname)` để bỏ qua mọi path khớp regex trước khi tạo logstream.

```go
func tailIgnoringRotated(ctx context.Context, pattern string) error {
	lines := make(chan *logline.LogLine, 1024)
	var wg sync.WaitGroup
	wk := waker.NewTimed(ctx, time.Second)
	t, err := tailer.New(ctx, &wg, lines,
		tailer.LogPatternPollWaker(wk),
		tailer.LogstreamPollWaker(wk))
	if err != nil {
		return err
	}
	// Bỏ qua file đã rotate nén: doPatternGlob sẽ gọi t.Ignore(pathname)
	if err := t.SetIgnorePattern(`\.gz$`); err != nil {
		return err
	}
	return t.AddPattern(pattern)
}
```

Evidence:
- `internal/tailer/tail.go:240` — `func (t *Tailer) SetIgnorePattern(pattern string) error {` (compile regex, gán `t.ignoreRegexPattern`).
- `internal/tailer/tail.go:222` — `func (t *Tailer) Ignore(pathname string) bool {`; `:239` — `return t.ignoreRegexPattern != nil && t.ignoreRegexPattern.MatchString(fi.Name())` (match trên tên file).
- `internal/tailer/tail.go:328` — `if t.Ignore(pathname) {` — điểm gọi trong `doPatternGlob`.

### (c) Deps cần kéo theo

- `internal/logline` (m18) — bắt buộc: kiểu `*logline.LogLine` của channel `lines` (tail.go:119; logline.go:9–14).
- `internal/tailer/logstream` (m03) — tự kéo theo khi `TailPath` chạy (tail.go:263 `logstream.New`); không cần import trực tiếp trong ví dụ.
- `internal/waker` (m11) — bắt buộc qua 2 Option `LogPatternPollWaker`/`LogstreamPollWaker` (tail.go:86/:100); ví dụ dùng `waker.NewTimed` (timedwaker.go:22).
- Stdlib: `context`, `sync`, `time`, `strings`.

### (d) Build riêng item

`go build ./... && go test ./internal/tailer/...` — **SKIPPED**: không có Go toolchain trong sandbox (giải thích ở đầu file). Grep evidence thực hiện trực tiếp trên cây PIN.

---

## s09 — datum (`internal/metrics/datum`, ★3, 8 files / 667 LOC)

### (a) Item này giải quyết vấn đề gì

datum định nghĩa value-type của metric (gm-02 m09): interface `Datum` (`ValueString`/`TimeString`/`TimeUTC`) + struct nền `BaseDatum` đóng dấu timestamp atomic, cùng 4 hiện thực `Int`, `Float`, `String`, `Buckets` (histogram theo Range) và các constructor zero-value `NewInt/NewFloat/NewString/NewBuckets`. Đây là đáy của đồ thị (deps_in = 0): mọi metric trong `metrics.Metric` đều cầm một `Datum`, nên store/exporter/VM thao tác giá trị số đồng nhất qua đúng 1 interface — ai muốn hiểu hoặc tái sử dụng cơ chế đo đếm của mtail (kèm timestamp từng điểm dữ liệu) thì bắt đầu từ package này.

### (b) Use cases

#### UC-09.1 — Tạo và cập nhật datum int/float kèm timestamp

Kịch bản: bạn xây một exporter nhỏ riêng (ngoài mtail) và muốn tái dùng cơ chế "giá trị + timestamp" của mtail cho các bộ đếm: tạo datum zero qua constructor, tăng/gán giá trị (timestamp zero → tự stamp "bây giờ" theo `BaseDatum.stamp`), rồi đọc lại cả giá trị lẫn chuỗi value để render.

```go
func typedDatums(ts time.Time) {
	di := datum.NewInt().(*datum.Int) // zero int datum
	di.IncBy(3, time.Time{})          // ts zero => được stamp "now"
	glog.Infof("int: get=%d value=%q", di.Get(), di.ValueString())

	df := datum.NewFloat().(*datum.Float)
	df.Set(2.5, ts)
	glog.Infof("float: get=%v value=%q", df.Get(), df.ValueString())

	// Hoặc dựng trực tiếp datum với value+timestamp sẵn có:
	dm := datum.MakeInt(7, ts)
	glog.Infof("made int: get=%d", dm.(*datum.Int).Get())
}
```

Evidence:
- `internal/metrics/datum/datum.go:55` — `func NewInt() Datum {` (`return MakeInt(0, zeroTime)`); `:60` — `func NewFloat() Datum {`; `:65` — `func NewString() Datum {`; `:70` — `func NewBuckets(buckets []Range) Datum {`.
- `internal/metrics/datum/datum.go:36–40` — `func (d *BaseDatum) stamp(timestamp time.Time)`: `timestamp.IsZero()` → `atomic.StoreInt64(&d.Time, time.Now().UTC().UnixNano())`, ngược lại stamp đúng ts đưa vào.
- `internal/metrics/datum/int.go:14` — `type Int struct {`; `:26` — `func (d *Int) IncBy(delta int64, timestamp time.Time) {`; `:38` — `func (d *Int) Get() int64`; `:43` — `func (d *Int) ValueString() string`.
- `internal/metrics/datum/float.go:15` — `type Float struct {`; `:26` — `func (d *Float) Set(v float64, ts time.Time) {`; `:32` — `func (d *Float) Get() float64`; `:21` — `func (d *Float) ValueString() string`.
- `internal/metrics/datum/datum.go:75` — `func MakeInt(v int64, ts time.Time) Datum {`.

#### UC-09.2 — Histogram bằng Buckets + Range

Kịch bản: đo latency của một thao tác theo bin hàng loạt (histogram): tạo `Buckets` từ danh sách `Range{Min, Max}`, nạp quan sát bằng `Observe` (bin tự chọn qua `Range.Contains`), sau đó lấy tổng quan — số quan sát, tổng, và bản đồ bin→count — để tự render hoặc đưa vào metric hệ thống khác.

```go
func latencyHistogram(ts time.Time) {
	d := datum.NewBuckets([]datum.Range{
		{Min: 0, Max: 10},
		{Min: 10, Max: 100},
		{Min: 100, Max: 1000},
	})
	b := d.(*datum.Buckets)

	b.Observe(42, ts)   // rơi vào bin [10,100]
	b.Observe(1234, ts) // rơi vào bin [100,1000]

	glog.Infof("count=%d sum=%v value=%q", b.GetCount(), b.GetSum(), b.ValueString())
	for r, count := range b.GetBuckets() {
		glog.Infof("bin (%v,%v]: %d", r.Min, r.Max, count)
	}
}
```

Evidence:
- `internal/metrics/datum/datum.go:70` — `func NewBuckets(buckets []Range) Datum {`.
- `internal/metrics/datum/buckets.go:15` — `type Range struct { Min float64; Max float64 }` (2 trường, sed kiểm chứng); `:25` — `func (r *Range) Contains(v float64) bool { return r.Min < v && v <= r.Max }`.
- `internal/metrics/datum/buckets.go:30` — `type Buckets struct {`; `:42` — `func (d *Buckets) Observe(v float64, ts time.Time) {`; `:59` — `func (d *Buckets) GetCount() uint64`; `:65` — `func (d *Buckets) GetSum() float64`; `:79` — `func (d *Buckets) GetBuckets() map[Range]uint64`.

#### UC-09.3 — Datum chuỗi (free-text metric) + đọc timestamp thống nhất qua interface

Kịch bản: bạn cần một metric kiểu "giá trị text gần nhất" (ví dụ upstream đang được dùng) và muốn mọi loại datum đọc timestamp theo cùng một giao diện: giữ `Datum` trong map chung, nạp `String` datum, rồi đọc `ValueString()`/`TimeString()`/`TimeUTC()` — đúng bộ 3 phương thức interface `Datum` khai báo.

```go
func stringDatumDemo(ts time.Time) {
	d := datum.NewString()            // giữ kiểu Datum interface
	ds := d.(*datum.String)           // cần type-assert để Set
	ds.Set("upstream=A", ts)

	// Đọc qua interface Datum (ValueString/TimeString/TimeUTC):
	var as datum.Datum = ds
	glog.Infof("value=%q ts=%s utc=%v",
		as.ValueString(), as.TimeString(), as.TimeUTC())
}
```

Evidence:
- `internal/metrics/datum/datum.go:15` — `type Datum interface {`; `:20` — `ValueString() string`; `:23` — `TimeString() string`; `:26` — `TimeUTC() time.Time`.
- `internal/metrics/datum/datum.go:30` — `type BaseDatum struct {`; `:31` — `Time int64 // nanoseconds since unix epoch`; `:45` — `func (d *BaseDatum) TimeString() string`; `:49` — `func (d *BaseDatum) TimeUTC() time.Time`.
- `internal/metrics/datum/string.go:14` — `type String struct {`; `:21` — `func (d *String) Set(value string, timestamp time.Time) {`; `:29` — `func (d *String) Get() string`; `:36` — `func (d *String) ValueString() string`.

### (c) Deps cần kéo theo

- deps_in = **0** (gm-02 m09: datum chỉ import stdlib — `fmt`, `math`, `sort`, `sync/atomic`, `time`, đã mở datum.go:6–12) → item này dùng độc lập, không kéo item mtail nào.
- Người tiêu thụ (deps_out, tham chiếu gm-02): metrics (m07) cầm datum trong `Metric`, exporter/vm/compiler/golden đều import — ví dụ UC-06 (exporter) điển hình: Collect đọc qua `store.Range` rồi render `Datum`.
- Stdlib: `time`.

### (d) Build riêng item

`go build ./... && go test ./internal/metrics/datum/...` — **SKIPPED**: không có Go toolchain trong sandbox. Grep evidence thực hiện trực tiếp trên cây PIN.

---

## s11 — waker (`internal/waker`, ★3, 5 files / 335 LOC)

### (a) Item này giải quyết vấn đề gì

waker định nghĩa interface đồng bộ hóa `Waker` — kênh `Wake()` được đóng khi routine rảnh cần dậy (gm-02 m11) — cùng 3 hiện thực: `timedWaker` (đánh thức định kỳ theo ticker, dùng trong production), `testWaker` (đồng bộ hóa có kiểm soát giữa goroutine bị test và vòng lặp test, kèm `WakeFunc` kích phát) và `alwaysWaker` (kênh đã đóng sẵn, không bao giờ chặn). Đây là khớp nối "idle loop ↔ người đánh thức": tailer/logstream của mtail block trên `<-w.Wake()` thay vì sleep cứng, nên cùng một vòng lặp chạy được cả trong production (ticker) lẫn test (kích phát có kiểm soát).

### (b) Use cases

#### UC-11.1 — Vòng lặp idle worker đánh thức định kỳ (timedWaker)

Kịch bản: một goroutine nền của bạn rảnh rỗi phần lớn thời gian nhưng phải re-check trạng thái (fs, deadline, cache) định kỳ. Thay vì `time.Sleep` cứng, block trên `<-w.Wake()`: `timedWaker` đóng kênh wake sau mỗi tick; hủy context là toàn bộ vòng lặp thoát (waker tự Stop ticker khi ctx cancel).

```go
func pollLoop(ctx context.Context) {
	ctx, cancel := context.WithCancel(ctx)
	defer cancel()

	w := waker.NewTimed(ctx, 250*time.Millisecond)
	for {
		select {
		case <-ctx.Done():
			return
		case <-w.Wake(): // kênh được close mỗi tick
			refreshState() // công việc chờ: re-read fs, re-check deadline…
		}
	}
}
```

Evidence:
- `internal/waker/waker.go:7` — `type Waker interface {`; `:9` — `Wake() <-chan struct{}` (comment ":8 // Wake returns a channel that's closed when the idle routine should wake up.").
- `internal/waker/timedwaker.go:22` — `func NewTimed(ctx context.Context, interval time.Duration) Waker` (goroutine dừng khi ctx cancel, `defer t.t.Stop()` :27–28); `:45–49` — `func (t *timedWaker) Wake() (w <-chan struct{})`.
- Canonical consumption pattern: `internal/tailer/logstream/filestream.go:230–231` — `case <-waker.Wake():` / comment `// sleep until next Wake()`; `internal/tailer/tail.go:310` — `case <-t.logPatternPollWaker.Wake():`.

#### UC-11.2 — Waker "không bao giờ chặn" cho vòng one-shot/test

Kịch bản: bạn viết vòng xử lý kiểu drain-một-lần hoặc test đơn giản không cần đồng bộ hoá: dùng `NewTestAlways` — `alwaysWaker` trả về kênh đã `close` sẵn trong constructor nên select không bao giờ block, mỗi vòng lặp chạy liền không chờ tick.

```go
func busyDrain() {
	w := waker.NewTestAlways()
	// alwaysWaker "never blocks the wakee": kênh wake đã close sẵn,
	// select dưới đây luôn nhánh Wake() ngay lập tức.
	for i := 0; i < 3; i++ {
		select {
		case <-w.Wake():
			processOne()
		default:
			// không bao giờ rơi vào đây với alwaysWaker
		}
	}
}
```

Evidence:
- `internal/waker/testwaker.go:124` — comment `// alwaysWaker never blocks the wakee.`; `:125` — `type alwaysWaker struct { wake chan struct{} }`.
- `internal/waker/testwaker.go:129–134` — `func NewTestAlways() Waker { … close(w.wake); return w }` (close ngay trong constructor); `:137–139` — `func (w *alwaysWaker) Wake() <-chan struct{} { return w.wake }`.

#### UC-11.3 — Tự cài đặt Waker (close-and-reset) + testWaker cho test đồng bộ

Kịch bản: một component riêng của bạn muốn đúng mô hình waker của mtail nhưng tín hiệu đến từ sự kiện của bạn (không phải ticker): tự hiện thực interface `Waker` theo pattern close-and-reset của `timedWaker` — `close(wake)` đánh thức mọi người đang block, rồi tạo kênh mới cho chu kỳ sau. Trong test, dùng sẵn `NewTest` để đồng bộ hoá chính xác thời điểm goroutine bị test gọi `Wake()`.

```go
type signalWaker struct {
	mu   sync.Mutex
	wake chan struct{}
}

func newSignalWaker() *signalWaker { return &signalWaker{wake: make(chan struct{})} }

func (s *signalWaker) Wake() <-chan struct{} {
	s.mu.Lock()
	defer s.mu.Unlock()
	return s.wake
}

func (s *signalWaker) Signal() {
	s.mu.Lock()
	close(s.wake)
	s.wake = make(chan struct{}) // close-and-reset như timedWaker
	s.mu.Unlock()
}
```

Evidence:
- `internal/waker/waker.go:7–10` — interface cần hiện thực: `type Waker interface { Wake() <-chan struct{} }`.
- Pattern close-and-reset gốc: `internal/waker/timedwaker.go:34–38` — `t.mu.Lock(); close(t.wake); t.wake = make(chan struct{}); t.mu.Unlock()`; cùng pattern trong test: `internal/waker/testwaker.go:115–122` — `func (t *testWaker) broadcastWakeAndReset() { … close(t.wake); t.wake = make(chan struct{}) … }`.
- testWaker cho test: `internal/waker/testwaker.go:37` — `type WakeFunc func(int, int)` (tham số: số wakee cần đánh thức, số wakee chờ gọi Wake); `:42` — `func NewTest(ctx context.Context, wait int, name string) (Waker, WakeFunc)`.

### (c) Deps cần kéo theo

- deps_in = **0** (gm-02 m11: waker không import package mtail nào — waker.go/timedwaker.go/testwaker.go chỉ dùng stdlib `context`, `sync`, `time`, `github.com/golang/glog`) → dùng độc lập.
- Người tiêu thụ (deps_out, tham chiếu gm-02): logstream (m03), tailer (m08), mtail (m02), cmd/mtail (m12) — đúng như UC-08.1 (tailer cần 2 Option nhận `waker.Waker`) và UC-11.1 (pattern `<-w.Wake()` trong filestream.go:230).
- Stdlib: `context`, `sync`, `time`.

### (d) Build riêng item

`go build ./... && go test ./internal/waker/...` — **SKIPPED**: không có Go toolchain trong sandbox. Grep evidence thực hiện trực tiếp trên cây PIN.

---

## Trạng thái merge (máy-đọc)

| Nguồn | File | Nội dung góp vào merge | Trạng thái |
|---|---|---|---|
| u_w1 | `reports/mtail/gm-12-usage-w1.md` | s01 (mục từ Dòng 20), s07 (Dòng 153), s02 (Dòng 294), s04 (Dòng 441) — 12 use case | 4/4 `section_done: true` (`u-status-w1.json` Dòng 2-5) |
| u_w2 | `reports/mtail/gm-12-usage-w2.md` | s06 (mục từ Dòng 12), s08 (Dòng 124), s09 (Dòng 247), s11 (Dòng 344) — 12 use case | 4/4 `section_done: true` (`u-status-w2.json` Dòng 2-33) |

- Tổng merge: **8/8 item** của `u-checklist.json` (Dòng 2-94), **24/24 use case**, mỗi use case kèm evidence `File:dòng` trên cây PIN `4c7e0e1174ac1ead032efe28d86428bbbe0ae145`.
- Node merge KHÔNG thêm/sửa ví dụ hay evidence nào — chỉ tổng hợp bảng (module | dùng khi nào | deps_out) từ (a)-section của worker + `deps_out` nguyên văn `u-checklist.json`.
- Build/test: SKIPPED toàn bộ (kế thừa ghi chú trung thực của cả 2 worker — sandbox không Go toolchain), KHÔNG bịa output.
- Bảng tóm tắt use case từng worker nằm trong file worker tương ứng (cuối `gm-12-usage-w1.md` Dòng 592-603, cuối `gm-12-usage-w2.md` Dòng 445-456).
