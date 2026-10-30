# Module `test-common/test-common-internal-api`

Annotations and models for the cluster test framework: `@ClusterTest`, `@ClusterTemplate`, `ClusterConfig`, thread-leak detection.

## At a glance

| | |
|---|---|
| Upstream | `test-common/test-common-internal-api/src` in [apache/kafka](https://github.com/apache/kafka) at commit `aa62a433553c14866521bd40ff446b6920d4d67e` |
| Size | 15 files, 1,166 lines (whole module directory, including build files) |
| Reuse rating | 2★ — method in [`docs/method/rubric.md`](../../../../docs/method/rubric.md) |
| Extracted | 2026-10-29 |

## Dependencies

- Depends on: `clients`, `server-common`
- Used by: None — leaf module.

Key files, with their role:

- `test-common/test-common-internal-api/src/main/java/org/apache/kafka/common/test/api/ClusterTest.java` — annotation entry, L49

## Related reading

- Module map entry: [`docs/kafka/02-module-map.md`](../../../../docs/kafka/02-module-map.md#m57-test-common-test-common-internal-api)
- [`PROVENANCE.md`](PROVENANCE.md) — upstream source, license, and verification command
- Upstream freshness: [`tracking/kafka.md`](../../../../tracking/kafka.md)

## Verification

The source in this directory is byte-identical to apache/kafka at commit
`aa62a433553c14866521bd40ff446b6920d4d67e`: `diff -r` against a checkout of that commit shows no difference
in any upstream file. The only files added beyond the upstream tree are
cassian metadata: this `README.md`, `PROVENANCE.md`, and the `README.md` /
`PROVENANCE.md` of any nested module directory. No upstream file is modified.
