# Tend

This nest is tended by following the instructions in this file.

Edit this file to suit the current task.
Keep instructions concrete.
Prefer short operational guidance over general commentary.

## Purpose

Process items from `.nest/in/`.

For each ready item:
- claim it
- inspect it
- do the required work
- place the result in `.nest/out/`
- or place the item in `.nest/dropped/` with a brief reason

## Ready items

A ready item is an entry in `.nest/in/` that does not end in:
- `.hatching`
- `.tending`

Items may be files or directories.

## Working stance

Be conservative and explicit.

Do not:
- guess unnecessarily
- fabricate missing information
- overwrite meaning carelessly
- force marginal inputs through the workflow

Prefer dropping an item with a clear reason over producing a misleading result.

## Expected output

Unless otherwise specified:
- produce one output per input
- make outputs clear and directly usable
- keep outputs as simple as the task allows
- use stable, unsurprising names

## Drop criteria

Drop an item when:
- it is invalid for the task
- it cannot be read or processed safely
- key information is missing
- the requested transformation cannot be completed reliably

Write a short reason that would help a later agent or user understand what happened.

## Task-specific instructions

Replace this section with instructions for the current nest.

State:
- what the input items are
- what to produce
- any naming rules
- any formatting rules
- any constraints
- any drop criteria beyond the defaults