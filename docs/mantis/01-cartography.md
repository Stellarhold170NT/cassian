---
subject: google/mantis
measured_at: 1e15346c2ca2d6e7db57ced59615bb9d1685992f
status: final
---


# Cartography

## 1. git log -1 + commit count

**Command:**
```
git log -1 --format='%H %ci %s'
git rev-list --count HEAD
```

**Raw output:**
```
1e15346c2ca2d6e7db57ced59615bb9d1685992f 2026-11-02 17:16:36 -0800 Merge "AUTO_UPDATE FIX:  Update joserfc from 1.7.5 to 1.7.6 in reference/requirements.txt" into main
109
```

**Comment:** HEAD is a requirements bump merge; count is from a shallow clone (`--depth 100` requested; negotiation fetched 109 reachable commits — treat as lower bound of full history).

## 2. LICENSE gate

**Command:** `ls LICENSE*`

**Raw output:**
```
LICENSE
```

**Comment:** LICENSE present → gate PASS, node continues (BLOCKED only if absent).

## 3. Census LOC (per-extension, then summed — v9 formula; NOT `xargs wc -l | tail -1`)

**Command:**
```
for ext in py md yml; do
  n=$(find . -type f -name "*.$ext" -not -path './.git/*' | wc -l)
  l=$(find . -type f -name "*.$ext" -not -path './.git/*' -print0 | xargs -0 cat | wc -l)
  echo "EXT .$ext files=$n lines=$l"
done
```

**Raw output:**
```
EXT .py files=185 lines=96332
EXT .md files=38 lines=14345
EXT .yml files=4 lines=546
```

**Comment:** Total 227 files / 111,223 lines across py+md+yml; Python dominates (86.6% of lines) — Go-style census extensions from other subjects are not applicable here.

## 4. Build manifests (verbatim)

### 4a. `reference/requirements.in` (421 bytes, verbatim)
```
google-adk==2.11.0
litellm==1.101.3
pydantic>=2.4.0
microsandbox==0.7.2
pyyaml==6.0.3
google-cloud-aiplatform==2.2.0
anthropic
tree-sitter==0.26.0
tree-sitter-language-pack==1.20.0
mcp>=1.2.0


# Security floors on transitive dependencies (pulled in via litellm / google-adk).
# Keep these at or above the first fixed release; pip-compile carries them into
# requirements.txt with hashes.
aiohttp>=3.14.4
multidict>=6.9.1
```

### 4b. `reference/sandbox/requirements.in` (80 bytes, verbatim)
```
flask


# Security floor on a transitive dependency (via flask).
werkzeug>=3.1.9
```

### 4c. `reference/install.sh` (5,474 bytes, verbatim — declaration-relevant parts)
```bash
#!/bin/bash
# Copyright 2026 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


set -e


cd "$(dirname "$0")"


# --- Platform Gate ---
OS="$(uname -s)"
case "$OS" in
    Linux)
        # Standard Linux environment (including WSL2)
        ;;
    Darwin)
        if [ "$(uname -m)" = "arm64" ]; then
            echo "macOS (Apple Silicon) detected: microsandbox microVMs run via Hypervisor.framework."
        else
            echo "WARNING: macOS on Intel is unsupported for microVM isolation."
            echo "         Set sandbox.type to 'static-only' in workflow.json for static-only analysis."
        fi
        ;;
    CYGWIN*|MINGW*|MSYS*)
        echo "ERROR: Native Windows is not supported due to shell and virtualenv layout differences (.venv/Scripts vs .venv/bin)." >&2
        echo "       Please use WSL2 (Windows Subsystem for Linux), where Mantis runs unmodified." >&2
        exit 1
        ;;
    *)
        echo "WARNING: Unrecognized platform '$OS'. Proceeding with standard installation..."
        ;;
esac


# --- Python Version Gate ---
if ! python3 -c 'import sys; sys.exit(0 if sys.version_info >= (3, 12) else 1)' 2>/dev/null; then
    echo "ERROR: Mantis requires Python 3.12 or newer." >&2
    echo "       Current interpreter: $(python3 --version 2>&1 || echo 'none')" >&2
    exit 1
fi


echo "Setting up virtual environment..."
python3 -m venv .venv
source .venv/bin/activate


echo "Installing dependencies..."
pip install --require-hashes -r requirements.txt


# --- Sandbox image (optional: enables dynamic reproduction) ---
TAG="mantis-sandbox:latest"


build_image() {
    local tool="$1" tar
    tar="$(mktemp -t mantis-sandbox-XXXXXX.tar)"
    local status=0
    {
        "$tool" build -t "$TAG" ./sandbox &&
        case "$tool" in
            buildah) buildah push "$TAG" "oci-archive:$tar" ;;
            podman)  podman save --format oci-archive -o "$tar" "$TAG" ;;
            docker)  docker save -o "$tar" "$TAG" ;;
        esac &&
        .venv/bin/msb image load -i "$tar" -t "$TAG"
    } || status=$?
    rm -f "$tar"
    return "$status"
}


if .venv/bin/msb image list 2>/dev/null | grep -q "mantis-sandbox"; then
    echo "Sandbox image '$TAG' already cached; skipping build."
else
    BUILD_SUCCESS=0
    for t in buildah podman docker; do
        if command -v "$t" >/dev/null 2>&1; then
            echo "Attempting to build sandbox image with $t..."
            if build_image "$t"; then
                BUILD_SUCCESS=1
                echo "Successfully built and loaded '$TAG' with $t."
                break
            else
                echo "Building with $t failed; trying next builder if available..."
            fi
        fi
    done


    if [ "$BUILD_SUCCESS" -eq 0 ]; then
        # Fallback: no container builder on this host (typical macOS dev
        # machine). Pull a pinned base image straight into the microsandbox
        # cache instead. This is the only time a pull happens -- the runtime
        # always boots with PullPolicy.NEVER. Keep this list in sync with
        # MICROSANDBOX_FALLBACK_IMAGES in scripts/configure.py.
        # mirror.gcr.io first: some networks block Docker Hub.
        PULL_SUCCESS=0
        for img in "mirror.gcr.io/library/python:3-slim" "docker.io/library/python:3-slim"; do
            echo "No container builder found; pulling base image '$img' into the sandbox cache..."
            if .venv/bin/msb image pull "$img"; then
                PULL_SUCCESS=1
                echo "Successfully cached '$img'. Auto-configure will select it as the guest image."
                break
            else
                echo "Pulling '$img' failed; trying next mirror if available..."
            fi
        done


        if [ "$PULL_SUCCESS" -eq 0 ]; then
            echo "WARNING: could not build (buildah, podman, docker) or pull a sandbox guest image."
            echo "         Dynamic reproduction needs a cached guest image; fix network/registry access"
            echo "         and re-run ./install.sh, or set sandbox.type to 'static-only' in workflow.json."
        fi
    fi
fi




# --- Authoritative MANTIS_HOME ---
# Skills instruct agents to anchor every script invocation via "$MANTIS_HOME/reference/...".
# That anchoring is what keeps an agent from executing a same-named script out of an
# untrusted checkout, so MANTIS_HOME must be set by something authoritative rather than
# left to the operator. Emit it as a sourceable file next to the install root.
MANTIS_HOME_DIR="$(cd .. && pwd)"
cat > mantis-env.sh <<EOF
# Generated by reference/install.sh. Source this before invoking Mantis skills.
export MANTIS_HOME="$MANTIS_HOME_DIR"
EOF
echo "Wrote reference/mantis-env.sh (export MANTIS_HOME=\"$MANTIS_HOME_DIR\")."
echo "Add 'source \"$MANTIS_HOME_DIR/reference/mantis-env.sh\"' to your shell profile so"
echo "skill invocations anchor to this installation instead of the current directory."


echo "Setup complete! You can now run ./run.sh"
```

### 4d. `schema.json` (55,021 bytes — structure, verbatim fragments)
Title/type: `"title": "Mantis Pipeline State Contract"`, `"$schema": "https://json-schema.org/draft/2020-12/schema"`, `"type": "object"`.

Top-level `properties` (verbatim, lines 6–28): `finding`, `plan`, `learning_entry`, `state`, `tx_log_entry`, `repro_attempts`, `execution_log_entry` — each a `$ref` into `#/$defs/…`.

`$defs` names (grep-verified, line: name): 30 `uuid`, 35 `finding`, 563 `plan`, 602 `learning_entry`, 715 `state`, 806 `history_entry`, 826 `triage_rule_evaluation`, 858 `triage_checklist`, 893 `calibration_outcome`, 898 `calibration_rule_evaluation`, 927 `calibration_checklist`, 990 `tx_log_entry`, 1014 `repro_attempts`, 1032 `execution_log_entry` — 14 sub-schemas total.

Harness contract embedded in the schema description (verbatim key sentence): *"Mantis runs under multiple harnesses (various CLIs, ADK, custom deterministic pipelines), so the snapshot lifecycle is a CONTRACT, not a property of one orchestrator. A harness is CONFORMANT iff, per pass, it: (1) SYNCs first (non-destructive, opt-in) as the very first action, never mid-pass; (2) detects vcs_info and computes SNAPSHOT_ID only AFTER sync; (3) PINs an immutable snapshot copy, writes the sentinel file `<SNAPSHOT_ROOT>/.mantis_snapshot_id` … (5) runs every stage with `--snapshot_root=<SNAPSHOT_ROOT> --snapshot_id=<SNAPSHOT_ID> --state_root=<workspace parent>`; (6) archives and increments the pass, keeping each retried finding's ORIGINAL discovery_commit."*

Zone contract (from the schema's Non-JSON Contracts section, verbatim): *"#### Threat Model (workspace/kb/THREAT_MODEL.md) … - **Trust Boundaries**: Zone definitions and entry points."* — zones live in the threat-model document, not in schema.json itself; SNAPSHOT_ID ladder tiers (verbatim from description): clean git/hg → `commit_hash`; dirty → `commit_hash + ':' + content_hash`; multi-vcs → `revision + ':' + content_hash`; copyable no-VCS → `'content:' + content_hash`; single binary → `'sha256:' + artifact_hash`; live endpoint → `'live:' + ISO8601 timestamp, with snapshot_pinned=false`.

**Comment:** The universe of this repo is a Python ADK-based agent pipeline: 19 agent skills + a canonical inter-stage JSON schema; install is a Python ≥3.12 venv with hash-pinned `requirements.txt` plus an optional microsandbox (msb) guest image.

## 5. Entrypoints

**Command:**
```
ls skills/mantis-*
grep -rn 'def main\|argparse' reference/main.py reference/core | head -10
```

**Raw output (ls condensed — full listing showed only `SKILL.md` (+ optional `references/` per skill)):**
```
skills/mantis-advise, mantis-architecture, mantis-calibrate, mantis-chain,
mantis-critic, mantis-dedupe, mantis-history, mantis-meta-agent, mantis-patch,
mantis-pipeline-adapter, mantis-plan, mantis-reflect, mantis-report,
mantis-reproduce, mantis-researcher, mantis-review, mantis-structural-index,
mantis-summarize, mantis-threat-model          # 19 skills total (ls -d | wc -l = 19)
```
```
reference/core/environments/patch_fallback.py:158:def main(argv)
```

**Supplementary evidence:** `ls reference/*.py` → `reference/main.py` (181,791 bytes), `reference/test_suite.py` (239,582 bytes). `grep -n "__main__" reference/main.py` → line 3566: `if __name__ == "__main__":`. Head of `reference/main.py` imports `google.adk.runners.Runner`, `google.adk.sessions.sqlite_session_service.SqliteSessionService`, `google.adk.apps.app.App`.

**Comment:** Primary executable entry is `reference/main.py` (monolithic 181 KB ADK runner with `__main__` guard at line 3566, no argparse — config-driven); the only `def main` under `reference/core` is a patch fallback environment; user-facing surface is the 19 `skills/mantis-*/SKILL.md` agent entrypoints. `install.sh` ends with "You can now run ./run.sh" → secondary launcher `./run.sh` at repo root.

## 6. Top directories (maxdepth 2)

**Command:** `find . -maxdepth 2 -type d -not -path './.git*' | sort | head -80`

**Raw output:**
```
.
./action
./reference
./reference/core
./reference/docs
./reference/evals
./reference/prompts
./reference/sandbox
./reference/scripts
./reference/skills
./reference/test_scan
./reference/test_targets
./reference/tests
./reference/third_party
./reference/tools
./skills
./skills/mantis-advise
./skills/mantis-architecture
./skills/mantis-calibrate
./skills/mantis-chain
./skills/mantis-critic
./skills/mantis-dedupe
./skills/mantis-history
./skills/mantis-meta-agent
./skills/mantis-patch
./skills/mantis-pipeline-adapter
./skills/mantis-plan
./skills/mantis-reflect
./skills/mantis-report
./skills/mantis-reproduce
./skills/mantis-researcher
./skills/mantis-review
./skills/mantis-structural-index
./skills/mantis-summarize
./skills/mantis-threat-model
```

**Comment:** Two top-level code roots: `reference/` (the Python engine: core, sandbox, tests, tools, third_party) and `skills/` (19 agent skill packages); `action/` is a small extra top-level dir to classify in later nodes.

## 7. Target repo check (read-only)

**Command (token one-shot, masked here; token never written to any file):**
```
git ls-remote https://x-access-token:$TOKEN@github.com/Stellarhold170NT/cassian.git
```

**Raw output:**
```
08efd28a4c2fb13821c138a0c8b59df9713f3650	HEAD
08efd28a4c2fb13821c138a0c8b59df9713f3650	refs/heads/main
```
Exit code: 0.

**Comment:** cassian reachable with token, HEAD on `main` = `08efd28a4c2fb13821c138a0c8b59df9713f3650` → status OK (no push performed by this node).

---

## Machine-readable block

```json
{
  "repo": "github.com/google/mantis",
  "upstream_branch": "main",
  "sha": "1e15346c2ca2d6e7db57ced59615bb9d1685992f",
  "commit_count_shallow": 109,
  "shallow_note": "clone --depth 100 --single-branch; rev-list --count HEAD = 109 (lower bound of full history)",
  "languages": {
    "py": {"files": 185, "lines": 96332},
    "md": {"files": 38, "lines": 14345},
    "yml": {"files": 4, "lines": 546},
    "total": {"files": 227, "lines": 111223}
  },
  "license_gate": "PASS (LICENSE present)",
  "manifests": {
    "requirements_in": {
      "path": "reference/requirements.in",
      "direct": ["google-adk==2.11.0", "litellm==1.101.3", "pydantic>=2.4.0", "microsandbox==0.7.2", "pyyaml==6.0.3", "google-cloud-aiplatform==2.2.0", "anthropic", "tree-sitter==0.26.0", "tree-sitter-language-pack==1.20.0", "mcp>=1.2.0"],
      "security_floors": ["aiohttp>=3.14.4", "multidict>=6.9.1"]
    },
    "sandbox_requirements_in": {
      "path": "reference/sandbox/requirements.in",
      "direct": ["flask"],
      "security_floors": ["werkzeug>=3.1.9"]
    },
    "install_sh": {
      "path": "reference/install.sh",
      "gates": ["Linux/WSL2 supported; macOS arm64 ok, Intel unsupported (static-only fallback); native Windows rejected", "Python >= 3.12"],
      "install": ["python3 -m venv .venv", "pip install --require-hashes -r requirements.txt", "optional microsandbox guest image via buildah|podman|docker -> msb image load (fallback pull python:3-slim from mirror.gcr.io)", "emits mantis-env.sh with authoritative MANTIS_HOME", "final launcher: ./run.sh"]
    },
    "schema_json": {
      "path": "schema.json",
      "title": "Mantis Pipeline State Contract",
      "dialect": "https://json-schema.org/draft/2020-12/schema",
      "top_level_properties": ["finding", "plan", "learning_entry", "state", "tx_log_entry", "repro_attempts", "execution_log_entry"],
      "defs": ["uuid", "finding", "plan", "learning_entry", "state", "history_entry", "triage_rule_evaluation", "triage_checklist", "calibration_outcome", "calibration_rule_evaluation", "calibration_checklist", "tx_log_entry", "repro_attempts", "execution_log_entry"],
      "mantis_skills": ["mantis-advise", "mantis-architecture", "mantis-calibrate", "mantis-chain", "mantis-critic", "mantis-dedupe", "mantis-history", "mantis-meta-agent", "mantis-patch", "mantis-pipeline-adapter", "mantis-plan", "mantis-reflect", "mantis-report", "mantis-reproduce", "mantis-researcher", "mantis-review", "mantis-structural-index", "mantis-summarize", "mantis-threat-model"],
      "mantis_skills_count": 19,
      "zone_harness": {
        "harness_contract": "Pass Lifecycle Contract (harness-agnostic, taught by mantis-pipeline-adapter): SYNC first (opt-in) -> detect vcs_info + compute SNAPSHOT_ID after sync -> PIN immutable snapshot + sentinel .mantis_snapshot_id + append exactly one snapshot_history entry -> record vcs_info/active_snapshot -> optional structural index (workspace/kb/structural_index/) -> run every stage with --snapshot_root/--snapshot_id/--state_root -> archive + increment pass",
        "snapshot_id_ladder": ["clean git/hg: commit_hash", "dirty git/hg: commit_hash + ':' + content_hash", "multi-vcs (.repo): revision + ':' + content_hash", "no-VCS copyable: 'content:' + content_hash", "single binary: 'sha256:' + artifact_hash", "live endpoint: 'live:' + ISO8601 timestamp, snapshot_pinned=false"],
        "zone_contract": "Trust zones/zones live in workspace/kb/THREAT_MODEL.md per schema.json Non-JSON Contracts (Trust Boundaries = Zone definitions and entry points; DoS targets need Availability Tier CRITICAL/STANDARD/LOW_CRITICALITY)"
      }
    }
  },
  "entrypoints": {
    "primary": "reference/main.py (181,791 bytes; __main__ guard at line 3566; google-adk Runner/SqliteSessionService; no argparse)",
    "secondary": "./run.sh (referenced by install.sh final line)",
    "core_def_main": "reference/core/environments/patch_fallback.py:158:def main(argv)",
    "agent_skills": "19 x skills/mantis-*/SKILL.md (mantis-calibrate, mantis-patch, mantis-pipeline-adapter also ship references/)",
    "other_top_level_py": "reference/test_suite.py (239,582 bytes)"
  },
  "top_dirs": ["action", "reference", "reference/core", "reference/docs", "reference/evals", "reference/prompts", "reference/sandbox", "reference/scripts", "reference/skills", "reference/test_scan", "reference/test_targets", "reference/tests", "reference/third_party", "reference/tools", "skills"],
  "cassian_target": {
    "repo": "github.com/Stellarhold170NT/cassian",
    "status": "OK",
    "head": "08efd28a4c2fb13821c138a0c8b59df9713f3650",
    "ref": "refs/heads/main",
    "pushed_by_this_node": false
  }
}
```
