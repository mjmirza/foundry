---
description: Run the right Foundry linter on a file or skill and report the findings. Detects a hook, a skill, an MCP config, or a slash command from the target.
argument-hint: "<path to a hook, skill dir, mcp config, or command>"
allowed-tools: Bash, Read
---

Run the matching Foundry linter on the path the user gave as the argument.

Pick the linter by the target.

- A shell hook, a `.sh` file, use `scripts/check-hook.sh`.
- A skill directory or a `SKILL.md`, use `scripts/check-skill.sh`.
- An MCP config, a `.json` with an `mcpServers` block, use `scripts/check-mcp.sh`.
- A slash command, a `.md` with frontmatter, use `scripts/check-command.sh`.
- A documentation directory or a tree of markdown, use `scripts/check-docs.sh` to find broken links and orphan docs.

The scripts live inside the installed Foundry skill, under the `.agents/skills/foundry` or `.claude/skills/foundry` path, or under `foundry/scripts` in a repo checkout. Run the chosen linter on the argument.

Report each finding as the file and the rule broken, in the Foundry review format. If there are no findings, say the target passes and is clean. Do not rewrite the user's file. Report only.
