# Module `test-common/test-common-util`

JUnit-platform utilities for the test-cluster framework: post-discovery filters and the `@Flaky` annotation.

## At a glance

| | |
|---|---|
| Upstream | `test-common/test-common-util/src` in [apache/kafka](https://github.com/apache/kafka) at commit `aa62a433553c14866521bd40ff446b6920d4d67e` |
| Size | 8 files, 679 lines (whole module directory, including build files) |
| Reuse rating | 1★ — method in [`docs/method/rubric.md`](../../../../docs/method/rubric.md) |
| Extracted | 2026-10-29 |

## Dependencies

- Depends on: None — leaf module.
- Used by: `test-common/test-common-runtime`

Key files, with their role:

- `test-common/test-common-util/src/main/java/org/apache/kafka/common/test/junit/KafkaPostDiscoveryFilter.java` — entry, 152 lines

## Related reading

- Module map entry: [`docs/kafka/02-module-map.md`](../../../../docs/kafka/02-module-map.md#m59-test-common-test-common-util)
- [`PROVENANCE.md`](PROVENANCE.md) — upstream source, license, and verification command
- Upstream freshness: [`tracking/kafka.md`](../../../../tracking/kafka.md)

## Verification

The source in this directory is byte-identical to apache/kafka at commit
`aa62a433553c14866521bd40ff446b6920d4d67e`: `diff -r` against a checkout of that commit shows no difference
in any upstream file. The only files added beyond the upstream tree are
cassian metadata: this `README.md`, `PROVENANCE.md`, and the `README.md` /
`PROVENANCE.md` of any nested module directory. No upstream file is modified.
