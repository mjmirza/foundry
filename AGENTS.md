# AGENTS.md

This repository is Foundry, an agent skill that teaches an AI coding assistant to build and review agentic tooling at a high standard.

## Load the skill

If your assistant supports the Agent Skills format, load the skill at `foundry/SKILL.md`. The skills format copy is at `foundry/skills/foundry/SKILL.md`, and the reference files live under `foundry/references/`. Read `foundry/references/principles.md` first.

## The operating rules

When you build or review a skill, hook, MCP server, subagent, command, settings file, or any agent configuration, follow the five doctrines.

1. Correctness over confidence. Verify a path, flag, config key, or exit code against the live client before you state it as fact.
2. Precision over zeal. Flag and report. Do not rewrite working code on your own. Every rule has a leave alone clause.
3. Portability is first class. Write once, install everywhere, with the correct per assistant path and symlink.
4. Token budget discipline. Keep the entry file lean. Encode edge cases and real mistakes, not what the model already knows.
5. Lifecycle and clarity. Keep manifest versions in sync and document the layout.

A built artifact that was never observed firing is not done. The full mistake catalog is in `foundry/references/anti-patterns.md`.
