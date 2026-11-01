---
subject: google/jimfs
measured_at: 8fa098e0715aa492914285312c07e151d2aace4d
status: final
---


# Overview


## (1) What JimFS is — 5 sentences

1. Jimfs is Google's **in-memory file system for Java 8 and above, implementing the `java.nio.file` abstract file system APIs** (README:3-5); the root POM describes it as "an in-memory implementation of Java 7's java.nio.file abstract file system API" (root `pom.xml` `<description>`, quoted in gm-01 §4).
2. It is a pure **library** (zero `main` entrypoints, gm-01 §5) whose whole public surface is two classes — the facade `Jimfs` (`Jimfs.java:79`, class javadoc "Static factory methods for creating new Jimfs file systems." at `Jimfs.java:39`) and the immutable presets/builder `Configuration` (`Configuration.java:57`, factories `unix() :85`, `osX() :133`, `windows() :176`, `forCurrentPlatform() :205`).
3. All data lives in the JVM heap: a `HeapDisk` "pseudo-disk" allocates fixed-size blocks to `RegularFile` objects (`HeapDisk.java:28-36` javadoc), and a `FileTree` "stores the root of the file hierarchy and handles file lookup" (`JimfsFileSystem.java:72-73`; class at `FileTree.java:38`, own javadoc `:33-34`).
4. Everything is reached through the JDK NIO2 contract: `JimfsFileSystemProvider` "implements the actual file system operations" behind `java.nio.file.Files` (`JimfsFileSystemProvider.java:53-57` javadoc, class at `:61`), while `SystemJimfsFileSystemProvider` is the `@AutoService(FileSystemProvider.class)` service (`SystemJimfsFileSystemProvider.java:62`) that only caches file systems so `Paths.get(URI)` works.
5. The entire implementation is **one flat package** `com.google.common.jimfs` — 62 files / 12,468 LOC main (plus 52 test files / 12,999 LOC, gm-01 §3) — with Guava as the only mandatory runtime dependency (icu4j, auto-service-annotations, jsr305, jspecify are `<optional>true</optional>`, `jimfs/pom.xml:45-67`).

## (2) Grasp in 5 minutes — 10 bullets

1. **Two public entry classes**: `Jimfs` (facade, `Jimfs.java:79`) and `Configuration` (`Configuration.java:57`); the package javadoc tells users exactly that: "Most users should only need to use the {@link ...Jimfs} and {@link ...Configuration} classes" (`package-info.java:17-21`).
2. **Create a file system in one line**: `Jimfs.newFileSystem()` → random UUID name → `Configuration.forCurrentPlatform()` (`Jimfs.java:96`, `:114`, `:82` `URI_SCHEME = "jimfs"`); Windows OS → `windows()`, Mac OS X → `osX()`, otherwise `unix()` (javadoc `Jimfs.java:92-94`).
3. **Wiring chain** (design overview javadoc `JimfsFileSystem.java:42-77`): `Jimfs.newFileSystem` calls `JimfsFileSystems.newFileSystem(JimfsFileSystemProvider.instance(), uri, config)` (`Jimfs.java:148`), which builds a `JimfsFileSystem` from the `Configuration` (roots + working directory included), then registers it in the system provider's cache so URI lookups work (`Jimfs.java:151-165`).
4. **Every operation goes through `FileSystemView`** — "this class contains the implementation of most file system operations, with relative path operations resolving against the working directory" (`FileSystemView.java:57-59`); it holds `JimfsFileStore store` + `Directory workingDirectory` (`:69,71`). One default view per file system + one extra view per `SecureDirectoryStream` (`:61-64`).
5. **`JimfsFileStore` is the storage facade**: it delegates lookup to `FileTree`, creation/copy to `FileFactory`, blocks to `HeapDisk`, attributes to `AttributeService` (`JimfsFileStore.java:39-46` javadoc; fields `tree/disk/attributes/factory` `:52-55`) and carries one store-wide `ReadWriteLock` (`:59-60`).
6. **Three file types only**: `Directory` (name→entry table, `Directory.java:32`), `RegularFile` (in-memory bytes, `RegularFile.java:45`), `SymbolicLink` (a path, `SymbolicLink.java:28`) — all extending `File` (`File.java:36`) (design javadoc `JimfsFileSystem.java:105-117`).
7. **Paths**: `JimfsPath implements Path` (`JimfsPath.java:55`) built by `PathService` (`PathService.java:48`) from a `PathType` (`PathType.java:38`; `unix() :44`, `windows() :67`, javadoc incl. drive-letter + UNC roots `:48-66`); names have *display* and *canonical* forms with optional normalizations (design javadoc `JimfsFileSystem.java:79-103`; `PathNormalization.java:33`).
8. **Attributes are pluggable providers**: registry `basic/owner/posix/dos/acl/user` (`StandardAttributeProviders.java:32-40`) plus a fresh per-file-system `unix` provider because it caches state (`:46-53`); `AttributeService` coordinates them (`AttributeService.java:47`).
9. **WatchService is polling-only by default**: `WatchServiceConfiguration.DEFAULT = polling(5, SECONDS)` (`WatchServiceConfiguration.java:35`); `PollingWatchService` diffs directory snapshots on a daemon `ScheduledExecutorService` (`PollingWatchService.java:57-64`), `AbstractWatchService` manages keys/queue (`AbstractWatchService.java:55-59`).
10. **Extras**: `jimfs://` URLs via `Handler` + `PathURLConnection` (`Handler.java:39`, `PathURLConnection.java:53`; handler registered in a static block `JimfsFileSystemProvider.java:65-72`); glob/regex `PathMatcher` (`PathMatchers.java:59-70`, translator `GlobToRegex.java:30`); four capability switches `LINKS`, `SYMBOLIC_LINKS`, `SECURE_DIRECTORY_STREAM`, `FILE_CHANNEL` (`Feature.java:37-104`).

## (3) C4 L1 — System context

Summarized from code + gm-02 only (gm-03 not read).

- **System under description**: JimFS — an in-memory `java.nio.file` file system for Java 8+ (README:3-5), shipped as one Maven artifact `com.google.jimfs:jimfs` (README:15-16; `jimfs/pom.xml:28`).
- **Actors**:
  - *Java developer (typically test code)* — calls `Jimfs.newFileSystem(Configuration.unix())` then drives the file system exclusively through standard `java.nio.file` APIs (`Files`, `Path`, `FileChannel`, `WatchService`) — README:31-43 basic-use example.
  - *JDK runtime* — mediates everything: `Files`/`Paths` dispatch to the installed `FileSystemProvider` SPI; `ServiceLoader` loads `SystemJimfsFileSystemProvider` from `META-INF/services` (generated at build time by AutoService, `pom.xml:217-228` annotationProcessorPaths; gm-02 deps_in).
- **External systems**:
  - *JVM heap* — the only storage medium; `HeapDisk` blocks + `FileTree` roots (`HeapDisk.java:28-36`, `FileTree.java:33-34`). Nothing is ever written to a real disk.
  - *Optional ICU4J on the classpath* — required only for `PathNormalization.CASE_FOLD_UNICODE` (`PathNormalization.java:72-80`, guard message "PathNormalization.CASE_FOLD_UNICODE requires ICU4J." at `:80`); dependency is `<optional>true</optional>` (`jimfs/pom.xml:46-50`).
  - *JVM URL machinery* — `Handler` self-registers package `com.google.common` in `java.protocol.handler.pkgs` so `new URL("jimfs://...")` resolves (`Handler.java:41-53`; registered from `JimfsFileSystemProvider.java:65-72`).
- **Boundary**: no network egress, no daemon threads except the optional polling watcher's daemon executor (`PollingWatchService.java:57-61`), no persistence, no auth surface; the file system exists only between `Jimfs.newFileSystem(...)` and `close()` (`FileSystemState.java:34-36` "manages the open/closed state of a file system", class at `:40`).
- **Value invariant**: real NIO2 semantics over throwaway memory — code that talks to `java.nio.file` works identically without touching a real disk, which is what makes it valuable for tests, sandboxes, and simulations.

## (4) C4 L2 — Containers

| # | Container | Type | Path | Responsibility (evidence) |
|---|---|---|---|---|
| 1 | Public facade | Java API | `Jimfs.java`, `Configuration.java` | Create configured `FileSystem` instances; 4 OS presets + builder with ~14 setters (`Configuration.java:85,133,176,205,218`; setter list `:393-715`) |
| 2 | JDK SPI adapters | Java (SPI) | `JimfsFileSystemProvider.java:61`, `SystemJimfsFileSystemProvider.java:63`, `Handler.java:39`, `PathURLConnection.java:53` | Translate `Files`/`Paths.get(URI)`/`URL` calls into engine calls; system provider holds a weak-values static cache `Map<URI, FileSystem>` (`SystemJimfsFileSystemProvider.java:71-90`) |
| 3 | File-system engine | Java (internal) | `JimfsFileSystem.java:167`, `FileSystemView.java:67`, `JimfsSecureDirectoryStream.java:47`, `Options.java:44`, `FileSystemState.java:40` | Implement every NIO2 operation relative to a working directory; per-stream views for secure streams (`FileSystemView.java:57-64`) |
| 4 | Storage subsystem | Java (internal) | `JimfsFileStore.java:50`, `FileTree.java:38`, `FileFactory.java:31`, `HeapDisk.java:37`, `File/Directory/DirectoryEntry/RegularFile/SymbolicLink` | File creation, lookup (symlink depth cap 40, `FileTree.java:40-45`), block allocation (default block 8192 B, default capacity 4 GiB — `Configuration.java:325,328`), attributes |
| 5 | Path subsystem | Java (internal) | `JimfsPath.java:55`, `PathService.java:48`, `PathType.java:38` (+`UnixPathType.java:29`, `WindowsPathType.java:30`), `Name.java:39`, `PathNormalization.java:33`, `PathMatchers.java:36`, `GlobToRegex.java:30` | Parse/compare/render paths; display vs canonical name forms; glob→regex matching |
| 6 | Attribute subsystem | Java (internal) | `AttributeService.java:47`, `AttributeProvider.java:34` + 7 providers, `UserLookupService.java:32` | Virtualized "basic/owner/posix/dos/acl/user/unix" attribute views (registry `StandardAttributeProviders.java:32-53`) |
| 7 | I/O channels | Java (internal) | `JimfsFileChannel.java:57`, `JimfsAsynchronousFileChannel.java:44`, `JimfsInputStream.java:34`, `JimfsOutputStream.java:31`, `DowngradedSeekableByteChannel.java:33`, `DowngradedDirectoryStream.java:33` | Standard `FileChannel`/stream APIs over `RegularFile` blocks |
| 8 | Watch subsystem | Java (internal) | `AbstractWatchService.java:55`, `PollingWatchService.java:51`, `WatchServiceConfiguration.java:32` | Directory change watching by periodic polling (default every 5 s, `:35`) |

Protocol between containers: plain in-package method calls (one flat package, no subpackages — gm-01 §7); the only "protocol" boundaries are (a) the JDK NIO2 SPI between containers 1/2 and the JDK, and (b) the build-time AutoService-generated `META-INF/services` registration (`pom.xml:217-228`, gm-02 deps_in).

## (5) C4 L3 — Components

All 62 main files of the single package, grouped by subsystem (class/interface/enum declaration lines grep-verified on the PIN clone; LOC from `wc -l`):

- **Facade & configuration** — `Jimfs` (`Jimfs.java:79`, 244 LOC), `Configuration` (`:57`, 731 LOC — largest config surface: presets `:85/:133/:176/:205`, `builder(PathType) :218`, setters `:393-715` incl. `setAttributeViews :569`, `addAttributeProvider :576`, `setSupportedFeatures :703`, `setWatchServiceConfiguration :715`), `Feature` (`Feature.java:37`, 105 LOC), `WatchServiceConfiguration` (`:32`, 76 LOC).
- **NIO2 plumbing** — `JimfsFileSystem` (`JimfsFileSystem.java:167`, 337 LOC; design javadoc `:42-166`), `JimfsFileSystemProvider` (`JimfsFileSystemProvider.java:61`, 354 LOC), `SystemJimfsFileSystemProvider` (`SystemJimfsFileSystemProvider.java:63`, 278 LOC), `JimfsFileSystems` (`JimfsFileSystems.java:31`, 126 LOC — internal factory), `FileSystemView` (`FileSystemView.java:67`, 744 LOC — largest file), `JimfsSecureDirectoryStream` (`JimfsSecureDirectoryStream.java:47`, 249 LOC), `Options` (`Options.java:44`, 166 LOC), `FileSystemState` (`FileSystemState.java:40`, 143 LOC).
- **Paths** — `JimfsPath` (`JimfsPath.java:55`, 441 LOC), `PathService` (`PathService.java:48`, 271 LOC), `PathType` (`PathType.java:38`, 242 LOC), `UnixPathType` (`UnixPathType.java:29`, 85 LOC), `WindowsPathType` (`WindowsPathType.java:30`, 207 LOC), `Name` (`Name.java:39`, 112 LOC), `PathNormalization` (`PathNormalization.java:33`, 133 LOC), `PathMatchers` (`PathMatchers.java:36`, 96 LOC), `GlobToRegex` (`GlobToRegex.java:30`, 400 LOC), `InternalCharMatcher` (`InternalCharMatcher.java:26`, 42 LOC).
- **Files & storage** — `File` (`File.java:36`, 265 LOC), `Directory` (`Directory.java:32`, 355 LOC), `DirectoryEntry` (`DirectoryEntry.java:39`, 171 LOC), `RegularFile` (`RegularFile.java:45`, 671 LOC), `SymbolicLink` (`SymbolicLink.java:28`, 51 LOC), `JimfsFileStore` (`JimfsFileStore.java:50`, 271 LOC), `FileTree` (`FileTree.java:38`, 214 LOC), `FileFactory` (`FileFactory.java:31`, 125 LOC), `HeapDisk` (`HeapDisk.java:37`, 155 LOC).
- **Attributes** — `AttributeService` (`AttributeService.java:47`, 426 LOC), `AttributeProvider` (`AttributeProvider.java:34`, 177 LOC), `AbstractAttributeView` (`AbstractAttributeView.java:29`, 41 LOC), `StandardAttributeProviders` (`StandardAttributeProviders.java:28`, 57 LOC), providers: `BasicAttributeProvider` (`:35`, 239), `OwnerAttributeProvider` (`:36`, 122), `PosixAttributeProvider` (`:47`, 268), `DosAttributeProvider` (`:38`, 199), `AclAttributeProvider` (`:39`, 154), `UserDefinedAttributeProvider` (`:38`, 163), `UnixAttributeProvider` (`:38`, 170), plus `UnixFileAttributeView` (`UnixFileAttributeView.java:26`, 26), `UserLookupService` (`UserLookupService.java:32`, 114), `AttributeCopyOption` (`AttributeCopyOption.java:24`, 31).
- **Channels & streams** — `JimfsFileChannel` (`JimfsFileChannel.java:57`, 678 LOC), `JimfsAsynchronousFileChannel` (`JimfsAsynchronousFileChannel.java:44`, 230 LOC), `JimfsInputStream` (`JimfsInputStream.java:34`, 163 LOC), `JimfsOutputStream` (`JimfsOutputStream.java:31`, 116 LOC), `DowngradedSeekableByteChannel` (`DowngradedSeekableByteChannel.java:33`, 84 LOC), `DowngradedDirectoryStream` (`DowngradedDirectoryStream.java:33`, 50 LOC).
- **Watching** — `AbstractWatchService` (`AbstractWatchService.java:55`, 303 LOC), `PollingWatchService` (`PollingWatchService.java:51`, 255 LOC).
- **URL support** — `Handler` (`Handler.java:39`, 93 LOC), `PathURLConnection` (`PathURLConnection.java:53`, 148 LOC).
- **Infrastructure** — `Util` (`Util.java:30`, 111 LOC), `FileTimeSource` (`FileTimeSource.java:26`, 29), `SystemFileTimeSource` (`SystemFileTimeSource.java:23`, 35), `GuardedBy` (`GuardedBy.java:36`, 36), `Java8Compatibility` (`Java8Compatibility.java:23`, 29), `FileLookup` (`FileLookup.java:26`, 34), `package-info` (`package-info.java`, 27).

Key dependency edges (from the design javadoc `JimfsFileSystem.java:42-77` + field/import grep): `JimfsFileSystem → FileSystemView (default view) + JimfsFileStore + PathService`; `JimfsFileSystemProvider → FileSystemView`; `FileSystemView → JimfsFileStore` (`:69`); `JimfsFileStore → FileTree + HeapDisk + AttributeService + FileFactory` (`JimfsFileStore.java:52-55`); `HeapDisk → RegularFile` blocks (`HeapDisk.java:48-52`); `PollingWatchService → FileSystemView + PathService` (`PollingWatchService.java:69-70`). Cross-boundary deps per gm-02: JDK `java.nio.file` 188 plain imports (the SPI/API contract), Guava 176 cross-boundary import statements across 50/62 files, ICU4J exactly 1 (`PathNormalization.java:21`).

## (6) Directory map + zone roles

| Zone | Contents | LOC (measured) | Role |
|---|---|---|---|
| `/` (repo root) | `README.md`, `LICENSE` (Apache-2.0, 11,357 bytes — gm-01 §2), `pom.xml` (parent, 371 lines), `CONTRIBUTING.md` | — | Project docs + parent POM declaring exactly one module (`pom.xml:28-30`, gm-01 §4) |
| `jimfs/` | the single Maven module `com.google.jimfs:jimfs`, packaging `bundle` (`jimfs/pom.xml:28-30`); deps: guava (mandatory) + icu4j/auto-service-annotations/jsr305/jspecify (`<optional>true</optional>` `:45-67`), test: junit/guava-testlib/truth (`:70-81`) | — | Build unit; felix `maven-bundle-plugin` with `Include-Resource META-INF/services=target/classes/META-INF/services` (`jimfs/pom.xml:94-102`) |
| `jimfs/src/main/java/com/google/common/jimfs/` | the entire implementation: 62 `.java` files, flat, 0 subpackages | 12,468 | **The only source zone** — universe item `m01` (gm-02); subsystems listed in (5) |
| `jimfs/src/test/java/com/google/common/jimfs/` | 52 test files mirroring the package | 12,999 | Oracle for behavior (S3); not checklist items per subject definition (gm-01 §3) |
| `util/` | 1 file `util/update_snapshot_docs.sh` | — (shell) | Docs-update helper (gm-01 §6) |

Zone reading order for a newcomer: README → `Jimfs`+`Configuration` → `JimfsFileSystem` design javadoc (`:42-166`, the best architecture doc in the repo) → `FileSystemView` → `JimfsFileStore`/`FileTree`/`HeapDisk` → one attribute provider → `AbstractWatchService`. No resources directory exists in `src/main` — the SPI service file is generated at build time (gm-02 deps_in).

## (7) Expensive flows

**Authority for this section: `reports/jimfs/gm-06-flows.md` (Stream D, produced in parallel — this node does NOT read or wait for it, per brief).** Candidates observed from code, to be reconciled with stream D:

1. *File-system creation* — `Jimfs.newFileSystem` → `JimfsFileSystems.newFileSystem` (wiring all subsystems from `Configuration`, creating roots + working directory) → registration in the system provider cache (`Jimfs.java:140-170`, `:148`; design javadoc `JimfsFileSystem.java:42-50`).
2. *Path lookup on every operation* — `FileSystemView.lookUpWithLock` takes the store-wide read lock then walks `FileTree` with symlink resolution capped at depth 40 (`FileSystemView.java:105-118`; `FileTree.java:40-45`; locks `JimfsFileStore.java:59-60,89-94`) — the hottest path since every `Files.*` call resolves through it.
3. *Byte-channel read/write* — `JimfsFileChannel`/`JimfsInputStream`/`JimfsOutputStream` over `RegularFile` blocks allocated/cached by `HeapDisk` (`HeapDisk.java:37-62`; `RegularFile.java:45+`).
4. *Directory watching* — `PollingWatchService` re-snapshots registered directories every interval (default 5 s) and posts diff events (`PollingWatchService.java:51-76`; `WatchServiceConfiguration.java:35`).

## (8) Run/harness — real commands

Java toolchain was **not** present in the bitnami/git sandbox (`which java javac mvn` → all missing; no `apt-get`, VMware Photon OS base). Installed from official distributions inside the sandbox — Temurin JDK 17.0.21 tarball (via Adoptium API) + Apache Maven 3.9.9 binary tarball — then ran the exact brief harness on the PIN clone:

```
$ cd /workspace/jimfs && mvn -q -DskipTests compile
(no output — quiet mode)   COMPILE_EXIT=0

$ cd /workspace/jimfs && mvn test
...
[INFO] Tests run: 5906, Failures: 0, Errors: 0, Skipped: 1
[INFO] BUILD SUCCESS
TEST_EXIT=0
```

Representative per-class lines from the same run: `RegularFileTest` — "Tests run: 5432, Failures: 0, Errors: 0, Skipped: 0, Time elapsed: 18.16 s"; `JimfsFileChannelTest` — "Tests run: 24 ... Skipped: 1"; `RegexGlobMatcherTest` — "Tests run: 12". Result: **build passes and the full test suite passes (exit 0)** — 5906 tests, 0 failures, 0 errors, 1 skipped. Not SKIPPED — real output, Maven 3.9.9 / OpenJDK 17.0.21. Compiler level: `maven-compiler-plugin` `source/target ${java.version}` (root `pom.xml:213-216`); README claims the Java 8 baseline (README:3).

## (9) Expensive extension points — teaser from gm-02

1. **`Configuration.Builder` — the primary seam** (gm-02 m01): ~14 setters covering everything (`Configuration.java:393-715`) — name normalization `:393/:404`, canonical path equality `:459`, block size `:471`, disk capacity `:492`, block cache `:512`, attribute views `:569`, custom providers `:576`, default attribute values `:632`, time source `:655`, roots `:669`, working directory `:688`, features `:703`, watch service `:715`.
2. **Custom `AttributeProvider` injection** — `Configuration.Builder.addAttributeProvider(AttributeProvider)` (`Configuration.java:576`) on top of the abstract SPI `AttributeProvider` (`AttributeProvider.java:34-52`: `name()`, `inherits()`, `viewType()`, `view(...)`) — the seam for virtual attribute semantics.
3. **`PathType` presets and the normalization pipeline** — `PathType.unix()/windows()` (`PathType.java:44-71`) with `WindowsPathType` drive-letter/UNC handling; `PathNormalization` (NFD, ASCII/Unicode case folding — ICU4J gate at `PathNormalization.java:72-80`) — the seam for new platform path semantics.
4. **`WatchServiceConfiguration.polling(interval, unit)`** (`WatchServiceConfiguration.java:37-43`) — the only watcher knob today (default 5 s `:35`); a push-based implementation would slot in behind `AbstractWatchService` (`AbstractWatchService.java:48-52` javadoc: subclasses "implement the means of watching").
5. **`HeapDisk` sizing** — block 8192 B / capacity 4 GiB / cache −1 defaults (`Configuration.java:325-331`) wired into `HeapDisk` (`HeapDisk.java:58-62` ctor reads `config.blockSize/maxSize/maxCacheSize` into its fields `blockSize/maxBlockCount/maxCachedBlockCount`) — the memory-footprint seam (gm-02 m01 main_files).
6. **`FileTimeSource` injection** (`Configuration.java:655`; `FileTimeSource.java:26`) — deterministic timestamps for reproducible tests.
7. **Feature flags** (`Feature.java:37-104`) — `LINKS`/`SYMBOLIC_LINKS`/`SECURE_DIRECTORY_STREAM`/`FILE_CHANNEL` switch whole API families on/off per configuration.

## (10) Risks when reusing

1. **Attribute views are largely cosmetic**: README warns explicitly — "while setting and reading POSIX file permissions is possible with the "posix" view, those permissions will not actually affect the behavior of the file system" (README:57-62). Reuse that expects permission enforcement (e.g. security tests) will get semantics the real OS would not give.
2. **One store-wide `ReadWriteLock` serializes mutation**: `JimfsFileStore` holds a single `readLock/writeLock` pair (`JimfsFileStore.java:59-60,89-94`) and every lookup goes through `FileSystemView.lookUpWithLock` (`FileSystemView.java:105-118`) — correctness is simple, but heavy concurrent workloads contend on one lock. Scale expectations should be modest. [CẦN XÁC MINH: whether writes take the same lock pair across all mutating methods — spot-checked only on the lookup path.]
3. **Watching is polling with 5-second default latency** (`WatchServiceConfiguration.java:35`): no inotify-style push events; tests relying on instant watch events are flaky by design. The polling executor is a daemon thread (won't block JVM exit, `PollingWatchService.java:57-61`).
4. **Unicode case-folding needs optional ICU4J**: `CASE_FOLD_UNICODE` throws unless ICU4J is present (`PathNormalization.java:80` guard). The dependency is `<optional>true</optional>` (`jimfs/pom.xml:46-50`), so downstream builds that exclude optional deps and then enable `CASE_FOLD_UNICODE` will fail at runtime, not build time.
5. **Memory is capped but shared**: default capacity 4 GiB (`Configuration.java:328`) per file system, block-cached on the heap (`HeapDisk.java:28-36`); many parallel file systems multiply this. Unclosed file systems are also kept URI-addressable only via a *weak-values* cache (`SystemJimfsFileSystemProvider.java:79-88` javadoc) — a deliberately chosen compromise where an unreferenced but open file system may be GC'd and `Paths.get(URI)` then throws `FileSystemNotFoundException` (documented at `:79-88`).
6. **Behavior is "modeled after UNIX", not any exact platform** (README:64-67): Windows configuration approximates real Windows (two documented unsupported path features: relative drive-letter paths and rootless absolute paths, `PathType.java:57-65`); byte-for-byte platform parity is not a goal.
7. **Upstream is a stable, low-churn library**: 62-file flat package, Java 8 baseline (README:3), single-maintainer era code (`@author Colin Decker` throughout, e.g. `Jimfs.java:77`); plan reuse as a pinned dependency, not a fork target — see tracking policy in (11).

## (11) Provenance

| Field | Value | Evidence |
|---|---|---|
| Upstream | https://github.com/google/jimfs | clone command this node |
| Branch | `master` | `git branch --show-current` → master |
| PIN (HEAD at capture) | `8fa098e0715aa492914285312c07e151d2aace4d` | `git log -1 --format='%H %ci %s'` → `8fa098e… 2026-10-22 08:59:22 -0700 Bump org.sonatype.central:central-publishing-maven-plugin from 0.11.0 to 0.12.0 in the dependencies group` |
| Shallow depth | ≤100 (`--depth 100`; 100 commits visible) | clone flags this node; `git rev-list --count HEAD` → 100 |
| License | Apache License 2.0 — `LICENSE` at repo root (11,357 bytes, "Apache License / Version 2.0, January 2004"), copyright "Copyright 2013 Google Inc." | gm-01 §2 (`head -3 LICENSE`) + README:69-72 + root `pom.xml` `<licenses>` (gm-01 §4) |
| Language | Java (single Maven module `com.google.jimfs:jimfs`, packaging bundle) | gm-01 §4; `jimfs/pom.xml:23-30` |
| Census | tree 114 files / 25,467 LOC; main 62 / 12,468; test 52 / 12,999 | re-verified this node (census command identical to gm-01 §3) — matches gm-01 + gm-02 absolutely |
| Dependencies | guava (mandatory); icu4j, auto-service-annotations, jsr305, jspecify `<optional>true</optional>`; test: junit, guava-testlib, truth | `jimfs/pom.xml:40-81` |
| Harness | Maven 3.9.9 + Temurin JDK 17.0.21 (tarballs installed in sandbox): compile exit 0; test 5906 run / 0 fail / 1 skip, BUILD SUCCESS | section (8), real output |
| Re-sync policy | compare against `tracking/jimfs.md` when it exists (`git ls-remote` HEAD vs pin → FRESH/STALE) | AGENTS.md §1/§8 |

## (12) Open questions

1. Do the four candidate flows in (7) match what Stream D documents in `reports/jimfs/gm-06-flows.md`, and which did it rank most expensive?
2. Which mutating operations share the store-wide write lock (`JimfsFileStore.java:59-60`) vs. the read lock — needed to substantiate the concurrency ceiling claim in (10.2) beyond the lookup path.
3. Should the cosmetic-permissions caveat (README:57-62) be a highlighted warning in the published `docs/jimfs/04-overview`, given test-suite users are the primary audience?
4. Is the weak-values URI cache semantics (`SystemJimfsFileSystemProvider.java:79-88`) worth its own risk bullet for consumers that hold only `Path` handles obtained from `Paths.get(URI)`?
5. gm-02 citation spot-check on this PIN clone: **zero deviations found** — `Jimfs.java:39/:79/:96/:114`, `Configuration.java:85/:133/:176/:205/:218`, `FileSystemView.java:57-59/:67/:69-72`, `PathService.java:33`, `SystemJimfsFileSystemProvider.java:21/:62`, `PathNormalization.java:21/:72/:80`, `RegularFile.java:21-22` all verified identical (unlike the codesearch run, which had line drift). Stream C can cite gm-02 lines as-is.

---

## Machine block

```json
{
  "node": "b-overview",
  "subject": "jimfs",
  "pin": "8fa098e0715aa492914285312c07e151d2aace4d",
  "branch": "master",
  "license": "Apache-2.0 (Copyright 2013 Google Inc.)",
  "maven_artifact": "com.google.jimfs:jimfs",
  "packaging": "bundle",
  "universe": {
    "kind": "single-maven-module-packages",
    "packages": [
      {
        "package": "com.google.common.jimfs",
        "path": "jimfs/src/main/java/com/google/common/jimfs",
        "files": 62,
        "loc": 12468,
        "subpackages": 0
      }
    ]
  },
  "census": {
    "tree": {"files": 114, "lines": 25467},
    "main": {"files": 62, "lines": 12468},
    "test": {"files": 52, "lines": 12999}
  },
  "dependencies": {
    "mandatory": ["com.google.guava:guava"],
    "optional": ["com.ibm.icu:icu4j", "com.google.auto.service:auto-service-annotations", "com.google.code.findbugs:jsr305", "org.jspecify:jspecify"],
    "test": ["junit", "guava-testlib", "truth"]
  },
  "harness": {
    "toolchain": "Apache Maven 3.9.9 + OpenJDK 17.0.21 (Temurin, installed from official tarballs in sandbox)",
    "build": "mvn -q -DskipTests compile -> exit 0",
    "test": "mvn test -> Tests run: 5906, Failures: 0, Errors: 0, Skipped: 1, BUILD SUCCESS (exit 0)"
  },
  "entrypoints": [],
  "flows_pointer": "reports/jimfs/gm-06-flows.md (stream D, parallel — not read)",
  "deviations_from_gm02": [],
  "gm02_citations_spotcheck": "all file:line citations listed in (12.5) verified identical on PIN clone",
  "rev": 3,
  "rev2_note": "review round 1: 48 anchor pairs (~58 citation sites) corrected after line-by-line re-verification on the same PIN clone",
  "rev3_note": "review round 2: design-javadoc range fixed to JimfsFileSystem.java:42-166 (javadoc ends :166, class :167), HeapDisk ctor wording fixed (reads config.blockSize/maxSize/maxCacheSize at :58-62), anchor-count self-description aligned with fix report"
}
```
