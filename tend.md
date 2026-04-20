# Goal

Move ready items from `.nest/in/` to `.nest/out/` without races or half-written data.

# Steps

1. **Watch** — scan `.nest/in/` for items whose name does not end in `.hatching` or `.tending`.
2. **Tend** — claim by renaming `<item>` → `<item>.tending`; stage in `.nest/out/` as `<item>.hatching`; rename to `<item>`.
3. **Unhatch** — on any failure, move the item to `.nest/unhatched/<item>` and write a sibling `<item>.reason.md` explaining why.
