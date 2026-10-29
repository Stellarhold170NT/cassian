# cassian

Cassian is a consigliere for codebases. It studies a repository in depth,
identifies the modules worth reusing, maps their dependencies, and preserves
verified source with provenance — the knowledge behind better engineering
decisions.

## How it works

For each subject repository, cassian:

1. Reads the codebase end to end and pins a single upstream commit.
2. Builds an index of every module — responsibility, public surface, size,
   and a rating backed by measured criteria.
3. Maps dependencies, so a module can be lifted out together with what it
   needs.
4. Extracts the source of every module verbatim, each with a PROVENANCE.md
   recording where it came from and under which license.
5. Tracks the pinned commit against upstream HEAD, so drift is visible.

Nothing is paraphrased. Extracts diff clean against upstream; claims in the
notes carry measurable references.

## Layout

- `matrix/` — the index per subject: every module, its rating, its location.
  Start here.
- `modules/<subject>/<module>/` — verbatim source, each module with its
  `PROVENANCE.md`.
- `docs/<subject>/` — cartography, module map, architecture (C4), overview,
  ratings, data flows, usage.
- `specs/<subject>/` — the extraction plan per module.
- `tracking/<subject>.md` — pinned commit against upstream HEAD.

First subject: apache/kafka (trunk, pinned).

## Use

Pick a module by rating in the matrix, follow its declared dependencies,
take the code from `modules/`, and cite its PROVENANCE when reusing.

## License

Extracted code remains under its original Apache-2.0 terms. Notes and
indices are Apache-2.0.
