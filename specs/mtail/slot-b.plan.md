# gm-09b — EXTRACTION PLAN — SLOT B (google/mtail @ PIN `4c7e0e11`) — item **s07 `metrics`** ★4

**GHI RÕ BẮT BUỘC (brief `ex_b--7c62dead.md` Dòng 7): đây chỉ là PLAN.** Cắt thật là lệnh riêng
ngoài run. Plan KHÔNG tự cắt, KHÔNG tự tạo repo, KHÔNG push, KHÔNG chép code upstream vào file
này — chỉ CHỈ ĐỊNH file (trừ khối go.mod MỚI mục 4, vốn không phải code upstream).

- **Item chọn: s07 `internal/metrics` — ★4 (T=7)**, item ≥4 sao **ĐỨNG THỨ HAI** trong
  `reports/mtail/gm-08-stars.md`. Thứ nhất là **s01 `compiler`** ★4 — đã thuộc slot A (đối chiếu:
  File: reports/mtail/gm-09a-plan.md | Dòng: 23 | Nội dung: "SLOT A takes s01 compiler (first
  ≥4-star item in rank order); slot B's own node takes s07").
- **Kê khai tie (trung thực): s01 và s07 CÙNG ★4, CÙNG T=7** (File: reports/mtail/gm-08-stars.md |
  Dòng: 25, 31 | Nội dung: hai hàng `★4 | 7`). Thứ tự "thứ nhất/thứ hai" = thứ tự hàng trong bảng
  merge §1 (s01 tại Dòng 25 đứng trước s07 tại Dòng 31), thống nhất với JSON block §2 (s01 Dòng 49
  trước s07 Dòng 55) và phân bố §5 (File: reports/mtail/gm-08-stars.md | Dòng: 87 | Nội dung:
  "★4 | 2 | s01 compiler, s07 metrics"); id tăng dần s01 < s07. Slot A đã nhận s01 theo cùng quy
  tắc → không mơ hồ, không cần cơ chế tie-break khác. ("Không cần tie-break" tại gm-08-stars §4
  Dòng 80 là về cap ★5 — khác chủ đề.)
- Nguồn sao: File: reports/mtail/gm-08-stars.md | Dòng: 31 (bảng: s07, ★4, T=7, S1=2 S2=2 S3=2
  S4=0 S5=1) · Dòng: 55 (JSON). Oracles: File: reports/mtail/gm-08-oracles-raw.md | Dòng: 508
  (m07: D=1, out=8, C=9, loc_total=1326, loc_test=681, ratio 0.5136, logic_loc=645, pub_funcs=28).
  Tập ≥4★ có 2 item = số 2 yêu cầu → **KHÔNG rơi nhánh 'N/A'** (brief Dòng 6).
- **LẦN CHẠY 2+ check (brief Dòng 3):** glob `reports/mtail/*` đầu phiên có tới `gm-08-stars.md`
  nhưng **KHÔNG có `gm-09b*`** → lần chạy 1, không INHERITED, không fix-list.
- **PIN: `4c7e0e1174ac1ead032efe28d86428bbbe0ae145`** — `sandbox_git_clone` trả
  `headCommit = 4c7e0e1174ac1ead032efe28d86428bbbe0ae145`, branch `main` (File:
  reports/mtail/gm-08-stars.md | Dòng: 4 | Nội dung: "PIN đo: 4c7e0e1174ac1ead032efe28d86428bbbe0ae145
  (branch main)") — khớp tuyệt đối; slot A clone độc lập cùng ra PIN (gm-09a-plan.md Dòng 8).
  Kê khai giống caveat gm-08 (File: reports/mtail/gm-08-stars.md | Dòng: 98): VFS sync không mang
  `.git` nên `git rev-parse` không chạy được trong container — PIN lấy từ kết quả clone tool, mọi
  đo dưới đây trên đúng cây đó.
- Upstream: https://github.com/google/mtail — branch default `main` (clone single-branch `main`
  không `-b` khác vẫn ra đúng PIN; cả slot A lẫn gm-08 đều kê khai `main`).
- Copy-then-prune — QUY TẮC SẮT (brief ex_a Dòng 6-12, áp dụng chung): copy cả cục NGUYÊN CỤC
  (byte-identical) rồi cắt tỉa theo bảng mục 3; cấm viết lại code. Quy trình GIỐNG slot A
  (brief Dòng 6) → plan bám khuôn 6 mục của `reports/codesearch/gm-09b-plan.md` và đồng bộ cấu
  hình với `reports/mtail/gm-09a-plan.md` (go.mod MỚI tối thiểu + go.sum nguyên cục, mục 4).

## 1. Ranh giới phụ thuộc (grep-verified trên cây PIN, session `sess-9c3bfead`)

| Claim | Evidence |
|---|---|
| `metrics` phụ thuộc nội bộ duy nhất package anh em `datum` (D=1) | File: internal/metrics/metric.go \| Dòng: 18 \| Nội dung: `"github.com/google/mtail/internal/metrics/datum"` — grep `mtail/internal` trên 4 file non-test (metric.go, store.go, testing.go, type.go) trả ĐÚNG 1 hit; khớp oracle s1_deps=1 (raw:508) |
| `datum` KHÔNG import item nội bộ nào (D=0) | grep `mtail/internal` trên 5 file non-test của `internal/metrics/datum` = 0 hit (chạy thật: "(none)") — khớp raw:510 (m09 D=0) |
| External deps non-test của metrics = đúng 2 module ngoài + stdlib | grep import trên 4 file non-test: `github.com/golang/glog` ×2 (metric.go:17, store.go:14), `github.com/pkg/errors` ×2 (metric.go:19, store.go:15), còn lại stdlib: context, encoding/json, fmt, io, math/rand, reflect, strings, sync, time |
| E1=4 hits khớp part w1 nguyên văn | File: reports/mtail/gm-08-part-w1.md \| Dòng: 52 \| Nội dung: "m07 E1(4): metrics/store.go:14 glog, :15 pkg/errors; metrics/metric.go:17 glog, :19 pkg/errors" — đo tươi trùng từng dòng (S4=0 đúng như đã chấm: dùng 2 thư viện OSS có sẵn) |
| Fan-in: 19 file non-test / 8 item tiêu thụ metrics (out=8, C=9) | grep -rl non-test trên cây: `cmd/mtail/main.go`; exporter 6 file (collectd, export, graphite, prometheus, statsd, varz); `internal/mtail/golden/reader.go` + `internal/mtail/testing.go`; `internal/runtime/code/object.go`; compiler 6 file (ast/ast.go, checker/checker.go, codegen/codegen.go, parser/parser.go, parser/sexp.go, parser/unparser.go); `internal/runtime/runtime.go`; `internal/runtime/vm/vm.go` = **19 file**, gom thành 8 item [m01, m02, m04, m05, m06, m12, m13, m14] — khớp deps_out JSON gm-02 (File: reports/mtail/gm-02-module-map.md \| Dòng: 550) và C = D + out = 1 + 8 = **9** ✓ (định nghĩa C theo hiệu chỉnh raw §3, File: reports/mtail/gm-08-oracles-raw.md \| Dòng: 496) |
| Test closure kéo thêm `testutil` | metrics tests import `internal/testutil` ×2 (metric_test.go, store_test.go/store_bench_test.go); datum tests import `internal/testutil` ×1 — grep thật trên 6 file *_test.go |
| Test closure kéo tiếp `logline` (2-hop) | File: internal/testutil/lines.go \| Dòng: 10 \| Nội dung: `"github.com/google/mtail/internal/logline"`; `logline.go:6` chỉ import `context` (stdlib) → logline tự chứa, D=0 (khớp raw:519, m18) |
| Không testdata, không file non-.go trong 4 package | `find internal/metrics -type d -name testdata` = 0; `find internal/{metrics,testutil,logline} -type f ! -name '*.go'` = 0 (metrics tests tự thân, không fixture ngoài) |
| Không có `vendor/` upstream | `ls -d vendor` → No such file (go mod dùng proxy + go.sum) |

## 2. FILE COPY NGUYÊN CỤC (toàn bộ test liên quan + config tối thiểu)

Cấu trúc cây đích sau cắt (giữ nguyên module path `github.com/google/mtail` để mọi import nội bộ
giải quyết — cấm đổi):

```
<extraction-root>/
├── go.mod            # MỚI, tối thiểu — khối đúng như mục 4 (3 require; KHÔNG phải file upstream)
├── go.sum            # copy NGUYÊN CỤC (35470 byte — cksum đối chiếu mục 4)
├── LICENSE           # copy NGUYÊN CỤC (Apache-2.0; `head -3` = "Apache License / Version 2.0, January 2004")
└── internal/
    ├── logline/
    │   └── logline.go            # 1 file / 19 LOC (m18 — phục vụ testutil/lines.go:10)
    ├── metrics/                  # ★ ITEM — package metrics, 7 file / 1326 LOC (m07)
    │   ├── metric.go             # (309) type Metric :84, NewMetric :100 — largest
    │   ├── metric_test.go        # (274)
    │   ├── store.go              # (219) type Store :19, NewStore :26 — entry
    │   ├── store_bench_test.go   # (216)
    │   ├── store_test.go         # (191)
    │   ├── testing.go            # (73) MetricSlice + Less — file non-test của census, KHÔNG cắt
    │   ├── type.go               # (44) enum Type :12
    │   └── datum/                # package datum, 8 file / 667 LOC (m09 — dep duy nhất)
    │       ├── datum.go          # (259) interface Datum :15, BaseDatum :30
    │       ├── buckets.go        # (117)
    │       ├── datum_test.go     # (60)
    │       ├── int.go            # (54)
    │       ├── string.go         # (47)
    │       ├── buckets_test.go   # (47)
    │       ├── float.go          # (43)
    │       └── int_test.go       # (40)
    └── testutil/                 # 15 file / 504 LOC (m10 — closure test; diff.go dùng go-cmp)
```

- **LOC census đo tươi trên cây PIN (công thức v9: per-file `wc -l` rồi tổng bằng
  `find -print0 | xargs -0 cat | wc -l`):**
  - m07 `internal/metrics` (maxdepth 1): 7 file, tổng **1326** = non-test **645** (309+219+73+44)
    + test **681** (274+216+191) — khớp tuyệt đối oracle (raw:508: 1326/681/645; census ✓ 7/1326).
  - m09 `internal/metrics/datum`: 8 file, tổng **667** = 520 + 147 — khớp raw:510 (census ✓ 8/667).
  - m10 `internal/testutil`: 15 file / **504**; m18 `internal/logline`: 1 file / **19** — khớp
    raw:511, 519 và đo độc lập của slot A (File: reports/mtail/gm-09a-plan.md | Dòng: 48).
  - testratio S3: 681/1326 = 0.51357 ≈ **0.5136** ✓ oracle.
- Tổng cây đích: **31 file .go / 2516 LOC Go** (1326+667+504+19) + 3 file config (go.mod, go.sum,
  LICENSE) = 34 file. dry-run mục 4 đếm đúng 31/2516.
- `pub_funcs` đo tươi bằng LỆNH WORKER NGUYÊN BẢN (File: reports/mtail/gm-08-oracles-raw.md |
  Dòng: 42): `find internal/metrics -maxdepth 1 -name '*.go' ! -name '*_test.go' -print0 |
  xargs -0 -r grep -LZ 'Code generated by' | xargs -0 -r grep -hE '^func (\([^)]*\) )?[A-Z]' |
  wc -l` → **28** ✓ khớp oracle (raw:508); danh sách 28 hàm gồm API chính: `NewStore`,
  `Store.Add/FindMetricOrNil/Gc/Range/StartGcLoop/MarshalJSON/WriteMetrics/ClearMetrics`,
  `NewMetric`, `Metric.GetDatum/AppendLabelValue/RemoveDatum/ExpireDatum/…`, `MetricSlice`
  sorter, `Kind/Type.String/Generate`.
- 3 file test của m07 (metric_test, store_test, store_bench_test) là oracle hồi quy S3 (681 LOC,
  ratio 0.5136 đóng băng trong gm-08) — copy nguyên cục cùng 4 test của datum + 1 của testutil
  vì closure test import chỉ các package đã có trong cây (mục 1).
- Per-file Apache header giữ nguyên mọi file (store.go:1-2: "Copyright 2011 Google Inc. All
  Rights Reserved. / This file is available under the Apache license.") — header trỏ về LICENSE
  nên LICENSE phải đi cùng cây.

## 3. PRUNE — GIỮ / VENDOR / CẮT (mỗi quyết định 1 dòng lý do)

| Đối tượng | Quyết định | Lý do |
|---|---|---|
| `go.mod` | **MỚI tối thiểu** (khối mục 4) | giữ module path + `go 1.21.1`; chỉ 3 require mà closure thật sự dùng — 9 direct + 14 indirect còn lại của upstream không có import nào trong 4 package (dry-run #2 chứng minh) |
| `go.sum` | GIỮ nguyên cục | prune tay rủi ro mất hash là fatal, thừa entry bị toolchain bỏ qua; cksum đối chiếu PIN = khớp (mục 4) |
| `LICENSE` | GIỮ | Apache-2.0 — per-file header (store.go:1-2) trỏ về file này |
| `internal/metrics/*.go` 7 file | GIỮ nguyên cục | Item trích là chính nó — copy-then-prune cấm tách lẻ từng file trong item |
| `internal/metrics/datum/*.go` 8 file | GIỮ | Dep nội bộ duy nhất của metrics (metric.go:18); D=0 tự chứa |
| `internal/metrics/testing.go` | GIỮ (không cắt dù tên "testing") | file non-test của census m07 (73/645 LOC — cắt là sai census 645 ngay; raw:508) — chứa MetricSlice/Less thuộc package metrics |
| `internal/testutil/*.go` 15 file | GIỮ | 3 ref test closure (mục 1); 15/504 khớp census m10 (raw:511) |
| `internal/logline/logline.go` | GIỮ | testutil/lines.go:10 — 2-hop edge của closure test; 1/19 khớp m18 (raw:519) |
| `cmd/` (mtail, mdot, mfmt, mgen) | CẮT | chiều deps_in ngược — 4 cmd tiêu thụ metrics, metrics không import cmd nào (fan-in list mục 1 một chiều) |
| `internal/runtime/` (compiler, vm, runtime, code) | CẮT | các item tiêu thụ (m01/m04/m05/m14 trong fan-in) — không thuộc slot B; compiler là phạm vi slot A (gm-09a §3) |
| `internal/mtail/`, `internal/exporter/`, `internal/tailer/`, `internal/waker/` | CẮT | item tiêu thụ còn lại (m02/m13, m06, m08/m03, m11) — chiều ngược |
| `docs/ examples/ Makefile Dockerfile* .github/ hooks/ logo.png mtail-mode.el mtail.service log_rewriter.awk subject_summarizer.mtail benchmark_results.csv TODO README*` | CẮT | không tham gia build/test Go của closure; `grep -rl 'github.com/google/mtail'` trên cây cắt trả đúng 6 file .go (mục 4) — không tham chiếu nào ra ngoài 4 package |
| go.mod requires CẮT: jaeger, groupcache, prometheus/client_golang + common, opencensus, x/sys + toàn bộ `// indirect` | CẮT | 0 import trong closure (mục 1); dry-run #2 với go.mod tối thiểu tải ĐÚNG 3 module ngoài rồi build/test xanh |
| VENDOR | N/A | upstream không có `vendor/`; 3 module giữ đều dep-free trên proxy.golang.org tại pin đúng (glog v1.2.2, go-cmp v0.6.0, pkg/errors v0.9.1 — go.mod:7,9,10) |

⚠️ **Trùng lặp có chủ đích, kê khai rõ:** toàn bộ phần support (metrics, datum, testutil,
logline) cũng nằm trong cây cắt của slot A (gm-09a §2-3 khai D=3 = metrics+datum+code kèm
testutil/logline) — cây slot B trọn vẹn là tập con cây slot A trừ compiler. Hai cây cắt **độc
lập, tự chứa đủ**, không xung đột phạm vi: module CHÍNH mỗi slot không chồng (slot A = compiler
m01; slot B = metrics m07); trùng lặp support là hệ quả bắt buộc của copy-verbatim — cùng tiền
lệ codesearch (sparse/set.go nằm trong cả 2 cây, File: reports/codesearch/gm-09b-plan.md |
Dòng: 82-85).

## 4. LỆNH BUILD+TEST ĐỘC LẬP DỰ KIẾN + DRY-RUN (output THẬT, không SKIPPED)

```bash
cd <extraction-root>          # cây 4 package như mục 2
go version                    # phải >= go1.21.1 (go.mod:3)
go build ./...                # expected: sạch, exit 0 — 4 package
go test ./...                 # expected: metrics + datum + testutil ok; logline [no test files]
```

- **DRY-RUN: ĐÃ CHẠY, output thật** (slot A SKIPPED vì sandbox không Go — kê khai trung thực ở
  gm-09a §5; sandbox node này tự cài Go được nên chạy thay bằng bằng chứng thật):
  - Toolchain: `go version go1.22.12 linux/amd64` (cùng phiên bản tiền lệ b-overview mtail).
  - **Lần 1 — go.mod upstream NGUYÊN CỤC + go.sum + LICENSE + 3 package dir** (`/tmp/cut-try`):
    ```
    == go files + LOC ==        31 / 2516          (= 1326+667+504+19, khớp mục 2)
    $ go build ./...            → BUILD_EXIT=0
    $ go test ./...
    ?   	github.com/google/mtail/internal/logline	[no test files]
    ok  	github.com/google/mtail/internal/metrics	0.107s
    ok  	github.com/google/mtail/internal/metrics/datum	0.051s
    ok  	github.com/google/mtail/internal/testutil	0.079s
    TEST_EXIT=0
    go: downloading github.com/golang/glog v1.2.2
    go: downloading github.com/pkg/errors v0.9.1
    go: downloading github.com/google/go-cmp v0.6.0     ← chỉ 3 module ngoài, đúng dự đoán
    ```
  - **Lần 2 — đúng inventory mục 2: go.mod MỚI tối thiểu (khối dưới) + go.sum verbatim**
    (`/tmp/cut-try2`, mô phỏng cấu hình slot A §4.2):
    ```
    module github.com/google/mtail

    go 1.21.1

    require (
    	github.com/golang/glog v1.2.2
    	github.com/google/go-cmp v0.6.0
    	github.com/pkg/errors v0.9.1
    )
    ```
    ```
    $ go build ./...            → BUILD_EXIT=0
    $ go test ./...
    ?   	github.com/google/mtail/internal/logline	[no test files]
    ok  	github.com/google/mtail/internal/metrics	0.164s
    ok  	github.com/google/mtail/internal/metrics/datum	0.024s
    ok  	github.com/google/mtail/internal/testutil	0.085s
    TEST_EXIT=0
    $ grep -rl 'github.com/google/mtail' --include='*.go' . | wc -l   → 6
    $ cksum go.sum /workspace/go.sum  → 2236214093 35470 (khớp cả hai)   ← go.sum verbatim
    ```
  - Cả 2 cấu hình đều xanh → node cắt thật có thể chọn go.mod tối thiểu (khuyến nghị, đồng bộ
    slot A) hoặc go.mod nguyên cục (cũng chạy được, dry-run lần 1 chứng minh).
  - Lệnh mục 4 trên là để node cắt thật chạy lại ngoài run trên cây cắt chính thức.
  - Ghi chú sandbox: container `bitnami/git` không có `diff` — kiểm go.sum dùng `cksum` (hoặc
    `diff` trên máy executor); không ảnh hưởng plan.

## 5. RỦI RO CẮT TỈA + CÁCH KIỂM SAU CẮT

| # | Rủi ro | Cách kiểm sau cắt |
|---|---|---|
| R1 | Quên `internal/metrics/datum` → build vỡ tại import metric.go:18 | `go build ./...` sạch; đếm cây đích đúng **31 file .go** (7 metrics + 8 datum + 15 testutil + 1 logline) + 3 file config |
| R2 | Quên closure test `testutil`→`logline` (2-hop, số D=1 không lộ) → `go test` vỡ compile | `go test ./...` phải xanh cả 3 package test; `internal/testutil/lines.go` tồn tại trong cây |
| R3 | Đổi module path go.mod cho gọn → 6 file ref vỡ, cám dỗ sửa source | `head -1 go.mod` = `module github.com/google/mtail`; `grep -rl 'github.com/google/mtail' --include='*.go' .` = **6** |
| R4 | Prune tay `go.sum` → thiếu hash cho glog/go-cmp/pkg/errors là fatal | `cksum go.sum` = 2236214093 35470 (hoặc `diff go.sum <PIN-clone>/go.sum` = 0) |
| R5 | Toolchain < 1.21.1 → lỗi cú pháp/stdlib không liên quan extraction | `go version` in ra ≥ go1.21.1 TRƯỚC khi build; kê khai phiên bản trong report cắt |
| R6 | Cắt nhầm `internal/metrics/testing.go` (tưởng là file test vì tên) → sai census 645 | `ls internal/metrics/*.go \| wc -l` = 7; tổng non-test `cat|wc` = 645 (309+219+73+44); copy nguyên cục cấm bỏ file trong item |
| R7 | Drift PIN khi cửa ải (upstream main tiến) | lần cắt thật clone single-branch `main` rồi `git checkout $PIN`, đỗ khi `git rev-parse HEAD` == `4c7e0e1174ac1ead032efe28d86428bbbe0ae145`; sai thì dừng, không cắt trên cây lệch |
| R8 | Byte-identity drift trong lúc copy | `diff -r <extraction-root>/internal <PIN-clone>/internal` (giới hạn 4 package dir) = 0 khác biệt; LOC 2516 tái lập |

## 6. Kê khai nguồn & kiểm cross-node

- Input: `reports/mtail/gm-08-stars.md` (18/18 item, joinPolicy all) — tập ≥4★ = {s01, s07}
  (Dòng: 25, 31 bảng; Dòng: 87 phân bố); item **thứ hai** = s07 metrics → slot B. Oracles row
  m07: gm-08-oracles-raw.md Dòng: 508; fact module m07: gm-02-module-map.md Dòng: 29/223-249
  (path internal/metrics, biên 7 file trực tiếp, store.go entry, metric.go largest).
- Lệnh đo nguyên bản được tái lập: pub_funcs (raw:42) → 28 ✓; census v9 → 1326/681/645,
  667/147/520, 504, 19 ✓ toàn bộ khớp oracle ±0; E1 4 dòng glog/pkg/errors khớp part w1 Dòng: 52.
- **Slot A đối chiếu (gm-09a xuất hiện GIỮA phiên — brief Dòng 4 "đọc thêm report trước nếu có"):**
  cùng PIN, cùng số census metrics/datum/testutil/logline đo độc lập (gm-09a Dòng: 48) — 0 lệch;
  cùng cấu hình go.mod tối thiểu 3 require (gm-09a §4.2 = mục 4 của plan này); khác duy nhất về
  khả năng sandbox: slot A dry-run SKIPPED (không Go), node này chạy thật 2 lần — không phải mâu
  thuẫn số liệu. Ranh giới: plan này KHÔNG lập kế hoạch cắt compiler (việc slot A).
- Lần chạy: **1** — glob `reports/mtail/*` đầu phiên không có `gm-09b*` → không INHERIT.
- Môi trường đo: sandbox riêng `bitnami/git:latest` ttl 7200, session `sess-9c3bfead`, dựa VFS
  workspace `sess-6490118a` chứa clone (sandbox đầu tạo trước khi clone nên container rỗng —
  tạo lại đúng chuẩn workflow `sandbox_create(project_path=<VFS workspace id>)`, không clone lại);
  clone do tool `sandbox_git_clone` thực hiện (trả `headCommit`/`filesIngested 258`/`branch main`);
  mọi lệnh đo/build/test qua `sandbox_shell`; không ghi file repo qua shell redirection (go.mod
  dry-run ghi qua `sandbox_vfs_write` rồi `cp` trong container, scratch đã xóa). KHÔNG dọn sandbox
  cuối phiên (brief Dòng 2). Không commit, không push, không tạo repo — PLAN-ONLY (brief Dòng 7).
