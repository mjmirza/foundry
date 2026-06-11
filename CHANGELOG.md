# Changelog

All notable changes to Foundry are recorded here. The format follows Keep a Changelog, and the project uses semantic versioning.

## Unreleased

## 0.4.2 (2026-06-11)

### Added

- A What you get section that states the value in outcome terms, the bugs it prevents and the hour it saves, before the machinery, and a three step from install to first win walk so a reader gets a real review of their own code in three commands.

### Changed

- Dropped the hard coded version badge that drifted out of sync, the npm badge already shows the live version. Updated the checks count.

## 0.4.1 (2026-06-11)

### Fixed

- check-docs reported valid heading anchors as broken on any doc with more than one heading. Three bugs combined. The slug list was emitted without newlines so every heading slug ran together, a pipefail plus a grep early exit turned a real match into a failure, and the slug collapsed consecutive dashes while GitHub does not. Anchors are now compared by slugifying both sides through the same function, and the heading lookup uses process substitution so the early exit cannot trip pipefail. Found while adopting the checker into another project, where a long table of contents lit up entirely false.
- A bare word link target in a syntax example, such as the url in `![alt](url)`, was read as a broken link. A real local link carries an extension or a path separator, so a bare word that does not resolve is now treated as a placeholder.

### Added

- An allow entry ending in a slash in `.docs-orphan-allow` now exempts a whole subtree from the orphan pass, so an archival tree is marked standalone in one line.
- Regression evals for a valid multi heading table of contents, a placeholder target, and the subtree orphan allow.

## 0.4.0 (2026-06-11)

### Added

- check-docs.sh, a deep markdown hygiene checker. It finds broken local links, broken heading anchors, missing images, and orphan docs that nothing references. The orphan pass is the part most link checkers lack, the docs equivalent of dead code, and it is anchor slug aware and skill dir aware so a `${CLAUDE_SKILL_DIR}` reference path resolves. It honors a `.check-docs-ignore` for excluded paths and a `.docs-orphan-allow` for intentionally standalone files.
- A docs hygiene block in the eval harness that builds a clean set and a broken set at runtime and asserts each verdict, plus a Docs hygiene step in CI on both Ubuntu and macOS.
- A reference rule in the documentation reference that every doc must be reachable from another doc, so a markdown file never sits disconnected.

### Fixed

- The orphan pass now treats a real markdown link as a reachability signal, so a bare same directory link such as `guide.md` no longer falsely flags its target as an orphan, while inline code reference paths are still honored for skill bodies.

## 0.3.1 (2026-06-11)

### Added

- A GitHub Actions publish workflow that runs npm publish with provenance and OIDC, so the package is signed and linked to its source commit and the workflow that built it. It runs on a GitHub Release.

### Changed

- The published npm package now carries npm provenance.

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
