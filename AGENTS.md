# AGENTS.md

Notes for coding agents that maintain this repo.

## What this repo is

A nestling that tends its nest. The repo root *is* the nest. `inbox/`, `done/`, `failed/`, and `log/` live at the top level. `nestling.sh` tends them.

## Rules

1. Keep it local-first and file-system based.
2. Do not add networking, queues, databases, or encryption unless asked.
3. Preserve the staged write protection:
   - write to `.incoming`
   - rename to `.ready`
   - only tend `.ready`
4. Keep `POLL_INTERVAL` configurable.
5. Preserve `failed/` and `log/`.
6. Prefer readability over abstraction.
7. No dependencies.

## When editing

- Do not silently change the nest layout.
- Do not remove the `.incoming` / `.ready` suffixes.
- Do not turn the demo into a framework.
- Keep the language plain: a nestling tends its nest.

## Safe extensions

Only when asked:

- metadata sidecar files
- retry counts
- extension filters
- checksum or size checks
