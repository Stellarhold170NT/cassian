---
subject: google/jimfs
measured_at: 8fa098e0715aa492914285312c07e151d2aace4d
status: final
---


# Cartography


## 0. Clone nông

```
$ git clone --depth 100 --single-branch https://github.com/google/jimfs /workspace/jimfs
Cloning into '/workspace/jimfs'...
$ cd /workspace/jimfs && git branch --show-current
master
```
Nhận xét: clone nông depth 100, nhánh `master` — đúng brief.

## 1. HEAD + commit count

```
$ git log -1 --format='%H %ci %s'
8fa098e0715aa492914285312c07e151d2aace4d 2026-10-22 08:59:22 -0700 Bump org.sonatype.central:central-publishing-maven-plugin from 0.11.0 to 0.12.0 in the dependencies group
$ git rev-list --count HEAD
100 (shallow ≤100)
```
Nhận xét: **PIN = `8fa098e0715aa492914285312c07e151d2aace4d`**; clone nông nên 100 là số commit thấy được (cận dưới, không phải tổng lịch sử repo).

## 2. LICENSE gate

```
$ ls -la | grep -i license
-rw-r--r-- 1 root root 11357 Nov  1 15:56 LICENSE
$ ls LICENSE*
LICENSE
$ head -3 LICENSE

                                 Apache License
                           Version 2.0, January 2004
```
Nhận xét: LICENSE tồn tại (Apache-2.0, 11,357 bytes) → **cổng license PASS**, không BLOCKED.

## 3. Census LOC (công thức v9 — từng extension rồi CỘNG, cấm `xargs wc -l | tail -1`)

```
$ for ext in java; do
    n=$(find . -type f -name "*.$ext" -not -path './.git/*' | wc -l)
    l=$(find . -type f -name "*.$ext" -not -path './.git/*' -print0 | xargs -0 cat | wc -l)
    echo "EXT .$ext files=$n lines=$l"
  done
EXT .java files=114 lines=25467
```

Bổ sung (phân tách main/test cho node sau — cùng công thức census):

```
$ find ./jimfs/src/main -type f -name '*.java' | wc -l        → 62
$ find ./jimfs/src/main -type f -name '*.java' -print0 | xargs -0 cat | wc -l  → 12468
$ find ./jimfs/src/test -type f -name '*.java' | wc -l        → 52
$ find ./jimfs/src/test -type f -name '*.java' -print0 | xargs -0 cat | wc -l  → 12999
```

Nhận xét: bất biến census khớp tuyệt đối — 62 (main) + 52 (test) = **114 file**, 12,468 + 12,999 = **25,467 dòng**. Test KHÔNG thành item (vào oracle S3 theo định nghĩa subject jimfs).

## 4. Build manifests (pom.xml — nguồn đối chiếu universe)

```
$ wc -l pom.xml
371 pom.xml
```

Phần khai báo nguyên văn (pom.xml gốc, root):

```xml
  <groupId>com.google.jimfs</groupId>
  <artifactId>jimfs-parent</artifactId>
  <packaging>pom</packaging>
  <version>HEAD-SNAPSHOT</version>

  <modules>
    <module>jimfs</module>
  </modules>

  <name>Jimfs Parent</name>

  <description>
    Jimfs is an in-memory implementation of Java 7's java.nio.file abstract file system API.
  </description>

  <url>https://github.com/google/jimfs</url>

  <licenses>
    <license>
      <name>The Apache Software License, Version 2.0</name>
      <url>https://www.apache.org/licenses/LICENSE-2.0.txt</url>
      <distribution>repo</distribution>
    </license>
  </licenses>
```

Xác minh số module trong parent pom:

```
$ grep -n 'module' pom.xml
28:  <modules>
29:    <module>jimfs</module>
30:  </modules>
```

Khai báo pom con (`jimfs/pom.xml`, trích):

```xml
    <groupId>com.google.jimfs</groupId>
    <artifactId>jimfs-parent</artifactId>
    <version>HEAD-SNAPSHOT</version>
  </parent>

  <artifactId>jimfs</artifactId>

  <packaging>bundle</packaging>

  <name>Jimfs</name>
      <groupId>com.google.guava</groupId>
      <artifactId>guava</artifactId>
```

Nhận xét: parent chỉ khai **đúng 1 module `<module>jimfs</module>`** → xác nhận định nghĩa AGENTS.md: jimfs = **MỘT maven module duy nhất**; module con `com.google.jimfs:jimfs` (packaging bundle), phụ thuộc Guava.

## 5. Entrypoints

```
$ grep -rln 'public static void main' jimfs/src | head -20
(không có output — 0 kết quả)
```
Nhận xét: jimfs là **thư viện thuần**, không có CLI entrypoint nào → `entrypoints = []` (hợp lệ với bản chất library).

## 6. Top dirs

Lệnh chạy có thêm bộ lọc `.git` so với brief (`.git` chỉ là metadata của clone, không thuộc cây source — ghi rõ đây là biến thể):

```
$ find . -maxdepth 2 -type d -not -path './.git*' | sort | head -80
.
./jimfs
./jimfs/src
./util
```

Nội dung `util/`:

```
$ find util -type f
util/update_snapshot_docs.sh
```
Nhận xét: cây repo cực phẳng — toàn bộ source nằm trong `jimfs/src`; `util/` chỉ chứa 1 script shell, không ảnh hưởng universe Java.

## 7. Java package universe (dưới `jimfs/src/main/java`)

Maven POM không khai báo package → danh sách package suy ra từ cây source (đây là nguồn đối chiếu universe cho gm-02+):

```
$ find jimfs/src/main/java -type d | sed 's|jimfs/src/main/java/||' | grep -v '^jimfs/src/main/java$' | sort
com
com/google
com/google/common
com/google/common/jimfs

$ find jimfs/src/main/java/com/google/common/jimfs -maxdepth 1 -name '*.java' | wc -l
62
$ find jimfs/src/main/java/com/google/common/jimfs -mindepth 1 -type d | wc -l
0
```
Nhận xét: **universe = đúng 1 package lá duy nhất `com.google.common.jimfs`** (62 file .java, ~12,468 LOC main, 0 subpackage). Theo đơn vị item của jimfs (cấp package), pipeline này có **1 item duy nhất** — subject < 4 item → worker trống tick `DRAINED wN` với 0 item là hợp lệ.

## 8. Repo đích cassian (CHỈ ĐỌC, không push)

```
$ git ls-remote https://x-access-token:$TOKEN@github.com/Stellarhold170NT/cassian.git HEAD
04d718b57b60dfe354663c45a3affda2f7c0805f	HEAD
```
Nhận xét: token hợp lệ, remote trả HEAD bình thường → **cassian: VERIFIED**.

---

## JSON block

```json
{
  "repo": "https://github.com/google/jimfs",
  "upstream_branch": "master",
  "sha": "8fa098e0715aa492914285312c07e151d2aace4d",
  "commit_count_shallow": 100,
  "languages": [
    { "ext": "java", "scope": "all", "files": 114, "lines": 25467 },
    { "ext": "java", "scope": "main", "files": 62, "lines": 12468 },
    { "ext": "java", "scope": "test", "files": 52, "lines": 12999 }
  ],
  "manifests": [
    {
      "file": "pom.xml",
      "type": "maven-parent",
      "groupId": "com.google.jimfs",
      "artifactId": "jimfs-parent",
      "version": "HEAD-SNAPSHOT",
      "packaging": "pom",
      "modules": ["jimfs"],
      "license": "Apache-2.0"
    },
    {
      "file": "jimfs/pom.xml",
      "type": "maven-module",
      "groupId": "com.google.jimfs",
      "artifactId": "jimfs",
      "packaging": "bundle",
      "dependencies": ["com.google.guava:guava"]
    }
  ],
  "java_packages": [
    {
      "package": "com.google.common.jimfs",
      "path": "jimfs/src/main/java/com/google/common/jimfs",
      "files": 62,
      "subpackages": 0,
      "universe_items": 1,
      "note": "single leaf package; Maven POM does not declare packages — list derived from jimfs/src/main/java tree"
    }
  ],
  "entrypoints": [],
  "top_dirs": [".", "./jimfs", "./jimfs/src", "./util"],
  "cassian_target": {
    "remote": "https://github.com/Stellarhold170NT/cassian.git",
    "head": "04d718b57b60dfe354663c45a3affda2f7c0805f",
    "status": "VERIFIED"
  }
}
```
