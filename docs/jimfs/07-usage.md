---
subject: google/jimfs
measured_at: 8fa098e0715aa492914285312c07e151d2aace4d
status: final
---


# Usage


## 1. Merge inputs (joinPolicy all — fail-closed check passed)

| Input | Content |
|---|---|
| `reports/jimfs/u-checklist.json` | 1 item total: `s01` (`com.google.common.jimfs`, 5★, main_files `Jimfs.java` / `FileSystemView.java` / `Configuration.java`) |
| `reports/jimfs/gm-12-usage-w1.md` + `reports/jimfs/u-status-w1.json` | w1: 1/1 item — tick `{"s_id":"s01","section_done":true,"examples":3,"evidence_lines":32}`; part ends "item s01 fully written (3 numbered use cases + 1 documented SPI note)" |
| `reports/jimfs/gm-12-usage-w2.md` + `reports/jimfs/u-status-w2.json` | w2: 0 item — `[]` (`DRAINED w2 — 0 item`, valid: universe = 1 item, all to u_w1 per `u-usage-plan.md` §3) |

→ not BLOCKED: all 4 required files present; merge proceeds, nothing fabricated.

## 2. Item table (all u-checklist items — columns: module | dùng khi nào | deps_out)

| module | dùng khi nào (use when) | deps_out |
|---|---|---|
| `com.google.common.jimfs` | In-memory `java.nio.file.FileSystem` for tests and path-sensitive code. **UC1** — scratch disk for unit tests that touch real file I/O: `try (FileSystem fs = Jimfs.newFileSystem())` then plain `Files.createDirectories` / `Files.write` / `Files.readAllBytes` (`Jimfs.java:96`; oracle `JimfsUnixLikeFileSystemTest.java:301/795`, `JimfsFileSystemCloseTest.java:275`, `ClassLoaderTest.java:117`). **UC2** — emulate a Windows (or Unix) path environment on a different host OS: `Jimfs.newFileSystem(Configuration.windows())` with drive-root/backslash separators and case-insensitive lookup (`Configuration.java:176`; oracle `ConfigurationTest.java:149/152/159/161`). **UC3** — custom configuration via the builder: `Configuration.unix().toBuilder().setWorkingDirectory(...).setAttributeViews(...).setDefaultAttributeValue(...).setMaxSize(...).build()` (`Configuration.java:317/688/569/632/492/727`; oracle `ConfigurationTest.java:243-247/234/182`). **SPI note (unnumbered)** — second entry point via JDK `ServiceLoader` / `jimfs://` URIs (`Jimfs.java:82`; `SystemJimfsFileSystemProvider.java:62/97/102/136`). | `com.google.jimfs:jimfs` — the artifact itself (`jimfs/pom.xml:23-28`); Guava `com.google.guava:guava` declared dependency (`jimfs/pom.xml:42`, root pom pins `33.7.2-jre`; 176 cross-boundary imports per gm-02); JDK `java.nio.file` — the API surface the examples program against (188 plain imports per gm-02); `com.google.auto.service:auto-service-annotations` — only for the SPI provider (root `pom.xml:109-110`); `com.ibm.icu:icu4j` — only for `CASE_FOLD_UNICODE` normalization (`PathNormalization.java:21/72/80`), not used by the examples; `org.jspecify.annotations` (31 files) + `com.google.errorprone.annotations` (12 files) — compile-time annotations of the main tree |

## 3. Deep sections (one per u-checklist item, in checklist id order)

### s01 — `com.google.common.jimfs`

Carried verbatim from `reports/jimfs/gm-12-usage-w1.md` (grep-verified there on
a clone at PIN `8fa098e0715aa492914285312c07e151d2aace4d`; clone via
`git clone --depth 100 --single-branch https://github.com/google/jimfs`, branch
`master`).

#### (a) What problem this item solves

The package is a complete in-memory implementation of Java 7's `java.nio.file` API
published as one flat package: `Jimfs.java` is the public facade that creates
`FileSystem` instances from `Configuration` presets (`unix`/`osX`/`windows`/
`forCurrentPlatform`), while `FileSystemView` (largest file) implements most file
system operations, resolving relative paths against its working directory
(responsibility carried from `gm-02-part-w1.md` §m01).

Source anchors (grep-verified at PIN):

- File: jimfs/src/main/java/com/google/common/jimfs/Jimfs.java | Dòng: 79 | Nội dung: `public final class Jimfs {` — public facade; class javadoc (gm-02, Jimfs.java:39 verbatim): "Static factory methods for creating new Jimfs file systems."
- File: jimfs/src/main/java/com/google/common/jimfs/FileSystemView.java | Dòng: 57-59 | Nội dung: "View of a file system with a specific working directory. As all file system operations need to / work when given either relative or absolute paths, this class contains the implementation of most / file system operations, with relative path operations resolving against the working directory."
- File: jimfs/src/main/java/com/google/common/jimfs/FileSystemView.java | Dòng: 67 | Nội dung: `final class FileSystemView {`
- File: jimfs/src/main/java/com/google/common/jimfs/Configuration.java | Dòng: 85/133/176/205 | Nội dung: `public static Configuration unix() {` / `osX() {` / `windows() {` / `forCurrentPlatform() {` — the four presets.

#### (b) + (c) Use cases (real APIs at PIN; evidence under every example)

##### UC1 — In-memory scratch disk for unit tests that touch real file I/O

Scenario: a unit test needs to create directories and write/read a real file, but
touching the host disk (or an OS-specific temp dir) makes the test slow, dirty and
platform-dependent. Jimfs hands the test a fully working `java.nio.file.FileSystem`
in RAM; the code under test keeps using plain `Files.*` calls unchanged. The no-arg
facade picks the configuration preset matching the current OS.

```java
import static java.nio.charset.StandardCharsets.UTF_8;

import com.google.common.jimfs.Jimfs;
import java.io.IOException;
import java.nio.file.FileSystem;
import java.nio.file.Files;
import java.nio.file.Path;

public class ReportStoreTest {

  public void writesAndReadsAReportInMemory() throws IOException {
    try (FileSystem fs = Jimfs.newFileSystem()) {          // preset for the current OS
      Files.createDirectories(fs.getPath("/work/data"));

      Path report = fs.getPath("/work/data/report.txt");
      Files.write(report, "daily totals".getBytes(UTF_8));

      byte[] read = Files.readAllBytes(report);            // read back inside the test
      // assert on `read` here
    }
  }
}
```

Evidence (every API in the example grep-verified at PIN):

- File: jimfs/src/main/java/com/google/common/jimfs/Jimfs.java | Dòng: 96 | Nội dung: `public static FileSystem newFileSystem() {`
- File: jimfs/src/main/java/com/google/common/jimfs/Jimfs.java | Dòng: 113-114 | Nội dung: `public static FileSystem newFileSystem(String name) {` / `return newFileSystem(name, Configuration.forCurrentPlatform());` — the no-arg overload reaches `forCurrentPlatform()` through this chain (note: the direct `forCurrentPlatform()` call sits at :114, which is exactly the pointer carried by u-checklist.json).
- File: jimfs/src/test/java/com/google/common/jimfs/JimfsUnixLikeFileSystemTest.java | Dòng: 301 | Nội dung: `Files.createDirectories(path("/foo/bar"));` — `Files.createDirectories` call site in the mirrored test oracle.
- File: jimfs/src/test/java/com/google/common/jimfs/JimfsUnixLikeFileSystemTest.java | Dòng: 795 | Nội dung: `Files.write(path("/test"), new byte[] {0, 1, 2, 3});` — `Files.write(Path, byte[])` call site (also :151 `Files.write(fs.getPath("/foo"), new byte[10000]);`).
- File: jimfs/src/test/java/com/google/common/jimfs/JimfsFileSystemCloseTest.java | Dòng: 275 | Nội dung: `assertThrows(ClosedFileSystemException.class, () -> Files.readAllBytes(file));` — `Files.readAllBytes` call site (also PathSubject.java:345).
- File: jimfs/src/test/java/com/google/common/jimfs/ClassLoaderTest.java | Dòng: 117 | Nội dung: `List<String> lines = Files.readAllLines(p, UTF_8);` — `UTF_8` charset constant used with `Files.*` in the test oracle.

##### UC2 — Emulate a Windows (or Unix) path environment on a different host OS

Scenario: code that builds and parses Windows-style paths (drive roots,
backslash separators) must be tested on a Linux CI machine that has no `C:\`
drive. Creating the in-memory file system with `Configuration.windows()` gives
that exact path syntax — drive-letter roots, `\` separators, case-insensitive
lookup — so path-handling logic runs against realistic Windows paths anywhere.
The mirror image (`Configuration.unix()` on Windows hosts) works identically.

```java
import static java.nio.charset.StandardCharsets.UTF_8;

import com.google.common.jimfs.Configuration;
import com.google.common.jimfs.Jimfs;
import java.io.IOException;
import java.nio.file.FileSystem;
import java.nio.file.Files;
import java.nio.file.Path;

public class WindowsPathHandlingTest {

  public void resolvesWindowsStylePathsOnLinuxCI() throws IOException {
    try (FileSystem fs = Jimfs.newFileSystem(Configuration.windows())) {
      Files.createDirectories(fs.getPath("C:\\work\\out"));

      Path csv = fs.getPath("C:\\work\\out\\totals.csv");  // drive-root syntax like real Windows
      Files.write(csv, "a,b\n1,2\n".getBytes(UTF_8));

      Files.readAllLines(csv, UTF_8);                      // parsed line by line, same as on Windows
    }
  }
}
```

Evidence (grep-verified at PIN):

- File: jimfs/src/main/java/com/google/common/jimfs/Configuration.java | Dòng: 176 | Nội dung: `public static Configuration windows() {`
- File: jimfs/src/test/java/com/google/common/jimfs/ConfigurationTest.java | Dòng: 149 | Nội dung: `FileSystem fs = Jimfs.newFileSystem(Configuration.windows());` — the exact composition used in the example.
- File: jimfs/src/test/java/com/google/common/jimfs/ConfigurationTest.java | Dòng: 152 | Nội dung: `.containsExactlyElementsIn(ImmutableList.of(fs.getPath("C:\\")))` — drive-root `getPath` syntax on the windows configuration.
- File: jimfs/src/test/java/com/google/common/jimfs/ConfigurationTest.java | Dòng: 159 | Nội dung: `Files.createFile(fs.getPath("C:\\foo"));` — backslash path syntax feeding a `Files.*` operation (:161 adds the case-insensitivity check `Files.createFile(fs.getPath("C:\\FOO"))` throwing `FileAlreadyExistsException`).
- File: jimfs/src/test/java/com/google/common/jimfs/JimfsUnixLikeFileSystemTest.java | Dòng: 301 | Nội dung: `Files.createDirectories(path("/foo/bar"));` — `Files.createDirectories` call site.
- File: jimfs/src/test/java/com/google/common/jimfs/ClassLoaderTest.java | Dòng: 117 | Nội dung: `List<String> lines = Files.readAllLines(p, UTF_8);` — `Files.readAllLines` call site.

##### UC3 — Custom configuration via the builder: default POSIX permissions, working directory, size cap

Scenario: an integration test needs a file system that behaves like a real
POSIX volume: files created with default permissions, relative paths resolving
against a chosen working directory, and a hard total-size cap to exercise
"disk full" handling. `Configuration.unix().toBuilder()` starts from the unix
preset and overrides exactly those knobs, then `Jimfs.newFileSystem(config)`
materializes it.

```java
import com.google.common.jimfs.Configuration;
import com.google.common.jimfs.Jimfs;
import java.io.IOException;
import java.nio.file.FileSystem;
import java.nio.file.Files;
import java.nio.file.attribute.PosixFilePermissions;

public class QuotaAndPermsTest {

  public void buildsPosixLikeFsWithDefaultPermissions() throws IOException {
    Configuration config = Configuration.unix().toBuilder()   // start from the unix preset
        .setWorkingDirectory("/work")
        .setAttributeViews("basic", "posix")
        .setDefaultAttributeValue(
            "posix:permissions", PosixFilePermissions.fromString("rw-r--r--"))
        .setMaxSize(100)
        .build();

    try (FileSystem fs = Jimfs.newFileSystem(config)) {
      Files.createFile(fs.getPath("/data.txt"));              // created with the default perms
      Files.getAttribute(fs.getPath("/data.txt"), "posix:permissions");
    }
  }
}
```

Evidence (grep-verified at PIN):

- File: jimfs/src/main/java/com/google/common/jimfs/Configuration.java | Dòng: 317 | Nội dung: `public Builder toBuilder() {`
- File: jimfs/src/test/java/com/google/common/jimfs/ConfigurationTest.java | Dòng: 243-247 | Nội dung: `public void testToBuilder() {` — `Configuration.unix().toBuilder().setWorkingDirectory("/hello/world").setAttributeViews("basic", "posix").build();` — the same chain shape as the example.
- File: jimfs/src/main/java/com/google/common/jimfs/Configuration.java | Dòng: 688 | Nội dung: `public Builder setWorkingDirectory(String workingDirectory) {`
- File: jimfs/src/main/java/com/google/common/jimfs/Configuration.java | Dòng: 569 | Nội dung: `public Builder setAttributeViews(String first, String... more) {`
- File: jimfs/src/main/java/com/google/common/jimfs/Configuration.java | Dòng: 632 | Nội dung: `public Builder setDefaultAttributeValue(String attribute, Object value) {`
- File: jimfs/src/main/java/com/google/common/jimfs/Configuration.java | Dòng: 492 | Nội dung: `public Builder setMaxSize(long maxSize) {`
- File: jimfs/src/main/java/com/google/common/jimfs/Configuration.java | Dòng: 727 | Nội dung: `public Configuration build() {`
- File: jimfs/src/main/java/com/google/common/jimfs/Jimfs.java | Dòng: 118 | Nội dung: `public static FileSystem newFileSystem(Configuration configuration) {` — composed in tests at ConfigurationTest.java:221 `FileSystem fs = Jimfs.newFileSystem(config);`.
- File: jimfs/src/test/java/com/google/common/jimfs/ConfigurationTest.java | Dòng: 159 | Nội dung: `Files.createFile(fs.getPath("C:\\foo"));` — `Files.createFile` call-site model (unix sibling at ConfigurationTest.java:230 `Files.createFile(fs.getPath("/foo"));`, same method).
- File: jimfs/src/test/java/com/google/common/jimfs/ConfigurationTest.java | Dòng: 234 | Nội dung: `assertThat(Files.getAttribute(fs.getPath("/foo"), "posix:permissions"))` — reading back `posix:permissions` via `Files.getAttribute`, exactly what the example does.
- File: jimfs/src/test/java/com/google/common/jimfs/ConfigurationTest.java | Dòng: 182 | Nội dung: `"posix:permissions", PosixFilePermissions.fromString("---------"))` — `PosixFilePermissions.fromString` feeding `setDefaultAttributeValue` in the test oracle (example uses `"rw-r--r--"`, same parser).

##### Documented second entry point — JDK SPI (`jimfs://` URIs), noted but not coded as a numbered example

Besides the facade, consumers can reach the same file system through the JDK
`ServiceLoader` SPI because the provider is annotation-registered; the scheme is
`jimfs`. The test suite drives the provider class directly rather than through a
`FileSystems.newFileSystem(URI)` lookup, so per rule (c) I record the anchors and
stop short of shipping a runtime `ServiceLoader` example without an executable
oracle:

- File: jimfs/src/main/java/com/google/common/jimfs/Jimfs.java | Dòng: 82 | Nội dung: `public static final String URI_SCHEME = "jimfs";`
- File: jimfs/src/main/java/com/google/common/jimfs/SystemJimfsFileSystemProvider.java | Dòng: 62 | Nội dung: `@AutoService(FileSystemProvider.class)` — SPI registration annotation (generates `META-INF/services/java.nio.file.spi.FileSystemProvider` at build time; `jimfs/src/main` contains only `java`, per gm-02-part-w1).
- File: jimfs/src/main/java/com/google/common/jimfs/SystemJimfsFileSystemProvider.java | Dòng: 97 | Nội dung: `public String getScheme() {`
- File: jimfs/src/main/java/com/google/common/jimfs/SystemJimfsFileSystemProvider.java | Dòng: 102 | Nội dung: `public FileSystem newFileSystem(URI uri, Map<String, ?> env) throws IOException {`
- File: jimfs/src/main/java/com/google/common/jimfs/SystemJimfsFileSystemProvider.java | Dòng: 136 | Nội dung: `URI_SCHEME.equalsIgnoreCase(uri.getScheme()),` — scheme validation on the SPI path.

#### (d) Dependencies needed (from gm-02 deps_out + imports used by the examples)

- Maven coordinate of the item itself: `com.google.jimfs:jimfs` — File: jimfs/pom.xml | Dòng: 23-28 | Nội dung: `<groupId>com.google.jimfs</groupId>` … `<artifactId>jimfs</artifactId>`. The examples import only `com.google.common.jimfs.Jimfs` / `Configuration` + JDK `java.nio.file` — everything else is transitive.
- Guava — declared dependency of the module (jimfs/pom.xml:42 `guava`; root pom pins `33.7.2-jre`, pom.xml:87, dep block pom.xml:95-97); 176 cross-boundary Guava imports per gm-02-part-w1 (fact from gm-02, measured at the same PIN).
- JDK `java.nio.file` — the API surface the examples program against (`Files`, `FileSystem`, `Path`); gm-02 counts 188 plain `java.nio.file` imports in main (fact from gm-02; `import java.nio.file.Path;` verified in the test oracle, e.g. PathTester.java / UrlTest.java / JimfsWindowsLikeFileSystemTest.java).
- `com.google.auto.service:auto-service-annotations` — only for the SPI provider (root pom.xml:109-110; used at SystemJimfsFileSystemProvider.java:62 above; the `:23` import pointer is fact from gm-02).
- `com.ibm.icu:icu4j` — only needed when a configuration uses `CASE_FOLD_UNICODE` normalization — File: jimfs/src/main/java/com/google/common/jimfs/PathNormalization.java | Dòng: 21/72/80 | Nội dung: `import com.ibm.icu.lang.UCharacter;` / `CASE_FOLD_UNICODE(...)` / `"PathNormalization.CASE_FOLD_UNICODE requires ICU4J. "` — NOT used by the three examples.
- `org.jspecify.annotations` (31 files) and `com.google.errorprone.annotations` (12 files, e.g. FileSystemState.java:24) — compile-time annotations of the main tree (counts fact from gm-02-part-w1, measured at the same PIN); not referenced by the examples.

#### (e) Per-item build

- The repo is a multi-module Maven build: File: pom.xml | Dòng: 28-30 | Nội dung: `<modules>` / `<module>jimfs</module>` / `</modules>` — so the item builds with `mvn -q -DskipTests compile` (or `mvn test`) from the repo root (or inside `jimfs/`).
- **SKIPPED (honest):** the sandbox image `bitnami/git:latest` has no Maven — `which mvn` returned nothing (MVN-ABSENT). No build/test output is fabricated here; the commands above are the documented Maven build matching the build file (`pom.xml` present at root + module).

## 4. Worker-slot coverage (drained slot recorded explicitly, per merge brief)

| Slot | u-checklist items owned | Status tick (`u-status-wN.json`) | Part report verdict |
|---|---|---|---|
| u_w1 | 1 (s01) | `{"s_id":"s01","section_done":true,"examples":3,"evidence_lines":32}` | s01 fully written — 3 numbered use cases (UC1/UC2/UC3) + 1 documented SPI note (unnumbered); every jimfs API in the code blocks has a `File`/`Dòng`/`Nội dung` grep hit in the part |
| u_w2 | 0 | `[]` (empty array) | `DRAINED w2 — 0 item` (valid per subject rules: universe < 4 items ⇒ idle slots allowed; w2 re-verified census 62 main files / 12,468 LOC / 1 package / 52 test files and anchors `Jimfs.java:79/96/114`, `Configuration.java:85/133/176/205/218` verbatim at the same PIN) |

No UNOWNED items exist: the single u-checklist item s01 is owned by u_w1 and fully written.

## 5. JSON block (parseable; every u-checklist item, in checklist id order)

```json
[
  {
    "s_id": "s01",
    "module": "com.google.common.jimfs",
    "stars": 5,
    "use_when": [
      "UC1 scratch disk for unit tests that touch real file I/O: try (FileSystem fs = Jimfs.newFileSystem()) then plain Files.createDirectories / Files.write / Files.readAllBytes (Jimfs.java:96; oracle JimfsUnixLikeFileSystemTest.java:301/795, JimfsFileSystemCloseTest.java:275, ClassLoaderTest.java:117)",
      "UC2 emulate a Windows or Unix path environment on a different host OS: Jimfs.newFileSystem(Configuration.windows()) with drive-root and backslash separators, case-insensitive lookup (Configuration.java:176; oracle ConfigurationTest.java:149/152/159/161)",
      "UC3 custom configuration via the builder: Configuration.unix().toBuilder().setWorkingDirectory(...).setAttributeViews(...).setDefaultAttributeValue(...).setMaxSize(...).build() (Configuration.java:317/688/569/632/492/727; oracle ConfigurationTest.java:243-247/234/182)",
      "SPI note (unnumbered): second entry point via JDK ServiceLoader / jimfs:// URIs - URI_SCHEME at Jimfs.java:82, @AutoService(FileSystemProvider.class) at SystemJimfsFileSystemProvider.java:62, getScheme :97, newFileSystem(URI, Map) :102, scheme validation :136"
    ],
    "deps_out": [
      "com.google.jimfs:jimfs - the artifact itself (jimfs/pom.xml:23-28); consumer examples import only com.google.common.jimfs.Jimfs / Configuration + JDK java.nio.file, everything else transitive",
      "Guava com.google.guava:guava - declared dependency (jimfs/pom.xml:42, root pom pins 33.7.2-jre; 176 cross-boundary imports per gm-02)",
      "JDK java.nio.file - the API surface the examples program against (Files, FileSystem, Path); 188 plain imports in main per gm-02",
      "com.google.auto.service:auto-service-annotations - only for the SPI provider (root pom.xml:109-110; used at SystemJimfsFileSystemProvider.java:62)",
      "com.ibm.icu:icu4j - only when a configuration uses CASE_FOLD_UNICODE normalization (PathNormalization.java:21/72/80); not used by the three examples",
      "org.jspecify.annotations (31 files) and com.google.errorprone.annotations (12 files, e.g. FileSystemState.java:24) - compile-time annotations of the main tree; not referenced by the examples"
    ],
    "examples": 3,
    "evidence_lines": 32,
    "build": "mvn -q -DskipTests compile (or mvn test) from the repo root - multi-module Maven, root pom.xml:28-30 declares the jimfs module; NOT executed by the worker (no Maven in its sandbox image, honestly recorded as SKIPPED - no build output fabricated)",
    "status": "DONE",
    "owner": "u_w1",
    "source": "reports/jimfs/gm-12-usage-w1.md"
  }
]
```

## 6. Merge verification (checks run by the merge node)

- Fail-closed input check: 2/2 usage parts (`gm-12-usage-w1.md`, `gm-12-usage-w2.md`) and 2/2 status files (`u-status-w1.json`, `u-status-w2.json`) present → merge proceeds; nothing fabricated.
- Run mode: no pre-existing `gm-12-usage.md` at merge start (glob over `reports/jimfs/`) → **FIRST GENERATION, NOT INHERITED**; the brief's "LẦN CHẠY 2+" clause was not triggered.
- Item completeness invariant: `u-checklist.json` items = 1 (s01) → deep sections 1 → item-table rows 1 → JSON array length 1 → **1 = 1 = 1 = 1**. Checklist id order (s01, first and only) preserved everywhere.
- Status agreement: `u-status-w1.json` tick `{s01, section_done=true, examples=3, evidence_lines=32}` ⇔ w1 part closing note "item s01 fully written (3 numbered use cases + 1 documented SPI note)" ⇔ merged JSON `s01.status = "DONE"`. `u-status-w2.json` = `[]` ⇔ part ends `DRAINED w2 — 0 item` ⇔ slot-coverage row "0 items owned".
- Evidence/example recount at merge: **32** `File | Dòng | Nội dung` evidence bullets in the s01 deep section (4 problem anchors + 6 UC1 + 6 UC2 + 11 UC3 + 5 SPI note = 32) — matches `u-status-w1.json` `evidence_lines: 32`; numbered examples = 3 (the SPI entry-point note is explicitly unnumbered) — matches `examples: 3`.
- Table/JSON column contract: item table carries every item with the brief's columns (module | dùng khi nào | deps_out); the JSON block is a plain array of objects with no nested double quotes and no backslash escapes inside string values, parseable with any standard JSON parser; the markdown table contains no raw `|` inside cell content.
- No sandbox was used for the merge itself (workspace-only file merge, per merge brief); all `file:line` evidence above is carried verbatim from the worker parts, each stating it was grep-verified on its own clone at PIN `8fa098e0715aa492914285312c07e151d2aace4d`.
- Source-vs-brief conflicts: none reported by either worker; w2 independently re-verified the census (62 main files / 12,468 LOC / 1 package / 52 test files) at the identical PIN.
- No build was executed for this item (the workers' sandbox images had no Maven; both recorded the build honestly as SKIPPED with the documented Maven commands — no build output is fabricated in this artifact).
