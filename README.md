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

That is the whole install. There is no package, no manifest, no scaffolder.

## Terminology

Three actors:

- **nest** — a `.nest/` folder at the root of a project.
- **nestling** — anything that tends the nest: a script, an AI, or a human.
- **tend** — notice a ready item in `in/` and handle it.

Three states an item can be in:

- **hatching** — still being written. Ends in `.hatching`; off limits.
- **tending** — claimed by a nestling. Ends in `.tending`; others must skip it.
- **unhatched** — could not be tended. Lives in `unhatched/` with a `.reason.md` sibling.

## The protocol

A nest is a `.nest/` folder with three children:

```text
.nest/
  in/         ready items
  out/        tended items
  unhatched/  failed items, each with a .reason.md sibling
```

An item can be a single **file** (e.g. `note.txt`) or a whole **directory** (e.g. `inbox-msg-42/`). In the rules below, `<item>` stands in for its name.

Three rules:

1. **Hatching write protection** — write as `<item>.hatching`, rename to `<item>` when complete. Never tend anything ending in `.hatching` or `.tending`.
2. **Claim, tend, place** — to tend an item, rename `<item>` → `<item>.tending` inside `.nest/in/`. Place the result in `.nest/out/` using the same hatching protection on the way in.
3. **Unhatch on failure** — move the item to `.nest/unhatched/<item>` and write a sibling `<item>.reason.md` explaining why.

The file system is the protocol. No network, no database, no queue, no dependencies.

## Item states

```text
.nest/in/         <item>.hatching  →  <item>  →  <item>.tending
.nest/out/        <item>.hatching  →  <item>
.nest/unhatched/  <item>           +  <item>.reason.md
```

Three locations, each with its own progression.

## Activity

Nestlings write startup and failure events to **stderr**. Success is visible in `.nest/out/`; failure in `.nest/unhatched/`. Set `POLL_INTERVAL` (seconds, default 1) to change poll cadence. For persistence:

```bash
./nestling.sh 2>> nestling.log
```

## tend.md

[`tend.md`](tend.md) is an optional, conventional file describing what a nestling should do with items in a nest (or inside a single item directory). Whoever tends — human, AI, or script — reads it and acts. The reference `tend.md` in this repo mirrors `nestling.sh`.

## Examples

Optional helpers live in [`examples/`](examples/): `feed.sh` puts items into `.nest/in/`, `sweep.sh` prunes `.nest/out/` by age, and `telegram_inbox.py` is an optional Telegram inbox bot.
