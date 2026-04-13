# AGENTS.md

A minimal example of an `AGENTS.md` for a nest.

Read [README.md](README.md) for the protocol.

## Read order

1. `README.md` — the protocol
2. `AGENTS.md` — local operating rules
3. `instructions.md` — task-specific instructions, if present

## Rules

1. Keep it local-first and file-system based.
2. Preserve the nest layout: `.nest/{in,out,failed,log}`.
3. Preserve hatching write protection:
   - write to `name.hatching`
   - rename to `name`
   - never tend anything still ending in `.hatching`
4. Preserve `.nest/failed/` and `.nest/log/`.
5. Prefer small, readable scripts.
6. Do not add networking, queues, databases, encryption, or dependencies unless asked.
7. Do not turn the example into a framework.

## instructions.md

If `instructions.md` is present, read it before tending the nest.

It is for whomever tends the nest:

- a human should follow it
- an AI agent should inspect it and carry it out
- a script should treat it as the process description

Keep task-specific behavior in `instructions.md`, not here.
