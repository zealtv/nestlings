# 🐣 nestlings

A tiny, file-based protocol for agents that tend a folder.

One script. One folder convention.

When you open `.nest/in/`, you are looking at the work that is ready now.

```text
.nest/
  in/
  out/
  dropped/
```

## How nestlings works

An item can be a file or a directory.

```text
.nest/
  in/
    item/
  out/
  dropped/
```

- items arrive in `in/`
- tended items are placed in `out/`
- failed items are placed in `dropped/`
- `.tending` means claimed
- `.hatching` means being written

## Rules

1. Write protection: write as `<item>.hatching`, then rename to `<item>` when complete.
2. Claim by suffix: `<item>` → `<item>.tending`
3. Tend from `in/`
4. Hatch to `out/`
5. Drop to `dropped/` with a sibling `<item>.reason.md`

The file system is the protocol.

## Agent loop

1. Look at `.nest/in/`
2. Pick one ready item
3. Claim it by renaming it with `.tending`
4. Read `tend.md` if present
5. Work
6. Either:
   - place the result in `.nest/out/` using `.hatching`
   - or move the item to `.nest/dropped/` and write a reason file

Never touch anything ending in `.hatching` or `.tending`.

## tend.md

`tend.md` is an optional conventional file that tells a human or agent what to do with items in the nest.

If present, read it before tending.

Keep it short. Keep it concrete.

## Run

```text
./nestling.sh
```

Set `POLL_INTERVAL` in seconds to change poll cadence.
