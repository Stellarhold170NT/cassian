---
subject: apache/kafka
measured_at: aa62a433553c14866521bd40ff446b6920d4d67e
status: final
---

# Cartography

Repository census of apache/kafka — build manifests, entry points, top-level
directory layout, and measured sizes. This is the orientation document for the
subject; the module-by-module breakdown follows in
[`02-module-map.md`](02-module-map.md), the architecture narrative in
[`04-overview.md`](04-overview.md).

**Measurement note.** Everything on this page was measured on a checkout of
upstream `trunk` at commit `0c92b0664539d0dfb60b43ede0026497a581d8e0`
("KAFKA-20125: Improve the docs of dynamic-only configurations (#21416)",
2026-10-29). The extracts pin of this subject is `aa62a433` — 5 commits earlier
(see [`index.md`](index.md) and [`tracking/kafka.md`](../../tracking/kafka.md)
for the relationship and the re-sync rule).

## License gate

The subject passes the reuse gate before any measurement: both license files
exist at the pin — `LICENSE` (11,358 bytes) and `LICENSE-binary` (14,615 bytes)
— plus `NOTICE`, `NOTICE-binary`, and a `licenses/` directory for bundled
dependencies. The whole tree is Apache-2.0; extracted modules remain under
their original terms (see the [README](../../README.md#license)).

## Source census

Counted with `find … -print0 | xargs -0 cat | wc -l` over the whole checkout,
excluding `.git`:

| extension | files | lines |
|---|---|---|
| .java | 6,283 | 1,604,604 |
| .scala | 255 | 134,173 |
| .py | 185 | 32,772 |
| .sh | 61 | 2,537 |

The checkout contains 7,642 files in total. The 66-module Gradle universe
analyzed in the docs accounts for 6,542 of those files and 1,738,903 lines;
the remainder lives in build infrastructure (`gradle/`, `checkstyle/`,
`generator/`, `api-checker/`), system-test harnesses (`tests/`, `test-common/`),
and packaging (`bin/`, `config/`, `docker/`, `docs/`).

## Build manifests

The build is a multi-module Gradle monorepo:

- `settings.gradle` (144 lines) declares the module universe: **65 included
  projects** plus one composite build (`includeBuild 'api-checker'`), with
  `rootProject.name = 'kafka'` and a rename of `:storage:api` to `storage-api`.
  The include list, verbatim:

```gradle
include 'clients',
    'clients:clients-integration-tests',
    'connect:api',
    'connect:basic-auth-extension',
    'connect:file',
    'connect:json',
    'connect:mirror',
    'connect:mirror-client',
    'connect:runtime',
    'connect:test-plugins',
    'connect:transforms',
    'coordinator-common',
    'core',
    'examples',
    'generator',
    'group-coordinator',
    'group-coordinator:group-coordinator-api',
    'jmh-benchmarks',
    'metadata',
    'mirror-coordinator',
    'raft',
    'server',
    'server-common',
    'share-coordinator',
    'shell',
    'storage',
    'storage:api',
    'streams',
    'streams:examples',
    'streams:integration-tests',
    'streams:streams-scala',
    'streams:test-utils',
    'streams:upgrade-system-tests-0110',
    'streams:upgrade-system-tests-10',
    'streams:upgrade-system-tests-11',
    'streams:upgrade-system-tests-20',
    'streams:upgrade-system-tests-21',
    'streams:upgrade-system-tests-22',
    'streams:upgrade-system-tests-23',
    'streams:upgrade-system-tests-24',
    'streams:upgrade-system-tests-25',
    'streams:upgrade-system-tests-26',
    'streams:upgrade-system-tests-27',
    'streams:upgrade-system-tests-28',
    'streams:upgrade-system-tests-30',
    'streams:upgrade-system-tests-31',
    'streams:upgrade-system-tests-32',
    'streams:upgrade-system-tests-33',
    'streams:upgrade-system-tests-34',
    'streams:upgrade-system-tests-35',
    'streams:upgrade-system-tests-36',
    'streams:upgrade-system-tests-37',
    'streams:upgrade-system-tests-38',
    'streams:upgrade-system-tests-39',
    'streams:upgrade-system-tests-40',
    'streams:upgrade-system-tests-41',
    'streams:upgrade-system-tests-42',
    'streams:upgrade-system-tests-43',
    'tools',
    'tools:tools-api',
    'transaction-coordinator',
    'trogdor',
    'test-common:test-common-internal-api',
    'test-common:test-common-util',
    'test-common:test-common-runtime'

project(":storage:api").name = "storage-api"
rootProject.name = 'kafka'
```

  (65 modules — counted mechanically: 130 quotes in the include block, 130/2.)
- `gradle.properties` (23 lines): `group=org.apache.kafka`,
  `version=4.5.0-SNAPSHOT`, `scalaVersion=2.13.18`, `swaggerVersion=2.2.55`,
  `task=build`, `org.gradle.jvmargs=-Xmx4g -Xss4m -XX:+UseParallelGC`,
  `org.gradle.parallel=true`.
- `build.gradle` (4,451 lines) opens its `buildscript` block from
  `gradle/dependencies.gradle` on Maven Central.
- Gradle wrapper pins **Gradle 9.8.2**
  (`gradle/wrapper/gradle-wrapper.properties`, distribution SHA-256
  `21bd5da2de49b642904077f38c0efdc7778e92b3ed0889392dca61b97e389607`).

## Entry points

The broker's true main is the Scala entry:

- `core/src/main/scala/kafka/Kafka.scala` — `def main(args: Array[String])` at
  **line 73**; `bin/kafka-server-start.sh` execs `kafka.Kafka`.

A mechanical scan for `public static void main` over the three largest Java
modules (clients, connect/runtime, core's neighbors) finds 19 Java mains. The
two real CLI runnables among them:

| main | location | role |
|---|---|---|
| `ConnectStandalone` | `connect/runtime/src/main/java/org/apache/kafka/connect/cli/ConnectStandalone.java` (line 180) | standalone Connect worker |
| `ConnectDistributed` | `connect/runtime/src/main/java/org/apache/kafka/connect/cli/ConnectDistributed.java` (line 110) | distributed Connect worker |

The remaining 17 are utility mains (config documentation printers such as
`ConsumerConfig.main`/`ProducerConfig.main`/`AdminClientConfig.main`, protocol
debug printers such as `Errors.main`/`ApiKeys.main`, and test-side
benchmarks/histogram printers). They are not production entry points.

## Top-level layout

33 top-level directories (132 directories down to depth 2), grouped by role:

| group | directories |
|---|---|
| platform clients | `clients/`, `streams/`, `connect/`, `examples/` |
| broker core | `core/`, `server/`, `server-common/`, `storage/` |
| KRaft metadata plane | `metadata/`, `raft/`, `coordinator-common/`, `group-coordinator/`, `share-coordinator/`, `transaction-coordinator/`, `mirror-coordinator/` |
| tooling | `tools/`, `shell/`, `trogdor/`, `jmh-benchmarks/` |
| build infrastructure | `gradle/`, `generator/`, `api-checker/`, `checkstyle/`, `release/`, `bin/` |
| testing | `tests/`, `test-common/` |
| packaging & docs | `config/`, `docker/`, `docs/`, `licenses/` |
| development environment | `committer-tools/`, `vagrant/`, `raft/bin/` |

## Totals for the subject

| metric | value |
|---|---|
| Gradle modules (universe) | 65 included + 1 composite build = **66** |
| source files in universe | 6,542 |
| lines in universe | 1,738,903 |
| extracted to this repo | 66/66 modules, byte-identical at the pin (`modules/kafka/`) |

Follow the reading order in [`index.md`](index.md) for the rest of the subject.
