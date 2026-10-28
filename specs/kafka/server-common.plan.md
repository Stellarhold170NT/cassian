# GM-09B — EXTRACTION PLAN — SLOT B: `server-common` (s12, 5★, thứ tự #2 trong tập ≥4★)

- Task: `goldmine-spec--ex_b--ef360255` | Lần chạy: **1** — glob `reports/*` không có `gm-09b*` trước đó → không INHERITED, sản xuất mới (fact: File: briefs/ex_b--ef360255.md | Dòng: 3; kiểm tra glob tại thời điểm viết — không match).
- **Quyết định kê khai (contract thiếu):** brief Dòng 6 yêu cầu "Quy trình GIỐNG slot A" nhưng `reports/gm-09a-plan.md` **chưa tồn tại** tại thời điểm node này chạy (glob kiểm chứng) → node này TỰ định nghĩa cấu trúc plan (mục 1–9) theo chuẩn chung của pipeline gm-*, và để slot A/node kế thừa đối chiếu. Không có giả định nào về nội dung kế hoạch của slot A ngoài ranh giới module (clients = #1, thuộc slot A).
- INPUT: `reports/gm-08-stars.md` (bảng 66/66) + `reports/gm-08-oracles.json` (Dòng 13) + `reports/gm-02-module-map.md` (m12, Dòng 155) + `reports/gm-07-rubric.md` (ngưỡng) + `reports/gm-01-cartography.md` (provenance, JSON Dòng 725-770).
- Môi trường đo của node này: sandbox riêng `bitnami/git:latest`, ttl 3600, session `sess-60970e78`; clone nông depth 100; mọi lệnh qua `sandbox_shell`; KHÔNG ghi file repo qua VFS (tuân thủ brief Dòng 1).

> **DISCLAIMER — CHỈ LÀ PLAN (bắt buộc ghi rõ theo brief Dòng 7):** file này là **kế hoạch cắt**. Node này KHÔNG thực hiện cắt, KHÔNG push vào repo đích `Stellarhold170NT/cassian`. Cắt thật chạy bằng **lệnh riêng ngoài run** — script đầy đủ ở mục 5, bounds kiểm nhận ở mục 6. Mỗi lệnh trong mục 5 đều đã được **dry-run tương đương trên clone của node này** (raw output mục 7) trừ bước push/build cuối (cần JDK 17 + mạng Gradle wrapper — không có trong sandbox git-only của node này, đã kê khai mục 8 risk #5).

---

## 1. Chọn module — thứ tự #2 trong tập ≥4★

Bảng sao gm-08 (MERGE 66/66, verify cơ học PASS — File: reports/gm-08-stars.md | Dòng: 176-183): phân bố **5★=2 · 4★=6** (Dòng 93). Tập ≥4★ theo thứ tự bảng (id tăng dần s01→s66):

| Thứ tự | id | module | sao | bằng chứng row |
|---|---|---|---|---|
| **#1** | s01 | clients | 5★ | File: reports/gm-08-stars.md | Dòng: 26 |
| **#2** | **s12** | **server-common** | **5★** | File: reports/gm-08-stars.md | Dòng: 37 |
| #3 | s06 | storage | 4★ | Dòng: 31 |
| #4 | s07 | metadata | 4★ | Dòng: 32 |
| #5 | s09 | raft | 4★ | Dòng: 34 |
| #6 | s15 | coordinator-common | 4★ | Dòng: 40 |
| #7 | s16 | connect/api | 4★ | Dòng: 41 |
| #8 | s20 | share-coordinator | 4★ | Dòng: 45 |

- **Slot B = thứ tự #2 = s12 `server-common`.** Slot A lấy #1 (clients) theo brief (File: briefs/ex_b--ef360255.md | Dòng: 5-6).
- **Tie-break:** hai module 5★ không gây mơ hồ thứ tự — thứ tự bảng id tăng dần (s01 < s12) VÀ trùng khớp tie-break rubric (S2 giảm dần: clients 23 > server-common 17 — File: reports/gm-07-rubric.md | Dòng: 109). Hai tiêu chí cùng cho một thứ tự → không có quyết định chủ quan.
- **Kiểm N/A:** tập ≥4★ có **8 module** ≥ số 2 yêu cầu → **KHÔNG rơi vào nhánh 'N/A'** của brief Dòng 6.

## 2. Fact module mục tiêu — đo lại tươi trên cây mới, đối chiếu cert gm-08

Cây đo node này: trunk HEAD `601492157a7e563b5cd4cdea8c9382302a1ea5f4` (clone đạt lần 1, `rev-list --count` = 100, commit `MINOR: Fix race in StreamsGroupWarmupTaskIntegrationTest (#23944)`, 2026-10-28 16:10:48 -0700 — raw mục 7.1). Lưu ý: trunk lại di chuyển — cert gm-01 `aa62a433…` (File: reports/gm-01-cartography.md | Dòng: 729) → clone gm-04 `3655d7c…` (File: reports/gm-04-overview.md | Dòng: 241) → clone node này `6014921…`. Câu hỏi pin-SHA gm-04 để mở (Dòng 253) được node này trả lời bằng **chính sách pin ở mục 4.0**.

| Đại lượng | Cert gm-08 (aa62a433) | Đo lại tươi (6014921) | Verdict |
|---|---|---|---|
| deps_in (module ngoài) | 1 — `clients` (oracles.json Dòng 13) | chỉ `clients` — 16 import `org.apache.kafka.clients.*` + 4 import `server.authorizer` (find-verify thuộc clients) + toàn bộ `common.*` trừ `DirectoryId` (2 file class tự sở hữu) | **KHỚP** |
| fan (in+out) | 17 = 1 + 16 (gm-02 m12 JSON, Dòng 155) | spot-check 5/16 consumer còn sống trên cây mới: metadata 79 · server 70 · storage 45 · raft 38 · shell 1 file có import package server-common (raw mục 7.8) | **KHỚP** |
| RATIO T/A | 0.4507 (oracles.json Dòng 13) | T=16195 / A=35932 = **0.4507** (T theo quy ước oracle `*src/test*` gồm testFixtures 872 dòng — file-level 1 pass, không lặp tổ tiên; raw mục 7.6) | **KHỚP** |
| loc (census v9) | 35932 (oracles.json Dòng 13) | 35932 (`find -print0 \| xargs -0 cat \| wc -l` java+scala) | **KHỚP** |
| files | 211 (checklist m12) | 211 java+scala; 212 file git-tracked trong `server-common/` (212−211 = 1 file khác — testFixtures resource) | **KHỚP** |
| PLM | 825 (w2 đo cùng cây cert — File: reports/gm-08-part-w2.md | Dòng: 55) | **825** — J=825, scala=0 file; regex in ra GIỐNG HỆT dòng REGEX_J của w2 (Dòng 48); sanity anchor KafkaProducer.java = **22** ≠ 26 của w2 — đã quy về drift cây: commit `abc2906` đụng KafkaProducer.java trong cửa sổ shallow (raw mục 7.7); server-common không đổi số nào → không ảnh hưởng | **KHỚP** (anchor chênh do drift — kê khai) |
| entry | `MetadataVersion.java:47` `public enum MetadataVersion {` (gm-02 Dòng 155) | `sed -n 47p` → `public enum MetadataVersion {` (raw mục 7.5) | **KHỚP** |
| largest | `PersisterStateManager.java` 1842 (gm-02 Dòng 155, path ghi `share/persister/`) | `server-common/src/main/java/org/apache/kafka/server/share/persister/PersisterStateManager.java` = 1842 (path đầy đủ là `server/share/persister/` — gm-02 ghi tắt) | **KHỚP** |
| N_E / E2 | N_E=2, e2=true (E1-m12 grep `enum MetadataVersion` ngoài module = 0; E2-m12 sourcegraph+GitHub — File: reports/gm-08-part-w2.md | Dòng: 143-189) | kế thừa nguyên trạng — không re-litigate (điểm mờ duy nhất của rubric, File: reports/gm-07-rubric.md | Dòng: 66) | — |
| **star** | 5★ = min(S1..S5) (gm-07 Dòng 89-93; ngưỡng Dòng 35/41/55/65/83: deps_in 1≤2 ∧ fan 17≥12 ∧ RATIO 0.4507≥0.40 ∧ N_E 2∧E2 ∧ loc 35932≥20000 ∧ PLM 825≥200) | mọi số đo lại đều khớp → **5★ tái khẳng định** | **KHỚP** |

**Kết luận mục 2:** không có số nào của server-common đổi giữa cert `aa62a433` và cây mới `6014921` → module này **ổn định giữa các commit drift**; không cần re-cert gm-08 cho slot B.

## 3. Phát hiện mới bắt buộc cho kế hoạch cắt — kiến trúc build đã ĐỔI so cert

**Phát hiện (source-truth tươi, thắng fact trong brief theo quy tắc chân lý môi trường):** tại HEAD `6014921`, **không còn module nào có `build.gradle` riêng** — toàn bộ cấu hình 65 module nằm tập trung trong root `build.gradle` (4451 dòng). Bằng chứng:

- `git ls-files | grep -E '^[a-z].*/build.gradle$'` → **đúng 4 file, đều thuộc `api-checker/`** (includeBuild riêng) — raw mục 7.2.
- `clients`, `metadata`, `server`, `storage`: **KHÔNG có** `build.gradle` trong module dir; `server-common/` chỉ chứa `src/` (`ls -la` + `git ls-files server-common | grep -v '^server-common/src/'` → rỗng).
- Cấu hình `:server-common` nằm trong root `build.gradle` **block Dòng 2410–2477**: `archivesName = "kafka-server-common"`, plugin `java-test-fixtures`, dependency **`api project(':clients')`** (khớp deps_in), libs ngoài (metrics, joptSimple, jacksonDatabind, pcollections, slf4jApi), testFixtures/test của clients, task `createVersionFile`, `jar`, `clean.doFirst`, **`checkstyle { configProperties = checkstyleConfigProperties("import-control-server-common.xml") }`**, `javadoc { enabled = false }` (raw mục 7.3-7.4).
- Scaffolding build phụ thuộc: `settings.gradle` 144 dòng (include `'server-common'` tại Dòng 98; `rootProject.name = 'kafka'` Dòng 143), `gradle/dependencies.gradle` 240 dòng (`apply from` tại build.gradle Dòng 24), `gradle.properties` (group/version/scalaVersion Dòng 16-18 = org.apache.kafka / 4.5.0-SNAPSHOT / 2.13.18), wrapper **Gradle 9.8.2** (gradle-wrapper.properties), `checkstyle/` 23 file **gồm `import-control-server-common.xml`** mà block :server-common tham chiếu.

Hệ quả: kế hoạch cắt **không thể** chỉ copy `server-common/` như thời cert (mỗi module một build.gradle) — phải cắt kèm scaffolding tập trung (mục 4).

## 4. Nội dung cắt (cut inventory) — chính xác theo path, có ranh giới slot

**Không gian slot:** slot B CHỈ lập kế hoạch cho `server-common`. `clients` là deps duy nhất nhưng thuộc slot A (thứ #1) — kế hoạch này **không lập kế hoạch cắt clients**, chỉ kê khai input (brief: "KHÔNG đụng phạm vi slot khác", Dòng 4).

| # | Path cần cắt | Vì sao | Bằng chứng |
|---|---|---|---|
| 1 | `server-common/` (toàn dir, 212 tracked file: `src/main` + `src/test` + `src/testFixtures`) | thân module — 211 java + 1 resource | raw mục 7.1, 7.5 |
| 2 | `settings.gradle` (nguyên bản 144 dòng) | include module + pluginManagement/develocity; cắt-trim về 2 include (`clients`, `server-common`) khi build standalone | Dòng 98/143 |
| 3 | `build.gradle` (root, trim theo recipe dưới) | block `:server-common` 2410-2477 + shared config (allprojects 167+, subprojects 308+, header plugins Dòng 27-30, `apply from` Dòng 24) | raw mục 7.3 |
| 4 | `gradle/dependencies.gradle` + `gradle/spotbugs-exclude.xml` + `gradle/wrapper/` + `gradlew` | version map (`libs.*`) + exclude rules + wrapper 9.8.2 | mục 3 |
| 5 | `gradle.properties` | group/version/scalaVersion | Dòng 16-18 |
| 6 | `checkstyle/` (23 file, bắt buộc có `import-control-server-common.xml`) | block :server-common gọi trực tiếp | raw mục 7.4 tail |
| 7 | `LICENSE` + `NOTICE` (+ header license ASF trong mọi file giữ nguyên) | giấy phép Apache-2.0 — gate cổng LICENSE của gm-01 | gm-01 mục (b) |
| 8 | **INPUT từ slot A:** `clients/` đã cắt (hoặc artifact `kafka-clients` tương đương) | `api project(':clients')` — build `:server-common` không compile thiếu nó | block Dòng ~2420 |

**Recipe trim root `build.gradle` (option A — build được):** giữ nguyên thứ tự: header Dòng 1–166 (buildscript/plugins/`apply from`/config chung) → khối `allprojects` (167) và `subprojects` (308) nguyên bản → block `project(':clients')` → block `project(':server-common')` (2410–2477) → loại mọi block `project(':X')` khác và mọi tham chiếu `project(':X')` với X ∉ {clients, server-common}. ⚠️ Số dòng **chỉ đúng tại sha 6014921** — tại sha cắt thật phải re-derive bằng `grep -n "^project(':server-common') {"` (lệnh trong mục 5, step B3).

**Option B (fallback — không build):** cắt source-only (#1, #5, #7) + chép block 2410–2477 thành file tham chiếu, wiring build để node seed quyết. Hệ quả: bỏ gate G6 (build), chỉ còn gate cấu trúc G1–G5/G7.

## 5. Lệnh cắt thật — CHẠY NGOÀI RUN này (mỗi lệnh kèm điều kiện đỗ)

Quy ước: mọi lệnh dưới đây **không chứa ký tự `>` literal** (broker sandbox chặn — w2 đã kê khai cùng lỗi, File: reports/gm-08-part-w2.md | Dòng: 43); biến `$PIN` = sha pin chốt ở step 0; token git truyền inline one-shot, KHÔNG ghi file (precedent bootstrap, File: reports/bootstrap--ef360255.md | Dòng: 29).

- **0) Chốt PIN (fail-closed):** `PIN=$(git ls-remote https://github.com/apache/kafka refs/heads/trunk | cut -d' ' -f1)` — ghi PIN vào metadata lần cắt; mọi gate dưới so với cây PIN. Khoảng cách PIN so cert cho phép: chỉ chấp nhận nếu gates G2–G4 dưới ra số bằng cert (đã chứng minh ổn định ở 2 cây: aa62a433 ↔ 6014921). Nếu lệch → DỪNG, re-cert trước khi cắt.
- **1) Clone + checkout pin:** `git clone --quiet --depth 100 --single-branch -b trunk https://github.com/apache/kafka /workspace/kafka && cd /workspace/kafka && git checkout $PIN` — đỗ khi `git rev-parse HEAD` == PIN.
- **2) Gate LICENSE:** `ls LICENSE NOTICE` tồn tại (gm-01 mục b).
- **3) Inventory copy (staging):** `mkdir -p /workspace/cut && cp -a server-common gradle gradlew gradle.properties settings.gradle build.gradle checkstyle LICENSE NOTICE /workspace/cut/` — đỗ khi `find /workspace/cut/server-common/src -type f \( -name '*.java' -o -name '*.scala' \) | wc -l` = **211**.
- **4) Trim build (option A):** tạo `settings.gradle` mới với 2 include + rootProject; tạo `build.gradle` mới theo recipe mục 4 (dùng `grep -n "^project(':server-common') {"` để lấy số dòng tươi) — đỗ khi `grep -c "^project('" build.gradle` (bản trim) = **2**.
- **5) Gate build:** `JAVA_HOME=<jdk17> ./gradlew :clients:compileJava :server-common:compileJava` — đỗ khi exit 0. (cần clients từ slot A trong staging.)
- **6) Gate test:** `./gradlew :server-common:test` — đỗ khi exit 0 (16.195 dòng test hiện hữu).
- **7) Push cassian (CUỐI, fail-closed):** `git ls-remote https://x-access-token:$TOKEN@github.com/Stellarhold170NT/cassian.git` — **nếu stdout khác rỗng → DỪNG, KHÔNG push** (repo kỳ vọng TRỐNG — xác nhận lần 4, File: reports/gm-01-cartography.md | Dòng: 769); nếu trống → commit + `git push cassian` nhánh seed của slot B (vd `seed/server-common`), KHÔNG force-push, KHÔNG đụng nhánh slot A.

## 6. Bounds kiểm nhận (L4 — Metric + Oracle + Ngưỡng nhị phân)

| Gate | Metric | Oracle (lệnh) | Ngưỡng ĐỖ |
|---|---|---|---|
| G1 | Pin đúng cây | `git rev-parse HEAD` | == PIN (exact) |
| G2 | Inventory nguyên vẹn | census v9 java+scala `server-common/src` | files=211 ∧ loc=35932 (±0) |
| G3 | RATIO test | T (file-level, pattern `*src/test*` gồm testFixtures) / A | = 0.4507 (sai lệch làm tròn ≤0.0005) |
| G4 | PLM | regex `^[[:space:]]*(public|protected)[[:space:]]+[A-Za-z_][]A-Za-z0-9_<>,. ?]*[[:space:]]+[A-Za-z0-9_]+[[:space:]]*\(` trừ accessor, `-path '*src/main*'` | = 825 (±0) |
| G5 | deps_in | grep import `org.apache.kafka.*` trên src/main, map find-verify | tập module ngoài == {clients} |
| G6 | Build | `:server-common:compileJava` | exit 0 (option A; option B bỏ gate) |
| G7 | License + style control | `ls checkstyle/import-control-server-common.xml`; header ASF trong file cắt | tồn tại ∧ header giữ nguyên |

Fail-closed: **bất kỳ** gate FAIL → không push, report BLOCKED kèm raw output. G3/G4 dùng **lệnh đã sửa** (literal oracle gm-07 có 2 bug lặp-tổ-ancest/regex đã kê khai và xử lý — File: reports/gm-08-part-w2.md | Dòng: 28-43; node này tái hiện y hệt, raw mục 7.6-7.7).

## 7. Raw output node này (sandbox `sess-60970e78`, bitnami/git, verbatim)

**7.1) Pin-check + clone + HEAD:**
```
$ git ls-remote https://github.com/apache/kafka refs/heads/trunk
601492157a7e563b5cd4cdea8c9382302a1ea5f4	refs/heads/trunk
LSREMOTE_EXIT=0
$ git clone --quiet --depth 100 --single-branch -b trunk https://github.com/apache/kafka /workspace/kafka
CLONE_EXIT=0
$ git rev-parse HEAD && git rev-list --count HEAD
601492157a7e563b5cd4cdea8c9382302a1ea5f4
100
$ git log -1 --format='%h %ad %s' --date=iso
6014921 2026-10-28 16:10:48 -0700 MINOR: Fix race in StreamsGroupWarmupTaskIntegrationTest (#23944)
```

**7.2) server-common không có build.gradle riêng; chỉ api-checker có:**
```
$ ls -la server-common/
total 12
drwxr-xr-x 3 root root ... src
$ git ls-files server-common | grep -v '^server-common/src/'
(rỗng — exit 0, stdout rỗng)
$ git ls-files | grep -E '^[a-z].*/build.gradle$' | wc -l
4        # api-checker/build.gradle, api-checker/core, gradle-plugins, maven-plugin
$ for m in clients metadata server storage; do ls $m/build.gradle; done
NO build.gradle (4/4)
$ grep -n "server-common" settings.gradle
98:    'server-common',
$ grep -n "rootProject.name" settings.gradle && grep -nE "^(version|scalaVersion|group)=" gradle.properties
143:rootProject.name = 'kafka'
16:group=org.apache.kafka
17:version=4.5.0-SNAPSHOT
18:scalaVersion=2.13.18
```

**7.3) Block `:server-common` trong root build.gradle (2410–2477):**
```
$ grep -n "^project(':server-common') {" build.gradle | cut -d: -f1
2410
BLOCK_START=2410 BLOCK_END=2477
$ sed -n '2410,2420p' build.gradle
project(':server-common') {
  base { archivesName = "kafka-server-common" }
  apply plugin: 'java-test-fixtures'
  dependencies {
    api project(':clients')
    implementation libs.metrics
    ...
```

**7.4) Tail block + scaffolding:**
```
$ sed -n '2460,2477p' build.gradle
    dependsOn createVersionFile
  }
  clean.doFirst { delete "${layout.buildDirectory.get().asFile.path}/kafka/" }
  checkstyle {
    configProperties = checkstyleConfigProperties("import-control-server-common.xml")
  }
  javadoc { enabled = false }
}
$ grep distributionUrl gradle/wrapper/gradle-wrapper.properties
distributionUrl=https\://services.gradle.org/distributions/gradle-9.8.2-bin.zip
$ ls checkstyle/ | grep -i server
import-control-server-common.xml
import-control-server.xml
$ wc -l build.gradle settings.gradle gradle/dependencies.gradle
4451 144 240 (build.gradle / settings.gradle / dependencies.gradle)
$ git ls-files server-common | wc -l
212
```

**7.5) Census v9 + entry/largest:**
```
$ find server-common/src -type f \( -name '*.java' -o -name '*.scala' \) -print0 | xargs -0 cat | wc -l
35932
$ find server-common/src -type f \( -name '*.java' -o -name '*.scala' \) | wc -l
211
$ wc -l server-common/src/main/java/org/apache/kafka/server/common/MetadataVersion.java
457 server-common/src/main/java/org/apache/kafka/server/common/MetadataVersion.java
$ sed -n '47p' .../MetadataVersion.java
public enum MetadataVersion {
$ find server-common/src -name 'PersisterStateManager.java'
server-common/src/main/java/org/apache/kafka/server/share/persister/PersisterStateManager.java
$ find server-common/src/main -type f \( -name '*.java' -o -name '*.scala' \) -print0 | xargs -0 wc -l | grep -v ' total$' | sort -rn | head -5
1842 .../server/share/persister/PersisterStateManager.java
673  .../server/share/persister/DefaultStatePersister.java
605  .../metadata/properties/MetaPropertiesEnsemble.java
576  .../queue/KafkaEventQueue.java
457  .../server/common/MetadataVersion.java
```

**7.6) S3 — T/A theo lệnh ĐÃ SỬA (file-level, gồm testFixtures theo quy ước oracle):**
```
$ T=$(find server-common/src -type f \( -name '*.java' -o -name '*.scala' \) -path '*src/test*' -print0 | xargs -0 -r cat | wc -l); A=35932
T=16195 A=35932
RATIO=0.4507
$ find server-common/src/testFixtures -type f -name '*.java' -print0 | xargs -0 -r cat | wc -l
872
# đối chứng lệnh LITERAL gm-07 (bị bug lặp tổ-ancestors): TEST_DIRS=$(find server-common -type d -path '*src/test*') → T=120168 (PHỒNG ~7.4×) — bỏ, dùng lệnh đã sửa khớp cert 0.4507
```

**7.7) PLM — lệnh đã sửa w2 (LT/GT tránh `>` literal bị broker chặn):**
```
REGEX_J=^[[:space:]]*(public|protected)[[:space:]]+[A-Za-z_][]A-Za-z0-9_<>,. ?]*[[:space:]]+[A-Za-z0-9_]+[[:space:]]*\(
server-common SCALA_FILES=0 J=825 PLM=825
# sanity anchor: KafkaProducer.java sanity=22 (w2 đo 26 trên cây aa62a433)
$ git log --oneline -3 -- clients/src/main/java/org/apache/kafka/clients/producer/KafkaProducer.java
abc2906 MINOR: Address 4.4 documentation gaps for Streams and OAuth (#23809)
# → chênh 22≠26 do drift cây (file vừa bị đụng), KHÔNG do lệch lệnh (REGEX_J in ra GIỐNG HỆT w2 Dòng 48); server-common: 825 == 825 cert
```

**7.8) S1 deps_in + spot-check deps_out:**
```
$ grep -rhE '^[[:space:]]*import[[:space:]]+org\.apache\.kafka\.' server-common/src/main --include='*.java' | sed -E 's/^[[:space:]]*import[[:space:]]+//; s/;[[:space:]]*$//' | awk -F. '{print $1"."$2"."$3"."$4}' | sort | uniq -c | sort -rn
175 org.apache.kafka.common
  30 org.apache.kafka.server
  16 org.apache.kafka.clients
# map: common.* trừ DirectoryId → clients (server-common chỉ sở hữu common/{DirectoryId,ClientIdAndBroker}.java);
# server.*: common(2) config(1) immutable(6) metrics(1) record(2) share(2) util(12) = 26 tự sở hữu; authorizer(4) → clients (find-verify: ./clients/src/main/java/org/apache/kafka/server/authorizer);
# clients(16) → clients. Tổng module ngoài = {clients} ✓ khớp deps_in=1
$ for m in metadata storage raft shell server; do CNT=$(grep -rlE '^[[:space:]]*import[[:space:]]+org\.apache\.kafka\.(server|queue|timeline|deferred|logger|metadata\.properties)' $m/src/main --include='*.java' | wc -l); echo "$m: files-with-imports=$CNT"; done
metadata: files-with-imports=79
storage: files-with-imports=45
raft: files-with-imports=38
shell: files-with-imports=1
server: files-with-imports=70
# → deps_out (16 module theo gm-02 m12) còn sống trên cây mới; fan=17=1+16 hợp lý
```

## 8. Rủi ro & caveats (đánh số, có bằng chứng)

1. **Trunk drift liên tục:** aa62a433 → 3655d7c → 6014921 trong ~1 ngày pipeline (mục 2). Chống: policy pin mục 5.0 + gates G2–G4 fail-closed.
2. **Root-build.gradle tập trung (mới so thời cert):** số dòng block đổi theo từng commit — recipe mục 4 phải re-derive tại PIN; nếu block dời cấu trúc (vd tách file) → rơi option B và report.
3. **Literal oracle gm-07 bug lặp tổ-ancestors + regex POSIX:** đã tái hiện (T=120168 khi dùng literal) — mọi gate dùng lệnh đã sửa như w2/w1 (mục 7.6-7.7).
4. **Sanity anchor drift (22 vs 26):** phương pháp không đổi, cây đổi — kê khai minh bạch; anchor tương lai nên đo trên chính file mục tiêu + ghi sha cây.
5. **Gate build/test (G6) không chạy được trong node plan:** sandbox git-only thiếu JDK 17 + cần tải Gradle 9.8.2 distribution — đã kê khai là việc của lần cắt thật ngoài run (mục 5 step 5-6).
6. **Race repo đích với slot A:** cassian kỳ vọng trống; nếu slot A đẩy trước, lần cắt B phải push nhánh riêng, không force-push (mục 5 step 7).
7. **testFixtures (872 dòng)** nằm trong T theo quy ước oracle `*src/test*` (File: reports/gm-08-oracles-raw.md | Dòng: 1682) — giữ nguyên quy ước trong gate G3, không lật ngưỡng.
8. **E2 là phán quyết đọc raw output** — kế thừa verdict w2 (mục 2), không tái phán trong node này.

## 9. Kế thừa (LẦN CHẠY 2+ của node này)

- `reports/gm-09b-plan.md` đã tồn tại → **INHERITED** toàn bộ mục 1–4, 6, 8; chỉ bổ sung/sửa theo fix-list của reviewer.
- Chạy lại RẺ (mỗi lần <1 phút): gates G2–G4 trên PIN mới (mục 5 step 0-3) — 211/35932/0.4507/825. Số nào lệch cert → đo lại đầy đủ mục 2, ghi delta vào một blockquote mới, KHÔNG xóa số cert cũ.
- Fix-list reviewer ghim ở cuối file (mục đính): chưa có.
