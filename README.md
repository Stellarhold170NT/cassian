# cassian

Cassian is a consigliere for codebases. It studies a repository in depth,
identifies the modules worth reusing, maps their dependencies, and preserves
verified source with provenance — the knowledge behind better engineering
decisions.

## What is here

First subject: apache/kafka (trunk, pinned at `aa62a433`).

- `modules/kafka/<module>/` — verbatim source of all 66 gradle modules
  (7,392 files, 1.88M measured lines), byte-identical to upstream at the
  pin. Each module carries a `PROVENANCE.md` with the upstream sha, path,
  license, and measured size.
- `matrix/matrix.csv` — the index: 66 modules with ratings and locations.
  Start here.
- `docs/kafka/` — cartography, module map, architecture (C4), overview,
  ratings, data flows.
- `specs/kafka/` — extraction plan per module.
- `tracking/kafka.md` — the pinned commit against upstream HEAD, plus the
  harvest record.

## Quick start

1. Sort `matrix/matrix.csv` by rating; the top rows are the modules worth
   taking first (clients, streams, core, group-coordinator…).
2. Take the code from `modules/kafka/<module>/`; its `PROVENANCE.md` states
   where it came from and its dependencies are documented in the module map.
3. Read in order: cartography, overview, module map, data flows, ratings.

## Method

Ratings follow a fixed rubric with measurable criteria
(`docs/kafka/05-stars.md`). Extracts are verified with `diff -r` against
upstream at the pin; the full sweep showed no differences.

## Limitations

- Subject documentation is currently written in Vietnamese; an English
  revision is in progress.
- Data-flow measurements use a 100-commit window; treat rankings as
  indicative, not definitive.
- Module ratings weight centrality more than ease of reuse; a revision of
  the rubric is planned.

## License

Extracted code remains under its original Apache-2.0 terms. Notes and
indices are Apache-2.0.
