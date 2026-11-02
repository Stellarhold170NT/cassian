# PROVENANCE — measurement

- upstream: https://github.com/google/pprof (branch main)
- upstream_sha: dbd0ed30aa888a30e21ba83b9831ac0e80d41022
- upstream_path: internal/measurement
- extracted_at: 2026-11-02
- license: Apache-2.0 — full text at upstream repository root (LICENSE)
- measured: 2 files, 416 lines (census v9 .go-only: find -name '*.go' -print0 | xargs -0 cat | wc -l at upstream_sha)
- generator: goldmine v16 pprof p7_cut
- verification: byte-identical to upstream at upstream_sha (per-file md5sum comparison of the full file list)
- re-sync: compare upstream_sha with upstream HEAD via tracking/pprof.md
