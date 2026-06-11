# Architecture

How Foundry is laid out and why. The shape follows the proven SwiftUI Agent Skill packaging, with three additions. A wider reference set, executable linters, and an eval harness.

## Repository layout

```
foundry/                              repo root
  README.md                           dual audience, badges, per assistant install
  AGENTS.md                           cross assistant root pointer, read by many tools
  LICENSE  CHANGELOG.md  CONTRIBUTING.md  CODE_OF_CONDUCT.md  .gitignore
  .banned-words-allow                 project vocabulary allow list for the writing guard
  .claude-plugin/marketplace.json     makes the repo a Claude Code marketplace
  assets/                             logo, light mode, warm palette, no purple
  docs/                               this file, the spec, and the coverage map
  foundry/                            the skill payload
    SKILL.md                          plugin format, relative reference paths
    .claude-plugin/plugin.json        plugin manifest, skills points at ./skills/
    agents/openai.yaml                Codex config in the agentskills.io format
    assets/                           the square icon
    references/                       the 12 reference files
    scripts/                          the three linters
      check-skill.sh check-hook.sh check-mcp.sh
      tests/run-tests.sh              runs the eval harness
    evals/                            the harness and its fixtures
      run-evals.sh
      fixtures/hooks|skills|mcp/good|bad
    skills/foundry/SKILL.md           skills format, uses CLAUDE_SKILL_DIR paths
    skills/foundry/references         symlink to ../../references
```

## Why two SKILL.md files

Different install paths read different layouts. The plugin format copy at `foundry/SKILL.md` uses relative reference paths and is what the Claude Code plugin marketplace reads. The skills format copy at `foundry/skills/foundry/SKILL.md` uses the skill directory variable and is what the skills installer reads. The two stay in sync, and the reference files exist once under `foundry/references/`. The nested copy reaches them through a symlink, so there is no duplication.

## The reference set

The skill body is a thin router. It decides which reference to load for the artifact in scope. Every reference is dense imperative bullets, each one an anti mistake rule with a before and after where code helps, and a leave alone clause. The list is in the README and in the skill body.

## The linters

The three scripts under `scripts/` turn the highest value rules into runnable checks. Each one reads a target, prints findings in the review format, exits 0 when clean, exits 1 on a finding, and fails open when its input cannot be read. The linters follow the same hook standard Foundry teaches, so they are their own first example.

## The evals

`evals/run-evals.sh` runs every linter against a corpus of good and bad fixtures and asserts that each bad fixture is caught and each good fixture passes. Any secret shaped fixture is assembled at runtime, so no secret is committed. This is the proof that the guidance is enforceable rather than only asserted.

`evals/integration.sh` is the deep end to end test. It installs Foundry into a sandbox with `install.sh`, then runs `doctor.sh` and the eval harness from the installed copy, checks that a dry run changes nothing, that a file already in the way is backed up rather than deleted, that a re install is idempotent, and that the linters flag real bad inputs and pass real good ones. It runs the real commands in sequence and asserts the artifacts they produce. `scripts/doctor.sh` is the health check for a checkout or an install. `scripts/tests/run-tests.sh` runs the unit harness and the integration test together, and the CI workflow runs both on every push and pull request.

## Version sync

The version appears in the marketplace manifest, the plugin manifest, and both SKILL.md frontmatter blocks. They must all match. Version drift across manifests is a real, reported bug, and the skill linter checks for it.

## Cross assistant install

The skills installer writes the universal copy and the per assistant symlink. The README documents the per assistant install commands. The portability reference carries the install path matrix and the rule to translate a capability to the target client's real mechanism rather than copying a file that the target cannot use.
