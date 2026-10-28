# gm-01 — BOOTSTRAP CARTOGRAPHY: apache/kafka → cassian

Task: `goldmine-spec--bootstrap--f51a5b72` | Lần chạy: **1** (không có reports/gm-01 trước đó → không có gì kế thừa, không ghi INHERITED).
Môi trường: sandbox riêng `bitnami/git:latest`, ttl 7200 (session `sess-46d71e1d`). Token GitHub **không** được ghi vào bất kỳ file nào (chỉ dùng one-shot trong lệnh git).

> **RUN 2 — INHERITED** (task `goldmine-spec--bootstrap--49038125`, sandbox riêng `bitnami/git:latest` ttl 7200, session `sess-0af0859c`):
> `git ls-remote https://github.com/apache/kafka refs/heads/trunk` → `4b31f50795397c1fc5f6355993661a2105a40e97` — **SHA KHỚP run 1** → KẾ THỪA mục 1, 2(a)(b)(e)(f) bên dưới. Clone lại nông (depth 100) trong sandbox run 2 chỉ để đo lại phần thiếu; HEAD cert tại chỗ khớp tuyệt đối (cùng sha/commit `4b31f507…` KAFKA-16304 #23928, `rev-list --count` = 100, checkout 7.642 file).
> Phần thiếu đã đo lại ở RUN 2 (mục 3b): (c) census LOC công thức v9 — **sửa số dòng Java của run 1**; (d) settings.gradle khối include NGUYÊN VĂN (65 module) + gradle.properties đầy đủ; (3) cassian ls-remote bằng chứng run 2.

> **RUN 3 — INHERITED** (task `goldmine-spec--bootstrap--8a7455e5`, sandbox riêng `bitnami/git:latest` ttl 7200, session `sess-998f6789`):
> `git ls-remote https://github.com/apache/kafka refs/heads/trunk` → `4b31f50795397c1fc5f6355993661a2105a40e97` — **SHA KHỚP tuyệt đối run 1/2** → KẾ THỪA toàn bộ mục 1, 2(a)–(f). Không còn phần thiếu nào để đo lại: census LOC v9 + settings.gradle verbatim + gradle.properties đã vá đủ ở RUN 2.
> Chỉ đo lại phần duy nhất mang tính thời điểm: **(3) cassian ls-remote bằng chứng RUN 3** — exit 0, stdout rỗng (repo vẫn trống, token vẫn hợp lệ). Xem bằng chứng ở mục 3.

> **RUN 4 — KHÔNG KẾ THỪA (sha upstream DỜI CHỖ), FULL RE-MEASUREMENT** (task `goldmine-spec--bootstrap--ef360255`, sandbox riêng `bitnami/git:latest` ttl 7200, session `sess-e776e433`):
> `git ls-remote https://github.com/apache/kafka refs/heads/trunk` → **`aa62a433553c14866521bd40ff446b6920d4d67e`** — **KHÔNG khớp** `4b31f507…` của RUN 1–3 → theo quy tắc brief mục 5 ("sha khớp mới được KẾ THỪA"), toàn bộ cartography được đo LẠI tại HEAD mới. Xem kết quả đầy đủ ở mục 3c (mục 1, 2(a)–(f), 3 của RUN 1–3 giữ lại làm lịch sử; **số liệu chuẩn hành cho pipeline là RUN 4**).
> Clone nông depth 100 lại đạt lần 1 (exit 0, 7.642 file — cùng số file checkout với run cũ); census LOC v9 đo trực tiếp tại HEAD mới; settings.gradle/gradle.properties dán nguyên văn lại.

## 1. Clone nông (lần 1, thành công)

Lệnh:
```bash
git clone --depth 100 --single-branch -b trunk https://github.com/apache/kafka /workspace/kafka
```
Raw output (tail, do clone in progress-bar dài):
```
Cloning into '/workspace/kafka'...
Updating files: 100% (7642/7642), done.
CLONE_EXIT=0
```
Nhận xét: clone đạt ngay lần đầu (exit 0, 7.642 file checkout); `/workspace/kafka` hợp lệ, không cần re-clone-full qua VFS.

## 2. CARTOGRAPHY (raw output từng lệnh)

### (a) HEAD + số commit
```bash
git log -1 --format='%H %ci %s'; git rev-list --count HEAD
```
```
4b31f50795397c1fc5f6355993661a2105a40e97 2026-10-28 09:54:49 -0700 KAFKA-16304: Report file read errors from SslTransportLayer.transferFrom as such (#23928)
100
```
Nhận xét: HEAD `4b31f507` (commit KAFKA-16304, #23928); `rev-list --count HEAD = 100` → **shallow ≤100**, lịch sử đầy đủ không có trong clone này.

### (b) Cổng LICENSE (gate)
```bash
ls -la LICENSE*
```
```
-rw-r--r-- 1 root root 11358 Oct 28 16:59 LICENSE
-rw-r--r-- 1 root root 14615 Oct 28 16:59 LICENSE-binary
LICENSE_EXIT=0
```
Nhận xét: **GATE ĐẠT** — LICENSE (Apache) + LICENSE-binary tồn tại, không rơi vào BLOCKED.

### (c) Số dòng theo extension
> ⚠️ **RUN 2 ĐÃ SỬA:** lệnh dưới đây của run 1 là công thức **BỊ CẤM theo v9** (`xargs wc -l | tail -1` chỉ bắt total batch cuối) → số dòng Java bảng dưới **SAI**. Số liệu chuẩn ở mục "3b — census LOC v9": **java = 1.604.444 dòng** (cũ) / **1.604.486 dòng** (RUN 4 tại HEAD mới — xem mục 3c). Scala/py/sh khớp giữa các lần đo (file count nhỏ, nằm gọn 1 batch xargs nên không lỗi).
```bash
find . -type f -name "*.<ext>" -not -path './.git/*' | xargs wc -l | tail -1   # lặp theo ext — CÔNG THỨC BỊ CẤM v9
```
```
EXT .java: files=6283 lines=172740
EXT .scala: files=255 lines=134077
EXT .py: files=185 lines=32772
EXT .sh: files=61 lines=2537
```
Nhận xét (sửa run 2): chủ đạo **Java**; Scala còn 134k dòng (lịch sử, phần lớn test/không còn trong trunk chính theo migration Java hóa); phụ trợ Python (kafkatest) và shell script. Số 172.740 dòng của run 1 là artifact của công thức bị cấm (chỉ đếm batch cuối).

### (d) Build manifests (head -25 mỗi file)

`settings.gradle` (head):
```
pluginManagement {
    // Exposes the api-checker plugins (org.apache.kafka.public-api-checker and
    // org.apache.kafka.internal-api-checker) to Kafka's own build by ID. ...
    includeBuild 'api-checker'
}
plugins {
```
`build.gradle` (head):
```
import org.eclipse.jgit.api.Git
import org.gradle.api.artifacts.FileCollectionDependency
import java.nio.charset.StandardCharsets

buildscript {
  repositories {
    mavenCentral()
  }
  apply from: "$rootDir/gradle/dependencies.gradle"
}
```
`gradle.properties` (head):
```
group=org.apache.kafka
version=4.5.0-SNAPSHOT
scalaVersion=2.13.18
swaggerVersion=2.2.55
task=build
org.gradle.jvmargs=-Xmx4g -Xss4m -XX:+UseParallelGC
org.gradle.parallel=true
```
`gradle/wrapper/gradle-wrapper.properties`: `distributionUrl=...gradle-9.8.2-bin.zip`
Nhận xét: build Gradle composite (includeBuild `api-checker`), phiên bản dev **4.5.0-SNAPSHOT**, Scala 2.13.18, Gradle wrapper 9.8.2, JVM build -Xmx4g.

### (e) Entrypoints
```bash
grep -rn "public static void main" core/src clients/src connect/runtime/src | head -20
```
```
clients/src/test/java/org/apache/kafka/test/MetricsBench.java:32:    public static void main(String[] args) {
clients/src/test/java/org/apache/kafka/common/metrics/stats/HistogramTest.java:149:    public static void main(String[] args) {
clients/src/main/java/org/apache/kafka/clients/consumer/internals/FetchMetricsRegistry.java:152:    public static void main(String[] args) {
clients/src/main/java/org/apache/kafka/clients/consumer/ConsumerConfig.java:884:    public static void main(String[] args) {
clients/src/main/java/org/apache/kafka/clients/producer/ProducerConfig.java:770:    public static void main(String[] args) {
clients/src/main/java/org/apache/kafka/clients/producer/internals/ProducerMetrics.java:40:    public static void main(String[] args) {
clients/src/main/java/org/apache/kafka/clients/admin/AdminClientConfig.java:341:    public static void main(String[] args) {
clients/src/main/java/org/apache/kafka/common/protocol/types/Type.java:1188:    public static void main(String[] args) {
clients/src/main/java/org/apache/kafka/common/protocol/Errors.java:600:    public static void main(String[] args) {
clients/src/main/java/org/apache/kafka/common/protocol/Protocol.java:249:    public static void main(String[] args) {
clients/src/main/java/org/apache/kafka/common/protocol/ApiKeys.java:340:    public static void main(String[] args) {
connect/runtime/src/main/java/org/apache/kafka/connect/cli/ConnectStandalone.java:180:    public static void main(String[] args) {
connect/runtime/src/main/java/org/apache/kafka/connect/cli/ConnectDistributed.java:110:    public static void main(String[] args) {
connect/runtime/src/main/java/org/apache/kafka/connect/runtime/SinkConnectorConfig.java:217:    public static void main(String[] args) {
connect/runtime/src/main/java/org/apache/kafka/connect/runtime/SourceConnectorConfig.java:339:    public static void main(String[] args) {
connect/runtime/src/main/java/org/apache/kafka/connect/runtime/ConnectMetrics.java:508:    public static void main(String[] args) {
connect/runtime/src/main/java/org/apache/kafka/connect/runtime/distributed/DistributedConfig.java:664:    public static void main(String[] args) {
connect/runtime/src/main/java/org/apache/kafka/connect/tools/PredicateDoc.java:69:    public static void main(String... args) {
connect/runtime/src/main/java/org/apache/kafka/connect/tools/TransformationDoc.java:78:    public static void main(String... args) {
```
Nhận xét: grep chỉ bắt entrypoint **Java** (Connect CLI `ConnectStandalone`/`ConnectDistributed` là main chạy thật; phần còn lại là main tiện ích debug/config-doc); broker chính `kafka.Kafka` viết bằng Scala (`def main`) nên không xuất hiện trong grep này — entrypoint thật của broker nằm ở `core/src/main/scala/kafka/Kafka.scala`.

### (f) Cây thư mục (maxdepth 2)
```bash
find . -maxdepth 2 -type d -not -path './.git*' | sort | head -80
```
```
./api-checker  ./bin  ./bin/windows  ./checkstyle
./clients  ./clients/clients-integration-tests  ./clients/src
./committer-tools  ./config
./connect  ./connect/api  ./connect/basic-auth-extension  ./connect/file  ./connect/json
./connect/mirror  ./connect/mirror-client  ./connect/runtime  ./connect/test-plugins  ./connect/transforms
./coordinator-common  ./coordinator-common/src
./core  ./core/src
./docker  ./docker/docker_official_images  ./docker/examples  ./docker/jvm  ./docker/native  ./docker/resources  ./docker/test
./docs  ./docs/apis  ./docs/configuration  ./docs/design  ./docs/documentation  ./docs/getting-started
./docs/images  ./docs/implementation  ./docs/kafka-connect  ./docs/operations  ./docs/security  ./docs/streams
./examples  ./examples/bin  ./examples/src
./generator  ./generator/src
./gradle  ./gradle/resources  ./gradle/wrapper
./group-coordinator  ./group-coordinator/group-coordinator-api  ./group-coordinator/src
./jmh-benchmarks  ./jmh-benchmarks/src
./licenses
./metadata  ./metadata/src
./mirror-coordinator  ./mirror-coordinator/src
./raft  ./raft/bin  ./raft/config  ./raft/src
./release
./server  ./server-common  ./server-common/src  ./server/src
./share-coordinator  ./share-coordinator/src
./shell  ./shell/src
./storage  ./storage/api  ./storage/src
```
*(80 dòng đầu theo lệnh brief; phần còn lại của sort gồm):*
```
./streams  ./streams/upgrade-system-tests-38..43
./test-common  ./test-common/test-common-internal-api  ./test-common/test-common-runtime  ./test-common/test-common-util
./tests  ./tests/bin  ./tests/docker  ./tests/kafkatest  ./tests/spec  ./tests/unit
./tools  ./tools/src  ./tools/tools-api
./transaction-coordinator  ./transaction-coordinator/src
./trogdor  ./trogdor/src
./vagrant  ./vagrant/aws
```
Nhận xét: tổng **132 module/dir cấp 1–2** — monorepo Gradle đa module: core broker (Java+Scala), clients, connect, streams, raft, storage, các coordinator (group/mirror/share/transaction), server-common, docker/tests/tools.

## 3. Kiểm repo đích cassian (CHỈ ĐỌC — không push)
```bash
git ls-remote https://x-access-token:$TOKEN@github.com/Stellarhold170NT/cassian.git
```
```
LSREMOTE_EXIT=0
(stdout rỗng)
```
Nhận xét: **OK** — token hợp lệ, repo tồn tại và **trống** (không ref nào) = đúng trạng thái kỳ vọng cho seed ban đầu.

## 3b. RUN 2 re-measurement (các phần thiếu của run 1 — task `goldmine-spec--bootstrap--49038125`)

### (c) census LOC v9 — công thức đúng (bắt buộc)
```bash
cd /workspace/kafka; for ext in java scala py sh; do
  n=$(find . -type f -name "*.$ext" -not -path './.git/*' | wc -l)
  l=$(find . -type f -name "*.$ext" -not -path './.git/*' -print0 | xargs -0 cat | wc -l)
  echo "EXT .$ext files=$n lines=$l"
done
```
```
=== CENSUS LOC v9 ===
EXT .java files=6283 lines=1604444
EXT .scala files=255 lines=134077
EXT .py files=185 lines=32772
EXT .sh files=61 lines=2537
```
Cross-check bằng oracle độc lập thứ hai (tổng ALL batch totals của `wc -l`, thay cho `tail -1`):
```bash
find . -type f -name "*.java" -not -path './.git/*' -print0 | xargs -0 wc -l | grep ' total$' | awk '{s+=$1} END {print "JAVA_SUM_ALL_BATCH_TOTALS="s}'
find . -type f -name "*.java" -not -path './.git/*' -print0 | xargs -0 cat | wc -l | awk '{print "JAVA_CAT_V9="$1}'
```
```
JAVA_SUM_ALL_BATCH_TOTALS=1604444
JAVA_CAT_V9=1604444
```
Nhận xét: 2 oracle độc lập cùng ra **1.604.444** → số dòng Java chuẩn tại SHA `4b31f507` là 1.604.444; số 172.740 của run 1 bị loại. File count khớp tuyệt đối run 1 (6.283 java / 255 scala / 185 py / 61 sh) → cùng một cây.

### (d) settings.gradle — khối include NGUYÊN VĂN (universe module toàn pipeline) + gradle.properties đầy đủ

`settings.gradle` (144 dòng; phần đầu pluginManagement như run 1 đã ghi). Khối include/project nguyên văn:
```gradle
include 'clients',
    'clients:clients-integration-tests',
    'connect:api',
    'connect:basic-auth-extension',
    'connect:file',
    'connect:json',
    'connect:mirror',
    'connect:mirror-client',
    'connect:runtime',
    'connect:test-plugins',
    'connect:transforms',
    'coordinator-common',
    'core',
    'examples',
    'generator',
    'group-coordinator',
    'group-coordinator:group-coordinator-api',
    'jmh-benchmarks',
    'metadata',
    'mirror-coordinator',
    'raft',
    'server',
    'server-common',
    'share-coordinator',
    'shell',
    'storage',
    'storage:api',
    'streams',
    'streams:examples',
    'streams:integration-tests',
    'streams:streams-scala',
    'streams:test-utils',
    'streams:upgrade-system-tests-0110',
    'streams:upgrade-system-tests-10',
    'streams:upgrade-system-tests-11',
    'streams:upgrade-system-tests-20',
    'streams:upgrade-system-tests-21',
    'streams:upgrade-system-tests-22',
    'streams:upgrade-system-tests-23',
    'streams:upgrade-system-tests-24',
    'streams:upgrade-system-tests-25',
    'streams:upgrade-system-tests-26',
    'streams:upgrade-system-tests-27',
    'streams:upgrade-system-tests-28',
    'streams:upgrade-system-tests-30',
    'streams:upgrade-system-tests-31',
    'streams:upgrade-system-tests-32',
    'streams:upgrade-system-tests-33',
    'streams:upgrade-system-tests-34',
    'streams:upgrade-system-tests-35',
    'streams:upgrade-system-tests-36',
    'streams:upgrade-system-tests-37',
    'streams:upgrade-system-tests-38',
    'streams:upgrade-system-tests-39',
    'streams:upgrade-system-tests-40',
    'streams:upgrade-system-tests-41',
    'streams:upgrade-system-tests-42',
    'streams:upgrade-system-tests-43',
    'tools',
    'tools:tools-api',
    'transaction-coordinator',
    'trogdor',
    'test-common:test-common-internal-api',
    'test-common:test-common-util',
    'test-common:test-common-runtime'


project(":storage:api").name = "storage-api"
rootProject.name = 'kafka'
```
`gradle.properties` NGUYÊN VĂN (23 dòng, đã lược khối license ASF 15 dòng đầu — nội dung cấu hình):
```properties
group=org.apache.kafka
version=4.5.0-SNAPSHOT
scalaVersion=2.13.18
# Adding swaggerVersion in gradle.properties to have a single version in place for swagger
swaggerVersion=2.2.55
task=build
org.gradle.jvmargs=-Xmx4g -Xss4m -XX:+UseParallelGC
org.gradle.parallel=true
```
Nhận xét: **65 module Gradle** trong include (verify bằng đếm cặp quote: `INCLUDE_ENTRIES=65`, block 65 dòng) + composite build `api-checker` (includeBuild); `rootProject.name='kafka'`; rename `:storage:api` → `storage-api`. Đây là universe module cho toàn pipeline các node sau.

### (3) cassian ls-remote — bằng chứng run 2 (CHỈ ĐỌC, không push)
```bash
git ls-remote https://x-access-token:$TOKEN@github.com/Stellarhold170NT/cassian.git; echo "LSREMOTE_EXIT=$?"   # $TOKEN truyền inline one-shot, giá trị KHÔNG ghi vào file nào
```
```
LSREMOTE_EXIT=0
(stdout rỗng)
```
Nhận xét: xác nhận lại ở run 2 — token hợp lệ, repo tồn tại và **trống** = đúng trạng thái kỳ vọng cho seed ban đầu.

**Bằng chứng RUN 3** (task `goldmine-spec--bootstrap--8a7455e5`):
```bash
git ls-remote https://x-access-token:$TOKEN@github.com/Stellarhold170NT/cassian.git 2>&1; echo "LSREMOTE_EXIT=$?"   # token one-shot inline, KHÔNG ghi vào file nào
```
```
LSREMOTE_EXIT=0
(stdout rỗng — cả stderr sạch)
```
Nhận xét: xác nhận lần 3 — token vẫn hợp lệ, `Stellarhold170NT/cassian` vẫn tồn tại và **trống** = trạng thái kỳ vọng giữ nguyên cho node seed phía sau.

## 3c. RUN 4 — FULL RE-MEASUREMENT tại HEAD mới `aa62a433…` (task `goldmine-spec--bootstrap--ef360255`)

> **Nguyên nhân re-run:** `git ls-remote` upstream trunk trả về `aa62a433553c14866521bd40ff446b6920d4d67e` ≠ `4b31f507…` (RUN 1–3) → điều kiện kế thừa ("sha khớp") KHÔNG thỏa → đo lại toàn bộ (a)–(f) + cassian. Sandbox riêng: `bitnami/git:latest`, ttl 7200, session `sess-e776e433`.

### Verify sha trước khi clone (mốc quyết định INHERIT/no-INHERIT)
```bash
git ls-remote https://github.com/apache/kafka refs/heads/trunk; echo "TRUNK_LSREMOTE_EXIT=$?"
```
```
aa62a433553c14866521bd40ff446b6920d4d67e	refs/heads/trunk
TRUNK_LSREMOTE_EXIT=0
```

### 1. Clone nông (lần 1, thành công — sandbox RUN 4)
```bash
git clone --depth 100 --single-branch -b trunk https://github.com/apache/kafka /workspace/kafka; echo "CLONE_EXIT=$?"
```
```
Cloning into '/workspace/kafka'...
Updating files: 100% (7642/7642), done.
CLONE_EXIT=0
```
Nhận xét: clone đạt lần 1 (exit 0, 7.642 file checkout — cùng số file với run cũ); không cần re-clone-full.

### 2(a) HEAD + số commit
```bash
cd /workspace/kafka && git log -1 --format='%H %ci %s' && git rev-list --count HEAD
```
```
aa62a433553c14866521bd40ff446b6920d4d67e 2026-10-28 14:35:02 -0400 KAFKA-20866: Remove incremental-only append result state (#23749)
100
```
Nhận xét: HEAD mới `aa62a433` (commit **KAFKA-20866: Remove incremental-only append result state (#23749)** — khác run cũ `4b31f507`/KAFKA-16304 #23928); `rev-list --count HEAD = 100` → **shallow ≤100**.

### 2(b) Cổng LICENSE (gate)
```bash
ls -la LICENSE*
```
```
-rw-r--r-- 1 root root 11358 Oct 28 19:52 LICENSE
-rw-r--r-- 1 root root 14615 Oct 28 19:52 LICENSE-binary
```
Nhận xét: **GATE ĐẠT** — LICENSE + LICENSE-binary tồn tại (kích thước y hệt run cũ), không BLOCKED.

### 2(c) census LOC v9 — công thức đúng (bắt buộc)
```bash
cd /workspace/kafka; for ext in java scala py sh; do
  n=$(find . -type f -name "*.$ext" -not -path './.git/*' | wc -l)
  l=$(find . -type f -name "*.$ext" -not -path './.git/*' -print0 | xargs -0 cat | wc -l)
  echo "EXT .$ext files=$n lines=$l"
done
```
```
=== CENSUS LOC v9 ===
EXT .java files=6283 lines=1604486
EXT .scala files=255 lines=134077
EXT .py files=185 lines=32772
EXT .sh files=61 lines=2537
```
Nhận xét: **java = 1.604.486 dòng** tại HEAD mới (+42 dòng so với 1.604.444 của `4b31f507` — đúng kỳ vọng vì trunk có commit mới); scala/py/sh **khớp tuyệt đối** run cũ (134.077 / 32.772 / 2.537) → chỉ java thay đổi, dữ liệu nhất quán giữa 2 HEAD.

### 2(d) Build manifests — nguyên văn

`settings.gradle` — phần pluginManagement + plugins + develocity/buildCache (nguyên văn, sau khối license ASF):
```gradle
pluginManagement {
    // Exposes the api-checker plugins (org.apache.kafka.public-api-checker and
    // org.apache.kafka.internal-api-checker) to Kafka's own build by ID. The api-checker
    // tree is a separate Gradle build, so its Maven runtime dependencies don't end up on
    // every developer's main-build classpath, and each published artifact carries only
    // the classes its consumers need.
    includeBuild 'api-checker'
}


plugins {
    id 'com.gradle.develocity' version '3.19'
    id 'com.gradle.common-custom-user-data-gradle-plugin' version '2.0.2'
    id 'io.github.ben-manes.versions.settings' version '0.64.0'
}


def isGithubActions = System.getenv('GITHUB_ACTIONS') != null


def runNew = ext.find("kafka.test.run.new") == "true"
def runFlaky = ext.find("kafka.test.run.flaky") == "true"
def currentJvm = JavaVersion.current()


develocity {
    server = "https://develocity.apache.org"
    projectId = "kafka"
    ...
}


buildCache {
    local {
        // This allows the build cache to be used locally or on GitHub Actions.
        // Using the cache on GH should be safe since each job is run on a new VM
        enabled = true
    }


    remote(develocity.buildCache) {
        enabled = false
    }
}
```
Khối include/project NGUYÊN VĂN (universe module toàn pipeline):
```gradle
include 'clients',
    'clients:clients-integration-tests',
    'connect:api',
    'connect:basic-auth-extension',
    'connect:file',
    'connect:json',
    'connect:mirror',
    'connect:mirror-client',
    'connect:runtime',
    'connect:test-plugins',
    'connect:transforms',
    'coordinator-common',
    'core',
    'examples',
    'generator',
    'group-coordinator',
    'group-coordinator:group-coordinator-api',
    'jmh-benchmarks',
    'metadata',
    'mirror-coordinator',
    'raft',
    'server',
    'server-common',
    'share-coordinator',
    'shell',
    'storage',
    'storage:api',
    'streams',
    'streams:examples',
    'streams:integration-tests',
    'streams:streams-scala',
    'streams:test-utils',
    'streams:upgrade-system-tests-0110',
    'streams:upgrade-system-tests-10',
    'streams:upgrade-system-tests-11',
    'streams:upgrade-system-tests-20',
    'streams:upgrade-system-tests-21',
    'streams:upgrade-system-tests-22',
    'streams:upgrade-system-tests-23',
    'streams:upgrade-system-tests-24',
    'streams:upgrade-system-tests-25',
    'streams:upgrade-system-tests-26',
    'streams:upgrade-system-tests-27',
    'streams:upgrade-system-tests-28',
    'streams:upgrade-system-tests-30',
    'streams:upgrade-system-tests-31',
    'streams:upgrade-system-tests-32',
    'streams:upgrade-system-tests-33',
    'streams:upgrade-system-tests-34',
    'streams:upgrade-system-tests-35',
    'streams:upgrade-system-tests-36',
    'streams:upgrade-system-tests-37',
    'streams:upgrade-system-tests-38',
    'streams:upgrade-system-tests-39',
    'streams:upgrade-system-tests-40',
    'streams:upgrade-system-tests-41',
    'streams:upgrade-system-tests-42',
    'streams:upgrade-system-tests-43',
    'tools',
    'tools:tools-api',
    'transaction-coordinator',
    'trogdor',
    'test-common:test-common-internal-api',
    'test-common:test-common-util',
    'test-common:test-common-runtime'


project(":storage:api").name = "storage-api"
rootProject.name = 'kafka'
```
`gradle.properties` NGUYÊN VĂN (đã lược khối license ASF 15 dòng đầu — nội dung cấu hình):
```properties
group=org.apache.kafka
version=4.5.0-SNAPSHOT
scalaVersion=2.13.18
# Adding swaggerVersion in gradle.properties to have a single version in place for swagger
swaggerVersion=2.2.55
task=build
org.gradle.jvmargs=-Xmx4g -Xss4m -XX:+UseParallelGC
org.gradle.parallel=true
```
`build.gradle` (head sau license):
```gradle
import org.eclipse.jgit.api.Git
import org.gradle.api.artifacts.FileCollectionDependency
import java.nio.charset.StandardCharsets


buildscript {
  repositories {
    mavenCentral()
  }
  apply from: "$rootDir/gradle/dependencies.gradle"
}
```
`gradle/wrapper/gradle-wrapper.properties`:
```
distributionUrl=https\://services.gradle.org/distributions/gradle-9.8.2-bin.zip
distributionSha256Sum=21bd5da2de49b642904077f38c0efdc7778e92b3ed0889392dca61b97e389607
```
Nhận xét: **settings.gradle/gradle.properties/build.gradle/wrapper KHÔNG ĐỔI so với run cũ** (65 module include + includeBuild `api-checker`, `rootProject.name='kafka'`, rename `:storage:api`→`storage-api`, version 4.5.0-SNAPSHOT, Scala 2.13.18, Gradle 9.8.2) → universe module cho pipeline giữ nguyên.

### 2(e) Entrypoints
```bash
cd /workspace/kafka && grep -rn "public static void main" core/src clients/src connect/runtime/src | head -20
```
```
clients/src/test/java/org/apache/kafka/test/MetricsBench.java:32:    public static void main(String[] args) {
clients/src/test/java/org/apache/kafka/common/metrics/stats/HistogramTest.java:149:    public static void main(String[] args) {
clients/src/main/java/org/apache/kafka/clients/consumer/internals/FetchMetricsRegistry.java:152:    public static void main(String[] args) {
clients/src/main/java/org/apache/kafka/clients/consumer/ConsumerConfig.java:884:    public static void main(String[] args) {
clients/src/main/java/org/apache/kafka/clients/producer/ProducerConfig.java:770:    public static void main(String[] args) {
clients/src/main/java/org/apache/kafka/clients/producer/internals/ProducerMetrics.java:40:    public static void main(String[] args) {
clients/src/main/java/org/apache/kafka/clients/admin/AdminClientConfig.java:341:    public static void main(String[] args) {
clients/src/main/java/org/apache/kafka/common/protocol/types/Type.java:1188:    public static void main(String[] args) {
clients/src/main/java/org/apache/kafka/common/protocol/Errors.java:600:    public static void main(String[] args) {
clients/src/main/java/org/apache/kafka/common/protocol/Protocol.java:249:    public static void main(String[] args) {
clients/src/main/java/org/apache/kafka/common/protocol/ApiKeys.java:340:    public static void main(String[] args) {
connect/runtime/src/main/java/org/apache/kafka/connect/cli/ConnectStandalone.java:180:    public static void main(String[] args) {
connect/runtime/src/main/java/org/apache/kafka/connect/cli/ConnectDistributed.java:110:    public static void main(String[] args) {
connect/runtime/src/main/java/org/apache/kafka/connect/runtime/SinkConnectorConfig.java:217:    public static void main(String[] args) {
connect/runtime/src/main/java/org/apache/kafka/connect/runtime/SourceConnectorConfig.java:339:    public static void main(String[] args) {
connect/runtime/src/main/java/org/apache/kafka/connect/runtime/ConnectMetrics.java:508:    public static void main(String[] args) {
connect/runtime/src/main/java/org/apache/kafka/connect/runtime/distributed/DistributedConfig.java:664:    public static void main(String[] args) {
connect/runtime/src/main/java/org/apache/kafka/connect/tools/PredicateDoc.java:69:    public static void main(String... args) {
connect/runtime/src/main/java/org/apache/kafka/connect/tools/TransformationDoc.java:78:    public static void main(String... args) {
```
Cross-check broker main Scala:
```bash
ls -la core/src/main/scala/kafka/Kafka.scala && grep -n "def main" core/src/main/scala/kafka/Kafka.scala
```
```
-rwxr-xr-x 1 root root 4384 Oct 28 19:52 core/src/main/scala/kafka/Kafka.scala
73:  def main(args: Array[String]): Unit = {
```
Nhận xét: **19 entrypoint Java khớp tuyệt đối run cũ** (Connect CLI `ConnectStandalone`/`ConnectDistributed` là main chạy thật; còn lại là main tiện ích debug/config-doc); broker main vẫn là Scala `kafka.Kafka#main` (dòng 73, file tồn tại tại HEAD mới).

### 2(f) Cây thư mục (maxdepth 2, head -80 + tail)
```bash
cd /workspace/kafka && find . -maxdepth 2 -type d -not -path './.git*' | sort | head -80
```
```
.
./api-checker
./api-checker/core
./api-checker/gradle-plugins
./api-checker/maven-plugin
./bin
./bin/windows
./checkstyle
./clients
./clients/clients-integration-tests
./clients/src
./committer-tools
./config
./connect
./connect/api
./connect/basic-auth-extension
./connect/file
./connect/json
./connect/mirror
./connect/mirror-client
./connect/runtime
./connect/test-plugins
./connect/transforms
./coordinator-common
./coordinator-common/src
./core
./core/src
./docker
./docker/docker_official_images
./docker/examples
./docker/jvm
./docker/native
./docker/resources
./docker/test
./docs
./docs/apis
./docs/configuration
./docs/design
./docs/documentation
./docs/getting-started
./docs/images
./docs/implementation
./docs/kafka-connect
./docs/operations
./docs/security
./docs/streams
./examples
./examples/bin
./examples/src
./generator
./generator/src
./gradle
./gradle/resources
./gradle/wrapper
./group-coordinator
./group-coordinator/group-coordinator-api
./group-coordinator/src
./jmh-benchmarks
./jmh-benchmarks/src
./licenses
./metadata
./metadata/src
./mirror-coordinator
./mirror-coordinator/src
./raft
./raft/bin
./raft/config
./raft/src
./release
./server
./server-common
./server-common/src
./server/src
./share-coordinator
./share-coordinator/src
./shell
./shell/src
./storage
./storage/api
./storage/src
```
```bash
find . -maxdepth 2 -type d -not -path './.git*' | sort | tail -n +81
```
```
./streams
./streams/examples
./streams/integration-tests
./streams/quickstart
./streams/src
./streams/streams-scala
./streams/test-utils
./streams/upgrade-system-tests-0110
./streams/upgrade-system-tests-10
./streams/upgrade-system-tests-11
./streams/upgrade-system-tests-20
./streams/upgrade-system-tests-21
./streams/upgrade-system-tests-22
./streams/upgrade-system-tests-23
./streams/upgrade-system-tests-24
./streams/upgrade-system-tests-25
./streams/upgrade-system-tests-26
./streams/upgrade-system-tests-27
./streams/upgrade-system-tests-28
./streams/upgrade-system-tests-30
./streams/upgrade-system-tests-31
./streams/upgrade-system-tests-32
./streams/upgrade-system-tests-33
./streams/upgrade-system-tests-34
./streams/upgrade-system-tests-35
./streams/upgrade-system-tests-36
./streams/upgrade-system-tests-37
./streams/upgrade-system-tests-38
./streams/upgrade-system-tests-39
./streams/upgrade-system-tests-40
./streams/upgrade-system-tests-41
./streams/upgrade-system-tests-42
./streams/upgrade-system-tests-43
./test-common
./test-common/test-common-internal-api
./test-common/test-common-runtime
./test-common/test-common-util
./tests
./tests/bin
./tests/docker
./tests/kafkatest
./tests/spec
./tests/unit
./tools
./tools/src
./tools/tools-api
./transaction-coordinator
./transaction-coordinator/src
./trogdor
./trogdor/src
./vagrant
./vagrant/aws
```
Nhận xét: cùng cấu trúc 33 thư mục cấp-1 như run cũ (api-checker, bin, checkstyle, clients, committer-tools, config, connect, coordinator-common, core, docker, docs, examples, generator, gradle, group-coordinator, jmh-benchmarks, licenses, metadata, mirror-coordinator, raft, release, server, server-common, share-coordinator, shell, storage, streams, test-common, tests, tools, transaction-coordinator, trogdor, vagrant) — monorepo Gradle đa module: core broker (Java+Scala), clients, connect, streams, raft, storage, các coordinator, server-common, docker/tests/tools.

### 3. cassian ls-remote — bằng chứng RUN 4 (CHỈ ĐỌC, không push)
```bash
git ls-remote https://x-access-token:$TOKEN@github.com/Stellarhold170NT/cassian.git 2>&1; echo "LSREMOTE_EXIT=$?"   # token one-shot inline, KHÔNG ghi vào file nào
```
```
LSREMOTE_EXIT=0
(stdout rỗng — cả stderr sạch)
```
Nhận xét: xác nhận lần 4 — token vẫn hợp lệ, `Stellarhold170NT/cassian` vẫn tồn tại và **trống** = trạng thái kỳ vọng giữ nguyên cho node seed phía sau.

## 4. JSON block cuối file

```json
{
  "repo": "apache/kafka",
  "upstream_branch": "trunk",
  "sha": "aa62a433553c14866521bd40ff446b6920d4d67e",
  "sha_note": "RUN 4 (ef360255): trunk đã tiến tới commit KAFKA-20866 #23749; sha cũ của RUN 1-3 (4b31f50795397c1fc5f6355993661a2105a40e97) ĐÃ LỆI — mọi node sau của pipeline DÙNG sha aa62a433…",
  "commit_count_shallow": 100,
  "languages": {
    "java": {"files": 6283, "lines": 1604486},
    "scala": {"files": 255, "lines": 134077},
    "python": {"files": 185, "lines": 32772},
    "shell": {"files": 61, "lines": 2537}
  },
  "manifests": {
    "settings.gradle": "pluginManagement includeBuild 'api-checker' (develocity 3.19, projectId kafka) + include block 65 module (verbatim mục 3c-2d)",
    "modules": ["clients", "clients:clients-integration-tests", "connect:api", "connect:basic-auth-extension", "connect:file", "connect:json", "connect:mirror", "connect:mirror-client", "connect:runtime", "connect:test-plugins", "connect:transforms", "coordinator-common", "core", "examples", "generator", "group-coordinator", "group-coordinator:group-coordinator-api", "jmh-benchmarks", "metadata", "mirror-coordinator", "raft", "server", "server-common", "share-coordinator", "shell", "storage", "storage:api", "streams", "streams:examples", "streams:integration-tests", "streams:streams-scala", "streams:test-utils", "streams:upgrade-system-tests-0110", "streams:upgrade-system-tests-10", "streams:upgrade-system-tests-11", "streams:upgrade-system-tests-20", "streams:upgrade-system-tests-21", "streams:upgrade-system-tests-22", "streams:upgrade-system-tests-23", "streams:upgrade-system-tests-24", "streams:upgrade-system-tests-25", "streams:upgrade-system-tests-26", "streams:upgrade-system-tests-27", "streams:upgrade-system-tests-28", "streams:upgrade-system-tests-30", "streams:upgrade-system-tests-31", "streams:upgrade-system-tests-32", "streams:upgrade-system-tests-33", "streams:upgrade-system-tests-34", "streams:upgrade-system-tests-35", "streams:upgrade-system-tests-36", "streams:upgrade-system-tests-37", "streams:upgrade-system-tests-38", "streams:upgrade-system-tests-39", "streams:upgrade-system-tests-40", "streams:upgrade-system-tests-41", "streams:upgrade-system-tests-42", "streams:upgrade-system-tests-43", "tools", "tools:tools-api", "transaction-coordinator", "trogdor", "test-common:test-common-internal-api", "test-common:test-common-util", "test-common:test-common-runtime"],
    "build.gradle": "buildscript mavenCentral, apply gradle/dependencies.gradle",
    "gradle.properties": {"group": "org.apache.kafka", "version": "4.5.0-SNAPSHOT", "scalaVersion": "2.13.18", "swaggerVersion": "2.2.55", "task": "build", "org.gradle.jvmargs": "-Xmx4g -Xss4m -XX:+UseParallelGC", "org.gradle.parallel": true},
    "gradle_wrapper": "gradle-9.8.2-bin.zip (sha256 21bd5da2de49b642904077f38c0efdc7778e92b3ed0889392dca61b97e389607)"
  },
  "entrypoints": [
    "clients/src/main/java/org/apache/kafka/clients/consumer/ConsumerConfig.java:884",
    "clients/src/main/java/org/apache/kafka/clients/producer/ProducerConfig.java:770",
    "clients/src/main/java/org/apache/kafka/clients/admin/AdminClientConfig.java:341",
    "clients/src/main/java/org/apache/kafka/common/protocol/ApiKeys.java:340",
    "clients/src/main/java/org/apache/kafka/common/protocol/Errors.java:600",
    "clients/src/main/java/org/apache/kafka/common/protocol/Protocol.java:249",
    "clients/src/main/java/org/apache/kafka/common/protocol/types/Type.java:1188",
    "clients/src/main/java/org/apache/kafka/clients/consumer/internals/FetchMetricsRegistry.java:152",
    "clients/src/main/java/org/apache/kafka/clients/producer/internals/ProducerMetrics.java:40",
    "connect/runtime/src/main/java/org/apache/kafka/connect/cli/ConnectStandalone.java:180",
    "connect/runtime/src/main/java/org/apache/kafka/connect/cli/ConnectDistributed.java:110",
    "connect/runtime/src/main/java/org/apache/kafka/connect/runtime/SinkConnectorConfig.java:217",
    "connect/runtime/src/main/java/org/apache/kafka/connect/runtime/SourceConnectorConfig.java:339",
    "connect/runtime/src/main/java/org/apache/kafka/connect/runtime/ConnectMetrics.java:508",
    "connect/runtime/src/main/java/org/apache/kafka/connect/runtime/distributed/DistributedConfig.java:664",
    "connect/runtime/src/main/java/org/apache/kafka/connect/tools/PredicateDoc.java:69",
    "connect/runtime/src/main/java/org/apache/kafka/connect/tools/TransformationDoc.java:78",
    "clients/src/test/java/org/apache/kafka/test/MetricsBench.java:32",
    "clients/src/test/java/org/apache/kafka/common/metrics/stats/HistogramTest.java:149",
    "NOTE: broker main kafka.Kafka la Scala (def main, dong 73) tai core/src/main/scala/kafka/Kafka.scala — khong bat boi grep 'public static void main'"
  ],
  "top_dirs": ["api-checker", "bin", "checkstyle", "clients", "committer-tools", "config", "connect", "coordinator-common", "core", "docker", "docs", "examples", "generator", "gradle", "group-coordinator", "jmh-benchmarks", "licenses", "metadata", "mirror-coordinator", "raft", "release", "server", "server-common", "share-coordinator", "shell", "storage", "streams", "test-common", "tests", "tools", "transaction-coordinator", "trogdor", "vagrant"],
  "cassian_target": "Stellarhold170NT/cassian",
  "cassian_target_status": "VERIFIED-EMPTY (ls-remote exit 0, stdout rỗng — xác nhận lại lần 4 tại RUN 4)",
  "census_formula": "v9: find -print0 | xargs -0 cat | wc -l theo từng ext (RUN 4 tại sha aa62a433…; java 1604486 — cross-check lịch sử: 2 oracle độc lập ra 1604444 tại sha 4b31f507 cũ)",
  "inherited": {
    "run": 4,
    "from_task": "goldmine-spec--bootstrap--ef360255",
    "inherit_decision": "NO-INHERIT — sha upstream aa62a433553c14866521bd40ff446b6920d4d67e != 4b31f50795397c1fc5f6355993661a2105a40e97 (RUN 1-3)",
    "re_measured_full": [
      "clone nông depth 100 (exit 0, 7642 file)",
      "2(a) HEAD aa62a433… KAFKA-20866 #23749, rev-list count 100",
      "2(b) LICENSE gate PASS",
      "2(c) census LOC v9: java 6283/1604486, scala 255/134077, py 185/32772, sh 61/2537",
      "2(d) settings.gradle include verbatim 65 module + gradle.properties (không đổi so run cũ)",
      "2(e) 19 entrypoints Java (khớp tuyệt đối run cũ) + broker main Scala Kafka.scala:73",
      "2(f) top dirs 33 cấp-1 (không đổi)",
      "3) cassian ls-remote exit 0, repo trống"
    ],
    "unchanged_vs_run1_3": ["settings.gradle 65 module", "gradle.properties", "build.gradle head", "gradle wrapper 9.8.2", "entrypoints", "top_dirs", "scala/py/sh LOC", "số file checkout 7642", "cassian trống"],
    "changed_vs_run1_3": ["sha 4b31f507… → aa62a433…", "HEAD commit KAFKA-16304 #23928 → KAFKA-20866 #23749", "java LOC 1604444 → 1604486 (+42 dòng)"]
  }
}
```

## Kết luận

Trạng thái RUN 1–3 (lịch sử): **DONE** — clone đạt lần 1, cổng LICENSE đạt, cartography (a)–(f) đầy đủ, repo đích cassian xác thực được (trống). Token PAT classic dùng one-shot, không ghi vào file nào; **cần rotate sau pilot**.

**RUN 2 (task `goldmine-spec--bootstrap--49038125`) — INHERITED + vá lỗi:** sha trunk khớp tuyệt đối run 1 (`4b31f507…` — xác nhận bằng `git ls-remote` upstream + HEAD cert tại chỗ) → kế thừa mục 1, 2(a)(b)(e)(f). Đo lại phần thiếu: census LOC v9 **sửa số dòng Java 172.740 → 1.604.444** (2 oracle độc lập cùng giá trị); settings.gradle include block nguyên văn (**65 module** + includeBuild `api-checker`, `rootProject.name='kafka'`, rename `:storage:api`→`storage-api`); gradle.properties đầy đủ; cassian ls-remote run 2 (exit 0, trống). Trạng thái run 2: **DONE**.

**RUN 3 (task `goldmine-spec--bootstrap--8a7455e5`) — INHERITED, không còn phần thiếu:** `git ls-remote` upstream trunk → **`4b31f50795397c1fc5f6355993661a2105a40e97` khớp tuyệt đối run 1/2** → kế thừa toàn bộ mục 1, 2(a)–(f) và các kết quả đo lại của run 2 (census v9, settings.gradle 65 module, gradle.properties). Phần duy nhất mang tính thời điểm đã đo lại: cassian `ls-remote` lần 3 — exit 0, stdout rỗng → repo đích vẫn **trống**, token vẫn hợp lệ. Không cần clone lại (không mục nào thiếu). Trạng thái run 3: **DONE**.

**RUN 4 (task `goldmine-spec--bootstrap--ef360255`) — NO-INHERIT (sha upstream dời chỗ), FULL RE-MEASUREMENT:** `git ls-remote` trunk → `aa62a433553c14866521bd40ff446b6920d4d67e` ≠ `4b31f507…` → toàn bộ cartography đo lại tại HEAD mới: clone depth 100 đạt lần 1 (7.642 file); HEAD = KAFKA-20866 #23749; LICENSE gate ĐẠT; census v9 java 1.604.486 (+42 dòng so HEAD cũ), scala/py/sh không đổi; settings.gradle 65 module + gradle.properties + wrapper 9.8.2 **không đổi**; 19 entrypoint Java + broker main Scala khớp tuyệt đối; 33 top-dir không đổi; cassian ls-remote lần 4 — exit 0, repo **trống**, token hợp lệ. Số liệu chuẩn hành cho pipeline: sha **`aa62a433…`**, java LOC **1.604.486**. Token PAT classic one-shot, không ghi file nào; **cần rotate sau pilot**. Trạng thái run 4: **DONE**.
