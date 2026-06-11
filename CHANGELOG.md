# Changelog

All notable changes to Foundry are recorded here. The format follows Keep a Changelog, and the project uses semantic versioning.

## Unreleased

## 0.3.0 (2026-06-11)

After a three way adversarial audit, this release fixes real defects the audit found and closes the missing angles.

### Added

- check-command.sh, a fourth linter for slash commands, with good and bad fixtures and harness wiring.
- data/install-paths.json, a machine readable per client path map, so the installer and the docs cannot drift.
- A SECURITY.md disclosure policy, issue and pull request templates, CODEOWNERS, FUNDING, and an editorconfig.
- An examples directory with a real before and after produced by the hook linter.
- A foundry-check slash command that routes to the right linter.
- Published to npm as @nex8n/foundry. Run npx @nex8n/foundry to install the skill into a project. A package.json and a node launcher at bin/foundry.js wrap the installer.
- CI now runs on Ubuntu and macOS and adds a shellcheck step, with a least privilege permissions block. The macOS leg proves the BSD versus GNU rule the skill teaches.

### Fixed

- The installer was not actually non destructive. The rsync delete flag could remove a file placed in the install, and a foreign symlink at the client path was clobbered with no backup. The installer now never deletes, backs up any foreign file or symlink, and refreshes its own managed copy in place. Reproduced and proven by the integration test.
- The installer created symlinks at paths some clients do not read, and produced a duplicate skill with an unexpandable variable once installed. It now writes the universal copy plus the single Claude symlink, and excludes the nested skills format copy with an anchored pattern.
- The install path matrix was wrong on several clients and was called verified while being unverified. Corrected to the surveyed reality and reworded across the README, the changelog, and portability.md.
- Doctor handles a single skill install layout and uses if then else rather than a chained and or.
- Shellcheck is clean across every script.

## 0.2.0 (2026-06-11)

### Added

- A correct installer, install.sh, that writes the single universal copy and the per assistant symlink for Claude Code, Codex, Gemini, Cursor, and Cline, non destructively, with a backup of any file already in the way.
- A doctor health check that verifies both SKILL.md layouts, the references, the symlink, version sync, the linters, and the harness, for a checkout or an install.
- A deep end to end integration test that runs the real install, doctor, and linter commands in sequence and asserts the artifacts they produce, not only that they exit cleanly.
- A CI workflow that runs the shell syntax check, doctor, the eval harness, and the integration test, with the checkout action pinned to a commit SHA.

### Fixed

- Doctor now treats the marketplace manifest as optional, so an installed skill, which does not carry that repo level file, reports healthy. The deep test caught this.
- The installer refreshes its managed copy in place, so a re install is idempotent and does not pile up backups.

## 0.1.0 (2026-06-11)

### Added

- Initial release of the Foundry agent skill.
- Twelve reference files covering principles, skills, hooks, MCP servers, subagents, commands, context engineering, settings and config, testing and evals, security, portability, and the anti pattern catalog.
- A router SKILL.md in both the plugin format and the skills format, with the references shared through a symlink.
- Activation modes for review, build, harden, and port.
- Three executable linters, check-skill, check-hook, and check-mcp, each following the same hook standard Foundry teaches.
- An eval harness with good and bad fixtures that proves the linters catch every bad fixture and pass every good one, with secret shaped fixtures assembled at runtime.
- Cross assistant packaging. A Claude Code marketplace manifest, a plugin manifest, and a Codex agent config.
- A surveyed install path matrix across Claude Code, Codex, Gemini CLI, Cursor, Cline, and Copilot.
- Enterprise documentation. README, AGENTS.md, ARCHITECTURE, CONTRIBUTING, CODE_OF_CONDUCT, the design spec, and a community coverage map.
