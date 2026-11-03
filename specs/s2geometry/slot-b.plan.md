# gm-09b — EXTRACTION PLAN — SLOT B (google/s2geometry @ PIN `677c8ceb`) — **VERDICT: N/A**

> **GHI RÕ BẮT BUỘC (brief `ex_b--110dacaf.md` Dòng 7): đây chỉ là PLAN.** Cắt thật là lệnh
> riêng ngoài run. Trong trường hợp này verdict là **N/A** (không đủ item ≥4★ cho slot B)
> → **KHÔNG có gì để cắt, KHÔNG lập kế hoạch copy-then-prune, KHÔNG tự tạo repo, KHÔNG push.**
> Toàn bộ node này là node quyết định N/A có bằng chứng (đóng băng + đo tươi tại PIN),
> không phải node thiết kế cắt.

## Verdict

**N/A** — tập item ≥4★ của subject s2geometry **RỖNG (0 phần tử)**: slot A lấy phần tử
**ĐỨNG THỨ NHẤT**, slot B phải lấy phần tử **ĐỨNG THỨ HAI** — phần tử thứ hai không tồn tại,
vì chính phần tử thứ nhất cũng không tồn tại (universe 61 item có mức sao cao nhất là 3★).
Theo đúng điều kiện brief: "Lấy item ≥4 sao ĐỨNG THỨ HAI (slot A lấy thứ nhất). Quy trình
GIỐNG slot A. **Không đủ item → 'N/A' + DONE**" (File: briefs/ex_b--110dacaf.md | Dòng: 5-6).

## 1. Cơ sở N/A — bằng chứng từ chuỗi artifact đóng băng (gm-08)

| # | Luận điểm | Evidence |
|---|---|---|
| 1.1 | Universe subject = 61 item (s01..s61) | File: reports/s2geometry/sr-checklist.json \| Dòng: 2-62 \| Nội dung: 61 entry `{"id":"s01"…"s61"}` — không có s62 |
| 1.2 | Merge sao phủ 61/61, joinPolicy all, đủ 5/5 input, fail-closed kiểm tra đầu phiên PASS | File: reports/s2geometry/gm-08-stars.md \| Dòng: 5, 12-13 \| Nội dung: "joinPolicy **all**, fail-closed kiểm tra đầu phiên: **ĐỦ 5/5 input** … **61/61 item DONE**" |
| 1.3 | Phân bố sao toàn universe: ★5 = 0, ★4 = 0, ★3 = 2, ★2 = 15, ★1 = 44 | File: reports/s2geometry/gm-08-stars.md \| Dòng: 8, 21-25 \| Nội dung: "61/61 item DONE · 5★: 0 · 4★: 0 · 3★: 2 · 2★: 15 · 1★: 44"; bảng §1: "3★ \| 2 \| s15 s2latlng · s22 gmock" |
| 1.4 | Phát biểu tường minh của merge: không item nào đạt 4★/5★ | File: reports/s2geometry/gm-08-stars.md \| Dòng: 27 \| Nội dung: "Không item nào đạt 4★/5★: cặp S1∩S2 đạt ngưỡng 5★ duy nhất của universe là s30 (deps 2 ∧ fan 21) nhưng bị S5 chặn (loc 899 < 1000); mọi item deps ≤ 2 còn lại có fan ≤ 9 < 12" |
| 1.5 | JSON block máy-đọc 61 row: không row nào stars ≥ 4 | File: reports/s2geometry/gm-08-stars.md \| Dòng: 101-164 \| Nội dung: 61 row `"stars":1…3` — grep `"stars":4` / `"stars":5` = **0 match**; max là `"stars":3` (s15 @ Dòng 117, s22 @ Dòng 124) |
| 1.6 | Sao suy từ min-aggregation `star = min(S1..S5)`, merge đã tái tính độc lập 61/61 | File: reports/s2geometry/gm-08-stars.md \| Dòng: 14-15 \| Nội dung: "tái tính min-aggregation độc lập trên 61/61 item cho cùng kết quả (kể cả các ca biên: s30 bị S5 chặn vì loc 899 < 1000 …; s36 bị S3 chặn vì ratio 0.098 < 0.10; s32 bị S5 chặn vì PLM 1 < 2)" |
| 1.7 | Trần 5★ ≤ 3 item/repo không kích hoạt (0 ≤ 3) → không tie-break/demote làm mất thêm phần tử | File: reports/s2geometry/gm-08-stars.md \| Dòng: 16, 171 \| Nội dung: "0 item 5★ → mệnh đề '>3 item 5 sao → CẢNH BÁO rubric lỏng' **KHÔNG kích hoạt**, giữ nguyên số, không tie-break, không demote-by-cap" |
| 1.8 | Hệ quả: \|tập ≥4★\| = 0 < 2 → phần tử thứ #2 không tồn tại | Hệ quả logic của 1.1–1.7 \| Slot B rơi nhánh N/A của brief Dòng 6 |

**Kê khai chuỗi (brief Dòng 4):** glob `reports/s2geometry/` đầu phiên **chưa có**
`reports/s2geometry/gm-09a-plan.md` (slot A chưa xuất hiện) và **không có** `gm-09b*` → lần chạy 1,
không INHERITED (mục 6). Verdict N/A **độc lập** với nội dung slot A: tập ≥4★ rỗng thì slot A cũng
không có phần tử nào để nhận — không phát sinh xung đột phạm vi, plan này KHÔNG lập kế hoạch cắt
cho item nào.

## 2. Sàng cấu trúc cơ học trên 61 oracle row — tập ≥4★ = ∅ (PLM-free upper bound)

Ngưỡng áp dụng (File: reports/gm-07-rubric.md | Dòng: 93-97, kế thừa bởi part-w1 Dòng 15-21):
**4★ = deps_in ≤ 4 ∧ (in+out) ≥ 8 ∧ RATIO ≥ 0.25 ∧ N_E ≥ 1 ∧ loc ≥ 5000 ∧ PLM ≥ 50**;
**5★ = deps_in ≤ 2 ∧ (in+out) ≥ 12 ∧ RATIO ≥ 0.40 ∧ N_E ≥ 2 ∧ loc ≥ 20000 ∧ PLM ≥ 200**;
`star = min(S1..S5)`. Sàng dưới đây lọc trên 4 signal cấu trúc đọc thẳng
`gm-08-oracles.json` (s1_deps/s2_fan/s3_testratio/s5_loc), **không dùng PLM** → là **chặn trên**
của star: nếu chặn trên đã rỗng thì thêm PLM ≥ 50 (chỉ chặt hơn) chắc chắn vẫn rỗng. Lọc máy
(awk, sandbox `sess-689ede6a`, raw §5): 61/61 row, **PASS-4★ = 0, PASS-5★ = 0**.

| Bước sàng | Điều kiện | Số item sống | Item |
|---|---|---|---|
| 1 | deps ≤ 4 (S1 đủ 4★) | 26 | s22 s23 s30 s36 s37 s38 s39 s41 s42 s43 s45 s46 s47 s48 s49 s50 s52 s53 s54 s55 s56 s57 s58 s59 s60 s61 |
| 2 | ∧ fan ≥ 8 (S2 đủ 4★) | 3 | s30 s1chord (deps 2, fan 21) · s41 s2padded (3, 8) · s61 s2coder (1, 9) |
| 3 | ∧ ratio ≥ 0.25 ∧ loc ≥ 5000 (S3+S5 đủ 4★) | **0** | s30: ratio 0.310 ✓ nhưng **loc 899**; s41: ratio 0.359 ✓ nhưng **loc 435**; s61: **ratio 0.0 ∧ loc 56** |
| 4★-filter đầy đủ | ∧ PLM ≥ 50 ∧ N_E ≥ 1 | 0 | — (đã rỗng từ bước 3; PLM/N_E chỉ chặt hơn) |
| 5★-filter | deps ≤ 2 ∧ fan ≥ 12 ∧ ratio ≥ 0.40 ∧ loc ≥ 20000 (PLM-free) | 0 | duy nhất s30 vượt S1∩S2 (2, 21) nhưng loc 899 ∧ PLM 10 → khớp phát biểu merge Dòng 27 |

→ **Tập ≥4★ = ∅ tất định trên dữ liệu oracle; phần tử thứ nhất lẫn thứ hai đều không tồn tại.**
Mỗi số trong bảng truy được về JSON: s30 @ Dòng 31, s41 @ Dòng 42, s61 @ Dòng 62 của
`gm-08-oracles.json` (mỗi item nằm ở Dòng = chỉ số + 1).

## 3. Cross-check đo tươi tại PIN — chống nghi vấn "merge/oracle đánh thấp item nào đó"

Nghi vấn cần bác: *"oracle chấm sai làm che mất một item ≥4★ (thứ nhất hoặc thứ hai)"*. Bác bằng
đo tươi trên đúng cây PIN trong sandbox riêng (`bitnami/git:latest`, mọi lệnh git/code qua
`sandbox_shell`): `git clone --depth 100 --single-branch https://github.com/google/s2geometry` →
`git rev-parse HEAD` = **`677c8cebcff11ba11accc0b02005bc214e06e9fd`** == PIN chuỗi
(File: reports/s2geometry/gm-08-stars.md | Dòng: 4), branch `master` — mọi số dưới đây gắn cây PIN.

### 3.1 Census cấu trúc: phân hoạch 61 item ĐỦ và KHÔNG TRÙNG trên cây PIN

- src/s2 phẳng: **222 file .cc + 142 file .h = 130,700 LOC** (census v9 từng extension rồi cộng:
  cc 91,543 + h 39,157); 60 họ tiền tố khớp tên module của sr-checklist + `_fp_contract_off.*`
  → s2-core (55 file, đúng luật oracles-raw Dòng 34).
- src/python: cc 2,393 + h 74 + i 1,232 + py 5,426 = **9,125 LOC == oracle m02 chính xác từng
  extension** (File: reports/s2geometry/gm-08-oracles-raw.md | Dòng: 27 kê khai đúng bộ số này).
- **Tổng kiểm: Σ s5_loc của 61 item = 139,825 (awk cộng máy trên 61 row §5) = 130,700 + 9,125
  = tổng census đo tươi** → không còn file .cc/.h/.i/.py nào nằm ngoài 61 item, không item nào
  đếm trùng → **không thể có item "bị merge sót"** ngoài 61 item đã chấm.

### 3.2 Đo tươi 8 item quyết định — khớp oracle tuyệt đối (17/17 số)

8 item = 3 item sống sót bước sàng 2 (s30, s41, s61) + 5 item cận biên nhất các ngưỡng
(s15 deps, s22/s23/s43/s59 fan). Bảng so sánh (đo tươi @ PIN vs oracle JSON):

| item | A đo tươi | loc oracle | T đo | ratio đo | ratio oracle | deps đo tươi (owner set) | deps oracle | out đo tươi | out JSON |
|---|---|---|---|---|---|---|---|---|---|
| s15 s2latlng | 3432 | 3432 ✅ | 1791 | 0.522 | 0.522 ✅ | 5 {s1chord, s2-core, s2coder, s2edge, s2text} | 5 ✅ | 17 | 17 ✅ |
| s22 gmock | 2006 | 2006 ✅ | 572 | 0.285 | 0.285 ✅ | 3 {s2-core, s2latlng, s2text} | 3 ✅ | 4 {s2loop, s2polygon, s2polyline, s2region} | 4 ✅ |
| s23 s2predicates | 1977 | 1977 ✅ | 1799 | 0.910 | 0.91 ✅ | 3 {s1chord, s2-core, s2edge} | 3 ✅ | 4 {s2-core, s2buffer, s2convex, s2edge} | 4 ✅ |
| s30 s1chord | 899 | 899 ✅ | 279 | 0.310 | 0.31 ✅ | 2 {s2-core, s2edge} | 2 ✅ | 19 {18 src/s2 + s2-python} | 19 ✅ |
| s41 s2padded | 435 | 435 ✅ | 156 | 0.359 | 0.359 ✅ | 3 {s2-core, s2cell, s2coords} | 3 ✅ | 5 {mutable, s2-core, s2crossing, s2polygon, s2shapeutil} | 5 ✅ |
| s43 id | 368 | 368 ✅ | 77 | 0.209 | 0.209 ✅ | 2 {s2-core, sequence} | 2 ✅ | 5 {s2-core, s2boolean, s2builder, s2builderutil, s2winding} | 5 ✅ |
| s59 s2wrapped | 87 | 87 ✅ | 33 | 0.379 | 0.379 ✅ | 4 {s2-core, s2lax, s2shapeutil, s2text} | 4 ✅ | 3 {s2density, s2shape, s2shapeutil} | 4 (spurious s2-core — A.1) |
| s61 s2coder | 56 | 56 ✅ | 0 | 0.0 | 0.0 ✅ | 1 {s2-core} | 1 ✅ | 8 | 8 ✅ |

Owner classification dùng đúng luật oracles-raw Dòng 17-22 (ngoài `s2/` → EXTERNAL;
`s2/{util,base,internal,testing}/` → NOASSIGN; basename không `_` hoặc `_fp_contract_off` → s2-core;
còn lại → prefix trước `_` đầu tiên; self bị loại; chỉ owner thuộc 61-item universe được tính).

### 3.3 Caveat đo của node này (trung thực — 2 lỗi glob tự sửa, không phải lỗi oracle)

1. Lần đo T đầu dùng glob `fam_*_test.cc` → hụt 2 file test không có segment giữa fam và `_test`
   (`s2latlng_test.cc`, `s2predicates_test.cc`) → đo lại bằng `fam*_test.cc`: T(s15) = **1791** →
   ratio 1791/3432 = **0.522** ✓, T(s23) = **1799** → 1799/1977 = **0.910** ✓ — khớp oracle tuyệt
   đối, nghi ngờ về S3 được gỡ bỏ hoàn toàn.
2. Lần quét inverse ban đầu sinh 2 owner giả: "s2" = `src/python/s2_common.i` (file PYTHON — đúng
   ra là owner s2-python, khớp việc JSON m30.deps_out kê s2-python) và "s2index" =
   `src/s2/internal/s2index_cell_data.cc` (nằm SUBDIR `internal/` — ngoài universe phẳng src/s2,
   bị loại đúng luật). Sau hiệu chỉnh: 6/6 fan-component khớp oracle (mục 3.2).

### 3.4 Ghi nhận lệch protocol nhỏ của oracle (không đổi verdict, hướng bảo thủ)

`s59 s2_fan = 7 = s1 đo (4) + out ĐO (3)`, trong khi protocol kê khai
(File: reports/s2geometry/gm-08-oracles-raw.md | Dòng: 25) là `s1 đo + |deps_out| JSON` (= 4 —
cạnh `s2-core` spurious theo Phụ lục A.1 Dòng 3086). Nếu dùng JSON: fan = 8 → S2 4★, nhưng star
s59 vẫn 1★ vì S5 = 1★ (loc 87 < 200 ∧ PLM 0) — **verdict N/A không đổi**. Ghi nhận để controller
quyết định, không tự sửa artifact worker/merge.

## 4. Tính đơn điệu của verdict N/A (chống mọi lần chấm lại)

- **3 item vượt sàng đồ thị (deps ≤ 4 ∧ fan ≥ 8) đều trượt S5 ≥ 5.6 lần:** s30 loc 899 vs 5000
  (kèm PLM 10 vs 50), s41 loc 435, s61 loc 56 (kèm ratio 0.0 < 0.25). `loc` là census
  `find -print0 | xargs -0 cat | wc -l` deterministic — không lần đo lại nào dịch chuyển số này
  5.6 lần; **không thể sinh item 4★ từ 3 ứng viên này**.
- **4 item fan cận biên (7 vs ngưỡng 8):** s22 (loc 2006 — vẫn trượt S5 2.5 lần dù PLM 66 ✓),
  s23 (PLM 0), s43 (ratio 0.209 < 0.25 ∧ loc 368 ∧ PLM 3), s59 (loc 87 ∧ PLM 0). Kể cả cả 4 fan
  cùng flip lên ≥ 8 (trái chứng cứ đo tươi mục 3.2) thì **không item nào mới đạt 4★**.
- **S1 cận biên duy nhất: s15 deps 5 vs ≤ 4** (đúng 1). Giả sử flip: s15 vẫn cần loc ≥ 5000
  (đo 3432 — cách 1.45×) ∧ PLM ≥ 50 (đúng ngưỡng 50). Ngay cả khi s15 thành 4★: tập ≥4★ =
  {s15} kích thước **1** → phần tử đó thuộc slot A (thứ nhất); **phần tử thứ hai cho slot B
  VẪN không tồn tại** → N/A của slot B bền đơn điệu.
- Kết luận: |≥4★| ≤ 1 dưới mọi lần chấm lại thực tế < 2 → **N/A là verdict cuối cùng của slot B**.

## 5. Raw output verbatim (sandbox_shell, sandbox `sess-689ede6a`, clone @ PIN `677c8ceb…`)

Batch PIN + census + cấu trúc họ:
```
$ cd /workspace && git clone --depth 100 --single-branch https://github.com/google/s2geometry s2geometry
Cloning into 's2geometry'...
$ git -C s2geometry rev-parse HEAD
677c8cebcff11ba11accc0b02005bc214e06e9fd
$ git -C s2geometry branch --show-current
master
== src/s2 .cc/.h counts ==
222
142
== src/s2 census v9 per-ext (cc, h) ==
91543
39157
== src/python census v9 per-ext (cc, h, i, py) ==
2393
74
1232
5426
== prefix families in src/s2 (count files per prefix) ==   # rút gọn: 60 họ khớp checklist
      3 gmock      3 id      7 s2latlng      2 s2predicates      3 s1chord
      3 s2padded   2 s2wrapped   1 s2coder   54 s2-core(no_)   1 (empty = _fp_contract_off)  …
== TOTAL ==
rows=61 SUM(s5_loc)=139825
fresh census: src/s2 = 130700, src/python = 9125, grand = 139825
```

Batch đo tươi từng item (file set · A · T · owner-distinct includes):
```
=== s2latlng ===  s2latlng_rect.cc s2latlng_rect.h s2latlng_rect_bounder.cc s2latlng_rect_bounder.h
  s2latlng_rect_bounder_test.cc s2latlng_rect_test.cc s2latlng_test.cc   A=3432 T=1791(đo lại)
  owners: s1chord s2-core s2coder s2edge s2text
=== gmock ===  gmock_matchers.cc gmock_matchers.h gmock_matchers_test.cc   A=2006 T=572
  owners: s2-core s2latlng s2text
=== s2predicates ===  s2predicates_internal.h s2predicates_test.cc   A=1977 T=1799(đo lại)
  owners: s1chord s2-core s2edge
=== s1chord ===  s1chord_angle.cc s1chord_angle.h s1chord_angle_test.cc   A=899 T=279
  owners: s2-core s2edge
=== s2padded ===  s2padded_cell.cc s2padded_cell.h s2padded_cell_test.cc   A=435 T=156
  owners: s2-core s2cell s2coords
=== id ===  id_set_lexicon.cc id_set_lexicon.h id_set_lexicon_test.cc   A=368 T=77
  owners: s2-core sequence
=== s2wrapped ===  s2wrapped_shape.h s2wrapped_shape_test.cc   A=87 T=33
  owners: s2-core s2lax s2shapeutil s2text
=== s2coder ===  s2coder_testing.h   A=56 T=0   owners: s2-core
```

Batch inverse out (owners của các file include header target; sau hiệu chỉnh python/subdir):
```
s2/gmock_matchers.h      <- gmock(self) s2loop s2polygon s2polyline s2region          → out = 4
s2/id_set_lexicon.h      <- id(self) s2-core s2boolean s2builder s2builderutil s2winding → out = 5
s2/s2wrapped_shape.h     <- s2wrapped(self) s2density s2shape s2shapeutil             → out = 3
s2/s2predicates_internal.h <- s2predicates(self) s2-core s2buffer s2convex s2edge    → out = 4
s2/s1chord_angle.h       <- s1chord(self) + s2-python(s2cap_bindings.cc, s2_common.i,
                            s2cell_bindings.cc, s1chord_angle_bindings.cc) + s2-core s2buffer
                            s2builder s2cap s2cell s2closest s2earth s2edge s2furthest
                            s2hausdorff s2latlng s2max s2min s2polygon s2polyline
                            s2predicates s2region s2shape                            → out = 19
s2/s2padded_cell.h       <- s2padded(self) mutable s2-core s2crossing s2polygon
                            s2shapeutil  (match "s2index" = src/s2/internal/… ngoài universe) → out = 5
```

Batch sàng cơ học (61 row từ gm-08-oracles.json, lọc PLM-free):
```
4STAR-candidate (fails later gate): s1chord deps=2 fan=21 ratio=0.31 loc=899
4STAR-candidate (fails later gate): s2padded deps=3 fan=8 ratio=0.359 loc=435
4STAR-candidate (fails later gate): s2coder deps=1 fan=9 ratio=0.0 loc=56
rows processed = 61        # PASS4STAR: 0 dòng; PASS5STAR: 0 dòng
rows=61 SUM(s5_loc)=139825
```

## 6. Kế thừa LẦN CHẮY 2+ (brief Dòng 3)

Kiểm tra lúc bắt đầu node: glob `reports/s2geometry/` — **KHÔNG tồn tại** `gm-09a-plan.md` lẫn
`gm-09b-plan.md` (các gm-09a/b cũ chỉ có ở codesearch/jimfs/mtail/pprof) → **lần chạy 1, không
INHERITED**, file này là lần sinh đầu.

Hướng dẫn lần chạy sau (nếu re-run): verdict N/A chỉ đổi khi tập ≥4★ của s2geometry tăng lên
≥ 2 item — đòi hỏi gm-07/gm-08 chấm lại sao (hiện 3 item vượt sàng đồ thị đều trượt S5 ≥ 5.6×,
mục 4; đo tươi tại PIN khớp oracle 17/17 số, mục 3.2). Khi đó regenerate plan theo khuôn
copy-then-prune của slot A (bảng FILE COPY NGUYÊN CỤC / prune KEEP–VENDOR–CUT / lệnh
`cmake -S . -B build && cmake --build build -j2` — container `bitnami/git` không có cmake thì ghi
SKIPPED trung thực). Cho tới khi đó, file N/A này là kết quả cuối hợp lệ của slot B s2geometry.

## 7. Checklist thẩm định N/A (cho reviewer)

1. **G1 — Universe/census:** sr-checklist 61 item (mục 1.1); merge coverage 61/61 (mục 1.2);
   census tươi Σ = 139,825 khớp tuyệt đối tổng 61 s5_loc trên đúng PIN (mục 3.1) → không có item
   bị merge sót, không item nào ngoài universe.
2. **G2 — Tập ≥4★ = ∅ (kích thước 0):** phân bố sao đóng băng (mục 1.3-1.5) + sàng cơ học
   PLM-free 61 row cho 0 PASS (mục 2) → phần tử thứ #2 không tồn tại → N/A đúng điều kiện brief
   Dòng 6.
3. **G3 — Cross-check đo tươi:** 8 item quyết định khớp oracle 17/17 số (loc/T/ratio/deps/out,
   mục 3.2); 2 lỗi glob của node đã tự phát hiện - tự sửa - kê khai (mục 3.3); 1 lệch protocol
   nhỏ của oracle ghi nhận minh bạch, không đổi verdict (mục 3.4).
4. **G4 — Đơn điệu:** mọi kịch bản chấm lại thực tế cho |≥4★| ≤ 1 < 2 (mục 4) → N/A bền.
5. **G5 — Ranh giới slot:** file này KHÔNG lập kế hoạch cắt cho bất kỳ item nào (việc slot A
   không phát sinh vì tập rỗng), KHÔNG đụng artifact subject khác, KHÔNG sửa gm-08/part/status.
6. **G6 — PLAN-ONLY + REDACTION:** không cắt thật, không tạo repo, không push (brief Dòng 7);
   file không chứa token/secret (`ghp_` = 0).

## 8. Files của node này + kê khai môi trường

- `reports/s2geometry/gm-09b-plan.md` — deliverable (file N/A plan này) — **mới**.
- Không commit git, không push: deliverable là report trong workspace session (tiền lệ slot B
  pprof — File: reports/pprof/gm-09b-plan.md | Dòng: 254-255; slot B jimfs —
  File: reports/jimfs/gm-09b-plan.md | Dòng: 121-123). Sandbox chỉ clone-đọc google/s2geometry.
- Môi trường đo: sandbox riêng `bitnami/git:latest` ttl 7200, session `sess-689ede6a` (throwaway
  `/workspace`); clone nông depth-100 single-branch `master` bằng `sandbox_shell` trong container,
  `git rev-parse HEAD` == PIN `677c8cebcff11ba11accc0b02005bc214e06e9fd` đo trực tiếp. Không dùng
  token trong bất kỳ lệnh nào (URL public HTTPS). **KHÔNG dọn sandbox cuối phiên** (brief Dòng 2 —
  ttl tự hủy).
