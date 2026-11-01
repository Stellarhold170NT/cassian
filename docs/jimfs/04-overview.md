---
subject: google/jimfs
measured_at: 8fa098e0715aa492914285312c07e151d2aace4d
status: final
---


# Overview


Every `file:line` below was verified against the pinned tree
`8fa098e0715aa492914285312c07e151d2aace4d` unless attributed to another
document in this directory.


## What JimFS is — five sentences


1. Jimfs is Google's **in-memory file system for Java 8 and above,
   implementing the `java.nio.file` abstract file system APIs**
   (`README.md:3-5`); the root POM describes it as "an in-memory
   implementation of Java 7's java.nio.file abstract file system API"
   (root `pom.xml`, `<description>` at `:86-88`).
2. It is a pure **library** (zero `main` entrypoints) whose whole public
   surface is two classes — the facade `Jimfs` (`Jimfs.java:79`, class javadoc
   "Static factory methods for creating new Jimfs file systems." at
   `Jimfs.java:39`) and the immutable presets/builder `Configuration`
   (`Configuration.java:57`; factories `unix()` `:85`, `osX()` `:133`,
   `windows()` `:176`, `forCurrentPlatform()` `:205`).
3. All data lives in the JVM heap: a `HeapDisk` "pseudo-disk" allocates
   fixed-size blocks to `RegularFile` objects (`HeapDisk.java:28-36` javadoc),
   and a `FileTree` "stores the root of the file hierarchy and handles file
   lookup" (`JimfsFileSystem.java:72-73`; class at `FileTree.java:38`).
4. Everything is reached through the JDK NIO2 contract:
   `JimfsFileSystemProvider` "implements the actual file system operations"
   behind `java.nio.file.Files` (`JimfsFileSystemProvider.java:53-57` javadoc,
   class at `:61`), while `SystemJimfsFileSystemProvider` is the
   `@AutoService(FileSystemProvider.class)` service
   (`SystemJimfsFileSystemProvider.java:62`) that only caches file systems so
   `Paths.get(URI)` works.
5. The entire implementation is **one flat package** `com.google.common.jimfs`
   — 62 files / 12,468 LOC main (plus 52 test files / 12,999 LOC) — with
   Guava as the only mandatory runtime dependency (icu4j,
   auto-service-annotations, jsr305 and jspecify are `<optional>true</optional>`,
   `jimfs/pom.xml:45-67`).


## Grasp in five minutes


1. **Two public entry classes**: `Jimfs` (facade, `Jimfs.java:79`) and
   `Configuration` (`Configuration.java:57`); the package javadoc says exactly
   that: "Most users should only need to use the {@link ...Jimfs} and
   {@link ...Configuration} classes" (`package-info.java:17-21`).
2. **Create a file system in one line**: `Jimfs.newFileSystem()` → random UUID
   name → `Configuration.forCurrentPlatform()` (`Jimfs.java:96`, `:114`;
   `URI_SCHEME = "jimfs"` at `:82`); Windows OS → `windows()`, Mac OS X →
   `osX()`, otherwise `unix()` (javadoc `Jimfs.java:92-94`).
3. **Wiring chain** (design overview javadoc `JimfsFileSystem.java:42-77`):
   `Jimfs.newFileSystem` calls
   `JimfsFileSystems.newFileSystem(JimfsFileSystemProvider.instance(), uri, config)`
   (`Jimfs.java:148`), which builds a `JimfsFileSystem` from the
   `Configuration` (roots + working directory included), then registers it in
   the system provider's cache so URI lookups work (`Jimfs.java:151-165`).
4. **Every operation goes through `FileSystemView`** — "this class contains
   the implementation of most file system operations, with relative path
   operations resolving against the working directory"
   (`FileSystemView.java:57-59`); it holds `JimfsFileStore store` +
   `Directory workingDirectory` (`:69,71`). One default view per file system +
   one extra view per `SecureDirectoryStream` (`:61-64`).
5. **`JimfsFileStore` is the storage facade**: it delegates lookup to
   `FileTree`, creation/copy to `FileFactory`, blocks to `HeapDisk`, and
   attributes to `AttributeService` (`JimfsFileStore.java:39-46` javadoc;
   fields `tree/disk/attributes/factory` at `:52-55`) and carries one
   store-wide `ReadWriteLock` (`:59-60`).
6. **Three file types only**: `Directory` (name→entry table,
   `Directory.java:32`), `RegularFile` (in-memory bytes, `RegularFile.java:45`),
   `SymbolicLink` (a path, `SymbolicLink.java:28`) — all extending `File`
   (`File.java:36`) (design javadoc `JimfsFileSystem.java:105-117`).
7. **Paths**: `JimfsPath implements Path` (`JimfsPath.java:55`) built by
   `PathService` (`PathService.java:48`) from a `PathType` (`PathType.java:38`;
   `unix()` `:44`, `windows()` `:67`, javadoc incl. drive-letter + UNC roots
   `:48-66`); names have *display* and *canonical* forms with optional
   normalizations (design javadoc `JimfsFileSystem.java:79-103`;
   `PathNormalization.java:33`).
8. **Attributes are pluggable providers**: registry
   `basic/owner/posix/dos/acl/user` (`StandardAttributeProviders.java:32-40`)
   plus a fresh per-file-system `unix` provider because it caches state
   (`:46-53`); `AttributeService` coordinates them (`AttributeService.java:47`).
9. **WatchService is polling-only by default**:
   `WatchServiceConfiguration.DEFAULT = polling(5, SECONDS)`
   (`WatchServiceConfiguration.java:35`); `PollingWatchService` diffs
   directory snapshots on a daemon `ScheduledExecutorService`
   (`PollingWatchService.java:57-64`); `AbstractWatchService` manages
   keys/queue (`AbstractWatchService.java:55-59`).
10. **Extras**: `jimfs://` URLs via `Handler` + `PathURLConnection`
    (`Handler.java:39`, `PathURLConnection.java:53`; handler registered in a
    static block `JimfsFileSystemProvider.java:65-72`); glob/regex
    `PathMatcher` (`PathMatchers.java:59-70`, translator `GlobToRegex.java:30`);
    four capability switches `LINKS`, `SYMBOLIC_LINKS`,
    `SECURE_DIRECTORY_STREAM`, `FILE_CHANNEL` (`Feature.java:37-104`).


## System context


- **System under description**: JimFS — an in-memory `java.nio.file` file
  system for Java 8+ (`README.md:3-5`), shipped as one Maven artifact
  `com.google.jimfs:jimfs` (`README.md:15-16`; `jimfs/pom.xml:28`).
- **Actors**: a *Java developer (typically test code)* calls
  `Jimfs.newFileSystem(Configuration.unix())` and then drives the file system
  exclusively through standard `java.nio.file` APIs (`README.md:31-43`
  basic-use example); the *JDK runtime* mediates everything — `Files`/`Paths`
  dispatch to the installed `FileSystemProvider` SPI, and `ServiceLoader`
  loads `SystemJimfsFileSystemProvider` from `META-INF/services` (generated at
  build time by AutoService, `pom.xml:217-228` annotationProcessorPaths).
- **External systems**: the *JVM heap* is the only storage medium (`HeapDisk`
  blocks + `FileTree` roots — `HeapDisk.java:28-36`, `FileTree.java:33-34`);
  *optional ICU4J* is required only for `PathNormalization.CASE_FOLD_UNICODE`
  (`PathNormalization.java:72-80`, guard message at `:80`; dependency is
  `<optional>true</optional>`, `jimfs/pom.xml:46-50`); the *JVM URL machinery*
  — `Handler` self-registers package `com.google.common` in
  `java.protocol.handler.pkgs` so `new URL("jimfs://...")` resolves
  (`Handler.java:41-53`; registered from
  `JimfsFileSystemProvider.java:65-72`).
- **Boundary**: no network egress, no daemon threads except the optional
  polling watcher's daemon executor (`PollingWatchService.java:57-61`), no
  persistence, no auth surface; the file system exists only between
  `Jimfs.newFileSystem(...)` and `close()` (`FileSystemState.java:34-36`,
  class at `:40`).
- **Value invariant**: real NIO2 semantics over throwaway memory — code that
  talks to `java.nio.file` works identically without touching a real disk,
  which is what makes it valuable for tests, sandboxes, and simulations.


## Containers


Responsibility-cluster cut of the single package (five clusters are also
modeled as C4 containers in [`03-c4/workspace.dsl`](03-c4/workspace.dsl)):

| container | type | path | responsibility (evidence) |
|---|---|---|---|
| Public facade | Java API | `Jimfs.java`, `Configuration.java` | Create configured `FileSystem` instances; 4 OS presets + builder with ~14 setters (`Configuration.java:85,133,176,205,218`; setter list `:393-715`) |
| JDK SPI adapters | Java (SPI) | `JimfsFileSystemProvider.java:61`, `SystemJimfsFileSystemProvider.java:63`, `Handler.java:39`, `PathURLConnection.java:53` | Translate `Files`/`Paths.get(URI)`/`URL` calls into engine calls; the system provider holds a weak-values static cache `Map<URI, FileSystem>` (`SystemJimfsFileSystemProvider.java:71-90`) |
| File-system engine | Java (internal) | `JimfsFileSystem.java:167`, `FileSystemView.java:67`, `JimfsSecureDirectoryStream.java:47`, `Options.java:44`, `FileSystemState.java:40` | Implement every NIO2 operation relative to a working directory; per-stream views for secure streams (`FileSystemView.java:57-64`) |
| Storage subsystem | Java (internal) | `JimfsFileStore.java:50`, `FileTree.java:38`, `FileFactory.java:31`, `HeapDisk.java:37`, `File/Directory/DirectoryEntry/RegularFile/SymbolicLink` | File creation, lookup (symlink depth cap 40, `FileTree.java:40-45`), block allocation (default block 8192 B, default capacity 4 GiB — `Configuration.java:325,328`), attributes |
| Path subsystem | Java (internal) | `JimfsPath.java:55`, `PathService.java:48`, `PathType.java:38` (+`UnixPathType.java:29`, `WindowsPathType.java:30`), `Name.java:39`, `PathNormalization.java:33`, `PathMatchers.java:36`, `GlobToRegex.java:30` | Parse/compare/render paths; display vs canonical name forms; glob→regex matching |
| Attribute subsystem | Java (internal) | `AttributeService.java:47`, `AttributeProvider.java:34` + 7 providers, `UserLookupService.java:32` | Virtualized basic/owner/posix/dos/acl/user/unix attribute views (registry `StandardAttributeProviders.java:32-53`) |
| I/O channels | Java (internal) | `JimfsFileChannel.java:57`, `JimfsAsynchronousFileChannel.java:44`, `JimfsInputStream.java:34`, `JimfsOutputStream.java:31`, `DowngradedSeekableByteChannel.java:33`, `DowngradedDirectoryStream.java:33` | Standard `FileChannel`/stream APIs over `RegularFile` blocks |
| Watch subsystem | Java (internal) | `AbstractWatchService.java:55`, `PollingWatchService.java:51`, `WatchServiceConfiguration.java:32` | Directory change watching by periodic polling (default every 5 s, `:35`) |

Protocol between containers: plain in-package method calls (one flat package,
no subpackages); the only protocol boundaries are (a) the JDK NIO2 SPI between
the facade/adapters and the JDK, and (b) the build-time AutoService-generated
`META-INF/services` registration (`pom.xml:217-228`).


## Components (all 62 main files, grouped by subsystem)


Class/interface/enum declaration lines grep-verified on the pin; LOC from
`wc -l`:

- **Facade & configuration** — `Jimfs` (`Jimfs.java:79`, 244 LOC),
  `Configuration` (`:57`, 731 LOC — presets `:85/:133/:176/:205`,
  `builder(PathType)` `:218`, setters `:393-715` incl. `setAttributeViews :569`,
  `addAttributeProvider :576`, `setSupportedFeatures :703`,
  `setWatchServiceConfiguration :715`), `Feature` (`Feature.java:37`, 105 LOC),
  `WatchServiceConfiguration` (`:32`, 76 LOC).
- **NIO2 plumbing** — `JimfsFileSystem` (`JimfsFileSystem.java:167`, 337 LOC;
  design javadoc `:42-166`), `JimfsFileSystemProvider`
  (`JimfsFileSystemProvider.java:61`, 354 LOC), `SystemJimfsFileSystemProvider`
  (`SystemJimfsFileSystemProvider.java:63`, 278 LOC), `JimfsFileSystems`
  (`JimfsFileSystems.java:31`, 126 LOC — internal factory), `FileSystemView`
  (`FileSystemView.java:67`, 744 LOC — largest file),
  `JimfsSecureDirectoryStream` (`JimfsSecureDirectoryStream.java:47`, 249 LOC),
  `Options` (`Options.java:44`, 166 LOC), `FileSystemState`
  (`FileSystemState.java:40`, 143 LOC).
- **Paths** — `JimfsPath` (`JimfsPath.java:55`, 441 LOC), `PathService`
  (`PathService.java:48`, 271 LOC), `PathType` (`PathType.java:38`, 242 LOC),
  `UnixPathType` (`UnixPathType.java:29`, 85 LOC), `WindowsPathType`
  (`WindowsPathType.java:30`, 207 LOC), `Name` (`Name.java:39`, 112 LOC),
  `PathNormalization` (`PathNormalization.java:33`, 133 LOC), `PathMatchers`
  (`PathMatchers.java:36`, 96 LOC), `GlobToRegex` (`GlobToRegex.java:30`,
  400 LOC), `InternalCharMatcher` (`InternalCharMatcher.java:26`, 42 LOC).
- **Files & storage** — `File` (`File.java:36`, 265 LOC), `Directory`
  (`Directory.java:32`, 355 LOC), `DirectoryEntry` (`DirectoryEntry.java:39`,
  171 LOC), `RegularFile` (`RegularFile.java:45`, 671 LOC), `SymbolicLink`
  (`SymbolicLink.java:28`, 51 LOC), `JimfsFileStore` (`JimfsFileStore.java:50`,
  271 LOC), `FileTree` (`FileTree.java:38`, 214 LOC), `FileFactory`
  (`FileFactory.java:31`, 125 LOC), `HeapDisk` (`HeapDisk.java:37`, 155 LOC).
- **Attributes** — `AttributeService` (`AttributeService.java:47`, 426 LOC),
  `AttributeProvider` (`AttributeProvider.java:34`, 177 LOC),
  `AbstractAttributeView` (`AbstractAttributeView.java:29`, 41 LOC),
  `StandardAttributeProviders` (`StandardAttributeProviders.java:28`, 57 LOC),
  providers: `BasicAttributeProvider` (`:35`, 239), `OwnerAttributeProvider`
  (`:36`, 122), `PosixAttributeProvider` (`:47`, 268), `DosAttributeProvider`
  (`:38`, 199), `AclAttributeProvider` (`:39`, 154),
  `UserDefinedAttributeProvider` (`:38`, 163), `UnixAttributeProvider`
  (`:38`, 170), plus `UnixFileAttributeView` (`UnixFileAttributeView.java:26`,
  26), `UserLookupService` (`UserLookupService.java:32`, 114),
  `AttributeCopyOption` (`AttributeCopyOption.java:24`, 31).
- **Channels & streams** — `JimfsFileChannel` (`JimfsFileChannel.java:57`,
  678 LOC), `JimfsAsynchronousFileChannel`
  (`JimfsAsynchronousFileChannel.java:44`, 230 LOC), `JimfsInputStream`
  (`JimfsInputStream.java:34`, 163 LOC), `JimfsOutputStream`
  (`JimfsOutputStream.java:31`, 116 LOC), `DowngradedSeekableByteChannel`
  (`DowngradedSeekableByteChannel.java:33`, 84 LOC),
  `DowngradedDirectoryStream` (`DowngradedDirectoryStream.java:33`, 50 LOC).
- **Watching** — `AbstractWatchService` (`AbstractWatchService.java:55`,
  303 LOC), `PollingWatchService` (`PollingWatchService.java:51`, 255 LOC).
- **URL support** — `Handler` (`Handler.java:39`, 93 LOC),
  `PathURLConnection` (`PathURLConnection.java:53`, 148 LOC).
- **Infrastructure** — `Util` (`Util.java:30`, 111 LOC), `FileTimeSource`
  (`FileTimeSource.java:26`, 29), `SystemFileTimeSource`
  (`SystemFileTimeSource.java:23`, 35), `GuardedBy` (`GuardedBy.java:36`, 36),
  `Java8Compatibility` (`Java8Compatibility.java:23`, 29), `FileLookup`
  (`FileLookup.java:26`, 34), `package-info` (`package-info.java`, 27).

Key dependency edges (from the design javadoc `JimfsFileSystem.java:42-77` +
field/import grep): `JimfsFileSystem → FileSystemView (default view) +
JimfsFileStore + PathService`; `JimfsFileSystemProvider → FileSystemView`;
`FileSystemView → JimfsFileStore` (`:69`); `JimfsFileStore → FileTree +
HeapDisk + AttributeService + FileFactory` (`JimfsFileStore.java:52-55`);
`HeapDisk → RegularFile` blocks (`HeapDisk.java:48-52`);
`PollingWatchService → FileSystemView + PathService`
(`PollingWatchService.java:69-70`). Cross-boundary deps: JDK
`java.nio.file` 188 plain imports (the SPI/API contract), Guava 176
cross-boundary import statements across 50/62 files, ICU4J exactly 1
(`PathNormalization.java:21`).


## Directory map + zone roles


| zone | contents | measured | role |
|---|---|---|---|
| `/` (repo root) | `README.md`, `LICENSE` (Apache-2.0, 11,357 bytes), `pom.xml` (parent, 371 lines), `CONTRIBUTING.md` | — | Project docs + parent POM declaring exactly one module (`pom.xml:28-30`) |
| `jimfs/` | the single Maven module `com.google.jimfs:jimfs`, packaging `bundle` (`jimfs/pom.xml:28-30`); deps: guava (mandatory) + icu4j/auto-service-annotations/jsr305/jspecify (`<optional>true</optional>`, `:45-67`); test: junit/guava-testlib/truth (`:70-81`) | — | Build unit; felix `maven-bundle-plugin` with `Include-Resource META-INF/services=target/classes/META-INF/services` (`jimfs/pom.xml:94-102`) |
| `jimfs/src/main/java/com/google/common/jimfs/` | the entire implementation: 62 `.java` files, flat, 0 subpackages | 12,468 | The only source zone — item `m01` (see `02-module-map.md`) |
| `jimfs/src/test/java/com/google/common/jimfs/` | 52 test files mirroring the package | 12,999 | Behavior oracle; not checklist items per the subject definition |
| `util/` | 1 file `util/update_snapshot_docs.sh` | — (shell) | Docs-update helper |

Zone reading order for a newcomer: README → `Jimfs` + `Configuration` →
`JimfsFileSystem` design javadoc (`:42-166`, the best architecture doc in the
repo) → `FileSystemView` → `JimfsFileStore`/`FileTree`/`HeapDisk` → one
attribute provider → `AbstractWatchService`. No resources directory exists in
`src/main` — the SPI service file is generated at build time.


## Build and test evidence (real run on the pin)


Toolchain installed from official distributions for the measurement:
Apache Maven 3.9.9 + Temurin OpenJDK 17.0.21.

```
$ mvn -q -DskipTests compile
(no output — quiet mode)   COMPILE_EXIT=0

$ mvn test
...
[INFO] Tests run: 5906, Failures: 0, Errors: 0, Skipped: 1
[INFO] BUILD SUCCESS
TEST_EXIT=0
```

Representative per-class lines from the same run: `RegularFileTest` — "Tests
run: 5432, Failures: 0, Errors: 0, Skipped: 0, Time elapsed: 18.16 s";
`JimfsFileChannelTest` — "Tests run: 24 ... Skipped: 1"; `RegexGlobMatcherTest`
— "Tests run: 12". Compiler level: `maven-compiler-plugin`
`source/target ${java.version}` (root `pom.xml:213-216`); the README claims
the Java 8 baseline (`README.md:3`).


## Extension points


1. **`Configuration.Builder` — the primary seam**: ~14 setters covering
   everything (`Configuration.java:393-715`) — name normalization `:393/:404`,
   canonical path equality `:459`, block size `:471`, disk capacity `:492`,
   block cache `:512`, attribute views `:569`, custom providers `:576`,
   default attribute values `:632`, time source `:655`, roots `:669`, working
   directory `:688`, features `:703`, watch service `:715`.
2. **Custom `AttributeProvider` injection** —
   `Configuration.Builder.addAttributeProvider(AttributeProvider)`
   (`Configuration.java:576`) on top of the abstract SPI `AttributeProvider`
   (`AttributeProvider.java:34-52`: `name()`, `inherits()`, `viewType()`,
   `view(...)`) — the seam for virtual attribute semantics.
3. **`PathType` presets and the normalization pipeline** — `PathType.unix()/windows()`
   (`PathType.java:44-71`) with `WindowsPathType` drive-letter/UNC handling;
   `PathNormalization` (NFD, ASCII/Unicode case folding — ICU4J gate at
   `PathNormalization.java:72-80`) — the seam for new platform path semantics.
4. **`WatchServiceConfiguration.polling(interval, unit)`**
   (`WatchServiceConfiguration.java:37-43`) — the only watcher knob today
   (default 5 s `:35`); a push-based implementation would slot in behind
   `AbstractWatchService` (`AbstractWatchService.java:48-52` javadoc:
   subclasses "implement the means of watching").
5. **`HeapDisk` sizing** — block 8192 B / capacity 4 GiB / cache −1 defaults
   (`Configuration.java:325-331`) wired into `HeapDisk`
   (`HeapDisk.java:58-62` ctor reads `config.blockSize/maxSize/maxCacheSize`
   into `blockSize/maxBlockCount/maxCachedBlockCount`) — the memory-footprint
   seam.
6. **`FileTimeSource` injection** (`Configuration.java:655`;
   `FileTimeSource.java:26`) — deterministic timestamps for reproducible tests.
7. **Feature flags** (`Feature.java:37-104`) — `LINKS`/`SYMBOLIC_LINKS`/
   `SECURE_DIRECTORY_STREAM`/`FILE_CHANNEL` switch whole API families on/off
   per configuration.


## Risks when reusing


1. **Attribute views are largely cosmetic**: the README warns explicitly —
   "while setting and reading POSIX file permissions is possible with the
   'posix' view, those permissions will not actually affect the behavior of
   the file system" (`README.md:57-62`). Reuse that expects permission
   enforcement (e.g. security tests) will get semantics the real OS would not
   give.
2. **One store-wide `ReadWriteLock` serializes mutation**: `JimfsFileStore`
   holds a single `readLock/writeLock` pair (`JimfsFileStore.java:59-60,89-94`)
   and every lookup goes through `FileSystemView.lookUpWithLock`
   (`FileSystemView.java:105-118`) — correctness is simple, but heavy
   concurrent workloads contend on one lock. Scale expectations should be
   modest. (Verified on the lookup path; the write-lock pairing across all
   mutating methods was not exhaustively enumerated.)
3. **Watching is polling with 5-second default latency**
   (`WatchServiceConfiguration.java:35`): no inotify-style push events; tests
   relying on instant watch events are flaky by design. The polling executor
   is a daemon thread (won't block JVM exit, `PollingWatchService.java:57-61`).
4. **Unicode case-folding needs optional ICU4J**: `CASE_FOLD_UNICODE` throws
   unless ICU4J is present (`PathNormalization.java:80` guard). The dependency
   is `<optional>true</optional>` (`jimfs/pom.xml:46-50`), so downstream
   builds that exclude optional deps and then enable `CASE_FOLD_UNICODE`
   fail at runtime, not build time.
5. **Memory is capped but shared**: default capacity 4 GiB
   (`Configuration.java:328`) per file system, block-cached on the heap
   (`HeapDisk.java:28-36`); many parallel file systems multiply this. Unclosed
   file systems are kept URI-addressable only via a *weak-values* cache
   (`SystemJimfsFileSystemProvider.java:79-88` javadoc) — a deliberately
   chosen compromise where an unreferenced but open file system may be GC'd
   and `Paths.get(URI)` then throws `FileSystemNotFoundException`.
6. **Behavior is "modeled after UNIX", not any exact platform**
   (`README.md:64-67`): the Windows configuration approximates real Windows
   (two documented unsupported path features: relative drive-letter paths and
   rootless absolute paths, `PathType.java:57-65`); byte-for-byte platform
   parity is not a goal.
7. **Upstream is a stable, low-churn library**: 62-file flat package, Java 8
   baseline (`README.md:3`), `@author Colin Decker` throughout
   (e.g. `Jimfs.java:77`); plan reuse as a pinned dependency, not a fork
   target — see the re-sync policy in [`tracking/jimfs.md`](../../tracking/jimfs.md).


## Provenance


| field | value |
|---|---|
| upstream | https://github.com/google/jimfs, branch `master` |
| pin | `8fa098e0715aa492914285312c07e151d2aace4d` (2026-10-22, "Bump org.sonatype.central:central-publishing-maven-plugin from 0.11.0 to 0.12.0 in the dependencies group") |
| shallow depth | ≤100 commits visible (`--depth 100`) |
| license | Apache License 2.0 — `LICENSE` at repo root (11,357 bytes, "Copyright 2013 Google Inc.") |
| language | Java (single Maven module `com.google.jimfs:jimfs`, packaging bundle) |
| census | tree 114 files / 25,467 LOC; main 62 / 12,468; test 52 / 12,999 |
| dependencies | guava (mandatory); icu4j, auto-service-annotations, jsr305, jspecify `<optional>true</optional>`; test: junit, guava-testlib, truth (`jimfs/pom.xml:40-81`) |
| harness | Maven 3.9.9 + Temurin JDK 17.0.21: compile exit 0; test 5,906 run / 0 fail / 1 skip, BUILD SUCCESS |
| re-sync policy | compare against [`tracking/jimfs.md`](../../tracking/jimfs.md) (`git ls-remote` HEAD vs pin → FRESH/STALE) |
