# Module `server`

Java broker services split out of core: SocketServer network constants, fetch sessions, share groups, client metrics/telemetry, quotas, dynamic config.

## At a glance

| | |
|---|---|
| Upstream | `server/src` in [apache/kafka](https://github.com/apache/kafka) at commit `aa62a433553c14866521bd40ff446b6920d4d67e` |
| Size | 267 files, 53,788 lines (whole module directory, including build files) |
| Reuse rating | 1★ — method in [`docs/method/rubric.md`](../../../docs/method/rubric.md) |
| Extracted | 2026-10-29 |

## Dependencies

- Depends on: `clients`, `server-common`, `metadata`, `storage`, `raft`, `group-coordinator`, `group-coordinator/group-coordinator-api`, `transaction-coordinator`, `share-coordinator`, `mirror-coordinator`
- Used by: `core`, `jmh-benchmarks`, `test-common/test-common-runtime`, `tools`

Key files, with their role:

- ``server/src/main/java/org/apache/kafka/network/SocketServer.java` (L24 — 42-line constants holder`
- `real network layer is core's Scala `SocketServer.scala:71`, see overview §11)`
- `share/dlq/ShareGroupDLQStateManager.java` — largest

## Related reading

- Module map entry: [`docs/kafka/02-module-map.md`](../../../docs/kafka/02-module-map.md#m10-server)
- [`PROVENANCE.md`](PROVENANCE.md) — upstream source, license, and verification command
- Upstream freshness: [`tracking/kafka.md`](../../../tracking/kafka.md)

## Verification

The source in this directory is byte-identical to apache/kafka at commit
`aa62a433553c14866521bd40ff446b6920d4d67e`: `diff -r` against a checkout of that commit shows no difference
in any upstream file. The only files added beyond the upstream tree are
cassian metadata: this `README.md`, `PROVENANCE.md`, and the `README.md` /
`PROVENANCE.md` of any nested module directory. No upstream file is modified.
