# Module `connect/basic-auth-extension`

Connect REST extension adding JAAS basic authentication to the worker REST API.

## At a glance

| | |
|---|---|
| Upstream | `connect/basic-auth-extension/src` in [apache/kafka](https://github.com/apache/kafka) at commit `aa62a433553c14866521bd40ff446b6920d4d67e` |
| Size | 7 files, 881 lines (whole module directory, including build files) |
| Reuse rating | 2★ — method in [`docs/method/rubric.md`](../../../../docs/method/rubric.md) |
| Extracted | 2026-10-29 |

## Dependencies

- Depends on: `connect/api`, `clients`
- Used by: None — leaf module.

Key files, with their role:

- `connect/basic-auth-extension/src/main/java/org/apache/kafka/connect/rest/basic/auth/extension/BasicAuthSecurityRestExtension.java` — entry, L64

## Related reading

- Module map entry: [`docs/kafka/02-module-map.md`](../../../../docs/kafka/02-module-map.md#m58-connect-basic-auth-extension)
- [`PROVENANCE.md`](PROVENANCE.md) — upstream source, license, and verification command
- Upstream freshness: [`tracking/kafka.md`](../../../../tracking/kafka.md)

## Verification

The source in this directory is byte-identical to apache/kafka at commit
`aa62a433553c14866521bd40ff446b6920d4d67e`: `diff -r` against a checkout of that commit shows no difference
in any upstream file. The only files added beyond the upstream tree are
cassian metadata: this `README.md`, `PROVENANCE.md`, and the `README.md` /
`PROVENANCE.md` of any nested module directory. No upstream file is modified.
