# Module `streams/test-utils`

Official Streams test harness: `TopologyTestDriver` runs topologies without a broker; input/output topics, mock processor context.

## At a glance

| | |
|---|---|
| Upstream | `streams/test-utils/src` in [apache/kafka](https://github.com/apache/kafka) at commit `aa62a433553c14866521bd40ff446b6920d4d67e` |
| Size | 22 files, 8,893 lines (whole module directory, including build files) |
| Reuse rating | 2★ — method in [`docs/method/rubric.md`](../../../../docs/method/rubric.md) |
| Extracted | 2026-10-29 |

## Dependencies

- Depends on: `streams`, `clients`
- Used by: None — leaf module.

Key files, with their role:

- ``streams/test-utils/src/main/java/org/apache/kafka/streams/TopologyTestDriver.java` (entry, L229`
- `2103 lines)`

## Related reading

- Module map entry: [`docs/kafka/02-module-map.md`](../../../../docs/kafka/02-module-map.md#m22-streams-test-utils)
- [`PROVENANCE.md`](PROVENANCE.md) — upstream source, license, and verification command
- Upstream freshness: [`tracking/kafka.md`](../../../../tracking/kafka.md)

## Verification

The source in this directory is byte-identical to apache/kafka at commit
`aa62a433553c14866521bd40ff446b6920d4d67e`: `diff -r` against a checkout of that commit shows no difference
in any upstream file. The only files added beyond the upstream tree are
cassian metadata: this `README.md`, `PROVENANCE.md`, and the `README.md` /
`PROVENANCE.md` of any nested module directory. No upstream file is modified.
