---
subject: google/jimfs
measured_at: 8fa098e0715aa492914285312c07e151d2aace4d
status: final
---


# Extraction plan — `com.google.common.jimfs`


This is the extraction plan for the single ≥4-star item of the subject. The
actual cut lives in `modules/jimfs/com.google.common.jimfs/` (verbatim source
+ `PROVENANCE.md`); this document records what the cut does and how to verify
it.


## Selected item


The star-ranked universe is exactly 1 item, and it qualifies (rubric in
`docs/method/rubric.md`):

| id | module | stars | signal bands |
|---|---|---|---|
| m01 | `com.google.common.jimfs` | 5 | S1 B (6 external dep roots, band 3–6) · S2 A (fan-in 5 + fan-out 7 = 12, ≥10) · S3 A (test ratio 1.0426 = 12,999/12,468, ≥1.0) · S4 A (4 typed evidence entries spanning 2 types) · S5 A (main LOC 12,468 ≥ 5,000 ∧ public methods 391 ≥ 50) |

The extraction unit is coherent: google/jimfs is a **single Maven module**
whose main tree is one flat package
`jimfs/src/main/java/com/google/common/jimfs` (62 files / 12,468 LOC) and
whose test tree mirrors the same package (52 files / 12,999 LOC). Test files
are not items (single-module subject definition) but they are the regression
oracle (S3 ratio 1.0426 ≥ 1.0).

**Second slot: N/A.** The ≥4★ universe = {m01}; a second element does not
exist, so no second plan is made and nothing outside this item's scope is
cut.


## Step 1 — Copy verbatim (copy-then-prune: copy the whole block first)


```
<extraction-root>/
├── pom.xml                  # ← root pom.xml, copied whole, then pruned — artifactId stays jimfs-parent
├── LICENSE                  # ← verbatim (Apache-2.0, declared root pom.xml:47-53)
└── jimfs/
    ├── pom.xml              # ← VERBATIM, zero edits (module pom, 108 lines)
    └── src/
        ├── main/java/com/google/common/jimfs/   # ← all 62 .java files, verbatim
        └── test/java/com/google/common/jimfs/   # ← all 52 .java files, verbatim
```

- All 52 test files are copied: the universe is a single package and the test
  tree mirrors it in-package (helpers included: `PathSubject.java`,
  `PathTester.java`, `TestUtils.java`, `TestAttributeProvider.java`, …) —
  every one of them is a related test of the one and only item.
- Minimal config = the two poms (parent + module) exactly as upstream, minus
  the prune list below; no other config file exists in `jimfs/src`
  (`find jimfs/src -name 'META-INF*' -o -name '*.properties' -o -name '*.xml'` → 0).
- NOT copied (repo metadata / CI, zero build-test effect): `.github/`,
  `README.md`, `CONTRIBUTING.md`, `.gitignore`, `util/update_snapshot_docs.sh`.


## Step 2 — Prune decisions


### Dependencies (from `jimfs/pom.xml:38-82` + parent `dependencyManagement` `pom.xml:91-144`)

| dependency | pinned version | decision | reason |
|---|---|---|---|
| `com.google.guava:guava` | 33.7.2-jre (`pom.xml:87,94-98`) | keep | core runtime: 191 import statements across 50/62 main files; irreplaceable without editing copied sources |
| `com.ibm.icu:icu4j` | 77.1 (`pom.xml:101-105`) | keep | hard main-tree import `PathNormalization.java:21` — cutting breaks compile of the verbatim copy |
| `com.google.auto.service:auto-service-annotations` | 1.1.1 (`pom.xml:108-112`) | keep | annotation on `SystemJimfsFileSystemProvider.java:62` must compile |
| `com.google.code.findbugs:jsr305` | 3.0.2 (`pom.xml:113-117`) | keep | `package-info.java:27` import |
| `org.jspecify:jspecify` | 1.0.1 (`pom.xml:118-122`) | keep | 31 main files import `org.jspecify.annotations` |
| `com.google.errorprone:error_prone_annotations` | transitive (via guava) | keep (transitive) | 12 main files import it, e.g. `FileSystemState.java:24` |
| `junit:junit` | 4.13.2, test (`pom.xml:125-130`) | keep | all 52 test classes are JUnit 4 |
| `com.google.guava:guava-testlib` | 33.7.2-jre, test (`pom.xml:131-136`) | keep | `com.google.common.testing` imported in 36 of 52 test files |
| `com.google.truth:truth` | 1.4.5, test (`pom.xml:137-142`) | keep | same 36-file set (`com.google.common.truth`) |

- **Vendor anything?** No — every dependency is on Maven Central at the exact
  pinned version; vendoring would either duplicate artifacts or force edits
  to verbatim sources.
- **Cut any dependency?** No — no import root can be removed without editing
  the 62 copied sources, which the copy-verbatim rule forbids.

### Build config — prune list (root `pom.xml` only; `jimfs/pom.xml` stays verbatim)

| # | what | where | reason |
|---|---|---|---|
| C1 | `central-publishing-maven-plugin` 0.12.0 (`extensions=true`) | `:267-272` | Sonatype Central publishing needs credentials; useless for a standalone offline build |
| C2 | `maven-gpg-plugin` pluginManagement entry | `:158-161` | signing plugin config with no signing keys available |
| C3 | `sonatype-oss-release` profile (gpg `sign-artifacts`) | `:350-368` | release-signing profile; activating it would fail without a GPG key |
| C4 | javadoc `attach-javadocs` execution (`goal=jar`) | `:243-253` | javadoc jar binds at `package`; not part of the compile/test gate and adds doclint noise |
| C5 | source `attach-sources` execution (`goal=jar-no-fork`) | `:255-265` | sources jar not needed for the gate |
| C6 | `errorprone-enabled` profile (ErrorProne + beta-checker, forked javac, 9 `--add-exports`/`--add-opens` flags, `-Xep:Java8ApiChecker:ERROR`) | `:296-348` | JDK21+-only analysis that can turn warnings into build errors → cut for deterministic builds on any JDK |
| C7 | not copied at all: `.github/`, `README.md`, `CONTRIBUTING.md`, `.gitignore`, `util/` | repo root | repo metadata / CI / docs publishing, no effect on compile or tests |

Kept in the copied parent pom (everything not in C1–C7), notably:

| what | where | reason |
|---|---|---|
| properties (encoding + all version pins incl. `java.version=1.8`, `guava.version`, `auto-service.version`) | `:82-89` | exact upstream versions, zero drift |
| `dependencyManagement` block | `:91-144` | single source of truth for the dependency table above |
| `maven-compiler-plugin` + `annotationProcessorPaths` (`auto-service` processor + `auto-common`) | `:212-230` | **critical**: generates `META-INF/services/java.nio.file.spi.FileSystemProvider` at compile; `CrossClassLoaderAccessTest.java:45-47` resolves `jimfs://` through `Paths.get` → installed-provider ServiceLoader discovery, which fails with `ProviderNotFoundException` without the generated file |
| `maven-jar-plugin` `Automatic-Module-Name=com.google.common.jimfs` | `:232-241` | JPMS module-name fidelity, zero cost |
| surefire pin 3.6.0 (+ other pluginManagement pins: compiler 3.16.0 `:149-152`, deploy 3.2.0 `:153-157`, install `:162-165`, javadoc 3.12.0 `:166-185`, jar 3.5.1 `:186-190`, resources `:191-194`, source 3.4.0 `:195-198`, bundle 6.0.0 `:203-207`) | `:147-209` | version pins prevent Maven from resolving incompatible plugin versions |
| `before-jdk17` profile (bundle-plugin 5.1.9 on JDK <17) | `:277-294` | keeps `mvn package` working on JDK 8–16 (bundle 6.0.0 needs 17+) |

Module `jimfs/pom.xml` keeps everything verbatim, including its javadoc
`configuration` block (`:86-91` — configuration only, no execution bound,
inert) and the felix `maven-bundle-plugin` with
`Export-Package com.google.common.jimfs.*` + `Include-Resource`
META-INF/services (`:93-105`) — the bundle plugin only executes at `package`,
not at `compile`/`test`.


## Step 3 — Standalone build+test commands (gate)


On a machine with JDK 8–21 + Maven 3.9.x, run from `<extraction-root>`:

1. `mvn -q -DskipTests compile` → expect BUILD SUCCESS compiling exactly 62
   main files.
2. `mvn -q test` → expect all 52 test classes green (surefire 3.6.0); the
   upstream test LOC 12,999 vs main 12,468 (ratio 1.0426) is the S3 oracle.
3. Optional packaging gate: `mvn -q package -DskipTests` → proves the felix
   bundle packaging (module pom `:30`, `:93-105`) still assembles after the
   C1–C6 prune.
4. Post-prune SPI check: `jimfs/target/classes/META-INF/services/java.nio.file.spi.FileSystemProvider`
   must exist and contain `com.google.common.jimfs.SystemJimfsFileSystemProvider`.

JDK notes: upstream targets 1.8 (`pom.xml:86,215-216`); with the errorprone
profile cut (C6) the compile/test result is JDK-uniform; `mvn package` on
JDK <17 is handled by the kept `before-jdk17` profile (`pom.xml:277-294`).

Honest status of this plan: the dry run was **not executed** in the planning
environment (its image ships no JDK and no Maven); the build/test evidence
for the subject instead comes from the real run on the upstream pin —
`mvn -q -DskipTests compile` exit 0 and `mvn test` 5,906 run / 0 fail /
1 skip, BUILD SUCCESS (see `docs/jimfs/04-overview.md`). The actual extracted
copy under `modules/jimfs/` is source-verbatim and was verified byte-identical
to the pin (see `modules/jimfs/com.google.common.jimfs/PROVENANCE.md`).


## Step 4 — Prune risks + post-prune checks


| risk | check after prune |
|---|---|
| AutoService processor accidentally pruned → `CrossClassLoaderAccessTest` fails at runtime with `ProviderNotFoundException` (silently — code still compiles) | run check 4; rerun `mvn test`; the single failing class pinpoints it |
| icu4j dropped as "optional" → compile error at `PathNormalization.java:21` | `grep -rn 'com.ibm.icu' jimfs/src/main` must show exactly 1 file before any dependency prune |
| errorprone profile kept by mistake on a JDK 21+ machine → `-Xep:Java8ApiChecker:ERROR` may fail the build for reasons unrelated to the extraction | `mvn help:effective-pom` must NOT contain `error_prone_core` after prune |
| central-publishing extension left in → Maven tries to resolve/download the extension even offline | `mvn -q -DskipTests compile` completes with zero Sonatype-plugin resolution |
| Byte-identity drift during the copy | `diff -r <extraction-root>/jimfs/src <clone-at-pin>/jimfs/src` → 0 differences; file counts 62 main + 52 test = 114; census LOC 12,468 + 12,999 unchanged |
| Wrong JDK used where source level 8 is unsupported by the toolchain | record `java -version` + `mvn -v` in the cut report; source/target 1.8 is supported by JDK 8–21 toolchains |
