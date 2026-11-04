---
subject: google/mantis
measured_at: 1e15346c2ca2d6e7db57ced59615bb9d1685992f
status: final
---


# Flows

## 1. Chọn TOP-3 luồng BẰNG SỐ

### 1a. Fan-in/fan-out suy ra từ JSON gm-02 (công thức khai báo)

gm-02 không có cột số fan-in/out — chỉ có chuỗi `deps_in` ("điều gì dùng module này") và `deps_out` ("module này phụ thuộc gì") trong JSON 26 entry. **Công thức khai báo (brief không định nghĩa):** với mỗi item X, `fan_in(X)` = số module-id KHÁC được nêu đích danh trong chuỗi `deps_in` của X (đó là những người dùng X); `fan_out(X)` = số module-id KHÁC nêu trong `deps_out` của X. Module-id là 26 id `m01..m26` của chính gm-02 (mention nội bộ item không đếm; tests là oracle S3 không đếm). Churn lấy từ bảng 1b (cùng cửa sổ 109 commit). **Điểm module = fan_in + fan_out + churn.**

| id | module | fan_in | fan_out | churn | score |
|---|---|---|---|---|---|
| m01 | mantis-advise | 2 (m20,m24) | 3 (m22,m20,m23) | 2 | 7 |
| m02 | mantis-architecture | 3 (m08,m20,m24) | 2 (m26,m11) | 2 | 7 |
| m03 | mantis-calibrate | 3 (m08,m05,m24) | 0 | 4 | 7 |
| m04 | mantis-chain | 4 (m08,m24,m20,m26) | 3 (m26,m15,m06) | 2 | 9 |
| m05 | mantis-critic | 8 (m08,m20,m21,m24,m14,m10,m19,m26) | 1 (m03) | 2 | 11 |
| m06 | mantis-dedupe | 6 (m08,m15,m13,m24,m20,m21) | 1 (m26) | 2 | 9 |
| m07 | mantis-history | 2 (m08,m24) | 0 | 2 | 4 |
| m08 | mantis-meta-agent | 2 (m24,m10) | 17 (m07,m17,m18,m02,m19,m11,m15,m06,m16,m05,m14,m04,m09,m03,m12,m13,m26) | 2 | 21 |
| m09 | mantis-patch | 5 (m08,m20,m14,m10,m24) | 1 (m14) | 4 | 10 |
| m10 | mantis-pipeline-adapter | 6 (m04,m16,m06,m08,m26,m24) | 2 (m26,m17) | 8 | 16 |
| m11 | mantis-plan | 6 (m08,m10,m02,m24,m17,m09) | 0 | 2 | 8 |
| m12 | mantis-reflect | 5 (m08,m20,m21,m24,m26) | 1 (m26) | 2 | 8 |
| m13 | mantis-report | 5 (m08,m20,m21,m10,m24) | 4 (m06,m05,m09,m14) | 2 | 11 |
| m14 | mantis-reproduce | 4 (m08,m09,m24,m20) | 2 (m26,m09) | 3 | 9 |
| m15 | mantis-researcher | 4 (m08,m10,m17,m24) | 4 (m06,m04,m13,m14) | 2 | 10 |
| m16 | mantis-review | 5 (m08,m20,m21,m10,m24) | 4 (m26,m05,m14,m03) | 2 | 11 |
| m17 | mantis-structural-index | 5 (m08,m24,m14,m10,m20) | 3 (m11,m15,m20) | 2 | 10 |
| m18 | mantis-summarize | 3 (m08,m11,m24) | 1 (m08) | 2 | 6 |
| m19 | mantis-threat-model | 2 (m08,m24) | 1 (m05) | 2 | 5 |
| m20 | reference-core | 4 (m24,m23,m21,m22) | 1 (m23) | 217 | 222 |
| m21 | reference-evals | 1 (m24) | 2 (m20,m23) | 122 | 125 |
| m22 | reference-scripts | 2 (m24,m01) | 2 (m20,m24) | 60 | 64 |
| m23 | reference-tools | 3 (m20,m21,m24) | 1 (m20) | 29 | 33 |
| m24 | reference-root | 1 (m25) | 3 (m20,m22,m23) | 327 | 331 |
| m25 | action | 0 | 1 (m22; `reference/requirements.txt` không thuộc item nào — repo-meta) | 4 | 5 |
| m26 | schema-contract | 5 (m10,m16,m04,m06,m13) | 0 | 1 | 6 |

### 1b. Churn (cửa sổ ≤109 commit — verbatim)

**Top-20 file** (`git log --format= --name-only | sort | uniq -c | sort -rn | head -20`, chạy trong sandbox tại PIN):

```
     43 reference/main.py
     27 reference/core/graph_loader.py
     23 reference/core/config.py
     16 reference/core/database.py
     15 reference/evals/research_eval.py
     15 reference/README.md
     14 reference/tools/research_tools.py
     13 reference/scripts/launch.py
     12 reference/tests/test_adk_invariants.py
     12 reference/core/prompts.py
     11 reference/scripts/neuter_matrix.py
     11 reference/core/context.py
     10 reference/tests/test_evolve.py
      9 reference/tools/sandbox_tools.py
      9 reference/tests/test_security_regression.py
      9 reference/core/budget.py
      8 reference/scripts/mcp_server.py
      8 reference/requirements.txt
      8 reference/evals/evolve/proposer.py
      8 reference/core/synthesizer.py
```

**Rollup theo 26 item gm-02** (map: `skills/mantis-*` + đường dẫn cũ không tiền tố `skills/` — skills sống ở root đến commit `f7cbeb3 "Move the skills into skills/"`; `reference/core|evals|scripts|tools` → m20/m21/m22/m23; `reference/*` còn lại + README gốc → m24; `action/` + `.github/workflows/mantis-pr-scan.yml` → m25; `schema.json` → m26; còn lại → repo-meta):

```
   327 m24 reference-root        (43 reference/main.py, 15 README, 8 requirements.txt, 6 test_suite.py, 6 docs/github-action.md, ...)
   217 m20 reference-core        (27 graph_loader.py, 23 config.py, 16 database.py, 12 prompts.py, 11 context.py, 9 budget.py, 8 synthesizer.py, ...)
   122 m21 reference-evals       (15 research_eval.py, 10 test_evolve.py nằm tests/ → repo-meta; 8 proposer.py, 7 stage_agents.py, 7 adapter.py, ...)
    60 m22 reference-scripts     (13 launch.py, 11 neuter_matrix.py, 8 mcp_server.py, ...)
    29 m23 reference-tools       (14 research_tools.py, 9 sandbox_tools.py, ...)
    16 repo-meta                 (.pre-commit-config 4, test_skills_integrity.py 4, workflows khác, LICENSE, ...)
     8 mantis-pipeline-adapter
     4 mantis-patch
     4 mantis-calibrate
     4 m25 action
     3 mantis-reproduce
     2 mỗi skill còn lại (m01,m02,m04,m05,m06,m07,m08,m11,m12,m13,m15,m16,m17,m18,m19 — 15 × 2 = 30)
     1 m26 schema-contract
```

Tổng touch-events = 825 (`git log --format= --name-only | grep -vc '^$'` = 825; kiểm cộng dồn: 327+217+122+60+29+16+8+4+4+4+3+30+1 = 825 ✓), 283 file unique.

### 1c. Bảng chấm 5 luồng ứng viên → TOP-3

**Công thức khai báo:** `Score(flow) = Σ (fan_in + fan_out + churn)` trên tập module PHÂN BIỆT mà các bước sequenceDiagram của luồng chạm tới (control hoặc data). Nền tảng runtime dùng chung mọi luồng in-harness = substrate `{m20 core, m23 tools, m24 root-runner}` = 222+33+331 = **586** — cộng một lần cho mỗi luồng đi qua harness.

| # | Luồng | Tập module (riêng) | Điểm | Hạng |
|---|---|---|---|---|
| A | **Campaign pass lifecycle** — meta-agent điều phối 16 stage skill qua harness ADK | {m08,m07,m17,m18,m02,m19,m11,m15,m06,m16,m05,m14,m04,m09,m03,m12,m13,m26} = 162 + substrate 586 | **748** | **1** |
| B | **Finding validation funnel** — vòng đời một finding từ researcher đến report | {m15,m06,m16,m05,m14,m04,m09,m03,m13,m26} = 93 + substrate 586 | **679** | **2** |
| C | **PR-scan CI flow** — GitHub Action → pr_scan.py → pipeline → check_change gate | {m25,m22} = 69 + substrate 586 | **655** | **3** |
| D | Operator launch (run.sh → launch.py → campaign bootstrap) | {m22} = 64 + 586 | 650 | 4 |
| E | Sandbox evidence (reproduce → run_sandbox_with_evidence → gate) | {m14,m09} = 19 + 586 | 605 | 5 |

**TOP-3 = A (748) > B (679) > C (655).** D/E chỉ lệch 5–50 điểm — liệt kê để reviewer đối chiếu; E thậm chí là sub-path của B (bước 7–9). Chú ý: churn dồn vào lớp harness (m24/m20/m21 chiếm 666/825 touch-events) còn fan-out dồn vào m08 (17) — luồng nào đi qua cả hai lớp thì đắt nhất, đúng trực giác "orchestration + harness" của A.

---

## 2. Flow A — Campaign pass lifecycle (score 748)

**Vì sao đắt (số):** đi qua module điểm cao nhất m08 (fan_out 17 — duy nhất fan ra toàn bộ stage skills), m26 (fan_in 5), và toàn bộ substrate churn-heavy (m24 327 + m20 217 touch-events; `reference/main.py` 43 lần — top-1 churn cả repo). Mỗi pass chạy lại trọn luồng này; 16 stage skill đều nhận cùng bộ `--snapshot_root/--snapshot_id/--state_root`.

Hai lớp điều phối cùng tồn tại: (i) **harness ADK** (`reference/main.py` + `reference/core/synthesizer.py` dựng graph) và (ii) **hợp đồng skill-method** (`skills/mantis-meta-agent/SKILL.md` Block C/D + Stage 0–15). Mỗi bước dưới đây thuộc một trong hai lớp, neo file:line riêng.

```mermaid
sequenceDiagram
    autonumber
    participant OP as Operator/CI
    participant L as scripts/launch.py
    participant M as reference/main.py
    participant R as ADK Runner
    participant MA as mantis-meta-agent (skill method)
    participant S as Stage skills m02-m19
    participant W as workspace state

    OP->>L: ./run.sh target — python3 main.py = cùng chương trình (main.py:3566-3574)
    L->>L: def main (launch.py:762); BudgetConfig CLI>workflow>default (launch.py:39,518-622)
    L->>M: pipeline() (main.py:1943)
    M->>M: load_workflow_from_json (main.py:2045; graph_loader.py:2510, WorkflowSpec:213)
    M->>R: Runner(app=run_app, session_service=_PatientSqliteSessionService) (main.py:2832)
    R->>M: _drive_campaign: async for event in runner.run_async (main.py:292-336)
    MA->>W: Block C SYNC opt-in, LIVE root, không đụng workspace (SKILL.md:155-215)
    MA->>W: Block D PIN snapshot + sentinel CODE_ROOT/.mantis_snapshot_id (SKILL.md:257-304, 88-92)
    MA->>S: Stage 0-15 + --snapshot_root/--snapshot_id/--state_root cho MỌI stage (SKILL.md:398-412, 421, 426, 452, 456)
    M->>S: graph nodes gắn skill: researcher_structural→reproducer (synthesizer.py:598-682; template:192-197)
    S->>W: Stage 14 report (SKILL.md:505-512) → Stage 15 archive + pass N+1 (SKILL.md:514-555)
```

**Map bước → file:line (đã đọc code thật trong sandbox tại PIN):**

| Bước | Layer | Bằng chứng |
|---|---|---|
| 1 | harness | `reference/main.py:3566` `if __name__ == "__main__":` → `:3571-3576` `from scripts.launch import main as _launch_main; sys.exit(_launch_main())`; comment "python3 main.py ... and ./run.sh ... are the same program" |
| 2 | harness | `reference/scripts/launch.py:762` `def main() -> int:`; `:39` `from core.budget import BudgetConfig, parse_duration_seconds, parse_token_budget`; `:518-622` resolve budget |
| 3 | harness | `reference/main.py:1943` `async def pipeline(` |
| 4 | harness | `reference/main.py:2045` `workflow, config = load_workflow_from_json(`; `reference/core/graph_loader.py:2510` def, `:94` AgentNode, `:213` WorkflowSpec |
| 5 | harness | `reference/main.py:2832` `runner = Runner(` |
| 6 | harness | `reference/main.py:292` `async def _drive_campaign(`; `:336` `async for event in runner.run_async(` |
| 7 | skill | `skills/mantis-meta-agent/SKILL.md:155` "1. **SYNC (must be the very first action of the pass; `--sync` only).**" trong Block C `:136-153` |
| 8 | skill | `skills/mantis-meta-agent/SKILL.md:257` "PIN SNAPSHOT (after SYNC, before any stage)"; `:299` sentinel; `:88-92` `<state_root>/.mantis_snapshots/` + `CODE_ROOT/.mantis_snapshot_id` |
| 9 | skill | `skills/mantis-meta-agent/SKILL.md:398-412` snapshot argument passing ALL stages; `:421` Stage 0, `:426` Stage 0.5, `:452` Stage 4, `:456` Stage 5 |
| 10 | harness | `reference/core/synthesizer.py:598,610,631,645,652,658,666,674,680` (researcher_structural→…→reproducer); `:192-197`, `:219-225` template nodes |
| 11 | skill | `skills/mantis-meta-agent/SKILL.md:505-512` Stage 14; `:514` Stage 15 archive & increment |

---

## 3. Flow B — Finding validation funnel (score 679)

**Vì sao đắt (số):** đi qua 9/19 skill (m15,m06,m16,m05,m14,m04,m09,m03,m13 — tổng fan_in 44) + m26 (mọi bước đọc/ghi field `signature`/`lineage_id`/`reattack_status`/`mantis_risk_score` đều ràng buộc schema) + substrate. Số bước lớn nhất trong mọi luồng; mỗi finding đi trọn chuỗi này, reproduce có trần 6 lần thử (SKILL.md:368) và patch còn tái gọi reproduce (`--reattack`) — chuỗi có chu kỳ.

```mermaid
sequenceDiagram
    autonumber
    participant P as plan.json
    participant RE as researcher m15
    participant DB as core.database
    participant DE as dedupe m06
    participant RV as reviewer m16
    participant CR as critic m05
    participant RP as reproducer m14
    participant CH as chain m04
    participant PA as patcher m09
    participant CA as calibrator m03
    participant RT as reporter m13

    P->>RE: roadmap; thiếu plan thì sweep (SKILL.md:41)
    RE->>DB: signature/lineage 16-hex (SKILL.md:270-298) rồi report_findings → write_findings (research_tools.py:593; database.py:881); findings/<uuid>.json (SKILL.md:51-52)
    DB->>DE: graph order threat_model:645 → dedupe:652 (synthesizer.py); pairwise match + 3-tier ladder (SKILL.md:160-186, 247-291)
    DE->>RV: survivor MATCHED/NOT_MATCHED (synthesizer.py:658 reviewer)
    RV->>RV: "Assume every finding is a false positive" + 13 rules; drift → NEEDS_RESEARCH (SKILL.md:63, 170-173)
    RV->>CR: VALID set (synthesizer.py:666 critic; review_decision routes :674)
    CR->>RP: VIABLE findings; drift → CONDITIONAL_VIABLE không NON_VIABLE (SKILL.md:141, 209, 231)
    RP->>RP: REACHED-SINK EVIDENCE GATE — sidecar MANTIS_REACHED_ENTRYPOINT hoặc backtrace (SKILL.md:499-509); trần 6 lần (SKILL.md:368)
    RP->>CH: validated + KB → super-finding, signature = sha256("chain|"+sorted)[:16] (SKILL.md:196, 295)
    CH->>PA: patch Option A shadow BẮT BUỘC khi PINNED (SKILL.md:308-314, 339); tái gọi --reattack (reproduce SKILL.md:19-26, 57-63)
    PA->>CA: patch verdicts → mantis_risk_score, 27 sanity rules (SKILL.md:35; references/calibration_rules.md:3)
    CA->>RT: scored findings → review_packet_pass_N (SKILL.md:38-41)
```

**Map bước → file:line:**

| Bước | Bằng chứng |
|---|---|
| 1 | `skills/mantis-researcher/SKILL.md:41` "`workspace/plan.json` (falls back to codebase sweep if missing/empty)"; graph node `researcher_structural:598`, `researcher_domain:610`, `researcher:631` trong `reference/core/synthesizer.py` |
| 2 | `skills/mantis-researcher/SKILL.md:270` "For each finding, compute `signature`, `lineage_id`..."; `:277` "**Compute `signature` (deterministic content-identity hash):**"; `:298` "`signature` = first 16 hex characters"; `:51-52` "Raw finding files to `workspace/findings/<uuid>.json`"; `reference/tools/research_tools.py:593` `def report_findings(report: VulnerabilityReport)`; `reference/core/database.py:881` `def write_findings(...)` |
| 3 | `reference/core/synthesizer.py:645,652` threat_model → dedupe; `skills/mantis-dedupe/SKILL.md:160` "PAIRWISE SNAPSHOT MATCH CHECK"; `:175` "There is no other route to MATCHED; never fuzzy-compare"; `:247` "3-Tier Deduplication Ladder"; `:314` `# MANTIS_HELPER_VERSION = 2` |
| 4 | `reference/core/synthesizer.py:658` reviewer node |
| 5 | `skills/mantis-review/SKILL.md:63` "**Assume every finding is a false positive by default.**"; `:170-173` drift → `NEEDS_RESEARCH`; `:44` helper `MANTIS_HELPER_VERSION = 2` |
| 6 | `reference/core/synthesizer.py:666` critic, `:674` review_decision classifier; `skills/mantis-critic/SKILL.md:141` "CONDITIONAL_VIABLE, never NON_VIABLE (which calibrate drops)"; `:209` "There is no other route to MATCHED" |
| 7 | `reference/core/synthesizer.py:680` reproducer; `skills/mantis-critic/SKILL.md:231` drift → CONDITIONAL_VIABLE |
| 8 | `skills/mantis-reproduce/SKILL.md:499` "REACHED-SINK EVIDENCE GATE (mechanical):"; `:501` sidecar `MANTIS_REACHED_ENTRYPOINT`; `:504` backtrace channel; `:368` "hard ceiling of 6" |
| 9 | `skills/mantis-chain/SKILL.md:196` "minimum-eligibility guard"; `:295` "`sha256("chain|" + "|".join(sorted_constituent_signatures))`" |
| 10 | `skills/mantis-patch/SKILL.md:308-314` "PINNED mode → **Option A ... MANDATORY**"; `:339` "Option A: Temporary Directory Shadowing"; `skills/mantis-reproduce/SKILL.md:19-26` `--reattack` mode; `:57-63` reattack fields + cấm `VERIFIED_SECURE` khi `reattack_status` không `failed_to_bypass` |
| 11 | `skills/mantis-calibrate/SKILL.md:35` scoring fields; `skills/mantis-calibrate/references/calibration_rules.md:3` "27 calibration sanity triage rules" |
| 12 | `skills/mantis-report/SKILL.md:38-41` `review_packet_pass_<N>_<snapshot_tag>.md` + `review_packet-latest.md` |

Glue in-harness cho eval/fixed-stage: `reference/evals/stage_agents.py:29` `STAGE_OUTPUT_SCHEMAS`, `:36` `STAGE_CONFIGS`, `:50-57` researcher config (tool list production), `:122` fallback `{'skill': f'mantis-{stage_name}', ...}`.

---

## 4. Flow C — PR-scan CI flow (score 655)

**Vì sao đắt (số):** entry duy nhất từ CI (m25 → m22). m22 churn 60 (launch.py 13, mcp_server.py 8 — và `check_change` là hàm deterministic được 2 node gọi); điểm thấp hơn A/B vì chỉ thêm 2 module riêng trên substrate, nhưng là luồng duy nhất có gate nhị phân BLOCK/REVIEW/PASS để chặn merge.

```mermaid
sequenceDiagram
    autonumber
    participant GH as GitHub PR
    participant WF as mantis-pr-scan.yml
    participant AC as action/ (composite)
    participant PS as scripts/pr_scan.py
    participant MS as scripts/mcp_server.py
    participant MP as reference/main.py (subprocess)
    participant GA as check_change gate

    GH->>WF: pull_request event (.github/workflows/mantis-pr-scan.yml:7)
    WF->>WF: gate cùng-repo/không-draft (mantis-pr-scan.yml:37-38)
    WF->>AC: uses: ./action (mantis-pr-scan.yml:63)
    AC->>AC: Move the credential out of the checkout (action.yml:148-155)
    AC->>PS: python pr_scan.py --repo --base --fail-on ... (action.yml:186-211)
    PS->>PS: def main (pr_scan.py:1585); argparse --repo/--base/--max-* (pr_scan.py:1496-1506)
    PS->>MS: select_scan_files (pr_scan.py:551); pre check_change (pr_scan.py:692)
    PS->>MS: scan_command (pr_scan.py:762) → _scan_cmd (mcp_server.py:777)
    MS->>MP: subprocess [python, reference/main.py, file, --db, --yes, --path-root, --sandbox static-only] (pr_scan.py:246-259 stripped env; :771-772)
    MP->>GA: pipeline chạy đúng lõi Flow A (main.py:3566→1943); xong: check_change BLOCK/REVIEW/PASS (mcp_server.py:523-536; pr_scan.py:1068; VERDICT_* :78-81)
```

**Map bước → file:line:**

| Bước | Bằng chứng |
|---|---|
| 1 | `.github/workflows/mantis-pr-scan.yml:7` `pull_request:` |
| 2 | `.github/workflows/mantis-pr-scan.yml:37-38` `github.event.pull_request.head.repo.full_name == github.repository && !github.event.pull_request.draft` |
| 3 | `.github/workflows/mantis-pr-scan.yml:63` `- uses: ./action` |
| 4 | `action/action.yml:148` "- name: Move the credential out of the checkout"; `:155` `dest="$RUNNER_TEMP/mantis-credentials.json"` |
| 5 | `action/action.yml:186-211` scan step; `:211` `python "$GITHUB_ACTION_PATH/../reference/scripts/pr_scan.py" "${args[@]}"` |
| 6 | `reference/scripts/pr_scan.py:1585` `def main(argv...`; `:1496-1506` argparse `--repo/--base/--head/--model/--models/--api-base` |
| 7 | `reference/scripts/pr_scan.py:551` `def select_scan_files(`; `:692` `pre = check_change(state, files=list(changed), diff=diff)` |
| 8 | `reference/scripts/pr_scan.py:762` `def scan_command(...)` "scan_change's exact invocation plus the CI pins. Pure, for tests."; `reference/scripts/mcp_server.py:777` `def _scan_cmd(...)` |
| 9 | `reference/scripts/pr_scan.py:246` `def subprocess_env` (strips `_STRIPPED_ENV`), `:259` `subprocess.run(`; `mcp_server.py:779-784` `[sys.executable, str(_REF_ROOT/"main.py"), target, "--db", ..., "--path-root", ...]`; `pr_scan.py:771-772` `cmd += ["--sandbox", "static-only"]`; vào `reference/main.py:3566` → `:1943` pipeline (lõi Flow A) |
| 10 | `reference/scripts/mcp_server.py:523` `def check_change(...)`; `:526-536` docstring "BLOCK — an open HIGH/CRITICAL finding intersects the change. REVIEW — ... fail-closed. PASS — ..."; gọi tại `pr_scan.py:1068`; `pr_scan.py:78-81` import `BLOCKING_SEVERITIES, VERDICT_BLOCK, VERDICT_PASS, VERDICT_REVIEW` |

---

## 5. JSON đầu ra cho node sau

```json
{
  "subject": "mantis",
  "pin": "1e15346c2ca2d6e7db57ced59615bb9d1685992f",
  "method": "fan_in/fan_out counted from gm-02 deps strings; churn window <=109 commits (shallow clone)",
  "score_formula": "sum(fan_in+fan_out+churn) over distinct modules touched by the flow's steps; substrate {m20,m23,m24}=586 added once per in-harness flow",
  "top3": [
    {"rank": 1, "flow": "campaign_pass_lifecycle", "score": 748, "modules": ["m08","m07","m17","m18","m02","m19","m11","m15","m06","m16","m05","m14","m04","m09","m03","m12","m13","m26","m20","m23","m24"], "diagram_steps": 11},
    {"rank": 2, "flow": "finding_validation_funnel", "score": 679, "modules": ["m15","m06","m16","m05","m14","m04","m09","m03","m13","m26","m20","m23","m24"], "diagram_steps": 12},
    {"rank": 3, "flow": "pr_scan_ci", "score": 655, "modules": ["m25","m22","m20","m23","m24"], "diagram_steps": 10}
  ],
  "runners_up": [
    {"flow": "operator_launch", "score": 650},
    {"flow": "sandbox_evidence", "score": 605}
  ],
  "churn_top_files": {"reference/main.py": 43, "reference/core/graph_loader.py": 27, "reference/core/config.py": 23, "reference/core/database.py": 16, "reference/evals/research_eval.py": 15},
  "limitations": ["churn window <=109 commits", "fan_in/out derived from prose deps strings of gm-02, not a machine-readable edge list", "line numbers valid at PIN; upstream moves will shift them"]
}
```

## 6. Hạn chế đã kê

1. Cửa sổ churn ≤109 commit (shallow clone) — khai báo ở đầu tài liệu; churn tuyệt đối sẽ tăng khi mở rộng lịch sử, thứ hạng tương đối giữa 5 luồng khó đảo vì substrate (666/825 touch-events) đúng trong mọi cửa sổ gần.
2. fan_in/fan_out suy từ chuỗi deps prose của gm-02 theo phương pháp đã khai báo (mục 1a) — không phải edge-list máy đọc; ai chấm lại theo cách đếm khác (vd. tính cả tests) sẽ ra số khác nhưng thứ hạng top-3 giữ nguyên vì khoảng cách A–B là 69 điểm và B–C là 24 điểm đều do chênh lệch fan/ churn lớn hơn sai số đếm ±2 mention.
3. Line numbers đúng tại PIN `1e15346c`; upstream tiến sẽ dịch dòng.
