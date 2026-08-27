# 🪺 nestlings

A tiny, file-based protocol for making a folder ready to receive material.

One script. One folder convention.

When you open `.nest/in/`, you are looking at the items ready to be tended.

```
.nest/
  nestling.sh
  in/
  out/
  dropped/
  tend.md
```

## What a nest is for

A nest is the entrance and transport layer for a folder. A new repository can
begin with only `.nest/`: material can arrive before anyone knows whether it
will become evidence, memory, work, or nothing at all.

Items arrive in `in/`. A human, agent, or process tends them according to the
folder's local policy. Hatched items land in `out/`; dropped items land in
`dropped/` with a reason.

Nestlings owns safe intake, claiming, and disposition. It does not decide what
an item means, preserve project memory, plan work, or require a particular
agent runtime. Those choices belong to the tender and the folder. Other tools
may be selected as destinations when tending reveals a need for them, but they
are optional: a repository can remain useful with only its nest.

An item is one file or directory accepted into the nest. It may be an
unclassified piece of material, a shaped request, or material accompanied by a
note about what should happen. An item does not have to be a task.

To **tend** is to apply the folder's local policy to a claimed item. To
**hatch** is to complete that tending successfully by placing its result in
`out/`. Passing items through `in/`, `out/`, and `dropped/` leaves a simple
filesystem record of what happened.

## How nestlings works

An item can be a file or a directory.

```
.nest/
  in/
    item/
  out/
  dropped/
```

* items arrive in `in/`
* tended items are placed in `out/`
* failed items are placed in `dropped/`
* `.tending` means claimed
* `.landing` means being written

## Rules

1. Write protection: write as `<item>.landing`, then rename to `<item>` when complete.
2. Claim by suffix: `<item>` → `<item>.tending`
3. Tend from `in/`
4. Hatch to `out/`
5. Drop to `dropped/` with a sibling `<item>.reason.md`
6. Retry only directories explicitly marked with `.recoverable`; bounded retry
   state travels with the item as `.attempts` and `.recovery.md`

The file system is the protocol.

## Tending loop

1. Look at `.nest/in/`
2. Pick one ready item
3. Claim it by renaming it with `.tending`
4. Read `.nest/tend.md` if present
5. Apply the local policy
6. Either:
   * hatch by placing the result in `.nest/out/` using `.landing`
   * or move the item to `.nest/dropped/` and write a reason file

Other tenders must not touch anything ending in `.landing` or `.tending`.

An abandoned claim is not inferred from age alone. `stale` reports claimed
items older than a threshold without changing them; the process that owns the
nest decides whether a claim is abandoned and passes it to `resolve`. Resolution
returns a marked directory to `in/` while it is below the retry limit, otherwise
it drops the claim with a reason. Bare files and unmarked directories fail
closed and are dropped.

Set `NEST_MAX_ATTEMPTS` to a non-negative integer to change the default limit
of three. Producers should add `.recoverable` only when repeating the item is
safe. Nestlings does not decide whether a tender process is still alive.

## Passing between nests

When two folders communicate through nests, new material goes to the receiving
folder's `in/`, not the sending folder's `out/`.

The sender's `out/` records what it has tended. The receiver's `in/` holds what
it is being asked to tend.

## tend.md

`.nest/tend.md` is an optional conventional file that states the folder's local
policy for tending items.

If present, read it before tending.

Keep it short. Keep it concrete.

## Vendoring

To add a nest to another project, copy `nestling.sh` and `README.md` into
the project's `.nest/` directory, then run `./.nest/nestling.sh ensure` to
seed the trays:

```sh
mkdir -p <project>/.nest
cp nestling.sh README.md <project>/.nest/
<project>/.nest/nestling.sh ensure
```

`ensure` creates `in/`, `out/`, and `dropped/` next to itself.
`nestling.sh` operates on the `.nest/` directory it lives in, so each
vendored copy is self-contained.

## Commands

```
./nestling.sh ensure
./nestling.sh list
./nestling.sh ingest <src> [name]
./nestling.sh claim <n>
./nestling.sh complete <n> <result_src> [out_name]
./nestling.sh drop <n> <reason>
./nestling.sh stale [max-age-mins]   # read-only; default 10
./nestling.sh resolve <n> [reason]   # retry marked directories or drop
./nestling.sh sweep [days]   # remove out/dropped older than N days (default 14; pass 0 to sweep everything regardless of mtime). `.gitkeep` placeholders and `*.reason.md` siblings are preserved. Prints one line per item.
```
