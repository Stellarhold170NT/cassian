# Module `connect/test-plugins`

Plugin-loading test fixtures for Connect runtime (Verifiable/Mock connectors and tasks); test-only.

## At a glance

| | |
|---|---|
| Upstream | `connect/test-plugins/src` in [apache/kafka](https://github.com/apache/kafka) at commit `aa62a433553c14866521bd40ff446b6920d4d67e` |
| Size | 14 files, 1,158 lines (whole module directory, including build files) |
| Reuse rating | 1★ — method in [`docs/method/rubric.md`](../../../../docs/method/rubric.md) |
| Extracted | 2026-10-29 |

## Dependencies

- Depends on: `connect/api`, `clients`, `server-common`
- Used by: None — leaf module.

Key files, with their role:

- `connect/test-plugins/src/main/java/org/apache/kafka/connect/tools/VerifiableSourceTask.java` — entry, L50

## Related reading

- Module map entry: [`docs/kafka/02-module-map.md`](../../../../docs/kafka/02-module-map.md#m56-connect-test-plugins)
- [`PROVENANCE.md`](PROVENANCE.md) — upstream source, license, and verification command
- Upstream freshness: [`tracking/kafka.md`](../../../../tracking/kafka.md)

## Verification

The source in this directory is byte-identical to apache/kafka at commit
`aa62a433553c14866521bd40ff446b6920d4d67e`: `diff -r` against a checkout of that commit shows no difference
in any upstream file. The only files added beyond the upstream tree are
cassian metadata: this `README.md`, `PROVENANCE.md`, and the `README.md` /
`PROVENANCE.md` of any nested module directory. No upstream file is modified.
