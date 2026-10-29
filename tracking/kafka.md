![upstream](https://img.shields.io/badge/upstream-STALE-red)

| project | pinned_sha | head_now | state | last-check (UTC) |
|---|---|---|---|---|
| kafka | aa62a433553c14866521bd40ff446b6920d4d67e | 601492157a7e563b5cd4cdea8c9382302a1ea5f4 | STALE | 2026-10-28T23:35:39Z |

- Nguồn pin: cột `upstream_sha` của `matrix/matrix.csv` = cert gm-01 RUN 4 `aa62a433…` — commit "KAFKA-20866: Remove incremental-only append result state (#23749)" (File: reports/gm-01-cartography.md | Dòng: 348, workspace pipeline `workloop-ws`).
- Lệnh kiểm (quy trình gm-final mục 6, bước 2): `git ls-remote https://github.com/apache/kafka refs/heads/trunk` → `601492157a7e563b5cd4cdea8c9382302a1ea5f4` ≠ pin → **STALE**. FRESH nếu bằng pin; STALE nếu khác (không resolve commit, chỉ ls-remote — ghi "HEAD moved").
- Chính sách STALE (gm-final mục 6, bước 5): KHÔNG tự re-measure — đánh dấu và chờ orchestrator quyết định re-cert theo chu trình scan → worker → merge.
- Drift đã chứng minh trong pipeline: cert `aa62a433` → clone gm-04 `3655d7c` → clone gm-09b/ex_b `6014921` (~1 ngày, 3 sha) — java LOC +42 tại m01 chỉ vì 1 commit (File: reports/mm_scan--ef360255.md | Dòng: 111).

## Harvest (extracted modules)

- Pin: `aa62a433553c14866521bd40ff446b6920d4d67e` (upstream trunk at extraction time).
- 66 of 66 gradle modules extracted verbatim under `modules/kafka/` — 7,392 files,
  1,880,438 measured lines across whole module directories (build files included).
- Each module directory carries `PROVENANCE.md` (upstream sha, path, license,
  measured size, re-sync rule).
- Extracts are byte-identical to upstream at the pin; re-verify with
  `diff -r modules/kafka/<module> <upstream clone>/<module>`.
