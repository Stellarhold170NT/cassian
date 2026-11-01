---
subject: google/jimfs
measured_at: 8fa098e0715aa492914285312c07e151d2aace4d
status: final
---


# Folders


## 1. Bản đồ vùng chính (từ `top_dirs` trong gm-01)

gm-01 mục 6 liệt kê `top_dirs = [".", "./jimfs", "./jimfs/src", "./util"]`. Cây repo cực phẳng (find depth-2 chỉ thấy đúng 4 thư mục ngoài `.git`); bảng dưới map từng vùng + vai trò 1 câu, kèm evidence đo lại trên clone PIN này:

| Vùng | Đường dẫn thật | Vai trò (1 câu) | Evidence |
|---|---|---|---|
| Root `.` | `.` (chứa `pom.xml`, `README.md`, `LICENSE`, `CONTRIBUTING.md`, `.github/`, `.gitignore`) | Parent POM Maven + tài liệu dự án: `pom.xml` khai đúng 1 module con và không chứa code. | `File: pom.xml \| Dòng: 29 \| Nội dung: <module>jimfs</module>`; `.github/` chứa đúng 2 file: `.github/dependabot.yml`, `.github/workflows/ci.yml` (find) |
| Module `./jimfs` | `jimfs/` | Maven module duy nhất `com.google.jimfs:jimfs` (packaging `bundle`), nơi chứa toàn bộ source Java của thư viện. | `File: jimfs/pom.xml \| Dòng: 28-30 \| Nội dung: <artifactId>jimfs</artifactId> / <packaging>bundle</packaging>` |
| Source `./jimfs/src` | `jimfs/src/main/java/…`, `jimfs/src/test/java/…` | Chỉ tồn tại đúng 2 cây chuẩn Maven `src/main` + `src/test`, mỗi cây 1 package duy nhất `com/google/common/jimfs` — không có `resources`, không có cây source khác. | `find jimfs/src -type d` → đúng 13 thư mục, chỉ gồm `jimfs/src/{main,test}/java/com/google/common/jimfs`; `find jimfs/src -name 'META-INF' -o -name 'services' -o -name '*.properties' -o -name '*.xml'` → rỗng |
| Tiện ích `./util` | `util/update_snapshot_docs.sh` | Chứa 1 script Bash duy nhất để publish snapshot docs — nằm ngoài mọi cây Maven, không ảnh hưởng universe Java. | `find util -type f` → chỉ `util/update_snapshot_docs.sh`; `File: util/update_snapshot_docs.sh \| Dòng: 1 \| Nội dung: #!/bin/bash` |

Nhận xét: toàn bộ code nằm trong `jimfs/src`; `util/` là vùng phụ duy nhất ở root. Không có entrypoint CLI (gm-01 mục 5) — đây là thư viện thuần nên bản đồ vùng rất ngắn.

## 2. Cấu trúc bên trong 1 đại diện — package `com.google.common.jimfs` (lớn nhất trong gm-02)

gm-02 chỉ có đúng 1 item (`m01`) — package `com.google.common.jimfs` là package lớn nhất và duy nhất của cây `main`. Đây là đại diện được phân tích.

### 2.1 Layout: code chính vs test

| Cây | Đường dẫn | Nội dung |
|---|---|---|
| Code chính | `jimfs/src/main/java/com/google/common/jimfs/` | **62 file `.java`** (61 class + `package-info.java`), **12,468 dòng**, flat hoàn toàn: `find jimfs/src/main/java/com/google/common/jimfs -mindepth 1 -type d \| wc -l` → **0 subpackage** (đo trên thư mục lá package; lệnh trỏ `jimfs/src/main/java` trả 4 — đó là 4 thư mục namespace `com/google/common/jimfs`, không phải subpackage) |
| Test | `jimfs/src/test/java/com/google/common/jimfs/` | **52 file `.java`**, **12,999 dòng** — mirror đúng tên package của main để truy cập package-private internals (gm-02 deps_in); test nhiều hơn main ~4% về LOC |

Vì cùng tên package, ranh giới main/test chỉ nằm ở cây thư mục `src/main` vs `src/test` (chuẩn Maven), không nằm ở package. Lớn nhất mỗi phía: `FileSystemView.java` 744 dòng (main), test có 5 lớp base `Abstract*Test` dùng chung cho nhiều test cụ thể.

### 2.2 Tổ chức bên trong package chính (flat nhưng nhận diện được 10 nhóm theo tên file — bảng phủ đủ 62/62 file)

| Cụm | File (đếm từ `ls`) | Ghi chú |
|---|---|---|
| Facade + SPI (5 file) | `Jimfs.java`, `JimfsFileSystem.java`, `JimfsFileSystemProvider.java`, `JimfsFileSystems.java`, `SystemJimfsFileSystemProvider.java` | Điểm vào public: `File: Jimfs.java \| Dòng: 39 \| Nội dung: Static factory methods for creating new Jimfs file systems.`; `File: Jimfs.java \| Dòng: 79 \| Nội dung: public final class Jimfs {`; SPI đăng ký qua `@AutoService` (mục 4-D2) |
| Cấu hình (6 file) | `Configuration.java` (731 dòng), `PathType.java`, `UnixPathType.java`, `WindowsPathType.java`, `Options.java`, `Feature.java` | Các preset: `File: Configuration.java \| Dòng: 85/133/176/205 \| Nội dung: public static Configuration unix() / osX() / windows() / forCurrentPlatform()` |
| Path & matcher (6 file) | `JimfsPath.java` (441), `PathService.java` (271), `Name.java`, `PathMatchers.java`, `PathNormalization.java`, `GlobToRegex.java` (400) | `File: PathService.java \| Dòng: 48 \| Nội dung: final class PathService implements Comparator<JimfsPath> {` |
| Attributes (13 file) | `AbstractAttributeView`, `AclAttributeProvider`, `AttributeCopyOption`, `AttributeProvider`, `AttributeService`, `BasicAttributeProvider`, `DosAttributeProvider`, `OwnerAttributeProvider`, `PosixAttributeProvider`, `StandardAttributeProviders`, `UnixAttributeProvider`, `UnixFileAttributeView`, `UserDefinedAttributeProvider` | Cụm lớn nhất package; đếm `ls \| grep -ci attrib` → 13 |
| Watch service (3 file) | `AbstractWatchService.java`, `PollingWatchService.java`, `WatchServiceConfiguration.java` | 3 file |
| I/O — channel/stream (7 file) | `DowngradedDirectoryStream.java`, `DowngradedSeekableByteChannel.java`, `JimfsAsynchronousFileChannel.java`, `JimfsFileChannel.java` (678), `JimfsInputStream.java`, `JimfsOutputStream.java`, `JimfsSecureDirectoryStream.java` | 7 file |
| File tree / file store (12 file) | `File.java`, `Directory.java` (355), `DirectoryEntry.java`, `RegularFile.java` (671), `SymbolicLink.java`, `FileTree.java`, `HeapDisk.java`, `FileFactory.java`, `FileLookup.java`, `FileSystemState.java`, `FileSystemView.java` (744), `JimfsFileStore.java` | Lõi lưu trữ: `File: FileSystemView.java \| Dòng: 67 \| Nội dung: final class FileSystemView {` — holds `JimfsFileStore store` + `Directory workingDirectory` (:69-72) |
| URL support (2 file) | `Handler.java`, `PathURLConnection.java` | `File: Handler.java \| Dòng: 39 \| Nội dung: public final class Handler extends URLStreamHandler {` |
| User lookup (1 file) | `UserLookupService.java` | Tra cứu user/principal phục vụ owner attribute |
| Tiện ích mức package (7 file) | `FileTimeSource.java`, `SystemFileTimeSource.java`, `GuardedBy.java`, `InternalCharMatcher.java`, `Java8Compatibility.java`, `Util.java`, `package-info.java` | Helper không gom được vào cụm nghiệp vụ nào ở trên |

Bất biến phủ (đo lại sau review vòng 1): 5 + 6 + 6 + 13 + 3 + 7 + 12 + 2 + 1 + 7 = **62** = tổng file package (`ls jimfs/src/main/java/com/google/common/jimfs/ \| wc -l` → 62); danh sách 62 tên trong bảng khớp 1-1 với `ls` (md5 hai danh sách identical — lệnh trong fix report vòng 1, file `reports/c-folders--fce15710.md`); mỗi file xuất hiện đúng 1 cụm.

### 2.3 Test tree (52 file)

- 43/52 file kết thúc `Test.java` (đếm `ls | grep -c 'Test\.java$'` → 43).
- 9 file helper KHÔNG kết thúc `Test.java`: `BasicFileAttribute.java`, `ByteBufferChannel.java`, `FakeFileTimeSource.java`, `PathSubject.java`, `PathTester.java`, `TestAttributeProvider.java`, `TestAttributeView.java`, `TestAttributes.java`, `TestUtils.java` (liệt kê từ `ls`).
- 5 lớp base trừu tượng: `AbstractAttributeProviderTest`, `AbstractGlobMatcherTest`, `AbstractJimfsIntegrationTest`, `AbstractPathMatcherTest`, `AbstractWatchServiceTest` — các test cụ thể kế thừa (vd `JimfsUnixLikeFileSystemTest`, `JimfsWindowsLikeFileSystemTest`).
- Chỉ 2 import chéo file trong package test (gm-02: `PathTypeTest.java:23`, `PollingWatchServiceTest.java:28-29`) — phần còn lại truy cập trực tiếp vì cùng package.

## 3. Quy ước đặt tên đọc được từ code (≥3 ví dụ)

1. **Prefix `Jimfs*` cho wrapper của kiểu JDK NIO** — 11 file: `Jimfs`, `JimfsAsynchronousFileChannel`, `JimfsFileChannel`, `JimfsFileStore`, `JimfsFileSystem`, `JimfsFileSystemProvider`, `JimfsFileSystems`, `JimfsInputStream`, `JimfsOutputStream`, `JimfsPath`, `JimfsSecureDirectoryStream` (đếm `ls | grep -c '^Jimfs'` → 11). Ví dụ nguyên văn: `File: Jimfs.java | Dòng: 79 | Nội dung: public final class Jimfs {`; `File: Handler.java | Dòng: 39 | Nội dung: public final class Handler extends URLStreamHandler {` (Handler là ngoại lệ có chủ đích, xem mục 5).
2. **Suffix `*AttributeProvider` cho provider thuộc tính** — 9 file: interface `AttributeProvider`, các hiện thực `Basic/Dos/Posix/Acl/Unix/Owner/UserDefinedAttributeProvider`, registry `StandardAttributeProviders` (liệt kê từ `ls`). Quy ước một-hợp-âm với chuẩn JDK view names (`*AttributeView` — `UnixFileAttributeView.java`, `AbstractAttributeView.java`).
3. **Prefix `Abstract*` cho lớp base dùng chung** — main: `AbstractAttributeView.java`, `AbstractWatchService.java`; test: 5 file `Abstract*Test` (liệt kê từ `ls`). Ví dụ nguyên văn: `File: AbstractWatchService.java` (tồn tại trong `ls jimfs/src/main/java/com/google/common/jimfs/`).
4. **Suffix `*Service` cho lớp dịch vụ nội bộ** — `AttributeService.java`, `PathService.java`, `UserLookupService.java` (cùng cụm watch: `PollingWatchService`). Ví dụ nguyên văn: `File: PathService.java | Dòng: 48 | Nội dung: final class PathService implements Comparator<JimfsPath> {` kèm javadoc "Service for creating JimfsPath instances and handling other path-related operations."
5. **Test helper theo mẫu Google Truth/`*Tester`** — `PathSubject.java` (Truth `Subject`), `PathTester.java`, `TestUtils.java`, tiền tố `Test*` cho fake (`TestAttributeProvider`, `TestAttributes`, `FakeFileTimeSource`) — phân biệt rõ với 43 file `*Test` thật.
6. **Tên bắt buộc bởi contract JDK** — `Handler` phải tên đúng vậy để JDK tìm thấy qua `URL`: `File: Handler.java | Dòng: 29-31 | Nội dung: {@link URLStreamHandler} implementation for jimfs. Named {@code Handler} so that the class can be found by Java as described in the documentation for {@link URL#URL(String, String, int, String) URL}.`

## 4. Chỗ LỆCH chuẩn Java (mỗi chỗ ≥2 ví dụ; đã quét toàn cây, không bịa)

**D1 — Một package phẳng duy nhất, 0 subpackage dù 62 file.** Chuẩn Java/Maven cho dự án cỡ 12k LOC thường tách subpackage theo chức năng; jimfs giữ mọi class trong `com.google.common.jimfs`.
- Ví dụ 1: `find jimfs/src/main/java/com/google/common/jimfs -mindepth 1 -type d | wc -l` → **0** (62 file nằm đúng 1 thư mục; dưới `jimfs/src/main/java` chỉ có 4 thư mục namespace `com/google/common/jimfs` — lệnh trỏ `jimfs/src/main/java` trả 4, đúng bằng các thư mục trỏ tên package chứ không phải subpackage).
- Ví dụ 2: 3 cụm chức năng độc lập cùng nằm phẳng trong 1 thư mục — cụm attributes 13 file, cụm watch 3 file, cụm I/O 7 file (bảng mục 2.2, lấy từ `ls`) — thay vì tách `…jimfs/attributes/`, `…jimfs/watch/`, `…jimfs/io/`.

**D2 — Không có `src/main/resources`; file đăng ký SPI không tồn tại trong cây source mà được sinh lúc build.** Chuẩn Java classic commit `META-INF/services/<SPI>` vào `src/main/resources`.
- Ví dụ 1: `find jimfs/src -name 'META-INF' -o -name 'services' -o -name '*.properties' -o -name '*.xml'` → **rỗng**; `find jimfs/src -type d` không thấy bất kỳ thư mục `resources` nào (chỉ `main/java` + `test/java`).
- Ví dụ 2: `File: jimfs/src/main/java/com/google/common/jimfs/SystemJimfsFileSystemProvider.java | Dòng: 23 | Nội dung: import com.google.auto.service.AutoService;` và `Dòng: 62 | Nội dung: @AutoService(FileSystemProvider.class)` → `META-INF/services/java.nio.file.spi.FileSystemProvider` được AutoService sinh khi build thay vì commit (khớp ghi chú gm-02 deps_in).

**D3 — Test tree không theo mẫu JUnit nghiêm ngặt "1 class test = 1 `*Test`".**
- Ví dụ 1: 9/52 file test không kết thúc `Test.java` (mục 2.3: `PathSubject.java`, `PathTester.java`, `TestUtils.java`, `TestAttributes.java`, `TestAttributeProvider.java`, `TestAttributeView.java`, `BasicFileAttribute.java`, `ByteBufferChannel.java`, `FakeFileTimeSource.java`) — đây là helper/fake nằm chung package test.
- Ví dụ 2: 5 lớp base `Abstract*Test` (mục 2.3) làm nền kế thừa cho test cụ thể (`JimfsUnixLikeFileSystemTest`, `JimfsWindowsLikeFileSystemTest`…) — cấu trúc test kế thừa thay vì mỗi test tự đứng.

**Các khu vực KHÔNG phát hiện lệch đáng kể (ghi rõ + evidence):** layout Maven chuẩn được tuân thủ ở mọi cấp còn lại — parent pom khai đúng 1 module (`File: pom.xml | Dòng: 29 | Nội dung: <module>jimfs</module>`), cặp `src/main/java` + `src/test/java` đúng chuẩn, package ngược-domain `com.google.common.jimfs` đúng quy ước, có `package-info.java` cho annotation tiện mức package. Ngoài 3 điểm D1–D3 ở trên không tìm thấy lệch cấu trúc nào khác khi quét toàn bộ cây `jimfs/src` + root (find depth-2, find src -type d — evidence ở mục 1).

## 5. Gợi ý đọc hiểu (đọc thư mục nào trước, vì sao)

Thư mục đọc đầu tiên: **`jimfs/src/main/java/com/google/common/jimfs/`** — toàn bộ code chính nằm ở đó (62 file, 1 package), còn root chỉ còn pom/docs và `util/` chỉ 1 script. Thứ tự trong thư mục (từ API public đi vào nội bộ):

1. `pom.xml` (root) + `jimfs/pom.xml` — xác nhận 1 module, deps Guava/ICU4J; sau đó `README.md` cho cách dùng (không cần đọc `util/`).
2. `Jimfs.java` — facade tạo FileSystem: `File: Jimfs.java | Dòng: 96 | Nội dung: public static FileSystem newFileSystem() {` resolve qua `Configuration.forCurrentPlatform()` tại `Dòng: 114 | Nội dung: return newFileSystem(name, Configuration.forCurrentPlatform());`.
3. `Configuration.java` — hồ sơ cấu hình (preset `unix()/osX()/windows()/forCurrentPlatform()` tại :85/:133/:176/:205) rồi `PathType.java` + `UnixPathType/WindowsPathType` — cú pháp path từng nền tảng.
4. `JimfsFileSystemProvider.java` + `SystemJimfsFileSystemProvider.java` — 2 đường vào SPI (instance do user tạo vs provider hệ thống đăng ký @AutoService).
5. `FileSystemView.java` (744 dòng, file lớn nhất) — `File: FileSystemView.java | Dòng: 57-59 | Nội dung: this class contains the implementation of most file system operations, with relative path operations resolving against the working directory.` — đây là trung tâm mọi thao tác; đọc cùng `JimfsFileSystem.java`.
6. Nội bộ lưu trữ: `FileTree.java` (`Dòng: 38 | Nội dung: final class FileTree {` — javadoc: "The tree of directories and files for the file system. Contains the file system root directories and provides the ability to look up files by path."), `Directory.java` (:32 — "A table of DirectoryEntry"), `RegularFile.java` (:45 — "A mutable, resizable store for bytes. Bytes are stored in fixed-sized byte arrays (blocks) allocated by a HeapDisk."), `HeapDisk.java` (:37 — "A resizable pseudo-disk acting as a shared space for storing file data.").
7. Watch service (`AbstractWatchService` → `PollingWatchService`, `WatchServiceConfiguration`) và URL support (`Handler`, `PathURLConnection`) đọc cuối — hai tiện ích độc lập với lõi.

Vì sao thứ tự này: package phẳng nên không có "thư mục trước sau" theo tầng; duy nhất mối quan hệ phụ thuộc là API public → cấu hình → thao tác → cây file/đĩa. Đọc theo cụm tên file (mục 2.2) là cách điều hướng hiệu quả nhất; cây `jimfs/src/test/java/...` chỉ đọc kèm khi cần ví dụ gọi API (mirror cùng package, có sẵn `PathSubject`/`PathTester`).

## Verification notes (chống bịa)

- Mọi lệnh trong phiên này chạy trên clone tại `/workspace/jimfs` (sandbox `bitnami/git:latest` riêng của node), HEAD khớp PIN `8fa098e0715aa492914285312c07e151d2aace4d` của gm-01/gm-02 — không dùng HEAD khác.
- Mỗi `file:line` trong report đã grep-verified trên clone này; các con số (62/12,468; 52/12,999; 744; 731; 271 PathService; 11 Jimfs*; 9 *AttributeProvider; 13/3/7 cụm; 13 thư mục src; 0 subpackage đo từ thư mục lá; 43+9 test; 5 Abstract*Test) đều reproduce bằng lệnh đã nêu.
- Source-vs-brief: không phát hiện conflict — mọi số liệu đối chiếu với gm-01 (mục 3, 6, 7) và gm-02 (item m01) đều khớp. Nhận định "đo lại là dòng 28" ở bản vòng 1 là **SAI và đã rút**: `grep -n 'ParametersAreNonnullByDefault' jimfs/src/main/java/com/google/common/jimfs/package-info.java` → `27:import javax.annotation.ParametersAreNonnullByDefault;` — pointer `package-info.java:27` của gm-02 **đúng**. Sai sót gốc: suy số dòng từ khối `sed -n '24,28p'` hiển thị (dòng trống bị render làm lệch nhận dạng); bài học: pointer line-number chỉ nhận từ `grep -n`, không suy từ khối sed in ra.
- Rev 2 (sau review vòng 1/2): sửa B1 14→13 thư mục (`find jimfs/src -type d | wc -l` → 13); B2 cặp lệnh mindepth trỏ đúng thư mục lá package (lệnh cũ trỏ `jimfs/src/main/java` trả 4, không phải 0); B3 PathService 426→271 (`wc -l` → 271; 426 là LOC của AttributeService); B4 bảng cụm phủ đủ 62/62 (bổ sung `JimfsFileSystem.java`, `DirectoryEntry.java`, `UserLookupService.java` + hàng tiện ích; md5 bảng vs `ls` identical); B5 rút "đính chính" sai, xác nhận gm-02 `:27` đúng.
- Không đụng phạm vi subject khác; không push repo nào (node chỉ thu nhận cấu trúc, publish là việc node sau).
