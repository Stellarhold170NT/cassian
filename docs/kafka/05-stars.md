# 05-stars.md — RUBRIC SAO + BẢNG CHẤM 66 MODULE (apache/kafka)

> **Provenance (publish node):** Part I = `reports/gm-07-rubric.md` (rubric 5→1 sao — sao chép nguyên văn 150 dòng); Part II = `reports/gm-08-stars.md` (bảng chấm + JSON 66/66 — sao chép nguyên văn 196 dòng). Ghép theo layout `reports/gm-final.md` mục 4; nội dung 2 phần KHÔNG sửa.

---

# PART I — RUBRIC (nguyên văn reports/gm-07-rubric.md)

# GM-07 — STAR RUBRIC 5→1 SAO (apache/kafka, 66 module)

- Task: `goldmine-spec--star_rubric--ef360255` | Lần chạy: **1** — glob `reports/*` toàn workspace không có file `gm-07-*` trước đó → không INHERITED (điều kiện "LẦN CHẠY 2+" của brief chưa kích hoạt — fact từ brief: File: briefs/star_rubric--ef360255.md | Dòng: 3).
- INPUT duy nhất: **gm-02** — JSON 66 item m01→m66 (File: reports/gm-02-module-map.md | Dòng: 143-210) + quy ước field (cùng file, Dòng: 42-48).
- Trạng thái node: **DRAFT** (chờ gate; không tự phong FROZEN).
- Yêu cầu brief đang thực thi: mỗi signal có ORACLE = lệnh đo cụ thể + ngưỡng số (File: briefs/star_rubric--ef360255.md | Dòng: 4-8); mỗi mức sao = tổ hợp ngưỡng cụ thể ghi đúng số (Dòng: 8-9); trần 5 sao ≤ 3 module/repo (Dòng: 8-9); tự kiểm "hai người đo độc lập ra cùng số" (Dòng: 9); CẤM tiêu chí cảm tính (Dòng: 10); output file này (Dòng: 10).

## 0. Ngữ nghĩa field gm-02 (chống đọc nhầm — bắt buộc đọc trước khi chấm)

| Field JSON | Nghĩa trên đồ thị phụ thuộc | Nguồn định nghĩa |
|---|---|---|
| `deps_in` | fan-OUT của module: nó import code từ những module ngoài nào (nhu cầu bên ngoài) | "các module BÊN NGOÀI mà module này import code từ chúng" (File: reports/gm-template-row.md | Dòng: 21) |
| `deps_out` | fan-IN của module: những module ngoài nào import nó (độ được phụ thuộc) | "các module BÊN NGOÀI import module này" (File: reports/gm-template-row.md | Dòng: 23) |

⚠️ Bẫy đặt tên: "fan-in" của lý thuyết đồ thị = field `deps_out` của JSON, KHÔNG phải `deps_in`. S2 dùng tổng của cả hai field nên bẫy này không đổi kết quả số, nhưng phải ghi rõ để audit không nhầm chiều. `deps_in`/`deps_out` rỗng `[]` = 0 (File: reports/gm-02-module-map.md | Dòng: 45).

Cây commit chuẩn để đo: `3655d7c19cd9771ef4b1d213084cfd08f45c7581` — cây mà các row gm-02 đã được verify (File: reports/gm-06-flows.md | Dòng: 6).

---

## 1. Năm signal — oracle + ngưỡng số

### S1 REUSABILITY — số dep ngoài, ÍT TỐT HƠN (brief Dòng: 4-5)

- Định nghĩa đo: `S1 = |deps_in|` — số module ngoài mà module này phải import code từ chúng (biên module, đo trên src/main).
- Oracle (nguồn chính): đếm số phần tử mảng `deps_in` trong JSON gm-02 (Dòng: 143-210).
- Oracle (đo lại khi audit) — lệnh chuẩn của template, kèm verify mapping:
```bash
grep -rhE '^[[:space:]]*import[[:space:]]+<package-prefix>' --include='*.scala' --include='*.java' <module>/src/main | sort -u
# mapping package→module BẮT BUỘC verify bằng:
find <module-dir> -type d -path "*/src/main/java/<package-path>"
```
  (File: reports/gm-template-row.md | Dòng: 35)
- Caveat kế thừa từ gm-02 (không đo lại kiểu khác): 20 module test-only grep trên toàn `src`; deps ẩn qua `src/testFixtures` không cộng; class generate build-time resolve về module chủ JSON spec (File: reports/gm-02-module-map.md | Dòng: 131).
- **Ngưỡng: 5★ |deps_in| ≤ 2 · 4★ ≤ 4 · 3★ ≤ 6 · 2★ ≤ 9 · 1★ ≥ 10.**

### S2 CENTRALITY — fan-in + fan-out từ JSON gm-02 (brief Dòng: 5-6)

- Định nghĩa đo: `S2 = |deps_in| + |deps_out|` (tổng hai mảng JSON — đúng chữ brief).
- Oracle: đếm phần tử 2 mảng trong JSON gm-02 (Dòng: 143-210); đo lại: deps_in bằng lệnh S1, deps_out bằng cùng lệnh đảo chiều quét toàn bộ module khác.
- **Ngưỡng: 5★ S2 ≥ 12 · 4★ ≥ 8 · 3★ ≥ 5 · 2★ ≥ 2 · 1★ ≤ 1.**

### S3 QUALITY — tỉ lệ test / tổng LOC (brief Dòng: 6)

- Định nghĩa đo: `RATIO = T / A`, với T = tổng LOC java+scala dưới mọi thư mục `src/test` của path, A = tổng LOC java+scala toàn path (census v9 — công thức `find … -print0 | xargs -0 cat | wc -l`; **CẤM** `xargs wc -l | tail -1` — File: reports/gm-template-row.md | Dòng: 34, 100).
- Oracle:
```bash
TEST_DIRS=$(find <path> -type d -path '*src/test*')
T=$(find $TEST_DIRS -type f \( -name '*.java' -o -name '*.scala' \) -print0 | xargs -0 cat | wc -l)
A=$(find <path> -type f \( -name '*.java' -o -name '*.scala' \) -print0 | xargs -0 cat | wc -l)
# RATIO = T/A ; module không có src/test → T = 0 → RATIO = 0
```
  Dùng danh sách thư mục `*src/test*` / `*src/main*` thay vì `<path>/src/test` cứng để đúng trường hợp đặc biệt m24 `api-checker`: field `path` là module dir, code nằm `api-checker/{core,gradle-plugins,maven-plugin}/src/...` (File: reports/gm-02-module-map.md | Dòng: 167, 92).
- Data-point hiệu chuẩn có sẵn trong field `tests` của gm-02 (đọc nguyên văn, chưa đo lại toàn bộ): m58 ≈ 0.44 (test 269+116 / loc 881 — Dòng: 201), m59 ≈ 0.45 (281/625 — Dòng: 202), m26 ≈ 0.31 (857+337/3897 — Dòng: 169), m24 ≈ 0.15 (513+424/6179 — Dòng: 167), m66 = 0 (không có test — Dòng: 209). Module lớn (m01, m02, m03…) đo lúc chấm — không pha chế số trước.
- **Ngưỡng: 5★ RATIO ≥ 0.40 · 4★ ≥ 0.25 · 3★ ≥ 0.10 · 2★ > 0 · 1★ = 0.**

### S4 DISTINCTIVENESS — không có OSS tương đương, ≥2 evidence (brief Dòng: 6-7)

- Định nghĩa đo: `N_E` = số evidence hợp lệ. Một evidence chỉ hợp lệ khi đủ CẢ 3 trường (thiếu 1 → không tính):
  1. Tên 1 candidate tương đương cụ thể (project OSS hoặc thương mại);
  2. Lệnh kiểm tra nguyên văn + raw output, chỉ 2 loại được phép:
     - **E1 (trong repo — deterministic):** `grep -rln "<class-lõi>" --include='*.java' --include='*.scala' <path-tất-cả-module-khác> | wc -l` → kết quả `0` chứng minh component chỉ tồn tại ở module này;
     - **E2 (ngoài repo):** truy vấn công khai ghi được lệnh (gh search code / URL tìm kiếm) + raw output dán nguyên văn;
  3. Kết luận đúng 1 dòng "không tương đương" kèm khác biệt API cụ thể (tên class/interface không có bên candidate).
- **Ngưỡng: 5★ N_E ≥ 2 VÀ ≥ 1 evidence thuộc loại E2 (mệnh đề brief là "không có OSS tương đương" nên bắt buộc 1 bằng chứng ngoài repo) · 4★ N_E = 1 · 3★ N_E = 0 (đã chạy protocol nhưng không lập được evidence) · S4 không dùng ở 2★/1★.**
- Honest caveat (điểm không 100% máy duy nhất của rubric): phán quyết "tương đương/không" của E2 do người chấm đọc raw output. Chắn có: E1 luôn deterministic; format 3 trường bắt buộc làm artifact audit được; hai người cùng bộ artifact → cùng N_E. Khác phán quyết E2 → ghi cả hai verdict vào row, không tự chọn phe (đi review).

### S5 SUBSTANCE — LOC + hàm public có logic thật (brief Dòng: 7-8)

- Định nghĩa đo: hai đại lượng cùng lúc: `loc` (field gm-02, census v9) và `PLM` = số method Java bắt đầu bằng modifier `public|protected` có kiểu trả về + tên + `(`, cộng số `def` Scala ở đầu dòng — TRỪ pattern accessor `get*/set*/is*/has*`.
- Oracle:
```bash
MAIN_DIRS=$(find <path> -type d -path '*src/main*')
J=$(grep -rhE '^[[:space:]]*(public|protected)[[:space:]]+[A-Za-z_][A-Za-z0-9_<>\[\],\. ?]*[[:space:]]+[A-Za-z0-9_]+[[:space:]]*\(' --include='*.java' $MAIN_DIRS | grep -cvE '\b(get|set|is|has)[A-Z]')
S=$(grep -rhE '^[[:space:]]*def[[:space:]]+[A-Za-z0-9_]+[[:space:]]*\(' --include='*.scala' $MAIN_DIRS | grep -cvE '\b(get|set|is|has)[A-Z]')
# PLM = J + S
```
- Quy ước kê khai (để hai người đo ra cùng số):
  (a) constructor không khớp regex (thiếu kiểu trả giữa modifier và dấu `(`) → không đếm;
  (b) method interface Java (khai báo không modifier) KHÔNG đếm → hệ quả thiết kế: module thuần API (m16 connect/api, m29 storage/api, m54 group-coordinator-api, m60 tools-api — File: reports/gm-02-module-map.md | Dòng: 159, 172, 197, 203) có PLM thấp; giá trị "được phụ thuộc" của chúng được ghi nhận bởi S2, không phải S5;
  (c) khai báo có annotation cùng dòng (`@Deprecated public void …`) hụt khớp → hụt có chủ đích, cùng lệnh = cùng số;
  (d) "logic thật" là xấp xỉ grep (không phân tích AST) — chọn grep vì deterministic, không phụ thuộc toolchain build. Scala `private def`/`protected def` bị loại tự nhiên vì dòng bắt đầu bằng modifier, không khớp `^[[:space:]]*def`.
- **Ngưỡng: 5★ loc ≥ 20000 ∧ PLM ≥ 200 · 4★ loc ≥ 5000 ∧ PLM ≥ 50 · 3★ loc ≥ 1000 ∧ PLM ≥ 10 · 2★ loc ≥ 200 ∧ PLM ≥ 2 · 1★ còn lại.**

---

## 2. Công thức sao — mỗi mức = tổ hợp ngưỡng cụ thể

`star(M) = min(S1★, S2★, S3★, S4★, S5★)` — min-aggregation nghĩa là đạt mức sao K khi AND của cả 5 signal đều đạt ngưỡng mức K:

| Sao | Tổ hợp ngưỡng đủ (ghi đúng số) |
|---|---|
| ★★★★★ | deps_in ≤ 2 ∧ (in+out) ≥ 12 ∧ RATIO ≥ 0.40 ∧ N_E ≥ 2 (≥1 loại E2) ∧ loc ≥ 20000 ∧ PLM ≥ 200 |
| ★★★★ | deps_in ≤ 4 ∧ (in+out) ≥ 8 ∧ RATIO ≥ 0.25 ∧ N_E ≥ 1 ∧ loc ≥ 5000 ∧ PLM ≥ 50 |
| ★★★ | deps_in ≤ 6 ∧ (in+out) ≥ 5 ∧ RATIO ≥ 0.10 ∧ loc ≥ 1000 ∧ PLM ≥ 10 |
| ★★ | deps_in ≤ 9 ∧ (in+out) ≥ 2 ∧ RATIO > 0 ∧ loc ≥ 200 ∧ PLM ≥ 2 |
| ★ | mọi cấu hình yếu hơn |

Vì sao min mà không cộng điểm: cộng/trọng số tạo trade-off ẩn (module 1★ quality bù bằng centrality) — vi phạm "mỗi mức sao = tổ hợp ngưỡng cụ thể" và làm hai người chấm ra khác nhau. Min là phép tổ hợp duy nhất không cần bàn luận.

---

## 3. Trần 5 sao ≤ 3 module/repo — bằng chứng cấu trúc trên dữ liệu gm-02

Điều kiện 5★ bị chặn trước ở S1∩S2 (hai signal đọc thẳng JSON, không cần đo mới). Các module đạt S2 ≥ 12 trên 66 item: m01 (23), m12 (17), m18 (16), m10 (14), m03 (13), m08 (12), m11 (12), m07 (12) (File: reports/gm-02-module-map.md | Dòng: 144, 155, 161, 153, 146, 151, 154, 150). Trong 8 module đó, chỉ **m01 (deps_in = 0)** và **m12 (deps_in = 1)** đạt S1 ≤ 2; m18 (16), m10 (10), m03 (11), m08 (12), m11 (12) vi phạm S1; m07 (3) vi phạm S1.

→ **S1∩S2 tại ngưỡng 5★ = {m01, m12} = 2 module ≤ 3.** S3/S4/S5 chỉ có thể HẠ sao (min-aggregation), không thể phát sinh 5★ mới → trần ≤ 3 được bảo đảm CẤU TRÚC trên dữ liệu gm-02 hiện hành, không phụ thuộc kết quả đo S3/S4/S5.

Backstop (vẫn ghi sổ bắt buộc): nếu khi chấm trên cây mới số module 5★ > 3, xếp hạng tie-break deterministic: **S2 giảm dần → loc giảm dần → id tăng dần**; module vượt trần bị HẠ 4★ và row chấm phải ghi "demoted by cap (rank #N)". Cấm demote theo cảm nhận.

---

## 4. Tự kiểm reproducibility (tiêu chí brief Dòng: 9-10: "hai người đo độc lập ra cùng số không?")

| Signal | Hai người độc lập ra cùng số? | Cơ chế bảo đảm |
|---|---|---|
| S1, S2 | CÓ | đếm phần tử mảng JSON (dữ liệu text tĩnh); audit bằng đúng 1 lệnh grep + 1 lệnh find mapping |
| S3 | CÓ | cùng lệnh find/cat/wc trên cùng cây commit → cùng T, A, RATIO |
| S5 | CÓ | cùng lệnh grep trên cùng cây → cùng PLM; loc chép census v9 |
| S4 | N_E: CÓ (đếm artifact); phán quyết E2: điểm mờ duy nhất | format 3 trường bắt buộc; E1 deterministic; E2 raw output dán nguyên văn để reviewer đối chiếu |

CẤM tuyệt đối: tiêu chí cảm tính ("code đẹp", "nổi tiếng", "quan trọng theo cảm nhận") vào bất kỳ ô ngưỡng nào; công thức census bị cấm v9 `xargs wc -l | tail -1` (File: reports/gm-template-row.md | Dòng: 34, 100); sửa `reports/gm-checklist.json` (cùng file, Dòng: 97).

---

## 5. Dry-run trên dữ liệu gm-02 có sẵn (chứng minh cap — CHƯA PHẢI LÀ BẢNG CHẤM)

S1/S2/S5-loc đọc thẳng JSON; S3 / S5-PLM / S4 = **CHƯA ĐO** (điền lúc chấm — cấm pha chế số trước khi chạy lệnh):

| module | deps_in | in+out | loc | S1★ | S2★ | S5★(loc-part) | Kết luận tạm |
|---|---|---|---|---|---|---|---|
| m01 clients | 0 | 23 | 387329 | 5 | 5 | 5 | ứng viên 5★ (S3/S4/PLM chờ đo) |
| m12 server-common | 1 | 17 | 35932 | 5 | 5 | 5 | ứng viên 5★ |
| m18 jmh-benchmarks | 16 | 16 | 11699 | 1 | 5 | 4 | S1 chặn |
| m02 streams | 1 | 5 | 338869 | 5 | 3 | 5 | S2 chặn 5★ |
| m03 core | 11 | 13 | 160242 | 1 | 5 | 5 | S1 chặn |
| m66 mirror-coordinator | 1 | 2 | 110 | 5 | 2 | 1 | ~★ |

Mọi số trên trích nguyên JSON gm-02 (File: reports/gm-02-module-map.md | Dòng: 144, 155, 161, 145, 146, 209).

---

## 6. Protocol chấm 1 module (cho node chấm sau dùng lại từng bước)

1. Chốt cây commit đo = cert hiện hành (mặc định `3655d7c…`, xem mục 0).
2. Đọc S1, S2 từ JSON gm-02; nếu audit → chạy lại lệnh mục 1 (S1) + lệnh đảo chiều (deps_out).
3. Chạy lệnh S3 → RATIO; chạy lệnh S5 → PLM; đối chiếu `loc` với JSON.
4. Lập 2 artifact S4 (E1 trong repo + E2 ngoài repo), mỗi artifact đủ 3 trường mục S4.
5. Tra bảng ngưỡng từng signal → sao từng signal → `star = min`.
6. Ghi 1 row: `module | deps_in | in+out | RATIO | N_E | loc | PLM | S1★..S5★ | star | evidence file:line | (demoted-by-cap nếu có)`.

---

# PART II — BẢNG CHẤM (nguyên văn reports/gm-08-stars.md)

# GM-08 — STARS (MERGED) — toàn universe 66 module (apache/kafka)

- Task: `goldmine-spec--sr_merge--ef360255` | MERGE RANK (joinPolicy all) — lần chạy 2+: các part/status gm-08 đã có → gộp lại theo status mới nhất (File: briefs/sr_merge--ef360255.md | Dòng: 2-4).
- **FAIL-CLOSED PASS** — kiểm tra đủ 4/4 file bắt buộc TRƯỚC khi gộp, tất cả tồn tại:
  - Part W1: `reports/gm-08-part-w1.md` — 33 module assignee `w1`, DRAINED (File: reports/gm-08-part-w1.md | Dòng: 314)
  - Part W2: `reports/gm-08-part-w2.md` — 33 module assignee `w2`, DRAINED (File: reports/gm-08-part-w2.md | Dòng: 344)
  - Status W1: `reports/sr-status-w1.json` — 33 entry, toàn bộ `status: "DONE"` (Dòng 2-34)
  - Status W2: `reports/sr-status-w2.json` — 33 entry, toàn bộ `status: "DONE"` (Dòng 2-34)
- Universe: `reports/sr-checklist.json` — 66 module s01→s66 (Dòng 2-67). joinPolicy all: w1 phủ 33 id lẻ (s01…s65), w2 phủ 33 id chẵn (s02…s66), hai tập rời rạc, hợp = **66/66** → đủ MỌI module theo checklist.
- Cây đo chung của 2 part (PLM/S4): cert `aa62a433553c14866521bd40ff446b6920d4d67e` — cùng cây oracle census (File: reports/gm-08-part-w1.md | Dòng: 21-24; File: reports/gm-08-part-w2.md | Dòng: 21-24; File: reports/gm-08-oracles-raw.md | Dòng: 19-37).

## 1. Kiểm tra chéo trước khi gộp (đối chiếu từng dòng, không tin mặc định)

1. **status ↔ part**: 66/66 entry số sao trong `sr-status-w1.json`/`sr-status-w2.json` khớp 100% cột STAR của bảng chấm trong part w1/w2 tương ứng (đối chiếu thủ công từng dòng).
2. **Số oracle**: deps_in/fan/RATIO/loc của 66/66 row khớp nguyên văn `reports/gm-08-oracles.json` (66 item, Dòng 2-67) — đối chiếu từng dòng, 0 lệch.
3. **Sao từng signal**: 66/66 row tra lại ĐÚNG ngưỡng gm-07 — S1 (File: reports/gm-07-rubric.md | Dòng: 35), S2 (Dòng: 41), S3 (Dòng: 55), S4 (Dòng: 65), S5 (Dòng: 83).
4. **star = min(S1..S5)** (File: reports/gm-07-rubric.md | Dòng: 89-99): 66/66 row khớp; không row nào mang "demoted by cap".
5. **Verify cơ học bổ sung**: JSON block mục 4 được script python kiểm lại trong sandbox (`python:3.11-slim`): parse JSON, đếm 66 entry, recompute cả 5 signal từ số oracle theo đúng ngưỡng gm-07, kiểm star=min, đối chiếu universe với `sr-checklist.json` — raw output đính kèm mục 5.

Cột "signal đạt (số từ oracles)" = mức sao từng signal S1–S5 kèm số đo oracle suy ra mức đó: `di`=deps_in (S1) · `fan`=in+out (S2) · `rat`=RATIO (S3) · `loc`+`plm`=PLM (S5) · `ne`=N_E (S4).

## 2. Bảng toàn module (module | sao | signal đạt (số từ oracles) | justification)

| id | module | worker | sao | signal đạt (số từ oracles) | justification |
|---|---|---|---|---|---|
| s01 | clients | w1 | **5** | S1=5 S2=5 S3=5 S4=5 S5=5<br>di=0 · fan=23 · rat=0.4805 · loc=387329 · plm=7031 · ne=2 | S1=5★ vì deps_in=0 — clients là module LÁ của đồ thị phụ thuộc, không import code từ module Kafka nào khác (nguồn: gm-02-module-map.md Dòng 144; oracles.json Dòng 2), đạt ngưỡng ≤2 của gm-07 Dòng 35. S2=5★ vì fan = deps_in 0 + deps_out 23 = 23 ≥ 12 — 23 module khác đứng trên clients (deps_out liệt kê đủ — gm-02-module-map.md Dòng 144; raw audit S2 — gm-08-oracles-raw.md Dòng 1504). S3=5★ vì RATIO = T 186098 / A 387329 = 0.4805 ≥ 0.40 (oracles.json Dòng 2; raw T — gm-08-oracles-raw.md Dòng 144, 1608; testFixtures gồm trong mẫu số theo oracle, không lật ngưỡng). S4=5★ vì N_E=2 có E2 — E1 trong-repo: grep 'class KafkaProducer' với word-boundary ngoài clients = 0 (part w1 mục 2, E1-m01); E2 ngoài-repo: GitHub repo-search + sourcegraph spring-kafka import chứng minh mọi candidate Java đều là wrapper hoặc instrumentation TRÊN NỀN kafka-clients chứ không thay thế (part w1 mục 2, E2-m01); 2 lý do không có OSS thay thế — trong repo không module nào định nghĩa lại client protocol, ngoài repo implementation Java độc lập không tồn tại vì tương đương protocol chỉ có ở Go/C (franz-go, librdkafka). S5=5★ vì loc = 387329 ≥ 20000 ∧ PLM = 7031 ≥ 200 (oracles.json Dòng 2; PLM raw mục 1 part w1 — 7031 method public/protected có logic thật, đã lọc accessor get/set/is/has). star = min(5,5,5,5,5) = 5★ theo công thức min gm-07 Dòng 89-93; trần cap toàn repo {s01, s12} = 2 ≤ 3 (gm-07 Dòng 105-107) → không demote. |
| s02 | streams | w2 | **3** | S1=5 S2=3 S3=5 S4=3 S5=5<br>di=1 · fan=5 · rat=0.5659 · loc=338869 · plm=4177 · ne=0 | S2=3★ chặn — fan 5<8; S1=5 (deps_in 1), S3=5 (0.5659), S5=5 (loc 338869, PLM 4177). |
| s03 | core | w1 | **1** | S1=1 S2=5 S3=5 S4=3 S5=5<br>di=11 · fan=13 · rat=0.7878 · loc=160242 · plm=562 · ne=0 | S1=1★ chặn — deps_in 11≥10 (nhiều nhất w1); S2=5 (fan 13), S3=5 (0.7878), S5=5 (160242/562). |
| s04 | group-coordinator | w2 | **3** | S1=3 S2=4 S3=5 S4=3 S5=5<br>di=5 · fan=10 · rat=0.6517 · loc=142203 · plm=1091 · ne=0 | S1=3★ chặn — deps_in 5 ∈ (4,6]; S2=4 (fan 10), S3=5 (0.6517), S5=5 (142203/1091). |
| s05 | connect/runtime | w1 | **3** | S1=4 S2=3 S3=5 S4=3 S5=5<br>di=4 · fan=6 · rat=0.6088 · loc=104931 · plm=1407 · ne=0 | S2=3★ chặn — fan 6<8; S1=4 (deps_in 4), S3=5 (0.6088), S5=5 (104931/1407). |
| s06 | storage | w2 | **4** | S1=4 S2=4 S3=5 S4=4 S5=5<br>di=3 · fan=10 · rat=0.6247 · loc=73952 · plm=1013 · ne=1 | S1=4 (deps_in 3>2), S2=4 (fan 10<12), S4=4 (chỉ E1 `class UnifiedLog\b` ngoài storage=0, thiếu E2); S3=5 (0.6247), S5=5 (73952/1013). |
| s07 | metadata | w1 | **4** | S1=4 S2=5 S3=5 S4=4 S5=5<br>di=3 · fan=12 · rat=0.5099 · loc=62545 · plm=865 · ne=1 | S1=4 (deps_in 3>2), S4=4 (chỉ E1 `class QuorumController\b` ngoài metadata=0); S2=5 (fan 12), S3=5 (0.5099), S5=5 (62545/865). |
| s08 | tools | w2 | **1** | S1=1 S2=5 S3=5 S4=3 S5=5<br>di=12 · fan=12 · rat=0.5512 · loc=62476 · plm=422 · ne=0 | S1=1★ chặn — deps_in 12≥10; S2=5 (fan 12), S3=5 (0.5512), S5=5 (62476/422). |
| s09 | raft | w1 | **4** | S1=4 S2=4 S3=5 S4=4 S5=5<br>di=3 · fan=9 · rat=0.6275 · loc=55879 · plm=595 · ne=1 | S1=4 (deps_in 3>2), S2=4 (fan 9<12), S4=4 (chỉ E1 `class KafkaRaftClient\b` ngoài raft=0); S3=5 (0.6275), S5=5 (55879/595). |
| s10 | server | w2 | **1** | S1=1 S2=5 S3=5 S4=3 S5=5<br>di=10 · fan=14 · rat=0.5605 · loc=53707 · plm=779 · ne=0 | S1=1★ chặn — deps_in 10≥10; S2=5 (fan 14), S3=5 (0.5605), S5=5 (53707/779). |
| s11 | streams/integration-tests | w1 | **1** | S1=1 S2=5 S3=5 S4=3 S5=1<br>di=12 · fan=12 · rat=1.0 · loc=50779 · plm=0 · ne=0 | S1=1★ (deps_in 12) ∧ S5=1★ (PLM=0 — test-only, không src/main); S2=5 (fan 12), S3=5 (1.0). |
| s12 | server-common | w2 | **5** | S1=5 S2=5 S3=5 S4=5 S5=5<br>di=1 · fan=17 · rat=0.4507 · loc=35932 · plm=825 · ne=2 | S1=5★ vì deps_in gồm đúng 1 phần tử (clients) ≤ 2 — server-common chỉ import code từ clients, là đỉnh gần-lá của đồ thị server-side (nguồn: gm-02-module-map.md Dòng 155; oracles.json Dòng 13), đạt ngưỡng ≤2 của gm-07 Dòng 35. S2=5★ vì fan = deps_in 1 + deps_out 16 = 17 ≥ 12 — fan-out LỚN NHẤT toàn universe, 16 module phụ thuộc gồm metadata, server, raft, tools, storage, group-coordinator, core, coordinator-common, share-coordinator, transaction-coordinator, storage/api, shell, jmh-benchmarks, test-common runtime, test-common internal-api, connect/test-plugins (deps_out liệt kê đủ — gm-02-module-map.md Dòng 155; phân tích cap gm-07 Dòng 105). S3=5★ vì RATIO = 0.4507 ≥ 0.40 (oracles.json Dòng 13; census v9 trên cây cert — gm-08-oracles-raw.md Dòng 77). S4=5★ vì N_E=2 có E2 — E1 trong-repo: grep 'enum MetadataVersion' với word-boundary ngoài server-common = 0 (part w2 mục 2, E1-m12); E2 ngoài-repo: 2 truy vấn sourcegraph fork:yes matchCount=0 cho cả 'enum MetadataVersion' lẫn 'class KafkaEventQueue' cộng GitHub repo-search top-10 'kafka server Java' không có implementation độc lập (part w2 mục 2, E2-m12); 2 lý do không có OSS thay thế — trong repo 16 module khác chỉ import chứ không định nghĩa lại MetadataVersion/KafkaEventQueue, ngoài repo AutoMQ và Confluent Server là fork phái sinh mã nguồn apache/kafka chứ không phải OSS độc lập cung cấp API tương đương. S5=5★ vì loc = 35932 ≥ 20000 ∧ PLM = 825 ≥ 200 (oracles.json Dòng 13; PLM raw mục 1 part w2 — 825 method public/protected có logic thật, đã lọc accessor get/set/is/has; largest file PersisterStateManager 1842 dòng — gm-02-module-map.md Dòng 155). star = min(5,5,5,5,5) = 5★ theo công thức min gm-07 Dòng 89-93; trần cap toàn repo {s01, s12} = 2 ≤ 3 (gm-07 Dòng 105-107) → không demote. |
| s13 | clients/clients-integration-tests | w1 | **1** | S1=1 S2=4 S3=5 S4=3 S5=1<br>di=10 · fan=10 · rat=1.0 · loc=23572 · plm=0 · ne=0 | S1=1★ (deps_in 10) ∧ S5=1★ (PLM=0 — test-only); S2=4 (fan 10), S3=5 (1.0). |
| s14 | trogdor | w2 | **2** | S1=5 S2=2 S3=3 S4=3 S5=4<br>di=2 · fan=2 · rat=0.2019 · loc=19750 · plm=561 · ne=0 | S2=2★ chặn — fan 2; S1=5 (deps_in 2), S3=3 (0.2019<0.25), S5=4 (19750/561). |
| s15 | coordinator-common | w1 | **4** | S1=4 S2=4 S3=5 S4=4 S5=4<br>di=4 · fan=10 · rat=0.6181 · loc=18618 · plm=165 · ne=1 | S5=4★ chặn — loc 18618<20000 (PLM 165≥50); S1=4 (deps_in 4), S2=4 (fan 10), S4=4 (chỉ E1 `class CoordinatorRuntime\b` ngoài coordinator-common=0); S3=5 (0.6181). |
| s16 | connect/api | w2 | **4** | S1=5 S2=4 S3=4 S4=4 S5=4<br>di=1 · fan=9 · rat=0.3834 · loc=13861 · plm=272 · ne=1 | S2=4 (fan 9<12), S3=4 (0.3834<0.40), S5=4 (loc 13861<20000, PLM 272), S4=4 (chỉ E1 `class ConnectRecord\b` ngoài connect/api=0); S1=5 (deps_in 1). |
| s17 | connect/mirror | w1 | **3** | S1=3 S2=3 S3=5 S4=3 S5=4<br>di=5 · fan=5 · rat=0.5285 · loc=13602 · plm=99 · ne=0 | S1=3★ (deps_in 5) ∧ S2=3★ (fan 5) chặn; S3=5 (0.5285), S5=4 (13602/99). |
| s18 | jmh-benchmarks | w2 | **1** | S1=1 S2=5 S3=1 S4=3 S5=4<br>di=16 · fan=16 · rat=0.0 · loc=11699 · plm=291 · ne=0 | S1=1★ (deps_in 16) ∧ S3=1★ (RATIO=0 — benchmark không src/test); S2=5 (fan 16), S5=4 (11699/291). |
| s19 | generator | w1 | **1** | S1=5 S2=1 S3=4 S4=3 S5=4<br>di=0 · fan=0 · rat=0.2591 · loc=11053 · plm=144 · ne=0 | S2=1★ chặn — fan 0≤1 (build-time tool, không ai import); S1=5 (deps_in 0), S3=4 (0.2591), S5=4 (11053/144). |
| s20 | share-coordinator | w2 | **4** | S1=4 S2=4 S3=5 S4=4 S5=4<br>di=4 · fan=8 · rat=0.6348 · loc=9915 · plm=93 · ne=1 | S1=4 (deps_in 4>2), S2=4 (fan 8<12), S5=4 (loc 9915<20000, PLM 93), S4=4 (chỉ E1 `class ShareCoordinatorService\b` ngoài share-coordinator=0); S3=5 (0.6348). |
| s21 | connect/transforms | w1 | **3** | S1=5 S2=3 S3=5 S4=3 S5=4<br>di=2 · fan=5 · rat=0.539 · loc=8950 · plm=222 · ne=0 | S2=3★ chặn — fan 5<8; S1=5 (deps_in 2), S3=5 (0.539), S5=4 (8950/222). |
| s22 | streams/test-utils | w2 | **2** | S1=5 S2=2 S3=5 S4=3 S5=4<br>di=2 · fan=2 · rat=0.5217 · loc=8856 · plm=236 · ne=0 | S2=2★ chặn — fan 2; S1=5 (deps_in 2), S3=5 (0.5217), S5=4 (8856/236). |
| s23 | streams/streams-scala | w1 | **2** | S1=5 S2=2 S3=4 S4=3 S5=4<br>di=2 · fan=2 · rat=0.3682 · loc=6212 · plm=64 · ne=0 | S2=2★ chặn — fan 2; S1=5 (deps_in 2), S3=4 (0.3682<0.40), S5=4 (6212/64 — scala def). |
| s24 | api-checker | w2 | **1** | S1=5 S2=1 S3=5 S4=3 S5=4<br>di=0 · fan=0 · rat=0.4574 · loc=6179 · plm=63 · ne=0 | S2=1★ chặn — fan 0≤1 (build-time tool); S1=5 (deps_in 0), S3=5 (0.4574), S5=4 (6179/63). |
| s25 | test-common/test-common-runtime | w1 | **2** | S1=2 S2=3 S3=3 S4=3 S5=4<br>di=7 · fan=7 · rat=0.2481 · loc=5203 · plm=125 · ne=0 | S1=2★ chặn — deps_in 7≤9; S2=3 (fan 7), S3=3 (0.2481<0.25), S5=4 (5203/125). |
| s26 | transaction-coordinator | w2 | **3** | S1=4 S2=3 S3=5 S4=3 S5=3<br>di=3 · fan=7 · rat=0.4863 · loc=3897 · plm=82 · ne=0 | S2=3★ chặn — fan 7<8; S1=4 (deps_in 3), S3=5 (0.4863), S5=3 (loc 3897<5000, PLM 82). |
| s27 | shell | w1 | **2** | S1=4 S2=2 S3=3 S4=3 S5=3<br>di=4 · fan=4 · rat=0.1794 · loc=3383 · plm=139 · ne=0 | S2=2★ chặn — fan 4; S1=4 (deps_in 4), S3=3 (0.1794<0.25), S5=3 (3383/139). |
| s28 | connect/json | w2 | **3** | S1=5 S2=3 S3=5 S4=3 S5=3<br>di=2 · fan=5 · rat=0.4827 · loc=2308 · plm=24 · ne=0 | S2=3★ chặn — fan 5<8; S1=5 (deps_in 2), S3=5 (0.4827), S5=3 (loc 2308<5000, PLM 24). |
| s29 | storage/api | w1 | **3** | S1=5 S2=3 S3=3 S4=3 S5=3<br>di=2 · fan=5 · rat=0.1299 · loc=2224 · plm=53 · ne=0 | S2=3 (fan 5), S3=3 (0.1299≥0.10), S5=3 (loc 2224, PLM 53 — thuần interface, quy ước gm-07 (b)); S1=5 (deps_in 2). |
| s30 | connect/mirror-client | w2 | **2** | S1=5 S2=2 S3=4 S4=3 S5=3<br>di=1 · fan=2 · rat=0.2904 · loc=1904 · plm=50 · ne=0 | S2=2★ chặn — fan 2; S1=5 (deps_in 1), S3=4 (0.2904<0.40), S5=3 (1904/50). |
| s31 | connect/file | w1 | **2** | S1=5 S2=2 S3=5 S4=3 S5=3<br>di=2 · fan=2 · rat=0.6466 · loc=1698 · plm=24 · ne=0 | S2=2★ chặn — fan 2; S1=5 (deps_in 2), S3=5 (0.6466), S5=3 (1698/24). |
| s32 | streams/examples | w2 | **2** | S1=5 S2=2 S3=4 S4=3 S5=3<br>di=2 · fan=2 · rat=0.3042 · loc=1558 · plm=26 · ne=0 | S2=2★ chặn — fan 2; S1=5 (deps_in 2), S3=4 (0.3042<0.40), S5=3 (1558/26). |
| s33 | streams/upgrade-system-tests-22 | w1 | **1** | S1=5 S2=2 S3=5 S4=3 S5=1<br>di=2 · fan=2 · rat=1.0 · loc=1385 · plm=0 · ne=0 | S5=1★ chặn — PLM=0 (toàn bộ code dưới src/test, không method main có modifier); S1=5, S2=2, S3=5 (1.0), loc 1385≥1000 nhưng PLM<10. |
| s34 | streams/upgrade-system-tests-23 | w2 | **1** | S1=5 S2=2 S3=5 S4=3 S5=1<br>di=2 · fan=2 · rat=1.0 · loc=1364 · plm=0 · ne=0 | S5=1★ chặn — PLM=0 (toàn bộ code dưới src/test); S1=5, S2=2, S3=5 (1.0), loc 1364. |
| s35 | streams/upgrade-system-tests-27 | w1 | **1** | S1=5 S2=2 S3=5 S4=3 S5=1<br>di=2 · fan=2 · rat=1.0 · loc=1331 · plm=0 · ne=0 | S5=1★ chặn — PLM=0 (toàn bộ code dưới src/test); S1=5, S2=2, S3=5 (1.0), loc 1331. |
| s36 | streams/upgrade-system-tests-26 | w2 | **1** | S1=5 S2=2 S3=5 S4=3 S5=1<br>di=2 · fan=2 · rat=1.0 · loc=1320 · plm=0 · ne=0 | S5=1★ chặn — PLM=0 (toàn bộ code dưới src/test); S1=5, S2=2, S3=5 (1.0), loc 1320. |
| s37 | streams/upgrade-system-tests-31 | w1 | **1** | S1=5 S2=2 S3=5 S4=3 S5=1<br>di=2 · fan=2 · rat=1.0 · loc=1320 · plm=0 · ne=0 | S5=1★ chặn — PLM=0 (toàn bộ code dưới src/test); S1=5, S2=2, S3=5 (1.0), loc 1320. |
| s38 | streams/upgrade-system-tests-32 | w2 | **1** | S1=5 S2=2 S3=5 S4=3 S5=1<br>di=2 · fan=2 · rat=1.0 · loc=1320 · plm=0 · ne=0 | S5=1★ chặn — PLM=0 (toàn bộ code dưới src/test); S1=5, S2=2, S3=5 (1.0), loc 1320. |
| s39 | streams/upgrade-system-tests-33 | w1 | **1** | S1=5 S2=2 S3=5 S4=3 S5=1<br>di=2 · fan=2 · rat=1.0 · loc=1320 · plm=0 · ne=0 | S5=1★ chặn — PLM=0 (toàn bộ code dưới src/test); S1=5, S2=2, S3=5 (1.0), loc 1320. |
| s40 | streams/upgrade-system-tests-34 | w2 | **1** | S1=5 S2=2 S3=5 S4=3 S5=1<br>di=2 · fan=2 · rat=1.0 · loc=1320 · plm=0 · ne=0 | S5=1★ chặn — PLM=0 (toàn bộ code dưới src/test); S1=5, S2=2, S3=5 (1.0), loc 1320. |
| s41 | streams/upgrade-system-tests-35 | w1 | **1** | S1=5 S2=2 S3=5 S4=3 S5=1<br>di=2 · fan=2 · rat=1.0 · loc=1320 · plm=0 · ne=0 | S5=1★ chặn — PLM=0 (toàn bộ code dưới src/test); S1=5, S2=2, S3=5 (1.0), loc 1320. |
| s42 | streams/upgrade-system-tests-36 | w2 | **1** | S1=5 S2=2 S3=5 S4=3 S5=1<br>di=2 · fan=2 · rat=1.0 · loc=1320 · plm=0 · ne=0 | S5=1★ chặn — PLM=0 (toàn bộ code dưới src/test); S1=5, S2=2, S3=5 (1.0), loc 1320. |
| s43 | streams/upgrade-system-tests-37 | w1 | **1** | S1=5 S2=2 S3=5 S4=3 S5=1<br>di=2 · fan=2 · rat=1.0 · loc=1320 · plm=0 · ne=0 | S5=1★ chặn — PLM=0 (toàn bộ code dưới src/test); S1=5, S2=2, S3=5 (1.0), loc 1320. |
| s44 | streams/upgrade-system-tests-38 | w2 | **1** | S1=5 S2=2 S3=5 S4=3 S5=1<br>di=2 · fan=2 · rat=1.0 · loc=1320 · plm=0 · ne=0 | S5=1★ chặn — PLM=0 (toàn bộ code dưới src/test); S1=5, S2=2, S3=5 (1.0), loc 1320. |
| s45 | streams/upgrade-system-tests-39 | w1 | **1** | S1=5 S2=2 S3=5 S4=3 S5=1<br>di=2 · fan=2 · rat=1.0 · loc=1320 · plm=0 · ne=0 | S5=1★ chặn — PLM=0 (toàn bộ code dưới src/test); S1=5, S2=2, S3=5 (1.0), loc 1320. |
| s46 | streams/upgrade-system-tests-40 | w2 | **1** | S1=5 S2=2 S3=5 S4=3 S5=1<br>di=2 · fan=2 · rat=1.0 · loc=1320 · plm=0 · ne=0 | S5=1★ chặn — PLM=0 (toàn bộ code dưới src/test); S1=5, S2=2, S3=5 (1.0), loc 1320. |
| s47 | streams/upgrade-system-tests-41 | w1 | **1** | S1=5 S2=2 S3=5 S4=3 S5=1<br>di=2 · fan=2 · rat=1.0 · loc=1320 · plm=0 · ne=0 | S5=1★ chặn — PLM=0 (toàn bộ code dưới src/test); S1=5, S2=2, S3=5 (1.0), loc 1320. |
| s48 | streams/upgrade-system-tests-42 | w2 | **1** | S1=5 S2=2 S3=5 S4=3 S5=1<br>di=2 · fan=2 · rat=1.0 · loc=1320 · plm=0 · ne=0 | S5=1★ chặn — PLM=0 (toàn bộ code dưới src/test); S1=5, S2=2, S3=5 (1.0), loc 1320. |
| s49 | streams/upgrade-system-tests-43 | w1 | **1** | S1=5 S2=2 S3=5 S4=3 S5=1<br>di=2 · fan=2 · rat=1.0 · loc=1320 · plm=0 · ne=0 | S5=1★ chặn — PLM=0 (toàn bộ code dưới src/test); S1=5, S2=2, S3=5 (1.0), loc 1320. |
| s50 | streams/upgrade-system-tests-28 | w2 | **1** | S1=5 S2=2 S3=5 S4=3 S5=1<br>di=2 · fan=2 · rat=1.0 · loc=1319 · plm=0 · ne=0 | S5=1★ chặn — PLM=0 (toàn bộ code dưới src/test); S1=5, S2=2, S3=5 (1.0), loc 1319. |
| s51 | streams/upgrade-system-tests-25 | w1 | **1** | S1=5 S2=2 S3=5 S4=3 S5=1<br>di=2 · fan=2 · rat=1.0 · loc=1318 · plm=0 · ne=0 | S5=1★ chặn — PLM=0 (toàn bộ code dưới src/test); S1=5, S2=2, S3=5 (1.0), loc 1318. |
| s52 | streams/upgrade-system-tests-30 | w2 | **1** | S1=5 S2=2 S3=5 S4=3 S5=1<br>di=2 · fan=2 · rat=1.0 · loc=1318 · plm=0 · ne=0 | S5=1★ chặn — PLM=0 (toàn bộ code dưới src/test); S1=5, S2=2, S3=5 (1.0), loc 1318. |
| s53 | streams/upgrade-system-tests-24 | w1 | **1** | S1=5 S2=2 S3=5 S4=3 S5=1<br>di=2 · fan=2 · rat=1.0 · loc=1317 · plm=0 · ne=0 | S5=1★ chặn — PLM=0 (toàn bộ code dưới src/test); S1=5, S2=2, S3=5 (1.0), loc 1317. |
| s54 | group-coordinator/group-coordinator-api | w2 | **1** | S1=5 S2=2 S3=1 S4=3 S5=3<br>di=1 · fan=4 · rat=0.0 · loc=1292 · plm=20 · ne=0 | S3=1★ chặn — RATIO=0 (không src/test); S1=5 (deps_in 1), S2=2 (fan 4), S5=3 (1292/20 — PLM từ class non-interface). |
| s55 | examples | w1 | **1** | S1=5 S2=1 S3=1 S4=3 S5=3<br>di=1 · fan=1 · rat=0.0 · loc=1216 · plm=26 · ne=0 | S2=1★ (fan 1≤1) ∧ S3=1★ (RATIO=0) chặn; S1=5 (deps_in 1), S5=3 (1216/26). |
| s56 | connect/test-plugins | w2 | **1** | S1=4 S2=2 S3=1 S4=3 S5=3<br>di=3 · fan=3 · rat=0.0 · loc=1157 · plm=66 · ne=0 | S3=1★ chặn — RATIO=0 (plugin test-only cho connect/runtime, không src/test); S1=4 (deps_in 3), S2=2 (fan 3), S5=3 (1157/66). |
| s57 | test-common/test-common-internal-api | w1 | **2** | S1=5 S2=2 S3=3 S4=3 S5=2<br>di=2 · fan=2 · rat=0.2045 · loc=939 · plm=20 · ne=0 | S2=2★ (fan 2) ∧ S5=2★ (loc 939<1000, PLM 20) chặn; S1=5 (deps_in 2), S3=3 (0.2045). |
| s58 | connect/basic-auth-extension | w2 | **2** | S1=5 S2=2 S3=5 S4=3 S5=2<br>di=2 · fan=2 · rat=0.437 · loc=881 · plm=14 · ne=0 | S2=2★ (fan 2) ∧ S5=2★ (loc 881<1000, PLM 14) chặn; S1=5 (deps_in 2), S3=5 (0.437). |
| s59 | test-common/test-common-util | w1 | **1** | S1=5 S2=1 S3=5 S4=3 S5=2<br>di=0 · fan=1 · rat=0.4496 · loc=625 · plm=6 · ne=0 | S2=1★ chặn — fan 1≤1 dù S1=5 (deps_in 0), S3=5 (0.4496); S5=2 (625/6). |
| s60 | tools/tools-api | w2 | **2** | S1=5 S2=2 S3=3 S4=3 S5=2<br>di=1 · fan=2 · rat=0.1245 · loc=265 · plm=3 · ne=0 | S2=2★ (fan 2) ∧ S5=2★ (loc 265, PLM 3 — thuần interface, quy ước gm-07 (b)) chặn; S1=5 (deps_in 1), S3=3 (0.1245). |
| s61 | streams/upgrade-system-tests-10 | w1 | **1** | S1=5 S2=2 S3=5 S4=3 S5=1<br>di=2 · fan=2 · rat=1.0 · loc=232 · plm=0 · ne=0 | S5=1★ chặn — PLM=0 (toàn bộ code dưới src/test); loc 232≥200 nhưng PLM<2; S1=5, S2=2, S3=5. |
| s62 | streams/upgrade-system-tests-11 | w2 | **1** | S1=5 S2=2 S3=5 S4=3 S5=1<br>di=2 · fan=2 · rat=1.0 · loc=232 · plm=0 · ne=0 | S5=1★ chặn — PLM=0 (toàn bộ code dưới src/test); loc 232≥200 nhưng PLM<2; S1=5, S2=2, S3=5. |
| s63 | streams/upgrade-system-tests-20 | w1 | **1** | S1=5 S2=2 S3=5 S4=3 S5=1<br>di=2 · fan=2 · rat=1.0 · loc=221 · plm=0 · ne=0 | S5=1★ chặn — PLM=0 (toàn bộ code dưới src/test); loc 221≥200 nhưng PLM<2; S1=5, S2=2, S3=5. |
| s64 | streams/upgrade-system-tests-21 | w2 | **1** | S1=5 S2=2 S3=5 S4=3 S5=1<br>di=2 · fan=2 · rat=1.0 · loc=221 · plm=0 · ne=0 | S5=1★ chặn — PLM=0 (toàn bộ code dưới src/test); loc 221≥200 nhưng PLM<2; S1=5, S2=2, S3=5. |
| s65 | streams/upgrade-system-tests-0110 | w1 | **1** | S1=5 S2=2 S3=5 S4=3 S5=1<br>di=2 · fan=2 · rat=1.0 · loc=180 · plm=0 · ne=0 | S5=1★ chặn — PLM=0 ∧ loc 180<200; S1=5, S2=2, S3=5 (1.0). |
| s66 | mirror-coordinator | w2 | **1** | S1=5 S2=2 S3=1 S4=3 S5=1<br>di=1 · fan=2 · rat=0.0 · loc=110 · plm=1 · ne=0 | S3=1★ (RATIO=0) ∧ S5=1★ (loc 110<200, PLM 1) chặn; S1=5 (deps_in 1), S2=2 (fan 2). |

Tổng: **5★=2 (s01 clients, s12 server-common) · 4★=6 · 3★=8 · 2★=11 · 1★=39** — tổng 66/66.

**Trần 5 sao ≤ 3 module/repo** (File: reports/gm-07-rubric.md | Dòng: 105-109): số module 5★ = **2 ≤ 3** → điều kiện ">3 module 5 sao" KHÔNG kích hoạt → **không phát CẢNH BÁO "rubric lỏng"**, giữ nguyên mọi sao, không row nào "demoted by cap". Khớp đúng dự báo cấu trúc {m01, m12} của rubric (Dòng: 107).

## 3. JSON block — [{module, stars, signals, justification}] đủ MỌI module theo sr-checklist.json

Schema: mỗi phần tử `{id, module, stars, signals, justification}` — `signals` chứa mức sao S1–S5 + toàn bộ số đo oracle (deps_in, fan, ratio, loc, plm, n_e) + cờ `e2` (có evidence loại E2 — điều kiện 5★ của S4, File: reports/gm-07-rubric.md | Dòng: 65). Trường `id` thêm cho truy vết về checklist (schema brief là minh họa — cùng cách hiểu như part w1 đã kê khai, File: reports/gm-08-part-w1.md | Dòng: 270). Nội dung dưới đây là chính xác chuỗi đã được script python parse + verify (mục 5).

```json
[
{"id":"s01","module":"clients","stars":5,"signals":{"S1":5,"S2":5,"S3":5,"S4":5,"S5":5,"deps_in":0,"fan":23,"ratio":0.4805,"loc":387329,"plm":7031,"n_e":2,"e2":true},"justification":"S1=5★ vì deps_in=0 — clients là module LÁ của đồ thị phụ thuộc, không import code từ module Kafka nào khác (nguồn: gm-02-module-map.md Dòng 144; oracles.json Dòng 2), đạt ngưỡng ≤2 của gm-07 Dòng 35. S2=5★ vì fan = deps_in 0 + deps_out 23 = 23 ≥ 12 — 23 module khác đứng trên clients (deps_out liệt kê đủ — gm-02-module-map.md Dòng 144; raw audit S2 — gm-08-oracles-raw.md Dòng 1504). S3=5★ vì RATIO = T 186098 / A 387329 = 0.4805 ≥ 0.40 (oracles.json Dòng 2; raw T — gm-08-oracles-raw.md Dòng 144, 1608; testFixtures gồm trong mẫu số theo oracle, không lật ngưỡng). S4=5★ vì N_E=2 có E2 — E1 trong-repo: grep 'class KafkaProducer' với word-boundary ngoài clients = 0 (part w1 mục 2, E1-m01); E2 ngoài-repo: GitHub repo-search + sourcegraph spring-kafka import chứng minh mọi candidate Java đều là wrapper hoặc instrumentation TRÊN NỀN kafka-clients chứ không thay thế (part w1 mục 2, E2-m01); 2 lý do không có OSS thay thế — trong repo không module nào định nghĩa lại client protocol, ngoài repo implementation Java độc lập không tồn tại vì tương đương protocol chỉ có ở Go/C (franz-go, librdkafka). S5=5★ vì loc = 387329 ≥ 20000 ∧ PLM = 7031 ≥ 200 (oracles.json Dòng 2; PLM raw mục 1 part w1 — 7031 method public/protected có logic thật, đã lọc accessor get/set/is/has). star = min(5,5,5,5,5) = 5★ theo công thức min gm-07 Dòng 89-93; trần cap toàn repo {s01, s12} = 2 ≤ 3 (gm-07 Dòng 105-107) → không demote."},
{"id":"s02","module":"streams","stars":3,"signals":{"S1":5,"S2":3,"S3":5,"S4":3,"S5":5,"deps_in":1,"fan":5,"ratio":0.5659,"loc":338869,"plm":4177,"n_e":0,"e2":false},"justification":"S2=3★ chặn — fan 5<8; S1=5 (deps_in 1), S3=5 (0.5659), S5=5 (loc 338869, PLM 4177)."},
{"id":"s03","module":"core","stars":1,"signals":{"S1":1,"S2":5,"S3":5,"S4":3,"S5":5,"deps_in":11,"fan":13,"ratio":0.7878,"loc":160242,"plm":562,"n_e":0,"e2":false},"justification":"S1=1★ chặn — deps_in 11≥10 (nhiều nhất w1); S2=5 (fan 13), S3=5 (0.7878), S5=5 (160242/562)."},
{"id":"s04","module":"group-coordinator","stars":3,"signals":{"S1":3,"S2":4,"S3":5,"S4":3,"S5":5,"deps_in":5,"fan":10,"ratio":0.6517,"loc":142203,"plm":1091,"n_e":0,"e2":false},"justification":"S1=3★ chặn — deps_in 5 ∈ (4,6]; S2=4 (fan 10), S3=5 (0.6517), S5=5 (142203/1091)."},
{"id":"s05","module":"connect/runtime","stars":3,"signals":{"S1":4,"S2":3,"S3":5,"S4":3,"S5":5,"deps_in":4,"fan":6,"ratio":0.6088,"loc":104931,"plm":1407,"n_e":0,"e2":false},"justification":"S2=3★ chặn — fan 6<8; S1=4 (deps_in 4), S3=5 (0.6088), S5=5 (104931/1407)."},
{"id":"s06","module":"storage","stars":4,"signals":{"S1":4,"S2":4,"S3":5,"S4":4,"S5":5,"deps_in":3,"fan":10,"ratio":0.6247,"loc":73952,"plm":1013,"n_e":1,"e2":false},"justification":"S1=4 (deps_in 3>2), S2=4 (fan 10<12), S4=4 (chỉ E1 'class UnifiedLog' ngoài storage = 0, thiếu E2); S3=5 (0.6247), S5=5 (73952/1013)."},
{"id":"s07","module":"metadata","stars":4,"signals":{"S1":4,"S2":5,"S3":5,"S4":4,"S5":5,"deps_in":3,"fan":12,"ratio":0.5099,"loc":62545,"plm":865,"n_e":1,"e2":false},"justification":"S1=4 (deps_in 3>2), S4=4 (chỉ E1 'class QuorumController' ngoài metadata = 0); S2=5 (fan 12), S3=5 (0.5099), S5=5 (62545/865)."},
{"id":"s08","module":"tools","stars":1,"signals":{"S1":1,"S2":5,"S3":5,"S4":3,"S5":5,"deps_in":12,"fan":12,"ratio":0.5512,"loc":62476,"plm":422,"n_e":0,"e2":false},"justification":"S1=1★ chặn — deps_in 12≥10; S2=5 (fan 12), S3=5 (0.5512), S5=5 (62476/422)."},
{"id":"s09","module":"raft","stars":4,"signals":{"S1":4,"S2":4,"S3":5,"S4":4,"S5":5,"deps_in":3,"fan":9,"ratio":0.6275,"loc":55879,"plm":595,"n_e":1,"e2":false},"justification":"S1=4 (deps_in 3>2), S2=4 (fan 9<12), S4=4 (chỉ E1 'class KafkaRaftClient' ngoài raft = 0); S3=5 (0.6275), S5=5 (55879/595)."},
{"id":"s10","module":"server","stars":1,"signals":{"S1":1,"S2":5,"S3":5,"S4":3,"S5":5,"deps_in":10,"fan":14,"ratio":0.5605,"loc":53707,"plm":779,"n_e":0,"e2":false},"justification":"S1=1★ chặn — deps_in 10≥10; S2=5 (fan 14), S3=5 (0.5605), S5=5 (53707/779)."},
{"id":"s11","module":"streams/integration-tests","stars":1,"signals":{"S1":1,"S2":5,"S3":5,"S4":3,"S5":1,"deps_in":12,"fan":12,"ratio":1.0,"loc":50779,"plm":0,"n_e":0,"e2":false},"justification":"S1=1★ (deps_in 12) ∧ S5=1★ (PLM=0 — test-only, không src/main); S2=5 (fan 12), S3=5 (1.0)."},
{"id":"s12","module":"server-common","stars":5,"signals":{"S1":5,"S2":5,"S3":5,"S4":5,"S5":5,"deps_in":1,"fan":17,"ratio":0.4507,"loc":35932,"plm":825,"n_e":2,"e2":true},"justification":"S1=5★ vì deps_in gồm đúng 1 phần tử (clients) ≤ 2 — server-common chỉ import code từ clients, là đỉnh gần-lá của đồ thị server-side (nguồn: gm-02-module-map.md Dòng 155; oracles.json Dòng 13), đạt ngưỡng ≤2 của gm-07 Dòng 35. S2=5★ vì fan = deps_in 1 + deps_out 16 = 17 ≥ 12 — fan-out LỚN NHẤT toàn universe, 16 module phụ thuộc gồm metadata, server, raft, tools, storage, group-coordinator, core, coordinator-common, share-coordinator, transaction-coordinator, storage/api, shell, jmh-benchmarks, test-common runtime, test-common internal-api, connect/test-plugins (deps_out liệt kê đủ — gm-02-module-map.md Dòng 155; phân tích cap gm-07 Dòng 105). S3=5★ vì RATIO = 0.4507 ≥ 0.40 (oracles.json Dòng 13; census v9 trên cây cert — gm-08-oracles-raw.md Dòng 77). S4=5★ vì N_E=2 có E2 — E1 trong-repo: grep 'enum MetadataVersion' với word-boundary ngoài server-common = 0 (part w2 mục 2, E1-m12); E2 ngoài-repo: 2 truy vấn sourcegraph fork:yes matchCount=0 cho cả 'enum MetadataVersion' lẫn 'class KafkaEventQueue' cộng GitHub repo-search top-10 'kafka server Java' không có implementation độc lập (part w2 mục 2, E2-m12); 2 lý do không có OSS thay thế — trong repo 16 module khác chỉ import chứ không định nghĩa lại MetadataVersion/KafkaEventQueue, ngoài repo AutoMQ và Confluent Server là fork phái sinh mã nguồn apache/kafka chứ không phải OSS độc lập cung cấp API tương đương. S5=5★ vì loc = 35932 ≥ 20000 ∧ PLM = 825 ≥ 200 (oracles.json Dòng 13; PLM raw mục 1 part w2 — 825 method public/protected có logic thật, đã lọc accessor get/set/is/has; largest file PersisterStateManager 1842 dòng — gm-02-module-map.md Dòng 155). star = min(5,5,5,5,5) = 5★ theo công thức min gm-07 Dòng 89-93; trần cap toàn repo {s01, s12} = 2 ≤ 3 (gm-07 Dòng 105-107) → không demote."},
{"id":"s13","module":"clients/clients-integration-tests","stars":1,"signals":{"S1":1,"S2":4,"S3":5,"S4":3,"S5":1,"deps_in":10,"fan":10,"ratio":1.0,"loc":23572,"plm":0,"n_e":0,"e2":false},"justification":"S1=1★ (deps_in 10) ∧ S5=1★ (PLM=0 — test-only); S2=4 (fan 10), S3=5 (1.0)."},
{"id":"s14","module":"trogdor","stars":2,"signals":{"S1":5,"S2":2,"S3":3,"S4":3,"S5":4,"deps_in":2,"fan":2,"ratio":0.2019,"loc":19750,"plm":561,"n_e":0,"e2":false},"justification":"S2=2★ chặn — fan 2; S1=5 (deps_in 2), S3=3 (0.2019<0.25), S5=4 (19750/561)."},
{"id":"s15","module":"coordinator-common","stars":4,"signals":{"S1":4,"S2":4,"S3":5,"S4":4,"S5":4,"deps_in":4,"fan":10,"ratio":0.6181,"loc":18618,"plm":165,"n_e":1,"e2":false},"justification":"S5=4★ chặn — loc 18618<20000 (PLM 165≥50); S1=4 (deps_in 4), S2=4 (fan 10), S4=4 (chỉ E1 'class CoordinatorRuntime' ngoài coordinator-common = 0); S3=5 (0.6181)."},
{"id":"s16","module":"connect/api","stars":4,"signals":{"S1":5,"S2":4,"S3":4,"S4":4,"S5":4,"deps_in":1,"fan":9,"ratio":0.3834,"loc":13861,"plm":272,"n_e":1,"e2":false},"justification":"S2=4 (fan 9<12), S3=4 (0.3834<0.40), S5=4 (loc 13861<20000, PLM 272), S4=4 (chỉ E1 'class ConnectRecord' ngoài connect/api = 0); S1=5 (deps_in 1)."},
{"id":"s17","module":"connect/mirror","stars":3,"signals":{"S1":3,"S2":3,"S3":5,"S4":3,"S5":4,"deps_in":5,"fan":5,"ratio":0.5285,"loc":13602,"plm":99,"n_e":0,"e2":false},"justification":"S1=3★ (deps_in 5) ∧ S2=3★ (fan 5) chặn; S3=5 (0.5285), S5=4 (13602/99)."},
{"id":"s18","module":"jmh-benchmarks","stars":1,"signals":{"S1":1,"S2":5,"S3":1,"S4":3,"S5":4,"deps_in":16,"fan":16,"ratio":0.0,"loc":11699,"plm":291,"n_e":0,"e2":false},"justification":"S1=1★ (deps_in 16) ∧ S3=1★ (RATIO=0 — benchmark không src/test); S2=5 (fan 16), S5=4 (11699/291)."},
{"id":"s19","module":"generator","stars":1,"signals":{"S1":5,"S2":1,"S3":4,"S4":3,"S5":4,"deps_in":0,"fan":0,"ratio":0.2591,"loc":11053,"plm":144,"n_e":0,"e2":false},"justification":"S2=1★ chặn — fan 0≤1 (build-time tool, không ai import); S1=5 (deps_in 0), S3=4 (0.2591), S5=4 (11053/144)."},
{"id":"s20","module":"share-coordinator","stars":4,"signals":{"S1":4,"S2":4,"S3":5,"S4":4,"S5":4,"deps_in":4,"fan":8,"ratio":0.6348,"loc":9915,"plm":93,"n_e":1,"e2":false},"justification":"S1=4 (deps_in 4>2), S2=4 (fan 8<12), S5=4 (loc 9915<20000, PLM 93), S4=4 (chỉ E1 'class ShareCoordinatorService' ngoài share-coordinator = 0); S3=5 (0.6348)."},
{"id":"s21","module":"connect/transforms","stars":3,"signals":{"S1":5,"S2":3,"S3":5,"S4":3,"S5":4,"deps_in":2,"fan":5,"ratio":0.539,"loc":8950,"plm":222,"n_e":0,"e2":false},"justification":"S2=3★ chặn — fan 5<8; S1=5 (deps_in 2), S3=5 (0.539), S5=4 (8950/222)."},
{"id":"s22","module":"streams/test-utils","stars":2,"signals":{"S1":5,"S2":2,"S3":5,"S4":3,"S5":4,"deps_in":2,"fan":2,"ratio":0.5217,"loc":8856,"plm":236,"n_e":0,"e2":false},"justification":"S2=2★ chặn — fan 2; S1=5 (deps_in 2), S3=5 (0.5217), S5=4 (8856/236)."},
{"id":"s23","module":"streams/streams-scala","stars":2,"signals":{"S1":5,"S2":2,"S3":4,"S4":3,"S5":4,"deps_in":2,"fan":2,"ratio":0.3682,"loc":6212,"plm":64,"n_e":0,"e2":false},"justification":"S2=2★ chặn — fan 2; S1=5 (deps_in 2), S3=4 (0.3682<0.40), S5=4 (6212/64 — scala def)."},
{"id":"s24","module":"api-checker","stars":1,"signals":{"S1":5,"S2":1,"S3":5,"S4":3,"S5":4,"deps_in":0,"fan":0,"ratio":0.4574,"loc":6179,"plm":63,"n_e":0,"e2":false},"justification":"S2=1★ chặn — fan 0≤1 (build-time tool); S1=5 (deps_in 0), S3=5 (0.4574), S5=4 (6179/63)."},
{"id":"s25","module":"test-common/test-common-runtime","stars":2,"signals":{"S1":2,"S2":3,"S3":3,"S4":3,"S5":4,"deps_in":7,"fan":7,"ratio":0.2481,"loc":5203,"plm":125,"n_e":0,"e2":false},"justification":"S1=2★ chặn — deps_in 7≤9; S2=3 (fan 7), S3=3 (0.2481<0.25), S5=4 (5203/125)."},
{"id":"s26","module":"transaction-coordinator","stars":3,"signals":{"S1":4,"S2":3,"S3":5,"S4":3,"S5":3,"deps_in":3,"fan":7,"ratio":0.4863,"loc":3897,"plm":82,"n_e":0,"e2":false},"justification":"S2=3★ chặn — fan 7<8; S1=4 (deps_in 3), S3=5 (0.4863), S5=3 (loc 3897<5000, PLM 82)."},
{"id":"s27","module":"shell","stars":2,"signals":{"S1":4,"S2":2,"S3":3,"S4":3,"S5":3,"deps_in":4,"fan":4,"ratio":0.1794,"loc":3383,"plm":139,"n_e":0,"e2":false},"justification":"S2=2★ chặn — fan 4; S1=4 (deps_in 4), S3=3 (0.1794<0.25), S5=3 (3383/139)."},
{"id":"s28","module":"connect/json","stars":3,"signals":{"S1":5,"S2":3,"S3":5,"S4":3,"S5":3,"deps_in":2,"fan":5,"ratio":0.4827,"loc":2308,"plm":24,"n_e":0,"e2":false},"justification":"S2=3★ chặn — fan 5<8; S1=5 (deps_in 2), S3=5 (0.4827), S5=3 (loc 2308<5000, PLM 24)."},
{"id":"s29","module":"storage/api","stars":3,"signals":{"S1":5,"S2":3,"S3":3,"S4":3,"S5":3,"deps_in":2,"fan":5,"ratio":0.1299,"loc":2224,"plm":53,"n_e":0,"e2":false},"justification":"S2=3 (fan 5), S3=3 (0.1299≥0.10), S5=3 (loc 2224, PLM 53 — thuần interface, quy ước gm-07 (b)); S1=5 (deps_in 2)."},
{"id":"s30","module":"connect/mirror-client","stars":2,"signals":{"S1":5,"S2":2,"S3":4,"S4":3,"S5":3,"deps_in":1,"fan":2,"ratio":0.2904,"loc":1904,"plm":50,"n_e":0,"e2":false},"justification":"S2=2★ chặn — fan 2; S1=5 (deps_in 1), S3=4 (0.2904<0.40), S5=3 (1904/50)."},
{"id":"s31","module":"connect/file","stars":2,"signals":{"S1":5,"S2":2,"S3":5,"S4":3,"S5":3,"deps_in":2,"fan":2,"ratio":0.6466,"loc":1698,"plm":24,"n_e":0,"e2":false},"justification":"S2=2★ chặn — fan 2; S1=5 (deps_in 2), S3=5 (0.6466), S5=3 (1698/24)."},
{"id":"s32","module":"streams/examples","stars":2,"signals":{"S1":5,"S2":2,"S3":4,"S4":3,"S5":3,"deps_in":2,"fan":2,"ratio":0.3042,"loc":1558,"plm":26,"n_e":0,"e2":false},"justification":"S2=2★ chặn — fan 2; S1=5 (deps_in 2), S3=4 (0.3042<0.40), S5=3 (1558/26)."},
{"id":"s33","module":"streams/upgrade-system-tests-22","stars":1,"signals":{"S1":5,"S2":2,"S3":5,"S4":3,"S5":1,"deps_in":2,"fan":2,"ratio":1.0,"loc":1385,"plm":0,"n_e":0,"e2":false},"justification":"S5=1★ chặn — PLM=0 (toàn bộ code dưới src/test, không method main có modifier); S1=5, S2=2, S3=5 (1.0), loc 1385≥1000 nhưng PLM<10."},
{"id":"s34","module":"streams/upgrade-system-tests-23","stars":1,"signals":{"S1":5,"S2":2,"S3":5,"S4":3,"S5":1,"deps_in":2,"fan":2,"ratio":1.0,"loc":1364,"plm":0,"n_e":0,"e2":false},"justification":"S5=1★ chặn — PLM=0 (toàn bộ code dưới src/test); S1=5, S2=2, S3=5 (1.0), loc 1364."},
{"id":"s35","module":"streams/upgrade-system-tests-27","stars":1,"signals":{"S1":5,"S2":2,"S3":5,"S4":3,"S5":1,"deps_in":2,"fan":2,"ratio":1.0,"loc":1331,"plm":0,"n_e":0,"e2":false},"justification":"S5=1★ chặn — PLM=0 (toàn bộ code dưới src/test); S1=5, S2=2, S3=5 (1.0), loc 1331."},
{"id":"s36","module":"streams/upgrade-system-tests-26","stars":1,"signals":{"S1":5,"S2":2,"S3":5,"S4":3,"S5":1,"deps_in":2,"fan":2,"ratio":1.0,"loc":1320,"plm":0,"n_e":0,"e2":false},"justification":"S5=1★ chặn — PLM=0 (toàn bộ code dưới src/test); S1=5, S2=2, S3=5 (1.0), loc 1320."},
{"id":"s37","module":"streams/upgrade-system-tests-31","stars":1,"signals":{"S1":5,"S2":2,"S3":5,"S4":3,"S5":1,"deps_in":2,"fan":2,"ratio":1.0,"loc":1320,"plm":0,"n_e":0,"e2":false},"justification":"S5=1★ chặn — PLM=0 (toàn bộ code dưới src/test); S1=5, S2=2, S3=5 (1.0), loc 1320."},
{"id":"s38","module":"streams/upgrade-system-tests-32","stars":1,"signals":{"S1":5,"S2":2,"S3":5,"S4":3,"S5":1,"deps_in":2,"fan":2,"ratio":1.0,"loc":1320,"plm":0,"n_e":0,"e2":false},"justification":"S5=1★ chặn — PLM=0 (toàn bộ code dưới src/test); S1=5, S2=2, S3=5 (1.0), loc 1320."},
{"id":"s39","module":"streams/upgrade-system-tests-33","stars":1,"signals":{"S1":5,"S2":2,"S3":5,"S4":3,"S5":1,"deps_in":2,"fan":2,"ratio":1.0,"loc":1320,"plm":0,"n_e":0,"e2":false},"justification":"S5=1★ chặn — PLM=0 (toàn bộ code dưới src/test); S1=5, S2=2, S3=5 (1.0), loc 1320."},
{"id":"s40","module":"streams/upgrade-system-tests-34","stars":1,"signals":{"S1":5,"S2":2,"S3":5,"S4":3,"S5":1,"deps_in":2,"fan":2,"ratio":1.0,"loc":1320,"plm":0,"n_e":0,"e2":false},"justification":"S5=1★ chặn — PLM=0 (toàn bộ code dưới src/test); S1=5, S2=2, S3=5 (1.0), loc 1320."},
{"id":"s41","module":"streams/upgrade-system-tests-35","stars":1,"signals":{"S1":5,"S2":2,"S3":5,"S4":3,"S5":1,"deps_in":2,"fan":2,"ratio":1.0,"loc":1320,"plm":0,"n_e":0,"e2":false},"justification":"S5=1★ chặn — PLM=0 (toàn bộ code dưới src/test); S1=5, S2=2, S3=5 (1.0), loc 1320."},
{"id":"s42","module":"streams/upgrade-system-tests-36","stars":1,"signals":{"S1":5,"S2":2,"S3":5,"S4":3,"S5":1,"deps_in":2,"fan":2,"ratio":1.0,"loc":1320,"plm":0,"n_e":0,"e2":false},"justification":"S5=1★ chặn — PLM=0 (toàn bộ code dưới src/test); S1=5, S2=2, S3=5 (1.0), loc 1320."},
{"id":"s43","module":"streams/upgrade-system-tests-37","stars":1,"signals":{"S1":5,"S2":2,"S3":5,"S4":3,"S5":1,"deps_in":2,"fan":2,"ratio":1.0,"loc":1320,"plm":0,"n_e":0,"e2":false},"justification":"S5=1★ chặn — PLM=0 (toàn bộ code dưới src/test); S1=5, S2=2, S3=5 (1.0), loc 1320."},
{"id":"s44","module":"streams/upgrade-system-tests-38","stars":1,"signals":{"S1":5,"S2":2,"S3":5,"S4":3,"S5":1,"deps_in":2,"fan":2,"ratio":1.0,"loc":1320,"plm":0,"n_e":0,"e2":false},"justification":"S5=1★ chặn — PLM=0 (toàn bộ code dưới src/test); S1=5, S2=2, S3=5 (1.0), loc 1320."},
{"id":"s45","module":"streams/upgrade-system-tests-39","stars":1,"signals":{"S1":5,"S2":2,"S3":5,"S4":3,"S5":1,"deps_in":2,"fan":2,"ratio":1.0,"loc":1320,"plm":0,"n_e":0,"e2":false},"justification":"S5=1★ chặn — PLM=0 (toàn bộ code dưới src/test); S1=5, S2=2, S3=5 (1.0), loc 1320."},
{"id":"s46","module":"streams/upgrade-system-tests-40","stars":1,"signals":{"S1":5,"S2":2,"S3":5,"S4":3,"S5":1,"deps_in":2,"fan":2,"ratio":1.0,"loc":1320,"plm":0,"n_e":0,"e2":false},"justification":"S5=1★ chặn — PLM=0 (toàn bộ code dưới src/test); S1=5, S2=2, S3=5 (1.0), loc 1320."},
{"id":"s47","module":"streams/upgrade-system-tests-41","stars":1,"signals":{"S1":5,"S2":2,"S3":5,"S4":3,"S5":1,"deps_in":2,"fan":2,"ratio":1.0,"loc":1320,"plm":0,"n_e":0,"e2":false},"justification":"S5=1★ chặn — PLM=0 (toàn bộ code dưới src/test); S1=5, S2=2, S3=5 (1.0), loc 1320."},
{"id":"s48","module":"streams/upgrade-system-tests-42","stars":1,"signals":{"S1":5,"S2":2,"S3":5,"S4":3,"S5":1,"deps_in":2,"fan":2,"ratio":1.0,"loc":1320,"plm":0,"n_e":0,"e2":false},"justification":"S5=1★ chặn — PLM=0 (toàn bộ code dưới src/test); S1=5, S2=2, S3=5 (1.0), loc 1320."},
{"id":"s49","module":"streams/upgrade-system-tests-43","stars":1,"signals":{"S1":5,"S2":2,"S3":5,"S4":3,"S5":1,"deps_in":2,"fan":2,"ratio":1.0,"loc":1320,"plm":0,"n_e":0,"e2":false},"justification":"S5=1★ chặn — PLM=0 (toàn bộ code dưới src/test); S1=5, S2=2, S3=5 (1.0), loc 1320."},
{"id":"s50","module":"streams/upgrade-system-tests-28","stars":1,"signals":{"S1":5,"S2":2,"S3":5,"S4":3,"S5":1,"deps_in":2,"fan":2,"ratio":1.0,"loc":1319,"plm":0,"n_e":0,"e2":false},"justification":"S5=1★ chặn — PLM=0 (toàn bộ code dưới src/test); S1=5, S2=2, S3=5 (1.0), loc 1319."},
{"id":"s51","module":"streams/upgrade-system-tests-25","stars":1,"signals":{"S1":5,"S2":2,"S3":5,"S4":3,"S5":1,"deps_in":2,"fan":2,"ratio":1.0,"loc":1318,"plm":0,"n_e":0,"e2":false},"justification":"S5=1★ chặn — PLM=0 (toàn bộ code dưới src/test); S1=5, S2=2, S3=5 (1.0), loc 1318."},
{"id":"s52","module":"streams/upgrade-system-tests-30","stars":1,"signals":{"S1":5,"S2":2,"S3":5,"S4":3,"S5":1,"deps_in":2,"fan":2,"ratio":1.0,"loc":1318,"plm":0,"n_e":0,"e2":false},"justification":"S5=1★ chặn — PLM=0 (toàn bộ code dưới src/test); S1=5, S2=2, S3=5 (1.0), loc 1318."},
{"id":"s53","module":"streams/upgrade-system-tests-24","stars":1,"signals":{"S1":5,"S2":2,"S3":5,"S4":3,"S5":1,"deps_in":2,"fan":2,"ratio":1.0,"loc":1317,"plm":0,"n_e":0,"e2":false},"justification":"S5=1★ chặn — PLM=0 (toàn bộ code dưới src/test); S1=5, S2=2, S3=5 (1.0), loc 1317."},
{"id":"s54","module":"group-coordinator/group-coordinator-api","stars":1,"signals":{"S1":5,"S2":2,"S3":1,"S4":3,"S5":3,"deps_in":1,"fan":4,"ratio":0.0,"loc":1292,"plm":20,"n_e":0,"e2":false},"justification":"S3=1★ chặn — RATIO=0 (không src/test); S1=5 (deps_in 1), S2=2 (fan 4), S5=3 (1292/20 — PLM từ class non-interface)."},
{"id":"s55","module":"examples","stars":1,"signals":{"S1":5,"S2":1,"S3":1,"S4":3,"S5":3,"deps_in":1,"fan":1,"ratio":0.0,"loc":1216,"plm":26,"n_e":0,"e2":false},"justification":"S2=1★ (fan 1≤1) ∧ S3=1★ (RATIO=0) chặn; S1=5 (deps_in 1), S5=3 (1216/26)."},
{"id":"s56","module":"connect/test-plugins","stars":1,"signals":{"S1":4,"S2":2,"S3":1,"S4":3,"S5":3,"deps_in":3,"fan":3,"ratio":0.0,"loc":1157,"plm":66,"n_e":0,"e2":false},"justification":"S3=1★ chặn — RATIO=0 (plugin test-only cho connect/runtime, không src/test); S1=4 (deps_in 3), S2=2 (fan 3), S5=3 (1157/66)."},
{"id":"s57","module":"test-common/test-common-internal-api","stars":2,"signals":{"S1":5,"S2":2,"S3":3,"S4":3,"S5":2,"deps_in":2,"fan":2,"ratio":0.2045,"loc":939,"plm":20,"n_e":0,"e2":false},"justification":"S2=2★ (fan 2) ∧ S5=2★ (loc 939<1000, PLM 20) chặn; S1=5 (deps_in 2), S3=3 (0.2045)."},
{"id":"s58","module":"connect/basic-auth-extension","stars":2,"signals":{"S1":5,"S2":2,"S3":5,"S4":3,"S5":2,"deps_in":2,"fan":2,"ratio":0.437,"loc":881,"plm":14,"n_e":0,"e2":false},"justification":"S2=2★ (fan 2) ∧ S5=2★ (loc 881<1000, PLM 14) chặn; S1=5 (deps_in 2), S3=5 (0.437)."},
{"id":"s59","module":"test-common/test-common-util","stars":1,"signals":{"S1":5,"S2":1,"S3":5,"S4":3,"S5":2,"deps_in":0,"fan":1,"ratio":0.4496,"loc":625,"plm":6,"n_e":0,"e2":false},"justification":"S2=1★ chặn — fan 1≤1 dù S1=5 (deps_in 0), S3=5 (0.4496); S5=2 (625/6)."},
{"id":"s60","module":"tools/tools-api","stars":2,"signals":{"S1":5,"S2":2,"S3":3,"S4":3,"S5":2,"deps_in":1,"fan":2,"ratio":0.1245,"loc":265,"plm":3,"n_e":0,"e2":false},"justification":"S2=2★ (fan 2) ∧ S5=2★ (loc 265, PLM 3 — thuần interface, quy ước gm-07 (b)) chặn; S1=5 (deps_in 1), S3=3 (0.1245)."},
{"id":"s61","module":"streams/upgrade-system-tests-10","stars":1,"signals":{"S1":5,"S2":2,"S3":5,"S4":3,"S5":1,"deps_in":2,"fan":2,"ratio":1.0,"loc":232,"plm":0,"n_e":0,"e2":false},"justification":"S5=1★ chặn — PLM=0 (toàn bộ code dưới src/test); loc 232≥200 nhưng PLM<2; S1=5, S2=2, S3=5."},
{"id":"s62","module":"streams/upgrade-system-tests-11","stars":1,"signals":{"S1":5,"S2":2,"S3":5,"S4":3,"S5":1,"deps_in":2,"fan":2,"ratio":1.0,"loc":232,"plm":0,"n_e":0,"e2":false},"justification":"S5=1★ chặn — PLM=0 (toàn bộ code dưới src/test); loc 232≥200 nhưng PLM<2; S1=5, S2=2, S3=5."},
{"id":"s63","module":"streams/upgrade-system-tests-20","stars":1,"signals":{"S1":5,"S2":2,"S3":5,"S4":3,"S5":1,"deps_in":2,"fan":2,"ratio":1.0,"loc":221,"plm":0,"n_e":0,"e2":false},"justification":"S5=1★ chặn — PLM=0 (toàn bộ code dưới src/test); loc 221≥200 nhưng PLM<2; S1=5, S2=2, S3=5."},
{"id":"s64","module":"streams/upgrade-system-tests-21","stars":1,"signals":{"S1":5,"S2":2,"S3":5,"S4":3,"S5":1,"deps_in":2,"fan":2,"ratio":1.0,"loc":221,"plm":0,"n_e":0,"e2":false},"justification":"S5=1★ chặn — PLM=0 (toàn bộ code dưới src/test); loc 221≥200 nhưng PLM<2; S1=5, S2=2, S3=5."},
{"id":"s65","module":"streams/upgrade-system-tests-0110","stars":1,"signals":{"S1":5,"S2":2,"S3":5,"S4":3,"S5":1,"deps_in":2,"fan":2,"ratio":1.0,"loc":180,"plm":0,"n_e":0,"e2":false},"justification":"S5=1★ chặn — PLM=0 ∧ loc 180<200; S1=5, S2=2, S3=5 (1.0)."},
{"id":"s66","module":"mirror-coordinator","stars":1,"signals":{"S1":5,"S2":2,"S3":1,"S4":3,"S5":1,"deps_in":1,"fan":2,"ratio":0.0,"loc":110,"plm":1,"n_e":0,"e2":false},"justification":"S3=1★ (RATIO=0) ∧ S5=1★ (loc 110<200, PLM 1) chặn; S1=5 (deps_in 1), S2=2 (fan 2)."}
]
```

## 4. Raw output — verify cơ học (python 3, sandbox `python:3.11-slim`, session `sess-e5242dc0`)

Script: parse `stars.json` (chuỗi JSON y hệt mục 3) → đếm entry → với MỖI module recompute S1–S5 từ số oracle theo đúng ngưỡng gm-07 (S1: File: reports/gm-07-rubric.md | Dòng: 35; S2: Dòng 41; S3: Dòng 55; S4: Dòng 65; S5: Dòng 83) → kiểm star=min(S1..S5) (Dòng: 89-99) → đối chiếu universe với `sr-checklist.json` → cảnh báo nếu 5★ > 3.

```
$ cd /workspace && python3 check.py
DIST 5/4/3/2/1 = 2 6 8 11 39
TOTAL = 66
TRAN 5-SAO OK: 2 <= 3
OK: JSON parse + 66/66 module dung theo checklist + moi signal dung nguong gm-07 + star = min(S1..S5)
[sandbox_shell] exit=0
```

## 5. Nguồn & caveats kế thừa (merge KHÔNG đo lại số nào mới)

1. **Nguồn số**: số oracle (deps_in/fan/ratio/loc) chép từ `reports/gm-08-oracles.json` (Dòng 2-67) qua 2 part; PLM và N_E do worker đo/lập trên cây cert `aa62a433…` (File: reports/gm-08-part-w1.md | Dòng: 24; File: reports/gm-08-part-w2.md | Dòng: 24). Nhiệm vụ node này là MERGE RANK — gộp + verify nhất quán, không đo mới.
2. **PLM đo bằng lệnh ĐÃ SỬA**: lệnh literal S5 của gm-07 có 2 bug đã kê khai (regex POSIX `\]` match 0 dòng; đếm lặp theo thư mục tổ tiên — File: reports/gm-08-part-w1.md | Dòng: 28-44); w2 dùng lại đúng lệnh ngữ nghĩa, sanity anchor KafkaProducer.java = 26 khớp giữa 2 worker trên cùng cây (File: reports/gm-08-part-w2.md | Dòng: 43, 292) → số PLM so sánh được giữa 2 part.
3. **N_E chỉ lập cho 8 module trần ≥4★** (w1: s01/s07/s09/s15 — File: reports/gm-08-part-w1.md | Dòng: 88, 170; w2: s06/s12/s16/s20 — File: reports/gm-08-part-w2.md | Dòng: 89, 191); 58 module còn lại N_E=0 → S4=3★ sàn, không thể hạ module trần ≤3★ (S4 không dùng ở 2★/1★ — File: reports/gm-07-rubric.md | Dòng: 65).
4. **E2 là phán quyết đọc raw output** — điểm mờ duy nhất của rubric (File: reports/gm-07-rubric.md | Dòng: 66); raw E2 dán nguyên văn trong part w1 (Dòng: 140-168, module s01) và part w2 (Dòng: 143-189, module s12) để reviewer đối chiếu. Hai module 5★ duy nhất (s01, s12) đều có E2 — điều kiện "≥1 E2" của S4 5★ thỏa.
5. **s3_testratio ghi theo đúng giá trị oracle**, không đo lại (quy ước parts — File: reports/gm-08-oracles-raw.md | Dòng: 1680-1681); testFixtures nằm trong mẫu số T theo pattern oracle (caveat kế thừa, không lật ngưỡng nào — File: reports/gm-08-part-w1.md | Dòng: 271).
6. **S4 5★ yêu cầu E2**: JSON có cờ `e2` để máy kiểm điều kiện "N_E ≥ 2 ∧ ≥1 E2" (File: reports/gm-07-rubric.md | Dòng: 65) — chỉ s01 và s12 mang `e2:true`, khớp part w1 mục E2-m01 (Dòng: 140) và part w2 mục E2-m12 (Dòng: 143).

---

**MERGED** — `gm-08-stars.md` gộp xong: bảng 66/66 module (module | sao | signal đạt kèm số oracle | justification) + JSON block máy-đọc 66/66 theo `sr-checklist.json`. Trần 5★ = 2 ≤ 3 → không cảnh báo rubric lỏng. Verify cơ học PASS (mục 4). Trạng thái worker: `sr-status-w1.json` + `sr-status-w2.json` — 66/66 DONE.
