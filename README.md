# cassian

Cassian is a consigliere for codebases. It studies a repository in depth,
identifies the modules worth reusing, maps their dependencies, and preserves
verified source with provenance — the knowledge behind better engineering
decisions.

## What is here

First subject: apache/kafka (trunk, pinned at a single commit).

- `matrix/matrix.csv` — the index: 66 gradle modules with ratings and
  locations. Start here.
- `docs/kafka/` — cartography, module map, architecture (C4), overview,
  ratings, data flows.
- `specs/kafka/` — extraction plan per module.
- `tracking/kafka.md` — the pinned commit against upstream HEAD, so drift
  is visible.

## Quick start

1. Sort `matrix/matrix.csv` by rating; the top rows are the modules worth
   studying first.
2. Open the module's entry in the module map: responsibility, dependencies,
   main files.
3. Read in order: cartography, overview, module map, data flows, ratings.

Verbatim code extracts land under `modules/` in a separate harvest commit;
`tracking/kafka.md` records the harvest state.

## Method

Ratings follow a fixed rubric with measurable criteria
(`docs/kafka/05-stars.md`). Data-flow notes are measured on the pinned tree.

## Limitations

- `modules/` is not yet populated; extracts arrive with the harvest commit.
- Subject documentation is currently written in Vietnamese; an English
  revision is in progress.
- Data-flow measurements use a 100-commit window; treat rankings as
  indicative, not definitive.

## License

Extracted code remains under its original Apache-2.0 terms. Notes and
indices are Apache-2.0.
