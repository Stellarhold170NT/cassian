# Module `share-coordinator`

Share-group coordinator runtime (KIP-932): `ShareCoordinatorService` + shard manage share-group offsets through the CoordinatorRuntime.

## At a glance

| | |
|---|---|
| Upstream | `share-coordinator/src` in [apache/kafka](https://github.com/apache/kafka) at commit `aa62a433553c14866521bd40ff446b6920d4d67e` |
| Size | 27 files, 10,109 lines (whole module directory, including build files) |
| Reuse rating | 4★ — method in [`docs/method/rubric.md`](../../../docs/method/rubric.md) |
| Extracted | 2026-10-29 |

## Dependencies

- Depends on: `clients`, `coordinator-common`, `server-common`, `metadata`
- Used by: `server`, `tools`, `core`, `jmh-benchmarks`

Key files, with their role:

- `share-coordinator/src/main/java/org/apache/kafka/coordinator/share/ShareCoordinatorService.java` — entry = largest, L85, 1194 lines

## Related reading

- Module map entry: [`docs/kafka/02-module-map.md`](../../../docs/kafka/02-module-map.md#m20-share-coordinator)
- [`PROVENANCE.md`](PROVENANCE.md) — upstream source, license, and verification command
- Upstream freshness: [`tracking/kafka.md`](../../../tracking/kafka.md)

## Verification

The source in this directory is byte-identical to apache/kafka at commit
`aa62a433553c14866521bd40ff446b6920d4d67e`: `diff -r` against a checkout of that commit shows no difference
in any upstream file. The only files added beyond the upstream tree are
cassian metadata: this `README.md`, `PROVENANCE.md`, and the `README.md` /
`PROVENANCE.md` of any nested module directory. No upstream file is modified.
