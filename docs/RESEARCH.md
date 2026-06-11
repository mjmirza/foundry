# Research and gap analysis

Foundry is built from a survey of the field, not from assumption. This document records how many repositories were mined, what they are, the gaps they leave open, and which of those gaps Foundry closes.

## How many repositories were mined

Three parallel research passes covered four lanes. Cursor rules, Claude Code resources, MCP and packaging, and the AGENTS.md standard. More than 35 distinct repositories were read end to end, including their open issues and pull requests. The dense anti mistake shape itself comes from the SwiftUI Agent Skill and its siblings. Star counts below are as reported by the GitHub API at survey time and are relative, not exact.

## The repositories

### Cursor rules and LLM coding rules

| Repo | Stars | What it is |
|---|---|---|
| PatrickJS/awesome-cursorrules | 39.9k | The largest rule registry, modern mdc format, framework and stack rules |
| grapeot/devin.cursorrules | 5.9k | Turns Cursor and Windsurf into a Devin style agent, scratchpad and lessons memory |
| sanjeed5/awesome-cursor-rules-mdc | 3.5k | Auto generates library rules, curated registry and a CLI |
| NeekChaw/RIPER-5 | 2.6k | A phase gate protocol so the agent does not jump ahead |
| flyeric0212/cursor-rules | 1.9k | Collected multi language and framework rule files |
| instructa/ai-prompts | 1.0k | Cross tool prompts and rules for Cursor, Cline, Windsurf, Copilot |
| caliber-ai-org/ai-setup | 1.1k | A CLI that syncs one rule source across Claude, Cursor, Copilot, OpenCode |
| rayfernando1337/llm-cursor-rules | 0.9k | CLAUDE.md and AGENTS.md generators, optimization rules, sub agents |
| matank001/cursor-security-rules | 0.4k | Per language secure development rules |
| Mindrally/skills | 0.1k | Many Claude Code skills converted from Cursor rules |
| jabrena/cursor-rules-java | 0.4k | An AI native workflow of rules, skills, and commands for Java |
| PanisHandsome/ai-rules-sync | 0.1k | One source of truth rule sync and convert across tools |

### Claude Code resources, skills, hooks, subagents

| Repo | Stars | What it is |
|---|---|---|
| anthropics/skills | 149k | The official public repo for Agent Skills, the canonical authoring patterns |
| anthropics/claude-code | 131k | Claude Code itself, the real feature request stream in its issues |
| anthropics/claude-plugins-official | 29k | The managed directory of plugins and the marketplace schema |
| hesreallyhim/awesome-claude-code | 46k | A curated list of skills, hooks, commands, orchestrators, plugins |
| wshobson/agents | 36k | A multi client agentic plugin marketplace of agents and commands |
| davila7/claude-code-templates | 27k | A CLI to install, configure, and monitor components |
| VoltAgent/awesome-agent-skills | 24k | A large community catalog of cross client agent skills |
| VoltAgent/awesome-claude-code-subagents | 21k | Specialized subagents organized by domain |
| disler/claude-code-hooks-mastery | 3.7k | The canonical hooks reference, all events, security blocking |
| wshobson/commands | 2.5k | A production set of slash commands |
| vijaythecoder/awesome-claude-agents | 4.3k | An orchestrated subagent team pattern |
| centminmod/my-claude-code-setup | 2.4k | A starter root instruction and memory configuration |

### MCP, AGENTS.md, packaging, and portability

| Repo | Stars | What it is |
|---|---|---|
| agentsmd/agents.md | 22k | The AGENTS.md open standard and its compatibility registry |
| vercel-labs/skills | 22k | The cross assistant skill installer and the skills directory |
| modelcontextprotocol/modelcontextprotocol | 8.3k | The MCP spec and its proposals for auth, transports, schema |
| modelcontextprotocol/registry | 6.9k | The community MCP server registry and publishing flow |
| modelcontextprotocol/mcpb | 1.9k | MCP bundles, one click packaging and signing |
| twostraws/SwiftUI-Agent-Skill | 4.0k | The dense anti mistake skill that Foundry is modeled on |
| twostraws/Swift-Agent-Skills | 2.0k | A skill directory and a build your own skill pattern |
| twostraws/SwiftAgents | 1.3k | An AGENTS.md as a skill for Swift |
| snyk/agent-scan | 2.5k | A security scanner for agents, MCP servers, and skills |
| cline/cline | 63k | A rules format and an MCP marketplace |
| continuedev/continue | 33k | Source controlled rules that can be enforced in CI |
| github/awesome-copilot | 34k | Copilot instructions, skills, and agent formats |
| open-gitagent/gitagent | 0.5k | A git native agent spec that exports to many formats |

## The gaps the others leave open, and how Foundry closes them

Every repo above ships rules about a stack, or a tool to install rules. None teaches an assistant how to build the tooling itself well. These are the gaps the survey surfaced, each now closed in Foundry.

| Gap in the field | Where it shows up | Closed in Foundry | Status |
|---|---|---|---|
| No portable skill that teaches how to author tooling, only rules about stacks | every repo above | the whole reference set plus the SKILL.md router | done |
| Hook footguns live as scattered bug fix PRs, never one reference | caliber, disler, claude-code issues | hooks.md and anti-patterns.md | done |
| No cross tool path and config truth table with a safe merge recipe | vercel-labs, devin, agents.md, caliber | portability.md | done |
| No fixtures or harness that prove a skill, hook, or MCP actually works | caliber, PatrickJS, mcp spec | testing-and-evals.md and the evals harness | done |
| MCP and skill supply chain safety is asked for but isolated | snyk, sanjeed5, mcpb, mcp registry | security.md, mcp-servers.md, check-mcp.sh | done |
| Context budget discipline is circled but never made a standard | caliber, sanjeed5, claude-code | context-engineering.md and principles.md | done |
| The invocation truth table, what inherits permissions and what fires, is undocumented | claude-code issues | settings-and-config.md, skills.md, hooks.md, subagents.md | done |
| The AGENTS.md to skills to hooks to rules interoperability map has no owner | agents.md open RFC | portability.md and AGENTS.md | done |
| Provenance and a post install drift gate for skills and MCP are requested but unbuilt | vercel-labs | security.md and skills.md | done as guidance |
| Plugin and skill isolation security is a one line concern in many repos | wshobson, claude-code | security.md | done |
| Anti over engineering and a before you build gate exist only as prose | rayfernando1337, sanjeed5, wshobson | principles.md and testing-and-evals.md | done |
| Portable self improving memory is wanted across tools | grapeot, PatrickJS | context-engineering.md | done as guidance |

## How to trace a single request

This document is the repo and gap view. For the request level view, where an individual open issue or pull request maps to the exact Foundry rule that answers it, see `COVERAGE.md`.
