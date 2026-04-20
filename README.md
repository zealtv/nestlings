# 🪺 nestlings

A tiny, file-based protocol for agents that tend a folder.

`nestling.sh` is the whole thing. One script, one folder convention.

## Install

Drop `nestling.sh` into any folder and run it. The nest is created on first run.

```bash
curl -fsSL https://raw.githubusercontent.com/zealtv/nestlings/main/nestling.sh -o nestling.sh
chmod +x nestling.sh
./nestling.sh
```

Or from a clone:

```bash
cp /path/to/nestlings/nestling.sh .
./nestling.sh
```

That is the whole install. There is no package, no manifest, no scaffolder. The optional helpers in `examples/` (`feed.sh`, `sweep.sh`, `telegram_inbox.py`) can be copied alongside if you want them.

## Terminology

- **nest** — a `.nest/` folder at the root of a project.
- **nestling** — anything that tends the nest: a script, an AI, or a human.
- **tend** — notice a ready item in `in/` and handle it.
- **hatching** — an item still being written. It ends in `.hatching` and must be ignored.
- **tending** — an item a nestling has claimed. It ends in `.tending` and other nestlings must skip it.
- **unhatched** — an item that could not be tended. It is moved to `unhatched/` with a `.reason.md` sibling.

## The protocol

A nest is a `.nest/` folder with three children:

```text
.nest/
  in/         ready items waiting to be tended
  out/        tended items for other agents to collect
  unhatched/  items that could not be tended, with a .reason.md sibling
```

An item can be a single **file** (e.g. `note.txt`) or a whole **directory** (e.g. `inbox-msg-42/`). Both flow through the same lifecycle. In the rules below, `<item>` stands in for the item's name.

Rules:

- Write new items as `<item>.hatching`, then rename to `<item>` when complete.
- Never tend anything still ending in `.hatching` or `.tending`.
- Nestlings watch `.nest/in/` for ready files or directories.
- A nestling claims an item by renaming `<item>` → `<item>.tending` inside `.nest/in/` before processing. `mv` is atomic on a single filesystem; the rename is the claim.
- On success, the item is removed from `.nest/in/` (typically moved to `.nest/out/` using the same hatching protection on the way in).
- On failure, the item is moved to `.nest/unhatched/` with a human- and agent-readable `<item>.reason.md` sibling next to it.
- The file system is the protocol. No network, no database, no queue, no dependencies.


A nestling may process an item, enrich it, sort it, archive it, or simply ingest it for later use. Inputs and outputs are decoupled. The reference nestling in this repo keeps things simple: it moves ready items from `in/` to `out/` using the same hatching protection.

## Item states

The two axes are **where** the item lives and **what suffix** (if any) it carries. The item itself can be a file or a directory either way.

| Where              | Name              | Meaning                                      |
| ------------------ | ----------------- | -------------------------------------------- |
| `.nest/in/`        | `<item>.hatching` | being written or copied — off limits         |
| `.nest/in/`        | `<item>`          | ready to be tended                           |
| `.nest/in/`        | `<item>.tending`  | claimed by a nestling — others skip it       |
| `.nest/out/`       | `<item>.hatching` | being placed — off limits to collectors      |
| `.nest/out/`       | `<item>`          | tended and stored                            |
| `.nest/unhatched/` | `<item>`          | failed; see sibling `<item>.reason.md`       |

## Activity output

Nestlings write startup and failure events to **stderr**, not to a log file. The filesystem already records success (items appear in `out/`) and failure (items appear in `unhatched/` with a `.reason.md`). If you want a persistent log, redirect:

```bash
./nestling.sh 2>> nestling.log
```

## Feeding the nest

With `nestling.sh` running, push items into `.nest/in/` and watch them flow to `.nest/out/`. The `examples/feed.sh` helper does this for you.

### Feed plain text

```bash
./examples/feed.sh --text "hello"
```

If you omit the name, `examples/feed.sh` creates a short unique text filename such as:

```text
note-20260413-214500-12345.txt
```

You can also provide a name:

```bash
./examples/feed.sh --text "hello" note.txt
```

### Feed an existing file

```bash
./examples/feed.sh path/to/file.txt
```

### Feed an existing directory

```bash
./examples/feed.sh path/to/folder
```

### Hand off ownership instead of copying

```bash
./examples/feed.sh --move path/to/file.txt
```

`examples/feed.sh` defaults to `--copy`. That is the safer choice for agents because the source item stays in place. In both modes, the script writes to `.nest/in/name.hatching` first and renames to `.nest/in/name` only when complete.

If the destination name already exists, `examples/feed.sh` fails immediately.

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

This repo includes `examples/telegram_inbox.py` as an optional inbox bot.

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

python3 examples/telegram_inbox.py
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

## Sweeping `out/`

`out/` is not auto-cleaned. If items have downstream collectors, they take ownership. Otherwise prune by age:

```bash
./examples/sweep.sh         # default: remove items older than 7 days
./examples/sweep.sh 30      # custom age in days
```

Or use `find` directly:

```bash
find .nest/out -mindepth 1 -maxdepth 1 -mtime +7 -exec rm -rf {} +
```

Sweeping is a policy choice, not a protocol rule — keep it separate from `nestling.sh`.

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
