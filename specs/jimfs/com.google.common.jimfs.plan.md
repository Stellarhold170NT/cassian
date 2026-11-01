# EXTRACTION PLAN — SLOT A: `com.google.common.jimfs` (google/jimfs @ 8fa098e0)

Selected item: **s01 `com.google.common.jimfs` — 5★**, the only (and highest-rated)
item of the subject (rating in `docs/jimfs/02-module-map.md`; no slot-B plan item
exists — see [`slot-b.plan.md`](slot-b.plan.md) for the N/A verdict).

**This document is a plan.** The actual cut is a separate, out-of-band step.

## 1. Selected item (per `gm-08-stars.md`)

The star-ranked universe is exactly **1 item** (`sr-checklist.json:2`), and it qualifies:

| id | module | stars | Bands (gm-07 ladder) | Source |
|---|---|---|---|---|
| s01 | `com.google.common.jimfs` | ★★★★★ | S1 B · S2 A · S3 A · S4 A · S5 A → first ladder match ★★★★★ | `gm-08-stars.md:44,46-48` |

→ **SLOT A takes s01** (first ≥4-star item). The universe has no second item, so the
"second item" that slot B would take does not exist (slot B's own node handles `N/A`).
The extraction unit is coherent: google/jimfs is a **single Maven module** whose main
tree is one flat package `jimfs/src/main/java/com/google/common/jimfs` (62 files /
12468 LOC) and whose test tree mirrors the same package (52 files / 12999 LOC) —
census re-verified this session, byte-for-byte equal to the frozen oracle numbers
(`gm-08-oracles-raw.md:88-98`). Test files are not checklist items (jimfs subject
definition, `AGENTS.md` §1) but they ARE the regression oracle (S3 ratio 1.0426 ≥ 1.0).

## 2. Fresh evidence gathered on the PIN tree this session

| Claim | Evidence |
|---|---|
| Repo layout: parent pom + single module | root `pom.xml` (371 lines, `<modules><module>jimfs</module>` at :28-30) + `jimfs/pom.xml` (108 lines, `packaging=bundle` at :30) |
| src has NO resources/config files (pure Java) | `find jimfs/src -name 'META-INF*' -o -name '*.properties' -o -name '*.xml'` → `0` |
| Main census | 62 files / 12468 LOC (`find … \| wc -l`, `xargs -0 cat \| wc -l`) |
| Test census | 52 files / 12999 LOC (same commands) |
| Public facade | `Jimfs.java:79 public final class Jimfs {`; overloads at :96, :113, :118, :130 |
| Configuration presets | `Configuration.java:85 unix()`, :133 `osX()`, :176 `windows()`, :205 `forCurrentPlatform()` |
| AutoService SPI registration | `SystemJimfsFileSystemProvider.java:23 import com.google.auto.service.AutoService;` and `:62 @AutoService(FileSystemProvider.class)` |
| ICU4J is a hard main-tree import | `PathNormalization.java:21 import com.ibm.icu.lang.UCharacter;`; `CASE_FOLD_UNICODE` declared :71 with the `requires ICU4J` guard at :70-82 |
| jsr305 usage (exactly 1 file) | `package-info.java:27 import javax.annotation.ParametersAreNonnullByDefault;` |
| jspecify / errorprone-annotations usage | 31 files import `org.jspecify`; 12 files import `com.google.errorprone.annotations` (e.g. `FileSystemState.java:24 CanIgnoreReturnValue`) |
| Tests resolve `jimfs://` URIs via installed-provider lookup | `CrossClassLoaderAccessTest.java:45 new URI("jimfs", fsName, "/test-path", null, null)` → `:47 Paths.get(isolatedUri)` on an isolated `URLClassLoader`; no direct `ServiceLoader` usage in tests (grep exit 1); `SystemJimfsFileSystemProvider` appears only in javadoc (`CrossClassLoaderAccessTest.java:27`, `ClassLoaderTest.java:40`) |
| Test libs | `com.google.common.testing` / `com.google.common.truth` imported in 36 of 52 test files (e.g. `AbstractJimfsIntegrationTest`) |

## 3. STEP 1 — Copy verbatim (copy-then-prune: copy the WHOLE block first)

Extracted standalone tree (everything below copied byte-identical from the PIN tree):

```
<extraction-root>/
├── pom.xml                  # ← root pom.xml, copied whole, then pruned (§4.2) — artifactId stays jimfs-parent
├── LICENSE                  # ← verbatim (Apache-2.0, declared root pom.xml:47-53)
└── jimfs/
    ├── pom.xml              # ← VERBATIM, ZERO edits (module pom, 108 lines)
    └── src/
        ├── main/java/com/google/common/jimfs/   # ← all 62 .java files, verbatim
        └── test/java/com/google/common/jimfs/   # ← all 52 .java files, verbatim
```

- All 52 test files are copied: the universe is a single package and the test tree
  mirrors it in-package (helpers included: `PathSubject.java`, `PathTester.java`,
  `TestUtils.java`, `TestAttributeProvider.java`, …) — every one of them is a
  "related test" of the one and only item.
- Minimal config = the two poms (parent + module) exactly as upstream, minus the
  §4.2 prune list; no other config file exists in `jimfs/src` (see §2, `0` matches).
- NOT copied (repo metadata / CI, zero build-test effect): `.github/`, `README.md`,
  `CONTRIBUTING.md`, `.gitignore`, `util/update_snapshot_docs.sh` (gh-pages publisher
  requiring `GITHUB_TOKEN`).

## 4. STEP 2 — Prune decisions (every decision, one-line reason)

### 4.1 Dependencies (from `jimfs/pom.xml:38-82` + parent `dependencyManagement` `pom.xml:91-144`)

| Dependency | Pinned version | Decision | Reason (1 line) |
|---|---|---|---|
| `com.google.guava:guava` | 33.7.2-jre (`pom.xml:87,94-98`) | **GIỮ** | core runtime: 191 import statements across 50/62 main files (`gm-02:63`), irreplacable without editing copied sources |
| `com.ibm.icu:icu4j` | 77.1 (`pom.xml:101-105`) | **GIỮ** | hard main-tree import `PathNormalization.java:21` — cutting breaks compile of the verbatim copy |
| `com.google.auto.service:auto-service-annotations` | 1.1.1 (`pom.xml:108-112`) | **GIỮ** | annotation on `SystemJimfsFileSystemProvider.java:62` must compile |
| `com.google.code.findbugs:jsr305` | 3.0.2 (`pom.xml:113-117`) | **GIỮ** | `package-info.java:27` import |
| `org.jspecify:jspecify` | 1.0.1 (`pom.xml:118-122`) | **GIỮ** | 31 main files import `org.jspecify.annotations` |
| `com.google.errorprone:error_prone_annotations` | transitive (via guava) | **GIỮ** (transitive) | 12 main files import it, e.g. `FileSystemState.java:24` |
| `junit:junit` | 4.13.2, test (`pom.xml:125-130`) | **GIỮ** | all 52 test classes are JUnit4 |
| `com.google.guava:guava-testlib` | 33.7.2-jre, test (`pom.xml:131-136`) | **GIỮ** | `com.google.common.testing` imported in the 36-file test-lib evidence set |
| `com.google.truth:truth` | 1.4.5, test (`pom.xml:137-142`) | **GIỮ** | same 36-file evidence set (`com.google.common.truth`) |
| **VENDOR anything?** | — | **none** | every dependency is on Maven Central at the exact pinned version; vendoring would either duplicate artifacts or force edits to verbatim sources — unnecessary |
| **CẮT any dependency?** | — | **none** | no import root can be removed without editing the 62 copied sources, which the copy-verbatim rule forbids |

### 4.2 Build config — prune list (root `pom.xml` only; `jimfs/pom.xml` stays VERBATIM)

CẮT from the copied parent pom (all evidence `File: pom.xml | Dòng: …`):

| # | What | Where | Reason (1 line) |
|---|---|---|---|
| C1 | `central-publishing-maven-plugin` 0.12.0 (`extensions=true`) | :267-272 | Sonatype Central publishing needs credentials; useless for a standalone offline build |
| C2 | `maven-gpg-plugin` pluginManagement entry | :158-161 | signing plugin config with no signing keys available |
| C3 | `sonatype-oss-release` profile (gpg `sign-artifacts`) | :350-368 | release-signing profile; activating it would fail without a GPG key |
| C4 | javadoc `attach-javadocs` execution (`goal=jar`) | :243-253 | javadoc jar binds at `package`; not part of the compile/test gate and adds doclint noise |
| C5 | source `attach-sources` execution (`goal=jar-no-fork`) | :255-265 | sources jar not needed for the gate |
| C6 | `errorprone-enabled` profile (ErrorProne + beta-checker, forked javac, 9 `--add-exports`/`--add-opens` flags, `-Xep:Java8ApiChecker:ERROR`) | :296-348 | JDK21+-only analysis that can turn warnings into build errors → cut for deterministic builds on any JDK |
| C7 | not copied at all: `.github/`, `README.md`, `CONTRIBUTING.md`, `.gitignore`, `util/` | repo root | repo metadata / CI / gh-pages publishing, no effect on compile or tests |

GIỮ in the copied parent pom (everything not in C1–C7), notably:

| What | Where | Reason (1 line) |
|---|---|---|
| properties (encoding + all version pins incl. `java.version=1.8`, `guava.version`, `auto-service.version`) | :82-89 | exact upstream versions, zero drift |
| `dependencyManagement` block | :91-144 | single source of truth for all §4.1 versions |
| `maven-compiler-plugin` + `annotationProcessorPaths` (`auto-service` processor + `auto-common`) | :212-230 | **critical**: generates `META-INF/services/java.nio.file.spi.FileSystemProvider` at compile; `CrossClassLoaderAccessTest.java:45-47` resolves `jimfs://` through `Paths.get` → installed-provider ServiceLoader discovery, which fails with `ProviderNotFoundException` without the generated file |
| `maven-jar-plugin` `Automatic-Module-Name=com.google.common.jimfs` | :232-241 | JPMS module-name fidelity, zero cost |
| surefire pin 3.6.0 (+ other pluginManagement version pins: compiler 3.16.0 :149-152, deploy 3.2.0 :153-157, install :162-165, javadoc 3.12.0 :166-185, jar 3.5.1 :186-190, resources :191-194, source 3.4.0 :195-198, bundle 6.0.0 :203-207) | :147-209 | version pins prevent Maven from resolving incompatible plugin versions (root pom comments :156, :187 explain this exactly) |
| `before-jdk17` profile (bundle-plugin 5.1.9 on JDK <17) | :277-294 | keeps `mvn package` working on JDK 8–16 (bundle 6.0.0 needs 17+) |

Module `jimfs/pom.xml` keeps everything verbatim, including its javadoc `configuration`
block (:86-91 — configuration only, no execution bound, inert) and the felix
`maven-bundle-plugin` with `Export-Package com.google.common.jimfs.*` + `Include-Resource`
META-INF/services (:93-105) — the bundle plugin only executes at `package`, not at
`compile`/`test`.

## 5. STEP 3 — Standalone build+test commands (planned gate)

Dry-run performed this session — honest result: **SKIPPED**.

```
--- mvn ---    mvn_exit=1        (command -v mvn → not found)
--- java ---   java_exit=1       (command -v java → not found)
--- javac ---  javac_exit=1      (command -v javac → not found)
```

`bitnami/git:latest` ships no JDK and no Maven (no `apt-get` either), and installing
them would exceed the brief's <2-minute dry-run budget — per brief line 11 this is
recorded as SKIPPED, no output fabricated.

Executor commands (on a machine with JDK 8–21 + Maven 3.9.x, run from `<extraction-root>`):

1. `mvn -q -DskipTests compile` → expect BUILD SUCCESS compiling exactly 62 main files.
2. `mvn -q test` → expect all 52 test classes green (surefire 3.6.0); upstream test
   LOC 12999 vs main 12468 (ratio 1.0426) is the S3 oracle already frozen in gm-08.
3. Optional packaging gate: `mvn -q package -DskipTests` → proves the felix bundle
   packaging (module pom :30, :93-105) still assembles after the C1–C6 prune.
4. Post-prune SPI check: `jimfs/target/classes/META-INF/services/java.nio.file.spi.FileSystemProvider`
   must exist and contain `com.google.common.jimfs.SystemJimfsFileSystemProvider`.

JDK notes for the executor: upstream targets 1.8 (`pom.xml:86,215-216`); with the
errorprone profile cut (C6) the compile/test result is JDK-uniform; `mvn package`
on JDK <17 is handled by the kept `before-jdk17` profile (`pom.xml:277-294`).

## 6. STEP 4 — Prune risks + post-prune checks

| Risk | Check after prune |
|---|---|
| AutoService processor accidentally pruned → `CrossClassLoaderAccessTest` fails at runtime with `ProviderNotFoundException` (silently — code still compiles) | run check §5.4; rerun `mvn test`; the single failing class pinpoints it |
| icu4j dropped as "optional" → compile error at `PathNormalization.java:21` | `grep -rn 'com.ibm.icu' jimfs/src/main` must show exactly 1 file BEFORE any dependency prune |
| errorprone profile kept by mistake on a JDK 21+ machine → `-Xep:Java8ApiChecker:ERROR` may fail the build for reasons unrelated to the extraction | `mvn help:effective-pom` must NOT contain `error_prone_core` after prune |
| central-publishing extension left in → Maven tries to resolve/download the extension even offline | `mvn -q -DskipTests compile` completes with zero Sonatype-plugin resolution |
| Byte-identity drift during the copy | `diff -r <extraction-root>/jimfs/src <clone-at-PIN>/jimfs/src` → 0 differences; file counts 62 main + 52 test = 114; census LOC 12468 + 12999 unchanged |
| Wrong JDK used (≥ 25?) where source level 8 is unsupported by the toolchain | record `java -version` + `mvn -v` in the cut report; source/target 1.8 is still supported by JDK 8–21 toolchains used by upstream CI |

## 7. Handoff

- This plan defines ONLY what the cut command should do; the cut, the standalone
  build/test run, and any repo creation belong to a separate node outside this run.
- Per node contract, the sandbox is left to expire via ttl (7200s) — no cleanup.
