# Module `metadata`

KRaft metadata layer: `QuorumController` and `ReplicationControlManager` drive topics/partitions/ACLs/quotas through the metadata log; metadata cache, image/delta, `StandardAuthorizer`.

## At a glance

| | |
|---|---|
| Upstream | `metadata/src` in [apache/kafka](https://github.com/apache/kafka) at commit `aa62a433553c14866521bd40ff446b6920d4d67e` |
| Size | 339 files, 63,500 lines (whole module directory, including build files) |
| Reuse rating | 4★ — method in [`docs/method/rubric.md`](../../../docs/method/rubric.md) |
| Extracted | 2026-10-29 |

## Dependencies

- Depends on: `clients`, `server-common`, `raft`
- Used by: `core`, `server`, `jmh-benchmarks`, `shell`, `test-common/test-common-runtime`, `coordinator-common`, `group-coordinator`, `share-coordinator`, `tools`

Key files, with their role:

- `metadata/src/main/java/org/apache/kafka/controller/QuorumController.java` — entry, L177
- `ReplicationControlManager.java` — largest

## Related reading

- Module map entry: [`docs/kafka/02-module-map.md`](../../../docs/kafka/02-module-map.md#m07-metadata)
- [`PROVENANCE.md`](PROVENANCE.md) — upstream source, license, and verification command
- Upstream freshness: [`tracking/kafka.md`](../../../tracking/kafka.md)

## Verification

The source in this directory is byte-identical to apache/kafka at commit
`aa62a433553c14866521bd40ff446b6920d4d67e`: `diff -r` against a checkout of that commit shows no difference
in any upstream file. The only files added beyond the upstream tree are
cassian metadata: this `README.md`, `PROVENANCE.md`, and the `README.md` /
`PROVENANCE.md` of any nested module directory. No upstream file is modified.
