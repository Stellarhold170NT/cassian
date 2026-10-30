# Module `streams`

Kafka Streams client library: KStream/KTable DSL, Processor API, state stores, StreamThread/TaskManager runtime; public entry `KafkaStreams`.

## At a glance

| | |
|---|---|
| Upstream | `streams/src` in [apache/kafka](https://github.com/apache/kafka) at commit `aa62a433553c14866521bd40ff446b6920d4d67e` |
| Size | 1593 files, 436,156 lines (whole module directory, including build files) |
| Reuse rating | 3★ — method in [`docs/method/rubric.md`](../../../docs/method/rubric.md) |
| Extracted | 2026-10-29 |

## Dependencies

- Depends on: `clients`
- Used by: `streams/streams-scala`, `streams/examples`, `streams/test-utils`, `jmh-benchmarks`

Key files, with their role:

- `streams/src/main/java/org/apache/kafka/streams/KafkaStreams.java` — entry, L165
- `kstream/KTable.java` — largest

## Related reading

- Module map entry: [`docs/kafka/02-module-map.md`](../../../docs/kafka/02-module-map.md#m02-streams)
- [`PROVENANCE.md`](PROVENANCE.md) — upstream source, license, and verification command
- Upstream freshness: [`tracking/kafka.md`](../../../tracking/kafka.md)

## Verification

The source in this directory is byte-identical to apache/kafka at commit
`aa62a433553c14866521bd40ff446b6920d4d67e`: `diff -r` against a checkout of that commit shows no difference
in any upstream file. The only files added beyond the upstream tree are
cassian metadata: this `README.md`, `PROVENANCE.md`, and the `README.md` /
`PROVENANCE.md` of any nested module directory. No upstream file is modified.
