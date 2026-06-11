# Community coverage

Foundry is built from the real asks of the field, not a guess at what matters. This map traces a representative request from the top agent tooling repos to the Foundry reference that answers it. Sources are open issues and pull requests on those repos, cited by repo and number. Tool behavior changes, so verify any path or flag against the live client.

Repos mined include anthropics/claude-code, anthropics/skills, vercel-labs/skills, agentsmd/agents.md, modelcontextprotocol, hesreallyhim/awesome-claude-code, wshobson/agents, disler/claude-code-hooks-mastery, davila7/claude-code-templates, PatrickJS/awesome-cursorrules, rayfernando1337/llm-cursor-rules, caliber-ai-org/ai-setup, sanjeed5/awesome-cursor-rules-mdc, grapeot/devin.cursorrules, NeekChaw/RIPER-5, twostraws Swift agent skills, open-gitagent/gitagent, snyk/agent-scan, cline, continue, github/awesome-copilot.

## Hooks

| Community request | Answered in |
|---|---|
| Hook commands must anchor on the project dir, not PWD (caliber#217, caliber#220) | hooks.md, anti-patterns.md |
| Skip hook commands inside nested or tool spawned sessions (caliber#172) | hooks.md |
| Windows path and shell crashes in hook commands (caliber#191 to caliber#200, disler#24) | hooks.md, anti-patterns.md |
| Hook referenced files the target never created (caliber#204) | hooks.md |
| PreToolUse shows error label even on exit 0 (claude-code#17088) | hooks.md, anti-patterns.md |
| PostToolUse does not fire for the Task tool (claude-code#65169) | hooks.md, subagents.md |
| Multi hook PreToolUse order and rewrite visibility unspecified (claude-code#66203) | hooks.md |
| duration_ms missing from PostToolUse docs (claude-code#52607) | hooks.md |
| SessionStart output truncated (claude-code#44086) | hooks.md |
| Session env file accumulates duplicate lines (claude-code#67067) | hooks.md, anti-patterns.md |
| Agent loses path to its own files, cwd assumption (disler#3) | hooks.md, anti-patterns.md |
| Destructive command guard over matches a safe rm (disler#28) | anti-patterns.md |
| Rules shipped with enforcement hooks (PatrickJS#308) | hooks.md, testing-and-evals.md |
| Auto invoke a skill from a SessionStart hook (claude-code#65371) | hooks.md, skills.md |

## Skills

| Community request | Answered in |
|---|---|
| Description as a router so the skill auto triggers (anthropics/skills) | skills.md, anti-patterns.md |
| Support subdirectories inside the skills folder (claude-code#10238, twostraws#19) | skills.md, ARCHITECTURE.md |
| Marketplace plugin skills missing from autocomplete (claude-code#18949) | skills.md, anti-patterns.md |
| A files allowlist in SKILL.md frontmatter (vercel#1241) | skills.md |
| Do not silently drop a skill on a YAML parse error (vercel#1282) | skills.md, anti-patterns.md |
| Skill quality scoring (caliber#73) | testing-and-evals.md |
| Long term skill lifecycle, dedupe and retire (twostraws#18) | skills.md |
| Provenance block in SKILL.md frontmatter (vercel#1391) | skills.md, security.md |
| Agent Skills Manager, install and manage (sanjeed5#40) | skills.md |
| Version still 1.0 in the nested copy, version drift (twostraws#19) | skills.md, ARCHITECTURE.md |

## MCP servers

| Community request | Answered in |
|---|---|
| Tool schema token overhead per session (mcp/spec#2808, mcp/spec#1308) | mcp-servers.md |
| Guidance on server description and instructions (mcp/spec#2146, mcp/spec#2060) | mcp-servers.md |
| Stateful stdio servers are a safety hazard (mcp/spec#823) | mcp-servers.md |
| MCP health checks, discovery, and install (caliber#74, caliber#50) | mcp-servers.md |
| Register in the correct config file, verify live (recurring) | mcp-servers.md, anti-patterns.md |
| Do not auto inject hosted MCP servers (claude-code#20412) | mcp-servers.md, settings-and-config.md |
| Express engine and runtime version in server metadata (mcp/registry#125) | mcp-servers.md |

## Security

| Community request | Answered in |
|---|---|
| Scan MCP servers and skills for malicious instructions (sanjeed5#28, awesome-claude-code#1973, snyk/agent-scan) | security.md |
| Tool poisoning, save and check signatures of tool calls (mcp/registry#82) | security.md, mcp-servers.md |
| Signature verification must not be a stub that claims verified (mcpb#260, mcpb#276) | security.md |
| Bound decompression against a zip bomb (mcpb#266) | security.md, mcp-servers.md |
| Do not pull a local auth token without consent (vercel#1302) | security.md |
| Telemetry off by default, opt in (caliber#146) | security.md |
| Destructive command safety guard (awesome-claude-code#1968) | anti-patterns.md, security.md |
| Subagents and skills do not inherit permissions (claude-code#18950, claude-code#10906) | subagents.md, settings-and-config.md |
| Post install drift gate after the pre install scan (vercel#1222) | security.md |

## Portability

| Community request | Answered in |
|---|---|
| Native AGENTS.md support across assistants (claude-code#6235, claude-code#31005) | portability.md, AGENTS.md |
| Install to the universal path also creates the per assistant symlink (vercel#1355, vercel#1385, vercel#1412) | portability.md, anti-patterns.md |
| Nested skills layout not discovered, one skill installed of many (vercel#1404) | portability.md, ARCHITECTURE.md |
| A merge story for an existing rules file, do not clobber (devin#129) | portability.md |
| Cross platform migration between assistants (caliber#120) | portability.md |
| First class Copilot and OpenCode targets (caliber#115, wshobson#557) | portability.md |
| Lockfile paths must be relative and casing preserved (vercel#1276, vercel#1220) | portability.md |
| AGENTS.md nesting not honored by Copilot (agents.md#153) | portability.md |
| A compatibility matrix per assistant and version (jabrena#810, devin#107) | portability.md |
| Default a marketplace clone to HTTPS not SSH (claude-code#26588, claude-code#14485) | portability.md, settings-and-config.md |

## Settings and config

| Community request | Answered in |
|---|---|
| Pin model and effort level in a config (caliber#75, caliber#80) | settings-and-config.md |
| User defined provider and model, not vendor locked (devin#124) | settings-and-config.md |
| Disable an individual plugin skill (claude-code#14920) | settings-and-config.md |
| settings parent directory traversal for monorepos (claude-code#12962) | settings-and-config.md |
| Match each component of a compound command against permissions (claude-code#16561, claude-code#28240) | settings-and-config.md |
| Installable and uninstallable components with history (davila7#617) | settings-and-config.md |
| Respect the ignore files in a scanner (caliber#221, caliber#218) | settings-and-config.md, portability.md |
| A sync must never delete user files (caliber#210, PanisHandsome#4) | anti-patterns.md, portability.md |

## Subagents and commands

| Community request | Answered in |
|---|---|
| A parallel subagents orchestration pattern (disler#6) | subagents.md |
| A slash command needs a description or it is invisible (wshobson/commands) | commands.md, anti-patterns.md |
| Link a command to the agent it targets (jabrena#821) | commands.md |
| Self improving behavioral skills, the skill forge idea (wshobson#570) | skills.md, context-engineering.md |
| A before you build, pre implementation gate (wshobson#565) | principles.md, testing-and-evals.md |

## Context engineering

| Community request | Answered in |
|---|---|
| A context budget analyzer, measure token cost (caliber#71, sanjeed5#46) | context-engineering.md |
| Avoid prompt too long when generating context (caliber#173) | context-engineering.md |
| Lean context rule, minimize injected content (sanjeed5#47) | context-engineering.md |
| A self maintained lessons and scratchpad memory (grapeot devin pattern, PatrickJS#295) | context-engineering.md |
| Lint CLAUDE.md for bloat (awesome-claude-code#1980) | context-engineering.md |
| Index with globs and ripgrep, do not paste file bodies (rayfernando1337) | context-engineering.md |

## Testing and evals

| Community request | Answered in |
|---|---|
| CI tests for the tooling itself, noop, dry run, missing source, schema (jabrena#824, PanisHandsome#3) | testing-and-evals.md |
| A production readiness gate (PatrickJS#309) | testing-and-evals.md |
| An MCP conformance test suite (mcp/spec#1990) | testing-and-evals.md |
| An AGENTS.md validator (agents.md#147) | testing-and-evals.md |
| Surface instant value, errors prevented (caliber#54) | testing-and-evals.md |

## Principles

| Community request | Answered in |
|---|---|
| A vendor neutral baseline rule for any assistant (PatrickJS#305, instructa#16) | principles.md |
| A phase gate so the agent does not jump ahead (NeekChaw RIPER-5) | principles.md |
| Best code is no code, extend before you build (rayfernando1337) | principles.md, anti-patterns.md |
| Anti over engineering as a checkable gate (sanjeed5#31) | principles.md, testing-and-evals.md |
| Rules that worsen working code, soften the rule (twostraws#14, twostraws#15) | principles.md, anti-patterns.md |
| Correctness, a rule once shipped backwards (twostraws#7) | principles.md |
