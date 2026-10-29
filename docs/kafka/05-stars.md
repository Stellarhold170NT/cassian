---
subject: apache/kafka
measured_at: aa62a433553c14866521bd40ff446b6920d4d67e
status: final
---

# Module ratings

Results of the rubric described in [`docs/method/rubric.md`](../method/rubric.md)
applied to all 66 Gradle modules of apache/kafka. Distribution:
**5★ = 2 · 4★ = 6 · 3★ = 8 · 2★ = 11 · 1★ = 39** (66/66 rated; no module left
unrated). The machine-readable copy — one row per module with dependencies,
sizes and document links — lives in [`matrix/matrix.csv`](../../matrix/matrix.csv).

The "binding constraint" column names the signal that keeps the module at its
level (`deps` = S1, `edges` = S2, `ratio` = S3, `loc/PLM` = S5). Where several
signals bind, all are listed. Statistics were measured at upstream commit
`0c92b0664539d0dfb60b43ede0026497a581d8e0`; see the measurement note in
[`docs/method/rubric.md`](../method/rubric.md) for how this relates to the
extracts pin.

| id | module | rating | binding constraint |
|---|---|---|---|
| s01 | clients | 5★ | — (0 deps, 23 edges, ratio 0.48, loc 387364, PLM 6928, 2 evidence incl. out-of-repo) |
| s02 | streams | 3★ | edges 5 < 8 |
| s03 | core | 1★ | deps 11 ≥ 10 |
| s04 | group-coordinator | 3★ | deps 5 |
| s05 | connect/runtime | 3★ | edges 6 < 8 |
| s06 | storage | 4★ | deps 3, edges 10, distinctiveness E1-only |
| s07 | metadata | 4★ | deps 3, distinctiveness E1-only |
| s08 | tools | 1★ | deps 12 ≥ 10 |
| s09 | raft | 4★ | deps 3, edges 9, distinctiveness E1-only |
| s10 | server | 1★ | deps 10 ≥ 10 |
| s11 | streams/integration-tests | 1★ | deps 12 ∧ PLM 0 (test-only) |
| s12 | server-common | 5★ | — (1 dep, 17 edges, ratio 0.45, loc 35932, PLM 825, 2 evidence incl. out-of-repo) |
| s13 | clients/clients-integration-tests | 1★ | deps 10 ∧ PLM 0 (test-only) |
| s14 | trogdor | 2★ | edges 2 |
| s15 | coordinator-common | 4★ | loc 18618 < 20000 |
| s16 | connect/api | 4★ | edges 9, ratio 0.38, loc 13861, distinctiveness E1-only |
| s17 | connect/mirror | 3★ | deps 5 ∧ edges 5 |
| s18 | jmh-benchmarks | 1★ | deps 16 ∧ ratio 0 (no tests) |
| s19 | generator | 1★ | edges 0 (build-time tool, nothing imports it) |
| s20 | share-coordinator | 4★ | deps 4, edges 8, loc 9915, distinctiveness E1-only |
| s21 | connect/transforms | 3★ | edges 5 < 8 |
| s22 | streams/test-utils | 2★ | edges 2 |
| s23 | streams/streams-scala | 2★ | edges 2 |
| s24 | api-checker | 1★ | edges 0 (build-time tool, nothing imports it) |
| s25 | test-common/test-common-runtime | 2★ | deps 7 |
| s26 | transaction-coordinator | 3★ | edges 7 < 8 |
| s27 | shell | 2★ | edges 4 |
| s28 | connect/json | 3★ | edges 5 < 8 |
| s29 | storage/api | 3★ | min of edges 5, ratio 0.13, loc 2224 (pure interface) |
| s30 | connect/mirror-client | 2★ | edges 2 |
| s31 | connect/file | 2★ | edges 2 |
| s32 | streams/examples | 2★ | edges 2 |
| s33–s53 | streams/upgrade-system-tests-22,23,27,26,31,32,33,34,35,36,37,38,39,40,41,42,43,28,25,30,24 | 1★ | PLM 0 (test-only); see family note below |
| s54 | group-coordinator/group-coordinator-api | 1★ | ratio 0 (no tests) |
| s55 | examples | 1★ | edges 1 ∧ ratio 0 |
| s56 | connect/test-plugins | 1★ | ratio 0 (no tests) |
| s57 | test-common/test-common-internal-api | 2★ | edges 2 ∧ loc 939 < 1000 |
| s58 | connect/basic-auth-extension | 2★ | edges 2 ∧ loc 881 < 1000 |
| s59 | test-common/test-common-util | 1★ | edges 1 ≤ 1 |
| s60 | tools/tools-api | 2★ | edges 2 ∧ loc 265 (pure interface) |
| s61–s64 | streams/upgrade-system-tests-10,11,20,21 | 1★ | PLM 0 (test-only); see family note below |
| s65 | streams/upgrade-system-tests-0110 | 1★ | PLM 0 ∧ loc 180 < 200 |
| s66 | mirror-coordinator | 1★ | ratio 0 ∧ loc 110, PLM 1 |

## Family note: streams/upgrade-system-tests-*

The 26 modules `streams/upgrade-system-tests-10,11,20,21,22,23,24,25,26,27,28,
30,31,32,33,34,35,36,37,38,39,40,41,42,43` and `-0110` are structurally
identical smoke-test suites that pin one Kafka Streams version each (0.11.0
through 4.3). All of them are test-only (PLM = 0), depend on exactly `streams`
and `clients`, and score 1★. Individual sizes range from 180 to 1385 lines;
per-module rows are in `matrix/matrix.csv`.

## Five-star cap

Two modules hold 5★ — `clients` and `server-common` — within the cap of three
per repository, so no module was demoted. Both combine a near-leaf position in
the dependency graph with the highest integration weight in the system and a
measured, tested, distinctive API.

## Verification

An independent machine check re-parsed this table, recomputed every signal
threshold from the recorded numbers, confirmed `star = min(S1..S5)` for all 66
modules, and cross-checked the distribution against the per-module records.
