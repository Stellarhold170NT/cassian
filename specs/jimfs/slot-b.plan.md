# EXTRACTION PLAN — SLOT B (google/jimfs @ 8fa098e0) — **VERDICT: N/A**

**This document is a plan.** Verdict **N/A**: no second item rated ≥4★ exists
(the universe is a single package) → nothing to cut for slot B.

## Verdict

**N/A** — tập item ≥4★ của subject jimfs có đúng **1** phần tử; slot A lấy phần tử
**ĐỨNG THỨ NHẤT**, slot B phải lấy phần tử **ĐỨNG THỨ HAI** — phần tử thứ hai không tồn tại.
Theo đúng điều kiện brief: "Không đủ item → 'N/A' + DONE" (File: briefs/ex_b--fce15710.md |
Dòng: 6 | Nội dung: "Lấy item ≥4 sao ĐỨNG THỨ HAI (slot A lấy thứ nhất). … Không đủ item →
'N/A' + DONE").

## 1. Cơ sở N/A — bằng chứng từ chuỗi artifact đóng băng (gm-07 → gm-08)

| # | Luận điểm | Evidence |
|---|---|---|
| 1.1 | Universe của subject = đúng 1 item | File: reports/jimfs/sr-checklist.json | Dòng: 1-3 | Nội dung: `[ {"id": "s01", "module": "com.google.common.jimfs", "assignee": "w1", "status": ""} ]` — 1 dòng item duy nhất |
| 1.2 | Merge sao xác nhận coverage 1/1 | File: reports/jimfs/gm-08-stars.md | Dòng: 18-20 | Nội dung: "Universe: `reports/jimfs/sr-checklist.json:2` = exactly **1 item** … the merge below covers **1/1** items" |
| 1.3 | Bảng sao chỉ có 1 hàng, item đó 5★ | File: reports/jimfs/gm-08-stars.md | Dòng: 42-44 | Nội dung: tiêu đề "Star table — ALL items (1/1)" + hàng duy nhất `s01 · com.google.common.jimfs · ★★★★★` |
| 1.4 | 5★ của s01 đạt qua thang rubric, có cap kiểm | File: reports/jimfs/gm-08-stars.md | Dòng: 46-50, 98-100 | Nội dung: ladder trace `S3=A ∧ S5=A ∧ S4=A ∧ (S1=A ∨ S2=A)` → ★★★★★; "5-star cap ≤ 3 items/repo: universe = 1 item → 1 ≤ 3, cap not binding" |
| 1.5 | Tập ≥4★ = {s01}, kích thước 1 → phần tử thứ #2 không tồn tại | Hệ quả logic của 1.1–1.4: tập {s01} có |{s01}| = 1 < 2 | Slot B rơi nhánh N/A của brief Dòng 6 |
| 1.6 | Số đo oracle của s01 (đối chiếu chéo §2) | File: reports/jimfs/gm-08-oracles.json | Dòng: 2 | Nội dung: `{"module": "com.google.common.jimfs", "s1_deps": 6, "s2_fan": 12, "s3_testratio": 1.0426, "s5_loc": 12468, "s4": null}` |

Không mơ hồ về thứ tự: bảng sao chỉ có 1 hàng nên không phát sinh tie-break; item duy nhất
(s01) thuộc slot A (brief `ex_a--fce15710.md` Dòng 4: "Lấy item ≥4 sao ĐỨNG THỨ NHẤT").
Slot B **không đụng phạm vi slot A** (brief Dòng 4) — không lặp lại kế hoạch cắt cho s01.

## 2. Cross-check nguồn tại PIN — tập universe = 1 đúng về cấu trúc (chống nghi vấn "merge sót item")

Clone nông `google/jimfs` trong sandbox riêng (`bitnami/git:latest`, mọi lệnh qua
`sandbox_shell`): broker clone trả **`headCommit = 8fa098e0715aa492914285312c07e151d2aace4d`,
branch `master`** — **HEAD upstream == PIN** của chuỗi gm-08 (File: reports/jimfs/gm-08-stars.md |
Dòng: 15-17 | Nội dung: "Subject PIN: `8fa098e0715aa492914285312c07e151d2aace4d`") → số đo tươi
dưới đây đo trên ĐÚNG CÂY PIN, không drift.

| Đại lượng | Chuỗi gm-08 (frozen) | Đo tươi @ PIN 8fa098e0 | Khớp |
|---|---|---|---|
| Package chính duy nhất | "one package" (gm-08-stars.md:44) | `find jimfs/src/main/java -name '*.java'` → đúng 1 thư mục `com/google/common/jimfs` | ✅ |
| Số file main | 62 (gm-08-stars.md:44) | 62 | ✅ |
| LOC main | 12468 (gm-08-oracles.json:2, gm-08-stars.md:44) | 12468 (`cat` tất cả rồi `wc -l` — công thức census v9, không `xargs wc -l \| tail -1`) | ✅ |
| Số file test | 52 (gm-08-stars.md:44) | 52 | ✅ |
| LOC test | 12999 (gm-08-stars.md:44) | 12999 | ✅ |
| testratio S3 | 1.0426 | 12999/12468 = 1.04259 ≈ 1.0426 | ✅ |
| Cấu trúc maven | "repo = 1 maven module" (AGENTS.md §2, universe cấp package) | root `pom.xml:29` = `<module>jimfs</module>` — đúng 1 leaf module `jimfs`; toàn bộ main code nằm dưới `jimfs/src/main/java` | ✅ |

Kết luận cấu trúc: bề mặt khai thác Java của jimfs là **đúng một package**
`com.google.common.jimfs` (62 file / 12468 LOC) — không tồn tại package chính thứ hai mà bước
merge sao có thể bỏ sót → universe 1 item là **đúng cấu trúc từ source**, verdict N/A không
phải do lỗi hợp nhất. Test KHÔNG thành item (vào oracle S3) theo định nghĩa universe jimfs
(AGENTS.md §2: "test KHÔNG thành item (vào oracle S3)").

Ghi chú trung thực: root `pom.xml` khai 1 `<module>jimfs</module>` (reactor 2 pom: parent +
con) — AGENTS.md §2 đã chuẩn hóa universe jimfs ở **cấp package dưới `jimfs/src/main/java`**,
nên 1 package chính = 1 item vẫn đúng; không ảnh hưởng verdict.

## 3. Kế thừa LẦN CHẠY 2+ (brief Dòng 3)

Kiểm tra lúc bắt đầu node: `glob reports/jimfs/**` và `reports/**/gm-09*` — **KHÔNG tồn tại**
`reports/jimfs/gm-09a-plan.md` lẫn `reports/jimfs/gm-09b-plan.md` (các gm-09b cũ chỉ có ở
`reports/gm-09b-plan.md` — kafka — và `reports/codesearch/gm-09b-plan.md` — codesearch) →
**lần chạy 1, không INHERITED**, file này là lần sinh đầu.

Hướng dẫn lần chạy sau (nếu re-run): verdict N/A chỉ đổi khi universe ≥4★ tăng lên ≥2 item —
điều đó đòi hỏi gm-07/gm-08 tạo thêm item mới cho jimfs; khi đó regenerate plan theo khuôn
`reports/codesearch/gm-09b-plan.md` (copy-then-prune: file copy nguyênục / bảng prune KEEP–
VENDOR–CUT / lệnh build+test `mvn -q -DskipTests compile`, `mvn test` — sandbox không có Maven
thì ghi SKIPPED trung thực / rủi ro cắt tỉa + kiểm sau cắt). Cho tới khi đó, file N/A này là
kết quả cuối hợp lệ của slot B jimfs.

## 4. Raw output verbatim (sandbox_shell, session sandbox `sess-2eedacc5`, clone @ PIN)

```
== maven modules in root pom ==
1
== the <module> line ==
29:    <module>jimfs</module>
== source tree dirs ==
jimfs/src
jimfs/src/main
jimfs/src/main/java
jimfs/src/main/java/com
jimfs/src/main/java/com/google
jimfs/src/main/java/com/google/common
jimfs/src/test
jimfs/src/test/java
jimfs/src/test/java/com
jimfs/src/test/java/com/google
jimfs/src/test/java/com/google/common
== main java files per dir ==
     62 jimfs/src/main/java/com/google/common/jimfs
== main: file count + total LOC (cat|wc, v9-safe) ==
62
12468
== test: file count + total LOC ==
52
12999
```

Lệnh tương ứng (thứ tự chạy): `grep -c '<module>' pom.xml` · `grep -n '<module>' pom.xml` ·
`find jimfs/src -maxdepth 5 -type d | sort` · `find jimfs/src/main/java -name '*.java' | sed
's|/[^/]*$||' | sort | uniq -c` · `find … -name '*.java' | wc -l` · `find … -print0 | xargs -0
cat | wc -l` (main rồi test). Clone do tool `sandbox_git_clone` thực hiện (không clone bằng
shell), trả `{"headCommit":"8fa098e0715aa492914285312c07e151d2aace4d","filesIngested":123,
"branch":"master"}`.

## 5. Checklist thẩm định N/A (cho reviewer)

1. G1 — Universe: `sr-checklist.json` có đúng 1 item (mục 1.1) và gm-08-stars coverage 1/1 (mục 1.2).
2. G2 — Bảng sao 1 hàng ≥4★ (mục 1.3): tập ≥4★ = {s01}, thứ #2 không tồn tại → N/A đúng điều kiện brief Dòng 6.
3. G3 — Số đo tươi khớp oracle tuyệt đối (mục 2: 62/12468/52/12999/1.0426) trên đúng PIN `8fa098e0` → bằng chứng không drift, không bịa.
4. G4 — Ranh giới slot: file này KHÔNG lập kế hoạch cắt cho s01 (việc của slot A), KHÔNG đụng artifact subject khác.
5. G5 — PLAN-ONLY: không cắt thật, không tạo repo, không push — đúng brief Dòng 7.

## 6. Files của node này

- `reports/jimfs/gm-09b-plan.md` — deliverable (file N/A plan này) — **mới**.
- `reports/ex_b--fce15710.md` — report node — **mới**.
- Không commit git, không push: deliverable là report trong workspace session; sandbox chỉ
  clone-đọc google/jimfs (giống tiền lệ slot B kafka — File: reports/ex_b--ef360255.md |
  Dòng: 41-43).
