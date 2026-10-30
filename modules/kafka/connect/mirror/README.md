# Module `connect/mirror`

MirrorMaker 2 on Connect runtime: source connector replicates records; checkpoint/heartbeat connectors sync offsets; standalone entry.

## At a glance

| | |
|---|---|
| Upstream | `connect/mirror/src` in [apache/kafka](https://github.com/apache/kafka) at commit `aa62a433553c14866521bd40ff446b6920d4d67e` |
| Size | 67 files, 13,643 lines (whole module directory, including build files) |
| Reuse rating | 3★ — method in [`docs/method/rubric.md`](../../../../docs/method/rubric.md) |
| Extracted | 2026-10-29 |

## Dependencies

- Depends on: `clients`, `connect/mirror-client`, `connect/runtime`, `connect/api`, `connect/json`
- Used by: None — leaf module.

Key files, with their role:

- `connect/mirror/src/main/java/org/apache/kafka/connect/mirror/MirrorMaker.java` — main, L329

## Related reading

- Module map entry: [`docs/kafka/02-module-map.md`](../../../../docs/kafka/02-module-map.md#m17-connect-mirror)
- [`PROVENANCE.md`](PROVENANCE.md) — upstream source, license, and verification command
- Upstream freshness: [`tracking/kafka.md`](../../../../tracking/kafka.md)

## Verification

The source in this directory is byte-identical to apache/kafka at commit
`aa62a433553c14866521bd40ff446b6920d4d67e`: `diff -r` against a checkout of that commit shows no difference
in any upstream file. The only files added beyond the upstream tree are
cassian metadata: this `README.md`, `PROVENANCE.md`, and the `README.md` /
`PROVENANCE.md` of any nested module directory. No upstream file is modified.
