---
subject: apache/kafka
measured_at: aa62a433553c14866521bd40ff446b6920d4d67e
status: final
---

# Rating method (rubric)

Every module in `matrix/matrix.csv` carries a 1–5 star rating produced by the
rubric below. The rating answers one question: **how safe and pleasant is it to
lift this module out of the codebase and reuse it elsewhere?** Three of the
signals measure reuse readiness directly (few external dependencies, real test
coverage, real substance); one signal (integration weight) measures how much of
the system builds on the module; one (distinctiveness) checks whether an
equivalent open-source component already exists.

The five signals are combined with a strict minimum: a module reaches K stars
only when **all five** signals independently reach K. There is no weighting and
no trade-off — a weak signal cannot be bought back by a strong one.

Module statistics used with this rubric were measured on the upstream tree at
commit `0c92b0664539d0dfb60b43ede0026497a581d8e0` (KAFKA-20125); the extracts
pin for this subject is `aa62a433` (see `docs/kafka/index.md`). None of the
files cited by the statistics changed between the two commits (verified against
the upstream compare API), so line references resolve identically at both.

## Field semantics

Throughout the docs, `depends_on` lists the modules **this module imports code
from** (its external needs), and `depended_by` lists the modules that **import
this module** (its integration weight). An empty list means zero. Two known
measurement conventions, applied uniformly:

- Test-only modules (no `src/main`) were scanned across all of `src`, since the
  main-side boundary is empty by construction.
- Hidden dependencies through `src/testFixtures` are not counted; classes
  generated at build time (`*.Data` message classes) resolve to the module that
  owns the JSON specification.

## Signals

### S1 — Dependency footprint (`|depends_on|`, fewer is better)

Count of distinct outside modules whose code this module imports at its module
boundary (main sources).

```bash
grep -rhE '^[[:space:]]*import[[:space:]]+<package-prefix>' \
  --include='*.scala' --include='*.java' <module>/src/main | sort -u
# verify the package→module mapping with:
find <module-dir> -type d -path "*/src/main/java/<package-path>"
```

Thresholds: 5★ ≤ 2 · 4★ ≤ 4 · 3★ ≤ 6 · 2★ ≤ 9 · 1★ ≥ 10.

### S2 — Integration weight (`|depends_on| + |depended_by|`)

Total edge count of the module in the dependency graph — how much of the system
stands on it plus how much it stands on.

Thresholds: 5★ ≥ 12 · 4★ ≥ 8 · 3★ ≥ 5 · 2★ ≥ 2 · 1★ ≤ 1.

Known bias: build-time tools that nobody imports (`generator`, `api-checker`)
score 1★ here even though they are trivially liftable. The README notes this as
a planned rubric revision; treat their rating accordingly.

### S3 — Test ratio (`T / A`)

`T` = lines of Java+Scala under every `*src/test*` directory of the module
path; `A` = lines of Java+Scala in the whole path (counted with
`find … -print0 | xargs -0 cat | wc -l`, never `xargs wc -l | tail -1`).

```bash
TEST_DIRS=$(find <path> -type d -path '*src/test*')
T=$(find $TEST_DIRS -type f \( -name '*.java' -o -name '*.scala' \) -print0 | xargs -0 cat | wc -l)
A=$(find <path> -type f \( -name '*.java' -o -name '*.scala' \) -print0 | xargs -0 cat | wc -l)
# RATIO = T / A ; a module without src/test scores 0
```

Thresholds: 5★ ≥ 0.40 · 4★ ≥ 0.25 · 3★ ≥ 0.10 · 2★ > 0 · 1★ = 0.

### S4 — Distinctiveness (no OSS equivalent)

`N_E` = number of valid evidence items. An evidence item counts only when all
three fields are present: (1) a named candidate equivalent, (2) a verifiable
probe with raw output — either `E1` in-repo
(`grep -rln "<core-class>" --include='*.java' --include='*.scala' <all other modules> | wc -l`
returning `0`) or `E2` out-of-repo (public code search with the query and raw
result recorded), and (3) a one-line conclusion naming the API surface the
candidate lacks.

Thresholds: 5★ N_E ≥ 2 with at least one `E2` · 4★ N_E = 1 · 3★ N_E = 0.
S4 does not apply at 2★/1★. The out-of-repo judgement call is the only
non-mechanical step; both `E1` and `E2` artifacts are recorded so a second
reader can re-derive the same `N_E`.

### S5 — Substance (`loc` + public logic methods)

Two quantities at once: `loc` (measured module size) and `PLM` = public or
protected Java methods with a real return type, plus top-level Scala `def`, minus
`get*/set*/is/has` accessors. Constructors and un-annotated interface
declarations do not match by design — pure-API modules therefore score low on
PLM, and their value as a dependency is captured by S2 instead.

```bash
MAIN_DIRS=$(find <path> -type d -path '*src/main*')
J=$(grep -rhE '^[[:space:]]*(public|protected)[[:space:]]+[A-Za-z_][A-Za-z0-9_<>\[\],\. ?]*[[:space:]]+[A-Za-z0-9_]+[[:space:]]*\(' --include='*.java' $MAIN_DIRS | grep -cvE '\b(get|set|is|has)[A-Z]')
S=$(grep -rhE '^[[:space:]]*def[[:space:]]+[A-Za-z0-9_]+[[:space:]]*\(' --include='*.scala' $MAIN_DIRS | grep -cvE '\b(get|set|is|has)[A-Z]')
# PLM = J + S
```

Thresholds: 5★ loc ≥ 20000 ∧ PLM ≥ 200 · 4★ ≥ 5000 ∧ ≥ 50 · 3★ ≥ 1000 ∧ ≥ 10 ·
2★ ≥ 200 ∧ ≥ 2 · 1★ otherwise.

## Star formula

`star(M) = min(S1, S2, S3, S4, S5)` — a module reaches K stars when the AND of
all five signal thresholds at level K holds:

| Stars | Required combination |
|---|---|
| ★★★★★ | deps ≤ 2 ∧ edges ≥ 12 ∧ ratio ≥ 0.40 ∧ N_E ≥ 2 (≥1 E2) ∧ loc ≥ 20000 ∧ PLM ≥ 200 |
| ★★★★ | deps ≤ 4 ∧ edges ≥ 8 ∧ ratio ≥ 0.25 ∧ N_E ≥ 1 ∧ loc ≥ 5000 ∧ PLM ≥ 50 |
| ★★★ | deps ≤ 6 ∧ edges ≥ 5 ∧ ratio ≥ 0.10 ∧ loc ≥ 1000 ∧ PLM ≥ 10 |
| ★★ | deps ≤ 9 ∧ edges ≥ 2 ∧ ratio > 0 ∧ loc ≥ 200 ∧ PLM ≥ 2 |
| ★ | anything weaker |

Why a minimum instead of weighted points: additive scores create hidden
trade-offs (a 1★-quality module buying back stars with centrality) and make two
independent scorers diverge. The minimum is the only aggregation that needs no
interpretation.

## Five-star cap

At most 3 modules per repository may hold 5★. The cap is enforced structurally:
the 5★ gates of S1∩S2 are computable from the dependency table alone, and only
`clients` (0 deps, 23 edges) and `server-common` (1 dep, 17 edges) pass both.
Downstream signals can only lower a module, never raise it. If a re-measurement
ever exceeds the cap, the deterministic tie-break is: integration weight
descending → loc descending → id ascending; overflowing modules are demoted to
4★ and marked `demoted by cap (rank #N)` in the results.

## Reproducibility

S1, S2, S5 are direct counts (same command → same number). S3 is the same
`find/cat/wc` recipe on the same tree. S4's evidence format makes `N_E` a count
of artifacts; only the `E2` verdict involves reading, and both artifacts are
kept for cross-checking. The published results in
[`docs/kafka/05-stars.md`](../kafka/05-stars.md) were re-verified by an
independent machine check that re-parsed the table, recomputed every signal
threshold from the recorded numbers, and confirmed `star = min(S1..S5)` for all
66 modules.
