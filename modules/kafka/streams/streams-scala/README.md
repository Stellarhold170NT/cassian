# Module `streams/streams-scala`

Scala wrapper for the Streams DSL (`StreamsBuilder`, `KStream`/`KTable`) with Scala↔Java function conversion.

## At a glance

| | |
|---|---|
| Upstream | `streams/streams-scala/src` in [apache/kafka](https://github.com/apache/kafka) at commit `aa62a433553c14866521bd40ff446b6920d4d67e` |
| Size | 39 files, 6,244 lines (whole module directory, including build files) |
| Reuse rating | 2★ — method in [`docs/method/rubric.md`](../../../../docs/method/rubric.md) |
| Extracted | 2026-10-29 |

## Dependencies

- Depends on: `streams`, `clients`
- Used by: None — leaf module.

Key files, with their role:

- `streams/streams-scala/src/main/scala/org/apache/kafka/streams/scala/StreamsBuilder.scala` — entry, L34

## Related reading

- Module map entry: [`docs/kafka/02-module-map.md`](../../../../docs/kafka/02-module-map.md#m23-streams-streams-scala)
- [`PROVENANCE.md`](PROVENANCE.md) — upstream source, license, and verification command
- Upstream freshness: [`tracking/kafka.md`](../../../../tracking/kafka.md)

## Verification

The source in this directory is byte-identical to apache/kafka at commit
`aa62a433553c14866521bd40ff446b6920d4d67e`: `diff -r` against a checkout of that commit shows no difference
in any upstream file. The only files added beyond the upstream tree are
cassian metadata: this `README.md`, `PROVENANCE.md`, and the `README.md` /
`PROVENANCE.md` of any nested module directory. No upstream file is modified.
