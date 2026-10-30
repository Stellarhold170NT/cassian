# Extraction plan — `clients` (5★, first module of the ≥4★ set)

> **This file is a plan, not a cut.** Nothing in this repository has been cut,
> repackaged, or pushed by this plan. The actual extraction runs later as a
> standalone procedure using the commands in this document; the acceptance
> gates below define when the result may be published. All measurements were
> verified on the upstream tree at `0c92b0664539d0dfb60b43ede0026497a581d8e0`
> and are identical at the extracts pin `aa62a433553c14866521bd40ff446b6920d4d67e`
> (see the pin policy in the commands section).

## 1. Module selection

The reuse-readiness ranking (`05-stars.md`) has two 5★ modules — `clients` and
`server-common` — followed by six 4★ modules. `clients` is the first module of
the ≥4★ set and the target of this plan; `server-common` is covered by the
companion plan [`server-common.plan.md`](server-common.plan.md). The ordering
is unambiguous: module ids ascend (`clients` before `server-common`) and the
rubric's edge-count tie-break agrees (`clients` fan 23 > `server-common` 17).

## 2. Verified module facts

| quantity | value (measured) | note |
|---|---|---|
| depends_on | — (leaf) | import scan of `clients/src/main` resolves only to packages owned by `clients` itself (`clients`, `common`, and the `server.authorizer/policy/quota/telemetry` packages that live inside clients) |
| depended_by | 23 modules | clients is the base of the dependency graph |
| test/source ratio | 0.4805 | T = 186,128 (files under any `src/test*` path, incl. testFixtures 7,880) / A = 387,364 |
| source size | 387,364 lines / 1,879 java+scala files | full census of `clients/src`; 2,157 git-tracked files under `clients/` including the separate `clients-integration-tests` module (not part of this plan) |
| public-method count | 6,928 main-scope methods | measured at the certification tree; 7,031 at the extracts pin — a pure drift delta, far above the 200-method threshold, star unaffected |
| scala sources | 0 | pure Java module |
| entry class | `clients/src/main/java/org/apache/kafka/clients/producer/KafkaProducer.java` (class declared at line 251) | |
| largest file | `clients/src/main/java/org/apache/kafka/clients/admin/KafkaAdminClient.java` (5,387 lines) | |

Conclusion: every rubric number reproduces exactly on the measured tree — the
module is stable across upstream drift and the 5★ rating is re-affirmed.

## 3. Key discovery: the build is centralized

`clients/` has **no `build.gradle` of its own** at the measured tree; its
configuration lives in the root `build.gradle` (4,451 lines) in the
`project(':clients')` block:

- `base { archivesName = "kafka-clients" }`, plugin `java-test-fixtures`, and
  the `generator`/`shadowed` configurations.
- **Codegen is mandatory:** `sourceSets.main.srcDirs` includes
  `build/generated/main/java` and `compileJava.dependsOn 'processMessages'`,
  which runs the `MessageGenerator` of module `:generator` over the **204
  message JSON files** in `clients/src/main/resources/common/message` (plus 6
  test-side JSONs). Copying `clients/src` without `:generator` and the codegen
  wiring will not compile.
- **shadowJar replaces jar:** `jar { enabled = false }`; `shadowJar` relocates
  `io.opentelemetry.proto`, `com.google.protobuf`, `org.apache.commons.net`
  and embeds `kafka-version.properties` (created by the `createVersionFile`
  task) plus the root `LICENSE`/`NOTICE`.
- **Global checkstyle:** `test.dependsOn('checkstyleMain', 'checkstyleTest')`
  with a repo-wide `checkstyle/import-control.xml` + `suppressions.xml`;
  `clients` itself has no per-module checkstyle file. Omitting `checkstyle/`
  fails the test gate immediately.
- Shared definitions referenced by the block: `runtimeTestLibs` (includes
  `project(":test-common:test-common-util")`), `testLog4j2Libs`,
  `buildVersionFileName` — all in the header of the root build file.

Consequence: the cut cannot be a bare `clients/src` copy; it must carry the
centralized scaffolding and two build-time helper modules.

## 4. Cut inventory (copy-then-prune: copy intact, then trim)

| # | path to cut | why |
|---|---|---|
| 1 | `clients/src/` (whole dir — main 1,562 + test 497 + testFixtures 35 tracked files) | the module body: 1,879 java+scala files, 387,364 lines, 204+6 message JSON specs |
| 2 | `generator/` (whole dir, 52 java files) | `:generator` — protocol codegen, required before `compileJava` |
| 3 | `test-common/test-common-util/` (whole dir, 5 java files) | dependency of `testImplementation`/`testFixturesImplementation`/`runtimeTestLibs` |
| 4 | `settings.gradle` (144 lines, trimmed to 3 includes) | module includes + pluginManagement |
| 5 | `build.gradle` (root; trimmed per the recipe below) | the `:clients` block plus shared header/allprojects/subprojects config |
| 6 | `gradle/dependencies.gradle` (240 lines, verbatim) | the `libs.*` version map |
| 7 | `gradle/wrapper/` + `gradlew` | Gradle 9.8.2 wrapper for an independent build |
| 8 | `gradle.properties` | group/version/scalaVersion |
| 9 | `checkstyle/` — at minimum `import-control.xml` + `suppressions.xml` | required by `test.dependsOn('checkstyleMain','checkstyleTest')` |
| 10 | `LICENSE` + `NOTICE` | copied into the jar by `shadowJar`; license gate |

**Trim recipe (option A — buildable):** keep, in order: header (buildscript,
`apply from`, `buildVersionFileName`, `runtimeTestLibs`, `testLog4j2Libs`,
compiler config) → `allprojects` and `subprojects` blocks verbatim →
`project(':generator')` block → `project(':test-common:test-common-util')`
block → `project(':clients')` block → drop every other `project(':X')` block
and every `project(':X')` reference with X ∉ {generator,
test-common:test-common-util, clients}. Also drop the
`project(':clients:clients-integration-tests')` block — that module is outside
this plan's scope. ⚠️ The block line numbers cited above are valid only at the
measured tree; at the actual cut pin re-derive them with
`grep -n "^project(':clients') {"` (step 4 of the commands).

**Option B (fallback — not buildable):** cut source-only (#1, #6, #8, #10) and
keep the `:clients` block as a reference file; drops the build/test gate, all
other gates still apply.

### Dependency keep/prune decisions

Keep (runtime of clients): `libs.zstd` 1.5.7-17, `libs.lz4`, `libs.snappy` and
`libs.slf4jApi` (all also on the `shadowed` configuration), `libs.opentelemetryProto`
(KIP-714 telemetry wire format) + `libs.protobuf` (its dependency),
`libs.commonsNet` (connection allowlist, commons-io excluded),
`libs.jacksonDatabind` + `libs.jose4j` (compileOnly — SASL/OAUTHBEARER token
parsing).

Keep (build/test infrastructure): `project(':generator')` (codegen),
`project(':test-common:test-common-util')`, the test stack verbatim (junit
5.14.4, mockito 5.24.0, bcpkix, log4j2 test libs, runtimeTestLibs,
`libs.testcontainersKeycloak`, `libs.jacksonJakartarsJsonProvider`),
checkstyle 12.3.1 + the two XML config files.

Vendor: none — clients embeds no vendored code; shading is handled by the
shadowJar relocation mechanism at build time.

Cut: `clients/clients-integration-tests/` (separate module, out of scope),
every other root-build `project(':X')` block, every `settings.gradle` include
outside the three kept modules (configuration phase fails on missing dirs
otherwise).

## 5. Commands for the actual cut (run outside this repository's workflow)

Conventions: `$PIN` is the pin fixed in step 0; every command's pass condition
is stated; no command below writes outside its staging area.

- **0) Fix the pin (fail-closed):**
  ```bash
  PIN=$(git ls-remote https://github.com/apache/kafka refs/heads/trunk | cut -d' ' -f1)
  ```
  Record the pin in the cut metadata; gates compare against this tree. If the
  gates below disagree with the certified numbers, stop and re-certify before
  cutting.
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
  cp -a clients/src generator test-common/test-common-util gradle gradlew \
        gradle.properties settings.gradle build.gradle checkstyle LICENSE NOTICE /workspace/cut/
  ```
  Pass when `find /workspace/cut/clients/src -type f \( -name '*.java' -o -name '*.scala' \) | wc -l` = 1879 and the census line count = 387,364 (at the cut pin; small drift must be declared, never star-flipping).
- **4) Trim the build (option A):** write a new `settings.gradle` with exactly
  3 includes and a new root `build.gradle` per the recipe (re-derive block
  boundaries with `grep -n "^project(':clients') {"`). Pass when
  `grep -c "^project('" build.gradle` = 3.
- **5) Build gate:** `JAVA_HOME=<jdk17> ./gradlew :clients:compileJava` — pass on exit 0.
- **6) Test gate:** `./gradlew :clients:test` — pass on exit 0 (497 test files
  + testFixtures, JUnit Platform). Without Docker, exclude the
  testcontainers-keycloak suites deliberately and declare the exclusion.
- **7) Publish (last, fail-closed):** commit the cut tree to a dedicated seed
  branch; never force-push; never modify the already-published `modules/`
  content or `README.md`. Final layout per the repository contract:
  `modules/kafka/clients/` + a `PROVENANCE.md` (pin, path, license, measured
  size).

## 6. Acceptance gates

| gate | metric | oracle | pass threshold |
|---|---|---|---|
| G1 | correct tree | `git rev-parse HEAD` | == PIN (exact) |
| G2 | inventory intact | java+scala census of `clients/src` | files=1879 ∧ loc=387364 (at the certified pin; declared drift allowed at a newer pin, star must not flip) |
| G3 | test ratio | T (file-level `*src/test*`, incl. testFixtures) / A | = 0.4805 (rounding ≤0.0005) |
| G4 | public-method count | main-scope regex count minus `get/set/is/has` accessors | ≥ 200 (reference 6,928 measured; drift declared) |
| G5 | dependencies | import scan of src/main mapped to owning modules | external module set == ∅ (leaf) |
| G6 | build + test | `:clients:compileJava` then `:clients:test` | exit 0 (option A only) |
| G7 | license + style | ASF headers intact; `checkstyle/import-control.xml` + `suppressions.xml` present | both |

Fail-closed: any gate failure → no push, report blocked with raw output.

## 7. Risks and caveats

1. **Trunk drift** — upstream moves constantly; re-derive gates G2–G4 at the
   cut pin. Small deltas are declared; star-flipping deltas stop the cut.
2. **Centralized build** — block line numbers are tree-specific; always
   re-derive with grep (step 4). If the block structure moved, fall back to
   option B and report.
3. **Codegen is mandatory** — cutting without `:generator` + `processMessages`
   cannot compile (204+6 message JSON specs feed generated sources).
4. **Build/test not dry-run here** — the planning environment had no JDK; gates
   G6 run only during the actual cut.
5. **Docker-dependent tests** — `testcontainersKeycloak` suites need Docker or
   a declared exclusion.
6. **Target repo is not empty** — the `modules/kafka/` harvest and `README.md`
   already exist; the cut must publish to its own seed branch without touching
   either.
7. **Cross-plan note** — this plan and the companion
   [`server-common.plan.md`](server-common.plan.md) share the same structure;
   server-common additionally consumes `clients` as an `api` dependency, so its
   cut expects the clients cut (or the published `kafka-clients` artifact) as
   input.

## 8. Re-verification at a later upstream pin

After this plan was written, the cheap gates were re-run unchanged against a
newer trunk pin, `14ee92ca1ecf469eb8f006abf7b75453513cac49` ("KAFKA-21230:
Pause task executors on byte limit (#23984)", one commit after the statistics
tree `0c92b066`). `git diff --stat 0c92b066..HEAD -- clients` is empty — no
`clients/` file changed between the two trees — so the numbers below were
re-measured on a tree where the module is byte-identical to the certified one.

| gate | expected (section 6) | re-measured at `14ee92ca` | result |
|---|---|---|---|
| G2 census | files=1879 ∧ loc=387364 | 1879 / 387364 | match |
| G3 ratio | 0.4805 (T/A) | T=186128, A=387364 → 0.4805 | match |
| G4 public-method count | ≈6928 ± drift | 6928 | match |
| G5 dependencies | ∅ (leaf) | package roots `clients`(683)/`common`(5038)/`server`(5) — all owned by clients | match |
| testFixtures lines | 7880 | 7880 | match |
| entry | `KafkaProducer.java:251` | 251, verbatim | match |
| file breakdown | src/main 1562 · src/test 497 · testFixtures 35 tracked (487+35 java); message JSON 204+6 | identical | match |
| build anchors | `:generator` 2019 · `:test-common-util` 1731 · `:clients` 2038 · `:clients:clients-integration-tests` 2246; settings include 76; 4451/144/240 lines; wrapper 9.8.2 | identical | match |
| license | LICENSE + NOTICE present | present | match |

The earlier public-method reference of 7,031 (at the extracts pin `aa62a433`)
differs by tree drift only — 6,928 reproduces exactly on two independent trees
— and both sit far above the ≥200 threshold. Risk 1 and risk 2 keep their full
force: the block-line coincidence holds at this pin, not forever, and the
re-derivation step in section 5 stays mandatory at the actual cut pin.
