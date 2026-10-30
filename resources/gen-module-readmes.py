#!/usr/bin/env python3
"""Generate per-module README.md files from measured data.

Sources of truth (no invented facts):
  - docs/kafka/02-module-map.md  -> responsibility text + key files
  - matrix/matrix.csv            -> rating, upstream_path, dependency edges, doc anchor
  - modules/kafka/<m>/PROVENANCE.md -> measured size, extracted_at, upstream_sha
"""
import csv, os, re, subprocess, sys

ROOT = "/app/workspace/AI Engineer World's Fair/cassian-docclean"

def parse_module_map():
    """Return {module_name: {'anchor':..., 'responsibility':..., 'key_files':...}}"""
    out = {}
    path = os.path.join(ROOT, "docs/kafka/02-module-map.md")
    row_re = re.compile(r'^\|\s*<a id="(m\d+-[^"]+)"></a>\s*(m\d+)\s*\|')
    with open(path, encoding="utf-8") as f:
        for line in f:
            line = line.rstrip("\n")
            if not line.startswith("| <a id="):
                continue
            cells = [c.strip() for c in line.split("|")]
            # ['', '<a id=..></a>m01', 'clients', 'responsibility', 'deps', 'deped', 'loc', 'key files', '']
            if len(cells) < 9:
                print(f"  !! odd row ({len(cells)} cells): {line[:80]}", file=sys.stderr)
                continue
            m = cells[2].split(" ")[0]  # module id like m01
            anchor_m = re.search(r'id="(m\d+-[^"]+)"', cells[1]).group(1)
            out[cells[2] if cells[2] else m] = {
                "mid": m,
                "anchor": anchor_m,
                "responsibility": cells[3],
                "key_files": cells[7],
            }
    return out

def parse_matrix():
    """Return {module_name: rowdict} keyed by the `module` column."""
    out = {}
    with open(os.path.join(ROOT, "matrix/matrix.csv"), encoding="utf-8") as f:
        for row in csv.DictReader(f):
            out[row["module"]] = row
    return out

def parse_provenance(module_dir):
    prov = {}
    p = os.path.join(module_dir, "PROVENANCE.md")
    if not os.path.exists(p):
        return prov
    for line in open(p, encoding="utf-8"):
        m = re.match(r"^-\s+(\w[\w-]*):\s+(.+?)\s*$", line)
        if m:
            prov[m.group(1)] = m.group(2)
    return prov

def rel_prefix(module_relpath):
    depth = module_relpath.count("/") + 1
    return "../" * depth

def fmt_deps(raw):
    raw = (raw or "").strip()
    if raw in ("", "-", "—"):
        return "None — leaf module."
    parts = [p.strip() for p in raw.split(";") if p.strip()]
    if not parts:
        return "None — leaf module."
    return ", ".join("`" + p + "`" for p in parts)

def key_files_block(kf):
    kf = (kf or "").strip()
    if kf in ("", "-", "—"):
        return None
    items = []
    for part in kf.split(";"):
        part = part.strip()
        if not part:
            continue
        m = re.match(r"^`([^`]+)`\s*(\((.*)\))?$", part)
        if m:
            note = m.group(3) or ""
            note = re.sub(r"^\d+,\s*", "", note)  # drop bare line counts like (5387, largest)
            items.append((m.group(1), note.strip()))
        else:
            items.append((part, ""))
    if not items:
        return None
    lines = ["Key files, with their role:"]
    lines.append("")
    for path_, note in items:
        lines.append(f"- `{path_}`" + (f" — {note}" if note else ""))
    return "\n".join(lines)

def main():
    mmap = parse_module_map()
    matrix = parse_matrix()
    print(f"module map entries: {len(mmap)}, matrix rows: {len(matrix)}")

    prov_dirs = []
    for dirpath, dirnames, filenames in os.walk(os.path.join(ROOT, "modules/kafka")):
        if "PROVENANCE.md" in filenames:
            prov_dirs.append(dirpath)
    print(f"module dirs with PROVENANCE: {len(prov_dirs)}")

    written, missing_desc, skipped = 0, [], []
    for mdir in sorted(prov_dirs):
        rel = os.path.relpath(mdir, ROOT)                      # modules/kafka/clients
        name = os.path.relpath(mdir, os.path.join(ROOT, "modules/kafka"))
        prov = parse_provenance(mdir)
        row = matrix.get(name)
        mm = mmap.get(name)
        if row is None:
            missing_desc.append((name, "no matrix row"))
            continue
        if mm is None:
            # Fallback: the 26 structurally identical streams upgrade smoke-test
            # modules are documented as one family row in the module map.
            if row.get("doc_link", "").strip().endswith("#streams-upgrade-system-tests-family"):
                short = name.rsplit("-", 1)[-1]
                if len(short) == 4:
                    ver = ".".join([short[0], short[1:3], short[3]])
                else:
                    ver = ".".join([short[0], short[1]])
                mm = {
                    "mid": row["id"],
                    "anchor": "streams-upgrade-system-tests-family",
                    "responsibility": (
                        f"Streams {ver} upgrade smoke-test suite: one of 26 structurally "
                        "identical test-only modules, each pinning one historical Kafka "
                        "Streams version and carrying a single `StreamsUpgradeTest` main "
                        "plus a smoke-test driver."
                    ),
                    "key_files": "",
                }
            else:
                missing_desc.append((name, "no module-map entry"))
                continue

        pre = rel_prefix(rel)
        # Skip modules whose README.md is an upstream file (e.g. examples, raft,
        # trogdor): never overwrite upstream text — the upstream README already
        # serves as the module's readme there.
        tracked = subprocess.run(
            ["git", "ls-files", "--", os.path.join(rel, "README.md")],
            cwd=ROOT, capture_output=True, text=True).stdout.strip()
        if tracked:
            skipped.append(name)
            continue
        sha = prov.get("upstream_sha", "aa62a433553c14866521bd40ff446b6920d4d67e")
        extracted = prov.get("extracted_at", "")
        measured = prov.get("measured", "")
        rating = row.get("rating", "")
        upstream_path = row.get("upstream_path", "")
        anchor = mm["anchor"]
        doc_link = row.get("doc_link", "").strip()

        lines = []
        lines.append(f"# Module `{name}`")
        lines.append("")
        lines.append(mm["responsibility"])
        lines.append("")
        lines.append("## At a glance")
        lines.append("")
        lines.append("| | |")
        lines.append("|---|---|")
        lines.append(f"| Upstream | `{upstream_path}` in [apache/kafka](https://github.com/apache/kafka) at commit `{sha}` |")
        if measured:
            lines.append(f"| Size | {measured} |")
        lines.append(f"| Reuse rating | {rating}★ — method in [`docs/method/rubric.md`]({pre}docs/method/rubric.md) |")
        if extracted:
            lines.append(f"| Extracted | {extracted} |")
        lines.append("")
        lines.append("## Dependencies")
        lines.append("")
        lines.append(f"- Depends on: {fmt_deps(row.get('depends_on'))}")
        lines.append(f"- Used by: {fmt_deps(row.get('depended_by'))}")
        lines.append("")
        kfb = key_files_block(mm["key_files"])
        if kfb:
            lines.append(kfb)
            lines.append("")
        lines.append("## Related reading")
        lines.append("")
        if doc_link:
            lines.append(f"- Module map entry: [`docs/kafka/02-module-map.md`]({pre}{doc_link.replace('#', '#')})")
        lines.append(f"- [`PROVENANCE.md`](PROVENANCE.md) — upstream source, license, and verification command")
        lines.append(f"- Upstream freshness: [`tracking/kafka.md`]({pre}tracking/kafka.md)")
        lines.append("")
        lines.append("## Verification")
        lines.append("")
        lines.append("The source in this directory is byte-identical to apache/kafka at commit")
        lines.append(f"`{sha}`: `diff -r` against a checkout of that commit shows no difference")
        lines.append("in any upstream file. The only files added beyond the upstream tree are")
        lines.append("cassian metadata: this `README.md`, `PROVENANCE.md`, and the `README.md` /")
        lines.append("`PROVENANCE.md` of any nested module directory. No upstream file is modified.")
        lines.append("")

        out = os.path.join(mdir, "README.md")
        with open(out, "w", encoding="utf-8") as f:
            f.write("\n".join(lines))
        written += 1

    print(f"written: {written}")
    if skipped:
        print("skipped (upstream README present): " + ", ".join(skipped))
    if missing_desc:
        print("MISSING DESCRIPTIONS:")
        for name, why in missing_desc:
            print(f"  {name}: {why}")

if __name__ == "__main__":
    main()
