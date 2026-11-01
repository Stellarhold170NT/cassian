---
subject: google/jimfs
measured_at: 8fa098e0715aa492914285312c07e151d2aace4d
status: final
---


# Folders


All numbers below were re-measured on a shallow clone at the pin
`8fa098e0715aa492914285312c07e151d2aace4d`; the census matches
[`01-cartography.md`](01-cartography.md) exactly (main 62 files / 12,468
lines; test 52 / 12,999).


## Zone map


The repo tree is extremely flat — a depth-2 `find` shows exactly four
directories outside `.git`.

| zone | path | role (one sentence) | evidence |
|---|---|---|---|
| Root | `.` (holds `pom.xml`, `README.md`, `LICENSE`, `CONTRIBUTING.md`, `.github/`, `.gitignore`) | Parent Maven POM + project docs: `pom.xml` declares exactly one child module and contains no code. | `pom.xml:29` `<module>jimfs</module>`; `.github/` holds exactly 2 files: `dependabot.yml`, `workflows/ci.yml` |
| Module | `jimfs/` | The single Maven module `com.google.jimfs:jimfs` (packaging `bundle`) containing the library's entire Java source. | `jimfs/pom.xml:28-30` `<artifactId>jimfs</artifactId>` / `<packaging>bundle</packaging>` |
| Source | `jimfs/src/` | Only the two standard Maven trees `src/main` + `src/test`, each holding a single package `com/google/common/jimfs` — no `resources`, no other source tree. | `find jimfs/src -type d` → exactly 13 directories, all `jimfs/src/{main,test}/java/com/google/common/jimfs`; `find jimfs/src -name 'META-INF' -o -name 'services' -o -name '*.properties' -o -name '*.xml'` → empty |
| Utility | `util/` | One Bash script for publishing snapshot docs — outside every Maven tree, no effect on the Java universe. | `find util -type f` → only `util/update_snapshot_docs.sh`; `util/update_snapshot_docs.sh:1` `#!/bin/bash` |

All code lives in `jimfs/src`; `util/` is the only auxiliary zone at the root.
There is no CLI entry point — a pure library, hence the very short zone map.


## Inside the package `com.google.common.jimfs`


The single checklist item is this package — the largest and only one of the
main tree.


### Main vs test layout


| tree | path | contents |
|---|---|---|
| Main | `jimfs/src/main/java/com/google/common/jimfs/` | **62 `.java` files** (61 classes + `package-info.java`), **12,468 lines**, completely flat: `find ... -mindepth 1 -type d \| wc -l` → **0 subpackages** (measured on the leaf package directory; the command pointed at `jimfs/src/main/java` returns 4 — the four namespace directories `com/google/common/jimfs`, not subpackages) |
| Test | `jimfs/src/test/java/com/google/common/jimfs/` | **52 `.java` files**, **12,999 lines** — mirrors the main package name to reach package-private internals; tests outweigh main by ~4% LOC |

Because both trees share the package name, the main/test boundary is the
Maven directory split (`src/main` vs `src/test`), not the package. Largest
file per side: `FileSystemView.java` at 744 lines (main); the test tree has 5
shared `Abstract*Test` base classes.


### The 62 main files in 10 name clusters


| cluster | files | notes |
|---|---|---|
| Facade + SPI (5) | `Jimfs.java`, `JimfsFileSystem.java`, `JimfsFileSystemProvider.java`, `JimfsFileSystems.java`, `SystemJimfsFileSystemProvider.java` | Public entry points: `Jimfs.java:39` ("Static factory methods for creating new Jimfs file systems."), `Jimfs.java:79` (`public final class Jimfs {`); SPI registered via `@AutoService` (see deviations, D2) |
| Configuration (6) | `Configuration.java` (731 lines), `PathType.java`, `UnixPathType.java`, `WindowsPathType.java`, `Options.java`, `Feature.java` | Presets: `Configuration.java:85/133/176/205` — `public static Configuration unix() / osX() / windows() / forCurrentPlatform()` |
| Path & matcher (6) | `JimfsPath.java` (441), `PathService.java` (271), `Name.java`, `PathMatchers.java`, `PathNormalization.java`, `GlobToRegex.java` (400) | `PathService.java:48` — `final class PathService implements Comparator<JimfsPath> {` |
| Attributes (13) | `AbstractAttributeView`, `AclAttributeProvider`, `AttributeCopyOption`, `AttributeProvider`, `AttributeService`, `BasicAttributeProvider`, `DosAttributeProvider`, `OwnerAttributeProvider`, `PosixAttributeProvider`, `StandardAttributeProviders`, `UnixAttributeProvider`, `UnixFileAttributeView`, `UserDefinedAttributeProvider` | Largest cluster of the package (`ls \| grep -ci attrib` → 13) |
| Watch service (3) | `AbstractWatchService.java`, `PollingWatchService.java`, `WatchServiceConfiguration.java` | — |
| I/O — channel/stream (7) | `DowngradedDirectoryStream.java`, `DowngradedSeekableByteChannel.java`, `JimfsAsynchronousFileChannel.java`, `JimfsFileChannel.java` (678), `JimfsInputStream.java`, `JimfsOutputStream.java`, `JimfsSecureDirectoryStream.java` | — |
| File tree / file store (12) | `File.java`, `Directory.java` (355), `DirectoryEntry.java`, `RegularFile.java` (671), `SymbolicLink.java`, `FileTree.java`, `HeapDisk.java`, `FileFactory.java`, `FileLookup.java`, `FileSystemState.java`, `FileSystemView.java` (744), `JimfsFileStore.java` | Storage core: `FileSystemView.java:67` `final class FileSystemView {` — holds `JimfsFileStore store` + `Directory workingDirectory` (`:69-72`) |
| URL support (2) | `Handler.java`, `PathURLConnection.java` | `Handler.java:39` — `public final class Handler extends URLStreamHandler {` |
| User lookup (1) | `UserLookupService.java` | User/principal lookup backing the owner attribute |
| Package-level utility (7) | `FileTimeSource.java`, `SystemFileTimeSource.java`, `GuardedBy.java`, `InternalCharMatcher.java`, `Java8Compatibility.java`, `Util.java`, `package-info.java` | Helpers that fit no business cluster above |

Coverage invariant: 5 + 6 + 6 + 13 + 3 + 7 + 12 + 2 + 1 + 7 = **62** = total
files in the package (`ls jimfs/src/main/java/com/google/common/jimfs/ | wc -l`
→ 62); the 62 names in the table match the `ls` listing 1-1 and each file
appears in exactly one cluster.


### Test tree (52 files)


- 43/52 files end in `Test.java` (`ls | grep -c 'Test\.java$'` → 43).
- 9 helper files do not end in `Test.java`: `BasicFileAttribute.java`,
  `ByteBufferChannel.java`, `FakeFileTimeSource.java`, `PathSubject.java`,
  `PathTester.java`, `TestAttributeProvider.java`, `TestAttributeView.java`,
  `TestAttributes.java`, `TestUtils.java`.
- 5 abstract base classes: `AbstractAttributeProviderTest`,
  `AbstractGlobMatcherTest`, `AbstractJimfsIntegrationTest`,
  `AbstractPathMatcherTest`, `AbstractWatchServiceTest` — concrete tests
  inherit from them (e.g. `JimfsUnixLikeFileSystemTest`,
  `JimfsWindowsLikeFileSystemTest`).
- Only 2 cross-file imports exist inside the test package
  (`PathTypeTest.java:23`, `PollingWatchServiceTest.java:28-29`) — everything
  else reaches siblings directly because of the shared package.


## Naming conventions (≥3 examples each)


1. **Prefix `Jimfs*` for wrappers of JDK NIO types** — 11 files: `Jimfs`,
   `JimfsAsynchronousFileChannel`, `JimfsFileChannel`, `JimfsFileStore`,
   `JimfsFileSystem`, `JimfsFileSystemProvider`, `JimfsFileSystems`,
   `JimfsInputStream`, `JimfsOutputStream`, `JimfsPath`,
   `JimfsSecureDirectoryStream` (`ls | grep -c '^Jimfs'` → 11). Verbatim:
   `Jimfs.java:79` `public final class Jimfs {`. (`Handler` is a deliberate
   exception — see below.)
2. **Suffix `*AttributeProvider` for attribute providers** — 9 files:
   interface `AttributeProvider`, implementations
   `Basic/Dos/Posix/Acl/Unix/Owner/UserDefinedAttributeProvider`, registry
   `StandardAttributeProviders`. One-to-one with the JDK view names
   (`*AttributeView` — `UnixFileAttributeView.java`,
   `AbstractAttributeView.java`).
3. **Prefix `Abstract*` for shared base classes** — main:
   `AbstractAttributeView.java`, `AbstractWatchService.java`; test: 5
   `Abstract*Test` files.
4. **Suffix `*Service` for internal service classes** — `AttributeService.java`,
   `PathService.java`, `UserLookupService.java` (plus `PollingWatchService`
   in the watch cluster). Verbatim: `PathService.java:48`
   `final class PathService implements Comparator<JimfsPath> {` with javadoc
   "Service for creating JimfsPath instances and handling other path-related
   operations."
5. **Test helpers follow the Google Truth/`*Tester` pattern** —
   `PathSubject.java` (Truth `Subject`), `PathTester.java`, `TestUtils.java`,
   `Test*` prefix for fakes (`TestAttributeProvider`, `TestAttributes`,
   `FakeFileTimeSource`) — clearly distinct from the 43 real `*Test` files.
6. **JDK-mandated names** — `Handler` must be named exactly that so the JDK
   finds it via `URL`: `Handler.java:29-31` — "{@link URLStreamHandler}
   implementation for jimfs. Named {@code Handler} so that the class can be
   found by Java as described in the documentation for
   {@link URL#URL(String, String, int, String) URL}."


## Deviations from Java conventions (each with ≥2 examples)


**D1 — One flat package, 0 subpackages despite 62 files.** A ~12k-LOC Java
project would conventionally split subpackages by function; jimfs keeps every
class in `com.google.common.jimfs`.

- Example 1: `find jimfs/src/main/java/com/google/common/jimfs -mindepth 1 -type d | wc -l` → **0** (62 files in one directory; under `jimfs/src/main/java` only the 4 namespace directories exist).
- Example 2: three functionally independent clusters sit flat in the same directory — attributes (13 files), watch (3), I/O (7) — instead of `…jimfs/attributes/`, `…jimfs/watch/`, `…jimfs/io/`.

**D2 — No `src/main/resources`; the SPI registration file is generated at
build time.** Classic Java convention commits
`META-INF/services/<SPI>` under `src/main/resources`.

- Example 1: `find jimfs/src -name 'META-INF' -o -name 'services' -o -name '*.properties' -o -name '*.xml'` → empty; `find jimfs/src -type d` shows no `resources` directory anywhere (only `main/java` + `test/java`).
- Example 2: `SystemJimfsFileSystemProvider.java:23` `import com.google.auto.service.AutoService;` and `:62` `@AutoService(FileSystemProvider.class)` → `META-INF/services/java.nio.file.spi.FileSystemProvider` is generated by AutoService during the build instead of being committed.

**D3 — Test tree does not follow the strict "one test class = one `*Test`"
JUnit pattern.**

- Example 1: 9/52 test files do not end in `Test.java` (the helpers listed above) — helpers/fakes living in the test package.
- Example 2: 5 `Abstract*Test` base classes underpin concrete tests
  (`JimfsUnixLikeFileSystemTest`, `JimfsWindowsLikeFileSystemTest`…) — an
  inheritance structure instead of self-contained tests.

**Zones with no further deviations**: standard Maven layout is followed
everywhere else — parent POM declares exactly 1 module (`pom.xml:29`),
`src/main/java` + `src/test/java` are standard, the reverse-domain package
name `com.google.common.jimfs` is conventional, and `package-info.java`
carries package-level annotations. Beyond D1–D3 a full sweep of `jimfs/src`
and the root found no other structural deviations.


## Suggested reading order


Read the directory `jimfs/src/main/java/com/google/common/jimfs/` first — all
main code is there (62 files, 1 package); the root holds only poms/docs and
`util/` one script. Within the directory (public API inward):

1. `pom.xml` (root) + `jimfs/pom.xml` — confirm the single module and the
   Guava/ICU4J deps; then `README.md` for usage (`util/` can be skipped).
2. `Jimfs.java` — facade creating file systems:
   `Jimfs.java:96` `public static FileSystem newFileSystem() {` resolving
   through `Configuration.forCurrentPlatform()` at `:114`.
3. `Configuration.java` — configuration presets
   (`unix()/osX()/windows()/forCurrentPlatform()` at `:85/:133/:176/:205`),
   then `PathType.java` + `UnixPathType/WindowsPathType` — per-platform path
   syntax.
4. `JimfsFileSystemProvider.java` + `SystemJimfsFileSystemProvider.java` — the
   two SPI routes (user-created instance vs the `@AutoService`-registered
   system provider).
5. `FileSystemView.java` (744 lines, largest file) —
   `:57-59` "this class contains the implementation of most file system
   operations, with relative path operations resolving against the working
   directory." — the center of every operation; read alongside
   `JimfsFileSystem.java`.
6. Storage internals: `FileTree.java` (`:38` `final class FileTree {` —
   javadoc: "The tree of directories and files for the file system. Contains
   the file system root directories and provides the ability to look up files
   by path."), `Directory.java` (`:32` — "A table of DirectoryEntry"),
   `RegularFile.java` (`:45` — "A mutable, resizable store for bytes. Bytes
   are stored in fixed-sized byte arrays (blocks) allocated by a HeapDisk."),
   `HeapDisk.java` (`:37` — "A resizable pseudo-disk acting as a shared space
   for storing file data.").
7. Watch service (`AbstractWatchService` → `PollingWatchService`,
   `WatchServiceConfiguration`) and URL support (`Handler`,
   `PathURLConnection`) last — two utilities independent of the core.

Rationale: the package is flat, so there is no layer-by-layer directory order;
the only dependency gradient is public API → configuration → operations →
file tree/disk. Navigating by the name clusters above is the most effective
way; the test tree is best read on demand as API-usage examples (mirrored
package with ready-made `PathSubject`/`PathTester` helpers).
