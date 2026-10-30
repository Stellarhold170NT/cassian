# Module `tools`

Official CLI set: TopicCommand, ConsoleProducer/Consumer, ConsumerGroupCommand, ReassignPartitionsCommand, ConfigCommand, TransactionsCommand, StreamsGroupCommand.

## At a glance

| | |
|---|---|
| Upstream | `tools/src` in [apache/kafka](https://github.com/apache/kafka) at commit `aa62a433553c14866521bd40ff446b6920d4d67e` |
| Size | 166 files, 62,825 lines (whole module directory, including build files) |
| Reuse rating | 1★ — method in [`docs/method/rubric.md`](../../../docs/method/rubric.md) |
| Extracted | 2026-10-29 |

## Dependencies

- Depends on: `clients`, `server-common`, `connect/runtime`, `storage`, `group-coordinator`, `metadata`, `transaction-coordinator`, `coordinator-common`, `tools/tools-api`, `raft`, `server`, `share-coordinator`
- Used by: None — leaf module.

Key files, with their role:

- `tools/src/main/java/org/apache/kafka/tools/TopicCommand.java` — main, L84
- `reassign/ReassignPartitionsCommand.java` — largest

## Related reading

- Module map entry: [`docs/kafka/02-module-map.md`](../../../docs/kafka/02-module-map.md#m08-tools)
- [`PROVENANCE.md`](PROVENANCE.md) — upstream source, license, and verification command
- Upstream freshness: [`tracking/kafka.md`](../../../tracking/kafka.md)

## Verification

The source in this directory is byte-identical to apache/kafka at commit
`aa62a433553c14866521bd40ff446b6920d4d67e`: `diff -r` against a checkout of that commit shows no difference
in any upstream file. The only files added beyond the upstream tree are
cassian metadata: this `README.md`, `PROVENANCE.md`, and the `README.md` /
`PROVENANCE.md` of any nested module directory. No upstream file is modified.
