# PROVENANCE — modules/switch/console-renderer

- upstream: sandbox-quantum/switch (branch main)
- upstream_sha: 39a722c5eeecf8479422351fc7ac2a61fe559a66
- upstream_path: console/apps/switch-console-desktop/src/renderer
- extracted_at: 2026-11-04T09:48:07Z
- license: Apache 2.0 License with the modified "Commons Clause" License Condition v1.0 (Copyright (c) 2026 SB Technology, Inc. dba SandboxAQ) - see upstream LICENSE
- census (measured on the PIN checkout, per extension then summed): 986 files / 140969 LOC (checklist contract: 986 files / 140969 LOC; verdict vs checklist: OK)
- generator: goldmine v16 switch p7_cut
- re-sync: per tracking/switch.md - compare 'git ls-remote https://github.com/sandbox-quantum/switch main' HEAD with upstream_sha; equal = FRESH, different = STALE (HEAD moved); re-sync is a separate decision

## Census detail (measured, per extension)

| ext | files | loc |
|---|---|---|
| ts | 458 | 49866 |
| tsx | 528 | 91103 |
| **total** | **986** | **140969** |

## Copy scope

Whole-tree copy of every path listed in upstream_path (multi-path items mirror the upstream relative layout inside this module directory). Byte-identity of every copied file against the PIN checkout was verified with 'git diff --no-index'. The census counts only the item's code extension set per the gm-02 worker convention (py for core items; ts/tsx/js/mjs/sh for console items; the deploy bucket set yaml|yml|py|tf|hcl|sh|conf|tpl|service|setup|switch plus bare Dockerfile; md for the docs item; all files for expert-templates). Qualifiers in upstream_path (top-level *.py only; only *.md) restrict the copy exactly as written.
