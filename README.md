# nestlings

A tiny, file-based protocol for tending items of work.

A nestling is one ready item. Nestlings are tended one at a time.

When you open `.nest/in/`, you are looking at the work that is ready now.

```text
.nest/
  in/
  out/
  dropped/
```

## How nestlings works

A nestling can be a file or a directory.

```text
.nest/
  in/
    item/
  out/
  dropped/
```

- root entries in `in/` are ready now
- claimed entries end with `.tending`
- entries being written end with `.hatching`
- completed results are placed in `out/`
- failed items are placed in `dropped/`

## Rules

1. Write safely: write as `<item>.hatching`, then rename to `<item>` when complete.
2. Claim by suffix: `<item>` → `<item>.tending`
3. Tend from `in/`
4. Complete by move into `out/`
5. Drop by move into `dropped/` and write `<item>.reason.md`

The file system is the protocol.

## Agent loop

1. Look at `.nest/in/`
2. Pick one ready item
3. Read `tend.md` if present
4. Claim it by renaming it with `.tending`
5. Work
6. Either:
   - place the result in `.nest/out/` using `.hatching`
   - or move the item to `.nest/dropped/` and write a reason file

Never touch anything ending in `.hatching` or `.tending` unless you are the actor that created that state.

Keep nestlings small. Split work upstream when one item starts carrying too much.

## tend.md

`tend.md` is the conventional file that tells a human or agent what the nest is for.

Keep it short. Keep it concrete.

It can contain:

- a brief
- notes
- links
- constraints
- a checklist

## Commands

```text
./nestling.sh ensure
./nestling.sh list
./nestling.sh ingest <src> [name]
./nestling.sh claim <name>
./nestling.sh complete <name> <result-src> [out-name]
./nestling.sh drop <name> [reason...]
```
