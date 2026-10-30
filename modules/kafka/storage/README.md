# Module `storage`

Broker log storage layer split out of core: `UnifiedLog`, `LogSegment`, `LogManager`, plus the remote-storage manager hooks consumed via `org.apache.kafka.storage.*`.

## At a glance

| | |
|---|---|
| Upstream | `storage/src` in [apache/kafka](https://github.com/apache/kafka) at commit `aa62a433553c14866521bd40ff446b6920d4d67e` |
| Size | 285 files, 76,796 lines (whole module directory, including build files) |
| Reuse rating | 4★ — method in [`docs/method/rubric.md`](../../../docs/method/rubric.md) |
| Extracted | 2026-10-29 |

## Dependencies

- Depends on: `clients`, `server-common`, `storage/api`
- Used by: `core`, `server`, `jmh-benchmarks`, `tools`, `coordinator-common`, `test-common/test-common-runtime`, `raft`

Key files, with their role:

- `storage/src/main/java/org/apache/kafka/storage/internals/log/UnifiedLog.java` — entry = largest, L105, 2806 lines
- `LogSegment.java`

## Related reading

- Module map entry: [`docs/kafka/02-module-map.md`](../../../docs/kafka/02-module-map.md#m06-storage)
- [`PROVENANCE.md`](PROVENANCE.md) — upstream source, license, and verification command
- Upstream freshness: [`tracking/kafka.md`](../../../tracking/kafka.md)

## Verification

The source in this directory is byte-identical to apache/kafka at commit
`aa62a433553c14866521bd40ff446b6920d4d67e`: `diff -r` against a checkout of that commit shows no difference
in any upstream file. The only files added beyond the upstream tree are
cassian metadata: this `README.md`, `PROVENANCE.md`, and the `README.md` /
`PROVENANCE.md` of any nested module directory. No upstream file is modified.
