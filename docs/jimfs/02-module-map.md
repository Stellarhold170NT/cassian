---
subject: google/jimfs
measured_at: 8fa098e0715aa492914285312c07e151d2aace4d
status: final
---


# Module map

JimFS is **one Maven module** (root `pom.xml` declares a single `<module>jimfs</module>`),
so the item universe is Java packages under `jimfs/src/main/java` — the scan produced
exactly **1 item**. All figures below were measured on the pinned tree
(`8fa098e0715aa492914285312c07e151d2aace4d`, branch `master`) by worker w1 and re-verified by the map gate (3 rounds).

| module | path | responsibility | main_files | deps_in / deps_out | loc | status |
|---|---|---|---|---|---|---|
<a id="m01-comgooglecommonjimfs"></a>| `com.google.common.jimfs` | `jimfs/src/main/java/com/google/common/jimfs` | Complete in-memory implementation of Java 7's `java.nio.file` API as one flat package — `Jimfs.java` is the public facade that creates `FileSystem` instances from `Configuration` presets (unix/osX/windows/forCurrentPlatform), while `FileSystemView.java` (largest file) contains the implementation of most file-system operations, resolving relative paths against its working directory over the internal file tree. | `Jimfs.java` (facade; class javadoc verbatim `Jimfs.java:39` "Static factory methods for creating new Jimfs file systems."; entry `Jimfs.java:79 public final class Jimfs {`; `Jimfs.java:96 public static FileSystem newFileSystem()` resolving to `Configuration.forCurrentPlatform()` at `Jimfs.java:114`), `FileSystemView.java` (largest, 744 lines, `FileSystemView.java:67 final class FileSystemView {`; javadoc at :57-59; `JimfsFileStore store` + `Directory workingDirectory` at :69-72), `Configuration.java` (731 lines, factories `unix()`/`osX()`/`windows()`/`forCurrentPlatform()` at :85/:133/:176/:205) | **in**: test tree mirrors the same package (`jimfs/src/test/java/com/google/common/jimfs`, 52 files, in-package access to internals; only 2 explicit cross-file test imports: `PathTypeTest.java:23`, `PollingWatchServiceTest.java:28-29`); external consumers via JDK SPI — `SystemJimfsFileSystemProvider.java:62 @AutoService(FileSystemProvider.class)` for `ServiceLoader` + public facade `Jimfs.newFileSystem(...)` <br> **out**: 704 import statements total = 586 plain + 118 static (`grep -rh '^import ' jimfs/src/main/java | wc -l` → 704); buckets count **plain imports**, statics noted separately: JDK `java.nio.file` 188 plain (+23 static → 211 combined; the NIO SPI/API contract), `java.util.concurrent` 40 (+1 static), `java.io` 43, `java.nio.channels` 29, `java.net` 19, nio buffers 7, `java.nio.charset` 0 plain (1 static — `PathURLConnection.java:20`), misc JDK (text 3, logging 2, time 1, math 1, `javax.annotation.ParametersAreNonnullByDefault` 1 at `package-info.java:27`); Guava `com.google.common.*` 191 total (110 plain + 81 static), in-package static 15 across 7 files, **cross-boundary Guava = 176** (= 175 strictly-cross: 109 plain + 66 static; + 1 plain in-package nested-type import `PathType.ParseResult` at `PathService.java:33`; 50/62 files; declared in `jimfs/pom.xml`); `com.google.errorprone.annotations` 12 files (e.g. `FileSystemState.java:24`); `org.jspecify.annotations` (`Nullable`) 31 files; `com.google.auto.service.AutoService` (`SystemJimfsFileSystemProvider.java:23`); `com.ibm.icu.lang.UCharacter` 1 import (`PathNormalization.java:21`, required by `CASE_FOLD_UNICODE` :72, guard message :80) | 12468 (62 files) | DONE |

## Dependency edges

- **In-universe:** none — the subject ships a single package, so there are no
  cross-item edges to draw. The dependency story is entirely item↔external.
- **deps_in (external):** the test tree mirrors the same package
  (`jimfs/src/test/java/com/google/common/jimfs`, 52 files, in-package access;
  only 2 explicit cross-file test imports: `PathTypeTest.java:23`,
  `PollingWatchServiceTest.java:28-29`); external consumers reach the library
  through the JDK SPI — `SystemJimfsFileSystemProvider.java:62
  @AutoService(FileSystemProvider.class)` for `ServiceLoader` — plus the public
  facade `Jimfs.newFileSystem(...)`.
- **deps_out (external):** 704 import statements total = 586 plain + 118 static.
  JDK: `java.nio.file` 188 plain (+23 static → 211 combined; the NIO SPI/API
  contract), `java.util.concurrent` 40 (+1 static), `java.io` 43,
  `java.nio.channels` 29, `java.net` 19, nio buffers 7, `java.nio.charset`
  0 plain (1 static — `PathURLConnection.java:20`), misc JDK (text 3, logging 2,
  time 1, math 1, `javax.annotation.ParametersAreNonnullByDefault` 1 at
  `package-info.java:27`). Guava `com.google.common.*` 191 total (110 plain +
  81 static), in-package static 15 across 7 files, cross-boundary Guava = 176
  (50/62 files; declared in `jimfs/pom.xml`). Also `com.google.errorprone.annotations`
  (12 files), `org.jspecify.annotations` (31 files),
  `com.google.auto.service.AutoService` (`SystemJimfsFileSystemProvider.java:23`),
  `com.ibm.icu.lang.UCharacter` 1 import (`PathNormalization.java:21`).

## Coverage note

| Slot | Items owned | Verdict |
|---|---|---|
| w1 | 1 (m01) | DONE — full row with re-measured census 62 files / 12468 LOC |
| w2–w4 | 0 | `DRAINED` (valid: universe is 1 package, assigned to w1) |

No UNOWNED items exist. Rating for m01: **5★** (see `specs/jimfs/com.google.common.jimfs.plan.md`
and the rubric trace in the star report).
