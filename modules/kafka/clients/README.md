# Module `clients`

Foundational Java client library: producer, consumer, admin, plus nearly all of `org.apache.kafka.common`; the leaf every other module stands on.

## At a glance

| | |
|---|---|
| Upstream | `clients/src` in [apache/kafka](https://github.com/apache/kafka) at commit `aa62a433553c14866521bd40ff446b6920d4d67e` |
| Size | 2157 files, 422,253 lines (whole module directory, including build files) |
| Reuse rating | 5★ — method in [`docs/method/rubric.md`](../../../docs/method/rubric.md) |
| Extracted | 2026-10-29 |

## Dependencies

- Depends on: None — leaf module.
- Used by: `streams`, `tools`, `connect/runtime`, `trogdor`, `server`, `connect/mirror`, `core`, `metadata`, `jmh-benchmarks`, `server-common`, `streams/examples`, `storage`, `test-common/test-common-runtime`, `examples`, `connect/mirror-client`, `group-coordinator`, `streams/test-utils`, `raft`, `connect/test-plugins`, `connect/api`, `transaction-coordinator`, `tools/tools-api`, `connect/file`

Key files, with their role:

- `clients/src/main/java/org/apache/kafka/clients/producer/KafkaProducer.java` — entry, L251
- `admin/KafkaAdminClient.java` — largest

## Related reading

- Module map entry: [`docs/kafka/02-module-map.md`](../../../docs/kafka/02-module-map.md#m01-clients)
- [`PROVENANCE.md`](PROVENANCE.md) — upstream source, license, and verification command
- Upstream freshness: [`tracking/kafka.md`](../../../tracking/kafka.md)

## Verification

The source in this directory is byte-identical to apache/kafka at commit
`aa62a433553c14866521bd40ff446b6920d4d67e`: `diff -r` against a checkout of that commit shows no difference
in any upstream file. The only files added beyond the upstream tree are
cassian metadata: this `README.md`, `PROVENANCE.md`, and the `README.md` /
`PROVENANCE.md` of any nested module directory. No upstream file is modified.
