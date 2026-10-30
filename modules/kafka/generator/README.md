# Module `generator`

Build-time protocol generator: reads JSON message specs and emits the message classes owned by their defining modules.

## At a glance

| | |
|---|---|
| Upstream | `generator/src` in [apache/kafka](https://github.com/apache/kafka) at commit `aa62a433553c14866521bd40ff446b6920d4d67e` |
| Size | 52 files, 11,053 lines (whole module directory, including build files) |
| Reuse rating | 1★ — method in [`docs/method/rubric.md`](../../../docs/method/rubric.md) |
| Extracted | 2026-10-29 |

## Dependencies

- Depends on: None — leaf module.
- Used by: None — leaf module.

Key files, with their role:

- `generator/src/main/java/org/apache/kafka/message/MessageGenerator.java` — main, L432

## Related reading

- Module map entry: [`docs/kafka/02-module-map.md`](../../../docs/kafka/02-module-map.md#m19-generator)
- [`PROVENANCE.md`](PROVENANCE.md) — upstream source, license, and verification command
- Upstream freshness: [`tracking/kafka.md`](../../../tracking/kafka.md)

## Verification

The source in this directory is byte-identical to apache/kafka at commit
`aa62a433553c14866521bd40ff446b6920d4d67e`: `diff -r` against a checkout of that commit shows no difference
in any upstream file. The only files added beyond the upstream tree are
cassian metadata: this `README.md`, `PROVENANCE.md`, and the `README.md` /
`PROVENANCE.md` of any nested module directory. No upstream file is modified.
