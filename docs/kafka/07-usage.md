---
subject: apache/kafka
measured_at: aa62a433553c14866521bd40ff446b6920d4d67e
status: final
---

# Usage

Hands-on guidance for the eight most reuse-ready modules (the 5★ and 4★ of
[`05-stars.md`](05-stars.md)): what each solves, runnable-style code sketches
with evidence, the classpath each needs, and how to build it standalone — then
a one-line "use it when" index for all 66 modules.

**How the code and evidence were verified.** Every evidence line below was
grepped against the tree at the measurement commit
(`0c92b0664539d0dfb60b43ede0026497a581d8e0`, KAFKA-20125); none of the cited
files changed between the extracts pin `aa62a433` and that commit, so all
references resolve identically at both. Build the permalink as
`https://github.com/apache/kafka/blob/aa62a433553c14866521bd40ff446b6920d4d67e/<path>#L<line>`.
The snippets are usage sketches for the verified APIs (not executed
end-to-end in this study); dependency edges and sizes live in
[`matrix/matrix.csv`](../../matrix/matrix.csv) and are not repeated here.

## clients (5★)

The foundational Java client library — producer, consumer, admin, plus nearly
all of `org.apache.kafka.common`. It is the leaf of the dependency graph: every
other module stands on it, and it is the module application developers touch
most (write records, read records, manage the cluster through Admin).

### UC1 — produce one message to topic `orders`

Scenario: a billing service writes each order as one message keyed `order-42`
so Kafka preserves per-key ordering. Use `KafkaProducer` asynchronously with a
`Callback` that prints the assigned offset; `flush()` guarantees the callback
ran before the producer closes.

```java
import org.apache.kafka.clients.producer.KafkaProducer;
import org.apache.kafka.clients.producer.ProducerConfig;
import org.apache.kafka.clients.producer.ProducerRecord;
import org.apache.kafka.common.serialization.StringSerializer;

import java.util.Properties;

Properties props = new Properties();
props.put(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG, "broker1:9092");
try (KafkaProducer<String, String> producer =
         new KafkaProducer<>(props, new StringSerializer(), new StringSerializer())) {
    ProducerRecord<String, String> record =
        new ProducerRecord<>("orders", "order-42", "{\"amount\":100}");
    producer.send(record, (metadata, exception) -> {
        if (exception != null) exception.printStackTrace();
        else System.out.println("stored at offset " + metadata.offset());
    });
    producer.flush();  // wait for every send to complete before closing
} // close() via try-with-resources (Producer extends Closeable)
```

Evidence:
- `clients/src/main/java/org/apache/kafka/clients/producer/KafkaProducer.java:251` — `public class KafkaProducer<K, V> implements Producer<K, V>`
- `clients/src/main/java/org/apache/kafka/clients/producer/KafkaProducer.java:322` — `public KafkaProducer(Map<String, Object> configs, Serializer<K> keySerializer, Serializer<V> valueSerializer)`
- `clients/src/main/java/org/apache/kafka/clients/producer/ProducerConfig.java:67` — `public static final String BOOTSTRAP_SERVERS_CONFIG`
- `clients/src/main/java/org/apache/kafka/clients/producer/ProducerRecord.java:134` — `public ProducerRecord(String topic, K key, V value)`
- `clients/src/main/java/org/apache/kafka/clients/producer/KafkaProducer.java:1147` — `public Future<RecordMetadata> send(ProducerRecord<K, V> record, Callback callback)`
- `clients/src/main/java/org/apache/kafka/clients/producer/Callback.java:65` — `void onCompletion(RecordMetadata metadata, Exception exception)`
- `clients/src/main/java/org/apache/kafka/clients/producer/RecordMetadata.java:71` — `public long offset()`
- `clients/src/main/java/org/apache/kafka/clients/producer/KafkaProducer.java:1422` — `public void flush()`
- `clients/src/main/java/org/apache/kafka/clients/producer/Producer.java:42` — `public interface Producer<K, V> extends Closeable`
- `clients/src/main/java/org/apache/kafka/common/serialization/StringSerializer.java:33` — `public class StringSerializer implements Serializer<String> {` (no-arg constructor, as used in the example)

### UC2 — consume topic `orders` with batch polls

Scenario: an aggregation worker reads topic `orders` in consumer group
`billing-reader`, polling once per second. Per-partition access goes through
`records(TopicPartition)`; `AUTO_OFFSET_RESET=earliest` makes a fresh group
read the topic from the beginning.

```java
import org.apache.kafka.clients.consumer.ConsumerConfig;
import org.apache.kafka.clients.consumer.ConsumerRecord;
import org.apache.kafka.clients.consumer.ConsumerRecords;
import org.apache.kafka.clients.consumer.KafkaConsumer;
import org.apache.kafka.common.TopicPartition;
import org.apache.kafka.common.serialization.StringDeserializer;

import java.time.Duration;
import java.util.List;
import java.util.Properties;

Properties props = new Properties();
props.put(ConsumerConfig.BOOTSTRAP_SERVERS_CONFIG, "broker1:9092");
props.put(ConsumerConfig.GROUP_ID_CONFIG, "billing-reader");
props.put(ConsumerConfig.AUTO_OFFSET_RESET_CONFIG, "earliest");
try (KafkaConsumer<String, String> consumer =
         new KafkaConsumer<>(props, new StringDeserializer(), new StringDeserializer())) {
    consumer.subscribe(List.of("orders"));
    ConsumerRecords<String, String> batches = consumer.poll(Duration.ofMillis(1000));
    for (ConsumerRecord<String, String> rec
             : batches.records(new TopicPartition("orders", 0))) {
        System.out.println(rec.key() + " -> " + rec.value());
    }
} // close() via try-with-resources (Consumer extends Closeable)
```

Evidence:
- `clients/src/main/java/org/apache/kafka/clients/consumer/KafkaConsumer.java:570` — `public KafkaConsumer(Map<String, Object> configs)`
- `clients/src/main/java/org/apache/kafka/clients/consumer/KafkaConsumer.java:620` — `public KafkaConsumer(Map<String, Object> configs,` (overload taking Deserializers)
- `clients/src/main/java/org/apache/kafka/clients/consumer/ConsumerConfig.java:137` — `BOOTSTRAP_SERVERS_CONFIG`; `:86` — `GROUP_ID_CONFIG`; `:182` — `AUTO_OFFSET_RESET_CONFIG = "auto.offset.reset"`
- `clients/src/main/java/org/apache/kafka/clients/consumer/KafkaConsumer.java:757` — `public void subscribe(Collection<String> topics)`
- `clients/src/main/java/org/apache/kafka/clients/consumer/KafkaConsumer.java:987` — `public ConsumerRecords<K, V> poll(final Duration timeout)`
- `clients/src/main/java/org/apache/kafka/clients/consumer/Consumer.java:41` — `public interface Consumer<K, V> extends Closeable`; `Consumer.java:284` — `void close()`
- `clients/src/main/java/org/apache/kafka/clients/consumer/ConsumerRecords.java:90` — `public List<ConsumerRecord<K, V>> records(TopicPartition partition)`
- `clients/src/main/java/org/apache/kafka/common/TopicPartition.java:36` — `public TopicPartition(String topic, int partition)`
- `clients/src/main/java/org/apache/kafka/clients/consumer/ConsumerRecord.java:195` — `public K key()`; `:202` — `public V value()`
- `clients/src/main/java/org/apache/kafka/common/serialization/StringDeserializer.java:36` — `public class StringDeserializer implements Deserializer<String>`

### UC3 — create a new topic through Admin

Scenario: an infrastructure bootstrap script creates topic `orders` with 6
partitions and replication factor 3 before deploying the service. `Admin.create`
is the factory for `KafkaAdminClient`; `createTopics` submits the asynchronous
request to the controller.

```java
import org.apache.kafka.clients.admin.Admin;
import org.apache.kafka.clients.admin.AdminClientConfig;
import org.apache.kafka.clients.admin.NewTopic;

import java.util.List;
import java.util.Map;

Map<String, Object> conf = Map.of(
    AdminClientConfig.BOOTSTRAP_SERVERS_CONFIG, "broker1:9092");
try (Admin admin = Admin.create(conf)) {   // Admin extends AutoCloseable
    NewTopic orders = new NewTopic("orders", 6, (short) 3);
    admin.createTopics(List.of(orders));   // CreateTopicsResult, asynchronous
    System.out.println("create request submitted");
}
```

Evidence:
- `clients/src/main/java/org/apache/kafka/clients/admin/Admin.java:145` — `static Admin create(Map<String, Object> conf)` (interface static method; body returns `KafkaAdminClient.createInternal(...)`)
- `clients/src/main/java/org/apache/kafka/clients/admin/Admin.java:127` — `public interface Admin extends AutoCloseable`
- `clients/src/main/java/org/apache/kafka/clients/admin/AdminClientConfig.java:52` — `public static final String BOOTSTRAP_SERVERS_CONFIG`
- `clients/src/main/java/org/apache/kafka/clients/admin/KafkaAdminClient.java:328` — `public class KafkaAdminClient extends AdminClient`
- `clients/src/main/java/org/apache/kafka/clients/admin/NewTopic.java:49` — `public NewTopic(String name, int numPartitions, short replicationFactor)`
- `clients/src/main/java/org/apache/kafka/clients/admin/Admin.java:182` — `default CreateTopicsResult createTopics(Collection<NewTopic> newTopics)`
- `clients/src/main/java/org/apache/kafka/clients/admin/Admin.java:169` — `void close(Duration timeout)`

**Dependencies to pull in.** Only `clients` itself — it is the leaf module
(depends_on: none). All imports in the three examples live in `clients` except
the JDK (`java.util`, `java.time`).

**Standalone build.** Gradle project path `:clients` (declared in
`settings.gradle`, line 76). Build with `./gradlew :clients:build` — a standard
lifecycle task of the Java plugin.

## server-common (5★)

The shared server-side library: `MetadataVersion`/feature levels,
`ApiMessageAndVersion` + record serde, `KafkaEventQueue`/timeline, purgatory,
fault handlers, the share persister, and utilities — the widest fan-out in the
module universe. Anyone embedding a broker/controller component (embedded
tests, operations tooling, a new server module) uses these primitives instead
of rewriting them.

### UC1 — check the cluster MetadataVersion before enabling a feature

Scenario: an operations tool needs to know which metadata version the cluster
runs on (read from config/records) before enabling a newer KIP feature. Parse
the version string, compare with `isAtLeast`, read `featureLevel` as the
numeric milestone.

```java
import org.apache.kafka.server.common.MetadataVersion;

public class FeatureGate {
    static boolean supportsKip(MetadataVersion clusterMv, MetadataVersion minimum) {
        return clusterMv.isAtLeast(minimum);
    }

    public static void main(String[] args) {
        MetadataVersion clusterMv = MetadataVersion.fromVersionString("4.0-IV0", false);
        short level = clusterMv.featureLevel();
        MetadataVersion newestProduction = MetadataVersion.latestProduction();
        boolean ok = supportsKip(clusterMv, MetadataVersion.IBP_4_0_IV0);
        System.out.println(level + " ok=" + ok + " latest=" + newestProduction);
    }
}
```

Evidence:
- `server-common/src/main/java/org/apache/kafka/server/common/MetadataVersion.java:47` — `public enum MetadataVersion`
- `MetadataVersion.java:370` — `public static MetadataVersion fromVersionString(String versionString, boolean unstableFeatureVersionsEnabled)`
- `MetadataVersion.java:445` — `public boolean isAtLeast(MetadataVersion otherVersion)`
- `MetadataVersion.java:97` — `IBP_4_0_IV0(22, "4.0", "IV0", false),` (enum constant)
- `MetadataVersion.java:195` — `public short featureLevel()`
- `MetadataVersion.java:412` — `public static MetadataVersion latestProduction()`

### UC2 — run sequential tasks on a KafkaEventQueue (the broker/controller event-thread model)

Scenario: an embedded component wants to serialize work the way the real
controller does — each unit of work is an `Event` appended to a queue, and an
exception lands in `handleException` instead of killing the thread. `close()`
shuts the event thread down.

```java
import org.apache.kafka.common.utils.Time;
import org.apache.kafka.common.utils.internals.LogContext;
import org.apache.kafka.queue.EventQueue;
import org.apache.kafka.queue.KafkaEventQueue;

public class EventDemo {
    public static void main(String[] args) throws InterruptedException {
        EventQueue queue = new KafkaEventQueue(
            Time.SYSTEM, new LogContext(), "usage-events");
        queue.append(new EventQueue.Event() {
            @Override public void run() {
                System.out.println("task running on event thread");
            }
        });
        queue.close();  // throws InterruptedException
    }
}
```

Evidence:
- `server-common/src/main/java/org/apache/kafka/queue/KafkaEventQueue.java:454` — `public KafkaEventQueue(Time time, LogContext logContext, String threadNamePrefix)`
- `server-common/src/main/java/org/apache/kafka/queue/EventQueue.java:116` — `default void append(Event event)`
- `server-common/src/main/java/org/apache/kafka/queue/EventQueue.java:26` — `interface Event`; `:30` — `void run() throws Exception`; `:43` — `default void handleException(Throwable e) {}`
- `server-common/src/main/java/org/apache/kafka/queue/EventQueue.java:227` — `void close() throws InterruptedException`
- `clients/src/main/java/org/apache/kafka/common/utils/Time.java:33` — `Time SYSTEM = SystemTime.getSystemTime()`
- `clients/src/main/java/org/apache/kafka/common/utils/internals/LogContext.java:33` — `public class LogContext`; `:41` — `public LogContext()`

### UC3 — a timeline counter with snapshots (for revertible state)

Scenario: an embedded state machine needs a counter such as "records
processed" that can revert to a snapshot point (the way the metadata cache
reverts when the leader changes). `SnapshotRegistry` manages epoch snapshots;
`TimelineInteger` records values per epoch.

```java
import org.apache.kafka.common.utils.internals.LogContext;
import org.apache.kafka.timeline.SnapshotRegistry;
import org.apache.kafka.timeline.TimelineInteger;

public class TimelineDemo {
    public static void main(String[] args) {
        SnapshotRegistry registry = new SnapshotRegistry(new LogContext());
        TimelineInteger processed = new TimelineInteger(registry);
        processed.set(7);
        int now = processed.get();
        System.out.println("processed=" + now);  // registry holds snapshot 7
    }
}
```

Evidence:
- `server-common/src/main/java/org/apache/kafka/timeline/SnapshotRegistry.java:137` — `public SnapshotRegistry(LogContext logContext)`
- `server-common/src/main/java/org/apache/kafka/timeline/TimelineInteger.java:51` — `public TimelineInteger(SnapshotRegistry snapshotRegistry)`
- `TimelineInteger.java:73` — `public void set(int newValue)`
- `TimelineInteger.java:58` — `public int get()`

**Dependencies to pull in.** `server-common` + `clients` (depends_on:
clients). UC2/UC3 import `Time` and `LogContext` from clients.

**Standalone build.** Gradle project path `:server-common` (declared in
`settings.gradle`, line 97). Build with `./gradlew :server-common:build` —
standard lifecycle task; the module's `build.gradle` defines no custom tasks.

## storage (4★)

The broker log-storage layer split out of core: `UnifiedLog`, `LogSegment`,
`LogManager`, plus the remote-storage `RemoteLogManager`; server/core consume
it through the `org.apache.kafka.storage.*` packages. Anyone working with log
data at file level (embedded tests reading/writing segments, offset-repair
tooling) uses this layer instead of parsing `.log` files by hand.

### UC1 — open a fresh log segment on disk and read a batch

Scenario: a diagnostic tool creates an empty segment at offset 0 inside a
simulated log directory to exercise the index, then reads up to 4096 bytes
from the segment head. `LogSegment.open` builds the log file plus indexes;
`read` returns a `FetchDataInfo` carrying the records.

```java
import org.apache.kafka.common.utils.Time;
import org.apache.kafka.storage.internals.log.FetchDataInfo;
import org.apache.kafka.storage.internals.log.LogConfig;
import org.apache.kafka.storage.internals.log.LogSegment;

import java.io.File;
import java.util.Map;

File dir = new File("/tmp/kafka-usage/seg-0");
dir.mkdirs();
LogConfig config = new LogConfig(Map.of());
try (LogSegment segment =
         LogSegment.open(dir, 0, config, Time.SYSTEM, 10 * 1024 * 1024, false)) {
    FetchDataInfo batch = segment.read(0, 4096);
    System.out.println("segment bytes=" + batch.records.sizeInBytes());
} // LogSegment implements Closeable
```

Evidence:
- `storage/src/main/java/org/apache/kafka/storage/internals/log/LogSegment.java:873` — `public static LogSegment open(File dir, long baseOffset, LogConfig config, Time time, int initFileSize, boolean preallocate)`
- `storage/src/main/java/org/apache/kafka/storage/internals/log/LogConfig.java:316` — `public LogConfig(Map<?, ?> props)`
- `LogSegment.java:408` — `public FetchDataInfo read(long startOffset, int maxSize) throws IOException`
- `storage/src/main/java/org/apache/kafka/storage/internals/log/FetchDataInfo.java:29` — `public final Records records`
- `clients/src/main/java/org/apache/kafka/common/record/internal/BaseRecords.java:27` — `int sizeInBytes()`
- `LogSegment.java:65` — `public class LogSegment implements Closeable`; `LogSegment.java:765` — `public void close() throws IOException`

### UC2 — read committed data on UnifiedLog (the path the broker fetch uses)

Scenario: an embedded broker/test needs to read the log from a start offset at
isolation HIGH_WATERMARK — seeing only replicated (committed) data, never the
unsafe tail. The result also reports the `highWatermark` and `logEndOffset`
markers for cross-checking.

```java
import org.apache.kafka.server.storage.log.FetchIsolation;
import org.apache.kafka.storage.internals.log.FetchDataInfo;
import org.apache.kafka.storage.internals.log.UnifiedLog;

// UnifiedLog instance created by LogManager/the quorum; the tool only reads.
public class CommittedReader {
    static void readCommitted(UnifiedLog log, long startOffset) throws Exception {
        FetchDataInfo committed =
            log.read(startOffset, 4096, FetchIsolation.HIGH_WATERMARK, true);
        System.out.println("fetch at " + committed.fetchOffsetMetadata.messageOffset);
        System.out.println("hw=" + log.highWatermark() + " leo=" + log.logEndOffset());
    }
}
```

Evidence:
- `storage/src/main/java/org/apache/kafka/storage/internals/log/UnifiedLog.java:105` — `public class UnifiedLog implements AutoCloseable`
- `UnifiedLog.java:1663` — `public FetchDataInfo read(long startOffset, int maxLength, FetchIsolation isolation, boolean minOneMessage) throws IOException`
- `server-common/src/main/java/org/apache/kafka/server/storage/log/FetchIsolation.java:23` — `LOG_END,`; `:24` — `HIGH_WATERMARK,`
- `storage/src/main/java/org/apache/kafka/storage/internals/log/UnifiedLog.java:506` — `public long highWatermark()`
- `UnifiedLog.java:2142` — `public long logEndOffset()`
- `FetchDataInfo.java:28` — `public final LogOffsetMetadata fetchOffsetMetadata` (field used in the example)
- `storage/src/main/java/org/apache/kafka/storage/internals/log/LogOffsetMetadata.java:33` — `public final long messageOffset;` (read via `committed.fetchOffsetMetadata.messageOffset` in the example)

### UC3 — package a fetch result (FetchDataInfo + LogOffsetMetadata) for tests

Scenario: when unit-testing the fetch path, build a valid `FetchDataInfo` from
offset metadata plus an empty `MemoryRecords` to simulate a read result — the
same assembly the repo's fetch path performs for request handlers.

```java
import org.apache.kafka.common.record.internal.MemoryRecords;
import org.apache.kafka.storage.internals.log.FetchDataInfo;
import org.apache.kafka.storage.internals.log.LogOffsetMetadata;

public class FetchResultFixture {
    static FetchDataInfo emptyBatchAt(long offset) {
        LogOffsetMetadata offsetMeta = new LogOffsetMetadata(offset);
        FetchDataInfo batch = new FetchDataInfo(offsetMeta, MemoryRecords.EMPTY);
        if (batch.firstEntryIncomplete) throw new IllegalStateException();
        return batch;
    }

    public static void main(String[] args) {
        FetchDataInfo b = emptyBatchAt(42);
        System.out.println("size=" + b.records.sizeInBytes());
    }
}
```

Evidence:
- `storage/src/main/java/org/apache/kafka/storage/internals/log/LogOffsetMetadata.java:37` — `public LogOffsetMetadata(long messageOffset)`
- `storage/src/main/java/org/apache/kafka/storage/internals/log/FetchDataInfo.java:33` — `public FetchDataInfo(LogOffsetMetadata fetchOffsetMetadata, Records records)`
- `FetchDataInfo.java:30` — `public final boolean firstEntryIncomplete`
- `clients/src/main/java/org/apache/kafka/common/record/internal/MemoryRecords.java:51` — `public static final MemoryRecords EMPTY`
- `MemoryRecords.java:50` — `public class MemoryRecords extends AbstractRecords`; `clients/.../internal/AbstractRecords.java:27` — `public abstract class AbstractRecords implements Records` (so MemoryRecords is a `Records`, matching the FetchDataInfo ctor parameter); `Records.java:44` — `public interface Records extends TransferableRecords`; `TransferableRecords.java:28` — `interface TransferableRecords extends BaseRecords`

**Dependencies to pull in.** `storage` + `clients` (Time/MemoryRecords),
`server-common` (FetchIsolation), `storage/api`. depended_by (7 modules): core,
server, jmh-benchmarks, tools, coordinator-common, test-common-runtime, raft.

**Standalone build.** Gradle project path `:storage` (declared in
`settings.gradle`, line 101). Build with `./gradlew :storage:build`.

## metadata (4★)

The KRaft metadata layer: `QuorumController`/`ReplicationControlManager` drive
topics, partitions, ACLs and quotas through the metadata log; the metadata
cache + image/delta model, `StandardAuthorizer`, and the `common.metadata.*`
record generation. The most practical uses for outsiders: (1) embed the KRaft
authorizer for ACL decisions, (2) read the metadata image to answer "which
partitions does this topic have, where is the leader", (3) build a KRaft-style
metadata cache for broker tests.

### UC1 — authorize READ on a topic with StandardAuthorizer

Scenario: an embedded broker (or an ACL reconciliation tool) must answer "may
User X read topic `orders`?". Configure `super.users`, build an `Action` with a
TOPIC/LITERAL `ResourcePattern`, call `authorize`, and get a
`AuthorizationResult` per action.

```java
import org.apache.kafka.common.acl.AclOperation;
import org.apache.kafka.common.security.auth.SecurityProtocol;
import org.apache.kafka.common.resource.PatternType;
import org.apache.kafka.common.resource.ResourcePattern;
import org.apache.kafka.common.resource.ResourceType;
import org.apache.kafka.common.security.auth.KafkaPrincipal;
import org.apache.kafka.metadata.authorizer.StandardAuthorizer;
import org.apache.kafka.server.authorizer.Action;
import org.apache.kafka.server.authorizer.AuthorizableRequestContext;
import org.apache.kafka.server.authorizer.AuthorizationResult;

import java.net.InetAddress;
import java.util.List;
import java.util.Map;

AuthorizableRequestContext ctx = new AuthorizableRequestContext() {
    public String listenerName() { return "PLAINTEXT"; }
    public SecurityProtocol securityProtocol() { return SecurityProtocol.PLAINTEXT; }
    public KafkaPrincipal principal() { return KafkaPrincipal.ANONYMOUS; }
    public InetAddress clientAddress() { return InetAddress.getLoopbackAddress(); }
    public int requestType() { return 18; }
    public int requestVersion() { return 1; }
    public String clientId() { return "usage"; }
    public int correlationId() { return 1; }
};

StandardAuthorizer authorizer = new StandardAuthorizer();  // as in StandardAuthorizerTest:203
authorizer.configure(Map.of(StandardAuthorizer.SUPER_USERS_CONFIG, "User:admin"));
Action readOrders = new Action(AclOperation.READ,
    new ResourcePattern(ResourceType.TOPIC, "orders", PatternType.LITERAL),
    1, true, false);
List<AuthorizationResult> verdicts = authorizer.authorize(ctx, List.of(readOrders));
System.out.println(verdicts.get(0));  // AuthorizationResult.ALLOWED / DENIED
```

Evidence:
- `metadata/src/main/java/org/apache/kafka/metadata/authorizer/StandardAuthorizer.java:57` — `public class StandardAuthorizer implements ClusterMetadataAuthorizer, Monitorable`
- `metadata/src/test/java/org/apache/kafka/metadata/authorizer/StandardAuthorizerTest.java:203` — usage reference
- `StandardAuthorizer.java:173` — `public void configure(Map<String, ?> configs)`
- `StandardAuthorizer.java:58` — `public static final String SUPER_USERS_CONFIG = "super.users"`
- `clients/src/main/java/org/apache/kafka/server/authorizer/AuthorizableRequestContext.java:31` — `public interface AuthorizableRequestContext` (methods: `listenerName` :36, `securityProtocol` :41, `principal` :46, `clientAddress` :51, `requestType` :58, `requestVersion` :65, `clientId` :70, `correlationId` :75)
- `clients/src/main/java/org/apache/kafka/common/security/auth/KafkaPrincipal.java:48` — `public static final KafkaPrincipal ANONYMOUS`
- `clients/src/main/java/org/apache/kafka/common/security/auth/SecurityProtocol.java:32` — `PLAINTEXT(0, "PLAINTEXT"),`
- `clients/src/main/java/org/apache/kafka/server/authorizer/Action.java:39` — `public Action(AclOperation operation, ResourcePattern resourcePattern, int resourceReferenceCount, boolean logIfAllowed, boolean logIfDenied)`
- `clients/src/main/java/org/apache/kafka/common/resource/ResourcePattern.java:46` — `public ResourcePattern(ResourceType resourceType, String name, PatternType patternType)`
- `clients/src/main/java/org/apache/kafka/common/acl/AclOperation.java:63` — `READ((byte) 3),`
- `clients/src/main/java/org/apache/kafka/common/resource/PatternType.java:63` — `LITERAL((byte) 3),`
- `clients/src/main/java/org/apache/kafka/common/resource/ResourceType.java:44` — `TOPIC((byte) 2),`
- `StandardAuthorizer.java:140` — `public List<AuthorizationResult> authorize(AuthorizableRequestContext requestContext, List<Action> actions)`
- `clients/src/main/java/org/apache/kafka/server/authorizer/AuthorizationResult.java:24` — `ALLOWED,`

### UC2 — query the metadata image: which partitions does topic `orders` have

Scenario: an operations dashboard embedding KRaft inspects a topic's partition
layout from a `MetadataImage` (an immutable snapshot of the metadata log).
Access the record component `topics()`, look up the `TopicImage` by name, and
walk `partitions()`.

```java
import org.apache.kafka.image.MetadataImage;
import org.apache.kafka.image.TopicImage;
import org.apache.kafka.image.TopicsImage;
import org.apache.kafka.metadata.PartitionRegistration;

import java.util.Map;

public class TopicLayout {
    static void show(MetadataImage image, String topicName) {
        TopicsImage topics = image.topics();          // record component
        TopicImage topic = topics.getTopic(topicName);
        if (topic == null) { System.out.println("topic not found"); return; }
        for (Map.Entry<Integer, PartitionRegistration> e : topic.partitions().entrySet()) {
            System.out.println("partition " + e.getKey());
        }
    }

    public static void main(String[] args) {
        show(MetadataImage.EMPTY, "orders");  // empty image -> "topic not found"
    }
}
```

Evidence:
- `metadata/src/main/java/org/apache/kafka/image/MetadataImage.java:31` — `public record MetadataImage(MetadataProvenance provenance, FeaturesImage features, ClusterImage cluster, TopicsImage topics, ConfigurationsImage configs, ClientQuotasImage clientQuotas, ProducerIdsImage producerIds, AclsImage acls, ScramImage scram, DelegationTokenImage delegationTokens)` (component `topics` → accessor `topics()`)
- `MetadataImage.java:35` — `public static final MetadataImage EMPTY = ...`
- `metadata/src/main/java/org/apache/kafka/image/TopicsImage.java:60` — `public TopicImage getTopic(String name)`
- `metadata/src/main/java/org/apache/kafka/image/TopicImage.java:37` — `public record TopicImage(String name, Uuid id, Map<Integer, PartitionRegistration> partitions)` (component `partitions` → accessor `partitions()`; import `org.apache.kafka.metadata.PartitionRegistration` — `TopicImage.java:25`)

### UC3 — build a KRaftMetadataCache for a test broker (image-driven cache)

Scenario: an embedded test needs a metadata cache in the KRaft model: the
cache holds the current `MetadataImage` and answers lookups (topic list,
topic-id, name by id) without a real broker. Update it with `setImage` when a
new image is published.

```java
import org.apache.kafka.common.Uuid;
import org.apache.kafka.image.MetadataImage;
import org.apache.kafka.metadata.KRaftMetadataCache;
import org.apache.kafka.server.common.KRaftVersion;

import java.util.Optional;
import java.util.Set;

public class CacheDemo {
    public static void main(String[] args) {
        KRaftMetadataCache cache =
            new KRaftMetadataCache(1, () -> KRaftVersion.KRAFT_VERSION_0);
        cache.setImage(MetadataImage.EMPTY);
        Set<String> topics = cache.getAllTopics();
        Uuid ordersId = cache.getTopicId("orders");
        Optional<String> ordersName = cache.getTopicName(ordersId);
        System.out.println(topics + " / " + ordersName);  // [] / Optional.empty (EMPTY image)
    }
}
```

Evidence:
- `metadata/src/main/java/org/apache/kafka/metadata/KRaftMetadataCache.java:65` — `public class KRaftMetadataCache implements MetadataCache`
- `KRaftMetadataCache.java:76` — `public KRaftMetadataCache(int brokerId, Supplier<KRaftVersion> kraftVersionSupplier)`
- `server-common/src/main/java/org/apache/kafka/server/common/KRaftVersion.java:23` — `KRAFT_VERSION_0(0, MetadataVersion.MINIMUM_VERSION),`
- `KRaftMetadataCache.java:486` — `public void setImage(MetadataImage newImage)`
- `KRaftMetadataCache.java:336` — `public Set<String> getAllTopics()`
- `KRaftMetadataCache.java:341` — `public Uuid getTopicId(String topicName)`
- `KRaftMetadataCache.java:347` — `public Optional<String> getTopicName(Uuid topicId)`
- `clients/src/main/java/org/apache/kafka/common/Uuid.java:36` — `public class Uuid implements Comparable<Uuid> {` (return type of `getTopicId`)

**Dependencies to pull in.** `metadata` + `clients` (resource/ACL types, Uuid),
`server-common` (KRaftVersion), `raft`. depended_by (9 modules): core, server,
jmh-benchmarks, shell, test-common-runtime, coordinator-common,
group-coordinator, share-coordinator, tools.

**Standalone build.** Gradle project path `:metadata` (declared in
`settings.gradle`, line 92). Build with `./gradlew :metadata:build`.

## raft (4★)

A self-contained implementation of KRaft consensus: `KafkaRaftClient` handles
leader election and log replication, `QuorumState` manages quorum state, and
the `RaftManager` interface is the attach point used by the broker/controller.
Anyone needing a replicated log with consensus (e.g. a metadata state machine)
can use this module instead of writing Raft from scratch.

### UC1 — run your state machine on KRaft (the QuorumController pattern)

```java
// 1) Build the KRaft client for your metadata state machine
RaftClient<ApiMessageAndVersion> raftClient = new KafkaRaftClient<>(
    OptionalInt.of(nodeId),   // this broker/controller's node id
    nodeDirectoryId,          // Uuid identifying the data directory
    metadataSerde,            // RecordSerde<ApiMessageAndVersion>
    channel,                  // NetworkChannel for voter RPCs
    raftLog,                  // RaftLog — the metadata log
    time);                    // Time

// 2) Register a listener: receive committed log batches + leader changes
raftClient.register(new RaftClient.Listener<ApiMessageAndVersion>() {
    @Override
    public void handleCommit(RaftClient.BatchReader<ApiMessageAndVersion> reader) {
        // metadata records committed by the leader -> apply to the state machine
    }
    @Override
    public void handleLeaderChange(LeaderAndEpoch leader) {
        // leader -> may append; follower -> read-only
    }
});
```

Evidence:
- `raft/src/main/java/org/apache/kafka/raft/KafkaRaftClient.java:234-240` — ctor: `public KafkaRaftClient(OptionalInt nodeId, Uuid nodeDirectoryId, RecordSerde<T> serde, NetworkChannel channel, RaftLog log, Time time, …)`
- `raft/src/main/java/org/apache/kafka/raft/RaftClient.java:35` — `public interface RaftClient<T> extends AutoCloseable {`
- `raft/src/main/java/org/apache/kafka/raft/RaftClient.java:37` — `interface Listener<T> {`; `:51` — `void handleCommit(BatchReader<T> reader);`; `:98` — `default void handleLeaderChange(LeaderAndEpoch leader) {}`; `:112` — `void register(Listener<T> listener);`
- `raft/src/main/java/org/apache/kafka/raft/RaftManager.java:27` — `public interface RaftManager<T> {` (entry interface); `:23` — raft itself imports `org.apache.kafka.server.common.serialization.RecordSerde` from server-common
- Real consumer: `metadata/src/main/java/org/apache/kafka/controller/QuorumController.java:116` (import), `:190` (`private RaftClient<ApiMessageAndVersion> raftClient`), `:255` (`public Builder setRaftClient(RaftClient<ApiMessageAndVersion> raftClient)`)

### UC2 — leader appends records to the log and resigns for maintenance

```java
// Once leader (from handleLeaderChange with leader.leaderId() == nodeId):
long firstOffset = raftClient.prepareAppend(currentEpoch, List.of(apiMessage));
raftClient.schedulePreparedAppend();      // flush prepared appends
long logEnd = raftClient.logEndOffset();  // track log progress
// Maintenance: hand leadership to another voter
raftClient.resign(currentEpoch);
```

Evidence:
- `raft/src/main/java/org/apache/kafka/raft/RaftClient.java:180` — `long prepareAppend(int epoch, List<T> records);`
- `raft/src/main/java/org/apache/kafka/raft/RaftClient.java:190` — `void schedulePreparedAppend();`
- `raft/src/main/java/org/apache/kafka/raft/RaftClient.java:258` — `long logEndOffset();`
- `raft/src/main/java/org/apache/kafka/raft/RaftClient.java:221` — `void resign(int epoch);`

**Dependencies to pull in.** `raft` + `server-common` (ApiMessageAndVersion +
RecordSerde from `org.apache.kafka.server.common.serialization`) + `clients`
(NetworkChannel, Time, Uuid — all in the KafkaRaftClient ctor signature).
depended_by (6 modules): metadata, core, server, tools, jmh-benchmarks,
test-common-runtime.

**Standalone build.** Gradle project path `:raft` (declared in
`settings.gradle`, line 96). Build with `./gradlew :raft:build` (or
`:raft:compileJava`).

## coordinator-common (4★)

The shared runtime for the KRaft coordinators (group/share/transaction):
`CoordinatorRuntime` is a per-partition state machine plus event processor,
with `CoordinatorLoader` (state reload from the log after restart),
`CoordinatorRecordSerde`, and metrics. Writing a new coordinator means wiring
this runtime — not building a state machine and I/O from scratch.

### UC1 — build a runtime for your own coordinator

```java
CoordinatorRuntime.Builder<MyShard, CoordinatorRecord> builder =
    new CoordinatorRuntime.Builder<>();              // Builder inner class
builder.withLogPrefix("my-coordinator")              // log prefix
       .withEventProcessor(eventProcessor)           // per-partition event machine
       .withPartitionWriter(writer)                  // writes records to the partition
       .withLoader(loader)                           // reloads state on restart
       .withTime(time)
       .withCoordinatorRuntimeMetrics(runtimeMetrics)
       .withSerializer(serde);                       // Serializer<CoordinatorRecord>
CoordinatorRuntime<MyShard, CoordinatorRecord> runtime = builder.build();
```

Evidence:
- `coordinator-common/src/main/java/org/apache/kafka/coordinator/common/runtime/CoordinatorRuntime.java:100` — `public class CoordinatorRuntime<S extends CoordinatorShard<U>, U> implements AutoCloseable {`
- `CoordinatorRuntime.java:108` — `public static class Builder<S extends CoordinatorShard<U>, U> {`
- `:126` withLogPrefix, `:136` withEventProcessor, `:141` withPartitionWriter, `:146` withLoader, `:156` withTime, `:171` withCoordinatorRuntimeMetrics, `:181` withSerializer, `:207` — `public CoordinatorRuntime<S, U> build() {`
- Interfaces: `CoordinatorShard.java:25` (`public interface CoordinatorShard<U> {`), `CoordinatorEventProcessor.java:24` (`public interface CoordinatorEventProcessor extends AutoCloseable {`), `CoordinatorLoader.java:29` (`public interface CoordinatorLoader<U> extends AutoCloseable {`)

### UC2 — write state through a write operation

```java
CompletableFuture<MyResult> done = runtime.scheduleWriteOperation(
    "put-my-state",                    // op name (log/metrics)
    topicPartition,                    // the coordinator's TopicPartition
    (shard, lastWrittenOffset) -> {    // CoordinatorWriteOperation<S, T, U>
        // return a CoordinatorResult carrying the records to append
        return myResult;
    });
// the future completes once records are written AND replayed into the shard
```

Evidence:
- `CoordinatorRuntime.java:2144-2147` — `public <T> CompletableFuture<T> scheduleWriteOperation(String name, TopicPartition tp, CoordinatorWriteOperation<S, T, U> op) {`
- Read path: `:2292` — `scheduleReadOperation`.

### UC3 — record serde plus loader for state reload

```java
public final class MyRecordSerde extends CoordinatorRecordSerde {   // abstract class
    @Override public byte[] serializeKey(CoordinatorRecord record) { /* ... */ }
    @Override public byte[] serializeValue(CoordinatorRecord record) { /* ... */ }
    @Override public CoordinatorRecord deserialize(/* params at :65 */) { /* ... */ }
}
// Reload state from the partition when the broker restarts:
CoordinatorLoader<MyState> loader =
    new CoordinatorLoaderImpl<>(/* writer, serde, time, ... — signature at :79 */);
```

Evidence:
- `coordinator-common/src/main/java/org/apache/kafka/coordinator/common/runtime/CoordinatorRecordSerde.java:42` — `public abstract class CoordinatorRecordSerde implements Serializer<CoordinatorRecord>, Deserializer<CoordinatorRecord>`; `:44` serializeKey, `:52` serializeValue, `:65` deserialize
- `CoordinatorRecord.java:31` — `public class CoordinatorRecord {`
- `CoordinatorLoaderImpl.java:51` — `public class CoordinatorLoaderImpl<T> implements CoordinatorLoader<T> {`; `:79` — `public CoordinatorLoaderImpl(`

**Dependencies to pull in.** The runtime is self-contained (record/serde/loader
in the same module). depended_by (6 modules): group-coordinator,
share-coordinator, transaction-coordinator, core, tools, jmh-benchmarks; the
server module wires it in its build file.

**Standalone build.** Gradle project path `:coordinator-common` (declared in
`settings.gradle`, line 87). Build with `./gradlew :coordinator-common:build`.

## connect/api (4★)

The SPI and data model of Kafka Connect: the `Connector`/`Task` interfaces
every connector implements, `ConnectRecord`/`SourceRecord`, `Schema`/`Struct`/
`Values`, converters, header converters, REST extension hooks, and the error
hierarchy. The runtime (connect/runtime) can only run connectors implementing
this SPI — writing a connector means writing against this module.

### UC1 — write a source connector

```java
public class UsersSourceConnector extends SourceConnector {        // the Connect SPI
    private Map<String, String> props;

    @Override
    public void start(Map<String, String> props) {                 // read configuration
        this.props = props;
    }

    @Override
    public Class<? extends Task> taskClass() {
        return UsersSourceTask.class;                              // your Task
    }

    @Override
    public List<Map<String, String>> taskConfigs(int maxTasks) {
        return List.of(props);                                     // split work across tasks
    }

    @Override
    public void stop() { }                                         // release resources

    @Override
    public ConfigDef config() { return CONFIG_DEF; }               // configuration schema
}
```

Evidence:
- `connect/api/src/main/java/org/apache/kafka/connect/source/SourceConnector.java:32` — `public abstract class SourceConnector extends Connector {`
- `connect/api/src/main/java/org/apache/kafka/connect/connector/Connector.java:48` — `public abstract class Connector implements ConnectPlugin {`
- `Connector.java:99` — `public abstract void start(Map<String, String> props);`; `:117` — `public abstract Class<? extends Task> taskClass();`; `:126` — `public abstract List<Map<String, String>> taskConfigs(int maxTasks);`; `:131` — `public abstract void stop();`; `:155` — `public abstract ConfigDef config();`
- `Connector.java:21` — `import org.apache.kafka.common.config.ConfigDef;` (ConfigDef lives in clients — a connect/api dependency)
- Lifecycle hook: `Connector.java:58` — `public void initialize(ConnectorContext ctx) {`

### UC2 — infer a schema and emit source records

```java
// Inside your SourceTask's poll(): define schema + build a source record
Schema valueSchema = SchemaBuilder.struct()             // define the schema
    .name("com.example.User")
    .field("name", Schema.STRING_SCHEMA)
    .build();

Struct value = new Struct(valueSchema)
    .put("name", "Ada Lovelace");

SourceRecord record = new SourceRecord(
    Map.of("server", "prod-db"),        // sourcePartition
    Map.of("id", 42L),                  // sourceOffset
    "users", null,                      // target topic, partition (null = unspecified)
    valueSchema, value);
```

Evidence:
- `connect/api/src/main/java/org/apache/kafka/connect/data/SchemaBuilder.java:313` — `public static SchemaBuilder struct() {`; `:149` — `public SchemaBuilder name(String name) {`; `:323` — `public SchemaBuilder field(String fieldName, Schema fieldSchema) {`; `:422` — `public Schema build() {`
- `connect/api/src/main/java/org/apache/kafka/connect/data/Schema.java:137` — `Schema STRING_SCHEMA = SchemaBuilder.string().build();`
- `connect/api/src/main/java/org/apache/kafka/connect/data/Struct.java:53` — `public Struct(Schema schema) {`; `:203` — `public Struct put(String fieldName, Object value) {`
- `connect/api/src/main/java/org/apache/kafka/connect/source/SourceRecord.java:50-51` — ctor `(Map<String, ?> sourcePartition, Map<String, ?> sourceOffset, String topic, Integer partition, Schema valueSchema, Object value)` (other overloads at `:55`, `:60`)
- Schema-less alternative: `connect/api/src/main/java/org/apache/kafka/connect/data/Values.java:346` — `public static Schema inferSchema(Object value) {`

**Dependencies to pull in.** The examples need only `connect/api` + `clients`
(ConfigDef). depended_by (8 modules): connect/runtime, connect/transforms,
connect/test-plugins, connect/mirror, connect/file, jmh-benchmarks,
connect/json, connect/basic-auth-extension.

**Standalone build.** Gradle project path `:connect:api` (declared in
`settings.gradle`, line 78; the build names the artifact `connect-api`). Build
with `./gradlew :connect:api:build`.

## share-coordinator (4★)

The coordinator runtime for share groups (KIP-932): `ShareCoordinatorService`
serves the write/read RPCs for share-partition state, and
`ShareCoordinatorShard` is the per-partition state machine persisting
`ShareGroupOffset` through the shared `CoordinatorRuntime` and coordinator
records, plus the state-batch persister from server-common.

### UC1 — enable the share coordinator on a broker

```java
ShareCoordinatorService service =
    new ShareCoordinatorService.Builder(nodeId, config)   // nodeId + ShareCoordinatorConfig
        .withWriter(writer)                               // PartitionWriter
        .withLoader(loader)                               // CoordinatorLoader<CoordinatorRecord>
        .withTime(time)
        .withTimer(timer)
        .withCoordinatorMetrics(metrics)                  // ShareCoordinatorMetrics
        .build();
service.startup(shareGroupTopicPartitionCount);           // IntSupplier
```

Evidence:
- `share-coordinator/src/main/java/org/apache/kafka/coordinator/share/ShareCoordinatorService.java:85` — `public class ShareCoordinatorService implements ShareCoordinator {`
- `:157` — `public Builder(int nodeId, ShareCoordinatorConfig config) {`; `:162` withWriter; `:167` withLoader; `:172` withTime; `:177` withTimer; `:182` withCoordinatorMetrics; `:192` — `public ShareCoordinatorService build() {`
- `:312-313` — `public void startup(IntSupplier shareGroupTopicPartitionCount) {`

### UC2 — serve share-group state RPCs

```java
// RPCs from the broker when a share group writes/reads share-partition state
CompletableFuture<WriteShareGroupStateResponseData> writeF =
    service.writeState(context, request);
CompletableFuture<ReadShareGroupStateResponseData> readF =
    service.readState(context, request);
CompletableFuture<ReadShareGroupStateSummaryResponseData> sumF =
    service.readStateSummary(context, request);
```

Evidence:
- `ShareCoordinatorService.java:472` — `public CompletableFuture<WriteShareGroupStateResponseData> writeState(RequestContext context, WriteShareGroupStateRequestData request) {`
- `:589` — `public CompletableFuture<ReadShareGroupStateResponseData> readState(RequestContext context, ReadShareGroupStateRequestData request) {`
- `:707` — `public CompletableFuture<ReadShareGroupStateSummaryResponseData> readStateSummary(RequestContext context, ReadShareGroupStateSummaryRequestData request) {`
- Same family: `:816` deleteState, `:925` initializeState.

### UC3 — shard replays share-partition snapshot records

```java
// ShareCoordinatorShard implements CoordinatorShard<CoordinatorRecord>
CoordinatorRecord snapshot = ShareCoordinatorRecordHelpers
    .newShareSnapshotRecord(groupId, topicId, partitionId, offsetData);
shard.replay(offset, producerId, producerEpoch, snapshot);
```

Evidence:
- `share-coordinator/src/main/java/org/apache/kafka/coordinator/share/ShareCoordinatorShard.java:75` — `public class ShareCoordinatorShard implements CoordinatorShard<CoordinatorRecord> {`
- `:227` — `public void replay(long offset, long producerId, short producerEpoch, CoordinatorRecord record) throws RuntimeException {`
- `share-coordinator/src/main/java/org/apache/kafka/coordinator/share/ShareCoordinatorRecordHelpers.java:29` — `public static CoordinatorRecord newShareSnapshotRecord(String groupId, Uuid topicId, int partitionId, ShareGroupOffset offsetData) {` (same family: `:55` newShareUpdateRecord, `:78` newShareStateTombstoneRecord)
- The module's own serde: `ShareCoordinatorRecordSerde.java:25` — `public class ShareCoordinatorRecordSerde extends CoordinatorRecordSerde {`

**Dependencies to pull in.** The examples need `share-coordinator` +
`coordinator-common` (CoordinatorShard/CoordinatorRecord) + `clients`
(RequestContext, Uuid) + `server-common` (persister state batches). depended_by
(4 modules): server, tools, core, jmh-benchmarks. Honest caveat: a direct
class-name search for `ShareCoordinatorService` under `server/src/main/java/`
returns 0 files; consumption is verifiable at build level — core and server
wire `implementation project(':share-coordinator')`, and server adds
`testImplementation testFixtures(project(':share-coordinator'))` in the root
`build.gradle`.

**Standalone build.** Gradle project path `:share-coordinator` (declared in
`settings.gradle`, line 99). Build with `./gradlew :share-coordinator:build`.

## Use-it-when index (all 66 modules)

Ratings are the reuse-readiness results from
[`05-stars.md`](05-stars.md) (5★=2, 4★=6, 3★=8, 2★=11, 1★=39; unrated entries
carry a reason there); the "use it when" column is derived strictly from each
module's responsibility as documented in
[`02-module-map.md`](02-module-map.md) and
[`matrix/matrix.csv`](../../matrix/matrix.csv). Modules with a detailed section
above are marked †. The 26 structurally identical Streams upgrade smoke-test
modules are collapsed into one representative row (per-module paths and sizes
are in `matrix.csv`).

| module | rating | use it when |
|---|---|---|
| clients | 5★ | An app needs produce/consume or cluster administration via the Java API; leaf module — pulls no other Kafka module † |
| server-common | 5★ | A server-side component needs shared primitives: MetadataVersion, record serde, event queue, timeline, purgatory, persister † |
| storage | 4★ | File-level log APIs (UnifiedLog/LogSegment/LogManager) to read/write segments without parsing `.log` files † |
| metadata | 4★ | KRaft metadata: topic/partition/ACL control, metadata cache + image/delta, StandardAuthorizer † |
| raft | 4★ | Self-contained KRaft consensus for a replicated log — instead of writing Raft yourself † |
| coordinator-common | 4★ | Writing a new KRaft coordinator: CoordinatorRuntime + loader/serde/metrics scaffolding † |
| connect/api | 4★ | Writing a Connect connector: Connector/Task SPI, records, Schema/Struct/Values, converters † |
| share-coordinator | 4★ | Share-group coordinator runtime (KIP-932): service/shard manage share offsets on CoordinatorRuntime † |
| streams | 3★ | Stream processing with KStream/KTable DSL, Processor API, state stores, StreamThread runtime |
| group-coordinator | 3★ | Broker-side consumer-group runtime (KIP-848): service/shard, metadata manager, assignors |
| connect/runtime | 3★ | Running Kafka Connect: CLI entries, Worker, Herder, config/offset/status stores on Kafka topics |
| connect/mirror | 3★ | MirrorMaker 2: cluster-to-cluster replication, checkpoint/heartbeat sync, standalone entry |
| connect/transforms | 3★ | Standard single-message transforms: Cast, TimestampConverter, Flatten, InsertField, RegexRouter… |
| connect/json | 3★ | The official Connect JSON converter: Schema+Struct ↔ JSON serde |
| transaction-coordinator | 3★ | Broker-side transaction data layer: TransactionMetadata, transaction log, producer-id manager |
| storage/api | 3★ | Tiered/remote-storage SPI: RemoteStorageManager, RemoteLogMetadataManager, segment metadata model |
| streams/test-utils | 2★ | Broker-less Streams topology testing: TopologyTestDriver + TestInputTopic/TestOutputTopic |
| streams/streams-scala | 2★ | Scala wrapper for the Streams DSL with Scala↔Java function conversion |
| trogdor | 2★ | Fault-injection/benchmark framework: agent + coordinator run worker tasks, workload library |
| test-common/test-common-runtime | 2★ | Real-broker KRaft cluster test kit: KafkaClusterTestKit, ClusterInstance, @ClusterTest extensions |
| test-common/test-common-internal-api | 2★ | Shared annotations/models for the cluster test framework: @ClusterTest, @ClusterTemplate, ClusterConfig |
| shell | 2★ | Interactive KRaft metadata console (ls/get/log) reading metadata through the raft client |
| connect/mirror-client | 2★ | Lightweight MirrorMaker 2 client: heartbeat/checkpoint topics, replication naming policy |
| connect/file | 2★ | Reference FileStream connectors (file → Kafka, Kafka → file); simplest connector sample |
| streams/examples | 2★ | Self-contained Streams demos with main(): WordCount, PageView, SessionWindows, InteractiveQueries |
| connect/basic-auth-extension | 2★ | Basic-auth REST extension for the Connect worker REST API (JAAS) |
| tools/tools-api | 2★ | Stable small API for CLI log-reading plugins: RecordReader/Decoder (binary-compatible) |
| core | 1★ | Run or embed the real Scala broker (entry `kafka.Kafka`); server business logic (KafkaApis, ReplicaManager) |
| tools | 1★ | Official CLIs: TopicCommand, Console*, ConsumerGroupCommand, ReassignPartitions, Config, Transactions |
| server | 1★ | Java broker services split from core: network constants, fetch sessions, share groups, client metrics |
| streams/integration-tests | 1★ | End-to-end Streams integration tests (EOS, queryable state, upgrades) — test-only |
| clients/clients-integration-tests | 1★ | Real-broker consumer/producer/share-consumer integration tests — test-only |
| jmh-benchmarks | 1★ | JMH microbenchmarks across many layers — not runtime code |
| generator | 1★ | Build-time codegen of protocol/message classes from JSON specs |
| api-checker | 1★ | Build-time guard blocking plugin use of Kafka internal APIs (ASM scan + validators) |
| streams/upgrade-system-tests-0110…4.3 (m33–m53, m61–m65) | 1★ | Upgrade smoke tests, one pinned Streams version each — test-only; per-module rows in `matrix.csv` |
| group-coordinator/group-coordinator-api | 1★ | Public group-coordinator API: assignor interfaces/records; implementation lives in group-coordinator |
| examples | 1★ | Official producer/consumer demos including the exactly-once transactional demo |
| connect/test-plugins | 1★ | Plugin-loading test fixtures for Connect runtime (Verifiable/Mock connectors) — test-only |
| test-common/test-common-util | 1★ | JUnit-platform utilities for the test cluster: post-discovery filters + @Flaky |
| mirror-coordinator | 1★ | MirrorMaker 2 coordination config (ClusterMirrorConfigs) served through server dynamic config |

## How to read this document

- **To use a 4★/5★ module**: read its section above — what the module solves,
  code sketches with evidence, the classpath to pull in, and the standalone
  build command.
- **To scan all 66 modules quickly**: use the index table above; ratings are
  reuse-readiness (not centrality), justified per module in
  [`05-stars.md`](05-stars.md).
- **For measured numbers** (sizes, dependency edges, entry classes): see
  [`02-module-map.md`](02-module-map.md) and
  [`matrix/matrix.csv`](../../matrix/matrix.csv) — they are not repeated here.
- All code evidence above was verified at the measurement commit; build the
  upstream permalink with the pin declared in
  [`index.md`](index.md).
