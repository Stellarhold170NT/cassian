# PROVENANCE — modules/switch/expert-templates

- upstream: sandbox-quantum/switch (branch main)
- upstream_sha: 39a722c5eeecf8479422351fc7ac2a61fe559a66
- upstream_path: switch-expert, examples, scripts
- extracted_at: 2026-11-04T09:48:07Z
- license: Apache 2.0 License with the modified "Commons Clause" License Condition v1.0 (Copyright (c) 2026 SB Technology, Inc. dba SandboxAQ) - see upstream LICENSE
- census (measured on the PIN checkout, per extension then summed): 28 files / 5879 LOC (checklist contract: 28 files / 5879 LOC; verdict vs checklist: OK)
- generator: goldmine v16 switch p7_cut
- re-sync: per tracking/switch.md - compare 'git ls-remote https://github.com/sandbox-quantum/switch main' HEAD with upstream_sha; equal = FRESH, different = STALE (HEAD moved); re-sync is a separate decision

## Census detail (measured, per extension)

| ext | files | loc |
|---|---|---|
| md | 9 | 1925 |
| py | 9 | 2856 |
| sh | 3 | 460 |
| yaml | 7 | 638 |
| **total** | **28** | **5879** |

## Copy scope

Whole-tree copy of every path listed in upstream_path (multi-path items mirror the upstream relative layout inside this module directory). Byte-identity of every copied file against the PIN checkout was verified with 'git diff --no-index'. The census counts only the item's code extension set per the gm-02 worker convention (py for core items; ts/tsx/js/mjs/sh for console items; the deploy bucket set yaml|yml|py|tf|hcl|sh|conf|tpl|service|setup|switch plus bare Dockerfile; md for the docs item; all files for expert-templates). Qualifiers in upstream_path (top-level *.py only; only *.md) restrict the copy exactly as written.
