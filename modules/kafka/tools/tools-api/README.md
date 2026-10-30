# Module `tools/tools-api`

Small stable API for CLI tool plugins: `RecordReader`/`Decoder` interfaces, kept binary-compatible for log readers.

## At a glance

| | |
|---|---|
| Upstream | `tools/tools-api/src` in [apache/kafka](https://github.com/apache/kafka) at commit `aa62a433553c14866521bd40ff446b6920d4d67e` |
| Size | 9 files, 304 lines (whole module directory, including build files) |
| Reuse rating | 2★ — method in [`docs/method/rubric.md`](../../../../docs/method/rubric.md) |
| Extracted | 2026-10-29 |

## Dependencies

- Depends on: `clients`
- Used by: `tools`

Key files, with their role:

- `tools/tools-api/src/main/java/org/apache/kafka/tools/api/RecordReader.java` — interface entry, L36

## Related reading

- Module map entry: [`docs/kafka/02-module-map.md`](../../../../docs/kafka/02-module-map.md#m60-tools-tools-api)
- [`PROVENANCE.md`](PROVENANCE.md) — upstream source, license, and verification command
- Upstream freshness: [`tracking/kafka.md`](../../../../tracking/kafka.md)

## Verification

The source in this directory is byte-identical to apache/kafka at commit
`aa62a433553c14866521bd40ff446b6920d4d67e`: `diff -r` against a checkout of that commit shows no difference
in any upstream file. The only files added beyond the upstream tree are
cassian metadata: this `README.md`, `PROVENANCE.md`, and the `README.md` /
`PROVENANCE.md` of any nested module directory. No upstream file is modified.
