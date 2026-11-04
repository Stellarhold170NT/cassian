// ============================================================================
// Mantis -- C4 model (Structurizr DSL)
// Subject : github.com/google/mantis @ PIN 1e15346c2ca2d6e7db57ced59615bb9d1685992f (branch main)
// Inputs  : reports/mantis/gm-01-cartography.md, reports/mantis/gm-02-module-map.md
// Layers  : L1 SystemContext, L2 Containers, L3 Components (3 core containers)
// Rule    : every element and relationship carries a "// evidence:" comment.
//           No evidence -> not in the model.
// ============================================================================

workspace {

  model {

    // ---------------------------------------------------------------- People

    // evidence: reference/README.md:20-26 (configure.py --auto / --test --probe / launch campaign)
    securityOperator = person "Security Operator" "Installs Mantis, configures workflow.json and launches review campaigns from the command line."

    // evidence: skills/mantis-advise/SKILL.md:29 (advise.py --file query); skills/mantis-report/SKILL.md:41,365 (review_packet-latest.md)
    developer = person "Developer / Code Reviewer" "Queries proactive security advice before code edits and consumes the review packet for the audited codebase."

    // evidence: .github/workflows/mantis-pr-scan.yml:63 (uses: ./action); action/action.yml:1-11
    ciPipeline = person "CI Pipeline" "Runs the Mantis PR Scan composite action on pull_request events to audit changed PR files."

    // evidence: reference/docs/mcp.md:1-3 (scripts/mcp_server.py as live sidecar); reference/scripts/mcp_server.py:18-19
    mcpAgent = person "External MCP Agent" "Coding agent connecting to the Mantis MCP sidecar for deterministic security knowledge."

    // ---------------------------------------------------------------- System

    // evidence: schema.json:2-4 (title: Mantis Pipeline State Contract); skills/README.md:8-26 (19-skill catalog)
    mantis = softwareSystem "Mantis" "Portable toolkit for building secure software: 19 agent skills (the method) plus an ADK reference harness that runs an automated security review pipeline." {

      // ---------------------------------------------------------- L2 containers

      // evidence: reference/main.py:3566-3574 (__main__ -> scripts/launch.py); reference/README.md:20-26; reference/main.py:292,527,902
      referenceHarness = container "Reference Harness" "ADK campaign runner: monolithic main.py drives _drive_campaign over scan targets; install.sh + run.sh entry points." "Python 3.12 + Google ADK" {

        // evidence: reference/main.py:292 (async def _drive_campaign), :527 (def discover_files), :902 (def resolve_scan_targets)
        campaignRunner = component "CampaignRunner" "Async _drive_campaign executes the ADK App over scan targets with budgeted LLM sessions and transcript/spend reporting." "Python (reference/main.py, 3582 lines)"

        // evidence: reference/main.py:3566-3574 (if __name__ == __main__: from scripts.launch import main)
        cliEntry = component "CliEntry" "Main entry guard delegating to scripts/launch.py main()."

        // evidence: reference/skills/mantis-launch/SKILL.md:31 (run.sh anchoring via MANTIS_HOME)
        harnessSkills = component "Operator Skills" "mantis-launch and mantis-configure skills anchoring MANTIS_HOME/reference/run.sh for operators and agents."

        // evidence: reference/sandbox/Dockerfile:1-5 (reproducer/patcher guest, no network, FROM python:3-slim); reference/install.sh:72 (msb image load)
        sandboxImage = component "Sandbox Guest Image" "reference/sandbox Dockerfile plus hash-pinned requirements, built to mantis-sandbox:latest and loaded into the microsandbox cache."

        // evidence: reference/test_suite.py:78-90 (imports main + tools.research_tools + tools.sandbox_tools)
        selfTestSuite = component "Self-Test Suite" "4889-line self-test suite over main, core and tools." "Python (reference/test_suite.py)"
      }

      // evidence: reference/run.sh:45 (python3 scripts/launch.py); def main at launch.py:762, configure.py:1400, mcp_server.py:1026, advise.py:703; mcp_server.py:18-19; pr_scan.py:18-19
      operatorCli = container "Operator & CI CLI" "Operator/CI scripts: launch.py (campaign launcher), configure.py (workflow.json configurator), pr_scan.py (PR diff audit), mcp_server.py (MCP sidecar), advise.py + knowledge.py (advisory), neuter_matrix.py (guard mutation testing)." "Python CLI (reference/scripts)"

      // evidence: reference/main.py:41-57 (core.* imports); census in reports/mantis/gm-02-module-map.md item m20 (38 files / 26405 LOC)
      coreEngine = container "Core Engine Library" "Engine library: LLM provider config/retry, SQLite state store, workflow graph loader + synthesizer, LLM egress gateway, execution environments, surveyor, structural index, budget." "Python library (reference/core)" {

        // evidence: reference/core/config.py:266-267 (DEFAULT_MODEL, SUPPORTED_SANDBOXES)
        providerConfig = component "Provider Config" "LLM provider/model config, retry and auth-error classification (is_rate_limit_error, MantisAuthError, ResilientLiteLlm)." "Python (core/config.py)"

        // evidence: reference/core/database.py:70 (def connect); init_db and is_suppressed per gm-02 item m20
        stateDatabase = component "State Database" "SQLite findings/state/knowledge store: connect, init_db, read/write findings, risk scores, suppression checks." "Python (core/database.py)"

        // evidence: reference/core/graph_loader.py:94 (class AgentNode), :213 (class WorkflowSpec); reference/workflow.json:1-15 (mantis_vulnerability_pipeline)
        graphLoader = component "Graph Loader" "Parses reference/workflow.json (mantis_vulnerability_pipeline: agent + classifier nodes) into WorkflowSpec/AgentNode graphs." "Python (core/graph_loader.py)"

        // evidence: reference/core/synthesizer.py:58 (from tools import TOOLS); Known Skills list consumed by orchestrator stages per gm-02 item m08
        graphSynthesizer = component "Graph Synthesizer" "ResearchGraphSynthesizer/WorkflowSynthesizer assembling agent graphs; knows the mantis-* skill surface." "Python (core/synthesizer.py)"

        // evidence: reference/core/llm_gateway.py:60 (class SecretScrubber), :139 (def wrap_untrusted_content), :291 (def sanitize_egress_text)
        llmGateway = component "LLM Egress Gateway" "Secret scrubbing, untrusted-content wrapping and egress sanitization for all LLM traffic." "Python (core/llm_gateway.py)"

        // evidence: reference/core/environments/base.py:24 (class BaseEnvironment), :47 (class ProxyEnvironment); static/gvisor/microsandbox/gce/staging/patch_fallback modules (patch_fallback.py:158 def main)
        executionEnvironments = component "Execution Environments" "Isolated execution backends: static, gVisor, microsandbox, GCE, staging vetting and pure-Python patch_fallback." "Python (core/environments/)"

        // evidence: reference/core/surveyor.py:919-921 (lazy tools import comment)
        surveyor = component "Surveyor" "Zero-LLM candidate ranking surveyor; lazy tools import to avoid the core-tools cycle." "Python (core/surveyor.py)"

        // evidence: reference/core/structural_index.py:20 (subset of the mantis-structural-index spec: a SQLite catalog with symbols...)
        structuralIndexCore = component "Structural Index Core" "In-harness SQLite symbol/call-edge catalog implementing a subset of the mantis-structural-index spec." "Python (core/structural_index.py)"

        // evidence: reference/core/budget.py:63 (parse_duration_seconds), :101 (parse_token_budget), :139 (class BudgetConfig); reference/workflow.json:15-22 (budget caps)
        budget = component "Budget" "Wall-clock/token/graph-step/llm-call budget parsing and enforcement (BudgetConfig, BudgetController)." "Python (core/budget.py)"

        // evidence: reference/core/schemas.py:260,269,275,281,329 (VulnerabilityReport, ReviewVerdict, CriticVerdict, ReproVerdict, ExecutiveReport); reference/core/sarif.py:324 (mantis-patch-status)
        schemasAndSarif = component "Schemas & SARIF" "Pydantic inter-stage models (VulnerabilityReport, ReviewVerdict, CriticVerdict, ReproVerdict, ExecutiveReport) and SARIF export." "Python (core/schemas.py, core/sarif.py)"

        // evidence: reference/core/ module set (knowledge.py, memory.py, chains.py, correlator.py, planner.py, context.py, transcript.py, truncation.py, paths.py, compactor.py, harness_context.py, evidence.py, poc_scaffold.py, exclusions.py, diversity.py, custom_tools.py, sandbox.py) per census gm-02 item m20
        supportServices = component "Support Services" "Knowledge, memory, chains, correlator, planner, run context, transcript, truncation, paths, compactor, harness context, evidence, PoC scaffold and sandbox glue." "Python (core/*)"
      }

      // evidence: reference/tools/__init__.py:54 (TOOLS: dict[str, object] = {, 30 entries); sandbox_tools.py:26 (MANTIS_SENTINEL_TOKEN), :436 (run_sandbox_with_evidence)
      agentTools = container "Agent Tool Registry" "30-entry TOOLS registry bound to every ADK agent: bounded file/git readers, findings/state CRUD, sandboxed PoC execution with reached-sink evidence, structural-index navigation." "Python package (reference/tools)"

      // evidence: skills/mantis-meta-agent/SKILL.md:155-157 (SYNC first), :254-256 (PIN after sync), :343-345 (RECORD), :421-514 (Stage 0-15 delegation)
      metaAgent = container "Meta-Agent Orchestrator Skill" "Persistent campaign supervisor implementing the Pass Lifecycle Contract: SYNC, VCS detect, PIN immutable snapshot, RECORD state, delegate Stages 0-15, archive and increment pass." "Agent skill (skills/mantis-meta-agent/SKILL.md)"

      // evidence: skills/README.md:8-26 (skill rows); stage map skills/mantis-meta-agent/SKILL.md:421-512
      stageSkills = container "Pipeline Stage Skill Suite" "The 18 remaining skills: KB builders, audit chain, verify/fix, closing stages, advisor and pipeline consultant." "Agent skills (skills/mantis-*/SKILL.md)" {

        // evidence: skills/mantis-meta-agent/SKILL.md:421-450 (Stages 0, 0.5, 1, 2, 3)
        kbStages = component "KB Builder Stages" "mantis-history (Stage 0 VCS mining), mantis-structural-index (Stage 0.5), mantis-summarize (Stage 1), mantis-architecture (Stage 2 KB synthesizer), mantis-threat-model (Stage 3 THREAT_MODEL.md with trust-boundary zones)." "Agent skills"

        // evidence: skills/mantis-meta-agent/SKILL.md:452-467 (Stages 4-8)
        auditStages = component "Audit & Validation Stages" "mantis-plan (Stage 4 plan.json roadmap), mantis-researcher (Stage 5 findings), mantis-dedupe (Stage 6), mantis-review (Stage 7, 13-rule filter), mantis-critic (Stage 8 viability)." "Agent skills"

        // evidence: skills/mantis-meta-agent/SKILL.md:469-485 (Stages 9-12)
        verifyFixStages = component "Verify & Fix Stages" "mantis-reproduce (Stage 9 PoC + reached-sink gate), mantis-chain (Stage 10 exploit chains), mantis-patch (Stage 11 shadow-dir patches + reattack), mantis-calibrate (Stage 12 risk score)." "Agent skills"

        // evidence: skills/mantis-meta-agent/SKILL.md:487-520 (Stages 13-15)
        closingStages = component "Closing Stages" "mantis-reflect (Stage 13 trajectory learnings), mantis-report (Stage 14 review packet), Stage 15 archive re-verification." "Agent skills"

        // evidence: skills/README.md:8 (advisor row); skills/mantis-advise/SKILL.md:29 (advise.py --file)
        advisorSkill = component "Advisor Skill" "mantis-advise: proactive per-file security advisor and remediation dossier generator." "Agent skill"

        // evidence: schema.json:4 (Pass Lifecycle Contract taught by mantis-pipeline-adapter); skills/mantis-pipeline-adapter/SKILL.md:325,334
        adapterSkill = component "Pipeline Consultant Skill" "mantis-pipeline-adapter: teaches harness builders the reference architecture and the harness-agnostic Pass Lifecycle Contract." "Agent skill"
      }

      // evidence: schema.json:2-4 (title + description listing the 7 top-level properties and $defs validation)
      stateContract = container "Pipeline State Contract" "schema.json: draft-2020-12 JSON Schema (7 top-level properties, 14 defs) plus Non-JSON Contracts: Pass Lifecycle, SNAPSHOT_ID ladder, THREAT_MODEL zones." "JSON Schema (schema.json)"

      // evidence: schema.json:4 (workspace/.mantis_state.json validated against defs/state); skills/mantis-researcher/SKILL.md:50-52 (findings writes); skills/mantis-report/SKILL.md:41 (review_packet-latest.md); skills/mantis-advise/SKILL.md:29 (knowledge.db)
      workspaceState = container "Workspace State Store" "Per-campaign state: .mantis_state.json, plan.json, findings/, learnings.jsonl, kb/ (THREAT_MODEL.md, architecture.md, structural_index/), reproducers/, archive/, knowledge.db." "JSON/JSONL/Markdown files + SQLite"

      // evidence: action/action.yml:1-11 (name Mantis PR Scan, advisory by default); :211 (invokes reference/scripts/pr_scan.py)
      prScanAction = container "Mantis PR Scan GitHub Action" "Composite GitHub Action wrapping pr_scan.py: 12 inputs, verdict PASS/REVIEW/BLOCK/NOT_RUN, advisory by default, credential-relocation step." "GitHub Actions composite action (action/action.yml)"

      // evidence: reference/evals/README.md:1-3 (Benchmarks for the reference pipeline, cheapest first); reference/evals/run_eval.py:24-31
      evals = container "Evaluation Harnesses" "Tier-1 zero-LLM surveyor benchmark, Tier-2 researcher campaign eval, stage-agent benchmarks, Harness-squared evolve loop." "Python (reference/evals)"
    }

    // -------------------------------------------------------- External systems

    // evidence: skills/mantis-meta-agent/SKILL.md:155-157 (SYNC first), :254-256 (PIN immutable snapshot after sync); skills/mantis-history/SKILL.md:26 (LIVE repository root, not the snapshot)
    targetRepo = softwareSystem "Audited Target Repository" "The LIVE codebase under review (git/hg/multi-vcs/none): Mantis syncs it, pins immutable per-pass snapshots, audits source files under CODE_ROOT."

    // evidence: reference/core/config.py:266 (DEFAULT_MODEL vertex_ai/gemini-3.8-flash); reference/requirements.in:2 (litellm==1.101.3), :7 (anthropic)
    llmProviders = softwareSystem "LLM Providers" "Inference backends reached through LiteLLM (default vertex_ai/gemini-3.8-flash; Anthropic also declared)."

    // evidence: reference/main.py:31-39 (google.adk Runner/RunConfig/SqliteSessionService/App imports); reference/requirements.in:1 (google-adk==2.11.0), :6 (google-cloud-aiplatform==2.2.0)
    googleAdk = softwareSystem "Google ADK / Vertex AI" "Agent Development Kit runtime (Runner, App, SqliteSessionService) and Vertex AI SDKs the reference harness executes on."

    // evidence: reference/core/config.py:267 (SUPPORTED_SANDBOSES static-only/static/gvisor/microsandbox/gce); reference/tools/sandbox_tools.py:436 (run_sandbox_with_evidence)
    sandboxRuntime = softwareSystem "Isolated Sandbox Runtime" "Guest execution runtimes for PoC and patch verification: microsandbox microVM, gVisor, GCE or static-only."

    // ------------------------------------------------------ L1 relationships

    // evidence: reference/README.md:20-26 (configure.py --auto, --test --probe, ./run.sh); reference/run.sh:45
    securityOperator -> referenceHarness "Installs, configures and launches review campaigns via run.sh and scripts/configure.py"

    // evidence: skills/mantis-advise/SKILL.md:29 (python3 ${MANTIS_HOME}/reference/scripts/advise.py --file)
    developer -> operatorCli "Queries per-file security advice (advise.py --file)"

    // evidence: skills/mantis-report/SKILL.md:41,365 (workspace/report/review_packet-latest.md)
    developer -> workspaceState "Reads workspace/report/review_packet-latest.md"

    // evidence: .github/workflows/mantis-pr-scan.yml:63 (- uses: ./action)
    ciPipeline -> prScanAction "Executes the composite action on pull_request events"

    // evidence: reference/docs/mcp.md:1-3; reference/scripts/mcp_server.py:18-19 (structural index, findings database, threat-model-informed security)
    mcpAgent -> operatorCli "MCP queries for structural index, findings database and threat model"

    // evidence: reference/main.py:527 (def discover_files), :902 (def resolve_scan_targets)
    referenceHarness -> targetRepo "Discovers and resolves scan targets in the audited tree"

    // evidence: skills/mantis-meta-agent/SKILL.md:155-157 (SYNC very first action of the pass), :254-256 (PIN immutable per-pass copy)
    metaAgent -> targetRepo "SYNCs the LIVE repo and PINs an immutable per-pass snapshot with SNAPSHOT_ID"

    // evidence: skills/mantis-history/SKILL.md:26 (reads VCS logs from the LIVE repository root, not the snapshot); skills/mantis-review/SKILL.md:135-141 (SNAPSHOT MODE determination)
    stageSkills -> targetRepo "Audits source under pinned CODE_ROOT and mines LIVE VCS history"

    // evidence: reference/main.py:31-39 (google.adk imports)
    referenceHarness -> googleAdk "Runs agent graphs on ADK Runner, App and SqliteSessionService"

    // evidence: reference/core/config.py:266 (DEFAULT_MODEL); reference/main.py:41-57 (ResilientLiteLlm import from core.config)
    coreEngine -> llmProviders "Calls LLM backends via ResilientLiteLlm with retry and auth classification"

    // evidence: reference/tools/sandbox_tools.py:436 (run_sandbox_with_evidence), :26 (MANTIS_SENTINEL_TOKEN reached-sink marker)
    agentTools -> sandboxRuntime "Executes PoC and patch verification commands in isolated guest environments"

    // ------------------------------------------------------ L2 relationships

    // evidence: reference/main.py:3566-3574 (__main__ -> scripts.launch main); reference/run.sh:45
    referenceHarness -> operatorCli "Delegates CLI entry and campaign launch to scripts/launch.py"

    // evidence: reference/main.py:41-57 (core.* import block)
    referenceHarness -> coreEngine "Imports budget/database/sandbox/graph_loader/context/transcript/paths/config/compactor/llm_gateway"

    // evidence: reference/workflow.json:25-97 (history, structural_index, architect, threat_modeler, planner, researcher, findings_gate, deduplicator, reviewer, critic nodes); reference/evals/stage_agents.py:36 (STAGE_CONFIGS), :122 (skill mapping mantis-<stage>)
    referenceHarness -> stageSkills "Executes stage skills as workflow.json agent nodes"

    // evidence: skills/mantis-meta-agent/SKILL.md:421-512 (Stage 0-15 delegation bullets)
    metaAgent -> stageSkills "Delegates Stages 0-15 to @mantis-* subagents with snapshot args"

    // evidence: skills/mantis-meta-agent/SKILL.md:343-345 (RECORD updates workspace/.mantis_state.json conforming to schema defs/state), :514 (Stage 15 Archive & KB Verification)
    metaAgent -> workspaceState "Records active_snapshot/snapshot_history and archives pass findings"

    // evidence: schema.json:4 (Validation Guidelines: validate findings/plan/learning_entry/state/execution_log_entry against defs); skills/mantis-review/SKILL.md:182-183 (schema.json lines 365-398 / 418-470)
    stageSkills -> stateContract "Validates findings, checklists and state files against schema defs"

    // evidence: skills/mantis-architecture/SKILL.md:55 (workspace/kb/dependencies.json); skills/mantis-threat-model/SKILL.md:47 (KB_SNAPSHOT provenance line); skills/mantis-researcher/SKILL.md:50-52 (findings writes)
    stageSkills -> workspaceState "Reads/writes plan.json, findings, learnings and the knowledge base"

    // evidence: reference/scripts/mcp_server.py:18-19 (exposes structural index, findings database, threat model); reference/scripts/knowledge.py:18 (knowledge.db export)
    operatorCli -> workspaceState "Serves findings database, threat model and knowledge.db to operators and MCP agents"

    // evidence: reference/scripts/launch.py:39-41 (core.budget/core.config/core.synthesizer imports); reference/scripts/configure.py:42 (core.config); reference/scripts/pr_scan.py:76 (core.config EXIT_AUTH)
    operatorCli -> coreEngine "CLI scripts import core budget/config/synthesizer/llm_gateway"

    // evidence: reference/core/synthesizer.py:58; reference/core/graph_loader.py:51 (both: from tools import TOOLS)
    coreEngine -> agentTools "Binds the TOOLS registry into synthesized agent graphs"

    // evidence: reference/tools/research_tools.py:24-25 (core.schemas/core.database imports); reference/core/surveyor.py:919-921 (lazy tools import comment)
    agentTools -> coreEngine "Lazy core.* imports (schemas, database, context, environments, llm_gateway, truncation, structural_index)"

    // evidence: reference/evals/run_eval.py:24-31 (sys.path bootstrap + core.context/core.database imports)
    evals -> coreEngine "Bootstraps reference/ sys.path and imports core.context/core.database"

    // evidence: reference/evals/stage_agents.py:122 (tools: list(TOOLS.keys()))
    evals -> agentTools "Stage agents bind the production TOOLS registry"

    // evidence: action/action.yml:211 (python .../reference/scripts/pr_scan.py with args)
    prScanAction -> operatorCli "Invokes reference/scripts/pr_scan.py with MANTIS_ACTION env"

    // ---------------------------------------------- L3: ReferenceHarness internals

    // evidence: reference/main.py:41-57 (graph_loader/context/config imports)
    campaignRunner -> graphLoader "Loads workflow.json graphs and drives them on the ADK Runner"

    // evidence: reference/main.py:41-46 (BudgetConfig/BudgetController imports)
    campaignRunner -> budget "Enforces wall-clock/token budgets during the campaign"

    // evidence: reference/test_suite.py:79-90 (tools.research_tools + tools.sandbox_tools imports)
    selfTestSuite -> agentTools "Exercises research and sandbox tools against main and core"

    // evidence: reference/skills/mantis-launch/SKILL.md:31 (run.sh anchoring); reference/main.py:3571-3574
    harnessSkills -> cliEntry "Invokes MANTIS_HOME/reference/run.sh (same program as main.py)"

    // evidence: reference/install.sh:72 (.venv/bin/msb image load); reference/sandbox/Dockerfile:1-5
    sandboxImage -> sandboxRuntime "Loaded into the microsandbox cache as mantis-sandbox:latest"

    // ---------------------------------------------- L3: CoreEngine internals

    // evidence: reference/core/synthesizer.py:58 (from tools import TOOLS)
    graphSynthesizer -> agentTools "Binds the TOOLS registry"

    // evidence: reference/core/graph_loader.py:51 (from tools import TOOLS)
    graphLoader -> agentTools "Binds the TOOLS registry"

    // evidence: reference/core/surveyor.py:919-921 (lazy import from tools.research_tools)
    surveyor -> agentTools "Lazy import of tools.research_tools git-jail helpers"

    // evidence: reference/core/config.py:266-267 (DEFAULT_MODEL, SUPPORTED_SANDBOXES)
    providerConfig -> llmProviders "Defaults to vertex_ai/gemini-3.8-flash; classifies rate-limit and auth errors"

    // evidence: reference/core/llm_gateway.py:291 (sanitize_egress_text)
    llmGateway -> llmProviders "Sanitizes egress text before it reaches model APIs"

    // evidence: reference/core/config.py:267 (SUPPORTED_SANDBOSES); reference/core/environments/base.py:24,47
    executionEnvironments -> sandboxRuntime "Boots static/gVisor/microsandbox/GCE execution environments"

    // ---------------------------------------------- L3: StageSkills internals

    // evidence: skills/mantis-architecture/SKILL.md:55 (kb/dependencies.json, import/dependency edges); skills/mantis-threat-model/SKILL.md:47 (KB_SNAPSHOT provenance line)
    kbStages -> auditStages "Hands the knowledge base (architecture, entities, THREAT_MODEL, dependencies.json) to planning and audit"

    // evidence: skills/mantis-meta-agent/SKILL.md:452-485 (ordered Stages 4-12); skills/mantis-researcher/SKILL.md:57 (hands findings to mantis-dedupe)
    auditStages -> verifyFixStages "Hands snapshot-matched validated findings to reproduce/chain/patch/calibrate"

    // evidence: skills/mantis-reproduce/SKILL.md:52 (state_root/workspace/reproducers); skills/mantis-patch/SKILL.md:637 (--target_root=PATCHED_SHADOW_ROOT)
    verifyFixStages -> workspaceState "Writes reproducers, patches and calibrated risk scores back into findings"

    // evidence: skills/mantis-reproduce/SKILL.md:52,233 (reproducers directory); skills/mantis-patch/SKILL.md:637 (reattack against shadow copy)
    verifyFixStages -> sandboxRuntime "Runs PoCs and re-attacks inside isolated sandboxes and shadow copies"

    // evidence: skills/mantis-report/SKILL.md:41,365 (review_packet-latest.md)
    closingStages -> workspaceState "Writes review_packet-latest.md and archives the pass"

    // evidence: skills/mantis-advise/SKILL.md:29 (advise.py --file --db knowledge.db)
    advisorSkill -> operatorCli "Invokes scripts/advise.py --file against knowledge.db"

    // evidence: skills/mantis-plan/SKILL.md:409,441 (query_structural_index.py helper for function-level context)
    auditStages -> kbStages "Plans with KB index plus structural-index call-graph hints"

  }

  views {

    // L1 -- system context
    systemContext mantis "SystemContext" {
      include *
      autolayout lr
    }

    // L2 -- containers
    container mantis "Containers" {
      include *
      autolayout tb
    }

    // L3 -- components of the Reference Harness container
    component referenceHarness "ReferenceHarnessComponents" {
      include *
      autolayout lr
    }

    // L3 -- components of the Core Engine Library container
    component coreEngine "CoreEngineComponents" {
      include *
      autolayout tb
    }

    // L3 -- components of the Pipeline Stage Skill Suite container
    component stageSkills "StageSkillsComponents" {
      include *
      autolayout tb
    }

    styles {
      element "External System" {
        background "#dddddd"
        color "#000000"
      }
      element "Container" {
        background "#438dd5"
        color "#ffffff"
      }
      element "Component" {
        background "#85bbf0"
        color "#000000"
      }
    }
  }
}
