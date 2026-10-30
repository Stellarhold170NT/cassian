# Module `connect/json`

Official Connect JSON converter: schema-aware serde between `Struct` and JSON, with config and schema utilities.

## At a glance

| | |
|---|---|
| Upstream | `connect/json/src` in [apache/kafka](https://github.com/apache/kafka) at commit `aa62a433553c14866521bd40ff446b6920d4d67e` |
| Size | 12 files, 2,326 lines (whole module directory, including build files) |
| Reuse rating | 3★ — method in [`docs/method/rubric.md`](../../../../docs/method/rubric.md) |
| Extracted | 2026-10-29 |

## Dependencies

- Depends on: `connect/api`, `clients`
- Used by: `connect/runtime`, `connect/mirror`, `jmh-benchmarks`

Key files, with their role:

- ``connect/json/src/main/java/org/apache/kafka/connect/json/JsonConverter.java` (entry, L65`
- `766 lines)`

## Related reading

- Module map entry: [`docs/kafka/02-module-map.md`](../../../../docs/kafka/02-module-map.md#m28-connect-json)
- [`PROVENANCE.md`](PROVENANCE.md) — upstream source, license, and verification command
- Upstream freshness: [`tracking/kafka.md`](../../../../tracking/kafka.md)

## Verification

The source in this directory is byte-identical to apache/kafka at commit
`aa62a433553c14866521bd40ff446b6920d4d67e`: `diff -r` against a checkout of that commit shows no difference
in any upstream file. The only files added beyond the upstream tree are
cassian metadata: this `README.md`, `PROVENANCE.md`, and the `README.md` /
`PROVENANCE.md` of any nested module directory. No upstream file is modified.
