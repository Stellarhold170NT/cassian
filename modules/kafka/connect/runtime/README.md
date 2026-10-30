# Module `connect/runtime`

Connect execution runtime: CLI entries (distributed/standalone), Worker and Herder, config/offset/status stores backed by Kafka topics.

## At a glance

| | |
|---|---|
| Upstream | `connect/runtime/src` in [apache/kafka](https://github.com/apache/kafka) at commit `aa62a433553c14866521bd40ff446b6920d4d67e` |
| Size | 433 files, 104,996 lines (whole module directory, including build files) |
| Reuse rating | 3★ — method in [`docs/method/rubric.md`](../../../../docs/method/rubric.md) |
| Extracted | 2026-10-29 |

## Dependencies

- Depends on: `clients`, `connect/api`, `connect/transforms`, `connect/json`
- Used by: `connect/mirror`, `tools`

Key files, with their role:

- `connect/runtime/src/main/java/org/apache/kafka/connect/cli/ConnectDistributed.java` — main, L110
- `distributed/DistributedHerder.java` — largest

## Related reading

- Module map entry: [`docs/kafka/02-module-map.md`](../../../../docs/kafka/02-module-map.md#m05-connect-runtime)
- [`PROVENANCE.md`](PROVENANCE.md) — upstream source, license, and verification command
- Upstream freshness: [`tracking/kafka.md`](../../../../tracking/kafka.md)

## Verification

The source in this directory is byte-identical to apache/kafka at commit
`aa62a433553c14866521bd40ff446b6920d4d67e`: `diff -r` against a checkout of that commit shows no difference
in any upstream file. The only files added beyond the upstream tree are
cassian metadata: this `README.md`, `PROVENANCE.md`, and the `README.md` /
`PROVENANCE.md` of any nested module directory. No upstream file is modified.
