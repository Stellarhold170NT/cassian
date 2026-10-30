# Module `streams/integration-tests`

End-to-end Streams integration tests (EOS, queryable state, store upgrades, rebalance) against a real broker; test-only.

## At a glance

| | |
|---|---|
| Upstream | `streams/integration-tests/src` in [apache/kafka](https://github.com/apache/kafka) at commit `aa62a433553c14866521bd40ff446b6920d4d67e` |
| Size | 119 files, 50,860 lines (whole module directory, including build files) |
| Reuse rating | 1★ — method in [`docs/method/rubric.md`](../../../../docs/method/rubric.md) |
| Extracted | 2026-10-29 |

## Dependencies

- Depends on: `streams`, `clients`, `streams/test-utils`, `group-coordinator`, `group-coordinator/group-coordinator-api`, `server-common`, `tools`, `server`, `transaction-coordinator`, `test-common/test-common-runtime`, `storage`, `streams/upgrade-system-tests-43`
- Used by: None — leaf module.

Key files, with their role:

- `streams/integration-tests/src/test/java/org/apache/kafka/streams/integration/IQv2StoreIntegrationTest.java` — largest

## Related reading

- Module map entry: [`docs/kafka/02-module-map.md`](../../../../docs/kafka/02-module-map.md#m11-streams-integration-tests)
- [`PROVENANCE.md`](PROVENANCE.md) — upstream source, license, and verification command
- Upstream freshness: [`tracking/kafka.md`](../../../../tracking/kafka.md)

## Verification

The source in this directory is byte-identical to apache/kafka at commit
`aa62a433553c14866521bd40ff446b6920d4d67e`: `diff -r` against a checkout of that commit shows no difference
in any upstream file. The only files added beyond the upstream tree are
cassian metadata: this `README.md`, `PROVENANCE.md`, and the `README.md` /
`PROVENANCE.md` of any nested module directory. No upstream file is modified.
