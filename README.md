# cassian

Cassian is a consigliere for codebases. It studies a repository in depth,
identifies the modules worth reusing, maps their dependencies, and preserves
verified source with provenance — the knowledge behind better engineering
decisions.

## How a subject is organized

Each studied repository becomes a subject and gets its own namespace:

- `modules/<subject>/<module>/` — verbatim source, byte-identical to a pinned
  upstream commit; every module carries a `PROVENANCE.md` with the upstream
  sha, path, license, and measured size.
- `docs/<subject>/` — cartography, module map, architecture, overview,
  ratings, data flows; `docs/<subject>/index.md` is the reading order.
- `specs/<subject>/` — extraction plan per module.
- `tracking/<subject>.md` — pinned commit against upstream HEAD, plus the
  harvest record and re-sync rule.
- `matrix/` — one index per subject: every module, its rating, its location.
  Start here.

## Subjects

| subject | upstream | pin | extracts |
|---|---|---|---|
| kafka | github.com/apache/kafka | `aa62a433` | 66 of 66 gradle modules under `modules/kafka/`, verified byte-identical; index at `matrix/matrix.csv` |

## Quick start

1. Open the subject's index in `matrix/` and sort by rating; the top rows are
   the modules worth taking first.
2. Read the module's entry in `docs/<subject>/` — responsibility,
   dependencies, main files.
3. Take the code from `modules/<subject>/<module>/`; its `PROVENANCE.md`
   states where it came from.

## Method

Ratings follow a fixed rubric with measurable criteria. Extracts are verified
with `diff -r` against upstream at the pin.

## Limitations

- kafka subject documentation is currently written in Vietnamese; an English
  revision is in progress.
- Data-flow measurements for kafka use a 100-commit window; treat rankings
  as indicative, not definitive.
- Module ratings weight centrality more than ease of reuse; a rubric revision
  is planned.

## License

Extracted code remains under its original Apache-2.0 terms. Notes and
indices are Apache-2.0.
