# Spec

## Purpose

Define the smallest readable system in which a nestling tends its nest.

## What is a nestling

A nestling is an agent responsible for a folder. It can be a script, an AI, or a human. This spec describes how a nestling reads its inbox, tends each file, and places the result in done.

## The nest

```
inbox/    untended files
done/     tended files
failed/   files the nestling could not tend
log/      plain text records
```

## File states

- `name.incoming` — being written, must not be tended
- `name.ready` — safe to tend
- `done/name` — successfully tended
- `failed/name.ready` — kept for inspection

## Rules

1. The file system is the transport.
2. The nestling only tends files in `inbox/` ending in `.ready`.
3. Writers must write to `.incoming` and then rename to `.ready`.
4. Poll every `POLL_INTERVAL` seconds. Default: `1`.
5. On failure, move the source to `failed/` and log the error.
6. On success, log the action.
7. Keep it small and readable.

## Tending flow

1. poll `inbox/`
2. find `*.ready`
3. read the file
4. apply the transform
5. write the result to `done/name.incoming`
6. rename to `done/name`
7. remove the source from `inbox/`
8. write a log entry

## Failure

When tending fails:

1. keep the source filename intact
2. move the source to `failed/`
3. append an error to the log
4. keep polling

## Logging

A single log file: `log/nestling.log`. Each line:

```
timestamp | nestling | event | filename | message
```

## Demo transform

The demo prepends one line to the file:

```
[tended by nestling]
```

This keeps the demo inspectable.

## Configuration

- `POLL_INTERVAL=1`

## Non-goals

This is not a workflow engine. It exists to show:

- folder-based tending
- staged file protection
- simple failure handling
