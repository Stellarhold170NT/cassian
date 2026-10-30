# cassian

Cassian is a consigliere for codebases. It studies a repository in depth,
identifies the modules worth reusing, maps their dependencies, and preserves
verified source with provenance — the knowledge behind better engineering
decisions.

## How a subject is organized

Each studied repository becomes a subject and gets its own namespace:

- `modules/<subject>/<module>/` — verbatim source, byte-identical to a pinned
  upstream commit. Every module directory carries two added files: `README.md`
  (what the module is, at a glance) and `PROVENANCE.md` (upstream sha, path,
  license, measured size, verification command). No upstream file is modified.
- `docs/<subject>/` — cartography, module map, architecture, overview,
  ratings, data flows; `docs/<subject>/index.md` is the reading order.
- `specs/<subject>/` — extraction plan per module.
- `tracking/<subject>.md` — pinned commit against upstream HEAD, plus the
  harvest record and re-sync rule.
- `matrix/` — one index per subject: every module, its rating, its location.
  Start here.
- `resources/` — the documentation toolchain this repository holds itself to:
  the Google developer documentation style guide, the Elephant-Goldfish review
  model, and the Vale configuration in `.vale.ini`.

## Subjects

| subject | upstream | pin | extracts |
|---|---|---|---|
| kafka | github.com/apache/kafka | `aa62a433` | 66 of 66 gradle modules under `modules/kafka/`, verified byte-identical; index at `matrix/matrix.csv` |

## Quick start

1. Open the subject's index in `matrix/` and sort by rating; the top rows are
   the modules worth taking first.
2. Read the module's `README.md` for what it is and what it depends on, and
   its entry in `docs/<subject>/` for measured detail.
3. Take the code from `modules/<subject>/<module>/`; its `PROVENANCE.md`
   states where it came from.

## Method

Ratings follow a fixed rubric (`docs/method/rubric.md`) with measurable
criteria. Extracts are verified with `diff -r` against upstream at the pin.
Data-flow measurements cover the most recent 100 upstream commits, so churn
rankings are relative signals over the window, not lifetime history. The
rubric weights centrality more heavily than ease of reuse; both signals are
listed per module so readers can apply their own weights.

## Documentation standard

Every markdown file in this repository (outside `modules/`, which is upstream
text) is held to the Google developer documentation style guide and reviewed
with the Elephant-Goldfish method: one deep-context pass to fix the facts,
then zero-context readers who must be able to understand the page from the
page alone. `.vale.ini` enforces the mechanical part — run:

```
vale --minAlertLevel=error $(git ls-files '*.md')
```

The gate is zero errors: English-only prose, no pipeline-internal tokens, no
Limitations-style disclaimer piles (limitations are stated as facts next to
the claims they qualify).

## License

Extracted code remains under its original Apache-2.0 terms. Notes and
indices are Apache-2.0.
