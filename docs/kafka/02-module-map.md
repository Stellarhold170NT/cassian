---
subject: apache/kafka
measured_at: aa62a433553c14866521bd40ff446b6920d4d67e
status: final
---

# Module map

One entry per Gradle module of apache/kafka, grouped by subsystem — 66 modules
in total. This is the human-readable companion to the machine index
[`matrix/matrix.csv`](../../matrix/matrix.csv), which carries the same rows in
full (dependencies, sizes, ratings, extract locations). Ratings live in
[`05-stars.md`](05-stars.md); architecture views in
[`04-overview.md`](04-overview.md); hot data flows in
[`06-flows.md`](06-flows.md); hands-on recipes in
[`07-usage.md`](07-usage.md).

**How to read the columns.** `depends_on` lists the modules this module imports
code from (its external needs); `depended_by` lists the modules that import it
(who stands on it). `loc` is the measured source size (all files under the
module path, tests included). `key files` names the public entry point and the
largest source file, as paths relative to the upstream repository root — browse
any of them at
`https://github.com/apache/kafka/tree/aa62a433553c14866521bd40ff446b6920d4d67e/<path>`.
Long dependency lists are truncated here; the full lists are in `matrix.csv`.

**Measurement note.** Sizes and dependency edges were measured on the upstream
tree at commit `0c92b0664539d0dfb60b43ede0026497a581d8e0` (KAFKA-20125); the
extracts pin for this subject is `aa62a433` (see
[`index.md`](index.md)). None of the key files cited below changed between the
two commits, so every path and line reference resolves identically at both.
Conventions: test-only modules were scanned across all of `src`; hidden
dependencies through `src/testFixtures` are excluded; classes generated at
build time resolve to the module owning their JSON specification.

## Client libraries

| id | module | responsibility | depends_on | depended_by | loc | key files |
|---|---|---|---|---|---|---|
| <a id="m01-clients"></a>m01 | clients | Foundational Java client library: producer, consumer, admin, plus nearly all of `org.apache.kafka.common`; the leaf every other module stands on. | — | 23 modules | 387364 | `clients/src/main/java/org/apache/kafka/clients/producer/KafkaProducer.java` (entry, L251); `admin/KafkaAdminClient.java` (5387, largest) |
| <a id="m02-streams"></a>m02 | streams | Kafka Streams client library: KStream/KTable DSL, Processor API, state stores, StreamThread/TaskManager runtime; public entry `KafkaStreams`. | clients | 4 modules | 338869 | `streams/src/main/java/org/apache/kafka/streams/KafkaStreams.java` (entry, L165); `kstream/KTable.java` (2473, largest) |
| <a id="m22-streams-test-utils"></a>m22 | streams/test-utils | Official Streams test harness: `TopologyTestDriver` runs topologies without a broker; input/output topics, mock processor context. | streams; clients | — | 8856 | `streams/test-utils/src/main/java/org/apache/kafka/streams/TopologyTestDriver.java` (entry, L229; 2103 lines) |
| <a id="m23-streams-streams-scala"></a>m23 | streams/streams-scala | Scala wrapper for the Streams DSL (`StreamsBuilder`, `KStream`/`KTable`) with Scala↔Java function conversion. | streams; clients | — | 6212 | `streams/streams-scala/src/main/scala/org/apache/kafka/streams/scala/StreamsBuilder.scala` (entry, L34) |
| <a id="m32-streams-examples"></a>m32 | streams/examples | Official Streams demos (WordCount, PageView, SessionWindows, InteractiveQueries); each demo has its own `main()`. | streams; clients | — | 1558 | `streams/examples/src/main/java/org/apache/kafka/streams/examples/wordcount/WordCountDemo.java` (main, L87) |
| <a id="m11-streams-integration-tests"></a>m11 | streams/integration-tests | End-to-end Streams integration tests (EOS, queryable state, store upgrades, rebalance) against a real broker; test-only. | 12 modules | — | 50795 | `streams/integration-tests/src/test/java/org/apache/kafka/streams/integration/IQv2StoreIntegrationTest.java` (2069, largest) |

## Connect

| id | module | responsibility | depends_on | depended_by | loc | key files |
|---|---|---|---|---|---|---|
| <a id="m16-connect-api"></a>m16 | connect/api | Connect SPI and data model: `Connector`/`Task`, `ConnectRecord`/`SourceRecord`, `Schema`/`Struct`, converters, REST extension hooks — everything else builds on it. | clients | 8 modules | 13861 | `connect/api/src/main/java/org/apache/kafka/connect/connector/Connector.java` (entry, L48); `data/Values.java` (1405, largest) |
| <a id="m05-connect-runtime"></a>m05 | connect/runtime | Connect execution runtime: CLI entries (distributed/standalone), Worker and Herder, config/offset/status stores backed by Kafka topics. | clients; connect/api; connect/transforms; connect/json | connect/mirror; tools | 104931 | `connect/runtime/src/main/java/org/apache/kafka/connect/cli/ConnectDistributed.java` (main, L110); `distributed/DistributedHerder.java` (3126, largest) |
| <a id="m21-connect-transforms"></a>m21 | connect/transforms | Standard single-message transforms: Cast, TimestampConverter, Flatten, InsertField, RegexRouter, ValueToKey, plus predicates. | connect/api; clients | 3 modules | 8950 | `connect/transforms/src/main/java/org/apache/kafka/connect/transforms/Cast.java` (entry, L57) |
| <a id="m28-connect-json"></a>m28 | connect/json | Official Connect JSON converter: schema-aware serde between `Struct` and JSON, with config and schema utilities. | connect/api; clients | 3 modules | 2308 | `connect/json/src/main/java/org/apache/kafka/connect/json/JsonConverter.java` (entry, L65; 766 lines) |
| <a id="m17-connect-mirror"></a>m17 | connect/mirror | MirrorMaker 2 on Connect runtime: source connector replicates records; checkpoint/heartbeat connectors sync offsets; standalone entry. | 5 modules | — | 13602 | `connect/mirror/src/main/java/org/apache/kafka/connect/mirror/MirrorMaker.java` (main, L329) |
| <a id="m30-connect-mirror-client"></a>m30 | connect/mirror-client | Lightweight MirrorMaker 2 client: `MirrorClient` reads heartbeat/checkpoint topics; replication naming policy API. | clients | connect/mirror | 1904 | `connect/mirror-client/src/main/java/org/apache/kafka/connect/mirror/MirrorClient.java` (entry, L51) |
| <a id="m31-connect-file"></a>m31 | connect/file | Reference file connectors: `FileStreamSourceConnector` (file → Kafka) and `FileStreamSinkConnector` (Kafka → file). | clients; connect/api | — | 1698 | `connect/file/src/main/java/org/apache/kafka/connect/file/FileStreamSourceConnector.java` (entry, L42) |
| <a id="m58-connect-basic-auth-extension"></a>m58 | connect/basic-auth-extension | Connect REST extension adding JAAS basic authentication to the worker REST API. | connect/api; clients | — | 881 | `connect/basic-auth-extension/src/main/java/org/apache/kafka/connect/rest/basic/auth/extension/BasicAuthSecurityRestExtension.java` (entry, L64) |
| <a id="m56-connect-test-plugins"></a>m56 | connect/test-plugins | Plugin-loading test fixtures for Connect runtime (Verifiable/Mock connectors and tasks); test-only. | connect/api; clients; server-common | — | 1157 | `connect/test-plugins/src/main/java/org/apache/kafka/connect/tools/VerifiableSourceTask.java` (entry, L50) |

## Core broker

| id | module | responsibility | depends_on | depended_by | loc | key files |
|---|---|---|---|---|---|---|
| <a id="m03-core"></a>m03 | core | Scala broker module with the runnable entry point (`kafka.Kafka`) and most server-side business logic: KafkaApis, ReplicaManager, share partitions, the Scala controller. | 11 modules | jmh-benchmarks; test-common/test-common-runtime | 160338 | `core/src/main/scala/kafka/Kafka.scala` (entry, L73); `kafka/server/KafkaApis.scala` (4414, largest) |
| <a id="m10-server"></a>m10 | server | Java broker services split out of core: SocketServer network constants, fetch sessions, share groups, client metrics/telemetry, quotas, dynamic config. | 10 modules | 4 modules | 53773 | `server/src/main/java/org/apache/kafka/network/SocketServer.java` (L24 — 42-line constants holder; real network layer is core's Scala `SocketServer.scala:71`, see overview §11); `share/dlq/ShareGroupDLQStateManager.java` (1052, largest) |
| <a id="m12-server-common"></a>m12 | server-common | Shared server-side library: `MetadataVersion`, ApiMessage/RecordSerde, `KafkaEventQueue`, purgatory, fault handlers, share persister, utils; the widest fan-out in the system. | clients | 16 modules | 35932 | `server-common/src/main/java/org/apache/kafka/server/common/MetadataVersion.java` (entry enum, L47); `share/persister/PersisterStateManager.java` (1842, largest) |

## Storage

| id | module | responsibility | depends_on | depended_by | loc | key files |
|---|---|---|---|---|---|---|
| <a id="m06-storage"></a>m06 | storage | Broker log storage layer split out of core: `UnifiedLog`, `LogSegment`, `LogManager`, plus the remote-storage manager hooks consumed via `org.apache.kafka.storage.*`. | clients; server-common; storage/api | 7 modules | 73952 | `storage/src/main/java/org/apache/kafka/storage/internals/log/UnifiedLog.java` (entry = largest, L105, 2806 lines); `LogSegment.java` |
| <a id="m29-storage-api"></a>m29 | storage/api | Remote/tiered storage SPI split out of storage: `RemoteStorageManager`, `RemoteLogMetadataManager`, segment metadata model. | clients; server-common | storage; core; server | 2224 | `storage/api/src/main/java/org/apache/kafka/server/log/remote/storage/RemoteStorageManager.java` (interface entry, L56) |

## Metadata and consensus

| id | module | responsibility | depends_on | depended_by | loc | key files |
|---|---|---|---|---|---|---|
| <a id="m07-metadata"></a>m07 | metadata | KRaft metadata layer: `QuorumController` and `ReplicationControlManager` drive topics/partitions/ACLs/quotas through the metadata log; metadata cache, image/delta, `StandardAuthorizer`. | clients; server-common; raft | 9 modules | 62545 | `metadata/src/main/java/org/apache/kafka/controller/QuorumController.java` (entry, L177); `ReplicationControlManager.java` (2604, largest) |
| <a id="m09-raft"></a>m09 | raft | Self-contained KRaft consensus implementation: `KafkaRaftClient` (leader election, log replication), `QuorumState`, the `RaftManager` interface, metadata log. | clients; server-common; storage | 6 modules | 55879 | `raft/src/main/java/org/apache/kafka/raft/RaftManager.java` (interface entry, L27); `KafkaRaftClient.java` (4185, largest) |

## Coordinators

| id | module | responsibility | depends_on | depended_by | loc | key files |
|---|---|---|---|---|---|---|
| <a id="m15-coordinator-common"></a>m15 | coordinator-common | Shared runtime for the KRaft coordinators (group/share/transaction): `CoordinatorRuntime` per-partition state machine, loader, record serde, metrics. | clients; server-common; metadata; storage | 6 modules | 18618 | `coordinator-common/src/main/java/org/apache/kafka/coordinator/common/runtime/CoordinatorRuntime.java` (entry = largest, L100, 2541 lines) |
| <a id="m04-group-coordinator"></a>m04 | group-coordinator | Broker-side group runtime (KIP-848): `GroupCoordinatorService` plus per-partition state machines for consumer/classic/streams/share groups and the assignor set. | 5 modules | 5 modules | 142204 | `group-coordinator/src/main/java/org/apache/kafka/coordinator/group/GroupCoordinatorService.java` (entry, L166); `GroupMetadataManager.java` (10188, largest) |
| <a id="m54-group-coordinator-group-coordinator-api"></a>m54 | group-coordinator/group-coordinator-api | Public API of the group coordinator: assignor interfaces and records for consumer and streams groups; implementation lives in the main module. | clients | 3 modules | 1292 | `group-coordinator/group-coordinator-api/src/main/java/org/apache/kafka/coordinator/group/api/assignor/ConsumerGroupPartitionAssignor.java` (interface entry, L26) |
| <a id="m20-share-coordinator"></a>m20 | share-coordinator | Share-group coordinator runtime (KIP-932): `ShareCoordinatorService` + shard manage share-group offsets through the CoordinatorRuntime. | clients; coordinator-common; server-common; metadata | 4 modules | 9915 | `share-coordinator/src/main/java/org/apache/kafka/coordinator/share/ShareCoordinatorService.java` (entry = largest, L85, 1194 lines) |
| <a id="m26-transaction-coordinator"></a>m26 | transaction-coordinator | Transaction data layer for the broker: `TransactionMetadata` state machine, transaction log, producer-id manager. | clients; server-common; coordinator-common | 4 modules | 3897 | `transaction-coordinator/src/main/java/org/apache/kafka/coordinator/transaction/TransactionMetadata.java` (entry = largest, L37, 673 lines) |
| <a id="m66-mirror-coordinator"></a>m66 | mirror-coordinator | Single-file module holding MirrorMaker 2 coordination config (`ClusterMirrorConfigs`), read by the server through dynamic config. | clients | server | 110 | `mirror-coordinator/src/main/java/org/apache/kafka/coordinator/mirror/ClusterMirrorConfigs.java` (entry = only file, L34) |

## Tools and utilities

| id | module | responsibility | depends_on | depended_by | loc | key files |
|---|---|---|---|---|---|---|
| <a id="m08-tools"></a>m08 | tools | Official CLI set: TopicCommand, ConsoleProducer/Consumer, ConsumerGroupCommand, ReassignPartitionsCommand, ConfigCommand, TransactionsCommand, StreamsGroupCommand. | 12 modules | — | 62476 | `tools/src/main/java/org/apache/kafka/tools/TopicCommand.java` (main, L84); `reassign/ReassignPartitionsCommand.java` (1590, largest) |
| <a id="m60-tools-tools-api"></a>m60 | tools/tools-api | Small stable API for CLI tool plugins: `RecordReader`/`Decoder` interfaces, kept binary-compatible for log readers. | clients | tools | 265 | `tools/tools-api/src/main/java/org/apache/kafka/tools/api/RecordReader.java` (interface entry, L36) |
| <a id="m27-shell"></a>m27 | shell | Metadata shell: interactive console (`ls`/`get`/`log`) reading KRaft metadata through the raft client. | metadata; clients; server-common; server | — | 3383 | `shell/src/main/java/org/apache/kafka/shell/MetadataShell.java` (main, L202) |
| <a id="m19-generator"></a>m19 | generator | Build-time protocol generator: reads JSON message specs and emits the message classes owned by their defining modules. | — | — | 11053 | `generator/src/main/java/org/apache/kafka/message/MessageGenerator.java` (main, L432) |
| <a id="m24-api-checker"></a>m24 | api-checker | Build-time checker that blocks plugin developers from using internal APIs (ASM scan + cascade validators; maven mojo and gradle wiring). | — | — | 6179 | `api-checker/core/src/main/java/org/apache/kafka/apicheck/PluginDeveloperApiUsageScanner.java` (entry, L82) |
| <a id="m14-trogdor"></a>m14 | trogdor | Fault-injection and benchmark framework: agent runs worker tasks, coordinator manages lifecycle, workload library. | clients; group-coordinator | — | 19750 | `trogdor/src/main/java/org/apache/kafka/trogdor/agent/Agent.java` (main, L201) |
| <a id="m18-jmh-benchmarks"></a>m18 | jmh-benchmarks | JMH microbenchmarks across layers (assignors, purgatory, records, streams, connect, storage, metadata); not runtime code. | 16 modules | — | 11699 | `jmh-benchmarks/src/main/java/org/apache/kafka/jmh/assignor/ConsumerAssignorBenchmark.java` (entry = largest, L113, 681 lines) |
| <a id="m55-examples"></a>m55 | examples | Official producer/consumer demos, including exactly-once transactional examples. | clients | — | 1216 | `examples/src/main/java/kafka/examples/KafkaConsumerProducerDemo.java` (main, L38) |

## Test infrastructure

| id | module | responsibility | depends_on | depended_by | loc | key files |
|---|---|---|---|---|---|---|
| <a id="m25-test-common-test-common-runtime"></a>m25 | test-common/test-common-runtime | Real-broker KRaft cluster test kit: `KafkaClusterTestKit`, `ClusterInstance`, JUnit 5 `ClusterTest` extensions (the modern replacement for core's KafkaClusterTest). | 7 modules | — | 5203 | `test-common/test-common-runtime/src/main/java/org/apache/kafka/common/test/KafkaClusterTestKit.java` (entry = largest, L96, 935 lines) |
| <a id="m57-test-common-test-common-internal-api"></a>m57 | test-common/test-common-internal-api | Annotations and models for the cluster test framework: `@ClusterTest`, `@ClusterTemplate`, `ClusterConfig`, thread-leak detection. | clients; server-common | — | 939 | `test-common/test-common-internal-api/src/main/java/org/apache/kafka/common/test/api/ClusterTest.java` (annotation entry, L49) |
| <a id="m59-test-common-test-common-util"></a>m59 | test-common/test-common-util | JUnit-platform utilities for the test-cluster framework: post-discovery filters and the `@Flaky` annotation. | — | test-common/test-common-runtime | 625 | `test-common/test-common-util/src/main/java/org/apache/kafka/common/test/junit/KafkaPostDiscoveryFilter.java` (entry, 152 lines) |
| <a id="m13-clients-clients-integration-tests"></a>m13 | clients/clients-integration-tests | Consumer/producer/share-consumer integration tests against a real broker, extracted from clients; test-only. | 10 modules | — | 23572 | `clients/clients-integration-tests/src/test/java/org/apache/kafka/clients/consumer/PlaintextConsumerTest.java` (entry, L127) |

## Streams upgrade system tests

<a id="streams-upgrade-system-tests-family"></a>
The 26 modules below are structurally identical smoke-test suites, each pinning
one Kafka Streams version (0.11.0 through 4.3). All are test-only, depend on
exactly `streams` and `clients`, and carry one `StreamsUpgradeTest` main plus a
smoke-test driver; sizes range from 180 to 1385 lines. Per-module rows (paths,
sizes, extract locations) are in [`matrix/matrix.csv`](../../matrix/matrix.csv).

| id | module | responsibility | depends_on | depended_by | loc |
|---|---|---|---|---|---|
| m33–m53 | streams/upgrade-system-tests-22,23,27,26,31,32,33,34,35,36,37,38,39,40,41,42,43,28,25,30,24 | Streams 2.2–4.3 upgrade smoke tests; test-only | streams; clients | — | 1385 → 1317 |
| m61–m64 | streams/upgrade-system-tests-10,11,20,21 | Streams 1.0–2.1 upgrade smoke tests; test-only | streams; clients | — | 232 → 221 |
| m65 | streams/upgrade-system-tests-0110 | Streams 0.11.0 upgrade smoke test; smallest module in the universe (180 lines) | streams; clients | — | 180 |

**Totals.** 66 modules; 6542 source files; 1,738,903 measured lines across the
universe (statistics measured as noted above). Every module is extracted
verbatim under `modules/kafka/<module>/` with a `PROVENANCE.md` recording the
upstream pin, path, license, and measured size.
