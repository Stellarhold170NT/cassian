---
subject: sandbox-quantum/switch
measured_at: 39a722c5eeecf8479422351fc7ac2a61fe559a66
pin: 39a722c5eeecf8479422351fc7ac2a61fe559a66
status: final
---


# Agent Switch — documentation set


Documentation for [sandbox-quantum/switch](https://github.com/sandbox-quantum/switch)
("Agent Switch" — an AI agent orchestration and governance platform), mined at
pin `39a722c5eeecf8479422351fc7ac2a61fe559a66` (branch `main`, commit
2026-11-03 23:27:31 UTC). The code extracts live under
[`modules/switch/`](../../modules/switch/) (byte-identical to the pin, one
`PROVENANCE.md` per module); freshness and the re-sync rule are tracked in
[`tracking/switch.md`](../../tracking/switch.md).


**Census at the pin:** 4,613 checkout files · 3,909 code files · 856,195
lines (py 436,178 · ts 304,875 · tsx 115,142). The module universe is **17
items · 3,363 files · 663,505 lines**, all extracted.


## Reading order


| # | doc | what it answers |
|---|---|---|
| 1 | [`01-cartography.md`](01-cartography.md) | What is in the repo — license gate, census, build manifests, entrypoints, top-level layout |
| 2 | [`02-module-map.md`](02-module-map.md) | The 17-module universe — responsibilities, sizes, import edges |
| 3 | [`03-c4/workspace.dsl`](03-c4/workspace.dsl) (+ [`diagrams.mmd`](03-c4/diagrams.mmd)) | The C4 model (L1/L2/L3) with per-edge file:line evidence |
| 4 | [`04-overview.md`](04-overview.md) | How the architecture fits together and why |
| 5 | [`05-folders.md`](05-folders.md) | Annotated directory map with measured sizes |
| 6 | [`06-flows.md`](06-flows.md) | The five expensive end-to-end paths |
| 7 | [`07-usage.md`](07-usage.md) | 24 working use cases (code + evidence) across the 8 star-rated modules |


Extraction plans for the top-rated slots are in
[`specs/switch/`](../../specs/switch/) (`slot-a.plan.md`, `slot-b.plan.md` —
both N/A: no module reached the 4★ slot threshold at this pin; the highest
measured rating is deploy at 3★).


The subject docs are written in English. Measurement methodology (census
formula, module unit, edge measurement) is stated inline in each document.
