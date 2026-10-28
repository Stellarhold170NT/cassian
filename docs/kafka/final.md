# GM-FINAL — TỔNG HỢP BỘ TÀI LIỆU GOLDMINE (apache/kafka → đề xuất repo mỏ "cassian")

Task: `goldmine-spec--goldmine_bundle--ef360255` | Lần chạy: **1** (`reports/gm-final.md` chưa tồn tại trước đó → viết mới, không INHERITED).
INPUT: toàn bộ `reports/gm-*` hiện hữu (17 file — glob kiểm chứng); brief: `briefs/goldmine_bundle--ef360255.md`.

> ⚠️ **GHI RÕ (bắt buộc theo brief — File: briefs/goldmine_bundle--ef360255.md | Dòng: 24-25):** TOÀN BỘ nội dung dưới đây là **ĐỀ XUẤT (PROPOSAL)** cho repo mỏ. Không có gì được đẩy lên GitHub trong node này; **node publish** (node sau) mới đẩy docs lên `Stellarhold170NT/cassian` (repo đã xác nhận TRỐNG 4 lần bằng `ls-remote` — File: reports/gm-01-cartography.md | Dòng: 769 | Nội dung: `"cassian_target_status": "VERIFIED-EMPTY (ls-remote exit 0, stdout rỗng — xác nhận lại lần 4 tại RUN 4)"`). Token chỉ xuất hiện dạng placeholder `{GH_TOKEN}` — không có giá trị thật trong file nào.

---

## 0. FAIL-CLOSED — tài liệu gm-* THIẾU (ghi thiếu, không bịa)

Glob `reports/gm-*` toàn workspace (17 file) đối chiếu dải gm-01→gm-10:

| Kỳ vọng | File thật | Trạng thái |
|---|---|---|
| gm-01 | `gm-01-cartography.md` | CÓ |
| gm-02 | `gm-02-module-map.md` (+ 4 part `gm-02-part-w1..w4.md`) | CÓ |
| gm-03 | — | **THIẾU** — không có file nào; được node khác tham chiếu là "gate-consistency đối chiếu chéo" (File: reports/gm-04-overview.md | Dòng: 4 | Nội dung: "KHÔNG đọc gm-03 (gate-consistency đối chiếu chéo — trùng lệch là lỗi của node này)") và node b-overview kê khai "không tồn tại tại thời điểm làm + brief cấm" (File: reports/b-overview--ef360255.md | Dòng: 7) |
| gm-04 | `gm-04-overview.md` | CÓ |
| gm-05 | — | **THIẾU** — không có file, không có brief tương ứng trong `briefs/` |
| gm-06 | `gm-06-flows.md` | CÓ |
| gm-07 | `gm-07-rubric.md` | CÓ |
| gm-08 | `gm-08-stars.md`, `gm-08-oracles.json`, `gm-08-oracles-raw.md`, `gm-08-part-w1.md`, `gm-08-part-w2.md` | CÓ |
| gm-09 (slot A) | — | **THIẾU** — `gm-09a-plan.md` (plan cắt cho `clients`, thứ tự #1) không tồn tại; đã được node slot B kê khai trước (File: reports/gm-09b-plan.md | Dòng: 4 | Nội dung: "brief Dòng 6 yêu cầu 'Quy trình GIỐNG slot A' nhưng `reports/gm-09a-plan.md` chưa tồn tại tại thời điểm node này chạy") |
| gm-09 (slot B) | `gm-09b-plan.md` | CÓ |
| gm-10 | — | **THIẾU** — không có file, không có brief tương ứng |
| Phụ trợ | `gm-checklist.json`, `gm-template-row.md` | CÓ |

Hệ quả: các mục 2 (bảng sao) và 3 (extraction plans) dưới đây chỉ phủ những gì có thật — sao 66/66 module ĐỦ (khối sao không phụ thuộc gm-09a), còn extraction plan chỉ có **slot B (server-common)**; slot A (clients) ghi thiếu.

## 1. Index bộ tài liệu + verdict từng gate

### 1a. Index artifact gm-* của chain `ef360255`

| Artifact | Node sản xuất | Nội dung lõi |
|---|---|---|
| `gm-01-cartography.md` | bootstrap (RUN 4, NO-INHERIT) | Cartography apache/kafka tại sha **`aa62a433553c14866521bd40ff446b6920d4d67e`** (KAFKA-20866 #23749): LICENSE gate ĐẠT, census v9 java 6.283 file / **1.604.486 dòng** (+42 so HEAD cũ), scala 134.077 / py 32.772 / sh 2.537, settings.gradle **65 module** + includeBuild `api-checker`, 19 entrypoint Java + broker main Scala `Kafka.scala:73`, 33 top-dir, repo cassian VERIFIED-EMPTY (File: reports/gm-01-cartography.md | Dòng: 319-789) |
| `gm-02-module-map.md` (+4 part) | mm_scan → mm_w1..w4 → mm_merge | Bản đồ 66 module (m01→m66): path, responsibility, main_files, deps_in/out, loc, tests; tổng universe **6542 file / 1.738.689 LOC** (File: reports/mm_scan--ef360255.md | Dòng: 90 | Nội dung: "IN_UNIVERSE_SUM files=6542 loc=1738689"); JSON block 66 object schema 10 field |
| `gm-04-overview.md` | b-overview (stream B) | Overview 12 mục: Kafka là gì (5 câu), nắm 5 phút, C4 L1/L2/L3 (mermaid), bản đồ thư mục theo vùng, lệnh chạy/test thật, 10 điểm mở rộng SPI, 8 rủi ro tái sử dụng (File: reports/gm-04-overview.md | Dòng: 11-246) |
| `gm-06-flows.md` | d-flows (stream D) | Top-3 luồng đắt giá theo công thức Score = Σ(fan) + Σ(churn): **D-Streams pipeline 4477 > B-Consumer-group KIP-848 3524 > C-KRaft metadata write 3337**; sequenceDiagram truy vết file:line từng bước trên cây `3655d7c` (File: reports/gm-06-flows.md | Dòng: 100, 117-239) |
| `gm-07-rubric.md` | star_rubric | Rubric 5 signal (S1 deps_in / S2 fan / S3 test-ratio / S4 distinctiveness / S5 loc+PLM), ngưỡng số cứng từng sao, star = min, trần 5★ ≤ 3 module/repo (File: reports/gm-07-rubric.md | Dòng: 35, 41, 55, 65, 83, 89-99, 105-109) |
| `gm-08-oracles.json` + `gm-08-oracles-raw.md` | sr_check | Số oracle 66 module: s1_deps, s2_fan, s3_testratio, s5_loc (s4 null — PLM/N_E do worker đo) + raw census/audit 1685 dòng |
| `gm-08-part-w1.md`, `gm-08-part-w2.md` | sr_w1, sr_w2 | Chấm 33+33 module: PLM (lệnh đã sửa 2 bug của oracle literal) + N_E/E2 cho 8 module trần ≥4★, đo trên cây cert `aa62a433` |
| `gm-08-stars.md` | sr_merge (MERGE) | Bảng sao 66/66 module + JSON block 66 entry `{module, stars, signals, justification}`; phân bố **5★=2 · 4★=6 · 3★=8 · 2★=11 · 1★=39**; verify cơ học python PASS (File: reports/gm-08-stars.md | Dòng: 93, 176-183) |
| `gm-09b-plan.md` | ex_b (slot B) | Plan cắt `server-common` (5★ #2): cut inventory 8 hạng mục, recipe trim root build.gradle, 7 lệnh cắt + 7 gate G1–G7 fail-closed (CHỈ LÀ PLAN — chưa cắt, chưa push) |
| `gm-checklist.json` | mm_scan | Checklist 66 item (id/module/path/files/loc/assignee, status để trống theo thiết kế) |
| `gm-template-row.md` | spec-writer + mm_scan | Template row bắt buộc cho worker + worked example m03 + bảng path_extra |

### 1b. Verdict từng gate (reviewer độc lập, chain `ef360255`)

| Gate | Node bị review | Vòng 1 | Vòng 2 | Ghi chú |
|---|---|---|---|---|
| gate-map | mm_merge (gm-02) | **APPROVED 5/5** (File: reports/gate-map--r1--ef360255.md | Dòng: 1, 35) | **APPROVED 5/5** (File: reports/gate-map--r2--ef360255.md | Dòng: 1, 35) | Gate tự parse JSON gm-02 bằng parser thật lần đầu, census v9 66/66 đo lại trên cây cert khớp tuyệt đối, spot-check cộng dồn 5 cycle = 20/66 item 0 bịa |
| b-gate | b-overview (gm-04) | **APPROVED** (File: reports/b-gate--r1--ef360255.md | Dòng: 1) | **APPROVED** (File: reports/b-gate--r2--ef360255.md | Dòng: 1) | r1 spot-check ~55/65 claim (~80%); r2 duyệt phần fix |
| d-gate | d-flows (gm-06) | **APPROVED** (File: reports/d-gate--r1--ef360255.md | Dòng: 1) | **APPROVED** (File: reports/d-gate--r2--ef360255.md | Dòng: 1) | Reviewer re-run churn khớp 20/20 dòng, re-tính score khớp 5/5 (D=4477, B=3524, C=3337, A=3174, E=2994) |
| gate-stars | sr_merge (gm-08) | **CHANGES_REQUESTED** (File: reports/gate-stars--r1--ef360255.md | Dòng: 1 | Nội dung: "justification của 2/2 module 5★ … chỉ có 1 câu … thay vì ≥5 câu có evidence → đòn") | **APPROVED** (File: reports/gate-stars--r2--ef360255.md | Dòng: 1) | Fix = nới justification 4 cell 5★ lên ≥5 câu, không đụng số sao/oracle |
| (bootstrap) | gm-01 | — | — | Node đầu chuỗi, không có gate riêng trong briefs; trạng thái DONE theo report (File: reports/bootstrap--ef360255.md | Dòng: 3) |
| (star_rubric) | gm-07 | — | — | Artifact tự kê trạng thái **DRAFT — chờ gate, không tự phong FROZEN** (File: reports/gm-07-rubric.md | Dòng: 5); rubric được vận hành và thẩm định gián tiếp qua gate-stars |

### 1c. Hai khối checklist — số item DONE/UNOWNED

| Khối checklist | Số item | DONE | UNOWNED | Bằng chứng |
|---|---|---|---|---|
| **Khối 1 — `gm-checklist.json`** (module map) | 66 | **66/66 (100%)** | **0/66 (0%) ≤ 30%** | Union 4 file status = 66 id khớp tuyệt đối checklist, mọi entry DONE kèm evidence file:line (File: reports/mm_merge--ef360255.md | Dòng: 25); gate xác nhận `UNOWNED_COUNT=0, UNOWNED_PCT=0.0%` (File: reports/gate-map--r1--ef360255.md | Dòng: 149) |
| **Khối 2 — `sr-checklist.json`** (stars) | 66 | **66/66 (100%)** | **0/66 (0%)** | sr-status-w1.json 33 entry DONE (File: reports/sr-status-w1.json | Dòng: 2-34) + sr-status-w2.json 33 entry DONE (File: reports/sr-status-w2.json | Dòng: 2-34) = 66/66; gate-stars duyệt trừ tập hợp PASS r1/r2 (File: reports/gate-stars--r1--ef360255.md | Dòng: 15; reports/gate-stars--r2--ef360255.md | Dòng: 5) |

## 2. Bảng sao module (66/66, nguồn `gm-08-stars.md`)

Cột "chặn bởi" = signal giữ module ở mức sao đó (số oracle: di=deps_in, fan=in+out, rat=RATIO, loc, plm=PLM, ne=N_E).

| id | module | sao | chặn bởi |
|---|---|---|---|
| s01 | clients | **5★** | — (di=0 · fan=23 · rat=0.4805 · loc=387329 · plm=7031 · ne=2, có E2) |
| s02 | streams | 3★ | S2 (fan 5<8) |
| s03 | core | 1★ | S1 (di 11≥10) |
| s04 | group-coordinator | 3★ | S1 (di 5) |
| s05 | connect/runtime | 3★ | S2 (fan 6<8) |
| s06 | storage | 4★ | S1 (di 3), S2 (fan 10), S4 (ne=1, thiếu E2) |
| s07 | metadata | 4★ | S1 (di 3), S4 (ne=1) |
| s08 | tools | 1★ | S1 (di 12) |
| s09 | raft | 4★ | S1 (di 3), S2 (fan 9), S4 (ne=1) |
| s10 | server | 1★ | S1 (di 10) |
| s11 | streams/integration-tests | 1★ | S1 (di 12) ∧ S5 (plm=0, test-only) |
| s12 | server-common | **5★** | — (di=1 · fan=17 · rat=0.4507 · loc=35932 · plm=825 · ne=2, có E2) |
| s13 | clients/clients-integration-tests | 1★ | S1 (di 10) ∧ S5 (plm=0) |
| s14 | trogdor | 2★ | S2 (fan 2) |
| s15 | coordinator-common | 4★ | S5 (loc 18618<20000) |
| s16 | connect/api | 4★ | S2 (fan 9), S3 (0.3834<0.40), S5 (loc 13861), S4 (ne=1) |
| s17 | connect/mirror | 3★ | S1 (di 5) ∧ S2 (fan 5) |
| s18 | jmh-benchmarks | 1★ | S1 (di 16) ∧ S3 (rat=0) |
| s19 | generator | 1★ | S2 (fan 0) |
| s20 | share-coordinator | 4★ | S1 (di 4), S2 (fan 8), S5 (loc 9915), S4 (ne=1) |
| s21 | connect/transforms | 3★ | S2 (fan 5) |
| s22 | streams/test-utils | 2★ | S2 (fan 2) |
| s23 | streams/streams-scala | 2★ | S2 (fan 2) |
| s24 | api-checker | 1★ | S2 (fan 0) |
| s25 | test-common/test-common-runtime | 2★ | S1 (di 7) |
| s26 | transaction-coordinator | 3★ | S2 (fan 7) |
| s27 | shell | 2★ | S2 (fan 4) |
| s28 | connect/json | 3★ | S2 (fan 5) |
| s29 | storage/api | 3★ | min đạt 3 (S2 fan 5, S3 0.1299, S5 loc 2224 — module thuần interface) |
| s30 | connect/mirror-client | 2★ | S2 (fan 2) |
| s31 | connect/file | 2★ | S2 (fan 2) |
| s32 | streams/examples | 2★ | S2 (fan 2) |
| s33 | streams/upgrade-system-tests-22 | 1★ | S5 (plm=0, test-only) |
| s34 | streams/upgrade-system-tests-23 | 1★ | S5 (plm=0) |
| s35 | streams/upgrade-system-tests-27 | 1★ | S5 (plm=0) |
| s36 | streams/upgrade-system-tests-26 | 1★ | S5 (plm=0) |
| s37 | streams/upgrade-system-tests-31 | 1★ | S5 (plm=0) |
| s38 | streams/upgrade-system-tests-32 | 1★ | S5 (plm=0) |
| s39 | streams/upgrade-system-tests-33 | 1★ | S5 (plm=0) |
| s40 | streams/upgrade-system-tests-34 | 1★ | S5 (plm=0) |
| s41 | streams/upgrade-system-tests-35 | 1★ | S5 (plm=0) |
| s42 | streams/upgrade-system-tests-36 | 1★ | S5 (plm=0) |
| s43 | streams/upgrade-system-tests-37 | 1★ | S5 (plm=0) |
| s44 | streams/upgrade-system-tests-38 | 1★ | S5 (plm=0) |
| s45 | streams/upgrade-system-tests-39 | 1★ | S5 (plm=0) |
| s46 | streams/upgrade-system-tests-40 | 1★ | S5 (plm=0) |
| s47 | streams/upgrade-system-tests-41 | 1★ | S5 (plm=0) |
| s48 | streams/upgrade-system-tests-42 | 1★ | S5 (plm=0) |
| s49 | streams/upgrade-system-tests-43 | 1★ | S5 (plm=0) |
| s50 | streams/upgrade-system-tests-28 | 1★ | S5 (plm=0) |
| s51 | streams/upgrade-system-tests-25 | 1★ | S5 (plm=0) |
| s52 | streams/upgrade-system-tests-30 | 1★ | S5 (plm=0) |
| s53 | streams/upgrade-system-tests-24 | 1★ | S5 (plm=0) |
| s54 | group-coordinator/group-coordinator-api | 1★ | S3 (rat=0) |
| s55 | examples | 1★ | S2 (fan 1) ∧ S3 (rat=0) |
| s56 | connect/test-plugins | 1★ | S3 (rat=0) |
| s57 | test-common/test-common-internal-api | 2★ | S2 (fan 2) ∧ S5 (loc 939<1000) |
| s58 | connect/basic-auth-extension | 2★ | S2 (fan 2) ∧ S5 (loc 881<1000) |
| s59 | test-common/test-common-util | 1★ | S2 (fan 1) |
| s60 | tools/tools-api | 2★ | S2 (fan 2) ∧ S5 (loc 265) |
| s61 | streams/upgrade-system-tests-10 | 1★ | S5 (plm=0) |
| s62 | streams/upgrade-system-tests-11 | 1★ | S5 (plm=0) |
| s63 | streams/upgrade-system-tests-20 | 1★ | S5 (plm=0) |
| s64 | streams/upgrade-system-tests-21 | 1★ | S5 (plm=0) |
| s65 | streams/upgrade-system-tests-0110 | 1★ | S5 (plm=0 ∧ loc 180<200) |
| s66 | mirror-coordinator | 1★ | S3 (rat=0) ∧ S5 (loc 110<200, plm=1) |

**Phân bố: 5★=2 (clients, server-common) · 4★=6 · 3★=8 · 2★=11 · 1★=39 — tổng 66/66.** Trần 5★ ≤ 3 module/repo: 2 ≤ 3 → không cảnh báo "rubric lỏng", không row nào "demoted by cap" (File: reports/gm-08-stars.md | Dòng: 93-95). Verify cơ học độc lập (python recompute 5 signal từ oracle theo ngưỡng gm-07): PASS 66/66 (File: reports/gm-08-stars.md | Dòng: 176-183).

## 3. Extraction plans — tóm tắt

### 3a. Slot B — `server-common` (gm-09b, THIẾU slot A — xem mục 0)

- **Chọn module:** thứ tự #2 trong tập ≥4★ = s12 `server-common` (5★). Slot A lẽ ra lấy #1 (clients) — **plan slot A không tồn tại** (File: reports/gm-09b-plan.md | Dòng: 4, 27).
- **Fact đã verify tươi trên cây `601492157a7e…`** (trunk lại di chuyển so cert `aa62a433`): deps_in={clients}, fan=17, RATIO=0.4507 (T=16195/A=35932), loc=35932, files=211, PLM=825, entry `MetadataVersion.java:47`, largest `PersisterStateManager.java` 1842 — **mọi số khớp cert → 5★ tái khẳng định** (File: reports/gm-09b-plan.md | Dòng: 35-48).
- **Phát hiện kiến trúc mới:** tại HEAD mới **không còn module nào có `build.gradle` riêng** (chỉ api-checker) — cấu hình 65 module nằm tập trung trong root `build.gradle` 4451 dòng; block `:server-common` tại Dòng 2410–2477 → kế hoạch cắt phải kèm scaffolding (File: reports/gm-09b-plan.md | Dòng: 52-59).
- **Cut inventory (8 hạng mục):** `server-common/` (212 tracked file), `settings.gradle`, root `build.gradle` (trim theo recipe), `gradle/` (dependencies.gradle, spotbugs-exclude, wrapper 9.8.2) + `gradlew`, `gradle.properties`, `checkstyle/` (23 file, bắt buộc `import-control-server-common.xml`), `LICENSE`+`NOTICE`, INPUT `clients/` từ slot A (File: reports/gm-09b-plan.md | Dòng: 61-74).
- **Gates G1–G7 (fail-closed, bất kỳ FAIL → không push):** G1 pin đúng cây; G2 census 211/35932 (±0); G3 RATIO=0.4507 (±0.0005); G4 PLM=825 (±0); G5 deps_in == {clients}; G6 `:server-common:compileJava` exit 0 (option A); G7 license + import-control tồn tại (File: reports/gm-09b-plan.md | Dòng: 93-105).
- **Quy trình 7 bước ngoài-run:** 0) chốt PIN bằng `ls-remote`; 1) clone + checkout PIN; 2) gate LICENSE; 3) staging copy; 4) trim build (option A) hoặc source-only (option B fallback); 5) gate build; 6) gate test; 7) kiểm cassian còn TRỐNG → push nhánh riêng `seed/server-common`, không force-push (File: reports/gm-09b-plan.md | Dòng: 80-91).
- **Rủi ro chính:** trunk drift liên tục (3 sha trong 1 ngày: aa62a433 → 3655d7c → 6014921); số dòng block build.gradle đổi theo commit (phải re-derive tại PIN); literal oracle gm-07 có 2 bug đã sửa (regex POSIX + đếm lặp tổ-ancestors); gate build G6 cần JDK 17 không có trong sandbox plan; race repo đích với slot A; testFixtures 872 dòng thuộc mẫu số RATIO theo quy ước oracle (File: reports/gm-09b-plan.md | Dòng: 238-247).

### 3b. Slot A — `clients` (s01, 5★ #1): **THIẾU**

Không có `gm-09a-plan.md`; dữ liệu module có sẵn để lập plan khi chạy lại: stars 5★ (di=0 · fan=23 · rat=0.4805 · loc=387329 · plm=7031 · ne=2 có E2 — File: reports/gm-08-stars.md | Dòng: 26, 103), path `clients/src`, 1879 file. Node kế thừa cần tự dựng plan theo cùng chuẩn G1–G7 của slot B (tiền lệ cấu trúc: File: reports/gm-09b-plan.md | Dòng: 93-105).

## 4. ĐỀ XUẤT repo mỏ "cassian" — cấu trúc cố định

> Toàn bộ mục này là **ĐỀ XUẤT**; node publish sẽ tạo nội dung tương ứng và đẩy lên `Stellarhold170NT/cassian`. **KHÔNG có README.md** trong repo đích (brief: "repo đích phải không README" — File: briefs/goldmine_bundle--ef360255.md | Dòng: 16-17). **Sao nằm trong `matrix.csv`, KHÔNG thành thư mục** (Dòng: 17-18). **Module vào `modules/` PHẢI có `PROVENANCE.md`** (upstream, sha, license, file copy, prune log, re-sync) (Dòng: 17-18). `modules/` là pha P7 — **lần này KHÔNG tạo** (Dòng: 14).

```text
cassian/
├── matrix/matrix.csv          # index tổng (mục 5)
├── docs/kafka/                # 01-cartography … 06-flows, final.md
│   └── 03-c4/                 # workspace.dsl (PlantUML C4), diagrams.mmd (mermaid)
├── specs/kafka/<module>.plan.md   # extraction plan từng module (gm-09*)
├── modules/kafka/<module>/    # P7 — lần này KHÔNG tạo; khi có PHẢI kèm PROVENANCE.md
└── tracking/kafka.md          # last-check, sha pin, churn (mục 6)
```

Ánh xạ tài liệu có sẵn → slot đề xuất (sao chép nguyên văn, không viết mới tại node publish):

| Slot cassian | Nguồn workspace | Ghi chú |
|---|---|---|
| `docs/kafka/01-cartography.md` | `reports/gm-01-cartography.md` | Giữ nguyên RUN 1–4 làm lịch sử; số liệu chuẩn hành = RUN 4 |
| `docs/kafka/02-module-map.md` | `reports/gm-02-module-map.md` | Kèm JSON 66 object |
| `docs/kafka/03-c4/workspace.dsl` + `03-c4/diagrams.mmd` | `reports/gm-04-overview.md` mục 3–5 | Node publish phải chuyển 3 sơ đồ mermaid C4 (L1 context / L2 container / L3 component) thành workspace.dsl + giữ diagrams.mmd — nội dung DSL **chưa tồn tại**, cần viết khi publish (đề xuất) |
| `docs/kafka/04-…` (phan đầu…05-stars) | `reports/gm-04-overview.md`, `gm-06-flows.md`, `gm-07-rubric.md` + `gm-08-stars.md` | Đánh số 01…06 giữ theo thứ tự chuỗi pipeline; `final.md` = chính file gm-final này |
| `specs/kafka/server-common.plan.md` | `reports/gm-09b-plan.md` | Có thật |
| `specs/kafka/clients.plan.md` | — | **Thiếu** (slot A) — chỉ tạo khi plan A được sản xuất |
| `modules/kafka/<module>/` | — | KHÔNG tạo lần này (P7); mỗi module sau này cần `PROVENANCE.md`: upstream repo, sha pin, license (Apache-2.0 + NOTICE), danh sách file copy, prune log, quy trình re-sync |
| `matrix/matrix.csv` | mẫu ở mục 5 | Index tổng — nơi duy nhất chứa cột stars |
| `tracking/kafka.md` | sinh bởi cron mục 6 | last-check, sha pin, churn |

## 5. matrix.csv mẫu (ĐỀ XUẤT)

Header đúng brief (File: briefs/goldmine_bundle--ef360255.md | Dòng: 19-20): `project,module,stars,upstream_repo,upstream_sha,license,docs_link,path_in_goldmine`.

```csv
project,module,stars,upstream_repo,upstream_sha,license,docs_link,path_in_goldmine
kafka,clients,5,https://github.com/apache/kafka,aa62a433553c14866521bd40ff446b6920d4d67e,Apache-2.0,docs/kafka/01-cartography.md,specs/kafka/clients.plan.md
kafka,server-common,5,https://github.com/apache/kafka,aa62a433553c14866521bd40ff446b6920d4d67e,Apache-2.0,docs/kafka/01-cartography.md,specs/kafka/server-common.plan.md
kafka,storage,4,https://github.com/apache/kafka,aa62a433553c14866521bd40ff446b6920d4d67e,Apache-2.0,docs/kafka/01-cartography.md,specs/kafka/storage.plan.md
kafka,metadata,4,https://github.com/apache/kafka,aa62a433553c14866521bd40ff446b6920d4d67e,Apache-2.0,docs/kafka/01-cartography.md,specs/kafka/metadata.plan.md
kafka,raft,4,https://github.com/apache/kafka,aa62a433553c14866521bd40ff446b6920d4d67e,Apache-2.0,docs/kafka/01-cartography.md,specs/kafka/raft.plan.md
kafka,coordinator-common,4,https://github.com/apache/kafka,aa62a433553c14866521bd40ff446b6920d4d67e,Apache-2.0,docs/kafka/01-cartography.md,specs/kafka/coordinator-common.plan.md
kafka,connect/api,4,https://github.com/apache/kafka,aa62a433553c14866521bd40ff446b6920d4d67e,Apache-2.0,docs/kafka/01-cartography.md,specs/kafka/connect-api.plan.md
kafka,share-coordinator,4,https://github.com/apache/kafka,aa62a433553c14866521bd40ff446b6920d4d67e,Apache-2.0,docs/kafka/01-cartography.md,specs/kafka/share-coordinator.plan.md
```

Quy ước đề xuất: 66 dòng (mỗi module 1 dòng, cả 66 đều có stars từ khối sao); `upstream_sha` = sha pin tại thời điểm đo (hiện cert `aa62a433…`); `path_in_goldmine` chỉ trỏ `specs/` khi plan tồn tại (hiện chỉ server-common), module chưa có plan để trống; `modules/kafka/<module>/` chỉ xuất hiện ở cột này sau khi cắt thật (P7, kèm PROVENANCE.md). License lấy từ gate LICENSE của gm-01 (Apache-2.0 — File: reports/gm-01-cartography.md | Dòng: 353-361).

## 6. Kế hoạch tracking upstream (ĐỀ XUẤT)

Mục tiêu: cron định kỳ so **pinned SHA** (cột `upstream_sha` của matrix.csv) với **HEAD upstream**, xuất thống kê markdown + badge stale vào `tracking/kafka.md`.

Quy trình đề xuất:
1. Đọc `matrix/matrix.csv`, lấy tập (upstream_repo, upstream_sha) duy nhất theo project.
2. `git ls-remote <upstream_repo> refs/heads/trunk` → HEAD hiện tại; so với pin: **FRESH** nếu bằng, **STALE** nếu khác (kèm khoảng cách mô tả: không resolve commit vì chỉ ls-remote — ghi "HEAD moved").
3. Append/xuất lại `tracking/kafka.md`: bảng `project | pinned_sha | head_now | state (FRESH/STALE) | last-check (UTC)` + dòng badge đầu file: `![upstream](https://img.shields.io/badge/upstream-STALE-red)` hoặc `...-FRESH-green`.
4. Churn tracking (kèm theo, lấy từ chuỗi đo hiện có): số dòng java của repo là chỉ số drift nhạy đã chứng minh (+42 dòng java tại m01 chỉ vì 1 commit — File: reports/mm_scan--ef360255.md | Dòng: 111); node tracking sau có thể chạy lại census v9 cho module pin để định lượng drift từng module.
5. Chính sách xử lý STALE: không tự re-measure trong cron — mở issue/đánh dấu, chờ orchestrator quyết định re-cert (đúng chu trình scan → worker → merge đã vận hành ở chain này).

Workflow mẫu (GitHub Actions, cron hằng ngày — **ĐỀ XUẤT**, token chỉ dạng placeholder `{GH_TOKEN}`):

```yaml
name: upstream-tracking
on:
  schedule:
    - cron: "17 3 * * *"   # hằng ngày 03:17 UTC
  workflow_dispatch: {}

permissions:
  contents: write

jobs:
  check-pinned-sha:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          token: ${{ secrets.GH_TOKEN }}   # placeholder — cấu hình secret {GH_TOKEN} trên repo
      - name: Compare pinned SHA vs upstream HEAD
        env:
          GH_TOKEN: ${{ secrets.GH_TOKEN }}   # placeholder {GH_TOKEN} — không hardcode giá trị thật
        run: |
          set -eu
          OUT=tracking/kafka.md
          printf '| project | pinned_sha | head_now | state | last-check (UTC) |\n|---|---|---|---|---|\n' > "$OUT.tmp"
          STATE="FRESH"
          while IFS=, read -r project module stars upstream_repo upstream_sha license docs_link path_in_goldmine; do
            [ "$project" = "project" ] && continue            # skip header
            [ -z "$upstream_repo" ] && continue               # dòng trống
            HEAD_NOW="$(git ls-remote "$upstream_repo" refs/heads/trunk | cut -f1)"
            if [ "$HEAD_NOW" = "$upstream_sha" ]; then STATE="FRESH"; else STATE="STALE"; fi
            printf '| %s | %s | %s | %s | %s |\n' "$project" "$upstream_sha" "${HEAD_NOW:-n/a}" "$STATE" "$(date -u +%Y-%m-%dT%H:%M:%SZ)" >> "$OUT.tmp"
          done < matrix/matrix.csv
          if grep -q "STALE" "$OUT.tmp"; then BADGE="![upstream](https://img.shields.io/badge/upstream-STALE-red)"; else BADGE="![upstream](https://img.shields.io/badge/upstream-FRESH-green)"; fi
          { echo "$BADGE"; echo; cat "$OUT.tmp"; } > "$OUT"
          rm -f "$OUT.tmp"
      - name: Commit tracking report
        run: |
          git config user.name "cassian-tracking"
          git config user.email "tracking@users.noreply.github.com"
          git add tracking/kafka.md
          git diff --cached --quiet || git commit -m "tracking: refresh pinned-sha vs HEAD"
          git push
```

## 7. Kết luận

- Bộ tài liệu gm-01/02/04/06/07/08/09b **đầy đủ, 4 cổng gate độc lập đều APPROVED** (gate-map 2 vòng, b-gate 2 vòng, d-gate 2 vòng, gate-stars vòng 2 sau 1 vòng CHANGES_REQUESTED đã sửa); 2 khối checklist 66/66 DONE, 0 UNOWNED.
- Thiếu (fail-closed, đã kê mục 0): **gm-03, gm-05, gm-09a (slot A), gm-10** — không bịa nội dung thay thế.
- Sản phẩm node này: `reports/gm-final.md` (file này). Node publish kế tiếp mới đẩy nội dung ĐỀ XUẤT lên `Stellarhold170NT/cassian` (repo đang TRỐNG, đã xác nhận 4 lần).
- Việc còn lại cho pipeline: (a) lập plan slot A (`clients`) theo chuẩn G1–G7 của slot B; (b) quyết định bổ sung/xóa node gm-03/gm-05/gm-10 trong orchestrator; (c) tại lần cắt thật: chốt PIN mới bằng ls-remote, re-derive số dòng block build.gradle, chạy gate build G6 với JDK 17; (d) rotate token PAT sau pilot (File: reports/bootstrap--ef360255.md | Dòng: 29).
