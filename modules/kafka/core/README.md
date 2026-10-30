# Module `core`

Scala broker module with the runnable entry point (`kafka.Kafka`) and most server-side business logic: KafkaApis, ReplicaManager, share partitions, the Scala controller.

## At a glance

| | |
|---|---|
| Upstream | `core/src` in [apache/kafka](https://github.com/apache/kafka) at commit `aa62a433553c14866521bd40ff446b6920d4d67e` |
| Size | 248 files, 160,291 lines (whole module directory, including build files) |
| Reuse rating | 1★ — method in [`docs/method/rubric.md`](../../../docs/method/rubric.md) |
| Extracted | 2026-10-29 |

## Dependencies

- Depends on: `clients`, `server`, `server-common`, `storage`, `storage/api`, `metadata`, `raft`, `group-coordinator`, `transaction-coordinator`, `share-coordinator`, `coordinator-common`
- Used by: `jmh-benchmarks`, `test-common/test-common-runtime`

Key files, with their role:

- `core/src/main/scala/kafka/Kafka.scala` — entry, L73
- `kafka/server/KafkaApis.scala` — largest

## Related reading

- Module map entry: [`docs/kafka/02-module-map.md`](../../../docs/kafka/02-module-map.md#m03-core)
- [`PROVENANCE.md`](PROVENANCE.md) — upstream source, license, and verification command
- Upstream freshness: [`tracking/kafka.md`](../../../tracking/kafka.md)

## Verification

The source in this directory is byte-identical to apache/kafka at commit
`aa62a433553c14866521bd40ff446b6920d4d67e`: `diff -r` against a checkout of that commit shows no difference
in any upstream file. The only files added beyond the upstream tree are
cassian metadata: this `README.md`, `PROVENANCE.md`, and the `README.md` /
`PROVENANCE.md` of any nested module directory. No upstream file is modified.
