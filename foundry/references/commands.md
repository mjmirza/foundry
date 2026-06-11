# Commands

How to write a slash command that appears, runs, and targets the right agent. A command is a saved prompt with frontmatter.

## Frontmatter is what makes it appear

```yaml
---
description: Audit the current branch for unmerged migrations.   # required, or it is invisible
argument-hint: "[path]"                                          # optional, shown on invoke
allowed-tools: Bash, Read, Grep                                  # optional, scope the tools
---
```

- A command with no `description` does not appear in the slash menu. This is the most common reason a command seems missing.
- Prefix the file name with an underscore to keep a helper command hidden from the menu while still callable.
- An `argument-hint` tells the user what to pass.

## Command, hook, or skill

Pick the right shape for the job.

- A command is for an action the user triggers on purpose, such as a review or a ship flow.
- A hook is for an automatic behavior that must fire on an event, such as a check before a push. If the user must remember to run it, it should have been a hook.
- A skill is for a body of know how the model applies when context matches, with references and scripts behind it.

Do not build a command for something that must always happen. Build a hook. Do not build a hook for a body of guidance. Build a skill.

## Target the right agent

When a command is meant to run with a specific subagent or model, say so in the command, so it runs in the right place rather than in whatever context happened to be active.

## Keep it lean

A command is loaded when invoked, so keep it focused. Put long reference detail in a skill the command can point to, not inline in the command body.

## Leave alone

Do not split a working single command into several just for tidiness. Confirm the user wants the change before restructuring a command they rely on.
