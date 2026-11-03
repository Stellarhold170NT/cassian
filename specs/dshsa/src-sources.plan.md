---
subject: deepseek-ai/dsh-superagent-prototype
measured_at: 8c32a9dc5d72c033816c6a8110b37f40cf94fba4
status: plan
---

# Extraction plan — slot: `src/sources` (dsh-superagent-sources)

- Upstream: `https://github.com/deepseek-ai/dsh-superagent-prototype`
  (branch `main`), pin `8c32a9dc5d72c033816c6a8110b37f40cf94fba4` — verified
  on the clone at plan time (both slot plans were authored from gated
  pipeline reports measured on this pin).
- Provenance of the decision: pipeline `goldmine-dshsa` ran `ex_a` (slot A)
  then `ex_b` (slot B). `ex_b` started before `ex_a`'s plan file landed and
  resolved "second item" by table order to `src/core` again — a disclosed
  slot collision (its own report records the ambiguity and the re-plan
  condition). This document is the re-planned slot B per `ex_a`'s handoff
  note ("slot B = src/sources"): the two ★★★★★ items (9/10 each, cap ≤3
  respected) are `src/core` (slot A) and `src/sources` (slot B).

## 1. Target

`dsh-superagent/src/sources` — 16 files / 2,059 LOC at the pin (module map
`docs/dshsa/02-module-map.md#m06-sources`, census row m06; star rating
★★★★★, total 9/10: S1 1 (deps_out 3), S2 2 (fan 7), S3 2 (6.8 spec/kLOC),
S4 2 (K1 SourceKind contract + K4 consumerRetry backoff), S5 2 (loc 2059 ≥
1500 ∧ pub_api 72)).

## 2. Why this module

- Pluggable source contract in one interface: `kind.ts:85` defines
  `SourceKind<C>` (config schema + form fields + policy + channel adapter +
  thread-context reader).
- Two real polling sources ship in-repo: `github.ts` (459 LOC, retry window
  24h `RETRY_WINDOW_MS` at github.ts:156, 410-Gone vs 404 classification
  :157-158) and `feishu.ts` (139 LOC polling loop).
- Retry semantics tied to healthy-run duration: `feishu-loops.ts:67-69`
  backoff 1s/×2/60s-cap.

## 3. Extract procedure (copy-then-prune)

1. `git clone --depth 100 --single-branch -b main` at the pin; verify
   `git rev-parse HEAD == 8c32a9dc5d72c033816c6a8110b37f40cf94fba4`.
2. Copy `dsh-superagent/src/sources/` verbatim into
   `modules/dshsa/m06/` (already done by the harvest commit — PROVENANCE.md
   records upstream path `dsh-superagent/src/sources`).
3. Prune only dead excludes recorded by the plan (none for this module —
   the 16 files are all substantive).
4. Build + test the extracted tree: `pnpm install --frozen-lockfile &&
   pnpm typecheck && pnpm test` (vitest). Dry-run at plan time was SKIPPED
   honestly: the bitnami/git sandbox has no node/pnpm — re-run on a Node
   24 machine to certify (same procedure as slot A).

## 4. Re-sync rule

Follows `tracking/dshsa.md`: FRESH while
`git ls-remote ... refs/heads/main` == pin; STALE triggers a re-certification
cycle, never an automatic re-measure.
