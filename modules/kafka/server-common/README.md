# Module `server-common`

Shared server-side library: `MetadataVersion`, ApiMessage/RecordSerde, `KafkaEventQueue`, purgatory, fault handlers, share persister, utils; the widest fan-out in the system.

## At a glance

| | |
|---|---|
| Upstream | `server-common/src` in [apache/kafka](https://github.com/apache/kafka) at commit `aa62a433553c14866521bd40ff446b6920d4d67e` |
| Size | 212 files, 35,972 lines (whole module directory, including build files) |
| Reuse rating | 5★ — method in [`docs/method/rubric.md`](../../../docs/method/rubric.md) |
| Extracted | 2026-10-29 |

## Dependencies

- Depends on: `clients`
- Used by: `metadata`, `server`, `raft`, `tools`, `storage`, `jmh-benchmarks`, `group-coordinator`, `core`, `coordinator-common`, `share-coordinator`, `test-common/test-common-runtime`, `transaction-coordinator`, `test-common/test-common-internal-api`, `connect/test-plugins`, `storage/api`, `shell`

Key files, with their role:

- `server-common/src/main/java/org/apache/kafka/server/common/MetadataVersion.java` — entry enum, L47
- `share/persister/PersisterStateManager.java` — largest

## Related reading

- Module map entry: [`docs/kafka/02-module-map.md`](../../../docs/kafka/02-module-map.md#m12-server-common)
- [`PROVENANCE.md`](PROVENANCE.md) — upstream source, license, and verification command
- Upstream freshness: [`tracking/kafka.md`](../../../tracking/kafka.md)

## Verification

The source in this directory is byte-identical to apache/kafka at commit
`aa62a433553c14866521bd40ff446b6920d4d67e`: `diff -r` against a checkout of that commit shows no difference
in any upstream file. The only files added beyond the upstream tree are
cassian metadata: this `README.md`, `PROVENANCE.md`, and the `README.md` /
`PROVENANCE.md` of any nested module directory. No upstream file is modified.
