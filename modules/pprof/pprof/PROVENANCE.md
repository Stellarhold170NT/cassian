# PROVENANCE — pprof

- upstream: https://github.com/google/pprof (branch main)
- upstream_sha: dbd0ed30aa888a30e21ba83b9831ac0e80d41022
- upstream_path: .
- extracted_at: 2026-11-02
- license: Apache-2.0 — full text at upstream repository root (LICENSE)
- measured: 2 files, 120 lines (census v9 .go-only over the item file list pprof.go + third_party/svgpan/svgpan.go at upstream_sha; the root path is never globbed recursively)
- assets: third_party/svgpan/svgpan.js and third_party/svgpan/LICENSE are included because svgpan.go embeds svgpan.js (go:embed); svgpan is vendored from aleofreddi/svgpan and its LICENSE is preserved at third_party/svgpan/LICENSE
- generator: goldmine v16 pprof p7_cut
- verification: byte-identical to upstream at upstream_sha (per-file md5sum comparison of the full file list)
- re-sync: compare upstream_sha with upstream HEAD via tracking/pprof.md
