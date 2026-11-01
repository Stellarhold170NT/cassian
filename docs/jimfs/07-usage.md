---
subject: google/jimfs
measured_at: 8fa098e0715aa492914285312c07e151d2aace4d
status: final
---


# Usage


Hands-on recipes for `com.google.common.jimfs` (artifact
`com.google.jimfs:jimfs`). Every API in the examples below is grep-verified in
the pinned tree (`8fa098e0715aa492914285312c07e151d2aace4d`); oracle call
sites come from the mirrored test package, which exercises the same public
APIs.


## When to use


An in-memory `java.nio.file.FileSystem` for tests and path-sensitive code.


- **UC1 — scratch disk for unit tests that touch real file I/O.**
- **UC2 — emulate a Windows or Unix path environment on a different host OS.**
- **UC3 — custom configuration via the builder.**
- **Second entry point (SPI)** — JDK `ServiceLoader` / `jimfs://` URIs
  (documented, not coded as a numbered example).


## UC1 — In-memory scratch disk for unit tests that touch real file I/O


Scenario: a unit test needs to create directories and write/read a real file,
but touching the host disk (or an OS-specific temp dir) makes the test slow,
dirty and platform-dependent. Jimfs hands the test a fully working
`java.nio.file.FileSystem` in RAM; the code under test keeps using plain
`Files.*` calls unchanged. The no-arg facade picks the configuration preset
matching the current OS.

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

Evidence (every API in the example grep-verified at the pin):

- `jimfs/src/main/java/com/google/common/jimfs/Jimfs.java:96` —
  `public static FileSystem newFileSystem() {`
- `jimfs/src/main/java/com/google/common/jimfs/Jimfs.java:113-114` —
  `public static FileSystem newFileSystem(String name) {` /
  `return newFileSystem(name, Configuration.forCurrentPlatform());` — the
  no-arg overload reaches `forCurrentPlatform()` through this chain.
- `jimfs/src/test/java/com/google/common/jimfs/JimfsUnixLikeFileSystemTest.java:301` —
  `Files.createDirectories(path("/foo/bar"));` — `Files.createDirectories`
  call site in the test oracle.
- `jimfs/src/test/java/com/google/common/jimfs/JimfsUnixLikeFileSystemTest.java:795` —
  `Files.write(path("/test"), new byte[] {0, 1, 2, 3});` —
  `Files.write(Path, byte[])` call site (also `:151`
  `Files.write(fs.getPath("/foo"), new byte[10000]);`).
- `jimfs/src/test/java/com/google/common/jimfs/JimfsFileSystemCloseTest.java:275` —
  `assertThrows(ClosedFileSystemException.class, () -> Files.readAllBytes(file));` —
  `Files.readAllBytes` call site (also `PathSubject.java:345`).
- `jimfs/src/test/java/com/google/common/jimfs/ClassLoaderTest.java:117` —
  `List<String> lines = Files.readAllLines(p, UTF_8);` — `UTF_8` charset
  constant used with `Files.*` in the test oracle.


## UC2 — Emulate a Windows (or Unix) path environment on a different host OS


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

Evidence (grep-verified at the pin):

- `jimfs/src/main/java/com/google/common/jimfs/Configuration.java:176` —
  `public static Configuration windows() {`
- `jimfs/src/test/java/com/google/common/jimfs/ConfigurationTest.java:149` —
  `FileSystem fs = Jimfs.newFileSystem(Configuration.windows());` — the exact
  composition used in the example.
- `jimfs/src/test/java/com/google/common/jimfs/ConfigurationTest.java:152` —
  `.containsExactlyElementsIn(ImmutableList.of(fs.getPath("C:\\")))` —
  drive-root `getPath` syntax on the windows configuration.
- `jimfs/src/test/java/com/google/common/jimfs/ConfigurationTest.java:159` —
  `Files.createFile(fs.getPath("C:\\foo"));` — backslash path syntax feeding
  a `Files.*` operation (`:161` adds the case-insensitivity check
  `Files.createFile(fs.getPath("C:\\FOO"))` throwing
  `FileAlreadyExistsException`).
- `jimfs/src/test/java/com/google/common/jimfs/JimfsUnixLikeFileSystemTest.java:301` —
  `Files.createDirectories(path("/foo/bar"));` — `Files.createDirectories`
  call site.
- `jimfs/src/test/java/com/google/common/jimfs/ClassLoaderTest.java:117` —
  `List<String> lines = Files.readAllLines(p, UTF_8);` — `Files.readAllLines`
  call site.


## UC3 — Custom configuration via the builder: default POSIX permissions, working directory, size cap


Scenario: an integration test needs a file system that behaves like a real
POSIX volume: files created with default permissions, relative paths
resolving against a chosen working directory, and a hard total-size cap to
exercise "disk full" handling. `Configuration.unix().toBuilder()` starts from
the unix preset and overrides exactly those knobs, then
`Jimfs.newFileSystem(config)` materializes it.

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

Evidence (grep-verified at the pin):

- `jimfs/src/main/java/com/google/common/jimfs/Configuration.java:317` —
  `public Builder toBuilder() {`
- `jimfs/src/test/java/com/google/common/jimfs/ConfigurationTest.java:243-248` —
  `public void testToBuilder() {` —
  `Configuration.unix().toBuilder().setWorkingDirectory("/hello/world").setAttributeViews("basic", "posix").build();` —
  the same chain shape as the example (the closing `.build();` sits at `:248`).
- `jimfs/src/main/java/com/google/common/jimfs/Configuration.java:688` —
  `public Builder setWorkingDirectory(String workingDirectory) {`
- `jimfs/src/main/java/com/google/common/jimfs/Configuration.java:569` —
  `public Builder setAttributeViews(String first, String... more) {`
- `jimfs/src/main/java/com/google/common/jimfs/Configuration.java:632` —
  `public Builder setDefaultAttributeValue(String attribute, Object value) {`
- `jimfs/src/main/java/com/google/common/jimfs/Configuration.java:492` —
  `public Builder setMaxSize(long maxSize) {`
- `jimfs/src/main/java/com/google/common/jimfs/Configuration.java:727` —
  `public Configuration build() {`
- `jimfs/src/main/java/com/google/common/jimfs/Jimfs.java:118` —
  `public static FileSystem newFileSystem(Configuration configuration) {` —
  composed in tests at `ConfigurationTest.java:221`
  `FileSystem fs = Jimfs.newFileSystem(config);`.
- `jimfs/src/test/java/com/google/common/jimfs/ConfigurationTest.java:159` —
  `Files.createFile(fs.getPath("C:\\foo"));` — `Files.createFile` call-site
  model (unix sibling at `ConfigurationTest.java:230`
  `Files.createFile(fs.getPath("/foo"));`, same method).
- `jimfs/src/test/java/com/google/common/jimfs/ConfigurationTest.java:234` —
  `assertThat(Files.getAttribute(fs.getPath("/foo"), "posix:permissions"))` —
  reading back `posix:permissions` via `Files.getAttribute`, exactly what the
  example does.
- `jimfs/src/test/java/com/google/common/jimfs/ConfigurationTest.java:182` —
  `"posix:permissions", PosixFilePermissions.fromString("---------"))` —
  `PosixFilePermissions.fromString` feeding `setDefaultAttributeValue` in the
  test oracle (the example uses `"rw-r--r--"`, same parser).

Caveat that applies here (see `04-overview.md`, risks): the `posix` view
stores and returns permissions, but they are cosmetic — jimfs does not
enforce them.


## Second entry point — JDK SPI (`jimfs://` URIs)


Besides the facade, consumers can reach the same file system through the JDK
`ServiceLoader` SPI because the provider is annotation-registered; the scheme
is `jimfs`. The test suite drives the provider class directly rather than
through a `FileSystems.newFileSystem(URI)` lookup, so this note records the
anchors and stops short of shipping a runtime `ServiceLoader` example without
an executable oracle:

- `jimfs/src/main/java/com/google/common/jimfs/Jimfs.java:82` —
  `public static final String URI_SCHEME = "jimfs";`
- `jimfs/src/main/java/com/google/common/jimfs/SystemJimfsFileSystemProvider.java:62` —
  `@AutoService(FileSystemProvider.class)` — SPI registration annotation
  (generates `META-INF/services/java.nio.file.spi.FileSystemProvider` at
  build time; `jimfs/src/main` contains only `java`).
- `jimfs/src/main/java/com/google/common/jimfs/SystemJimfsFileSystemProvider.java:97` —
  `public String getScheme() {`
- `jimfs/src/main/java/com/google/common/jimfs/SystemJimfsFileSystemProvider.java:102` —
  `public FileSystem newFileSystem(URI uri, Map<String, ?> env) throws IOException {`
- `jimfs/src/main/java/com/google/common/jimfs/SystemJimfsFileSystemProvider.java:136` —
  `URI_SCHEME.equalsIgnoreCase(uri.getScheme()),` — scheme validation on the
  SPI path.


## Dependencies needed


- Maven coordinate of the package itself: `com.google.jimfs:jimfs`
  (`jimfs/pom.xml:23-28`). The examples import only
  `com.google.common.jimfs.Jimfs` / `Configuration` + JDK `java.nio.file` —
  everything else is transitive.
- Guava — declared dependency of the module (`jimfs/pom.xml:42` `guava`; the
  root POM pins `33.7.2-jre`); 176 cross-boundary Guava imports in the main
  tree (see `02-module-map.md`).
- JDK `java.nio.file` — the API surface the examples program against (`Files`,
  `FileSystem`, `Path`); 188 plain `java.nio.file` imports in main.
- `com.google.auto.service:auto-service-annotations` — only for the SPI
  provider (root `pom.xml:109-110`; used at
  `SystemJimfsFileSystemProvider.java:62`).
- `com.ibm.icu:icu4j` — only needed when a configuration uses
  `CASE_FOLD_UNICODE` normalization
  (`PathNormalization.java:21/72/80`); not used by the three examples.
- `org.jspecify.annotations` (31 files) and
  `com.google.errorprone.annotations` (12 files, e.g.
  `FileSystemState.java:24`) — compile-time annotations of the main tree; not
  referenced by the examples.


## Build


The repo is a multi-module Maven build (`pom.xml:28-30` declares the `jimfs`
module), so the artifact builds with `mvn -q -DskipTests compile` (or
`mvn test`) from the repository root. Real measured evidence on the pin:
compile exits 0 and the full suite passes — 5,906 tests run, 0 failures,
0 errors, 1 skipped, BUILD SUCCESS (see `04-overview.md`).
