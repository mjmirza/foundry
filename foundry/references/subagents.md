# Subagents

How to use subagents so they save context and wall clock instead of burning both. A subagent is a separate context that returns a conclusion to the main thread.

## When to fan out

Reach for a subagent when the work is independent and you only need the result, not the intermediate reading. Good fits are a broad search across many files, an analysis whose detail you do not need to keep, several implementation attempts to compare, or a long task to run while the main thread continues. Keep work inline when it is short, when each step depends on the last, or when you already know the file.

## Context isolation is the point

A subagent has its own context, so its large intermediate reads do not pollute the main thread. Tell each subagent that its final message is the return value, not a human facing reply, so it returns the conclusion and not a transcript. Ask for the distilled result, with sources, not the raw dump.

## Parallel work

- Run independent subagents at the same time in one batch, rather than one after another, when you need all the results.
- When several subagents write files that could collide, give each its own worktree so the writes do not conflict. Worktree isolation has a real setup cost, so use it only when parallel writers would otherwise clash.
- For unknown size work such as finding all of something, keep spawning finders until a round returns nothing new, rather than guessing a fixed count.
- When you need confidence in a finding, have independent subagents verify it from different angles, and keep it only when a majority agree.

## What a subagent does not inherit

- A subagent does not inherit the user's settings permissions. Re declare the allow rules it needs, or it will re prompt or stall.
- The PostToolUse hook does not fire for a subagent or Task completion. Do not rely on a post tool hook to collect subagent output. Collect it from the subagent's returned result instead.

## Cost discipline

A fleet of subagents multiplies token spend. Spawn the smallest number that covers the work. Prefer one well scoped finder over five overlapping ones. Name what was dropped if you cap coverage, so a reader is not misled into thinking everything was covered.

## Leave alone

Do not convert a working inline flow into a subagent fan out unless the isolation or the parallelism is a real win. Added orchestration that does not save context or time is just more surface to break.
