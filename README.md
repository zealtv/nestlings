# 🪺 nestlings

A tiny, file-based protocol for agents that tend a folder.

## Words

- **nest** — a `.nest/` folder at the root of any directory.
- **nestling** — the agent that tends the nest. A script, an AI, or a human.
- **tend** — read a file from the nest, do work, place the result.
- **hatching** — a file still being written. Suffixed `.hatching`. Never tended.

## The protocol

- A nest is a `.nest/` folder with four children: `in/`, `done/`, `failed/`, `log/`.
- A nestling watches `.nest/in/` and tends each file it finds there.
- To add a file, write `name.hatching`, then rename it to `name`. Nestlings skip anything still ending in `.hatching`.
- On success, the file moves to `.nest/done/` and one line is appended to `.nest/log/nestling.log`.
- On failure, the file moves to `.nest/failed/` and the error is logged.
- The file system is the protocol. No network, no database, no queue, no dependencies.

## The nest

```
.nest/
  in/       files waiting to be tended
  done/     files the nestling has tended
  failed/   files the nestling could not tend
  log/      a plain-text record of what happened
```

## File states

- `name.hatching` — being written. Off limits.
- `name` — ready in `.nest/in/`.
- `.nest/done/name` — tended.
- `.nest/failed/name` — kept for inspection.

## Log format

One line per event in `.nest/log/nestling.log`:

```
timestamp | nestling | event | filename | message
```

Events: `START`, `OK`, `FAIL`.

## Run the demo

```bash
./nestling.sh
```

The nestling watches `.nest/in/` and tends each file it finds.

In another terminal:

```bash
./feed.sh "hello"
```

Within a second, `.nest/done/sample.txt` appears with `[tended by nestling]` on the first line.

## Configuration

- `POLL_INTERVAL=1` — seconds between polls.

## Non-goals

This is not a workflow engine. It exists to show one thing clearly:

- folder-based tending
- hatching write protection
- plain failure handling

Point an agent at this repo and ask it to add a nest to any folder. The conventions above are the whole protocol.
