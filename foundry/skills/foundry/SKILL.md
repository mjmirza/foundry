---
name: foundry
description: Reviews and builds agentic tooling to best practice across any AI coding assistant. Use when writing, reviewing, debugging, or porting a skill, hook, MCP server, subagent, slash command, settings file, or any agent configuration, and when a skill does not trigger, a hook blocks the wrong thing, or an MCP server does not appear.
license: MIT
argument-hint: "[mode or focus area]"
metadata:
  author: Mirza Iqbal
  version: "0.1.0"
---

Review and build agentic tooling for correctness, portability, safety, and token cost. Report only genuine problems. Do not nitpick, do not invent issues, and do not rewrite the user's working code unless they ask for the fix to be applied.

Read `${CLAUDE_SKILL_DIR}/references/principles.md` first. It carries the five doctrines that govern everything below. Correctness over confidence, precision over zeal, portability first, token budget discipline, lifecycle and clarity.

## What this skill covers

Skills, hooks, MCP servers, subagents, slash commands, context engineering, settings, and security. The full agentic stack, not one framework, and across Claude Code, Codex, Gemini CLI, Cursor, Cline, and Copilot.

## Modes

The skill accepts an optional argument that narrows the work.

- No argument. Review the tooling in scope and report findings.
- `build skill|hook|mcp|subagent|command`. Build that artifact to the matching reference, write its test, register it, and confirm it fires.
- `review <path>`. Audit existing tooling at that path for the mistakes in `${CLAUDE_SKILL_DIR}/references/anti-patterns.md`.
- `harden`. Run a security pass using `${CLAUDE_SKILL_DIR}/references/security.md`.
- `port <assistant>`. Map the tooling to another assistant using `${CLAUDE_SKILL_DIR}/references/portability.md`, translating the capability, not only the file.

## Review process

Load only the reference files relevant to the artifact in scope.

1. Apply the doctrines in `${CLAUDE_SKILL_DIR}/references/principles.md`.
2. Check skills against `${CLAUDE_SKILL_DIR}/references/skills.md`.
3. Check hooks against `${CLAUDE_SKILL_DIR}/references/hooks.md`.
4. Check MCP servers against `${CLAUDE_SKILL_DIR}/references/mcp-servers.md`.
5. Check subagents against `${CLAUDE_SKILL_DIR}/references/subagents.md`.
6. Check slash commands against `${CLAUDE_SKILL_DIR}/references/commands.md`.
7. Check context and rule files against `${CLAUDE_SKILL_DIR}/references/context-engineering.md`.
8. Check settings and permissions against `${CLAUDE_SKILL_DIR}/references/settings-and-config.md`.
9. Check security against `${CLAUDE_SKILL_DIR}/references/security.md`.
10. Check portability against `${CLAUDE_SKILL_DIR}/references/portability.md`.
11. Confirm tests and evals against `${CLAUDE_SKILL_DIR}/references/testing-and-evals.md`.
12. Cross check every finding against `${CLAUDE_SKILL_DIR}/references/anti-patterns.md`.

## Output format

Organize findings by file. For each finding.

1. State the file and the relevant lines.
2. Name the rule being broken in one short sentence.
3. Show a brief before and after.

Skip files with no issues. End with a short prioritized summary, highest impact first. Report only. Apply a fix only when the user asks.

## Core instructions

- Verify any path, flag, config key, or exit code against the live client before stating it as fact. Tool behavior changes between versions.
- Every rule has a leave alone clause. Do not flag intentional, working patterns.
- A built artifact that was never observed firing is not done.

## References

- `${CLAUDE_SKILL_DIR}/references/principles.md` the five doctrines and the review format.
- `${CLAUDE_SKILL_DIR}/references/skills.md` description as router, the three layer model, frontmatter, paths, packaging.
- `${CLAUDE_SKILL_DIR}/references/hooks.md` events, exit codes, stdin parsing, fail open, the footguns.
- `${CLAUDE_SKILL_DIR}/references/mcp-servers.md` registration, tool naming, token cost, supply chain.
- `${CLAUDE_SKILL_DIR}/references/subagents.md` isolation, parallelism, what a subagent does not inherit.
- `${CLAUDE_SKILL_DIR}/references/commands.md` frontmatter, command versus hook versus skill.
- `${CLAUDE_SKILL_DIR}/references/context-engineering.md` lean context, index do not paste, measure the budget.
- `${CLAUDE_SKILL_DIR}/references/settings-and-config.md` merge not overwrite, least privilege, per assistant config.
- `${CLAUDE_SKILL_DIR}/references/security.md` injection defense, egress, secrets, supply chain, no attribution.
- `${CLAUDE_SKILL_DIR}/references/portability.md` the install path matrix and capability translation.
- `${CLAUDE_SKILL_DIR}/references/testing-and-evals.md` the seven case test and how to eval each artifact.
- `${CLAUDE_SKILL_DIR}/references/anti-patterns.md` the centerpiece catalog of real mistakes, each with the fix.
