---
subject: google/mantis
measured_at: 1e15346c2ca2d6e7db57ced59615bb9d1685992f
status: final
---


# Usage

## 1. Bảng tổng hợp 8 item — module | dùng khi nào | deps_out (theo gm-02, nguyên văn qua u-checklist)

Thứ tự = thứ tự `u-checklist.json` (sao giảm dần: 5★ trước, rồi 4★; trong băng theo score gm-08 giảm dần, hòa thì s_id tăng dần).

| s_id | module | sao/score | files/LOC | dùng khi nào (when to use) | deps_out (nguyên văn gm-02 / u-checklist) |
|---|---|---|---|---|---|
| s14 | mantis-reproduce | 5★ / 21 | 1 md / 828 | Orchestrator Stage 9 + the patcher's verify loop: design & execute crash reproducers/PoCs inside isolated sandboxes; every verdict gated on mechanical reached-sink evidence; `--reattack` mode is the independent verifier of patches (INV-1) — invoked `@mantis-reproduce` per `skills/mantis-meta-agent/SKILL.md:469,477-481` | schema.json: top-level `repro_attempts` property (:22-24) + `$defs/repro_attempts` (:1014), finding `reattack_status` (:156), `reattack_variants` >=3 for failed_to_bypass (:175), reattack/patch_base_snapshot provenance (:259); workspace state: `workspace/findings/` in-place updates, `workspace/reproducers/`, `workspace/archive/.repro_attempts.json` (+.lock, .tmp swap); sandbox/container runtime harness-provided: `run_sandbox_with_evidence` tool (reference/core/synthesizer.py:221); INV-1 downgrade contract with mantis-patch (atomic VERIFIED_SECURE → VERIFICATION_FAILED, SKILL.md:63,:463) |
| s26 | schema-contract | 5★ / 21 | 1 file / 1,058 | Contract root for harness builders and all 19 skills: validate every inter-stage state file (`finding`/`plan`/`learning_entry`/`state`/`tx_log_entry`/`repro_attempts`/`execution_log_entry`) against the draft-2020-12 schema; its description also carries the non-JSON contracts (Threat Model rules, harness-agnostic Pass Lifecycle, 6-tier SNAPSHOT_ID ladder, global backward-compat safe-branch) — `schema.json:2-4` | none across the item boundary - schema.json is the contract root; every consumer references it, it references nothing outside itself (gm-02 m26 deps_out) |
| s21 | reference-evals | 5★ / 20 | 49 files / 8,111 | Cheapest-first falsification of pipeline changes (`reference/evals/README.md:3-20`): Tier-1 zero-LLM surveyor ranking benchmark (juice-shop ground truth), Tier-2 researcher campaign eval over the seeded never-executed corpus (`--toolset structural`), fixed-dataset single-stage benchmarks (`run_eval.py --stage dedupe\|review\|critic\|calibrate`), paired resumable sweeps, Harness² evolve loop | reference/core (m20) imported from 9 files: sweep.py:394 core.config.is_auth_error; run_eval.py:27-28 core.context + core.database; research_eval.py:445,513,755,769,840-841,889,941,1071 (core.graph_loader, core.transcript, core.harness_context.assert_no_grader_verdicts, tools.TOOLS, core.database, core.structural_index.build_structural_index); stage_agents.py:23-27,136,165,188; surveyor_benchmark.py:219 core.surveyor._group_key; deduplicator_agent/agent.py:21,24; evolve/surface.py:63,153,285,329; evolve/adapter.py:234,472,595,632; evolve/proposer.py:126,415 — reference/tools (m23): from tools import TOOLS (stage_agents.py:27, research_eval.py:769, deduplicator_agent/agent.py:24, evolve/surface.py:285) — external: google.adk (run_eval.py:31, stage_agents.py:20-22) — intra-boundary: from evals.stage_agents import build_stage_agent (run_eval.py:29); datasets are the item's own *.json files |
| s03 | mantis-calibrate | 4★ / 22 | 2 md / 912 | Orchestrator Stage 12 final scoring: load every processed finding, read `workspace/kb/THREAT_MODEL.md` for boundary overrides + asset criticality, stamp calibrated 1–10 `mantis_risk_score`/`priority` + sanity-triage bookkeeping, bounded by the 27-rule catalogue; idempotent re-runs — `@mantis-calibrate` per `skills/mantis-meta-agent/SKILL.md:483` | workspace state only: `workspace/findings/*.json` updated in place + per-pass history entry with snapshot provenance (SKILL.md:33-41); `workspace/kb/THREAT_MODEL.md` (boundary overrides); `workspace/.mantis_state.json` (active_snapshot); reusable helper `workspace/helpers/append_calibrate.py` (:41, written at :556-559); no reference/ script and no ${MANTIS_HOME} command (0 grep matches - pure agent-procedure skill) |
| s06 | mantis-dedupe | 4★ / 22 | 1 md / 371 | Orchestrator Stage 6 consolidator: cluster raw findings; hard-trash a duplicate ONLY on the pairwise byte-for-byte `discovery_commit` snapshot MATCH; keep NOT_MATCHED pairs active with soft `possible_duplicate_of` (possible-regression guard); 3-Tier dedup ladder (sha256 → RCA → vector); versioned merge helper + tx log — `@mantis-dedupe` per `skills/mantis-meta-agent/SKILL.md:460-461` | schema.json finding contracts: `duplicate_of` (schema.json:108), `possible_duplicate_of` (:265-267), `signature` (:273-275), `lineage_id` (:279); workspace state: `workspace/findings/` (+.trash/), `workspace/archive/findings_pass_*/` + legacy loop*_findings/, `workspace/.mantis_state.json` (active_snapshot, pass_number), `workspace/.tx_log.jsonl`, `workspace/helpers/merge_findings.py`; embedding engine config vertex_ai/gemini-embedding-001 + EMBEDDING_SIMILARITY_THRESHOLD (harness-provided, SKILL.md:268-291); zero reference/-script references - pure agent-procedure skill |
| s16 | mantis-review | 4★ / 21 | 1 md / 437 | Orchestrator Stage 7 adversarial validator: re-read each finding's `code_paths` under the pinned CODE_ROOT; stance "Assume every finding is a false positive by default"; 13 negative rules → `triage_checklist`; finalize VALID / FALSE_POSITIVE / PROVISIONALLY_VALID / NEEDS_RESEARCH; idempotent re-review keyed `(pass_number, snapshot)` — `@mantis-review` per `skills/mantis-meta-agent/SKILL.md:463-464` | schema.json triage/state validation rules cited by line (SKILL.md:183,:325,:338,:348); workspace state: `workspace/findings/` in-place updates (status/reasoning/repro_hints/triage_checklist/history :35-38), `workspace/helpers/append_review.py` (:38,:358-379), `workspace/.mantis_state.json` (:27-29); target source reads under resolved CODE_ROOT (pinned snapshot :32-34,:116-122); output statuses consumed downstream by @mantis-critic / @mantis-reproduce / @mantis-calibrate (meta-agent Stages 8-12); no reference/*.py invocation |
| s09 | mantis-patch | 4★ / 20 | 2 md / 823 | Orchestrator Stage 11 fix stage: minimal patches under transactional isolation (PINNED → Option A shadow MANDATORY, Option B FORBIDDEN); Block F reached-sink + Block G unpatched-baseline/compile/benign gates; `VERIFIED_SECURE` only after a fresh `@mantis-reproduce --reattack` fails to bypass with ≥3 variants; 3-way patch rebasing onto newer snapshots — `@mantis-patch` per `skills/mantis-meta-agent/SKILL.md:477-481` | `@mantis-reproduce --reattack --target_root=<PATCHED_SHADOW_ROOT> --snapshot_pinned=false --state_root=<state_root> --finding_id=...` sub-agent invocation (SKILL.md:628-651); findings JSON fields: patch_status, patch_base_snapshot, patch_diff, reattack_status/_file_path/_run_command/_output/_variants, history (:745-771); workspace layout: `workspace/helpers/append_patch.py` (:58,:733-743), `workspace/reproducers/` + `workspace/helpers/` preserved on rollback (:714-718), `workspace/findings/.trash/<uuid>.json` + archive duplicate search (:229-235), `<state_root>/.mantis_snapshots/` prior-pass snapshot for rebasing (:445-448), `workspace/.mantis_state.json` changed_files (:469-471), `workspace/.workspace_edit.lock` (:411-417); reference doc references/patch_rebasing.md (load-trigger :3-10); no direct reference/*.py invocation |
| s19 | mantis-threat-model | 4★ / 20 | 1 md / 251 | Orchestrator Stage 3 KB generator: synthesize trust boundaries / attack surfaces / attacker profiles from `workspace/kb/architecture.md` + `workspace/kb/entities/*.md` into the living `workspace/kb/THREAT_MODEL.md` (first line `KB_SNAPSHOT:` provenance); archives the prior model per pass; verbatim STALE banner consumed by `mantis-critic`'s freshness check; findings-only, never reads target source — `@mantis-threat-model` per `skills/mantis-meta-agent/SKILL.md:449` | workspace state: `workspace/kb/THREAT_MODEL.md` (the living deliverable, state-relative :46-55; first line is a KB_SNAPSHOT: provenance line :47); `workspace/kb/architecture.md` + `workspace/kb/entities/*.md` (KB inputs produced by upstream KB stages); `workspace/.mantis_state.json` (pass_number, active_snapshot provenance :36-39); pass archive `workspace/archive/kb/THREAT_MODEL_pass_${N}.md` (:50); downstream mantis-critic freshness check (:242); never reads target source (:31-33); no reference/ script, no ${MANTIS_HOME} command |

---

## 2. Chi tiết từng item (section sâu — joinPolicy ALL, nguyên văn 2 worker)

### s14 · mantis-reproduce — `skills/mantis-reproduce/SKILL.md` (1 md / 828 LOC)

*(nguồn: gm-12-usage-w1.md, nguyên văn)*

#### (a) What problem this item solves

`/mantis-reproduce` is the integration-test stage of a Mantis campaign: it designs and executes crash reproducers/PoCs inside isolated sandboxes and refuses to believe itself — every verdict is gated on mechanical reached-sink evidence (a sidecar file containing `MANTIS_REACHED_ENTRYPOINT` written in-path, or a target-produced crash backtrace/ASan/UBSan frame naming the sink — `skills/mantis-reproduce/SKILL.md:499-509`). Attempt accounting is snapshot-aware with a hard ceiling of 6 full sandboxed runs per finding (`:368`), and in `--reattack` mode it is the independent verifier of `mantis-patch`'s fixes: mandatory variant hunting (N ≥ 3 boundary-mutated inputs, `:373-376`) against the patched shadow, with the honesty anchor that evidence must come from the UNPATCHED baseline (`:520-521`) and a negative verdict is never fabricated (`:525`).

#### (b) Use case 1 — reproduce a validated finding with snapshot-aware attempt accounting

Scenario: Stage 9 of the campaign; finding `3f9d2a1e…` passed review. The orchestrator calls the skill with the documented flags; the reproducer writes `poc_<uuid>.py` under `workspace/reproducers/`, stamps `repro_status`/`repro_file_path`/`run_command`/`repro_output` into the finding in place, and updates the atomic attempt cache `{count,last_snapshot}` so the cap resets when the snapshot changes. A build failure or `exit 127` is EVIDENCE ABSENT → `repro_status = not_attempted` (retry-eligible), never a false "not reproducible".

```bash
# Orchestrator Stage 9 (verified: skills/mantis-meta-agent/SKILL.md:469)
@mantis-reproduce --snapshot_root=/srv/snapshots/sha-1e15346 \
                  --snapshot_id=1e15346c2ca2d6e7db57ced59615bb9d1685992f \
                  --state_root=/srv/mantis-state
# Full command surface (SKILL.md:19): /mantis-reproduce [--reattack]
#   [--finding_id=<uuid>] [--force] [--target_root=<path>] [--state_root=<path>]
#   [--snapshot_root=<path>] [--snapshot_id=<SNAPSHOT_ID>] [--snapshot_pinned=<true|false>]

# Outputs (SKILL.md:51-56): PoC files land in workspace/reproducers/;
# findings updated in place with repro_status/repro_file_path/run_command/repro_output.
ls /srv/mantis-state/workspace/reproducers/
# poc_3f9d2a1e-8c41-4b6e-9d2f-a1b2c3d4e5f6.py

jq '{repro_status, repro_file_path, run_command}' \
   /srv/mantis-state/workspace/findings/3f9d2a1e-8c41-4b6e-9d2f-a1b2c3d4e5f6.json
# { "repro_status": "reproduced", "repro_file_path": ".../poc_....py",
#   "run_command": "python3 poc_...py" }

# Attempt cache is snapshot-aware (SKILL.md:64-66, :594-595):
jq '.' /srv/mantis-state/workspace/archive/.repro_attempts.json
# { "stable-key-3f9d2a1e": { "count": 2, "last_snapshot": "1e15346c...5992f" } }

# A build failure / exit 127 is EVIDENCE ABSENT (SKILL.md:516) ->
# repro_status = not_attempted (retry-eligible), NEVER a negative verdict (SKILL.md:525).
```

Evidence (grep-verified on PIN clone): `skills/mantis-meta-agent/SKILL.md:469` ("Stage 9 (Reproduce): Call the `@mantis-reproduce` subagent"); `skills/mantis-reproduce/SKILL.md:19` (command surface), `:51-56` (writes PoC files + `repro_status`/`repro_file_path`/`run_command`/`repro_output`), `:64-66` (`.repro_attempts.json` updated atomically, values `{count,last_snapshot}`), `:74-78` (`.repro_attempts.lock` + `os.replace` on `.tmp`; "refuses to emit a negative verdict without reached-sink evidence"), `:516` ("EVIDENCE ABSENT includes: any compiler/build nonzero exit; exit 127 …"), `:525` ("NEVER synthesize the marker"), `:594-595` (snapshot-aware cap shape `{count, last_snapshot}`); `schema.json:1014-1033` (`$defs/repro_attempts`: bare integer legacy form OR `{count,last_snapshot}` object, read rule for consumers).

#### (b) Use case 2 — reattack-verify a patch (INV-1): variants on the shadow, evidence on the baseline

Scenario: the patcher (Stage 11) has applied a fix on a patched shadow copy. It must spawn a FRESH `@mantis-reproduce --reattack` (the orchestrator is explicitly instructed to make the patcher "repeatedly call a fresh `@mantis-reproduce` subagent against its patches"). Eligibility is enforced first (`status` VALID/PROVISIONALLY_VALID, `repro_status=reproduced`, `patch_status` not `MITIGATION_PROPOSED`; `VERIFIED_SECURE` allowed because C5 downgrades it). The reproducer hunts ≥ 3 boundary-mutated variants against the sentinel-exempt shadow; a bypass (`reattack_status=bypassed_patch`) atomically downgrades `patch_status` to `VERIFICATION_FAILED` in the same write.

```bash
# Orchestrator Stage 11 instruction (verified: skills/mantis-meta-agent/SKILL.md:477-481)
# Patcher spawns the independent verifier on the patched shadow:
@mantis-reproduce --reattack \
  --finding_id=3f9d2a1e-8c41-4b6e-9d2f-a1b2c3d4e5f6 \
  --target_root=/srv/mantis-state/workspace/.patch_shadows/3f9d2a1e/patched \
  --snapshot_pinned=false \
  --state_root=/srv/mantis-state
# --target_root is AUTHORITATIVE and the sentinel check is skipped for it (SKILL.md:30-35);
# --snapshot_pinned=false marks the deliberately-mutated shadow (SKILL.md:39-42).

# Eligibility gate before the run (SKILL.md:172-177):
jq '{status, repro_status, patch_status}' \
  /srv/mantis-state/workspace/findings/3f9d2a1e-8c41-4b6e-9d2f-a1b2c3d4e5f6.json
# { "status": "VALID", "repro_status": "reproduced", "patch_status": "VERIFIED_SECURE" }

# Variant hunting is MANDATORY in reattack mode: N >= 3 mutated inputs (SKILL.md:373-376).
# Outcome schema (schema.json:173-175): reattack_variants "Must be non-empty (>= 3
# entries) for reattack_status = failed_to_bypass".

# Bypass -> atomic INV-1 downgrade in the same write (SKILL.md:690-695, :718):
jq '{reattack_status, reattack_variants: (.reattack_variants|length), patch_status}' \
  /srv/mantis-state/workspace/findings/3f9d2a1e-8c41-4b6e-9d2f-a1b2c3d4e5f6.json
# { "reattack_status": "bypassed_patch", "reattack_variants": 1,
#   "patch_status": "VERIFICATION_FAILED" }
```

Evidence: `skills/mantis-meta-agent/SKILL.md:477-481` ("Instruct it to repeatedly call a fresh `@mantis-reproduce` subagent against its patches"); `skills/mantis-reproduce/SKILL.md:30-35` (`--target_root` AUTHORITATIVE, sentinel check skipped), `:39-42` (`--snapshot_pinned=false` semantics for patched shadows), `:172-177` (expected patch workflow state incl. "`VERIFIED_SECURE` IS allowed: C5 below atomically downgrades it"), `:373-376` ("you MUST author and execute **N ≥ 3 boundary-mutated variant inputs** … merely re-running the original PoC is insufficient"), `:57-66` (reattack writes `reattack_*` fields, does not modify `repro_*`/`status`), `:690-695` (`reattack_status` enum `bypassed_patch`/`failed_to_bypass`; bypass ⇒ `patch_status = "VERIFICATION_FAILED"` in the same write), `:718` ("`VERIFICATION_FAILED` for `bypassed_patch`. Never persist"); `:450`/`:463` ("prefer a false VERIFICATION_FAILED over a false VERIFIED_SECURE" / "apply INV-1 (downgrade `VERIFIED_SECURE` → `VERIFICATION_FAILED`)"); `schema.json:156` (`reattack_status`), `:173-175` (`reattack_variants` ≥3 rule), `:393-395` (`allOf` conditional on `reattack_status: failed_to_bypass`).

#### (d) Deps to pull when reusing this item

- `schema.json`: top-level `repro_attempts` property + `$defs/repro_attempts` (`schema.json:22-24`, `:1014-1033`), finding `reattack_status` `:156`, `reattack_variants` `:173-175`.
- Workspace state: `workspace/findings/` in-place, `workspace/reproducers/` (PoC files), `workspace/archive/.repro_attempts.json` (+`.lock`, `.tmp` swap) — `skills/mantis-reproduce/SKILL.md:48,51,64,74-75`.
- Sandbox/container runtime must be available (`:68-69` "Sandbox/container runtime environment must be available"); the harness-side tool is `run_sandbox_with_evidence` (stage table, gm-02 m14 deps_in).
- INV-1 downgrade pair with `mantis-patch` (atomic `VERIFIED_SECURE` → `VERIFICATION_FAILED`, `:463`); orchestrator Stages 9/11 (`skills/mantis-meta-agent/SKILL.md:469,477-481`).

#### (e) Item build

SKIPPED (honest) — `skills/mantis-reproduce/` contains only `SKILL.md` (828 lines); no `requirements.in`/build file exists for this item, and the brief's `pytest reference/tests` target belongs to the reference harness (outside this item). Census `1 md / 828 LOC` matches gm-02.

---

### s26 · schema-contract — `schema.json` (1 file / 1,058 LOC)

*(nguồn: gm-12-usage-w1.md, nguyên văn)*

#### (a) What problem this item solves

`schema.json` is the canonical "Mantis Pipeline State Contract" (`schema.json:3`): a draft-2020-12 JSON Schema (`:2`) with 7 top-level properties (`finding`, `plan`, `learning_entry`, `state`, `tx_log_entry`, `repro_attempts`, `execution_log_entry` — `:6-27`) and 14 `$defs` sub-schemas (`:29`), that every inter-stage state file validates against. Its description blob (`:4`) also carries the non-JSON contracts: the Threat Model document rules, the harness-agnostic 6-step Pass Lifecycle Contract, the 6-tier SNAPSHOT_ID ladder, and the Global backward-compat safe-branch rule (absent/empty/null always routes to the SAFE branch — e.g. absent `discovery_commit` → NOT_MATCHED, absent `active_snapshot` → MODE-OFF). It references nothing outside itself (contract root, no executable entrypoint).

#### (b) Use case 1 — harness author validates a finding file against the contract's own rules

Scenario: a harness builder wants to gate every `workspace/findings/<uuid>.json` before the pipeline consumes it. Per the Validation Guidelines embedded in the schema description, finding files validate against `#/$defs/finding`; the builder also enforces the contract's variant rule mechanically: `reattack_status=failed_to_bypass` requires ≥ 3 `reattack_variants` entries. The checker reads the required-field list directly from the schema file instead of hardcoding it, so it can never drift from the contract.

```python
# checker.py — stdlib-only; loads the CONTRACT ITSELF as the rule source.
import json, sys

schema = json.load(open("schema.json"))            # schema.json:3 "Mantis Pipeline State Contract"
finding_def = schema["$defs"]["finding"]           # Validation Guidelines (schema.json:4):
                                                   #   findings validate against #/$defs/finding
finding = json.load(open(sys.argv[1]))

problems = []
for field in finding_def.get("required", []):      # required list read from schema.json, not hardcoded
    if field not in finding:
        problems.append(f"missing required field: {field}")

# reattack_variants contract (schema.json:175): "Must be non-empty (>= 3 entries)
# for reattack_status = failed_to_bypass"
if finding.get("reattack_status") == "failed_to_bypass":
    if len(finding.get("reattack_variants") or []) < 3:
        problems.append("reattack_status=failed_to_bypass requires >= 3 reattack_variants")

# Snapshot provenance stamp (schema.json:255/259): repro/reattack SNAPSHOT_IDs are
# optional; absent -> downstream reproduce/patch must re-verify rather than trust.
print("CONTRACT_OK" if not problems else "CONTRACT_FAIL: " + "; ".join(problems))
```

Evidence: `schema.json:2-4` (`$schema` draft-2020-12; title; description carrying "Validate individual finding files (`workspace/findings/<uuid>.json`) against `#/$defs/finding`"), `:6-27` (7 top-level properties), `:29`/`:35` (`$defs`, `finding` sub-schema), `:156` (`reattack_status`), `:173-175` (`reattack_variants` "≥ 3 entries for `failed_to_bypass`"), `:255`/`:259` (repro/reattack snapshot provenance "absent -> … re-verify rather than trust").

#### (b) Use case 2 — compute the SNAPSHOT_ID per the ladder and route absent fields to the safe branch

Scenario: an orchestrator pins a pass against a dirty working tree and must compute the SNAPSHOT_ID exactly as the ladder prescribes (dirty git = `commit_hash + ':' + content_hash`, content_hash = sha256 over EVERY file in the pinned copy), then demonstrate the backward-compat safe branch: a legacy finding without `discovery_commit` is NOT_MATCHED (never trusted), not a validation failure.

```bash
# SNAPSHOT_ID ladder (verified: schema.json:4 description):
#   clean git/hg: commit_hash
#   dirty  git/hg: commit_hash + ':' + content_hash (sha256 over EVERY file)
python3 - <<'PY'
import hashlib, subprocess, pathlib
root = pathlib.Path("/srv/snapshots/sha-1e15346")
commit = subprocess.run(["git", "-C", str(root), "rev-parse", "HEAD"],
                        capture_output=True, text=True).stdout.strip()
h = hashlib.sha256()
for f in sorted(root.rglob("*")):
    if f.is_file() and ".git" not in f.parts:
        h.update(f.read_bytes())
print(f"SNAPSHOT_ID={commit}:{h.hexdigest()}")
PY

# Safe branch (schema.json:4 "Global backward-compat rule"):
#   finding.discovery_commit absent -> Snapshot Match Check NOT_MATCHED
#     (re-research/re-verify, never a trusting DUPLICATE/FALSE_POSITIVE/...)
#   state.active_snapshot absent -> MODE-OFF (byte-for-byte today)
jq 'select(.discovery_commit == null) | {id, route: "NOT_MATCHED"}' workspace/findings/*.json
# Legacy findings validate UNCHANGED: "There is intentionally NO new required entry"
```

Evidence: `schema.json:4` — SNAPSHOT_ID ladder ("clean git/hg: commit_hash; dirty git/hg: commit_hash + ':' + content_hash … content_hash is a sha256 over EVERY file in the pinned copy") and Global backward-compat rule ("discovery_commit absent -> Snapshot Match Check NOT_MATCHED … state.active_snapshot absent → MODE-OFF … There is intentionally NO new required entry and NO new allOf gate"); `schema.json:249-251` (`discovery_commit` — "UNTRUSTED-IF-ABSENT … treated as NOT_MATCHED"), `:261-263` (`patch_base_snapshot` key + description), `:265-267` (`possible_duplicate_of`), `:273-275` (`signature`), `:277-279` (`lineage_id`).

#### (d) Deps to pull when reusing this item

- None across the item boundary — `schema.json` is the contract root; every consumer references it, it references nothing outside itself (gm-02 m26 deps_out, re-verified: no imports/executable entrypoint exist in a single JSON file).
- Consumers (for wiring): all 19 skills + harness builders; e.g. `mantis-reproduce` reads `$defs/repro_attempts` (`skills/mantis-reproduce/SKILL.md:64-66`), `mantis-patch` writes `patch_base_snapshot` (`schema.json:261-263`).
- A JSON Schema validator library is NOT vendored in the repo (grep for `jsonschema|Draft202012Validator` in `reference/requirements.in` + `reference/core/*.py` = 0 matches) — bring your own validator, or use the stdlib checks as above.

#### (e) Item build

SKIPPED (honest) — `schema.json` is a contract document with no build file and no executable entrypoint (gm-02 m26: "no executable entrypoint — contract document"); census 1 file / 1,058 lines matches gm-02.

---

### s21 · reference-evals — `reference/evals` (49 files / 8,111 LOC)

*(nguồn: gm-12-usage-w1.md, nguyên văn)*

#### (a) What problem this item solves

`reference/evals` is the evaluation harness suite of the reference ADK pipeline, ordered "cheapest first" (`reference/evals/README.md:3-5`): the Tier-1 zero-LLM surveyor ranking benchmark (recall@k / nDCG@k / MRR against `ground_truth/juice_shop.json`), the Tier-2 researcher campaign eval over the seeded never-executed vulnerable corpus (`research_target/`), fixed-dataset single-stage benchmarks for dedupe/review/critic/calibrate via `run_eval.py --stage …`, paired resumable sweeps (`sweep.py`), and the Harness² evolve loop (`evolve/`). Each tier answers one question in isolation and "a pass at one tier does not transfer upward" (`README.md:9-11`); there is deliberately no end-to-end tier yet (`README.md:20`).

#### (b) Use case 1 — run the Tier-1 surveyor ranking benchmark (zero tokens) on a ranking change

Scenario: a contributor re-tunes the Phase-0 surveyor's file-ranking heuristic and must prove the change didn't regress ranking before spending any LLM budget. Tier 1 is deterministic and costs zero tokens: it scores the ranked map against the juice-shop ground truth with recall@k, nDCG@k, MRR and a coverage ceiling.

```bash
# From the repo root; command documented verbatim (verified: README.md:40-41):
git clone --depth 1 https://github.com/juice-shop/juice-shop ~/src/juice-shop
python3 evals/surveyor_benchmark.py --target ~/src/juice-shop \
    --ground-truth evals/ground_truth/juice_shop.json

# Metrics reported (README.md:29): recall@k, nDCG@k, MRR, and a coverage ceiling
# that separates "ranked late" from "never sliced".
# Ground truth for the corpus (verified: ls evals/ground_truth/):
#   ground_truth/juice_shop.json
# Tie-back into core (surveyor_benchmark.py:219):
#   from core.surveyor import _group_key   # same grouping as the production surveyor
# Caveat baked into the README (README.md:42-44 rel): the ground truth was verified
# against the pinned upstream and the surveyor is calibrated on juice-shop
# measurements -- treat absolute numbers with that contamination caveat.
```

Evidence: `reference/evals/README.md:26` ("## Tier 1 — Surveyor ranking benchmark (`surveyor_benchmark.py`)"), `:28-29` ("Deterministic, no LLM. Scores the Phase-0 ranked map … recall@k, nDCG@k, MRR, and a coverage ceiling"), `:39-41` (juice-shop clone + `python3 evals/surveyor_benchmark.py --target ~/src/juice-shop --ground-truth evals/ground_truth/juice_shop.json`), `:37` ("the ground truth was verified against"), `:48` ("calibrated on juice-shop measurements (see `core/surveyor.py`)"); `reference/evals/surveyor_benchmark.py:219` (`from core.surveyor import _group_key`), `:224` (`key = _group_key(e["file"])`); `ls reference/evals/ground_truth/` → `juice_shop.json`.

#### (b) Use case 2 — run a fixed single-stage benchmark (calibrate) and a Tier-2 toolset A/B

Scenario: a harness maintainer changed the calibrator's tool list and must attribute any regression to the stage that caused it. `run_eval.py --stage calibrate` runs the fixed `calibrate_dataset.json` rows through a stage agent built from `STAGE_CONFIGS['calibrator']` (skill `mantis-calibrate` with the production tool list). For researcher changes, Tier-2 flips the independent variable: `--toolset structural` adds the structural navigation tools to the campaign over the never-executed corpus.

```bash
# run_eval.py CLI (verified: reference/evals/run_eval.py:408-412):
#   --stage {dedupe,review,critic,calibrate,research,all}  --model  --effort
#   --runs N   --toolset (research stage only)
python3 evals/run_eval.py --stage calibrate --runs 3
# Stage config (stage_agents.py:36-98): STAGE_CONFIGS['calibrator'] ->
#   'skill': 'mantis-calibrate', 'tools': ['score_risk', 'calibrate_finding',
#   'get_findings', 'get_threat_model', 'read_file']

# Tier 2: researcher toolset A/B over the seeded corpus (README.md:64-69):
python3 evals/run_eval.py --stage research --toolset structural --runs 1
# The corpus is deliberately vulnerable and never-executed; do not "fix" its
# seeded flaws (README.md:73-74).

# Sweep layer for noise control (sweep.py:15-18): matrix {arm x seed x repeat}.
python3 evals/sweep.py --help   # paired, resumable researcher sweeps
```

Evidence: `reference/evals/run_eval.py:25` (`sys.path.insert(0, … parent.parent)` bootstrap), `:27-31` (`core.context`/`core.database`/`evals.stage_agents`/`google.adk` imports), `:408-412` (argparse: `--stage` choices `dedupe|review|critic|calibrate|research|all`, `--model`, `--runs`, `--toolset` "research stage only"); `reference/evals/stage_agents.py:29-36` (`STAGE_OUTPUT_SCHEMAS`, `STAGE_CONFIGS`), calibrator entry with `'skill': 'mantis-calibrate'` and the 5-tool list (read in `:36-98` range), stage headings `planner :37`, `researcher :50`, `critic :68`, `patcher :83`, `reporter :93`; `reference/evals/README.md:64-69` (Tier 2 + `--toolset structural`), `:73-74` ("deliberately vulnerable, never-executed corpus … do not 'fix' its seeded flaws"); `reference/evals/sweep.py:15-18` ("Paired, resumable researcher sweeps … matrix of cells {arm x seed x repeat}"); `ls reference/evals/` → `calibrate_dataset.json`, `research_target/`, `ground_truth/`, `test_config.json` present.

#### (d) Deps to pull when reusing this item

- `reference/core` (m20): `run_eval.py:27-28`, `stage_agents.py:23` (`core.config.get_llm_kwargs/ResilientLiteLlm`), `stage_agents.py:25` (`core.schemas` ReviewVerdict/CriticVerdict/ReproVerdict/ExecutiveReport), `sweep.py:394` (`from core.config import is_auth_error`), `surveyor_benchmark.py:219` (`core.surveyor._group_key`), `research_eval.py` (`core.graph_loader`, `core.transcript`, `core.database`, `core.structural_index.build_structural_index`).
- `reference/tools` (m23): `from tools import TOOLS` (`stage_agents.py:27`) — the 30-entry production tool registry.
- External: `google.adk` (`run_eval.py:30-31` Runner + InMemorySessionService; `stage_agents.py:20-22`).
- Intra-boundary datasets: `calibrate_dataset.json`, `review_dataset.json`, `ground_truth/juice_shop.json`, `research_target/`, `test_config.json` (item's own `*.json` files; gm-02 m21).
- Reverse dependency check: nothing in `reference/core`/`main.py` imports `evals` (gm-02 m21 deps_in verified NO reverse import) — dependency is one-way evals→core/tools.

#### (e) Item build

SKIPPED (honest) — the build inputs exist: `ls reference/` shows both `requirements.in` and `requirements.txt` (so the brief's `pip install -r reference/requirements.in` target is real), but this sandbox has no pip package install/network path and the eval runners additionally require `google.adk` + LLM credentials at runtime; running them here would fabricate output. Per brief rule, recorded SKIPPED; census re-verified instead (48 py / 7,828 + 1 md / 283 = 49 / 8,111, matches gm-02).

---

### s03 · mantis-calibrate — `skills/mantis-calibrate/SKILL.md` + `references/calibration_rules.md` (2 md / 912 LOC)

*(nguồn: gm-12-usage-w1.md, nguyên văn)*

#### (a) What problem this item solves

`/mantis-calibrate` is the findings-only final scoring stage (orchestrator Stage 12): it loads every processed finding, reads `workspace/kb/THREAT_MODEL.md` for threat-boundary overrides and asset criticality, and stamps a calibrated 1–10 `mantis_risk_score` plus `priority` and the sanity-triage bookkeeping (`sanity_triage_applied`, `calibration_checklist`, `outrage_commentary`, `executive_summary`) back into each finding in place (`skills/mantis-calibrate/SKILL.md:33-40`). Scoring is strictly bounded by the 27 sanity-triage rules in `references/calibration_rules.md:3` — force-downgrades to LOW 2.0 (Category A, `:24`), force-caps at HIGH 7.9 (Category B, `:112`) and MEDIUM 5.9 (Category C, `:188`) — and the stage is idempotent: "Running multiple times on the same inputs yields identical outputs" (`SKILL.md:46`).

#### (b) Use case 1 — final scoring pass with boundary overrides and an idempotent re-run

Scenario: the campaign reaches Stage 12 with a reproduced, VIABLE finding on a DoS-exposed admin service. The calibrator stamps the full scoring field set into the finding; because the Threat Model documents `availability_tier: CRITICAL` for that asset, the DoS finding is allowed to exceed the usual MEDIUM sanity cap. The harness then re-runs the stage to verify the idempotency guarantee byte-for-byte.

```bash
# Orchestrator Stage 12 (verified: skills/mantis-meta-agent/SKILL.md:483)
@mantis-calibrate --state_root=/srv/mantis-state

# Inputs (SKILL.md:31-37): workspace/findings/*.json,
#   workspace/kb/THREAT_MODEL.md (boundary overrides + asset criticality),
#   workspace/.mantis_state.json (pass tracking; active_snapshot provenance).
# Stamped fields (SKILL.md:33-40):
jq '{mantis_risk_score, priority, impact_score, likelihood_score,
     availability_tier, attacker_position, sanity_triage_applied,
     calibration_checklist: (.calibration_checklist | keys)}' \
  /srv/mantis-state/workspace/findings/3f9d2a1e-8c41-4b6e-9d2f-a1b2c3d4e5f6.json
# { "mantis_risk_score": 8.4, "priority": "HIGH", "impact_score": 4,
#   "likelihood_score": 5, "availability_tier": "CRITICAL",
#   "attacker_position": "unauthenticated", "sanity_triage_applied": ["rule_09_dos"],
#   "calibration_checklist": ["rule_01", "rule_09", "rule_14"] }

# DoS CRITICAL carve-out (SKILL.md:540-543): a DoS finding must not be rated
# CRITICAL unless availability_tier is explicitly CRITICAL in the Threat Model
# AND no auto-recovery mitigates it.

# Idempotency guarantee (SKILL.md:46): re-run yields identical outputs --
cp findings/f.json /tmp/before.json && @mantis-calibrate --state_root=/srv/mantis-state \
   && diff <(jq -S . /tmp/before.json) <(jq -S . findings/f.json) && echo IDEMPOTENT
```

Evidence: `skills/mantis-meta-agent/SKILL.md:483` ("Stage 12 (Calibrate): Call the `@mantis-calibrate` subagent to read the…"); `skills/mantis-calibrate/SKILL.md:2-6` (front matter "Calculates the final risk score…"), `:16-18` ("produce a final risk score (1-10)"), `:24` (command `/mantis-calibrate`), `:31-37` (Reads incl. THREAT_MODEL "threat boundary overrides and asset criticality"), `:33-40` (Writes `impact_score`, `likelihood_score`, `availability_tier`, `inferred_exposure`, `attacker_position`, `mantis_risk_score`, `priority`, `sanity_triage_applied`, `calibration_checklist`, `outrage_commentary`, `executive_summary` + history entry), `:46` ("Running multiple times on the same inputs yields identical outputs"), `:540-543` (DoS CRITICAL carve-out), `:544`/`:546` (priority bands HIGH 6.0–7.9, MEDIUM 3.0–5.9); `schema.json:213` (`mantis_risk_score` field), `:228` (`triage_checklist`) + `:858` (`$defs/triage_checklist`).

#### (b) Use case 2 — enforce the sanity caps mechanically and reuse only the version-guarded helper

Scenario: a CI job audits calibration output: no calibrated finding may violate the 27-rule catalogue (a debug-only/sample finding must sit at LOW 2.0; a stored-XSS-on-a-critical-admin-page finding must never exceed HIGH 7.9), and the reused `append_calibrate.py` helper must carry the exact version marker `# MANTIS_HELPER_VERSION = 2` — an older helper silently drops the `snapshot` history field and `STALE_EVIDENCE` handling, so the skill regenerates it when the marker is wrong.

```bash
# Version guard before reusing the helper (verified: SKILL.md:563-566):
head -1 /srv/mantis-state/workspace/helpers/append_calibrate.py
# must be exactly:  # MANTIS_HELPER_VERSION = 2
grep -q '^# MANTIS_HELPER_VERSION = 2$' \
  /srv/mantis-state/workspace/helpers/append_calibrate.py \
  || echo "REGENERATE helper: marker absent or wrong integer (SKILL.md:563-570)"

# Mechanical cap audit against the 27-rule catalogue (calibration_rules.md:3):
python3 - <<'PY'
import json, glob
LOW, HIGH_MAX, MED_MAX = 2.0, 7.9, 5.9          # rules.md:24 (A), :112 (B), :188 (C)
for p in glob.glob("/srv/mantis-state/workspace/findings/*.json"):
    f = json.load(open(p))
    s = f.get("mantis_risk_score")
    tags = set(f.get("sanity_triage_applied", []))
    if "category_A" in tags and (s is None or s > LOW):
        print(f"CAP-VIOLATION {p}: Category A must cap at LOW {LOW} (rules.md:24)")
    if "stored_xss_admin" in tags and s is not None and s > HIGH_MAX:
        print(f"CAP-VIOLATION {p}: Category B must cap at HIGH {HIGH_MAX} (rules.md:112)")
PY

# Priority bands are part of the contract (SKILL.md:544/:546):
#   HIGH (6.0 - 7.9) / MEDIUM (3.0 - 5.9) / LOW (0.1 - 2.9)
```

Evidence: `skills/mantis-calibrate/SKILL.md:556-557` ("write a reusable helper script (e.g., `workspace/helpers/append_calibrate.py`) during your first finding update"), `:563-566` ("The very first line of `append_calibrate.py` MUST be the exact comment `# MANTIS_HELPER_VERSION = 2` … regenerate the helper from scratch"), `:567-570` (regenerated helper must write the `snapshot` history key and prepend `STALE_EVIDENCE` to `sanity_triage_applied`); `skills/mantis-calibrate/references/calibration_rules.md:3` ("This document defines the 27 calibration sanity triage rules (caps and downgrades)"), `:24` ("### Category A: Force-Downgrade to LOW (Cap at 2.0 / LOW Priority)"), `:112` ("### Category B: Force-Cap to HIGH (Cap at 7.9 / Maximum HIGH Priority)"), `:188` ("### Category C: Force-Cap to MEDIUM (Cap at 5.9 / Maximum MEDIUM Priority)"); `skills/mantis-calibrate/SKILL.md:539` ("must be capped at HIGH (7.9)"), `:544`/`:546` (bands).

#### (d) Deps to pull when reusing this item

- Workspace state only: `workspace/findings/*.json` updated in place + per-pass `history` entry with snapshot provenance (`SKILL.md:33-41`), `workspace/kb/THREAT_MODEL.md` (boundary overrides), `workspace/.mantis_state.json` (`active_snapshot`), helper `workspace/helpers/append_calibrate.py` (`:41`, written at `:556-559`).
- Rules catalogue: `skills/mantis-calibrate/references/calibration_rules.md` (27 rules; load per `SKILL.md:479` "The complete, detailed definitions of the 27 calibration sanity rules are…").
- Upstream: orchestrator Stage 12 (`skills/mantis-meta-agent/SKILL.md:483`); critic cross-reference (`skills/mantis-critic/SKILL.md:222` "`mantis-calibrate` DROPS" NON_VIABLE — gm-02 m03).
- No `reference/` script and no `${MANTIS_HOME}` command (0 grep matches — pure agent-procedure skill; gm-02 m03, re-verified by this worker's read of the SKILL.md I/O section).

#### (e) Item build

SKIPPED (honest) — `ls skills/mantis-calibrate` shows only `SKILL.md` (666 lines) + `references/calibration_rules.md` (246 lines); no build file exists for this item; census 2 md / 912 LOC matches gm-02.

---

### s06 · mantis-dedupe — `skills/mantis-dedupe/SKILL.md` (1 md / 371 LOC)

*(nguồn: gm-12-usage-w2.md, nguyên văn)*

#### (a) What problem this item solves

`/mantis-dedupe` is the Stage-6 consolidator of a Mantis campaign: it clusters raw findings so redundant reports do not reach review/report. It hard-trashes a duplicate **only** when the current finding and an archived finding are snapshot-MATCHED by byte-for-byte equal `discovery_commit` (there is "no other route to MATCHED; never fuzzy-compare" — `skills/mantis-dedupe/SKILL.md:173`), keeps NOT_MATCHED pairs active with a soft `possible_duplicate_of` pointer so a possible regression ("old bug reintroduced", `:134`) is never silently dropped, and merges survivors through a versioned deterministic helper (`workspace/helpers/merge_findings.py`) with a transaction log (`workspace/.tx_log.jsonl`) for rollback.

#### (b) Use case 1 — run dedupe in a multi-pass campaign without trashing a reintroduced bug

Scenario: pass 2 of a campaign re-discovers a bug that was found, triaged and resolved in pass 1 on the **same** pinned commit; it also produces a different bug on the same file at a different line. The orchestrator calls the skill at Stage 6 with the documented args; dedupe stamps `discovery_commit`, runs the PAIRWISE SNAPSHOT MATCH CHECK, and only the byte-for-byte MATCHED finding is trashed with a tx-log record for rollback; the distinct-line bug stays ACTIVE.

```bash
# Orchestrator Stage 6 (verified: skills/mantis-meta-agent/SKILL.md:460)
@mantis-dedupe --snapshot_root=/srv/snapshots/sha-1e15346 \
               --snapshot_id=1e15346c2ca2d6e7db57ced59615bb9d1685992f \
               --state_root=/srv/mantis-state
# All three args absent -> MODE-OFF/legacy mode (SKILL.md:22-24)

# Inputs: current findings + archived pass-1 findings (SKILL.md:28-33)
ls workspace/findings/*.json workspace/archive/findings_pass_1/*.json

# Finding a1 re-found on the SAME commit as archived finding c9:
#   pairwise check compares a1.discovery_commit vs c9.discovery_commit
#   (NOT vs SNAPSHOT_ID) -> byte-for-byte equal -> MATCHED (SKILL.md:160-181)
jq -r '.discovery_commit' workspace/findings/a1.json workspace/archive/findings_pass_1/c9.json
# 1e15346c2ca2d6e7db57ced59615bb9d1685992f
# 1e15346c2ca2d6e7db57ced59615bb9d1685992f

# Result: a1 moved to trash with status DUPLICATE + duplicate_of (SKILL.md:35-36)
jq '{status, duplicate_of}' workspace/findings/.trash/a1.json
# { "status": "DUPLICATE", "duplicate_of": "c9-replaced-by-uuid" }

# Rollback trail: one JSON line per moved file (SKILL.md:40, schema :365)
tail -1 workspace/.tx_log.jsonl
# {"timestamp": "2026-07-14T15:13:00Z", "action": "dedupe_merge",
#  "primary_uuid": "<c9-uuid>", "moved_uuid": "<a1-uuid>"}
```

Evidence (grep-verified on PIN clone): `skills/mantis-meta-agent/SKILL.md:460` ("Stage 6 (Deduplication): Call the `@mantis-dedupe` subagent"); `skills/mantis-dedupe/SKILL.md:22-24` (args, MODE-OFF fallback), `:28-33` (reads), `:35-36` (moves duplicates to `.trash/` with `"status": "DUPLICATE"` + `"duplicate_of"`), `:37-39` (soft `possible_duplicate_of` + `discovery_commit` stamp), `:40` (`workspace/.tx_log.jsonl` appends), `:160-181` (PAIRWISE SNAPSHOT MATCH CHECK, `:173` "There is no other route to MATCHED; never fuzzy-compare"), `:365` (tx-log schema line), `:134` (regression rationale); `schema.json:108` (`"duplicate_of"`), `:265` + `:267` (`possible_duplicate_of` description: "used by mantis-dedupe to avoid dropping a possible regression").

#### (b) Use case 2 — configure Tier-3 vector dedup and never merge two distinct bugs in one file

Scenario: a harness builder enables Tier-3 of the 3-Tier Deduplication Ladder (vector similarity) and must guarantee the skill's safety rule: two distinct bugs at `parser.c:100` vs `parser.c:900` share a `signature` but are NOT duplicates, because `code_paths` are compared line-inclusively; at most a soft `possible_duplicate_of` pointer is set. The builder also verifies the generated merge helper carries the exact version marker before reuse (the skill refuses helpers with a wrong/absent marker).

```bash
# Tier-3 vector scan knobs consumed by the skill (SKILL.md:278, :290):
export EMBEDDING_ENGINE="vertex_ai/gemini-embedding-001"  # default engine (SKILL.md:278)
export EMBEDDING_SIMILARITY_THRESHOLD="0.90"              # merge >= 0.90, fail-closed < 0.70 (:290)

# Candidate rule (SKILL.md:145-158): a signature match WITHOUT line-inclusive
# code_paths + title agreement is NOT a duplicate -> keep ACTIVE, soft pointer only.
jq -r '.code_paths, .signature' workspace/findings/x1.json workspace/findings/x2.json
# ["src/parser.c:100"] / ["src/parser.c:900"]  -> line-inclusive compare differs
# both share signature "sig-parse-int-overflow" -> at most possible_duplicate_of

# Version-guarded helper before reuse (SKILL.md:314-315):
head -1 workspace/helpers/merge_findings.py
# must be exactly:  # MANTIS_HELPER_VERSION = 2
grep -q '^# MANTIS_HELPER_VERSION = 2$' workspace/helpers/merge_findings.py \
  || echo "REGENERATE helper: marker absent or wrong integer (SKILL.md:314-315)"

# Audit soft pointers after the pass (schema.json:267: NON-destructive advisory):
jq 'select(.possible_duplicate_of != null) | {uuid, possible_duplicate_of, status}' workspace/findings/*.json
```

Evidence: `skills/mantis-dedupe/SKILL.md:278` ("`vertex_ai/gemini-embedding-001`"), `:290` ("`EMBEDDING_SIMILARITY_THRESHOLD`"), `:145-158` (signature is candidate-only; line-inclusive `code_paths` agreement required; at most soft `possible_duplicate_of`, never a trash), `:314-315` ("exactly `# MANTIS_HELPER_VERSION = 2`" + grep-the-first-lines reuse rule); `schema.json:273` (`"signature"`), `:277` (`"lineage_id"`), `:265`/`:267` (`possible_duplicate_of` NON-destructive advisory).

#### (d) Deps to pull when reusing this item

- `schema.json` finding `$defs`: `duplicate_of` `schema.json:108`, `possible_duplicate_of` `:265`, `signature` `:273`, `lineage_id` `:277`.
- Workspace state: `workspace/findings/` (+ `.trash/`), `workspace/archive/findings_pass_*/*.json` + legacy `workspace/archive/loop*_findings/*.json`, `workspace/.mantis_state.json` (`active_snapshot`/`snapshot_pinned`), `workspace/.tx_log.jsonl`, generated helper `workspace/helpers/merge_findings.py` (all `skills/mantis-dedupe/SKILL.md:28-43`).
- Harness-provided embedding engine + threshold (`vertex_ai/gemini-embedding-001`, `EMBEDDING_SIMILARITY_THRESHOLD`, `:278`/`:290`).
- Downstream consumer: `skills/mantis-report/SKILL.md:215` ("Duplicate Advisory: If the finding has a `possible_duplicate_of` field").
- Upstream hand-off: `skills/mantis-researcher` writes the `signature` at creation (gm-02 fact, block m06).

#### (e) Item build

SKIPPED (honest) — `ls skills/mantis-dedupe` shows only `SKILL.md` (21,718 bytes); there is no `requirements.in`/build file to install, and the brief's `python3 -m pytest reference/tests` target belongs to the reference harness, not this skill. Census `1 md / 371 LOC` matches gm-02.

---

### s16 · mantis-review — `skills/mantis-review/SKILL.md` (1 md / 437 LOC)

*(nguồn: gm-12-usage-w2.md, nguyên văn)*

#### (a) What problem this item solves

`/mantis-review` is the adversarial independent validator between research and exploit work: it re-reads each finding's `code_paths` under the resolved pinned `CODE_ROOT` (never the live tree when a snapshot is pinned — `skills/mantis-review/SKILL.md:32-34`), applies the stance "Assume every finding is a false positive by default" (`:63`) plus 13 negative rules, builds the `triage_checklist`, finalizes statuses `VALID` / `FALSE_POSITIVE` / `PROVISIONALLY_VALID` / `NEEDS_RESEARCH`, and updates findings in-place through a version-guarded helper with idempotency key `(pass_number, snapshot)`.

#### (b) Use case 1 — kill a hallucinated finding before it reaches exploitation

Scenario: the researcher reported "SQL injection in `db/query.py:88`", but the reviewer re-reads that exact path in the pinned snapshot and finds the input is bound through a parameterized placeholder — a source-coherence failure. The reviewer finalizes the finding in-place as `FALSE_POSITIVE` with the rule checklist as machine-readable evidence, so downstream critic/reproduce/calibrate never spend budget on it.

```bash
# Orchestrator Stage 7 (verified: skills/mantis-meta-agent/SKILL.md:463)
@mantis-review --snapshot_root=/srv/snapshots/sha-1e15346 \
               --snapshot_id=1e15346c2ca2d6e7db57ced59615bb9d1685992f \
               --state_root=/srv/mantis-state

# The reviewer updates the finding IN-PLACE; fields per SKILL.md:36-37:
jq '{status, reasoning, repro_hints,
     triage_checklist: (.triage_checklist | keys)}' workspace/findings/f-123.json
# {
#   "status": "FALSE_POSITIVE",
#   "reasoning": "R12 source coherence: value bound via parameterized ? ...",
#   "repro_hints": [],
#   "triage_checklist": ["rule_12_source_coherence", "rule_13_ingress", "..."]
# }

# Drift case: target file changed between discovery and review ->
# finalize as drift NEEDS_RESEARCH with an all-UNKNOWN checklist (SKILL.md:171-173),
# and a genuinely inconclusive review also finalizes NEEDS_RESEARCH (SKILL.md:316).
```

Evidence: `skills/mantis-meta-agent/SKILL.md:463` ("Stage 7 (Review): Call the `@mantis-review` subagent"); `skills/mantis-review/SKILL.md:36-37` (writes `"status"`, `"reasoning"`, `"repro_hints"`, `"triage_checklist"`, history), `:63` (adversarial stance, verbatim), `:171-173` (drift `NEEDS_RESEARCH` via the helper), `:182` (the skill's own citation of "`schema.json` lines 365-398" for checklist validation), `:313` (`PROVISIONALLY_VALID`), `:316` (`NEEDS_RESEARCH` when inconclusive); `schema.json:228` (`finding.triage_checklist`), `:858` (`$defs/triage_checklist`), `:826` (`$defs/triage_rule_evaluation`).

#### (b) Use case 2 — idempotent re-review across passes with the version-guarded helper

Scenario: the harness re-runs a pass and the reviewer is invoked again on the same findings. The skill must not double-write history: its idempotency key is `(pass_number, snapshot)` — skip only when a `"stage": "reviewer"` history entry exists with the same pass AND the same snapshot; a legacy entry lacking `snapshot` counts as UNKNOWN and forces a re-review so the verdict is re-grounded against the current pinned snapshot. The helper it writes must carry the exact version marker as first line.

```python
# workspace/helpers/append_review.py — generated by @mantis-review.
# Contract (verified): SKILL.md:44 first line MUST be exactly
#   # MANTIS_HELPER_VERSION = 2     (regenerate helper if marker differs)
# SKILL.md:47: idempotency key is (pass_number, snapshot).

def already_reviewed(history, pass_number, snapshot_id):
    """SKILL.md:47-58 skip rule, encoded 1:1."""
    for entry in history:
        if entry.get("stage") == "reviewer":
            if entry.get("pass_number") != pass_number:
                continue
            if entry.get("snapshot") == snapshot_id:
                return True   # same pass + same snapshot -> SKIP update
            return False      # legacy (no snapshot) or other snapshot -> UNKNOWN: RE-REVIEW
    return False              # no reviewer entry -> review

# Harness-side version guard before reusing a stale helper (SKILL.md:44-45):
#   head -1 workspace/helpers/append_review.py == "# MANTIS_HELPER_VERSION = 2"
#   else the skill regenerates the helper (see SKILL.md "step 5").
```

Evidence: `skills/mantis-review/SKILL.md:38` (writes helper `workspace/helpers/append_review.py`), `:43-44` ("MUST carry `# MANTIS_HELPER_VERSION = 2` as its first line"), `:47-58` (idempotency key `(pass_number, snapshot)`; SKIP iff `"stage": "reviewer"` entry with equal `pass_number` AND equal `snapshot`; legacy/other-snapshot = UNKNOWN → RE-REVIEW — both MODE-OFF and MODE-ON variants quoted in the read).

#### (d) Deps to pull when reusing this item

- `schema.json` triage/state validation rules — the skill quotes them by line (`skills/mantis-review/SKILL.md:182` cites `schema.json` lines 365-398; see also `:325` per gm-02).
- Workspace state: `workspace/findings/*.json` (in-place), `workspace/helpers/append_review.py`, `workspace/.mantis_state.json` (`pass_number`, `active_snapshot`) — `skills/mantis-review/SKILL.md:25-38`.
- Target source reads under resolved `CODE_ROOT` (pinned snapshot), never the live tree when pinned — `:32-34`.
- Statuses consumed downstream by `@mantis-critic` / `@mantis-reproduce` (reattack eligibility requires `repro_status=reproduced` + review status) / `@mantis-calibrate` (gm-02 block m16 deps_out).

#### (e) Item build

SKIPPED (honest) — `ls skills/mantis-review` shows only `SKILL.md` (26,094 bytes); no build file exists for this skill; census `1 md / 437 LOC` matches gm-02.

---

### s09 · mantis-patch — `skills/mantis-patch/SKILL.md` + `references/patch_rebasing.md` (2 md / 823 LOC)

*(nguồn: gm-12-usage-w2.md, nguyên văn)*

#### (a) What problem this item solves

`/mantis-patch` is the fix stage: it generates minimal security patches under transactional isolation (shadow directory MANDATORY in PINNED mode), and only after two mechanical gates may it stamp `patch_status=VERIFIED_SECURE` — Block F (reached-sink evidence: sidecar `MANTIS_REACHED_ENTRYPOINT` written in-path or target-produced sanitizer/backtrace frame, `skills/mantis-patch/SKILL.md:525`/`:537`) and Block G (unpatched baseline must trigger + patched build compiles + benign control reaches sink, `:552`-`:590`), with the final verdict requiring a fresh, independent `@mantis-reproduce --reattack` run that fails to bypass with ≥3 variants (`:613-615`). It stamps `patch_base_snapshot` (`schema.json:663`: "written by mantis-patch (or omitted in LEGACY mode)") so verdicts stay valid across passes and patches can be rebased 3-way onto newer snapshots.

#### (b) Use case 1 — verify a fix with an independent re-attack on the patched shadow (PINNED mode)

Scenario: finding `3f9d2a1e…` is reproduced; the patcher applies a fix to a patched shadow copy of the pinned snapshot. To keep verification honest, the patcher spawns a FRESH `@mantis-reproduce` sub-agent in reattack mode against the patched shadow with the exact documented flag set (`--target_root` is authoritative and sentinel-exempt; `--snapshot_pinned=false` because the shadow is deliberately mutated). The reproducer writes `reattack_*` fields back into the original finding while leaving the original `repro_*` evidence untouched.

```bash
# Orchestrator Stage 11 (verified: skills/mantis-meta-agent/SKILL.md:477)
@mantis-patch --snapshot_root=/srv/snapshots/sha-1e15346 \
              --snapshot_id=1e15346c2ca2d6e7db57ced59615bb9d1685992f \
              --state_root=/srv/mantis-state

# Inside the patcher — the documented independent re-attack (SKILL.md:627-647):
# Option A (Shadowing), always in PINNED mode:
@mantis-reproduce --reattack \
  --finding_id=3f9d2a1e-8c41-4b6e-9d2f-a1b2c3d4e5f6 \
  --target_root=/srv/mantis-state/workspace/.patch_shadows/3f9d2a1e/patched \
  --snapshot_pinned=false \
  --state_root=/srv/mantis-state

# Outcomes land in the ORIGINAL finding (SKILL.md:653-656):
jq '{patch_status, reattack_status,
     reattack_variants: (.reattack_variants | length)}' \
  workspace/findings/3f9d2a1e-8c41-4b6e-9d2f-a1b2c3d4e5f6.json
# { "patch_status": "VERIFIED_SECURE", "reattack_status": "failed_to_bypass",
#   "reattack_variants": 3 }   # >=3 valid variants required (SKILL.md:614-615)
```

Evidence: `skills/mantis-meta-agent/SKILL.md:477` ("Stage 11 (Patch & Verify): Call the `@mantis-patch` subagent"); `skills/mantis-patch/SKILL.md:628` ("launch a fresh `@mantis-reproduce --reattack --finding_id=[finding_id]` sub-agent ... against the PATCHED shadow"), `:635-647` (exact Option A flag list: `--reattack`, `--target_root=<PATCHED_SHADOW_ROOT>` AUTHORITATIVE/sentinel-EXEMPT, `--snapshot_pinned=false`, `--state_root=<state_root>`, `--finding_id=[finding_id]`), `:653-656` (writes `reattack_status/_file_path/_run_command/_output` into the original finding, `repro_*` untouched), `:613-615` (`failed_to_bypass` = non-empty `reattack_variants` with ≥3 valid variant inputs), `:552` ("Hard gate before any `VERIFIED_SECURE` — Block G"), `:525`/`:537` (Block F `MANTIS_REACHED_ENTRYPOINT` channels); `schema.json:147` (`patch_status`), `:386-388` (`const "VERIFIED_SECURE"` conditional), `:393-395` (`const "failed_to_bypass"` conditional), `:261` + `:663` (`patch_base_snapshot`).

#### (b) Use case 2 — rebase last pass's verified patch onto a newer snapshot (and the LEGACY-mode lock)

Scenario: the audit moves from commit A to commit B between passes; the stored `patch_diff` for a still-open finding no longer applies cleanly. The skill's rebasing reference prescribes a 3-way merge (`git merge-file -p <ours> <base> <theirs>`) with `diff3 -m` as fallback and a hard guardrail to regenerate the patch whenever uncertain. In LEGACY mode (no snapshots), Option B file-level backups are concurrency-unsafe, so the agent must hold an exclusive `fcntl.flock` on `workspace/.workspace_edit.lock` for the whole patch→verify→reattack→restore lifecycle.

```bash
# 3-way rebase of patch_diff from base snapshot A onto current tree B
# (verified: references/patch_rebasing.md:27, :30, :48):
git merge-file -p workspace/src/auth/session.c \
                /srv/.mantis_snapshots/pass-7/src/auth/session.c \
                /srv/live-tree/src/auth/session.c > merged.c
# conflict -> documented fallback:
diff3 -m workspace/src/auth/session.c \
         /srv/.mantis_snapshots/pass-7/src/auth/session.c \
         /srv/live-tree/src/auth/session.c > merged_d3.c
# patch_rebasing.md:48  "On ANY uncertainty, fall back to Phase-1 patch generation."

# LEGACY mode only — Option B exclusive workspace lock (SKILL.md:411-417):
python3 - <<'PY'
import fcntl
lock = open("workspace/.workspace_edit.lock", "w")
fcntl.flock(lock, fcntl.LOCK_EX)  # hold through patching, verification,
                                  # re-attack and restoration (SKILL.md:415-417)
# ... backups (*.bak-<finding_id>), edits, verification, restore ...
fcntl.flock(lock, fcntl.LOCK_UN)
PY
```

Evidence: `skills/mantis-patch/references/patch_rebasing.md:27` ("`git merge-file -p <ours> <base> <theirs> > <result>` — the `-p` flag writes"), `:30` ("`diff3 -m <ours> <base> <theirs> > <result>` or any 3-way merge tool"), `:48` ("**Guardrail:** On ANY uncertainty, fall back to Phase-1 patch generation."); `skills/mantis-patch/SKILL.md:411-417` ("acquire an exclusive lock on `workspace/.workspace_edit.lock` (using `fcntl.flock` with `fcntl.LOCK_EX` ...)" — exact lines `:413-414`), `:272` (patch_status set `{"VERIFIED_SECURE", "MITIGATION_PROPOSED", "VERIFICATION_INCOMPLETE"}` for chains).

#### (d) Deps to pull when reusing this item

- `@mantis-reproduce` invocation contract (flags above) — the two skills form the INV-1 downgrade pair (`VERIFIED_SECURE` atomically downgraded when re-attack does not end `failed_to_bypass`; gm-02 blocks m09/m14).
- `schema.json` fields: `patch_status` `:147`, `reattack_status` `:156`, `reattack_variants` `:173`, `patch_base_snapshot` `:261`/`:663`.
- Workspace layout: `workspace/helpers/append_patch.py`, `workspace/reproducers/` + `workspace/helpers/` preserved on rollback, `workspace/findings/.trash/<uuid>.json` + `workspace/archive/findings_pass_*/` duplicate search, `<state_root>/.mantis_snapshots/` prior-pass snapshot for rebasing, `workspace/.workspace_edit.lock` (gm-02 block m09 deps_out, bound to the same PIN tree).
- Reference doc load-trigger: `skills/mantis-patch/references/patch_rebasing.md` (loaded per `:3-10` per gm-02).

#### (e) Item build

SKIPPED (honest) — `ls skills/mantis-patch` shows only `SKILL.md` (46,742 bytes) + `references/patch_rebasing.md` (2,829 bytes); no build file; census `2 md / 823 LOC` matches gm-02.

---

### s19 · mantis-threat-model — `skills/mantis-threat-model/SKILL.md` (1 md / 251 LOC)

*(nguồn: gm-12-usage-w2.md, nguyên văn)*

#### (a) What problem this item solves

`/mantis-threat-model` is the Stage-B Knowledge-Base generator: it synthesizes trust boundaries, attack surfaces and attacker profiles from the upstream KB inputs (`workspace/kb/architecture.md` + `workspace/kb/entities/*.md`) into the living deliverable `workspace/kb/THREAT_MODEL.md`, whose first line is a `KB_SNAPSHOT:` provenance stamp. It is a findings-only stage that never reads target source (`--snapshot_root` is "accepted for interface uniformity but NOT used", `skills/mantis-threat-model/SKILL.md:31-32`), archives the previous model per pass BEFORE overwriting, and carries a verbatim STALE banner whenever the snapshot was not re-evaluated that pass — the banner downstream `mantis-critic` reads as its KB freshness check (`:242`).

#### (b) Use case 1 — regenerate the threat model on a freshly pinned snapshot

Scenario: pass 8 starts against a new pinned commit; the orchestrator passes `--snapshot_id` so provenance is stamped into the deliverable. The skill first archives the pass-7 model, then deterministically overwrites `THREAT_MODEL.md` with a first line `KB_SNAPSHOT: <CUR>`; if no snapshot arg/state exists the stamp is the literal `UNPINNED`.

```bash
# Orchestrator Stage 3 (verified: skills/mantis-meta-agent/SKILL.md:449)
@mantis-threat-model --state_root=/srv/mantis-state \
                     --snapshot_id=1e15346c2ca2d6e7db57ced59615bb9d1685992f

# Args semantics (SKILL.md:22-32): --snapshot_id is provenance-ONLY;
# --snapshot_root accepted but NOT used (never reads target source).

# Per-pass archive is written BEFORE overwrite (SKILL.md:51-52):
ls workspace/archive/kb/
# THREAT_MODEL_pass_7.md

# Deliverable header (SKILL.md:49-50):
head -1 workspace/kb/THREAT_MODEL.md
# KB_SNAPSHOT: 1e15346c2ca2d6e7db57ced59615bb9d1685992f

# Inputs consumed (SKILL.md:38-44): .mantis_state.json (pass_number,
# active_snapshot), workspace/kb/architecture.md, workspace/kb/entities/*.md.
```

Evidence: `skills/mantis-meta-agent/SKILL.md:449` ("Stage 3 (Threat Modeling): Call the `@mantis-threat-model` subagent"); `skills/mantis-threat-model/SKILL.md:26-30` (`--snapshot_id` provenance-only + `UNPINNED` fallback), `:31-32` (`--snapshot_root` NOT used), `:38-47` (reads incl. prior model's first `KB_SNAPSHOT:` line), `:48-52` (writes + "Archives the previous `workspace/kb/THREAT_MODEL.md` (if any) to `workspace/archive/kb/THREAT_MODEL_pass_${N}.md` BEFORE overwriting"), `:120` ("If `--snapshot_id` was passed → `CUR` = that value").

#### (b) Use case 2 — stale carry-forward between passes and the critic freshness check

Scenario: pass 9 runs with the snapshot unchanged (`PREV_TM == CUR` → `SYNC_OCCURRED = false`). The skill may reuse the prior model's substance but MUST insert the verbatim STALE banner naming the carried snapshot; the downstream critic reads that banner as a KB freshness check and refuses to trust stale KB as if it were re-derived.

```bash
# Sync decision ladder (SKILL.md:120): CUR comes from --snapshot_id (or state);
# the first ^KB_SNAPSHOT: line of the existing model is PREV_TM (SKILL.md:126).

# Stale pass output — banner is verbatim (SKILL.md:244-247):
head -3 workspace/kb/THREAT_MODEL.md
# KB_SNAPSHOT: 1e15346c2ca2d6e7db57ced59615bb9d1685992f
# ...
# > STALE: Threat model NOT re-evaluated this pass; carried unchanged from snapshot 1e15346c2ca2d6e7db57ced59615bb9d1685992f.

# Fresh pass (SYNC_OCCURRED == true): banner MUST NOT be emitted (SKILL.md:247).
grep -q '^> STALE:' workspace/kb/THREAT_MODEL.md \
  && echo "KB is STALE for critic's freshness check (SKILL.md:242)" \
  || echo "KB fresh"

# Risk surface if a harness drops the banner (SKILL.md:188): the critic would
# mark EVERY finding SAMPLE_OR_TEST — the banner is what keeps the pipeline honest.
```

Evidence: `skills/mantis-threat-model/SKILL.md:120` (CUR derivation), `:126` ("FIRST line matching `^KB_SNAPSHOT:` in the existing"), `:188` ("`/mantis-critic` marks EVERY finding `SAMPLE_OR_TEST`"), `:242` ("`mantis-critic` reads it as a KB freshness check"), `:244-247` (STALE banner rule; verbatim banner at `:246`).

#### (d) Deps to pull when reusing this item

- Upstream KB inputs produced by earlier stages: `workspace/kb/architecture.md`, `workspace/kb/entities/*.md` (`skills/mantis-threat-model/SKILL.md:43-44`).
- Workspace state: `workspace/.mantis_state.json` (`pass_number`, `active_snapshot` provenance — optional; absent → degraded) `:38-42`; archive dir `workspace/archive/kb/` `:51-52`.
- Downstream consumer: `skills/mantis-critic` freshness check `:242` (+ failure mode `:188`).
- Never reads target source — findings-only role `:31-32`.

#### (e) Item build

SKIPPED (honest) — `ls skills/mantis-threat-model` shows only `SKILL.md` (13,311 bytes); no build file; census `1 md / 251 LOC` matches gm-02.

---

## 3. Traceability summary (merged w1 + w2)

| s_id | module | worker | Examples | Distinct evidence citations | All grep-verified on PIN |
|---|---|---|---|---|---|
| s14 | mantis-reproduce | u_w1 | 2 | 17 | yes |
| s26 | schema-contract | u_w1 | 2 | 14 | yes |
| s21 | reference-evals | u_w1 | 2 | 17 | yes |
| s03 | mantis-calibrate | u_w1 | 2 | 15 | yes |
| s06 | mantis-dedupe | u_w2 | 2 | 20 | yes |
| s16 | mantis-review | u_w2 | 2 | 14 | yes |
| s09 | mantis-patch | u_w2 | 2 | 18 | yes |
| s19 | mantis-threat-model | u_w2 | 2 | 12 | yes |

Totals: 8/8 items covered (matches `u-checklist.json`), 16 use-case examples, 127 distinct evidence citations, 0 items without grep-verified evidence. Machine-readable ticks: `reports/mantis/u-status-w1.json` + `reports/mantis/u-status-w2.json` (8/8 `section_done: true`).

## 4. JSON block (nguồn sự thật máy-đọc)

```json
[
  {
    "s_id": "s14",
    "module": "mantis-reproduce",
    "worker": "u_w1",
    "stars": 5,
    "score_gm08": 21,
    "files_loc": "1 md / 828",
    "main_files": ["skills/mantis-reproduce/SKILL.md"],
    "use_when": "Orchestrator Stage 9 + patcher verify loop: design/execute crash reproducers in isolated sandboxes, verdicts gated on mechanical reached-sink evidence; --reattack mode = independent patch verifier (INV-1)",
    "deps_out": [
      "schema.json: top-level repro_attempts property (:22-24) + $defs/repro_attempts (:1014), finding reattack_status (:156), reattack_variants >=3 for failed_to_bypass (:175), reattack/patch_base_snapshot provenance (:259)",
      "workspace state: workspace/findings/ in-place updates, workspace/reproducers/, workspace/archive/.repro_attempts.json (+.lock, .tmp swap)",
      "sandbox/container runtime harness-provided: run_sandbox_with_evidence tool (reference/core/synthesizer.py:221)",
      "INV-1 downgrade contract with mantis-patch (atomic VERIFIED_SECURE -> VERIFICATION_FAILED, SKILL.md:63,:463)"
    ],
    "examples": 2,
    "build": "SKIPPED"
  },
  {
    "s_id": "s26",
    "module": "schema-contract",
    "worker": "u_w1",
    "stars": 5,
    "score_gm08": 21,
    "files_loc": "1 file / 1,058",
    "main_files": ["schema.json"],
    "use_when": "Contract root: harness builders + all 19 skills validate every inter-stage state file against draft-2020-12; description carries non-JSON contracts (Threat Model rules, Pass Lifecycle, SNAPSHOT_ID ladder, backward-compat safe-branch)",
    "deps_out": [
      "none across the item boundary - schema.json is the contract root; every consumer references it, it references nothing outside itself (gm-02 m26 deps_out)"
    ],
    "examples": 2,
    "build": "SKIPPED"
  },
  {
    "s_id": "s21",
    "module": "reference-evals",
    "worker": "u_w1",
    "stars": 5,
    "score_gm08": 20,
    "files_loc": "49 files / 8,111",
    "main_files": [
      "reference/evals/research_eval.py",
      "reference/evals/stage_agents.py",
      "reference/evals/run_eval.py",
      "reference/evals/sweep.py",
      "reference/evals/surveyor_benchmark.py",
      "reference/evals/README.md",
      "reference/evals/evolve/"
    ],
    "use_when": "Cheapest-first falsification of pipeline changes: Tier-1 zero-LLM surveyor ranking benchmark, Tier-2 researcher campaign eval, fixed-dataset single-stage benchmarks (run_eval.py --stage), paired resumable sweeps, Harness2 evolve loop",
    "deps_out": [
      "reference/core (m20) imported from 9 files: sweep.py:394 core.config.is_auth_error; run_eval.py:27-28 core.context + core.database; research_eval.py:445,513,755,769,840-841,889,941,1071 (core.graph_loader, core.transcript, core.harness_context.assert_no_grader_verdicts, tools.TOOLS, core.database, core.structural_index.build_structural_index); stage_agents.py:23-27,136,165,188; surveyor_benchmark.py:219 core.surveyor._group_key; deduplicator_agent/agent.py:21,24; evolve/surface.py:63,153,285,329; evolve/adapter.py:234,472,595,632; evolve/proposer.py:126,415",
      "reference/tools (m23): from tools import TOOLS (stage_agents.py:27, research_eval.py:769, deduplicator_agent/agent.py:24, evolve/surface.py:285)",
      "external: google.adk (run_eval.py:31, stage_agents.py:20-22)",
      "intra-boundary: from evals.stage_agents import build_stage_agent (run_eval.py:29); datasets are the item's own *.json files"
    ],
    "examples": 2,
    "build": "SKIPPED"
  },
  {
    "s_id": "s03",
    "module": "mantis-calibrate",
    "worker": "u_w1",
    "stars": 4,
    "score_gm08": 22,
    "files_loc": "2 md / 912",
    "main_files": [
      "skills/mantis-calibrate/SKILL.md",
      "skills/mantis-calibrate/references/calibration_rules.md"
    ],
    "use_when": "Orchestrator Stage 12 final scoring: load processed findings, apply THREAT_MODEL boundary overrides, stamp 1-10 mantis_risk_score/priority bounded by the 27 sanity-triage rules; idempotent re-runs",
    "deps_out": [
      "workspace state only: workspace/findings/*.json updated in place + per-pass history entry with snapshot provenance (SKILL.md:33-41)",
      "workspace/kb/THREAT_MODEL.md (boundary overrides)",
      "workspace/.mantis_state.json (active_snapshot)",
      "reusable helper workspace/helpers/append_calibrate.py (:41, written at :556-559)",
      "no reference/ script and no ${MANTIS_HOME} command (0 grep matches - pure agent-procedure skill)"
    ],
    "examples": 2,
    "build": "SKIPPED"
  },
  {
    "s_id": "s06",
    "module": "mantis-dedupe",
    "worker": "u_w2",
    "stars": 4,
    "score_gm08": 22,
    "files_loc": "1 md / 371",
    "main_files": ["skills/mantis-dedupe/SKILL.md"],
    "use_when": "Orchestrator Stage 6 consolidator: cluster findings, hard-trash only snapshot-MATCHED duplicates (pairwise discovery_commit), keep NOT_MATCHED with soft possible_duplicate_of, 3-Tier dedup ladder, versioned helper + tx log",
    "deps_out": [
      "schema.json finding contracts: duplicate_of (schema.json:108), possible_duplicate_of (:265-267), signature (:273-275), lineage_id (:279)",
      "workspace state: workspace/findings/ (+.trash/), workspace/archive/findings_pass_*/ + legacy loop*_findings/, workspace/.mantis_state.json (active_snapshot, pass_number), workspace/.tx_log.jsonl, workspace/helpers/merge_findings.py",
      "embedding engine config vertex_ai/gemini-embedding-001 + EMBEDDING_SIMILARITY_THRESHOLD (harness-provided, SKILL.md:268-291)",
      "zero reference/-script references - pure agent-procedure skill"
    ],
    "examples": 2,
    "build": "SKIPPED"
  },
  {
    "s_id": "s16",
    "module": "mantis-review",
    "worker": "u_w2",
    "stars": 4,
    "score_gm08": 21,
    "files_loc": "1 md / 437",
    "main_files": ["skills/mantis-review/SKILL.md"],
    "use_when": "Orchestrator Stage 7 adversarial validator: re-read code_paths under pinned CODE_ROOT, 13 negative rules -> triage_checklist, finalize VALID/FALSE_POSITIVE/PROVISIONALLY_VALID/NEEDS_RESEARCH, idempotent re-review keyed (pass_number, snapshot)",
    "deps_out": [
      "schema.json triage/state validation rules cited by line (SKILL.md:183,:325,:338,:348)",
      "workspace state: workspace/findings/ in-place updates (status/reasoning/repro_hints/triage_checklist/history :35-38), workspace/helpers/append_review.py (:38,:358-379), workspace/.mantis_state.json (:27-29)",
      "target source reads under resolved CODE_ROOT (pinned snapshot :32-34,:116-122)",
      "output statuses consumed downstream by @mantis-critic / @mantis-reproduce / @mantis-calibrate (meta-agent Stages 8-12); no reference/*.py invocation"
    ],
    "examples": 2,
    "build": "SKIPPED"
  },
  {
    "s_id": "s09",
    "module": "mantis-patch",
    "worker": "u_w2",
    "stars": 4,
    "score_gm08": 20,
    "files_loc": "2 md / 823",
    "main_files": [
      "skills/mantis-patch/SKILL.md",
      "skills/mantis-patch/references/patch_rebasing.md"
    ],
    "use_when": "Orchestrator Stage 11 fix stage: minimal patches under shadow isolation (PINNED -> Option A MANDATORY), Block F reached-sink + Block G baseline gates, VERIFIED_SECURE only after fresh @mantis-reproduce --reattack fails to bypass with >=3 variants, 3-way rebasing",
    "deps_out": [
      "@mantis-reproduce --reattack --target_root=<PATCHED_SHADOW_ROOT> --snapshot_pinned=false --state_root=<state_root> --finding_id=... sub-agent invocation (SKILL.md:628-651)",
      "findings JSON fields: patch_status, patch_base_snapshot, patch_diff, reattack_status/_file_path/_run_command/_output/_variants, history (:745-771)",
      "workspace layout: workspace/helpers/append_patch.py (:58,:733-743), workspace/reproducers/ + workspace/helpers/ preserved on rollback (:714-718), workspace/findings/.trash/<uuid>.json + archive duplicate search (:229-235), <state_root>/.mantis_snapshots/ prior-pass snapshot for rebasing (:445-448), workspace/.mantis_state.json changed_files (:469-471), workspace/.workspace_edit.lock (:411-417)",
      "reference doc references/patch_rebasing.md (load-trigger :3-10); no direct reference/*.py invocation"
    ],
    "examples": 2,
    "build": "SKIPPED"
  },
  {
    "s_id": "s19",
    "module": "mantis-threat-model",
    "worker": "u_w2",
    "stars": 4,
    "score_gm08": 20,
    "files_loc": "1 md / 251",
    "main_files": ["skills/mantis-threat-model/SKILL.md"],
    "use_when": "Orchestrator Stage 3 KB generator: synthesize trust boundaries/attack surfaces/attacker profiles into workspace/kb/THREAT_MODEL.md (KB_SNAPSHOT: provenance, STALE banner for critic freshness check); findings-only, never reads target source",
    "deps_out": [
      "workspace state: workspace/kb/THREAT_MODEL.md (the living deliverable, state-relative :46-55; first line is a KB_SNAPSHOT: provenance line :47)",
      "workspace/kb/architecture.md + workspace/kb/entities/*.md (KB inputs produced by upstream KB stages)",
      "workspace/.mantis_state.json (pass_number, active_snapshot provenance :36-39)",
      "pass archive workspace/archive/kb/THREAT_MODEL_pass_${N}.md (:50)",
      "downstream mantis-critic freshness check (:242); never reads target source (:31-33); no reference/ script, no ${MANTIS_HOME} command"
    ],
    "examples": 2,
    "build": "SKIPPED"
  }
]
```
