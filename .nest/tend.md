# Tend

This nest is tended by following the instructions in this file.

`tend.md` is the policy surface — everything the nestling protocol leaves
to judgement lives here. The file is **not** enforced. Sections below are a
suggested skeleton; keep what helps, remove what doesn't, add what's missing.

Two rules of thumb for writing this file:

* Keep it short. A page is a long tend.md.
* Operational, not descriptive. *"For each item, do X then Y"* beats
  *"this nest handles X-shaped work."*

---

## Purpose

One sentence on what this nest is for. *"Process incoming customer
emails into draft replies."* *"Triage research links into project
threads or scribble ideation."* If the purpose can't fit in a sentence,
the nest is probably trying to do too much — split it.

## Items

What kinds of items arrive here. Note any *shapes* that the tender
should recognise: a directory containing `prompt.md`, a single
markdown file, a payload directory with a `run.sh`, etc. If items are
fully opaque and judged item-by-item, say so.

## Decide

The decision procedure. The most important section. Walk through it as
a checklist; the answer to each question routes the item.

1. Is the item ready (no `.tending` or `.hatching` suffix)?
2. Is its shape recognised? If not, → drop.
3. Can the work be completed in this tend cycle? If yes, do it.
4. Should this become shaped work? If yes, → mv to `.loom/threads/`.
5. Should this surface again later? If yes, → mv to
   `.groundhog/schedule/once/<date>/`.
6. Otherwise → drop with reason.

This is a template; fill in the questions that actually matter for
this nest.

## Act

What to do for each decision branch. State output naming, intermediate
artefacts, and where results land.

* **Action items** — do the work; result file in `out/<item>/`.
* **Shaped work** — `mv` the item to `.loom/threads/<id>/`; leave a
  one-line receipt in `out/<item>.handed-off.md`.
* **Deferred** — `mv` into `.groundhog/schedule/once/<YYYY-MM-DD>/`.

## Drop when

Concrete drop criteria, in addition to the protocol-level ones (invalid,
unreadable, unsafe). The free-form reason file should help a later
tender (or future you) understand what happened.

* The required input is missing or ambiguous.
* The action would have side effects this nest is not authorised to take.
* The item duplicates one already tended today.

## Hard rules

Things the tender must not do regardless of judgement. This is the
trust-boundary — the place where mistakes are expensive enough that no
amount of cleverness should override the rule.

* Never send external messages (email, Slack, webhooks) without a
  human-confirmation step.
* Never modify state outside `.nest/`, `.loom/`, `.groundhog/`, and
  `.scribble/` without explicit permission in the item.
* Never tend an item that already has a sibling `<name>.reason.md` in
  `dropped/` — surface it instead.

## Context

Where to look for additional context the tender may need.

* Parent stitch's `instructions.md` (`cat ../../instructions.md` if
  this nest sits inside a loom thread).
* `.acorn/forage <person>` for any human named in the item (when
  acorn lands).
* Adjacent `README.md` for project conventions.

## Working stance

A short paragraph on disposition. Conservative or exploratory? Ask
questions or assume? Default to drop, default to act, default to defer?
This is the personality of the tender in this folder. Different nests
in the same tree can — and probably should — have different stances.

Be conservative and explicit. Do not guess unnecessarily, fabricate
missing information, overwrite meaning carelessly, or force marginal
inputs through the workflow. Prefer dropping with a clear reason over
producing a misleading result.

## Task-specific instructions

Anything that doesn't fit the structure above. Replace this section
freely.
