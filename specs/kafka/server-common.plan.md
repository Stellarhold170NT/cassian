# Extraction plan — `server-common` (5★, second module of the ≥4★ set)

> **This file is a plan, not a cut.** Nothing in this repository has been cut,
> repackaged, or pushed by this plan. The actual extraction runs later as a
> standalone procedure using the commands in this document; the acceptance
> gates below define when the result may be published. Every command below was
> rehearsed against a real clone of the measured tree except the final
> build/push steps (they require a JDK 17 + Gradle environment, which the
> planning environment lacked — declared in the risks section).

## 1. Module selection

The reuse-readiness ranking (`05-stars.md`) has two 5★ modules — `clients` and
`server-common`. `server-common` is the second module of the ≥4★ set and the
target of this plan; `clients` is covered by the companion plan
[`clients.plan.md`](clients.plan.md). The ordering is unambiguous: module ids
ascend and the rubric's edge-count tie-break agrees (`clients` fan 23 >
`server-common` 17). The ≥4★ set has 8 members, so the selection never falls
back to an unrated module.

## 2. Verified module facts

| quantity | value (measured) | note |
|---|---|---|
| depends_on | `clients` (single dependency) | 16 `org.apache.kafka.clients.*` import statements + 4 `server.authorizer` imports (owned by clients) + `common.*` except 2 self-owned `DirectoryId` classes |
| depended_by | 16 modules | spot-check on a newer tree: metadata 79, server 70, storage 45, raft 38, shell 1 importing files |
| test/source ratio | 0.4507 | T = 16,195 (files under any `src/test*` path, incl. testFixtures 872) / A = 35,932 |
| source size | 35,932 lines / 211 java+scala files | full census of `server-common/src`; 212 git-tracked files (the extra one is a testFixtures resource) |
| public-method count | 825 main-scope methods | regex count minus accessors; identical across the measurement trees |
| scala sources | 0 | pure Java module |
| entry | `server-common/src/main/java/org/apache/kafka/server/common/MetadataVersion.java` (enum declared at line 47) | |
| largest file | `server-common/src/main/java/org/apache/kafka/server/share/persister/PersisterStateManager.java` (1,842 lines) | |
| import profile (src/main) | 175 `common` / 30 `server` / 16 `clients` statements | stable across trees |

Every number reproduces exactly across four independent trees
(`aa62a433…`, `6014921…`, `0c92b066…`, `14ee92ca…`) — the module is stable
across upstream drift and the 5★ rating is re-affirmed.

## 3. Key discovery: no module owns a build file anymore

At the measured tree **no regular module has its own `build.gradle`** — the
only module-scoped build files in the repo (4) belong to the `api-checker`
composite build. All 65-module configuration is centralized in the root
`build.gradle` (4,451 lines). For `server-common`:

- `server-common/` contains only `src/`.
- Its configuration lives in the root build's `project(':server-common')`
  block: `base { archivesName = "kafka-server-common" }`, plugin
  `java-test-fixtures`, and the dependency set — **`api project(':clients')`**
  (matching deps_on), `libs.metrics`, `libs.joptSimple`, `libs.jacksonDatabind`,
  `libs.pcollections`, `libs.slf4jApi`, the clients testFixtures/test
  configuration, the `createVersionFile` task, `jar`, `clean.doFirst`, a
  dedicated `checkstyle { configProperties =
  checkstyleConfigProperties("import-control-server-common.xml") }`, and
  `javadoc { enabled = false }`.
- Build scaffolding: `settings.gradle` (144 lines, includes `server-common` at
  line 98; `rootProject.name = 'kafka'`), `gradle/dependencies.gradle`
  (240 lines, applied from the root build), `gradle.properties`
  (group `org.apache.kafka`, version 4.5.0-SNAPSHOT, scala 2.13.18), wrapper
  **Gradle 9.8.2**, and `checkstyle/` (23 files, must include
  `import-control-server-common.xml`).

Consequence: the cut cannot be a bare `server-common/` copy — it must carry
the centralized scaffolding, and building it standalone requires `clients`
from the companion plan.

## 4. Cut inventory (copy-then-prune: copy intact, then trim)

| # | path to cut | why |
|---|---|---|
| 1 | `server-common/` (whole dir, 212 tracked files) | the module body: 211 java files + 1 testFixtures resource, 35,932 lines |
| 2 | `settings.gradle` (144 lines, trimmed to 2 includes) | module includes + pluginManagement |
| 3 | `build.gradle` (root; trimmed per the recipe below) | the `:server-common` and `:clients` blocks plus shared config |
| 4 | `gradle/dependencies.gradle` + `gradle/spotbugs-exclude.xml` + `gradle/wrapper/` + `gradlew` | version map (`libs.*`), exclude rules, Gradle 9.8.2 wrapper |
| 5 | `gradle.properties` | group/version/scalaVersion |
| 6 | `checkstyle/` (23 files, must include `import-control-server-common.xml`) | referenced directly by the `:server-common` block |
| 7 | `LICENSE` + `NOTICE` (+ ASF headers preserved in every kept file) | license gate |
| 8 | input from the companion plan: the cut `clients/` tree (or an equivalent `kafka-clients` artifact) | `api project(':clients')` — the build cannot compile without it |

**Trim recipe (option A — buildable):** keep, in order: header (buildscript,
plugins, `apply from`, common config) → `allprojects` and `subprojects` blocks
verbatim → the `project(':clients')` block → the `project(':server-common')`
block → drop every other `project(':X')` block and every `project(':X')`
reference with X ∉ {clients, server-common}. ⚠️ Block line numbers (the
`:server-common` block spans lines 2410–2477 at the measured tree) are valid
only at that tree; at the actual cut pin re-derive them with
`grep -n "^project(':server-common') {"` (step 4 of the commands).

**Option B (fallback — not buildable):** cut source-only (#1, #5, #7) and keep
the `:server-common` block as a reference file; drops the build gate, all
other gates still apply.

## 5. Commands for the actual cut (run outside this repository's workflow)

Conventions: `$PIN` is the pin fixed in step 0; every command's pass condition
is stated.

- **0) Fix the pin (fail-closed):**
  ```bash
  PIN=$(git ls-remote https://github.com/apache/kafka refs/heads/trunk | cut -d' ' -f1)
  ```
  Record the pin in the cut metadata; gates compare against this tree. Accept
  a newer pin only if gates G2–G4 reproduce the certified numbers (already
  proven stable across four trees). Otherwise stop and re-certify first.
- **1) Clone and checkout the pin:**
  ```bash
  git clone --quiet --depth 100 --single-branch -b trunk https://github.com/apache/kafka /workspace/kafka
  cd /workspace/kafka && git checkout $PIN
  ```
  Pass when `git rev-parse HEAD` == PIN.
- **2) License gate:** `ls LICENSE NOTICE` — both must exist.
- **3) Staging copy:**
  ```bash
  mkdir -p /workspace/cut
  cp -a server-common gradle gradlew gradle.properties settings.gradle build.gradle checkstyle LICENSE NOTICE /workspace/cut/
  ```
  Pass when `find /workspace/cut/server-common/src -type f \( -name '*.java' -o -name '*.scala' \) | wc -l` = 211 (and census loc = 35,932).
- **4) Trim the build (option A):** write a new `settings.gradle` with exactly
  2 includes and a new root `build.gradle` per the recipe (re-derive block
  boundaries with `grep -n "^project(':server-common') {"`). Pass when
  `grep -c "^project('" build.gradle` = 2.
- **5) Build gate:** `JAVA_HOME=<jdk17> ./gradlew :clients:compileJava :server-common:compileJava` — pass on exit 0 (requires the clients cut from the companion plan in the staging tree).
- **6) Test gate:** `./gradlew :server-common:test` — pass on exit 0 (16,195 lines of tests).
- **7) Publish (last, fail-closed):** commit the cut tree to a dedicated seed
  branch; never force-push; never modify the already-published `modules/`
  content or `README.md`. Final layout per the repository contract:
  `modules/kafka/server-common/` + a `PROVENANCE.md` (pin, path, license,
  measured size).

## 6. Acceptance gates

| gate | metric | oracle | pass threshold |
|---|---|---|---|
| G1 | correct tree | `git rev-parse HEAD` | == PIN (exact) |
| G2 | inventory intact | java+scala census of `server-common/src` | files=211 ∧ loc=35932 (±0 at the certified pin) |
| G3 | test ratio | T (file-level `*src/test*`, incl. testFixtures) / A | = 0.4507 (rounding ≤0.0005) |
| G4 | public-method count | main-scope regex count minus accessors | = 825 (±0) |
| G5 | dependencies | import scan of src/main mapped to owning modules | external module set == {clients} |
| G6 | build | `:server-common:compileJava` | exit 0 (option A only) |
| G7 | license + style | `checkstyle/import-control-server-common.xml` present; ASF headers intact | both |

Fail-closed: any gate failure → no push, report blocked with raw output.

## 7. Verification across three trees

The gate battery (G2 census, G3 ratio, G4 method count, import profile,
dependency edges, block span, entry declaration) was re-run independently on
three upstream trees with zero numeric discrepancies:

| quantity | pin `aa62a433` | tree `6014921` | tree `0c92b066` |
|---|---|---|---|
| java+scala files | 211 | 211 | 211 |
| census lines | 35932 | 35932 | 35932 |
| testFixtures lines | 872 | 872 | 872 |
| ratio T/A | 0.4507 | 0.4507 | 0.4507 |
| public-method count | 825 | 825 | 825 |
| import profile (main) | — | 175/30/16 | 175/30/16 |
| depends_on | {clients} | {clients} | {clients} (16 statements) |
| block span (`:server-common`) | — | 2410–2477 | 2410–2477 |
| entry `MetadataVersion.java:47` | `public enum MetadataVersion {` | same | same |
| G7 license/checkstyle | present | present | present |

## 8. Risks and caveats

1. **Trunk drift** — re-derive gates G2–G4 at the cut pin; small deltas are
   declared, star-flipping deltas stop the cut (fail-closed pin policy).
2. **Centralized build** — block line numbers are tree-specific; always
   re-derive with grep (step 4). Cosmetic reformatting inside a block (seen
   between trees) does not change the recipe, but the span must be re-derived.
3. **Build/test not dry-run here** — gates G6 need JDK 17 + Gradle and run only
   during the actual cut.
4. **Cross-plan input** — the build consumes `clients` (companion plan);
   without it only option B applies.
5. **Measurement-scope note** — the 16-statement dependency count and the
   9-file count are different scales (statements vs files); do not mix them
   when re-measuring.
6. **Target repo is not empty** — the `modules/kafka/` harvest and `README.md`
   already exist; the cut must publish to its own seed branch without touching
   either.

## 9. Re-verification at a fourth tree

The section-7 battery was re-run unchanged against trunk pin
`14ee92ca1ecf469eb8f006abf7b75453513cac49` ("KAFKA-21230: Pause task executors
on byte limit (#23984)") — the fourth measured tree. The drift window explains
the result mechanically: trunk advanced exactly one commit past `0c92b066`
(`git rev-list --count 0c92b066..HEAD` = 1), and that commit touches no file
under `server-common/` (`git log --oneline 0c92b066..HEAD -- server-common`
is empty). All 18 quantities reproduce identically:

| quantity | trees `aa62a433` / `6014921` / `0c92b066` | tree `14ee92ca` |
|---|---|---|
| java+scala files | 211 / 211 / 211 | 211 |
| census lines | 35932 / 35932 / 35932 | 35932 |
| testFixtures lines | 872 / 872 / 872 | 872 |
| git-tracked `server-common` files | — / 212 / 212 | 212 |
| ratio T/A | 0.4507 across all three | 0.4507 (16195/35932) |
| public-method count | 825 / 825 / 825 | 825 |
| sanity `KafkaProducer.java` line count | 26 / 22 (local tree drift) / 26 | 26 |
| import profile (main) | — / 175/30/16 / 175/30/16 | 175/30/16 |
| depends_on (`clients`) | 1 module / 16 statements / 16 statements | 16 statements |
| dependency spot (metadata/storage/raft/shell/server) | — / 79/45/38/1/70 / same | 79/45/38/1/70 |
| `:server-common` block span | — / 2410–2477 / 2410–2477 | 2410–2477 |
| build/settings/dependencies line counts | — / 4451/144/240 / same | 4451/144/240 |
| `settings.gradle` include line | — / 98 / 98 | 98 |
| `gradle.properties` group/version/scala | — / 16-18 / 16-18 | 16-18 |
| wrapper | — / 9.8.2 / 9.8.2 | 9.8.2 |
| checkstyle `import-control-server-common.xml` | — / present / present | present |
| entry `MetadataVersion.java:47` | `public enum MetadataVersion {` | same |
| largest file `PersisterStateManager` | 1842 / 1842 / 1842 | 1842 |

Risk 2's caveat (re-derive the block span with grep at the actual cut pin) and
the fail-closed pin policy stay in force unchanged.
