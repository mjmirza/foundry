# Changelog

All notable changes to Foundry are recorded here. The format follows Keep a Changelog, and the project uses semantic versioning.

## Unreleased

## 0.1.0 (2026-06-11)

### Added

- Initial release of the Foundry agent skill.
- Twelve reference files covering principles, skills, hooks, MCP servers, subagents, commands, context engineering, settings and config, testing and evals, security, portability, and the anti pattern catalog.
- A router SKILL.md in both the plugin format and the skills format, with the references shared through a symlink.
- Activation modes for review, build, harden, and port.
- Three executable linters, check-skill, check-hook, and check-mcp, each following the same hook standard Foundry teaches.
- An eval harness with good and bad fixtures that proves the linters catch every bad fixture and pass every good one, with secret shaped fixtures assembled at runtime.
- Cross assistant packaging. A Claude Code marketplace manifest, a plugin manifest, and a Codex agent config.
- A verified install path matrix across Claude Code, Codex, Gemini CLI, Cursor, Cline, and Copilot.
- Enterprise documentation. README, AGENTS.md, ARCHITECTURE, CONTRIBUTING, CODE_OF_CONDUCT, the design spec, and a community coverage map.
