# tracking — sandbox-quantum/switch


## Badge


**STALE** — upstream `main` has moved past the pin.


| project | pinned_sha | head_now | state | last-check (UTC) |
|---|---|---|---|---|
| sandbox-quantum/switch | `39a722c5eeecf8479422351fc7ac2a61fe559a66` | `9e0e10325f091a44b21bd6234b9de0699b9497ae` | STALE (HEAD moved) | 2026-11-05 |


## Pin sources


- Documentation set (`docs/switch/`) and the module map: measured on a shallow
  clone of `main` at `39a722c5eeecf8479422351fc7ac2a61fe559a66`
  (commit "@pintu544 has signed the CLA in sandbox-quantum/switch#1423",
  2026-11-03 23:27:31 UTC).
- Harvest: `modules/switch/<module>/` — byte-identical extracts at the pin
  (verified with `diff -r` per module), each with a `PROVENANCE.md` recording
  upstream path, pin, license, files/loc, and generator
  (`goldmine v16 switch p7_cut`).
- Re-check rule: `git ls-remote https://github.com/sandbox-quantum/switch main`
  and compare against `pinned_sha` above; equal → FRESH, different → STALE
  (no commit resolution, the head hash is recorded as returned). Re-syncing
  the extract is a separate, explicit decision.


## Harvest


17 modules under `modules/switch/`: core-flat, bridges, db, gateway-core,
migrations, management, connections, delivery, core-misc (13 subpackages),
console-renderer, console-main, console-shared, console-packages, gateway-web,
deploy, docs, expert-templates. Census at the pin: 3,363 files / 663,505 loc
(per-module numbers in `docs/switch/02-module-map.md` and each `PROVENANCE.md`).


## Documentation set


- `docs/switch/`: 01-cartography, 02-module-map, 03-c4/ (workspace.dsl +
  diagrams.mmd), 04-overview, 05-folders, 06-flows, 07-usage (24 use cases
  across the 8 star-rated modules), index.md.
- `specs/switch/`: slot-a.plan.md, slot-b.plan.md — both N/A (no module
  reached the 4★ slot threshold; highest measured rating is deploy at 3★).
- `matrix/matrix.csv`: 17 rows appended (one per module).
