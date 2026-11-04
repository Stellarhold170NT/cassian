---
subject: google/mantis
measured_at: 1e15346c2ca2d6e7db57ced59615bb9d1685992f
status: final
---


# Folders

## 1. Zone map (from `top_dirs` in gm-01, re-verified on the PIN tree)

Repo root (verified `ls -la`): `.github/`, `action/`, `reference/`, `skills/`, `schema.json`, `test_skills_integrity.py`, `README.md`, `README_AGENTS.md`, `AGENTS.md`, `CONTRIBUTING.md`, `LICENSE`, `.pre-commit-config.yaml`, `.pip-tools.toml`, `.gitignore`. The root README declares the three-layer model itself: `File: README.md | Dòng: 29-34 | Nội dung: "- [`skills/`](skills/) -- the method: the skills an agent loads on demand, from ..." / "- [`reference/`](reference/) -- an ADK harness that runs the method as a ..." / "- [`action/`](action/) -- a GitHub Action that runs the harness over a pull ..."`.

| # | Zone (path) | Measured on PIN | Role (one sentence) |
|---|---|---|---|
| Z1 | `skills/` | 19 dirs + `README.md`; 25 `.md` / 10,083 LOC | The agent-facing method layer: 19 `mantis-<stage>` skills, each one `SKILL.md` (+ optional `references/`) — `File: skills/README.md | Dòng: 3 | Nội dung: "Each directory is one skill: a `SKILL.md` an agent loads on demand, with any"`. |
| Z2 | `reference/core/` | 38 `.py` / 26,405 LOC | Python engine library of the ADK harness (config, DB, graph loader, surveyor, environments). |
| Z3 | `reference/tools/` | 4 `.py` / 3,247 LOC | The 30-entry `TOOLS` registry bound to every ADK agent (state CRUD, bounded readers, sandbox exec). |
| Z4 | `reference/scripts/` | 11 `.py` / 8,269 LOC | Operator/CI CLI surface (`launch.py`, `configure.py`, `pr_scan.py`, `mcp_server.py`, hygiene tools). |
| Z5 | `reference/evals/` | 48 `.py` + 1 `.md` / 8,111 LOC (+12 `.json` datasets) | Eval harnesses: surveyor benchmark, research eval, stage benchmarks, Harness² evolve loop. |
| Z6 | `reference/tests/` | 62 `.py` (61 `test_*.py` + `__init__.py`) | Verification oracle — the whole test suite lives here, physically outside the library it tests. |
| Z7 | `reference/skills/` | 2 `.md` (mantis-configure, mantis-launch) | The harness's own two operator skills (configure the run; launch via `run.sh`). |
| Z8 | `reference/docs/` | 3 `.md` (gce_sandbox_setup, github-action, mcp) | Operator docs for the GCE sandbox, the GitHub Action, and the MCP sidecar. |
| Z9 | `reference/prompts/` | 1 `.md` (system-researcher.md) | The researcher agent's system prompt template. |
| Z10 | `reference/sandbox/` | `Dockerfile` + `requirements.in/.txt` | The no-network guest image definition for reproducers/patchers. |
| Z11 | `reference/third_party/` | 16 `.py` + `LICENSE` + `VENDOR.md` + 1 `.diff` under `harness2/` | Vendored upstream package (`harness2`) with local patches, isolated from first-party code. |
| Z12 | `reference/test_scan/` + `reference/test_targets/` | 3 `.py` (15 + 128 + 128 LOC) | Deliberately vulnerable fixture apps used by the pipeline's self-scan (see §4). |
| Z13 | `reference/` root files | `main.py`, `test_suite.py`, `workflow.json` (172 lines), `README.md`, `install.sh`, `run.sh`, `requirements.in/.txt` | Executable top layer + launcher + pipeline graph config + install assets. |
| Z14 | `action/` | 1 `.yml` (`action.yml`, 211 LOC) | Composite GitHub Action "Mantis PR Scan" wrapping `reference/scripts/pr_scan.py`. |
| Z15 | `.github/workflows/` | 3 `.yml` (scorecard, mantis-knowledge-refresh, mantis-pr-scan) | Repo CI workflows; `mantis-pr-scan.yml` self-hosts the action (`uses: ./action`, per gm-02 m25). |

## 2. Representative zone in depth: `reference/core` (largest item in gm-02 — m20, 38 files / 26,405 LOC)

**Layout: one flat package + one subpackage.** `File: reference/core | Nội dung: find → subdirs = reference/core, reference/core/environments` — 30 modules at package root + 8 files in the single `environments/` subpackage; **no other nesting**.

- **By size (wc -l, descending):** `config.py` 3,174 → `graph_loader.py` 3,070 → `database.py` 2,898 → `planner.py` 1,956 → `surveyor.py` 1,471 → `synthesizer.py` 1,361 → `cost.py` 1,180 → `structural_index.py` 1,080 → `knowledge.py` 871 → `budget.py` 856 → `memory.py` 835 → … tail: `exclusions.py` 94, `context.py` 92, `sandbox.py` 43, `__init__.py` 13. Eight of the 38 files carry >1,000 LOC each — the package is flat but coarse-grained.
- **The one subpackage — execution environments.** `reference/core/environments/` holds `base.py` (127; `BaseEnvironment`), `static_env.py` (278), `gvisor_env.py` (392), `microsandbox_env.py` (316), `gce_env.py` (704), `staging.py` (150), `patch_fallback.py` (247), `__init__.py` (54). The `__init__` is a pure re-export facade: `File: reference/core/environments/__init__.py | Dòng: 15-19 | Nội dung: "from .base import BaseEnvironment, ProxyEnvironment, get_shared_proxy_environment / from .microsandbox_env import MicrosandboxEnvironment / from .gvisor_env import GvisorEnvironment / from .static_env import StaticOnlyEnvironment / from .gce_env import GceEnvironment"`.
- **Main code vs test — strictly separated.** `File: reference/core | Nội dung: find -name 'test_*.py' -o -name '*_test.py' → 0 hits` — zero tests inside the library. All 61 test modules live in the sibling `reference/tests/` (`test_adk_invariants.py`, `test_db_concurrency.py`, …), plus `reference/test_suite.py` (4,889 lines, gm-02 m24) at the `reference/` root. Reader rule: anything under `reference/core/**` is production code; anything under `reference/tests/**` is the executable spec.
- **Module name = module role.** `File: reference/core/surveyor.py | Dòng: 15-18 | Nội dung: "\"\"\"Phase 0: Deterministic Topographic Reconnaissance -- the Surveyor.\n\nProduces a ranked map of a repository (\"which areas are worth auditing, in what order\") *before* any model is involved. ...\""` — the same one-module-one-job pattern repeats across `config.py`, `database.py`, `graph_loader.py`, `budget.py`, `correlator.py`.

## 3. Naming conventions observed in code (5 conventions, each with examples from the PIN tree)

1. **Skills = kebab-case `mantis-<verb>` directories, one uppercase `SKILL.md` each.** Examples: `skills/mantis-advise`, `skills/mantis-calibrate`, `skills/mantis-pipeline-adapter` (all 19 verified by `ls -d skills/*/`; catalog `File: skills/README.md | Dòng: 8-9 | Nội dung: "| [`mantis-advise`](mantis-advise/SKILL.md) | Proactive security advisor..."`).
2. **Sandbox backend modules = `<name>_env.py`, classes PascalCase `...Environment`.** Examples: `gce_env.py` → `GceEnvironment`, `gvisor_env.py` → `GvisorEnvironment`, `microsandbox_env.py` → `MicrosandboxEnvironment`, `static_env.py` → `StaticOnlyEnvironment` (import block cited in §2).
3. **Test files = `test_<topic>.py`, one file per concern.** Examples: `reference/tests/test_adk_invariants.py`, `reference/tests/test_db_concurrency.py`, `reference/tests/test_budget_planner.py` (61 such files; zero other naming patterns in `reference/tests/`).
4. **CLI scripts = verb-first snake_case.** Examples: `reference/scripts/configure.py`, `reference/scripts/launch.py`, `reference/scripts/check_license_headers.py`, `reference/scripts/gen_skills_index.py`, `reference/scripts/neuter_matrix.py` (11 files).
5. **Core modules = single lowercase noun per responsibility.** Examples: `reference/core/config.py`, `reference/core/database.py`, `reference/core/graph_loader.py`, `reference/core/budget.py`, `reference/core/correlator.py` (30 root modules, all snake_case, no `utils.py`/`helpers.py` grab-bags found at package root).

## 4. Deviations from the Python+Markdown standard (each with ≥2 verified examples)

The repo is predominantly Python+Markdown, but a reader must expect these non-standard elements — all verified on the PIN tree (`find . ! -name '*.py' ! -name '*.md' ! -name '*.yml' -not -path './.git/*'`, full 30-file listing captured):

1. **Config/contract-as-data JSON at strategic points.** Examples: `schema.json` (repo root, 1,058 lines — the "Mantis Pipeline State Contract", gm-02 m26) and `reference/workflow.json` (172 lines — the pipeline graph consumed by `graph_loader.py`). Plus 12 eval datasets under `reference/evals/` (`calibrate_dataset.json`, `ground_truth/juice_shop.json`, …).
2. **Bash entry scripts (4).** Examples: `reference/install.sh` (the installer with platform/Python gates, quoted verbatim in gm-01 §4c) and `reference/run.sh` (the launcher calling `scripts/launch.py`); siblings `reference/scripts/setup_gce_sandbox.sh`, `reference/scripts/setup_github_action.sh`.
3. **Container + pip-tools packaging artifacts.** Examples: `reference/sandbox/Dockerfile` (guest image) and the `.in`/`.txt` hash-pinned pairs `reference/requirements.in` → `reference/requirements.txt` and `reference/sandbox/requirements.in` → `reference/sandbox/requirements.txt`; `File: .pip-tools.toml | Nội dung: 66 bytes at repo root, mirrored as reference/.pip-tools.toml`.
4. **Vendored third-party code with its own layout.** Examples: `reference/third_party/harness2/harness2/` (16 `.py` files that do not follow the first-party naming zones) and `reference/third_party/harness2/patches/0001-register-surface.diff` (a shipped patch file); own `LICENSE` + `VENDOR.md`.
5. **Deliberately vulnerable fixture apps inside the production tree.** Examples: `File: reference/test_scan/vulnerable.py | Dòng: 7-15 | Nội dung: "# SQL Injection vulnerability" ... "# Arbitrary code execution vulnerability" ... "eval(code)"` (15 LOC) and `reference/test_targets/app.py` / `vault_app.py` (128 lines each). These look like engine code by location but are bait corpora for self-scans — do not "fix" them (the evals README's never-fix rule for seeded flaws, gm-02 m21).
6. **One orphan root-level Python script.** Examples: `test_skills_integrity.py` (139 lines) — the only `.py` outside `reference/` (consistency checker for the skills catalog); no `__init__.py` accompanies it.
7. **A plural/singular near-collision in evals.** Examples: `reference/evals/research_target/` (the never-executed vulnerable corpus: `app.py`, `auth.py`, `config.py`, `dal/`, …) vs `reference/evals/research_targets/` (the generator package: `__init__.py`, `gen.py`) — same stem, different roles; easy to confuse when navigating.
8. **Mixed naming inside eval datasets.** Examples: `reference/evals/deduplication.test.json` (a `.test.` infix in a data file, unique among the 12 datasets) and `reference/evals/ground_truth/juice_shop.json` (ground-truth dir separate from `research_target/ground_truth.json` — two different ground-truth locations).

No other significant deviation was detected: YAML is confined to its conventional slots (`.pre-commit-config.yaml`, `.github/workflows/*.yml`, `action/action.yml`), and there are no notebooks, no compiled artifacts, and no live credentials in the tree — the scan `grep -rn "ghp_" . --exclude-dir=.git` (re-measured on this PIN tree) returns exactly 5 hits, all benign: the `SecretScrubber` redaction pattern `File: reference/core/llm_gateway.py | Dòng: 73 | Nội dung: "(re.compile(r\"ghp_[0-9a-zA-Z]{36}\"), \"[REDACTED_GITHUB_PAT]\")"` plus 4 fake-token fixture/assert lines in `reference/tests/test_adk_invariants.py:770,775` (`GH_TOKEN = "ghp_123456789012345678901234567890123456"` and its `assertNotIn("ghp_1234567890", wrapped)`) and `reference/tests/test_knowledge.py:49,103` (`token=ghp_ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789` and its `assertNotIn(... "credentials are scrubbed")`) — placeholder tokens used to test scrubbing, so the REDACTION rule holds (no real `ghp_` token committed).

## 5. Suggested reading order (what to read first, and why)

1. **`README.md` (root) → the three-layer map.** It states the architecture in one paragraph (`skills/` = method, `reference/` = harness, `action/` = CI, lines 29-34) — everything else hangs off that distinction.
2. **`skills/README.md` → `skills/mantis-meta-agent/SKILL.md`.** The 19-skill catalog first, then the orchestrator skill that delegates Stages 0-15 to the others (gm-02 m08); the skills are the product, the harness only realizes them.
3. **`schema.json`.** The state contract every stage reads/writes (`workspace/findings/*.json`, `.mantis_state.json`, …); without it the skill references to `SNAPSHOT_ID`/`discovery_commit`/`triage_checklist` are unreadable.
4. **`reference/README.md` → `reference/workflow.json` → `reference/main.py` (`__main__` at :3566) → `reference/core/config.py` → `graph_loader.py` → `database.py`.** This is the execution spine: run instructions, then the graph the runner loads, then the runner, then the three biggest core modules (config/graph_loader/database = 9,142 LOC combined) that everything else imports.
5. **`reference/core/environments/__init__.py` (54 lines) when you need the sandbox story**, then only the env file you care about — the facade tells you the full backend list in five import lines (§2).
6. **`reference/tests/` and `reference/test_suite.py` last, as the executable spec** — they encode the invariants (INV-1..5 per gm-02 m10) that explain *why* the skills are so defensive.
7. **Skip-with-awareness:** `reference/third_party/harness2/` (vendored, read only when touching the vendor), `reference/test_scan/` + `reference/test_targets/` (intentionally vulnerable bait — read, never "fix"), `reference/evals/research_target/` (same bait rule).

---

## Machine-readable block

```json
{
  "repo": "github.com/google/mantis",
  "pin": "1e15346c2ca2d6e7db57ced59615bb9d1685992f",
  "pin_match_gm01": true,
  "zones": ["skills", "reference/core", "reference/tools", "reference/scripts", "reference/evals", "reference/tests", "reference/skills", "reference/docs", "reference/prompts", "reference/sandbox", "reference/third_party", "reference/test_scan+test_targets", "reference-root", "action", ".github/workflows"],
  "representative": {"path": "reference/core", "files": 38, "loc": 26405, "root_modules": 30, "subpackage": "environments/ (8 files)", "tests_inside": 0},
  "naming_conventions": 5,
  "deviations": 8,
  "reading_order_steps": 7,
  "gm02_crosscheck": "core 38/26405; evals 49/8111; scripts 11/8269; tools 4/3247; tests 62; skills 25md/10083 — all match"
}
```
