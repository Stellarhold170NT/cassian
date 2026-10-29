workspace "Apache Kafka C4 Model" "C4 L1-L3 model of the apache/kafka tree at commit aa62a433553c14866521bd40ff446b6920d4d67e (the extracts pin of this subject). Every element and relationship carries a '// evidence:' comment anchored to a repository path that exists at the pin. Statistics quoted in element descriptions were measured on the upstream tree at commit 0c92b0664539d0dfb60b43ede0026497a581d8e0; no cited path changed between the two commits. ZooKeeper is intentionally absent: the trunk is KRaft-only (no ZooKeeper sources, no zookeeper dependency, configuration uses process.roles)." {

    model {

        // ============================================================
        // L1 - SYSTEM CONTEXT (people + external systems + Kafka)
        // ============================================================

        // evidence: bin/kafka-topics.sh
        operator = person "Kafka Administrator / Operator" "Human operator administering topics, configs and consumer groups through the bundled CLI tooling."

        // evidence: examples/src/main/java/kafka/examples/Producer.java
        producerApp = softwareSystem "Producer Application" "External application that publishes event records via the Java producer API."

        // evidence: examples/src/main/java/kafka/examples/Consumer.java
        consumerApp = softwareSystem "Consumer Application" "External application that subscribes to and consumes event records via the Java consumer API."

        // evidence: streams/examples/src/main/java/org/apache/kafka/streams/examples/wordcount/WordCountDemo.java
        streamsApp = softwareSystem "Streams Application" "External application building stateful stream-processing topologies on the Kafka Streams library."

        // evidence: storage/api/src/main/java/org/apache/kafka/server/log/remote/storage/RemoteStorageManager.java
        objectStore = softwareSystem "Remote Object Store" "External object/blob storage used for tiered storage of log segments via the RemoteStorageManager SPI."

        // evidence: settings.gradle
        kafka = softwareSystem "Apache Kafka" "Distributed event-streaming platform; Gradle root project 'kafka' 4.5.0-SNAPSHOT, KRaft-only (no ZooKeeper)." {

            // ============================================================
            // L2 - CONTAINERS (deployable/runnable units of Apache Kafka)
            // ============================================================

            // evidence: core/src/main/scala/kafka/Kafka.scala
            broker = container "Broker" "Core broker process: request handling, replication, log storage and coordinator runtimes; entrypoint kafka.Kafka (Scala main)." "Java/Scala (modules core, server, storage + storage/api, coordinator-common, group-coordinator (+group-coordinator-api), transaction-coordinator, share-coordinator, mirror-coordinator, server-common)" {

                // evidence: core/src/main/scala/kafka/Kafka.scala
                brokerEntry = component "kafka.Kafka" "Broker entrypoint; parses config, builds and starts the broker server (Scala main at line 73)." "Scala (module core)"

                // evidence: server/src/main/java/org/apache/kafka/network/SocketServer.java
                socketServer = component "SocketServer" "Network layer accepting client connections and request channels." "Java (module server, org.apache.kafka.network)"

                // evidence: core/src/main/scala/kafka/server/KafkaApis.scala
                kafkaApis = component "KafkaApis" "Request-handling facade implementing the Kafka protocol APIs; largest file of module core (4414 lines)." "Scala (module core)"

                // evidence: core/src/main/scala/kafka/server/ReplicaManager.scala
                replicaManager = component "ReplicaManager" "Partition replication, fetch and leader state management on the broker." "Scala (module core)"

                // evidence: storage/src/main/java/org/apache/kafka/storage/internals/log/UnifiedLog.java
                logStorage = component "UnifiedLog / LogManager" "Durable log storage engine: UnifiedLog, LogSegment, LogManager plus remote-log hooks." "Java (module storage, org.apache.kafka.storage.internals.log)"

                // evidence: group-coordinator/src/main/java/org/apache/kafka/coordinator/group/GroupCoordinatorService.java
                groupCoordinator = component "Group Coordinator (KIP-848)" "GroupCoordinatorService + GroupCoordinatorShard/GroupMetadataManager: consumer/classic/streams/share group state machines (largest file 10188 lines)." "Java (module group-coordinator)"

                // evidence: transaction-coordinator/src/main/java/org/apache/kafka/coordinator/transaction/TransactionMetadata.java
                txnCoordinator = component "Transaction Coordinator" "TransactionMetadata state machine + TransactionLog + producer-id allocation (RPCProducerIdManager)." "Java (module transaction-coordinator)"

                // evidence: share-coordinator/src/main/java/org/apache/kafka/coordinator/share/ShareCoordinatorService.java
                shareCoordinator = component "Share Coordinator (KIP-932)" "ShareCoordinatorService/Shard managing share-group offsets on the CoordinatorRuntime." "Java (module share-coordinator)"

                // evidence: coordinator-common/src/main/java/org/apache/kafka/coordinator/common/runtime/CoordinatorRuntime.java
                coordinatorCommon = component "Coordinator Runtime (coordinator-common)" "Shared runtime for KRaft coordinators: CoordinatorRuntime per-partition state machine + event processor, CoordinatorLoader/RecordSerde and metrics; base of the group and share coordinators (module coordinator-common, 18618 lines at the measurement commit)." "Java (module coordinator-common, org.apache.kafka.coordinator.common.runtime)"

                // evidence: core/src/main/scala/kafka/raft/KafkaRaftManager.scala
                brokerRaftManager = component "RaftManager (broker-side)" "Broker-side KRaft client: joins the quorum, appends and replicates the metadata log." "Scala (module core, kafka.raft)"

                // evidence: core/src/main/scala/kafka/server/metadata/BrokerMetadataPublisher.scala
                metadataPublisher = component "BrokerMetadataPublisher" "Publishes metadata deltas from the KRaft metadata log into the broker in-memory metadata cache (395 lines)." "Scala (module core, kafka.server.metadata)"

                // evidence: server-common/src/main/java/org/apache/kafka/server/common/MetadataVersion.java
                serverCommon = component "Server-common infrastructure" "Shared server library: MetadataVersion/Feature, ApiMessageAndVersion + RecordSerde, KafkaEventQueue, purgatory, fault handler (widest fan-out module)." "Java (module server-common)"
            }

            // evidence: metadata/src/main/java/org/apache/kafka/controller/QuorumController.java
            kraftController = container "KRaft Controller & Metadata" "KRaft metadata quorum replacing ZooKeeper: consensus client, active controller and metadata layer." "Java (modules raft, metadata)" {

                // evidence: raft/src/main/java/org/apache/kafka/raft/KafkaRaftClient.java
                raftClient = component "KafkaRaftClient" "Self-contained KRaft consensus: leader election and log replication (largest file 4185 lines)." "Java (module raft)"

                // evidence: metadata/src/main/java/org/apache/kafka/controller/QuorumController.java
                quorumController = component "QuorumController" "Active/standby controller driving cluster metadata through the replicated log (entry, line 177)." "Java (module metadata)"

                // evidence: metadata/src/main/java/org/apache/kafka/controller/ReplicationControlManager.java
                replicationControl = component "ReplicationControlManager" "Topic/partition/ACL/quota control plane recorded into the metadata log (largest file 2604 lines)." "Java (module metadata)"

                // evidence: metadata/src/main/java/org/apache/kafka/metadata/authorizer/StandardAuthorizer.java
                standardAuthorizer = component "StandardAuthorizer" "ACL-based authorization persisted in the metadata layer." "Java (module metadata)"
            }

            // evidence: clients/src/main/java/org/apache/kafka/clients/producer/KafkaProducer.java
            clients = container "Clients Library (Java)" "Link-time client library embedded in applications: producer, consumer, admin plus common protocol/network." "Java (module clients, 387364 lines / 1879 files at the measurement commit)" {

                // evidence: clients/src/main/java/org/apache/kafka/clients/producer/KafkaProducer.java
                kafkaProducer = component "KafkaProducer" "Producer API entry (line 251): batching, partitioning, transactions, delivery." "Java (module clients)"

                // evidence: clients/src/main/java/org/apache/kafka/clients/consumer/KafkaConsumer.java
                kafkaConsumer = component "KafkaConsumer" "Consumer API: subscribe/assign, poll loop, rebalance, fetch." "Java (module clients)"

                // evidence: clients/src/main/java/org/apache/kafka/clients/admin/KafkaAdminClient.java
                kafkaAdminClient = component "KafkaAdminClient" "Admin API: topic/config/ACL/quota management (largest file 5387 lines)." "Java (module clients)"

                // evidence: clients/src/main/java/org/apache/kafka/clients/NetworkClient.java
                networkClient = component "NetworkClient" "Protocol transport: connection pooling, in-flight requests, metadata updates." "Java (module clients)"

                // evidence: clients/src/main/java/org/apache/kafka/common/protocol/ApiKeys.java
                protocol = component "Kafka Wire Protocol (ApiKeys)" "Protocol API enumeration and serialization shared by all clients (ApiKeys entry, line 340)." "Java (module clients, org.apache.kafka.common.protocol)"
            }

            // evidence: streams/src/main/java/org/apache/kafka/streams/KafkaStreams.java
            streamsLib = container "Kafka Streams" "Stream-processing client library: DSL, processor API, state stores and StreamThread runtime." "Java/Scala (modules streams, streams-scala, streams-test-utils; 338869 lines / 1273 files at the measurement commit)" {

                // evidence: streams/src/main/java/org/apache/kafka/streams/KafkaStreams.java
                streamsRuntime = component "KafkaStreams" "Public application entry (line 165): lifecycle, state management, thread orchestration." "Java (module streams)"

                // evidence: streams/src/main/java/org/apache/kafka/streams/kstream/KTable.java
                dsl = component "KStream / KTable DSL" "Declarative stream DSL: KStream, KTable, windows, joins (largest file KTable 2473 lines)." "Java (module streams, kstream)"

                // evidence: streams/src/main/java/org/apache/kafka/streams/processor/internals/StreamThread.java
                streamThread = component "StreamThread" "Runtime engine: partitions stream tasks over input topics, drives state stores and standby replicas." "Java (module streams, processor.internals)"

                // evidence: streams/streams-scala/src/main/scala/org/apache/kafka/streams/scala/StreamsBuilder.scala
                scalaDsl = component "Scala DSL wrapper" "Scala-friendly KStream/KTable/StreamsBuilder API (entry StreamsBuilder.scala line 34)." "Scala (module streams-scala)"

                // evidence: streams/test-utils/src/main/java/org/apache/kafka/streams/TopologyTestDriver.java
                topologyTestDriver = component "TopologyTestDriver" "Official test harness executing topologies without a broker (largest file 2103 lines)." "Java (module streams-test-utils)"
            }

            // evidence: connect/runtime/src/main/java/org/apache/kafka/connect/cli/ConnectDistributed.java
            connect = container "Kafka Connect" "Connector runtime integrating external systems: CLI entry, worker, herder, SPI, transforms, converters, MirrorMaker 2." "Java (modules connect-runtime, connect-api, connect-transforms, connect-json, connect-mirror (+mirror-client), connect-file, connect-basic-auth-extension, ...)" {

                // evidence: connect/runtime/src/main/java/org/apache/kafka/connect/cli/ConnectDistributed.java
                connectCli = component "ConnectDistributed (CLI)" "Distributed Connect worker entrypoint (main at line 110; standalone entry ConnectStandalone line 180)." "Java (module connect-runtime, cli)"

                // evidence: connect/runtime/src/main/java/org/apache/kafka/connect/runtime/Worker.java
                connectWorker = component "Worker" "Executes connector tasks: source/sink task lifecycle, converters, offset management." "Java (module connect-runtime)"

                // evidence: connect/runtime/src/main/java/org/apache/kafka/connect/runtime/distributed/DistributedHerder.java
                distributedHerder = component "DistributedHerder" "Cluster coordination of connector/task assignment and rebalancing (largest file 3126 lines)." "Java (module connect-runtime, distributed)"

                // evidence: connect/api/src/main/java/org/apache/kafka/connect/connector/Connector.java
                connectorSpi = component "Connector SPI" "Plugin contract every connector implements: Connector/Task, ConnectRecord, Schema/Struct (entry Connector.java line 48)." "Java (module connect-api)"

                // evidence: connect/transforms/src/main/java/org/apache/kafka/connect/transforms/Cast.java
                smt = component "Single Message Transforms" "Standard SMT library: Cast, TimestampConverter, Flatten, InsertField, RegexRouter (entry Cast.java line 57)." "Java (module connect-transforms)"

                // evidence: connect/json/src/main/java/org/apache/kafka/connect/json/JsonConverter.java
                jsonConverter = component "JSON Converter" "Official JSON serde of Connect data (entry JsonConverter.java line 65, largest 766 lines)." "Java (module connect-json)"

                // evidence: connect/mirror/src/main/java/org/apache/kafka/connect/mirror/MirrorMaker.java
                mirrorMaker2 = component "MirrorMaker 2" "Cluster-to-cluster mirroring on Connect: MirrorSourceConnector, checkpoint/heartbeat sync (main MirrorMaker.java line 329)." "Java (module connect-mirror)"
            }

            // evidence: tools/src/main/java/org/apache/kafka/tools/TopicCommand.java
            tools = container "CLI Tools" "Official command-line tooling shipped with the distribution." "Java (modules tools, tools-api, shell)" {

                // evidence: tools/src/main/java/org/apache/kafka/tools/TopicCommand.java
                topicCommand = component "TopicCommand" "Topic create/alter/list/describe/delete CLI (main at line 84)." "Java (module tools)"

                // evidence: tools/src/main/java/org/apache/kafka/tools/consumer/ConsoleConsumer.java
                console = component "ConsoleProducer / ConsoleConsumer" "Interactive console producer and consumer CLIs." "Java (module tools, consumer)"

                // evidence: tools/src/main/java/org/apache/kafka/tools/ProducerPerformance.java
                producerPerf = component "ProducerPerformance" "Throughput benchmark CLI for producers." "Java (module tools)"

                // evidence: tools/src/main/java/org/apache/kafka/tools/reassign/ReassignPartitionsCommand.java
                reassign = component "ReassignPartitionsCommand" "Partition reassignment planning and execution (largest file 1590 lines)." "Java (module tools, reassign)"

                // evidence: shell/src/main/java/org/apache/kafka/shell/MetadataShell.java
                metadataShell = component "MetadataShell" "Interactive KRaft metadata shell: ls/get/log over the metadata log (main at line 202)." "Java (module shell)"
            }
        }

        // ============================================================
        // L1 - SYSTEM CONTEXT RELATIONSHIPS
        // ============================================================

        // evidence: examples/src/main/java/kafka/examples/Producer.java
        producerApp -> kafka "Publishes event records"

        // evidence: examples/src/main/java/kafka/examples/Consumer.java
        consumerApp -> kafka "Subscribes to and consumes event records"

        // evidence: streams/examples/src/main/java/org/apache/kafka/streams/examples/wordcount/WordCountDemo.java
        streamsApp -> kafka "Reads input topics, writes results and state changelog topics"

        // evidence: bin/kafka-topics.sh
        operator -> kafka "Administers topics, configs and consumer groups via CLI tooling"

        // evidence: storage/api/src/main/java/org/apache/kafka/server/log/remote/storage/RemoteStorageManager.java
        kafka -> objectStore "Offloads and fetches tiered log segments (RemoteStorageManager SPI)"

        // ============================================================
        // L2 - CONTAINER RELATIONSHIPS
        // ============================================================

        // evidence: examples/src/main/java/kafka/examples/Producer.java
        producerApp -> clients "Links the client library and publishes via KafkaProducer"

        // evidence: examples/src/main/java/kafka/examples/Consumer.java
        consumerApp -> clients "Links the client library and consumes via KafkaConsumer"

        // evidence: streams/examples/src/main/java/org/apache/kafka/streams/examples/wordcount/WordCountDemo.java
        streamsApp -> streamsLib "Builds and runs stream topologies"

        // evidence: bin/kafka-topics.sh
        operator -> tools "Invokes admin/maintenance commands"

        // evidence: clients/src/main/java/org/apache/kafka/common/protocol/ApiKeys.java
        clients -> broker "Kafka wire protocol: produce, fetch, metadata, join/sync, offset commit"

        // evidence: streams/src/main/java/org/apache/kafka/streams/KafkaClientSupplier.java
        streamsLib -> clients "Built on producer/consumer/admin client APIs"

        // evidence: streams/src/main/java/org/apache/kafka/streams/processor/internals/InternalTopicManager.java
        streamsLib -> broker "Record I/O plus internal state store and changelog topic management"

        // evidence: connect/runtime/src/main/java/org/apache/kafka/connect/util/KafkaBasedLog.java
        connect -> clients "Embeds producer/consumer/admin for record and internal-topic I/O"

        // evidence: connect/runtime/src/main/java/org/apache/kafka/connect/storage/KafkaOffsetBackingStore.java
        connect -> broker "Connector record flow plus config/offset/status internal topics"

        // evidence: tools/src/main/java/org/apache/kafka/tools/TopicCommand.java
        tools -> clients "Admin, consumer and producer APIs under every command"

        // evidence: core/src/main/scala/kafka/raft/KafkaRaftManager.scala
        broker -> kraftController "KRaft quorum membership; appends and replicates the metadata log"

        // evidence: core/src/main/scala/kafka/server/metadata/BrokerMetadataPublisher.scala
        kraftController -> broker "Publishes metadata deltas into the broker metadata cache"

        // evidence: storage/api/src/main/java/org/apache/kafka/server/log/remote/storage/RemoteStorageManager.java
        broker -> objectStore "Copies and fetches remote log segments (tiered storage)"

        // ============================================================
        // L3 - COMPONENT RELATIONSHIPS (path-verified at the pin)
        // ============================================================

        // evidence: core/src/main/scala/kafka/server/KafkaApis.scala
        kafkaApis -> replicaManager "Delegates produce/fetch/metadata handling"

        // evidence: core/src/main/scala/kafka/server/KafkaApis.scala
        kafkaApis -> groupCoordinator "Serves consumer-group APIs"

        // evidence: core/src/main/scala/kafka/server/KafkaApis.scala
        kafkaApis -> txnCoordinator "Serves transactional APIs (initProducerId and friends, line 1699)"

        // evidence: core/src/main/scala/kafka/server/KafkaApis.scala
        kafkaApis -> shareCoordinator "Serves share-group APIs"

        // evidence: group-coordinator/src/main/java/org/apache/kafka/coordinator/group/GroupCoordinatorService.java
        groupCoordinator -> coordinatorCommon "Runs group state machines on the shared CoordinatorRuntime"

        // evidence: share-coordinator/src/main/java/org/apache/kafka/coordinator/share/ShareCoordinatorService.java
        shareCoordinator -> coordinatorCommon "Runs share-group state machines on the shared CoordinatorRuntime"

        // evidence: core/src/main/scala/kafka/server/ReplicaManager.scala
        replicaManager -> logStorage "Reads and writes log segments through the log manager"

        // evidence: clients/src/main/java/org/apache/kafka/clients/producer/KafkaProducer.java
        kafkaProducer -> networkClient "Sends produce requests over the network"

        // evidence: tools/src/main/java/org/apache/kafka/tools/TopicCommand.java
        topicCommand -> kafkaAdminClient "Topic operations via the admin API"

        // evidence: streams/src/main/java/org/apache/kafka/streams/KafkaStreams.java
        streamsRuntime -> streamThread "Runs and rebalances stream tasks"

        // evidence: metadata/src/main/java/org/apache/kafka/controller/QuorumController.java
        quorumController -> raftClient "Replicates the metadata log through the raft client"
    }

    views {

        // evidence: settings.gradle
        systemContext kafka "Kafka-01-SystemContext" "L1 - System context: actors and external systems around Apache Kafka" {
            include *
            autolayout lr
        }

        // evidence: settings.gradle
        container kafka "Kafka-02-Containers" "L2 - Containers: deployable units inside Apache Kafka" {
            include *
            autolayout tb
        }

        // evidence: core/src/main/scala/kafka/Kafka.scala
        component broker "Kafka-03-Broker" "L3 - Components of the Broker container" {
            include *
            autolayout tb
        }

        // evidence: metadata/src/main/java/org/apache/kafka/controller/QuorumController.java
        component kraftController "Kafka-03-KRaft" "L3 - Components of the KRaft Controller & Metadata container" {
            include *
            autolayout tb
        }

        // evidence: clients/src/main/java/org/apache/kafka/clients/producer/KafkaProducer.java
        component clients "Kafka-03-Clients" "L3 - Components of the Clients Library container" {
            include *
            autolayout tb
        }

        // evidence: connect/runtime/src/main/java/org/apache/kafka/connect/cli/ConnectDistributed.java
        component connect "Kafka-03-Connect" "L3 - Components of the Kafka Connect container" {
            include *
            autolayout tb
        }

        // evidence: streams/src/main/java/org/apache/kafka/streams/KafkaStreams.java
        component streamsLib "Kafka-03-Streams" "L3 - Components of the Kafka Streams container" {
            include *
            autolayout tb
        }

        // evidence: tools/src/main/java/org/apache/kafka/tools/TopicCommand.java
        component tools "Kafka-03-Tools" "L3 - Components of the CLI Tools container" {
            include *
            autolayout tb
        }
    }
}
