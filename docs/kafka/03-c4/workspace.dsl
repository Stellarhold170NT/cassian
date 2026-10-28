' workspace.dsl — C4 của apache/kafka dạng PlantUML C4 (3 mức: L1 context / L2 container / L3 component)
' Nguồn: chuyển đổi từ 3 sơ đồ mermaid trong reports/gm-04-overview.md mục 3-5 (bản mermaid giữ nguyên trong diagrams.mmd cùng thư mục).
' Nội dung DSL được viết TẠI node publish theo chỉ định của reports/gm-final.md mục 4 ("nội dung DSL chưa tồn tại, cần viết khi publish").
' Render: PlantUML (server hoặc extension) — mỗi khối @startuml..@enduml là 1 sơ đồ; mô tả node giữ nguyên evidence file:line từ gm-04.

@startuml L1_SystemContext
!include <C4/C4_Context>
title C4 L1 — System Context: Apache Kafka (gm-04 mục 3)

System_Boundary(apps, "Ứng dụng doanh nghiệp (JVM)") {
  System(p, "Producer app", "KafkaProducer.send() — clients .../KafkaProducer.java:251")
  System(c, "Consumer app", "KafkaConsumer.poll() — clients .../KafkaConsumer.java:987")
  System(s, "Streams app", "KafkaStreams.start() — streams .../KafkaStreams.java:165")
}

Person(ops, "Ops/Admin (con người)", "bin/kafka-topics.sh, kafka-consumer-groups.sh — tools TopicCommand.java:84")
System_Ext(ext, "Hệ thống ngoài", "DB, file, cụm Kafka khác — connect/runtime ConnectDistributed.java:110, connect/mirror MirrorMaker.java:329")
System(kafka, "HỆ THỐNG APACHE KAFKA", "cluster broker+controller KRaft — wire protocol nhị phân ApiKeys.java:48-49")

Rel(p, kafka, "produce (PRODUCE)")
Rel(kafka, c, "consume (FETCH)")
Rel(s, kafka, "kèm internal topics")
Rel(ops, kafka, "AdminClient / RPC quản trị")
BiRel(ext, kafka, "Sink/Source connector, replication")
@enduml

@startuml L2_Containers
!include <C4/C4_Container>
title C4 L2 — Containers (gm-04 mục 4)

System_Boundary(dist, "Kafka distribution (build từ monorepo)") {
  Container_Boundary(jvmBroker, "JVM Broker (kafka.Kafka) — bin/kafka-server-start.sh:44 → core/.../kafka/Kafka.scala:73") {
    Component(net, "Network layer", "Scala", "SocketServer (1695 dòng) — core/.../network/SocketServer.scala:71")
    Component(apis, "KafkaApis — bộ dispatch RPC", "Scala", "core/.../server/KafkaApis.scala:95 (4414 dòng)")
    Component(re, "ReplicaManager — replica/append/fetch", "Scala", "core/.../ReplicaManager.scala:154 (2577)")
    Component(gc, "GroupCoordinatorService (KIP-848)", "Java", "group-coordinator .../GroupCoordinatorService.java:166")
    Component(tc, "Transaction coordinator data", "Java", "transaction-coordinator .../TransactionMetadata.java:37")
    Component(sc, "ShareCoordinatorService (KIP-932)", "Java", "share-coordinator .../ShareCoordinatorService.java:85")
    Component(cm, "ClientMetricsManager — telemetry", "Java", "server/.../ClientMetricsManager.java:82")
  }
  Container_Boundary(jvmCtl, "JVM Controller (KRaft) — có thể chung JVM broker ở combined mode (config/server.properties:19 process.roles=broker,controller)") {
    Component(qc, "QuorumController", "Java", "metadata/.../QuorumController.java:177 (2245)")
    Component(raft, "KafkaRaftClient", "Java", "raft/.../KafkaRaftClient.java:170 (4185)")
  }
  Container_Boundary(libs, "Thư viện client (nhúng vào app JVM)") {
    Component(cl, "clients.jar", "Java", "producer/consumer/admin")
    Component(st, "streams.jar", "Java", "Kafka Streams client")
    Component(cr, "connect-runtime.jar", "Java", "Kafka Connect runtime")
  }
  ContainerDb(disk, "Đĩa: log segments", "Log-structured commit log", "storage UnifiedLog.java:105 + LogManager.java:81 + metadata log KRaft")
  Container(clip, "CLI tools JVM", "JVM", "tools/, shell/, bin/*.sh")
}

Rel(net, apis, "dispatch")
Rel(apis, re, "append/fetch")
Rel(re, disk, "log segments")
Rel(apis, gc, "consumer groups")
Rel(apis, tc, "transactions")
Rel(apis, sc, "share groups")
Rel(apis, cm, "client metrics")
Rel(qc, raft, "metadata log")
Rel(raft, disk, "metadata log append")
Rel(jvmBroker, jvmCtl, "metadata quorum")
Rel(cl, net, "RPC")
Rel(st, cl, "dùng chung clients")
Rel(cr, cl, "dùng chung clients")
Rel(clip, cl, "dùng chung clients")
@enduml

@startuml L3_Components
!include <C4/C4_Component>
title C4 L3 — Components bên trong broker/controller (gm-04 mục 5)

Container_Boundary(brokerInternal, "Inside: Broker JVM (core + server + storage)") {
  Component(a, "SocketServer (Scala)", "Scala", "Acceptor/Processor đọc network — core/.../network/SocketServer.scala:71")
  Component(b, "RequestChannel", "Scala", "core/.../network/RequestChannel.scala (201)")
  Component(c2, "KafkaRequestHandler pool", "Scala", "core/.../KafkaRequestHandler.scala:91, gọi apis.handle — Dòng 167")
  Component(d, "KafkaApis — switch theo ApiKeys", "Scala", "Dòng 175: case ApiKeys.PRODUCE → handleProduceRequest (Dòng 401)")
  Component(e, "ReplicaManager", "Scala", "core/.../ReplicaManager.scala:154")
  Component(f, "UnifiedLog/LogManager", "Java", "storage/.../UnifiedLog.java:105, LogManager.java:81")
}
Container_Boundary(coordRuntime, "Inside: coordinator runtime (dùng chung)") {
  Component(g, "CoordinatorRuntime (generic S,U)", "Java", "state-machine per-partition — coordinator-common .../CoordinatorRuntime.java:100")
  Component(h, "GroupCoordinatorShard/GroupMetadataManager", "Java", "group-coordinator .../GroupMetadataManager.java (10188 — gm-02 m04)")
}
Container_Boundary(kraftInternal, "Inside: Controller JVM (metadata + raft)") {
  Component(i, "QuorumController", "Java", "event/claim per record — metadata/.../QuorumController.java:177")
  Component(j, "KafkaRaftClient", "Java", "leader election + log replication — raft/.../KafkaRaftClient.java:170")
}

Rel(a, b, "queue request")
Rel(b, c2, "handoff")
Rel(c2, d, "apis.handle")
Rel(d, e, "PRODUCE/FETCH")
Rel(e, f, "append/read")
Rel(d, g, "consumer groups / share / txn")
Rel(g, h, "shard write")
Rel(i, j, "metadata records")
@enduml
