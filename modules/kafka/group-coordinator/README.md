# Module `group-coordinator`

Broker-side group runtime (KIP-848): `GroupCoordinatorService` plus per-partition state machines for consumer/classic/streams/share groups and the assignor set.

## At a glance

| | |
|---|---|
| Upstream | `group-coordinator/src` in [apache/kafka](https://github.com/apache/kafka) at commit `aa62a433553c14866521bd40ff446b6920d4d67e` |
| Size | 299 files, 145,040 lines (whole module directory, including build files) |
| Reuse rating | 3★ — method in [`docs/method/rubric.md`](../../../docs/method/rubric.md) |
| Extracted | 2026-10-29 |

## Dependencies

- Depends on: `clients`, `group-coordinator/group-coordinator-api`, `coordinator-common`, `server-common`, `metadata`
- Used by: `core`, `jmh-benchmarks`, `tools`, `trogdor`, `server`

Key files, with their role:

- `group-coordinator/src/main/java/org/apache/kafka/coordinator/group/GroupCoordinatorService.java` — entry, L166
- `GroupMetadataManager.java` — largest

## Related reading

- Module map entry: [`docs/kafka/02-module-map.md`](../../../docs/kafka/02-module-map.md#m04-group-coordinator)
- [`PROVENANCE.md`](PROVENANCE.md) — upstream source, license, and verification command
- Upstream freshness: [`tracking/kafka.md`](../../../tracking/kafka.md)

## Verification

The source in this directory is byte-identical to apache/kafka at commit
`aa62a433553c14866521bd40ff446b6920d4d67e`: `diff -r` against a checkout of that commit shows no difference
in any upstream file. The only files added beyond the upstream tree are
cassian metadata: this `README.md`, `PROVENANCE.md`, and the `README.md` /
`PROVENANCE.md` of any nested module directory. No upstream file is modified.
