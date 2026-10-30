![upstream](https://img.shields.io/badge/upstream-STALE-red)

| project | pinned_sha | head_now | state | last-check (UTC) |
|---|---|---|---|---|
| kafka | aa62a433553c14866521bd40ff446b6920d4d67e | 14ee92ca1ecf469eb8f006abf7b75453513cac49 | STALE | 2026-10-29T23:57:00Z |

- Source of the pin: `docs/kafka/index.md` front matter (`measured_at`) — the
  commit of upstream `trunk` the subject was frozen against: "KAFKA-20866:
  Remove incremental-only append result state (#23749)".
- Check command: `git ls-remote https://github.com/apache/kafka refs/heads/trunk`.
  FRESH when it equals the pin; STALE otherwise (sha comparison only, no commit
  resolution). Current head `14ee92ca` ("KAFKA-21230: Pause task executors on
  byte limit (#23984)") differs from the pin → STALE.
- STALE policy: do not re-measure automatically — the pin stays, a re-sync
  cycle decides when to re-certify against a new commit.
- Measurement note: documentation statistics (census, module sizes, ratings,
  flow traces) were taken at `0c92b0664539d0dfb60b43ede0026497a581d8e0`
  (KAFKA-20125), one of the commits after the pin. Upstream
  `aa62a433..0c92b066` touched 15 files (`SslPrincipalMapper`, `BrokerServer`,
  `KafkaConfig`, `BrokerLifecycleManager`, `AssignmentBuilder`, `QuotaConfig`,
  `ServerLogConfigs`, `DynamicLogConfig` and related tests); none of them is
  cited by the docs, so every reference resolves identically at both commits.
  The current head moved one further commit (streams-only); the same reasoning
  applies to the citation set.

## Harvest (extracted modules)

- Pin: `aa62a433553c14866521bd40ff446b6920d4d67e` (upstream trunk at extraction time).
- 66 of 66 gradle modules extracted verbatim under `modules/kafka/` — 7,392 files,
  1,880,438 measured lines across whole module directories (build files included).
- Each module directory carries `PROVENANCE.md` (upstream sha, path, license,
  measured size, re-sync rule).
- Extracts are byte-identical to upstream at the pin; re-verify with
  `diff -r modules/kafka/<module> <upstream clone>/<module>`.

## Documentation set

- `docs/kafka/01…07` + `docs/method/rubric.md` + `matrix/matrix.csv` +
  `specs/kafka/clients.plan.md` + `specs/kafka/server-common.plan.md` form the
  documentation set for this subject; reading order in
  [`docs/kafka/index.md`](../docs/kafka/index.md).
- The set was verified against the upstream tree `0c92b066` as described in the
  measurement note; per-file measurement provenance lives in each document's
  own note and front matter.
