---
subject: google/mantis
measured_at: 1e15346c2ca2d6e7db57ced59615bb9d1685992f
status: plan
---

# GM-09b — EXTRACTION PLAN — SLOT B (google/mantis) — item s03 `mantis-calibrate`

- Subject: `google/mantis` · Upstream: `github.com/google/mantis` branch `main` · **PIN: `1e15346c2ca2d6e7db57ced59615bb9d1685992f`** (mọi số đo dưới đây gắn cây PIN này).
- INPUT cố định: `reports/mantis/gm-08-stars.md` (bảng 26/26 item, §1). Chuỗi: gm-08-stars → node này (slot B). `reports/mantis/gm-01-cartography.md:3-5` xác nhận upstream/branch/phương pháp clone.
- LẦN CHẠY: **1** — glob `reports/mantis/gm-09*` trước phiên = rỗng → KHÔNG có gì INHERITED, phát hành mới toàn bộ.
- Sandbox riêng `bitnami/git:latest` (ttl 7200, session `sess-5eef58f6`, VFS workspace `sess-2d4256df`): `sandbox_git_clone` trả `headCommit=1e15346c2ca2d6e7db57ced59615bb9d1685992f` = đúng PIN; `git ls-remote` lúc phiên chạy trả `1e15346c…` cho cả HEAD và `refs/heads/main` → **upstream FRESH, chưa trôi**.
- **GHI RÕ (bắt buộc theo brief): tài liệu này CHỈ LÀ PLAN** — không cắt, không ghi repo đích `cassian`. Việc cắt thật (P7 harvest) do lệnh riêng ngoài run thực hiện theo §4.

## 0. Phân slot — quy tắc xác định (deterministic)

Brief slot B: "Lấy item ≥4 sao ĐỨNG THỨ HAI (slot A lấy thứ nhất)". Thứ tự = thứ tự hàng trong bảng §1 của `gm-08-stars.md` (s01→s26, trùng thứ tự JSON block). Chuỗi 20 item ≥4★ theo thứ tự đó:

```
1st = s02 mantis-architecture (★4, score 16)   ← SLOT A
2nd = s03 mantis-calibrate    (★4, score 22)   ← SLOT B (item này)
3rd = s05 mantis-critic … tiếp đến s26 schema-contract (không thuộc slot nào)
```

Evidence lựa chọn:
- `File: reports/mantis/gm-08-stars.md | Dòng: 14 | Nội dung: "| s02 | w2 | mantis-architecture | ★4 | 4/5 · score=16 …"` — item ≥4★ thứ nhất.
- `File: reports/mantis/gm-08-stars.md | Dòng: 15 | Nội dung: "| s03 | w1 | mantis-calibrate | ★4 | 5/5 · score=22 · S1=5(raw 1) S2=3(fan 3+4) S3=5(T=3, 3.29/kLOC) S4=5(EV 2) S5=4(R 38/912) |"` — item ≥4★ thứ hai.
- Lưu ý chuỗi: tại thời điểm dispatch, **chưa thấy `gm-09a`** (glob rỗng) — slot B tự chốt theo đúng quy tắc brief ở trên; quy tắc này bảo đảm slot A (thứ nhất) và slot B (thứ hai) không bao giờ trùng item. "Quy trình GIỐNG slot A" không đối chiếu được vì report slot A chưa tồn tại — phiên này thiết lập quy trình theo brief; nếu gm-09a phát hành sau với cấu trúc khác, gate đối chiếu theo đúng luật A=1st/B=2nd.

## 1. Item được chọn — thẻ nhận diện

| Trường | Giá trị | Nguồn |
|---|---|---|
| id | s03 (= m03 trong gm-02) | gm-08-stars §1; gm-02 JSON |
| module | `mantis-calibrate` | gm-02 `:63-64` |
| sao / score | ★4 / 22 (S1=5 S2=3 S3=5 S4=5 S5=4) | gm-08-stars §1 dòng s03 |
| upstream path | `skills/mantis-calibrate` | gm-02 `:64` |
| Lớp rubric | MD (SKILL.md + references/*.md) | gm-07-rubric §1 |
| files / LOC | **2 files / 912 LOC** (666 + 246, đo lại trên PIN — khớp tuyệt đối gm-02 `loc=912`) | census phiên này |
| license | Apache-2.0 (`LICENSE` root repo) | `File: LICENSE | Dòng: 3-4 | Nội dung: "Apache License / Version 2.0, January 2004"` |
| kind | stage-skill (EV-C = 0 — 16 item cùng kind) | gm-07-rubric §5 |

Census đo lại trên PIN (công thức v9: từng extension rồi cộng — item chỉ có `.md`):
```
666  skills/mantis-calibrate/SKILL.md
246  skills/mantis-calibrate/references/calibration_rules.md
912 total
```
sha256 (dùng cho kiểm byte-identical sau khi cắt):
- `skills/mantis-calibrate/SKILL.md` → `c4eb14c114e308ed9f0147397be8b72cb2a5bb837177918e518d83f0c8c9e29b` (41,402 bytes)
- `skills/mantis-calibrate/references/calibration_rules.md` → `3cca579ac19e2b779531a28787369062342485165f4954643bc434e81c28a42b` (14,560 bytes)

## 2. Bằng chứng đã xác minh trên cây PIN (anti-bịa — trích nguyên văn)

- `File: skills/mantis-calibrate/SKILL.md | Dòng: 2-6 | Nội dung: "name: mantis-calibrate … Calculates the final risk score based on empirical evidence and architectural impact. … Don't use for discovering new vulnerabilities or writing patches."`
- `File: skills/mantis-calibrate/SKILL.md | Dòng: 25-30 | Nội dung: "- **Reads**: - `workspace/findings/*.json` … - `workspace/kb/THREAT_MODEL.md` … - `workspace/.mantis_state.json` … `active_snapshot` — `{snapshot_id, snapshot_pinned, root}` …"`
- `File: skills/mantis-calibrate/SKILL.md | Dòng: 32-41 | Nội dung: "- **Writes**: - Updates finding files in-place with scoring/calibration fields (`impact_score`, …, `mantis_risk_score`, `priority`, `sanity_triage_applied` …, `calibration_checklist` …, `outrage_commentary`, `executive_summary`). Appends a `history` entry … - Reusable helper script `workspace/helpers/append_calibrate.py`."`
- `File: skills/mantis-calibrate/SKILL.md | Dòng: 44-46 | Nội dung: "Running multiple times on the same inputs yields identical outputs, with no duplicated entries."` (idempotency — khớp gm-02 m03 `:44`)
- `File: skills/mantis-calibrate/SKILL.md | Dòng: 556-559 | Nội dung: "write a reusable helper script (e.g., `workspace/helpers/append_calibrate.py`) during your first finding update."`
- `File: skills/mantis-calibrate/SKILL.md | Dòng: 562-566 | Nội dung: "**Helper version marker (mandatory).** The very first line of `append_calibrate.py` MUST be the exact comment `# MANTIS_HELPER_VERSION = 2` … if the file is absent, OR the first line is not exactly `# MANTIS_HELPER_VERSION = 2` … **regenerate the helper from scratch**"`
- `File: skills/mantis-calibrate/references/calibration_rules.md | Dòng: 3-4 | Nội dung: "This document defines the 27 calibration sanity triage rules (caps and downgrades) used to calculate the final severity and priority of findings."`
- `File: skills/mantis-calibrate/references/calibration_rules.md | Dòng: 13 | Nội dung: "## Core Principle: Marginal Capability"`
- `File: skills/mantis-calibrate/references/calibration_rules.md | Dòng: 24 | Nội dung: "### Category A: Force-Downgrade to LOW (Cap at 2.0 / LOW Priority)"`
- `File: skills/mantis-calibrate/references/calibration_rules.md | Dòng: 36-42 | Nội dung: "absent under the pinned CODE_ROOT (see the STALE-EVIDENCE guard in `mantis-calibrate/SKILL.md`). … keep the higher score and mark `calibration_checklist.repro_failure.outcome = "UNKNOWN"` with a `STALE_EVIDENCE:` reason instead of force-LOW."`
- `File: skills/mantis-calibrate/references/calibration_rules.md | Dòng: 112 | Nội dung: "### Category B: Force-Cap to HIGH (Cap at 7.9 / Maximum HIGH Priority)"`
- `File: skills/mantis-calibrate/references/calibration_rules.md | Dòng: 188 | Nội dung: "### Category C: Force-Cap to MEDIUM (Cap at 5.9 / Maximum MEDIUM Priority)"`

Oracle chạy lại trên PIN (khớp số đã phát hành của s03 trong gm-08-stars):
- **S3 (T=3)**: `grep -rl 'mantis-calibrate' reference/tests reference/evals reference/test_suite.py` → đúng 3 file độc lập: `reference/evals/stage_agents.py`, `reference/tests/test_adk_invariants.py`, `reference/tests/test_research_graph_synthesis.py` (2 self-match trong item không tính — file test ĐỘC LẬP). Ratio = 3 × 1000 / 912 = 3.29 ≥ 2.0 → S3=5. ✓
- **EV-A (unique-token)**: item định nghĩa marker `# MANTIS_HELPER_VERSION = 2` (`SKILL.md:562-566`); token xuất hiện trong 7 file, 6 ngoài item (mantis-dedupe/SKILL.md:314, mantis-review/SKILL.md:44+366, mantis-patch, mantis-pipeline-adapter/SKILL.md + references/mantis-kb-query.md, mantis-structural-index/SKILL.md) → ≥2 consumer ngoài. ✓
- **EV-B (citation-density)**: `grep -rl 'mantis-calibrate' --exclude-dir=.git . | grep -v skills/mantis-calibrate | wc -l` = **10** file ngoài. ✓ (khớp "EV-B 10" trong justification s03)
- **REDACTION**: `grep -rn "ghp_" skills/mantis-calibrate` = 0 hit. ✓

## 3. PLAN BODY — nội dung cắt (tiếng Anh, sẵn sàng đặt vào `specs/mantis/mantis-calibrate.plan.md`)

> **Extraction plan — module `mantis-calibrate` (google/mantis @ `1e15346c2ca2d6e7db57ced59615bb9d1685992f`).**
>
> **What.** Harvest the upstream directory `skills/mantis-calibrate` (2 files: `SKILL.md`, `references/calibration_rules.md`; 912 LOC total) into the destination repo as `modules/mantis/mantis-calibrate/`, byte-identical to the PIN tree. Rationale: this is the findings-only final scoring stage that stamps a calibrated 1–10 `mantis_risk_score`/`priority` back into each finding in place, bounded by 27 sanity-triage rules — rated ★4 (score 22/25) by the repo star rubric; it also defines the cross-item helper contract marker `# MANTIS_HELPER_VERSION = 2` consumed by ≥2 skills outside the module.
>
> **File manifest (upstream → destination, 1:1, no renames).**
>
> | Upstream path (relative to repo root) | Destination path | Bytes | SHA-256 | LOC |
> |---|---|---|---|---|
> | `skills/mantis-calibrate/SKILL.md` | `modules/mantis/mantis-calibrate/SKILL.md` | 41,402 | `c4eb14c1…e29b` | 666 |
> | `skills/mantis-calibrate/references/calibration_rules.md` | `modules/mantis/mantis-calibrate/references/calibration_rules.md` | 14,560 | `3cca579a…a42b` | 246 |
>
> **Steps (executed by the separate cut command, not by this plan node).**
> 1. From a clone pinned at `1e15346c2ca2d6e7db57ced59615bb9d1685992f`, copy the module tree verbatim:
>    `mkdir -p modules/mantis/mantis-calibrate/references && cp skills/mantis-calibrate/SKILL.md modules/mantis/mantis-calibrate/SKILL.md && cp skills/mantis-calibrate/references/calibration_rules.md modules/mantis/mantis-calibrate/references/calibration_rules.md`
> 2. Add `modules/mantis/mantis-calibrate/PROVENANCE.md` with exactly these fields: `upstream: github.com/google/mantis`, `upstream_sha: 1e15346c2ca2d6e7db57ced59615bb9d1685992f`, `upstream_path: skills/mantis-calibrate`, `extracted_at: <UTC timestamp of the cut>`, `license: Apache-2.0`, `files: 2`, `loc: 912` (formula: per-extension `wc -l`, then sum), `generator: goldmine v16 mantis p7_cut`, `re-sync: see tracking/mantis.md`.
> 3. Add `modules/mantis/mantis-calibrate/README.md`: one short generated stub pointing back to upstream path + PIN. No other files may be added.
> 4. Commit on the publishing branch: `harvest: mantis mantis-calibrate @1e15346c2ca2d6e7db57ced59615bb9d1685992f`, author `cassian-mine <mine@cassian.local>`. No force push.
>
> **Hard invariants.** (a) Every harvested file is byte-identical to the PIN tree (`diff -r` clean; sha256 equal to the manifest above). (b) Census invariant: 2 files / 912 LOC before = after (PROVENANCE/README excluded from the count). (c) `grep -rn "ghp_"` over the harvested tree = 0. (d) Only `PROVENANCE.md` and `README.md` are added on top of upstream content.

## 4. Checklist nghiệm thu cho node cắt thật (pass/fail nhị phân)

| # | Kiểm tra | Ngưỡng PASS |
|---|---|---|
| 1 | `diff -r <PIN-tree>/skills/mantis-calibrate modules/mantis/mantis-calibrate` (loại PROVENANCE.md/README.md) | 0 khác biệt |
| 2 | sha256 từng file | khớp bảng §3 |
| 3 | Census | 2 files / 912 LOC (trước = sau) |
| 4 | `PROVENANCE.md` | đủ 9 trường §3 bước 2, `upstream_sha` = PIN |
| 5 | REDACTION | `grep -rn "ghp_"` trên cây cắt = 0 |
| 6 | Gate diff whitelist | chỉ thêm: `modules/mantis/mantis-calibrate/**` (gồm PROVENANCE/README); commit message đúng mẫu §3 bước 4 |
| 7 | Tracking | `git ls-remote` upstream main == PIN → ghi FRESH; khác → ghi "HEAD moved" (không resolve commit) |

## 5. Caveats

- **PLAN ONLY**: node này không chạy bước cắt, không push repo đích — mọi lệnh §3 dành cho node/lệnh P7 ngoài run.
- Upstream FRESH tại thời điểm lập plan (`git ls-remote` = PIN). Nếu node cắt chạy sau mà upstream đã trôi, vẫn cắt đúng **PIN** (không rebase lên HEAD mới); việc re-sync là quyết định riêng theo `tracking/mantis.md`.
- Đối tượng slot A (item ≥4★ thứ nhất = s02 `mantis-architecture`) nằm ngoài phạm vi node này — không đụng.
- Số `s5_substance_value` R=38 của s03 (gm-08-stars) không đo lại ở đây vì không cần thiết cho plan cắt; mọi số dùng cho cắt (files/LOC/sha256) đã đo lại trực tiếp trên PIN và khớp gm-02.
