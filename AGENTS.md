# AGENTS.md

A minimal example of an `AGENTS.md` for a nest.

Read [README.md](README.md) for the protocol.

## Read order

1. `README.md` — the protocol
2. `AGENTS.md` — local operating rules
3. `instructions.md` — task-specific instructions, if present

## Rules

1. Keep it local-first and file-system based.
2. Preserve the nest layout: `.nest/{in,out,unhatched}`.
3. Preserve hatching write protection:
   - write to `name.hatching`
   - rename to `name`
   - never tend anything still ending in `.hatching`
4. Preserve the `.tending` claim convention: rename `in/name` → `in/name.tending` before processing, and never tend anything still ending in `.tending`.
5. On failure, move the item to `.nest/unhatched/name` and write a sibling `name.reason.md` explaining why.
6. Activity (startup, failures) goes to stderr. Do not reintroduce a log file inside `.nest/`.
7. Prefer small, readable scripts.
8. Do not add networking, queues, databases, encryption, or dependencies unless asked.
9. Do not turn the example into a framework.

## instructions.md

If `instructions.md` is present, read it before tending the nest.

It is for whomever tends the nest:

- a human should follow it
- an AI agent should inspect it and carry it out
- a script should treat it as the process description

Keep task-specific behavior in `instructions.md`, not here.
