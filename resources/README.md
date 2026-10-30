# Resources — the documentation toolchain

This directory holds the standards every markdown file in this repository is
held to, and the flow used to produce and keep them clean.

## What is here

| path | what it is |
|---|---|
| [`styleguides/google-docguide-style.md`](styleguides/google-docguide-style.md) | Verbatim markdown source of the [Google developer documentation style guide, style page](https://google.github.io/styleguide/docguide/style.html). |
| [`egm/README.md`](egm/README.md) | Verbatim README of [google/elephant-goldfish-model](https://github.com/google/elephant-goldfish-model) (EGM). |
| [`egm/architecture.md`](egm/architecture.md) | EGM design document — the Elephant/Goldfish roles and review pipeline. |
| [`egm/egm-review-SKILL.md`](egm/egm-review-SKILL.md) | EGM review skill — the zero-context review stages and report format. |
| [`reference-gitlab-vale.ini`](reference-gitlab-vale.ini) | GitLab's `.vale.ini`, kept as the structural reference this repository's config was modeled on. |
| [`gen-module-readmes.py`](gen-module-readmes.py) | Generates every `modules/kafka/<module>/README.md` from `matrix/matrix.csv`, the module map, and `PROVENANCE.md`. |
| [`vale/styles/`](vale/styles/) | The Vale style packages this repository defines (`cassian_base`, `cassian_docs`). |

## The flow (Elephant-Goldfish, applied to documentation)

Every authored page goes through two kinds of attention, then a mechanical gate:

1. **Elephant pass (deep context).** The writer holds the full context — the
   measured data, the subject history, the repository contracts in `AGENTS.md`
   — and drafts or revises the page. Facts come from measured sources only:
   `matrix/matrix.csv`, `PROVENANCE.md`, the module map, and the tracking
   record. Nothing is asserted from memory.
2. **Goldfish passes (zero context).** Each revision is read by a reviewer who
   sees only the page and the sources it cites. If a reader cannot tell what
   the page claims, where each number came from, and what to do next — the
   page is not done. Caveats are stated as facts next to the claims they
   qualify, never collected into a Limitations pile.
3. **Vale gate (mechanical).** `.vale.ini` enforces the invariants that do not
   need judgment:

   ```
   vale --minAlertLevel=error $(git ls-files '*.md')
   ```

   `cassian_base` fails the build on: non-English prose, leaked
   pipeline-internal tokens (`job-…`, `sess-…`, `INHERITED`, a GitHub token
   prefix, and similar), and, at suggestion level, the pipeline codename.
   `cassian_docs` carries the style layer: banned promotional adjectives
   (EGM's plain-English rule, as errors), vague intensifiers, sentence
   length, heading case, and a hard error on any `Limitations` heading.

## Regenerating the module READMEs

The per-module READMEs are generated, not hand-written, so they cannot drift
from the measured data:

```
python3 resources/gen-module-readmes.py
```

They are regenerated whenever `matrix/matrix.csv` or the module map changes,
and every regeneration must pass the Vale gate before it is committed.
