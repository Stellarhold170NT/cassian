# cassian

Cassian is an archive of studied codebases. Each subject repository is read
end to end, measured against its own source, and reduced to what is worth
keeping — an index, maps, notes, and verbatim extracts of the code itself.

The name nods to the consigliere: the advisor who has read everything and
volunteers only what is asked.

## Layout

- `matrix/` — one index per subject: every module, its rating, its location.
  Start here.
- `modules/<subject>/<module>/` — verbatim source, byte-identical to a pinned
  upstream commit. Each module carries a `PROVENANCE.md` with the upstream
  sha, path, license, and measured size.
- `docs/<subject>/` — cartography, module map, architecture (C4), overview,
  ratings, data flows, usage.
- `specs/<subject>/` — the extraction plan for each module.
- `tracking/<subject>.md` — the pinned commit against upstream HEAD, so
  drift is visible.

First subject: apache/kafka (trunk, pinned).

## Use

Choose a module by rating in the matrix, follow its declared dependencies,
take the code from `modules/`. Nothing is paraphrased: extracts diff clean
against upstream, and claims in the notes carry measurable references.

## License

Extracted code remains under its original Apache-2.0 terms. Notes and
indices are Apache-2.0.
