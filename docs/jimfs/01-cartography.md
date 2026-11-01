---
subject: google/jimfs
measured_at: 8fa098e0715aa492914285312c07e151d2aace4d
status: final
---


# Cartography


google/jimfs — an in-memory implementation of Java 7's `java.nio.file`
abstract file system API. All numbers below were measured on a shallow clone
(≤100 commits, branch `master`) at the pin
`8fa098e0715aa492914285312c07e151d2aace4d` (2026-10-22, "Bump
org.sonatype.central:central-publishing-maven-plugin from 0.11.0 to 0.12.0 in
the dependencies group"). The commit count 100 is a lower bound caused by the
shallow clone, not total repository history.


## License gate


`LICENSE` exists at the repository root (11,357 bytes, "Apache License /
Version 2.0, January 2004"). PASS — Apache-2.0.


## Census (per-extension count, then summed)


| scope | files | lines |
|---|---|---|
| `.java`, whole tree | 114 | 25,467 |
| `.java`, `jimfs/src/main` | 62 | 12,468 |
| `.java`, `jimfs/src/test` | 52 | 12,999 |

Invariants hold exactly: 62 + 52 = 114 files; 12,468 + 12,999 = 25,467 lines.
Test files are not checklist items for this subject (single Maven module, so
the item universe is defined at package level under `jimfs/src/main/java`);
the test tree serves as the regression oracle.


## Build manifests


Root `pom.xml` (371 lines) declares exactly one module:

```xml
<groupId>com.google.jimfs</groupId>
<artifactId>jimfs-parent</artifactId>
<packaging>pom</packaging>
<version>HEAD-SNAPSHOT</version>
<modules>
  <module>jimfs</module>
</modules>
```

(`<module>jimfs</module>` at `pom.xml:29`.) The module POM `jimfs/pom.xml`
declares `com.google.jimfs:jimfs` with `<packaging>bundle</packaging>` and
depends on `com.google.guava:guava`. This confirms the subject definition:
jimfs is a single Maven module, so the item universe is the set of Java
packages under `jimfs/src/main/java`.


## Entry points


```
grep -rln 'public static void main' jimfs/src   → no output (0 results)
```

JimFS is a pure library: `entrypoints = []`.


## Top-level directories


| directory | contents |
|---|---|
| `/` | `pom.xml` (parent), `README.md`, `LICENSE`, `CONTRIBUTING.md`, `.github/` (dependabot.yml, workflows/ci.yml), `.gitignore` |
| `jimfs/` | the single Maven module `com.google.jimfs:jimfs` (packaging `bundle`) |
| `jimfs/src/` | only the two standard Maven trees `main/java` and `test/java`, each holding exactly one package `com/google/common/jimfs` — no `resources`, no other source tree (13 directories under `jimfs/src` in total) |
| `util/` | one shell script, `util/update_snapshot_docs.sh` (docs-update helper; outside every Maven tree) |

The whole implementation lives in `jimfs/src`.


## Java package universe


```
find jimfs/src/main/java -type d | sort
→ com / com/google / com/google/common / com/google/common/jimfs
find jimfs/src/main/java/com/google/common/jimfs -maxdepth 1 -name '*.java' | wc -l  → 62
find jimfs/src/main/java/com/google/common/jimfs -mindepth 1 -type d | wc -l        → 0
```

The universe is exactly one leaf package, `com.google.common.jimfs` — 62
`.java` files, 12,468 LOC, 0 subpackages. At package granularity the subject
therefore has exactly one item (`m01`). The Maven POM does not declare
packages; this list is derived from the source tree under
`jimfs/src/main/java`.


## Provenance


| field | value |
|---|---|
| upstream | https://github.com/google/jimfs (branch `master`) |
| pin | `8fa098e0715aa492914285312c07e151d2aace4d` |
| license | Apache License 2.0 |
| language | Java (single Maven module `com.google.jimfs:jimfs`) |
| census | 114 files / 25,467 LOC total; main 62 / 12,468; test 52 / 12,999 |
| re-sync | see [`tracking/jimfs.md`](../../tracking/jimfs.md) |
