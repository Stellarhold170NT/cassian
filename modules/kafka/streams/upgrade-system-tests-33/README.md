# Module `streams/upgrade-system-tests-33`

Streams 3.3 upgrade smoke-test suite: one of 26 structurally identical test-only modules, each pinning one historical Kafka Streams version and carrying a single `StreamsUpgradeTest` main plus a smoke-test driver.

## At a glance

| | |
|---|---|
| Upstream | `streams/upgrade-system-tests-33/src` in [apache/kafka](https://github.com/apache/kafka) at commit `aa62a433553c14866521bd40ff446b6920d4d67e` |
| Size | 5 files, 1,320 lines (whole module directory, including build files) |
| Reuse rating | 1★ — method in [`docs/method/rubric.md`](../../../../docs/method/rubric.md) |
| Extracted | 2026-10-29 |

## Dependencies

- Depends on: `streams`, `clients`
- Used by: None — leaf module.

## Related reading

- Module map entry: [`docs/kafka/02-module-map.md`](../../../../docs/kafka/02-module-map.md#streams-upgrade-system-tests-family)
- [`PROVENANCE.md`](PROVENANCE.md) — upstream source, license, and verification command
- Upstream freshness: [`tracking/kafka.md`](../../../../tracking/kafka.md)

## Verification

The source in this directory is byte-identical to apache/kafka at commit
`aa62a433553c14866521bd40ff446b6920d4d67e`: `diff -r` against a checkout of that commit shows no difference
in any upstream file. The only files added beyond the upstream tree are
cassian metadata: this `README.md`, `PROVENANCE.md`, and the `README.md` /
`PROVENANCE.md` of any nested module directory. No upstream file is modified.
