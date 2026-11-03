# gm-09a — EXTRACTION PLAN — SLOT A (google/s2geometry @ PIN `677c8ceb`) — **VERDICT: N/A**

> **GHI RÕ BẮT BUỘC (brief `ex_a--110dacaf.md` Dòng 13): đây chỉ là PLAN.** Cắt thật là lệnh
> riêng ngoài run. Trong trường hợp này verdict là **N/A** (không đủ item ≥4★ cho slot A)
> → **KHÔNG có gì để cắt, KHÔNG lập kế hoạch copy-then-prune, KHÔNG tự tạo repo, KHÔNG push.**
> Toàn bộ node này là node quyết định N/A có bằng chứng (đóng băng + đo tươi tại PIN),
> không phải node thiết kế cắt.

## Verdict

**N/A** — tập item ≥4★ của subject s2geometry **RỖNG (0 phần tử)**: slot A phải lấy phần tử
**ĐỨNG THỨ NHẤT** của tập đó — phần tử thứ nhất không tồn tại. Theo đúng điều kiện brief:
"Lấy item ≥4 sao ĐỨNG THỨ NHẤT (slot B lấy thứ hai; **không đủ item đạt → 'N/A' + DONE**)"
(File: briefs/ex_a--110dacaf.md | Dòng: 4-5). Đã đối chiếu chéo: slot B (File:
reports/s2geometry/gm-09b-plan.md | Dòng: 11) cũng kết luận N/A trên cùng dữ liệu — nhất quán
vì tập rỗng thì cả hai slot cùng không có phần tử; không xung đột phạm vi.

## 1. Cơ sở N/A — bằng chứng từ chuỗi artifact đóng băng (gm-08)

| # | Luận điểm | Evidence |
|---|---|---|
| 1.1 | Universe subject = 61 item (s01..s61) | File: reports/s2geometry/sr-checklist.json \| Dòng: 2-62 \| Nội dung: 61 entry `{"id":"s01"…"s61"}` — không có s62 |
| 1.2 | Merge sao phủ 61/61, joinPolicy all, đủ 5/5 input, fail-closed kiểm tra đầu phiên PASS | File: reports/s2geometry/gm-08-stars.md \| Dòng: 5, 12-13 \| Nội dung: "joinPolicy **all**, fail-closed kiểm tra đầu phiên: **ĐỦ 5/5 input** … **61/61 item DONE**" |
| 1.3 | Phân bố sao toàn universe: ★5 = 0, ★4 = 0, ★3 = 2, ★2 = 15, ★1 = 44 | File: reports/s2geometry/gm-08-stars.md \| Dòng: 8, 21-25 \| Nội dung: "61/61 item DONE · 5★: 0 · 4★: 0 · 3★: 2 · 2★: 15 · ★1: 44"; bảng §1: "3★ \| 2 \| s15 s2latlng · s22 gmock" |
| 1.4 | Phát biểu tường minh của merge: không item nào đạt 4★/5★ | File: reports/s2geometry/gm-08-stars.md \| Dòng: 27 \| Nội dung: "Không item nào đạt 4★/5★: cặp S1∩S2 đạt ngưỡng 5★ duy nhất của universe là s30 (deps 2 ∧ fan 21) nhưng bị S5 chặn (loc 899 < 1000); mọi item deps ≤ 2 còn lại có fan ≤ 9 < 12" |
| 1.5 | JSON block máy-đọc 61 row: không row nào stars ≥ 4 | File: reports/s2geometry/gm-08-stars.md \| Dòng: 101-164 \| Nội dung: grep `"stars":[45]` trên file = **0 match** (positive control: grep `"stars":3` = đúng 2 match — s2latlng @ Dòng 117, gmock @ Dòng 124, khớp bảng §1) → max là `"stars":3` |
| 1.6 | Sao suy từ min-aggregation `star = min(S1..S5)`, merge đã tái tính độc lập 61/61 | File: reports/s2geometry/gm-08-stars.md \| Dòng: 14-15 \| Nội dung: "tái tính min-aggregation độc lập trên 61/61 item cho cùng kết quả (kể cả các ca biên: s30 bị S5 chặn vì loc 899 < 1000 …; s36 bị S3 chặn vì ratio 0.098 < 0.10; s32 bị S5 chặn vì PLM 1 < 2)" |
| 1.7 | Trần 5★ ≤ 3 item/repo không kích hoạt (0 ≤ 3) → không tie-break/demote làm mất thêm phần tử | File: reports/s2geometry/gm-08-stars.md \| Dòng: 16, 171 \| Nội dung: "0 item 5★ → mệnh đề '>3 item 5 sao → CẢNH BÁO rubric lỏng' **KHÔNG kích hoạt**, giữ nguyên số, không tie-break, không demote-by-cap" |
| 1.8 | Hệ quả: \|tập ≥4★\| = 0 < 1 → phần tử thứ #1 (của slot A) không tồn tại | Hệ quả logic của 1.1–1.7 \| Slot A rơi nhánh N/A của brief Dòng 5 |

## 2. Sàng cơ học độc lập trên 61 oracle row — tập ≥4★ = ∅ (PLM-free upper bound)

Ngưỡng áp dụng (File: reports/gm-07-rubric.md | Dòng: 93-97, kế thừa bởi part-w1 Dòng 15-21):
**4★ = deps_in ≤ 4 ∧ (in+out) ≥ 8 ∧ RATIO ≥ 0.25 ∧ N_E ≥ 1 ∧ loc ≥ 5000 ∧ PLM ≥ 50**;
**5★ = deps_in ≤ 2 ∧ (in+out) ≥ 12 ∧ RATIO ≥ 0.40 ∧ N_E ≥ 2 ∧ loc ≥ 20000 ∧ PLM ≥ 200**;
`star = min(S1..S5)`. Sàng dưới đây lọc trên 4 signal cấu trúc đọc thẳng
`gm-08-oracles.json` (s1_deps/s2_fan/s3_testratio/s5_loc), **không dùng PLM** → là **chặn trên**
của star: nếu chặn trên đã rỗng thì thêm PLM ≥ 50 (chỉ chặt hơn) chắc chắn vẫn rỗng.

Lọc máy độc lập của node này (awk script `sieve.awk` tự viết, chạy trong sandbox riêng
`sess-48ecfcb2`, raw §5): 61/61 row, **PASS4★ = 0, PASS5★ = 0**.

| Bước sàng | Điều kiện | Số item sống | Item |
|---|---|---|---|
| 1 | deps ≤ 4 (S1 đủ 4★) | 26 | s22 s23 s30 s36 s37 s38 s39 s41 s42 s43 s45 s46 s47 s48 s49 s50 s52 s53 s54 s55 s56 s57 s58 s59 s60 s61 |
| 2 | ∧ fan ≥ 8 (S2 đủ 4★) | 3 | s30 s1chord (deps 2, fan 21) · s41 s2padded (3, 8) · s61 s2coder (1, 9) |
| 3 | ∧ ratio ≥ 0.25 ∧ loc ≥ 5000 (S3+S5 đủ 4★) | **0** | s30: ratio 0.310 ✓ nhưng **loc 899**; s41: ratio 0.359 ✓ nhưng **loc 435**; s61: **ratio 0.0 ∧ loc 56** |
| 4★-filter đầy đủ | ∧ PLM ≥ 50 ∧ N_E ≥ 1 | 0 | — (đã rỗng từ bước 3; PLM/N_E chỉ chặt hơn) |
| 5★-filter | deps ≤ 2 ∧ fan ≥ 12 ∧ ratio ≥ 0.40 ∧ loc ≥ 20000 (PLM-free) | 0 | duy nhất s30 vượt S1∩S2 (2, 21) nhưng ratio 0.31 < 0.40 ∧ loc 899 — khớp phát biểu merge Dòng 27 |

→ **Tập ≥4★ = ∅ tất định trên dữ liệu oracle; phần tử thứ nhất (slot A) không tồn tại.**
Mỗi số trong bảng truy được về JSON: s30 @ Dòng 31, s41 @ Dòng 42, s61 @ Dòng 62 của
`gm-08-oracles.json` (mỗi item nằm ở Dòng = chỉ số + 1).

**Kiểm chéo cấu trúc (thêm, từ cùng sieve):** 7 item có loc ≥ 5000 (s2-core 20879, s2-python
9125, s2cell 8746, s2builderutil 8213, s2closest 8084, s2edge 6608, s2boolean 5706) **đều có
deps ≥ 7 > 4** → hai vế của conjunctive filter 4★ rời nhau tuyệt đối trên dữ liệu hiện tại:
không item nào có thể thỏa đồng thời "đủ lớn" và "ít phụ thuộc".

**Kê khai lỗi tự sửa trong quá trình sieve (trung thực, không ảnh hưởng kết quả cuối):**
1. Lần ghi `oracles.json` vào sandbox đầu tiên bị bỏ trống nội dung (write không có body) →
   sieve chạy trên 0 row (output `rows=` rỗng) — phát hiện ngay qua `rows` trống, ghi lại file
   đủ 61 row và chạy lại.
2. Lần sieve đầu dùng offset `substr` sai cho 2 trường (`"s1_deps":` là 10 ký tự, `"s3_testratio":`
   là 15 ký tự) → deps/ratio bị cắt xấu (s1chord in `deps=0 ratio=0` thay vì `2 / 0.31`) — phát
   hiện qua cross-check grep nguyên văn 3 row, sửa offset rồi chạy lại (sieve v2, raw §5).
   Các con số trình bày ở bảng trên là của sieve v2 sau sửa; fan/loc (hai trường kiểm soát
   bước 2–3) đúng từ lần đầu và không đổi giữa hai lần chạy.

## 3. Cross-check đo tươi tại PIN — chống nghi vấn "merge/oracle đánh thấp item nào đó"

Nghi vấn cần bác: *"oracle chấm sai làm che mất một item ≥4★ (thứ nhất cho slot A)"*. Bác bằng
đo tươi trên đúng cây PIN trong sandbox riêng (`bitnami/git:latest`, mọi lệnh git/code qua
`sandbox_shell`): `git clone --depth 100 --single-branch https://github.com/google/s2geometry` →
`git rev-parse HEAD` = **`677c8cebcff11ba11accc0b02005bc214e06e9fd`** == PIN chuỗi
(File: reports/s2geometry/gm-08-stars.md | Dòng: 4), branch `master` — mọi số dưới đây gắn cây PIN.

### 3.1 Census cấu trúc: tổng LOC khớp tuyệt đối Σ oracle

- src/s2 phẳng: **222 file .cc + 142 file .h = 130,700 LOC** (census v9 từng extension rồi cộng:
  cc 91,543 + h 39,157).
- src/python: cc 2,393 + h 74 + i 1,232 + py 5,426 = **9,125 LOC** (khớp nguyên văn kê khai của
  oracle — File: reports/s2geometry/gm-08-oracles-raw.md | Dòng: 27).
- **Tổng kiểm: sieve cộng Σ s5_loc của 61 row = 139,825 = 130,700 + 9,125 = tổng census đo tươi**
  → không còn file .cc/.h/.i/.py nào nằm ngoài 61 item, không item nào đếm trùng → **không thể
  có item "bị merge sót"** ngoài 61 item đã chấm.

### 3.2 Đo tươi 5 item quyết định — khớp oracle tuyệt đối (5/5 số loc)

5 item = 3 ứng viên sống sót sàng bước 2 (s30, s41, s61) + 2 item cao sao nhất universe (s15 3★,
s22 3★ — cận trên của bảng sao). File-set đo theo đúng luật census của oracle
(File: reports/s2geometry/gm-08-oracles-raw.md | Dòng: 17-22: basename không `_` → s2-core,
nên `s2latlng.cc/.h` và `s2coder.h` KHÔNG thuộc item s15/s61):

| item | item file-set đo | loc đo tươi | loc oracle | Khớp |
|---|---|---|---|---|
| s30 s1chord | s1chord_angle.cc + .h + _test.cc (3 file) | **899** | 899 (Dòng 31) | ✅ |
| s41 s2padded | s2padded_cell.cc + .h + _test.cc (3 file) | **435** | 435 (Dòng 42) | ✅ |
| s61 s2coder | s2coder_testing.h (1 file) | **56** | 56 (Dòng 62) | ✅ |
| s15 s2latlng | s2latlng_rect*.cc/.h (4) + s2latlng_rect_test.cc + s2latlng_rect_bounder_test.cc + s2latlng_test.cc (7 file; loại s2latlng.cc/.h — s2-core) | **3432** | 3432 (Dòng 16) | ✅ |
| s22 gmock | gmock_matchers.cc + .h + _test.cc (3 file) | **2006** | 2006 (Dòng 23) | ✅ |

### 3.3 Hệ quả đo tươi đối với 3 ứng viên cuối cùng

- s30: loc đo tươi 899 vs ngưỡng 4★ cần ≥ 5000 (thiếu **5.56×**), PLM 10 vs cần ≥ 50 — `loc` là
  census `find -print0 | xargs -0 cat | wc -l` deterministic, không lần đo lại nào dịch được
  số này 5.6 lần.
- s41: loc 435 vs ≥ 5000 (thiếu **11.5×**).
- s61: ratio 0.0 (không có file test trong item) vs cần ≥ 0.25 ∧ loc 56 vs ≥ 5000.
→ Không ứng viên nào có đường lên 4★; **phần tử thứ nhất cho slot A không thể sinh ra từ dữ liệu**.

## 4. Tính đơn điệu của verdict N/A (chống mọi lần chấm lại)

- **Hai vế filter rời nhau (mục 2):** mọi item loc ≥ 5000 đều deps ≥ 7. Muốn xuất hiện item 4★
  mới, phải có item vượt đồng thời hai vế — hiện không ai gần cả hai.
- **3 ứng viên đồ thị đều trượt S5 ≥ 5.6×** (mục 3.3) với số đo deterministic.
- **Cận biên cao nhất của universe là s15 (deps 5 vs ngưỡng ≤ 4, đúng 1):** giả sử deps flip,
  s15 vẫn cần loc ≥ 5000 (đo tươi 3432 — cách **1.46×**) trước khi tính tới các signal còn lại;
  và s22 (fan 7 vs ≥ 8, đúng 1) vẫn cần loc ≥ 5000 (đo 2006 — cách **2.49×**) dù PLM 66 ✓.
  `loc` flip không thể xảy ra do census deterministic → không item nào flip được.
- Kết luận: **|≥4★| = 0 bền vững dưới mọi lần chấm lại thực tế** → phần tử thứ nhất không tồn tại
  → N/A là verdict cuối cùng của slot A. (Chứng minh bổ sung: nếu một ngày nào đó |≥4★| = 1 thì
  phần tử đó thuộc slot A — lúc đó slot B mới là N/A; hiện tại cả hai cùng N/A vì tập rỗng.)

## 5. Raw output verbatim (sandbox_shell, sandbox `sess-48ecfcb2`, clone @ PIN `677c8ceb…`)

Batch PIN + census:
```
$ cd /workspace && git clone --depth 100 --single-branch https://github.com/google/s2geometry s2geometry
Cloning into 's2geometry'...
Updating files: 100% (520/520), done.
$ git -C s2geometry rev-parse HEAD
677c8cebcff11ba11accc0b02005bc214e06e9fd
$ git -C s2geometry branch --show-current
master
== src/s2 counts cc h ==
222
142
== census v9 per-ext src/s2 (cc, h) ==
91543
39157
== census v9 per-ext src/python (cc, h, i, py) ==
cc: 2393
h: 74
i: 1232
py: 5426
```

Batch sieve v2 (sau sửa offset; file `oracles.json` = nguyên văn 61 row của
`reports/s2geometry/gm-08-oracles.json`, program `sieve.awk` ghi qua sandbox_write_file):
```
== AWK SIEVE v2 (offsets fixed) ==
4STAR-candidate (fails later gate): s1chord deps=2 fan=21 ratio=0.31 loc=899
4STAR-candidate (fails later gate): s2padded deps=3 fan=8 ratio=0.359 loc=435
4STAR-candidate (fails later gate): s2coder deps=1 fan=9 ratio=0 loc=56
rows=61 SUM(s5_loc)=139825 PASS4STAR=0 PASS5STAR=0
items loc>=5000 with deps>4: 7
== cross-check awk field extraction on 3 rows ==
{"module":"s2-core","s1_deps":25,"s2_fan":85,"s3_testratio":0.0,"s5_loc":20879,"s4":null},
{"module":"s1chord","s1_deps":2,"s2_fan":21,"s3_testratio":0.31,"s5_loc":899,"s4":null},
{"module":"s2padded","s1_deps":3,"s2_fan":8,"s3_testratio":0.359,"s5_loc":435,"s4":null},
```

Batch đo tươi item (family glob + file-set chính xác):
```
=== s1chord === 899      s1chord_angle_test.cc s1chord_angle.h s1chord_angle.cc
=== s2padded === 435     s2padded_cell_test.cc s2padded_cell.cc s2padded_cell.h
=== s2coder ===  216     s2coder_testing.h s2coder.h        # item s61 = s2coder_testing.h:
         s2coder_testing.h: 56                            # s2coder.h là s2-core (basename không _)
=== gmock ===    2006    gmock_matchers_test.cc gmock_matchers.h gmock_matchers.cc
=== s2latlng === 3829    …(9 file glob)…                    # item s15 = 7 file loại s2latlng.cc/.h:
         s2latlng item (7 files): 3432                    # s2latlng.cc/.h là s2-core
```

## 6. Kế thừa LẦN CHẠY 2+ (brief Dòng 3)

Kiểm tra lúc bắt đầu node: glob `reports/s2geometry/` — **KHÔNG tồn tại** `gm-09a-plan.md`
(chỉ có `gm-09b-plan.md`; các gm-09a/b cũ nằm ở codesearch/jimfs/mtail/pprof) → **lần chạy 1
của slot A s2geometry, không INHERITED, không fix-list**; file này là lần sinh đầu. (Slot B
cùng subject cũng tự kê khai lúc nó chạy: "gm-09a-plan.md … slot A chưa xuất hiện" —
File: reports/s2geometry/gm-09b-plan.md | Dòng: 30-31 — khớp.)

Hướng dẫn lần chạy sau (nếu re-run): verdict N/A chỉ đổi khi tập ≥4★ của s2geometry có ≥ 1 phần
tử — đòi hỏi gm-07/gm-08 chấm lại sao. Ba đường gần nhất đều bít bởi số đo deterministic
(mục 4). Khi tập ≥4★ ≥ 1: regenerate plan theo khuôn slot A pprof
(File: reports/pprof/gm-09a-plan.md | Dòng: 29-55 — bảng COPY NGUYÊN CỤC / prune
KEEP–VENDOR–CUT / lệnh `cmake -S . -B build && cmake --build build -j2`; container
`bitnami/git` không có cmake thì ghi SKIPPED trung thực). Cho tới khi đó, file N/A này là
kết quả cuối hợp lệ của slot A s2geometry.

## 7. Checklist thẩm định N/A (cho reviewer)

1. **G1 — Universe/census:** sr-checklist 61 item (mục 1.1); merge coverage 61/61 (mục 1.2);
   census tươi Σ = 139,825 khớp tuyệt đối Σ 61 s5_loc trên đúng PIN (mục 3.1) → không item bị
   merge sót, không item nào ngoài universe.
2. **G2 — Tập ≥4★ = ∅ (kích thước 0):** phân bố sao đóng băng (mục 1.3-1.5, có positive control
   grep) + sieve cơ học PLM-free độc lập 61 row cho 0 PASS (mục 2) → phần tử thứ #1 không tồn tại
   → N/A đúng điều kiện brief Dòng 5.
3. **G3 — Cross-check đo tươi:** 5 item quyết định khớp oracle 5/5 số loc trên đúng cây PIN
   (mục 3.2); 2 lỗi của node (write rỗng, offset awk) tự phát hiện - tự sửa - kê khai (mục 2);
   lỗi 3.3 không phát sinh — đo tươi khớp tuyệt đối ngay từ lần đầu.
4. **G4 — Đơn điệu:** hai vế filter rời nhau + 3 ứng viên trượt S5 ≥ 5.6× + 2 cận biên trượt
   loc 1.46×/2.49× (mục 4) → |≥4★| = 0 bền → N/A bền cho slot A.
5. **G5 — Ranh giới slot:** file này KHÔNG lập kế hoạch cắt cho bất kỳ item nào (tập rỗng),
   KHÔNG đụng artifact subject khác, KHÔNG sửa gm-08/part/status; nhất quán với slot B
   (cùng N/A trên cùng dữ liệu).
6. **G6 — PLAN-ONLY + REDACTION:** không cắt thật, không tạo repo, không push (brief Dòng 13);
   file không chứa token/secret (`ghp_` = 0); clone chỉ dùng URL public HTTPS, không token.

## 8. Files của node này + kê khai môi trường

- `reports/s2geometry/gm-09a-plan.md` — deliverable (file N/A plan này) — **mới**.
- Không commit git, không push: deliverable là report trong workspace session (tiền lệ
  gm-08-stars — File: reports/s2geometry/gm-08-stars.md | Dòng: 173; slot B s2geometry —
  File: reports/s2geometry/gm-09b-plan.md | Dòng: 237-239). Sandbox chỉ clone-đọc
  google/s2geometry.
- Môi trường đo: sandbox riêng `bitnami/git:latest` ttl 7200, session `sess-48ecfcb2`
  (throwaway `/workspace`); clone nông depth-100 single-branch `master` bằng `sandbox_shell`
  trong container, `git rev-parse HEAD` == PIN `677c8cebcff11ba11accc0b02005bc214e06e9fd` đo
  trực tiếp. Không dùng token trong bất kỳ lệnh nào. **KHÔNG dọn sandbox cuối phiên**
  (brief Dòng 2 — ttl tự hủy).
