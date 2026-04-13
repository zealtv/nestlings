# 🪺 nestlings

A tiny, file-based protocol for agents that tend a folder.

## Terminology

- **nest** — a `.nest/` folder at the root of a project.
- **nestling** — anything that tends the nest: a script, an AI, or a human.
- **tend** — notice a ready item in `in/` and handle it.
- **hatching** — an item still being written. It ends in `.hatching` and must be ignored.

## The protocol

A nest is a `.nest/` folder with four children:

```text
.nest/
  in/       ready items waiting to be tended
  out/      tended items for other agents to collect
  failed/   items that could not be tended
  log/      a plain-text record of what happened
```

Rules:

- Write new items as `name.hatching`, then rename to `name` when complete.
- Never tend anything still ending in `.hatching`.
- Nestlings watch `.nest/in/` for ready files or directories.
- On success, the tended item moves to `.nest/out/`.
- On failure, the item moves to `.nest/failed/`.
- Append one line per event to `.nest/log/nestling.log`.
- The file system is the protocol. No network, no database, no queue, no dependencies.


A nestling may process an item, enrich it, sort it, archive it, or simply ingest it for later use. Inputs and outputs are decoupled. The reference nestling in this repo keeps things simple: it moves ready items from `in/` to `out/` using the same hatching protection.

## Item states

- `name.hatching` — being written. Off limits.
- `name` — ready in `.nest/in/`.
- `.nest/out/name` — tended and stored.
- `.nest/failed/name` — kept for inspection.

## Log format

One line per event in `.nest/log/nestling.log`:

```text
timestamp | nestling | event | filename | message
```

Events: `START`, `OK`, `FAIL`.

## Run the demo

Start the reference nestling:

```bash
./nestling.sh
```

It watches `.nest/in/` and moves each ready item to `.nest/out/`.

### Feed plain text

```bash
./feed.sh --text "hello"
```

If you omit the name, `feed.sh` creates a short unique text filename such as:

```text
note-20260413-214500-12345.txt
```

You can also provide a name:

```bash
./feed.sh --text "hello" note.txt
```

### Feed an existing file

```bash
./feed.sh path/to/file.txt
```

### Feed an existing directory

```bash
./feed.sh path/to/folder
```

### Hand off ownership instead of copying

```bash
./feed.sh --move path/to/file.txt
```

`feed.sh` defaults to `--copy`. That is the safer choice for agents because the source item stays in place. In both modes, the script writes to `.nest/in/name.hatching` first and renames to `.nest/in/name` only when complete.

If the destination name already exists, `feed.sh` fails immediately.

## Instruction items

An optional `instructions.md` may describe how a nestling should tend the nest. This is a convention, not a new required protocol rule.

Why it helps:

- humans can read the instructions directly
- AI agents can inspect the directory and act on it
- scripts can treat the file as the description of the process to execute

A simple pattern for `instructions.md` is:

```md
This item contains instructions for whoever tends this nest.

- If you are a human, follow the steps below.
- If you are an AI agent, inspect this directory and carry out the steps.
- If you are a script, this file describes the process to execute.

## Goal

...

## Inputs

...

## Steps

...

## Outputs

...
```


## Telegram inbox bot

This repo includes `telegram_inbox.py` as an optional inbox bot.

By default it writes directly to `.nest/in/`.

Each Telegram message becomes a directory. The bot writes that directory as `name.hatching/` first, then renames it to `name/` only after `message.txt`, `meta.json`, and any attachments are fully written.

That means the reference nestling can treat Telegram items the same way it treats any other ready item.

### Setup

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install python-telegram-bot

export TELEGRAM_BOT_TOKEN="123456:ABCDEF_your_token_here"
export TELEGRAM_ALLOWED_USER_IDS="123456789"

python3 telegram_inbox.py
```

Optional:

```bash
export TELEGRAM_INBOX_DIR="$PWD/.nest/in"
```

That is already the default.

### Telegram flow

1. The bot creates `.nest/in/name.hatching/`
2. The bot writes `message.txt`, `meta.json`, and attachments
3. The bot renames the directory to `.nest/in/name/`
4. `nestling.sh` sees the ready directory
5. `nestling.sh` moves it to `.nest/out/name/`

## Configuration

- `POLL_INTERVAL=1` — seconds between polls.
- `TELEGRAM_BOT_TOKEN` — Telegram bot token.
- `TELEGRAM_INBOX_DIR` — where the Telegram bot writes items. Defaults to `./.nest/in`.
- `TELEGRAM_ALLOWED_USER_IDS` — comma-separated Telegram user IDs allowed to send to the bot.


## Design notes

This repo aims for structure, simplicity, and clarity.

It is not a workflow engine or a framework. It shows a small protocol clearly:

- a local folder as the interface
- hatching write protection
- plain success and failure states
- tools that are easy for other agents to call

If you want to add a nest to another folder, copy the conventions, keep the layout plain, and keep `.hatching` sacred.
