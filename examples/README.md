# 🪺 examples

Optional helpers. Copy any of them next to your `nestling.sh` if you want them.

- [`feed.sh`](feed.sh) — put items into `.nest/in/`.
- [`sweep.sh`](sweep.sh) — prune old items from `.nest/out/`.
- [`telegram_inbox.py`](telegram_inbox.py) — Telegram bot that drops messages into `.nest/in/`.

Run all of them from the nest root (the directory containing `.nest/`).

## feed.sh

Three ways to feed the nest:

```bash
./examples/feed.sh --text "hello"          # plain text item
./examples/feed.sh path/to/file.txt        # copy a file (default --copy)
./examples/feed.sh --move path/to/file.txt # hand off ownership instead
```

You can append a name as the last positional arg (`./examples/feed.sh --text "hi" note.txt`). If the name already exists in `.nest/in/`, the script fails immediately. In all modes the item is written as `<name>.hatching` first, then renamed to `<name>` only when complete.

## sweep.sh

`out/` is not auto-cleaned. If items have downstream collectors, they take ownership; otherwise prune by age:

```bash
./examples/sweep.sh         # default: items older than 7 days
./examples/sweep.sh 30      # custom age in days
```

Or use `find` directly:

```bash
find .nest/out -mindepth 1 -maxdepth 1 -mtime +7 -exec rm -rf {} +
```

Sweeping is a policy choice, not a protocol rule — that's why it lives here, not in `nestling.sh`.

## telegram_inbox.py

Each Telegram message becomes a directory in `.nest/in/`. The bot writes it as `<name>.hatching/` first — with `message.txt`, `meta.json`, and any attachments — then renames to `<name>/` only when complete. From `nestling.sh`'s perspective it's just another ready item.

Setup:

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install python-telegram-bot

export TELEGRAM_BOT_TOKEN="123456:ABCDEF_your_token_here"
export TELEGRAM_ALLOWED_USER_IDS="123456789"

python3 examples/telegram_inbox.py
```

Three env vars:

- `TELEGRAM_BOT_TOKEN` — bot token.
- `TELEGRAM_ALLOWED_USER_IDS` — comma-separated user IDs allowed to send.
- `TELEGRAM_INBOX_DIR` — where to write items. Defaults to `./.nest/in`.
