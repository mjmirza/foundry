# Foundry Design Spec

Date. 2026-06-11
Status. Approved direction, building v0.1
Author. Mirza Iqbal

## What Foundry is

Foundry is one installable, portable agent skill that turns any AI coding assistant into an expert at designing, building, operating, and hardening agentic tooling. It covers the full agentic stack rather than a single framework. Skills, hooks, MCP servers, subagents, slash commands, context engineering, settings, and security.

It is modeled on the proven shape of `twostraws/SwiftUI-Agent-Skill` (a dense, anti mistake, review oriented skill that encodes the errors LLMs actually make) and extended far past it in scope, portability, executable checks, and evals.

The slug is `foundry`. The repo lives at `~/repositories/foundry`, MIT licensed, public, a distribution and authority asset.

## Why it is original

Nobody owns a high quality, cross assistant skill that teaches an agent to BUILD agentic tooling well. The deepest real source for it is the agent-os corpus (the hook authoring standard, skill authoring doctrine, MCP registration fidelity, testing protocol, security rules), distilled into a portable, vendor neutral skill.

## The five doctrines (mined from the reference repo scar tissue)

1. Correctness over confidence. A real PR shipped backwards guidance. Every Foundry rule is grounded in real practice, and the riskiest rules are backed by runnable checks.
2. Precision over zeal. Real PRs and issues were rules that degraded working code by over firing. Every Foundry rule carries a leave alone clause and flags rather than auto fixes.
3. Portability is first class. A real issue was a wrong install path. Foundry ships exact per assistant install paths and the gotchas.
4. Token budget discipline. Encode only edge cases, surprises, soft deprecations, and real mistakes. Never repeat what LLMs already know.
5. Lifecycle and clarity. Keep manifest versions in sync, document the packaging layout, and treat skill sprawl as a real problem.

## Packaging (cross assistant, mirrors the reference and improves it)

```
foundry/                              repo root
  README.md                           dual audience, badges, per assistant install
  AGENTS.md                           cross assistant root pointer
  LICENSE                             MIT
  CHANGELOG.md  CONTRIBUTING.md  CODE_OF_CONDUCT.md  .gitignore
  .claude-plugin/marketplace.json     makes the repo a Claude Code marketplace
  assets/                             light mode logo and icon, no purple
  docs/spec/...                       this document and the architecture doc
  foundry/                            the skill payload
    SKILL.md                          plugin format, relative reference paths
    .claude-plugin/plugin.json        plugin manifest, skills points at ./skills/
    agents/openai.yaml                Codex config (agentskills.io format)
    agents/gemini.yaml                Gemini config
    assets/                           icon png and svg
    references/                       the 12 dense reference files
    scripts/                          executable linters plus their tests
    evals/                            fixtures and a runner
    skills/foundry/SKILL.md           skills format, uses CLAUDE_SKILL_DIR paths
    skills/foundry/references         symlink to ../../references (no duplication)
```

The dual SKILL.md layout makes both install paths work. The `npx skills add` path reads the skills format copy. The Claude Code plugin marketplace path reads the plugin format copy. The references live once and are symlinked, exactly the trick the reference repo uses.

## The 12 reference files (dense imperative bullets, bad to good, anti mistake)

1. principles.md. The five doctrines, the review output format, the leave alone discipline.
2. skills.md. Description as router so it auto triggers, the three layer model, frontmatter, invocation flags, the save scripts heuristic, structure clarity, version sync, token budget.
3. hooks.md. Events, shebang, set minus u o pipefail and never minus e, parse stdin JSON not env, POSIX character classes not PCRE escapes, exit code semantics, fail open, central logging, continueOnBlock, mcp_tool hooks, the args exec form, terminal isolation.
4. mcp-servers.md. Transports, tool naming and descriptions, registration in the correct file, onboarding first DX, env handling, supply chain and tool poisoning defense.
5. subagents.md. Context isolation, when to fan out, worktree isolation, judge panels, loop until dry, over spawning.
6. commands.md. Frontmatter required or it will not surface, argument hint, command versus hook versus skill, naming.
7. context-engineering.md. Context hygiene, guided exploration, compaction, structured notes, subagent isolation.
8. settings-and-config.md. settings.json structure, permissions least privilege, env, merge not overwrite, per assistant config.
9. testing-and-evals.md. The seven type test gauntlet (positive, negative, stress, boundary, performance, idempotency, fail open), fixtures, how to eval agentic tooling.
10. security.md. Inbound injection defense, egress discipline, secrets and env, no AI attribution, MCP supply chain.
11. portability.md. The per assistant matrix. Claude Code, Codex, Gemini CLI, Cursor, Cline, Copilot. Concept to mechanism mapping, exact install paths, gotchas, registry and AGENTS.md.
12. anti-patterns.md. The centerpiece catalog of the top mistakes AI assistants make building agentic tooling, each bad to good, cross referencing the rest.

## Executable linters (the hard to copy edge, most skills are docs only)

In `foundry/scripts/`, each with good and bad test fixtures under `scripts/tests/`.

1. check-skill.sh. Frontmatter present, description quality heuristic, SKILL.md within a size budget, referenced files exist, version matches across manifests.
2. check-hook.sh. Shebang correct, set minus u o pipefail present and minus e absent, no PCRE escapes, reads stdin, fail open pattern, logging present.
3. check-mcp.sh. Registered in the correct file, version pinned, no secrets inline.

All linters fail open on their own errors, exit 0 on clean, exit 1 on a finding, and print findings in the review format.

## Evals (the differentiator the reference repo lacks)

In `foundry/evals/`. A runner exercises the linters against a corpus of good and bad fixtures and asserts the linters catch every bad fixture and pass every good one. This proves the anti mistake guidance is enforceable, not only asserted. The runner is the same shape as the agent-os test gauntlet.

## Activation modes

`/foundry` general review and build. `/foundry build skill|hook|mcp|subagent|command`. `/foundry review <path>` audits existing tooling for the mistakes. `/foundry harden` runs a security pass. `/foundry port <assistant>` ports tooling across assistants. Modes are optional arguments, the same pattern the reference repo uses with `argument-hint`.

## What it absorbs from the reference repo community asks

Marketplace packaging, the nested skills layout with a references symlink, cross assistant agent configs, registry friendliness, the rule softening lesson, correctness over backwards guidance, leave alone clauses, exact install paths, structure clarity, version sync, and lifecycle awareness. All of these are folded into the doctrines, the references, or the docs.

## Constraints honored

MIT license. No AI attribution anywhere. Light mode logo, no purple or banned palettes. README image references use absolute raw URLs. No em dashes or stray colons in prose. Author is Mirza Iqbal. Genesis commit on main then a feature branch and a pull request.

## Out of scope for v0.1

Auto fixing tooling (Foundry reviews and reports, it never rewrites the user's working code). A hosted registry. Per assistant binary installers beyond the documented `npx skills` and Claude plugin paths.
