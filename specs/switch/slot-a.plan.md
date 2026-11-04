# Extraction plan — slot A (sandbox-quantum/switch)


**Verdict: N/A — no qualifying item at this pin.**


Slot A is reserved for the single highest-rated module of a subject — an item
whose measured rating reaches **4★ or more** — and receives the deep-dive
extraction plan (per-file cut list, reuse targets, integration order).


## Measured ratings (pin `39a722c5eeecf8479422351fc7ac2a61fe559a66`)


| module | rating |
|---|---|
| deploy | ★3 |
| the other 16 modules (core-flat, bridges, db, gateway-core, migrations, management, connections, delivery, core-misc, console-renderer, console-main, console-shared, console-packages, gateway-web, docs, expert-templates) | ★1 each |


No module reaches 4★, so slot A has no qualifying candidate.


## Consequence


- No per-file cut plan is produced for slot A at this pin.
- The full harvest still proceeds under the standard P7 cut (all 17 modules,
  byte-identical extracts, see `modules/switch/<module>/PROVENANCE.md`).
- If a later re-sync raises any module to 4★ (see
  `tracking/switch.md` for the re-check rule), this plan is superseded by a
  concrete slot-A cut plan for that module.


## Measurement note


Ratings come from the subject's measured rubric (use-case surface and reuse
value per module; results in `docs/switch/07-usage.md` — 8 star-rated modules,
24 use cases — and `matrix/matrix.csv`). The star counts above were measured
once at the pin and are not re-derived here.
